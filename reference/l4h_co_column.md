# Extracts carbon monoxide (CO) concentration from Sentinel-5P TROPOMI

Retrieves the CO column number density (mol/m2) for a user-defined
region and date range from the Sentinel‑5P TROPOMI OFFLINE L3 CO
dataset.

**\[stable\]**

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

  Logical. Return result as `sf`? Default: `TRUE`.

- quiet:

  Logical. Suppress progress messages? Default: `FALSE`.

- force:

  Logical. Force extract without spatial check? Default: `FALSE`.

- ...:

  Arguments passed to
  [`rgee::ee_extract`](https://r-spatial.github.io/rgee/reference/ee_extract.html).

## Value

A `sf` or `tibble` containing CO column density (**mol/m2**) by date and
geometry.

## Details

The function uses the Earth Engine dataset `COPERNICUS/S5P/OFFL/L3_CO`
and selects only the `"CO_column_number_density"` band. It supports
summarization using a reducer statistic per image.

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

COPERNICUS/S5P/OFFL/L3_CO. Sentinel‑5P Offline L3 Carbon Monoxide.
European Union / ESA / Copernicus.
<https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S5P_OFFL_L3_CO>

## Examples
