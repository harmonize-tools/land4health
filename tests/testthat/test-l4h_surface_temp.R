test_that("l4h_surface_temp rejects invalid date format", {
  expect_error(
    l4h_surface_temp("invalid", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_surface_temp rejects invalid to date format", {
  expect_error(
    l4h_surface_temp("2020-01-01", "invalid", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_surface_temp rejects reversed dates", {
  expect_error(
    l4h_surface_temp("2020-12-31", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
})
