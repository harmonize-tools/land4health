test_that("l4h_dengue validates data_type argument", {
  expect_error(
    l4h_dengue(from = "2020-01-01", to = "2020-12-31", data_type = "invalid"),
    "should be one of"
  )
})

test_that("l4h_dengue validates date order", {
  expect_error(
    l4h_dengue(from = "2020-12-31", to = "2020-01-01", data_type = "temporal"),
    "Invalid"
  )
})

test_that("l4h_dengue validates region", {
  expect_error(
    l4h_dengue(from = "2020-01-01", to = "2020-12-31", region = "invalid_region"),
    "must be one of"
  )
})

test_that("l4h_malaria validates species", {
  expect_error(
    l4h_malaria(from = 2020, to = 2020, species = "xx"),
    "Invalid species"
  )
})

test_that("l4h_malaria validates measure", {
  expect_error(
    l4h_malaria(from = 2020, to = 2020, measure = "invalid"),
    "Invalid measure"
  )
})

test_that("l4h_malaria validates year order", {
  expect_error(
    l4h_malaria(from = 2021, to = 2020),
    "must be >="
  )
})

test_that("l4h_chirps validates by argument", {
  expect_error(
    l4h_chirps(from = "2020-01-01", to = "2020-12-31", by = "weekly"),
    "should be one of"
  )
})

test_that("l4h_pm2_5 validates date format", {
  expect_error(
    l4h_pm2_5(from = "invalid", to = "2019-12-31"),
    "YYYY-MM-DD"
  )
})

test_that("l4h_terra_climate validates date format", {
  expect_error(
    l4h_terra_climate(from = "invalid", to = "2020-12-31", band = "pr"),
    "YYYY-MM-DD"
  )
})
