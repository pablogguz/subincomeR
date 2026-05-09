
#*******************************************************************************
#* This script: prepares .gpkg file with GADM-1 v3.6 geometries
#*
#* Input:
#*
#* - GADM v3.6 dataset, downloaded from https://gadm.org/download_world36.html (layers version)
#* - DOSE geopackage with custom geometries for non-GADM regions, downloaded from
#*   https://zenodo.org/records/20035157 (file: DOSE_additional_regions_V2_14.gpkg)
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
root <- path.expand("~/Dropbox/doseR_raw/")

raw <- paste0(root, "raw/")
proc <- paste0(root, "proc/")
#proc_git <- path.expand("~/Documents/GitHub/subincomeR/external-data/")

# Script starts ----------------------------------------------------------------

# List the layers in the geopackage
layers <- st_layers(paste0(raw, "gadm36_levels.gpkg"))
print(layers$name)

# Read DOSE custom geometries (the "additional regions" gpkg) ----
dose <- st_read(paste0(raw, "DOSE_additional_regions_V2_14.gpkg")) %>%
  select(GID_0, NAME_0, GID_1, NAME_1, ENGTYPE_1, geom) %>%
  st_zm()

# Read DOSE CSV — the source of truth for which GID_1 codes the data uses.
# The CSV decides per country whether DOSE references GADM-style codes
# (e.g. CAN.1_1..CAN.13_1) or DOSE-additional-style codes (e.g. PHL.100_1+).
csv_path <- paste0(raw, "DOSE_V2.14.csv")
if (!file.exists(csv_path)) {
  download.file(
    "https://zenodo.org/records/20035157/files/DOSE_V2.14.csv?download=1",
    destfile = csv_path, mode = "wb"
  )
}
dose_csv <- read.csv(csv_path)
csv_gid1      <- unique(dose_csv$GID_1)
csv_countries <- unique(dose_csv$GID_0)

# Read GADM 3.6 ----
# Filter rules:
#  1. For DOSE-covered countries: keep only GADM polygons whose GID_1 is
#     referenced in the CSV. This drops the 81 unused PHL provinces, the
#     85 unused MKD ones, etc. — they're clutter that shows up as gray on
#     the landing-page map and confuses matchDOSE's point-in-polygon match.
#  2. For non-DOSE countries: keep all GADM polygons, so matchDOSE still
#     resolves the GID_1 of arbitrary coordinates worldwide.
#  3. Drop any GADM polygon whose GID_1 is also supplied by DOSE additional
#     regions — DOSE's geometry takes precedence (e.g. KAZ.1_1..KAZ.14_1
#     are in both, and the DOSE shape is the canonical one).
gadm36 <- st_read(paste0(raw, "gadm36_levels.gpkg"), layer = "level1") %>%
  select(GID_0, NAME_0, GID_1, NAME_1, ENGTYPE_1, geom) %>%
  filter(!(GID_0 %in% csv_countries) | GID_1 %in% csv_gid1) %>%
  filter(!(GID_1 %in% dose$GID_1)) %>%
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

