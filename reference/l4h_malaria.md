# Extract malaria metrics from the Malaria Atlas Project GeoServer

Downloads modeled malaria raster surfaces from the **Malaria Atlas
Project** (MAP) GeoServer via WCS 2.0.1, extracts zonal statistics for a
user-defined region and time range, and returns an `sf` or `tibble`.

Available species: *Plasmodium falciparum* (`"pf"`) and *Plasmodium
vivax* (`"pv"`). Available measures: `"incidence_rate"`,
`"incidence_count"`, `"parasite_rate"`, `"mortality_rate"`,
`"mortality_count"`. The function automatically selects the **latest
release** available on the server for the requested species + measure
combination.

**NA**

## Usage

``` r
l4h_malaria(
  from,
  to,
  species = "pf",
  measure = "incidence_rate",
  region,
  stat = "mean",
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- from:

  Integer. Start year.

- to:

  Integer. End year. Must be \>= `from`.

- species:

  Character. One of `"pf"` (Plasmodium falciparum) or `"pv"` (Plasmodium
  vivax). Default `"pf"`.

- measure:

  Character. One of `"incidence_rate"`, `"incidence_count"`,
  `"parasite_rate"`, `"mortality_rate"`, `"mortality_count"`. Default
  `"incidence_rate"`.

- region:

  Spatial object defining the region of interest. Accepts an `sf`,
  `sfc`, or `SpatVector` object.

- stat:

  Character. Summary statistic per pixel per year. One of `"mean"`,
  `"median"`, `"min"`, `"max"`. Default `"mean"`.

- sf:

  Logical. If `TRUE`, returns an `sf`; if `FALSE`, returns a `tibble`.
  Default `TRUE`.

- quiet:

  Logical. If `TRUE`, suppresses progress messages. Default `FALSE`.

- force:

  Logical. If `TRUE`, skips the representativity check. Default `FALSE`.

- ...:

  Additional arguments (currently unused).

## Value

An `sf` or `tibble` with columns:

- `date` (`Date`, first day of year),

- `species` (`character`, `"pf"` or `"pv"`),

- `measure` (`character`, the requested measure),

- `value` (`numeric`, in native units), plus geometry if `sf = TRUE`,
  and any attributes from `region`.

## Details

The MAP GeoServer provides modeled global raster surfaces at ~5 km
resolution. Rates are expressed per person (0-1 scale for parasite rate,
per 1,000 for incidence), and counts are absolute numbers. The function
connects to the GeoServer via
[`ows4R::WCSClient`](https://eblondel.github.io/ows4R/reference/WCSClient.html),
downloads the coverage clipped to the region bounding box, and uses
[`terra::extract()`](https://rspatial.github.io/terra/reference/extract.html)
for zonal statistics.

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

Malaria Atlas Project. <https://malariaatlas.org/>

## Examples

``` r
# \donttest{
library(land4health)

# ROI simple (EPSG:4326)
region <- st_as_sf(st_sfc(
  st_polygon(list(matrix(c(
    -74.1, -4.4,
    -74.1, -3.7,
    -73.2, -3.7,
    -73.2, -4.4,
    -74.1, -4.4
  ), ncol = 2, byrow = TRUE))), crs = 4326))

# Pf incidence rate 2015-2020
out <- l4h_malaria(
  from    = 2015,
  to      = 2020,
  species = "pf",
  measure = "incidence_rate",
  region  = region
)
#> ℹ Connecting to Malaria Atlas GeoServer...
#> ℹ Using release: 202608 - "Malaria__202608_Global_Pf_Incidence_Rate"
#> No encoding supplied: defaulting to UTF-8.
#> ℹ Extracting 6 year(s): 2015 to 2020
#> ℹ Downloading 2015 (1/6)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2016 [428ms]
#> 
#> ℹ Downloading 2016 (2/6)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2017 [1.2s]
#> 
#> ℹ Downloading 2017 (3/6)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2018 [853ms]
#> 
#> ℹ Downloading 2018 (4/6)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2019 [274ms]
#> 
#> ℹ Downloading 2019 (5/6)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2020 [844ms]
#> 
#> ℹ Downloading 2020 (6/6)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2020 [843ms]
#> 
head(out)
#> Simple feature collection with 6 features and 4 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -74.1 ymin: -4.4 xmax: -73.2 ymax: -3.7
#> Geodetic CRS:  WGS 84
#>         date species        measure      value                       geometry
#> 1 2015-01-01      pf incidence_rate 0.02168967 POLYGON ((-74.1 -4.4, -74.1...
#> 2 2016-01-01      pf incidence_rate 0.03309536 POLYGON ((-74.1 -4.4, -74.1...
#> 3 2017-01-01      pf incidence_rate 0.01907846 POLYGON ((-74.1 -4.4, -74.1...
#> 4 2018-01-01      pf incidence_rate 0.01128593 POLYGON ((-74.1 -4.4, -74.1...
#> 5 2019-01-01      pf incidence_rate 0.00713318 POLYGON ((-74.1 -4.4, -74.1...
#> 6 2020-01-01      pf incidence_rate 0.00632583 POLYGON ((-74.1 -4.4, -74.1...

# Pv parasite rate
out_pv <- l4h_malaria(
  from    = 2020,
  to      = 2022,
  species = "pv",
  measure = "parasite_rate",
  region  = region,
  sf      = FALSE
)
#> ℹ Connecting to Malaria Atlas GeoServer...
#> ℹ Using release: 202608 - "Malaria__202608_Global_Pv_Parasite_Rate"
#> No encoding supplied: defaulting to UTF-8.
#> ℹ Extracting 3 year(s): 2020 to 2022
#> ℹ Downloading 2020 (1/3)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2021 [268ms]
#> 
#> ℹ Downloading 2021 (2/3)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2022 [278ms]
#> 
#> ℹ Downloading 2022 (3/3)
#> <GMLEnvelope>
#> ....|-- lowerCorner: -4.4 -74.1 "2000-01-01T00:00:00"
#> ....|-- upperCorner: -3.7 -73.2 "2025-01-01T00:00:00"
#> ✔ Downloaded 2022 [271ms]
#> 
head(out_pv)
#>         date species       measure      value
#> 1 2020-01-01      pv parasite_rate 0.03325922
#> 2 2021-01-01      pv parasite_rate 0.02815815
#> 3 2022-01-01      pv parasite_rate 0.03627322
# }
```
