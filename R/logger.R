#' Generate logging utility
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


#' Get or set log level threshold
#' @param level see \code{log_levels}
#' @param namespace logger namespace
#' @return currently set log level threshold
#' @export
log_threshold <- function(level, namespace = 'global') {

    if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
        namespace <- 'global'
    }

    config <- get(namespace, envir = namespaces)

    if (missing(level)) {
        return(config$threshold)
    }

    config$threshold <- level
    assign(namespace, config, envir = namespaces)

    ## DRY with below 3?

}

log_layout <- function(layout, namespace = 'global') {

}

log_appender <- function(appender, namespace = 'global') {

}


#' Find the logger used in the current namespace
#' @return function
#' @keywords internal
get_logger <- function() {
    ## TODO actually find instead of static
    do.call(logger, namespaces$global)
}


#' Log a message with given log level
#' @param level log level from \code{log_levels}
#' @param msg character vector
#' @export
#' @aliases log log_fatal log_error log_warn log_info log_debug log_trace
#' @examples \dontrun{
#' log(INFO, 'hi there')
#' log_info('hi there')
#'
#' ## output omitted
#' log_debug('hi there')
#'
#' ## lower threshold and retry
#' log_threshold(TRACE)
#' log_debug('hi there')
#' }
log <- function(level, msg) {
    get_logger()(level, msg)
}


#' @export
log_fatal <- function(msg) log(FATAL, msg)
#' @export
log_error <- function(msg) log(ERROR, msg)
#' @export
log_info <- function(msg) log(INFO, msg)
#' @export
log_debug <- function(msg) log(DEBUG, msg)
#' @export
log_trace <- function(msg) log(TRACE, msg)
