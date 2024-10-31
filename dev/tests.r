
# Simple example
matched_data_with_countries <- matchDOSE(
    lat = c(19.4326, 51.5074), 
    long = c(-99.1332, -0.1276),
    countries = c("MEX", "GBR"), 
    format_countries = "iso3c"
)

# Example with fake country names
lat <- c(40.7128, 51.5074, -33.8688, 0, 0)
long <- c(-74.0060, -0.1278, 151.2093, 0, 0)
countries <- c("United States", "United Kingdom", "Australia", "Narnia", "Atlantis")

# Call the function with test data
result <- matchDOSE(lat = lat, long = long, countries = countries, format_countries = "country.name")
