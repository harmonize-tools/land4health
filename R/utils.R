#' Reading a csv containing geoidep resources
#' @importFrom utils read.csv
#' @keywords internal
get_data <- \(){
  read.csv("inst/exdata/sources.csv")
}
