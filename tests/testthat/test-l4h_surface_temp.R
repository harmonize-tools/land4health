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

test_that("l4h_surface_temp rejects non-sf region", {
  expect_error(
    l4h_surface_temp("2020-01-01", "2020-12-31", data.frame(x = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_surface_temp rejects invalid band", {
  expect_error(
    l4h_surface_temp("2020-01-01", "2020-12-31", tiny_poly, band = "invalid"),
    "should be one of"
  )
})

test_that("l4h_surface_temp band=day flow works with mocked GEE", {
  skip_if_not_installed("withr")
  skip_if_not(reticulate::py_module_available("ee"), "earthengine-api Python module not available")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(
        id = 1L,
        X2020_01_01 = 25.0,
        geometry = tiny_poly$geometry[1]
      )
    },
    `l4h_to_eedate` = function(x) as.character(as.numeric(as.Date(x, origin = "1970-01-01")) * 86400000),
    {
      result <- l4h_surface_temp(
        "2020-01-01", "2020-01-01", tiny_poly,
        band = "day", sf = TRUE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
    }
  )
})

test_that("l4h_surface_temp band=night flow works with mocked GEE", {
  skip_if_not_installed("withr")
  skip_if_not(reticulate::py_module_available("ee"), "earthengine-api Python module not available")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(
        id = 1L,
        X2020_01_01 = 15.0
      )
    },
    `l4h_to_eedate` = function(x) as.character(as.numeric(as.Date(x, origin = "1970-01-01")) * 86400000),
    {
      result <- l4h_surface_temp(
        "2020-01-01", "2020-01-01", tiny_poly,
        band = "night", sf = FALSE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
    }
  )
})
