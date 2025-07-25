#' Extract Urban Area from MODIS Land Cover (MCD12Q1.061)
#'
#' @description
#' Extracts the annual area of a specific land cover class from the MODIS Land Cover product (MCD12Q1.061),
#' using the specified land cover classification scheme (band).
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param from Character string indicating the starting year (e.g., `"2010"`).
#' @param to Character string indicating the ending year (e.g., `"2020"`).
#' @param region A `sf` object representing the region of interest.
#' @param scale Numeric. The nominal scale in meters to use for the area calculation (e.g., `500`).
#' @param lc_band Character. The MODIS land cover classification band to use. One of:
#' `"LC_Type1"` (default), `"LC_Type2"`, `"LC_Type3"`, `"LC_Type4"`, or `"LC_Type5"`.
#' @param sf Logical. Return result as an `sf` object? Default is `TRUE`.
#' @param quiet Logical. If `TRUE`, suppress the progress bar (default `FALSE`).
#' @param force Logical. Force request extract.
#' @param ... arguments of `ee_extract` of `rgee` packages.
#'
#' @return A `tibble` containing the year and area (in km²) of the selected land cover class.
#'
#' @details
#' This function uses the MODIS Land Cover Type Yearly Global 500m dataset (MCD12Q1.061) from Google Earth Engine.
#' It calculates the area of the land cover class `"13"` (Urban and Built-Up Lands) based on the selected band.
#'
#' ## Available Classification Schemes:
#'
#' - **LC_Type1**: IGBP global vegetation classification (17 classes)
#' - **LC_Type2**: University of Maryland (UMD) land cover classification
#' - **LC_Type3**: MODIS LAI/FPAR Biome Type classification
#' - **LC_Type4**: MODIS Net Primary Production (NPP) Biome classification
#' - **LC_Type5**: Plant Functional Type (PFT) classification
#'
#' **Note:** The function currently extracts only class `13` (Urban), which may correspond to different meanings depending on the selected `lc_band`.
#'
#' For detailed class definitions of each scheme, refer to:
#' [MODIS/061/MCD12Q1 on Google Earth Engine](https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MCD12Q1)
#'
#' @examples
#' \dontrun{
#'
#' library(land4health)
#' library(geoidep)
#' ee_Initialize()
#' region <- get_districts()
#' region_ee <- pol_as_ee(region, id = 'distr' ,simplify = 1000)
#' data <- get_urban(from = 2008, to = 2010, region = region)
#'
#' }
# Function for extract urban areas

l4h_urban_area <- function(from, to, region, scale = 500, lc_band = "LC_Type2", sf = TRUE, quiet = FALSE, force = FALSE, ...) {

  lc_band <- match.arg(lc_band, choices = c("LC_Type1", "LC_Type2", "LC_Type3", "LC_Type4", "LC_Type5"))

  # Conditions about the times
  start_year <- as.numeric(substr(from, 1, 4))
  end_year <- as.numeric(substr(to, 1, 4))

  start_year_from_ee <- as.numeric(.internal_data$mcd12q1.061$startyear)
  end_year_from_ee  <- as.numeric(.internal_data$mcd12q1.061$endyear)

  if (start_year < start_year_from_ee || end_year > end_year_from_ee) {
    cli::cli_abort(
      glue::glue(
        "MODIS MCD12Q1 data is only available from {start_year_from_ee} to {end_year_from_ee}."
        )
      )
  }

  years <- ee$List(as.list(seq(start_year, end_year)))

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
      scale = 500
    )
  }

  image_list <- years$map(
    rgee::ee_utils_pyfunc(function(y) {
      year_img <- ee$ImageCollection(.internal_data$mcd12q1.061$id)$
        filter(ee$Filter$calendarRange(y, y, "year"))$
        select(lc_band)$
        first()

      urban_area <- year_img$eq(13)$
        selfMask()$
        multiply(ee$Image$pixelArea())$
        divide(1e6)
      return(urban_area)
    })
  )

  urban_stack <- ee$ImageCollection$fromImages(image_list)$toBands()

  # Extract with reducer
  if (isTRUE(sf)) {
    extract_area <- extract_ee_with_progress(
      image = urban_stack,
      sf_region = region,
      scale = 500,
      fun = "sum",
      sf = TRUE,
      quiet = quiet,
      ...
    )

    geom_col <- attr(extract_area, "sf_column")
    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("X"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = start_year:end_year,
        variable = "urban_area") |>
      dplyr::relocate(c("date", "variable", "value"), .before = all_of(geom_col))


  } else {
    extract_area <- extract_ee_with_progress(
      image = urban_stack,
      sf_region = region,
      scale = 500,
      fun = "sum",
      sf = FALSE,
      quiet = quiet,
      ...
    ) |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("X"),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = start_year:end_year,
        variable = "urban_area")
  }
  return(extract_area)
}
