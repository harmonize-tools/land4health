% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_metrics_summary.R
\name{get_metrics_summary}
\alias{get_metrics_summary}
\title{Summary of Categories and Available Metrics in land4health}
\usage{
get_metrics_summary(query = NULL)
}
\arguments{
\item{query}{Character. Default is NULL.}
}
\value{
A \code{tibble} (or \code{sf}, depending on the structure of the data) with two columns:
\code{provider} (the name of the provider) and \code{metrics_counts} (the number of available metrics).
}
\description{
This function returns a summary of the categories present in the dataset along with the number of available metrics for each provider.
It provides a quick overview of the distribution of key indicators and covariates, which is useful for exploratory analysis in spatial epidemiology.
}
\examples{
\donttest{
library(land4health)
get_metrics_summary()
}
}
