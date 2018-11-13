#' Generate logging function
#'
#' Available variables to be used in the \code{msg_format}:
#' \itemize{
#'   \item level: log level, eg INFO
#'   \item time: current time formatted as \code{time_format}
#'   \item namespace: R package calling the logging function
#'   \item TODO function and call
#'   \item user: name of the real user id as reported by \code{Sys.info}
#'   \item pid: the process identification number of the R session
#'   \item node: name by which the machine is known on the network as reported by \code{Sys.info}
#' }
#' @param level log level, eg \code{INFO}
#' @param msg character vector
#' @param msg_format \code{glue}-flavored layout of the message
#' @param time_format see \code{strptime} for details
#' @return function taking \code{level} and \code{msg} arguments
#' @importFrom glue glue
#' @export
#' @examples \dontrun{
#' logger <- layout_generator(msg_format = '{node}/{pid} {time} {level}: {msg}')
#' logger(FATAL, 'asdsa {runif(1)}')
#' }
layout_generator <- function(msg_format = '{level} [{time}] {msg}',
                             time_format = '%Y-%d-%m %H:%M:%S') {

    force(msg_format)
    force(time_format)

    function(level, msg) {

        if (!inherits(level, 'loglevel')) {
            stop('Invalid log level, see ?log_levels')
        }

        namespace <- find_namespace()

        time  <- as.character(Sys.time(), time_format)
        level <- attr(level, 'level')
        pid   <- Sys.getpid()
        user  <- Sys.info()[["user"]]
        node  <- Sys.info()[["nodename"]]
        msg   <- glue(msg)

        glue(msg_format)

    }

}


#' Format a log message with \code{glue}
#' @inheritParams layout_generator
#' @return character vector
#' @importFrom glue glue
#' @export
layout_glue <- layout_generator(
    msg_format = '{level} [{time}] {msg}',
    time_format = '%Y-%d-%m %H:%M:%S')


#' Format a log message as JSON
#' @inheritParams layout_generator
#' @return character vector
#' @export
#' @note TODO refactor get vars into helper function and transform this function to a generator with all the available variables?
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
