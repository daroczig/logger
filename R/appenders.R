#' Append log record to stdout
#' @param lines character vector
#' @export
#' @seealso This is a \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}
appender_console <- structure(function(lines) {
    cat(lines, sep = '\n')
}, generator = quote(appender_console()))


#' Append log messages to a file
#' @param file path
#' @param append boolean passed to \code{cat} defining if the file should be overwritten with the most recent log message instead of appending
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}
appender_file <- function(file, append = TRUE) {
    force(append)
    structure(
        function(lines) {
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


#' Delays executing the actual appender function to the future in a background process to avoid blocking the main R session
#' @param appender a  \code{\link{log_appender}} function with a \code{generator} attribute (TODO note not required, all fn will be passed if not)
#' @param batch number of records to process from the queue at once
#' @param namespace \code{logger} namespace to use for logging messages on starting up the background process
#' @return function taking \code{lines} argument
#' @export
#' @note This functionality depends on the \pkg{txtq} and \pkg{callr} packages.
#' @examples \dontrun{
#' appender_file_slow <- function(file) {
#'   function(lines) {
#'     Sys.sleep(1)
#'     cat(lines, sep = '\n', file = file, append = TRUE)
#'   }
#' }
#'
#' ## log what's happening in the background
#' log_threshold(TRACE, namespace = 'async_logger')
#' log_appender(appender_console, namespace = 'async_logger')
#'
#' ## start async appender
#' t <- tempfile()
#' log_info('Logging in the background to {t}')
#' my_appender <- appender_async(appender_file_slow(file = t))
#'
#' ## use async appander
#' log_appender(my_appender)
#' log_info('Was this slow?')
#' for (i in 1:25) log_info(i)
#'
#' ## check on the async appender
#' attr(my_appender, 'async_writer_queue')$count()
#' attr(my_appender, 'async_writer_process')$get_pid()
#' }
appender_async <- function(appender, batch = 1, namespace = 'async_logger') {

    fail_on_missing_package('txtq')
    fail_on_missing_package('callr')

    force(appender)
    force(batch)

    ## create a storage for the message queue
    async_writer_storage <- tempfile()
    log_trace(paste('Async writer storage:', async_writer_storage), namespace = 'async_logger')

    ## initialize the message queue
    async_writer_queue <- txtq::txtq(async_writer_storage)

    ## start a background process for the async execution of the message queue
    ## TODO make it easy to create multiple/parallel background processes?
    async_writer_process <- callr::r_session$new()
    log_trace(paste('Async writer PID:', async_writer_process$get_pid()), namespace = 'async_logger')

    ## load minimum required packages
    async_writer_process$run(function() require('logger'))
    async_writer_process$run(function() require('txtq'))

    ## connect to the message queue
    async_writer_process$run(assign, args = list(x = 'async_writer_storage', value = async_writer_storage))
    async_writer_process$run(function() async_writer_queue <<- txtq::txtq(async_writer_storage))

    ## pass arguments and appender
    async_writer_process$run(assign, args = list(x = 'batch', value = batch))
    async_writer_process$run(assign, args = list(x = 'appender', value = appender))

    ## start infinite loop processing log records
    log_info('start')
    async_writer_process$call(function() {
        while (TRUE) {
            items <- async_writer_queue$pop(batch)
            if (nrow(items) == 0) {
                ## avoid burning CPU
                Sys.sleep(.1)
            } else {
                ## execute the actual appender for each log item
                for (i in seq_len(nrow(items))) {
                    appender(items$message[i])
                }
                ## remove processed log records
                async_writer_queue$clean()
            }
        }
    })
    log_info('end')

    structure(
        function(lines) {
            ## TODO check if background process still works?
            ## if (async_writer_process$get_state() != 'busy') {
            ##     stop('Ouch, the background log appender process has stopped working?')
            ## }
            ## write to message queue
            for (line in lines) {
                async_writer_queue$push(title = as.character(as.numeric(Sys.time())), message = line)
            }
        },
        generator = deparse(match.call()),
        async_writer_storage = async_writer_storage,
        async_writer_queue = async_writer_queue,
        async_writer_process = async_writer_process)

}
