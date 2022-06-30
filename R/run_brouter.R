run_brouter <- function(code, brouter_dir = dir_working("brouter"), port=17777L) {

  checkmate::assert_integer(port, lower = 1024L, upper=49151L, len=1L)   # TODO - find an open port

  brouter_jar <- Sys.glob(paste0(brouter_dir, "/brouter-*-all.jar"))

  px <- start_program(
      "java", c(
        java_args(), 
        "-cp", brouter_jar,
        "btools.server.RouteServer",
        dir_output("brouter"),
        paste0(brouter_dir, "/profiles2/"),
        ".", # Custom profiles
        port,
        1L, # Threads
        "0.0.0.0"),
      "BRouter.+", timeout=20)


  return(px)
}