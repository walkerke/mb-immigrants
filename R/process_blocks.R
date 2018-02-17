library(tidyverse)
library(sf)

states <- c(state.abb, "DC")

# 2000

df00 <- read_csv("data-raw/blocks/2000/nhgis0091_csv/nhgis0091_ds147_2000_block.csv")

nopop00 <- df00 %>%
  select(GISJOIN, totalpop = FXS001) %>%
  filter(totalpop == 0)

# saveRDS(nopop, "data/nopop.rds")

# nopop <- read_rds("data/nopop.rds")

merge_and_write00 <- function(state) {
  
  message("Processing ", state, "...")
  
  layer_name = paste0(state, "_block_2000")
  
  blks <- st_read(dsn = "data/blocks00", layer = layer_name, 
                  stringsAsFactors = FALSE)
  
  blks_nopop <- inner_join(blks, nopop00, by = "GISJOIN")
  
  out_file <- paste0("data/blocks00/nopop/", state, "_nopop.shp")
  
  st_write(blks_nopop, out_file)
  
}

walk(states, merge_and_write00)



states <- c(state.abb, "DC")

# 2010

df10 <- read_csv("data-raw/blocks/2010/nhgis0078_csv/nhgis0078_csv/nhgis0078_ds172_2010_block.csv")

nopop10 <- df10 %>%
  select(GISJOIN, totalpop = H7V001) %>%
  filter(totalpop == 0)

# saveRDS(nopop, "data/nopop.rds")

# nopop <- read_rds("data/nopop.rds")

merge_and_write10 <- function(state) {
  
  message("Processing ", state, "...")
  
  layer_name = paste0(state, "_block_2010")
  
  blks <- st_read(dsn = "data/blocks10", layer = layer_name, 
                  stringsAsFactors = FALSE)
  
  blks_nopop <- inner_join(blks, nopop10, by = "GISJOIN")
  
  out_file <- paste0("data/blocks10/nopop/", state, "_nopop.shp")
  
  st_write(blks_nopop, out_file, delete_layer = TRUE)
  
}

walk(states, merge_and_write10)