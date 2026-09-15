#' Reading a csv containing geoidep resources
#' @importFrom utils read.csv2
#' @keywords internal
get_data <- function(){
  url <- system.file("exdata", "sources.csv", package = "land4health")
  data <- read.csv2(url) |> tidyr::as_tibble()
  return(data)
}

#' Internal: Check that Earth Engine is initialized
#' @keywords internal
check_ee_initialized <- function() {
  ee <- tryCatch(rgee::ee, error = function(e) NULL)
  if (is.null(ee)) {
    cli::cli_abort(c(
      "x" = "The {.pkg rgee} package is not loaded.",
      "i" = "Run {.code library(rgee)} and then {.code rgee::ee_Initialize()} before using GEE functions."
    ))
  }
  initialized <- tryCatch({
    ee$Number(1)$getInfo()
    TRUE
  }, error = function(e) FALSE)
  if (!initialized) {
    cli::cli_abort(c(
      "x" = "Earth Engine is not initialized.",
      "i" = "Run {.code rgee::ee_Initialize()} before using GEE functions."
    ))
  }
}

#' Internal: Safe toBands with band count check
#' @param collection An ee$ImageCollection.
#' @param max_bands Maximum allowed bands. Default 5000.
#' @return An ee$Image with named bands.
#' @keywords internal
safe_toBands <- function(collection, max_bands = 5000) {
  n <- collection$size()$getInfo()
  if (n > max_bands) {
    cli::cli_abort(c(
      "x" = "The ImageCollection has {.val {n}} images, exceeding the limit of {.val {max_bands}} bands for {.fn toBands}.",
      "i" = "Use a shorter date range or coarser temporal aggregation (e.g., {.arg by = \"month\"} or {.arg by = \"annual\"})."
    ))
  }
  collection$toBands()
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
    "geom_col",
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
    "band_raw",
    ".row_id",
    "id",
    "band"
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

#' Internal Earth Engine data extraction (Optimized)
#'
#' Transfers geometries to Earth Engine and extracts statistics using direct
#' invocations of the reduceRegions method to avoid earthengine-api incompatibilities.
#'
#' @param image An \code{ee$Image} or \code{ee$ImageCollection} object.
#' @param sf_region An \code{sf} or \code{sfc} object containing the regions of interest.
#' @param scale Spatial resolution in meters. If \code{NULL}, the native resolution is used.
#' @param fun Reducer name (\code{"mean"}, \code{"sum"}, etc.) or an \code{ee$Reducer} object.
#' @param sf Logical. If \code{TRUE}, returns an \code{sf} object; if \code{FALSE}, a \code{tibble}.
#' @param tile_scale Scale factor for internal EE subdivisions (1 to 16). Default is 1.
#' @param quiet Logical. If \code{TRUE}, suppresses the progress bar. Default is \code{FALSE}.
#' @param force Logical. If \code{FALSE}, evaluates representativeness before processing.
#' @param ... Additional arguments passed internally to \code{rgee::sf_as_ee}.
#'
#' @return An \code{sf} or \code{tbl_df} (\code{data.frame}) object with the extracted data.
#' @keywords internal
l4h_ee_extract <- function(image,
                           sf_region,
                           scale = NULL,
                           fun = "mean",
                           sf = TRUE,
                           tile_scale = 1,
                           quiet = FALSE,
                           force = FALSE,
                           ...) {

  # 0. Check Earth Engine is initialized
  check_ee_initialized()

  # 1. Geometry validation
  sf_classes <- c("sf", "sfc", "SpatVector")
  if (!inherits(sf_region, sf_classes)) {
    cli::cli_abort("Parameter {.arg sf_region} must be an object of class {.cls sf}, {.cls sfc}, or {.cls SpatVector}.")
  }

  if (inherits(sf_region, "SpatVector")) {
    sf_region <- sf::st_as_sf(sf_region)
  }

  # Evaluate representativeness using check_representativity
  if (isFALSE(force) && !is.null(scale)) {
    check_representativity(region = sf_region, scale = scale)
  }

  # 2. Convert 'fun' to ee$Reducer using get_reducer()
  ee_reducer <- if (is.character(fun)) {
    get_reducer(name = fun)
  } else if (inherits(fun, "ee.reducer.Reducer")) {
    fun
  } else {
    cli::cli_abort("Parameter {.arg fun} must be a string (e.g. 'mean') or an {.cls ee$Reducer} object.")
  }

  # 3. Normalize raster (ImageCollection to multiband Image if applicable)
  if (inherits(image, "ee.imagecollection.ImageCollection")) {
    image <- safe_toBands(image)
  } else if (!inherits(image, "ee.image.Image")) {
    cli::cli_abort("Parameter {.arg image} must be an {.cls ee.Image} or {.cls ee.ImageCollection} object.")
  }

  # 4. Split geometries and configure progress bar
  geoms <- split_sf(sf_region)
  show_bar <- !quiet && length(geoms) > 0
  tick <- function() {}
  bar_id <- NULL

  if (show_bar) {
    bar_id <- cli::cli_progress_bar("Extracting Earth Engine data", total = length(geoms))
    tick <- function() cli::cli_progress_update(id = bar_id)
  }

  # 5. Extract by geometries
  results <- lapply(geoms, function(feat) {
    ee_y <- rgee::sf_as_ee(feat, quiet = TRUE, ...)

    reduce_args <- list(
      collection = ee_y,
      reducer    = ee_reducer,
      tileScale  = as.integer(tile_scale)
    )

    if (!is.null(scale)) {
      reduce_args$scale <- as.numeric(scale)
    }

    # Direct invocation (avoids the 'image = img' failure)
    ee_reduced <- do.call(image$reduceRegions, reduce_args)

    out <- if (isTRUE(sf)) {
      rgee::ee_as_sf(ee_reduced, quiet = TRUE)
    } else {
      sf_obj <- rgee::ee_as_sf(ee_reduced, quiet = TRUE)
      sf::st_drop_geometry(sf_obj)
    }

    tick()
    out
  })

  if (show_bar) cli::cli_progress_done(id = bar_id)

  if (length(results) == 0) return(dplyr::tibble())

  dplyr::bind_rows(results)
}
