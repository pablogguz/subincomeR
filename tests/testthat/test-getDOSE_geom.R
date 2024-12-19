# tests/testthat/test-getDOSE_geom.R

# Helper function to create test directory
create_test_dir <- function() {
  file.path(tempdir(), "subincomeR_test")
}

test_that("getDOSE_geom handles basic functionality correctly", {
  skip_on_cran()
  
  # Test basic functionality with default tempdir
  geom <- getDOSE_geom(download = TRUE)
  expect_s3_class(geom, "sf")
  expect_true(nrow(geom) > 0)
  expect_true(all(c("GID_0", "GID_1", "geom") %in% names(geom)))
  
  # Test file reuse
  geom2 <- getDOSE_geom(download = TRUE)
  expect_identical(geom, geom2)
})

test_that("getDOSE_geom handles custom paths and directory creation", {
  skip_on_cran()
  # Create a test directory path (but don't create the directory)
  test_dir <- file.path(tempdir(), "new_test_dir")
  
  # Function should create directory and work properly
  geom <- getDOSE_geom(path = test_dir, download = TRUE)
  expect_true(dir.exists(test_dir))
  expect_s3_class(geom, "sf")
  
  # Clean up
  unlink(test_dir, recursive = TRUE)
})

test_that("getDOSE_geom filters countries correctly", {
  skip_on_cran()
  
  countries <- c("USA", "CAN")
  geom <- getDOSE_geom(countries = countries, download = TRUE)
  unique_countries <- unique(geom$GID_0)
  expect_true(all(unique_countries %in% countries))
})

test_that("getDOSE_geom handles invalid inputs gracefully", {
  # Test invalid countries parameter
  expect_error(getDOSE_geom(countries = 123, download = TRUE),
               "'countries' must be a character vector")
  
  # Test invalid path parameter
  expect_error(getDOSE_geom(path = 123),
               "'path' must be a single character string")
  expect_error(getDOSE_geom(path = character(0)),
               "'path' must be a single character string")
  expect_error(getDOSE_geom(path = c("path1", "path2")),
               "'path' must be a single character string")
})