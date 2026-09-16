# List malaria layers by species & metric from Malaria Atlas Project

Provides a tidy listing of all malaria data layers in the Malaria Atlas
Project GeoServer, including separate columns for species (Plasmodium
falciparum vs. Plasmodium vivax), year, month, and metric (e.g.
incidence_rate, parasite_rate, mortality_count, etc.). These layers
cover modeled estimates of malaria prevalence, incidence, mortality and
more, at global scale, broken down by species and time.

**\[stable\]**

## Usage

``` r
l4h_layers_available_malaria(year = NULL, species = NULL, measure = NULL)
```

## Arguments

- year:

  Integer or integer vector. Optional filter on dataset year (e.g.
  `2024`).

- species:

  Character or character vector. Optional filter on species:

  - `"plasmodium falciparum"`

  - `"plasmodium vivax"`

- measure:

  Character or character vector. Optional filter on metric type: e.g.
  `"incidence_rate"`, `"parasite_rate"`, `"mortality_count"`,
  `"reproductive_number"`.

## Value

A tibble with columns:

- `workspace` — always `"malaria"`

- `year` — dataset year

- `month` — dataset month (NA if annual)

- `species` — full species name (lowercase)

- `measure` — metric type (lowercase)

- `dataset_id` — original coverage ID for subsequent WMS/WCS requests

## Details

The Malaria Atlas Project <https://malariaatlas.org/> provides globally
modeled raster surfaces of key malaria indicators. This function
retrieves all available coverage IDs from the GeoServer, parses out the
species, time, and metric, and returns them in a user-friendly table for
easy filtering and selection.

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
# \donttest{
# list all available malaria layers
all_layers <- l4h_layers_available_malaria()
head(all_layers)
#> # A tibble: 6 × 6
#>   workspace  year month species               measure         dataset_id        
#>   <chr>     <int> <int> <chr>                 <chr>           <chr>             
#> 1 malaria    2022     6 plasmodium falciparum mortality_count Malaria__202206_G…
#> 2 malaria    2024     6 plasmodium falciparum mortality_count Malaria__202406_G…
#> 3 malaria    2025     8 plasmodium falciparum mortality_count Malaria__202508_G…
#> 4 malaria    2022     6 plasmodium falciparum mortality_rate  Malaria__202206_G…
#> 5 malaria    2024     6 plasmodium falciparum mortality_rate  Malaria__202406_G…
#> 6 malaria    2025     8 plasmodium falciparum mortality_rate  Malaria__202508_G…

# filter for Plasmodium falciparum parasite rate in 2024
pf_pr_2024 <- l4h_layers_available_malaria(
  year    = 2024,
  species = "plasmodium falciparum",
  measure = "parasite_rate"
)
print(pf_pr_2024)
#> # A tibble: 1 × 6
#>   workspace  year month species               measure       dataset_id          
#>   <chr>     <int> <int> <chr>                 <chr>         <chr>               
#> 1 malaria    2024     6 plasmodium falciparum parasite_rate Malaria__202406_Glo…
# }
```
