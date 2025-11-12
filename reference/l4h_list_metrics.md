# List available metrics in *land4health*

Returns a tibble with the metadata of every metric shipped with
**land4health**. You can optionally filter by thematic *category*,
metric short name, or *provider*. If `open_in_browser = TRUE`, all
matching URLs are opened in your default browser; for safety you
**must** supply at least one filter, and—if more than five tabs would
open—you are asked to confirm in interactive sessions.

## Usage

``` r
l4h_list_metrics(
  category = NULL,
  metric = NULL,
  provider = NULL,
  open_in_browser = FALSE
)
```

## Arguments

- category:

  Optional single string. Filter by thematic category.

- metric:

  Optional single string. Filter by metric short name.

- provider:

  Optional single string. Filter by the `dataset` column.

- open_in_browser:

  Logical; open the matching URLs in your browser? Defaults to `FALSE`.

## Value

A tibble (returned *invisibly*). When `open_in_browser = FALSE` a
compact preview (max 10 rows) is printed before the tibble is returned.

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

## Examples

``` r
## All examples keep `open_in_browser = FALSE` to avoid side-effects
## during automated checks.

## 1  Show the full inventory (truncated to 10 rows).
l4h_list_metrics()
#> # A tibble: 10 × 11
#>    category           metric  pixel_resolution_met…¹ dataset start_year end_year
#>    <chr>              <chr>   <chr>                  <chr>        <int>    <int>
#>  1 Human intervention Defore… 30                     Hansen…       2000     2023
#>  2 Human intervention Human … 300                    Global…       1990     2017
#>  3 Human intervention Popula… 100                    WorldP…       2000     2021
#>  4 Human intervention Urban … 500                    MODIS …       2001     2022
#>  5 Human intervention Night … 500                    VIIRS …       1992     2023
#>  6 Human intervention Human … 30                     Global…       1975     2030
#>  7 Enviroment         Water … 30                     MapBio…       1985     2022
#>  8 Enviroment         Urban … 1000                   Urban …       2003     2020
#>  9 Accessibility      Travel… 927.67                 Malari…       2019     2020
#> 10 Accessibility      Rural … 100                    Rural …       2024     2024
#> # ℹ abbreviated name: ¹​pixel_resolution_meters
#> # ℹ 5 more variables: resolution_temporal <chr>, layer_can_be_actived <lgl>,
#> #   tags <chr>, lifecycle <chr>, url <chr>
#> ... (1 more)

## 2  Filter by category (“Human intervention”).
l4h_list_metrics(category = "Human intervention")
#> # A tibble: 6 × 11
#>   category           metric   pixel_resolution_met…¹ dataset start_year end_year
#>   <chr>              <chr>    <chr>                  <chr>        <int>    <int>
#> 1 Human intervention Defores… 30                     Hansen…       2000     2023
#> 2 Human intervention Human M… 300                    Global…       1990     2017
#> 3 Human intervention Populat… 100                    WorldP…       2000     2021
#> 4 Human intervention Urban a… 500                    MODIS …       2001     2022
#> 5 Human intervention Night t… 500                    VIIRS …       1992     2023
#> 6 Human intervention Human S… 30                     Global…       1975     2030
#> # ℹ abbreviated name: ¹​pixel_resolution_meters
#> # ℹ 5 more variables: resolution_temporal <chr>, layer_can_be_actived <lgl>,
#> #   tags <chr>, lifecycle <chr>, url <chr>

## 3  Filter by provider (“WorldPop”) and store the result.
worldpop_tbl <- l4h_list_metrics(provider = "WorldPop")
#> # A tibble: 1 × 11
#>   category           metric   pixel_resolution_met…¹ dataset start_year end_year
#>   <chr>              <chr>    <chr>                  <chr>        <int>    <int>
#> 1 Human intervention Populat… 100                    WorldP…       2000     2021
#> # ℹ abbreviated name: ¹​pixel_resolution_meters
#> # ℹ 5 more variables: resolution_temporal <chr>, layer_can_be_actived <lgl>,
#> #   tags <chr>, lifecycle <chr>, url <chr>
head(worldpop_tbl)
#> # A tibble: 1 × 11
#>   category           metric   pixel_resolution_met…¹ dataset start_year end_year
#>   <chr>              <chr>    <chr>                  <chr>        <int>    <int>
#> 1 Human intervention Populat… 100                    WorldP…       2000     2021
#> # ℹ abbreviated name: ¹​pixel_resolution_meters
#> # ℹ 5 more variables: resolution_temporal <chr>, layer_can_be_actived <lgl>,
#> #   tags <chr>, lifecycle <chr>, url <chr>
```
