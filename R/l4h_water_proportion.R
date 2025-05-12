#' Annual Proportion of Water Coverage from MapBiomas Perú
#'
#' @description
#' The function returns the proportion of each region's area that is covered by surface water for each year.
#' The values are expressed as a decimal ratio between 0 and 1 (e.g., 0.25 means 25% of the area was covered by water).
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param from Integer. Start year (e.g., 1985).
#' @param to Integer. End year (e.g., 2022). Must be equal to or greater than `from`.
#' @param region A spatial object defining the region of interest.
#' Can be an Earth Engine geometry (e.g., \code{ee$FeatureCollection}, \code{ee$Feature}),
#' an \code{sf} or \code{sfc} object, or a \code{SpatVector} (from the \pkg{terra} package).
#' The object will be converted to an Earth Engine FeatureCollection if needed.
#' @param fun Character. Summary function to apply. Values include \code{"mean"}, \code{"sum"},\code{"median"} , etc. Default is \code{"mean"}.
#' @param sf Logical. Return result as an `sf` object? Default is `TRUE`.
#' If `FALSE`, returns the Earth Engine `ImageCollection`.
#' @param force Logical. If `TRUE`, skips internal representativity checks on the input geometry.
#' Defaults to `FALSE`.
#' @param ... Additional arguments passed to internal processing functions (e.g., reducers).
#'
#' @return An object containing annual water coverage. Depending on `sf`, it may be an `sf` object,
#' a list, or an Earth Engine `ImageCollection` with yearly layers.
#'
#' @references
#' - MapBiomas Perú (2021). *Colección 1 – Annual water coverage*.
#' Mapbiomas project, available on: \url{https://peru.mapbiomas.org/colecciones-de-mapbiomas-peru/}
#'
#' @examples
#' \dontrun{
#' # Extract water coverage between 2000 and 2020
#' l4h_water_coverage(from = 2000, to = 2020, region = my_basin)
#' }
#'
#' @export
l4h_water_proportion <- function(from, to, region, fun = "mean" ,sf = TRUE, force = FALSE, ...) {
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
  water_data_index <- function(){
    extract_area <- rgee::ee_extract(
      x = water_data_area,
      y = region_ee,
      fun = get_reducer(name = fun),
      scale = 30,
      sf = TRUE,
      quiet = FALSE,
      lazy = FALSE,
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
      dplyr::relocate(water_proportion,.before = geom_col)
  }

  return(extract_area)
}
