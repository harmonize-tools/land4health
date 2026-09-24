# Extract ERA5-Land climate variables from Google Earth Engine

Extracts **ERA5-Land** climate variables for a user-defined region and
time range from the Earth Engine datasets **ECMWF/ERA5_LAND/DAILY_AGGR**
(`by = "daily"`) or **ECMWF/ERA5_LAND/MONTHLY_AGGR** (`by = "month"`).
Each image is summarized over the region using a chosen statistic (e.g.,
mean/median), values are converted to conventional units (degrees
Celsius, mm, volume fraction), and the function returns an `sf` or
`tibble`.

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
    Default `"month"`.

- band:

  Character vector. One or more ERA5-Land variables to extract.
  Supported codes:

  - `"t2m"` (2m air temperature, K -\> degrees C),

  - `"d2m"` (2m dewpoint temperature, K -\> degrees C),

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

- `variable` (character — band code, e.g. `"t2m"`),

- `value` (numeric — degrees C, mm, or volume fraction), plus geometry
  if `sf = TRUE`, and any attributes from `region`.

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

Munoz-Sabater, J., Dutra, E., Agusti-Panareda, A. et al. (2021).
ERA5-Land: a state-of-the-art global reanalysis dataset for land
applications. *Hydrology and Earth System Sciences*, 25, 4349-4383.
[doi:10.5194/hess-25-4349-2021](https://doi.org/10.5194/hess-25-4349-2021)

## Examples

``` r
if (FALSE) { # \dontrun{
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

# 2. Daily precipitation (mm) + soil moisture, one month
out_daily <- l4h_era5land(
  from   = "2020-06-01",
  to     = "2020-06-30",
  by     = "daily",
  band   = c("pr", "soil"),
  region = region,
  stat   = "mean"
)
head(out_daily)
} # }
```
