# Extract dengue case data from OpenDengue

A global database of publicly available dengue case data. **The
OpenDengue Project** provides a harmonized, open-access repository of
dengue surveillance data from national ministries of health across Latin
America and other regions. This function enables programmatic access to
weekly case counts by downloading, caching, unzipping, reading, and
filtering national, spatial, or temporal extracts by region and country
for a specified date range, returning a ready-to-use tibble.

**\[stable\]**

## Usage

``` r
l4h_dengue_cases(
  from,
  to,
  data_type = c("temporal", "spatial", "national"),
  region = NULL,
  country = "Peru",
  cache = TRUE,
  quiet = FALSE
)
```

## Source

Data from the [OpenDengue Project](https://opendengue.org).

## Arguments

- from:

  Start date (`YYYY-MM-DD`).

- to:

  End date (`YYYY-MM-DD`).

- data_type:

  One of `"national"`, `"spatial"`, or `"temporal"`.

- region:

  Region code or full name (case-insensitive). Codes: `"paho"`,
  `"searo"`, `"wpro"`, `"afro"`, `"emro"`, `"euro"`. Full names:
  "Pan-American Region", "South-East Asia Region", "Western Pacific
  Region", "African Region", "Eastern Mediterranean Region", "European
  Region".

- country:

  Country name (case-insensitive, e.g., `"peru"`), matched against
  `adm_0_name`.

- cache:

  Logical. If `TRUE`, caches the downloaded ZIP locally.

- quiet:

  Logical. If `TRUE`, prints progress status via **cli**.

## Value

A tibble with columns: `date_start`, `date_end`, `cases`, `state`,
`area`, plus other fields.

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

Morales, I. et al. (2024). OpenDengue: Harmonized dengue surveillance
data for Latin America.

## See also

Other similar or related functions:
[`l4h_layers_available_malaria()`](https://github.com/harmonize-tools/land4health/reference/l4h_layers_available_malaria.md)

## Examples

``` r
if (interactive()) {
  # National extract for Peru in 2019
  df_nat <- l4h_dengue_cases(
    from = "2019-01-01",
    to = "2019-12-31",
    data_type = "national",
    region = "paho",
    country = "peru",
    cache = TRUE,
    quiet = TRUE
  )
  head(df_nat)

  # Spatial extract for Brazil
  df_spat <- l4h_dengue_cases(
    from = "2021-01-01",
    to = "2021-12-31",
    data_type = "spatial",
    region = "Pan-American Region",
    country = "brazil",
    cache = TRUE,
    quiet = TRUE
  )
  head(df_spat)

  # Temporal extract for Argentina
  df_temp <- l4h_dengue_cases(
    from = "2020-01-01",
    to = "2020-12-31",
    data_type = "temporal",
    region = "PAHO",
    country = "Argentina",
    cache = TRUE,
    quiet = TRUE
  )
  head(df_temp)
}
```
