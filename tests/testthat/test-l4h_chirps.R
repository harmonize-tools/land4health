test_that("l4h_chirps validates by argument", {
  expect_error(
    l4h_chirps(from = "2020-01-01", to = "2020-12-31", by = "weekly",
               region = tiny_poly),
    "should be one of"
  )
})

test_that("l4h_chirps rejects invalid date format", {
  expect_error(
    l4h_chirps("invalid", "2020-12-31", region = tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_chirps rejects invalid to date format", {
  expect_error(
    l4h_chirps("2020-01-01", "not-a-date", region = tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_chirps rejects reversed dates", {
  expect_error(
    l4h_chirps("2020-12-31", "2020-01-01", region = tiny_poly),
    "greater than or equal"
  )
})

test_that("l4h_chirps rejects non-sf region", {
  expect_error(
    l4h_chirps("2020-01-01", "2020-12-31", region = data.frame(x = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_chirps rejects sat product before 2001", {
  expect_error(
    l4h_chirps("1999-01-01", "1999-12-31", product = "sat",
               region = tiny_poly),
    "only available from 2001"
  )
})

test_that("l4h_chirps rejects invalid product", {
  expect_error(
    l4h_chirps("2020-01-01", "2020-12-31", product = "invalid",
               region = tiny_poly),
    "should be one of"
  )
})

test_that("l4h_chirps rejects year out of range", {
  expect_error(
    l4h_chirps("1970-01-01", "1970-12-31", region = tiny_poly),
    "range"
  )
})

test_that("l4h_chirps by='daily' flow works with mocked GEE", {
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
        X20200101 = 5.0,
        X20200102 = 10.0
      )
    },
    {
      result <- l4h_chirps(
        "2020-01-01", "2020-01-02",
        by = "daily", region = tiny_poly,
        sf = FALSE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
    }
  )
})

test_that("l4h_chirps by='month' flow works with mocked GEE", {
  skip("Complex GEE chain (ImageCollection$fromImages) cannot be mocked")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(
        id = 1L,
        precip_202001 = 100.0,
        precip_202002 = 150.0,
        geometry = tiny_poly$geometry[1]
      )
    },
    {
      result <- l4h_chirps(
        "2020-01-01", "2020-02-28",
        by = "month", region = tiny_poly,
        sf = TRUE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
      expect_true("variable" %in% names(result))
    }
  )
})

test_that("l4h_chirps by='annual' flow works with mocked GEE", {
  skip("Complex GEE chain (ImageCollection$fromImages + List$map) cannot be mocked")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(
        id = 1L,
        precip_2020 = 1200.0
      )
    },
    {
      result <- l4h_chirps(
        "2020-01-01", "2020-12-31",
        by = "annual", region = tiny_poly,
        sf = FALSE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
    }
  )
})
