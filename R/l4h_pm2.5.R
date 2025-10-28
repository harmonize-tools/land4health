#' Extract Global PM2.5 (monthly) from Google Earth Engine
#'
#' @description
#' Extracts monthly **PM2.5** concentrations for a user-defined region
#' and time range from the Earth Engine Community Catalog dataset
#' **Global PM2.5 (V6GL02 CNN)**. Each monthly image is summarized over the
#' region using a selected statistic (e.g., mean/median). The function returns
#' either an `sf` or a `tibble`, with dates normalized to the **first day
#' of each month**.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param from Character or Date. Start date (`"YYYY-MM-DD"`).
#' @param to Character or Date. End date (`"YYYY-MM-DD"`).
#' @param band Character (kept for API symmetry). The dataset exposes a single band,
#'   currently `'b1'` (PM\eqn{_{2.5}} in µg/m\eqn{^3}). The function selects `'b1'`
#'   internally; this argument is ignored.
#' @param region Spatial object defining the region of interest.
#'   Accepts an `sf`, `sfc`, or `SpatVector` object.
#' @param scale Numeric. Reducer scale in meters. Default `1000`.
#'   (Use a value close to the dataset's native grid; typical choices are a few km.)
#' @param stat Character. Summary statistic per image per region. One of
#'   `"mean"`, `"median"`, `"min"`, `"max"`.
#' @param sf Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`.
#'   Default `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress bars/messages. Default `FALSE`.
#' @param force Logical. If `TRUE`, forces extraction even if cached results exist.
#'   Default `TRUE`.
#' @param ... Additional arguments passed to the extraction backend.
#'
#' @return An `sf` or `tibble` with columns:
#'   - `date` (`Date`) — first day of the month,
#'   - `variable` (`character`) — fixed as `"pm2.5"`,
#'   - `value` (`numeric`) — PM2.5 in **µg/m\eqn{^3}**,
#'   plus geometry if `sf = TRUE`, and any attributes from `region`.
#'
#' @details
#' This function queries the Global PM2.5 monthly product (V6GL02, CNN‐based fusion)
#' from the **GEE Community Catalog** and aggregates it over the provided region and dates.
#' The dataset provides monthly surface PM2.5 concentrations (µg/m\eqn{^3}).
#' Values are returned in native units (no extra scale factor is applied here).
#'
#' **Notes**
#' - Dates are validated (`YYYY-MM-DD`) and constrained to the dataset range used
#'   in this package (default: 2000–2019).
#' - Output dates are normalized to the first day of each month found in the bands.
#' - The function expects a reasonable `scale` relative to the dataset resolution
#'   to avoid oversampling or excessive smoothing.
#'
#' @section Credits:
#' [![](innovalab.svg)](https://www.innovalab.info/)
#'
#' Pioneering geospatial health analytics and open‐science tools.
#' Developed by the Innovalab Team, for more information send a email to <imt.innovlab@oficinas-upch.pe>
#'
#' Follow us on :
#'  - ![](linkedin-innova.png)[Innovalab Linkedin](https://www.linkedin.com/company/innovalab-imt), ![](twitter-innova.png)[Innovalab X](https://x.com/innovalab_imt)
#'  - ![](facebook-innova.png)[Innovalab facebook](https://www.facebook.com/imt.innovalab), ![](instagram-innova.png)[Innovalab instagram](https://www.instagram.com/innovalab_imt/)
#'  - ![](tiktok-innova.png)[Innovalab tiktok](https://www.tiktok.com/@innovalab_imt), ![](spotify-innova.png)[Innovalab Podcast](https://www.innovalab.info/podcast)
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(land4health)
#' rgee::ee_Initialize()
#'
#' # ROI simple (EPSG:4326)
#' region <- st_as_sf(st_sfc(
#'   st_polygon(list(matrix(c(
#'     -74.1, -4.4,
#'     -74.1, -3.7,
#'     -73.2, -3.7,
#'     -73.2, -4.4,
#'     -74.1, -4.4
#'   ), ncol = 2, byrow = TRUE))), crs = 4326))
#'
#' # PM2.5 mensual (µg/m^3) para 2010, promedio espacial
#' out_pm <- l4h_pm2.5(
#'   from   = "2010-01-01",
#'   to     = "2010-12-31",
#'   band   = "b1",        # ignorado (única banda)
#'   region = region,
#'   stat   = "mean",
#'   scale  = 3000
#' )
#' head(out_pm)
#' }
#'
#' @references
#' GEE Community Catalog – Global PM2.5 (V6GL02 CNN).
#' \url{https://gee-community-catalog.org/projects/global_pm25/}
#'
#' @export



l4h_pm2.5 <- function(from, to, band, region, scale = 1000, stat = "mean", sf = TRUE, quiet = FALSE, force = TRUE, ...){

  # Dataset date range
  start_year <- '2000-01-01'
  end_year   <- '2019-12-31'

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

  collection <- ee$ImageCollection(.internal_data$pm2.5$id)$
    select('b1')$
    filterDate(from_ee, to_ee)$
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
    range_date_original <- seq(as.Date(from_date), as.Date(to_date), by = "1 months")
    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("V6GL02"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        variable = "pm2.5",
        date = paste0(regmatches(variable, regexpr("\\d{6}", variable)),'01'),
        date = as.Date(date, format = "%Y%m%d")) |>
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
        cols = tidyr::starts_with("V6GL02"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        variable = "pm2.5",
        date = paste0(regmatches(variable, regexpr("\\d{6}", variable)),'01'),
        date = as.Date(date, format = "%Y%m%d"))
  }
  return(extract_area)
}
