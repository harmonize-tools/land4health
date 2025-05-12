.internal_data <- list(
  land4health = 'https://raw.githubusercontent.com/harmonize-tools/land4health/refs/heads/main/inst/exdata/sources.csv',
  hansen = 'UMD/hansen/global_forest_change_2023_v1_11',
  inaccessibilityindex  = 'projects/sat-io/open-datasets/RAI/raimultiplier',
  ruralpopulationwithaccess = 'projects/sat-io/open-datasets/RAI/ruralpopaccess',
  accessibility_healthcare = 'Oxford/MAP/accessibility_to_healthcare_2019',
  accessibility_cities = 'Oxford/MAP/accessibility_to_cities_2015_v1_0'
)
usethis::use_data(
  .internal_data,
  internal = TRUE,
  overwrite = TRUE)
