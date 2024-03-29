download_osm <- function(){
  old_opts <- options(timeout = download_timeout_in_seconds(1.5*1024*1024*1024))
  on.exit(options(old_opts))

  gb_osm_url <- "https://download.geofabrik.de/europe/great-britain-latest.osm.pbf"
  cache_key <- cache_key_for_osm_url(gb_osm_url)

  dest_path <- dir_working("great-britain-latest.osm.pbf")

  if(cache_key == cache_key_for_file(dest_path)){
    message("Cache hit for ", dest_path)
    return(dest_path)
  }

  download.file(gb_osm_url, dest_path)

  jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE, list(
    SourceUrl = gb_osm_url,
    SourceDownloadedAt = now_as_iso8601(),
    SourceLicence = "ODbL-1.0",
    SourceAttribution = "OpenStreetMap contributors",
    ParochialCacheKey = cache_key
  )) %>% write(paste0(dest_path, ".meta.json"))

  return(dest_path)
}

prepare_osm <- function(){
  src_path <- dir_working("great-britain-latest.osm.pbf")
  dest_path <- dir_output("openstreetmap/", output_affix(), ".osm.pbf")

  checkmate::assert_file_exists(src_path, access="r")
 
  prepare_bounds_geojson()

  cache_key <- openssl::sha1(paste0(
    cache_key_for_file(src_path),
    bounds() %>% sf::st_as_text()
    )) %>% as.character()


  if(cache_key == cache_key_for_file(dest_path)){
    message("Cache hit for ", dest_path)
    return(dest_path)
  }

  message("Preparing OpenStreetMap extract...")

  message("Extracting OSM within bounds-plus-20km buffer...")

  buffered_bounds_geojson_path <- tempfile(tmpdir = dir_working(), fileext=".geojson")
  buffered_temp_path <- tempfile(tmpdir = dir_working(), fileext=".osm.pbf")

  on.exit(fs::file_delete(buffered_bounds_geojson_path))
  on.exit(fs::file_delete(buffered_temp_path))

  bounds(buffer_by_metres = 20000) %>%
    sf::st_write(buffered_bounds_geojson_path)

  buffered_osmium_args <- c(
    "extract",
    "-p", buffered_bounds_geojson_path,
    "-s", "smart",
    "-S", "complete-partial-relations=80",
    "-f", "pbf,pbf_compression=lz4",
    src_path,
    "-o", buffered_temp_path
  )

  processx::run("osmium", buffered_osmium_args)
  stopifnot("Unknown error writing OSM within buffered bounds" = file.exists(buffered_temp_path))

  message("Extracting OSM within bounds...")

  bounded_temp_path <- tempfile(tmpdir = dir_working(), fileext=".osm.pbf")
  on.exit(fs::file_delete(bounded_temp_path))

  bounded_osmium_args <- c(
    "extract",
    "-p", path_to_bounds_geojson(),
    "-s", "smart",
    "-S", "complete-partial-relations=80",
    "-f", "pbf,pbf_compression=lz4",
    buffered_temp_path,
    "-o", bounded_temp_path
  )

  processx::run("osmium", bounded_osmium_args)
  stopifnot("Unknown error writing OSM within bounds" = file.exists(bounded_temp_path))

  message("Extracting OSM transport-tagged entities within bounds-plus-20km buffer...")

  buffered_transport_temp_path <- tempfile(tmpdir = dir_working(), fileext=".osm.pbf")
  on.exit(fs::file_delete(buffered_transport_temp_path))

  buffered_transport_osmium_args <- c(
    "tags-filter",
    "--expressions", dir_support("pfaedle_osm_tags.txt"),
    "-f", "pbf,pbf_compression=lz4",
    buffered_temp_path,
    "-o", buffered_transport_temp_path
  )

  processx::run("osmium", buffered_transport_osmium_args)
  stopifnot("Unknown error writing OSM transport-tagged entities within bounds-plus-20km buffer" = file.exists(buffered_transport_temp_path))

  message("Extracting OSM rail-tagged entities...")

  rail_temp_path <- tempfile(tmpdir = dir_working(), fileext=".osm.pbf")
  on.exit(fs::file_delete(rail_temp_path))

  rail_osmium_args <- c(
    "tags-filter",
    "--expressions", dir_support("rail_osm_tags.txt"),
    src_path,
    "-o", rail_temp_path
  )

  processx::run("osmium", rail_osmium_args)
  stopifnot("Unknown error writing rail-tagged OSM" = file.exists(rail_temp_path))


  message("Merging OSM extracts...")

  if(fs::file_exists(dest_path)){
    fs::file_delete(dest_path)
  }

  # Relates to the operation of osmextract::oe_read()
  gpkg_path <- dest_path %>% stringr::str_replace("\\.osm\\.pbf$", ".gpkg")

  if(fs::file_exists(gpkg_path)){
    fs::file_delete(gpkg_path)
  }

  merge_osmium_args <- c(
    "merge",
    bounded_temp_path,
    buffered_transport_temp_path,
    rail_temp_path,
    "-o", dest_path
  )

  processx::run("osmium", merge_osmium_args)

  stopifnot("Unknown error writing merged OSM" = file.exists(dest_path))

  list(
    CreatedAt = now_as_iso8601(),
    DerivedFrom = I(describe_file(src_path)),
    ParochialCacheKey = cache_key
  ) %>% jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE) %>%
  write(paste0(dest_path, ".meta.json"))

  return(dest_path)
}

download_and_prepare_osm <- function(){
  download_osm()
  dest_path <- prepare_osm()

  return(dest_path)
}
