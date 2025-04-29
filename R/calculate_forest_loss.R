#' Calculate Forest Loss
#'
#' This function calculates forest loss inside a user-defined polygon.
#'
#' @param polygon A sf object with the area of interest.
#' @param forest_loss_layer A SpatRaster or sf object representing forest loss.
#'
#' @return A list with loss area (in m²) and loss percentage.
#'
#' @section Lifecycle:
#' `r lifecycle::badge('stable')`
#'
#' @export
calculate_forest_loss <- \(from, to, region, fun, progress = FALSE, sf = TRUE) {

  if (to < from) {
    cli::cli_abort(c(
      "!" = "Invalid dates: {.field from} = {from}, {.field to} = {to}.",
      "x" = "The {.field to} date must be later than the {.field from} date."
    ))
  }

  start_date <- as.integer(
    substr(
      regmatches(to,regexpr("\\d{4}", to)),
      start = 3,
      stop = 4)
  )

  end_date <- as.integer(
    substr(
      regmatches(from,regexpr("\\d{4}", from)),
      start = 3,
      stop = 4)
  )

  range_date <- start_date:end_date

  hansen_id <- .internal_data$hansen

  sf_box <- region |> sf::st_bbox()

  r <- rgeedim::gd_bbox(
    xmin = sf_box["xmin"],
    xmax = sf_box["xmax"],
    ymin = sf_box["ymin"],
    ymax = sf_box["ymax"]
  )

  x <- hansen_id |>
    rgeedim::gd_image_from_id() |>
    rgeedim::gd_download(
      filename = tempfile(fileext = ".tif"),
      region = sf_box,
      crs = paste0("EPSG:", sf::st_crs(region)$epsg),
      bands = list("lossyear"),
      scale = scale,
      overwrite = TRUE,
      silent = FALSE)


}
