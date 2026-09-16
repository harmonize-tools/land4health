test_that("l4h_vegetation rejects invalid band", {
  expect_error(
    l4h_vegetation(tiny_poly, "2020-01-01", "2020-12-31", band = "NDBI"),
    "should be one of"
  )
})

test_that("l4h_vegetation rejects invalid by", {
  expect_error(
    l4h_vegetation(tiny_poly, "2020-01-01", "2020-12-31", by = "weekly"),
    "should be one of"
  )
})

test_that("l4h_vegetation rejects invalid fun", {
  expect_error(
    l4h_vegetation(tiny_poly, "2020-01-01", "2020-12-31", fun = "range"),
    "should be one of"
  )
})

test_that("l4h_vegetation rejects non-sf region", {
  expect_error(
    l4h_vegetation(data.frame(x = 1), "2020-01-01", "2020-12-31"),
    "region.*must be"
  )
})

test_that("l4h_vegetation rejects sfc region (sf only)", {
  skip_if_not_installed("sf")
  sfc <- sf::st_sfc(sf::st_point(c(0, 0)))
  expect_error(
    l4h_vegetation(sfc, "2020-01-01", "2020-12-31"),
    "region.*must be"
  )
})

test_that("l4h_vegetation rejects out-of-range dates", {
  expect_error(
    l4h_vegetation(tiny_poly, "1999-01-01", "1999-12-31"),
    "Date range out of bounds"
  )
})

test_that("l4h_vegetation rejects future dates", {
  expect_error(
    l4h_vegetation(tiny_poly, "2025-01-01", "2025-12-31"),
    "Date range out of bounds"
  )
})

test_that("l4h_vegetation flow test skipped", {
  skip("ee$ImageCollection$fromImages cannot be mocked on function objects")
})
