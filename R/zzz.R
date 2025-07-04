.onAttach <- function(libname, pkgname) {
  if (interactive() && !isTRUE(getOption("land4health.shownWelcome"))) {

    # Block 1 : Presentation of Harmonize --------------------------------------
    withCallingHandlers({
      cli::cli_h1("Welcome to land4health")
      cli::cli_text("{.emph A tool of {.href [{.pkg Harmonize Project}](https://www.harmonize-tools.org/)} to calculate and extract Remote Sensing Metrics for Spatial Health Analysis. Currently,{.code land4health} supports metrics in the following categories:}")

      # Block 2 : Metrics available ----------------------------------------------
      providers_count <- get_data() |>
        subset(select = "category") |>
        table() |>
        as.data.frame() |>
        tidyr::as_tibble()
      names(providers_count) <- c("category", "metrics_counts")
      category_data <- providers_count
      list_categories <- c(if (is.data.frame(category_data) && "category" %in% names(category_data)) {
        category_data$category[1:min(3, nrow(category_data))] |> as.vector()
      } else {
        character()
      }, "and more!")

      for (category in list_categories) {
        cli::cli_li(category)
      }


      cli::cli_text("{.emph For a complete list of available metrics, use the {.code l4h_list_metrics()} function.}")
    },
    message = function(m) {
      packageStartupMessage(m$message)
      invokeRestart("muffleMessage")
    })

    options(land4health.shownWelcome = TRUE)
  }

  # Block 4: Packages backend of land4health ----------------------------------
  withCallingHandlers({
    cli::cli_h1("")
    cli::cli_inform("Attaching core {.pkg land4health} packages:")
  },
  message = function(m) {
    packageStartupMessage(m$message)
    invokeRestart("muffleMessage")
  })

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
