#' Reading a csv containing geoidep resources
#' @importFrom utils read.csv2
#' @keywords internal
get_data <- function(){
  url <- system.file("exdata", "sources.csv", package = "land4health")
  data <- read.csv2(url) |> tidyr::as_tibble()
  return(data)
}

#' Internal: Get an Earth Engine reducer
#' Returns a reducer object (e.g., `ee$Reducer$mean()`) based on a string name.
#' @param name A string: one of `"mean"`, `"sum"`, `"min"`, `"max"`, `"median"`, `"stdDev"` and `"first"`
#' @return An Earth Engine reducer object.
#' @keywords internal
get_reducer <- function(name) {
  reducers <- c(
    "mean" = "mean",
    "sum" = "sum",
    "min" = "min",
    "max" = "max",
    "median" = "median",
    "sd" = "stdDev",
    "first" = "first"
  )

  if (!name %in% names(reducers)) {
    cli::cli_abort("Reducer '{name}' is not valid. Valid options are: {paste(names(reducers), collapse = ', ')}")
  }

  reducer_name <- reducers[[name]]
  do.call(rgee::ee$Reducer[[reducer_name]], list())
}

#' Evaluates whether a given polygon covers a minimum number of valid pixels
#' in a specified Earth Engine image.
#' @param region An `sf` polygon object representing the area of interest.
#' @param scale Numeric. Pixel resolution in meters (e.g., 30 for Hansen).
#' @return Invisible `TRUE` if all polygons cover at least 1 pixel;
#'   otherwise invisible `FALSE` with a `cli` warning reporting how many
#'   polygons fall below 1 pixel. Extraction is never stopped; use `force = TRUE`
#'   in the calling `l4h_*` function to skip this check entirely.
#' @keywords internal
check_representativity <- function(region, scale = 30) {
  if (!inherits(region, "sf")) {
    cli::cli_abort("The {.arg region} must be an {.cls sf} object.")
  }

  # Area of every polygon in km2 (R base + sf, no dplyr)
  areas_km2 <- as.numeric(sf::st_area(sf::st_transform(region, crs = 3857)) / 1e6)

  # Area of 1 pixel in km2
  pixel_area <- (scale^2) / 1e6

  n <- length(areas_km2)
  n_bad <- sum(areas_km2 < pixel_area, na.rm = TRUE)

  # Inform only: never abort, `force` in callers controls skipping
  if (n_bad > 0) {
    cli::cli_warn(c(
      "!" = "The region does not cover enough pixels to be representative.",
      "i" = "Pixel area required: {round(pixel_area, 4)} km2 at {scale} m resolution.",
      "x" = "{n_bad} of {n} polygons fall below 1 pixel. Smallest covers {round(min(areas_km2, na.rm = TRUE), 4)} km2."
    ))
    return(invisible(FALSE))
  }

  invisible(TRUE)
}

#' Split an sf object into a list of single-row sf objects
#' @param sf_region An object of class `sf` representing multiple geometries.
#' @return A list of single-row `sf` objects.
#' @keywords internal
split_sf <- function(sf_region) {
  if (!inherits(sf_region, "sf")) {
    cli::cli_abort("`sf_region` must be an {.pkg sf} object.")
  }

  lapply(seq_len(nrow(sf_region)), function(i) sf_region[i, , drop = FALSE])
}


#' Extract Earth Engine data with a progress bar
#' @param image An Earth Engine Image object (from `rgee`).
#' @param sf_region An `sf` object containing regions to extract.
#' @param scale Numeric. Scale in meters for extraction.
#' @param fun A reducer function, e.g. `ee$Reducer$mean()`.
#' @param sf Logical. Should the function return an sf object?
#' @param quiet Logical. If TRUE, suppress the progress bar (default FALSE).
#' @param via Character. Either "getInfo" or "drive".
#' @param ... arguments of `ee_extract` of `rgee` packages.
#' @return An `sf` or  `data.frame` object.
#' @keywords internal
extract_ee_with_progress <- function(
    image,
    sf_region,
    scale,
    fun,
    sf,
    quiet = FALSE,
    via = "getInfo",
    ...
) {
  geoms <- split_sf(sf_region)

  # cli progress bar unless suppressed (or nothing to extract).
  # `tick()` is a no-op when quiet, so the loop below never branches.
  show_bar <- !quiet && length(geoms) > 0
  tick <- function() {}

  if (show_bar) {
    cli::cli_progress_bar("Extracting data", total = length(geoms))
    # Advances the current bar by one step
    tick <- function() cli::cli_progress_update()
  }

  if (inherits(sf_region, "sf")) {
    if (!suppressPackageStartupMessages(requireNamespace("geojsonio", quietly = TRUE))) {
      cli::cli_abort(
        "{.pkg geojsonio} is required when passing {.cls sf} objects to {.fun rgee::ee_extract}.
       Install it with: install.packages('geojsonio')."
      )
    }
  }
  results <- lapply(geoms, function(feat) {
    out <- suppressPackageStartupMessages(rgee::ee_extract(
      x     = image,
      y     = feat,
      scale = scale,
      fun   = get_reducer(name = fun),
      sf    = sf,
      via   = via,
      quiet = TRUE,
      ...
    ))
    tick()   # <- no-op when quiet, otherwise advances the cli bar
    out
  })

  if (show_bar) cli::cli_progress_done()

  if (length(results) == 0) return(dplyr::tibble())
  dplyr::bind_rows(results)
}


#' @keywords internal
#' @noRd
`%||%` <- function(x, y) {
  if (!is.null(x)) x else y
}

#' @keywords internal
#' @noRd
calculate_area <- function(mask) {
  mask$
    reproject('EPSG:4326', NULL, 1000)$
    multiply(ee$Image$pixelArea())$
    divide(1e6)
}

#' @keywords internal
#' @noRd
bitwiseExtract <- function(value, fromBit, toBit = fromBit) {
  maskSize <- ee$Number(1)$add(toBit)$subtract(fromBit)
  mask <- ee$Number(1)$leftShift(maskSize)$subtract(1)
  value$rightShift(fromBit)$bitwiseAnd(mask)
}

#' @keywords internal
#' @noRd
mask_quality <- function(image, band, qc_band, level = c("strict", "moderate")) {
  level <- match.arg(level)
  qc  <- image$select(qc_band)
  lst <- image$select(band)
  quality_flag <- bitwiseExtract(qc, 0, 1)
  mask <- switch(level,strict = quality_flag$eq(0),moderate = quality_flag$lte(1))
  lst$updateMask(mask)$multiply(0.02)$subtract(273.15)$rename(band)$reproject('EPSG:4326', NULL, 1000)
}

#' Global variables for get_early_warning
#' This code declares global variables used in the some function to avoid R CMD check warnings.
#' @name global-variables
#' @keywords internal
utils::globalVariables(
  c(
    "provider",
    "category",
    "ee",
    "year",
    "area_km2",
    "b1",
    "rai_index",
    "population",
    "accessibility",
    "water_coverage",
    "geom_col",
    "water_proportion",
    "modis_img",
    "fecha",
    "month",
    "quiet",
    "variable",
    "value",
    "all_of",
    "tick",
    ".find_python",
    "date",
    "value_rural",
    "suhi",
    "value_urban",
    "count",
    "dengue_total",
    "adm_0_name",
    "adm_1_name",
    "adm_2_name",
    "calendar_end_date",
    "calendar_start_date",
    "read.csv",
    "version",
    "file_name",
    "band_info",
    "adist",
    "band_raw"
  )
)

# Internal function to create environment loader
.create_env_loader <- function(env_name, env_method) {
  # Create a temporary file to store environment info
  config_dir <- rappdirs::user_config_dir("land4health")

  if (!dir.exists(config_dir)) {
    dir.create(config_dir, recursive = TRUE)
  }

  config_file <- file.path(config_dir, "python_env.rds")

  env_config <- list(
    envname = env_name,
    method = env_method,
    timestamp = Sys.time()
  )

  saveRDS(env_config, config_file)

  cli::cli_alert_success("Environment configuration saved")
}

# Internal function to load environment config
.load_env_config <- function() {
  config_file <- file.path(rappdirs::user_config_dir("land4health"), "python_env.rds")

  if (file.exists(config_file)) {
    return(readRDS(config_file))
  }

  return(NULL)
}

#' Convert sf to GeoJSON (internal)
#' @keywords internal
as_geojson_min <- function(x) {
  # Asegura WGS84 porque EE y GeoJSON esperan lon/lat
  x <- sf::st_transform(x, 4326)
  # Carga diferida con mensajes suprimidos: geojsonio arrastra
  # geojson + geojsonsf y dispara "Registered S3 method overwritten"
  # si se cargara al hacer library(land4health). Al estar en Suggests
  # solo se carga aqui, y suprimido.
  if (!requireNamespace("geojsonio", quietly = TRUE)) {
    cli::cli_abort(
      "{.pkg geojsonio} is required. Install it with: install.packages('geojsonio')."
    )
  }
  suppressPackageStartupMessages(geojsonio::geojson_json(x))
}

