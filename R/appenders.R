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
#' @param file path
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}
appender_file <- function(file) {
    structure(
        function(lines) {
            cat(lines, sep = '\n', file = file, append = TRUE)
        }, generator = deparse(match.call()))
}


#' Append log messages to a file and stdout as well
#' @param file path
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}
appender_tee <- function(file) {
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
