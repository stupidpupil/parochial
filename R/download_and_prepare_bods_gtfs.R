download_and_prepare_bods_gtfs <- function(){

  bods_files <- intersecting_regions_and_nations() %>% pull(bods_itm_code) %>% na.omit()
  base_bus_url <- "https://data.bus-data.dft.gov.uk/timetable/download/gtfs-file/"

  output_paths <- c()

  for (r in bods_files) {
    work_path <- download_bods(r)
    output_path <- dir_output("gtfs/", r, ".bods.", output_affix(),".gtfs.zip")

    output_paths <- c(output_paths, output_path)

    cache_key <- openssl::sha1(paste0(
      cache_key_for_file(work_path),
      bounds() %>% sf::st_as_text(),
      parochial_temporal_bounds_as_character()
    )) %>%
    as.character()

    if(cache_key != cache_key_for_file(output_path)){
      message("Preparing GTFS from \'", r, "\' BODS timetables...")
      gtfs <- gtfstools::read_gtfs(work_path)
      gtfs <- gtfs %>% gtfs_parochialise()
      gtfs %>% gtfstools::write_gtfs(output_path)

      list(
        CreatedAt = now_as_iso8601(),
        DerivedFrom = I(describe_file(work_path)),
        Coverage = parochial_coverage_as_list(),
        ParochialCacheKey = cache_key
      ) %>% jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE) %>%
      write(paste0(output_path, ".meta.json"))

      delete_merged_gtfs()      
    }else{
      message("Cache hit for ", output_path)
    }

  }

  return(output_paths)
}
