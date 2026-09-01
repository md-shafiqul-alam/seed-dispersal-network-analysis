# -----------------------------------------------------------------------
# 04. Extract mean climate & elevation values per grid cell
# -----------------------------------------------------------------------

library(sf)
library(terra)
library(dplyr)

grid <- st_read("data/grid_richness.gpkg", quiet = TRUE)
bioclim <- rast("data/bioclim/bioclim_europe.tif")
elev <- rast("data/elevation.tif")

grid_vect <- vect(grid)

clim_means <- terra::extract(bioclim, grid_vect, fun = mean, na.rm = TRUE, ID = FALSE)
elev_means <- terra::extract(elev, grid_vect, fun = mean, na.rm = TRUE, ID = FALSE)

grid_env <- grid %>%
  bind_cols(clim_means) %>%
  bind_cols(elev_means)

st_write(grid_env, "data/grid_env.gpkg", delete_dsn = TRUE)

message("Climate and elevation predictors extracted per grid cell.")
