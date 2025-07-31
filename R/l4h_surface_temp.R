#' Extracts Land Surface Temperature (LST) from MODIS MOD11A1
#'
#' @description
#' Extracts daytime or nighttime Land Surface Temperature (LST) for a user-defined region
#' and time range using the MODIS MOD11A1.061 product. The function supports summarizing
#' the temperature data over each date using a selected statistic (e.g., mean or median).
#'
#' `r lifecycle::badge('stable')`
#'
#' @param from Character or Date. Start date of the analysis (e.g., `"2020-01-01"`).
#' @param to Character or Date. End date of the analysis (e.g., `"2020-12-31"`).
#' @param region A spatial object defining the region of interest. Accepts an `sf`, `sfc`, or `SpatVector` object.
#' @param band Character. LST type to extract: `"day"` (LST_Day_1km) or `"night"` (LST_Night_1km). Default is `"day"`.
#' @param level Character. Quality filter level to apply to MODIS LST pixels.
#'   Use `"strict"` to retain only high-quality observations (QA bits 0–1 equal to `00`),
#'   or `"moderate"` to allow both high and acceptable quality (QA bits 0–1 equal to `00` or `01`).
#'   Default is `"moderate"`.
#' @param scale Numeric. Spatial resolution in meters. Default is `1000` (native resolution).
#' @param stat Character. Summary statistic to apply per image per region. One of `"mean"`, `"median"`, `"min"`, `"max"`. Passed to `ee_extract()`.
#' @param sf Logical. If `TRUE`, returns an `sf` object; if `FALSE`, returns a `tibble`. Default is `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress bars and messages. Default is `FALSE`.
#' @param force Logical. If `TRUE`, forces the extraction even if results are cached. Default is `FALSE`.
#' @param ... Additional arguments passed to `rgee::ee_extract()`.
#'
#' @return A `sf` or `tibble` object with LST values (in degrees Celsius) extracted from MODIS MOD11A1.
#'
#' @details
#' The MODIS MOD11A1.061 product provides daily Land Surface Temperature and quality information.
#' This function filters out low-quality or cloud-contaminated pixels based on the `QC_Day` or `QC_Night` band.
#' Only pixels where the quality control bits 0–1 equal `00` (high quality) are retained.
#'
#' LST values are originally stored as Kelvin multiplied by 0.02. This function automatically
#' converts them to degrees Celsius using the formula: `LST = (value × 0.02) - 273.15`.
#'
#' @examples
#' \dontrun{
#' library(land4health)
#' ee_Initialize()
#'
#' # Define a bounding box region in Ucayali, Peru
#' region <- st_as_sf(st_sfc(
#'   st_polygon(list(matrix(c(
#'     -74.1, -4.4,
#'     -74.1, -3.7,
#'     -73.2, -3.7,
#'     -73.2, -4.4,
#'     -74.1, -4.4
#'   ), ncol = 2, byrow = TRUE))),
#'   crs = 4326
#' ))
#'
#' # Extract daytime LST for 2020
#' lst_day <- l4h_surface_temp(from = "2020-01-01", to = "2020-12-31",
#'                    region = region, band = "day", stat = "mean")
#' head(lst_day)
#'
#' # Extract nighttime LST
#' lst_night <- l4h_surface_temp(from = "2020-01-01", to = "2020-12-31",
#'                      region = region, band = "night", stat = "mean")
#' head(lst_night)
#' }
#'
#' @references
#' Wan, Z., Hook, S., & Hulley, G. (2015). MOD11A1 MODIS/Terra Land Surface Temperature
#' and Emissivity Daily L3 Global 1km SIN Grid V006 (Version 6.1). NASA EOSDIS Land Processes DAAC.
#' \url{https://doi.org/10.5067/MODIS/MOD11A1.061}
#'
#' MODIS MOD11A1.061 - Google Earth Engine Dataset Catalog.
#' \url{https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD11A1}
#'
#' @export

l4h_surface_temp <- function(from, to, region, band = "day", level = "strict", scale = 1000, stat = "mean", sf = TRUE, quiet = FALSE, force = TRUE, ...){

  # Dataset date range
  start_year <- as.numeric(.internal_data$lst$startyear)
  end_year   <- as.numeric(.internal_data$lst$endyear)

  # Regex para validar formato "YYYY-MM-DD"
  valid_date_format <- function(x) grepl("^\\d{4}-\\d{2}-\\d{2}$", x)

  # Verificar formato antes de convertir
  if (!valid_date_format(from)) {
    cli::cli_abort("Parameter {.field from} must be in 'YYYY-MM-DD' format. Got: {.val {from}}")
  }
  if (!valid_date_format(to)) {
    cli::cli_abort("Parameter {.field to} must be in 'YYYY-MM-DD' format. Got: {.val {to}}")
  }

  # Convertir a Date
  from_date <- as.Date(from)
  to_date   <- as.Date(to)

  # Validar conversiones
  if (is.na(from_date)) {
    cli::cli_abort("Parameter {.field from} could not be parsed as a valid date. Got: {.val {from}}")
  }
  if (is.na(to_date)) {
    cli::cli_abort("Parameter {.field to} could not be parsed as a valid date. Got: {.val {to}}")
  }

  # Validar años en rango permitido
  from_year <- as.numeric(format(from_date, "%Y"))
  to_year   <- as.numeric(format(to_date, "%Y"))

  if (from_year < start_year || to_year > end_year) {
    cli::cli_abort("Years must be in the range {start_year} to {end_year}. Got: {.val {from_year}} to {.val {to_year}}")
  }

  # Validar orden temporal
  if (to_date < from_date) {
    cli::cli_abort("Parameter {.field to} must be greater than or equal to {.field from}")
  }

  # Convertir a fechas Earth Engine
  from_ee <- rgee::rdate_to_eedate(from_date)
  to_ee   <- rgee::rdate_to_eedate(to_date)

  # Define supported classes
  sf_classes <- c("sf", "sfc", "SpatVector")

  # Check input object class
  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object.")
  }

  # Check if region is spatially representative
  if (isFALSE(force)) {
    check_representativity(
      region = region,
      scale = 30
    )
  }

  band <- match.arg(band, choices = c("day", "night"))
  lst_band <- switch(band, day = "LST_Day_1km", night = "LST_Night_1km")
  qc_band <- switch(band, day = "QC_Day", night = "QC_Night")

  collection <- ee$ImageCollection(.internal_data$lst$id)$
    filterDate(from_ee, to_ee)$
    map(rgee::ee_utils_pyfunc(function(img) {
      mask_quality(
        image     = img,
        band      = lst_band,
        qc_band   = qc_band,
        level     = level
      )
    }))$
    toBands()

  # Extract with reducer
  if (isTRUE(sf)) {
    extract_area <- extract_ee_with_progress(
      image = collection,
      sf_region = region,
      scale = scale,
      fun = stat,
      sf = TRUE,
      quiet = quiet,
      ...
    )

    geom_col <- attr(extract_area, "sf_column")
    range_date_original <- seq(as.Date(from_date), as.Date(to_date), by = "1 days")
    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("X"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = sub("^X(\\d{4}_\\d{2}_\\d{2}).*", "\\1", date),
        date = gsub("_", "-", date),
        date = as.Date(date),
        variable = paste0("LST-",band,"-1km")) |>
      dplyr::relocate(c("date", "variable", "value"), .before = all_of(geom_col))

  } else {
    extract_area <- extract_ee_with_progress(
      image = collection,
      sf_region = region,
      scale = scale,
      fun = stat,
      sf = FALSE,
      quiet = quiet,
      ...
    ) |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("X"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = sub("^X(\\d{4}_\\d{2}_\\d{2}).*", "\\1", date),
        date = gsub("_", "-", date),
        date = as.Date(date),
        variable = paste0("LST-",band,"-1km"))

  }
  return(extract_area)
}
