#' Download and load the DOSE dataset into memory
#'
#' This function downloads the DOSE dataset from Zenodo and loads it into memory as a dataframe.
#' It allows for optional filtering of the dataset based on specific years and/or countries.
#' The country format can be specified to ensure correct filtering. The function automatically
#' handles different download methods based on system capabilities.
#'
#' @param years Optional vector of years for which to filter the DOSE dataset.
#'        If NULL (the default), data for all years are returned.
#' @param countries Optional vector of countries for which to filter the DOSE dataset.
#'        Countries can be specified in ISO2C, ISO3C, or country name format.
#'        Use the format_countries parameter to specify the format of the countries vector.
#' @param format_countries The format of the countries provided in the countries parameter.
#'        Acceptable values are 'iso2c', 'iso3c', or 'country.name'. Default is 'country.name'.
#'        This parameter is used only if the countries parameter is not NULL.
#' @param path Optional character string specifying where to store the downloaded data.
#'        If NULL (default), uses tempdir().
#' @return A dataframe containing the filtered DOSE dataset based on the input parameters.
#' @importFrom dplyr filter
#' @importFrom countrycode countrycode
#' @importFrom utils download.file read.csv
#' @importFrom rlang .data
#' @importFrom curl curl_download
#' @export
#' @examples
#' \donttest{
#' # Load the entire dataset
#' data_all <- getDOSE()
#'
#' # Load dataset filtered by specific years
#' data_2018_2019 <- getDOSE(years = c(2018, 2019))
#'
#' # Load dataset filtered by specific countries (using ISO3C codes)
#' data_usa_can <- getDOSE(countries = c('USA', 'CAN'), format_countries = 'iso3c')
#'
#' # Load dataset filtered by year and countries (using country names)
#' data_mex_2019 <- getDOSE(years = 2019, countries = c('Mexico'), 
#'                          format_countries = 'country.name')
#' }

getDOSE <- function(years = NULL, countries = NULL, format_countries = "country.name",
                   path = NULL) {
  # Load required packages
  requireNamespace("countrycode", quietly = TRUE)
  requireNamespace("dplyr", quietly = TRUE)

  # Add validation for years parameter
  if (!is.null(years)) {
    if (!is.numeric(years)) {
      stop("'years' must be numeric")
    }
  }

  # Validate format_countries input
  valid_formats <- c("iso2c", "iso3c", "country.name")
  if (!format_countries %in% valid_formats) {
    stop("Invalid format_countries value. Please use one of: 'iso2c', 'iso3c', or 'country.name'.")
  }

  # Validate and set up storage directory
  if (is.null(path)) {
    storage_dir <- tempdir()
  } else {
    if (!is.character(path) || length(path) != 1) {
      stop("'path' must be a single character string")
    }
    storage_dir <- path
    dir.create(storage_dir, recursive = TRUE, showWarnings = FALSE)
  }

  # Define file path
  file_path <- file.path(storage_dir, "DOSE_V2.9.csv")

  # Check if the DOSE dataset already exists
  if (!file.exists(file_path)) {
    # If not, download and save it
    message("DOSE dataset not found. Downloading...")
    zip_url <- "https://zenodo.org/records/13773040/files/DOSE_V2.9.csv?download=1"

    download_success <- FALSE
    
    # First attempt: try curl
    if (requireNamespace("curl", quietly = TRUE)) {
      tryCatch({
        curl::curl_download(url = zip_url, destfile = file_path)
        download_success <- TRUE
        message("Download successful using curl")
      }, error = function(e) {
        message("curl download failed, trying alternative method...")
      })
    }
    
    # Second attempt: try wininet (Windows) or default method
    if (!download_success) {
      tryCatch({
        suppressWarnings({
          if (.Platform$OS.type == "windows") {
            download.file(zip_url, destfile = file_path, mode = "wb", 
                        method = "wininet", quiet = TRUE)
          } else {
            download.file(zip_url, destfile = file_path, mode = "wb", 
                        quiet = TRUE)
          }
        })
        download_success <- TRUE
        message("Download successful using alternative method")
      }, error = function(e) {
        stop("Failed to download the dataset. Error: ", e$message)
      })
    }

    if (download_success) {
      message("DOSE dataset successfully downloaded and stored in ", storage_dir)
    }
  }

  # Read the dataset
  message("Loading DOSE dataset...")
  dose_data <- read.csv(file_path, stringsAsFactors = FALSE)

  # Filter by years if provided
  if (!is.null(years)) {
    dose_data <- dose_data %>%
      dplyr::filter(.data$year %in% years)
  }

  # Filter by countries if provided
  if (!is.null(countries)) {
    iso3c_countries <- countrycode::countrycode(countries, origin = format_countries, 
                                              destination = "iso3c", warn = FALSE)
    dose_data <- dose_data %>%
      dplyr::filter(.data$GID_0 %in% iso3c_countries)
  }

  return(dose_data)
}