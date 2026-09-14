#' List malaria layers by species & metric from Malaria Atlas Project
#'
#' @description
#' Provides a tidy listing of all malaria data layers in the Malaria Atlas Project GeoServer,
#' including separate columns for species (Plasmodium falciparum vs. Plasmodium vivax),
#' year, month, and metric (e.g. incidence_rate, parasite_rate, mortality_count, etc.).
#' These layers cover modeled estimates of malaria prevalence, incidence, mortality and more,
#' at global scale, broken down by species and time.
#'
#' \if{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{
#'   \figure{lifecycle-stable.png}{options: width="120"}
#' }}
#' \if{latex}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{
#'   \figure{lifecycle-stable.pdf}{options: width=2cm}
#' }}
#'
#' @param year    Integer or integer vector. Optional filter on dataset year (e.g. `2024`).
#' @param species Character or character vector. Optional filter on species:
#'   - `"plasmodium falciparum"`
#'   - `"plasmodium vivax"`
#' @param measure Character or character vector. Optional filter on metric type:
#'   e.g. `"incidence_rate"`, `"parasite_rate"`, `"mortality_count"`, `"reproductive_number"`.
#'
#' @return A tibble with columns:
#'   * `workspace`  — always `"malaria"`
#'   * `year`       — dataset year
#'   * `month`      — dataset month (NA if annual)
#'   * `species`    — full species name (lowercase)
#'   * `measure`    — metric type (lowercase)
#'   * `dataset_id` — original coverage ID for subsequent WMS/WCS requests
#'
#' @details
#' The Malaria Atlas Project \url{https://malariaatlas.org/} provides globally modeled
#' raster surfaces of key malaria indicators. This function retrieves all available
#' coverage IDs from the GeoServer, parses out the species, time, and metric,
#' and returns them in a user-friendly table for easy filtering and selection.
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
#' \donttest{
#' # list all available malaria layers
#' all_layers <- l4h_layers_available_malaria()
#' head(all_layers)
#'
#' # filter for Plasmodium falciparum parasite rate in 2024
#' pf_pr_2024 <- l4h_layers_available_malaria(
#'   year    = 2024,
#'   species = "plasmodium falciparum",
#'   measure = "parasite_rate"
#' )
#' print(pf_pr_2024)
#' }
#' @export
l4h_layers_available_malaria <- function(year    = NULL,
                                         species = NULL,
                                         measure = NULL) {
  logger <- getOption("l4h.ows4r.logger", NULL)
  client <- suppressMessages(ows4R::WCSClient$new(
    url            = .internal_data$malaria_atlas,
    serviceVersion = "2.0.1",
    logger         = logger
  ))

  ids <- client$getCapabilities()$getCoverageSummaries() |>
    lapply(function(x) x$getId()) |>
    unlist()

  pat   <- "^(Malaria)__([0-9]{4,6})_Global_(.*)$"
  parts <- regmatches(ids, regexec(pat, ids))
  n     <- length(parts)

  ws_vec      <- character(n)
  version_vec <- character(n)
  raw_vec     <- character(n)
  for (i in seq_len(n)) {
    p <- parts[[i]]
    if (length(p) == 4) {
      ws_vec[i]      <- tolower(p[2])
      version_vec[i] <- p[3]
      raw_vec[i]     <- p[4]
    }
  }

  year_vec  <- as.integer(substr(version_vec, 1, 4))
  month_vec <- ifelse(nchar(version_vec) == 6,
                      as.integer(substr(version_vec, 5, 6)),
                      NA_integer_)

  abbr        <- tolower(sub("_.*$", "", raw_vec))
  species_vec <- ifelse(abbr == "pf",
                        "plasmodium falciparum",
                        ifelse(abbr == "pv",
                               "plasmodium vivax",
                               abbr))
  measure_vec <- tolower(sub("^[^_]+_", "", raw_vec))

  df <- tidyr::tibble(
    workspace  = ws_vec,
    year       = year_vec,
    month      = month_vec,
    species    = species_vec,
    measure    = measure_vec,
    dataset_id = ids
  )

  if (!is.null(year))    df <- df[df$year    %in% year,    ]
  if (!is.null(species)) df <- df[df$species %in% species, ]
  if (!is.null(measure)) df <- df[df$measure %in% measure, ]

  df
}
