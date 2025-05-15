#' Download and process evapotranspiration data (SEBAL-MODIS) from Earth Engine
#'
#' This function accesses the `geeSEBAL-MODIS` collection published by the ET-Brasil project,
#' extracts the `etp` band (daily evapotranspiration in mm/day), and allows temporal aggregation
#' by 8-day images, monthly composites, or the entire period. Optionally, results can be returned
#' as `sf`/`stars` objects in R.
#'
#' @param from Start date in `"YYYY-MM-DD"` format.
#' @param to End date in `"YYYY-MM-DD"` format.
#' @param by Temporal aggregation frequency. Options: `"8 days"` (original 8-day composites), `"month"` (monthly average or sum), or `"annual"` (annual avergae or sumperiod).
#' @param region A spatial object defining the region of interest. Accepts `sf`, `SpatVector`, or `ee$FeatureCollection` objects.
#' @param fun Aggregation function when `by = "month"` or `"total"`. Valid values are `"mean"` or `"sum"`.
#' @param sf Logical. Return result as an `sf` object? Default is `TRUE`.
#' @param force Logical. If `TRUE`, forces download even if a local file already exists.
#' @param ... Additional arguments passed to `ee_as_stars()` or `ee_extract()`.
#'
#' @return A `sf` or `tibble` object with etp values.

l4h_sebal_modis <- function(from, to, by = '8 days', region, fun = "mean" ,sf = TRUE, force = FALSE, ...){

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
  from <- tryCatch(as.Date(from, format = "%Y-%m-%d"),error = function(e) NA)
  to <- tryCatch(as.Date(to, format = "%Y-%m-%d"), error = function(e) NA)

  date_seq <- switch(
    by,
    "8 days" = seq(from, to, by = "8 days"),
    "month"  = seq(from, to, by = "month"),
    "annual" = seq(from, to, by = "year"),
    cli::cli_abort("Interval '{by}' not supported.")
  )

  # Define supported classes
  sf_classes <- c("sf", "sfc", "SpatVector")

  # Check input object class
  if (!inherits(region, sf_classes)) {
    stop("Invalid 'region' input. Expected an 'sf', 'sfc' or 'SpatVector' object.")
  }

  # Reducer function
  reducer_fun <- get_reducer(name = fun)

  # Create binary image with lossyear in range
  ic <- .internal_data$geesebal |>
    ee$ImageCollection() |>
    ee$ImageCollection$select('ET_24h')

  # Years
  start_year <- min(date_seq) |> format("%Y") |> as.integer()
  end_year <- max(date_seq)  |> format("%Y") |> as.integer()

  # Months
  start_month <- min(date_seq) |> format("%m") |> as.integer()
  end_month <- max(date_seq)  |> format("%m") |> as.integer()

  # Days
  start_day<- min(date_seq) |> format("%d") |> as.integer()
  end_day <- max(date_seq)  |> format("%d") |> as.integer()

  if(by == '8 days'){
    modis_ic <- ic |>
      ee$ImageCollection$filter(ee$Filter$calendarRange(start_year,end_year,'year')) |>
      ee$ImageCollection$filter(ee$Filter$calendarRange(start_month,end_month,'month')) |>
      ee$ImageCollection$filter(ee$Filter$calendarRange(start_day,end_day,'day_of_month')) |>
      ee$ImageCollection$toBands()

    modis_name <- modis_ic$bandNames()$getInfo()
    modis_date <- as.numeric(gsub("_.*", "", modis_name))
    modis_rename <- paste0('etp_',modis_date)
    modis_pre <- modis_ic$rename(modis_rename)
    return(modis_pre)

  } else if (by == 'month'){
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

    modis_monthly_ee <- function(x){
      # Years
      years_ee <- list_date$year[x]
      # Months
      months <- unlist(list_date$meses[x])
      month_ee <- months|>
        ee$List()

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
      modis_rename <- paste0('etp_',modis_month)
      modis_pre <- modis_ic$rename(modis_rename)
      }

    modis_pre <- lapply(1:nrow(list_date),modis_monthly_ee) |>
      ee$ImageCollection() |>
      ee$ImageCollection$toBands()

  } else if (by == 'annual'){
    years <- date_seq |>
      format('%Y') |>
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
    modis_rename <- paste0('etp_',modis_year)
    modis_pre <- modis_img$rename(modis_rename)

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
  modis_tidy <- modis_extract |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with('etp_'),
      names_to = "variable",
      values_to = "value") |>
    dplyr::mutate(
      date = as.Date(sub("^.+_", "", variable), format = "%Y%m%d"),
      variable = "etp") |>
    dplyr::relocate(c("date","variable","value"),.before = geom_col)
  return(modis_tidy)
}

