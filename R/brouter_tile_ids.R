brouter_tile_ids <- function(for_bounds = bounds(buffer_by_metres = 10000)){

  bbox <- for_bounds %>% sf::st_bbox()
  # bRouter's tiles are 5 deg x 5 deg

  incr <- 5

  bbox$xmin <- floor(bbox$xmin/incr)*incr
  bbox$ymin <- floor(bbox$ymin/incr)*incr

  bbox$xmax <- ceiling(bbox$xmax/incr)*incr
  bbox$ymax <- ceiling(bbox$ymax/incr)*incr

  expand_grid(
    xmin = seq(bbox$xmin, bbox$xmax-incr, incr),
    ymin = seq(bbox$ymin, bbox$ymax-incr, incr)
  ) %>%
  mutate(
    brouter_id = paste0(if_else(xmin < 0, "W", "E"), abs(xmin), "_",  if_else(ymin < 0, "S", "N"), abs(ymin))
  ) %>%
  pull(brouter_id)
}