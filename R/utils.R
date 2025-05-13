#' Reading a csv containing geoidep resources
#' @importFrom utils read.csv
#' @keywords internal
get_data <- \(url = NULL){
  if(is.null(url)){
    url <- getOption(
      x = "land4health",
      default = .internal_data$land4health
      )
  }
  tryCatch({
    data <- read.csv(url) |>
      tidyr::as_tibble()
    return(data)
  }, error = function(e) {
    stop("The file could not be read. Please install the package and its dependencies correctly and consider the latest version.")
  })
}

#' Global variables for get_early_warning
#' This code declares global variables used in the some function to avoid R CMD check warnings.
#' @name global-variables
#' @keywords internal
utils::globalVariables(c("provider","category","ee","year","area_km2", "b1","rai_index","population","accessibility","water_coverage", "geom_col","water_proportion"))


#' Internal: Get an Earth Engine reducer
#' Returns a reducer object (e.g., `ee$Reducer$mean()`) based on a string name.
#' @param name A string: one of `"mean"`, `"sum"`, `"min"`, `"max"`, `"median"`, `"stdDev"`.
#' @return An Earth Engine reducer object.
#' @keywords internal
get_reducer <- function(name) {
  reducers <- c(
    "mean" = "mean",
    "sum" = "sum",
    "min" = "min",
    "max" = "max",
    "median" = "median",
    "sd" = "stdDev",
    "first" = "first"
  )

  if (!name %in% names(reducers)) {
    cli::cli_abort("Reducer '{name}' is not valid. Valid options are: {paste(names(reducers), collapse = ', ')}")
  }

  reducer_name <- reducers[[name]]
  do.call(rgee::ee$Reducer[[reducer_name]], list())
}

#' Evaluates whether a given polygon covers a minimum number of valid pixels
#' in a specified Earth Engine image.
#' @param region An `sf` polygon object representing the area of interest.
#' @param scale Numeric. Pixel resolution in meters (e.g., 30 for Hansen).
#' @return Invisible `TRUE` if representative; otherwise `FALSE`.
#' @keywords internal
check_representativity <- function(region, scale = 30) {
  if (!inherits(region, "sf")) {
    cli::cli_abort("The {.arg region} must be an {.cls sf} object.")
  }

  # Selection of polygon of size minimum
  region_area_km2 <- region |>
    sf::st_transform(crs = 3857) |>
    (\(x) dplyr::mutate(x, area_km2 = as.vector(sf::st_area(sf::st_geometry(x)) / 1e6)))() |>
    dplyr::arrange(area_km2) |>
    dplyr::slice(1) |>
    sf::st_drop_geometry() |>
    dplyr::select(area_km2)

  # Pixel area
  pixels_area <- (scale^2)/1e6
  condicion <- region_area_km2 < pixels_area

  # Condition
  if (isTRUE(condicion)) {
    msg <- c(
      "!" = "The region does not cover enough pixels to be representative.",
      "i" = "Area Minimum required: {round(pixels_area,2)} km2 at {scale}m resolution.",
      "x" = "Smallest region covers: {round(min(region_area_km2), 2)}km2 area",
      "v" = "Consider using a larger polygon or buffering the input region."
    ) |>
      cli::cli_alert_warning()
    return(msg)
  }

}
