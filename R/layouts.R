#' Collect useful information about the logging environment to be used in log messages
#' @param log_level log level as per \code{\link{log_levels}}
#' @param time_format see \code{strptime} for details
#' @return list
#' @keywords internal
#' @seealso layout_generator
get_logger_meta_variables <- function(log_level, time_format = '%Y-%d-%m %H:%M:%S') {
    list(
        namespace = find_namespace(),
        fn        = find_fn(),
        call      = find_call(),
        time      = as.character(Sys.time(), time_format),
        loglevel  = attr(log_level, 'level'),
        pid       = Sys.getpid(),
        user      = Sys.info()[["user"]],
        node      = Sys.info()[["nodename"]])
}


#' Generate logging function
#'
#' Available variables to be used in the \code{msg_format} provided by \code{logger:::get_logger_meta_variables}:
#' \itemize{
#'   \item level: log level, eg INFO
#'   \item time: current time formatted as \code{time_format}
#'   \item namespace: R package (if any) calling the logging function
#'   \item call: parent call (if any) calling the logging function
#'   \item fn: function's (if any) name calling the logging function
#'   \item user: name of the real user id as reported by \code{Sys.info}
#'   \item pid: the process identification number of the R session
#'   \item node: name by which the machine is known on the network as reported by \code{Sys.info}
#' }
#' @param level log level, eg \code{INFO}
#' @param msg character vector
#' @param msg_format \code{glue}-flavored layout of the message
#' @param time_format see \code{strptime} for details
#' @return function taking \code{level} and \code{msg} arguments - keeping the original call creating the generator in the \code{generator} attribute that is returned when calling \code{log_layout()} for the currently used layout
#' @importFrom glue glue
#' @export
#' @examples \dontrun{
#' logger <- layout_generator(formatter_args = '{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}')
#' logger(FATAL, 'try {runif(1)}')
#'
#' log_layout(logger)
#' log_info('try {runif(1)}')
#'
#' logger <- layout_generator(
#'   formatter_fn = sprintf,
#'   formatter_args = list('%s [%s] %s', level, time, msg))
#' }
layout_generator <- function(msg_format = '{loglevel} [{time}] {msg}',
                             time_format = '%Y-%d-%m %H:%M:%S') {

    force(msg_format)
    force(time_format)

    call <- deparse(match.call())

    structure(function(level, msg) {
        ## TODO msg -> ... + paste0 first

        if (!inherits(level, 'loglevel')) {
            stop('Invalid log level, see ?log_levels')
        }

        msg <- sapply(msg, glue)

        with(get_logger_meta_variables(level, time_format), glue(msg_format))

    }, generator = call)

}


#' Format a log message with \code{glue}
#' @inheritParams layout_generator
#' @return character vector
#' @importFrom glue glue
#' @export
layout_glue <- layout_generator(
    msg_format  = '{loglevel} [{time}] {msg}',
    time_format = '%Y-%d-%m %H:%M:%S')


#' Format a log message as JSON
#' @inheritParams layout_generator
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
            level = level,
            timestamp = Sys.time(),
            message = as.character(msg)
        ), auto_unbox = TRUE))

}
