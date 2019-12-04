#' Append log record to stderr
#' @param lines character vector
#' @export
#' @aliases appender_stderr
#' @usage
#' appender_console(lines)
#'
#' appender_stderr(lines)
#' @seealso This is a \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_stdout}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}
appender_console <- structure(function(lines) {
    cat(lines, file = stderr(), sep = '\n')
}, generator = quote(appender_console()))


#' @export
appender_stderr <- appender_console


#' Append log record to stdout
#' @param lines character vector
#' @export
#' @seealso This is a \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}
appender_stdout <- structure(function(lines) {
    cat(lines, sep = '\n')
}, generator = quote(appender_stdout()))


#' Append log messages to a file
#'
#' Log messages are written to a file with basic log rotation: when max number of lines or bytes is defined to be other than \code{Inf}, then the log file is renamed with a \code{.1} suffix and a new log file is created. The renaming happens recursively (eg \code{logfile.1} renamed to \code{logfile.2}) until the specified \code{max_files}, then the oldest file (\code{logfile.{max_files-1}}) is deleted.
#' @param file path
#' @param append boolean passed to \code{cat} defining if the file should be overwritten with the most recent log message instead of appending
#' @param max_lines numeric specifying the maximum number of lines allowed in a file before rotating
#' @param max_bytes numeric specifying the maximum number of bytes allowed in a file before rotating
#' @param max_files integer specifying the maximum number of files to be used in rotation
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}
#' @examples \dontrun{
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
#' t <- tempfile(); dir.create(t)
#' f <- file.path(t, 'log')
#'
#' ## define the file logger with log rotation enabled
#' log_appender(appender_file(f, max_lines = 3, max_files = 5L))
#'
#' ## log 25 messages
#' for (i in 1:25) log_info(i)
#'
#' ## see what was logged
#' lapply(list.files(t, full.names = TRUE), function(t) {
#'   cat('\n##', t, '\n')
#'   cat(readLines(t), sep = '\n')
#' })
#'
#' ## enable internal logging to see what's actually happening in the logrotate steps
#' log_threshold(TRACE, namespace = '.logger')
#' ## run the above commands again
#' }
appender_file <- function(file, append = TRUE, max_lines = Inf, max_bytes = Inf, max_files = 1L) {

    force(append)
    force(max_lines)
    force(max_bytes)
    force(max_files)

    if (!is.integer(max_files) || max_files < 1) {
        stop('max_files must be a positive integer')
    }

    structure(
        function(lines) {
            if (is.finite(max_lines) | is.finite(max_bytes)) {

                fail_on_missing_package('R.utils')

                n_lines <- tryCatch(
                    suppressWarnings(R.utils::countLines(file)),
                    error = function(e) 0)
                n_bytes <- ifelse(file.exists(file), file.info(file)$size, 0)

                if (n_lines >= max_lines || n_bytes >= max_bytes) {
                    log_trace(
                        'lines: %s, max_lines: %s, bytes: %s, max_bytes: %s',
                        n_lines, max_lines, n_bytes, max_bytes,
                        namespace = '.logger')
                    log_trace(
                        'lines >= max_lines || bytes >= max_bytes: %s',
                        n_lines >= max_lines || n_bytes >= max_bytes,
                        namespace = '.logger')
                    for (i in max_files:1) {

                        ## just kill the old file
                        if (i == 1) {
                            log_trace('killing the main file: %s', file, namespace = '.logger')
                            unlink(file)
                        } else {

                            ## rotate the old file
                            new <- paste(file, i - 1, sep = '.')
                            if (i == 2) {
                                old <- file
                            } else {
                                old <- paste(file, i - 2, sep = '.')
                            }

                            if (file.exists(old)) {
                                log_trace('renaming %s to %s', old, new, namespace = '.logger')
                                file.rename(old, new)
                            }

                            ## kill the rotated, but not needed file
                            if (i > max_files) {
                                log_trace('killing the file with too many rotations: %s', new, namespace = '.logger')
                                unlink(new)
                            }

                        }
                    }
                }
            }
            log_trace('logging %s to %s', shQuote(lines), file, namespace = '.logger')
            cat(lines, sep = '\n', file = file, append = append)
        }, generator = deparse(match.call()))
}


#' Append log messages to a file and stdout as well
#' @inheritParams appender_file
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}
appender_tee <- function(file, append = TRUE) {
    force(append)
    structure(
        function(lines) {
            appender_console(lines)
            appender_file(file)(lines)
        }, generator = deparse(match.call()))
}


#' Send log messages to a Slack channel
#' @param channel Slack channel name with a hashtag prefix for public channel and no prefix for private channels
#' @param username Slack (bot) username
#' @param icon_emoji optional override for the bot icon
#' @param api_token Slack API token
#' @param preformatted use code tags around the message?
#' @return function taking \code{lines} argument
#' @export
#' @note This functionality depends on the \pkg{slackr} package.
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_pushbullet}}
appender_slack <- function(channel      = Sys.getenv('SLACK_CHANNEL'),
                           username     = Sys.getenv('SLACK_USERNAME'),
                           icon_emoji   = Sys.getenv('SLACK_ICON_EMOJI'),
                           api_token    = Sys.getenv('SLACK_API_TOKEN'),
                           preformatted = TRUE) {

    fail_on_missing_package('slackr')
    force(channel)
    force(username)
    force(icon_emoji)
    force(api_token)
    force(preformatted)

    structure(
        function(lines) {
            slackr::text_slackr(text = lines, channel = channel, username = username,
                        icon_emoji = icon_emoji, api_token = api_token, preformatted = preformatted)
        }, generator = deparse(match.call()))

}


#' Send log messages to Pushbullet
#' @param ... parameters passed to \code{pbPost}, such as \code{recipients} or \code{apikey}, although it's probably much better to set all these in the \code{~/.rpushbullet.json} as per package docs at \url{http://dirk.eddelbuettel.com/code/rpushbullet.html}
#' @export
#' @note This functionality depends on the \pkg{RPushbullet} package.
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}
#' @export
appender_pushbullet <- function(...) {

    fail_on_missing_package('RPushbullet')

    structure(
        function(lines) {
            RPushbullet::pbPost(type = 'note', body = paste(lines, sep = '\n'), ...)
        }, generator = deparse(match.call()))

}


#' Send log messages to a Telegram chat
#' @param chat_id Unique identifier for the target chat or username of the target channel (in the format @channelusername)
#' @param bot_token Telegram Authorization token
#' @param parse_mode Message parse mode. Allowed values: Markdown or HTML
#' @return function taking \code{lines} argument
#' @export
#' @note This functionality depends on the \pkg{telegram} package.
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_pushbullet}}
appender_telegram <- function(chat_id      = Sys.getenv('TELEGRAM_CHAT_ID'),
                              bot_token    = Sys.getenv('TELEGRAM_BOT_TOKEN'),
                              parse_mode   = NULL) {

    fail_on_missing_package('telegram')
    force(chat_id)
    force(bot_token)
    force(parse_mode)

    tb <- telegram::TGBot$new(token = bot_token)
    structure(
        function(lines) {
            tb$sendMessage(text = lines, parse_mode = parse_mode, chat_id = chat_id)
        }, generator = deparse(match.call()))

}

#' Send log messages to the POSIX system log
#' @param identifier A string identifying the process.
#' @param ... Further arguments passed on to \code{\link[rsyslog]{open_syslog}}.
#' @return function taking \code{lines} argument
#' @export
#' @note This functionality depends on the \pkg{rsyslog} package.
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_pushbullet}}
#' @examples
#' if (requireNamespace("rsyslog", quietly = TRUE)) {
#'   log_appender(appender_syslog("test"))
#'   log_info("Test message.")
#' }
appender_syslog <- function(identifier, ...) {
    fail_on_missing_package('rsyslog')
    rsyslog::open_syslog(identifier = identifier, ...)
    structure(
        function(lines) {
            for (line in lines)
                rsyslog::syslog(line)
        },
        generator = deparse(match.call())
    )
}

## TODO other appenders: graylog, kinesis, datadog, cloudwatch, email via sendmailR, ES etc
