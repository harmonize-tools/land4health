test_that("l4h_malaria validates from type", {
  expect_error(
    l4h_malaria(from = "2020", to = 2020, region = tiny_poly),
    "single integer year"
  )
})

test_that("l4h_malaria validates to type", {
  expect_error(
    l4h_malaria(from = 2020, to = "2020", region = tiny_poly),
    "single integer year"
  )
})

test_that("l4h_malaria validates year order", {
  expect_error(
    l4h_malaria(from = 2021, to = 2020, region = tiny_poly),
    "must be >="
  )
})

test_that("l4h_malaria validates species", {
  expect_error(
    l4h_malaria(from = 2020, to = 2020, species = "xx", region = tiny_poly),
    "Invalid species"
  )
})

test_that("l4h_malaria validates measure", {
  expect_error(
    l4h_malaria(from = 2020, to = 2020, measure = "invalid", region = tiny_poly),
    "Invalid measure"
  )
})

test_that("l4h_malaria validates region class", {
  expect_error(
    l4h_malaria(from = 2020, to = 2020, region = data.frame(x = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_malaria accepts sfc region with force=TRUE", {
  skip_if_not_installed("sf")
  sfc <- sf::st_sfc(sf::st_point(c(-77, -12)), crs = 4326)
  expect_error(
    l4h_malaria(from = 2020, to = 2020, region = sfc, force = TRUE),
    "ows4R|GeoServer|WCSClient|connection|coverage|layer|No data"
  )
})

test_that("l4h_malaria flow tests skipped - ows4R::* cannot be mocked", {
  skip("ows4R::* calls are namespaced and cannot be mocked with with_mocked_bindings")
})
