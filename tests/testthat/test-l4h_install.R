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
