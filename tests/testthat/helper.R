# Do not move this to another line as the location of this piece of code is tested for
test_info <- function() {
  log_info("TEST")
}

local_test_logger <- function(threshold = INFO,
                              formatter = formatter_glue,
                              layout = layout_simple,
                              appender = appender_stdout,
                              namespace = "global",
                              frame = parent.frame()) {
  old <- namespaces[[namespace]]

  namespaces[[namespace]] <- list(
    default = list(
      threshold = as.loglevel(threshold),
      layout    = layout,
      formatter = formatter,
      appender  = appender
    )
  )

  withr::defer(namespaces[[namespace]] <- old, frame)
  invisible()
}

eval_outside <- function(...) {
  input <- normalizePath(withr::local_tempfile(lines = character()), winslash = "/")
  output <- normalizePath(withr::local_tempfile(lines = character()), winslash = "/")
  writeLines(con = input, c(
    "library(logger)",
    "log_layout(layout_glue_generator('{level} {msg}'))",
    paste0("log_appender(appender_file('", output, "'))"),
    ...
  ))
  path <- file.path(R.home("bin"), "Rscript")
  if (Sys.info()[["sysname"]] == "Windows") {
    path <- paste0(path, ".exe")
  }
  suppressWarnings(system2(path, input, stdout = TRUE, stderr = TRUE))
  readLines(output)
}
