#' Download and load GADM-DOSE geometries
#'
#' This function downloads and loads GADM-DOSE geometries from a remote source.
#' The geometries are cached locally for future use. Users can specify a custom
#' path for storage or use the default cache directory.
#'
#' @param gpkg_path Optional path to store the .gpkg file. If not specified,
#'        the default cache directory is used.
#' @param countries Optional vector of ISO3C country codes to filter geometries.
#'        If NULL (default), all available geometries are returned.
#' @return An sf object containing the GADM-DOSE geometries
#' @importFrom rappdirs user_cache_dir
#' @importFrom sf st_read
#' @importFrom zip unzip
#' @importFrom utils download.file
#' @importFrom curl curl_download
#' @export
#' @examples
#' \donttest{
#' # Load all geometries using default cache location
#' geom_all <- getDOSE_geom()
#'
#' # Load geometries for specific countries
#' geom_subset <- getDOSE_geom(countries = c("USA", "CAN", "MEX"))
#'
#' # Load geometries with custom storage location
#' geom_custom <- getDOSE_geom(gpkg_path = "~/my_data/gadm_geom.gpkg")
#' }
getDOSE_geom <- function(gpkg_path = NULL, countries = NULL) {
  # Load required packages
  requireNamespace("sf", quietly = TRUE)
  requireNamespace("zip", quietly = TRUE)
  requireNamespace("rappdirs", quietly = TRUE)
  requireNamespace("curl", quietly = TRUE)

  # Input validation
  if (!is.null(countries) && !is.character(countries)) {
    stop("'countries' must be a character vector of country codes")
  }
  
  if (!is.null(gpkg_path)) {
    if (!is.character(gpkg_path) || nchar(gpkg_path) == 0) {
      stop("gpkg_path must be a valid file path")
    }
    # Ensure directory exists
    dir.create(dirname(gpkg_path), recursive = TRUE, showWarnings = FALSE)
  }

  # Define cache directory using rappdirs
  cache_dir <- rappdirs::user_cache_dir("subincomeR")
  
  # If gpkg_path is provided, use it; otherwise, use default cache directory
  if (is.null(gpkg_path)) {
    gpkg_path <- file.path(cache_dir, "gadm_geom.gpkg")
  } else {
    dir.create(dirname(gpkg_path), recursive = TRUE, showWarnings = FALSE)
  }
  zip_path <- file.path(dirname(gpkg_path), "gadm_geom.zip")

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
      message("Geometries not found in machine. Downloading GADM-DOSE geometries...")
      
      # Create cache directory
      dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
      
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

      if (download_success) {
        message("GADM-DOSE geometries successfully downloaded and stored in ", cache_dir)
      }
    }
    
    # Unzip if needed
    if (!file.exists(gpkg_path) && file.exists(zip_path) && is_valid_zip(zip_path)) {
      message("Extracting files...")
      # Unzip directly to the cache directory
      suppressWarnings(unzip(zipfile = zip_path, exdir = dirname(gpkg_path)))
      
      # Verify the file exists after unzipping
      if (!file.exists(gpkg_path)) {
        stop("Failed to extract gpkg file to the expected location: ", gpkg_path)
      }
    }
  }

  # Construct SQL query based on countries parameter
  if (!is.null(countries)) {
    query_str <- paste0("SELECT * FROM gadm_geom WHERE GID_0 IN ('", 
                       paste(countries, collapse="','"), "')")
  } else {
    query_str <- "SELECT * FROM gadm_geom"
  }

  # Load and return geometries
  sf::st_read(gpkg_path, query = query_str, quiet = TRUE)
}