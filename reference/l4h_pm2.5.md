# Extract Global PM2.5 (monthly) from Google Earth Engine

Extracts monthly **PM2.5** concentrations for a user-defined region and
time range from the Earth Engine Community Catalog dataset **Global
PM2.5 (V6GL02 CNN)**. Each monthly image is summarized over the region
using a selected statistic (e.g., mean/median). The function returns
either an `sf` or a `tibble`, with dates normalized to the **first day
of each month**.

**\[experimental\]**

## Usage

``` r
l4h_pm2.5(
  from,
  to,
  band,
  region,
  scale = 1000,
  stat = "mean",
  sf = TRUE,
  quiet = FALSE,
  force = TRUE,
  ...
)
```

## Arguments

- from:

  Character or Date. Start date (`"YYYY-MM-DD"`).

- to:

  Character or Date. End date (`"YYYY-MM-DD"`).

- band:

  Character (kept for API symmetry). The dataset exposes a single band,
  currently `'b1'` (PM\\\_{2.5}\\ in µg/m\\^3\\). The function selects
  `'b1'` internally; this argument is ignored.

- region:

  Spatial object defining the region of interest. Accepts an `sf`,
  `sfc`, or `SpatVector` object.

- scale:

  Numeric. Reducer scale in meters. Default `1000`. (Use a value close
  to the dataset's native grid; typical choices are a few km.)

- stat:

  Character. Summary statistic per image per region. One of `"mean"`,
  `"median"`, `"min"`, `"max"`.

- sf:

  Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`.
  Default `TRUE`.

- quiet:

  Logical. If `TRUE`, suppresses progress bars/messages. Default
  `FALSE`.

- force:

  Logical. If `TRUE`, forces extraction even if cached results exist.
  Default `TRUE`.

- ...:

  Additional arguments passed to the extraction backend.

## Value

An `sf` or `tibble` with columns:

- `date` (`Date`) — first day of the month,

- `variable` (`character`) — fixed as `"pm2.5"`,

- `value` (`numeric`) — PM2.5 in **µg/m\\^3\\**, plus geometry if
  `sf = TRUE`, and any attributes from `region`.

## Details

This function queries the Global PM2.5 monthly product (V6GL02,
CNN‐based fusion) from the **GEE Community Catalog** and aggregates it
over the provided region and dates. The dataset provides monthly surface
PM2.5 concentrations (µg/m\\^3\\). Values are returned in native units
(no extra scale factor is applied here).

**Notes**

- Dates are validated (`YYYY-MM-DD`) and constrained to the dataset
  range used in this package (default: 2000–2019).

- Output dates are normalized to the first day of each month found in
  the bands.

- The function expects a reasonable `scale` relative to the dataset
  resolution to avoid oversampling or excessive smoothing.

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

GEE Community Catalog – Global PM2.5 (V6GL02 CNN).
<https://gee-community-catalog.org/projects/global_pm25/>

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)
library(land4health)
rgee::ee_Initialize()

# ROI simple (EPSG:4326)
region <- st_as_sf(st_sfc(
  st_polygon(list(matrix(c(
    -74.1, -4.4,
    -74.1, -3.7,
    -73.2, -3.7,
    -73.2, -4.4,
    -74.1, -4.4
  ), ncol = 2, byrow = TRUE))), crs = 4326))

# PM2.5 mensual (µg/m^3) para 2010, promedio espacial
out_pm <- l4h_pm2.5(
  from   = "2010-01-01",
  to     = "2010-12-31",
  band   = "b1",        # ignorado (única banda)
  region = region,
  stat   = "mean",
  scale  = 3000
)
head(out_pm)
} # }
```
