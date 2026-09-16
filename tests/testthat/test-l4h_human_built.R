test_that("l4h_human_built rejects invalid date format", {
  expect_error(
    l4h_human_built("invalid", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_human_built rejects invalid to date format", {
  expect_error(
    l4h_human_built("2020-01-01", "nope", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_human_built rejects reversed dates", {
  expect_error(
    l4h_human_built("2020-12-31", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
})
