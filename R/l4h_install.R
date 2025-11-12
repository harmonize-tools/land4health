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
#' @param restart Logical. If TRUE, automatically restarts R session after installation. Default TRUE.
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
#' # Basic installation with auto-restart
#' l4h_install()
#'
#' # Force reinstallation without restart
#' l4h_install(force = TRUE, restart = FALSE)
#'
#' # Use conda environment
#' l4h_install(method = "conda")
#' }
#' @export
l4h_install <- function(pip = TRUE, system = FALSE, force = FALSE, restart = TRUE, ...) {
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

  env_name <- args[["envname"]]
  env_method <- ifelse("method" %in% names(args), args[["method"]], "auto")

  # Optionally use system() pip call
  if (system && pip) {
    fp <- .find_python()
    if (nchar(fp) > 0) {
      tick("Using system pip")
      system(paste(
        shQuote(fp),
        "-m pip install --user",
        ifelse(force, "-U --force-reinstall", ""),
        "earthengine-api==0.1.370 numpy"
      ))
      cli::cli_alert_success("System install complete")
      return(invisible(NULL))
    } else {
      cli::cli_alert_warning("Python not found in system PATH")
      cli::cli_alert_info("Falling back to reticulate installation")
    }
  }

  # Handle method = "virtualenv" or "conda"
  if ("method" %in% names(args)) {
    if (args[["method"]] == "virtualenv") {
      if (!reticulate::virtualenv_exists(envname = env_name)) {
        tick("Creating virtualenv")
        reticulate::virtualenv_create(envname = env_name)
      } else {
        tick("Using existing virtualenv")
      }
    } else if (args[["method"]] == "conda") {
      cl <- try(reticulate::conda_list(), silent = TRUE)
      if (inherits(cl, 'data.frame') && !env_name %in% cl$name) {
        tick("Creating conda env")
        reticulate::conda_create(envname = env_name)
      } else {
        tick("Using existing conda env")
      }
    }
  }

  tick(sprintf("Installing packages in environment '%s' using method '%s'",
               env_name, env_method))

  install_success <- FALSE

  tryCatch({
    do.call(reticulate::py_install, c(list(
      c("numpy", "earthengine-api==0.1.370"),
      pip = pip,
      pip_ignore_installed = force
    ), args))

    cli::cli_alert_success("Installation finished successfully")
    install_success <- TRUE

  }, error = function(e) {
    cli::cli_alert_danger("Installation failed")
    cli::cli_bullets(c(
      "x" = "Error: {e$message}",
      "i" = "Try with {.code l4h_install(force = TRUE)}",
      "i" = "Or specify a method: {.code l4h_install(method = 'virtualenv')}"
    ))
  })

  # If installation was successful, setup environment loading and optionally restart
  if (install_success) {
    # Create startup script to automatically load environment
    .create_env_loader(env_name, env_method)

    if (restart) {
      cli::cli_h2("Next: Restarting R session")
      cli::cli_alert_info("Python environment will be configured automatically on restart")

      # Restart R if in RStudio
      if (rstudioapi::isAvailable()) {
        cli::cli_alert_info("Restarting R in 2 seconds...")
        Sys.sleep(2)
        rstudioapi::restartSession()
      } else {
        cli::cli_alert_warning("RStudio not detected")
        cli::cli_bullets(c(
          "i" = "Restart R manually",
          "i" = "Then run: {.code land4health::l4h_use_python('{env_name}')}"
        ))
      }
    } else {
      cli::cli_h2("Installation complete")
      cli::cli_bullets(c(
        "i" = "Restart R: {.kbd Ctrl+Shift+F10} (Windows/Linux) or {.kbd Cmd+Shift+0} (Mac)",
        "i" = "Or run: {.code .rs.restartR()}",
        "i" = "Python environment will be configured automatically"
      ))
    }
  }

  invisible(NULL)
}
