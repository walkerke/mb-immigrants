library(tidyverse)
library(sf)


# Get US states

state <- c(state.abb, "DC")

df <- read_csv("data-raw/nhgis0090_csv/nhgis0090_ds226_20165_2016_tract.csv")

df2 <- df %>%
  transmute(GISJOIN = GISJOIN, 
            europe = AGCTE002, 
            eastasia = AGCTE048 + AGCTE067, 
            sasia = AGCTE056, 
            swanaf = AGCTE078 + AGCTE101, 
            ssafr = AGCTE092 + AGCTE098 + AGCTE106 + AGCTE109 + AGCTE116, 
            oceania = AGCTE117, 
            mexico = AGCTE139, 
            latam = AGCTE124 - AGCTE139, 
            canada = AGCTE160, 
            total = AGCTE001
          )

sf_list <- map(state, function(x) {
  
  dir <- "data/2016/dissolve"
  
  layer <- paste0(x, "_dissolve")
  
  st_read(dsn = dir, layer = layer, stringsAsFactors = FALSE)
  
})

dtracts <- Reduce(rbind, sf_list)


joined <- dtracts %>% left_join(df2, by = "GISJOIN")

# Get back the CRS
# al <- st_read(dsn = "data/2016/dissolve", layer = "AL_dissolve")
# 
# st_crs(joined) <- st_crs(al)

st_write(joined, dsn = "data/2016/dissolve/full_dissolved_2016.shp", 
         delete_layer = TRUE)
