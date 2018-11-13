#' Logging utility
#' @param threshold omit log messages below this \code{log_levels}
#' @param layout function rendering the log message
#' @param appender function writing the log message
#' @return function taking \code{level} and \code{msg} arguments
#' @export
logger <- function(threshold, layout, appender) {

    force(threshold)
    force(layout)
    force(appender)

    function(level, msg) {

        if (!inherits(threshold, 'loglevel')) {
            stop('Invalid log level provided as threshold, see ?log_levels')
        }

        if (level > threshold) {
            return(invisible(NULL))
        }

        appender(layout(level, msg))

    }
}


#' Find the logger used in the current namespace
#' @return function
#' @keywords internal
get_logger <- function() {
    ## TODO actually find instead of static
    namespaces$global
}


#' Log a message with given log level
#' @param level log level from \code{log_levels}
#' @param msg character vector
#' @export
log <- function(level, msg) {
    get_logger()(level, msg)
}
