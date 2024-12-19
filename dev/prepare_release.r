
# Set up vignettes 
# usethis::use_vignette("regional-convergence")

# # Add lifecycle badge to README
# usethis::use_lifecycle_badge("experimental")

# # Add R CMD check GitHub Actions workflow
# usethis::use_github_action_check_standard()

# # Add license
# usethis::use_mit_license()

# Set up testing environment ----
# usethis::use_testthat()

# Load functions ----
devtools::load_all()

# Documentation ----
devtools::document()
#devtools::build_manual()

# Tests ----
devtools::test()
# devtools::test(filter = "getDOSE")
# devtools::test(filter = "matchDOSE")

# Checks ----
devtools::check()

# Examples
devtools::run_examples(run_donttest = TRUE)

# Vignettes
devtools::build_vignettes()

# Build website
pkgdown::build_site()

# Package version ----
usethis::use_version()
