#' #' Extract Urban Area from MODIS Land Cover (MCD12Q1.061)
#' #'
#' #' Extracts the annual area of a specific land cover class from the MODIS Land Cover product (MCD12Q1.061),
#' #' using the specified land cover classification scheme (band).
#' #'
#' #' @param from Character string indicating the starting year (e.g., `"2010"`).
#' #' @param to Character string indicating the ending year (e.g., `"2020"`).
#' #' @param region A `sf` object representing the region of interest.
#' #' @param scale Numeric. The nominal scale in meters to use for the area calculation (e.g., `500`).
#' #' @param lc_band Character. The MODIS land cover classification band to use. One of:
#' #' `"LC_Type1"` (default), `"LC_Type2"`, `"LC_Type3"`, `"LC_Type4"`, or `"LC_Type5"`.
#' #'
#' #' @return A `tibble` containing the year and area (in km²) of the selected land cover class.
#' #'
#' #' @details
#' #' This function uses the MODIS Land Cover Type Yearly Global 500m dataset (MCD12Q1.061) from Google Earth Engine.
#' #' It calculates the area of the land cover class `"13"` (Urban and Built-Up Lands) based on the selected band.
#' #'
#' #' ## Available Classification Schemes:
#' #'
#' #' - **LC_Type1**: IGBP global vegetation classification (17 classes)
#' #' - **LC_Type2**: University of Maryland (UMD) land cover classification
#' #' - **LC_Type3**: MODIS LAI/FPAR Biome Type classification
#' #' - **LC_Type4**: MODIS Net Primary Production (NPP) Biome classification
#' #' - **LC_Type5**: Plant Functional Type (PFT) classification
#' #'
#' #' **Note:** The function currently extracts only class `13` (Urban), which may correspond to different meanings depending on the selected `lc_band`.
#' #'
#' #' For detailed class definitions of each scheme, refer to:
#' #' [MODIS/061/MCD12Q1 on Google Earth Engine](https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MCD12Q1)
#' #'
#' #' @examples
#' #' \dontrun{
#' #'
#' #' library(innovar)
#' #' library(rgee)
#' #' library(sf)
#' #' ee_Initialize()
#' #' data("Peru")
#' #' region <- Peru
#' #' region_ee <- pol_as_ee(region, id = 'distr' ,simplify = 1000)
#' #' data <- get_urban(from = '2008-01-01', to = '2010-01-01', region = region)
#' #'
#' #' }
#' # Function for extract urban areas
#'
#' l4h_urban_area <- function(from, to, region, scale = 1000) {
#'
#'     # Conditions about the times
#'   start_year <- substr(from, 1, 4) %>% as.numeric()
#'   end_year <- substr(to, 1, 4) %>% as.numeric()
#'
#'   if(start_year == end_year){
#'     year <- unique(
#'       c(start_year:end_year)
#'     ) %>%
#'       list()
#'
#'     year_list <- ee$List(year)
#'   } else {
#'     year <- unique(
#'       c(start_year:end_year)
#'     )
#'     year_list <- ee$List(year)
#'   }
#'
#'   # Message of error
#'   if (to < 2001  | from > 2019) {
#'     print(sprintf("No exist data of urban area"))
#'   }
#'
#'   list_urban <-
#'     year_list$
#'     map(
#'       ee_utils_pyfunc(
#'         function(x) {
#'           ee$ImageCollection("MODIS/006/MCD12Q1")$
#'             select(c('LC_Type2'))$
#'             filter(
#'               ee$Filter$calendarRange(
#'                 x,
#'                 x,
#'                 "year")
#'             )$
#'             map(function(img) img$eq(list(13)))$
#'             mean()$
#'             multiply(
#'               ee$Image$pixelArea())$
#'             divide(100000)$
#'             rename('urban')
#'         }
#'       )
#'     )
#'
#'   urban_img <- ee$ImageCollection$
#'     fromImages(list_urban)$
#'     toBands()$
#'     clip(region)
#'
#'   data <-
#'     ee_sum(
#'       x = urban_img,
#'       y = region,
#'       scale = scale
#'     )
#'
#'   return(data)
#' }
