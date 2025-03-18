.onAttach <- function(libname, pkgname) {
  if (interactive() && !isTRUE(getOption("land4health.shownWelcome"))) {

    cli::cli_h1("Welcome to land4health")

    cli::cli_alert_info("A tool of Harmonize Project for calculate and extract Remote Sensing Metrics for Spatial Health Analysis")
    cli::cli_alert_info("Currently,`land4health` supports metrics related to the following categories:")

    # providers_data <- get_providers()
    # providers <- c(if (is.data.frame(providers_data) && "provider" %in% names(providers_data)) {
    #   providers_data$provider[1:min(4, nrow(providers_data))] |> as.vector()
    # } else character(),"and more!")
    #
    # for (provider in providers) {
    #   cli::cli_alert_success(provider)
    # }

    cli::cli_alert_info("For more information about metrics, please use the `get_metrics_sources()` function.")

    options(land4health.shownWelcome = TRUE)
  }
}
