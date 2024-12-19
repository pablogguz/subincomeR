#' Download and load GADM-DOSE geometries
#'
#' This function downloads and loads GADM-DOSE geometries from a remote source.
#' The geometries are stored in a temporary directory by default, or in a user-specified
#' location if provided. The uncompressed geometries file is approximately 769 MB.
#'
#' @param path Optional character string specifying where to store the files.
#'        If NULL (default), uses tempdir().
#' @param countries Optional vector of ISO3C country codes to filter geometries.
#'        If NULL (default), all available geometries are returned.
#' @param download Logical indicating whether to download without confirmation.
#'        Default is FALSE, which will prompt for confirmation in interactive sessions.
#'        Set to TRUE to skip confirmation.
#' @return An sf object containing the GADM-DOSE geometries
#' @importFrom sf st_read
#' @importFrom zip unzip
#' @importFrom utils download.file menu
#' @importFrom curl curl_download
#' @export
#' @examples
#' \donttest{
#' # Load all geometries with download confirmation
#' geom_all <- getDOSE_geom()
#'
#' # Load geometries with automatic download
#' geom_auto <- getDOSE_geom(download = TRUE)
#'
#' # Load geometries for specific countries
#' geom_subset <- getDOSE_geom(
#'   countries = c("USA", "CAN", "MEX"),
#'   download = TRUE
#' )
#' }
getDOSE_geom <- function(path = NULL, countries = NULL, download = FALSE) {
  # Load required packages
  requireNamespace("sf", quietly = TRUE)
  requireNamespace("zip", quietly = TRUE)
  requireNamespace("curl", quietly = TRUE)

  # Input validation
  if (!is.null(countries) && !is.character(countries)) {
    stop("'countries' must be a character vector of country codes")
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

  # Define file paths
  gpkg_path <- file.path(storage_dir, "gadm_geom.gpkg")
  zip_path <- file.path(storage_dir, "gadm_geom.zip")

  # URL of the zipped geopackage file
  zip_url <- "https://www.dropbox.com/scl/fi/em780r55pmi7r44602npe/gadm_geom.zip?rlkey=f6w82ac5rmzm27se1hkcb5k7g&dl=1"

  # Function to check if zip file is valid
  is_valid_zip <- function(zip_path) {
    tryCatch({
      zip::zip_list(zip_path)
      return(TRUE)
    }, error = function(e) {
      return(FALSE)
    })
  }

  # Check if both zip and extracted file exist and are valid
  if (!file.exists(gpkg_path)) {
    need_download <- TRUE
    
    # Check if zip exists and is valid
    if (file.exists(zip_path)) {
      if (is_valid_zip(zip_path)) {
        message("Found valid zip file, extracting...")
        need_download <- FALSE
      } else {
        message("Found corrupted zip file, re-downloading...")
        file.remove(zip_path)
      }
    }
    
    if (need_download) {
      message("\nThe GADM-DOSE geometries file is approximately 769 MB when uncompressed.")
      
      if (!download && interactive()) {
        proceed <- utils::menu(c("Yes", "No"), title="Would you like to proceed with the download?")
        if (proceed != 1) {
          stop("Download cancelled by user.")
        }
      }
      
      message("\nDownloading GADM-DOSE geometries...")
      
      download_success <- FALSE
      
      # First attempt: try curl
      if (requireNamespace("curl", quietly = TRUE)) {
        tryCatch({
          curl::curl_download(url = zip_url, destfile = zip_path)
          # Verify if the downloaded file is a valid zip
          if (is_valid_zip(zip_path)) {
            download_success <- TRUE
            message("Download successful using curl")
          } else {
            message("curl download resulted in corrupted file, trying alternative method...")
            file.remove(zip_path)
          }
        }, error = function(e) {
          message("curl download failed, trying alternative method...")
        })
      }
      
      # Second attempt: try wininet (Windows) or default method
      if (!download_success) {
        tryCatch({
          suppressWarnings({
            if (.Platform$OS.type == "windows") {
              download.file(zip_url, destfile = zip_path, mode = "wb", 
                          method = "wininet", quiet = TRUE)
            } else {
              download.file(zip_url, destfile = zip_path, mode = "wb", 
                          quiet = TRUE)
            }
          })
          if (is_valid_zip(zip_path)) {
            download_success <- TRUE
            message("Download successful using alternative method")
          } else {
            stop("Downloaded file is corrupted")
          }
        }, error = function(e) {
          stop("Failed to download the dataset. Error: ", e$message)
        })
      }
    }
    
    # Unzip if needed
    if (!file.exists(gpkg_path) && file.exists(zip_path) && is_valid_zip(zip_path)) {
      message("Extracting files...")
      # Unzip to the storage directory
      suppressWarnings(unzip(zipfile = zip_path, exdir = storage_dir))
      
      # Verify the file exists after unzipping
      if (!file.exists(gpkg_path)) {
        stop("Failed to extract gpkg file to the expected location: ", gpkg_path)
      }

      # Clean up zip file after successful extraction
      unlink(zip_path)
    }
  }

  # Construct SQL query based on countries parameter
  if (!is.null(countries)) {
    query_str <- paste0("SELECT * FROM gadm_geom WHERE GID_0 IN ('", 
                       paste(countries, collapse="','"), "')")
  } else {
    query_str <- "SELECT * FROM gadm_geom"
  }

  # Load geometries
  result <- sf::st_read(gpkg_path, query = query_str, quiet = TRUE)
  
  # Display storage location
  message(sprintf("\nGeometries saved in %s", storage_dir))
  
  return(result)
}