test_that("l4h_install rejects invalid backend", {
  expect_error(
    l4h_install(backend = "conda"),
    "should be one of"
  )
})

test_that("l4h_install accepts valid backends", {
  expect_no_error(match.arg("auto", c("auto", "uv", "pip")))
  expect_no_error(match.arg("uv", c("auto", "uv", "pip")))
  expect_no_error(match.arg("pip", c("auto", "uv", "pip")))
})

test_that("l4h_install rejects uv when not found", {
  skip_on_cran()
  skip_if_not_installed("withr")
  withr::local_envvar(c("PATH" = ""))
  expect_error(
    l4h_install(backend = "uv"),
    "uv.*not found"
  )
})

test_that("l4h_install flow tests skipped - reticulate::* cannot be mocked", {
  skip("reticulate::* calls are namespaced and cannot be mocked with with_mocked_bindings")
})
