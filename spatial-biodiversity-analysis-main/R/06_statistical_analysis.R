# -----------------------------------------------------------------------
# 06. Model species richness as a function of environmental gradients,
#     and check for residual spatial autocorrelation
# -----------------------------------------------------------------------

library(sf)
library(dplyr)
library(mgcv)
library(spdep)

grid <- st_read("data/grid_full.gpkg", quiet = TRUE) %>%
  filter(!is.na(temp_mean), !is.na(edge_density))

# ---- GAM: smooth terms allow non-linear environmental responses ---------
mod <- gam(
  richness ~ s(temp_mean) + s(precip_annual) + s(elevation) +
    s(edge_density) + s(patch_density),
  family = poisson(link = "log"),
  data = grid
)

summary(mod)

dir.create("outputs", showWarnings = FALSE)
sink("outputs/model_summary.txt")
print(summary(mod))
sink()

# ---- Check for residual spatial autocorrelation (Moran's I) --------------
grid$resid <- residuals(mod, type = "pearson")

coords <- st_coordinates(st_centroid(grid))
nb <- knn2nb(knearneigh(coords, k = 6))
lw <- nb2listw(nb, style = "W")

moran_test <- moran.test(grid$resid, lw)
print(moran_test)

capture.output(moran_test, file = "outputs/moran_test.txt")

message(
  "Model fit and Moran's I test complete — see outputs/model_summary.txt ",
  "and outputs/moran_test.txt. A significant Moran's I on residuals means ",
  "richness is spatially autocorrelated beyond what the predictors explain; ",
  "consider adding a spatial smooth term (e.g. s(x, y)) or a GLMM with a ",
  "spatial random effect."
)
