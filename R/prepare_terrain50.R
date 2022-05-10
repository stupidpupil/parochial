prepare_terrain50 <- function(){
	terrain50 <- vrt_for_terrain50_zip(
		terr50_zip_path = dir_working("terr50_gagg_gb.zip"), 
		vrt_filename = dir_working("terr50_gagg_gb.vrt"))

	dest_path <- dir_output(paste0(output_affix(), ".terr50.tif"))

	terra::crop(terrain50, bounds() %>% sf::st_transform(27700)) %>% 
		terra::project("epsg:4326") %>%
		terra::writeRaster(dest_path, overwrite=TRUE)

  list(
    CreatedAt = now_as_iso8601(),
    DerivedFrom = I(describe_file(dir_working("terr50_gagg_gb.zip")))
  ) %>% jsonlite::toJSON(pretty = TRUE) %>%
  write(paste0(dest_path, ".meta.json"))

}