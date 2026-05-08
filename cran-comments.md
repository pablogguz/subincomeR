## subincomeR 0.5.0

In this version I have:
* Updated the link to the DOSE dataset repository to reflect the new
  version 2.14 (Zenodo record 20035157).
* Replaced the magrittr pipe (`%>%`) with the native R pipe (`|>`) in
  package code, resolving the CRAN check NOTE
  ("no visible global function definition for '%>%'") that surfaced
  once `sf` stopped re-exporting `%>%` (see r-spatial/sf#2607).
* Added a minimum R dependency of `R (>= 4.1.0)`, required by the
  native pipe.

## Test environments
* local macOS 15.5 (arm64), R 4.5.2
* win-builder (devel)
* mac-builder (release)
* GitHub Actions:
  * windows-latest (devel, release, oldrel-1)
  * macos-latest (devel, release, oldrel-1)
  * ubuntu-latest (devel, release, oldrel-1)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Downstream dependencies
There are currently no downstream dependencies for this package.
