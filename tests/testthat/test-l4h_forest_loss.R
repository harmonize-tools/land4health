test_that("l4h_forest_loss rejects invalid date format", {
  expect_error(
    l4h_forest_loss("bad-date", "2020-12-31", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_forest_loss rejects invalid to date format", {
  expect_error(
    l4h_forest_loss("2020-01-01", "bad-date", tiny_poly),
    "YYYY-MM-DD"
  )
})

test_that("l4h_forest_loss rejects reversed dates", {
  expect_error(
    l4h_forest_loss("2020-12-31", "2020-01-01", tiny_poly),
    "greater than or equal"
  )
})

test_that("l4h_forest_loss rejects non-sf region", {
  expect_error(
    l4h_forest_loss("2020-01-01", "2020-12-31", data.frame(x = 1)),
    "Invalid.*region"
  )
})

test_that("l4h_forest_loss full flow works with mocked GEE", {
  skip_if_not_installed("withr")

  mock_ee <- .make_mock_ee()
  fake_result <- .make_fake_extract_bands(c("constant.2020"))
  fake_result$id <- 1L

  withr::local_options(list(
    ee_env = mock_ee
  ))

  # Assign mock ee to global env so function can find it
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(id = 1L, constant.2020 = 0.5, geometry = tiny_poly$geometry[1])
    },
    {
      result <- l4h_forest_loss(
        "2020-01-01", "2020-12-31", tiny_poly,
        sf = TRUE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
      expect_true("variable" %in% names(result))
      expect_true("value" %in% names(result))
    }
  )
})

test_that("l4h_forest_loss sf=FALSE flow works with mocked GEE", {
  skip_if_not_installed("withr")

  mock_ee <- .make_mock_ee()
  assign("ee", mock_ee, envir = globalenv())
  on.exit(rm("ee", envir = globalenv()), add = TRUE)

  with_mocked_bindings(
    `check_ee_initialized` = function() invisible(NULL),
    `check_representativity` = function(...) invisible(TRUE),
    `l4h_ee_extract` = function(...) {
      dplyr::tibble(id = 1L, constant.2020 = 0.5)
    },
    {
      result <- l4h_forest_loss(
        "2020-01-01", "2020-12-31", tiny_poly,
        sf = FALSE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_true("date" %in% names(result))
      expect_true("variable" %in% names(result))
    }
  )
})

test_that("l4h_forest_loss multi-year flow works with mocked GEE", {
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
        constant.2020 = 0.5,
        constant.2021 = 0.3,
        geometry = tiny_poly$geometry[1]
      )
    },
    {
      result <- l4h_forest_loss(
        "2020-01-01", "2021-12-31", tiny_poly,
        sf = TRUE, quiet = TRUE, force = TRUE
      )
      expect_s3_class(result, "tbl_df")
      expect_equal(nrow(result), 2L)
    }
  )
})
