# Data

This folder is populated by running the download scripts (`R/01_...` and
`R/02_...`) and is gitignored — nothing here is committed.

| File (after running scripts) | Source | Script |
|---|---|---|
| `occurrences.csv` | GBIF (`rgbif::occ_search`) | `01_download_occurrences.R` |
| `bioclim/*.tif` | WorldClim v2.1, via `geodata::worldclim_global()` | `02_download_environmental_layers.R` |
| `elevation.tif` | SRTM, via `geodata::elevation_30s()` | `02_download_environmental_layers.R` |
| `landcover.tif` | ESA WorldCover, via `geodata::landcover()` | `02_download_environmental_layers.R` |
| `grid_richness.gpkg` | derived | `03_build_grid_and_richness.R` |
| `grid_full.gpkg` | derived (richness + predictors + fragmentation) | `05_fragmentation_metrics.R` |

## Swapping in ANEW data

To run this pipeline on ANEW seed-dispersal network data instead of GBIF
richness:

1. Replace `01_download_occurrences.R` with a loader for your
   interaction/network dataset (site coordinates + a per-site metric,
   e.g. species richness of dispersers, mean interaction degree, or
   nestedness contribution).
2. Skip straight to `03_build_grid_and_richness.R`, but replace the
   richness calculation with a spatial join of your per-site metric onto
   the same grid (or keep site-level points instead of gridding, if your
   sample size is small — `st_join` still works).
3. Steps 4–7 need no changes.
