test_that("l4h_human_built rejects invalid date format", {
  expect_error(
    l4h_human_built("invalid", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_human_built rejects invalid to date format", {
  expect_error(
    l4h_human_built("2020-01-01", "nope", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_human_built rejects reversed dates", {
  expect_error(
    l4h_human_built("2020-12-31", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
})

test_that("l4h_human_built full flow works with mocked GEE", {
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
        GHS_2020 = 100,
        geometry = tiny_poly$geometry[1]
      )
    },
    {
      result <- l4h_human_built(
        "2020-01-01", "2020-12-31", tiny_poly,
        sf = TRUE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
      expect_true("variable" %in% names(result))
    }
  )
})

test_that("l4h_human_built sf=FALSE flow works with mocked GEE", {
  skip_if_not_installed("withr")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(id = 1L, GHS_2020 = 100)
    },
    {
      result <- l4h_human_built(
        "2020-01-01", "2020-12-31", tiny_poly,
        sf = FALSE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
    }
  )
})

test_that("l4h_human_built rejects non-sf region", {
  expect_error(
    l4h_human_built("2020-01-01", "2020-12-31", 42),
    "Invalid.*region"
  )
})
