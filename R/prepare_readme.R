prepare_readme <- function(){

  output_readme_path <- dir_working("output_readme.Rmd")

  if(!fs::file_exists(output_readme_path)){
    output_readme_path <- dir_support("output_readme.Rmd")
  }

  release_body_path <- dir_working("release_body.Rmd")

  if(!fs::file_exists(release_body_path)){
    release_body_path <- dir_support("release_body.Rmd")
  }

  rmarkdown::render(output_readme_path, knit_root_dir=normalizePath("."), output_dir=dir_output(), output_format="all")
  rmarkdown::render(release_body_path,  knit_root_dir=normalizePath("."), output_dir=dir_output(), output_format="all")

}
