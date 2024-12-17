# tests/testthat/test-getDOSE_geom.R

# Helper function to clear cache for testing
clear_cache <- function() {
  cache_dir <- rappdirs::user_cache_dir("subincomeR")
  if (dir.exists(cache_dir)) {
    unlink(cache_dir, recursive = TRUE)
  }
}

# Helper function to create mock coordinates
create_test_coords <- function() {
  list(
    lat = c(19.4326, 51.5074),
    long = c(-99.1332, -0.1276)
  )
}

test_that("getDOSE_geom downloads and loads geometries correctly", {
  skip_on_cran()
  # Test basic functionality
  geom <- getDOSE_geom()
  expect_s3_class(geom, "sf")
  expect_true(nrow(geom) > 0)
})

test_that("getDOSE_geom filters countries correctly", {
  skip_on_cran()
  countries <- c("USA", "CAN")
  geom <- getDOSE_geom(countries = countries)
  unique_countries <- unique(geom$GID_0)
  expect_true(all(unique_countries %in% countries))
})

test_that("getDOSE_geom handles custom paths correctly", {
  # Set up test environment
  temp_dir <- file.path(tempdir(), "subincomeR_test")
  dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)
  temp_gpkg <- file.path(temp_dir, "test.gpkg")
  
  # Create mock sf object
  mock_sf <- data.frame(
    GID_1 = c("USA.1", "USA.2"),
    geom = c("POLYGON((...))", "POLYGON((...))"),
    stringsAsFactors = FALSE
  )
  class(mock_sf) <- c("sf", "data.frame")
  
  # Local mock functions
  mock_read <- function(...) mock_sf
  
  # Use local mocking
  local_mocked_bindings(
    st_read = mock_read,
    .package = "sf"
  )
  
  # Create an empty gpkg file to satisfy file existence check
  file.create(temp_gpkg)
  
  # Run test
  result <- getDOSE_geom(gpkg_path = temp_gpkg)
  
  # Test expectations
  expect_s3_class(result, "sf")
  expect_true(file.exists(temp_gpkg))
  
  # Clean up
  unlink(temp_dir, recursive = TRUE)
})

test_that("getDOSE_geom handles invalid inputs gracefully", {
  expect_error(
    getDOSE_geom(countries = 123),
    "'countries' must be a character vector"
  )
  
  expect_error(
    getDOSE_geom(gpkg_path = ""),
    "gpkg_path must be a valid file path"
  )
})