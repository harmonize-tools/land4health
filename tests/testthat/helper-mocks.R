# Shared mock infrastructure for land4health tests
# Allows testing GEE/network functions without real connections
skip_if_not_installed("sf")

# Shared sf fixture
tiny_poly <- sf::st_sf(
  geometry = sf::st_sfc(
    sf::st_polygon(list(matrix(
      c(-77.03, -12.04, -77.02, -12.04, -77.02, -12.03,
        -77.03, -12.03, -77.03, -12.04),
      ncol = 2, byrow = TRUE
    ))),
    crs = 4326
  ),
  id = 1L
)

# Returns self for every method call, enabling ee$Image(...) chains
.make_mock_ee_obj <- function() {
  obj <- new.env(parent = emptyenv())
  obj$select     <- function(...) invisible(obj)
  obj$filterDate <- function(...) invisible(obj)
  obj$filter     <- function(...) invisible(obj)
  obj$map        <- function(...) invisible(obj)
  obj$toBands    <- function(...) invisible(obj)
  obj$merge      <- function(...) invisible(obj)
  obj$eq         <- function(...) invisible(obj)
  obj$multiply   <- function(...) invisible(obj)
  obj$divide     <- function(...) invisible(obj)
  obj$reproject  <- function(...) invisible(obj)
  obj$rename     <- function(...) invisible(obj)
  obj$updateMask <- function(...) invisible(obj)
  obj$lte        <- function(...) invisible(obj)
  obj$neq        <- function(...) invisible(obj)
  obj$And        <- function(...) invisible(obj)
  obj$add        <- function(...) invisible(obj)
  obj$rightShift <- function(...) invisible(obj)
  obj$bitwiseAnd <- function(...) invisible(obj)
  obj$reduceRegions <- function(...) invisible(obj)
  obj$mean       <- function(...) invisible(obj)
  obj$sum        <- function(...) invisible(obj)
  obj$expression <- function(...) invisible(obj)
  obj$set        <- function(...) invisible(obj)
  obj$size       <- function() {
    n <- new.env(parent = emptyenv())
    n$getInfo <- function() 10L
    n
  }
  obj$bandNames <- function() {
    n <- new.env(parent = emptyenv())
    n$getInfo <- function() c("X2020_01_01", "X2020_06_01")
    n
  }
  obj
}

# Mock of Earth Engine ---
.make_mock_image_class <- function() {
  image_env <- new.env(parent = emptyenv())
  # Store .make_mock_ee_obj directly so closures can find it
  image_env$.make_mock_ee_obj <- .make_mock_ee_obj
  image_env$pixelArea <- function() .make_mock_ee_obj()
  constructor <- function(id = NULL) .make_mock_ee_obj()
  environment(constructor) <- image_env
  constructor
}

.make_mock_filter <- function() {
  f <- new.env(parent = emptyenv())
  f$calendarRange <- function(...) invisible(f)
  f$date          <- function(...) invisible(f)
  f
}

.make_mock_number <- function(val = 1) {
  n <- new.env(parent = emptyenv())
  n$getInfo   <- function() val
  n$add       <- function(...) .make_mock_number(val)
  n$subtract  <- function(...) .make_mock_number(val)
  n$leftShift <- function(...) .make_mock_number(val)
  n
}

.make_mock_reducer <- function() {
  r <- new.env(parent = emptyenv())
  r
}

.make_mock_list <- function() {
  lst <- new.env(parent = emptyenv())
  lst$sequence <- function(...) .make_mock_list()
  lst$map      <- function(...) .make_mock_ee_obj()
  lst$flatten  <- function() .make_mock_ee_obj()
  lst
}

.make_mock_date_class <- function() {
  d <- new.env(parent = emptyenv())
  d$fromYMD <- function(...) .make_mock_ee_obj()
  d$millis  <- function() .make_mock_number()
  d
}

.make_mock_ee <- function() {
  e <- new.env(parent = emptyenv())
  ic_obj <- .make_mock_ee_obj()
  ic_obj$fromImages <- function(imgs) .make_mock_ee_obj()
  ic_obj$.self <- ic_obj  # Self-reference for closure lookup
  ic_fn <- function(...) .self
  environment(ic_fn) <- ic_obj  # $fromImages lookup goes here
  e$ImageCollection <- ic_fn

  e$Image           <- .make_mock_image_class()
  e$Filter          <- .make_mock_filter()
  e$Number          <- function(x = 1) .make_mock_number(x)
  e$Reducer         <- .make_mock_reducer()
  e$List            <- function(...) .make_mock_list()
  e$Date            <- .make_mock_date_class()
  e
}

# Mock httr2 - l4h_dengue ----
.make_mock_httr2_response <- function(file_name = "Temporal_extract_PAHO_V9_1.zip") {
  resp <- new.env(parent = emptyenv())
  resp$body <- list()
  resp
}

.make_mock_json_items <- function(file_name = "Temporal_extract_PAHO_V9_1.zip") {
  list(list(name = file_name))
}

# Fake extract result (sf with geometry)
.make_fake_extract_result <- function() {
  dplyr::tibble(
    id = 1L,
    geom = tiny_poly$geometry[1]
  )
}

# Fake extract result (tibble, no geometry)
.make_fake_extract_tibble <- function() {
  dplyr::tibble(id = 1L, value = 0.5)
}

# Fake dengue CSV data
.make_fake_dengue_csv <- function() {
  dplyr::tibble(
    adm_0_name = "PERU",
    adm_1_name = "LIMA",
    adm_2_name = "LIMA",
    calendar_start_date = as.Date("2020-01-01"),
    calendar_end_date = as.Date("2020-01-31"),
    dengue_total = 100L
  )
}

# Fake extract with named band columns (for pivot_longer)
.make_fake_extract_bands <- function(band_names = c("X2020", "X2021")) {
  result <- dplyr::tibble(id = 1L)
  for (b in band_names) {
    result[[b]] <- 0.5
  }
  result
}
