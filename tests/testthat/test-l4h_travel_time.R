test_that("l4h_travel_time rejects non-sf region", {
  expect_error(
    l4h_travel_time(region = data.frame(x = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_travel_time rejects invalid destination", {
  expect_error(
    l4h_travel_time(region = tiny_poly, destination = "schools"),
    "healthcare.*cities"
  )
})

test_that("l4h_travel_time rejects walking_only for cities", {
  expect_error(
    l4h_travel_time(region = tiny_poly, destination = "cities",
                    transport_mode = "walking_only"),
    "walking_only.*not supported"
  )
})

test_that("l4h_travel_time rejects invalid transport_mode for healthcare", {
  expect_error(
    l4h_travel_time(region = tiny_poly, destination = "healthcare",
                    transport_mode = "cycling"),
    "Invalid.*transport_mode"
  )
})

test_that("l4h_travel_time flow test skipped", {
  skip("ee$Image static methods cannot be mocked on function objects")
})
