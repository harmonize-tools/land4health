.onAttach <- function(libname, pkgname) {
  if (interactive() && !isTRUE(getOption("land4health.shownWelcome"))) {

    name.project <- cli::bg_blue(cli::style_bold(cli::col_white("Harmonize Project")))

    cli::cli_h1("Welcome to land4health")
    cli::cli_alert_info("{.emph A tool of {.href [{name.project}](https://www.harmonize-tools.org/)} for calculate and extract Remote Sensing Metrics for Spatial Health Analysis}")
    cli::cli_alert_info("{.emph Currently,`land4health` supports metrics related to the following categories:}")

    category_data <- get_metrics_summary()
    list_categories <- c(if (is.data.frame(category_data) && "category" %in% names(category_data)) {
      category_data$category[1:min(4, nrow(category_data))] |> as.vector()
    } else character(),"and more!")

    for (category in list_categories) {
      cli::cli_li(category)
    }

    cli::cli_alert_info("{.emph For more information about metrics, please use the `get_metrics_metadata()` function.}")

    options(land4health.shownWelcome = TRUE)
  }
}
