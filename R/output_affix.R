output_affix <- function() {
  ret <- config::get()$output_affix

  if(!is.null(ret)){
    if(ret != ""){
      return(ret)      
    }
  }

  openssl::sha1(bounds() %>% sf::st_as_text()) %>% as.character() %>% stringr::str_sub(end = 6L)
}