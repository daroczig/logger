#' Dummy appender not delivering the log record to anywhere
#' @param lines character vector
#' @export
appender_void <- function(lines) {}
attr(appender_void, "generator") <- quote(appender_void())

#' Append log record to stderr
#' @param lines character vector
#' @export
#' @family log_appenders
appender_console <- function(lines) {
  cat(lines, file = stderr(), sep = "\n")
}
attr(appender_console, "generator") <- quote(appender_console())


#' @export
#' @rdname appender_console
appender_stderr <- appender_console
attr(appender_stderr, "generator") <- quote(appender_stderr())


#' Append log record to stdout
#' @param lines character vector
#' @export
#' @family log_appenders
appender_stdout <- function(lines) {
  cat(lines, sep = "\n")
}
attr(appender_stdout, "generator") <- quote(appender_stdout())

#' Append log messages to a file
#'
#' Log messages are written to a file with basic log rotation: when
#' max number of lines or bytes is defined to be other than `Inf`,
#' then the log file is renamed with a `.1` suffix and a new log file
#' is created. The renaming happens recursively (eg `logfile.1`
#' renamed to `logfile.2`) until the specified `max_files`, then the
#' oldest file (\code{logfile.{max_files-1}}) is deleted.
#' @param file path
#' @param append boolean passed to `cat` defining if the file should
#'     be overwritten with the most recent log message instead of
#'     appending
#' @param max_lines numeric specifying the maximum number of lines
#'     allowed in a file before rotating
#' @param max_bytes numeric specifying the maximum number of bytes
#'     allowed in a file before rotating
#' @param max_files integer specifying the maximum number of files to
#'     be used in rotation
#' @export
#' @return function taking `lines` argument
#' @family log_appenders
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' ## ##########################################################################
#' ## simple example logging to a file
#' t <- tempfile()
#' log_appender(appender_file(t))
#' for (i in 1:25) log_info(i)
#' readLines(t)
#'
#' ## ##########################################################################
#' ## more complex example of logging to file
#' ## rotated after every 3rd line up to max 5 files
#'
#' ## create a folder storing the log files
#' t <- tempfile()
#' dir.create(t)
#' f <- file.path(t, "log")
#'
#' ## define the file logger with log rotation enabled
#' log_appender(appender_file(f, max_lines = 3, max_files = 5L))
#'
#' ## enable internal logging to see what's actually happening in the logrotate steps
#' log_threshold(TRACE, namespace = ".logger")
#' ## log 25 messages
#' for (i in 1:25) log_info(i)
#'
#' ## see what was logged
#' lapply(list.files(t, full.names = TRUE), function(t) {
#'   cat("\n##", t, "\n")
#'   cat(readLines(t), sep = "\n")
#' })
#'
#' \dontshow{logger:::namespaces_set(old)}
appender_file <- function(file, append = TRUE, max_lines = Inf, max_bytes = Inf, max_files = 1L) { # nolint
  force(file)
  force(append)
  force(max_lines)
  force(max_bytes)
  force(max_files)

  if (!is.integer(max_files) || max_files < 1) {
    stop("max_files must be a positive integer")
  }

  structure(
    function(lines) {
      if (is.finite(max_lines) | is.finite(max_bytes)) {
        fail_on_missing_package("R.utils")

        n_lines <- tryCatch(
          suppressWarnings(R.utils::countLines(file)),
          error = function(e) 0
        )
        n_bytes <- ifelse(file.exists(file), file.info(file)$size, 0)

        if (n_lines >= max_lines || n_bytes >= max_bytes) {
          log_trace(
            "lines: %s, max_lines: %s, bytes: %s, max_bytes: %s",
            n_lines, max_lines, n_bytes, max_bytes,
            namespace = ".logger"
          )
          log_trace(
            "lines >= max_lines || bytes >= max_bytes: %s",
            n_lines >= max_lines || n_bytes >= max_bytes,
            namespace = ".logger"
          )
          for (i in max_files:1) {
            ## just kill the old file
            if (i == 1) {
              log_trace("killing the main file: %s", file, namespace = ".logger")
              unlink(file)
            } else {
              ## rotate the old file
              new <- paste(file, i - 1, sep = ".")
              if (i == 2) {
                old <- file
              } else {
                old <- paste(file, i - 2, sep = ".")
              }

              if (file.exists(old)) {
                log_trace("renaming %s to %s", old, new, namespace = ".logger")
                file.rename(old, new)
              }

              ## kill the rotated, but not needed file
              if (i > max_files) {
                log_trace("killing the file with too many rotations: %s", new, namespace = ".logger")
                unlink(new)
              }
            }
          }
        }
      }
      log_trace("logging %s to %s", shQuote(lines), file, namespace = ".logger")
      cat(lines, sep = "\n", file = file, append = append)
    },
    generator = deparse(match.call())
  )
}


#' Append log messages to a file and stdout as well
#'
#' This appends log messages to both console and a file. The same
#' rotation options are available as in [appender_file()].
#' @inheritParams appender_file
#' @export
#' @return function taking `lines` argument
#' @family log_appenders
appender_tee <- function(file, append = TRUE, max_lines = Inf, max_bytes = Inf, max_files = 1L) {
  force(file)
  force(append)
  force(max_lines)
  force(max_bytes)
  force(max_files)
  structure(
    function(lines) {
      if (needs_stdout()) appender_stdout(lines) else appender_console(lines)
      appender_file(file, append, max_lines, max_bytes, max_files)(lines)
    },
    generator = deparse(match.call())
  )
}


#' Send log messages to a Slack channel
#' @param channel Slack channel name with a hashtag prefix for public
#'     channel and no prefix for private channels
#' @param username Slack (bot) username
#' @param icon_emoji optional override for the bot icon
#' @param api_token Slack API token
#' @param preformatted use code tags around the message?
#' @return function taking `lines` argument
#' @export
#' @note This functionality depends on the \pkg{slackr} package.
#' @family log_appenders
appender_slack <- function(channel = Sys.getenv("SLACK_CHANNEL"),
                           username = Sys.getenv("SLACK_USERNAME"),
                           icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
                           api_token = Sys.getenv("SLACK_API_TOKEN"),
                           preformatted = TRUE) {
  fail_on_missing_package("slackr", "1.4.1")
  force(channel)
  force(username)
  force(icon_emoji)
  force(api_token)
  force(preformatted)

  structure(
    function(lines) {
      slackr::slackr_msg(
        text = lines, channel = channel, username = username,
        icon_emoji = icon_emoji, token = api_token, preformatted = preformatted
      )
    },
    generator = deparse(match.call())
  )
}


#' Send log messages to Pushbullet
#' @param ... parameters passed to [RPushbullet::pbPost], such as `recipients`
#'     or `apikey`, although it's probably much better to set all these
#'     in the `~/.rpushbullet.json` as per package docs at
#'     <http://dirk.eddelbuettel.com/code/rpushbullet.html>
#' @export
#' @note This functionality depends on the \pkg{RPushbullet} package.
#' @family log_appenders
#' @export
appender_pushbullet <- function(...) {
  fail_on_missing_package("RPushbullet")

  structure(
    function(lines) {
      RPushbullet::pbPost(type = "note", body = paste(lines, sep = "\n"), ...)
    },
    generator = deparse(match.call())
  )
}


#' Send log messages to a Telegram chat
#' @param chat_id Unique identifier for the target chat or username of
#'     the target channel (in the format @channelusername)
#' @param bot_token Telegram Authorization token
#' @param parse_mode Message parse mode. Allowed values: Markdown or
#'     HTML
#' @return function taking `lines` argument
#' @export
#' @note This functionality depends on the \pkg{telegram} package.
#' @family log_appenders
appender_telegram <- function(chat_id = Sys.getenv("TELEGRAM_CHAT_ID"),
                              bot_token = Sys.getenv("TELEGRAM_BOT_TOKEN"),
                              parse_mode = NULL) {
  fail_on_missing_package("telegram")
  force(chat_id)
  force(bot_token)
  force(parse_mode)

  tb <- telegram::TGBot$new(token = bot_token)
  structure(
    function(lines) {
      tb$sendMessage(text = lines, parse_mode = parse_mode, chat_id = chat_id)
    },
    generator = deparse(match.call())
  )
}


#' Send log messages to the POSIX system log
#' @param identifier A string identifying the process.
#' @param ... Further arguments passed on to [rsyslog::open_syslog()].
#' @return function taking `lines` argument
#' @export
#' @note This functionality depends on the \pkg{rsyslog} package.
#' @family log_appenders
#' @examples \dontrun{
#' if (requireNamespace("rsyslog", quietly = TRUE)) {
#'   log_appender(appender_syslog("test"))
#'   log_info("Test message.")
#' }
#' }
appender_syslog <- function(identifier, ...) {
  fail_on_missing_package("rsyslog")
  rsyslog::open_syslog(identifier = identifier, ...)
  structure(
    function(lines) {
      for (line in lines) {
        rsyslog::syslog(line)
      }
    },
    generator = deparse(match.call())
  )
}


# nocov start
#' Send log messages to a network syslog server
#' @param identifier program/function identification (string).
#' @param server machine where syslog daemon runs (string).
#' @param port port where syslog daemon listens (integer).
#'
#' @return A function taking a `lines` argument.
#' @export
#' @note This functionality depends on the \pkg{syslognet} package.
#' @examples \dontrun{
#' if (requireNamespace("syslognet", quietly = TRUE)) {
#'   log_appender(appender_syslognet("test_app", "remoteserver"))
#'   log_info("Test message.")
#' }
#' }
appender_syslognet <- function(identifier, server, port = 601L) {
  fail_on_missing_package("syslognet")
  force(identifier)
  force(server)
  force(port)
  structure(
    function(lines) {
      sev <- attr(lines, "severity", exact = TRUE)
      for (line in lines) {
        syslognet::syslog(line, sev, app_name = identifier, server = server, port = port)
      }
    },
    generator = deparse(match.call())
  )
}
# nocov end


#' Send log messages to a Amazon Kinesis stream
#' @param stream name of the Kinesis stream
#' @return function taking `lines` and optional `partition_key`
#'     argument
#' @export
#' @note This functionality depends on the \pkg{botor} package.
#' @family log_appenders
appender_kinesis <- function(stream) {
  fail_on_missing_package("botor")
  force(stream)
  structure(
    function(lines, partition_key = NA_character_) {
      for (line in lines) {
        botor::kinesis()$put_record(StreamName = stream, Data = line, PartitionKey = partition_key)
      }
    },
    generator = deparse(match.call())
  )
}


#' Delays executing the actual appender function to the future in a
#' background process to avoid blocking the main R session
#' @param appender a [log_appender()] function with a `generator`
#'     attribute (TODO note not required, all fn will be passed if
#'     not)
#' @param namespace `logger` namespace to use for logging messages on
#'     starting up the background process
#' @param init optional function to run in the background process that
#'     is useful to set up the environment required for logging, eg if
#'     the `appender` function requires some extra packages to be
#'     loaded or some environment variables to be set etc
#' @return function taking `lines` argument
#' @export
#' @note This functionality depends on the \pkg{mirai} package.
#' @family log_appenders
#' @examples \dontrun{
#' appender_file_slow <- function(file) {
#'   force(file)
#'   function(lines) {
#'     Sys.sleep(1)
#'     cat(lines, sep = "\n", file = file, append = TRUE)
#'   }
#' }
#'
#' ## log what's happening in the background
#' log_threshold(TRACE, namespace = "async_logger")
#' log_appender(appender_console, namespace = "async_logger")
#'
#' ## start async appender
#' t <- tempfile()
#' log_info("Logging in the background to {t}")
#'
#' ## use async appender
#' log_appender(appender_async(appender_file_slow(file = t)))
#' log_info("Was this slow?")
#' system.time(for (i in 1:25) log_info(i))
#'
#' readLines(t)
#' Sys.sleep(10)
#' readLines(t)
#'
#' }
appender_async <- function(appender,
                           namespace = "async_logger",
                           init = function() log_info("Background process started")) {
  fail_on_missing_package("mirai")
  force(appender)

  # Start one non-dispatcher background process if not already started
  if (is.null(mirai::nextget("n", .compute = namespace))) {
    mirai::daemons(1L, dispatcher = FALSE, cleanup = FALSE, .compute = namespace)
  }
  mirai::everywhere(
    {
      library(logger)
      init()
    },
    appender = appender, # remains in .GlobalEnv on daemon
    .args = list(init = init),
    .compute = namespace
  )

  structure(
    function(lines) {
      mirai::mirai(
        for (line in lines) {
          appender(line)
        },
        .args = list(lines = lines),
        .compute = namespace
      )
    },
    generator = deparse(match.call())
  )
}

## TODO other appenders: graylog, datadog, cloudwatch, email via sendmailR, ES etc
