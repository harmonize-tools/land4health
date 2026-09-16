# Extracts forest cover loss within a defined polygon

Calculates forest loss within a user-defined region for a specified year
range. Forest loss is defined as a **stand-replacement disturbance**, or
a change from forest to non-forest state.

**\[stable\]**

## Usage

``` r
l4h_forest_loss(from, to, region, sf = TRUE, quiet = FALSE, force = FALSE, ...)
```

## Arguments

- from:

  Character. Start date in `"YYYY-MM-DD"` format (only the year is
  used).

- to:

  Character. End date in `"YYYY-MM-DD"` format (only the year is used).

- region:

  A spatial object defining the region of interest. Accepts an `sf`,
  `sfc`, or `SpatVector` object (from the terra package).

- sf:

  Logical. Return result as an `sf` object? Default is `TRUE`.

- quiet:

  Logical. If `TRUE`, suppress the progress bar (default `FALSE`).

- force:

  Logical. Force request extract.

- ...:

  arguments of `ee_extract` of `rgee` packages.

## Value

A `sf` or `tibble` object with **forest loss per year in square
kilometers**.

## Details

Forest loss is derived from the Hansen Global Forest Change dataset. The
`lossyear` band encodes the year of forest cover loss as follows:

- Values range from **1** to **n**, where 1 corresponds to the year
  **2001** and n to the year **2000 + n**.

- A value of **0** indicates **no forest loss** detected.

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

Hansen, M. C., Potapov, P. V., Moore, R., Hancher, M., Turubanova, S.
A., Tyukavina, A., ... & Townshend, J. R. G. (2013). *High-Resolution
Global Maps of 21st-Century Forest Cover Change*. Science, 342(6160),
850–853. DOI:
[doi:10.1126/science.1244693](https://doi.org/10.1126/science.1244693)

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
  crs = 4326
))

# Run forest loss calculation
result <- l4h_forest_loss(
  from = '2005-01-01',
  to = '2007-01-01',
  region = region)

head(result)
} # }
```
