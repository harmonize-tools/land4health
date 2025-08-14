#' Download and process evapotranspiration data
#'
#' @description This function accesses the `geeSEBAL-MODIS` collection published by the ET-Brasil project,
#' extracts the `etp` band (daily evapotranspiration in mm/day), and allows temporal aggregation
#' by 8-day images or monthly or yearly composites period. Optionally, results can be returned
#' as `sf`/`tibble` objects in R.
#'
#' `r lifecycle::badge('stable')`
#'
#' @param from Start date in `"YYYY-MM-DD"` format.
#' @param to End date in `"YYYY-MM-DD"` format.
#' @param by Temporal aggregation frequency. Options: `"8 days"` (original 8-day composites), `"month"` (monthly average or sum), or `"annual"` (annual avergae or sumperiod).
#' @param region A spatial object defining the region of interest. Accepts `sf`, `SpatVector`, or `ee$FeatureCollection` objects.
#' @param fun Aggregation function when `by = "month"` or `"total"`. Valid values are `"mean"` or `"sum"`.
#' @param sf Logical. Return result as an `sf` object? Default is `TRUE`.
#' @param quiet Logical. If TRUE, suppress the progress bar (default FALSE).
#' @param force Logical. If `TRUE`, forces download even if a local file already exists.
#' @param ... arguments of `ee_extract` of `rgee` packages.
#' @return A `sf` or `tibble` object with etp values.
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
#'
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
#' # 1. Eight-day composites (8 days)
#' # 2020-01-01 → 2020-12-31, reducer = "mean"
#' sebal_8d <- l4h_sebal_modis(
#'   from   = "2020-01-01",
#'   to     = "2020-12-31",
#'   region = region
#' )
#'
#' # 2. Monthly means
#' # Same period, but aggregated to calendar months
#' sebal_month <- l4h_sebal_modis(
#'   from   = "2020-01-01",
#'   to     = "2020-12-31",
#'   by     = "month",
#'   region = region
#' )
#'
#' # 3. Annual evapotranspiration
#' # 2015 → 2023, one value per year
#' sebal_annual <- l4h_sebal_modis(
#'   from   = 2015,
#'   to     = 2023,
#'   by     = "annual",
#'   fun    = "sum",
#'   region = region,
#'   sf     = FALSE
#' )
#'
#' }
#' @references
#' - Comini,B., Ruhoff,A., Laipelt,L., Fleischmann,A., Huntington,J.,
#'    Morton,C., Melton,F., Erickson,T., Roberti,D., Souza,V., Biudes,M.,
#'    Machado,N., Santos,C. & Cosio,E. (2023). *geeSEBAL‑MODIS:
#'    Continental‑scale evapotranspiration based on the surface energy
#'    balance for South America.* Preprint. DOI: 10.13140/RG.2.2.17579.11041
#'
#' - geeSEBAL‑MODIS v0‑02 dataset. Licensed under the
#'   *Creative Commons Attribution 4.0 International (CC‑BY‑4.0)* license.

#' @export
l4h_sebal_modis <- function(from, to, by = "8 days", region, fun = "mean", sf = TRUE, force = FALSE, quiet = FALSE, ...) {
  # Validar que la conversion fue exitosa
  if (is.na(from) || is.na(to)) {
    cli::cli_abort("Dates must be in the format 'YYYY-MM-DD'. Valid example: '2024-01-01'.")
  }

  # Validar que from y to sean fechas
  if (!inherits(from, "Date")) from <- as.Date(from)
  if (!inherits(to, "Date")) to <- as.Date(to)

  # Validacion de fechas
  if (from < as.Date("2002-07-01") || to > as.Date("2022-12-31")) {
    cli::cli_abort("Dates must be in the range 2002-07-01 to 2022-12-31. Received: {.val {from}} a {.val {to}}")
  }

  if (to < from) {
    cli::cli_abort("The {.field to} parameter must be greater than or equal to {.field from}.")
  }
  # Convertir a Date usando formato explicito
  from <- tryCatch(as.Date(from, format = "%Y-%m-%d"), error = function(e) NA)
  to <- tryCatch(as.Date(to, format = "%Y-%m-%d"), error = function(e) NA)

  from_ee <- rgee::rdate_to_eedate(from)
  to_ee <- rgee::rdate_to_eedate(to)

  date_seq <- switch(by,
    "8 days" = seq(from, to, by = "8 days"),
    "month"  = seq(from, to, by = "month"),
    "annual" = seq(from, to, by = "year"),
    cli::cli_abort("Interval '{by}' not supported.")
  )

  # Define supported classes
  sf_classes <- c("sf", "sfc", "SpatVector")

  # Check input object class
  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be an {.cls sf}, {.cls sfc}, or {.cls SpatVector} object.")
  }

  # Reducer function
  reducer_fun <- get_reducer(name = fun)

  # Create binary image with lossyear in range
  ic <- .internal_data$geesebal$id |>
    ee$ImageCollection() |>
    ee$ImageCollection$select("ET_24h")

  if (by == "8 days") {
    modis_ic <- ic |>
      ee$ImageCollection$filterDate(from_ee, to_ee) |>
      ee$ImageCollection$toBands()
    modis_name <- modis_ic$bandNames()$getInfo()
    modis_date <- as.numeric(gsub("_.*", "", modis_name))
    modis_rename <- paste0("etp_", modis_date)
    modis_pre <- modis_ic$rename(modis_rename)
  } else if (by == "month") {
    # new dataframe with years and months
    date_seq_df <- data.frame(fecha = date_seq) |>
      dplyr::mutate(
        year = as.numeric(format(fecha, "%Y")),
        month = as.numeric(format(fecha, "%m"))
      )

    # group_by years and months
    list_date <- date_seq_df |>
      dplyr::group_by(year) |>
      dplyr::summarise(meses = list(sort(unique(month))))

    modis_monthly_ee <- function(x) {
      # Years
      years_ee <- list_date$year[x]
      # Months
      months <- unlist(list_date$meses[x])
      months_ee <- months |> ee$List()

      # Preprocessing modis
      modis_ic <- ee$ImageCollection$
        fromImages(
        months_ee$map(rgee::ee_utils_pyfunc(
          function(m) {
            ic$
              filter(ee$Filter$calendarRange(years_ee, years_ee, "year"))$
              filter(ee$Filter$calendarRange(m, m, "month"))$
              mean()$
              set("year", years_ee)$
              set("month", m)
          }
        ))
      )$toBands()

      modis_name <- modis_ic$bandNames()$getInfo()
      modis_month <- months[as.numeric(gsub("_.*", "", modis_name)) + 1]
      modis_rename <- paste0("etp_", modis_month)
      modis_pre <- modis_ic$rename(modis_rename)
    }

    modis_pre <- lapply(1:nrow(list_date), modis_monthly_ee) |>
      ee$ImageCollection() |>
      ee$ImageCollection$toBands()
  } else if (by == "annual") {
    years <- date_seq |>
      format("%Y") |>
      unique() |>
      as.integer()

    years_ee <- years |>
      ee$List()

    modis_ic <- ee$ImageCollection$
      fromImages(
      years_ee$map(rgee::ee_utils_pyfunc(
        function(y) {
          ic$
            filter(ee$Filter$calendarRange(y, y, "year"))$
            mean()$
            set("year", y)
        }
      ))
    )$toBands()

    modis_name <- modis_ic$bandNames()$getInfo()
    modis_year <- years[as.numeric(gsub("_.*", "", modis_name)) + 1]
    modis_rename <- paste0("etp_", modis_year)
    modis_pre <- modis_ic$rename(modis_rename)
  } else {
    stop("Invalid 'by' input. Please only select '8 days', 'month' or 'annual'")
  }

  # Extract data
  modis_extract <- extract_ee_with_progress(
    image = modis_pre,
    sf_region = region,
    scale = 500,
    fun = fun,
    sf = sf,
    quiet = quiet,
    ...
  )
  geom_col <- attr(modis_extract, "sf_column")
  idx_etp <- grep("(^|_)etp_", names(modis_extract))

  stopifnot(
    length(idx_etp) == length(date_seq),
    inherits(date_seq, "Date") ||
      all(!is.na(as.Date(date_seq, "%Y%m")))
  )
  new_names <- paste0("etp_", format(as.Date(date_seq, "%Y%m")))
  names(modis_extract)[idx_etp] <- new_names
  modis_tidy <- modis_extract |>
    tidyr::pivot_longer(
      cols = dplyr::contains("etp_"),
      names_to = "variable",
      values_to = "value"
    ) |>
    dplyr::mutate(
      date = as.Date(sub("^etp_", "", variable)),
      variable = "etp"
    ) |>
    dplyr::relocate(date, variable, value, .before = all_of(geom_col))

  return(modis_tidy)
}
