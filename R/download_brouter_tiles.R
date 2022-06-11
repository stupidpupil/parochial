download_brouter_tiles <- function(tile_ids = brouter_tile_ids()){
  old_opts <- options(timeout=max(options()$timeout,600))
  on.exit(options(old_opts))

  dest_paths <- c()

  for(tile_id in tile_ids){
    src_url <- paste0("http://brouter.de/brouter/segments4/", tile_id, ".rd5")
    dest_path <- dir_output("brouter/", tile_id, ".rd5")

    cache_key <- cache_key_for_brouter_tile_url(src_url)

     if(cache_key == cache_key_for_file(dest_path)){
        message("Cache hit for ", dest_path)
        dest_paths <- c(dest_paths, dest_path)
        next
      }

    download.file(src_url, dest_path)

    jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE, list(
      SourceUrl = src_url,
      SourceDownloadedAt = now_as_iso8601(),
      SourceLicence = "ODbL-1.0",
      SourceAttribution = "OpenStreetMap contributors",
      ParochialCacheKey = cache_key
    )) %>% write(paste0(dest_path, ".meta.json"))

    dest_paths <- dest_paths + dest_path
  }

  return(dest_paths)
}
