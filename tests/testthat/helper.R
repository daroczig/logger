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
