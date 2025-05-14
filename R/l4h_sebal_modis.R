#' #' Download and process evapotranspiration data (SEBAL-MODIS) from Earth Engine
#' #'
#' #' This function accesses the `geeSEBAL-MODIS` collection published by the ET-Brasil project,
#' #' extracts the `ET_24h` band (daily evapotranspiration in mm/day), and allows temporal aggregation
#' #' by 8-day images, monthly composites, or the entire period. Optionally, results can be returned
#' #' as `sf`/`stars` objects in R.
#' #'
#' #' @param from Start date in `"YYYY-MM-DD"` format.
#' #' @param to End date in `"YYYY-MM-DD"` format.
#' #' @param by Temporal aggregation frequency. Options: `"8 days"` (original 8-day composites), `"month"` (monthly average or sum), or `"annual"` (annual avergae or sumperiod).
#' #' @param region A spatial object defining the region of interest. Accepts `sf`, `SpatVector`, or `ee$FeatureCollection` objects.
#' #' @param fun Aggregation function when `by = "month"` or `"total"`. Valid values are `"mean"` or `"sum"`.
#' #' @param sf Logical. If `TRUE`, returns a `stars`/`sf` object using `ee_as_stars()`. If `FALSE`, returns the raw Earth Engine object.
#' #' @param force Logical. If `TRUE`, forces download even if a local file already exists.
#' #' @param ... Additional arguments passed to `ee_as_stars()` or `ee_extract()`.
#' #'
#' #' @return A `stars` raster object if `sf = TRUE`, or an `ee$Image` object if `sf = FALSE`.
#'
#' l4h_sebal_modis <- function(from, to, by = '8 days', region, fun = "mean" ,sf = TRUE, force = FALSE, ...){
#'
#'   # Validar que la conversión fue exitosa
#'   if (is.na(from) || is.na(to)) {
#'     cli::cli_abort("Las fechas deben tener el formato 'YYYY-MM-DD'. Ejemplo válido: '2024-01-01'")
#'   }
#'
#'   # Validar que from y to sean fechas
#'   if (!inherits(from, "Date")) from <- as.Date(from)
#'   if (!inherits(to, "Date")) to <- as.Date(to)
#'
#'   # Validación de fechas
#'   if (from < as.Date("2002-07-01") || to > as.Date("2022-12-31")) {
#'     cli::cli_abort("Fechas deben estar en el rango 2002-07-01 a 2022-12-31. Recibido: {.val {from}} a {.val {to}}")
#'   }
#'
#'   if (to < from) {
#'     cli::cli_abort("El parametro {.field to} debe ser mayor o igual a {.field from}")
#'   }
#'   # Convertir a Date usando formato explícito
#'   from <- tryCatch(as.Date(from, format = "%Y-%m-%d"),error = function(e) NA)
#'   to <- tryCatch(as.Date(to, format = "%Y-%m-%d"), error = function(e) NA)
#'
#'   date_seq <- switch(
#'     by,
#'     "8 days" = seq(from, to, by = "8 days"),
#'     "month"  = seq(from, to, by = "month"),
#'     "annual" = seq(from, to, by = "year"),
#'     cli::cli_abort("Intervalo '{by}' no soportado.")
#'   )
#'
#'   # Define supported classes
#'   sf_classes <- c("sf", "sfc", "SpatVector")
#'   rgee_classes <- c("ee.featurecollection.FeatureCollection", "ee.feature.Feature")
#'
#'   # Check input object class
#'   if (inherits(region, sf_classes)) {
#'     region_ee <- rgee::sf_as_ee(region,quiet = TRUE)
#'   } else if (inherits(region, rgee_classes)) {
#'     region_ee <- region
#'   } else {
#'     stop("Invalid 'region' input. Expected an 'sf', 'sfc', 'SpatVector', or Earth Engine FeatureCollection object.")
#'   }
#'
#'   # Obtener función de reducción
#'   reducer_fun <- get_reducer(name = fun)  # tu función get_reducer debe estar definida
#'
#'   # Create binary image with lossyear in range
#'   ic <- .internal_data$geesebal |>
#'     ee$ImageCollection() |>
#'     ee$ImageCollection$select('ET_24h')
#'
#'   start_year <- min(date_seq) |> format("%Y") |> as.integer()
#'   end_year <- max(date_seq)  |> format("%Y") |> as.integer()
#'
#'   start_month <- min(date_seq) |> format("%m") |> as.integer()
#'   end_month <- max(date_seq)  |> format("%m") |> as.integer()
#'
#'   start_day<- min(date_seq) |> format("%d") |> as.integer()
#'   end_day <- max(date_seq)  |> format("%d") |> as.integer()
#'
#'   if(by == '8 days'){
#'     sebal_img <- ic |>
#'       ee$ImageCollection$filter(ee$Filter$calendarRange(start_year,end_year,'year')) |>
#'       ee$ImageCollection$filter(ee$Filter$calendarRange(start_month,end_month,'month')) |>
#'       ee$ImageCollection$filter(ee$Filter$calendarRange(start_day,end_day,'day_of_month')) |>
#'       ee$ImageCollection$toBands()
#'
#'   }
#'
#'
#'
#'
#'
#' }
#'
