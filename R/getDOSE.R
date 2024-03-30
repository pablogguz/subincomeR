#' Download and load the DOSE dataset into memory
#'
#' This function downloads the DOSE dataset from Zenodo and loads it into memory as a dataframe.
#' It allows for optional filtering of the dataset based on specific years and/or countries.
#' The country format can be specified to ensure correct filtering.
#'
#' @param years Optional vector of years for which to filter the DOSE dataset.
#'        If NULL (the default), data for all years are returned.
#' @param countries Optional vector of countries for which to filter the DOSE dataset.
#'        Countries can be specified in ISO2C, ISO3C, or country name format.
#'        Use the format_countries parameter to specify the format of the countries vector.
#' @param format_countries The format of the countries provided in the countries parameter.
#'        Acceptable values are 'iso2c', 'iso3c', or 'country.name'. Default is 'country.name'.
#'        This parameter is used only if the countries parameter is not NULL.
#' @return A dataframe containing the filtered DOSE dataset based on the input parameters.
#' @importFrom rappdirs user_cache_dir
#' @importFrom dplyr filter
#' @importFrom countrycode countrycode
#' @importFrom utils download.file read.csv
#' @importFrom rlang .data
#' @importFrom curl curl_download
#' @export
#' @examples
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
#' data_mex_2019 <- getDOSE(years = 2019, countries = c('Mexico'), format_countries = 'country.name')

getDOSE <- function(years = NULL, countries = NULL, format_countries = "country.name") {

  # Load required packages
  requireNamespace("rappdirs", quietly = TRUE)
  requireNamespace("countrycode", quietly = TRUE)
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("curl", quietly = TRUE)

  # Validate format_countries input
  valid_formats <- c("iso2c", "iso3c", "country.name")
  if (!format_countries %in% valid_formats) {
    stop("Invalid format_countries value. Please use one of: 'iso2c', 'iso3c', or 'country.name'.")
  }

  # Define cache directory and file path
  cache_dir <- rappdirs::user_cache_dir("subincomeR")
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  file_path <- file.path(cache_dir, "DOSE_V2.csv")

  # Check if the DOSE dataset already exists in the cache
  if (!file.exists(file_path)) {
    # If not, download and save it
    message("DOSE dataset not found on machine. Downloading...")
    zip_url <- "https://zenodo.org/records/7573249/files/DOSE_V2.csv?download=1"

    # download.file(url, destfile = file_path, mode = "wb", quiet = TRUE, showProgress = TRUE)
    curl::curl_download(url = zip_url, destfile = file_path)

    message("DOSE dataset successfully downloaded and stored in ", cache_dir)
  }

  # Read the dataset from the cache
  message("Loading DOSE dataset...")
  dose_data <- read.csv(file_path, stringsAsFactors = FALSE)

  # Filter by years if provided
  if (!is.null(years)) {
    dose_data <- dose_data %>%
      dplyr::filter(.data$year %in% years)
  }

  if (!is.null(countries)) {
    iso3c_countries <- countrycode::countrycode(countries, origin = format_countries, destination = "iso3c", warn = FALSE)
    dose_data <- dose_data %>%
      dplyr::filter(.data$GID_0 %in% iso3c_countries)
  }

  return(dose_data)

}
