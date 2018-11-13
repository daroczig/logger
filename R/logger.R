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

        if (level >= threshold) {
            return(invisible(NULL))
        }

        appender(layout(level, msg))

    }
}
