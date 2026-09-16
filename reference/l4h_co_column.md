# Extracts carbon monoxide (CO) concentration from Sentinel-5P TROPOMI

Retrieves the CO column number density (mol/m2) for a user-defined
region and date range from the Sentinel-5P TROPOMI OFFLINE L3 CO
dataset.

**NA**

## Usage

``` r
l4h_co_column(
  from,
  to,
  region,
  stat = "mean",
  scale = 1113,
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- from:

  Character. Start date in `"YYYY-MM-DD"` format (e.g., `"2020-01-01"`).

- to:

  Character. End date in `"YYYY-MM-DD"` format (e.g., `"2020-12-31"`).

- region:

  A spatial object (`sf`, `sfc`, or `SpatVector`) defining the region of
  interest.

- stat:

  Character. Summary statistic to apply (`"mean"`, `"median"`, `"max"`,
  etc.).

- scale:

  Numeric. Nominal scale in meters. Default is `1113`.

- sf:

  Logical. Return result as `sf`? Default is `TRUE`.

- quiet:

  Logical. Suppress progress messages? Default is `FALSE`.

- force:

  Logical. Force extract without spatial check? Default is `FALSE`.

- ...:

  Arguments passed to the extraction backend.

## Value

An `sf` or `tibble` containing CO column density (mol/m2) by date and
geometry.

## Details

The function uses the Earth Engine dataset `COPERNICUS/S5P/OFFL/L3_CO`
and selects only the `"CO_column_number_density"` band. Images are
composited to daily means before extraction to avoid exceeding the
5000-band limit on `toBands()`.

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

COPERNICUS/S5P/OFFL/L3_CO. Sentinel-5P Offline L3 Carbon Monoxide.
European Union / ESA / Copernicus.
<https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S5P_OFFL_L3_CO>

## Examples

``` r
if (FALSE) { # \dontrun{
library(land4health)
ee_Initialize()

# Define region as a bounding box polygon
region <- st_as_sf(st_sfc(
  st_polygon(list(matrix(c(
    -74.1, -4.4,
    -74.1, -3.7,
    -73.2, -3.7,
    -73.2, -4.4,
    -74.1, -4.4
  ), ncol = 2, byrow = TRUE))),
  crs = 4326)
)

# Run CO column calculation
co_data <- l4h_co_column(
  from = "2022-01-01",
  to = "2022-12-31",
  region = region,
  stat = "mean"
)
head(co_data)
} # }
```
