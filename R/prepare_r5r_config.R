prepare_r5r_config <- function(){

  file.copy(dir_support("r5r/build-config.json"), dir_output("r5r/build-config.json"), overwrite=TRUE)

  stopifnot(file.exists(dir_output("r5r/build-config.json")))

  return(TRUE)
}
