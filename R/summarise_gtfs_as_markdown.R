summarise_gtfs_as_markdown <- function(gtfs_path){

	path_to_gtfs_summary_rmd <- dir_support("gtfs_summary.Rmd")

	temp_markdown_path <- tempfile(tmpdir = dir_working(), fileext=".md")

	on.exit(fs::file_delete(temp_markdown_path))
	knitr::knit(path_to_gtfs_summary_rmd, temp_markdown_path)

	readr::read_file(temp_markdown_path)
}