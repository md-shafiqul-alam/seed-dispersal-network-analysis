# -----------------------------------------------------------------------
# 05. Habitat fragmentation metrics per grid cell (landscapemetrics)
#
# Uses tree cover as a binary habitat/non-habitat layer (threshold at
# 50%) and computes, per grid cell: edge density and patch density —
# two standard fragmentation indices.
# -----------------------------------------------------------------------

library(sf)
library(terra)
library(landscapemetrics)
library(dplyr)
library(purrr)

grid <- st_read("data/grid_env.gpkg", quiet = TRUE)
landcover <- rast("data/landcover.tif")

# Binary habitat layer: tree cover >= 50% treated as "habitat"
habitat <- classify(landcover, matrix(c(-Inf, 50, 0, 50, Inf, 1), ncol = 3, byrow = TRUE))
names(habitat) <- "habitat"

frag_one_cell <- function(cell_geom) {
  cell_vect <- vect(cell_geom)
  cropped <- tryCatch(crop(habitat, cell_vect, mask = TRUE), error = function(e) NULL)

  if (is.null(cropped) || all(is.na(values(cropped)))) {
    return(data.frame(edge_density = NA, patch_density = NA))
  }

  m <- calculate_lsm(
    cropped,
    what = c("lsm_c_ed", "lsm_c_pd"),
    verbose = FALSE
  )

  # Keep habitat class (value == 1); average if multiple classes present
  ed <- m %>% filter(metric == "ed", class == 1) %>% pull(value)
  pd <- m %>% filter(metric == "pd", class == 1) %>% pull(value)

  data.frame(
    edge_density = ifelse(length(ed) == 0, NA, ed),
    patch_density = ifelse(length(pd) == 0, NA, pd)
  )
}

frag_metrics <- map_dfr(st_geometry(grid), frag_one_cell)

grid_full <- grid %>% bind_cols(frag_metrics)

st_write(grid_full, "data/grid_full.gpkg", delete_dsn = TRUE)

message("Fragmentation metrics (edge density, patch density) computed per cell.")
