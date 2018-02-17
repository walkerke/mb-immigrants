library(tidyverse)
library(sf)


# Get US states

state <- c(state.abb, "DC")

df <- read_csv("data-raw/nhgis0090_csv/nhgis0090_ds151_2000_tract.csv")

df2 <- df %>%
  transmute(GISJOIN = GISJOIN, 
            europe = GV9001 + GV9002 + GV9003 + GV9004 + GV9005, 
            eastasia = GV9006 + GV9008, 
            sasia = GV9007, 
            swanaf = GV9009 + GV9013, 
            ssafr = GV9011 + GV9012 + GV9014 + GV9015 + GV9016, 
            oceania = GV9017 + GV9018 + GV9019 + GV9020 + GV9021, 
            mexico = GWA068, 
            latam = GV9022 - GWA068, 
            canada = GV9023
          )

sf_list <- map(state, function(x) {
  
  dir <- "data/2000/dissolve"
  
  layer <- paste0(x, "_dissolve")
  
  st_read(dsn = dir, layer = layer, stringsAsFactors = FALSE)
  
})

dtracts <- Reduce(rbind, sf_list)


joined <- dtracts %>% left_join(df2, by = "GISJOIN")

# Get back the CRS
# al <- st_read(dsn = "data/2016/dissolve", layer = "AL_dissolve")
# 
# st_crs(joined) <- st_crs(al)

st_write(joined, dsn = "data/2000/dissolve/full_dissolved_2000.shp")
