
#*******************************************************************************
#* This script: some tests
#*
#* Code by Pablo Garcia Guzman
#*******************************************************************************

devtools::load_all()

# Example coordinates - these are just for testing and do not necessarily correspond to the countries
lat <- c(40.7128, 51.5074, -33.8688, 0, 0)
long <- c(-74.0060, -0.1278, 151.2093, 0, 0)
countries <- c("United States", "United Kingdom", "Australia", "Narnia", "Atlantis")

# Call the function with test data
result <- matchDOSE(lat = lat, long = long, countries = countries, format_countries = "country.name")
