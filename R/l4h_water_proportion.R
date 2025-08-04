#' Annual Proportion of Water Coverage from MapBiomas Peru
#'
#' @description
#' The function returns the proportion of each region's area that is covered by surface water for each year.
#' The values are expressed as a decimal ratio between 0 and 1 (e.g., 0.25 means 25\% of the area was covered by water).
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param from Integer. Start year (e.g., 1985).
#' @param to Integer. End year (e.g., 2022). Must be equal to or greater than `from`.
#' @param region A spatial object defining the region of interest.
#' Can be an \code{sf}, \code{sfc} object, or a \code{SpatVector} (from the \pkg{terra} package).
#' @param fun Character. Summary function to apply. Values include \code{"mean"}, \code{"sum"},\code{"median"} , etc. Default is \code{"mean"}.
#' @param sf Logical. Return result as an `sf` object? Default is `TRUE`.
#' @param quiet Logical. If TRUE, suppress the progress bar (default FALSE).
#' If `FALSE`, returns the Earth Engine `ImageCollection`.
#' @param force Logical. If `TRUE`, skips internal representativity checks on the input geometry.
#' Defaults to `FALSE`.
#' @param ... arguments of `ee_extract` of `rgee` packages.
#'
#' @return An object containing annual water coverage. Depending on `sf`, it may be an `sf` object,
#' a list, or an Earth Engine `ImageCollection` with yearly layers.
#'
#' @references
#' - MapBiomas Peru (2021). *Collection 1 – Annual water coverage*.
#' Mapbiomas project, available on: \url{https://peru.mapbiomas.org/colecciones-de-mapbiomas-peru/}
#'
#' @examples
#' \dontrun{
#' library(land4health)
#' ee_Initialize()
#'
#' # Define region as a bounding box (Ucayali, Peru)
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
#' # Extract water coverage between 2000 and 2020
#' l4h_water_proportion(
#'   from = 2000,
#'   to = 2020,
#'   region = region)
#' }
#'
#' @export
l4h_water_proportion <- function(from, to, region, fun = "mean", sf = TRUE, quiet = FALSE, force = FALSE, ...) {
  # Validate input years
  if (!is.numeric(from) || nchar(as.character(from)) != 4) {
    cli::cli_abort("Parameter {.field from} must be a 4-digit numeric year. Got: {.val {from}}")
  }

  if (!is.numeric(to) || nchar(as.character(to)) != 4) {
    cli::cli_abort("Parameter {.field to} must be a 4-digit numeric year. Got: {.val {to}}")
  }

  if (from < 1987 || to > 2022) {
    cli::cli_abort("Years must be in the range 1987 to 2022. Got: {.val {from}} to {.val {to}}")
  }

  if (to < from) {
    cli::cli_abort("Parameter {.field to} must be greater than or equal to {.field from}")
  }

  # Create year range (01, 02, ..., 23)
  range_date_original <- from:to
  band_names <- sprintf(fmt = "annual_water_coverage_%s", range_date_original)

  # Define supported classes
  sf_classes <- c("sf", "sfc", "SpatVector")

  # Check input object class
  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object.")
  }

  # Create binary image with lossyear in range
  water_data_db <- .internal_data$water_coverage |>
    ee$Image$select(c(band_names))

  # Check if region is spatially representative
  if (isFALSE(force)) {
    check_representativity(
      region = region,
      scale = 30
    )
  }
  # Multiply by pixel area to get area lost in m² → convert to km²
  water_data_area <- water_data_db$
    multiply(ee$Image$pixelArea())$
    divide(1e6)

  # Extract with reducer
  water_data_index <- function() {
    extract_area <- extract_ee_with_progress(
      image = water_data_area,
      sf_region = region,
      fun = fun,
      scale = 30,
      sf = TRUE,
      quiet = quiet,
      ...
    )
    geom_col <- attr(extract_area, "sf_column")
    extract_area <- extract_area |>
      (\(x) dplyr::mutate(x, area_km2 = as.vector(sf::st_area(sf::st_geometry(x)) / 1e6)))() |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("annual_water_coverage"),
        names_to = "year",
        values_to = "water_coverage"
      ) |>
      dplyr::mutate(
        year = as.Date(
          ISOdate(
            factor(year, labels = range_date_original),
            1,
            1
          )
        )
      ) |>
      dplyr::mutate(water_proportion = water_coverage / area_km2) |>
      dplyr::select(-area_km2, -water_coverage)
  }

  # Ejecuta el procesamiento del índice
  extract_area <- water_data_index()

  # Según argumento `sf`, devuelve con o sin geometría
  if (isFALSE(sf)) {
    extract_area <- sf::st_drop_geometry(extract_area) |>
      dplyr::relocate(water_proportion, .before = geom_col)
  }

  return(extract_area)
}
