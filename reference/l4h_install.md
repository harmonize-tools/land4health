# Install Python dependencies for land4health package

Installs required Python packages (earthengine-api and numpy) using
various methods.

**\[experimental\]**

## Usage

``` r
l4h_install(pip = TRUE, system = FALSE, force = FALSE, restart = TRUE, ...)
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

- ...:

  Additional arguments passed to reticulate::py_install(), such as:

  - method: Installation method ("auto", "virtualenv", "conda")

  - envname: Environment name (default: "r-land4health")

## Value

Invisibly returns NULL

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic installation with auto-restart
l4h_install()

# Force reinstallation without restart
l4h_install(force = TRUE, restart = FALSE)

# Use conda environment
l4h_install(method = "conda")
} # }
```
