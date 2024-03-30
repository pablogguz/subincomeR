
#*******************************************************************************
#* This script: generates logo for package website
#*
#* Code by Pablo Garcia Guzman
#*******************************************************************************

packages_to_load <- c("ggplot2",
                      "dplyr",
                      "hexSticker",
                      "geogrid",
                      "rnaturalearth",
                      "tmap",
                      "usethis",
                      "sf")

package.check <- lapply(
  packages_to_load,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
    }
  }
)

lapply(packages_to_load, require, character=T)

# Script starts ----------------------------------------------------------------

# Read world geometries
world <- ne_countries(scale = "medium", returnclass = "sf")
world <- world %>%
  filter(sov_a3 != "ATA") # remove Antarctica

# Convert to hexagons
manc_grid <- calculate_grid(shape = world, grid_type = "hexagonal", seed = 1612)

# Make geometries valid
world <- st_make_valid(world)

# Assign hexagons to polygons
poly <- assign_polygons(world, manc_grid)
poly_sf <- st_as_sf(poly)

# Plot
world_plot <- ggplot(data = poly_sf) +
  geom_sf(fill = "#0072B2", color = "white") +
  theme_void()

# Create the hex sticker
hexSticker::sticker(
  filename = "inst/figures/logo.png",
  # Subplot aesthetics
  world_plot,
  s_width = 1.5, s_height = 1.5, # Adjust size to fit within the hexagon
  s_x = 1, s_y = 0.8, # Center the plot within the hexagon
  # Package name aesthetics
  package = "subincomeR",
  p_size = 20,
  p_color = "white",
  # Hexagon aesthetics
  h_size = 1,
  h_fill = "#0072B2",
  h_color = "white",
  # URL aesthetics
  url = "pablogguz.github.io/subincomeR",
  u_size = 4.8,
  u_color = "white"
) |> plot() # Preview with plot()

# Generate string to copy-paste into README
use_logo("inst/figures/logo.png", geometry = "480x556", retina = TRUE)
