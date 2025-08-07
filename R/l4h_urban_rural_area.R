#' Extracts surface areas by urban and rural categories from GHS-SMOD
#'
#' @description
#' Calculates the surface area (in km2) of urban, rural, or all settlement classes every 5 years between
#' 1985 and 2030 using the GHS-SMOD R2023A dataset. This product applies the Degree of Urbanization
#' methodology (Stage I) to the GHS-POP R2023A and GHS-BUILT-S R2023A layers. The function summarizes
#' areas by category and year over the specified region.
#'
#' `r lifecycle::badge('questioning')`
#
#' @param region An `sf` object defining the region of interest.
#' @param category Character. Settlement category to extract: `"urban"`, `"rural"`, or `"all"`.
#' @param scale Numeric. Spatial resolution (in meters) to use for area calculation (e.g., `30`).
#' @param sf Logical. If `TRUE`, returns an `sf` object. Default is `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress messages. Default is `FALSE`.
#' @param force Logical. If `TRUE`, forces the extraction request even if cached results exist.
#' @param ... Additional arguments passed to `ee_extract()` from the `rgee` package.
#'
#' @return A `tibble` with estimated settlement area (in km2) by year and category.
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
#' # Extract surface area of urban category (in km2)
#' urban_area <- l4h_urban_area(
#'   category = "urban",
#'   region = region)
#'
#' head(urban_area)
#'
#' # Extract surface area of rural category (in km2)
#' rural_area <- l4h_urban_area(
#'   category = "rural",
#'   region = region)
#'
#' head(rural_area)
#'
#' # Extract total surface area (urban + rural) (in km2)
#' all_area <- l4h_urban_area(
#'   category = "all",
#'   region = region)
#'
#' head(all_area)
#' }
#'
#' @references
#' - European Commission, Joint Research Centre (JRC). GHS Settlement Grid R2023A (1975–2030).
#' Available at: \url{https://data.jrc.ec.europa.eu/dataset/a0df7a6f-49de-46ea-9bde-563437a6e2ba#dataaccess}
#'
#' @export
l4h_urban_rural_area <- function(region, category = "all", scale = 1000, sf = TRUE, quiet = FALSE, force = FALSE, ...) {

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

  ghsl_ic <- ee$ImageCollection(.internal_data$ghsl$id)$toBands()
  eq_rural <- ghsl_ic$updateMask(ghsl_ic$eq(12)$Or(ghsl_ic$eq(13)))
  eq_urban <- ghsl_ic$eq(21)$Or(ghsl_ic$eq(22)$Or(ghsl_ic$eq(23)$Or(ghsl_ic$eq(30))))
  rural_area <- calculate_area(eq_rural)
  urban_area <- calculate_area(eq_urban)

  img_db <- switch(
    category,
    urban = urban_area,
    rural = rural_area,
    all = rural_area$add(urban_area),
    cli::cli_abort("Invalid category. Use 'urban', 'rural', or 'all'.")
  )

  # Extract with reducer
  if (isTRUE(sf)) {
    extract_area <- extract_ee_with_progress(
      image = img_db,
      sf_region = region,
      scale = 1000,
      fun = "sum",
      sf = TRUE,
      quiet = quiet,
      ...
    )

    geom_col <- attr(extract_area, "sf_column")
    extract_area <- extract_area |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("GHS"),
        names_to = "date",
        values_to = "area_km2") |>
      dplyr::mutate(
        date = seq(1975,2030, by = 5),
        variable = category) |>
      dplyr::relocate(c("date", "variable", "area_km2"), .before = all_of(geom_col))


  } else {
    extract_area <- extract_ee_with_progress(
      image = img_db,
      sf_region = region,
      scale = 1000,
      fun = "sum",
      sf = FALSE,
      quiet = quiet,
      ...
    ) |>
      tidyr::pivot_longer(
        cols = tidyr::starts_with("GHS"),
        names_to = "date",
        values_to = "area_km2") |>
      dplyr::mutate(
        date = seq(1975,2030, by = 5),
        variable = category)
  }
  return(extract_area)
}
