#' Configure Python environment for land4health
#'
#' @description Sets up the Python environment automatically based on installation.
#'
#' @param envname Character. Name of the Python environment. If NULL, uses saved config.
#' @param method Character. Method to use ("auto", "virtualenv", "conda"). If NULL, uses saved config.
#' @param quiet Logical. Suppress messages? Default FALSE.
#'
#' @return Invisibly returns NULL
#'
#' @examples
#' \dontrun{
#' l4h_use_python()
#' l4h_use_python("r-land4health", "virtualenv")
#' }
#'
#' @export
l4h_use_python <- function(envname = NULL, method = NULL, quiet = FALSE) {
  # Load saved config if parameters not provided
  if (is.null(envname) || is.null(method)) {
    config <- .load_env_config()

    if (!is.null(config)) {
      envname <- envname %||% config$envname
      method <- method %||% config$method

      if (!quiet) {
        cli::cli_alert_info("Using saved configuration: {envname} ({method})")
      }
    } else {
      envname <- envname %||% "r-land4health"
      method <- method %||% "auto"
    }
  }

  if (!quiet) {
    cli::cli_h2("Configuring Python environment")
  }

  # Detect method if auto
  if (method == "auto") {
    if (reticulate::virtualenv_exists(envname)) {
      method <- "virtualenv"
    } else {
      conda_envs <- try(reticulate::conda_list(), silent = TRUE)
      if (inherits(conda_envs, 'data.frame') && envname %in% conda_envs$name) {
        method <- "conda"
      } else {
        if (!quiet) {
          cli::cli_alert_danger("Environment '{envname}' not found")
          cli::cli_alert_info("Run {.code l4h_install()} first")
        }
        return(invisible(NULL))
      }
    }
  }

  # Use the environment
  tryCatch({
    if (method == "virtualenv") {
      if (!quiet) cli::cli_alert_info("Using virtualenv: {envname}")
      reticulate::use_virtualenv(envname, required = TRUE)
    } else if (method == "conda") {
      if (!quiet) cli::cli_alert_info("Using conda environment: {envname}")
      reticulate::use_condaenv(envname, required = TRUE)
    }

    # Verify Earth Engine API
    ee <- try(reticulate::import("ee"), silent = TRUE)

    if (!inherits(ee, "try-error")) {
      if (!quiet) {
        cli::cli_alert_success("Python environment configured successfully")
        cli::cli_alert_success("Earth Engine API loaded")
        cli::cli_alert_info("Initialize with: {.code rgee::ee_Initialize()}")
      }
    } else {
      if (!quiet) {
        cli::cli_alert_warning("Earth Engine API not found in environment")
        cli::cli_alert_info("Run {.code l4h_install()} to install Python packages")
      }
    }

  }, error = function(e) {
    if (!quiet) {
      cli::cli_alert_danger("Failed to configure Python environment")
      cli::cli_alert_info("Error: {e$message}")
    }
  })

  invisible(NULL)
}

# Helper operator
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
