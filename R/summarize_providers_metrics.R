#' Summary of Providers and Available Metrics in land4health
#'
#' @description
#' This function returns a summary of the providers present in the dataset along with the number of available metrics for each provider.
#' It provides a quick overview of the distribution of key indicators and covariates, which is useful for exploratory analysis in spatial epidemiology.
#'
#' @param query Character. Default is NULL.
#' @return A \code{tibble} (or \code{sf}, depending on the structure of the data) with two columns:
#' \code{provider} (the name of the provider) and \code{metrics_counts} (the number of available metrics).
#'
#' @examples
#' \donttest{
#' library(land4health)
#' summarize_providers_metrics()
#' }
#' @export
summarize_providers_metrics <- \(query = NULL){

  if(is.null(query)){
    providers_count <- get_data() |>
      subset(select = "dataset") |>
      table() |>
      as.data.frame() |>
      tidyr::as_tibble()
    names(providers_count) <- c("provider", "metrics_counts")

  } else {
    stop("Please, only NULL is valid")
  }
  return(providers_count)
}
