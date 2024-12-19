
<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN status](https://www.r-pkg.org/badges/version/subincomeR)](https://CRAN.R-project.org/package=subincomeR)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/subincomeR)](https://cran.r-project.org/package=subincomeR)
[![R-CMD-check](https://github.com/pablogguz/subincomeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pablogguz/subincomeR/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# subincomeR <a href="https://pablogguz.github.io/subincomeR/"><img src="man/figures/logo.png" align="right" height="200" alt="subincomeR website" /></a>

`subincomeR` is an R package providing tools for accessing and analyzing the MCC-PIK Database Of Sub-national Economic Output ([DOSE](https://www.nature.com/articles/s41597-023-02323-8)). DOSE is a comprehensive global dataset of sub-national income covering over 1,600 regions across 83 countries from 1960 to 2020, compiled from official statistical agencies, yearbooks, and academic sources.

DOSE provides data at the first administrative level (GADM-1), which includes subnational divisions like states, provinces, or regions. [GADM](https://gadm.org/) (Global Administrative Areas Database) is a spatial database of the world's administrative boundaries, providing a standardized system for defining administrative divisions across countries. For example, GADM-1 corresponds to states in the United States, départements in France, or provinces in China. The dataset is available for download at [Zenodo](https://zenodo.org/records/13773040). You can find all the documentation and metadata in [Wenz et al. (2023)](https://www.nature.com/articles/s41597-023-02323-8).

## Features 
-   **Easy access**: download and cache DOSE data locally, including geometries for each region
-   **Spatial integration**: Match coordinates to DOSE regions using GADM boundaries

![](man/figures/map.png)

## Installation 

You can install the released version of `subincomeR` from CRAN with:

``` r
install.packages("subincomeR")
```

Alternatively, you can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("pablogguz/subincomeR")
```

## Examples

```r
# Load the complete dataset
data <- getDOSE()

# Load data for specific years
data_2019 <- getDOSE(years = 2019)

# Match coordinates to regions
matched_data <- matchDOSE(
  lat = c(19.4326, 51.5074),
  long = c(-99.1332, -0.1276)
)
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request. For major changes, please open an issue first to discuss what you would like to change.

## Author

**Pablo García Guzmán**  
EBRD

-----------------------------------------------------------------

## References 

- Wenz, L., Carr, R.D., Kögel, N. et al. (2023). DOSE – Global data set of reported sub-national economic output. *Scientific Data*, 10, 425. [https://doi.org/10.1038/s41597-023-023](https://doi.org/10.1038/s41597-023-02323-8)

- Wenz, L., Kotz, M., Kalkuhl, M., Carr, R., Kögel, N., Giesen, C., Reckwitz, A., Wedemeyer, J., & Ziegler, K. (2024). DOSE - Global dataset of reported subnational economic output [Data set]. Zenodo. https://doi.org/10.5281/zenodo.13773040
