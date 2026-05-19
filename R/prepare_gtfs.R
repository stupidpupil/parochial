prepare_gtfs <- function(){

  working_gtfs_files <- list.files(dir_working(), pattern = ".+\\.gtfs\\.zip$", full.names=TRUE)

  output_paths <- c()

  for (work_path in working_gtfs_files) {

    output_path <- dir_output("gtfs/", work_path %>% basename()  %>% basename() %>% stringr::str_replace("\\.gtfs\\.zip", paste0(".", output_affix(), ".gtfs.zip" )) )

    output_paths <- c(output_paths, output_path)

    cache_key <- openssl::sha1(paste0(
      cache_key_for_file(work_path),
      bounds() %>% sf::st_as_text(),
      parochial_temporal_bounds_as_character()
    )) %>%
    as.character()

    if(cache_key != cache_key_for_file(output_path)){
      message("Preparing GTFS from \'", work_path, "\' ...")
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