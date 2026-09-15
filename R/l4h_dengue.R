#' Extract dengue case data from OpenDengue
#'
#' @description
#' Downloads dengue case counts from the **OpenDengue Project**, a
#' harmonized, open-access repository of dengue surveillance data from
#' national ministries of health. The function supports national,
#' spatial, and temporal extracts filtered by WHO region and country
#' for a specified date range.
#'
#' \if{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{
#'   \figure{lifecycle-stable.png}{options: width="120"}
#' }}
#' \if{latex}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{
#'   \figure{lifecycle-stable.pdf}{options: width=2cm}
#' }}
#'
#' @param from Character or Date. Start date (`"YYYY-MM-DD"`).
#' @param to Character or Date. End date (`"YYYY-MM-DD"`).
#' @param data_type Character. One of `"national"`, `"spatial"`, or
#'   `"temporal"`. Default `"temporal"`.
#' @param region Character. WHO region code or full name
#'   (case-insensitive). Codes: `"paho"`, `"searo"`, `"wpro"`,
#'   `"afro"`, `"emro"`, `"euro"`. Full names: `"Pan-American Region"`,
#'   `"South-East Asia Region"`, `"Western Pacific Region"`,
#'   `"African Region"`, `"Eastern Mediterranean Region"`,
#'   `"European Region"`. Default `"paho"`.
#' @param country Character. Country name (case-insensitive),
#'   matched against `adm_0_name`. Default `"Peru"`.
#' @param cache Logical. If `TRUE`, caches the downloaded ZIP locally.
#'   Default `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress messages.
#'   Default `FALSE`.
#'
#' @return A tibble with columns: `date_start`, `date_end`, `cases`,
#'   `state`, `area`, plus other fields from the source data.
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
#' @source Data from the [OpenDengue Project](https://opendengue.org).
#' @references Morales, I. et al. (2024). OpenDengue: Harmonized
#'   dengue surveillance data for Latin America.
#' @seealso [l4h_malaria()]
#'
#' @examples
#' if (interactive()) {
#'   # National extract for Peru in 2019
#'   df_nat <- l4h_dengue(
#'     from = "2019-01-01",
#'     to = "2019-12-31",
#'     data_type = "national",
#'     region = "paho",
#'     country = "peru",
#'     cache = TRUE,
#'     quiet = TRUE
#'   )
#'   head(df_nat)
#'
#'   # Spatial extract for Brazil
#'   df_spat <- l4h_dengue(
#'     from = "2021-01-01",
#'     to = "2021-12-31",
#'     data_type = "spatial",
#'     region = "Pan-American Region",
#'     country = "brazil",
#'     cache = TRUE,
#'     quiet = TRUE
#'   )
#'   head(df_spat)
#'
#'   # Temporal extract for Argentina
#'   df_temp <- l4h_dengue(
#'     from = "2020-01-01",
#'     to = "2020-12-31",
#'     data_type = "temporal",
#'     region = "PAHO",
#'     country = "Argentina",
#'     cache = TRUE,
#'     quiet = TRUE
#'   )
#'   head(df_temp)
#' }
#' @export
l4h_dengue <- function(
    from,
    to,
    data_type    = c("temporal", "spatial", "national"),
    region       = NULL,
    country      = "Peru",
    cache        = TRUE,
    quiet        = FALSE
) {

  # version
  url <- "https://api.github.com/repos/OpenDengue/master-repo/contents/assets?ref=main"
  resp <- httr2::request(url) |>
    httr2::req_user_agent("land4health/1.0") |>
    httr2::req_perform()
  items <- resp |> httr2::resp_body_json()
  file_name <- items[[1]]$name
  version <- sub(".*_([Vv][0-9]+_[0-9]+)\\.zip$", "\\1", basename(file_name))

  # If extraction failed or the result is not a valid version, abort
  if (identical(version, file_name) || !grepl("^[Vv][0-9]+_[0-9]+$", version)) {
    cli::cli_abort(
      "Function under construction due to version change. {.val {file_name}} does not contain a valid version tag."
    )
  }

  # Parse dates
  from <- as.Date(from)
  to   <- as.Date(to)

  if (is.na(from) || is.na(to) || from > to) {
    cli::cli_abort("Invalid 'from' or 'to' dates.")
  }

  # Internal mappings
  types <- c(
    national = "National",
    spatial  = "Spatial",
    temporal = "Temporal"
  )

  codes <- c(
    paho  = "PAHO",
    searo = "SEARO",
    wpro  = "WPRO",
    afro  = "AFRO",
    emro  = "EMRO",
    euro  = "EURO"
  )

  names_full <- c(
    paho  = "Pan-American Region",
    searo = "South-East Asia Region",
    wpro  = "Western Pacific Region",
    afro  = "African Region",
    emro  = "Eastern Mediterranean Region",
    euro  = "European Region"
  )

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
      "'region' must be one of codes: {paste(codes_keys, collapse = ', ')} or full names: {paste(names_full, collapse = ', ')}."
    )
  }
  region_code <- codes[[key]]
  region_name <- names_full[[key]]

  # Normalize country
  country <- toupper(country)
  if (quiet) cli::cli_status("Preparing {data_type} extract for {region_name} and {country}")

  # Build download URL
  url <- sprintf(
    "https://opendengue.org/assets/%s_extract_%s_%s.zip",
    types[[data_type]], region_code, version
  )
  if (quiet) cli::cli_status("Downloading {basename(url)}...")

  # Download and cache
  cache_dir <- tools::R_user_dir("land4health", "cache")
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  zip_file <- file.path(cache_dir, basename(url))
  req <- httr2::request(url)
  if (!cache || !file.exists(zip_file) || file.info(zip_file)$size == 0) {
    if (!quiet) req <- httr2::req_verbose(req)
    httr2::req_perform(req, path = zip_file)
    if (!quiet) cli::cli_status_update("Downloaded {basename(zip_file)}")
  } else if (!quiet) {
    cli::cli_status("Using cached file: {basename(zip_file)}")
  }

  # Unzip and read
  if (!quiet) cli::cli_status("Extracting CSV...")
  files <- utils::unzip(zip_file, exdir = cache_dir)
  csv <- grep("\\.csv$", files, value = TRUE)[1]
  if (is.na(csv)) cli::cli_abort("No CSV file found in the ZIP.")
  if (!quiet) cli::cli_status("Reading {basename(csv)}...")
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
