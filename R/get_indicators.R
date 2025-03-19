#' Load and preview indicators from an Excel file
#'
#' This function reads an Excel file containing environmental indicators and displays
#' the first few rows.
#'
#' @param file_path Path to the Excel file (default is "files/indicators.xlsx").
#' @param interactive If TRUE, displays a data table in an interactive format (default is FALSE).
#' @return A table with the first rows of the dataset.
#' @export
get_indicators <- function(file_path = "files/indicators.xlsx", interactive = FALSE) {
  # Leer el archivo Excel
  indicadores_data <- readxl::read_excel(file_path)

  # Mostrar las primeras filas
  if (interactive) {
    return(DT::datatable(head(indicadores_data)))
  } else {
    return(head(indicadores_data))
  }
}
