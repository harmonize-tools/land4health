
<!-- README.md is generated from README.Rmd. Please edit that file -->

# land4health: Remote Sensing Metrics for Spatial Health Analysis <img src="man/figures/logo.png" align="right" hspace="10" vspace="0" width="15%">

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/harmonize-tools/land4health/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/harmonize-tools/land4health/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Calculate and extract remote sensing metrics for spatial health analysis
🛰️. This package offers R users a quick and easy way to obtain areal or
zonal statistics of key indicators and covariates, ideal for modeling
infectious diseases 🦠 within the framework of spatial epidemiology 🏥.

## Installation

You can install the development version of land4health from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("harmonize-tools/land4health")
```

``` r
library(land4health)
ee_Initialize(quiet = TRUE)
```

``` r
── Welcome to land4health ──────────────────────────────────────────────────────────────────
A tool of Harmonize Project to calculate and extract Remote Sensing Metrics for Spatial
Health Analysis.
Currently,`land4health` supports metrics related to the following categories:
• Enviroment
• Human intervention
• and more!
For more information about metrics, please use the `get_metrics_metadata()` function.

── Attaching core land4health packages ─────────────────────────────────────────────────────
→ rgee v1.1.7
→ sf v1.0.20
```

## List available metrics and metadata

``` r
get_metrics_metadata()
#> # A tibble: 7 × 11
#>   category           metric   pixel_resolution_met…¹ dataset start_year end_year
#>   <chr>              <chr>                     <int> <chr>        <int>    <int>
#> 1 Human intervention Defores…                     30 Hansen…       2000     2023
#> 2 Human intervention Human M…                    300 Global…       1990     2017
#> 3 Human intervention Populat…                    100 WorldP…       2000     2021
#> 4 Human intervention Urban a…                    500 MODIS …       2001     2022
#> 5 Human intervention Night t…                    500 VIIRS …       1992     2023
#> 6 Human intervention Human S…                     30 Global…       1975     2030
#> 7 Enviroment         Urban H…                   1000 Urban …       2003     2020
#> # ℹ abbreviated name: ¹​pixel_resolution_meters
#> # ℹ 5 more variables: resolution_temporal <chr>, layer_can_be_actived <lgl>,
#> #   tags <chr>, lifecycle <chr>, url <chr>
```

## View summary of available indicators

``` r
get_metrics_summary()
#> # A tibble: 2 × 2
#>   category           metrics_counts
#>   <fct>                       <int>
#> 1 Enviroment                      1
#> 2 Human intervention              6
```

## Example: Calculate Forest Loss in a Custom Region

This example demonstrates how to calculate forest loss between 2005 and
2010 using a custom polygon and Earth Engine.

``` r
region <- st_as_sf(st_sfc(
  st_polygon(list(matrix(c(
    -74.1, -4.4,
    -74.1, -3.7,
    -73.2, -3.7,
    -73.2, -4.4,
    -74.1, -4.4
  ), ncol = 2, byrow = TRUE))),
  crs = 4326
))

# Run forest loss calculation
result <- calculate_forest_loss(from = 2005, to = 2010, region = region)
#> Registered S3 method overwritten by 'geojsonsf':
#>   method        from   
#>   print.geojson geojson
#> Number of features: Calculating ...Number of features: 1                     
#> Number of features: Calculating ...Number of features: 1
result
#> Simple feature collection with 6 features and 2 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -74.1 ymin: -4.4 xmax: -73.2 ymax: -3.7
#> Geodetic CRS:  WGS 84
#>   year loss_year_km2                              x
#> 1 2005      4.41e-05 POLYGON ((-74.1 -4.4, -74.1...
#> 2 2006      1.17e-05 POLYGON ((-74.1 -4.4, -74.1...
#> 3 2007      1.56e-05 POLYGON ((-74.1 -4.4, -74.1...
#> 4 2008      3.81e-05 POLYGON ((-74.1 -4.4, -74.1...
#> 5 2009      4.46e-05 POLYGON ((-74.1 -4.4, -74.1...
#> 6 2010      3.30e-05 POLYGON ((-74.1 -4.4, -74.1...
```
