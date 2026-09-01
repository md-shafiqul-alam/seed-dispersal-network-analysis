# Spatial Biodiversity Analysis

A basic R/GIS workflow linking **species richness** of seed-dispersing
vertebrates to **environmental gradients** (climate, elevation, land cover,
habitat fragmentation) across a European study extent.

Built as a template for spatial ecology work relevant to seed-dispersal
network research (e.g. ANEW) — the same pipeline that computes richness
per grid cell can be adapted to compute network metrics (e.g. mean
interaction degree, nestedness) per cell instead, and regress those
against the same environmental predictors.

## Question

**Which environmental factors explain spatial variation in seed-disperser
richness across European landscapes?**

## Pipeline

| Step | Script | What it does |
|---|---|---|
| 1 | `R/01_download_occurrences.R` | Pulls GBIF occurrence records for a frugivore group (default: European thrushes, *Turdus*) within a bounding box |
| 2 | `R/02_download_environmental_layers.R` | Downloads WorldClim bioclimatic variables, elevation, and land cover for the same extent |
| 3 | `R/03_build_grid_and_richness.R` | Builds a regular hex grid, spatially joins occurrences, computes species richness per cell |
| 4 | `R/04_extract_environmental_predictors.R` | Extracts mean climate/elevation values per grid cell |
| 5 | `R/05_fragmentation_metrics.R` | Computes habitat fragmentation metrics (edge density, patch density) per cell from land cover, using `landscapemetrics` |
| 6 | `R/06_statistical_analysis.R` | Merges richness + predictors; fits a GLM/GAM; checks spatial autocorrelation with Moran's I |
| 7 | `R/07_maps_and_figures.R` | Produces richness/predictor maps (`tmap`) and relationship plots (`ggplot2`) |

## Packages

`sf`, `terra`, `rgbif`, `geodata`, `landscapemetrics`, `spdep`, `mgcv`,
`tmap`, `ggplot2`, `dplyr`. Install everything with:

```r
source("environment/requirements.R")
```

## Data

Nothing is bundled in this repo (raw occurrence/raster data is large and
easy to re-download). Run scripts 1–2 to populate `data/`, which is
gitignored. See `data/README.md` for source details and swap-in points
(e.g. point `01_download_occurrences.R` at your own ANEW interaction
dataset instead of GBIF occurrences to run the exact same downstream
pipeline on network-derived metrics).

## Adapting this for ANEW

The grid-cell design (`03_build_grid_and_richness.R`) is the reusable
part: any per-site or per-cell response variable — richness, a network
metric, an interaction count — can be substituted in step 3, and steps
4–7 (environmental extraction, fragmentation, modeling, mapping) work
unchanged.

## License

MIT — reuse freely.
