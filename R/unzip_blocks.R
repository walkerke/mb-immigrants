library(tidyverse)
# 2000

folders <- list.files("data-raw/blocks/2000/nhgis0091_shape/", pattern = ".zip", 
                      full.names = TRUE)

unzip_and_move <- function(x) {
  unzip(x, exdir = "data/blocks00")
}

walk(folders, unzip_and_move)

# 2010

folders <- list.files("data-raw/blocks/2010/nhgis0079_shape/", pattern = ".zip", 
                      full.names = TRUE)

unzip_and_move <- function(x) {
  unzip(x, exdir = "data/blocks10")
}

walk(folders, unzip_and_move)