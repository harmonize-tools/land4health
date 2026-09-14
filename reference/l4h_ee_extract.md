# Internal Earth Engine data extraction (Optimized)

Transfers geometries to Earth Engine and extracts statistics using
direct invocations of the reduceRegions method to avoid earthengine-api
incompatibilities.

## Usage

``` r
l4h_ee_extract(
  image,
  sf_region,
  scale = NULL,
  fun = "mean",
  sf = TRUE,
  tile_scale = 1,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- image:

  An `ee$Image` or `ee$ImageCollection` object.

- sf_region:

  An `sf` or `sfc` object containing the regions of interest.

- scale:

  Spatial resolution in meters. If `NULL`, the native resolution is
  used.

- fun:

  Reducer name (`"mean"`, `"sum"`, etc.) or an `ee$Reducer` object.

- sf:

  Logical. If `TRUE`, returns an `sf` object; if `FALSE`, a `tibble`.

- tile_scale:

  Scale factor for internal EE subdivisions (1 to 16). Default is 1.

- quiet:

  Logical. If `TRUE`, suppresses the progress bar. Default is `FALSE`.

- force:

  Logical. If `FALSE`, evaluates representativeness before processing.

- ...:

  Additional arguments passed internally to
  [`rgee::sf_as_ee`](https://r-spatial.github.io/rgee/reference/sf_as_ee.html).

## Value

An `sf` or `tbl_df` (`data.frame`) object with the extracted data.
