# Calculates the Surface Urban Heat Island (SUHI) index using MODIS LST and GHS-SMOD

Computes the SUHI (Surface Urban Heat Island) index as the difference
between the mean land surface temperature (LST) in urban and rural areas
for each date in a user-defined region and time range.

**\[experimental\]**

## Usage

``` r
l4h_urban_heat_index(
  from,
  to,
  region,
  band = "day",
  level = "strict",
  stat = "max",
  scale = 1000,
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- from:

  Character or Date. Start date (format: `"YYYY-MM-DD"`).

- to:

  Character or Date. End date (format: `"YYYY-MM-DD"`).

- region:

  Spatial object (`sf`, `sfc`, or `SpatVector`) defining the region.

- band:

  Character. `"day"` or `"night"` LST from MODIS. Default is `"day"`.

- level:

  Character. `"strict"` or `"moderate"` quality filter for MODIS.
  Default is `"strict"`.

- stat:

  Character. Aggregation statistic, e.g. `"mean"` or `"median"`. Default
  is `"mean"`.

- scale:

  Numeric. Resolution in meters. Default is `1000`.

- sf:

  Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`.
  Default is `TRUE`.

- quiet:

  Logical. If `TRUE`, suppress messages. Default is `FALSE`.

- force:

  Logical. If `TRUE`, skip representativity check. Default is `FALSE`.

- ...:

  Extra arguments passed to `ee_extract()`.

## Value

A `tibble` or `sf` object with columns: `date`, `variable = "SUHI"`, and
`value` (°C).

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
library(land4health)
ee_Initialize()

# Define a bounding box region (Ucayali, Peru)
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

# Calculate SUHI using daytime LST (mean temperature difference)
suhi_day <- l4h_urban_heat_index(
  from = "2020-01-01",
  to = "2020-12-31",
  region = region,
  band = "day",
  stat = "mean"
)
head(suhi_day)

# Calculate SUHI using nighttime LST (max difference)
suhi_night <- l4h_urban_heat_index(
  from = "2020-01-01",
  to = "2020-12-31",
  region = region,
  band = "night",
  stat = "max"
)
head(suhi_night)
} # }
```
