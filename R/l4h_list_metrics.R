#' List available metrics in land4health
#'
#' @param category Optional string. Filter by thematic category.
#' @param metric   Optional string. Filter by metric short-name.
#' @param provider Optional string. Filter by `dataset`.
#' @param open_in_browser Logical. Open the URLs in your browser? Default TRUE.
#'
#' @return A tibble (returned invisibly).  When `open_in_browser = FALSE`
#'         it prints a compact preview before returning.
#' @export
l4h_list_metrics <- function(category = NULL,
                             metric   = NULL,
                             provider = NULL,
                             open_in_browser = TRUE) {

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

  if (open_in_browser) {
    n <- nrow(df)

    # Preguntar si hay >5 enlaces en sesion interactiva
    if (interactive() && n > 5L) {
      ans <- tolower(trimws(readline(
        sprintf("% links will be opened in the browser. continue? [y/N]: ", n)
      )))
      if (!startsWith(ans, "y"))
        return(invisible(df))
    }

    invisible(lapply(df$url, utils::browseURL))   # abrir todas las URLs
  } else {
    message("Available metrics:")
    # Mostrar solo las primeras 10 filas si hay muchas
    if (nrow(df) > 10L) {
      print(utils::head(df, 10L), row.names = FALSE)
      cat("... (", nrow(df) - 10L, " more)\n", sep = "")
    } else {
      print(df, row.names = FALSE)
    }
  }

  invisible(df)
}
