#' Calculate Forest Loss
#'
#' @description
#' Calculates forest loss within a user-defined region for a specified year range.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param from A numeric year between 2001 and 2023. Indicates the start of the analysis period.
#' @param to A numeric year between 2001 and 2023. Indicates the end of the analysis period.
#' @param region A spatial object defining the region of interest.
#' Can be an \code{sf}, \code{sfc} object, or a \code{SpatVector} (from the \pkg{terra} package).
#' @param sf Logical. Return result as an `sf` object? Default is `TRUE`.
#' @param quiet Logical. If TRUE, suppress the progress bar (default FALSE).
#' @param force Logical. Force request extract.
#' @param ... arguments of `ee_extract` of `rgee` packages.
#'
#' @return A `sf` or `tibble` object with forest loss per year in square kilometers.
#'
#' @details
#' Forest loss is derived from the Hansen Global Forest Change dataset (`UMD/hansen/global_forest_change_2023_v1_11`).
#' The `lossyear` band encodes the year of forest cover loss as follows:
#'
#' - Values range from **1 to 23**, corresponding to the years **2001 to 2023**.
#' - A value of **0** indicates **no forest loss** detected.
#' - Forest loss is defined as a **stand-replacement disturbance**, or a change from forest to non-forest state.
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
#' result <- l4h_forest_loss(from = 2005, to = 2007, region = region)
#' print(result)
#' }
#'
#' @references
#' Hansen, M. C., Potapov, P. V., Moore, R., Hancher, M., Turubanova, S. A., Tyukavina, A., ... & Townshend, J. R. G. (2013).
#' *High-Resolution Global Maps of 21st-Century Forest Cover Change*. Science, 342(6160), 850–853.
#' DOI: \doi{10.1126/science.1244693}
#'
#' @export
l4h_forest_loss <- function(from, to, region, sf = TRUE, quiet = FALSE, force = FALSE, ...) {
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
  range_date_original <- from:to
  range_date_processed <- as.integer(substr(as.character(range_date_original), start = 3, stop = 4))

  # Define supported classes
  sf_classes <- c("sf", "sfc", "SpatVector")

  # Check input object class
  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object.")
  }

  # Create binary image with lossyear in range
  hanse_data_db <- ee$Image(.internal_data$hansen)$select("lossyear")
  hanse_data_img <- hanse_data_db$eq(range_date_processed)

  # Check if region is spatially representative
  if (isFALSE(force)) {
    check_representativity(
      region = region,
      scale = 30
    )
  }
  # Multiply by pixel area to get area lost in m² → convert to km²
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
        date = as.Date(
          ISOdate(factor(date, labels = range_date_original), 1, 1)
          ),
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
      ...) |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("constant"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = as.Date(
          ISOdate(
            factor(date, labels = range_date_original), 1, 1
            )
          ),
        variable = "forest_loss"
      )
  }
  return(extract_area)
}
