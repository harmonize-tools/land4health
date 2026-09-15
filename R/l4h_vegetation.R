#' Extract vegetation indices from MODIS MOD13A1
#'
#' @description Computes monthly or annual areal statistics of vegetation indices
#' (NDVI, EVI, or SAVI) from MODIS MOD13A1 (500 m, 16-day composite)
#' for a given spatial region, applying quality filtering via the
#' \code{DetailedQA} bitmask.
#'
#' \if{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{
#'   \figure{lifecycle-stable.png}{options: width="120"}
#' }}
#' \if{latex}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{
#'   \figure{lifecycle-stable.pdf}{options: width=2cm}
#' }}
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
#' @param force Logical. If \code{TRUE}, skips the representativity check
#'   (polygons smaller than 1 pixel are still extracted, only a warning is issued).
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
#'  head(result_monthly)
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
#'
#'  glimpse(result_annual)
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
    quiet = FALSE,
    force = FALSE
) {

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

  if (isFALSE(force)) {
    check_representativity(region, scale = scale)
  }

  scale_factor <- c(NDVI = 0.0001, EVI = 0.0001, SAVI = 1)[[band]]

  region_sf <- sf::st_transform(region, crs = 4326)

  if (band == "SAVI") {
    collection <- ee$ImageCollection("MODIS/061/MOD13A1")$
      select(c("sur_refl_b01", "sur_refl_b02", "DetailedQA"))
  } else {
    collection <- ee$ImageCollection("MODIS/061/MOD13A1")$
      select(c(band, "DetailedQA"))
  }

  # QA filter (uses bitwiseExtract() from utils.R)
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

  image_stack <- temporal_collection$
    filter(ee$Filter$date(from, to))$
    toBands()$
    multiply(scale_factor)

  cli::cli_alert_info(
    "Extracting {band} ({fun}, by {by}) | MODIS MOD13A1 | {from} to {to}"
  )

  result_wide <- l4h_ee_extract(
    image     = image_stack,
    sf_region = region_sf,
    scale     = scale,
    fun       = fun,     # get_reducer() is called inside l4h_ee_extract
    sf        = FALSE,
    quiet     = quiet
  )

  date_seq <- if (by == "month") {
    seq(as.Date(from), as.Date(to), by = "1 month")
  } else {
    seq(
      as.Date(paste0(start_year, "-01-01")),
      as.Date(paste0(end_year,   "-01-01")),
      by = "1 year"
    )
  }

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

  if (sf) {
    if (length(id_cols) > 0) {
      result_long <- region_sf |>
        dplyr::select(dplyr::all_of(id_cols)) |>
        dplyr::right_join(result_long, by = id_cols)
    } else {
      result_long <- sf::st_bind_cols(
        region_sf[, attr(region_sf, "sf_column"), drop = FALSE],
        result_long
      )
    }
  }

  return(result_long)
}
