#' Extract vegetation indices from MODIS MOD13A1
#'
#' @description Computes monthly or annual areal statistics of vegetation indices
#' (NDVI, EVI, or SAVI) from MODIS MOD13A1 (500 m, 16-day composite)
#' for a given spatial region, applying quality filtering via the
#' \code{DetailedQA} bitmask.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param region An \code{sf} object (polygon or multipolygon). Must be in a
#'   geographic CRS (or will be reprojected to WGS84 internally).
#' @param from Character. Start date in \code{"YYYY-MM-DD"} format.
#'   Valid range: \code{"2000-02-18"} onwards.
#' @param to Character. End date in \code{"YYYY-MM-DD"} format.
#' @param band Character. Vegetation index to extract. One of \code{"NDVI"},
#'   \code{"EVI"}, or \code{"SAVI"}. Default: \code{"NDVI"}.
#' @param by Character. Temporal aggregation unit. One of \code{"month"}
#'   (default) or \code{"year"}.
#' @param fun Character. Zonal statistic to compute over the region. One of
#'   \code{"mean"}, \code{"max"}, \code{"min"}, \code{"median"}, \code{"sum"},
#'   \code{"sd"}, \code{"first"}. Default: \code{"mean"}.
#' @param scale Numeric. Nominal scale in metres for the GEE projection.
#'   Default: \code{500} (native MOD13A1 resolution).
#' @param sf Logical. If \code{TRUE}, returns an \code{sf} object with
#'   geometries attached. Default: \code{FALSE}.
#' @param quiet Logical. If \code{TRUE}, suppresses the progress bar.
#'   Default: \code{FALSE}.
#'
#' @details
#' ## Temporal aggregation
#'
#' MODIS MOD13A1 produces one composite every **16 days**. This function
#' aggregates those composites into a coarser temporal unit:
#'
#' \itemize{
#'   \item \code{by = "month"}: All 16-day images within each calendar month
#'     are reduced to a single image using \code{max()} (maximum value
#'     composite), yielding one value per region per month.
#'   \item \code{by = "year"}: All 16-day images within each calendar year
#'     are reduced to a single image using \code{max()}, yielding one value
#'     per region per year.
#' }
#'
#' The \code{fun} argument controls the **spatial** (zonal) statistic applied
#' over each region polygon, and is independent of the temporal aggregation.
#'
#' ## Quality filtering
#'
#' Applied through the \code{DetailedQA} bitmask of \code{MODIS/061/MOD13A1}:
#' \itemize{
#'   \item Bits 0-1: VI quality (value \code{2} = not produced/cloudy, excluded).
#'   \item Bit 14: Adjacent cloud detected (excluded).
#'   \item Bit 15: Possible shadow (excluded).
#' }
#'
#' ## Scale factors
#' \itemize{
#'   \item \code{NDVI} and \code{EVI}: multiplied by \code{0.0001}.
#'   \item \code{SAVI}: computed on-the-fly from surface reflectance bands
#'     \code{sur_refl_b01} (red) and \code{sur_refl_b02} (NIR), L = 0.5.
#' }
#'
#' @return A tibble (or \code{sf} tibble if \code{sf = TRUE}) in long format:
#' \describe{
#'   \item{\code{<id_cols>}}{Original attribute columns from \code{region}.}
#'   \item{\code{date}}{\code{Date} object. First day of each month
#'     (\code{by = "month"}) or first day of each year (\code{by = "year"}).}
#'   \item{\code{variable}}{Name of the vegetation index (e.g. \code{"NDVI"}).}
#'   \item{\code{value}}{Computed zonal statistic for that region and period.}
#' }
#'
#' @importFrom sf st_transform st_drop_geometry
#' @importFrom dplyr mutate select all_of right_join
#' @importFrom tidyr pivot_longer
#' @importFrom tibble as_tibble
#' @importFrom cli cli_abort cli_alert_info
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
#' @examples
#' \dontrun{
#' library(land4health)
#' library(geoidep)
#'
#' rgee::ee_Initialize(quiet = TRUE)
#'
#' provinces <- get_provinces(show_progress = FALSE) |>
#'   subset(nombdep == "LORETO")
#'
#' # Monthly mean NDVI
#' result_monthly <- provinces |>
#'   l4h_vegetation(
#'     from = "2010-01-01",
#'     to   = "2012-12-31",
#'     band = "NDVI",
#'     by   = "month",
#'     fun  = "mean",
#'     sf   = TRUE
#'   )
#'
#' # Annual mean NDVI
#' result_annual <- provinces |>
#'   l4h_vegetation(
#'     from = "2010-01-01",
#'     to   = "2020-12-31",
#'     band = "NDVI",
#'     by   = "year",
#'     fun  = "mean",
#'     sf   = TRUE
#'   )
#' }
#'
#' @export
l4h_vegetation <- function(
    region,
    from,
    to,
    band  = c("NDVI", "EVI", "SAVI"),
    by    = c("month", "year"),
    fun   = c("mean", "max", "min", "median", "sum", "sd", "first"),
    scale = 500,
    sf    = FALSE,
    quiet = FALSE
) {

  # -- 0. Argument validation ------------------------------------------------
  band <- match.arg(band)
  by   <- match.arg(by)
  fun  <- match.arg(fun)

  if (!inherits(region, "sf")) {
    cli::cli_abort("{.arg region} must be an {.cls sf} object.")
  }

  start_year <- as.integer(substr(from, 1, 4))
  end_year   <- as.integer(substr(to,   1, 4))

  if (start_year > 2024 || end_year < 2000) {
    cli::cli_abort(
      "Date range out of bounds. MODIS MOD13A1 is available from 2000 to present."
    )
  }

  # -- 1. Representativity check --------------------------------------------
  check_representativity(region, scale = scale)

  # -- 2. Scale factor per band ---------------------------------------------
  scale_factor <- c(NDVI = 0.0001, EVI = 0.0001, SAVI = 1)[[band]]

  # -- 3. Region to WGS84 ---------------------------------------------------
  region_sf <- sf::st_transform(region, crs = 4326)

  # -- 4. MODIS collection --------------------------------------------------
  if (band == "SAVI") {
    collection <- ee$ImageCollection("MODIS/061/MOD13A1")$
      select(c("sur_refl_b01", "sur_refl_b02", "DetailedQA"))
  } else {
    collection <- ee$ImageCollection("MODIS/061/MOD13A1")$
      select(c(band, "DetailedQA"))
  }

  # -- 5. QA filter (uses bitwiseExtract() from utils.R) --------------------
  .apply_qa_filter <- function(image) {
    qa <- image$select("DetailedQA")
    f1 <- bitwiseExtract(qa, 0, 1)   # bits 0-1: VI quality
    f2 <- bitwiseExtract(qa, 14)     # bit 14:   adjacent cloud
    f3 <- bitwiseExtract(qa, 15)     # bit 15:   possible shadow
    mask <- f1$neq(2)$And(f2$neq(1))$And(f3$neq(1))

    if (band == "SAVI") {
      image$select(c("sur_refl_b01", "sur_refl_b02"))$updateMask(mask)
    } else {
      image$select(band)$updateMask(mask)
    }
  }

  # -- 6. SAVI on-the-fly expression ----------------------------------------
  .compute_savi <- function(img) {
    img$expression(
      "(1 + L) * float(nir - red) / (nir + red + L)",
      list(
        "nir" = img$select("sur_refl_b02"),
        "red" = img$select("sur_refl_b01"),
        "L"   = 0.5
      )
    )$rename("SAVI")
  }

  # -- 7. Temporal composites (driven by `by`) ------------------------------
  years <- ee$List$sequence(start_year, end_year)

  if (by == "month") {

    months <- ee$List$sequence(1, 12)

    temporal_collection <- ee$ImageCollection$fromImages(
      years$map(rgee::ee_utils_pyfunc(function(y) {
        months$map(rgee::ee_utils_pyfunc(function(m) {
          img_period <- collection$
            filter(ee$Filter$calendarRange(y, y, "year"))$
            filter(ee$Filter$calendarRange(m, m, "month"))$
            map(.apply_qa_filter)

          if (band == "SAVI") img_period <- img_period$map(.compute_savi)

          img_period$
            max()$                          # max of 16-day composites within month
            set("year",  y)$
            set("month", m)$
            set("system:time_start", ee$Date$fromYMD(y, m, 1)$millis())
        }))
      }))$flatten()
    )

  } else {  # by == "year"

    temporal_collection <- ee$ImageCollection$fromImages(
      years$map(rgee::ee_utils_pyfunc(function(y) {
        img_period <- collection$
          filter(ee$Filter$calendarRange(y, y, "year"))$
          map(.apply_qa_filter)

        if (band == "SAVI") img_period <- img_period$map(.compute_savi)

        img_period$
          max()$                            # max of all 16-day composites within year
          set("year", y)$
          set("system:time_start", ee$Date$fromYMD(y, 1, 1)$millis())
      }))
    )
  }

  # -- 8. Filter to exact date range + apply scale factor -------------------
  image_stack <- temporal_collection$
    filter(ee$Filter$date(from, to))$
    toBands()$
    multiply(scale_factor)

  # -- 9. Extract using land4health wrapper (progress bar included) ---------
  cli::cli_alert_info(
    "Extracting {band} ({fun}, by {by}) | MODIS MOD13A1 | {from} to {to}"
  )

  result_wide <- extract_ee_with_progress(
    image     = image_stack,
    sf_region = region_sf,
    scale     = scale,
    fun       = fun,     # get_reducer() is called inside extract_ee_with_progress
    sf        = FALSE,
    quiet     = quiet
  )

  # -- 10. Build date sequence matching the image_stack bands ---------------
  date_seq <- if (by == "month") {
    seq(as.Date(from), as.Date(to), by = "1 month")
  } else {
    seq(
      as.Date(paste0(start_year, "-01-01")),
      as.Date(paste0(end_year,   "-01-01")),
      by = "1 year"
    )
  }

  # -- 11. Reshape to land4health long format --------------------------------
  geom_col  <- attr(region_sf, "sf_column")
  id_cols   <- setdiff(names(region_sf), geom_col)
  band_cols <- setdiff(names(result_wide), id_cols)

  result_long <- result_wide |>
    tibble::as_tibble() |>
    tidyr::pivot_longer(
      cols      = dplyr::all_of(band_cols),
      names_to  = "band_raw",
      values_to = "value"
    ) |>
    dplyr::mutate(
      date     = rep(date_seq, times = nrow(region_sf)),
      variable = band
    ) |>
    dplyr::select(-band_raw) |>
    dplyr::select(dplyr::all_of(id_cols), date, variable, value)

  # -- 12. Optionally attach geometries -------------------------------------
  if (sf) {
    result_long <- region_sf |>
      dplyr::select(dplyr::all_of(id_cols)) |>
      dplyr::right_join(result_long, by = id_cols)
  }

  return(result_long)
}
