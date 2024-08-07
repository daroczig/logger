## init storage for all logger settings
namespaces <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  namespaces_reset()
}

namespaces_reset <- function() {
  rm(list = ls(namespaces), envir = namespaces)

  ## default namespace's logger settings
  namespaces$global <- list(
    ## there can be multiple loggers for a namespace
    default = list(
      threshold = as.loglevel(Sys.getenv("LOGGER_LOG_LEVEL", unset = "INFO")),
      layout    = layout_simple,
      formatter = formatter_sprintf,
      appender  = if (in_pkgdown()) appender_stdout else appender_console
    )
  )

  if (requireNamespace("glue", quietly = TRUE)) {
    log_formatter(formatter_glue, namespace = "global", index = 1)
  }

  ## internal namespace for debugging logger
  namespaces$.logger <- list(
    default = list(
      threshold = ERROR,
      layout    = layout_simple,
      formatter = formatter_sprintf,
      appender  = appender_console
    )
  )
}

.onAttach <- function(libname, pkgname) {
  ## warn user about using sprintf instead of glue due to missing dependency
  if (!requireNamespace("glue", quietly = TRUE)) {
    packageStartupMessage(
      paste(
        'logger: As the "glue" R package is not installed,',
        'using "sprintf" as the default log message formatter instead of "glue".'
      )
    )
  }
}
