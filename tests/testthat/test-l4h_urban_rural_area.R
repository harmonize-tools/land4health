test_that("l4h_urban_rural_area rejects non-sf region", {
  expect_error(
    l4h_urban_rural_area(region = list(a = 1)),
    "Invalid.*region"
  )
})
