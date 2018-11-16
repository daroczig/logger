#' Generate logging utility
#' @param threshold omit log messages below this \code{log_levels}
#' @param formatter function pre-processing the message of the log record
#' @param layout function rendering the layout of the actual log record
#' @param appender function writing the log record
#' @return function taking \code{level} and \code{msg} arguments
#' @export
logger <- function(threshold, formatter, layout, appender) {

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

        msg <- formatter(msg)
        ## TODO support multiple appenders/handlers (list of functions), like tee?
        ## TODO or support multiple loggers on the same namespace, eg log text to console and JSON to another stream?
        appender(layout(level, msg))

    }
}


#' Get or set log level threshold
#' @param level see \code{log_levels}
#' @param namespace logger namespace
#' @return currently set log level threshold
#' @export
log_threshold <- function(level, namespace = 'global') {

    config <- get(fallback_namespace(namespace), envir = namespaces)

    if (missing(level)) {
        return(config$threshold)
    }

    config$threshold <- level
    assign(namespace, config, envir = namespaces)

}


#' Get or set logger layout
#' @param layout function
#' @param namespace logger namespace
#' @export
#' @examples \dontrun{
#' log_layout(layout_json)
#' log_info(42:44)
#' }
log_layout <- function(layout, namespace = 'global') {

    config <- get(fallback_namespace(namespace), envir = namespaces)

    if (missing(layout)) {
        layout <- config$layout
        if (!is.null(attr(layout, 'generator'))) {
            layout <- parse(text = attr(layout, 'generator'))[[1]]
        }
        return(layout)
    }

    config$layout <- layout
    assign(namespace, config, envir = namespaces)

}


#' Get or set logger appender function
#' @param layout function
#' @param namespace logger namespace
#' @export
#' @examples \dontrun{
#' t <- tempfile()
#' log_appender(appender_tee(t))
#' log_info(42)
#' log_info(42:44)
#' readLines(t)
#' }
log_appender <- function(appender, namespace = 'global') {

    config <- get(fallback_namespace(namespace), envir = namespaces)

    if (missing(appender)) {
        appender <- config$appender
        if (!is.null(attr(appender, 'generator'))) {
            appender <- parse(text = attr(layout, 'generator'))[[1]]
        }
        return(appender)
    }

    config$appender <- appender
    assign(namespace, config, envir = namespaces)

}


#' Find the logger used in the current namespace with a fallback to the global namespace
#' @return function
#' @keywords internal
get_logger <- function() {
    namespace <- find_namespace()
    if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
        namespace <- 'global'
    }
    params <- get(namespace, envir = getFromNamespace('namespaces', 'logger'))
    do.call(logger, params)
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
#'
#' ## multiple lines
#' log_info('ok {1:3} + {1:3} = {2*(1:3)}')
#' log_layout(layout_json)
#'
#' ## note for the JSON output, glue is not automatically applied
#' log_info(glue::glue('ok {1:3} + {1:3} = {2*(1:3)}'))
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
