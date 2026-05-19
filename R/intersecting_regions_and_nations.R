intersecting_regions_and_nations <- function(){
  rnn <- sf::read_sf(dir_support("regions_and_nations.geojson")) %>%
    left_join(readr::read_csv(dir_support("regions_and_nations.csv"), col_types="ccc"), by="code")

  rnn[lengths(rnn %>% sf::st_intersects(bounds())) > 0,] 
}