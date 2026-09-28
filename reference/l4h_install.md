# Install Python dependencies for land4health package

Installs required Python packages (earthengine-api and numpy). By
default uses **uv** when available (much faster downloads with a live
progress bar in the console) and falls back to pip via
[`reticulate::py_install()`](https://rstudio.github.io/reticulate/reference/py_install.html)
otherwise.

**NA**

## Usage

``` r
l4h_install(
  pip = TRUE,
  system = FALSE,
  force = FALSE,
  restart = TRUE,
  backend = c("auto", "uv", "pip"),
  ...
)
```

## Arguments

- pip:

  Logical. If TRUE (default), uses pip for installation. Set to FALSE if
  specifying a different installation method.

- system:

  Logical. If TRUE, uses system pip directly via system() call.

- force:

  Logical. If TRUE, forces reinstallation/upgrade of packages.

- restart:

  Logical. If TRUE, automatically restarts R session after installation.
  Default TRUE.

- backend:

  Character. Installation backend: `"auto"` (default) uses `uv` when it
  is installed and falls back to `"pip"` otherwise; `"uv"` requires `uv`
  (see <https://docs.astral.sh/uv/>); `"pip"` always uses
  [`reticulate::py_install()`](https://rstudio.github.io/reticulate/reference/py_install.html).
  Note: `uv` manages `virtualenv` environments only — an explicit
  `method = "conda"` always uses the `"pip"` backend.

- ...:

  Additional arguments passed to reticulate::py_install(), such as:

  - method: Installation method ("auto", "virtualenv", "conda")

  - envname: Environment name (default: "r-land4health")

## Value

Invisibly returns NULL

## Examples

``` r
# Installation is intentionally not run in examples because it modifies
# the Python environment and may be slow.

# See the installation vignette for instructions:
vignette("land4health-setup", package = "land4health")
#> Warning: vignette ‘land4health-setup’ not found
```
