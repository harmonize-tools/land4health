#' Extracts Land Surface Temperature (LST) from MODIS MOD11A1
#'
#' @description
#' Extracts daytime or nighttime Land Surface Temperature (LST) for a user-defined region
#' and time range using the MODIS MOD11A1.061 product. The function supports summarizing
#' the temperature data over each date (or each month) using a selected statistic
#' (e.g., mean or median).
#'
#' \if{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.png}{options: width="120"}
#' }}
#' \if{latex}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.pdf}{options: width=2cm}
#' }}
#'
#' @param from Character or Date. Start date of the analysis (e.g., `"2020-01-01"`).
#' @param to Character or Date. End date of the analysis (e.g., `"2020-12-31"`).
#' @param region A spatial object defining the region of interest. Accepts an `sf`, `sfc`, or `SpatVector` object.
#' @param band Character. LST type to extract: `"day"` (LST_Day_1km) or `"night"` (LST_Night_1km). Default is `"day"`.
#' @param level Character. Quality filter level to apply to MODIS LST pixels.
#'   Use `"strict"` to retain only high-quality observations (QA bits 0-1 equal to `00`),
#'   or `"moderate"` to allow both high and acceptable quality (QA bits 0-1 equal to `00` or `01`).
#'   Default is `"moderate"`.
#' @param by Character. Temporal resolution of the output. One of `"day"` (default, one value
#'   per available daily image) or `"month"`. When `"month"`, cloud-masked daily images within
#'   each calendar month are combined server-side with the reducer selected in `stat` (mean,
#'   median, min or max) *before* the spatial extraction, so masked (cloudy) pixels do not
#'   count as zeros or missing days — they are simply excluded from that month's reducer.
#' @param scale Numeric. Spatial resolution in meters. Default is `1000` (native resolution).
#' @param stat Character. Summary statistic to apply. One of `"mean"`, `"median"`, `"min"`, `"max"`.
#'   Used as the spatial reducer passed to `ee_extract()` for every `by` value, and additionally
#'   as the temporal reducer across days within a month when `by = "month"`.
#' @param sf Logical. If `TRUE`, returns an `sf` object; if `FALSE`, returns a `tibble`. Default is `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress bars and messages. Default is `FALSE`.
#' @param force Logical. If `TRUE`, skips the representativity check
#'   (polygons smaller than 1 pixel are still extracted, only a warning is issued).
#'   Default is `FALSE`.
#' @param ... Additional arguments passed to `rgee::ee_extract()`.
#'
#' @return A `sf` or `tibble` object with LST values (in degrees Celsius) extracted from MODIS MOD11A1,
#'   at daily or monthly resolution depending on `by`.
#'
#' @section Credits:
#' \if{html}{\href{https://www.innovalab.info/}{\figure{innovalab.png}{options: width="120"}}}
#' \if{latex}{\href{https://www.innovalab.info/}{\figure{innovalab.pdf}{options: width=2cm}}}
#'
#' Pioneering geospatial health analytics and open-science tools.
#' Developed by the Innovalab Team. For more information, send an email to
#' \email{imt.innovlab@oficinas-upch.pe}.
#'
#' @details
#' The MODIS MOD11A1.061 product provides daily Land Surface Temperature and quality information.
#' This function filters out low-quality or cloud-contaminated pixels based on the `QC_Day` or `QC_Night` band.
#'
#' When `by = "month"`, for each calendar month in `[from, to]` the function:
#' \enumerate{
#'   \item Filters the daily collection to that month.
#'   \item Applies the same quality mask used for daily extraction to every image.
#'   \item Reduces the masked images to a single monthly image using the reducer implied by `stat`.
#' }
#' Because masking happens before reducing, a cloudy day never drags the monthly value down or up —
#' it simply does not contribute a pixel to that month's calculation.
#'
#' LST values are originally stored as Kelvin multiplied by 0.02. This function automatically
#' converts them to degrees Celsius using the formula: `LST = (value x 0.02) - 273.15`.
#'
#' @examples
#' \dontrun{
#' library(land4health)
#' ee_Initialize()
#'
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
#' # Daily (unchanged default behaviour)
#' lst_day <- l4h_surface_temp(
#'   from = "2020-01-01", to = "2020-12-31",
#'   region = region, band = "day", stat = "mean")
#'
#' # Monthly
#' lst_month <- l4h_surface_temp(
#'   from = "2020-01-01", to = "2020-12-31",
#'   region = region, band = "day", stat = "mean", by = "month")
#'
#' head(lst_month)
#' }
#'
#' @references
#' Wan, Z., Hook, S., & Hulley, G. (2015). MOD11A1 MODIS/Terra Land Surface Temperature
#' and Emissivity Daily L3 Global 1km SIN Grid V006 (Version 6.1). NASA EOSDIS Land Processes DAAC.
#' \doi{https://doi.org/10.5067/MODIS/MOD11A1.061}
#'
#' MODIS MOD11A1.061 - Google Earth Engine Dataset Catalog.
#' \url{https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD11A1}
#'
#' @export

l4h_surface_temp <- function(from, to, region, band = "day", level = "strict",
                              by = "day", scale = 1000, stat = "mean",
                              sf = TRUE, quiet = FALSE, force = FALSE, ...){

  # Dataset date range
  start_year <- as.numeric(.internal_data$lst$startyear)
  end_year   <- as.numeric(.internal_data$lst$endyear)

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

  sf_classes <- c("sf", "sfc", "SpatVector")

  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object.")
  }

  band <- match.arg(band, choices = c("day", "night"))
  by   <- match.arg(by, choices = c("day", "month"))
  stat <- match.arg(stat, choices = c("mean", "median", "min", "max"))

  if (isFALSE(force)) {
    check_representativity(region = region, scale = 30)
  }

  check_ee_initialized()

  from_ee <- l4h_to_eedate(from_date)
  to_ee   <- l4h_to_eedate(to_date)

  lst_band <- switch(band, day = "LST_Day_1km", night = "LST_Night_1km")
  qc_band  <- switch(band, day = "QC_Day", night = "QC_Night")

  if (by == "day") {

    collection <- ee$ImageCollection(.internal_data$lst$id)$
      filterDate(from_ee, to_ee)$
      map(rgee::ee_utils_pyfunc(function(img) {
        mask_quality(image = img, band = lst_band, qc_band = qc_band, level = level)
      }))$
      toBands()

    date_regex <- "^X(\\d{4}_\\d{2}_\\d{2}).*"
    to_date_col <- function(x) as.Date(gsub("_", "-", x))
    variable_label <- paste0("LST-", band, "-1km")

  } else {

    temporal_reducer <- switch(stat,
      mean   = ee$Reducer$mean(),
      median = ee$Reducer$median(),
      min    = ee$Reducer$min(),
      max    = ee$Reducer$max()
    )

    months_seq <- seq(
      as.Date(format(from_date, "%Y-%m-01")),
      as.Date(format(to_date, "%Y-%m-01")),
      by = "month"
    )

    monthly_images <- lapply(months_seq, function(m) {
      m_start <- l4h_to_eedate(m)
      m_end   <- m_start$advance(1, "month")
      idx     <- format(m, "%Y_%m")

      ee$ImageCollection(.internal_data$lst$id)$
        filterDate(m_start, m_end)$
        map(rgee::ee_utils_pyfunc(function(img) {
          mask_quality(image = img, band = lst_band, qc_band = qc_band, level = level)
        }))$
        reduce(temporal_reducer)$
        rename(lst_band)$
        set("system:index", idx)
    })

    collection <- ee$ImageCollection$fromImages(monthly_images)$toBands()

    date_regex <- "^X(\\d{4}_\\d{2}).*"
    to_date_col <- function(x) as.Date(paste0(gsub("_", "-", x), "-01"))
    variable_label <- paste0("LST-", band, "-1km-monthly")

  }

  if (isTRUE(sf)) {
    extract_area <- l4h_ee_extract(
      image = collection, sf_region = region, scale = scale,
      fun = stat, sf = TRUE, quiet = quiet, ...
    )

    geom_col  <- attr(extract_area, "sf_column")
    id_cols   <- setdiff(names(region), geom_col)
    band_cols <- setdiff(names(extract_area), c(geom_col, id_cols))

    for (col in band_cols) extract_area[[col]] <- as.numeric(extract_area[[col]])

    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols = dplyr::all_of(band_cols),
        names_to = "date", values_to = "value") |>
      dplyr::mutate(
        date = sub(date_regex, "\\1", date),
        date = to_date_col(date),
        variable = variable_label) |>
      dplyr::relocate(c("date", "variable", "value"), .before = dplyr::all_of(geom_col))

  } else {
    extract_area <- l4h_ee_extract(
      image = collection, sf_region = region, scale = scale,
      fun = stat, sf = FALSE, quiet = quiet, ...
    )

    band_cols <- grep("^X", names(extract_area), value = TRUE)
    for (col in band_cols) extract_area[[col]] <- as.numeric(extract_area[[col]])

    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols = dplyr::all_of(band_cols),
        names_to = "date", values_to = "value") |>
      dplyr::mutate(
        date = sub(date_regex, "\\1", date),
        date = to_date_col(date),
        variable = variable_label)
  }

  return(extract_area)
}
