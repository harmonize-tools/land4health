#' Calculates the Surface Urban Heat Island (SUHI) index using MODIS LST and GHS-SMOD
#'
#' @description
#' Computes the SUHI (Surface Urban Heat Island) index as the difference between the
#' mean land surface temperature (LST) in urban and rural areas for each date in a
#' user-defined region and time range.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param from Character or Date. Start date (format: `"YYYY-MM-DD"`).
#' @param to Character or Date. End date (format: `"YYYY-MM-DD"`).
#' @param region Spatial object (`sf`, `sfc`, or `SpatVector`) defining the region.
#' @param band Character. `"day"` or `"night"` LST from MODIS. Default is `"day"`.
#' @param level Character. `"strict"` or `"moderate"` quality filter for MODIS. Default is `"strict"`.
#' @param stat Character. Aggregation statistic, e.g. `"mean"` or `"median"`. Default is `"mean"`.
#' @param scale Numeric. Resolution in meters. Default is `1000`.
#' @param sf Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`. Default is `TRUE`.
#' @param quiet Logical. If `TRUE`, suppress messages. Default is `FALSE`.
#' @param force Logical. If `TRUE`, skip representativity check. Default is `FALSE`.
#' @param ... Extra arguments passed to `ee_extract()`.
#'
#' @return A `tibble` or `sf` object with columns: `date`, `variable = "SUHI"`, and `value` (°C).
#'
#' @section Credits:
#' [![](innovalab.svg)](https://www.innovalab.info/)
#'
#' Pioneering geospatial health analytics and open‐science tools.
#' Developed by the Innovalab Team, for more information send a email to <imt.innovlab@oficinas-upch.pe>
#'
#' Follow us on :
#'  - ![](linkedin-innova.png)[Innovalab Linkedin](https://twitter.com/InnovalabGeo), ![](twitter-innova.png)[Innovalab X](https://x.com/innovalab_imt)
#'  - ![](facebook-innova.png)[Innovalab facebook](https://www.facebook.com/imt.innovalab), ![](instagram-innova.png)[Innovalab instagram](https://www.instagram.com/innovalab_imt/)
#'  - ![](tiktok-innova.png)[Innovalab tiktok](https://twitter.com/InnovalabGeo), ![](spotify-innova.png)[Innovalab Podcast](https://www.innovalab.info/podcast)
#'
#' @examples
#' \dontrun{
#' library(land4health)
#' ee_Initialize()
#'
#' # Define a bounding box region (Ucayali, Peru)
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
#' # Calculate SUHI using daytime LST (mean temperature difference)
#' suhi_day <- l4h_urban_heat_index(
#'   from = "2020-01-01",
#'   to = "2020-12-31",
#'   region = region,
#'   band = "day",
#'   stat = "mean"
#' )
#' head(suhi_day)
#'
#' # Calculate SUHI using nighttime LST (max difference)
#' suhi_night <- l4h_urban_heat_index(
#'   from = "2020-01-01",
#'   to = "2020-12-31",
#'   region = region,
#'   band = "night",
#'   stat = "max"
#' )
#' head(suhi_night)
#' }
#'
#' @export
l4h_urban_heat_index <- function(from, to, region,
                                 band = "day", level = "strict",
                                 stat = "max", scale = 1000,
                                 sf = TRUE, quiet = FALSE, force = FALSE, ...) {

  # Obtener LST urbano
  lst_urban <- l4h_surface_temp(
    from = from, to = to,
    region = region, band = band, level = level,
    stat = stat, scale = scale, sf = sf,
    quiet = quiet, force = force#, ...
  )

  # Obtener áreas urbanas y rurales
  region_ee    <- region |> dplyr::select(attr(region, "sf_column")) |> rgee::sf_as_ee()
  ghsl_ic      <- ee$ImageCollection(.internal_data$ghsl$id)$toBands()
  rural_mask   <- ghsl_ic$eq(12)$Or(ghsl_ic$eq(13))
  rural_binary <- rural_mask$updateMask(rural_mask)$multiply(1)$
    reduce(ee$Reducer$sum())$
    rename("rural")$
    clip(region_ee)$
    reproject('EPSG:4326', NULL, 1000)

  rural_geom   <- rural_binary$reduceToVectors(
    geometry = region_ee$geometry(),
    scale = 1000,
    geometryType = "polygon",
    maxPixels = 1e13
  ) |>
    rgee::ee_as_sf()
  n_max <- max(rural_geom$count)
  rural_area_max <-  rural_geom |> dplyr::filter(count %in% dplyr::all_of(n_max))

  # Obtener LST rural
  lst_rural <- l4h_surface_temp(
    from = from, to = to,
    region = rural_area_max, band = band, level = level,
    stat = "min", scale = scale, sf = FALSE,
    quiet = quiet, force = force, ...
  )

  # Calcular SUHI
  result <- dplyr::inner_join(lst_urban, lst_rural, by = "date", suffix = c("_urban", "_rural")) |>
    dplyr::mutate(
      suhi = value_urban - value_rural,
      variable = "SUHI"
    ) |>
    dplyr::select(date, variable, value = suhi, dplyr::everything()) |>
    dplyr::relocate(attr(lst_urban, "sf_column"), .after = dplyr::last_col())

  if (isFALSE(sf)) {
    result <- result |>
      sf::st_drop_geometry()
  }

  return(result)
}
