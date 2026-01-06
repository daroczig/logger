#' Collect useful information about the logging environment to be used in log messages
#'
#' Available variables to be used in the log formatter functions, eg in [layout_glue_generator()]:
#'
#' * `levelr`: log level as an R object, eg [INFO()]
#' * `level`: log level as a string, eg [INFO()]
#' * `time`: current time as `POSIXct`
#' * `node`: name by which the machine is known on the network as reported by `Sys.info`
#' * `arch`: machine type, typically the CPU architecture
#' * `os_name`: Operating System's name
#' * `os_release`: Operating System's release
#' * `os_version`: Operating System's version
#' * `user`: name of the real user id as reported by `Sys.info`
#' * `pid`: the process identification number of the R session
#' * `node`: name by which the machine is known on the network as reported by `Sys.info`
#' * `r_version`: R's major and minor version as a string
#' * `ns`: namespace usually defaults to `global` or the name of the holding R package
#'   of the calling the logging function
#' * `ns_pkg_version`: the version of `ns` when it's a package
#' * `ans`: same as `ns` if there's a defined [logger()] for the namespace,
#'   otherwise a fallback namespace (eg usually `global`)
#' * `topenv`: the name of the top environment from which the parent call was called
#'   (eg R package name or `GlobalEnv`)
#' * `call`: parent call (if any) calling the logging function
#' * `location`: A list with element `path` and `line` giving the location of the
#'   log call
#' * `fn`: function's (if any) name calling the logging function
#'
#' @param log_level log level as per [log_levels()]
#' @inheritParams log_level
#' @return list
#' @export
#' @importFrom utils packageVersion
#' @seealso [layout_glue_generator()]
#' @family log_layouts
get_logger_meta_variables <- function(log_level = NULL,
                                      namespace = NA_character_,
                                      .logcall = sys.call(),
                                      .topcall = sys.call(-1),
                                      .topenv = parent.frame(),
                                      .timestamp = Sys.time()) {
  sysinfo <- Sys.info()

  list(
    ns = namespace,
    ans = fallback_namespace(namespace),
    topenv = top_env_name(.topenv),
    fn = deparse_to_one_line(.topcall[[1]]),
    call = deparse_to_one_line(.topcall),
    location = log_call_location(.logcall),
    time = .timestamp,
    levelr = log_level,
    level = attr(log_level, "level"),
    pid = Sys.getpid(),

    ## R and ns package versions
    r_version = paste0(R.Version()[c("major", "minor")], collapse = "."),
    ns_pkg_version = tryCatch(as.character(packageVersion(namespace)), error = function(e) NA_character_),

    ## stuff from Sys.info
    node = sysinfo[["nodename"]],
    arch = sysinfo[["machine"]],
    os_name = sysinfo[["sysname"]],
    os_release = sysinfo[["release"]],
    os_version = sysinfo[["version"]],
    user = sysinfo[["user"]]
    ## NOTE might be better to rely on the whoami pkg?

    ## TODO jenkins (or any) env vars => no need to get here, users can write custom layouts
    ## TODO seed
  )
}


#' Generate log layout function using common variables available via glue syntax
#'
#' `format` is passed to [glue::glue()] with access to the below variables:
#' \itemize{ \item msg: the actual log message \item further variables
#' set by [get_logger_meta_variables()] }
#' @param format [glue::glue()]-flavored layout of the message using the above
#'   variables
#' @return function taking `level` and `msg` arguments - keeping the
#'   original call creating the generator in the `generator` attribute
#'   that is returned when calling [log_layout()] for the currently
#'   used layout
#' @export
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' example_layout <- layout_glue_generator(
#'   format = "{node}/{pid}/{ns}/{ans}/{topenv}/{fn} {time} {level}: {msg}"
#' )
#' example_layout(INFO, "try {runif(1)}")
#'
#' log_layout(example_layout)
#' log_info("try {runif(1)}")
#' \dontshow{logger:::namespaces_set(old)}
#' @seealso See example calls from [layout_glue()] and [layout_glue_colors()].
#' @family log_layouts
layout_glue_generator <- function(format = '{level} [{format(time, "%Y-%m-%d %H:%M:%S")}] {msg}') {
  force(format)

  structure(function(level,
                     msg,
                     namespace = NA_character_,
                     .logcall = sys.call(),
                     .topcall = sys.call(-1),
                     .topenv = parent.frame(),
                     .timestamp = Sys.time()) {
    fail_on_missing_package("glue")
    if (!inherits(level, "loglevel")) {
      stop("Invalid log level, see ?log_levels")
    }

    meta <- logger_meta_env(
      log_level = level,
      namespace = namespace,
      .logcall = .logcall,
      .topcall = .topcall,
      .topenv = .topenv,
      .timestamp = .timestamp,
      parent = environment()
    )
    glue::glue(format, .envir = meta)
  }, generator = deparse(match.call()))
}


#' Format a log record by including the raw message without anything
#' added or modified
#' @inheritParams log_level
#' @param msg string message
#' @return character vector
#' @export
#' @family log_layouts
layout_blank <- function(level,
                         msg,
                         namespace = NA_character_,
                         .logcall = sys.call(),
                         .topcall = sys.call(-1),
                         .topenv = parent.frame(),
                         .timestamp = Sys.time()) {
  msg
}
attr(layout_blank, "generator") <- quote(layout_blank())

#' Format a log record by concatenating the log level, timestamp and
#' message
#' @inheritParams log_level
#' @param msg string message
#' @return character vector
#' @export
#' @family log_layouts
layout_simple <- function(level,
                          msg,
                          namespace = NA_character_,
                          .logcall = sys.call(),
                          .topcall = sys.call(-1),
                          .topenv = parent.frame(),
                          .timestamp = Sys.time()) {
  paste0(attr(level, "level"), " [", format(.timestamp, "%Y-%m-%d %H:%M:%S"), "] ", msg)
}
attr(layout_simple, "generator") <- quote(layout_simple())

#' Format a log record as the logging package does by default
#' @inheritParams layout_simple
#' @param msg string message
#' @return character vector
#' @export
#' @family log_layouts
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' log_layout(layout_logging)
#' log_info(42)
#' log_info(42, namespace = "everything")
#'
#' \dontrun{
#' devtools::load_all(system.file("demo-packages/logger-tester-package", package = "logger"))
#' logger_tester_function(INFO, 42)
#' }
#' \dontshow{logger:::namespaces_set(old)}
layout_logging <- function(level,
                           msg,
                           namespace = NA_character_,
                           .logcall = sys.call(),
                           .topcall = sys.call(-1),
                           .topenv = parent.frame(),
                           .timestamp = Sys.time()) {
  meta <- logger_meta_env(
    log_level = level,
    namespace = namespace,
    .logcall = .logcall,
    .topcall = .topcall,
    .topenv = .topenv,
    .timestamp = .timestamp
  )
  paste0(
    format(meta$time, "%Y-%m-%d %H:%M:%S"), " ",
    attr(level, "level"), ":",
    ifelse(meta$ns == "global", "", meta$ns), ":",
    msg
  )
}
attr(layout_logging, "generator") <- quote(layout_logging())

#' Format a log message with [glue::glue()]
#'
#' By default, this layout includes the log level of the log record as
#' per [log_levels()], the current timestamp and the actual log
#' message -- that you can override via calling
#' [layout_glue_generator()] directly. For colorized output, see
#' [layout_glue_colors()].
#' @inheritParams layout_simple
#' @return character vector
#' @export
#' @family log_layouts
layout_glue <- layout_glue_generator()
attr(layout_glue, "generator") <- quote(layout_glue())

#' Format a log message with [glue::glue()] and ANSI escape codes to add colors
#'
#' Colour log levels based on their severity. Log levels are coloured
#' with [colorize_by_log_level()] and the messages are coloured with
#' [grayscale_by_log_level()].
#'
#' @inheritParams layout_simple
#' @return character vector
#' @export
#' @family log_layouts
#' @note This functionality depends on the \pkg{crayon} package.
#' @examplesIf requireNamespace("crayon")
#' log_layout(layout_glue_colors)
#' log_threshold(TRACE)
#' log_info("Starting the script...")
#' log_debug("This is the second line")
#' log_trace("That is being placed right after the first one.")
#' log_warn("Some errors might come!")
#' log_error("This is a problem")
#' log_debug("Getting an error is usually bad")
#' log_error("This is another problem")
#' log_fatal("The last problem.")
layout_glue_colors <- layout_glue_generator(
  format = paste(
    "{crayon::bold(colorize_by_log_level(level, levelr))}",
    '[{crayon::italic(format(time, "%Y-%m-%d %H:%M:%S"))}]',
    "{grayscale_by_log_level(msg, levelr)}"
  )
)
attr(layout_glue_colors, "generator") <- quote(layout_glue_colors())

#' Generate log layout function rendering JSON
#' @param fields character vector of field names to be included in the
#'   JSON
#' @return character vector
#' @export
#' @note This functionality depends on the \pkg{jsonlite} package.
#' @family log_layouts
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' log_layout(layout_json())
#' log_info(42)
#' log_info("ok {1:3} + {1:3} = {2*(1:3)}")
#' \dontshow{logger:::namespaces_set(old)}
layout_json <- function(fields = default_fields()) {
  force(fields)

  if ("msg" %in% fields) {
    warning("'msg' is always automatically included")
    fields <- setdiff(fields, "msg")
  }

  structure(function(level,
                     msg,
                     namespace = NA_character_,
                     .logcall = sys.call(),
                     .topcall = sys.call(-1),
                     .topenv = parent.frame(),
                     .timestamp = Sys.time()) {
    fail_on_missing_package("jsonlite")

    meta <- logger_meta_env(
      log_level = level,
      namespace = namespace,
      .logcall = .logcall,
      .topcall = .topcall,
      .topenv = .topenv,
      .timestamp = .timestamp
    )
    json <- mget(fields, meta)
    sapply(msg, function(msg) jsonlite::toJSON(c(json, list(msg = msg)), auto_unbox = TRUE))
  }, generator = deparse(match.call()))
}


#' Generate log layout function rendering JSON after merging meta
#' fields with parsed list from JSON message
#' @param fields character vector of field names to be included in the
#'   JSON. If named, the names will be used as field names in the JSON.
#' @export
#' @note This functionality depends on the \pkg{jsonlite} package.
#' @family log_layouts
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' log_formatter(formatter_json)
#' log_info(everything = 42)
#'
#' log_layout(layout_json_parser())
#' log_info(everything = 42)
#'
#' log_layout(layout_json_parser(fields = c("time", "node")))
#' log_info(cars = row.names(mtcars), species = unique(iris$Species))
#'
#' log_layout(layout_json_parser(fields = c(timestamp = "time", "node")))
#' log_info(
#'   message = paste(
#'     "Compared to the previous example,
#'     the 'time' field is renamed to 'timestamp'"
#'   )
#' )
#' \dontshow{logger:::namespaces_set(old)}
#' @importFrom stats setNames
layout_json_parser <- function(fields = default_fields()) {
  force(fields)

  structure(function(level,
                     msg,
                     namespace = NA_character_,
                     .logcall = sys.call(),
                     .topcall = sys.call(-1),
                     .topenv = parent.frame(),
                     .timestamp = Sys.time()) {
    fail_on_missing_package("jsonlite")

    meta <- logger_meta_env(
      log_level = level,
      namespace = namespace,
      .logcall = .logcall,
      .topcall = .topcall,
      .topenv = .topenv,
      .timestamp = .timestamp
    )
    meta <- mget(fields, meta)
    field_names <- names(fields)
    if (!is.null(field_names)) {
      norename <- field_names == ""
      field_names[norename] <- fields[norename]
      meta <- setNames(meta, field_names)
    }
    msg <- jsonlite::fromJSON(msg)

    jsonlite::toJSON(c(meta, msg), auto_unbox = TRUE, null = "null")
  }, generator = deparse(match.call()))
}

default_fields <- function() {
  c(
    "time", "level", "ns", "ans", "topenv", "fn", "node", "arch",
    "os_name", "os_release", "os_version", "pid", "user"
  )
}

#' Format a log record for github actions
#'
#' GitHub Actions can recognise specially formatted output and make these
#' prominent in the output. The `layout_gha()` layout will ensure the correct
#' formatting when running in GitHub Actions.
#'
#' @note
#' GitHub Actions only recognise the log levels `error`, `warning`, `notice`,
#' and `debug`. Because of this, `FATAL` and `ERROR` are coerced to `error`,
#' `SUCCESS` and `INFO` are coerced to `notice`, and `DEBUG` and `TRACE` are
#' coerced to `debug` (`WARN` maps directly to `warning`).
#'
#' @inheritParams layout_simple
#' @return character vector
#' @export
#' @family log_layouts
#'
layout_gha <- structure(
  function(level,
           msg,
           namespace = NA_character_,
           .logcall = sys.call(),
           .topcall = sys.call(-1),
           .topenv = parent.frame(),
           .timestamp = Sys.time()) {
    level <- attr(level, "level")
    gha_level <- switch(level,
      FATAL = ,
      ERROR = "error",
      WARN = "warning",
      SUCCESS = ,
      INFO = "notice",
      DEBUG = ,
      TRACE = "debug",
      "notice" # Defaults to notice if for some reason another level gets used
    )
    title <- if (gha_level == "debug") "" else paste0(" title=", level)
    paste0("::", gha_level, title, "::", msg)
  },
  generator = quote(layout_gha())
)

# nocov start
#' Format a log record for syslognet
#'
#' Format a log record for syslognet.
#' This function converts the logger log level to a
#' log severity level according to RFC 5424 "The Syslog Protocol".
#'
#' @inheritParams layout_simple
#' @return A character vector with a severity attribute.
#' @export
layout_syslognet <- structure(
  function(level,
           msg,
           namespace = NA_character_,
           .logcall = sys.call(),
           .topcall = sys.call(-1),
           .topenv = parent.frame(),
           .timestamp = Sys.time()) {
    ret <- paste(attr(level, "level"), msg)
    attr(ret, "severity") <- switch(
      attr(level, "level", exact = TRUE),
      "FATAL" = "CRITICAL",
      "ERROR" = "ERR",
      "WARN" = "WARNING",
      "SUCCESS" = "NOTICE",
      "INFO" = "INFO",
      "DEBUG" = "DEBUG",
      "TRACE" = "DEBUG"
    )
    ret
  },
  generator = quote(layout_syslognet())
)
# nocov end
