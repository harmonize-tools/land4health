# Compute Rural Access Index (RAI)

Calculates the Rural Access Index (RAI) for a given region using
datasets from the GEE Community Catalog. The RAI represents the
proportion of the rural population living within 2 km of an all-season
road, aligning with SDG indicator 9.1.1.

**NA**

## Usage

``` r
l4h_rural_access_index(
  region,
  weighted = FALSE,
  fun = NULL,
  sf = FALSE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- region:

  A spatial object defining the region of interest. Can be an `sf`,
  `sfc` object, or a `SpatVector` (from the terra package).

- weighted:

  Logical. If `TRUE`, computes a population-weighted RAI (i.e., rural
  population with access divided by total rural population). If `FALSE`,
  computes an area-based RAI (i.e., total pixel area with access divided
  by total rural area). Default is `FALSE`.

- fun:

  Character. Summary function to apply to the population raster when
  `weighted = TRUE`. Common values include `"mean"`, `"sum"`, etc.
  Ignored when `weighted = FALSE`. Default is `"mean"`.

- sf:

  Logical. If `TRUE`, returns the result as an `sf` object. If `FALSE`,
  returns an Earth Engine object. Default is `FALSE`.

- quiet:

  Logical. If TRUE, suppress the progress bar (default FALSE).

- force:

  Logical. If `TRUE`, skips the representativity check and forces the
  extraction. Default is `FALSE`.

- ...:

  arguments of `ee_extract` of `rgee` packages.

## Value

A spatial object containing the computed RAI value for the region in an
`sf` or `tibble` object.

## Details

This function uses the following datasets from the GEE Community
Catalog:

- `projects/sat-io/open-datasets/RAI/ruralpopaccess/` – raster of rural
  population with access to all-season roads

- `projects/sat-io/open-datasets/RAI/inaccessibilityindex/` – binary
  raster indicating access areas (1 = access, 0 = no access)

When `weighted = TRUE`, the RAI is calculated as the sum (or chosen
summary via `fun`) of the accessible rural population divided by the
total rural population within the specified region.

When `weighted = FALSE`, the RAI is calculated as the ratio of pixel
areas: the total area (in in km^2) with access divided by the total
rural area.

The `fun` parameter only applies when `weighted = TRUE`. It will be
ignored otherwise.

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

GEE Community Catalog: <https://gee-community-catalog.org/projects/rai/>

Frontiers in Remote Sensing (2024):
[doi:10.3389/frsen.2024.1375476](https://doi.org/10.3389/frsen.2024.1375476)

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

# Population-weighted RAI
rai_w <- l4h_rural_access_index(
    region = region,
    weighted = TRUE,
    fun = "sum",
    sf = TRUE)
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
head(rai_w)
#> Error: object 'rai_w' not found

# Area-based RAI
rai <- l4h_rural_access_index(
    region = region,
    weighted = FALSE,
    sf = TRUE)
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
head(rai)
#> Error: object 'rai' not found
# }
```
