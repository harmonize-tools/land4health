test_that("all exported functions exist", {
  fns <- c(
    "l4h_chirps", "l4h_co_column", "l4h_dengue", "l4h_era5land", "l4h_forest_loss",
    "l4h_human_built", "l4h_install", "l4h_list_metrics", "l4h_malaria",
    "l4h_night_lights", "l4h_packages", "l4h_pm2_5", "l4h_rural_access_index",
    "l4h_sebal_modis", "l4h_surface_temp", "l4h_terra_climate",
    "l4h_travel_time", "l4h_urban_heat_index", "l4h_urban_rural_area",
    "l4h_use_python", "l4h_vegetation"
  )
  for (fn in fns) {
    expect_true(is.function(get(fn)), label = paste(fn, "is a function"))
  }
})

test_that("l4h_packages returns expected packages", {
  pkgs <- l4h_packages()
  expect_true("land4health" %in% pkgs)
  expect_true("rgee" %in% pkgs)
  expect_true("sf" %in% pkgs)
})

test_that("l4h_list_metrics returns tibble", {
  out <- l4h_list_metrics()
  expect_s3_class(out, "tbl_df")
  expect_true("category" %in% names(out))
  expect_true("metric" %in% names(out))
  expect_true(nrow(out) > 0)
})

test_that("l4h_list_metrics filters by category", {
  out <- l4h_list_metrics(category = "Climate")
  expect_s3_class(out, "tbl_df")
  expect_true(all(out$category == "Climate"))
})

test_that("l4h_list_metrics filters by metric", {
  out <- l4h_list_metrics(metric = "Deforestation")
  expect_s3_class(out, "tbl_df")
  expect_true(nrow(out) == 1)
})
