test_that("check_ee_initialized errors when GEE not available", {
  expect_error(check_ee_initialized(), "not initialized|not loaded")
})

test_that("safe_toBands errors on large collection", {
  fake_img <- structure(
    list(size = function() structure(
      list(getInfo = function() 6000), class = "ee.Number"
    )),
    class = "ee.imagecollection.ImageCollection"
  )
  expect_error(safe_toBands(fake_img), "exceeding the limit")
})

test_that("l4h_ee_extract rejects non-sf input", {
  skip_if_not_installed("rgee")
  expect_error(
    l4h_ee_extract(image = NULL, sf_region = data.frame(x = 1)),
    "sf_region|Earth Engine is not initialized"
  )
})
