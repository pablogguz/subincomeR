
#*******************************************************************************
#* This script: some code profiling
#*
#* Code by Pablo Garcia Guzman
#*******************************************************************************

devtools::load_all()

# Set the seed for reproducibility
set.seed(0)

# Generate 100 random latitudes and longitudes
latitudes <- runif(100, min = -90, max = 90)
longitudes <- runif(100, min = -180, max = 180)

# Create a dataframe
df_coordinates <- data.frame(latitude = latitudes, longitude = longitudes)

# Display the first few rows of the dataframe
head(df_coordinates)

# Match ----
start_time <- Sys.time()

matched_data_df <- matchDOSE(df = df_coordinates, lat_col = "latitude", long_col = "longitude")

end_time <- Sys.time()
duration <- end_time - start_time
print(duration)
