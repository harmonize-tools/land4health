.onAttach <- function(libname, pkgname) {
  if (interactive() && !isTRUE(getOption("land4health.shownWelcome"))) {
  # Block 1 : Presentation of Harmonize --------------------------------------
    cli::cli_h1("Welcome to land4health")
    cli::cli_text("{.emph A tool of {.href [{.pkg Harmonize Project}](https://www.harmonize-tools.org/)} to calculate and extract Remote Sensing Metrics for Spatial Health Analysis.}")
    cli::cli_text("{.emph Currently,`land4health` supports metrics related to the following categories:}")

  # Block 2 : Metrics available ----------------------------------------------
    providers_count <- get_data() |>
      subset(select = "category") |>
      table() |>
      as.data.frame() |>
      tidyr::as_tibble()
    names(providers_count) <- c("category", "metrics_counts")
    category_data <- providers_count
    list_categories <- c(if (is.data.frame(category_data) && "category" %in% names(category_data)) {
      category_data$category[1:min(4, nrow(category_data))] |> as.vector()
    } else {
      character()
    }, "and more!")

    for (category in list_categories) {
      cli::cli_li(category)
    }
  # Block 3: Additional help
    cli::cli_text("{.emph For more information about metrics, please use the `get_metrics_metadata()` function.}")
    options(land4health.shownWelcome = TRUE)
  }

  # Block 4: Packages backend of land4health ----------------------------------
  cli::cli_inform(
    "Attaching core {.pkg land4health} packages:",
    class = "packageStartupMessage"
  )
  attached <- land4health_attach()
  if (length(attached) > 0) {
    pkg_ul(attached)
  }
}

# cribbed from https://github.com/R-ArcGIS/arcgis/blob/main/R/zzz.R
pkg_ul <- function(pkgs) {
  pkg_versions <- vapply(
    pkgs,
    function(.x) as.character(utils::packageVersion(.x)),
    character(1)
  )

  for (i in seq_along(pkgs)) {
    pkg <- pkgs[i]
    ver <- pkg_versions[i]
    cli::cli_inform(
      c(">" = "{.pkg {pkg}} v{ver}"),
      class = "packageStartupMessage"
    )
  }
}
