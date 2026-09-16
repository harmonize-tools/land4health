test_that("l4h_urban_heat_index delegates validation to l4h_surface_temp", {
  expect_error(
    l4h_urban_heat_index("invalid", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_urban_heat_index rejects reversed dates", {
  expect_error(
    l4h_urban_heat_index("2020-12-31", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
})
