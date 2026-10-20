#' Extract ERA5-Land climate variables from Google Earth Engine
#'
#' @description
#' Extracts **ERA5-Land** climate variables for a user-defined region
#' and time range from the Earth Engine datasets
#' **ECMWF/ERA5_LAND/DAILY_AGGR** (`by = "daily"`) or
#' **ECMWF/ERA5_LAND/MONTHLY_AGGR** (`by = "month"`), plus
#' **ECMWF/ERA5_LAND/HOURLY** for the diurnal bands `"rh_day"`/`"rh_night"`.
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
#'   Default `"month"`. Diurnal bands (`"rh_day"`, `"rh_night"`) always use
#'   the hourly collection (see Details), aggregated to the same periods.
#' @param band Character vector. One or more ERA5-Land variables to extract.
#'   Supported codes:
#'   - `"t2m"` (2m air temperature, K -> degrees C),
#'   - `"d2m"` (2m dewpoint temperature, K -> degrees C),
#'   - `"rh"` (mean relative humidity, % — derived in Earth Engine from
#'   `temperature_2m` and `dewpoint_temperature_2m` via the Magnus
#'   formula, see Details),
#'   - `"rh_day"` (daytime relative humidity, % — mean over 06:00-18:00
#'   Peru time from `ECMWF/ERA5_LAND/HOURLY`, see Details),
#'   - `"rh_night"` (nighttime relative humidity, % — mean over
#'   18:00-06:00 Peru time from `ECMWF/ERA5_LAND/HOURLY`, see Details),
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
#'   - `variable` (character — band code, e.g. `"t2m"`, `"rh"`),
#'   - `value` (numeric — degrees C, percent, mm, or volume fraction),
#'   plus geometry if `sf = TRUE`, and any attributes from `region`.
#'
#' @details
#' Relative humidity (`band = "rh"`) is derived server-side in Earth Engine
#' from the bands the function already uses (`temperature_2m` and
#' `dewpoint_temperature_2m`), following the Magnus formula for saturation
#' vapour pressure (Wright 1997 coefficients, same as the EU operational
#' product derived from ERA5-Land):
#'
#' \deqn{e(T) = 611.21 \times \exp\left(\frac{17.502 \times T}{240.97 + T}\right)}{e(T) = 611.21 * exp((17.502 * T) / (240.97 + T))}
#' \deqn{RH = 100 \times \frac{e(Td)}{e(T)}}{RH = 100 * e(Td) / e(T)}
#'
#' with `T` (air temperature) and `Td` (dewpoint) in degrees C, converted
#' from Kelvin inside Earth Engine (`- 273.15`). The ratio simplifies to
#' `100 * exp(b*c*(Td - T) / ((c + T) * (c + Td)))` with `b = 17.502` and
#' `c = 240.97`. Values are clamped to 0–100%.
#'
#' Note the aggregation order: `DAILY_AGGR`/`MONTHLY_AGGR` already store
#' time-averaged `T`/`Td`, so `rh` is the humidity of the averaged
#' temperatures, not the average of instantaneous humidity. This is the
#' standard practice (same as the EU ERA5-Land product). Below 0 °C the
#' water-saturation form is kept (no ice correction), which is acceptable
#' for vector-borne disease modelling but documented here as a limitation.
#'
#' Day and night are defined in Peru time (PET, UTC-5, no daylight saving):
#' day is 06:00-18:00 PET and night is 18:00-06:00 PET. Since
#' `ECMWF/ERA5_LAND/HOURLY` timestamps are UTC, `"rh_day"` averages the UTC
#' hours 11-22 and `"rh_night"` the UTC hours 23, 00-10. Each hourly image
#' is converted to RH with the same Magnus formula above and then averaged
#' (mean of hourly means with equal weights). Diurnal bands therefore cannot
#' be combined with `"rh"` or native bands in one call: they come from
#' different collections with different time bases.
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
#' \donttest{
#' if (interactive()) {
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
#' # 2. Daily relative humidity (%) + precipitation (mm), one month
#' out_daily <- l4h_era5land(
#'   from   = "2020-06-01",
#'   to     = "2020-06-30",
#'   by     = "daily",
#'   band   = c("rh", "pr"),
#'   region = region,
#'   stat   = "mean"
#' )
#' head(out_daily)
#'
#' # 3. Daytime vs nighttime relative humidity (%), one week (Peru time)
#' out_diurnal <- l4h_era5land(
#'   from   = "2020-06-01",
#'   to     = "2020-06-07",
#'   by     = "daily",
#'   band   = c("rh_day", "rh_night"),
#'   region = region,
#'   stat   = "mean"
#' )
#' head(out_diurnal)
#' }
#' }
#'
#' @references
#' Muñoz Sabater, J. (2019): ERA5-Land monthly averaged data from 1950 to present.
#' Copernicus Climate Change Service (C3S) Climate Data Store (CDS).
#' \doi{10.24381/cds.68d2bb30}
#'
#' Bolton, D. (1980). The computation of equivalent potential temperature.
#' *Monthly Weather Review*, 108, 1046-1053.
#'
#' Alduchov, O. A., & Eskridge, R. E. (1996). Improved Magnus form
#' approximation of saturation vapor pressure. *Journal of Applied
#' Meteorology*, 35, 601-609.
#'
#'
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
    choices <- c("t2m", "d2m", "rh", "rh_day", "rh_night", "pr", "soil", "pet")
    gee <- c(
      t2m      = "temperature_2m",
      d2m      = "dewpoint_temperature_2m",
      rh       = "rh",
      rh_day   = "rh_day",
      rh_night = "rh_night",
      pr       = "total_precipitation_sum",
      soil     = "volumetric_soil_water_layer_1",
      pet      = "potential_evaporation_sum"
    )
    factor <- c(t2m = 1, d2m = 1, rh = 1, rh_day = 1, rh_night = 1,
                pr = 1000, soil = 1, pet = 1000)
    offset <- c(t2m = -273.15, d2m = -273.15, rh = 0, rh_day = 0,
                rh_night = 0, pr = 0, soil = 0, pet = 0)

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

  diurnal_codes <- intersect(info$code, c("rh_day", "rh_night"))
  native_codes  <- setdiff(info$code, c("rh", "rh_day", "rh_night"))
  has_rh <- "rh" %in% info$code

  # Diurnal bands come from the HOURLY collection while "rh" and the native
  # bands come from DAILY_AGGR/MONTHLY_AGGR: different time bases, so they
  # cannot be combined in a single call.
  if (length(diurnal_codes) > 0L && (length(native_codes) > 0L || has_rh)) {
    cli::cli_abort(c(
      "x" = "{.arg band} {.val rh_day}/{.val rh_night} cannot be combined with {.val rh} or aggregate bands.",
      "i" = "Request diurnal bands and aggregate bands in separate calls."
    ))
  }

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

  # Shared: RH from T/Td via the Magnus formula (Wright 1997 coefficients).
  # Reused for aggregate images (DAILY_AGGR/MONTHLY_AGGR) and hourly images.
  .rh_expression <- "min(max(100 * exp(17.502 * 240.97 * (Td - T) / ((240.97 + T) * (240.97 + Td))), 0), 100)"
  .compute_rh <- function(img) {
    Tc <- img$select("temperature_2m")$subtract(273.15)
    Tdc <- img$select("dewpoint_temperature_2m")$subtract(273.15)
    img$expression(
      .rh_expression,
      list("T" = Tc, "Td" = Tdc)
    )$rename("rh")
  }

  # Extract one ImageCollection (one image per period, bands in `codes`
  # order) and pivot to long format with positional date/band mapping.
  .extract_long <- function(ic_final, codes, dates, ...) {
    n_vars <- length(codes)
    collection <- safe_toBands(ic_final)

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
    var_vec  <- rep(codes, times = n_dates)
    date_vec <- rep(dates, each = n_vars)

    # Coerce bands to numeric before pivoting (GEE may return mixed types)
    for (col in band_cols) {
      extract_area[[col]] <- as.numeric(extract_area[[col]])
    }

    n_feat <- nrow(extract_area)

    idx <- match(codes, info$code)
    scale_vec  <- stats::setNames(info$factor[idx], codes)
    offset_vec <- stats::setNames(info$offset[idx], codes)

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

  # One output date per period (daily dates, or first day of each month)
  if (by == "daily") {
    period_dates <- seq(from_date, to_date, by = "day")
  } else {
    period_dates <- seq(as.Date(format(from_date, "%Y-%m-01")),
                        as.Date(format(to_date, "%Y-%m-01")),
                        by = "month")
  }

  outs <- list()

  # Aggregate bands: DAILY_AGGR / MONTHLY_AGGR ------------------------
  if (length(native_codes) > 0L || has_rh) {
    agg_codes <- info$code[info$code %in% c(native_codes, "rh")]

    if (by == "daily") {
      dataset_id <- .internal_data$era5land_daily$id
      from_ee <- l4h_to_eedate(from_date)
      to_ee   <- l4h_to_eedate(to_date + 1L) #Fixed date
    } else {
      dataset_id <- .internal_data$era5land_monthly$id
      m_start <- as.Date(format(from_date, "%Y-%m-01"))
      m_end <- as.Date(format(to_date, "%Y-%m-01"))
      m_end_excl <- seq(m_end, by = "month", length.out = 2)[2]
      from_ee <- l4h_to_eedate(m_start)
      to_ee   <- l4h_to_eedate(m_end_excl)
    }

    # Native GEE names ("rh" is derived, not a native band)
    gee_real <- c(
      t2m  = "temperature_2m",
      d2m  = "dewpoint_temperature_2m",
      pr   = "total_precipitation_sum",
      soil = "volumetric_soil_water_layer_1",
      pet  = "potential_evaporation_sum"
    )

    # RH needs T and Td even if the user only asked for "rh"
    select_bands <- unique(c(
      unname(gee_real[native_codes]),
      if (has_rh) c("temperature_2m", "dewpoint_temperature_2m")
    ))

    ic0 <- ee$ImageCollection(dataset_id)$
      select(select_bands)$
      filterDate(from_ee, to_ee)

    # Final band order follows the requested codes ("rh" is computed)
    final_gee <- vapply(
      agg_codes,
      function(co) if (co == "rh") "rh" else unname(gee_real[co]),
      character(1)
    )

    if (has_rh) {
      ic_agg <- ic0$map(rgee::ee_utils_pyfunc(
        function(img) img$addBands(.compute_rh(img))$select(final_gee)
      ))
    } else {
      ic_agg <- ic0$select(final_gee)
    }

    outs[[length(outs) + 1L]] <- .extract_long(ic_agg, agg_codes, period_dates, ...)
  }

  # Diurnal bands: HOURLY in Peru time (PET, UTC-5, no DST) ------------
  # Day:   06:00-18:00 PET = UTC hours 11-22
  # Night: 18:00-06:00 PET = UTC hours 23, 00-10
  if (length(diurnal_codes) > 0L) {
    hourly_id <- .internal_data$era5land_hourly$id

    .period_bounds <- function(d) {
      if (by == "daily") {
        list(start = d, end = d + 1L)
      } else {
        list(start = d, end = seq(d, by = "month", length.out = 2)[2])
      }
    }

    .diurnal_composite <- function(d) {
      bounds <- .period_bounds(d)
      base <- ee$ImageCollection(hourly_id)$
        select(c("temperature_2m", "dewpoint_temperature_2m"))$
        filterDate(l4h_to_eedate(bounds$start), l4h_to_eedate(bounds$end))

      parts <- lapply(diurnal_codes, function(co) {
        hours <- if (co == "rh_day") 11:22 else c(23L, 0L:10L)
        hourly_means <- lapply(hours, function(h) {
          base$
            filter(ee$Filter$calendarRange(h, h, "hour"))$
            map(rgee::ee_utils_pyfunc(.compute_rh))$
            mean()$
            rename(paste0("h", h))
        })
        stacked <- hourly_means[[1L]]
        if (length(hourly_means) > 1L) {
          for (k in 2:length(hourly_means)) {
            stacked <- stacked$addBands(hourly_means[[k]])
          }
        }
        # Mean of hourly means = overall mean (equal hourly weights)
        stacked$reduce(ee$Reducer$mean())$rename(co)
      })

      img <- parts[[1L]]
      if (length(parts) > 1L) {
        for (k in 2:length(parts)) {
          img <- img$addBands(parts[[k]])
        }
      }
      img
    }

    composites <- lapply(seq_along(period_dates),
                         function(i) .diurnal_composite(period_dates[i]))
    ic_diurnal <- ee$ImageCollection$fromImages(composites)

    outs[[length(outs) + 1L]] <- .extract_long(ic_diurnal, diurnal_codes, period_dates, ...)
  }

  dplyr::bind_rows(outs)
}
