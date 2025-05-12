#' Download and process evapotranspiration data (SEBAL-MODIS) from Earth Engine
#'
#' This function accesses the `geeSEBAL-MODIS` collection published by the ET-Brasil project,
#' extracts the `ET_24h` band (daily evapotranspiration in mm/day), and allows temporal aggregation
#' by 8-day images, monthly composites, or the entire period. Optionally, results can be returned
#' as `sf`/`stars` objects in R.
#'
#' @param from Start date in `"YYYY-MM-DD"` format.
#' @param to End date in `"YYYY-MM-DD"` format.
#' @param by Temporal aggregation frequency. Options: `"8day"` (original 8-day composites), `"month"` (monthly average or sum), or `"total"` (entire period).
#' @param region A spatial object defining the region of interest. Accepts `sf`, `SpatVector`, or `ee$FeatureCollection` objects.
#' @param fun Aggregation function when `by = "month"` or `"total"`. Valid values are `"mean"` or `"sum"`.
#' @param sf Logical. If `TRUE`, returns a `stars`/`sf` object using `ee_as_stars()`. If `FALSE`, returns the raw Earth Engine object.
#' @param force Logical. If `TRUE`, forces download even if a local file already exists.
#' @param ... Additional arguments passed to `ee_as_stars()` or `ee_extract()`.
#'
#' @return A `stars` raster object if `sf = TRUE`, or an `ee$Image` object if `sf = FALSE`.

l4h_sebal_modis <- function(from, to, by = '8day', region, fun = "mean" ,sf = TRUE, force = FALSE, ...){
  # Validate input years
  if (!is.numeric(from) || nchar(as.character(from)) != 4) {
    cli::cli_abort("Parameter {.field from} must be a 4-digit numeric year. Got: {.val {from}}")
  }

  if (!is.numeric(to) || nchar(as.character(to)) != 4) {
    cli::cli_abort("Parameter {.field to} must be a 4-digit numeric year. Got: {.val {to}}")
  }

  if (from < as.Date('2002-07-01') || to > as.Date('2022-12-31')) {
    cli::cli_abort("Years must be in the range 2002-07-01 to 2022-12-31. Got: {.val {from}} to {.val {to}}")
  }

  if (to < from) {
    cli::cli_abort("Parameter {.field to} must be greater than or equal to {.field from}")
  }

  # Create year range date
  range_date_original <- from:to
  band_names <- sprintf(fmt = "annual_water_coverage_%s",range_date_original)

  # Define supported classes
  sf_classes <- c("sf", "sfc", "SpatVector")
  rgee_classes <- c("ee.featurecollection.FeatureCollection", "ee.feature.Feature")

  # Check input object class
  if (inherits(region, sf_classes)) {
    region_ee <- rgee::sf_as_ee(region)
  } else if (inherits(region, rgee_classes)) {
    region_ee <- region
  } else {
    stop("Invalid 'region' input. Expected an 'sf', 'sfc', 'SpatVector', or Earth Engine FeatureCollection object.")
  }

  region_ee <- region |>
    rgee::sf_as_ee()

  # Create binary image with lossyear in range
  sebal_data_db <- .internal_data$geesebal |>
    ee$ImageCollection() |>
    ee$ImageCollection$select('ET_24h')

  if(by == '8day'){
    sebal_index <- sebal_data_db |>
      ee$filter(ee$Filter$calendarRange(from,to,'day')) |>
      ee$ImageCollection$toBands()

  } else if(by == 'month'){
    ee_months <- seq(as.Date(from), to = as.Date(to), by = 'months')

    sebal_index <- sebal_data_db |>
      ee$filter(ee$Filter$calendarRange(from,to,'month'))

  } else if (by == "annual") {
    ee_years  <- seq(as.Date(from), to = as.Date(to), by = 'years')
    sebal_index <- sebal_data_db |>
      ee$filter(ee$Filter$calendarRange(from,to,'year'))

  } else {

  }



}

