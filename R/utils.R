#' Reading a csv containing geoidep resources
#' @importFrom utils read.csv
#' @keywords internal
get_data <- \(){
  read.csv("https://raw.githubusercontent.com/harmonize-tools/land4health/refs/heads/main/inst/exdata/sources.csv") |>
    tidyr::as_tibble()
}

#' Global variables for get_early_warning
#' This code declares global variables used in the some function to avoid R CMD check warnings.
#' @name global-variables
#' @keywords internal
utils::globalVariables(c("provider","category"))
