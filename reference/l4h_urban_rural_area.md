# Extracts surface areas by urban and rural categories from GHS-SMOD

Calculates the surface area (in km2) of urban, rural, or all settlement
classes every 5 years between 1985 and 2030 using the GHS-SMOD R2023A
dataset. This product applies the Degree of Urbanization methodology
(Stage I) to the GHS-POP R2023A and GHS-BUILT-S R2023A layers. The
function summarizes areas by category and year over the specified
region.

**NA**

## Usage

``` r
l4h_urban_rural_area(
  region,
  category = "all",
  scale = 1000,
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- region:

  An `sf` object defining the region of interest.

- category:

  Character. Settlement category to extract: `"urban"`, `"rural"`, or
  `"all"`.

- scale:

  Numeric. Spatial resolution (in meters) to use for area calculation
  (e.g., `30`).

- sf:

  Logical. If `TRUE`, returns an `sf` object. Default is `TRUE`.

- quiet:

  Logical. If `TRUE`, suppresses progress messages. Default is `FALSE`.

- force:

  Logical. If `TRUE`, forces the extraction request even if cached
  results exist.

- ...:

  Additional arguments passed to `ee_extract()` from the `rgee` package.

## Value

A `tibble` with estimated settlement area (in km2) by year and category.

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

- European Commission, Joint Research Centre (JRC). GHS Settlement Grid
  R2023A (1975–2030). Available at:
  <https://data.jrc.ec.europa.eu/dataset/a0df7a6f-49de-46ea-9bde-563437a6e2ba#dataaccess>

## Examples

``` r
# \donttest{
library(land4health)
ee_Initialize()
#> Error in ee_connect_to_py(path = ee_current_version, n = 5): The current Python PATH: /home/runner/.cache/R/reticulate/uv/cache/archive-v0/PrMPWDK85JlNDOVs/bin/python
#> does not have the Python package "earthengine-api" installed. Do you restarted/terminated
#> your R session after install miniconda or run ee_install()?
#> If this is not the case, try:
#> > ee_install_upgrade(): Install the latest Earth Engine Python version.
#> > reticulate::use_python(): Refresh your R session and manually set the Python environment with all rgee dependencies.
#> > ee_install(): To create and set a Python environment with all rgee dependencies.
#> > ee_install_set_pyenv(): To set a specific Python environment.

# Define region as a bounding box (Ucayali, Peru)
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

# Extract surface area of urban category (in km2)
urban_area <- l4h_urban_rural_area(
  category = "urban",
  region = region)
#> Error in check_ee_initialized(): ✖ Earth Engine is not initialized.
#> ℹ Run `rgee::ee_Initialize()` before using GEE functions.

head(urban_area)
#> Error: object 'urban_area' not found

# Extract surface area of rural category (in km2)
rural_area <- l4h_urban_rural_area(
  category = "rural",
  region = region)
#> Error in check_ee_initialized(): ✖ Earth Engine is not initialized.
#> ℹ Run `rgee::ee_Initialize()` before using GEE functions.

head(rural_area)
#> Error: object 'rural_area' not found

# Extract total surface area (urban + rural) (in km2)
all_area <- l4h_urban_rural_area(
  category = "all",
  region = region)
#> Error in check_ee_initialized(): ✖ Earth Engine is not initialized.
#> ℹ Run `rgee::ee_Initialize()` before using GEE functions.

head(all_area)
#> Error: object 'all_area' not found
# }
```
