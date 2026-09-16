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
