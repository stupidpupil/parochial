#' Get the parochial cache key for a TravelWhiz GTFS URL
#' 
#' @details
#' The cache key is based on the ETag HTTP header and the URL itself.
#'
#' @param travelwhiz_url A URL for a TravelWhiz GTFS download.
#'
cache_key_for_travelwhiz_url <- function(travelwhiz_url){

  checkmate::assert_character(travelwhiz_url, len=1, pattern=paste0("^https://storage\\.travelwhiz\\.app/generated-gtfs/.+$"))

  travelwhiz_head <- httr::HEAD(travelwhiz_url)
  openssl::sha1(paste0(
    travelwhiz_head$headers$ETag,
    travelwhiz_url
  )) %>% as.character()
}