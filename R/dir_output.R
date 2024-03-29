dir_output <- function(...){
  ret <- NULL

  try({
    ret <-config::get()$dir_output
  }, silent=TRUE)

  if(is.null(ret)){
    ret <- "output"
  }

  if(length(list(...)) > 0){
    ret <- paste0(ret, "/", paste0(...))
    fs::dir_create(fs::path_dir(ret), recurse=TRUE)
  }

  return(ret)
}