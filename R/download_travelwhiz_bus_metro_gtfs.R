download_travelwhiz_bus_metro_gtfs <- function(region_code){

  if(missing(region_code)){
    region_code <- intersecting_regions_and_nations() %>% pull(travelwhiz_code) %>% na.omit() %>% unique()
  }

  region_code %>% checkmate::assert_character()

  if(length(region_code) > 1){
    return(vapply(region_code, function(r){download_travelwhiz_bus_metro_gtfs(r)}, character(1)))
  }

  output_paths <- c()

  old_opts <- options(timeout = download_timeout_in_seconds(200*1024*1024))
  on.exit(options(old_opts))

  travelwhiz_url <- paste0("https://storage.travelwhiz.app/generated-gtfs/uk-busmetro-", region_code, ".gtfs.zip")

  work_path <- dir_working("uk-busmetro-", region_code, ".gtfs.zip")

  cache_key <- cache_key_for_travelwhiz_url(travelwhiz_url)

  if(cache_key != cache_key_for_file(work_path)){
    message("Downloading TravelWhiz GTFS data for ", region_code, "...")
    download.file(travelwhiz_url, work_path)

    jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE, list(
      SourceUrl = travelwhiz_url,
      SourceDownloadedAt = now_as_iso8601(),
      SourceLicence = "CC-BY-4.0",
      SourceAttribution = "TravelWhiz",
      ParochialCacheKey = cache_key
    )) %>% write(paste0(work_path, ".meta.json"))

  }else{
    message("Cache hit for ", work_path)
  }

  return(work_path)

}