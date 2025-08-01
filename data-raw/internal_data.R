updated_db_ee <- function(type = NULL, db = NULL){

  if(!is.null(db)){
    url_ee <- switch(
      type,
      "eedataset" = 'https://raw.githubusercontent.com/samapriya/Earth-Engine-Datasets-List/master/gee_catalog.json',
      "eeawesome"  = 'https://raw.githubusercontent.com/samapriya/awesome-gee-community-datasets/refs/heads/master/community_datasets.json',
      cli::cli_abort("Error in '{type}', please verify type argument.")
    )

    catalog_ee <- jsonlite::fromJSON(url_ee) |>
      tidyr::as_tibble()

    id <- catalog_ee |>
      dplyr::filter(stringr::str_detect(id, pattern = db))

  } else {
    id <- 'projects/mapbiomas-public/assets/peru/collection1/mapbiomas_peru_collection1_water_v1'
  }

  return(id)
}

.internal_data <- list(
  hansen             = updated_db_ee(type = 'eedataset', db = 'hansen'),
  rai                = updated_db_ee(type = 'eeawesome', db = 'raimultiplier'),
  ruralaccess        = updated_db_ee(type = 'eeawesome', db = 'ruralpopaccess'),
  inaccessibility    = updated_db_ee(type = 'eeawesome', db = 'inaccessibility'),
  access_healthcare  = updated_db_ee(type = 'eedataset', db = 'accessibility_to_healthcare'),
  access_cities      = updated_db_ee(type = 'eedataset', db = 'accessibility_to_cities'),
  water_coverage     = updated_db_ee(type = 'mapbiomas', db = NULL),
  geesebal           = updated_db_ee(type = 'eeawesome', db = 'geesebal'),
  ghsl               = updated_db_ee(type = 'eeawesome', db = 'GHS_SMOD'),
  lst                = updated_db_ee(type = 'eedataset', db = 'MODIS/061/MOD11A1'),
  co_column          = updated_db_ee(type = 'eedataset', db = 'COPERNICUS/S5P/OFFL/L3_CO'),
  night_lights_dmsp  = updated_db_ee(type = 'eeawesome', db = 'Harmonized_NTL/dmsp'),
  night_lights_viirs = updated_db_ee(type = 'eeawesome', db = 'Harmonized_NTL/viirs'),
  human_built        = updated_db_ee(type = 'eedataset', db = 'JRC/GHSL/P2023A/GHS_BUILT_S'),
  malaria_atlas      = "https://data.malariaatlas.org/geoserver/Malaria/ows"
)

usethis::use_data(.internal_data, internal = TRUE, overwrite = TRUE)
