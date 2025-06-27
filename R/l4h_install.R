#' Install Python dependencies for land4health package
#'
#' @description
#' Installs required Python packages (`earthengine-api` and `numpy`) using
#' virtualenv, conda, or system pip via the `reticulate` package.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param pip Logical. If \code{TRUE} (default), uses pip for installation.
#'   Automatically set to \code{FALSE} if a method is specified via \code{...}.
#' @param system Logical. If \code{TRUE}, uses the system Python and pip via a
#'   system call. Defaults to \code{FALSE}.
#' @param force Logical. If \code{TRUE}, forces reinstallation of packages using
#'   \code{--force-reinstall}. Defaults to \code{FALSE}.
#' @param ... Additional arguments passed to \code{\link[reticulate]{py_install}}, such as:
#'   \itemize{
#'     \item \code{method}: Installation method ("auto", "virtualenv", "conda")
#'     \item \code{envname}: Python environment name (default: "r-land4health")
#'   }
#'
#' @return Invisibly returns \code{NULL}. This function is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # Basic installation
#' l4h_install()
#'
#' # Force reinstallation
#' l4h_install(force = TRUE)
#'
#' # Use a conda environment
#' l4h_install(method = "conda")
#' }
#'
#' @importFrom cli cli_h1 cli_alert_info cli_alert_success cli_alert_danger
#' @export

l4h_install <- function(pip = TRUE, system = FALSE, force = FALSE, ...) {
  cli::cli_h1("Installing land4health Python dependencies")

  args <- list(...)

  # Detect method override
  if (!is.null(args[["method"]])) pip <- FALSE
  if (!"envname" %in% names(args)) args[["envname"]] <- "r-land4health"

  method <- args[["method"]] %||% "auto"

  # Use system pip if requested
  if (system && pip) {
    fp <- .find_python()
    if (nchar(fp) > 0) {
      cli::cli_alert_info("Using system pip: {.path {fp}}")
      system(paste(
        shQuote(fp),
        "-m pip install --user",
        ifelse(force, "-U --force", ""),
        "earthengine-api==0.1.370 numpy >nul 2>&1" # oculta salida en Windows
      ))
      cli::cli_alert_success("System pip installation complete.")
      return(invisible(NULL))
    }
  }

  # Create environment
  if (method == "virtualenv") {
    if (!reticulate::virtualenv_exists(args[["envname"]])) {
      cli::cli_alert_info("Creating virtualenv {.val {args[['envname']]}}")
      reticulate::virtualenv_create(envname = args[["envname"]], quiet = TRUE)
    } else {
      cli::cli_alert_info("Using existing virtualenv {.val {args[['envname']]}}")
    }
  } else if (method == "conda") {
    cl <- try(reticulate::conda_list(), silent = TRUE)
    if (inherits(cl, "data.frame") && !args[["envname"]] %in% cl$name) {
      cli::cli_alert_info("Creating conda environment {.val {args[['envname']]}}")
      reticulate::conda_create(envname = args[["envname"]], packages = NULL, pip = TRUE)
    } else {
      cli::cli_alert_info("Using existing conda environment {.val {args[['envname']]}}")
    }
  }

  cli::cli_alert_info("Installing packages: numpy, earthengine-api==0.1.370")

  tryCatch({
    do.call(reticulate::py_install, c(list(
      packages = c("numpy", "earthengine-api==0.1.370"),
      pip = pip,
      pip_ignore_installed = force,
      pip_options = c("-q")  # silencioso
    ), args))
    cli::cli_alert_success("Installation completed successfully.")
  }, error = function(e) {
    cli::cli_alert_danger("Installation failed: {e$message}")
  })

  invisible(NULL)
}
