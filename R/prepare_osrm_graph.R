prepare_osrm_graph <- function(profile_name="driving"){

  input_files <- dir_output("openstreetmap/", output_affix(), ".osm.pbf")

  dest_path <- path_to_osrm_graph(profile_name)
  dest_dir <- dirname(dest_path)

  cache_key <- openssl::sha1(paste0(
    paste0(cache_key_for_file(input_files), collapse="")
    )) %>% as.character()

  if(cache_key == cache_key_for_file(dest_path)){
    message("Cache hit for ", dest_path)
    return(dest_path)
  }

  unlink(Sys.glob(paste0(dest_path, "*")))

  link_paths <- link_create_with_dir(input_files, dest_dir)
  on.exit({fs::link_delete(link_paths)}, add = TRUE)

  message("OSRM-Extracting...")

  # TODO - https://stxxl.org/tags/1.4.1/install_config.html
  
  profile_path <- fs::path_package(package_name(), "extdata", "osrm", profile_name, ext="lua")
  checkmate::assert_file_exists(profile_path, access="r")

  unlink(Sys.glob(paste0(dest_path, "*")))
  processx::run("osrm-extract", c("-p", profile_path, link_paths))
  
  stopifnot("Unknown error writing OSRM graph" = file.exists(paste0(dest_path,".edges"))) # HACK
  
  message("OSRM-Contracting...")

  processx::run("osrm-contract", dest_path)

  stopifnot("Unknown error writing OSRM graph" = file.exists(paste0(dest_path, ".hsgr"))) # HACK

  
  # TODO - optionally clean-up files that osrm-routed doesn't need
  # https://github.com/Project-OSRM/osrm-backend/wiki/Toolchain-file-overview

  list(
    CreatedAt = now_as_iso8601(),
    DerivedFrom = describe_file(input_files),
    ParochialCacheKey = cache_key
  ) %>% jsonlite::toJSON(pretty = TRUE) %>%
  write(paste0(dest_path, ".meta.json"))

  return(dest_path)
}
