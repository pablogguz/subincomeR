# tests/testthat/test-matchDOSE.R

# Helper function to create test directory
create_test_dir <- function() {
  file.path(tempdir(), "subincomeR_test")
}

# Helper function to create test coordinates
create_test_coords <- function() {
  list(
    lat = c(19.4326, 51.5074),
    long = c(-99.1332, -0.1276)
  )
}

test_that("matchDOSE handles basic functionality correctly", {
  skip_on_cran()
  coords <- create_test_coords()
  
  # Test basic functionality with default tempdir
  result <- matchDOSE(lat = coords$lat, long = coords$long, download = TRUE)
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c("lat", "long", "GID_1") %in% names(result)))
  
  # Test file reuse
  result2 <- matchDOSE(lat = coords$lat, long = coords$long)
  expect_identical(result, result2)
})

test_that("matchDOSE works with different input types and filtering", {
  skip_on_cran()
  coords <- create_test_coords()
  
  # Test dataframe input
  df <- data.frame(
    latitude = coords$lat,
    longitude = coords$long
  )
  df_result <- matchDOSE(
    df = df, 
    lat_col = "latitude", 
    long_col = "longitude",
    download = TRUE
  )
  expect_s3_class(df_result, "data.frame")
  expect_true(nrow(df_result) > 0)
  
  # Test year filtering
  years <- 2019
  year_result <- matchDOSE(
    lat = coords$lat[1],
    long = coords$long[1],
    years = years,
    download = TRUE
  )
  expect_true(all(year_result$year %in% years))
  
  # Test country filtering
  country_result <- matchDOSE(
    lat = coords$lat,
    long = coords$long,
    countries = c("MEX", "GBR"),
    format_countries = "iso3c",
    download = TRUE
  )
  expect_true(all(country_result$GID_0 %in% c("MEX", "GBR")))
})

test_that("matchDOSE handles invalid inputs gracefully", {
  # Test missing inputs
  expect_error(matchDOSE(), "Either provide 'lat' and 'long' vectors or a dataframe")
  expect_error(matchDOSE(lat = 1), "Either provide 'lat' and 'long' vectors or a dataframe")
  
  # Test invalid dataframe
  expect_error(
    matchDOSE(df = data.frame(x = 1)),
    "Dataframe must contain 'lat' and 'long' columns"
  )
  
  # Test invalid path
  coords <- create_test_coords()
  expect_error(
    matchDOSE(lat = coords$lat, long = coords$long, path = 123, download = TRUE),
    "'path' must be a single character string"
  )
  expect_error(
    matchDOSE(lat = coords$lat, long = coords$long, path = character(0), download = TRUE),
    "'path' must be a single character string"
  )
  expect_error(
    matchDOSE(lat = coords$lat, long = coords$long, path = c("path1", "path2"), download = TRUE),
    "'path' must be a single character string"
  )
})