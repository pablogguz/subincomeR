# Download and load the DOSE dataset into memory

This function downloads the DOSE dataset from Zenodo and loads it into
memory as a dataframe. It allows for optional filtering of the dataset
based on specific years and/or countries. The country format can be
specified to ensure correct filtering. The function automatically
handles different download methods based on system capabilities.

## Usage

``` r
getDOSE(
  years = NULL,
  countries = NULL,
  format_countries = "country.name",
  path = NULL
)
```

## Arguments

- years:

  Optional vector of years for which to filter the DOSE dataset. If NULL
  (the default), data for all years are returned.

- countries:

  Optional vector of countries for which to filter the DOSE dataset.
  Countries can be specified in ISO2C, ISO3C, or country name format.
  Use the format_countries parameter to specify the format of the
  countries vector.

- format_countries:

  The format of the countries provided in the countries parameter.
  Acceptable values are 'iso2c', 'iso3c', or 'country.name'. Default is
  'country.name'. This parameter is used only if the countries parameter
  is not NULL.

- path:

  Optional character string specifying where to store the downloaded
  data. If NULL (default), uses tempdir().

## Value

A dataframe containing the filtered DOSE dataset based on the input
parameters.

## Examples

``` r
# \donttest{
# Load the entire dataset
data_all <- getDOSE()
#> DOSE dataset not found. Downloading...
#> Download successful using curl
#> DOSE dataset successfully downloaded and stored in /tmp/Rtmpt7ZLZW
#> Loading DOSE dataset...

# Load dataset filtered by specific years
data_2018_2019 <- getDOSE(years = c(2018, 2019))
#> Loading DOSE dataset...

# Load dataset filtered by specific countries (using ISO3C codes)
data_usa_can <- getDOSE(countries = c('USA', 'CAN'), format_countries = 'iso3c')
#> Loading DOSE dataset...

# Load dataset filtered by year and countries (using country names)
data_mex_2019 <- getDOSE(years = 2019, countries = c('Mexico'), 
                         format_countries = 'country.name')
#> Loading DOSE dataset...
# }
```
