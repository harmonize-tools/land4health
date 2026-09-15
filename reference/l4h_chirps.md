# Extract CHIRPS v3 precipitation data from Google Earth Engine

Extracts **CHIRPS v3** precipitation estimates for a user-defined region
and time range from the Earth Engine dataset
**UCSB-CHC/CHIRPS/V3/DAILY_SAT** (IMERG-based) or
**UCSB-CHC/CHIRPS/V3/DAILY_RNL** (ERA5-based). The function supports
daily, monthly, and annual temporal aggregation. Monthly and annual
values are computed as **sums** of daily precipitation (mm), which is
the standard in hydrology and vector-borne disease modelling.

CHIRPS v3 (Climate Hazards Center InfraRed Precipitation with Stations
version 3) is a quasi-global (60°S–60°N), high-resolution (0.05°)
gridded rainfall dataset from 1981 to near-present, combining satellite
thermal infrared estimates with in-situ station observations.

**NA**

## Usage

``` r
l4h_chirps(
  from,
  to,
  by = "month",
  product = "sat",
  region,
  scale = 5566,
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

  Character. Temporal aggregation frequency. Options:

  - `"daily"` — daily precipitation (mm/day),

  - `"month"` — monthly accumulated precipitation (mm/month),

  - `"annual"` — annual accumulated precipitation (mm/year). Default
    `"month"`.

- product:

  Character. CHIRPS v3 daily product used for disaggregation. Options:

  - `"sat"` — IMERG-based daily (0.1° resolution, available from 2001),

  - `"rnl"` — ERA5-based daily (0.25° resolution, available from 1981).
    Default `"sat"`.

- region:

  Spatial object defining the region of interest. Accepts an `sf`,
  `sfc`, or `SpatVector` object.

- scale:

  Numeric. Reducer scale in meters. Default `5566` (CHIRPS native pixel
  ~5,566 m).

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

- `variable` (character — `"precipitation"`),

- `value` (numeric — mm in the corresponding time unit), plus geometry
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
  instagram](https://www.instagram.com/innovalab_imt/)

- ![](figures/tiktok-innova.png)[Innovalab
  tiktok](https://www.tiktok.com/@innovalab_imt)

- ![](figures/spotify-innova.png)[Innovalab
  Podcast](https://www.innovalab.info/podcast)

## References

Funk, C., Peterson, P., Harrison, L. et al. (2026). The Climate Hazards
Center Infrared Precipitation with Stations, Version 3. *Scientific
Data*, 13, 718.
[doi:10.1038/s41597-026-07096-4](https://doi.org/10.1038/s41597-026-07096-4)

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

# 1. Monthly precipitation (mm/month) 2020, SAT product
out_monthly <- l4h_chirps(
  from    = "2020-01-01",
  to      = "2020-12-31",
  by      = "month",
  product = "sat",
  region  = region,
  stat    = "mean"
)
head(out_monthly)

# 2. Annual precipitation (mm/year) 2015-2020, RNL product
out_annual <- l4h_chirps(
  from    = "2015-01-01",
  to      = "2020-12-31",
  by      = "annual",
  product = "rnl",
  region  = region,
  stat    = "mean"
)
head(out_annual)

# 3. Daily precipitation (mm/day) for one month
out_daily <- l4h_chirps(
  from    = "2020-06-01",
  to      = "2020-06-30",
  by      = "daily",
  product = "sat",
  region  = region,
  stat    = "mean"
)
head(out_daily)
} # }
```
