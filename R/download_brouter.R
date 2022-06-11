download_brouter <- function(){

  src_url <- "https://github.com/abrensch/brouter/releases/download/v1.6.3/brouter-1.6.3.zip"
  dest_path <- dir_working("brouter.zip")

  cache_key <- openssl::sha1(src_url) %>% as.character()

  if(cache_key == cache_key_for_file(dest_path)){
    message("Cache hit for ", dest_path)
    return(dest_path)
  }
  
  download.file(src_url, dest_path)
  unzip(dest_path, exdir=dir_working())

  if(fs::dir_exists(dir_working("brouter"))){
    fs::dir_delete(dir_working("brouter"))
  }

  unzipped_dir <- dir_working(unzip(dest_path, list=TRUE)[1,"Name"])

  fs::file_move(unzipped_dir, dir_working("brouter"))

  jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE, list(
    SourceUrl = src_url,
    SourceDownloadedAt = now_as_iso8601(),
    SourceLicence = "MIT",
    SourceAttribution = "bRouter",
    ParochialCacheKey = cache_key
  )) %>% write(paste0(dest_path, ".meta.json"))

  return(dir_working("brouter"))
}
