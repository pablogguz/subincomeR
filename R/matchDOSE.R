#' Match coordinates to DOSE dataset
#'
#' This function matches input coordinates (latitude and longitude) to the DOSE dataset.
#' It accepts either vectors of latitudes and longitudes or a dataframe containing
#' these coordinates. Before matching, it ensures that only unique coordinates are processed
#' to avoid duplicating operations on identical coordinates. It uses GADM-1 geometries
#' to match coordinates to regions and returns a dataframe with unique input coordinates 
#' and matched DOSE data.
#'
#' @param lat Optional vector of latitudes of the points to match. Required if no dataframe is provided.
#' @param long Optional vector of longitudes of the points to match. Required if no dataframe is provided.
#' @param df Optional dataframe containing coordinates and possibly additional columns. If provided,
#'        'lat' and 'long' vectors should not be provided. The dataframe must include columns specified
#'        by 'lat_col' and 'long_col' parameters.
#' @param lat_col Optional name of the latitude column in 'df'. Only used if 'df' is provided.
#'        Defaults to "lat".
#' @param long_col Optional name of the longitude column in 'df'. Only used if 'df' is provided.
#'        Defaults to "long".
#' @param years Optional vector of years for which to filter the DOSE dataset.
#'        If NULL (the default), a 1:m matching is performed and data for all years are returned.
#' @param countries Optional vector or dataframe column name of country identifiers.
#'        If provided, the function skips the country matching step. Can significantly reduce processing time.
#' @param format_countries Specifies the format of the country identifiers in 'countries'.
#'        Options are "country.name" (default), "iso3c", and "iso2c". This parameter is ignored if 'countries' is NULL.
#' @param path Optional character string specifying where to store downloaded files.
#'        If NULL (default), uses tempdir().
#' @param download Logical indicating whether to download without confirmation.
#'        Default is FALSE, which will prompt for confirmation in interactive sessions.
#'        Set to TRUE to skip confirmation.
#' @return A dataframe with input coordinates (and any additional input dataframe columns) and matched DOSE data.
#' @import sf
#' @importFrom dplyr filter left_join select mutate
#' @importFrom tidygeocoder reverse_geocode
#' @importFrom countrycode countrycode
#' @importFrom rlang .data
#' @export
#' @examples
#' \donttest{
#' # Match coordinates using vectors
#' matched_data <- matchDOSE(lat = c(19.4326, 51.5074), 
#'                          long = c(-99.1332, -0.1276))
#'
#' # Match coordinates using a dataframe
#' df <- data.frame(ID = 1:2, 
#'                  latitude = c(19.4326, 51.5074), 
#'                  longitude = c(-99.1332, -0.1276))
#' matched_data_df <- matchDOSE(df = df, 
#'                             lat_col = "latitude", 
#'                             long_col = "longitude")
#'
#' # Match coordinates for a specific year
#' matched_data_2019 <- matchDOSE(lat = c(19.4326), 
#'                                long = c(-99.1332), 
#'                                years = 2019)
#'
#' # Match coordinates with known countries
#' matched_data_countries <- matchDOSE(lat = c(19.4326, 51.5074),
#'                                    long = c(-99.1332, -0.1276),
#'                                    countries = c("MEX", "GBR"),
#'                                    format_countries = "iso3c")
#' }
matchDOSE <- function(lat = NULL, long = NULL, df = NULL, lat_col = "lat",
                     long_col = "long", years = NULL, countries = NULL,
                     format_countries = "iso3c", path = NULL, download = FALSE) {

  # Ensure necessary packages are loaded
  requireNamespace("sf", quietly = TRUE)
  requireNamespace("tidygeocoder", quietly = TRUE)
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("countrycode", quietly = TRUE)

  # Validate format_countries input
  valid_formats <- c("iso2c", "iso3c", "country.name")
  if (!format_countries %in% valid_formats) {
    stop("Invalid format_countries value. Please use one of: 'iso2c', 'iso3c', or 'country.name'.")
  }

  # Determine input type and prepare data accordingly
  if (!is.null(df)) {
    # Check if specified lat and long column names exist in the dataframe
    if (!(lat_col %in% names(df)) || !(long_col %in% names(df))) {
      stop(paste("Dataframe must contain '", lat_col, "' and '", long_col, "' columns.", sep = ""))
    }

    # Create a coordinates dataframe using specified column names
    coords_df <- df[, c(lat_col, long_col, setdiff(names(df), c(lat_col, long_col)))]
    names(coords_df)[1:2] <- c("lat", "long") # Standardize column names
  } else {
    if (is.null(lat) || is.null(long)) {
      stop("Either provide 'lat' and 'long' vectors or a dataframe with latitude and longitude columns.")
    }
    coords_df <- data.frame(lat = lat, long = long)
  }

  # Ensure coordinates are unique
  coords_df <- coords_df %>%
    dplyr::distinct(lat, long, .keep_all = TRUE)

  # If countries are provided, prepare the country codes
  if (!is.null(countries)) {
    message("Country identifiers provided. Skipping geocoding...")

    if (format_countries != "iso3c") {
      # Convert country identifiers to iso3c
      original_countries <- countries
      countries <- suppressWarnings(countrycode::countrycode(countries, 
                                                           origin = format_countries, 
                                                           destination = "iso3c"))

      # Check for failed conversions
      failed_countries <- original_countries[is.na(countries)]
      if (length(failed_countries) > 0) {
        warning("Could not convert to iso3c codes: ",
                paste(shQuote(failed_countries), collapse = ", "))
      }
    }

    matched_countries <- unique(countries[!is.na(countries)])
    results <- coords_df
  } else { 
    # Perform reverse geocoding to get country codes
    tryCatch({
      results <- tidygeocoder::reverse_geocode(
        coords_df, 
        lat = "lat", 
        long = "long", 
        method = "osm", 
        full_results = TRUE
      ) %>%
        dplyr::select("lat", "long", dplyr::everything(), "country_code") %>%
        dplyr::mutate(
          country_code = toupper(.data$country_code),
          GID_0 = countrycode::countrycode(.data$country_code, "iso2c", "iso3c")
        )
      
      matched_countries <- unique(results$GID_0)
    }, error = function(e) {
      stop(
        "Failed to geocode coordinates. This could be due to:\n",
        "1. No internet connection\n",
        "2. OpenStreetMap service unavailable\n",
        "3. Request timeout\n",
        "Consider providing country codes directly using the 'countries' parameter.\n",
        "Original error: ", e$message
      )
    })
  }

  # Get geometries using getDOSE_geom
  dose_geom <- getDOSE_geom(path = path, countries = matched_countries, download = download) %>%
    dplyr::select("GID_1", "geom")

  # Match coordinates to geometries
  coords_sf <- sf::st_as_sf(results, coords = c("long", "lat"), 
                           crs = sf::st_crs(dose_geom), remove = FALSE)

  message("Matching coordinates to subdivisions...")
  matched_data <- sf::st_join(coords_sf, dose_geom)

  # Get DOSE data and join with matched geometries
  dose_data <- getDOSE(path = path, years = years) %>%
    dplyr::select(-"GID_0")

  final_data <- dplyr::left_join(matched_data, dose_data, by = "GID_1")

  return(as.data.frame(final_data))
}