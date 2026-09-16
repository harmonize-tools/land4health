test_that("l4h_sebal_modis rejects invalid date type", {
  expect_error(
    l4h_sebal_modis(123, "2020-12-31", region = tiny_poly),
    "Date or character"
  )
})

test_that("l4h_sebal_modis rejects invalid to date type", {
  expect_error(
    l4h_sebal_modis("2020-01-01", 123, region = tiny_poly),
    "Date or character"
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

test_that("l4h_sebal_modis rejects invalid by argument", {
  expect_error(
    l4h_sebal_modis("2020-01-01", "2020-12-31", by = "weekly", region = tiny_poly),
    "not supported"
  )
})

test_that("l4h_sebal_modis rejects non-sf region", {
  expect_error(
    l4h_sebal_modis("2010-01-01", "2010-12-31", region = data.frame(x = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_sebal_modis rejects NA dates", {
  expect_error(
    l4h_sebal_modis("bad-date", "2020-12-31", region = tiny_poly),
    "character string is not in a standard unambiguous format|YYYY-MM-DD"
  )
})

test_that("l4h_sebal_modis flow test skipped", {
  skip("ee$ImageCollection static methods cannot be mocked on function objects")
})
