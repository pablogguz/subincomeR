# subincomeR 0.3.0

* Updated DOSE dataset to version 2.10

# subincomeR 0.2.2

* Removed writing to user's home filespace by default (using tempdir() instead)
* Added explicit path parameter throughout to allow users to specify custom storage locations
* Added download confirmation for large files with option to skip in non-interactive sessions

# subincomeR 0.2.1

* Fixed minor style issues in DESCRIPTION file

# subincomeR 0.2.0

* Added the `getDOSE_geom()` function to explicitly download the geometries of the sub-national regions

# subincomeR 0.1.3

* Updated DOSE dataset to version 2.9
* Improved download handling to better manage corrupted downloads and connection issues

# subincomeR 0.1.2

* Added the option to specify the path where the `.gpkg` file with the sub-national geometries would be stored

# subincomeR 0.1.1

* Added the option to pre-specify country identifiers in ```matchDOSE()``` to skip the first step of the geocoding process

# subincomeR 0.1.0

* Initial release
