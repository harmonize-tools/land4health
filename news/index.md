# Changelog

## land4health 0.3.0

- [`l4h_surface_temp()`](https://github.com/harmonize-tools/land4health/reference/l4h_surface_temp.md)
  gains a `by` argument (`"day"`/`"month"`) to extract LST values at
  **daily** or **monthly** resolution. When `by = "month"`, cloud-masked
  pixels are excluded before the temporal reduction, so low-quality
  observations do not bias the monthly summary. The `"day"` option
  remains the default, so existing code is unaffected.

## land4health 0.2.0

------------------------------------------------------------------------

### 1. Vector-borne disease

- ✔ add
  [`l4h_malaria()`](https://github.com/harmonize-tools/land4health/reference/l4h_malaria.md),
  this function extracts modeled malaria metrics (incidence rate,
  incidence count, parasite rate, mortality rate, mortality count) for
  *Plasmodium falciparum* and *Plasmodium vivax* from the [Malaria Atlas
  Project](https://malariaatlas.org/) GeoServer via WCS 2.0.1.
  Automatically selects the latest release available.

- ✔ add
  [`l4h_dengue()`](https://github.com/harmonize-tools/land4health/reference/l4h_dengue.md)
  ,downloads dengue case counts from the **OpenDengue Project**, a
  harmonized, open-access repository of dengue surveillance data from
  national ministries of health. The function supports national,
  spatial, and temporal extracts filtered by WHO region and country for
  a specified date range.

### 2. Climate

- ✔ add
  [`l4h_chirps()`](https://github.com/harmonize-tools/land4health/reference/l4h_chirps.md),
  this function extracts precipitation values (daily, monthly, and
  annual) from [CHIRPS v3](https://www.chc.ucsb.edu/data/chirps3). The
  user can choose between IMERG-based (`product = "sat"`) or ERA5-based
  (`product = "rnl"`) daily products.

- ✔ add
  [`l4h_surface_temp()`](https://github.com/harmonize-tools/land4health/reference/l4h_surface_temp.md),extracts
  daytime or nighttime Land Surface Temperature (LST) for a user-defined
  region and time range using the MODIS MOD11A1.061 product

### 3. Human intervention

- ✔ add
  [`l4h_night_lights()`](https://github.com/harmonize-tools/land4health/reference/l4h_night_lights.md),
  extracts global night‑time lights using harmonized DMSP‑OLS and VIIRS
  data.

- ✔ add
  [`l4h_urban_rural_area()`](https://github.com/harmonize-tools/land4health/reference/l4h_urban_rural_area.md),
  calculates the surface area (in km2) of urban, rural, or all
  settlement classes every 5 years between 1985 and 2030 using the
  GHS-SMOD R2023A dataset.

- ✔ add
  [`l4h_human_built()`](https://github.com/harmonize-tools/land4health/reference/l4h_human_built.md),
  extracts built‑up surface area from GHSL Built‑Up Surface dataset.

### 4. Environment

- ✔ add
  [`l4h_co_column()`](https://github.com/harmonize-tools/land4health/reference/l4h_co_column.md),
  extracts carbon monoxide (CO) concentration from Sentinel-5P TROPOMI.

- ✔ add
  [`l4h_urban_heat_index()`](https://github.com/harmonize-tools/land4health/reference/l4h_urban_heat_index.md),
  calculates the Surface Urban Heat Island (SUHI) index using MODIS LST
  and GHS-SMOD.

### 5. Utils

- ✔ add
  [`l4h_ee_extract()`](https://github.com/harmonize-tools/land4health/reference/l4h_ee_extract.md)
  like an alternative to some problems
  with[`ee_extract`](https://github.com/r-spatial/rgee/issues/402)

### 6. Others

- New badge to give credit to Innovalab
  [![](https://raw.githubusercontent.com/harmonize-tools/land4health/ef742944b79b0523b16f3f3fd26e7388ca4e9551/man/figures/innovalab.svg)](https://www.innovalab.info/).
- Reduction in the number of dependeces
- Improving the progress bar using only the
  [cli](https://cli.r-lib.org/articles/progress-advanced.html) package.

### 7. Removed

- Removed `l4h_water_proportion()`. The MapBiomas Peru water dataset
  does not yet have a stable API or consistent versioning for reliable
  programmatic access.

## land4health 0.1.0

------------------------------------------------------------------------

This initial release of **land4health** lays the foundation for the core
functionality and defines the structure of the main functions, as
outlined in issue
[\#3](https://github.com/harmonize-tools/land4health/issues/4).

### ️1. Available Functions

#### Human intervention

- ✔ add
  [`l4h_forest_loss()`](https://github.com/harmonize-tools/land4health/reference/l4h_forest_loss.md)

#### Accessibility

- ✔ add
  [`l4h_rural_access_index()`](https://github.com/harmonize-tools/land4health/reference/l4h_rural_access_index.md)
- ✔ add
  [`l4h_travel_time()`](https://github.com/harmonize-tools/land4health/reference/l4h_travel_time.md)

#### Environment

- ✔ add `l4h_water_proportion()`

#### Climate

- ✔ add
  [`l4h_sebal_modis()`](https://github.com/harmonize-tools/land4health/reference/l4h_sebal_modis.md)

#### Utils

- ✔ add
  [`l4h_install()`](https://github.com/harmonize-tools/land4health/reference/l4h_install.md)
- ✔ add
  [`l4h_list_metrics()`](https://github.com/harmonize-tools/land4health/reference/l4h_list_metrics.md)
- ✔ add
  [`l4h_packages()`](https://github.com/harmonize-tools/land4health/reference/l4h_packages.md)

### 2. Features

- Upgraded assets and databases using **GHA**
  ![](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdib3g9IjAgMCAxMjggMTI4IiB3aWR0aD0iMjIiIGhlaWdodD0iMjIiPjxwYXRoIGZpbGw9IiMyMDg4ZmYiIGQ9Ik0yNi42NjYgMEMxMS45NyAwIDAgMTEuOTcgMCAyNi42NjZjMCAxMi44NyA5LjE4MSAyMy42NTEgMjEuMzM0IDI2LjEzdjM3Ljg3YzAgMTEuNzcgOS42OCAyMS4zMzQgMjEuMzMyIDIxLjMzNGguMTk1YzEuMzAyIDkuMDIzIDkuMSAxNiAxOC40NzMgMTZDNzEuNjEyIDEyOCA4MCAxMTkuNjEyIDgwIDEwOS4zMzRzLTguMzg4LTE4LjY2OC0xOC42NjYtMTguNjY4Yy05LjM3MiAwLTE3LjE3IDYuOTc3LTE4LjQ3MyAxNmgtLjE5NWMtOC43MzcgMC0xNi03LjE1Mi0xNi0xNlY2My43NzlhMTguNTE0IDE4LjUxNCAwIDAgMCAxMy4yNCA1LjU1NWgyLjk1NWMxLjMwMyA5LjAyMyA5LjEgMTYgMTguNDczIDE2IDkuMzcyIDAgMTcuMTY5LTYuOTc3IDE4LjQ3LTE2aDExLjA1N2MxLjMwMyA5LjAyMyA5LjEgMTYgMTguNDczIDE2IDEwLjI3OCAwIDE4LjY2Ni04LjM5IDE4LjY2Ni0xOC42NjhDMTI4IDU2LjM4OCAxMTkuNjEyIDQ4IDEwOS4zMzQgNDhjLTkuMzczIDAtMTcuMTcxIDYuOTc3LTE4LjQ3MyAxNkg3OS44MDVjLTEuMzAxLTkuMDIzLTkuMDk4LTE2LTE4LjQ3MS0xNnMtMTcuMTcxIDYuOTc3LTE4LjQ3MyAxNmgtMi45NTVjLTYuNDMzIDAtMTEuNzkzLTQuNTg5LTEyLjk4OC0xMC42NzIgMTQuNTgtLjEzNiAyNi40MTYtMTIuMDUgMjYuNDE2LTI2LjY2MkM1My4zMzQgMTEuOTcgNDEuMzYyIDAgMjYuNjY2IDB6bTAgNS4zMzRBMjEuMjkyIDIxLjI5MiAwIDAgMSA0OCAyNi42NjYgMjEuMjk0IDIxLjI5NCAwIDAgMSAyNi42NjYgNDggMjEuMjkyIDIxLjI5MiAwIDAgMSA1LjMzNCAyNi42NjYgMjEuMjkgMjEuMjkgMCAwIDEgMjYuNjY2IDUuMzM0em0tNS4yMTUgNy41NDFDMTguNjcgMTIuODg5IDE2IDE1LjEyMyAxNiAxOC4xNjZ2MTcuMDQzYzAgNC4wNDMgNC43MDkgNi42NjMgOC4xNDUgNC41MzNsMTMuNjM0LTguNDU1YzMuMjU3LTIuMDIgMy4yNzQtNy4wMDIuMDMyLTkuMDQ1bC0xMy42MzUtOC41OWE1LjAyNCA1LjAyNCAwIDAgMC0yLjcyNS0uNzc3em0tLjExNyA1LjI5MSAxMy42MzUgOC41ODgtMTMuNjM1IDguNDU1VjE4LjE2NnptNDAgMzUuMTY4YTEzLjI5IDEzLjI5IDAgMCAxIDEzLjMzMiAxMy4zMzJBMTMuMjkzIDEzLjI5MyAwIDAgMSA2MS4zMzQgODAgMTMuMjk0IDEzLjI5NCAwIDAgMSA0OCA2Ni42NjZhMTMuMjkzIDEzLjI5MyAwIDAgMSAxMy4zMzQtMTMuMzMyem00OCAwYTEzLjI5IDEzLjI5IDAgMCAxIDEzLjMzMiAxMy4zMzJBMTMuMjkzIDEzLjI5MyAwIDAgMSAxMDkuMzM0IDgwIDEzLjI5NCAxMy4yOTQgMCAwIDEgOTYgNjYuNjY2YTEzLjI5MyAxMy4yOTMgMCAwIDEgMTMuMzM0LTEzLjMzMnptLTQyLjU2OCA2Ljk1MWEyLjY2NyAyLjY2NyAwIDAgMC0xLjg4Ny43OGwtNi4zIDYuMjk0LTIuMDkzLTIuMDg0YTIuNjY3IDIuNjY3IDAgMCAwLTMuNzcxLjAwNiAyLjY2NyAyLjY2NyAwIDAgMCAuMDA4IDMuNzcybDMuOTc0IDMuOTZhMi42NjcgMi42NjcgMCAwIDAgMy43NjYtLjAwMWw4LjE4NS04LjE3NGEyLjY2NyAyLjY2NyAwIDAgMCAuMDAyLTMuNzcyIDIuNjY3IDIuNjY3IDAgMCAwLTEuODg0LS43OHptNDggMGEyLjY2NyAyLjY2NyAwIDAgMC0xLjg4Ny43OGwtNi4zIDYuMjk0LTIuMDkzLTIuMDg0YTIuNjY3IDIuNjY3IDAgMCAwLTMuNzcxLjAwNiAyLjY2NyAyLjY2NyAwIDAgMCAuMDA4IDMuNzcybDMuOTc0IDMuOTZhMi42NjcgMi42NjcgMCAwIDAgMy43NjYtLjAwMWw4LjE4NS04LjE3NGEyLjY2NyAyLjY2NyAwIDAgMCAuMDAyLTMuNzcyIDIuNjY3IDIuNjY3IDAgMCAwLTEuODg0LS43OHpNNjEuMzM0IDk2YTEzLjI5MyAxMy4yOTMgMCAwIDEgMTMuMzMyIDEzLjMzNCAxMy4yOSAxMy4yOSAwIDAgMS0xMy4zMzIgMTMuMzMyQTEzLjI5MyAxMy4yOTMgMCAwIDEgNDggMTA5LjMzNCAxMy4yOTQgMTMuMjk0IDAgMCAxIDYxLjMzNCA5NnpNNTYgMTA1LjMzNGMtMi4xOTMgMC00IDEuODA3LTQgNCAwIDIuMTk1IDEuODA4IDQgNCA0czQtMS44MDUgNC00YzAtMi4xOTMtMS44MDctNC00LTR6bTEwLjY2NiAwYy0yLjE5MyAwLTQgMS44MDctNCA0IDAgMi4xOTUgMS44MDggNCA0IDRzNC0xLjgwNSA0LTRjMC0yLjE5My0xLjgwNy00LTQtNHpNNTYgMTA4Yy43NSAwIDEuMzM0LjU4NSAxLjMzNCAxLjMzNCAwIC43NTMtLjU4MyAxLjMzMi0xLjMzNCAxLjMzMi0uNzUgMC0xLjMzNC0uNTgtMS4zMzQtMS4zMzIgMC0uNzUuNTg1LTEuMzM0IDEuMzM0LTEuMzM0em0xMC42NjYgMGMuNzUgMCAxLjMzNC41ODUgMS4zMzQgMS4zMzQgMCAuNzUzLS41ODMgMS4zMzItMS4zMzQgMS4zMzItLjc1IDAtMS4zMzItLjU4LTEuMzMyLTEuMzMyIDAtLjc1LjU4My0xLjMzNCAxLjMzMi0xLjMzNHoiIC8+PC9zdmc+)

  using pipelines with R
  [\#4](https://github.com/harmonize-tools/land4health/issues/4)

- add [lifecycle
  badges](https://lifecycle.r-lib.org/articles/stages.html) to all
  exported functions.

  - ![](https://lifecycle.r-lib.org/articles/figures/lifecycle-stable.svg)
  - ![](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)
  - ![](https://lifecycle.r-lib.org/reference/figures/lifecycle-deprecated.svg)
  - ![](https://lifecycle.r-lib.org/reference/figures/lifecycle-superseded.svg)  
      

- Introduced a new progress bar ( ████████ 100% ) for all functions to
  enhance the user experience.
  [\#6](https://github.com/harmonize-tools/land4health/issues/6)

- Initial CRAN submission.
