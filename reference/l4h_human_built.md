# Extracts built‑up surface area from GHSL Built‑Up Surface dataset

Retrieves total built‑up surface area (in m2 per 100m grid cell) from
the GHSL Built-Up Surface dataset (GHS‑BUILT‑S R2023A), over a
user-defined region and date range. The dataset is provided in 5‑year
epochs (1975–2030) at ~100m resolution.

**\[stable\]**

## Usage

``` r
l4h_human_built(
  from,
  to,
  region,
  scale = 100,
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- from:

  Character. Start date in "YYYY-MM-DD" format (only the year is used).

- to:

  Character. End date in "YYYY-MM-DD" format (only the year is used).

- region:

  Spatial object (`sf`, `sfc`, or `SpatVector`) defining the region.

- scale:

  Numeric. Resolution in meters (default = 100).

- sf:

  Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`.
  Default = `TRUE`.

- quiet:

  Logical. If `TRUE`, suppresses progress output. Default = `FALSE`.

- force:

  Logical. If `TRUE`, bypass representativity checks. Default = `FALSE`.

- ...:

  Arguments passed to
  [`rgee::ee_extract()`](https://r-spatial.github.io/rgee/reference/ee_extract.html).

## Value

A `sf` or `tibble` with columns `date`, `variable`, and
`built_surface_m2`.

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

- Pesaresi, M. & Politis, P. (2023). GHS‑BUILT‑S R2023A: Red de
  superficie construida de GHS, derivada de la composición de Sentinel-2
  y Landsat, multitemporal (1975–2030). European Commission, Joint
  Research Centre (JRC).
  [doi:10.2905/9F06F36F-4B11-47EC-ABB0-4F8B7B1D72EA](https://doi.org/10.2905/9F06F36F-4B11-47EC-ABB0-4F8B7B1D72EA)
  . PID:
  <http://data.europa.eu/89h/9f06f36f-4b11-47ec-abb0-4f8b7b1d72ea>

- Pesaresi, M., Schiavina, M., Politis, P., Freire, S., Krasnodebska,
  K., Uhl, J.H., Carioli, A., et al. (2024). Avances en la capa de
  asentamientos humanos globales a través de la evaluación conjunta de
  datos de observación de la Tierra y encuestas demográficas.
  *International Journal of Digital Earth*, 17(1).
  [doi:10.1080/17538947.2024.2390454](https://doi.org/10.1080/17538947.2024.2390454)

- Dataset on Google Earth Engine:
  <https://developers.google.com/earth-engine/datasets/catalog/JRC_GHSL_P2023A_GHS_BUILT_S>

## Examples

``` r
if (FALSE) { # \dontrun{
library(land4health)
library(sf)
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

# Extract built-up surface area from 2000 to 2020
built_area <- l4h_human_built(
  from = "2000-01-01",
  to = "2020-12-31",
  region = region,
  scale = 100,
  stat = "sum"
)
head(built_area)

# Example using as tibble
built_tbl <- l4h_human_built(
  from = "1990-01-01",
  to = "2015-12-31",
  region = region,
  sf = FALSE,
  stat = "mean"
)
dplyr::glimpse(built_tbl)
} # }
```
