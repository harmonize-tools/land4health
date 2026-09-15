test_that("check_representativity warns for small polygons", {
  small_poly <- sf::st_as_sf(sf::st_sfc(
    sf::st_polygon(list(matrix(c(
      0, 0, 0.0001, 0, 0.0001, 0.0001, 0, 0.0001, 0, 0
    ), ncol = 2, byrow = TRUE))), crs = 4326))
  expect_warning(
    check_representativity(small_poly, scale = 30),
    "not cover enough pixels"
  )
})

test_that("check_representativity passes for large polygons", {
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

test_that("split_sf splits correctly", {
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
  poly <- sf::st_as_sf(sf::st_sfc(
    sf::st_polygon(list(matrix(c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
      ncol = 2, byrow = TRUE))), crs = 4326))
  result <- as_geojson_min(poly)
  expect_true(is.character(result))
  expect_true(grepl("Polygon", result))
})
