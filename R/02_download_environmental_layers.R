# -----------------------------------------------------------------------
# 02. Download environmental layers: climate, elevation, land cover
# -----------------------------------------------------------------------

library(geodata)
library(terra)

dir.create("data/env_raw", showWarnings = FALSE, recursive = TRUE)

# Study extent (matches 01_download_occurrences.R)
ext_europe <- ext(-10, 30, 36, 60)

# ---- Bioclimatic variables (WorldClim v2.1, ~5 arc-min resolution) -----
bioclim <- worldclim_global(
  var = "bio",
  res = 5,
  path = "data/env_raw"
)
bioclim_eu <- crop(bioclim, ext_europe)

# Keep a small, ecologically interpretable subset:
# bio1 = annual mean temp, bio4 = temp seasonality,
# bio12 = annual precip, bio15 = precip seasonality
keep <- c("wc2.1_5m_bio_1", "wc2.1_5m_bio_4", "wc2.1_5m_bio_12", "wc2.1_5m_bio_15")
bioclim_eu <- bioclim_eu[[keep]]
names(bioclim_eu) <- c("temp_mean", "temp_seasonality", "precip_annual", "precip_seasonality")

dir.create("data/bioclim", showWarnings = FALSE)
writeRaster(bioclim_eu, "data/bioclim/bioclim_europe.tif", overwrite = TRUE)

# ---- Elevation -----------------------------------------------------------
elev <- elevation_global(res = 5, path = "data/env_raw")
elev_eu <- crop(elev, ext_europe)
names(elev_eu) <- "elevation"
writeRaster(elev_eu, "data/elevation.tif", overwrite = TRUE)

# ---- Land cover (used later for fragmentation metrics) -------------------
# landcover() pulls ESA WorldCover-derived layers by class; here we grab
# "trees" as a habitat-cover proxy. Combine multiple classes if needed.
lc <- landcover(var = "trees", path = "data/env_raw")
lc_eu <- crop(lc, ext_europe)
names(lc_eu) <- "tree_cover"
writeRaster(lc_eu, "data/landcover.tif", overwrite = TRUE)

message("Environmental layers downloaded and cropped to the study extent.")
