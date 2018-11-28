#' Append log record to stdout
#' @param lines character vector
#' @export
#' @seealso This is a \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_file}} or \code{\link{appender_tee}}
appender_console <- structure(function(lines) {
    cat(lines, sep = '\n')
}, generator = quote(appender_console()))


#' Append log messages to a file
#' @param file path
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}} or \code{\link{appender_tee}}
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
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}} or \code{\link{appender_file}}
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

## TODO other appenders: graylog, kinesis, datadog, cloudwatch etc
