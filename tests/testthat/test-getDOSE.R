# tests/testthat/test-getDOSE.R

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

test_that("getDOSE downloads and loads data correctly", {
  skip_on_cran()
  # Test basic functionality
  df <- getDOSE()
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 0)
  expect_true(all(c("GID_0", "GID_1", "year") %in% names(df)))
})

test_that("getDOSE filters years correctly", {
  skip_on_cran()
  years <- c(2018, 2019)
  df <- getDOSE(years = years)
  expect_true(all(df$year %in% years))
})

test_that("getDOSE filters countries correctly", {
  skip_on_cran()
  countries <- c("USA", "CAN")
  df <- getDOSE(countries = countries, format_countries = "iso3c")
  expect_true(all(df$GID_0 %in% countries))
})

test_that("getDOSE handles invalid inputs gracefully", {
  skip_on_cran()
  # Test invalid format_countries
  expect_error(getDOSE(format_countries = "invalid"),
               "Invalid format_countries value")
  
  # Test invalid years
  expect_error(getDOSE(years = "invalid"),
               "'years' must be numeric")
  expect_error(getDOSE(years = TRUE),
               "'years' must be numeric")
  expect_error(getDOSE(years = list(2020)),
               "'years' must be numeric")
})

test_that("getDOSE uses cache correctly", {
  skip_on_cran()
  # First call should download
  df1 <- getDOSE()
  # Second call should use cache
  df2 <- getDOSE()
  expect_identical(df1, df2)
})