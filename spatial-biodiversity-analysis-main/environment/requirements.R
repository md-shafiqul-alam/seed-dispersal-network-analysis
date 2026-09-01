# -----------------------------------------------------------------------
# Install all packages needed for the spatial-biodiversity-analysis pipeline
# -----------------------------------------------------------------------

pkgs <- c(
  "sf",                # vector spatial data
  "terra",             # raster spatial data
  "rgbif",             # GBIF occurrence API
  "geodata",           # WorldClim / elevation / land cover download
  "landscapemetrics",  # fragmentation metrics
  "spdep",             # spatial autocorrelation (Moran's I)
  "mgcv",              # GAM modeling
  "tmap",              # thematic maps
  "ggplot2",           # plotting
  "dplyr",             # data wrangling
  "tidyr",
  "rnaturalearth",     # country/coastline boundaries for the study extent
  "rnaturalearthdata"
)

installed <- rownames(installed.packages())
to_install <- setdiff(pkgs, installed)

if (length(to_install) > 0) {
  install.packages(to_install, repos = "https://cloud.r-project.org")
} else {
  message("All required packages are already installed.")
}
