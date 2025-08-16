#' Compute Rural Access Index (RAI)
#'
#' @description
#' Calculates the Rural Access Index (RAI) for a given region using datasets from the GEE Community Catalog.
#' The RAI represents the proportion of the rural population living within 2 km of an all-season road,
#' aligning with SDG indicator 9.1.1.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param region A spatial object defining the region of interest.
#' Can be an \code{sf}, \code{sfc} object, or a \code{SpatVector} (from the \pkg{terra} package).
#' @param weighted Logical. If \code{TRUE}, computes a population-weighted RAI (i.e., rural population with access
#' divided by total rural population). If \code{FALSE}, computes an area-based RAI (i.e., total pixel area with access
#' divided by total rural area). Default is \code{FALSE}.
#' @param fun Character. Summary function to apply to the population raster when \code{weighted = TRUE}.
#' Common values include \code{"mean"}, \code{"sum"}, etc. Ignored when \code{weighted = FALSE}. Default is \code{"mean"}.
#' @param sf Logical. If \code{TRUE}, returns the result as an \code{sf} object. If \code{FALSE},
#' returns an Earth Engine object. Default is \code{FALSE}.
#' @param quiet Logical. If TRUE, suppress the progress bar (default FALSE).
#' @param force Logical. If \code{TRUE}, skips the representativity check and forces the extraction. Default is \code{FALSE}.
#' @param ... arguments of `ee_extract` of `rgee` packages.
#'
#' @details
#' This function uses the following datasets from the GEE Community Catalog:
#' \itemize{
#'   \item \code{projects/sat-io/open-datasets/RAI/ruralpopaccess/} – raster of rural population with access to all-season roads
#'   \item \code{projects/sat-io/open-datasets/RAI/inaccessibilityindex/} – binary raster indicating access areas (1 = access, 0 = no access)
#' }
#'
#' When \code{weighted = TRUE}, the RAI is calculated as the sum (or chosen summary via \code{fun}) of the accessible rural population
#' divided by the total rural population within the specified region.
#'
#' When \code{weighted = FALSE}, the RAI is calculated as the ratio of pixel areas: the total area (in in km^2) with access
#' divided by the total rural area.
#'
#' The \code{fun} parameter only applies when \code{weighted = TRUE}. It will be ignored otherwise.
#'
#' @return A spatial object containing the computed RAI value for the region in an
#' \code{sf} or \code{tibble} object.
#'
#' @section Credits:
#' [![](innovalab.svg)](https://www.innovalab.info/)
#'
#' Pioneering geospatial health analytics and open‐science tools.
#' Developed by the Innovalab Team, for more information send a email to <imt.innovlab@oficinas-upch.pe>
#'
#' Follow us on :
#'  - ![](linkedin-innova.png)[Innovalab Linkedin](https://www.linkedin.com/company/innovalab-imt), ![](twitter-innova.png)[Innovalab X](https://x.com/innovalab_imt)
#'  - ![](facebook-innova.png)[Innovalab facebook](https://www.facebook.com/imt.innovalab), ![](instagram-innova.png)[Innovalab instagram](https://www.instagram.com/innovalab_imt/)
#'  - ![](tiktok-innova.png)[Innovalab tiktok](https://www.tiktok.com/@innovalab_imt), ![](spotify-innova.png)[Innovalab Podcast](https://www.innovalab.info/podcast)
#'
#' @references
#' GEE Community Catalog: \url{https://gee-community-catalog.org/projects/rai/}
#'
#' Frontiers in Remote Sensing (2024): \doi{10.3389/frsen.2024.1375476}
#'
#' @examples
#' \dontrun{
#' library(land4health)
#' library(sf)
#' ee_Initialize()
#'
#' # Define a bounding box region in Ucayali, Peru
#' region <- st_as_sf(st_sfc(
#'   st_polygon(list(matrix(c(
#'     -74.1, -4.4,
#'     -74.1, -3.7,
#'     -73.2, -3.7,
#'     -73.2, -4.4,
#'     -74.1, -4.4
#'   ), ncol = 2, byrow = TRUE))),
#'
#' # Population-weighted RAI
#' rai_w <- l4h_rural_access_index(
#'     region = region,
#'     weighted = TRUE,
#'     fun = "sum",
#'     sf = TRUE)
#' head(rai_w)
#'
#' # Area-based RAI
#' rai <- l4h_rural_access_index(
#'     region = region,
#'     weighted = FALSE,
#'     sf = TRUE)
#' head(rai)
#' }
#'
#' @export
l4h_rural_access_index <- function(region, weighted = FALSE, fun = NULL, sf = FALSE, quiet = FALSE, force = FALSE, ...) {
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

  if (isTRUE(weighted)) {
    if (is.null(fun)) {
      cli::cli_abort(c(
        "Missing required argument {.arg fun}.",
        "i" = "This argument must be provided when {.arg weighted = TRUE}."
      ))
    }

    img_index <- rgee::ee$Image(.internal_data$ruralaccess$id)

    # Extract with reducer
    if (isTRUE(sf)) {
      extract_area <- extract_ee_with_progress(
        image = img_index,
        sf_region = region,
        scale = 100,
        fun = fun,
        sf = TRUE,
        quiet = quiet
      ) |>
        dplyr::rename(rai_index_w = population)
    } else {
      extract_area <- extract_ee_with_progress(
        image = img_index,
        sf_region = region,
        scale = 100,
        fun = fun,
        sf = FALSE,
        quiet = quiet
      ) |>
        dplyr::rename(rai_index_w = population)
    }
  } else {
    img <- rgee::ee$Image(.internal_data$inaccessibility)

    img_index <- img$multiply(ee$Image$pixelArea())$
      divide(1e6)

    # Extract with reducer
    if (isTRUE(sf)) {
      extract_area <- extract_ee_with_progress(
        image = img_index,
        sf_region = region,
        scale = 100,
        fun = "sum",
        sf = TRUE
      ) |>
        (\(x) dplyr::mutate(x, area_km2 = as.vector(sf::st_area(sf::st_geometry(x)) / 1e6)))() |>
        dplyr::rename(rai_index = b1) |>
        dplyr::mutate(rai_index = rai_index / area_km2) |>
        dplyr::select(-area_km2)

      geom_col <- attr(extract_area, "sf_column")

      extract_area <- extract_area |>
        (\(x) dplyr::mutate(x, area_km2 = as.vector(sf::st_area(sf::st_geometry(x)) / 1e6)))() |>
        dplyr::rename(rai_index = b1) |>
        dplyr::mutate(rai_index = rai_index / area_km2) |>
        dplyr::select(-area_km2)
    } else {
      extract_area <- extract_ee_with_progress(
        image = img_index,
        sf_region = region,
        scale = 100,
        fun = "sum",
        sf = TRUE
      ) |>
        (\(x) dplyr::mutate(x, area_km2 = as.vector(sf::st_area(sf::st_geometry(x)) / 1e6)))() |>
        dplyr::rename(rai_index = b1) |>
        dplyr::mutate(rai_index = rai_index / area_km2) |>
        dplyr::select(-area_km2) |>
        sf::st_drop_geometry()
    }
  }

  return(extract_area)
}
