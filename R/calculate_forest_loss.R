#' Calculate Forest Loss
#'
#' Calculates forest loss within a user-defined region for a specified year range.
#'
#' @param from A numeric year between 2001 and 2023. Indicates the start of the analysis period.
#' @param to A numeric year between 2001 and 2023. Indicates the end of the analysis period.
#' @param region A `sf` object representing the area of interest.
#' @param fun A string indicating the reducer to apply (e.g., `"mean"`, `"sum"`). Default is `"mean"`.
#' @param progress Logical. Show progress bar? Default is `FALSE`.
#' @param sf Logical. Return result as an `sf` object? Default is `TRUE`.
#' @param force Logical. Force request extract.
#'
#' @return A `data.frame` or `sf` object with forest loss per year in square kilometers.
#'
#' @details
#' Forest loss is derived from the Hansen Global Forest Change dataset (`UMD/hansen/global_forest_change_2023_v1_11`).
#' The `lossyear` band encodes the year of forest cover loss as follows:
#'
#' - Values range from **1 to 23**, corresponding to the years **2001 to 2023**.
#' - A value of **0** indicates **no forest loss** detected.
#' - Forest loss is defined as a **stand-replacement disturbance**, or a change from forest to non-forest state.
#'
#' This function uses those values to calculate annual forest loss within the specified region and year range.
#'
#' @section Lifecycle:
#' `r lifecycle::badge('stable')`
#'
#' @examples
#' \dontrun{
#' library(rgee)
#' library(sf)
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
#' result <- calculate_forest_loss(from = 2005, to = 2007, region = region)
#' print(result)
#' }
#'
#' @references
#' Hansen, M. C., Potapov, P. V., Moore, R., Hancher, M., Turubanova, S. A., Tyukavina, A., ... & Townshend, J. R. G. (2013).
#' *High-Resolution Global Maps of 21st-Century Forest Cover Change*. Science, 342(6160), 850–853.
#' DOI: \doi{10.1126/science.1244693}
#'
#' @export
calculate_forest_loss <- function(from, to, region, fun = "mean", progress = FALSE, sf = TRUE, force = FALSE) {

  # Validate input years
  if (!is.numeric(from) || nchar(as.character(from)) != 4) {
    cli::cli_abort("Parameter {.field from} must be a 4-digit numeric year. Got: {.val {from}}")
  }

  if (!is.numeric(to) || nchar(as.character(to)) != 4) {
    cli::cli_abort("Parameter {.field to} must be a 4-digit numeric year. Got: {.val {to}}")
  }

  if (from < 2001 || to > 2023) {
    cli::cli_abort("Years must be in the range 2001 to 2023. Got: {.val {from}} to {.val {to}}")
  }

  if (to < from) {
    cli::cli_abort("Parameter {.field to} must be greater than or equal to {.field from}")
  }

  # Create year range (01, 02, ..., 23)
  range_date <- substr(as.character(from:to), start = 3, stop = 4) |> as.integer()


  # Convert region to Earth Engine object
  sf_box <- rgee::sf_as_ee(region)

  # Create binary image with lossyear in range
  hanse_data_pre <- .internal_data$hansen |>
    ee$Image$select('lossyear')

  # Check if region is spatially representative
  if (!force) {
    gee_check_representativity(region, image = hanse_data_pre, scale = 30, min_pixels = 2,abort = TRUE)
  }

  hanse_data <-hanse_data_pre |>
    ee$Image$eq(range_date)

  # Multiply by pixel area to get area lost in m² → convert to km²
  area_hansen_data <- hanse_data$
    multiply(ee$Image$pixelArea())$
    divide(1e6)

  # Extract with reducer
  extract_df <- rgee::ee_extract(
    x = area_hansen_data,
    y = sf_box,
    fun = get_reducer(fun),
    scale = 30,
    sf = FALSE
  ) |>
    tidyr::pivot_longer(
      cols = tidyr::starts_with("constant"),
      names_to = "year",
      values_to = "loss_year_km2"
    ) |>
    dplyr::mutate(year = from:to)

  # Return result
  if (sf) {
    extract_df <- dplyr::bind_cols(region, extract_df)
  }

  return(extract_df)
}
