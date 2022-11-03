summarise_gtfs_as_markdown <- function(gtfs_paths){

  if(length(gtfs_paths) == 0){
    return("")
  }

  checkmate::assert_file_exists(gtfs_paths)

  if(length(gtfs_paths) > 1){
    return(gtfs_paths |> purrr::map_chr(summarise_gtfs_as_markdown) |> paste0(collapse = "\n\n"))
  }else{
    gtfs_path <- gtfs_paths
  }

  gtfs_path <- fs::path_wd(gtfs_path)

  path_to_gtfs_summary_rmd <- dir_support("gtfs_summary.Rmd")

  temp_markdown_path <- tempfile(tmpdir = dir_working(), fileext=".md")

  on.exit(fs::file_delete(temp_markdown_path))
  knitr::knit(path_to_gtfs_summary_rmd, temp_markdown_path)

  readr::read_file(temp_markdown_path)
}
