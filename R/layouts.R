#' Collect useful information about the logging environment to be used in log messages
#' @param log_level log level as per \code{\link{log_levels}}
#' @return list
#' @keywords internal
#' @seealso layout_glue_generator
get_logger_meta_variables <- function(log_level) {

    list(

        namespace = find_namespace(),
        fn        = find_fn(),
        call      = find_call(),

        time      = Sys.time(),
        level     = attr(log_level, 'level'),

        pid       = Sys.getpid(),
        ## TODO run Sys.info only once
        user      = Sys.info()[["user"]],
        node      = Sys.info()[["nodename"]]

        ## TODO OS version
        ## TODO jenkins env vars if available
        ## TODO any env var
        ## TODO seed

    )

}


#' Generate logging function
#'
#' Available variables to be used in the \code{msg_format} provided by \code{logger:::get_logger_meta_variables}:
#' \itemize{
#'   \item msg: the actual log message
#'   \item level: log level, eg INFO
#'   \item time: current time formatted as \code{time_format}
#'   \item namespace: R package (if any) calling the logging function
#'   \item call: parent call (if any) calling the logging function
#'   \item fn: function's (if any) name calling the logging function
#'   \item user: name of the real user id as reported by \code{Sys.info}
#'   \item pid: the process identification number of the R session
#'   \item node: name by which the machine is known on the network as reported by \code{Sys.info}
#' }
#' @param format \code{glue}-flavored layout of the message using the above variables
#' @return function taking \code{level} and \code{msg} arguments - keeping the original call creating the generator in the \code{generator} attribute that is returned when calling \code{log_layout()} for the currently used layout
#' @importFrom glue glue
#' @export
#' @examples \dontrun{
#' logger <- layout_glue_generator(format = '{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}')
#' logger(FATAL, 'try {runif(1)}')
#'
#' log_layout(logger)
#' log_info('try {runif(1)}')
#' }
layout_glue_generator <- function(format = '{level} [{format(time, "%Y-%d-%m %H:%M:%S")}] {msg}') {

    force(format)

    structure(function(level, msg) {

        if (!inherits(level, 'loglevel')) {
            stop('Invalid log level, see ?log_levels')
        }

        with(get_logger_meta_variables(level), glue(format))

    }, generator = deparse(match.call())
    ## TODO add get_logger_meta_variables as attributes if the appender might want to use it, eg syslog?
    )

}


#' Format a log record by concatenating the log level, timestamp and message
#' @param level log level, see \code{\link{log_levels}} for more details
#' @param msg string message
#' @return character vector
#' @export
layout_raw <- function(level, msg) {
    paste0(attr(level, 'level'), ' [', format(Sys.time(), "%Y-%d-%m %H:%M:%S"), '] ', msg)
}


#' Format a log message with \code{glue}
#' @inheritParams layout_raw
#' @return character vector
#' @importFrom glue glue
#' @export
layout_glue <- layout_glue_generator()


#' Format a log message as JSON
#' @inheritParams layout_raw
#' @return character vector
#' @export
#' @examples \dontrun{
#' log_layout(layout_json)
#' log_info(42:44)
#' }
layout_json <- function(level, msg) {

    if (!requireNamespace('jsonlite', quietly = TRUE)) {
        stop('Please install the jsonlite package for logging messages in JSON format')
    }

    sapply(msg, function(msg)
        jsonlite::toJSON(list(
            level = attr(level, 'level'),
            timestamp = Sys.time(),
            message = as.character(msg)
        ), auto_unbox = TRUE))

}
