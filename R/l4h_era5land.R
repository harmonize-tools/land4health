#' Extract ERA5-Land climate variables from Google Earth Engine
#'
#' @description
#' Extracts **ERA5-Land** climate variables for a user-defined region
#' and time range from the Earth Engine datasets
#' **ECMWF/ERA5_LAND/DAILY_AGGR** (`by = "daily"`) or
#' **ECMWF/ERA5_LAND/MONTHLY_AGGR** (`by = "month"`).
#' Each image is summarized over the region using a chosen
#' statistic (e.g., mean/median), values are converted to conventional
#' units (degrees Celsius, mm, volume fraction), and the function
#' returns an `sf` or `tibble`.
#'
#' ERA5-Land is the land-component replay of the ECMWF ERA5 climate
#' reanalysis (Copernicus Climate Data Store), with global coverage
#' from 1950 to near-present at ~9 km (0.1 degrees) resolution.
#' It complements `l4h_chirps()` (finer precipitation) and
#' `l4h_terra_climate()` (finer monthly climatology) by providing
#' **daily** exposure windows and soil-moisture variables that are
#' key for vector-borne disease modelling (temperature/precipitation lags).
#'
#' \if{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.png}{options: width="120"}
#' }}
#' \if{latex}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.pdf}{options: width=2cm}
#' }}
#'
#' @param from Character or Date. Start date (`"YYYY-MM-DD"`).
#' @param to Character or Date. End date (`"YYYY-MM-DD"`).
#' @param by Character. Temporal resolution. Options:
#'   - `"daily"` — daily values from `ECMWF/ERA5_LAND/DAILY_AGGR`,
#'   - `"month"` — monthly values from `ECMWF/ERA5_LAND/MONTHLY_AGGR`.
#'   Default `"month"`.
#' @param band Character vector. One or more ERA5-Land variables to extract.
#'   Supported codes:
#'   - `"t2m"` (2m air temperature, K -> degrees C),
#'   - `"d2m"` (2m dewpoint temperature, K -> degrees C),
#'   - `"pr"` (total precipitation, m -> mm),
#'   - `"soil"` (volumetric soil water layer 1, 0-7 cm, m3/m3),
#'   - `"pet"` (potential evaporation, m -> mm).
#'   Default `"t2m"`.
#' @param region Spatial object defining the region of interest.
#'   Accepts an `sf`, `sfc`, or `SpatVector` object.
#' @param scale Numeric. Reducer scale in meters. Default `11132`
#'   (ERA5-Land native pixel ~11,132 m).
#' @param stat Character. Summary statistic per image per region. One of
#'   `"mean"`, `"median"`, `"min"`, `"max"`.
#' @param sf Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a
#'   `tibble`. Default `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress bars/messages.
#'   Default `FALSE`.
#' @param force Logical. If `TRUE`, skips the representativity check.
#'   Default `FALSE`.
#' @param ... Additional arguments passed to the extraction backend.
#'
#' @return An `sf` or `tibble` with columns:
#'   - `date` (Date — first day of the period),
#'   - `variable` (character — band code, e.g. `"t2m"`),
#'   - `value` (numeric — degrees C, mm, or volume fraction),
#'   plus geometry if `sf = TRUE`, and any attributes from `region`.
#'
#' @section Credits:
#' \if{html}{\href{https://www.innovalab.info/}{\figure{innovalab.png}{options: width="120"}}}
#' \if{latex}{\href{https://www.innovalab.info/}{\figure{innovalab.pdf}{options: width=2cm}}}
#'
#' Pioneering geospatial health analytics and open-science tools.
#' Developed by the Innovalab Team. For more information, send an email to
#' \email{imt.innovlab@oficinas-upch.pe}.
#'
#' Follow us on:
#' \itemize{
#'   \item \if{html}{\figure{linkedin-innova.png}{options: width="16"}} \if{latex}{\figure{linkedin-innova.pdf}{options: width=0.4cm}} \href{https://www.linkedin.com/company/innovalab-imt}{Innovalab Linkedin}
#'   \item \if{html}{\figure{twitter-innova.png}{options: width="16"}} \if{latex}{\figure{twitter-innova.pdf}{options: width=0.4cm}} \href{https://x.com/innovalab_imt}{Innovalab X}
#'   \item \if{html}{\figure{facebook-innova.png}{options: width="16"}} \if{latex}{\figure{facebook-innova.pdf}{options: width=0.4cm}} \href{https://www.facebook.com/imt.innovalab}{Innovalab facebook}
#'   \item \if{html}{\figure{instagram-innova.png}{options: width="16"}} \if{latex}{\figure{instagram-innova.pdf}{options: width=0.4cm}} \href{https://www.instagram.com/innovalab_imt}{Innovalab instagram}
#'   \item \if{html}{\figure{tiktok-innova.png}{options: width="16"}} \if{latex}{\figure{tiktok-innova.pdf}{options: width=0.4cm}} \href{https://www.tiktok.com/@innovalab_imt}{Innovalab tiktok}
#'   \item \if{html}{\figure{spotify-innova.png}{options: width="16"}} \if{latex}{\figure{spotify-innova.pdf}{options: width=0.4cm}} \href{https://www.innovalab.info/podcast}{Innovalab Podcast}
#' }
#'
#' @examples
#' \dontrun{
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
#' # 1. Monthly 2m temperature (degrees C) 2020
#' out_monthly <- l4h_era5land(
#'   from   = "2020-01-01",
#'   to     = "2020-12-31",
#'   by     = "month",
#'   band   = "t2m",
#'   region = region,
#'   stat   = "mean"
#' )
#' head(out_monthly)
#'
#' # 2. Daily precipitation (mm) + soil moisture, one month
#' out_daily <- l4h_era5land(
#'   from   = "2020-06-01",
#'   to     = "2020-06-30",
#'   by     = "daily",
#'   band   = c("pr", "soil"),
#'   region = region,
#'   stat   = "mean"
#' )
#' head(out_daily)
#' }
#'
#' @references
#' Munoz-Sabater, J., Dutra, E., Agusti-Panareda, A. et al. (2021).
#' ERA5-Land: a state-of-the-art global reanalysis dataset for land
#' applications. *Hydrology and Earth System Sciences*, 25, 4349-4383.
#' \doi{10.5194/hess-25-4349-2021}
#'
#' @export
l4h_era5land <- function(from,
                         to,
                         by     = "month",
                         band   = "t2m",
                         region,
                         scale  = 11132,
                         stat   = "mean",
                         sf     = TRUE,
                         quiet  = FALSE,
                         force  = FALSE,
                         ...) {

  # ERA5-Land: 1950-01-02 to near-present
  start_year <- 1950L
  end_year   <- as.numeric(format(Sys.Date(), "%Y"))

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

  by <- match.arg(by, choices = c("daily", "month"))

  band_info <- function(band) {
    choices <- c("t2m", "d2m", "pr", "soil", "pet")
    gee <- c(
      t2m  = "temperature_2m",
      d2m  = "dewpoint_temperature_2m",
      pr   = "total_precipitation_sum",
      soil = "volumetric_soil_water_layer_1",
      pet  = "potential_evaporation_sum"
    )
    factor <- c(t2m = 1, d2m = 1, pr = 1000, soil = 1, pet = 1000)
    offset <- c(t2m = -273.15, d2m = -273.15, pr = 0, soil = 0, pet = 0)

    if (missing(band) || !is.character(band) || length(band) < 1L) {
      cli::cli_abort(c(
        "x" = "Provide one or more band codes as a character vector.",
        "!" = "Valid options are: {.or {choices}}."
      ), call = NULL)
    }

    band_lower <- tolower(band)

    invalid <- unique(band_lower[!band_lower %in% choices])
    if (length(invalid)) {
      cli::cli_abort(c(
        "x" = "Some band codes are invalid: {.val {invalid}}.",
        "!" = "Valid options are: {.or {choices}}."
      ), call = NULL)
    }

    list(
      code   = band_lower,
      gee    = unname(gee[band_lower]),
      factor = unname(factor[band_lower]),
      offset = unname(offset[band_lower])
    )
  }

  info <- band_info(band = band)
  n_vars <- length(info$code)

  # Validate region
  sf_classes <- c("sf", "sfc", "SpatVector")
  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object.")
  }

  # Check representativity
  if (isFALSE(force)) {
    check_representativity(region = region, scale = scale)
  }

  # Check Earth Engine is initialized
  check_ee_initialized()

  if (by == "daily") {
    dataset_id <- .internal_data$era5land_daily$id
    from_ee <- l4h_to_eedate(from_date)
    to_ee   <- l4h_to_eedate(to_date)
    period_start <- from_date
    period_by <- "day"
  } else {
    dataset_id <- .internal_data$era5land_monthly$id
    period_start <- as.Date(format(from_date, "%Y-%m-01"))
    m_end <- as.Date(format(to_date, "%Y-%m-01"))
    m_end_excl <- seq(m_end, by = "month", length.out = 2)[2]
    from_ee <- l4h_to_eedate(period_start)
    to_ee   <- l4h_to_eedate(m_end_excl)
    period_by <- "month"
  }

  ic <- ee$ImageCollection(dataset_id)$
    select(info$gee)$
    filterDate(from_ee, to_ee)

  collection <- safe_toBands(ic)

  # Extract data
  extract_area <- l4h_ee_extract(
    image     = collection,
    sf_region = region,
    scale     = scale,
    fun       = stat,
    sf        = sf,
    quiet     = quiet,
    ...
  )

  # Identify band columns positionally (toBands names are unpredictable)
  geom_col <- attr(extract_area, "sf_column")
  if (!is.null(geom_col)) {
    band_cols <- setdiff(names(extract_area), c(geom_col, names(region)))
    band_cols <- band_cols[band_cols %in% names(extract_area)]
    region_attr <- intersect(names(region), names(extract_area))
  } else {
    band_cols <- names(extract_area)
    region_attr <- intersect(names(region), names(extract_area))
    band_cols <- setdiff(band_cols, region_attr)
  }

  if (length(band_cols) == 0L || length(band_cols) %% n_vars != 0L) {
    cli::cli_abort(c(
      "x" = "Extracted {.val {length(band_cols)}} bands, which is not a multiple of {.val {n_vars}} requested variables.",
      "i" = "Use a shorter date range or check the dataset availability."
    ))
  }

  n_dates <- length(band_cols) / n_vars

  # toBands() preserves chronological order: image-major, band-minor
  var_vec  <- rep(info$code, times = n_dates)
  date_seq <- seq(period_start, by = period_by, length.out = n_dates)
  date_vec <- rep(date_seq, each = n_vars)

  # Coerce bands to numeric before pivoting (GEE may return mixed types)
  for (col in band_cols) {
    extract_area[[col]] <- as.numeric(extract_area[[col]])
  }

  n_feat <- nrow(extract_area)

  scale_vec  <- stats::setNames(info$factor, info$code)
  offset_vec <- stats::setNames(info$offset, info$code)

  extract_area <- extract_area |>
    tidyr::pivot_longer(
      cols      = dplyr::all_of(band_cols),
      names_to  = "band_raw",
      values_to = "value"
    ) |>
    dplyr::mutate(
      date     = rep(date_vec, times = n_feat),
      variable = rep(var_vec, times = n_feat),
      value    = value * unname(scale_vec[variable]) +
        unname(offset_vec[variable])
    ) |>
    dplyr::select(-band_raw)

  # Relocate columns
  if (!is.null(geom_col)) {
    extract_area <- extract_area |>
      dplyr::relocate(c("date", "variable", "value"), .before = all_of(geom_col))
  } else {
    extract_area <- extract_area |>
      dplyr::relocate(c("date", "variable", "value"))
  }

  return(extract_area)
}
