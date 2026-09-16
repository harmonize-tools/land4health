# Travel Time to Healthcare or Cities (Oxford Dataset)

Retrieves the travel time raster (in minutes) to the nearest healthcare
facility or populated city, based on the Oxford Global Map of
Accessibility datasets.

**\[stable\]**

## Usage

``` r
l4h_travel_time(
  region,
  destination = "cities",
  transport_mode = "all",
  fun = "mean",
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

- destination:

  Character. Target destination for travel time. Use `"healthcare"`
  (default) for travel time to the nearest healthcare facility, or
  `"cities"` for travel time to the nearest populated urban center.

- transport_mode:

  Character. Mode of transportation. Use `"all"` (default) for general
  travel time (mixed modes), or `"walking_only"` for walking-only
  accessibility (**only valid when `destination = "healthcare"`**).

- fun:

  Character. Summary function to apply. Values include `"mean"`,
  `"sum"`,`"median"` , etc. Default is `"mean"`.

- sf:

  Logical. If `TRUE`, returns the result as an `sf` object. If `FALSE`,
  returns an Earth Engine object. Default is `FALSE`.

- quiet:

  Logical. If TRUE, suppress the progress bar (default FALSE).

- force:

  Logical. If `TRUE`, skips the internal representativity check of the
  input region. Defaults to `FALSE`.

- ...:

  arguments of `ee_extract` of `rgee` packages.

## Value

A spatial object containing the computed RAI value for the region in an
`sf` or `tibble` object.

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

- Weiss, D.J. et al. (2018). *A global map of travel time to cities to
  assess inequalities in accessibility in 2015.* Nature, 553(7688),
  333–336. DOI: 10.1038/nature25181

- Weiss, D.J. et al. (2020). *Global maps of travel time to healthcare
  facilities.* Nature Medicine, 26, 1835–1838. DOI:
  10.1038/s41591-020-1059-1

## Examples

``` r
if (FALSE) { # \dontrun{
library(land4health)
library(sf)
ee_Initialize()

# Define a bounding-box region in Ucayali, Peru
region <- st_as_sf(
  st_sfc(
    st_polygon(list(matrix(
      c(
        -74.1, -4.4,
        -74.1, -3.7,
        -73.2, -3.7,
        -73.2, -4.4,
        -74.1, -4.4
      ), ncol = 2, byrow = TRUE
    )))
  ),
  crs = 4326
)

# Travel time to nearest healthcare facility (all modes)
result_hosp_all <- l4h_travel_time(region = region)
head(result_hosp_all)

# Travel time to nearest healthcare facility (walking only)
result_hosp_walk <- l4h_travel_time(
  region        = region,
  destination   = "healthcare",
  transport_mode = "walking_only")

head(result_hosp_walk)

# Mean travel time to nearest cities (mixed modes)
result_city_mean <- l4h_travel_time(
  region      = region,
  destination = "cities",
  fun         = "mean")

head(result_city_mean)

# Sum of travel time to nearest cities
result_city_sum <- l4h_travel_time(
  region      = region,
  destination = "cities",
  fun         = "sum")

head(result_city_sum)
} # }
```
