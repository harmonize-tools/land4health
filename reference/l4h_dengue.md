# Extract dengue case data from OpenDengue

Downloads dengue case counts from the **OpenDengue Project**, a
harmonized, open-access repository of dengue surveillance data from
national ministries of health. The function supports national, spatial,
and temporal extracts filtered by WHO region and country for a specified
date range.

**NA**

## Usage

``` r
l4h_dengue(
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

  Character or Date. Start date (`"YYYY-MM-DD"`).

- to:

  Character or Date. End date (`"YYYY-MM-DD"`).

- data_type:

  Character. One of `"national"`, `"spatial"`, or `"temporal"`. Default
  `"temporal"`.

- region:

  Character. WHO region code or full name (case-insensitive). Codes:
  `"paho"`, `"searo"`, `"wpro"`, `"afro"`, `"emro"`, `"euro"`. Full
  names: `"Pan-American Region"`, `"South-East Asia Region"`,
  `"Western Pacific Region"`, `"African Region"`,
  `"Eastern Mediterranean Region"`, `"European Region"`. Default
  `"paho"`.

- country:

  Character. Country name (case-insensitive), matched against
  `adm_0_name`. Default `"Peru"`.

- cache:

  Logical. If `TRUE`, caches the downloaded ZIP locally. Default `TRUE`.

- quiet:

  Logical. If `TRUE`, suppresses progress messages. Default `FALSE`.

## Value

A tibble with columns: `date_start`, `date_end`, `cases`, `state`,
`area`, plus other fields from the source data.

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

Morales, I. et al. (2024). OpenDengue: Harmonized dengue surveillance
data for Latin America.

## See also

[`l4h_malaria()`](https://github.com/harmonize-tools/land4health/reference/l4h_malaria.md)

## Examples

``` r
if (interactive()) {
  # National extract for Peru in 2019
  df_nat <- l4h_dengue(
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
  df_spat <- l4h_dengue(
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
  df_temp <- l4h_dengue(
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
