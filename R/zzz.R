.onAttach <- function(libname, pkgname) {
  packageStartupMessage("── Welcome to land4health ──")
  packageStartupMessage("🌍 land4health provides tools for analyzing frequency-grouped, weighted, and multi-source environmental indicators.")
  packageStartupMessage("Currently, `land4health` supports the following features:")
  packageStartupMessage("✔ Zonal statistics calculation (e.g., MEAN, MAXIMUM, MINIMUM, MEDIAN)")
  packageStartupMessage("✔ Multi-source data integration and harmonization")
  packageStartupMessage("✔ Export and visualization of results")
  packageStartupMessage("ℹ For more information, use `?land4health` or `help(package = 'land4health')`.")
}
