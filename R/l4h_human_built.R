#' Extracts built‑up surface area from GHSL Built‑Up Surface dataset
#'
#' @description
#' Retrieves total built‑up surface area (in m2 per 100m grid cell) from the
#' GHSL Built-Up Surface dataset (GHS‑BUILT‑S R2023A), over a user-defined region and
#' date range. The dataset is provided in 5‑year epochs (1975–2030) at ~100m resolution.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param from Character. Start date in "YYYY-MM-DD" format (only the year is used).
#' @param to   Character. End date in "YYYY-MM-DD" format (only the year is used).
#' @param region Spatial object (`sf`, `sfc`, or `SpatVector`) defining the region.
#' @param scale Numeric. Resolution in meters (default = 100).
#' @param sf Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`. Default = `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress output. Default = `FALSE`.
#' @param force Logical. If `TRUE`, bypass representativity checks. Default = `FALSE`.
#' @param ... Arguments passed to `rgee::ee_extract()`.
#'
#' @return A `sf` or `tibble` with columns `date`, `variable`, and `built_surface_m2`.
#'
#' @references
#' - Pesaresi, M. & Politis, P. (2023). GHS‑BUILT‑S R2023A: Red de superficie construida de GHS, derivada de la composición de Sentinel-2 y Landsat, multitemporal (1975–2030). European Commission, Joint Research Centre (JRC). \doi{10.2905/9F06F36F-4B11-47EC-ABB0-4F8B7B1D72EA}. PID: \url{http://data.europa.eu/89h/9f06f36f-4b11-47ec-abb0-4f8b7b1d72ea}
#' - Pesaresi, M., Schiavina, M., Politis, P., Freire, S., Krasnodebska, K., Uhl, J.H., Carioli, A., et al. (2024). Avances en la capa de asentamientos humanos globales a través de la evaluación conjunta de datos de observación de la Tierra y encuestas demográficas. *International Journal of Digital Earth*, 17(1). \doi{10.1080/17538947.2024.2390454}
#' - Dataset on Google Earth Engine: \url{https://developers.google.com/earth-engine/datasets/catalog/JRC_GHSL_P2023A_GHS_BUILT_S}

#' @examples
#' \dontrun{
#' library(land4health)
#' library(sf)
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
#' # Extract built-up surface area from 2000 to 2020
#' built_area <- l4h_human_built(
#'   from = "2000-01-01",
#'   to = "2020-12-31",
#'   region = region,
#'   scale = 100,
#'   stat = "sum"
#' )
#' head(built_area)
#'
#' # Example using as tibble
#' built_tbl <- l4h_human_built(
#'   from = "1990-01-01",
#'   to = "2015-12-31",
#'   region = region,
#'   sf = FALSE,
#'   stat = "mean"
#' )
#' dplyr::glimpse(built_tbl)
#' }
#'
#' @export
l4h_human_built <- function(from, to, region,
                            scale = 100, sf = TRUE,
                            quiet = FALSE, force = FALSE, ...) {

  # Dataset date range
  start_year <- as.numeric(.internal_data$human_built$startyear)[1]
  end_year   <- as.numeric(.internal_data$human_built$endyear)[1]

  # Regex para validar formato "YYYY-MM-DD"
  valid_date_format <- function(x) grepl("^\\d{4}-\\d{2}-\\d{2}$", x)

  # Verificar formato antes de convertir
  if (!valid_date_format(from)) {
    cli::cli_abort("Parameter {.field from} must be in 'YYYY-MM-DD' format. Got: {.val {from}}")
  }
  if (!valid_date_format(to)) {
    cli::cli_abort("Parameter {.field to} must be in 'YYYY-MM-DD' format. Got: {.val {to}}")
  }

  # Convertir a Date
  from_date <- as.Date(from)
  to_date   <- as.Date(to)

  # Validar conversiones
  if (is.na(from_date)) {
    cli::cli_abort("Parameter {.field from} could not be parsed as a valid date. Got: {.val {from}}")
  }
  if (is.na(to_date)) {
    cli::cli_abort("Parameter {.field to} could not be parsed as a valid date. Got: {.val {to}}")
  }

  # Validar años en rango permitido
  from_year <- as.numeric(format(from_date, "%Y"))
  to_year   <- as.numeric(format(to_date, "%Y"))

  if (from_year < start_year || to_year > end_year) {
    cli::cli_abort("Years must be in the range {start_year} to {end_year}. Got: {.val {from_year}} to {.val {to_year}}")
  }

  # Validar orden temporal
  if (to_date < from_date) {
    cli::cli_abort("Parameter {.field to} must be greater than or equal to {.field from}")
  }

  # Convertir a fechas Earth Engine
  from_ee <- rgee::rdate_to_eedate(from_date)
  to_ee   <- rgee::rdate_to_eedate(to_date)

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
      scale = 30
    )
  }
  # Cargar colección y filtrar por años
  coll <- ee$ImageCollection(.internal_data$human_built$id[1])$
    filter(ee$Filter$calendarRange(from_year, to_year, "year"))

  # Seleccionar banda
  coll <- coll$select("built_surface")$toBands()

  # Extract with reducer
  if (isTRUE(sf)) {
    extract_hbuilt <- extract_ee_with_progress(
      image = coll,
      sf_region = region,
      scale = scale,
      fun = "sum",
      sf = TRUE,
      quiet = quiet,
      # ...
    )

    geom_col <- attr(extract_hbuilt, "sf_column")
    extract_hbuilt <- extract_hbuilt |>
      tidyr::pivot_longer(
        cols = grep("built_surface", names(extract_hbuilt), value = TRUE),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = sub("^X(\\d{4}).*", "\\1", date),
        date = paste0(date, "-01-01"),
        date = as.Date(date),
        variable = "built_surface") |>
      dplyr::relocate(c("date", "variable", "value"), .before = all_of(geom_col))

  } else {
    extract_hbuilt <- extract_ee_with_progress(
      image = coll,
      sf_region = region,
      scale = scale,
      fun = "sum",
      sf = FALSE,
      quiet = quiet,
      ...
    ) |>
      tidyr::pivot_longer(
        cols = grep("built_surface", names(extract_hbuilt), value = TRUE),
        names_to = "date",
        values_to = "value") |>
      dplyr::mutate(
        date = sub("^X(\\d{4}).*", "\\1", date),
        date = paste0(date, "-01-01"),
        date = as.Date(date),
        variable = "built_surface")

  }
  return(extract_hbuilt)
}
