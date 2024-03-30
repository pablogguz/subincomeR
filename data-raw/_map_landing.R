
#*******************************************************************************
#* This script: generates map for package landing page
#*
#* Code by Pablo Garcia Guzman
#*******************************************************************************

packages_to_load <- c("ggplot2",
                      "dplyr",
                      "hexSticker",
                      "geogrid",
                      "rnaturalearth",
                      "usethis",
                      "sf",
                      "rmapshaper",
                      "leaflet")

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

# # Define the cache directory using rappdirs
# cache_dir <- rappdirs::user_cache_dir("subincomeR")
# dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
# zip_path <- file.path(cache_dir, "gadm_geom.zip")
# gpkg_path <- file.path(cache_dir, "gadm_geom.gpkg")
#
# # Read geometries ----
# dose_geom <- sf::st_read(gpkg_path)
#
# # Load DOSE data ----
# data <- getDOSE() %>%
#   mutate(grp_ppp = grp_pc_lcu_2015/PPP) %>% # generate variable for PPP regional GDP per capita
#   filter(!is.na(grp_ppp)) %>%
#   group_by(GID_1) %>%
#   arrange(desc(year)) %>%
#   filter(row_number()==1) %>% # keep latest non-missing value for each region
#   ungroup() %>%
#   select(GID_1, year, grp_ppp)
#
# # Match ----
# plot <- left_join(data, dose_geom) %>%
#   rename(geometry = geom) %>%
#   st_as_sf()
#
# map <- ggplot(data = plot) +
#   geom_sf(aes(fill = grp_ppp), color = "grey70", linewidth = .3) +
#   scale_fill_distiller(palette = "Blues", na.value = "lightgray",
#                        name = stringr::str_wrap("Regional GDP per capita (2015 int. $)", width = 40),
#                        guide = guide_colourbar(title.position = "top",
#                                                title.hjust = 0.5, barheight = 0.4,
#                                                barwidth = 12),
#                        direction = 1) +
#   # labs(
#   #   caption = "@pablogguz_ | Source: DOSE"
#   # ) +
#   theme_void() +
#   theme(text = element_text(family = "Open Sans"),
#         plot.title = element_text(hjust = 0.5),
#         legend.position = "bottom",
#         plot.background = element_rect(fill = "#f2f2f2", color = NA),
#         legend.title.align = 0.5,
#         plot.caption = element_text(size = 8, hjust = 0.01, vjust = 2, colour = "#3C4043"))
#
# ggsave("inst/figures/map.png", map, height = 6, width = 8, dpi = 200)

