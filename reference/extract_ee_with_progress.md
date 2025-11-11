# Extract Earth Engine data with a progress bar

Extract Earth Engine data with a progress bar

## Usage

``` r
extract_ee_with_progress(
  image,
  sf_region,
  scale,
  fun,
  sf,
  quiet = FALSE,
  via = "getInfo",
  ...
)
```

## Arguments

- image:

  An Earth Engine Image object (from `rgee`).

- sf_region:

  An `sf` object containing regions to extract.

- scale:

  Numeric. Scale in meters for extraction.

- fun:

  A reducer function, e.g. `ee$Reducer$mean()`.

- sf:

  Logical. Should the function return an sf object?

- quiet:

  Logical. If TRUE, suppress the progress bar (default FALSE).

- via:

  Character. Either "getInfo" or "drive".

- ...:

  arguments of `ee_extract` of `rgee` packages.

## Value

An `sf` or `data.frame` object.
