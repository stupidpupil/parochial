cache_key_for_brouter_tile_url <- function(brouter_tile_url){
  checkmate::assert_character(brouter_tile_url, len=1, pattern=paste0("^https?://brouter\\.de/brouter/segments4/.+$"))

  brouter_head <- httr::HEAD(brouter_tile_url)
  openssl::sha1(paste0(
    brouter_head$headers$ETag,
    brouter_tile_url
  )) %>% as.character()

}