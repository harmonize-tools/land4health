# Calculates the Surface Urban Heat Island (SUHI) index using MODIS LST and GHS-SMOD

Computes the SUHI (Surface Urban Heat Island) index as the difference
between the mean land surface temperature (LST) in urban and rural areas
for each date in a user-defined region and time range.

**NA**

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

[![](figures/innovalab.png)](https://www.innovalab.info/)

Pioneering geospatial health analytics and open-science tools. Developed
by the Innovalab Team. For more information, send an email to
<imt.innovlab@oficinas-upch.pe>.

Follow us on:

- ![](figures/linkedin-innova.png)[Innovalab
  Linkedin](https://www.linkedin.com/company/innovalab-imt)

- ![](figures/twitter-innova.png)[Innovalab
  X](https://x.com/innovalab_imt)

- ![](figures/facebook-innova.png)[Innovalab
  facebook](https://www.facebook.com/imt.innovalab)

- ![](figures/instagram-innova.png)[Innovalab
  instagram](https://www.instagram.com/innovalab_imt/)

- ![](figures/tiktok-innova.png)[Innovalab
  tiktok](https://www.tiktok.com/@innovalab_imt)

- ![](figures/spotify-innova.png)[Innovalab
  Podcast](https://www.innovalab.info/podcast)

## Examples

``` r
# \donttest{
library(land4health)
ee_Initialize()
#> Error in ee_connect_to_py(path = ee_current_version, n = 5): The current Python PATH: /home/runner/.cache/R/reticulate/uv/cache/archive-v0/PrMPWDK85JlNDOVs/bin/python
#> does not have the Python package "earthengine-api" installed. Do you restarted/terminated
#> your R session after install miniconda or run ee_install()?
#> If this is not the case, try:
#> > ee_install_upgrade(): Install the latest Earth Engine Python version.
#> > reticulate::use_python(): Refresh your R session and manually set the Python environment with all rgee dependencies.
#> > ee_install(): To create and set a Python environment with all rgee dependencies.
#> > ee_install_set_pyenv(): To set a specific Python environment.

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
#> Error in check_ee_initialized(): ✖ Earth Engine is not initialized.
#> ℹ Run `rgee::ee_Initialize()` before using GEE functions.
head(suhi_day)
#> Error: object 'suhi_day' not found

# Calculate SUHI using nighttime LST (max difference)
suhi_night <- l4h_urban_heat_index(
  from = "2020-01-01",
  to = "2020-12-31",
  region = region,
  band = "night",
  stat = "max"
)
#> Error in check_ee_initialized(): ✖ Earth Engine is not initialized.
#> ℹ Run `rgee::ee_Initialize()` before using GEE functions.
head(suhi_night)
#> Error: object 'suhi_night' not found
# }
```
