test_that("l4h_sebal_modis rejects invalid date format", {
  expect_error(
    l4h_sebal_modis("not-a-date", "2020-12-31", region = tiny_poly)
  )
})

test_that("l4h_sebal_modis rejects reversed dates", {
  expect_error(
    l4h_sebal_modis("2020-12-31", "2020-01-01", region = tiny_poly),
    "must be greater than or equal"
  )
})

test_that("l4h_sebal_modis rejects out-of-range dates", {
  expect_error(
    l4h_sebal_modis("2000-01-01", "2000-12-31", region = tiny_poly),
    "range 2002"
  )
})
