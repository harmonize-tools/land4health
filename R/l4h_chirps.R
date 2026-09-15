#' Extract CHIRPS v3 precipitation data from Google Earth Engine
#'
#' @description
#' Extracts **CHIRPS v3** precipitation estimates for a user-defined region
#' and time range from the Earth Engine dataset
#' **UCSB-CHC/CHIRPS/V3/DAILY_SAT** (IMERG-based) or
#' **UCSB-CHC/CHIRPS/V3/DAILY_RNL** (ERA5-based).
#' The function supports daily, monthly, and annual temporal aggregation.
#' Monthly and annual values are computed as **sums** of daily precipitation
#' (mm), which is the standard in hydrology and vector-borne disease modelling.
#'
#' CHIRPS v3 (Climate Hazards Center InfraRed Precipitation with Stations
#' version 3) is a quasi-global (60°S–60°N), high-resolution (0.05°) gridded
#' rainfall dataset from 1981 to near-present, combining satellite thermal
#' infrared estimates with in-situ station observations.
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
#' @param by Character. Temporal aggregation frequency. Options:
#'   - `"daily"` — daily precipitation (mm/day),
#'   - `"month"` — monthly accumulated precipitation (mm/month),
#'   - `"annual"` — annual accumulated precipitation (mm/year).
#'   Default `"month"`.
#' @param product Character. CHIRPS v3 daily product used for disaggregation.
#'   Options:
#'   - `"sat"` — IMERG-based daily (0.1° resolution, available from 2001),
#'   - `"rnl"` — ERA5-based daily (0.25° resolution, available from 1981).
#'   Default `"sat"`.
#' @param region Spatial object defining the region of interest.
#'   Accepts an `sf`, `sfc`, or `SpatVector` object.
#' @param scale Numeric. Reducer scale in meters. Default `5566`
#'   (CHIRPS native pixel ~5,566 m).
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
#'   - `variable` (character — `"precipitation"`),
#'   - `value` (numeric — mm in the corresponding time unit),
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
#'   \item \if{html}{\figure{instagram-innova.png}{options: width="16"}} \if{latex}{\figure{instagram-innova.pdf}{options: width=0.4cm}} \href{https://www.instagram.com/innovalab_imt/}{Innovalab instagram}
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
#' # 1. Monthly precipitation (mm/month) 2020, SAT product
#' out_monthly <- l4h_chirps(
#'   from    = "2020-01-01",
#'   to      = "2020-12-31",
#'   by      = "month",
#'   product = "sat",
#'   region  = region,
#'   stat    = "mean"
#' )
#' head(out_monthly)
#'
#' # 2. Annual precipitation (mm/year) 2015-2020, RNL product
#' out_annual <- l4h_chirps(
#'   from    = "2015-01-01",
#'   to      = "2020-12-31",
#'   by      = "annual",
#'   product = "rnl",
#'   region  = region,
#'   stat    = "mean"
#' )
#' head(out_annual)
#'
#' # 3. Daily precipitation (mm/day) for one month
#' out_daily <- l4h_chirps(
#'   from    = "2020-06-01",
#'   to      = "2020-06-30",
#'   by      = "daily",
#'   product = "sat",
#'   region  = region,
#'   stat    = "mean"
#' )
#' head(out_daily)
#' }
#'
#' @references
#' Funk, C., Peterson, P., Harrison, L. et al. (2026).
#' The Climate Hazards Center Infrared Precipitation with Stations, Version 3.
#' *Scientific Data*, 13, 718. \doi{10.1038/s41597-026-07096-4}
#'
#' @export
l4h_chirps <- function(from,
                       to,
                       by     = "month",
                       product = "sat",
                       region,
                       scale  = 5566,
                       stat   = "mean",
                       sf     = TRUE,
                       quiet  = FALSE,
                       force  = FALSE,
                       ...) {

  # CHIRPS v3: 1981-01-01 to near-present
  start_year <- 1981L
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

  by <- match.arg(by, choices = c("daily", "month", "annual"))

  product <- match.arg(product, choices = c("sat", "rnl"))

  # Validate product availability against date range
  if (product == "sat" && from_year < 2001) {
    cli::cli_abort(c(
      "x" = "Product {.val sat} (IMERG-based) is only available from 2001 onward.",
      "i" = "Use {.val product = 'rnl'} for dates before 2001, or adjust {.field from}."
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

  # Convert dates to Earth Engine
  from_ee <- rgee::rdate_to_eedate(from_date)
  to_ee   <- rgee::rdate_to_eedate(to_date)

  # Select dataset based on product
  dataset_id <- if (product == "sat") {
    .internal_data$chirps_sat$id
  } else {
    .internal_data$chirps_rnl$id
  }

  ic <- ee$ImageCollection(dataset_id)$
    select("precipitation")$
    filterDate(from_ee, to_ee)

  # Build image(s) according to 'by'
  if (by == "daily") {

    collection <- safe_toBands(ic)

  } else if (by == "month") {

    date_seq      <- seq(from_date, to_date, by = "month")
    date_seq_df   <- data.frame(fecha = date_seq) |>
      dplyr::mutate(
        year  = as.numeric(format(fecha, "%Y")),
        month = as.numeric(format(fecha, "%m"))
      )
    list_date <- date_seq_df |>
      dplyr::group_by(year) |>
      dplyr::summarise(meses = list(sort(unique(month))))

    monthly_ee <- function(x) {
      years_ee  <- list_date$year[x]
      months    <- unlist(list_date$meses[x])
      months_ee <- months |> ee$List()

      ee$ImageCollection$
        fromImages(
          months_ee$map(rgee::ee_utils_pyfunc(
            function(m) {
              ic$
                filter(ee$Filter$calendarRange(years_ee, years_ee, "year"))$
                filter(ee$Filter$calendarRange(m, m, "month"))$
                sum()$
                set("year", years_ee)$
                set("month", m)
            }
          ))
        )$toBands()
    }

    collection <- lapply(seq_len(nrow(list_date)), monthly_ee) |>
      ee$ImageCollection() |>
      ee$ImageCollection$toBands()

    # Rename bands to YYYYMM format
    band_names <- collection$bandNames()$getInfo()
    month_vals <- date_seq_df$month
    new_names  <- paste0("precip_", format(date_seq_df$fecha, "%Y%m"))
    collection <- collection$select(band_names)$rename(new_names)

  } else if (by == "annual") {

    years <- seq(from_date, to_date, by = "year") |>
      format("%Y") |>
      unique() |>
      as.integer()

    years_ee <- years |> ee$List()

    collection <- ee$ImageCollection$
      fromImages(
        years_ee$map(rgee::ee_utils_pyfunc(
          function(y) {
            ic$
              filter(ee$Filter$calendarRange(y, y, "year"))$
              sum()$
              set("year", y)
          }
        ))
      )$toBands()

    # Rename bands to YYYY format
    band_names <- collection$bandNames()$getInfo()
    new_names  <- paste0("precip_", years)
    collection  <- collection$select(band_names)$rename(new_names)
  }

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

  # Post-process: pivot to long format
  geom_col <- attr(extract_area, "sf_column")

  if (by == "daily") {

    # Get band names from the extracted data (exclude geometry and attributes)
    all_cols <- names(extract_area)
    if (!is.null(geom_col)) {
      band_cols <- setdiff(all_cols, c(geom_col, attr(extract_area, "sf_column")))
    } else {
      band_cols <- all_cols
    }
    # Remove non-band columns (attributes from region)
    region_cols <- setdiff(all_cols, band_cols)
    band_cols <- intersect(band_cols, names(extract_area))

    # Extract date from band names: look for 8-digit patterns (YYYYMMDD)
    band_dates <- regmatches(band_cols, regexpr("\\d{8}", band_cols))
    date_vals  <- as.Date(band_dates, format = "%Y%m%d")

    # Rename bands to date strings for pivoting
    new_names <- paste0("day_", format(date_vals, "%Y%m%d"))
    names(extract_area)[names(extract_area) %in% band_cols] <- new_names

    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols      = tidyr::starts_with("day_"),
        names_to  = "date",
        values_to = "value"
      ) |>
      dplyr::mutate(
        variable = "precipitation",
        date     = as.Date(sub("^day_", "", date), format = "%Y%m%d")
      )

  } else if (by == "month") {

    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols      = tidyr::starts_with("precip_"),
        names_to  = "date",
        values_to = "value"
      ) |>
      dplyr::mutate(
        variable = "precipitation",
        date     = as.Date(paste0(sub("^precip_", "", date), "01"), format = "%Y%m%d")
      )

  } else if (by == "annual") {

    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols      = tidyr::starts_with("precip_"),
        names_to  = "date",
        values_to = "value"
      ) |>
      dplyr::mutate(
        variable = "precipitation",
        date     = as.Date(paste0(sub("^precip_", "", date), "-01-01"))
      )
  }

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
