# Evaluates whether a given polygon covers a minimum number of valid pixels in a specified Earth Engine image.

Evaluates whether a given polygon covers a minimum number of valid
pixels in a specified Earth Engine image.

## Usage

``` r
check_representativity(region, scale = 30)
```

## Arguments

- region:

  An `sf` polygon object representing the area of interest.

- scale:

  Numeric. Pixel resolution in meters (e.g., 30 for Hansen).

## Value

Invisible `TRUE` if all polygons cover at least 1 pixel; otherwise
invisible `FALSE` with a `cli` warning reporting how many polygons fall
below 1 pixel. Extraction is never stopped; use `force = TRUE` in the
calling `l4h_*` function to skip this check entirely.
