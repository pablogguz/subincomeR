

# Load functions ----
devtools::load_all()

# Documentation ----
devtools::document()

# Checks ----
devtools::check()

# Build website
pkgdown::build_site()

# Package version ----
usethis::use_version()

# Create GitHub release
usethis::use_github_release()

# Create git tag
new_version <- desc::desc_get_version()
repo <- git2r::repository(".")
git2r::tag(repo, paste0("v", new_version))
