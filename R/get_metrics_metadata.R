#' List providers, description, year and link
#'
#' @description
#' This function allows you to list the list of available providers of the land4health package.
#'
#' @param query A string. Default is NULL. List of available providers. For more details, use the `get_providers` function.
#' @returns A tibble object.
#'
#' @examples
#' \donttest{
#' library(land4health)
#' get_metrics_metadata()
#' }
#' @export

get_metrics_metadata <- \(query = NULL) {

  available_providers <- get_data() |> dplyr::select(category) |> dplyr::pull()

  if (is.null(query)) {
    sources <- get_data() |>
      tidyr::as_tibble()

  } else if (all(query %in% available_providers)) {
    sources <- get_data() |>
      tidyr::as_tibble() |>
      dplyr::filter(provider %in% query)

  } else {
    stop("Please select valid providers from the available providers")
  }

  return(sources)
}
