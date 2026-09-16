#' Extract malaria metrics from the Malaria Atlas Project GeoServer
#'
#' @description
#' Downloads modeled malaria raster surfaces from the **Malaria Atlas Project**
#' (MAP) GeoServer via WCS 2.0.1, extracts zonal statistics for a user-defined
#' region and time range, and returns an `sf` or `tibble`.
#'
#' Available species: *Plasmodium falciparum* (`"pf"`) and
#' *Plasmodium vivax* (`"pv"`).
#' Available measures: `"incidence_rate"`, `"incidence_count"`,
#' `"parasite_rate"`, `"mortality_rate"`, `"mortality_count"`.
#' The function automatically selects the **latest release** available on the
#' server for the requested species + measure combination.
#'
#' \if{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.png}{options: width="120"}
#' }}
#' \if{latex}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{
#'   \figure{lifecycle-experimental.pdf}{options: width=2cm}
#' }}
#'
#' @param from Integer. Start year.
#' @param to Integer. End year. Must be >= `from`.
#' @param species Character. One of `"pf"` (Plasmodium falciparum) or
#'   `"pv"` (Plasmodium vivax). Default `"pf"`.
#' @param measure Character. One of `"incidence_rate"`, `"incidence_count"`,
#'   `"parasite_rate"`, `"mortality_rate"`, `"mortality_count"`.
#'   Default `"incidence_rate"`.
#' @param region Spatial object defining the region of interest.
#'   Accepts an `sf`, `sfc`, or `SpatVector` object.
#' @param stat Character. Summary statistic per pixel per year. One of
#'   `"mean"`, `"median"`, `"min"`, `"max"`. Default `"mean"`.
#' @param sf Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a
#'   `tibble`. Default `TRUE`.
#' @param quiet Logical. If `TRUE`, suppresses progress messages. Default
#'   `FALSE`.
#' @param force Logical. If `TRUE`, skips the representativity check.
#'   Default `FALSE`.
#' @param ... Additional arguments (currently unused).
#'
#' @return An `sf` or `tibble` with columns:
#'   - `date` (`Date`, first day of year),
#'   - `species` (`character`, `"pf"` or `"pv"`),
#'   - `measure` (`character`, the requested measure),
#'   - `value` (`numeric`, in native units),
#'   plus geometry if `sf = TRUE`, and any attributes from `region`.
#'
#' @details
#' The MAP GeoServer provides modeled global raster surfaces at ~5 km resolution.
#' Rates are expressed per person (0-1 scale for parasite rate, per 1,000 for
#' incidence), and counts are absolute numbers. The function connects to the
#' GeoServer via `ows4R::WCSClient`, downloads the coverage clipped to the
#' region bounding box, and uses `terra::extract()` for zonal statistics.
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
#'
#' # ROI simple (EPSG:4326)
#' region <- st_as_sf(st_sfc(
#'   st_polygon(list(matrix(c(
#'     -74.1, -4.4,
#'     -74.1, -3.7,
#'     -73.2, -3.7,
#'     -73.2, -4.4,
#'     -74.1, -4.4
#'   ), ncol = 2, byrow = TRUE))), crs = 4326))
#'
#' # Pf incidence rate 2015-2020
#' out <- l4h_malaria(
#'   from    = 2015,
#'   to      = 2020,
#'   species = "pf",
#'   measure = "incidence_rate",
#'   region  = region
#' )
#' head(out)
#'
#' # Pv parasite rate
#' out_pv <- l4h_malaria(
#'   from    = 2020,
#'   to      = 2022,
#'   species = "pv",
#'   measure = "parasite_rate",
#'   region  = region,
#'   sf      = FALSE
#' )
#' head(out_pv)
#' }
#'
#' @references
#' Malaria Atlas Project. \url{https://malariaatlas.org/}
#'
#' @export
l4h_malaria <- function(from,
                        to,
                        species  = "pf",
                        measure  = "incidence_rate",
                        region,
                        stat     = "mean",
                        sf       = TRUE,
                        quiet    = FALSE,
                        force    = FALSE,
                        ...) {


  if (!is.numeric(from) || length(from) != 1L || is.na(from)) {
    cli::cli_abort("{.field from} must be a single integer year. Got: {.val {from}}")
  }
  if (!is.numeric(to) || length(to) != 1L || is.na(to)) {
    cli::cli_abort("{.field to} must be a single integer year. Got: {.val {to}}")
  }
  from <- as.integer(from)
  to   <- as.integer(to)
  if (to < from) {
    cli::cli_abort("{.field to} must be >= {.field from}")
  }

  species <- tolower(species)
  valid_species <- c("pf", "pv")
  if (!species %in% valid_species) {
    cli::cli_abort("Invalid species: {.val {species}}. Valid options: {.or {valid_species}}")
  }

  measure <- tolower(measure)
  valid_measures <- c("incidence_rate", "incidence_count", "parasite_rate",
                      "mortality_rate", "mortality_count")
  if (!measure %in% valid_measures) {
    cli::cli_abort("Invalid measure: {.val {measure}}. Valid options: {.or {valid_measures}}")
  }

  sf_classes <- c("sf", "sfc", "SpatVector")
  if (!inherits(region, sf_classes)) {
    cli::cli_abort("Invalid {.arg region}: must be {.cls sf}, {.cls sfc}, or {.cls SpatVector}.")
  }

  region_sf <- if (inherits(region, "SpatVector")) sf::st_as_sf(region) else region

  if (isFALSE(force)) {
    check_representativity(region = region_sf, scale = 5000)
  }

  # Map measure names to GeoServer naming
  # incidence_rate -> Incidence_Rate, parasite_rate -> Parasite_Rate, etc.
  measure_map <- c(
    incidence_rate  = "Incidence_Rate",
    incidence_count = "Incidence_Count",
    parasite_rate   = "Parasite_Rate",
    mortality_rate  = "Mortality_Rate",
    mortality_count = "Mortality_Count"
  )
  measure_gs <- measure_map[[measure]]

  # Species abbreviation for GeoServer (Pf, Pv)
  sp_abbr <- paste0(toupper(substr(species, 1, 1)), substr(species, 2, 2))

  # -- Connect to GeoServer and find latest release
  if (!quiet) cli::cli_alert_info("Connecting to Malaria Atlas GeoServer...")

  logger <- getOption("l4h.ows4r.logger", NULL)
  client <- suppressMessages(
    ows4R::WCSClient$new(
      url            = .internal_data$malaria_atlas,
      serviceVersion = "2.0.1",
      logger         = logger
    )
  )

  caps <- client$getCapabilities()
  all_ids <- sapply(caps$getCoverageSummaries(), function(x) x$getId())

  # Filter IDs matching our species + measure
  pattern <- sprintf("Malaria__\\d{6}_Global_%s_%s", sp_abbr, measure_gs)
  matching_ids <- grep(pattern, all_ids, value = TRUE)

  if (length(matching_ids) == 0) {
    cli::cli_abort(c(
      "x" = "No layers found for species {.val {species}} and measure {.val {measure}}.",
      "i" = "Check the {.arg species} and {.arg measure} parameters."
    ))
  }

  # Extract release versions and pick the latest
  releases <- as.integer(sub("Malaria__(\\d{6})_Global_.*", "\\1", matching_ids))
  latest_release <- max(releases)
  dataset_id <- sprintf("Malaria__%06d_Global_%s_%s", latest_release, sp_abbr, measure_gs)

  if (!quiet) cli::cli_alert_info("Using release: {.val {latest_release}} - {.val {dataset_id}}")

  #Find coverage and get time steps
  coverage <- caps$findCoverageSummaryById(dataset_id, exact = TRUE)
  if (is.null(coverage)) {
    cli::cli_abort("Coverage {.val {dataset_id}} not found on the GeoServer.")
  }

  # Get available time steps from dimensions
  dims <- coverage$getDimensions()
  # The temporal dimension has coefficients with ISO date strings
  time_steps <- NULL
  for (d in dims) {
    coefs <- d$coefficients
    if (!is.null(coefs) && any(grepl("T", coefs))) {
      time_steps <- as.character(coefs)
      break
    }
  }

  if (is.null(time_steps)) {
    cli::cli_abort("Could not retrieve time steps from the GeoServer.")
  }

  # Parse years from time steps (e.g., "2020-01-01T00:00:00" -> 2020)
  available_years <- as.integer(format(as.Date(time_steps), "%Y"))
  requested_years <- from:to
  valid_years <- intersect(requested_years, available_years)

  if (length(valid_years) == 0) {
    cli::cli_abort(c(
      "x" = "No data available for years {from} to {to}.",
      "i" = "Available years: {range(available_years)[1]} to {range(available_years)[2]}."
    ))
  }

  if (!quiet) {
    cli::cli_alert_info("Extracting {length(valid_years)} year(s): {.val {range(valid_years)[1]}} to {.val {range(valid_years)[2]}}")
  }

  # Build bounding box from region
  bbox_sf <- sf::st_bbox(sf::st_transform(region_sf, crs = 4326))
  bbox_ows <- ows4R::OWSUtils$toBBOX(
    xmin = bbox_sf[["xmin"]], xmax = bbox_sf[["xmax"]],
    ymin = bbox_sf[["ymin"]], ymax = bbox_sf[["ymax"]]
  )

  region_vect <- terra::vect(region_sf)

  # Extract by year
  results <- vector("list", length(valid_years))

  for (i in seq_along(valid_years)) {
    yr <- valid_years[i]
    time_str <- sprintf("%04d-01-01T00:00:00", yr)

    if (!quiet) {
      cli::cli_progress_step(
        "Downloading {.val {yr}} ({i}/{length(valid_years)})",
        msg_done = "Downloaded {.val {yr}}"
      )
    }

    # Find the matching time step
    time_match <- time_steps[grepl(sprintf("^%04d", yr), time_steps)]
    if (length(time_match) == 0) next

    # Download coverage via WCS
    raster <- tryCatch(
      coverage$getCoverage(bbox = bbox_ows, time = time_match[1]),
      error = function(e) {
        if (!quiet) cli::cli_warn("Failed to download {.val {yr}}: {conditionMessage(e)}")
        return(NULL)
      }
    )

    if (is.null(raster)) next

    # Set NA flag
    terra::NAflag(raster) <- -9999

    # Extract band 1 (modelled estimate) only
    if (terra::nlyr(raster) >= 2) {
      # Band 2 is mask: 0 = valid, 1 = masked
      mask_band <- raster[[2]]
      main_band <- raster[[1]]
      main_band[mask_band == 1] <- NA
      raster <- main_band
    }

    # Zonal statistics (terra-native, no GEE dependency)
    valid_stats <- c("mean", "median", "min", "max", "sum")
    if (!stat %in% valid_stats) {
      cli::cli_abort("Invalid {.arg stat}: {.val {stat}}. Valid options: {.or {valid_stats}}")
    }
    ext <- terra::extract(raster, region_vect, fun = stat, na.rm = TRUE)

    # Build result
    id_col <- if ("ID" %in% names(ext)) ext$ID else seq_len(nrow(ext))
    vals <- ext[[2]]

    results[[i]] <- data.frame(
      id      = id_col,
      date    = as.Date(sprintf("%04d-01-01", yr)),
      species = species,
      measure = measure,
      value   = as.numeric(vals),
      stringsAsFactors = FALSE
    )
  }

  # Remove NULLs (failed downloads)
  results <- results[!vapply(results, is.null, logical(1))]

  if (length(results) == 0) {
    cli::cli_abort("No data could be extracted. Check your region and date range.")
  }

  result <- dplyr::bind_rows(results)

  # Add geometry from region using id column (row index into region_sf)
  result_id <- result$id

  if (isTRUE(sf)) {
    result$id <- NULL
    result <- sf::st_set_geometry(result, sf::st_geometry(region_sf)[result_id])
  } else {
    result$id <- NULL
  }

  return(result)
}
