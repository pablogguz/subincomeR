# Download and load GADM-DOSE geometries

This function downloads and loads GADM-DOSE geometries from a remote
source. The geometries are stored in a temporary directory by default,
or in a user-specified location if provided. The uncompressed geometries
file is approximately 769 MB.

## Usage

``` r
getDOSE_geom(path = NULL, countries = NULL, download = FALSE)
```

## Arguments

- path:

  Optional character string specifying where to store the files. If NULL
  (default), uses tempdir().

- countries:

  Optional vector of ISO3C country codes to filter geometries. If NULL
  (default), all available geometries are returned.

- download:

  Logical indicating whether to download without confirmation. Default
  is FALSE, which will prompt for confirmation in interactive sessions.
  Set to TRUE to skip confirmation.

## Value

An sf object containing the GADM-DOSE geometries

## Examples

``` r
# \donttest{
# Load all geometries with download confirmation
geom_all <- getDOSE_geom()
#> 
#> The GADM-DOSE geometries file is approximately 769 MB when uncompressed.
#> 
#> Downloading GADM-DOSE geometries...
#> Download successful using curl
#> Extracting files...
#> 
#> Geometries saved in /tmp/RtmpftQIZh

# Load geometries with automatic download
geom_auto <- getDOSE_geom(download = TRUE)
#> 
#> Geometries saved in /tmp/RtmpftQIZh

# Load geometries for specific countries
geom_subset <- getDOSE_geom(
  countries = c("USA", "CAN", "MEX"),
  download = TRUE
)
#> 
#> Geometries saved in /tmp/RtmpftQIZh
# }
```
