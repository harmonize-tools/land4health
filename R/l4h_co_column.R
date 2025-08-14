#' Extracts carbon monoxide (CO) concentration from Sentinel-5P TROPOMI
#'
#' @description
#' Retrieves the CO column number density (mol/m2) for a user-defined region and date range
#' from the Sentinel‑5P TROPOMI OFFLINE L3 CO dataset.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param from   Character. Start date in `"YYYY-MM-DD"` format (e.g., `"2020-01-01"`).
#' @param to     Character. End date in `"YYYY-MM-DD"` format (e.g., `"2020-12-31"`).
#' @param region A spatial object (`sf`, `sfc`, or `SpatVector`) defining the region of interest.
#' @param stat   Character. Summary statistic to apply (`"mean"`, `"median"`, `"max"`, etc.).
#' @param scale  Numeric. Nominal scale in meters. Default is `1113`.
#' @param sf     Logical. Return result as `sf`? Default: `TRUE`.
#' @param quiet  Logical. Suppress progress messages? Default: `FALSE`.
#' @param force  Logical. Force extract without spatial check? Default: `FALSE`.
#' @param ...        Arguments passed to `rgee::ee_extract`.
#' @return A `sf` or `tibble` containing CO column density (__mol/m2__) by date and geometry.
#'
#' @details
#' The function uses the Earth Engine dataset `COPERNICUS/S5P/OFFL/L3_CO` and selects only the
#' `"CO_column_number_density"` band. It supports summarization using a reducer statistic per image.
#' @section Credits:
#' [![](innovalab.svg)](https://www.innovalab.info/)
#'
#' Pioneering geospatial health analytics and open‐science tools.
#' Developed by the Innovalab Team, for more information send a email to <imt.innovlab@oficinas-upch.pe>
#'
#' Follow us on :
#'  - ![](linkedin-innova.png)[Innovalab Linkedin](https://twitter.com/InnovalabGeo), ![](twitter-innova.png)[Innovalab X](https://x.com/innovalab_imt)
#'  - ![](facebook-innova.png)[Innovalab facebook](https://www.facebook.com/imt.innovalab), ![](instagram-innova.png)[Innovalab instagram](https://www.instagram.com/innovalab_imt/)
#'  - ![](tiktok-innova.png)[Innovalab tiktok](https://twitter.com/InnovalabGeo), ![](spotify-innova.png)[Innovalab Podcast](https://www.innovalab.info/podcast)
#'
#' @examples
#' \dontrun{
#' library(land4health)
#' ee_Initialize()
#'
#' # Define region as a bounding box polygon
#' region <- st_as_sf(st_sfc(
#'   st_polygon(list(matrix(c(
#'     -74.1, -4.4,
#'     -74.1, -3.7,
#'     -73.2, -3.7,
#'     -73.2, -4.4,
#'     -74.1, -4.4
#'   ), ncol = 2, byrow = TRUE))),
#'   crs = 4326
#' )
#'
#' # Run CO column calculation
#' co_data <- l4h_co_column(
#'   from = "2022-01-01",
#'   to = "2022-12-31",
#'   region = region,
#'   stat = "mean"
#' )
#' head(co_data)
#' }
#'
#' @references
#' COPERNICUS/S5P/OFFL/L3_CO. Sentinel‑5P Offline L3 Carbon Monoxide. European Union / ESA / Copernicus.
#' \url{https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S5P_OFFL_L3_CO}
#'
#' @export
l4h_co_column <- function(from, to, region, stat = "mean",
                          scale = 1113, sf = TRUE, quiet = FALSE,
                          force = FALSE, ...) {

  # Dataset date range
  start_year <- as.numeric(.internal_data$co_column$startyear)
  end_year   <- as.numeric(.internal_data$co_column$endyear)

  # Regex para validar formato "YYYY-MM-DD"
  valid_date_format <- function(x) grepl("^\\d{4}-\\d{2}-\\d{2}$", x)

  if (!valid_date_format(from)) {
    cli::cli_abort("Parameter {.field from} must be in 'YYYY-MM-DD' format. Got: {.val {from}}")
  }
  if (!valid_date_format(to)) {
    cli::cli_abort("Parameter {.field to} must be in 'YYYY-MM-DD' format. Got: {.val {to}}")
  }

  from_date <- as.Date(from)
  to_date   <- as.Date(to)

  if (is.na(from_date)) {
    cli::cli_abort("Parameter {.field from} could not be parsed as a valid date. Got: {.val {from}}")
  }
  if (is.na(to_date)) {
    cli::cli_abort("Parameter {.field to} could not be parsed as a valid date. Got: {.val {to}}")
  }

  from_year <- as.numeric(format(from_date, "%Y"))
  to_year   <- as.numeric(format(to_date, "%Y"))

  if (from_year < start_year || to_year > end_year) {
    cli::cli_abort("Years must be in the range {start_year} to {end_year}. Got: {.val {from_year}} to {.val {to_year}}")
  }

  if (to_date < from_date) {
    cli::cli_abort("Parameter {.field to} must be greater than or equal to {.field from}")
  }

  from_ee <- rgee::rdate_to_eedate(from_date)
  to_ee   <- rgee::rdate_to_eedate(to_date)

  # Validar objeto espacial
  sf_classes <- c("sf", "sfc", "SpatVector")

  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object.")
  }

  # Chequeo de representatividad espacial
  if (isFALSE(force)) {
    check_representativity(region = region, scale = scale)
  }

  # Dataset de CO Sentinel-5P
  co_ic <- ee$ImageCollection(.internal_data$co_column$id)$
    filterDate(from_ee, to_ee)$
    select("CO_column_number_density")$
    toBands()

  # Extract with reducer
  if (isTRUE(sf)) {
    extract_co <- extract_ee_with_progress(
      image = co_ic,
      sf_region = region,
      scale = scale,
      fun = stat,
      sf = TRUE,
      quiet = quiet,
      ...
    )

    geom_col <- attr(extract_co, "sf_column")
    range_date_original <- seq(as.Date(from_date), as.Date(to_date), by = "1 days")
    extract_co <- extract_co |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("X"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = sub("^X\\d{8}T\\d+_(\\d{4})(\\d{2})(\\d{2}).*", "\\1-\\2-\\3", date),
        date = as.Date(date),
        variable = "CO_column_density") |>
      dplyr::relocate(c("date", "variable", "value"), .before = all_of(geom_col))

  } else {
    extract_co <- extract_ee_with_progress(
      image = co_ic,
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
        date = sub("^X\\d{8}T\\d+_(\\d{4})(\\d{2})(\\d{2}).*", "\\1-\\2-\\3", date),
        date = as.Date(date),
        variable = "CO_column_density")

  }
  return(extract_co)
}
