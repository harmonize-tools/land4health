# Extracts global night‑time lights using harmonized DMSP‑OLS and VIIRS data

Retrieves annual night‑time light radiance (average radiance,
nanoWatt/sr/cm²) from the Harmonized Global Night Time Lights dataset
for a user-defined region and time range. The dataset harmonizes
DMSP-OLS (1992‑2013) with VIIRS‑like data (2014‑2021), ensuring
consistent long-term time series at ~1km resolution.

**NA**

## Usage

``` r
l4h_night_lights(
  from,
  to,
  region,
  stat = "mean",
  scale = 1000,
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- from:

  Character. Start date in `"YYYY-MM-DD"` format (only the year is
  used).

- to:

  Character. End date in `"YYYY-MM-DD"` format (only the year is used).

- region:

  A spatial object (`sf`, `sfc`, or `SpatVector`) defining the region of
  interest.

- stat:

  Character. Summary statistic to apply per year per region (e.g.
  `"mean"`, `"sum"`).

- scale:

  Numeric. Nominal scale in meters (default `1000`).

- sf:

  Logical. If `TRUE`, return as `sf`; if `FALSE`, return as `tibble`.
  Default `TRUE`.

- quiet:

  Logical. If `TRUE`, suppress progress messages. Default `FALSE`.

- force:

  Logical. If `TRUE`, skip representativity check. Default `FALSE`.

- ...:

  Additional arguments passed to
  [`rgee::ee_extract()`](https://r-spatial.github.io/rgee/reference/ee_extract.html).

## Value

A `sf` or `tibble` with annual night‑time light statistics per region
and date.

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

# Extract only DMSP-OLS data (1998–2010)
ntl_dmsp <- l4h_night_lights(
  from = "1998-01-01",
  to = "2010-12-31",
  region = region,
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
head(ntl_dmsp)
#> Error: object 'ntl_dmsp' not found

# Extract only VIIRS data (2016–2021)
ntl_viirs <- l4h_night_lights(
  from = "2016-01-01",
  to = "2021-12-31",
  region = region,
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
head(ntl_viirs)
#> Error: object 'ntl_viirs' not found

# Extract both DMSP and VIIRS (2008–2020)
ntl_mixed <- l4h_night_lights(
  from = "2008-01-01",
  to = "2020-12-31",
  region = region,
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
head(ntl_mixed)
#> Error: object 'ntl_mixed' not found
# }
```
