# Install Python dependencies for land4health package

Installs required Python packages (`earthengine-api` and `numpy`) using
virtualenv, conda, or system pip via the `reticulate` package.

**\[experimental\]**

## Usage

``` r
l4h_install(pip = TRUE, system = FALSE, force = FALSE, ...)
```

## Arguments

- pip:

  Logical. If `TRUE` (default), uses pip for installation. Automatically
  set to `FALSE` if a method is specified via `...`.

- system:

  Logical. If `TRUE`, uses the system Python and pip via a system call.
  Defaults to `FALSE`.

- force:

  Logical. If `TRUE`, forces reinstallation of packages using
  `--force-reinstall`. Defaults to `FALSE`.

- ...:

  Additional arguments passed to
  [`py_install`](https://rstudio.github.io/reticulate/reference/py_install.html),
  such as:

  - `method`: Installation method ("auto", "virtualenv", "conda")

  - `envname`: Python environment name (default: "r-land4health")

## Value

Invisibly returns `NULL`. This function is called for its side effects.

## Credits

[![](figures/innovalab.svg)](https://www.innovalab.info/)

Pioneering geospatial health analytics and open‐science tools. Developed
by the Innovalab Team, for more information send a email to
<imt.innovlab@oficinas-upch.pe>

Follow us on :

- ![](figures/linkedin-innova.png)[Innovalab
  Linkedin](https://www.linkedin.com/company/innovalab-imt),
  ![](figures/twitter-innova.png)[Innovalab
  X](https://x.com/innovalab_imt)

- ![](figures/facebook-innova.png)[Innovalab
  facebook](https://www.facebook.com/imt.innovalab),
  ![](figures/instagram-innova.png)[Innovalab
  instagram](https://www.instagram.com/innovalab_imt/)

- ![](figures/tiktok-innova.png)[Innovalab
  tiktok](https://www.tiktok.com/@innovalab_imt),
  ![](figures/spotify-innova.png)[Innovalab
  Podcast](https://www.innovalab.info/podcast)

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic installation
l4h_install()

# Force reinstallation
l4h_install(force = TRUE)

# Use a conda environment
l4h_install(method = "conda")
} # }
```
