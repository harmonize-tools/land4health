#' Travel Time to Healthcare or Cities (Oxford Dataset)
#'
#' @description
#' Retrieves the travel time raster (in minutes) to the nearest healthcare facility
#' or populated city, based on the Oxford Global Map of Accessibility datasets.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param region A spatial object defining the region of interest.
#' Can be an \code{sf}, \code{sfc} object, or a \code{SpatVector} (from the \pkg{terra} package).
#' @param destination Character. Target destination for travel time.
#' Use `"healthcare"` (default) for travel time to the nearest healthcare facility, or
#' `"cities"` for travel time to the nearest populated urban center.
#' @param transport_mode Character. Mode of transportation.
#' Use `"all"` (default) for general travel time (mixed modes),
#' or `"walking_only"` for walking-only accessibility (**only valid when `destination = "healthcare"`**).
#' @param fun Character. Summary function to apply. Values include \code{"mean"}, \code{"sum"},\code{"median"} , etc. Default is \code{"mean"}.
#' @param sf Logical. If \code{TRUE}, returns the result as an \code{sf} object. If \code{FALSE},
#' returns an Earth Engine object. Default is \code{FALSE}.
#' @param quiet Logical. If TRUE, suppress the progress bar (default FALSE).
#' @param force Logical. If `TRUE`, skips the internal representativity check of the input region.
#' Defaults to `FALSE`.
#' @param ... arguments of `ee_extract` of `rgee` packages.
#'
#' @return A spatial object containing the computed RAI value for the region in an
#' \code{sf} or \code{tibble} object.
#'
#' @examples
#' @examples
#' \dontrun{
#' library(land4health)
#' library(sf)
#' ee_Initialize()
#'
#' # Define a bounding-box region in Ucayali, Peru
#' region <- st_as_sf(
#'   st_sfc(
#'     st_polygon(list(matrix(
#'       c(
#'         -74.1, -4.4,
#'         -74.1, -3.7,
#'         -73.2, -3.7,
#'         -73.2, -4.4,
#'         -74.1, -4.4
#'       ), ncol = 2, byrow = TRUE
#'     )))
#'   ),
#'   crs = 4326
#' )
#'
#' # Travel time to nearest healthcare facility (all modes)
#' result_hosp_all <- l4h_travel_time(region = region)
#' head(result_hosp_all)
#'
#' # Travel time to nearest healthcare facility (walking only)
#' result_hosp_walk <- l4h_travel_time(
#'   region        = region,
#'   destination   = "healthcare",
#'   transport_mode = "walking_only")
#'
#' head(result_hosp_walk)
#'
#' # Mean travel time to nearest cities (mixed modes)
#' result_city_mean <- l4h_travel_time(
#'   region      = region,
#'   destination = "cities",
#'   fun         = "mean")
#'
#' head(result_city_mean)
#'
#' # Sum of travel time to nearest cities
#' result_city_sum <- l4h_travel_time(
#'   region      = region,
#'   destination = "cities",
#'   fun         = "sum")
#'
#' head(result_city_sum)
#' }
#'
#' @references
#' - Weiss, D.J. et al. (2018). *A global map of travel time to cities to assess inequalities in accessibility in 2015.*
#' Nature, 553(7688), 333–336. DOI: 10.1038/nature25181
#'
#' - Weiss, D.J. et al. (2020). *Global maps of travel time to healthcare facilities.*
#' Nature Medicine, 26, 1835–1838. DOI: 10.1038/s41591-020-1059-1
#'
#' @export

l4h_travel_time <- function(region, destination = "cities", transport_mode = "all", fun = "mean", sf = FALSE, quiet = FALSE, force = FALSE, ...) {
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
      scale = 1000
    )
  }

  # Dataset selection based on destination and transport_mode
  if (destination == "healthcare") {
    # Valid modes: "all", "walking_only"
    band <- switch(transport_mode,
      "all" = "accessibility",
      "walking_only" = "accessibility_walking_only",
      cli::cli_abort(c(
        "!" = "Invalid {.arg transport_mode} for {.strong destination = \"healthcare\"}.",
        "x" = "Valid options are {.val \"all\"} and {.val \"walking_only\"}."
      ))
    )

    # Load healthcare image
    img_index <- .internal_data$access_healthcare$id |>
      ee$Image() |>
      ee$Image$select(band) |>
      ee$Image$rename("healthcare_access")
  } else if (destination == "cities") {
    if (transport_mode != "all") {
      cli::cli_abort(c(
        "!" = "{.arg transport_mode = \"walking_only\"} is not supported for {.strong destination = \"cities\"}.",
        "x" = "Only {.val \"all\"} is valid for cities."
      ))
    }

    # Load cities image
    img_index <- .internal_data$access_cities$id |>
      ee$Image() |>
      ee$Image$select("accessibility") |>
      ee$Image$rename("city_access")
  } else {
    cli::cli_abort(c(
      "!" = "{.strong land4health()} only supports {.val \"healthcare\"} and {.val \"cities\"} as valid values for {.arg destination}.",
      "x" = "Please select one of these two options."
    ))
  }

  # Extract with reducer
  if (isTRUE(sf)) {
    extract_area <- extract_ee_with_progress(
      image = img_index,
      sf_region = region,
      fun = fun,
      scale = 1000,
      sf = TRUE,
      quiet = FALSE,
      lazy = FALSE
    )
  } else {
    extract_area <- extract_ee_with_progress(
      image = img_index,
      sf_region = region,
      fun = fun,
      scale = 1000,
      sf = FALSE
    )
  }

  return(extract_area)
}
