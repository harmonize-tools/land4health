#' List available metrics in *land4health*
#'
#' @description
#' Returns a tibble with the metadata of every metric shipped with
#' **land4health**.  You can optionally filter by thematic *category*, metric
#' short name, or *provider*.
#' If `open_in_browser = TRUE`, all matching URLs are opened in your default
#' browser; for safety you **must** supply at least one filter, and—if more than
#' five tabs would open—you are asked to confirm in interactive sessions.
#'
#' @param category  Optional single string. Filter by thematic category.
#' @param metric    Optional single string. Filter by metric short name.
#' @param provider  Optional single string. Filter by the `dataset` column.
#' @param open_in_browser Logical; open the matching URLs in your browser?
#'        Defaults to `FALSE`.
#'
#' @return A tibble (returned *invisibly*).  When `open_in_browser = FALSE`
#'         a compact preview (max 10 rows) is printed before the tibble is
#'         returned.
#'
#' @examples
#' ## All examples keep `open_in_browser = FALSE` to avoid side-effects
#' ## during automated checks.
#'
#' ## 1  Show the full inventory (truncated to 10 rows).
#' l4h_list_metrics()
#'
#' ## 2  Filter by category (“Human intervention”).
#' l4h_list_metrics(category = "Human intervention")
#'
#' ## 3  Filter by provider (“WorldPop”) and store the result.
#' worldpop_tbl <- l4h_list_metrics(provider = "WorldPop")
#' head(worldpop_tbl)
#'
#' ## 4  Pipe into dplyr (executes in < 1 s, loaded only if available).
#' if (requireNamespace("dplyr", quietly = TRUE)) {
#'   l4h_list_metrics() |>
#'     dplyr::filter(pixel_resolution_meters <= 100) |>
#'     dplyr::select(metric, start_year, end_year)
#' }
#'
#' ## 5  Trying to open links without filters triggers an error;
#' ##    wrapped in \dontrun{} so R CMD check is not interrupted.
#' \dontrun{
#' l4h_list_metrics(open_in_browser = TRUE)
#' }
#' @export
l4h_list_metrics <- function(category = NULL,
                             metric   = NULL,
                             provider = NULL,
                             open_in_browser = FALSE) {

  check_scalar_chr <- function(x, arg) {
    if (!is.null(x) && (!is.character(x) || length(x) != 1))
      stop(sprintf("`%s` must be a single string or NULL.", arg), call. = FALSE)
  }
  check_scalar_chr(category, "category")
  check_scalar_chr(metric,   "metric")
  check_scalar_chr(provider, "provider")

  df <- get_data()

  if (!is.null(category))
    df <- df[df$category == category, , drop = FALSE]
  if (!is.null(metric))
    df <- df[df$metric == metric, , drop = FALSE]
  if (!is.null(provider))
    df <- df[df$dataset == provider, , drop = FALSE]

  if (nrow(df) == 0L)
    stop("No metrics matched your query.", call. = FALSE)

  # Browser logic
  if (open_in_browser) {

    # Require at least one filter to avoid a tab storm
    if (is.null(category) && is.null(metric) && is.null(provider)) {
      cli::cli_abort(c(
        "x" = "{.code open_in_browser = TRUE} cannot be used without a filter.\n",
        "i" = "Add at least one of {.arg category}, {.arg metric}, {.arg provider}."
      ))

    }

    n <- nrow(df)

    # Ask for confirmation if > 5 tabs would open
    if (interactive() && n > 5L) {
      ans <- tolower(trimws(readline(
        sprintf("%d links will be opened in your default browser. Continue? [y/N]: ", n)
      )))
      if (!startsWith(ans, "y"))
        return(invisible(df))
    }

    invisible(lapply(df$url, utils::browseURL))

  } else {
    if (nrow(df) > 10L) {
      print(utils::head(df, 10L), row.names = FALSE)
      cat("... (", nrow(df) - 10L, " more)\n", sep = "")
    } else {
      print(df, row.names = FALSE)
    }
  }
}


