#' Match coordinates to DOSE dataset
#'
#' This function matches input coordinates (latitude and longitude) to the DOSE dataset.
#' It accepts either vectors of latitudes and longitudes or a dataframe containing
#' these coordinates. Before matching, it ensures that only unique coordinates are processed
#' to avoid duplicating operations on identical coordinates. It downloads the GADM-1 geometries
#' from a specified URL if not already cached locally, unzips it, and returns a dataframe with
#' unique input coordinates and matched DOSE data. Optionally, the function can filter the DOSE dataset by specific years.
#' Additionally, users can specify countries directly to skip the country matching step, potentially saving processing time.
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
#'        If provided, the function skips the country matching step. The identifiers can be in the format specified
#'        by 'format_countries'. This can significantly reduce processing time.
#' @param format_countries Specifies the format of the country identifiers in 'countries'.
#'        Options are "country.name" (default), "iso3c", and "iso2c". This parameter is ignored if 'countries' is NULL.
#' @param gpkg_path Optional path to store the .gpkg file. If not specified, the default cache directory is used.
#' @return A dataframe with input coordinates (and any additional input dataframe columns) and matched DOSE data.
#' @import sf
#' @importFrom dplyr filter left_join select mutate
#' @importFrom rappdirs user_cache_dir
#' @importFrom zip unzip
#' @importFrom tidygeocoder reverse_geocode
#' @importFrom countrycode countrycode
#' @importFrom utils download.file read.csv
#' @importFrom rlang .data
#' @importFrom curl curl_download
#' @export
#' @examples
#' # Match two pairs of coordinates to DOSE using vectors
#' matched_data_vectors <- matchDOSE(lat = c(19.4326, 51.5074), long = c(-99.1332, -0.1276))
#'
#' # Match two pairs of coordinates to DOSE using a dataframe
#' df <- data.frame(ID = 1:2, latitude = c(19.4326, 51.5074), longitude = c(-99.1332, -0.1276))
#' matched_data_df <- matchDOSE(df = df, lat_col = "latitude", long_col = "longitude")
#'
#' # Match coordinates to DOSE for a specific year using vectors
#' matched_data_2019 <- matchDOSE(lat = c(19.4326), long = c(-99.1332), years = 2019)
#'
#' # Match coordinates and specify countries to skip country matching
#' matched_data_with_countries <- matchDOSE(lat = c(19.4326, 51.5074), long = c(-99.1332, -0.1276),
#'                                          countries = c("MEX", "GBR"), format_countries = "iso3c")

matchDOSE <- function(lat = NULL, long = NULL, df = NULL, lat_col = "lat",
                      long_col = "long", years = NULL, countries = NULL,
                      format_countries = "iso3c", gpkg_path = NULL) {

  # Ensure necessary packages are loaded
  requireNamespace("sf", quietly = TRUE)
  requireNamespace("zip", quietly = TRUE)
  requireNamespace("rappdirs", quietly = TRUE)
  requireNamespace("tidygeocoder", quietly = TRUE)
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("countrycode", quietly = TRUE)
  requireNamespace("curl", quietly = TRUE)

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
    names(coords_df)[1:2] <- c("lat", "long") # Standardize column names for internal use

  } else {

    if (is.null(lat) || is.null(long)) {
      stop("Either provide 'lat' and 'long' vectors or a dataframe with specified latitude and longitude column names.")
    }

    # Create a dataframe from lat and long vectors
    coords_df <- data.frame(lat = lat, long = long)
  }

  # Ensure coordinates are unique in the coordinates df
  coords_df <- coords_df %>%
    dplyr::group_by(.data$lat, .data$long) %>%
    dplyr::filter(dplyr::row_number()==1) %>%
    dplyr::ungroup()

  # Define the cache directory using rappdirs
  cache_dir <- rappdirs::user_cache_dir("subincomeR")
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  # If gpkg_path is provided, use it; otherwise, use the default cache directory
  if (is.null(gpkg_path)) {
    gpkg_path <- file.path(cache_dir, "gadm_geom.gpkg")
  } else {
    dir.create(dirname(gpkg_path), recursive = TRUE, showWarnings = FALSE)
  }
  zip_path <- file.path(dirname(gpkg_path), "gadm_geom.zip")

  # URL of the zipped geopackage file hosted online
  zip_url <- "https://www.dropbox.com/scl/fi/em780r55pmi7r44602npe/gadm_geom.zip?rlkey=f6w82ac5rmzm27se1hkcb5k7g&dl=1" # Update this URL

  # Download the zipped file if it's not already cached
  if (!file.exists(zip_path)) {
    message("Geometries not found in machine. Downloading GADM-DOSE geometries...")

    # Use tryCatch to suppress warnings and show a progress bar
    tryCatch({
      #download.file(zip_url, zip_path, mode = "wb", quiet = TRUE, method = "auto", showProgress = TRUE)
      curl::curl_download(url = zip_url, destfile = zip_path)

      message("GADM-DOSE successfully downloaded and stored in ", cache_dir)

    }, warning = function(w) {})

    # Unzip without showing any unzip warnings/messages
    suppressWarnings(unzip(zipfile = zip_path, exdir = cache_dir))
  }

  # If countries are provided, prepare the country codes
  if (!is.null(countries) && !is.null(format_countries)) {

    message("Country identifiers are provided. Skipping geocoding...")

    if (format_countries != "iso3c") {

      # Attempt to convert country identifiers to iso3c
      original_countries <- countries  # Preserve the original input for reference

      countries <- suppressWarnings(countrycode::countrycode(countries, origin = format_countries, destination = "iso3c"))

      # Identify which countries could not be converted (i.e., resulted in NA)
      failed_countries <- original_countries[is.na(countries)]

      if (length(failed_countries) > 0) {
        warning("The following country identifiers could not be converted to iso3c codes: ",
                paste(shQuote(failed_countries), collapse = ", "),
                ". Please double-check your country identifiers for accuracy or use iso3c codes directly.")
      }

    }

    matched_countries <- unique(countries)

    results <- coords_df # Simply assign the df with lat and long to results df

  } else { # If not, perform reverse geocoding to get the country code
    coords_df <- coords_df %>%
      dplyr::select(.data$lat, .data$long) %>%
      dplyr::distinct(.data$lat, .data$long)

    results <- tidygeocoder::reverse_geocode(coords_df, lat = "lat", long = "long", method = "osm", full_results = TRUE) %>%
      dplyr::select(lat, long, .data$country_code) %>%
      dplyr::mutate(country_code = toupper(.data$country_code),
                    GID_0 = countrycode::countrycode(.data$country_code, "iso2c", "iso3c"))

    matched_countries <- unique(results$GID_0)
  }

  # Load filtered geometries from .gpkg based on matched countries
  query_str <- paste0("SELECT * FROM gadm_geom WHERE GID_0 IN ('", paste(matched_countries, collapse="','"), "')")
  dose_geom <- sf::st_read(gpkg_path, query = query_str, quiet = TRUE) %>%
    dplyr::select(.data$GID_1, .data$geom)

  # Extract GID_1 IDs from polygons
  coords_sf <- sf::st_as_sf(results, coords = c("long", "lat"), crs = sf::st_crs(dose_geom), remove = FALSE)

  message("Matching coordinates to subdivisions...")
  matched_data <- sf::st_join(coords_sf, dose_geom)

  # Load the DOSE dataset
  dose_data <- getDOSE() %>%
    dplyr::select(-.data$GID_0)

  # Filter DOSE dataset by year if provided
  if (!is.null(years)) {
    message("Filtering years...")
    dose_data <- dose_data %>%
      dplyr::filter(.data$year %in% years)
  }

  # Assume 'GID_1' is the common key; adjust as necessary
  final_data <- left_join(matched_data, dose_data, by = "GID_1")

  return(as.data.frame(final_data))
}
