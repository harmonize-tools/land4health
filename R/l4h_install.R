#' Install Python dependencies for land4health package
#'
#' @description Installs required Python packages (earthengine-api and numpy).
#' By default uses **uv** when available (much faster downloads with a live
#' progress bar in the console) and falls back to pip via
#' `reticulate::py_install()` otherwise.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param pip Logical. If TRUE (default), uses pip for installation. Set to FALSE if
#'   specifying a different installation method.
#' @param system Logical. If TRUE, uses system pip directly via system() call.
#' @param force Logical. If TRUE, forces reinstallation/upgrade of packages.
#' @param restart Logical. If TRUE, automatically restarts R session after installation. Default TRUE.
#' @param backend Character. Installation backend: `"auto"` (default) uses `uv`
#'   when it is installed and falls back to `"pip"` otherwise; `"uv"` requires
#'   `uv` (see <https://docs.astral.sh/uv/>); `"pip"` always uses
#'   `reticulate::py_install()`. Note: `uv` manages `virtualenv` environments
#'   only — an explicit `method = "conda"` always uses the `"pip"` backend.
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
#' # Basic installation with auto-restart (uv when available)
#' l4h_install()
#'
#' # Force reinstallation without restart
#' l4h_install(force = TRUE, restart = FALSE)
#'
#' # Force the uv backend (fails loudly if uv is missing)
#' l4h_install(backend = "uv")
#'
#' # Classic pip backend
#' l4h_install(backend = "pip")
#'
#' # Use conda environment
#' l4h_install(method = "conda")
#' }
#' @export
l4h_install <- function(pip = TRUE, system = FALSE, force = FALSE, restart = TRUE,
                        backend = c("auto", "uv", "pip"), ...) {
  backend <- match.arg(backend)
  args <- list(...)

  # Packages pinned by land4health
  pkgs <- c("numpy", "earthengine-api==0.1.370")

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

  cli::cli_h1("Installing Python dependencies for {.pkg land4health}")

  # 1. Backend resolution
  uv_path <- Sys.which("uv")
  use_uv <- FALSE
  if (backend == "uv") {
    if (!nzchar(uv_path)) {
      cli::cli_abort(c(
        "x" = "{.pkg uv} backend requested but {.code uv} was not found on PATH.",
        "i" = "Install it from {.url https://docs.astral.sh/uv/} or use {.code l4h_install(backend = 'pip')}."
      ))
    }
    use_uv <- TRUE
  } else if (backend == "auto") {
    if (!nzchar(uv_path)) {
      tick("`uv` not found on PATH, falling back to pip via {.pkg reticulate}")
    } else if ("method" %in% names(args) && identical(args[["method"]], "conda")) {
      tick("conda environment requested, {.pkg uv} only manages virtualenvs: using pip backend")
    } else {
      use_uv <- TRUE
    }
  }

  if (use_uv) {
    cli::cli_alert_success("Using {.pkg uv} backend (fast installs with live progress)")
  }

  install_success <- FALSE

  # 2. Fast path: uv
  if (use_uv) {
    install_success <- .l4h_install_uv(
      packages = pkgs,
      env_name = env_name,
      force = force
    )
  } else {
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
  }

  #3. Shared finalize: env loader + restart
  # If installation was successful, setup environment loading and optionally restart
  if (install_success) {
    # Create startup script to automatically load environment
    .create_env_loader(env_name, if (use_uv) "virtualenv" else env_method)

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

#' Install packages with uv into a reticulate virtualenv
#'
#' Creates (or reuses) a virtualenv under `reticulate::virtualenv_root()` and
#' installs `packages` with `uv pip`. Download progress streams live to the
#' console through `uv`'s own progress bar.
#'
#' @param packages Character vector of pip specifiers.
#' @param env_name Virtualenv name (e.g. `"r-land4health"`).
#' @param force Logical. If `TRUE`, wipe and recreate the environment.
#' @return `TRUE` invisibly on success, `FALSE` on failure.
#' @keywords internal
#' @noRd
.l4h_install_uv <- function(packages, env_name, force = FALSE) {
  uv <- Sys.which("uv")
  venv_path <- file.path(reticulate::virtualenv_root(), env_name)
  venv_python <- file.path(
    venv_path,
    if (.Platform$OS.type == "windows") "Scripts/python.exe" else "bin/python"
  )

  # 1. Virtualenv
  if (isTRUE(force) && dir.exists(venv_path)) {
    cli::cli_alert_info("Removing existing environment {.val {env_name}}")
    unlink(venv_path, recursive = TRUE)
  }

  if (!file.exists(venv_python)) {
    cli::cli_alert_info("Creating virtual environment {.val {env_name}}")
    st <- system2(uv, c("venv", venv_path), stdout = TRUE, stderr = TRUE)
    if (!is.null(attr(st, "status")) && attr(st, "status") != 0L) {
      cli::cli_alert_danger("Could not create the virtual environment")
      cli::cli_bullets(c("x" = paste(utils::tail(st, 5L), collapse = "\n")))
      return(invisible(FALSE))
    }
    cli::cli_alert_success("Virtual environment ready")
  } else {
    cli::cli_alert_info("Using existing virtual environment {.val {env_name}}")
  }

  # 2. Install (uv streams its own live download progress)
  cli::cli_h2("Downloading {.val {length(packages)}} packages with {.pkg uv}")
  uv_args <- c("pip", "install", "--python", venv_python, packages)
  if (isTRUE(force)) {
    uv_args <- c(uv_args, "--reinstall")
  }
  st <- system2(uv, uv_args, stdout = "", stderr = "")
  if (!identical(unclass(st), 0L)) {
    cli::cli_alert_danger("Installation failed")
    cli::cli_bullets(c(
      "i" = "Try with {.code l4h_install(force = TRUE, backend = 'uv')}",
      "i" = "Or fall back to pip: {.code l4h_install(backend = 'pip')}"
    ))
    return(invisible(FALSE))
  }

  # 3. Verify imports
  cli::cli_alert_info("Verifying imports")
  ver <- suppressWarnings(system2(
    venv_python,
    c("-c", "import numpy, ee; print(numpy.__version__)"),
    stdout = TRUE, stderr = TRUE
  ))
  if (!is.null(attr(ver, "status")) && attr(ver, "status") != 0L) {
    cli::cli_alert_danger("Verification failed: {.pkg numpy} or {.pkg earthengine-api} cannot be imported")
    cli::cli_bullets(c("x" = paste(utils::tail(ver, 5L), collapse = "\n")))
    return(invisible(FALSE))
  }

  cli::cli_alert_success("Installation finished successfully (numpy {ver[1]})")
  invisible(TRUE)
}

#' Locate a system Python interpreter
#'
#' @return Path to `python`/`python3`, or `""` when none is on `PATH`.
#' @keywords internal
#' @noRd
.find_python <- function() {
  for (candidate in c("python", "python3")) {
    fp <- Sys.which(candidate)
    if (nzchar(fp)) {
      return(unname(fp))
    }
  }
  ""
}
