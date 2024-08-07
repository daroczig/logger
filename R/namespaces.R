## init storage for all logger settings
namespaces <- new.env(parent = emptyenv())

namespaces_reset <- function() {
  rm(list = ls(namespaces), envir = namespaces)

  ## default namespace's logger settings
  namespaces$global <- list(
      ## there can be multiple loggers for a namespace
      default = list(
          threshold = as.loglevel(Sys.getenv('LOGGER_LOG_LEVEL', unset = 'INFO')),
          layout    = layout_simple,
          formatter = formatter_sprintf,
          appender  = if (in_pkgdown()) appender_stdout else appender_console))

  if (requireNamespace('glue', quietly = TRUE)) {
      log_formatter(formatter_glue, namespace = 'global', index = 1)
  }

  ## internal namespace for debugging logger
  namespaces$.logger <- list(
      default = list(
          threshold = ERROR,
          layout    = layout_simple,
          formatter = formatter_sprintf,
          appender  = appender_console))

}

#' Looks up logger namespaces
#' @return character vector of namespace names
#' @export
log_namespaces <- function() {
  ls(envir = namespaces)
}


#' Checks if provided namespace exists and falls back to global if not
#' @param namespace string
#' @return string
#' @noRd
fallback_namespace <- function(namespace) {
  if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
      namespace <- 'global'
  }
  namespace
}


#' Find the logger definition(s) specified for the current namespace with a fallback to the global namespace
#' @return list of function(s)
#' @importFrom utils getFromNamespace
#' @param namespace override the default / auto-picked namespace with a custom string
#' @noRd
get_logger_definitions <- function(namespace = NA_character_, .topenv = parent.frame()) {
  namespace <- ifelse(is.na(namespace), top_env_name(.topenv), namespace)
  if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
      namespace <- 'global'
  }
  get(namespace, envir = getFromNamespace('namespaces', 'logger'))
}

#' Delete an index from a logger namespace
#' @inheritParams log_threshold
#' @export
delete_logger_index <- function(namespace = 'global', index) {
  configs <- get(fallback_namespace(namespace), envir = namespaces)
  if (index > length(configs)) {
      stop(sprintf('%s namespace has only %i indexes', namespace, length(configs)))
  }
  configs[index] <- NULL
  assign(namespace, configs, envir = namespaces)
}
