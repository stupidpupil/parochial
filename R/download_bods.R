download_bods <- function(region_code){

  if(missing(region_code)){
    region_code <- intersecting_regions_and_nations() %>% pull(bods_itm_code) %>% na.omit()
  }

  region_code %>% checkmate::assert_character()

  if(length(region_code) > 1){
    return(sapply(region_code, function(r){download_bods(r)}))
  }

  old_opts <- options(timeout = download_timeout_in_seconds(200*1024*1024))
  on.exit(options(old_opts))

  base_bus_url <- "https://data.bus-data.dft.gov.uk/timetable/download/gtfs-file/"

  bus_url <- paste0(base_bus_url, region_code, '/')
  work_path <- dir_working(region_code, ".bods.gtfs.zip")

  cache_key <- cache_key_for_bods_url(bus_url)

  if(cache_key != cache_key_for_file(work_path)){
    message("Downloading BODS data for ", region_code, "...")
    download.file(bus_url, work_path)

    jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE, list(
      SourceUrl = bus_url,
      SourceDownloadedAt = now_as_iso8601(),
      SourceLicence = "OGL-UK-3.0",
      SourceAttribution = "UK Department for Transport",
      ParochialCacheKey = cache_key
    )) %>% write(paste0(work_path, ".meta.json"))

  }else{
    message("Cache hit for ", work_path)
  }

  return(work_path)
}
