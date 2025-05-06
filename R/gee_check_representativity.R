#' Check spatial representativity of a polygon in Google Earth Engine
#'
#' Evaluates whether a given polygon covers a minimum number of valid pixels
#' in a specified Earth Engine image.
#'
#' @param region An `sf` polygon object representing the area of interest.
#' @param image An Earth Engine image (`ee$Image`) to evaluate coverage against.
#' @param scale Numeric. Pixel resolution in meters (e.g., 30 for Hansen).
#' @param min_pixels Numeric. Minimum number of pixels required to be considered representative. Default is 2.
#' @param abort Logical. If `TRUE`, the function stops on failure. If `FALSE`, returns `FALSE` with a warning.
#'
#' @return Invisible `TRUE` if representative; otherwise `FALSE`.
#' @export
gee_check_representativity <- function(region, image, scale = 30, min_pixels = 2, abort = FALSE) {
  if (!inherits(region, "sf")) {
    cli::cli_abort("The {.arg region} must be an {.cls sf} object.")
  }

  region_ee <- rgee::sf_as_ee(region)

  # Create binary mask where pixels are valid (not masked out)
  mask <- image |>
    ee$Image$mask() |>
    ee$Image$gt(0)

  pixel_area_m2 <- scale * scale

  # Estimate pixel count by dividing area by one pixel
  pixel_count_image <- mask$
    multiply(ee$Image$pixelArea())$
    divide(pixel_area_m2)$
    rename("pixel_count")

  # Extract total count over the region
  result <- rgee::ee_extract(
    x = pixel_count_image,
    y = region_ee,
    fun = ee$Reducer$sum(),
    scale = scale,
    sf = FALSE
  )

  # Minimum pixels per feature (row-wise)
  pixel_counts <- result[["pixel_count"]]

  if (any(is.na(pixel_counts))) {
    cli::cli_warn("Pixel count result contains NA values — possibly outside image extent.")
    return(invisible(FALSE))
  }

  if (min(pixel_counts) < min_pixels) {
    msg <- c(
      "!" = "The region does not cover enough pixels to be representative.",
      "i" = "Minimum required: {min_pixels} pixels at {scale}m resolution.",
      "x" = "Smallest region covers: {round(min(pixel_counts), 2)} pixels."
    )
    if (abort) {
      cli::cli_abort(msg)
    } else {
      cli::cli_warn(msg)
    }
    return(invisible(FALSE))
  }

  return(invisible(TRUE))
}
