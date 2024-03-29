bounds <- function(buffer_by_metres){

  config_bounds <- config::get()$bounds

  if(fs::file_exists(config_bounds)){
    bounds <- sf::read_sf(config_bounds) %>%  sf::st_geometry()
  }else{
    bounds <- config::get()$bounds %>% sf::st_as_sfc()    
  }

  if(is.na(sf::st_crs(bounds))){
    sf::st_crs(bounds) <- "EPSG:4326"
  }

  bounds <- sf::st_make_valid(bounds)

  if(!missing(buffer_by_metres)){
    bounds <- bounds %>%
      sf::st_transform(crs = "EPSG:27700") %>%
      sf::st_buffer(buffer_by_metres) %>%
      sf::st_transform(crs = "EPSG:4326")
  }

  return(bounds)
}

path_to_bounds_geojson <- function(){
  # Be aware that osmium will not like a polygon file called something like
  # "walesish.bound.geojson" as the two dots will confuse its file ext detection
  # resulting in the following error message:
  # "Could not autodetect file type in '(multi)polygon' object. Add a 'file_type'."

  dir_output(output_affix(), "-bounds.geojson")
}

prepare_bounds_geojson <- function(){
  dest_path <- path_to_bounds_geojson()
  unlink(dest_path)
  bounds() %>% sf::st_write(dest_path)
  return(dest_path)
}