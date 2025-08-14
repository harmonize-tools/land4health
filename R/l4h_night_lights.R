#' Extracts global night‑time lights using harmonized DMSP‑OLS and VIIRS data
#'
#' @description
#' Retrieves annual night‑time light radiance (average radiance, nanoWatt/sr/cm²) from the
#' Harmonized Global Night Time Lights dataset for a user-defined region and time range.
#' The dataset harmonizes DMSP-OLS (1992‑2013) with VIIRS‑like data (2014‑2021), ensuring
#' consistent long-term time series at ~1km resolution.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param from Character. Start date in `"YYYY-MM-DD"` format (only the year is used).
#' @param to Character. End date in `"YYYY-MM-DD"` format (only the year is used).
#' @param region A spatial object (`sf`, `sfc`, or `SpatVector`) defining the region of interest.
#' @param stat Character. Summary statistic to apply per year per region (e.g. `"mean"`, `"sum"`).
#' @param scale Numeric. Nominal scale in meters (default `1000`).
#' @param sf Logical. If `TRUE`, return as `sf`; if `FALSE`, return as `tibble`. Default `TRUE`.
#' @param quiet Logical. If `TRUE`, suppress progress messages. Default `FALSE`.
#' @param force Logical. If `TRUE`, skip representativity check. Default `FALSE`.
#' @param ... Additional arguments passed to `rgee::ee_extract()`.
#'
#' @return A `sf` or `tibble` with annual night‑time light statistics per region and date.
#'
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
#' library(sf)
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
#' # Extract only DMSP-OLS data (1998–2010)
#' ntl_dmsp <- l4h_night_lights(
#'   from = "1998-01-01",
#'   to = "2010-12-31",
#'   region = region,
#'   stat = "mean"
#' )
#' head(ntl_dmsp)
#'
#' # Extract only VIIRS data (2016–2021)
#' ntl_viirs <- l4h_night_lights(
#'   from = "2016-01-01",
#'   to = "2021-12-31",
#'   region = region,
#'   stat = "mean"
#' )
#' head(ntl_viirs)
#'
#' # Extract both DMSP and VIIRS (2008–2020)
#' ntl_mixed <- l4h_night_lights(
#'   from = "2008-01-01",
#'   to = "2020-12-31",
#'   region = region,
#'   stat = "mean"
#' )
#' head(ntl_mixed)
#' }
#' @export
l4h_night_lights <- function(from, to, region, stat = "mean",
                             scale = 1000, sf = TRUE, quiet = FALSE,
                             force = FALSE, ...) {
  # Dataset year range
  start_year <- 1992
  end_year   <- 2021

  # Validar formato de fecha (YYYY-MM-DD)
  valid_date_format <- function(x) grepl("^\\d{4}-\\d{2}-\\d{2}$", x)

  if (!valid_date_format(from)) {
    cli::cli_abort("Parameter {.field from} must be in 'YYYY-MM-DD' format. Got: {.val {from}}")
  }
  if (!valid_date_format(to)) {
    cli::cli_abort("Parameter {.field to} must be in 'YYYY-MM-DD' format. Got: {.val {to}}")
  }

  # Convertir a Date
  from_date <- as.Date(from)
  to_date   <- as.Date(to)

  if (is.na(from_date) || is.na(to_date)) {
    cli::cli_abort("Dates must be valid 'YYYY-MM-DD'. Got: {.val {from}}, {.val {to}}")
  }

  if (to_date < from_date) {
    cli::cli_abort("Parameter {.field to} must be greater than or equal to {.field from}")
  }

  # Extraer años
  from_year <- as.integer(format(from_date, "%Y"))
  to_year   <- as.integer(format(to_date, "%Y"))

  if (from_year < start_year || to_year > end_year) {
    cli::cli_abort("Years must be in the range {start_year} to {end_year}. Got: {.val {from_year}} to {.val {to_year}}")
  }

  # Validar objeto espacial
  sf_classes <- c("sf", "sfc", "SpatVector")

  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object.")
  }

  if (isFALSE(force)) {
    check_representativity(region = region, scale = scale)
  }

  # Crear colección según rango de años
  if (to_year <= 2013) {
    collection <- ee$ImageCollection(.internal_data$night_lights_dmsp$id)$
      filter(ee$Filter$calendarRange(from_year, to_year, "year"))
  } else if (from_year >= 2014) {
    collection <- ee$ImageCollection(.internal_data$night_lights_viirs$id)$
      filter(ee$Filter$calendarRange(from_year, to_year, "year"))
  } else {
    dmsp  <- ee$ImageCollection(.internal_data$night_lights_dmsp$id)$
      filter(ee$Filter$calendarRange(from_year, 2013, "year"))
    viirs <- ee$ImageCollection(.internal_data$night_lights_viirs$id)$
      filter(ee$Filter$calendarRange(2014, to_year, "year"))
    collection <- dmsp$merge(viirs)
  }

  # Seleccionar la banda de interés
  collection <- collection$select("b1")$toBands()

  # Extract with reducer
  if (isTRUE(sf)) {
    extract_nlight <- extract_ee_with_progress(
      image = collection,
      sf_region = region,
      scale = scale,
      fun = stat,
      sf = TRUE,
      quiet = quiet,
      ...
    )

    geom_col <- attr(extract_nlight, "sf_column")
    range_date_original <- seq(as.Date(from_date), as.Date(to_date), by = "1 days")
    extract_nlight <- extract_nlight |>
      tidyr::pivot_longer(
        cols = grep("Harmonized_DN_NTL", names(extract_nlight), value = TRUE),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        provider = dplyr::case_when(
          grepl("DMSP", date) ~ "dmsp",
          grepl("VIIRS", date) ~ "viirs",
          TRUE ~ NA_character_
        ),
        date = sub(".*_(\\d{4})_.*", "\\1", date),
        date = paste0(date, "-01-01"),
        date = as.Date(date),
        variable = "night_lights") |>
      dplyr::relocate(c("date", "variable", "provider", "value"), .before = all_of(geom_col))

  } else {
    extract_nlight <- extract_ee_with_progress(
      image = collection,
      sf_region = region,
      scale = scale,
      fun = stat,
      sf = FALSE,
      quiet = quiet,
      ...
    ) |>
      tidyr::pivot_longer(
        cols = grep("Harmonized_DN_NTL", names(extract_nlight), value = TRUE),,
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        provider = dplyr::case_when(
          grepl("DMSP", date) ~ "dmsp",
          grepl("VIIRS", date) ~ "viirs",
          TRUE ~ NA_character_),
        date = sub(".*_(\\d{4})_.*", "\\1", date),
        date = paste0(date, "-01-01"),
        date = as.Date(date),
        variable = "night_lights")

  }
  return(extract_nlight)
}
