# Extracts Land Surface Temperature (LST) from MODIS MOD11A1

Extracts daytime or nighttime Land Surface Temperature (LST) for a
user-defined region and time range using the MODIS MOD11A1.061 product.
The function supports summarizing the temperature data over each date
using a selected statistic (e.g., mean or median).

**\[stable\]**

## Usage

``` r
l4h_surface_temp(
  from,
  to,
  region,
  band = "day",
  level = "strict",
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

  Character or Date. Start date of the analysis (e.g., `"2020-01-01"`).

- to:

  Character or Date. End date of the analysis (e.g., `"2020-12-31"`).

- region:

  A spatial object defining the region of interest. Accepts an `sf`,
  `sfc`, or `SpatVector` object.

- band:

  Character. LST type to extract: `"day"` (LST_Day_1km) or `"night"`
  (LST_Night_1km). Default is `"day"`.

- level:

  Character. Quality filter level to apply to MODIS LST pixels. Use
  `"strict"` to retain only high-quality observations (QA bits 0–1 equal
  to `00`), or `"moderate"` to allow both high and acceptable quality
  (QA bits 0–1 equal to `00` or `01`). Default is `"moderate"`.

- scale:

  Numeric. Spatial resolution in meters. Default is `1000` (native
  resolution).

- stat:

  Character. Summary statistic to apply per image per region. One of
  `"mean"`, `"median"`, `"min"`, `"max"`. Passed to `ee_extract()`.

- sf:

  Logical. If `TRUE`, returns an `sf` object; if `FALSE`, returns a
  `tibble`. Default is `TRUE`.

- quiet:

  Logical. If `TRUE`, suppresses progress bars and messages. Default is
  `FALSE`.

- force:

  Logical. If `TRUE`, forces the extraction even if results are cached.
  Default is `FALSE`.

- ...:

  Additional arguments passed to
  [`rgee::ee_extract()`](https://r-spatial.github.io/rgee/reference/ee_extract.html).

## Value

A `sf` or `tibble` object with LST values (in degrees Celsius) extracted
from MODIS MOD11A1.

## Details

The MODIS MOD11A1.061 product provides daily Land Surface Temperature
and quality information. This function filters out low-quality or
cloud-contaminated pixels based on the `QC_Day` or `QC_Night` band. Only
pixels where the quality control bits 0–1 equal `00` (high quality) are
retained.

LST values are originally stored as Kelvin multiplied by 0.02. This
function automatically converts them to degrees Celsius using the
formula: `LST = (value × 0.02) - 273.15`.

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

Wan, Z., Hook, S., & Hulley, G. (2015). MOD11A1 MODIS/Terra Land Surface
Temperature and Emissivity Daily L3 Global 1km SIN Grid V006 (Version
6.1). NASA EOSDIS Land Processes DAAC.
<https://doi.org/10.5067/MODIS/MOD11A1.061>

MODIS MOD11A1.061 - Google Earth Engine Dataset Catalog.
<https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD11A1>

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

# Extract daytime LST for 2020
lst_day <- l4h_surface_temp(
  from = "2020-01-01",
  to = "2020-12-31",
  region = region,
  band = "day",
  stat = "mean")

head(lst_day)

# Extract nighttime LST
lst_night <- l4h_surface_temp(
 from = "2020-01-01",
 to = "2020-12-31",
 region = region,
 band = "night",
 stat = "mean")

head(lst_night)
} # }
```
