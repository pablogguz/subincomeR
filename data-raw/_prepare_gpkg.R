
#*******************************************************************************
#* This script: prepares .gpkg file with GADM-1 v3.6 geometries
#*
#* Input:
#*
#* - GADM v3.6 dataset, downloaded from https://gadm.org/download_world36.html (layers version)
#* - DOSE geopackage with custom geometries for non-GADM regions, downloaded from https://zenodo.org/records/7573249
#*
#* Output:
#*
#* - Some cute charts
#*
#* Code by Pablo Garcia Guzman
#*******************************************************************************

packages_to_load <- c("sf",
                      "dplyr",
                      "terra",
                      "zip")

package.check <- lapply(
  packages_to_load,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
    }
  }
)

lapply(packages_to_load, require, character=T)

# Set paths ----
username <- Sys.getenv("USERNAME")

root <- paste0("C:/Users/", username, "/Dropbox/doseR_raw/")

raw <- paste0(root, "raw/")
proc <- paste0(root, "proc/")
#proc_git <- paste0("C:/Users/", username, "/Documents/GitHub/subincomeR/external-data/")

# Script starts ----------------------------------------------------------------

# List the layers in the geopackage
layers <- st_layers(paste0(raw, "gadm36_levels.gpkg"))
print(layers$name)

# Read DOSE custom geometries ----
dose <- st_read(paste0(raw, "DOSE_shapefiles.gpkg")) %>%
  select(GID_0, NAME_0, GID_1, NAME_1, ENGTYPE_1, geom) %>%
  st_zm()

# Read GADM 3.6 ----
gadm36 <- st_read(paste0(raw, "gadm36_levels.gpkg"), layer = "level1") %>%
  select(GID_0, NAME_0, GID_1, NAME_1, ENGTYPE_1, geom) %>%
  # remove non-GADM regions in DOSE to avoid 1:m matching
  filter(!(GID_0 %in% dose$GID_0)) %>%
  st_zm()

# Append ----
data <- bind_rows(gadm36, dose)

# Make the geometries valid ----
# data <- st_make_valid(data)

## Save ----
st_write(data, paste0(proc, "/gadm_geom.gpkg"), delete_layer = TRUE, update = TRUE)

## Compress ----
zip::zipr(zipfile = paste0(proc, "/gadm_geom.zip"),
          files = paste0(proc, "/gadm_geom.gpkg"),
          compression_level = 9) # Maximum compression

## Delete the .gpkg file ----
file.remove(paste0(proc, "/gadm_geom.gpkg"))

