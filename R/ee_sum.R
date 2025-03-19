#' Set of function to zonal statistic
#' @param x image of type Image o Image Collection
#'
#' @param y region of type Feacture o FeatureCollection
#'
#' @param by a limit of pass
#'
#' median
#' @import rgee
# Functions for extract the mean of pixels of a rasterdata
# ee.Reducer.sum
#' @export

ee_sum <- function(x, y, scale) {
  y_len <- y$size()$getInfo()

  for (i in seq(1, y_len, scale)) {
    index <- i - 1
    print(sprintf("Extracting information [%s/%s]...", index, y_len))

    ee_value_layer <- ee$FeatureCollection(y) %>%
      ee$FeatureCollection$toList(scale, index) %>%
      ee$FeatureCollection()

    if (i == 1) {
      dataset <- ee_extract(
        x = x,
        fun = ee$Reducer$sum(),
        y = ee_value_layer,
        sf = T
      )
    } else {
      db_local <- ee_extract(
        x = x,
        y = ee_value_layer,
        fun = ee$Reducer$sum(),
        sf = T
      )
      dataset <- rbind(dataset, db_local)
    }
  }
  return(dataset)
}
