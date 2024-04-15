library(tidycensus)
library(tidyverse)

vars <- load_variables(2022, "acs5", cache = TRUE) %>%
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
            se_asia = "B05006_068",
            sw_asia = "B05006_079",
            east_africa = "B05006_096",
            central_africa = "B05006_105",
            north_africa = "B05006_110",
            southern_africa = "B05006_116",
            west_africa = "B05006_119",
            oceania = "B05006_130",
            mexico = "B05006_160",
            caribbean = "B05006_140",
            central_amer = "B05006_154",
            south_amer = "B05006_164",
            canada = "B05006_177"
          ), 
          output = "wide",
          year = 2022)
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
  pivot_longer(cols = europe:canada, names_to = "group", values_to = "n")
  
write_rds(immigrant_grouped, "data/immigrant_grouped.rds")

  