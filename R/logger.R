#' Generate logging utility
#'
#' A logger consists of a log level \code{threshold}, a log message \code{formatter} function, a log record \code{layout} formatting function and the \code{appender} function deciding on the destination of the log record. For more details, see the package \code{README.md}.
#' @param threshold omit log messages below this \code{\link{log_levels}}
#' @param formatter function pre-processing the message of the log record
#' @param layout function rendering the layout of the actual log record
#' @param appender function writing the log record
#' @return function taking \code{level} and \code{msg} arguments
#' @export
#' @note It's quite unlikely that you need to call this function directly, but instead set the logger parameters and functions at \code{\link{log_threshold}}, \code{\link{log_formatter}}, \code{\link{log_layout}} and \code{\link{log_appender}} and then call \code{\link{log_levels}} and its derivatives, such as \code{\link{log_info}} directly.
logger <- function(threshold, formatter, layout, appender) {

    force(threshold)
    force(layout)
    force(appender)

    function(level, ...) {

        if (!inherits(threshold, 'loglevel')) {
            stop('Invalid log level provided as threshold, see ?log_levels')
        }

        if (level > threshold) {
            return(invisible(NULL))
        }

        appender(layout(level, formatter(...)))

    }
}

## TODO DRY the below 4 functions

#' Get or set log level threshold
#' @param level see \code{\link{log_levels}}
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
#' @seealso \code{\link{logger}}, \code{\link{log_layout}}, \code{\link{log_formatter}}, \code{\link{log_appender}}
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


#' Get or set log record layout
#' @param layout function defining the structure of a log record, eg \code{\link{layout_simple}}, \code{\link{layout_glue}} or \code{\link{layout_glue_colors}}, \code{\link{layout_json}}, or generator functions such as \code{\link{layout_glue_generator}}
#' @inheritParams log_threshold
#' @export
#' @examples \dontrun{
#' log_layout(layout_json)
#' log_info(42:44)
#' }
#' @seealso \code{\link{logger}}, \code{\link{log_threshold}}, \code{\link{log_appender}} and \code{\link{log_formatter}}
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


#' Get or set log message formatter
#' @param formatter function defining how R objects are converted into a single string, eg \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_or_sprintf}}
#' @inheritParams log_threshold
#' @export
#' @seealso \code{\link{logger}}, \code{\link{log_threshold}}, \code{\link{log_appender}} and \code{\link{log_layout}}
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


#' Get or set log record appender function
#' @param appender function delivering a log record to the destination, eg \code{\link{appender_console}}, \code{\link{appender_file}} or \code{\link{appender_tee}}
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
#' @seealso \code{\link{logger}}, \code{\link{log_threshold}}, \code{\link{log_layout}} and \code{\link{log_formatter}}
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
#' @param namespace override the default / auto-picked namespace with a custom string
get_logger_definitions <- function(namespace = NA_character_) {
    namespace <- ifelse(is.na(namespace), find_namespace(), namespace)
    if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
        namespace <- 'global'
    }
    get(namespace, envir = getFromNamespace('namespaces', 'logger'))
}


#' Log a message with given log level
#' @param level log level from \code{\link{log_levels}}
#' @param ... R objects that can be converted to a character vector via the active message formatter function
#' @param namespace string referring to the \code{logger} environment / config to be used to override the target of the message record to be used instead of the default namespace, which is defined by the R package name from which the logger was called.
#' @seealso \code{\link{logger}}
#' @export
#' @aliases log_level log_fatal log_error log_warn log_success log_info log_debug log_trace
#' @examples \dontrun{
#' log_level(INFO, 'hi there')
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
log_level <- function(level, ..., namespace = NA_character_) {
    definitions <- get_logger_definitions(namespace)
    for (definition in definitions) {
        do.call(logger, definition)(level, ...)
    }
}


#' @export
log_fatal <- function(...) log_level(FATAL, ...)
#' @export
log_error <- function(...) log_level(ERROR, ...)
#' @export
log_warn <- function(...) log_level(WARN, ...)
#' @export
log_success <- function(...) log_level(SUCCESS, ...)
#' @export
log_info <- function(...) log_level(INFO, ...)
#' @export
log_debug <- function(...) log_level(DEBUG, ...)
#' @export
log_trace <- function(...) log_level(TRACE, ...)


#' Evaluate R expression with a temporarily updated log level threshold
#' @param expression R command
#' @param threshold \code{\link{log_levels}}
#' @inheritParams log_threshold
#' @export
#' @examples \dontrun{
#' log_threshold(TRACE)
#' log_trace('Logging everything!')
#' x <- with_log_threshold({
#'   log_info('Now we are temporarily suppressing eg INFO messages')
#'   log_warn('WARN')
#'   log_debug('Debug messages are suppressed as well')
#'   log_error('ERROR')
#'   invisible(42)
#' }, threshold = WARN)
#' x
#' log_trace('DONE')
#' }
with_log_threshold <- function(expression, threshold = ERROR, namespace = 'global', index = 1) {
    old <- log_threshold(namespace = namespace, index = index)
    on.exit({
        log_threshold(old, namespace = namespace, index = index)
    })
    log_threshold(threshold, namespace = namespace, index = index)
    eval(quote(expression))
}
