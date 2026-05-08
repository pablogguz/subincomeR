# Match coordinates to DOSE dataset

This function matches input coordinates (latitude and longitude) to the
DOSE dataset. It accepts either vectors of latitudes and longitudes or a
dataframe containing these coordinates. Before matching, it ensures that
only unique coordinates are processed to avoid duplicating operations on
identical coordinates. It uses GADM-1 geometries to match coordinates to
regions and returns a dataframe with unique input coordinates and
matched DOSE data.

## Usage

``` r
matchDOSE(
  lat = NULL,
  long = NULL,
  df = NULL,
  lat_col = "lat",
  long_col = "long",
  years = NULL,
  countries = NULL,
  format_countries = "iso3c",
  path = NULL,
  download = FALSE
)
```

## Arguments

- lat:

  Optional vector of latitudes of the points to match. Required if no
  dataframe is provided.

- long:

  Optional vector of longitudes of the points to match. Required if no
  dataframe is provided.

- df:

  Optional dataframe containing coordinates and possibly additional
  columns. If provided, 'lat' and 'long' vectors should not be provided.
  The dataframe must include columns specified by 'lat_col' and
  'long_col' parameters.

- lat_col:

  Optional name of the latitude column in 'df'. Only used if 'df' is
  provided. Defaults to "lat".

- long_col:

  Optional name of the longitude column in 'df'. Only used if 'df' is
  provided. Defaults to "long".

- years:

  Optional vector of years for which to filter the DOSE dataset. If NULL
  (the default), a 1:m matching is performed and data for all years are
  returned.

- countries:

  Optional vector or dataframe column name of country identifiers. If
  provided, the function skips the country matching step. Can
  significantly reduce processing time.

- format_countries:

  Specifies the format of the country identifiers in 'countries'.
  Options are "country.name" (default), "iso3c", and "iso2c". This
  parameter is ignored if 'countries' is NULL.

- path:

  Optional character string specifying where to store downloaded files.
  If NULL (default), uses tempdir().

- download:

  Logical indicating whether to download without confirmation. Default
  is FALSE, which will prompt for confirmation in interactive sessions.
  Set to TRUE to skip confirmation.

## Value

A dataframe with input coordinates (and any additional input dataframe
columns) and matched DOSE data.

## Examples

``` r
# \donttest{
# Match coordinates using vectors
matched_data <- matchDOSE(lat = c(19.4326, 51.5074), 
                         long = c(-99.1332, -0.1276))
#> Passing 2 coordinates to the Nominatim single coordinate geocoder
#> Query completed in: 2 seconds
#> 
#> Geometries saved in /tmp/RtmpoyAdTs
#> Matching coordinates to subdivisions...
#> Loading DOSE dataset...

# Match coordinates using a dataframe
df <- data.frame(ID = 1:2, 
                 latitude = c(19.4326, 51.5074), 
                 longitude = c(-99.1332, -0.1276))
matched_data_df <- matchDOSE(df = df, 
                            lat_col = "latitude", 
                            long_col = "longitude")
#> Passing 2 coordinates to the Nominatim single coordinate geocoder
#> Query completed in: 2 seconds
#> 
#> Geometries saved in /tmp/RtmpoyAdTs
#> Matching coordinates to subdivisions...
#> Loading DOSE dataset...

# Match coordinates for a specific year
matched_data_2019 <- matchDOSE(lat = c(19.4326), 
                               long = c(-99.1332), 
                               years = 2019)
#> Passing 1 coordinate to the Nominatim single coordinate geocoder
#> Query completed in: 1 seconds
#> 
#> Geometries saved in /tmp/RtmpoyAdTs
#> Matching coordinates to subdivisions...
#> Loading DOSE dataset...

# Match coordinates with known countries
matched_data_countries <- matchDOSE(lat = c(19.4326, 51.5074),
                                   long = c(-99.1332, -0.1276),
                                   countries = c("MEX", "GBR"),
                                   format_countries = "iso3c")
#> Country identifiers provided. Skipping geocoding...
#> 
#> Geometries saved in /tmp/RtmpoyAdTs
#> Matching coordinates to subdivisions...
#> Loading DOSE dataset...
# }
```
