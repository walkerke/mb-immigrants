library(tidycensus)
library(tidyverse)

vars <- load_variables(2018, "acs5", cache = TRUE) %>%
  dplyr::filter(str_detect(name, "B05006"))

# Grab data without geometry as we'll want to wrangle the geometry separately
state_codes <- c(state.abb, "DC")

immigrant_data <- map_dfr(state_codes, ~{
  get_acs(geography = "tract",
          state = .x,
          variables = c(
            europe = "B05006_002",
            east_asia = "B05006_048",
            south_asia = "B05006_056",
            se_asia = "B05006_067",
            sw_asia = "B05006_078",
            east_africa = "B05006_092",
            central_africa = "B05006_099",
            north_africa = "B05006_101",
            southern_africa = "B05006_106",
            west_africa = "B05006_109",
            oceania = "B05006_117",
            mexico = "B05006_139",
            caribbean = "B05006_125",
            central_amer = "B05006_138",
            south_amer = "B05006_148",
            canada = "B05006_161"
          ), 
          output = "wide")
})

immigrant_grouped <- immigrant_data %>%
  transmute(GEOID = GEOID,
            NAME = NAME,
            europe = europeE,
            east_se_asia = east_asiaE + se_asiaE,
            south_asia = south_asiaE,
            sw_asia_n_africa = sw_asiaE + north_africaE,
            sub_saharan_africa = east_africaE + central_africaE + 
              southern_africaE + west_africaE,
            oceania = oceaniaE,
            mexico = mexicoE,
            cs_amer_caribbean = (central_amerE - mexicoE) + caribbeanE + south_amerE,
            canada = canadaE) %>%
  mutate(across(where(is.numeric), ~as.integer(.x / 25)))
  
write_rds(immigrant_grouped, "data/immigrant_grouped.rds")

  