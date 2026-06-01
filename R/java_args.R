java_args <- function(){
  c(
    paste0("-Xmx", java_xmx()),
    "-XX:ActiveProcessorCount=2",
    "-Djava.util.concurrent.ForkJoinPool.common.parallelism=2"
  )
}

java_xmx <- function(){
  if(is.null(config::get()$java_xmx)){
    return("8g")
  }

  config::get()$java_xmx
}
