# cribbed from https://github.com/tidyverse/tidyverse/blob/main/R/attach.R
# Uses MIT license
core <- c("rgee","sf")

core_unloaded <- function() {
  search <- paste0("package:", core)
  core[!search %in% search()]
}

# Attach the package from the same package library it was
same_library <- function(pkg) {
  loc <- if (pkg %in% loadedNamespaces()) dirname(getNamespaceInfo(pkg, "path"))
  library(pkg, lib.loc = loc, character.only = TRUE, warn.conflicts = FALSE)
}

# attaches all the packages from core that are not loaded
land4health_attach <- function() {
  to_load <- core_unloaded()
  suppressPackageStartupMessages(
    lapply(to_load, same_library)
  )
  invisible(to_load)
}

#' List all *land4health* packages
#'
#' @param include_self default `TRUE`. Includes the "land4health" package name in the
#' resultant character vector.
#' @returns A character vector of package names included in the "land4health" meta-package.
#' @export
#' @examples
#' l4h_packages()
#'
# https://github.com/tidyverse/tidyverse/blob/main/R/utils.R
l4h_packages <- function(include_self = TRUE) {
  pkgs <- core
  if (include_self) {
    pkgs <- c(pkgs, "land4health")
  }
  return(pkgs)
}
