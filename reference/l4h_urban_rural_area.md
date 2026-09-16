# Extracts surface areas by urban and rural categories from GHS-SMOD

Calculates the surface area (in km2) of urban, rural, or all settlement
classes every 5 years between 1985 and 2030 using the GHS-SMOD R2023A
dataset. This product applies the Degree of Urbanization methodology
(Stage I) to the GHS-POP R2023A and GHS-BUILT-S R2023A layers. The
function summarizes areas by category and year over the specified
region.

**\[questioning\]**

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

- European Commission, Joint Research Centre (JRC). GHS Settlement Grid
  R2023A (1975–2030). Available at:
  <https://data.jrc.ec.europa.eu/dataset/a0df7a6f-49de-46ea-9bde-563437a6e2ba#dataaccess>

## Examples

``` r
if (FALSE) { # \dontrun{
library(land4health)
ee_Initialize()

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
urban_area <- l4h_urban_area(
  category = "urban",
  region = region)

head(urban_area)

# Extract surface area of rural category (in km2)
rural_area <- l4h_urban_area(
  category = "rural",
  region = region)

head(rural_area)

# Extract total surface area (urban + rural) (in km2)
all_area <- l4h_urban_area(
  category = "all",
  region = region)

head(all_area)
} # }
```
