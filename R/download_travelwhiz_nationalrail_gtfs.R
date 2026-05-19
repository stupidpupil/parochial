download_travelwhiz_nationalrail_gtfs <- function(){

  output_paths <- c()

  old_opts <- options(timeout = download_timeout_in_seconds(200*1024*1024))
  on.exit(options(old_opts))

  travelwhiz_url <- paste0("https://storage.travelwhiz.app/generated-gtfs/gb-nationalrail.gtfs.zip")

  work_path <- dir_working("gb-nationalrail.gtfs.zip")

  cache_key <- cache_key_for_travelwhiz_url(travelwhiz_url)

  if(cache_key != cache_key_for_file(work_path)){
    message("Downloading TravelWhiz National Rail GTFS data ...")
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