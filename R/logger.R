#' Generate logging utility
#'
#' A logger consists of a log level `threshold`, a log message
#' `formatter` function, a log record `layout` formatting function and
#' the `appender` function deciding on the destination of the log
#' record. For more details, see the package `README.md`.
#'
#' By default, a general logger definition is created when loading the `logger` package, that uses
#'
#' * [INFO()] (or as per the `LOGGER_LOG_LEVEL` environment variable override) as the log level threshold
#' * [layout_simple()] as the layout function showing the log level, timestamp and log message
#' * [formatter_glue()] (or [formatter_sprintf()] if \pkg{glue} is not installed) as the
#'   default formatter function transforming the R objects to be logged to a character vector
#' * [appender_console()] as the default log record destination
#'
#' @param threshold omit log messages below this [log_levels()]
#' @param formatter function pre-processing the message of the log
#'   record when it's not wrapped in a [skip_formatter()] call
#' @param layout function rendering the layout of the actual log
#'   record
#' @param appender function writing the log record
#' @return A function taking the log `level` to compare with the set
#'   threshold, all the `...` arguments passed to the formatter
#'   function, besides the standard `namespace`, `.logcall`,
#'   `.topcall` and `.topenv` arguments (see [log_level()] for more
#'   details). The function invisibly returns a list including the
#'   original `level`, `namespace`, all `...` transformed to a list as
#'   `params`, the log `message` (after calling the `formatter`
#'   function) and the log `record` (after calling the `layout`
#'   function), and a list of `handlers` with the `formatter`,
#'   `layout` and `appender` functions.
#' @export
#' @references For more details, see vignette("customize_logger")
#' @note It's quite unlikely that you need to call this function
#'   directly, but instead set the logger parameters and functions at
#'   [log_threshold()], [log_formatter()], [log_layout()] and
#'   [log_appender()] and then call [log_levels()] and its
#'   derivatives, such as [log_info()] directly.
#' @examples \dontrun{
#' do.call(logger, logger:::namespaces$global[[1]])(INFO, 42)
#' do.call(logger, logger:::namespaces$global[[1]])(INFO, "{pi}")
#' x <- 42
#' do.call(logger, logger:::namespaces$global[[1]])(INFO, "{x}^2 = {x^2}")
#' }
logger <- function(threshold, formatter, layout, appender) {
  force(threshold)
  threshold <- validate_log_level(threshold)
  force(layout)
  force(appender)

  function(level, ..., namespace = NA_character_,
           .logcall = sys.call(), .topcall = sys.call(-1),
           .topenv = parent.frame(), .timestamp = Sys.time()) {
    res <- list(
      level = level,
      namespace = namespace,
      params = list(...),
      handlers = list(
        formatter = formatter,
        layout = layout,
        appender = appender
      ),
      message = NULL,
      record = NULL
    )

    if (level > threshold) {
      return(invisible(res))
    }

    ## workaround to be able to avoid any formatter function, eg when passing in a string
    if (length(res$params) == 1 && isTRUE(attr(res$params[[1]], "skip_formatter", exact = TRUE))) {
      res$message <- res$params[[1]]
    } else {
      res$message <- do.call(formatter, c(res$params, list(
        .logcall = substitute(.logcall),
        .topcall = substitute(.topcall),
        .topenv = .topenv
      )))
    }

    ## .timestamp arg was added in 0.4.1 and external layout fns might not support it yet
    if (".timestamp" %in% names(formals(layout))) {
      res$record <- layout(
        level, res$message,
        namespace = namespace,
        .logcall = substitute(.logcall),
        .topcall = substitute(.topcall),
        .topenv = .topenv,
        .timestamp = .timestamp
      )
    } else {
      res$record <- layout(
        level, res$message,
        namespace = namespace,
        .logcall = substitute(.logcall),
        .topcall = substitute(.topcall),
        .topenv = .topenv
      )
    }

    appender(res$record)
    invisible(res)
  }
}


#' Checks if provided namespace exists and falls back to global if not
#' @param namespace string
#' @return string
#' @noRd
fallback_namespace <- function(namespace) {
  if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
    namespace <- "global"
  }
  namespace
}

#' @param namespace logger namespace
#' @param index index of the logger within the namespace
#' @return If `value` is `NULL`, will return the currently set value.
#'   If `value` is not `NULL`, will return the previously set value.
#' @noRd
log_config_setter <- function(name, value, namespace = "global", index = 1) {
  if (length(namespace) > 1) {
    for (ns in namespace) {
      log_config_setter(name, value, ns, index)
    }
    return(invisible())
  }

  configs <- get(fallback_namespace(namespace), envir = namespaces)
  config <- configs[[min(index, length(configs))]]
  old <- config[[name]]

  if (name == "threshold") {
    if (is.null(value)) {
      return(config[[name]])
    }
    config[[name]] <- validate_log_level(value)
  } else {
    if (is.null(value)) {
      res <- config[[name]]
      if (!is.null(attr(res, "generator"))) {
        res <- parse(text = attr(res, "generator"))[[1]]
      }
      return(res)
    }

    config[[name]] <- value
  }

  configs[[min(index, length(config) + 1)]] <- config
  assign(namespace, configs, envir = namespaces)
  invisible(old)
}


#' Delete an index from a logger namespace
#' @inheritParams log_threshold
#' @export
delete_logger_index <- function(namespace = "global", index) {
  configs <- get(fallback_namespace(namespace), envir = namespaces)
  if (index > length(configs)) {
    stop(sprintf("%s namespace has only %i indexes", namespace, length(configs)))
  }
  configs[index] <- NULL
  assign(namespace, configs, envir = namespaces)
}


#' Get or set log level threshold
#' @param level see [log_levels()]
#' @param namespace logger namespace
#' @param index index of the logger within the namespace
#' @return currently set log level threshold
#' @export
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' ## check the currently set log level threshold
#' log_threshold()
#'
#' ## change the log level threshold to WARN
#' log_threshold(WARN)
#' log_info(1)
#' log_warn(2)
#'
#' ## add another logger with a lower log level threshold and check the number of logged messages
#' log_threshold(INFO, index = 2)
#' log_info(1)
#' log_warn(2)
#'
#' ## set the log level threshold in all namespaces to ERROR
#' log_threshold(ERROR, namespace = log_namespaces())
#' \dontshow{logger:::namespaces_set(old)}
#' @family log configutation functions
log_threshold <- function(level = NULL, namespace = "global", index = 1) {
  log_config_setter("threshold", level, namespace = namespace, index = index)
}


#' Get or set log record layout
#' @param layout function defining the structure of a log record, eg
#'   [layout_simple()], [layout_glue()] or [layout_glue_colors()],
#'   [layout_json()], or generator functions such as
#'   [layout_glue_generator()], default NULL
#' @inheritParams log_threshold
#' @export
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' log_layout(layout_json())
#' log_info(42)
#' \dontshow{logger:::namespaces_set(old)}
#' @family log configutation functions
log_layout <- function(layout = NULL, namespace = "global", index = 1) {
  if (!is.null(layout) && !is.function(layout)) {
    stop("`layout` must be a function")
  }
  log_config_setter("layout", layout, namespace = namespace, index = index)
}


#' Get or set log message formatter
#' @param formatter function defining how R objects are converted into
#'   a single string, eg [formatter_paste()], [formatter_sprintf()],
#'   [formatter_glue()], [formatter_glue_or_sprintf()],
#'   [formatter_logging()], default NULL
#' @inheritParams log_threshold
#' @export
#' @family log configutation functions
log_formatter <- function(formatter = NULL, namespace = "global", index = 1) {
  if (!is.null(formatter) && !is.function(formatter)) {
    stop("`formatter` must be a function")
  }
  log_config_setter("formatter", formatter, namespace = namespace, index = index)
}


#' Get or set log record appender function
#' @param appender function delivering a log record to the
#'   destination, eg [appender_console()], [appender_file()] or
#'   [appender_tee()], default NULL
#' @inheritParams log_threshold
#' @export
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' ## change appender to "tee" that writes to the console and a file as well
#' t <- tempfile()
#' log_appender(appender_tee(t))
#' log_info(42)
#' log_info(43)
#' log_info(44)
#' readLines(t)
#'
#' ## poor man's tee by stacking loggers in the namespace
#' t <- tempfile()
#' log_appender(appender_stdout)
#' log_appender(appender_file(t), index = 2)
#' log_info(42)
#' readLines(t)
#' \dontshow{logger:::namespaces_set(old)}
#' @family log configutation functions
log_appender <- function(appender = NULL, namespace = "global", index = 1) {
  if (!is.null(appender) && !is.function(appender)) {
    stop("`appender` must be a function")
  }
  log_config_setter("appender", appender, namespace = namespace, index = index)
}


#' Find the logger definition(s) specified for the current namespace
#' with a fallback to the global namespace
#' @return list of function(s)
#' @noRd
#' @importFrom utils getFromNamespace
#' @param namespace override the default / auto-picked namespace with
#'   a custom string
get_logger_definitions <- function(namespace = NA_character_, .topenv = parent.frame()) {
  namespace <- ifelse(is.na(namespace), top_env_name(.topenv), namespace)
  if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
    namespace <- "global"
  }
  get(namespace, envir = getFromNamespace("namespaces", "logger"))
}


#' Looks up logger namespaces
#' @return character vector of namespace names
#' @export
log_namespaces <- function() {
  ls(envir = namespaces)
}


#' Returns number of currently active indices
#' @param namespace override the default / auto-picked namespace with
#'   a custom string
#' @return number of indices
#' @export
log_indices <- function(namespace = "global") {
  length(get(fallback_namespace(namespace), envir = namespaces))
}


#' Log a message with given log level
#' @param level log level, see [log_levels()] for more details
#' @param ... R objects that can be converted to a character vector
#'   via the active message formatter function
#' @param namespace string referring to the `logger` environment /
#'   config to be used to override the target of the message record to
#'   be used instead of the default namespace, which is defined by the
#'   R package name from which the logger was called, and falls back
#'   to a common, global namespace.
#' @param .logcall the logging call being evaluated (useful in
#'   formatters and layouts when you want to have access to the raw,
#'   unevaluated R expression)
#' @param .topcall R expression from which the logging function was
#'   called (useful in formatters and layouts to extract the calling
#'   function's name or arguments)
#' @param .topenv original frame of the `.topcall` calling function
#'   where the formatter function will be evaluated and that is used
#'   to look up the `namespace` as well via `logger:::top_env_name`
#' @param .timestamp The time the logging occured. Defaults to the current time
#'   but may be overwritten if the logging is delayed from the time it happend
#' @export
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' log_level(INFO, "hi there")
#' log_info("hi there")
#'
#' ## output omitted
#' log_debug("hi there")
#'
#' ## lower threshold and retry
#' log_threshold(TRACE)
#' log_debug("hi there")
#'
#' ## multiple lines
#' log_info("ok {1:3} + {1:3} = {2*(1:3)}")
#'
#' ## use json layout
#' log_layout(layout_json(c("time", "level")))
#' log_info("ok {1:3} + {1:3} = {2*(1:3)}")
#' \dontshow{logger:::namespaces_set(old)}
#' @return Invisible `list` of `logger` objects. See [logger()] for more details on the format.
log_level <- function(level, ..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1),
                      .topenv = parent.frame(), .timestamp = Sys.time()) {
  ## guess namespace
  if (is.na(namespace)) {
    topenv <- top_env_name(.topenv)
    namespace <- ifelse(topenv == "R_GlobalEnv", "global", topenv)
  }

  definitions <- get_logger_definitions(namespace, .topenv = .topenv)
  level <- validate_log_level(level)

  ## super early return (even before evaluating passed parameters)
  if (length(definitions) == 1 && level > definitions[[1]]$threshold) {
    return(invisible(NULL))
  }

  log_arg <- list(...)
  log_arg$level <- level
  log_arg$.logcall <- .logcall
  log_arg$.topcall <- if (!is.null(.topcall)) {
    .topcall
  } else {
    ## cannot pass NULL
    NA
  }
  log_arg$.topenv <- .topenv
  log_arg$.timestamp <- .timestamp
  log_arg$namespace <- namespace

  invisible(lapply(definitions, function(definition) {
    if (level > definition$threshold) {
      return(NULL)
    }

    log_fun <- do.call(logger, definition)
    structure(do.call(log_fun, log_arg), class = "logger")
  }))
}


#' Assure valid log level
#' @param level [log_levels()] object or string representation
#' @return [log_levels()] object
#' @noRd
validate_log_level <- function(level) {
  if (inherits(level, "loglevel")) {
    return(level)
  }
  if (is.character(level) && level %in% log_levels_supported) {
    return(get(level))
  }
  stop("Invalid log level")
}


#' @export
#' @rdname log_level
log_fatal <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1),
                      .topenv = parent.frame(), .timestamp = Sys.time()) {
  log_level(FATAL, ..., namespace = namespace, .logcall = .logcall,
            .topcall = .topcall, .topenv = .topenv, .timestamp = .timestamp)
}
#' @export
#' @rdname log_level
log_error <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1),
                      .topenv = parent.frame(), .timestamp = Sys.time()) {
  log_level(ERROR, ..., namespace = namespace, .logcall = .logcall,
            .topcall = .topcall, .topenv = .topenv, .timestamp = .timestamp)
}
#' @export
#' @rdname log_level
log_warn <- function(..., namespace = NA_character_,
                     .logcall = sys.call(), .topcall = sys.call(-1),
                     .topenv = parent.frame(), .timestamp = Sys.time()) {
  log_level(WARN, ..., namespace = namespace, .logcall = .logcall,
            .topcall = .topcall, .topenv = .topenv, .timestamp = .timestamp)
}
#' @export
#' @rdname log_level
log_success <- function(..., namespace = NA_character_,
                        .logcall = sys.call(), .topcall = sys.call(-1),
                        .topenv = parent.frame(), .timestamp = Sys.time()) {
  log_level(SUCCESS, ..., namespace = namespace, .logcall = .logcall,
            .topcall = .topcall, .topenv = .topenv, .timestamp = .timestamp)
}
#' @export
#' @rdname log_level
log_info <- function(..., namespace = NA_character_,
                     .logcall = sys.call(), .topcall = sys.call(-1),
                     .topenv = parent.frame(), .timestamp = Sys.time()) {
  log_level(INFO, ..., namespace = namespace, .logcall = .logcall,
            .topcall = .topcall, .topenv = .topenv, .timestamp = .timestamp)
}
#' @export
#' @rdname log_level
log_debug <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1),
                      .topenv = parent.frame(), .timestamp = Sys.time()) {
  log_level(DEBUG, ..., namespace = namespace, .logcall = .logcall,
            .topcall = .topcall, .topenv = .topenv, .timestamp = .timestamp)
}
#' @export
#' @rdname log_level
log_trace <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1),
                      .topenv = parent.frame(), .timestamp = Sys.time()) {
  log_level(TRACE, ..., namespace = namespace, .logcall = .logcall,
            .topcall = .topcall, .topenv = .topenv, .timestamp = .timestamp)
}


#' Evaluate R expression with a temporarily updated log level threshold
#' @param expression R command
#' @param threshold [log_levels()]
#' @inheritParams log_threshold
#' @export
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' log_threshold(TRACE)
#' log_trace("Logging everything!")
#' x <- with_log_threshold(
#'   {
#'     log_info("Now we are temporarily suppressing eg INFO messages")
#'     log_warn("WARN")
#'     log_debug("Debug messages are suppressed as well")
#'     log_error("ERROR")
#'     invisible(42)
#'   },
#'   threshold = WARN
#' )
#' x
#' log_trace("DONE")
#' \dontshow{logger:::namespaces_set(old)}
with_log_threshold <- function(expression, threshold = ERROR, namespace = "global", index = 1) {
  old <- log_threshold(threshold, namespace = namespace, index = index)
  on.exit(log_threshold(old, namespace = namespace, index = index))
  expression
}
