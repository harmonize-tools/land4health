.onAttach <- function(libname, pkgname) {
  if (interactive() && !isTRUE(getOption("land4health.shownWelcome"))) {

    name.project <- cli::bg_blue(cli::style_bold(cli::col_white("Harmonize Project")))

    cli::cli_h1("Welcome to land4health")
    cli::cli_alert_info("A tool of {.href [{name.project}](https://www.harmonize-tools.org/)} for calculate and extract Remote Sensing Metrics \nfor {.emph Spatial Health Analysis}")
    cli::cli_alert_info("Currently,`land4health` supports metrics related to the following categories:")

    providers_data <- get_providers_metrics()
    providers <- c(if (is.data.frame(providers_data) && "provider" %in% names(providers_data)) {
      providers_data$provider[1:min(4, nrow(providers_data))] |> as.vector()
    } else character(),"and more!")

    for (provider in providers) {
      cli::cli_li(provider)
    }

    cli::cli_alert_info("For more information about metrics, please use the `summarize_providers_metrics()` function.")

    options(land4health.shownWelcome = TRUE)
  }
}
