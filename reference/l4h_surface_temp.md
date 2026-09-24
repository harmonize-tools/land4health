# Extracts Land Surface Temperature (LST) from MODIS MOD11A1

Extracts daytime or nighttime Land Surface Temperature (LST) for a
user-defined region and time range using the MODIS MOD11A1.061 product.
The function supports summarizing the temperature data over each date
(or each month) using a selected statistic (e.g., mean or median).

**NA**

## Usage

``` r
l4h_surface_temp(
  from,
  to,
  region,
  band = "day",
  level = "strict",
  by = "day",
  scale = 1000,
  stat = "mean",
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
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
  `"strict"` to retain only high-quality observations (QA bits 0-1 equal
  to `00`), or `"moderate"` to allow both high and acceptable quality
  (QA bits 0-1 equal to `00` or `01`). Default is `"moderate"`.

- by:

  Character. Temporal resolution of the output. One of `"day"` (default,
  one value per available daily image) or `"month"`. When `"month"`,
  cloud-masked daily images within each calendar month are combined
  server-side with the reducer selected in `stat` (mean, median, min or
  max) *before* the spatial extraction, so masked (cloudy) pixels do not
  count as zeros or missing days — they are simply excluded from that
  month's reducer.

- scale:

  Numeric. Spatial resolution in meters. Default is `1000` (native
  resolution).

- stat:

  Character. Summary statistic to apply. One of `"mean"`, `"median"`,
  `"min"`, `"max"`. Used as the spatial reducer passed to `ee_extract()`
  for every `by` value, and additionally as the temporal reducer across
  days within a month when `by = "month"`.

- sf:

  Logical. If `TRUE`, returns an `sf` object; if `FALSE`, returns a
  `tibble`. Default is `TRUE`.

- quiet:

  Logical. If `TRUE`, suppresses progress bars and messages. Default is
  `FALSE`.

- force:

  Logical. If `TRUE`, skips the representativity check (polygons smaller
  than 1 pixel are still extracted, only a warning is issued). Default
  is `FALSE`.

- ...:

  Additional arguments passed to
  [`rgee::ee_extract()`](https://r-spatial.github.io/rgee/reference/ee_extract.html).

## Value

A `sf` or `tibble` object with LST values (in degrees Celsius) extracted
from MODIS MOD11A1, at daily or monthly resolution depending on `by`.

## Details

The MODIS MOD11A1.061 product provides daily Land Surface Temperature
and quality information. This function filters out low-quality or
cloud-contaminated pixels based on the `QC_Day` or `QC_Night` band.

When `by = "month"`, for each calendar month in `[from, to]` the
function:

1.  Filters the daily collection to that month.

2.  Applies the same quality mask used for daily extraction to every
    image.

3.  Reduces the masked images to a single monthly image using the
    reducer implied by `stat`.

Because masking happens before reducing, a cloudy day never drags the
monthly value down or up — it simply does not contribute a pixel to that
month's calculation.

LST values are originally stored as Kelvin multiplied by 0.02. This
function automatically converts them to degrees Celsius using the
formula: `LST = (value x 0.02) - 273.15`.

## Credits

[![](figures/innovalab.png)](https://www.innovalab.info/)

Pioneering geospatial health analytics and open-science tools. Developed
by the Innovalab Team. For more information, send an email to
<imt.innovlab@oficinas-upch.pe>.

## References

Wan, Z., Hook, S., & Hulley, G. (2015). MOD11A1 MODIS/Terra Land Surface
Temperature and Emissivity Daily L3 Global 1km SIN Grid V006 (Version
6.1). NASA EOSDIS Land Processes DAAC.
[doi:10.5067/MODIS/MOD11A1.061](https://doi.org/10.5067/MODIS/MOD11A1.061)

MODIS MOD11A1.061 - Google Earth Engine Dataset Catalog.
<https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD11A1>

## Examples

``` r
if (FALSE) { # \dontrun{
library(land4health)
ee_Initialize()

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

# Daily (unchanged default behaviour)
lst_day <- l4h_surface_temp(
  from = "2020-01-01", to = "2020-12-31",
  region = region, band = "day", stat = "mean")

# Monthly
lst_month <- l4h_surface_temp(
  from = "2020-01-01", to = "2020-12-31",
  region = region, band = "day", stat = "mean", by = "month")

head(lst_month)
} # }
```
