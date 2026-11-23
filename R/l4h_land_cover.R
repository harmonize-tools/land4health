#' Extract land-cover area by class from GLC-FCS30D
#'
#' @description
#' Calculates the area in square kilometers of each selected land-cover class
#' within a region for each year between 2000 and 2022. The annual
#' GLC-FCS30D product is mapped at 30 m resolution.
#'
#' \if{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.png}{options: width="120"}
#' }}
#' \if{latex}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.pdf}{options: width=2cm}
#' }}
#'
#' @param from Character. Start date in `"YYYY-MM-DD"` format; the year is used.
#' @param to Character. End date in `"YYYY-MM-DD"` format; the year is used.
#' @param region An `sf`, `sfc`, or `SpatVector` object defining the region.
#' @param cover_type Optional character or numeric vector of land-cover class
#'   names or codes. `NULL` (the default) returns all 35 mapped classes.
#'   Fill values are not included.
#' @param scale Numeric. Extraction scale in meters. Default is 30.
#' @param sf Logical. If `TRUE`, return an `sf` object; otherwise return a
#'   tibble. Default is `TRUE`.
#' @param quiet Logical. If `TRUE`, suppress the extraction progress bar.
#'   Default is `FALSE`.
#' @param force Logical. If `TRUE`, skip the representativity check.
#'   Default is `FALSE`.
#' @param ... Additional arguments passed to `l4h_ee_extract()`.
#'
#' @return An `sf` object or tibble with `date`, `cover_type`, `class_code`,
#'   and `area_km2` columns, plus the region attributes (and geometry when
#'   `sf = TRUE`).
#'
#' @details
#' The date arguments must fall between 2000 and 2022. They are used to select
#' annual classification bands; the returned `date` is January 1 of each
#' selected year. The GLC-FCS30D fill value (class code 0) is excluded.
#'
#' Class names and codes:
#' \itemize{
#'   \item 10, 11, 12, 20: rainfed, herbaceous-cover, orchard, and irrigated cropland.
#'   \item 51, 52, 61, 62, 71, 72, 81, 82, 91, 92: broadleaved, needle-leaved,
#'     deciduous, evergreen, and mixed forests.
#'   \item 120, 121, 122: shrubland, evergreen shrubland, and deciduous shrubland.
#'   \item 130, 140, 150, 152, 153: grassland, lichens and mosses, and sparse
#'     vegetation classes.
#'   \item 181, 182, 183, 184, 185, 186, 187: swamp, marsh, flooded flat,
#'     saline, mangrove, salt marsh, and tidal flat.
#'   \item 190, 200, 201, 202, 210, 220: impervious surfaces, bare areas,
#'     water body, and permanent ice and snow.
#' }
#'
#' @examples
#' \donttest{
#' if (interactive()) {
#'   rgee::ee_Initialize()
#'
#'   region <- sf::st_as_sf(sf::st_sfc(
#'     sf::st_polygon(list(matrix(c(
#'       -74.1, -4.4, -74.1, -3.7, -73.2, -3.7,
#'       -73.2, -4.4, -74.1, -4.4
#'     ), ncol = 2, byrow = TRUE))),
#'     crs = 4326
#'   ))
#'
#'   # Area by all classes and years from 2018 to 2022
#'   all_classes <- l4h_land_cover(
#'     from = "2018-01-01",
#'     to = "2022-12-31",
#'     region = region
#'   )
#'
#'   # Select specific classes by name or class code
#'   forest_and_water <- l4h_land_cover(
#'     from = "2018-01-01",
#'     to = "2022-12-31",
#'     region = region,
#'     cover_type = c("Closed evergreen broadleaved forest", 210)
#'   )
#' }
#' }
#'
#' @references
#' - Zhang, X. et al. (2024). GLC_FCS30D: the first global 30 m land-cover
#'   dynamics monitoring product with a fine classification system for 1985–2022.
#'   *Earth System Science Data*, 16, 1353–1381.
#'   \doi{10.5194/essd-16-1353-2024}
#' - GLC-FCS30D Earth Engine Community Catalog:
#'   \url{https://gee-community-catalog.org/projects/glc_fcs/}
#' - Earth Engine asset:
#'   \code{projects/sat-io/open-datasets/GLC-FCS30D/annual}
#'
#' @export
l4h_land_cover <- function(from, to, region, cover_type = NULL,
                           scale = 30, sf = TRUE, quiet = FALSE,
                           force = FALSE, ...) {
  valid_date <- function(x, arg) {
    if (!is.character(x) || length(x) != 1L || is.na(x) ||
        !grepl("^\\d{4}-\\d{2}-\\d{2}$", x)) {
      cli::cli_abort(
        "Parameter {.field {arg}} must be a single date in {.val YYYY-MM-DD} format."
      )
    }

    date <- suppressWarnings(as.Date(x, format = "%Y-%m-%d"))
    if (is.na(date) || format(date, "%Y-%m-%d") != x) {
      cli::cli_abort(
        "Parameter {.field {arg}} is not a valid date: {.val {x}}."
      )
    }
    date
  }

  from_date <- valid_date(from, "from")
  to_date <- valid_date(to, "to")
  from_year <- as.integer(format(from_date, "%Y"))
  to_year <- as.integer(format(to_date, "%Y"))

  if (from_date > to_date) {
    cli::cli_abort("Parameter {.arg to} must be greater than or equal to {.arg from}.")
  }
  if (from_year < 2000L || to_year > 2022L) {
    cli::cli_abort(
      "Years must be in the range 2000 to 2022. Got: {.val {from_year}} to {.val {to_year}}."
    )
  }

  classes <- data.frame(
    class_code = c(
      10L, 11L, 12L, 20L, 51L, 52L, 61L, 62L, 71L, 72L, 81L, 82L,
      91L, 92L, 120L, 121L, 122L, 130L, 140L, 150L, 152L, 153L,
      181L, 182L, 183L, 184L, 185L, 186L, 187L, 190L, 200L, 201L,
      202L, 210L, 220L
    ),
    cover_type = c(
      "Rainfed cropland",
      "Herbaceous cover cropland",
      "Tree or shrub cover (orchard) cropland",
      "Irrigated cropland",
      "Open evergreen broadleaved forest",
      "Closed evergreen broadleaved forest",
      "Open deciduous broadleaved forest",
      "Closed deciduous broadleaved forest",
      "Open evergreen needle-leaved forest",
      "Closed evergreen needle-leaved forest",
      "Open deciduous needle-leaved forest",
      "Closed deciduous needle-leaved forest",
      "Open mixed leaf forest",
      "Closed mixed leaf forest",
      "Shrubland",
      "Evergreen shrubland",
      "Deciduous shrubland",
      "Grassland",
      "Lichens and mosses",
      "Sparse vegetation",
      "Sparse shrubland",
      "Sparse herbaceous",
      "Swamp",
      "Marsh",
      "Flooded flat",
      "Saline",
      "Mangrove",
      "Salt marsh",
      "Tidal flat",
      "Impervious surfaces",
      "Bare areas",
      "Consolidated bare areas",
      "Unconsolidated bare areas",
      "Water body",
      "Permanent ice and snow"
    ),
    stringsAsFactors = FALSE
  )

  if (is.null(cover_type)) {
    selected_classes <- classes
  } else {
    if ((!is.character(cover_type) && !is.numeric(cover_type)) ||
        length(cover_type) == 0L || anyNA(cover_type)) {
      cli::cli_abort(
        "{.arg cover_type} must be {.code NULL}, or a non-empty vector of class names or codes."
      )
    }

    requested <- trimws(as.character(cover_type))
    code_index <- match(requested, as.character(classes$class_code))
    name_index <- match(tolower(requested), tolower(classes$cover_type))
    class_index <- ifelse(!is.na(code_index), code_index, name_index)

    if (anyNA(class_index)) {
      cli::cli_abort(
        "Unknown {.arg cover_type}: {.val {paste(requested[is.na(class_index)], collapse = ', ')}}. Use a mapped class name or code."
      )
    }
    if (anyDuplicated(class_index)) {
      cli::cli_abort("{.arg cover_type} cannot contain duplicate classes.")
    }
    selected_classes <- classes[class_index, , drop = FALSE]
  }

  if (!is.numeric(scale) || length(scale) != 1L || is.na(scale) ||
      !is.finite(scale) || scale <= 0) {
    cli::cli_abort("{.arg scale} must be a positive finite number.")
  }
  if (!is.logical(sf) || length(sf) != 1L || is.na(sf)) {
    cli::cli_abort("{.arg sf} must be TRUE or FALSE.")
  }

  sf_classes <- c("sf", "sfc", "SpatVector")
  if (!inherits(region, sf_classes)) {
    cli::cli_abort(
      "{.arg region} must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object."
    )
  }
  if (inherits(region, "SpatVector")) {
    region <- sf::st_as_sf(region)
  } else if (inherits(region, "sfc")) {
    region <- sf::st_sf(geometry = region)
  }
  if (nrow(region) == 0L || is.na(sf::st_crs(region))) {
    cli::cli_abort("{.arg region} must contain geometries with a defined CRS.")
  }

  if (isFALSE(force)) {
    check_representativity(region = region, scale = scale)
  }
  check_ee_initialized()

  years <- seq.int(from_year, to_year)
  annual_cover <- ee$ImageCollection(
    "projects/sat-io/open-datasets/GLC-FCS30D/annual"
  )$mosaic()

  area_image <- NULL
  band_names <- character()
  for (year in years) {
    classification <- annual_cover$select(paste0("b", year - 1999L))
    for (class_code in selected_classes$class_code) {
      band_name <- paste0("area_y", year, "_c", class_code)
      area_band <- classification$eq(class_code)$
        multiply(ee$Image$pixelArea())$
        divide(1e6)$
        rename(band_name)

      area_image <- if (is.null(area_image)) {
        area_band
      } else {
        area_image$addBands(area_band)
      }
      band_names <- c(band_names, band_name)
    }
  }

  extracted <- l4h_ee_extract(
    image = area_image,
    sf_region = region,
    scale = scale,
    fun = "sum",
    sf = sf,
    quiet = quiet,
    ...
  )

  missing_bands <- setdiff(band_names, names(extracted))
  if (length(missing_bands)) {
    cli::cli_abort(
      "Earth Engine did not return expected land-cover band(s): {.val {paste(missing_bands, collapse = ', ')}}."
    )
  }

  extracted |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(band_names),
      names_to = "band",
      values_to = "area_km2"
    ) |>
    dplyr::mutate(
      year = as.integer(sub("^area_y([0-9]{4})_c[0-9]+$", "\\1", band)),
      class_code = as.integer(sub("^area_y[0-9]{4}_c([0-9]+)$", "\\1", band)),
      date = as.Date(paste0(year, "-01-01")),
      cover_type = selected_classes$cover_type[
        match(class_code, selected_classes$class_code)
      ],
      area_km2 = as.numeric(area_km2)
    ) |>
    dplyr::select(-"band", -"year") |>
    dplyr::relocate(
      dplyr::all_of(c("date", "cover_type", "class_code", "area_km2")),
      .before = 1
    )
}
