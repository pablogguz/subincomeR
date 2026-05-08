# subincomeR — context for Claude

## What this is

An R package that wraps the MCC-PIK **DOSE** (Database Of Sub-national
Economic Output) dataset. It downloads the CSV from Zenodo, lets the
user filter it by year/country, and matches arbitrary lat/long
coordinates to GADM-1 polygons so each point gets the corresponding
sub-national income series.

Distributed on CRAN: <https://CRAN.R-project.org/package=subincomeR>.
Pkgdown site: <https://pablogguz.github.io/subincomeR/>.

## Source layout

- [DESCRIPTION](DESCRIPTION) — version, deps, Zenodo URL in description.
- [R/getDOSE.R](R/getDOSE.R) — downloads + loads the DOSE CSV.
- [R/getDOSE_geom.r](R/getDOSE_geom.r) — downloads + loads the GADM-DOSE
  geometries (the ~769 MB `.gpkg`, hosted on Dropbox, not Zenodo).
- [R/matchDOSE.R](R/matchDOSE.R) — point-to-region matching; uses
  `tidygeocoder` + `sf::st_join`.
- [R/subincomeR-package.R](R/subincomeR-package.R) — package-level docs.
- [vignettes/regional-convergence.Rmd](vignettes/regional-convergence.Rmd)
  — only vignette; loads `dplyr` so `%>%` is fine inside it.
- [data-raw/](data-raw/) — scripts for the hex logo and the landing-page
  map. Not part of the installed package; ignored via `.Rbuildignore`.
- [dev/prepare_release.r](dev/prepare_release.r) and
  [dev/prepare_CRAN.r](dev/prepare_CRAN.r) — the release / CRAN-submission
  recipe the maintainer follows (devtools, win/mac builders, etc.).
- [inst/WORDLIST](inst/WORDLIST) — `spelling::spell_check_package()` allowlist.
- [tests/spelling.R](tests/spelling.R) — runs the spell check during
  `R CMD check`.

## DOSE versioning

The Zenodo record ID and the CSV filename have to be bumped together
whenever upstream releases a new DOSE version.

- Zenodo record URL is referenced in: `DESCRIPTION`, `README.md`,
  `man/subincomeR-package.Rd`, and the download URL inside
  [R/getDOSE.R](R/getDOSE.R).
- CSV filename inside [R/getDOSE.R](R/getDOSE.R) (e.g. `DOSE_V2.14.csv`)
  has to match what's actually hosted on the Zenodo record.
- Current version (v0.5.0): DOSE V2.14, Zenodo record `20035157`.
- The geometries `.gpkg` is on Dropbox and is independent of DOSE
  versioning — only touch it if the maintainer regenerates it.

## Pipe convention

Package code uses the **native R pipe `|>`** only — never `%>%`. This
was changed in v0.5.0 after `sf` stopped re-exporting `%>%`
(see r-spatial/sf#2607), which surfaced as a CRAN NOTE
("no visible global function definition for '%>%'").

The minimum R version is therefore `R (>= 4.1.0)`, declared in
`DESCRIPTION`. Vignettes and `data-raw/` scripts can keep `%>%` because
they explicitly `library(dplyr)`.

## CRAN release procedure

The canonical workflow is in [dev/prepare_release.r](dev/prepare_release.r)
and [dev/prepare_CRAN.r](dev/prepare_CRAN.r). Roughly:

1. Update code, regenerate docs (`devtools::document()`).
2. Bump version in `DESCRIPTION` (or via `usethis::use_version()`).
3. Update `NEWS.md` with a new top section for the release.
4. Update `cran-comments.md` describing what changed and where it was tested.
5. Run `devtools::check(args = c("--no-manual", "--as-cran"))` and aim for
   `0 errors | 0 warnings | 0 notes`.
6. Run `devtools::check_win_devel()`, `check_win_release()`,
   `check_mac_release()` — all must come back clean.
7. `urlchecker::url_check()` (URLs in DESCRIPTION/README/Rd must resolve).
8. `usethis::use_spell_check()` — add false positives to `inst/WORDLIST`.
9. `devtools::submit_cran()`. This auto-updates `CRAN-SUBMISSION` with
   the version + commit SHA, so don't hand-edit that file.

`CRAN-SUBMISSION` is a stamp of the *last* submission, not a config file.

## CRAN policies and submission checklist

The full rules live with CRAN, not in this repo. Before each submission,
read:

- Repository policy: <https://cran.r-project.org/web/packages/policies.html>
- Submission checklist: <https://cran.r-project.org/web/packages/submission_checklist.html>
- Current check results for this package:
  <https://cran.r-project.org/web/checks/check_results_subincomeR.html>

## Things to watch for in this package specifically

- **No writes to the user's home directory.** `getDOSE()` and
  `getDOSE_geom()` default to `tempdir()`; only write elsewhere if the
  user passes `path =`. CRAN rejected an earlier version for writing
  to `~` by default — don't regress this.
- **Large download confirmation.** `getDOSE_geom()` prompts via
  `utils::menu()` in interactive sessions because the file is ~769 MB.
  Non-interactive sessions need `download = TRUE` to proceed.
- **Examples that hit the network.** All such examples are wrapped in
  `\donttest{}`. Keep them that way — CRAN runs examples but tolerates
  `\donttest` for slow / network-dependent ones.
- **Spell check.** `tests/spelling.R` runs on every check; non-English
  proper nouns belong in `inst/WORDLIST`.
