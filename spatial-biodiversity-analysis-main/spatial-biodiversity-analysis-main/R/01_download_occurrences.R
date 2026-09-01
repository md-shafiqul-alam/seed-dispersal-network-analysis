# -----------------------------------------------------------------------
# 01. Download biodiversity occurrence data from GBIF
#
# Default taxon: Turdus (thrushes) — a widespread European seed-disperser
# genus. Swap `taxon_key` / `taxon_name` for any group of interest.
# -----------------------------------------------------------------------

library(rgbif)
library(dplyr)

# ---- Study extent: rough European bounding box (lon/lat, WGS84) --------
bbox <- c(xmin = -10, ymin = 36, xmax = 30, ymax = 60)
wkt_bbox <- sprintf(
  "POLYGON((%f %f, %f %f, %f %f, %f %f, %f %f))",
  bbox["xmin"], bbox["ymin"],
  bbox["xmax"], bbox["ymin"],
  bbox["xmax"], bbox["ymax"],
  bbox["xmin"], bbox["ymax"],
  bbox["xmin"], bbox["ymin"]
)

# ---- Taxon of interest ---------------------------------------------------
taxon_name <- "Turdus"
taxon_key <- name_backbone(name = taxon_name)$usageKey

# ---- Query GBIF ----------------------------------------------------------
# Paginate through results; adjust `limit`/`n_pages` for a bigger pull.
n_pages <- 5
page_size <- 300

occ_list <- lapply(seq_len(n_pages) - 1, function(i) {
  res <- occ_search(
    taxonKey = taxon_key,
    geometry = wkt_bbox,
    hasCoordinate = TRUE,
    hasGeospatialIssue = FALSE,
    limit = page_size,
    start = i * page_size
  )
  res$data
})

occ_df <- bind_rows(occ_list) %>%
  filter(!is.na(decimalLongitude), !is.na(decimalLatitude)) %>%
  select(species, decimalLongitude, decimalLatitude, year, basisOfRecord) %>%
  distinct()

dir.create("data", showWarnings = FALSE)
write.csv(occ_df, "data/occurrences.csv", row.names = FALSE)

message(sprintf(
  "Downloaded %d occurrence records across %d species.",
  nrow(occ_df), n_distinct(occ_df$species)
))
