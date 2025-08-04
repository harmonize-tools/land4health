test_that("l4h_list_metrics returns a tibble", {
  result <- l4h_list_metrics()
  expect_s3_class(result, "tbl_df")
})

test_that("category filter returns only matching rows", {
  df_all <- l4h_list_metrics()
  unique_category <- df_all$category[1]
  result <- l4h_list_metrics(category = unique_category)
  expect_true(all(result$category == unique_category))
})

test_that("metric filter returns only matching metric", {
  df_all <- l4h_list_metrics()
  unique_metric <- df_all$metric[1]
  result <- l4h_list_metrics(metric = unique_metric)
  expect_true(all(result$metric == unique_metric))
})

test_that("provider filter returns only matching provider", {
  df_all <- l4h_list_metrics()
  unique_provider <- df_all$dataset[1]
  result <- l4h_list_metrics(provider = unique_provider)
  expect_true(all(result$dataset == unique_provider))
})

test_that("returns invisibly", {
  expect_invisible(l4h_list_metrics())
})

test_that("invalid scalar inputs throw error", {
  expect_error(l4h_list_metrics(category = c("A", "B")),
               "must be a single string")
  expect_error(l4h_list_metrics(metric = 123),
               "must be a single string")
})

test_that("errors if no results found", {
  expect_error(l4h_list_metrics(metric = "this_metric_does_not_exist"),
               "No metrics matched")
})

test_that("open_in_browser = FALSE returns tibble silently", {
  result <- expect_invisible(l4h_list_metrics(open_in_browser = FALSE))
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})
