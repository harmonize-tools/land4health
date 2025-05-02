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
utils::globalVariables(c("provider","category","ee"))


#' Internal: Get an Earth Engine reducer
#' Returns a reducer object (e.g., `ee$Reducer$mean()`) based on a string name.
#' @param name A string: one of `"mean"`, `"sum"`, `"min"`, `"max"`, `"median"`, `"stdDev"`.
#' @return An Earth Engine reducer object.
#' @keywords internal
get_reducer <- function(name) {
  if (!name %in% c("mean", "sum", "min", "max", "median", "stdDev")) {
    cli::cli_abort("Reducer '{name}' is not valid.")
  }
  do.call(rgee::ee$Reducer[[name]], list())
}


