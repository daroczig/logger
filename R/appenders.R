#' Append log record to stderr
#' @param lines character vector
#' @export
#' @aliases appender_stderr
#' @usage
#' appender_console(lines)
#'
#' appender_stderr(lines)
#' @seealso This is a \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_stdout}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}, \code{\link{appender_telegram}}, \code{\link{appender_syslog}}, \code{\link{appender_kinesis}} and \code{\link{appender_async}} for evaluate any \code{\link{log_appender}} function in a background process.
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
#' @param append boolean passed to \code{cat} defining if the file should be overwritten with the most recent log message instead of appending
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}, \code{\link{appender_telegram}}, \code{\link{appender_syslog}}, \code{\link{appender_kinesis}} and \code{\link{appender_async}} for evaluate any \code{\link{log_appender}} function in a background process.
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
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_slack}}, \code{\link{appender_pushbullet}}, \code{\link{appender_telegram}}, \code{\link{appender_syslog}}, \code{\link{appender_kinesis}} and \code{\link{appender_async}} for evaluate any \code{\link{log_appender}} function in a background process.
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
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_pushbullet}}, \code{\link{appender_telegram}}, \code{\link{appender_syslog}}, \code{\link{appender_kinesis}} and \code{\link{appender_async}} for evaluate any \code{\link{log_appender}} function in a background process.
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
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_slack}}, \code{\link{appender_telegram}}, \code{\link{appender_syslog}}, \code{\link{appender_kinesis}} and \code{\link{appender_async}} for evaluate any \code{\link{log_appender}} function in a background process.
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
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_pushbullet}}, \code{\link{appender_syslog}}, \code{\link{appender_kinesis}} and \code{\link{appender_async}} for evaluate any \code{\link{log_appender}} function in a background process.
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
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_pushbullet}}, \code{\link{appender_telegram}}, \code{\link{appender_kinesis}} and \code{\link{appender_async}} for evaluate any \code{\link{log_appender}} function in a background process.
#' @examples \dontrun{
#' if (requireNamespace("rsyslog", quietly = TRUE)) {
#'   log_appender(appender_syslog("test"))
#'   log_info("Test message.")
#' }
#' }
appender_syslog <- function(identifier, ...) {
    fail_on_missing_package('rsyslog')
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


#' Send log messages to a Amazon Kinesis stream
#' @param stream name of the Kinesis stream
#' @return function taking \code{lines} and optional \code{partition_key} argument
#' @export
#' @note This functionality depends on the \pkg{botor} package.
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_pushbullet}}, \code{\link{appender_telegram}}, \code{\link{appender_syslog}} and \code{\link{appender_async}} for evaluate any \code{\link{log_appender}} function in a background process.
appender_kinesis <- function(stream) {
    fail_on_missing_package('botor')
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


#' Delays executing the actual appender function to the future in a background process to avoid blocking the main R session
#' @param appender a  \code{\link{log_appender}} function with a \code{generator} attribute (TODO note not required, all fn will be passed if not)
#' @param batch number of records to process from the queue at once
#' @param namespace \code{logger} namespace to use for logging messages on starting up the background process
#' @param init optional function to run in the background process that is useful to set up the environment required for logging, eg if the \code{appender} function requires some extra packages to be loaded or some environment variables to be set etc
#' @return function taking \code{lines} argument
#' @export
#' @note This functionality depends on the \pkg{txtq} and \pkg{callr} packages. The R session's temp folder is used for staging files (message queue and other forms of communication between the parent and child processes).
#' @seealso This function is to be used with an actual \code{\link{log_appender}}, for example \code{\link{appender_console}}, \code{\link{appender_file}}, \code{\link{appender_tee}}, \code{\link{appender_pushbullet}}, \code{\link{appender_telegram}}, \code{\link{appender_syslog}} or \code{\link{appender_kinesis}}.
#' @examples \dontrun{
#' appender_file_slow <- function(file) {
#'   force(file)
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
#' system.time(for (i in 1:25) log_info(i))
#'
#' readLines(t)
#' Sys.sleep(10)
#' readLines(t)
#'
#' ## check on the async appender (debugging, you will probably never need this)
#' attr(my_appender, 'async_writer_queue')$count()
#' attr(my_appender, 'async_writer_queue')$log()
#'
#' attr(my_appender, 'async_writer_process')$get_pid()
#' attr(my_appender, 'async_writer_process')$get_state()
#' attr(my_appender, 'async_writer_process')$poll_process(1)
#' attr(my_appender, 'async_writer_process')$read()
#'
#' attr(my_appender, 'async_writer_process')$is_alive()
#' attr(my_appender, 'async_writer_process')$read_error()
#' }
appender_async <- function(appender, batch = 1, namespace = 'async_logger',
                           init = function() log_info('Background process started')) {

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
    async_writer_process$run(init)

    ## connect to the message queue
    async_writer_process$run(assign, args = list(x = 'async_writer_storage', value = async_writer_storage))
    async_writer_process$run(function() async_writer_queue <<- txtq::txtq(async_writer_storage))

    ## pass arguments
    async_writer_process$run(assign, args = list(x = 'batch', value = batch))

    ## pass appender
    async_writer_tempfile <- tempfile()
    saveRDS(appender, async_writer_tempfile)
    log_trace(paste('Async appender cached at:', async_writer_tempfile), namespace = 'async_logger')
    async_writer_process$run(assign, args = list(x = 'async_writer_tempfile', value = async_writer_tempfile))
    async_writer_process$run(assign, args = list(x = 'appender', value = readRDS(async_writer_tempfile)))

    ## start infinite loop processing log records
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

    structure(

        function(lines) {

            ## check if background process still works
            if (!isTRUE(async_writer_process$is_alive())) {
                stop('FATAL: Async writer process not found')
            }
            remote_error <- async_writer_process$read_error()
            if (remote_error != '') {
                stop(paste('FATAL: Async writer failed with', shQuote(remote_error)))
            }

            ## write to message queue
            for (line in lines) {
                async_writer_queue$push(title = as.character(as.numeric(Sys.time())), message = line)
            }

        },

        generator = deparse(match.call()),
        ## share remote process and queue with parent for debugging purposes
        async_writer_storage = async_writer_storage,
        async_writer_queue = async_writer_queue,
        async_writer_process = async_writer_process)

    ## NOTE no need to clean up, all will go away with the current R session's temp folder

}

## TODO other appenders: graylog, datadog, cloudwatch, email via sendmailR, ES etc
