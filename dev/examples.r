# Load functions ----
devtools::load_all()

# # Simple example
# matched_data_with_countries <- matchDOSE(
#     lat = c(19.4326, 51.5074), 
#     long = c(-99.1332, -0.1276),
#     countries = c("MEX", "GBR"), 
#     format_countries = "iso3c"
# )

# # Example with fake country names
# lat <- c(40.7128, 51.5074, -33.8688, 0, 0)
# long <- c(-74.0060, -0.1278, 151.2093, 0, 0)
# countries <- c("United States", "United Kingdom", "Australia", "Narnia", "Atlantis")

# # Call the function with test data
# result <- matchDOSE(lat = lat, long = long, countries = countries, format_countries = "country.name")

library(tictoc)

# Now test examples that use cached data
cat("\nTesting getDOSE with cached data:\n")
tic()
data_all <- getDOSE()
toc()

tic()
data_2018_2019 <- getDOSE(years = c(2018, 2019))
toc()

tic()
data_usa_can <- getDOSE(countries = c('USA', 'CAN'), format_countries = 'iso3c')
toc()

cat("\nTesting getDOSE_geom with cached data:\n")
tic()
geom_all <- getDOSE_geom()
toc()

tic()
geom_subset <- getDOSE_geom(countries = c("USA", "CAN", "MEX"))
toc()

cat("\nTesting matchDOSE with cached data:\n")
tic()
matched_data_vectors <- matchDOSE(
  lat = c(19.4326, 51.5074),
  long = c(-99.1332, -0.1276)
)
toc()

tic()
df <- data.frame(
  latitude = c(19.4326, 51.5074),
  longitude = c(-99.1332, -0.1276)
)
matched_data_df <- matchDOSE(df = df, lat_col = "latitude", long_col = "longitude")
toc()

tic()
# Match coordinates and specify countries to skip country matching
matched_data_with_countries <- matchDOSE(lat = c(19.4326, 51.5074), long = c(-99.1332, -0.1276),
                                          countries = c("MEX", "GBR"), format_countries = "iso3c")
toc()