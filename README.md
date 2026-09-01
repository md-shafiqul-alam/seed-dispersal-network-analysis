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

## Quick Start (Windows)

### Prerequisites

- **R** (≥ 4.0, tested with 4.6.1)
  - Download from [cran.r-project.org](https://cran.r-project.org/bin/windows/base/)
  - On Windows: Run installer with default settings
- **PowerShell** 5.1+ (built-in on Windows 10+)

### Setup Instructions

1. **Clone or download this repository** to your machine

2. **Install R** (if not already installed):

   ```powershell
   # Option A: Using winget (Windows 11+)
   winget install R.R

   # Option B: Manual download from https://cran.r-project.org/bin/windows/base/
   ```

3. **Create a local R library directory** (avoids permission issues):

   ```powershell
   # This folder will store all R packages
   New-Item -ItemType Directory -Path "$env:USERPROFILE\R_libs" -Force
   ```

4. **Install R packages**:
   ```powershell
   # Run from the project root directory
   & "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" -e ".libPaths(c('$env:USERPROFILE\R_libs', .libPaths())); source('environment/requirements.R')"
   ```
   This will install all required packages (sf, terra, rgbif, geodata, landscapemetrics, spdep, mgcv, tmap, ggplot2, dplyr).

### Running the Pipeline

**Option 1: Using the PowerShell wrapper (recommended)**

```powershell
# Run all scripts in sequence (easiest method)
.\run_r_script.ps1 "R/01_download_occurrences.R"
.\run_r_script.ps1 "R/02_download_environmental_layers.R"
.\run_r_script.ps1 "R/03_build_grid_and_richness.R"
.\run_r_script.ps1 "R/04_extract_environmental_predictors.R"
.\run_r_script.ps1 "R/05_fragmentation_metrics.R"
.\run_r_script.ps1 "R/06_statistical_analysis.R"
.\run_r_script.ps1 "R/07_maps_and_figures.R"
```

**Option 2: Manual execution from PowerShell**

```powershell
$RExe = "C:\Program Files\R\R-4.6.1\bin\Rscript.exe"
$RLibPath = "$env:USERPROFILE\R_libs"
& $RExe -e ".libPaths(c('$RLibPath', .libPaths())); source('R/01_download_occurrences.R')"
```

**Option 3: From R console**

```r
# Set library path first
.libPaths(c(file.path(Sys.getenv('USERPROFILE'), 'R_libs'), .libPaths()))

# Then source the script
source('R/01_download_occurrences.R')
```

### Expected Runtime

- **Script 01** (download occurrences): ~2-3 min (depends on GBIF API)
- **Script 02** (download environmental data): ~5-10 min (large downloads ~650 MB)
- **Script 03** (build grid): ~1-2 min
- **Script 04** (extract predictors): ~1-2 min
- **Script 05** (fragmentation metrics): ~2-3 min
- **Script 06** (statistical analysis): ~30 sec
- **Script 07** (maps and figures): ~15 sec

**Total**: ~15-25 minutes on first run (depends on internet and disk speed)

### Troubleshooting

**Error: "Rscript is not recognized as a cmdlet"**

- R is not in your system PATH
- **Fix**: Use full path: `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`
- Or add R to PATH manually via System Environment Variables

**Error: "lib = 'C:/Program Files/R/R-4.6.1/library' is not writable"**

- Insufficient permissions to install packages in default location
- **Fix**: The setup above creates a user library at `C:\Users\<YourUsername>\R_libs` instead
- Ensure the `.libPaths()` configuration is set in each script

**Error: "there is no package called 'X'"**

- A required package didn't install
- **Fix**: Run the requirements file again:
  ```powershell
  & "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" -e ".libPaths(c('$env:USERPROFILE\R_libs', .libPaths())); source('environment/requirements.R')"
  ```

**Error: "Cannot open file 'data/...'"**

- Earlier scripts haven't been run yet
- **Fix**: Run scripts 01 and 02 first to download data

**Long download times in Script 02**

- WorldClim data is large (~170 MB for climate alone)
- Downloaded data is cached in `data/env_raw/` for reuse
- If the download stalls, delete the partial cache and retry:
  ```powershell
  Remove-Item -Path "data/env_raw" -Recurse -Force
  ```

**Maps not generating in Script 07**

- Ensure Script 06 ran successfully first
- Check that `outputs/` directory exists

---

## Pipeline

| Step | Script                                    | What it does                                                                                                            |
| ---- | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| 1    | `R/01_download_occurrences.R`             | Pulls GBIF occurrence records for a frugivore group (default: European thrushes, _Turdus_) within a bounding box        |
| 2    | `R/02_download_environmental_layers.R`    | Downloads WorldClim bioclimatic variables, elevation, and land cover for the same extent                                |
| 3    | `R/03_build_grid_and_richness.R`          | Builds a regular hex grid, spatially joins occurrences, computes species richness per cell                              |
| 4    | `R/04_extract_environmental_predictors.R` | Extracts mean climate/elevation values per grid cell                                                                    |
| 5    | `R/05_fragmentation_metrics.R`            | Computes habitat fragmentation metrics (edge density, patch density) per cell from land cover, using `landscapemetrics` | `data/grid_full.gpkg`                                 |
| 6    | `R/06_statistical_analysis.R`             | Merges richness + predictors; fits a GAM; checks spatial autocorrelation with Moran's I                                 | `outputs/model_summary.txt`, `outputs/moran_test.txt` |
| 7    | `R/07_maps_and_figures.R`                 | Produces richness/predictor maps (`tmap`) and relationship plots (`ggplot2`)                                            | `outputs/figures/*.png`                               |

## Packages & Dependencies

All required packages are listed in `environment/requirements.R`. Includes:

- **Spatial**: `sf`, `terra`, `sp`, `spdep`
- **Species data**: `rgbif`, `geodata`
- **Analysis**: `landscapemetrics`, `mgcv`, `dplyr`, `tidyr`
- **Visualization**: `tmap`, `ggplot2`, `rnaturalearth`

Install via:

```r
source("environment/requirements.R")
```

## Project Structure

```
spatial-biodiversity-analysis-main/
├── README.md                          # This file
├── run_r_script.ps1                   # PowerShell wrapper for running R scripts
├── environment/
│   └── requirements.R                 # Package installation script
├── data/                              # Contains all intermediate data (git-ignored)
│   ├── occurrences.csv               # GBIF species occurrence records
│   ├── env_raw/                      # Cached environmental rasters
│   ├── grid_richness.gpkg            # Grid with species richness
│   ├── grid_env.gpkg                 # Grid with environmental predictors
│   └── grid_full.gpkg                # Final grid with all variables
├── R/                                 # Analysis scripts (run in order)
│   ├── 01_download_occurrences.R
│   ├── 02_download_environmental_layers.R
│   ├── 03_build_grid_and_richness.R
│   ├── 04_extract_environmental_predictors.R
│   ├── 05_fragmentation_metrics.R
│   ├── 06_statistical_analysis.R
│   └── 07_maps_and_figures.R
└── outputs/                          # Final results
    ├── model_summary.txt             # GAM model statistics
    ├── moran_test.txt                # Spatial autocorrelation results
    └── figures/                      # High-resolution maps (PNG)
```

## Data Sources & Caching

Nothing is bundled in this repo (raw occurrence/raster data is large and easy to re-download):

- **Species occurrences**: GBIF API (`rgbif` package) — query filtered for Turdus genus, Europe region, with coordinates and no geospatial issues
- **Climate data**: WorldClim 2.1 bioclimatic variables (5 arcmin resolution) — 19 variables covering temperature and precipitation patterns
- **Elevation**: GEBCO DEM (30-arc-second resolution)
- **Land cover**: Global tree cover layer (250m resolution)

Run scripts 1–2 on first setup to download and cache data in `data/env_raw/`. Data is git-ignored. See `data/README.md` for source details and customization points.

## Adapting this for Custom Data (ANEW, etc.)

The grid-cell design (`03_build_grid_and_richness.R`) is the reusable part: any per-site or per-cell response variable — richness, a network metric, an interaction count — can be substituted in step 3, and steps 4–7 (environmental extraction, fragmentation, modeling, mapping) work unchanged.

**To use custom species/interaction data**:

1. Prepare your data as a CSV with columns: `species`, `decimalLongitude`, `decimalLatitude`
2. Replace the GBIF download in script 01, or skip script 01 and point script 03 at your CSV
3. Run scripts 03–07 with your custom data unchanged

## License

MIT — reuse freely.
