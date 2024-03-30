
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
                      "leaflet",
                      "lwgeom")

package.check <- lapply(
  packages_to_load,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
    }
  }
)

lapply(packages_to_load, require, character=T)

devtools::load_all()

# Script starts ----------------------------------------------------------------

# Define the cache directory using rappdirs
cache_dir <- rappdirs::user_cache_dir("subincomeR")
dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
zip_path <- file.path(cache_dir, "gadm_geom.zip")
gpkg_path <- file.path(cache_dir, "gadm_geom.gpkg")

# Read geometries ----
dose_geom <- sf::st_read(gpkg_path)

# Load DOSE data ----
data <- getDOSE() %>%
  mutate(grp_ppp = grp_pc_lcu_2015/PPP) %>% # generate variable for PPP regional GDP per capita
  filter(!is.na(grp_ppp)) %>%
  group_by(GID_1) %>%
  arrange(desc(year)) %>%
  filter(row_number()==1) %>% # keep latest non-missing value for each region
  ungroup() %>%
  select(GID_1, year, grp_ppp)

# Match ----
plot <- left_join(dose_geom, data) %>%
  rename(geometry = geom) %>%
  mutate(grp_ppp = ifelse(grp_ppp>100000, 100000, grp_ppp)) %>%
  st_as_sf()

# test <- plot %>%
#   filter(row_number()<300)

# crs_wintri <- "+proj=wintri +datum=WGS84 +no_defs +over"
# plot_wintri <- st_transform_proj(plot, crs = crs_wintri)

map <- ggplot(data = plot) +
  geom_sf(aes(fill = grp_ppp), color = "grey70", linewidth = .01) +
  scale_fill_distiller(palette = "Blues", na.value = "lightgray",
                       name = stringr::str_wrap("Regional GDP per capita (2015 int. $, thousands)", width = 50),
                       guide = guide_colourbar(title.position = "top",
                                               title.hjust = 0.5, barheight = 0.4,
                                               barwidth = 12),
                       direction = 1,
                       trans = "log10", # Use a log scale
                       breaks = c(1000, 5000, 10000, 20000, 50000, 100000), # Define specific breaks
                       labels = c("1", "5", "10", "20", "50", "+100")) + # Custom labels
  # labs(
  #   caption = "@pablogguz_ | Source: DOSE"
  # ) +
  theme_void() +
  theme(text = element_text(family = "Open Sans"),
        plot.title = element_text(hjust = 0.5),
        legend.position = "bottom",
        plot.background = element_rect(fill = "#ffffff", color = NA),
        legend.title.align = 0.5,
        legend.title = element_text(size = 8), # Reduce font size of legend title
        plot.caption = element_text(size = 8, hjust = 0.01, vjust = 2, colour = "#3C4043")) +
  coord_sf(crs= "+proj=robin")

# ggsave("inst/figures/map.png", map, height = 4, width = 7, dpi = 200)
ggsave("man/figures/map.png", map, height = 4, width = 7, dpi = 200)

