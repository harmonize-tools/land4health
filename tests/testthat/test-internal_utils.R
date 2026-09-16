test_that("split_sf splits correctly", {
  skip_if_not_installed("sf")
  poly1 <- sf::st_as_sf(sf::st_sfc(
    sf::st_polygon(list(matrix(c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
      ncol = 2, byrow = TRUE))), crs = 4326))
  poly2 <- sf::st_as_sf(sf::st_sfc(
    sf::st_polygon(list(matrix(c(2, 2, 3, 2, 3, 3, 2, 3, 2, 2),
      ncol = 2, byrow = TRUE))), crs = 4326))
  combined <- rbind(poly1, poly2)
  result <- split_sf(combined)
  expect_length(result, 2)
  expect_s3_class(result[[1]], "sf")
  expect_equal(nrow(result[[1]]), 1)
})

test_that("split_sf rejects non-sf input", {
  expect_error(split_sf(data.frame(x = 1)), "sf")
})

test_that("as_geojson_min converts sf to geojson", {
  skip_if_not_installed("sf")
  skip_if_not_installed("geojsonio")
  poly <- sf::st_as_sf(sf::st_sfc(
    sf::st_polygon(list(matrix(c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
      ncol = 2, byrow = TRUE))), crs = 4326))
  result <- as_geojson_min(poly)
  expect_true(is.character(result))
  expect_true(grepl("Polygon", result))
})

test_that("%||% operator works", {
  expect_equal(1 %||% 2, 1)
  expect_equal(NULL %||% 2, 2)
  expect_equal("a" %||% "b", "a")
})

test_that("check_ee_initialized errors when GEE not available", {
  skip_if_not_installed("rgee")
  ee_ok <- tryCatch({ rgee::ee$Number(1)$getInfo(); TRUE }, error = function(e) FALSE)
  skip_if(ee_ok, "GEE is initialized")
  expect_error(check_ee_initialized(), "not initialized|not loaded")
})

test_that("safe_toBands errors on large collection", {
  fake_img <- structure(
    list(size = function() structure(
      list(getInfo = function() 6000), class = "ee.Number"
    )),
    class = "ee.imagecollection.ImageCollection"
  )
  expect_error(safe_toBands(fake_img), "exceeding the limit")
})

test_that("get_reducer returns ee Reducer objects", {
  skip_if_not_installed("rgee")
  skip_if(is.null(getOption("rgeeinitialized")), "GEE not initialized")
  for (name in c("mean", "sum", "min", "max", "median")) {
    r <- get_reducer(name)
    expect_true(inherits(r, "ee.reducer.Reducer"))
  }
})

test_that("get_reducer errors on invalid name", {
  skip_if_not_installed("rgee")
  expect_error(get_reducer("invalid"), "not valid")
})

test_that("l4h_ee_extract rejects non-sf input", {
  skip_if_not_installed("rgee")
  expect_error(
    l4h_ee_extract(image = NULL, sf_region = data.frame(x = 1)),
    "sf_region|Earth Engine is not initialized"
  )
})

test_that("check_representativity warns for small polygons", {
  skip_if_not_installed("sf")
  small_poly <- sf::st_as_sf(sf::st_sfc(
    sf::st_polygon(list(matrix(c(
      0, 0, 0.0001, 0, 0.0001, 0.0001, 0, 0.0001, 0, 0
    ), ncol = 2, byrow = TRUE))), crs = 4326))
  expect_warning(
    check_representativity(small_poly, scale = 30), "not cover enough pixels"
  )
})

test_that("check_representativity passes for large polygons", {
  skip_if_not_installed("sf")
  large_poly <- sf::st_as_sf(sf::st_sfc(
    sf::st_polygon(list(matrix(c(
      -80, -10, -70, -10, -70, 0, -80, 0, -80, -10
    ), ncol = 2, byrow = TRUE))), crs = 4326))
  expect_silent(result <- check_representativity(large_poly, scale = 30))
  expect_true(result)
})

test_that("check_representativity rejects non-sf input", {
  expect_error(check_representativity(data.frame(x = 1)), "sf")
})

test_that("get_data returns tibble from sources.csv", {
  result <- get_data()
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expect_true("category" %in% names(result))
  expect_true("metric" %in% names(result))
})

test_that("l4h_list_metrics returns tibble", {
  out <- l4h_list_metrics()
  expect_s3_class(out, "tbl_df")
  expect_true("category" %in% names(out))
  expect_true("metric" %in% names(out))
  expect_true(nrow(out) > 0)
})

test_that("l4h_list_metrics filters by category", {
  out <- l4h_list_metrics(category = "Climate")
  expect_s3_class(out, "tbl_df")
  expect_true(all(out$category == "Climate"))
})

test_that("l4h_list_metrics filters by metric", {
  out <- l4h_list_metrics(metric = "Deforestation")
  expect_s3_class(out, "tbl_df")
  expect_true(nrow(out) == 1)
})

test_that("all exported functions exist", {
  fns <- c(
    "l4h_chirps", "l4h_co_column", "l4h_dengue", "l4h_forest_loss",
    "l4h_human_built", "l4h_install", "l4h_list_metrics", "l4h_malaria",
    "l4h_night_lights", "l4h_packages", "l4h_pm2_5", "l4h_rural_access_index",
    "l4h_sebal_modis", "l4h_surface_temp", "l4h_terra_climate",
    "l4h_travel_time", "l4h_urban_heat_index", "l4h_urban_rural_area",
    "l4h_use_python", "l4h_vegetation"
  )
  for (fn in fns) {
    expect_true(is.function(get(fn)), label = paste(fn, "is a function"))
  }
})

test_that("l4h_packages returns expected packages", {
  pkgs <- l4h_packages()
  expect_true("land4health" %in% pkgs)
  expect_true("rgee" %in% pkgs)
  expect_true("sf" %in% pkgs)
})

test_that(".create_env_loader saves config", {
  skip_if_not_installed("withr")
  skip_if_not_installed("rappdirs")
  tmp <- withr::local_tempdir()
  withr::local_envvar("XDG_CONFIG_HOME" = tmp)
  expect_no_error(.create_env_loader("test-env", "virtualenv"))
  config_file <- file.path(rappdirs::user_config_dir("land4health"), "python_env.rds")
  expect_true(file.exists(config_file))
  config <- readRDS(config_file)
  expect_equal(config$envname, "test-env")
  expect_equal(config$method, "virtualenv")
})

test_that(".load_env_config returns NULL when no config exists", {
  skip_if_not_installed("withr")
  skip_if_not_installed("rappdirs")
  tmp <- withr::local_tempdir()
  withr::local_envvar("XDG_CONFIG_HOME" = tmp)
  # Remove any existing config file
  config_dir <- rappdirs::user_config_dir("land4health")
  config_file <- file.path(config_dir, "python_env.rds")
  if (file.exists(config_file)) unlink(config_file)
  result <- .load_env_config()
  expect_null(result)
})

test_that(".load_env_config returns saved config", {
  skip_if_not_installed("withr")
  skip_if_not_installed("rappdirs")
  tmp <- withr::local_tempdir()
  withr::local_envvar("XDG_CONFIG_HOME" = tmp)
  .create_env_loader("my-env", "conda")
  result <- .load_env_config()
  expect_equal(result$envname, "my-env")
  expect_equal(result$method, "conda")
})

test_that("bitwiseExtract works with mock ee", {
  skip_if_not_installed("rgee")
  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)
  mock_val <- .make_mock_ee_obj()
  result <- bitwiseExtract(mock_val, 0, 1)
  expect_true(inherits(result, "environment"))
})

test_that("calculate_area works with mock ee", {
  skip_if_not_installed("rgee")
  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)
  mock_img <- .make_mock_ee_obj()
  result <- calculate_area(mock_img)
  expect_true(inherits(result, "environment"))
})

test_that("mask_quality works with mock ee", {
  skip_if_not_installed("rgee")
  skip("mask_quality uses bitwiseExtract which accesses real ee$Number inside package namespace")
})
