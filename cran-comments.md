## subincome R 0.2.2

This is a resubmission. In this version I have:
* Removed writing to user's home filespace by default (using tempdir() instead)
* Added explicit path parameter througout to allow users to specify custom storage locations
* Added download confirmation for large files with option to skip in non-interactive sessions

## Test environments 
* local Windows 10 install, R 4.3.1
* win-builder (devel and release)
* mac-builder (release)
* GitHub Actions:
  * windows-latest (devel, release, oldrel-1)
  * macos-latest (devel, release, oldrel-1)
  * ubuntu-latest (devel, release, oldrel-1)

## R CMD check results

### local, mac-builder and GitHub Actions:

0 errors | 0 warnings | 0 notes

### win-builder:

0 errors | 0 warnings | 1 note

checking CRAN incoming feasibility ... NOTE
NOTE Maintainer: 'Pablo García Guzmán <garciagp@ebrd.com>'

New submission

## Downstream dependencies
There are currently no downstream dependencies for this package.
