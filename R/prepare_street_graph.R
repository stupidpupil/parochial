prepare_street_graph <- function(){

  input_files <- c(
      Sys.glob(dir_output("openstreetmap/*.osm.pbf")),
      Sys.glob(dir_output("*terr50.tif"))
    )

  cache_key <- openssl::sha1(paste0(
    openssl::sha1(file(dir_support("otp_config/build-config.json"))),
    openssl::sha1(file(dir_support("otp_config/router-config.json"))),
    paste0(cache_key_for_file(input_files), collapse=""),
    otp_version()
    )) %>% as.character()

  dest_path <- dir_output("opentripplanner/streetGraph.obj")
  dest_dir <- dirname(dest_path)

  if(cache_key == cache_key_for_file(dest_path)){
    message("Cache hit for ", dest_path)
    return(dest_path)
  }

  prepare_otp_config()

  if(fs::file_exists(dest_path)){
    fs::file_delete(dest_path)
  }

  message("Preparing OpenTripPlanner street graph...")

  link_paths <- link_create_with_dir(input_files, dest_dir)
  on.exit({fs::link_delete(link_paths)}, add = TRUE)

  otp_args <- c(
    "-jar", dir_working("otp.jar"), 
    "--cache", dir_working("otp_cache"), 
    "--buildStreet", dest_dir
    )

  processx::run("java", c(java_args(), otp_args))

  stopifnot("Unknown error writing OTP street graph" = file.exists(dest_path))

  list(
    CreatedAt = now_as_iso8601(),
    CreatedWithOpenTripPlannerVersion = otp_version(),
    DerivedFrom = describe_file(input_files),
    ParochialCacheKey = cache_key
  ) %>% jsonlite::toJSON(pretty = TRUE) %>%
  write(paste0(dest_path, ".meta.json"))

  return(dest_path)
}
