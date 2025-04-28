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
calculate_forest_loss <- \(to, from, region, fun, progress = FALSE, sf = TRUE) {
  sf_box <- region |> sf::st_bbox()
  r <- rgeedim::gd_bbox(
    xmin = sf_box["xmin"],
    xmax = sf_box["xmax"],
    ymin = sf_box["ymin"],
    ymax = sf_box["ymax"]
  )

  x <- rgeedim::gd_image_from_id(
    x = getOption(
      x = "land4health",
      default = .internal_data$hansen)
    )


}
