## init storage for all logger settings
namespaces <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  namespaces_set(namespaces_default())
}

namespaces_reset <- function() {
  rm(list = ls(namespaces), envir = namespaces)
  namespaces_set(namespaces_default())
}

namespaces_default <- function() {
  has_glue <- requireNamespace("glue", quietly = TRUE)
  is_running_gha <- isTRUE(Sys.getenv("GITHUB_ACTIONS") == "true")

  list(
    global = list(
      default = list(
        threshold = as.loglevel(Sys.getenv("LOGGER_LOG_LEVEL", unset = "INFO")),
        layout    = if (is_running_gha) layout_gha else layout_simple,
        formatter = if (has_glue) formatter_glue else formatter_sprintf,
        appender  = if (needs_stdout()) appender_stdout else if (is_running_gha) appender_stderr else appender_console
      )
    ),
    .logger = list(
      default = list(
        threshold = ERROR,
        layout    = if (is_running_gha) layout_gha else layout_simple,
        formatter = formatter_sprintf,
        appender  = if (needs_stdout()) appender_stdout else if (is_running_gha) appender_stderr else appender_console
      )
    )
  )
}

namespaces_set <- function(new = namespaces_default()) {
  old <- as.list(namespaces)

  rm(list = ls(namespaces), envir = namespaces)
  list2env(new, namespaces)

  invisible(old)
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
