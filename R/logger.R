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

## TODO DRY the below 4 functions

#' Get or set log level threshold
#' @param level see \code{log_levels}
#' @param namespace logger namespace
#' @param index index of the logger within the namespace
#' @return currently set log level threshold
#' @export
#' @examples \dontrun{
#' ## check the currently set log level threshold
#' log_threshold()
#'
#' ## change the log level threshold to WARN
#' log_threshold(WARN)
#' log_info(1)
#' log_warn(2)
#'
#' ## add another logger with a lower log level threshold and check the number of logged messages
#' log_threshold(INFO, index = 2)
#' log_info(1)
#' log_warn(2)
#' }
log_threshold <- function(level, namespace = 'global', index = 1) {

    configs <- get(fallback_namespace(namespace), envir = namespaces)
    config  <- configs[[min(index, length(configs))]]

    if (missing(level)) {
        return(config$threshold)
    }

    config$threshold <- level
    configs[[min(index, length(config) + 1)]] <- config
    assign(namespace, configs, envir = namespaces)

}


#' Get or set logger layout
#' @param layout function defining the structure of a log message / object
#' @inheritParams log_threshold
#' @export
#' @examples \dontrun{
#' log_layout(layout_json)
#' log_info(42:44)
#' }
log_layout <- function(layout, namespace = 'global', index = 1) {

    configs <- get(fallback_namespace(namespace), envir = namespaces)
    config  <- configs[[min(index, length(configs))]]

    if (missing(layout)) {
        layout <- config$layout
        if (!is.null(attr(layout, 'generator'))) {
            layout <- parse(text = attr(layout, 'generator'))[[1]]
        }
        return(layout)
    }

    config$layout <- layout
    configs[[min(index, length(config) + 1)]] <- config
    assign(namespace, configs, envir = namespaces)

}


#' Get or set logger layout
#' @param formatter function defining how R objects are converted into a single string
#' @inheritParams log_threshold
#' @export
log_formatter <- function(formatter, namespace = 'global', index = 1) {

    configs <- get(fallback_namespace(namespace), envir = namespaces)
    config  <- configs[[min(index, length(configs))]]

    if (missing(formatter)) {
        formatter <- config$formatter
        if (!is.null(attr(formatter, 'generator'))) {
            formatter <- parse(text = attr(formatter, 'generator'))[[1]]
        }
        return(formatter)
    }

    config$formatter <- formatter
    configs[[min(index, length(config) + 1)]] <- config
    assign(namespace, configs, envir = namespaces)

}


#' Get or set logger appender function
#' @param layout function
#' @inheritParams log_threshold
#' @export
#' @examples \dontrun{
#' ## change appender to "tee" that writes to the console and a file as well
#' t <- tempfile()
#' log_appender(appender_tee(t))
#' log_info(42)
#' log_info(42:44)
#' readLines(t)
#'
#' ## poor man's tee by stacking loggers in the namespace
#' t <- tempfile()
#' log_appender(appender_console)
#' log_appender(appender_file(t), index = 2)
#' log_info(42)
#' readLines(t)
#' }
log_appender <- function(appender, namespace = 'global', index = 1) {

    configs <- get(fallback_namespace(namespace), envir = namespaces)
    config  <- configs[[min(index, length(configs))]]

    if (missing(appender)) {
        appender <- config$appender
        if (!is.null(attr(appender, 'generator'))) {
            appender <- parse(text = attr(appender, 'generator'))[[1]]
        }
        return(appender)
    }

    config$appender <- appender
    configs[[min(index, length(config) + 1)]] <- config
    assign(namespace, configs, envir = namespaces)

}


#' Find the logger definition(s) specified for the current namespace with a fallback to the global namespace
#' @return list of function(s)
#' @keywords internal
#' @importFrom utils getFromNamespace
get_logger_definitions <- function() {
    namespace <- find_namespace()
    if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
        namespace <- 'global'
    }
    get(namespace, envir = getFromNamespace('namespaces', 'logger'))
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
    defintions <- get_logger_definitions()
    for (defintion in defintions) {
        do.call(logger, defintion)(level, msg)
    }
}


#' @export
log_fatal <- function(msg) log(FATAL, msg)
#' @export
log_error <- function(msg) log(ERROR, msg)
#' @export
log_warn <- function(msg) log(WARN, msg)
#' @export
log_info <- function(msg) log(INFO, msg)
#' @export
log_debug <- function(msg) log(DEBUG, msg)
#' @export
log_trace <- function(msg) log(TRACE, msg)
