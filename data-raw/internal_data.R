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
      dplyr::filter(stringr::str_detect(id, pattern = db)) |>
      dplyr::select(id) |>
      dplyr::pull()
  } else {
    id <- 'projects/mapbiomas-public/assets/peru/collection1/mapbiomas_peru_collection1_water_v1'
  }


  return(id)
}

.internal_data <- list(
  hansen            = updated_db_ee(type = 'eedataset', db = 'hansen'),
  rai               = updated_db_ee(type = 'eeawesome', db = 'raimultiplier'),
  ruralaccess       = updated_db_ee(type = 'eeawesome', db = 'ruralpopaccess'),
  inaccessibility   = updated_db_ee(type = 'eeawesome', db = 'inaccessibility'),
  access_healthcare = updated_db_ee(type = 'eedataset', db = 'accessibility_to_healthcare'),
  access_cities     = updated_db_ee(type = 'eedataset', db = 'accessibility_to_cities'),
  water_coverage    = updated_db_ee(type = 'mapbiomas', db = NULL),
  geesebal          = updated_db_ee(type = 'eeawesome', db = 'geesebal')
)

usethis::use_data(.internal_data, internal = TRUE, overwrite = TRUE)
