test_that("l4h_rural_access_index rejects non-sf region", {
  expect_error(
    l4h_rural_access_index(region = data.frame(x = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_rural_access_index rejects weighted without fun", {
  skip_if_not_installed("sf")
  expect_error(
    l4h_rural_access_index(region = tiny_poly, weighted = TRUE),
    "Missing required argument"
  )
})

test_that("l4h_rural_access_index flow test skipped", {
  skip("ee$Image static methods cannot be mocked on function objects")
})
