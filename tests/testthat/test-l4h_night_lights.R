test_that("l4h_night_lights rejects invalid date format", {
  expect_error(
    l4h_night_lights("bad", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_night_lights rejects invalid to date format", {
  expect_error(
    l4h_night_lights("2020-01-01", "bad", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_night_lights rejects reversed dates", {
  expect_error(
    l4h_night_lights("2020-12-31", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
})

test_that("l4h_night_lights rejects non-sf region", {
  expect_error(
    l4h_night_lights("2020-01-01", "2020-12-31", 42),
    "Invalid.*region"
  )
})

test_that("l4h_night_lights rejects year out of range", {
  expect_error(
    l4h_night_lights("1990-01-01", "2022-12-31", tiny_poly),
    "range"
  )
})

test_that("l4h_night_lights VIIRS flow test skipped", {
  skip("ee ImageCollection chain cannot be fully mocked")
})
