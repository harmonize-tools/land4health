#' Extract TerraClimate variables (monthly) from Google Earth Engine
#'
#' @description
#' Extracts one or more **TerraClimate** variables for a user-defined region
#' and time range from the Earth Engine dataset **IDAHO_EPSCOR/TERRACLIMATE**.
#' The function summarizes each monthly image over the region using a chosen
#' statistic (e.g., mean/median), applies the appropriate **scale factors** to
#' return values in native units, and returns an `sf` or `tibble`.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param from Character or Date. Start date (`"YYYY-MM-DD"`).
#' @param to Character or Date. End date (`"YYYY-MM-DD"`).
#' @param band Character vector. One or more TerraClimate variables to extract.
#'   Supported codes: `"aet"`, `"def"`, `"pdsi"`, `"pet"`, `"pr"`, `"ro"`,
#'   `"soil"`, `"srad"`, `"swe"`, `"tmmn"`, `"tmmx"`, `"vap"`, `"vpd"`, `"vs"`.
#'   Scale factors and units (aplicadas automáticamente):
#'   - `aet` (mm, ×0.1), `def` (mm, ×0.1), `pdsi` (unitless, ×0.01),
#'   - `pet` (mm, ×0.1), `pr` (mm, ×1), `ro` (mm, ×1), `soil` (mm, ×0.1),
#'   - `srad` (W/m², ×0.1), `swe` (mm, ×1),
#'   - `tmmn` (°C, ×0.1), `tmmx` (°C, ×0.1),
#'   - `vap` (kPa, ×0.001), `vpd` (kPa, ×0.01), `vs` (m/s, ×0.01).
#' @param region Spatial object defining the region of interest.
#'   Accepts an `sf`, `sfc`, or `SpatVector` object.
#' @param scale Numeric. Reducer scale in meters. Default `1000`.
#'   (TerraClimate pixel ≈ **4638 m**; usar ~4500–5000 m suele ser adecuado.)
#' @param stat Character. Summary statistic per image per region. One of
#'   `"mean"`, `"median"`, `"min"`, `"max"`. Passed internally to the extractor.
#' @param sf Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`.
#'   Default `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress bars/messages. Default `FALSE`.
#' @param force Logical. If `TRUE`, fuerza la extracción aun si hay caché. Default `TRUE`.
#' @param ... Additional arguments passed to the extraction backend.
#'
#' @return An `sf` or `tibble` with columns:
#'   - `date` (Date, primer día del mes),
#'   - `variable` (character, código TerraClimate),
#'   - `value` (numérico, en unidades nativas ya escaladas),
#'   plus geometry if `sf = TRUE`, and any attributes from `region`.
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
#' # Precipitación mensual (mm) 2020, promedio espacial
#' out_pr <- l4h_terra_climate(
#'   from = "2020-01-01",
#'   to   = "2020-12-31",
#'   band = "pr",
#'   region = region,
#'   stat = "mean",
#'   scale = 5000
#' )
#' head(out_pr)
#'
#' # Múltiples variables: Tmax (°C) + VPD (kPa)
#' out_multi <- l4h_terra_climate(
#'   from = "2019-01-01",
#'   to   = "2019-12-31",
#'   band = c("tmmx","vpd"),
#'   region = region,
#'   stat = "median",
#'   scale = 5000
#' )
#' }
#'
#' @references
#' Abatzoglou, J. T., Dobrowski, S. Z., Parks, S. A., & Hegewisch, K. C. (2018).
#' TerraClimate, a high-resolution global dataset of monthly climate and climatic
#' water balance from 1958–2015. *Scientific Data*, 5, 170191.
#' \doi{10.1038/sdata.2017.191}
#'
#' @export
l4h_terra_climate <- function(from, to, band, region, scale = 1000, stat = "mean", sf = TRUE, quiet = FALSE, force = TRUE, ...){

  # Dataset date range
  start_year <- as.numeric(.internal_data$terraclimate$startyear)
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

  band_info <- function(band) {
    choices <- c("aet","def","pdsi","pet","pr","ro","soil","srad","swe",
                 "tmmn","tmmx","vap","vpd","vs")
    scales <- c(
      aet=0.1, def=0.1, pdsi=0.01, pet=0.1, pr=1.0, ro=1.0,
      soil=0.1, srad=0.1, swe=1.0, tmmn=0.1, tmmx=0.1,
      vap=0.001, vpd=0.01, vs=0.01
    )

    if (missing(band) || !is.character(band) || length(band) < 1L) {
      cli::cli_abort(c(
        "x" = "Provide one or more band names as a character vector.",
        "!" = "Valid options are: {.or {choices}}."
      ), call = NULL)
    }

    band_lower <- tolower(band)

    invalid <- unique(band_lower[!band_lower %in% choices])
    if (length(invalid)) {
      suggestion <- vapply(
        invalid,
        function(b) choices[which.min(adist(b, choices))],
        character(1)
      )
      sug_str <- paste0(
        "{.val ", suggestion, "} (for {.val ", invalid, "})"
      )
      cli::cli_abort(c(
        "x" = "Some band names are invalid.",
        "!" = "Valid options are: {.or {choices}}.",
        "i" = paste("Closest matches:", paste(sug_str, collapse = ", "))
      ), call = NULL)
    }

    out <- unname(scales[band_lower])
    names(out) <- band_lower
    out
  }


  factor_band <- band_info(band = band)

  collection <- ee$ImageCollection(.internal_data$terraclimate$id)$
    select(band)$
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
        cols = tidyr::starts_with("X"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        variable = sub(".*_([A-Za-z]+)$", "\\1", date),
        date = paste0(sub("^X(\\d{4}\\d{2}).*", "\\1", date),'01'),
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
        cols = tidyr::starts_with("X"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        variable = sub(".*_([A-Za-z]+)$", "\\1", date),
        date = paste0(sub("^X(\\d{4}\\d{2}).*", "\\1", date),'01'),
        date = as.Date(date, format = "%Y%m%d"))

  }
  return(extract_area)
}
