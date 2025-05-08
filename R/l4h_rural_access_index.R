#' Compute Rural Access Index (RAI)
#'
#' Calculates the Rural Access Index (RAI) for a given region using datasets from the GEE Community Catalog.
#' The RAI represents the proportion of the rural population living within 2 km of an all-season road,
#' aligning with SDG indicator 9.1.1.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param region A spatial object defining the region of interest. Can be an Earth Engine
#' geometry (e.g., \code{ee$FeatureCollection}) or an \code{sf} object.
#' @param weighted Logical. If \code{TRUE}, computes a population-weighted RAI (i.e., rural population with access
#' divided by total rural population). If \code{FALSE}, computes an area-based RAI (i.e., total pixel area with access
#' divided by total rural area). Default is \code{FALSE}.
#' @param fun Character. Summary function to apply to the population raster when \code{weighted = TRUE}.
#' Common values include \code{"mean"}, \code{"sum"}, etc. Ignored when \code{weighted = FALSE}. Default is \code{"mean"}.
#' @param sf Logical. If \code{TRUE}, returns the result as an \code{sf} object. If \code{FALSE},
#' returns an Earth Engine object. Default is \code{FALSE}.
#' @param force Logical. If \code{TRUE}, skips the representativity check and forces the extraction. Default is \code{FALSE}.
#'
#' @details
#' This function uses the following datasets from the GEE Community Catalog:
#' \itemize{
#'   \item \code{projects/sat-io/open-datasets/RAI/ruralpopaccess} – raster of rural population with access to all-season roads
#'   \item \code{projects/sat-io/open-datasets/RAI/inaccessibilityindex} – binary raster indicating access areas (1 = access, 0 = no access)
#' }
#'
#' When \code{weighted = TRUE}, the RAI is calculated as the sum (or chosen summary via \code{fun}) of the accessible rural population
#' divided by the total rural population within the specified region.
#'
#' When \code{weighted = FALSE}, the RAI is calculated as the ratio of pixel areas: the total area (in km²) with access
#' divided by the total rural area.
#'
#' The \code{fun} parameter only applies when \code{weighted = TRUE}. It will be ignored otherwise.
#'
#' @return A spatial object containing the computed RAI value for the region, either as an Earth Engine object
#' or an \code{sf} object depending on the \code{sf} argument.
#'
#' @references
#' GEE Community Catalog: \url{https://gee-community-catalog.org/projects/rai}
#'
#' Frontiers in Remote Sensing (2024): \doi{10.3389/frsen.2024.1375476}
#'
#' @examples
#' \dontrun{
#' library(land4health)
#' ee_Initialize()
#' # Population-weighted RAI
#' l4h_rural_access_index(region, weighted = TRUE, fun = "sum", sf = TRUE)
#'
#' # Area-based RAI
#' l4h_rural_access_index(region, weighted = FALSE, sf = TRUE)
#' }
#'
#' @export
l4h_rural_access_index <- function(region, weighted = FALSE, fun = NULL, sf = FALSE, force = FALSE){
  region_ee <- region |>
    rgee::sf_as_ee()

  # Check if region is spatially representative
  if (isFALSE(force)) {
    check_representativity(
      region = region,
      scale = 30
    )
  }

  if(isTRUE(weighted)){
    img_index <- .internal_data$ruralpopulationwithaccess |> rgee::ee$Image()
    # Extract with reducer
    if (isTRUE(sf)) {
      extract_area <- rgee::ee_extract(
        x = img_index,
        y = region_ee,
        fun = get_reducer(name = "sum"),
        scale = 100,
        sf = TRUE,
        quiet = FALSE,
        lazy = FALSE)

    } else {
      extract_area <- rgee::ee_extract(
        x = img_index,
        y = region_ee,
        fun = get_reducer(name = "sum"),
        scale = 30,
        sf = FALSE)
    }


  } else{
    img <- .internal_data$inaccessibilityindex |>
      rgee::ee$Image()

    img_index <- img$multiply(ee$Image$pixelArea())$
      divide(1e6)
    # Extract with reducer
    if (isTRUE(sf)) {
      extract_area <- rgee::ee_extract(
        x = img_index,
        y = region_ee,
        fun = get_reducer(name = "sum"),
        scale = 100,
        sf = TRUE,
        quiet = FALSE,
        lazy = FALSE)

      geom_col <- attr(extract_area, "sf_column")
      extract_area <- extract_area |>
        (\(x) dplyr::mutate(x, area_km2 = as.vector(sf::st_area(sf::st_geometry(x)) / 1e6)))() |>
        dplyr::rename(rai_index = b1) |>
        dplyr::mutate(rai_index = rai_index/area_km2) |>
        dplyr::select(-area_km2)

    } else {
      extract_area <- rgee::ee_extract(
        x = img_index,
        y = region_ee,
        fun = get_reducer(name = "sum"),
        scale = 30,
        sf = FALSE) |>
        (\(x) dplyr::mutate(x, area_km2 = as.vector(sf::st_area(sf::st_geometry(x)) / 1e6)))() |>
        dplyr::rename(rai_index = b1) |>
        dplyr::mutate(rai_index = rai_index/area_km2) |>
        dplyr::select(-area_km2)

    }
  }

  return(extract_area)
}
