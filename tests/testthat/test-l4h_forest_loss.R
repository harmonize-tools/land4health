test_that("l4h_forest_loss rejects invalid date format", {
  expect_error(
    l4h_forest_loss("bad-date", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_forest_loss rejects invalid to date format", {
  expect_error(
    l4h_forest_loss("2020-01-01", "bad-date", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_forest_loss rejects reversed dates", {
  expect_error(
    l4h_forest_loss("2020-12-31", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
})

test_that("l4h_forest_loss rejects non-sf region", {
  expect_error(
    l4h_forest_loss("2020-01-01", "2020-12-31", data.frame(x = 1)),
    "Invalid.*region"
  )
})
