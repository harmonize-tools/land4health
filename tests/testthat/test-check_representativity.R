test_that("check_representativity informs only, with totals", {
  skip_if_not_installed("sf")

  # 10x10m square in Lima (~100 m2 < 1 Hansen pixel 900 m2)
  tiny <- sf::st_sf(
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(
        c(-77.03, -12.04, -77.0299, -12.04, -77.0299, -12.0399,
          -77.03, -12.0399, -77.03, -12.04),
        ncol = 2, byrow = TRUE
      ))),
      crs = 4326
    )
  )
  # 1x1km square (> 1 pixel at 30m)
  big_coords <- matrix(
    c(-77.03, -12.04, -77.02, -12.04, -77.02, -12.03,
      -77.03, -12.03, -77.03, -12.04),
    ncol = 2, byrow = TRUE
  )
  big <- sf::st_sf(
    geometry = sf::st_sfc(sf::st_polygon(list(big_coords)), crs = 4326)
  )

  expect_warning(
    out <- check_representativity(tiny, scale = 30),
    "1 of 1 polygons"
  )
  expect_false(out)

  mixed <- rbind(big, big, tiny)
  expect_warning(
    out2 <- check_representativity(mixed, scale = 30),
    "1 of 3 polygons"
  )
  expect_false(out2)

  expect_no_warning(out3 <- check_representativity(rbind(big, big), scale = 30))
  expect_true(out3)
})
