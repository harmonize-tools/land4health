# Extract TerraClimate variables (monthly) from Google Earth Engine

Extracts one or more **TerraClimate** variables for a user-defined
region and time range from the Earth Engine dataset
**IDAHO_EPSCOR/TERRACLIMATE**. The function summarizes each monthly
image over the region using a chosen statistic (e.g., mean/median),
applies the appropriate **scale factors** to return values in native
units, and returns an `sf` or `tibble`.

**\[experimental\]**

## Usage

``` r
l4h_terra_climate(
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

  Character vector. One or more TerraClimate variables to extract.
  Supported codes: `"aet"`, `"def"`, `"pdsi"`, `"pet"`, `"pr"`, `"ro"`,
  `"soil"`, `"srad"`, `"swe"`, `"tmmn"`, `"tmmx"`, `"vap"`, `"vpd"`,
  `"vs"`. Scale factors and units (aplicadas automáticamente):

  - `aet` (mm, ×0.1), `def` (mm, ×0.1), `pdsi` (unitless, ×0.01),

  - `pet` (mm, ×0.1), `pr` (mm, ×1), `ro` (mm, ×1), `soil` (mm, ×0.1),

  - `srad` (W/m², ×0.1), `swe` (mm, ×1),

  - `tmmn` (°C, ×0.1), `tmmx` (°C, ×0.1),

  - `vap` (kPa, ×0.001), `vpd` (kPa, ×0.01), `vs` (m/s, ×0.01).

- region:

  Spatial object defining the region of interest. Accepts an `sf`,
  `sfc`, or `SpatVector` object.

- scale:

  Numeric. Reducer scale in meters. Default `1000`. (TerraClimate pixel
  ≈ **4638 m**; usar ~4500–5000 m suele ser adecuado.)

- stat:

  Character. Summary statistic per image per region. One of `"mean"`,
  `"median"`, `"min"`, `"max"`. Passed internally to the extractor.

- sf:

  Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`.
  Default `TRUE`.

- quiet:

  Logical. If `TRUE`, suppresses progress bars/messages. Default
  `FALSE`.

- force:

  Logical. If `TRUE`, fuerza la extracción aun si hay caché. Default
  `TRUE`.

- ...:

  Additional arguments passed to the extraction backend.

## Value

An `sf` or `tibble` with columns:

- `date` (Date, primer día del mes),

- `variable` (character, código TerraClimate),

- `value` (numérico, en unidades nativas ya escaladas), plus geometry if
  `sf = TRUE`, and any attributes from `region`.

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

Abatzoglou, J. T., Dobrowski, S. Z., Parks, S. A., & Hegewisch, K. C.
(2018). TerraClimate, a high-resolution global dataset of monthly
climate and climatic water balance from 1958–2015. *Scientific Data*, 5,
170191.
[doi:10.1038/sdata.2017.191](https://doi.org/10.1038/sdata.2017.191)

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

# Precipitación mensual (mm) 2020, promedio espacial
out_pr <- l4h_terra_climate(
  from = "2020-01-01",
  to   = "2020-12-31",
  band = "pr",
  region = region,
  stat = "mean",
  scale = 5000
)
head(out_pr)

# Múltiples variables: Tmax (°C) + VPD (kPa)
out_multi <- l4h_terra_climate(
  from = "2019-01-01",
  to   = "2019-12-31",
  band = c("tmmx","vpd"),
  region = region,
  stat = "median",
  scale = 5000
)
} # }
```
