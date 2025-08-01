#' Extracts forest cover loss within a defined polygon
#'
#' @description
#' Calculates forest loss within a user-defined region for a specified year range.
#' Forest loss is defined as a **stand-replacement disturbance**, or a change from forest to non-forest state.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param from Character. Start date in `"YYYY-MM-DD"` format (only the year is used).
#' @param to Character. End date in `"YYYY-MM-DD"` format (only the year is used).
#' @param region A spatial object defining the region of interest. Accepts an `sf`, `sfc`, or `SpatVector` object (from the \pkg{terra} package).
#' @param sf Logical. Return result as an `sf` object? Default is `TRUE`.
#' @param quiet Logical. If `TRUE`, suppress the progress bar (default `FALSE`).
#' @param force Logical. Force request extract.
#' @param ... arguments of `ee_extract` of `rgee` packages.
#'
#' @return A `sf` or `tibble` object with **forest loss per year in square kilometers**.
#'
#' @details
#' Forest loss is derived from the Hansen Global Forest Change dataset.
#' The `lossyear` band encodes the year of forest cover loss as follows:
#'
#' - Values range from **1** to **n**, where 1 corresponds to the year **2001** and n to the year **2000 + n**.
#' - A value of **0** indicates **no forest loss** detected.
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
#' ))
#'
#' # Run forest loss calculation
#' result <- l4h_forest_loss(
#'   from = '2005-01-01',
#'   to = '2007-01-01',
#'   region = region)
#'
#' head(result)
#' }
#'
#' @references
#' Hansen, M. C., Potapov, P. V., Moore, R., Hancher, M., Turubanova, S. A., Tyukavina, A., ... & Townshend, J. R. G. (2013).
#' *High-Resolution Global Maps of 21st-Century Forest Cover Change*. Science, 342(6160), 850–853.
#' DOI: \doi{10.1126/science.1244693}
#'
#' @export
l4h_forest_loss <- function(from, to, region, sf = TRUE, quiet = FALSE, force = FALSE, ...) {

  # Dataset date range
  start_year <- as.numeric(.internal_data$hansen$startyear)
  end_year   <- as.numeric(.internal_data$hansen$endyear)

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

  # Multiply by pixel area to get area lost in m² → convert to km²
  range_date_original <- from_year:to_year
  range_date_processed <- as.integer(substr(as.character(range_date_original), start = 3, stop = 4))

  hanse_data_db <- ee$Image(.internal_data$hansen$id)$select("lossyear")
  hanse_data_img <- hanse_data_db$eq(range_date_processed)

  hansen_data_area <- hanse_data_img$
    multiply(ee$Image$pixelArea())$
    divide(1e6)

  # Extract with reducer
  if (isTRUE(sf)) {
    extract_area <- extract_ee_with_progress(
      image = hansen_data_area,
      sf_region = region,
      scale = 30,
      fun = "sum",
      sf = TRUE,
      quiet = quiet,
      ...
    )
    geom_col <- attr(extract_area, "sf_column")
    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("constant"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = as.Date(ISOdate(factor(date, labels = range_date_original), 1, 1)),
        variable = "forest_loss") |>
      dplyr::relocate(c("date", "variable", "value"), .before = geom_col)

  } else {
    extract_area <- extract_ee_with_progress(
      image = hansen_data_area,
      sf_region = region,
      scale = 30,
      fun = "sum",
      sf = FALSE,
      quiet = quiet,
      ...
      ) |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("constant"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = as.Date(ISOdate(factor(date, labels = range_date_original), 1, 1)),
        variable = "forest_loss"
      )
  }
  return(extract_area)
}
