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

test_that("l4h_dengue validates all data_type values", {
  expect_error(
    l4h_dengue(from = "2020-01-01", to = "2020-12-31", data_type = "xyz"),
    "should be one of"
  )
})

test_that("l4h_dengue validates NA dates", {
  expect_error(
    l4h_dengue(from = "not-a-date", to = "2020-12-31"),
    "character string is not in a standard unambiguous format|Invalid"
  )
})

test_that("l4h_dengue validates invalid full name region", {
  expect_error(
    l4h_dengue(from = "2020-01-01", to = "2020-12-31", region = "Nonexistent Region"),
    "must be one of"
  )
})

test_that("l4h_dengue validates sfc region", {
  skip_if_not_installed("sf")
  sfc <- sf::st_sfc(sf::st_point(c(-77, -12)), crs = 4326)
  expect_error(
    l4h_dengue(from = "2020-01-01", to = "2020-12-31", region = sfc),
    "must be one of"
  )
})

test_that("l4h_dengue validates reversed dates", {
  expect_error(
    l4h_dengue(from = "2021-01-01", to = "2020-01-01"),
    "Invalid"
  )
})
