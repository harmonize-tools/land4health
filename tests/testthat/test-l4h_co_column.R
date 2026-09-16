test_that("l4h_co_column rejects invalid date format", {
  expect_error(
    l4h_co_column("invalid", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_co_column rejects invalid to date format", {
  expect_error(
    l4h_co_column("2020-01-01", "not-a-date", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_co_column rejects reversed dates", {
  expect_error(
    l4h_co_column("2020-12-31", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
})

test_that("l4h_co_column rejects non-sf region", {
  expect_error(
    l4h_co_column("2020-01-01", "2020-12-31", 42),
    "Invalid.*region"
  )
})

test_that("l4h_co_column rejects year out of range", {
  expect_error(
    l4h_co_column("2010-01-01", "2010-12-31", tiny_poly),
    "range"
  )
})

test_that("l4h_co_column flow test skipped", {
  skip("ImageCollection$fromImages cannot be mocked on function object")
})
