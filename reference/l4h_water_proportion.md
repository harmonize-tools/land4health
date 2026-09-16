# Annual Proportion of Water Coverage from MapBiomas Peru

The function returns the proportion of each region's area that is
covered by surface water for each year. The values are expressed as a
decimal ratio between 0 and 1 (e.g., 0.25 means 25\\

**\[experimental\]**

## Usage

``` r
l4h_water_proportion(
  from,
  to,
  region,
  fun = "mean",
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- from:

  Integer. Start year (e.g., 1985).

- to:

  Integer. End year (e.g., 2022). Must be equal to or greater than
  `from`.

- region:

  A spatial object defining the region of interest. Can be an `sf`,
  `sfc` object, or a `SpatVector` (from the terra package).

- fun:

  Character. Summary function to apply. Values include `"mean"`,
  `"sum"`,`"median"` , etc. Default is `"mean"`.

- sf:

  Logical. Return result as an `sf` object? Default is `TRUE`.

- quiet:

  Logical. If TRUE, suppress the progress bar (default FALSE). If
  `FALSE`, returns the Earth Engine `ImageCollection`.

- force:

  Logical. If `TRUE`, skips internal representativity checks on the
  input geometry. Defaults to `FALSE`.

- ...:

  arguments of `ee_extract` of `rgee` packages.

## Value

An object containing annual water coverage. Depending on `sf`, it may be
an `sf` object, a list, or an Earth Engine `ImageCollection` with yearly
layers.

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

- MapBiomas Peru (2021). *Collection 1 – Annual water coverage*.
  Mapbiomas project, available on:
  <https://peru.mapbiomas.org/colecciones-de-mapbiomas-peru/>

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

# Extract water coverage between 2000 and 2020
l4h_water_proportion(
  from = 2000,
  to = 2020,
  region = region)
} # }
```
