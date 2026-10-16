# Extract ERA5-Land climate variables from Google Earth Engine

Extracts **ERA5-Land** climate variables for a user-defined region and
time range from the Earth Engine datasets **ECMWF/ERA5_LAND/DAILY_AGGR**
(`by = "daily"`) or **ECMWF/ERA5_LAND/MONTHLY_AGGR** (`by = "month"`),
plus **ECMWF/ERA5_LAND/HOURLY** for the diurnal bands
`"rh_day"`/`"rh_night"`. Each image is summarized over the region using
a chosen statistic (e.g., mean/median), values are converted to
conventional units (degrees Celsius, mm, volume fraction), and the
function returns an `sf` or `tibble`.

ERA5-Land is the land-component replay of the ECMWF ERA5 climate
reanalysis (Copernicus Climate Data Store), with global coverage from
1950 to near-present at ~9 km (0.1 degrees) resolution. It complements
[`l4h_chirps()`](https://github.com/harmonize-tools/land4health/reference/l4h_chirps.md)
(finer precipitation) and
[`l4h_terra_climate()`](https://github.com/harmonize-tools/land4health/reference/l4h_terra_climate.md)
(finer monthly climatology) by providing **daily** exposure windows and
soil-moisture variables that are key for vector-borne disease modelling
(temperature/precipitation lags).

**NA**

## Usage

``` r
l4h_era5land(
  from,
  to,
  by = "month",
  band = "t2m",
  region,
  scale = 11132,
  stat = "mean",
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- from:

  Character or Date. Start date (`"YYYY-MM-DD"`).

- to:

  Character or Date. End date (`"YYYY-MM-DD"`).

- by:

  Character. Temporal resolution. Options:

  - `"daily"` — daily values from `ECMWF/ERA5_LAND/DAILY_AGGR`,

  - `"month"` — monthly values from `ECMWF/ERA5_LAND/MONTHLY_AGGR`.
    Default `"month"`. Diurnal bands (`"rh_day"`, `"rh_night"`) always
    use the hourly collection (see Details), aggregated to the same
    periods.

- band:

  Character vector. One or more ERA5-Land variables to extract.
  Supported codes:

  - `"t2m"` (2m air temperature, K -\> degrees C),

  - `"d2m"` (2m dewpoint temperature, K -\> degrees C),

  - `"rh"` (mean relative humidity, % — derived in Earth Engine from
    `temperature_2m` and `dewpoint_temperature_2m` via the Magnus
    formula, see Details),

  - `"rh_day"` (daytime relative humidity, % — mean over 06:00-18:00
    Peru time from `ECMWF/ERA5_LAND/HOURLY`, see Details),

  - `"rh_night"` (nighttime relative humidity, % — mean over 18:00-06:00
    Peru time from `ECMWF/ERA5_LAND/HOURLY`, see Details),

  - `"pr"` (total precipitation, m -\> mm),

  - `"soil"` (volumetric soil water layer 1, 0-7 cm, m3/m3),

  - `"pet"` (potential evaporation, m -\> mm). Default `"t2m"`.

- region:

  Spatial object defining the region of interest. Accepts an `sf`,
  `sfc`, or `SpatVector` object.

- scale:

  Numeric. Reducer scale in meters. Default `11132` (ERA5-Land native
  pixel ~11,132 m).

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

  Logical. If `TRUE`, skips the representativity check. Default `FALSE`.

- ...:

  Additional arguments passed to the extraction backend.

## Value

An `sf` or `tibble` with columns:

- `date` (Date — first day of the period),

- `variable` (character — band code, e.g. `"t2m"`, `"rh"`),

- `value` (numeric — degrees C, percent, mm, or volume fraction), plus
  geometry if `sf = TRUE`, and any attributes from `region`.

## Details

Relative humidity (`band = "rh"`) is derived server-side in Earth Engine
from the bands the function already uses (`temperature_2m` and
`dewpoint_temperature_2m`), following the Magnus formula for saturation
vapour pressure (Wright 1997 coefficients, same as the EU operational
product derived from ERA5-Land):

\$\$e(T) = 611.21 \times \exp\left(\frac{17.502 \times T}{240.97 +
T}\right)\$\$ \$\$RH = 100 \times \frac{e(Td)}{e(T)}\$\$

with `T` (air temperature) and `Td` (dewpoint) in degrees C, converted
from Kelvin inside Earth Engine (`- 273.15`). The ratio simplifies to
`100 * exp(b*c*(Td - T) / ((c + T) * (c + Td)))` with `b = 17.502` and
`c = 240.97`. Values are clamped to 0–100%.

Note the aggregation order: `DAILY_AGGR`/`MONTHLY_AGGR` already store
time-averaged `T`/`Td`, so `rh` is the humidity of the averaged
temperatures, not the average of instantaneous humidity. This is the
standard practice (same as the EU ERA5-Land product). Below 0 °C the
water-saturation form is kept (no ice correction), which is acceptable
for vector-borne disease modelling but documented here as a limitation.

Day and night are defined in Peru time (PET, UTC-5, no daylight saving):
day is 06:00-18:00 PET and night is 18:00-06:00 PET. Since
`ECMWF/ERA5_LAND/HOURLY` timestamps are UTC, `"rh_day"` averages the UTC
hours 11-22 and `"rh_night"` the UTC hours 23, 00-10. Each hourly image
is converted to RH with the same Magnus formula above and then averaged
(mean of hourly means with equal weights). Diurnal bands therefore
cannot be combined with `"rh"` or native bands in one call: they come
from different collections with different time bases.

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
  instagram](https://www.instagram.com/innovalab_imt)

- ![](figures/tiktok-innova.png)[Innovalab
  tiktok](https://www.tiktok.com/@innovalab_imt)

- ![](figures/spotify-innova.png)[Innovalab
  Podcast](https://www.innovalab.info/podcast)

## References

Muñoz Sabater, J. (2019): ERA5-Land monthly averaged data from 1950 to
present. Copernicus Climate Change Service (C3S) Climate Data Store
(CDS).
[doi:10.24381/cds.68d2bb30](https://doi.org/10.24381/cds.68d2bb30)

Bolton, D. (1980). The computation of equivalent potential temperature.
*Monthly Weather Review*, 108, 1046-1053.

Alduchov, O. A., & Eskridge, R. E. (1996). Improved Magnus form
approximation of saturation vapor pressure. *Journal of Applied
Meteorology*, 35, 601-609.

## Examples

``` r
# \donttest{
if (interactive()) {
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

# 1. Monthly 2m temperature (degrees C) 2020
out_monthly <- l4h_era5land(
  from   = "2020-01-01",
  to     = "2020-12-31",
  by     = "month",
  band   = "t2m",
  region = region,
  stat   = "mean"
)
head(out_monthly)

# 2. Daily relative humidity (%) + precipitation (mm), one month
out_daily <- l4h_era5land(
  from   = "2020-06-01",
  to     = "2020-06-30",
  by     = "daily",
  band   = c("rh", "pr"),
  region = region,
  stat   = "mean"
)
head(out_daily)

# 3. Daytime vs nighttime relative humidity (%), one week (Peru time)
out_diurnal <- l4h_era5land(
  from   = "2020-06-01",
  to     = "2020-06-07",
  by     = "daily",
  band   = c("rh_day", "rh_night"),
  region = region,
  stat   = "mean"
)
head(out_diurnal)
}
# }
```
