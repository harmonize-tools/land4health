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
if (FALSE) { # \dontrun{
l4h_use_python()
l4h_use_python("r-land4health", "virtualenv")
} # }
```
