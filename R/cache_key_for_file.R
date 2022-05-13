cache_key_for_file <- function(path) {
  if(!file.exists(path)){
    return(FALSE)
  }

  meta_path <- paste0(path, ".meta.json")
  meta <- list()


  if(file.exists(meta_path)){
    meta <- jsonlite::fromJSON(meta_path)
    if(!is.null(meta$ParochialCacheKey)){
      return(meta$ParochialCacheKey)
    }
  }

  sha1sum <- openssl::sha1(file(path)) %>% as.character()
  class(sha1sum) <- "character"

  meta$ParochialCacheKey <- sha1sum

  meta %>%
    jsonlite::toJSON(pretty = TRUE) %>%
    write(meta_path)

  return(sha1sum)
}