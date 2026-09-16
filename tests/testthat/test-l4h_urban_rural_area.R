test_that("l4h_urban_rural_area rejects non-sf region", {
  expect_error(
    l4h_urban_rural_area(region = list(a = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_urban_rural_area rejects invalid category", {
  skip_if_not_installed("sf")
  expect_error(
    l4h_urban_rural_area(region = tiny_poly, category = "invalid", force = TRUE),
    "Invalid category"
  )
})

test_that("l4h_urban_rural_area flow test skipped", {
  skip("ee$ImageCollection static methods cannot be mocked on function objects")
})
