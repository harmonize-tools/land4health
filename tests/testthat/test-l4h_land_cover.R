test_that("l4h_land_cover validates dates and range", {
  expect_error(
    l4h_land_cover("invalid", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
  expect_error(
    l4h_land_cover("2020-02-31", "2020-12-31", tiny_poly),
    "valid date"
  )
  expect_error(
    l4h_land_cover("2021-01-01", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
  expect_error(
    l4h_land_cover("1999-01-01", "2000-12-31", tiny_poly),
    "range 2000 to 2022"
  )
})

test_that("l4h_land_cover validates region and cover types", {
  expect_error(
    l4h_land_cover("2020-01-01", "2020-12-31", data.frame(x = 1)),
    "region.*sf"
  )
  expect_error(
    l4h_land_cover("2020-01-01", "2020-12-31", tiny_poly, cover_type = "unknown"),
    "Unknown.*cover_type"
  )
  expect_error(
    l4h_land_cover("2020-01-01", "2020-12-31", tiny_poly, cover_type = "0"),
    "Unknown.*cover_type"
  )
  expect_error(
    l4h_land_cover("2020-01-01", "2020-12-31", tiny_poly, cover_type = c(10, "10")),
    "duplicate classes"
  )
})

test_that("l4h_land_cover extracts selected class areas by year", {
  skip_if_not_installed("withr")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(
        id = 1L,
        area_y2020_c10 = 1.5,
        area_y2020_c210 = 2,
        area_y2021_c10 = 1.75,
        area_y2021_c210 = 2.25
      )
    },
    {
      result <- l4h_land_cover(
        from = "2020-01-01",
        to = "2021-12-31",
        region = tiny_poly,
        cover_type = c("Rainfed cropland", 210),
        sf = FALSE,
        quiet = TRUE,
        force = TRUE
      )

      expect_s3_class(result, "tbl_df")
      expect_equal(nrow(result), 4L)
      expect_equal(result$class_code, c(10L, 210L, 10L, 210L))
      expect_equal(
        result$cover_type,
        c("Rainfed cropland", "Water body", "Rainfed cropland", "Water body")
      )
      expect_equal(result$date, as.Date(c(
        "2020-01-01", "2020-01-01", "2021-01-01", "2021-01-01"
      )))
      expect_equal(result$area_km2, c(1.5, 2, 1.75, 2.25))
    }
  )
})

test_that("l4h_land_cover returns an sf object when requested", {
  skip_if_not_installed("withr")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      sf::st_sf(
        id = 1L,
        area_y2020_c210 = 2,
        geometry = tiny_poly$geometry
      )
    },
    {
      result <- l4h_land_cover(
        from = "2020-01-01",
        to = "2020-12-31",
        region = tiny_poly,
        cover_type = "Water body",
        quiet = TRUE,
        force = TRUE
      )

      expect_s3_class(result, "sf")
      expect_equal(result$class_code, 210L)
      expect_equal(result$area_km2, 2)
    }
  )
})
