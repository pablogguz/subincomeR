# tests/testthat/test-getDOSE.R

# Helper function to create test directory
create_test_dir <- function() {
  file.path(tempdir(), "subincomeR_test")
}

test_that("getDOSE handles basic functionality correctly", {
  skip_on_cran()
  
  # Test basic functionality with default tempdir
  df <- getDOSE()
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 0)
  expect_true(all(c("GID_0", "GID_1", "year") %in% names(df)))
  
  # Test file reuse
  df2 <- getDOSE()
  expect_identical(df, df2)
})

test_that("getDOSE handles custom paths and directory creation", {
  skip_on_cran()
  # Create a test directory path (but don't create the directory)
  test_dir <- file.path(tempdir(), "new_test_dir")
  
  # Function should create directory and work properly
  df <- getDOSE(path = test_dir)
  expect_true(dir.exists(test_dir))
  expect_s3_class(df, "data.frame")
  
  # Clean up
  unlink(test_dir, recursive = TRUE)
})

test_that("getDOSE filters data correctly", {
  skip_on_cran()

  # Test year filtering
  years <- c(2018, 2019)
  df_years <- getDOSE(years = years)
  expect_true(all(df_years$year %in% years))
  
  # Test country filtering
  countries <- c("USA", "CAN")

  df_countries <- getDOSE(
    countries = countries, 
    format_countries = "iso3c", 
  )

  expect_true(all(df_countries$GID_0 %in% countries))
})

test_that("getDOSE handles invalid inputs gracefully", {
  # Test invalid format_countries
  expect_error(getDOSE(format_countries = "invalid"),
               "Invalid format_countries value")
  
  # Test invalid years
  expect_error(getDOSE(years = "invalid"), "'years' must be numeric")
  expect_error(getDOSE(years = TRUE), "'years' must be numeric")
  expect_error(getDOSE(years = list(2020)), "'years' must be numeric")
  
  # Test invalid path
  expect_error(getDOSE(path = 123), "'path' must be a single character string")
  expect_error(getDOSE(path = character(0)), "'path' must be a single character string")
  expect_error(getDOSE(path = c("path1", "path2")), "'path' must be a single character string")
})