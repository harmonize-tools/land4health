# Shared test fixtures for land4health tests
skip_if_not_installed("sf")

# A simple valid sf polygon for region validation
tiny_poly <- sf::st_sf(
  geometry = sf::st_sfc(
    sf::st_polygon(list(matrix(
      c(-77.03, -12.04, -77.02, -12.04, -77.02, -12.03,
        -77.03, -12.03, -77.03, -12.04),
      ncol = 2, byrow = TRUE
    ))),
    crs = 4326
  )
)

# Mock check_ee_initialized to be a no-op so tests can reach
# validation code without a real GEE session.
mock_ee_noop <- function() invisible(NULL)
