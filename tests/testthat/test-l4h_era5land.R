test_that("l4h_era5land validates by argument", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", by = "weekly"),
    "should be one of"
  )
})

test_that("l4h_era5land validates band codes", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", band = "invalid"),
    "invalid"
  )
})

test_that("l4h_era5land validates date format", {
  expect_error(
    l4h_era5land(from = "invalid", to = "2020-12-31"),
    "YYYY-MM-DD"
  )
})

test_that("l4h_era5land validates date order", {
  expect_error(
    l4h_era5land(from = "2020-12-31", to = "2020-01-01"),
    "greater than or equal"
  )
})

test_that("l4h_era5land validates year range", {
  expect_error(
    l4h_era5land(from = "1940-01-01", to = "1945-12-31"),
    "range"
  )
})

test_that("l4h_era5land validates region", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", region = "invalid"),
    "must be an"
  )
})

test_that("l4h_era5land accepts band = 'rh' (fails on region, not on band)", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", band = "rh", region = "invalid"),
    "must be an"
  )
})

test_that("l4h_era5land accepts band = c('rh', 'pr') (fails on region, not on band)", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", band = c("rh", "pr"), region = "invalid"),
    "must be an"
  )
})

test_that("l4h_era5land accepts band = 'rh_day' (fails on region, not on band)", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", band = "rh_day", region = "invalid"),
    "must be an"
  )
})

test_that("l4h_era5land accepts band = c('rh_day', 'rh_night') (fails on region, not on band)", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", band = c("rh_day", "rh_night"), region = "invalid"),
    "must be an"
  )
})

test_that("l4h_era5land rejects mixing rh_day with aggregate bands", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", band = c("rh_day", "pr"), region = "invalid"),
    "cannot be combined"
  )
})

test_that("l4h_era5land rejects mixing rh_day with rh", {
  expect_error(
    l4h_era5land(from = "2020-01-01", to = "2020-12-31", band = c("rh_day", "rh"), region = "invalid"),
    "cannot be combined"
  )
})
