# -----------------------------------------------------------------------
# 07. Maps and relationship plots
# -----------------------------------------------------------------------

library(sf)
library(tmap)
library(ggplot2)
library(dplyr)

grid <- st_read("data/grid_full.gpkg", quiet = TRUE)

dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)

tmap_mode("plot")

# ---- Map 1: species richness ---------------------------------------------
m_richness <- tm_shape(grid) +
  tm_polygons("richness", palette = "YlGnBu", title = "Species richness") +
  tm_layout(main.title = "Seed-disperser richness", legend.outside = TRUE)
tmap_save(m_richness, "outputs/figures/map_richness.png", width = 8, height = 6, dpi = 300)

# ---- Map 2: mean annual temperature --------------------------------------
m_temp <- tm_shape(grid) +
  tm_polygons("temp_mean", palette = "-RdYlBu", title = "Mean annual temp (°C x10)") +
  tm_layout(main.title = "Climate: temperature", legend.outside = TRUE)
tmap_save(m_temp, "outputs/figures/map_temperature.png", width = 8, height = 6, dpi = 300)

# ---- Map 3: habitat fragmentation (edge density) --------------------------
m_frag <- tm_shape(grid) +
  tm_polygons("edge_density", palette = "OrRd", title = "Edge density") +
  tm_layout(main.title = "Habitat fragmentation", legend.outside = TRUE)
tmap_save(m_frag, "outputs/figures/map_fragmentation.png", width = 8, height = 6, dpi = 300)

# ---- Scatterplots: richness vs each predictor ------------------------------
df <- grid %>% st_drop_geometry()

p1 <- ggplot(df, aes(temp_mean, richness)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "gam", formula = y ~ s(x)) +
  labs(x = "Mean annual temperature", y = "Species richness") +
  theme_minimal()

p2 <- ggplot(df, aes(edge_density, richness)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "gam", formula = y ~ s(x)) +
  labs(x = "Edge density (fragmentation)", y = "Species richness") +
  theme_minimal()

ggsave("outputs/figures/richness_vs_temperature.png", p1, width = 6, height = 4, dpi = 300)
ggsave("outputs/figures/richness_vs_fragmentation.png", p2, width = 6, height = 4, dpi = 300)

message("Maps and figures written to outputs/figures/")
