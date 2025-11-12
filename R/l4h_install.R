#' Install Python dependencies for land4health package
#'
#' @description Installs required Python packages (earthengine-api and numpy) using various methods.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param pip Logical. If TRUE (default), uses pip for installation. Set to FALSE if
#'   specifying a different installation method.
#' @param system Logical. If TRUE, uses system pip directly via system() call.
#' @param force Logical. If TRUE, forces reinstallation/upgrade of packages.
#' @param ... Additional arguments passed to reticulate::py_install(), such as:
#'   \itemize{
#'     \item method: Installation method ("auto", "virtualenv", "conda")
#'     \item envname: Environment name (default: "r-land4health")
#'   }
#'
#' @return Invisibly returns NULL
#'
#' @examples
#' \dontrun{
#' # Basic installation
#' l4h_install()
#'
#' # Force reinstallation
#' l4h_install(force = TRUE)
#'
#' # Use conda environment
#' l4h_install(method = "conda")
#' }
#' @export
l4h_install <- function(pip = TRUE, system = FALSE, force = FALSE, ...) {
  # cribbed from: https://github.com/brownag/rgeedim/blob/main/R/install.R
  args <- list(...)

  # Helper function for status messages
  tick <- function(msg) {
    cli::cli_alert_info(msg)
  }

  # Use pip = FALSE if method is specified
  if (!is.null(args[["method"]])) {
    pip <- FALSE
  }

  # Set default environment name
  if (!"envname" %in% names(args)) {
    args[["envname"]] <- "r-land4health"
  }

  # Optionally use system() pip call
  if (system && pip) {
    fp <- .find_python()
    if (nchar(fp) > 0) {
      tick("Using system pip")
      system(paste(
        shQuote(fp),
        "-m pip install --user",
        ifelse(force, "-U --force", ""),
        "earthengine-api==0.1.370 numpy"
      ))
      tick("System install complete")
      return(invisible(NULL))
    }
  }

  # Handle method = "virtualenv" or "conda"
  if ("method" %in% names(args)) {

    if (args[["method"]] == "virtualenv") {
      if (!reticulate::virtualenv_exists(envname = args[["envname"]])) {
        tick("Creating virtualenv")
        reticulate::virtualenv_create(envname = args[["envname"]])
      } else {
        tick("Using existing virtualenv")
      }

    } else if (args[["method"]] == "conda") {
      cl <- try(reticulate::conda_list())
      if (inherits(cl, 'data.frame') && !args[["envname"]] %in% cl$name) {
        tick("Creating conda env")
        reticulate::conda_create(envname = args[["envname"]])
      } else {
        tick("Using existing conda env")
      }
    }
  }

  tick(sprintf("Installing packages in environment '%s' using method '%s'",
               args[["envname"]],
               ifelse("method" %in% names(args), args[["method"]], "auto")))

  tryCatch({
    do.call(reticulate::py_install, c(list(
      c("numpy", "earthengine-api==0.1.317"),
      pip = pip,
      pip_ignore_installed = force
    ), args))
    tick("Finished")
  }, error = function(e) {
    tick("Installation failed")
    message("Error: ", e$message)
  })

  invisible(NULL)
}
