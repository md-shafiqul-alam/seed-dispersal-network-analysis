# -----------------------------------------------------------------------
# 03. Build a hex grid over the study extent and compute species
#     richness per cell from occurrence points
# -----------------------------------------------------------------------

library(sf)
library(dplyr)
library(rnaturalearth)

occ <- read.csv("data/occurrences.csv")

occ_sf <- st_as_sf(
  occ,
  coords = c("decimalLongitude", "decimalLatitude"),
  crs = 4326
)

# ---- Study area boundary (land only, so cells over open ocean drop out) --
europe <- ne_countries(continent = "Europe", returnclass = "sf") %>%
  st_make_valid() %>%
  st_crop(st_bbox(c(xmin = -10, ymin = 36, xmax = 30, ymax = 60), crs = 4326))

# ---- Build hex grid -------------------------------------------------------
# cellsize is in degrees here for simplicity; reproject to an equal-area
# CRS (e.g. EPSG:3035, ETRS89-LAEA Europe) first if cell area needs to be
# exactly comparable across latitudes.
grid <- st_make_grid(europe, cellsize = 1, square = FALSE) %>%
  st_sf(geometry = .) %>%
  mutate(cell_id = row_number()) %>%
  st_filter(europe)

# ---- Species richness per cell --------------------------------------------
occ_in_grid <- st_join(occ_sf, grid, join = st_within)

richness <- occ_in_grid %>%
  st_drop_geometry() %>%
  filter(!is.na(cell_id)) %>%
  group_by(cell_id) %>%
  summarise(richness = n_distinct(species), n_records = n())

grid_richness <- grid %>%
  left_join(richness, by = "cell_id") %>%
  mutate(
    richness = ifelse(is.na(richness), 0, richness),
    n_records = ifelse(is.na(n_records), 0, n_records)
  )

st_write(grid_richness, "data/grid_richness.gpkg", delete_dsn = TRUE)

message(sprintf(
  "Built %d grid cells; richness ranges from %d to %d species.",
  nrow(grid_richness), min(grid_richness$richness), max(grid_richness$richness)
))
