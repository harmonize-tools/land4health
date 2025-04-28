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
utils::globalVariables(c("provider","category"))
