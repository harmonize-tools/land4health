# Download and process evapotranspiration data

This function accesses the `geeSEBAL-MODIS` collection published by the
ET-Brasil project, extracts the `etp` band (daily evapotranspiration in
mm/day), and allows temporal aggregation by 8-day images or monthly or
yearly composites period. Optionally, results can be returned as
`sf`/`tibble` objects in R.

**\[stable\]**

## Usage

``` r
l4h_sebal_modis(
  from,
  to,
  by = "8 days",
  region,
  fun = "mean",
  sf = TRUE,
  force = FALSE,
  quiet = FALSE,
  ...
)
```

## Arguments

- from:

  Start date in `"YYYY-MM-DD"` format.

- to:

  End date in `"YYYY-MM-DD"` format.

- by:

  Temporal aggregation frequency. Options: `"8 days"` (original 8-day
  composites), `"month"` (monthly average or sum), or `"annual"` (annual
  avergae or sumperiod).

- region:

  A spatial object defining the region of interest. Accepts `sf`,
  `SpatVector`, or `ee$FeatureCollection` objects.

- fun:

  Aggregation function when `by = "month"` or `"total"`. Valid values
  are `"mean"` or `"sum"`.

- sf:

  Logical. Return result as an `sf` object? Default is `TRUE`.

- force:

  Logical. If `TRUE`, forces download even if a local file already
  exists.

- quiet:

  Logical. If TRUE, suppress the progress bar (default FALSE).

- ...:

  arguments of `ee_extract` of `rgee` packages.

## Value

A `sf` or `tibble` object with etp values.

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

## References

- Comini,B., Ruhoff,A., Laipelt,L., Fleischmann,A., Huntington,J.,
  Morton,C., Melton,F., Erickson,T., Roberti,D., Souza,V., Biudes,M.,
  Machado,N., Santos,C. & Cosio,E. (2023). *geeSEBAL‑MODIS:
  Continental‑scale evapotranspiration based on the surface energy
  balance for South America.* Preprint. DOI: 10.13140/RG.2.2.17579.11041

- geeSEBAL‑MODIS v0‑02 dataset. Licensed under the *Creative Commons
  Attribution 4.0 International (CC‑BY‑4.0)* license.

## Examples

``` r
if (FALSE) { # \dontrun{

library(land4health)
ee_Initialize()

# Define a bounding box region in Ucayali, Peru
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

# 1. Eight-day composites (8 days)
# 2020-01-01 → 2020-12-31, reducer = "mean"
sebal_8d <- l4h_sebal_modis(
  from   = "2020-01-01",
  to     = "2020-12-31",
  region = region
)

# 2. Monthly means
# Same period, but aggregated to calendar months
sebal_month <- l4h_sebal_modis(
  from   = "2020-01-01",
  to     = "2020-12-31",
  by     = "month",
  region = region
)

# 3. Annual evapotranspiration
# 2015 → 2023, one value per year
sebal_annual <- l4h_sebal_modis(
  from   = 2015,
  to     = 2023,
  by     = "annual",
  fun    = "sum",
  region = region,
  sf     = FALSE
)

} # }
```
