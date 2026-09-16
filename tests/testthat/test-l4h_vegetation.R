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
