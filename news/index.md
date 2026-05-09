# Changelog

## subincomeR 0.5.0

CRAN release: 2026-05-08

- Updated DOSE dataset to version 2.14 (Zenodo record 20035157)
- Replaced the magrittr pipe (`%>%`) with the native R pipe (`|>`) in
  package code, addressing the CRAN NOTE flagged after `sf` stopped
  re-exporting `%>%` (see r-spatial/sf#2607)
- Declared a minimum R version of 4.1.0 (required by the native pipe)

## subincomeR 0.4.0

CRAN release: 2025-09-11

- Updated DOSE dataset to version 2.11

## subincomeR 0.3.0

CRAN release: 2025-02-16

- Updated DOSE dataset to version 2.10

## subincomeR 0.2.2

CRAN release: 2024-12-19

- Removed writing to user’s home filespace by default (using tempdir()
  instead)
- Added explicit path parameter throughout to allow users to specify
  custom storage locations
- Added download confirmation for large files with option to skip in
  non-interactive sessions

## subincomeR 0.2.1

- Fixed minor style issues in DESCRIPTION file

## subincomeR 0.2.0

- Added the
  [`getDOSE_geom()`](https://pablogguz.github.io/subincomeR/reference/getDOSE_geom.md)
  function to explicitly download the geometries of the sub-national
  regions

## subincomeR 0.1.3

- Updated DOSE dataset to version 2.9
- Improved download handling to better manage corrupted downloads and
  connection issues

## subincomeR 0.1.2

- Added the option to specify the path where the `.gpkg` file with the
  sub-national geometries would be stored

## subincomeR 0.1.1

- Added the option to pre-specify country identifiers in
  [`matchDOSE()`](https://pablogguz.github.io/subincomeR/reference/matchDOSE.md)
  to skip the first step of the geocoding process

## subincomeR 0.1.0

- Initial release
