# tests/testthat/test-matchDOSE.R

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

test_that("matchDOSE works with coordinate vectors", {
  skip_on_cran()
  result <- matchDOSE(
    lat = c(19.4326, 51.5074),
    long = c(-99.1332, -0.1276)
  )
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c("lat", "long", "GID_1") %in% names(result)))
})

test_that("matchDOSE works with dataframe input", {
  skip_on_cran()
  df <- data.frame(
    latitude = c(19.4326, 51.5074),
    longitude = c(-99.1332, -0.1276)
  )
  result <- matchDOSE(df = df, lat_col = "latitude", long_col = "longitude")
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("matchDOSE filters years correctly", {
  skip_on_cran()
  years <- 2019
  result <- matchDOSE(
    lat = c(19.4326),
    long = c(-99.1332),
    years = years
  )
  expect_true(all(result$year %in% years))
})

test_that("matchDOSE handles direct country specification", {
  skip_on_cran()
  result <- matchDOSE(
    lat = c(19.4326, 51.5074),
    long = c(-99.1332, -0.1276),
    countries = c("MEX", "GBR"),
    format_countries = "iso3c"
  )
  expect_true(all(result$GID_0 %in% c("MEX", "GBR")))
})

test_that("matchDOSE handles invalid inputs gracefully", {
  skip_on_cran()
  expect_error(matchDOSE())  # No coordinates provided
  expect_error(matchDOSE(lat = 1))  # Missing longitude
  expect_error(matchDOSE(df = data.frame(x = 1)))  # Missing required columns
})