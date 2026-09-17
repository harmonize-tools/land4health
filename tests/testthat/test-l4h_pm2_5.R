test_that("l4h_pm2_5 rejects invalid date format", {
  expect_error(
    l4h_pm2_5(from = "invalid", to = "2019-12-31", region = tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_pm2_5 rejects invalid to date format", {
  expect_error(
    l4h_pm2_5(from = "2018-01-01", to = "invalid", region = tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_pm2_5 rejects reversed dates", {
  expect_error(
    l4h_pm2_5("2019-12-31", "2018-01-01", region = tiny_poly),
    "greater than or equal"
  )
})

test_that("l4h_pm2_5 rejects non-sf region", {
  expect_error(
    l4h_pm2_5("2018-01-01", "2019-12-31", region = data.frame(x = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_pm2_5 full flow works with mocked GEE", {
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
        X2018_01_01 = 25.0,
        X2019_01_01 = 30.0,
        geometry = tiny_poly$geometry[1]
      )
    },
    `l4h_to_eedate` = function(x) as.character(as.numeric(as.Date(x, origin = "1970-01-01")) * 86400000),
    {
      result <- l4h_pm2_5(
        "2018-01-01", "2019-12-31", tiny_poly,
        sf = TRUE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
      expect_true("variable" %in% names(result))
    }
  )
})

test_that("l4h_pm2_5 sf=FALSE flow works with mocked GEE", {
  skip_if_not_installed("withr")
  skip_if_not(reticulate::py_module_available("ee"), "earthengine-api Python module not available")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(id = 1L, X2018_01_01 = 25.0)
    },
    `l4h_to_eedate` = function(x) as.character(as.numeric(as.Date(x, origin = "1970-01-01")) * 86400000),
    {
      result <- l4h_pm2_5(
        "2018-01-01", "2018-12-31", tiny_poly,
        sf = FALSE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
    }
  )
})
