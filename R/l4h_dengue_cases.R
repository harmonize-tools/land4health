#' Extract dengue case data from OpenDengue
#'
#' @description
#' A global database of publicly available dengue case data.
#' The OpenDengue Project provides a harmonized, open-access repository of dengue surveillance data
#' from national ministries of health across Latin America and other regions. This function enables
#' programmatic access to weekly case counts by downloading, caching, unzipping, reading, and filtering
#' national, spatial, or temporal extracts by region and country for a specified date range, returning
#' a ready-to-use tibble.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param from         Start date (`YYYY-MM-DD`).
#' @param to           End date (`YYYY-MM-DD`).
#' @param data_type    One of `"national"`, `"spatial"`, or `"temporal"`.
#' @param region       Region code or full name (case-insensitive). Codes: `"paho"`, `"searo"`,
#'                     `"wpro"`, `"afro"`, `"emro"`, `"euro"`. Full names: "Pan-American Region",
#'                     "South-East Asia Region", "Western Pacific Region", "African Region",
#'                     "Eastern Mediterranean Region", "European Region".
#' @param country      Country name (case-insensitive, e.g., `"peru"`), matched against `adm_0_name`.
#' @param version      Version tag, e.g. `"V1_3"`.
#' @param cache        Logical. If `TRUE`, caches the downloaded ZIP locally.
#' @param quiet        Logical. If `TRUE`, prints progress status via **cli**.
#'
#' @return A tibble with columns: `date_start`, `date_end`, `cases`, `state`, `area`, plus other fields.
#'
#' @source Data from the [OpenDengue Project](https://opendengue.org).
#' @references Morales, I. et al. (2024). OpenDengue: Harmonized dengue surveillance data for Latin America.
#'
#' @examples
#' \donttest{
#'
#' # National extract for Peru in 2019
#' df_nat <- l4h_dengue_cases(
#'   from = "2019-01-01",
#'   to = "2019-12-31",
#'   data_type = "national",
#'   region = "paho",
#'   country = "peru",
#'   cache = TRUE,
#'   quiet = TRUE)
#'
#' head(df_nat)
#'
#' # Spatial extract for Brazil first half 2021
#' df_spat <- l4h_dengue_cases(
#'   from = "2021-01-01",
#'   to = "2021-12-31",
#'   data_type = "spatial",
#'   region = "Pan-American Region",
#'   country = "brazil",
#'  cache = TRUE,
#'  quiet = FALSE)
#'
#' head(df_spat)
#'
#' # Temporal extract for Argentina in 2020
#' df_temp <- l4h_dengue_cases(
#'   from = "2020-01-01",
#'   to = "2020-12-31",
#'   data_type = "temporal",
#'   region = "PAHO",
#'   country = "Argentina",
#'   cache = TRUE,
#'   quiet = TRUE)
#'
#' head(df_temp)
#' }
#' @export
l4h_dengue_cases <- function(
    from,
    to,
    data_type    = c("temporal", "spatial", "national"),
    region       = NULL,
    country      = "Peru",
    version      = "V1_3",
    cache        = TRUE,
    quiet = FALSE
) {
  # Parse dates
  from <- as.Date(from);
  to   <- as.Date(to);
  if (is.na(from) || is.na(to) || from > to) {
    cli::cli_abort("Invalid 'from' or 'to' dates.")
  }

  # Internal mappings
  types <- c(
    national = "National",
    spatial  = "Spatial",
    temporal = "Temporal")

  codes <- c(
    paho  = "PAHO",
    searo = "SEARO",
    wpro  = "WPRO",
    afro  = "AFRO",
    emro  = "EMRO",
    euro  = "EURO")

  names_full <- c(paho = "Pan-American Region", searo = "South-East Asia Region",
                  wpro = "Western Pacific Region", afro = "African Region",
                  emro = "Eastern Mediterranean Region",
                  euro = "European Region")

  # Validate extract type
  data_type <- match.arg(data_type)

  # Normalize region (code or full name)
  if (is.null(region)) region <- "paho"
  input <- tolower(region)
  codes_keys <- names(codes)
  full_lc <- tolower(names_full)
  if (input %in% codes_keys) {
    key <- input
  } else if (input %in% full_lc) {
    key <- codes_keys[match(input, full_lc)]
  } else {
    cli::cli_abort(
      "'region' must be one of codes: {paste(codes_keys, collapse=', ')} or full names: {paste(names_full, collapse=', ')}."
    )
  }
  region_code <- codes[[key]]
  region_name <- names_full[[key]]

  # Normalize country
  country <- toupper(country)
  if (quiet) cli::cli_status("Preparing {data_type} extract for {region_name} and {country}")

  # Build download URL
  url <- glue::glue(
    "https://opendengue.org/assets/",
    "{types[[data_type]]}_extract_{region_code}_{version}.zip"
  )
  if (quiet) cli::cli_status("Downloading {basename(url)}...")

  # Download & cache
  cache_dir <- tools::R_user_dir("land4health", "cache")
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  zip_file <- file.path(cache_dir, basename(url))
  req <- httr2::request(url)
  if (!cache || !file.exists(zip_file) || file.info(zip_file)$size == 0) {
    if (quiet) req <- httr2::req_verbose(req)
    httr2::req_perform(req, path = zip_file)
    if (quiet) cli::cli_status_update("Downloaded {basename(zip_file)}")
  } else if (quiet) {
    cli::cli_status("Using cached file: {basename(zip_file)}")
  }

  # Unzip and read
  if (quiet) cli::cli_status("Extracting CSV...")
  files <- utils::unzip(zip_file, exdir = cache_dir)
  csv <- grep("\\.csv$", files, value = TRUE)[1]
  if (is.na(csv)) cli::cli_abort("No CSV file found in the ZIP.")
  if (quiet) cli::cli_status("Reading {basename(csv)}...")
  df <- read.csv(csv) |> tidyr::as_tibble()

  # Filter and rename
  df <- df |>
    dplyr::filter(
      adm_0_name          == country,
      calendar_start_date >= from,
      calendar_start_date <= to
    )
  if (quiet) cli::cli_status_update("Retrieved {nrow(df)} rows for {country}")

  df <- df |>
    dplyr::rename(
      date_start = calendar_start_date,
      date_end   = calendar_end_date,
      cases      = dengue_total,
      state      = adm_1_name,
      area       = adm_2_name
    )

  if (quiet) cli::cli_status_clear()
  df
}
