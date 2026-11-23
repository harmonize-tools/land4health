# Extract land-cover area by class from GLC-FCS30D

Calculates the area in square kilometers of each selected land-cover
class within a region for each year between 2000 and 2022. The annual
GLC-FCS30D product is mapped at 30 m resolution.

**NA**

## Usage

``` r
l4h_land_cover(
  from,
  to,
  region,
  cover_type = NULL,
  scale = 30,
  sf = TRUE,
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- from:

  Character. Start date in `"YYYY-MM-DD"` format; the year is used.

- to:

  Character. End date in `"YYYY-MM-DD"` format; the year is used.

- region:

  An `sf`, `sfc`, or `SpatVector` object defining the region.

- cover_type:

  Optional character or numeric vector of land-cover class names or
  codes. `NULL` (the default) returns all 35 mapped classes. Fill values
  are not included.

- scale:

  Numeric. Extraction scale in meters. Default is 30.

- sf:

  Logical. If `TRUE`, return an `sf` object; otherwise return a tibble.
  Default is `TRUE`.

- quiet:

  Logical. If `TRUE`, suppress the extraction progress bar. Default is
  `FALSE`.

- force:

  Logical. If `TRUE`, skip the representativity check. Default is
  `FALSE`.

- ...:

  Additional arguments passed to
  [`l4h_ee_extract()`](https://github.com/harmonize-tools/land4health/reference/l4h_ee_extract.md).

## Value

An `sf` object or tibble with `date`, `cover_type`, `class_code`, and
`area_km2` columns, plus the region attributes (and geometry when
`sf = TRUE`).

## Details

The date arguments must fall between 2000 and 2022. They are used to
select annual classification bands; the returned `date` is January 1 of
each selected year. The GLC-FCS30D fill value (class code 0) is
excluded.

Class names and codes:

- 10, 11, 12, 20: rainfed, herbaceous-cover, orchard, and irrigated
  cropland.

- 51, 52, 61, 62, 71, 72, 81, 82, 91, 92: broadleaved, needle-leaved,
  deciduous, evergreen, and mixed forests.

- 120, 121, 122: shrubland, evergreen shrubland, and deciduous
  shrubland.

- 130, 140, 150, 152, 153: grassland, lichens and mosses, and sparse
  vegetation classes.

- 181, 182, 183, 184, 185, 186, 187: swamp, marsh, flooded flat, saline,
  mangrove, salt marsh, and tidal flat.

- 190, 200, 201, 202, 210, 220: impervious surfaces, bare areas, water
  body, and permanent ice and snow.

## References

- Zhang, X. et al. (2024). GLC_FCS30D: the first global 30 m land-cover
  dynamics monitoring product with a fine classification system for
  1985–2022. *Earth System Science Data*, 16, 1353–1381.
  [doi:10.5194/essd-16-1353-2024](https://doi.org/10.5194/essd-16-1353-2024)

- GLC-FCS30D Earth Engine Community Catalog:
  <https://gee-community-catalog.org/projects/glc_fcs/>

- Earth Engine asset: `projects/sat-io/open-datasets/GLC-FCS30D/annual`

## Examples

``` r
# \donttest{
if (interactive()) {
  rgee::ee_Initialize()

  region <- sf::st_as_sf(sf::st_sfc(
    sf::st_polygon(list(matrix(c(
      -74.1, -4.4, -74.1, -3.7, -73.2, -3.7,
      -73.2, -4.4, -74.1, -4.4
    ), ncol = 2, byrow = TRUE))),
    crs = 4326
  ))

  # Area by all classes and years from 2018 to 2022
  all_classes <- l4h_land_cover(
    from = "2018-01-01",
    to = "2022-12-31",
    region = region
  )

  # Select specific classes by name or class code
  forest_and_water <- l4h_land_cover(
    from = "2018-01-01",
    to = "2022-12-31",
    region = region,
    cover_type = c("Closed evergreen broadleaved forest", 210)
  )
}
# }
```
