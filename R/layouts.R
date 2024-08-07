#' Generate log layout function using common variables available via glue syntax
#'
#' `format` is passed to `glue` with access to the below variables:
#' \itemize{ \item msg: the actual log message \item further variables
#' set by [get_logger_meta_variables()] }
#' @param format `glue`-flavored layout of the message using the above
#'   variables
#' @return function taking `level` and `msg` arguments - keeping the
#'   original call creating the generator in the `generator` attribute
#'   that is returned when calling [log_layout()] for the currently
#'   used layout
#' @export
#' @examples \dontrun{
#' example_layout <- layout_glue_generator(
#'   format = "{node}/{pid}/{ns}/{ans}/{topenv}/{fn} {time} {level}: {msg}"
#' )
#' example_layout(INFO, "try {runif(1)}")
#'
#' log_layout(example_layout)
#' log_info("try {runif(1)}")
#' }
#' @seealso See example calls from [layout_glue()] and [layout_glue_colors()].
layout_glue_generator <- function(format = '{level} [{format(time, "%Y-%m-%d %H:%M:%S")}] {msg}') {
  force(format)

  structure(function(level, msg, namespace = NA_character_,
                     .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
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
#' @seealso This is a [log_layout()], for alternatives, see
#'   [layout_simple()], [layout_glue_colors()], [layout_json()], or
#'   generator functions such as [layout_glue_generator()]
layout_blank <- structure(function(level, msg, namespace = NA_character_,
                                   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
  msg
}, generator = quote(layout_blank()))


#' Format a log record by concatenating the log level, timestamp and
#' message
#' @inheritParams log_level
#' @param msg string message
#' @return character vector
#' @export
#' @seealso This is a [log_layout()], for alternatives, see
#'   [layout_blank()], [layout_glue()], [layout_glue_colors()],
#'   [layout_json()], [layout_json_parser()], or generator functions
#'   such as [layout_glue_generator()]
layout_simple <- structure(function(level, msg, namespace = NA_character_,
                                    .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
  paste0(attr(level, "level"), " [", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] ", msg)
}, generator = quote(layout_simple()))


#' Format a log record as the logging package does by default
#' @inheritParams layout_simple
#' @param msg string message
#' @return character vector
#' @export
#' @seealso This is a [log_layout()], for alternatives, see
#'   [layout_blank()], [layout_glue()], [layout_glue_colors()],
#'   [layout_json()], [layout_json_parser()], or generator functions
#'   such as [layout_glue_generator()]
#' @examples \dontrun{
#' log_layout(layout_logging)
#' log_info(42)
#' log_info(42, namespace = "everything")
#'
#' devtools::load_all(system.file("demo-packages/logger-tester-package", package = "logger"))
#' logger_tester_function(INFO, 42)
#' }
layout_logging <- structure(function(level, msg, namespace = NA_character_,
                                     .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
  meta <- logger_meta_env(
    log_level = level,
    namespace = namespace,
    .logcall = .logcall,
    .topcall = .topcall,
    .topenv = .topenv
  )
  paste0(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ",
    attr(level, "level"), ":",
    ifelse(meta$ns == "global", "", meta$ns), ":",
    msg
  )
}, generator = quote(layout_logging()))


#' Format a log message with `glue`
#'
#' By default, this layout includes the log level of the log record as
#' per [log_levels()], the current timestamp and the actual log
#' message -- that you can override via calling
#' [layout_glue_generator()] directly. For colorized output, see
#' [layout_glue_colors()].
#' @inheritParams layout_simple
#' @return character vector
#' @export
#' @seealso This is a [log_layout()], for alternatives, see
#'   [layout_blank()], [layout_simple()], [layout_glue_colors()],
#'   [layout_json()], [layout_json_parser()], or generator functions
#'   such as [layout_glue_generator()]
layout_glue <- layout_glue_generator()


#' Format a log message with `glue` and ANSI escape codes to add colors
#'
#' Colour log levels based on their severity. Log levels are coloured
#' with [colorize_by_log_level()] and the messages are coloured with
#' [grayscale_by_log_level()].
#'
#' @inheritParams layout_simple
#' @return character vector
#' @export
#' @seealso This is a [log_layout()], for alternatives, see
#'   [layout_blank()], [layout_simple()], [layout_glue()],
#'   [layout_json()], [layout_json_parser()], or generator functions
#'   such as [layout_glue_generator()]
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


#' Generate log layout function rendering JSON
#' @param fields character vector of field names to be included in the
#'   JSON
#' @return character vector
#' @export
#' @note This functionality depends on the \pkg{jsonlite} package.
#' @seealso This is a [log_layout()], for alternatives, see
#'   [layout_blank()], [layout_simple()], [layout_glue()],
#'   [layout_glue_colors()], [layout_json_parser()], or generator
#'   functions such as [layout_glue_generator()]
#' @examples \dontrun{
#' log_layout(layout_json())
#' log_info(42)
#' log_info("ok {1:3} + {1:3} = {2*(1:3)}")
#' }
#' @note This functionality depends on the \pkg{jsonlite} package.
#' @seealso This is a [log_layout()], for alternatives, see [layout_blank()], [layout_simple()], [layout_glue()], [layout_glue_colors()], [layout_json_parser()],  or generator functions such as [layout_glue_generator()]
layout_json <- function(fields = c("time", "level", "ns", "ans", "topenv", "fn", "node", "arch", "os_name", "os_release", "os_version", "pid", "user")) {
  force(fields)

  structure(function(level, msg, namespace = NA_character_,
                     .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    fail_on_missing_package("jsonlite")

    meta <- logger_meta_env(
      log_level = level,
      namespace = namespace,
      .logcall = .logcall,
      .topcall = .topcall,
      .topenv = .topenv
    )
    json <- mget(fields, meta)
    sapply(msg, function(msg) jsonlite::toJSON(c(json, list(msg = msg)), auto_unbox = TRUE))
  }, generator = deparse(match.call()))
}


#' Generate log layout function rendering JSON after merging meta
#' fields with parsed list from JSON message
#' @param fields character vector of field names to be included in the
#'   JSON
#' @export
#' @note This functionality depends on the \pkg{jsonlite} package.
#' @seealso This is a [log_layout()] potentially to be used with
#'   [formatter_json()], for alternatives, see [layout_simple()],
#'   [layout_glue()], [layout_glue_colors()], [layout_json()] or
#'   generator functions such as [layout_glue_generator()]
#' @examples \dontrun{
#' log_formatter(formatter_json)
#' log_info(everything = 42)
#' log_layout(layout_json_parser())
#' log_info(everything = 42)
#' log_layout(layout_json_parser(fields = c("time", "node")))
#' log_info(cars = row.names(mtcars), species = unique(iris$Species))
#' }
layout_json_parser <- function(fields = c(
                                 "time", "level", "ns", "ans", "topenv", "fn", "node", "arch",
                                 "os_name", "os_release", "os_version", "pid", "user"
                               )) {
  force(fields)

  structure(function(level, msg, namespace = NA_character_,
                     .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    fail_on_missing_package("jsonlite")

    meta <- logger_meta_env(
      log_level = level,
      namespace = namespace,
      .logcall = .logcall,
      .topcall = .topcall,
      .topenv = .topenv
    )
    meta <- mget(fields, meta)
    msg <- jsonlite::fromJSON(msg)

    jsonlite::toJSON(c(meta, msg), auto_unbox = TRUE, null = "null")
  }, generator = deparse(match.call()))
}


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
  function(level, msg, namespace = NA_character_,
           .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    ret <- paste(attr(level, "level"), msg)
    attr(ret, "severity") <- switch(attr(level, "level", exact = TRUE),
      "FATAL" = "CRITICAL",
      "ERROR" = "ERR",
      "WARN" = "WARNING",
      "SUCCESS" = "NOTICE",
      "INFO" = "INFO",
      "DEBUG" = "DEBUG",
      "TRACE" = "DEBUG"
    )
    return(ret)
  },
  generator = quote(layout_syslognet())
)
# nocov end
