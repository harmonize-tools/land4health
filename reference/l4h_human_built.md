# Extracts built‑up surface area from GHSL Built‑Up Surface dataset

Retrieves total built‑up surface area (in m2 per 100m grid cell) from
the GHSL Built-Up Surface dataset (GHS‑BUILT‑S R2023A), over a
user-defined region and date range. The dataset is provided in 5‑year
epochs (1975–2030) at ~100m resolution.

**NA**

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

- Pesaresi, M. & Politis, P. (2023). GHS‑BUILT‑S R2023A: Red de
  superficie construida de GHS, derivada de la composición de Sentinel-2
  y Landsat, multitemporal (1975–2030). European Commission, Joint
  Research Centre (JRC).
  [doi:10.2905/9F06F36F-4B11-47EC-ABB0-4F8B7B1D72EA](https://doi.org/10.2905/9F06F36F-4B11-47EC-ABB0-4F8B7B1D72EA)
  .

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
# \donttest{
library(land4health)
ee_Initialize()
#> Error in ee_connect_to_py(path = ee_current_version, n = 5): The current Python PATH: /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2/bin/python
#> does not have the Python package "earthengine-api" installed. Do you restarted/terminated
#> your R session after install miniconda or run ee_install()?
#> If this is not the case, try:
#> > ee_install_upgrade(): Install the latest Earth Engine Python version.
#> > reticulate::use_python(): Refresh your R session and manually set the Python environment with all rgee dependencies.
#> > ee_install(): To create and set a Python environment with all rgee dependencies.
#> > ee_install_set_pyenv(): To set a specific Python environment.

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
#> Error: Python module ee was not found.
#> 
#> Detected Python configuration:
#> 
#> python:         /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2/bin/python
#> libpython:      /home/runner/.cache/R/reticulate/uv/python/cpython-3.12.14-linux-x86_64-gnu/lib/libpython3.12.so
#> pythonhome:     /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2:/home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2
#> virtualenv:     /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2/bin/activate_this.py
#> version:        3.12.14 (main, Sep 24 2026, 17:57:43) [Clang 22.1.3 ]
#> numpy:          /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2/lib/python3.12/site-packages/numpy
#> numpy_version:  2.5.3
#> ee:             [NOT FOUND]
#> 
#> NOTE: Python version was forced by py_require()
#> 
head(built_area)
#> Error: object 'built_area' not found

# Example using as tibble
built_tbl <- l4h_human_built(
  from = "1990-01-01",
  to = "2015-12-31",
  region = region,
  sf = FALSE,
  stat = "mean"
)
#> Error: Python module ee was not found.
#> 
#> Detected Python configuration:
#> 
#> python:         /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2/bin/python
#> libpython:      /home/runner/.cache/R/reticulate/uv/python/cpython-3.12.14-linux-x86_64-gnu/lib/libpython3.12.so
#> pythonhome:     /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2:/home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2
#> virtualenv:     /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2/bin/activate_this.py
#> version:        3.12.14 (main, Sep 24 2026, 17:57:43) [Clang 22.1.3 ]
#> numpy:          /home/runner/.cache/R/reticulate/uv/cache/archive-v0/EzqkS_u7yWiyKT-2/lib/python3.12/site-packages/numpy
#> numpy_version:  2.5.3
#> ee:             [NOT FOUND]
#> 
#> NOTE: Python version was forced by py_require()
#> 
dplyr::glimpse(built_tbl)
#> Error: object 'built_tbl' not found
# }
```
