#' Compute Rural Access Index (RAI)
#'
#' @description
#' Calculates the Rural Access Index (RAI) for a given region using datasets from the GEE Community Catalog.
#' The RAI represents the proportion of the rural population living within 2 km of an all-season road,
#' aligning with SDG indicator 9.1.1.
#'
#' \if{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.png}{options: width="120"}
#' }}
#' \if{latex}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.pdf}{options: width=2cm}
#' }}
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
#' @references
#' GEE Community Catalog: \url{https://gee-community-catalog.org/projects/rai/}
#'
#' Frontiers in Remote Sensing (2024): \doi{10.3389/frsen.2024.1375476}
#'
#' @examples
#' \dontrun{
#' library(land4health)
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
#'   crs = 4326
#' ))
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

    rai_id <- tryCatch(.internal_data$ruralaccess$id, error = function(e) character(0))
    if (length(rai_id) == 0 || !is.character(rai_id) || nchar(rai_id[1]) == 0) {
      rai_id <- "projects/sat-io/open-datasets/RAI/ruralpopaccess"
    }
    img_index <- rgee::ee$Image(rai_id[1])

    # Extract with reducer
    if (isTRUE(sf)) {
      extract_area <- l4h_ee_extract(
        image = img_index,
        sf_region = region,
        scale = 100,
        fun = fun,
        sf = TRUE,
        quiet = quiet
      )
    } else {
      extract_area <- l4h_ee_extract(
        image = img_index,
        sf_region = region,
        scale = 100,
        fun = fun,
        sf = FALSE,
        quiet = quiet
      )
    }

    band_col <- setdiff(names(extract_area), c(attr(extract_area, "sf_column"), names(region)))
    if (length(band_col) == 1) {
      extract_area <- extract_area |>
        dplyr::rename(rai_index_w = dplyr::all_of(band_col))
    }
  } else {
    inacc_id <- tryCatch(.internal_data$inaccessibility$id, error = function(e) character(0))
    if (length(inacc_id) == 0 || !is.character(inacc_id) || nchar(inacc_id[1]) == 0) {
      inacc_id <- "projects/sat-io/open-datasets/RAI/raimultiplier"
    }
    img <- rgee::ee$Image(inacc_id[1])

    img_index <- img$multiply(ee$Image$pixelArea())$
      divide(1e6)

    # Extract with reducer
    if (isTRUE(sf)) {
      extract_area <- l4h_ee_extract(
        image = img_index,
        sf_region = region,
        scale = 100,
        fun = "sum",
        sf = TRUE
      )

      band_col <- setdiff(names(extract_area), c(attr(extract_area, "sf_column"), names(region)))
      extract_area <- extract_area |>
        (\(x) dplyr::mutate(x, area_km2 = as.vector(sf::st_area(sf::st_geometry(x)) / 1e6)))() |>
        dplyr::rename(rai_index = dplyr::all_of(band_col)) |>
        dplyr::mutate(rai_index = rai_index / area_km2) |>
        dplyr::select(-area_km2)
    } else {
      extract_area <- l4h_ee_extract(
        image = img_index,
        sf_region = region,
        scale = 100,
        fun = "sum",
        sf = FALSE
      )

      band_col <- setdiff(names(extract_area), names(region))
      extract_area <- extract_area |>
        (\(x) {
          geom <- sf::st_geometry(region)
          x$area_km2 <- as.vector(sf::st_area(geom) / 1e6)
          x
        })() |>
        dplyr::rename(rai_index = dplyr::all_of(band_col)) |>
        dplyr::mutate(rai_index = rai_index / area_km2) |>
        dplyr::select(-area_km2)
    }
  }

  return(extract_area)
}
