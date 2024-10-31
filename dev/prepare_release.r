# # dev/release.R

# prepare_release <- function() {
#   # Ensure we're in package root
#   if (!file.exists("DESCRIPTION")) {
#     stop("Must be in package root directory")
#   }
  
#   message("Starting release preparation...")
  
#   # Record current version before bumping
#   old_version <- desc::desc_get_version()
  
#   # Check if Git is clean
#   if (length(git2r::status()$changed) > 0) {
#     stop("Working directory not clean. Commit changes first.")
#   }
  
#   message("\n🔍 Running checks and documentation...")
  
#   # Load functions
#   devtools::load_all()

#   # Update documentation
#   devtools::document()
  
#   # Run full check
#   check_results <- devtools::check()
#   if (length(check_results$errors) > 0 || length(check_results$warnings) > 0) {
#     stop("Package checks failed. Please fix errors/warnings before release.")
#   }
  
#   message("\n🔢 Updating version...")
#   # Increment version and get new version
#   usethis::use_version()
#   new_version <- desc::desc_get_version()
  
#   message("\n📝 Updating NEWS.md...")
#   # Update NEWS.md - will open for editing
#   usethis::edit_file("NEWS.md")
#   readline(prompt = "Press [Enter] when you've updated NEWS.md")
  
#   message("\n🌐 Building documentation website...")
#   # Build website
#   pkgdown::build_site()
  
#   message("\n🏷️ Creating git tag...")
#   # Create git tag
#   repo <- git2r::repository(".")
#   git2r::tag(repo, paste0("v", new_version))

#   # Create GitHub release
#   message("\n📢 Creating GitHub release...")
#   usethis::use_github_release()
  
#   # Build package
#   message("\n📦 Building package...")
#   devtools::build()
  
#   # Final message
#   message("\n✨ Release preparation completed!")
#   message("\nRelease checklist:")
#   message("1. Push all changes: git push")
#   message("2. Push tags: git push --tags")
#   message("3. Review the GitHub release draft")
#   message("4. Check that pkgdown site built correctly")
#   message(paste0("\nVersion bumped from ", old_version, " to ", new_version))
  
#   # Return invisibly
#   invisible(TRUE)
# }

# prepare_release()

# # Usage:
# # source("dev/release.R")
# # prepare_release()