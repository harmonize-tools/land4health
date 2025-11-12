# Changelog

## land4health 0.2.0

New release with new functions and some wrapper for extract data to
[**Malaria-Atlas**](https://malariaatlas.org/) and
[**OpenDengue**](https://opendengue.org/) projects.

#### Vector-borne disease

- ✔ add
  [`l4h_dengue_cases()`](https://github.com/harmonize-tools/land4health/reference/l4h_dengue_cases.md)
- ✔ add
  [`l4h_layers_available_malaria()`](https://github.com/harmonize-tools/land4health/reference/l4h_layers_available_malaria.md)

#### Human intervention

- ✔ add
  [`l4h_night_lights()`](https://github.com/harmonize-tools/land4health/reference/l4h_night_lights.md)
- ✔ add
  [`l4h_urban_rural_area()`](https://github.com/harmonize-tools/land4health/reference/l4h_urban_rural_area.md)
- ✔ add
  [`l4h_human_built()`](https://github.com/harmonize-tools/land4health/reference/l4h_human_built.md)

#### Environment

- ✔ add
  [`l4h_co_column()`](https://github.com/harmonize-tools/land4health/reference/l4h_co_column.md)
- ✔ add
  [`l4h_urban_heat_index()`](https://github.com/harmonize-tools/land4health/reference/l4h_urban_heat_index.md)

#### Climate

- ✔ add
  [`l4h_surface_temp()`](https://github.com/harmonize-tools/land4health/reference/l4h_surface_temp.md)

#### Others

- New badge to give credit to Innovalab
  ![](https://raw.githubusercontent.com/harmonize-tools/land4health/ef742944b79b0523b16f3f3fd26e7388ca4e9551/man/figures/innovalab.svg).

## land4health 0.1.0

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

- ✔ add
  [`l4h_water_proportion()`](https://github.com/harmonize-tools/land4health/reference/l4h_water_proportion.md)

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
