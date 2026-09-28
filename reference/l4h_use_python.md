# Configure Python environment for land4health

Sets up the Python environment automatically based on installation.

## Usage

``` r
l4h_use_python(envname = NULL, method = NULL, quiet = FALSE)
```

## Arguments

- envname:

  Character. Name of the Python environment. If NULL, uses saved config.

- method:

  Character. Method to use ("auto", "virtualenv", "conda"). If NULL,
  uses saved config.

- quiet:

  Logical. Suppress messages? Default FALSE.

## Value

Invisibly returns NULL

## Examples

``` r
# \donttest{
l4h_use_python()
#> 
#> ── Configuring Python environment ──
#> 
#> ✖ Environment 'r-land4health' not found
#> ℹ Run `l4h_install()` first
l4h_use_python("r-land4health", "virtualenv")
#> 
#> ── Configuring Python environment ──
#> 
#> ℹ Using virtualenv: r-land4health
#> ✖ Failed to configure Python environment
#> ℹ Error: Directory ~/.virtualenvs/r-land4health is not a Python virtualenv
# }
```
