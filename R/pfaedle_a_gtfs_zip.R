pfaedle_a_gtfs_zip <- function(path_to_gtfs_zip, path_to_osm = dir_output("openstreetmap/", output_affix(), ".osm.pbf")){

  checkmate::assert_file_exists(path_to_gtfs_zip, access="r", extension=".zip")
  checkmate::assert_file_exists(path_to_osm, access="r", extension=c(".pbf", ".osm"))

  temp_dir_path <- tempfile(tmpdir = dir_working())
    unzip(path_to_gtfs_zip, exdir=temp_dir_path)

  prepare_osm_for_pfaedle(path_to_osm, paste0(temp_dir_path, "/temp.osm"))

  pfaedle_args <- c(
    "-D",
    "-c", dir_support("pfaedle.cfg"),
    "-x", paste0(temp_dir_path, "/temp.osm"),
    temp_dir_path,
    "-o", paste0(temp_dir_path, "/gtfs-out")
  )

  processx::run("pfaedle", pfaedle_args)

  new_gtfs_zip_path <- paste0(temp_dir_path, "/", basename(path_to_gtfs_zip))

  utils::zip(
    zipfile = new_gtfs_zip_path, 
    files = dir(paste0(temp_dir_path, "/gtfs-out"), pattern="\\.txt$", full.names=TRUE),
    flags = "-rj0X"
    )

  stopifnot("Unknown error rezipping pfaedled GTFS" = file.exists(new_gtfs_zip_path))

  new_gtfs <- gtfstools::read_gtfs(new_gtfs_zip_path)
  trip_speeds <- gtfstools::get_trip_speed(new_gtfs) %>%
    left_join(new_gtfs$trips, by='trip_id') %>%
    left_join(new_gtfs$routes, by='route_id') %>%
    left_join(gtfs_route_types()) %>%
    select(trip_id, speed, max_speed_kmh)

  # Speed is in km/h and these are quite generous...
  trips_to_strip_shape_id <- trip_speeds %>%
    filter(speed > max_speed_kmh)

  new_gtfs$trips <- new_gtfs$trips %>%
    mutate(shape_id = if_else(trip_id %in% trips_to_strip_shape_id$trip_id, "", shape_id))

  message("Dropped ", nrow(trips_to_strip_shape_id), " shapes as too fast")

  new_gtfs$shapes <- new_gtfs$shapes %>%
    filter(shape_id %in% new_gtfs$trips$shape_id)

  unlink(path_to_gtfs_zip)
  new_gtfs %>% gtfstools::write_gtfs(path_to_gtfs_zip)

  unlink(temp_dir_path, recursive = TRUE)

  if(gtfstidy_is_available()){
    gtfstidy_simplify_shapes(path_to_gtfs_zip)
  }

  return(path_to_gtfs_zip)
}

prepare_osm_for_pfaedle <- function(in_osm_path, out_osm_path) {

  message("Writing filtered OSM in XML format for pfaedle...")

  osmium_args <- c(
    "tags-filter",
    "--expressions", dir_support("pfaedle_osm_tags.txt"),
    in_osm_path,
    "-o", out_osm_path,
    "-f", "osm,add_metadata=false", 
    "--overwrite"
  )

  processx::run("osmium", osmium_args)
  stopifnot("Unknown error writing OSM in XML format for pfaedle" = file.exists(out_osm_path))

  return(out_osm_path)
}
