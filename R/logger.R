#' Generate logging utility
#'
#' A logger consists of a log level \code{threshold}, a log message \code{formatter} function, a log record \code{layout} formatting function and the \code{appender} function deciding on the destination of the log record. For more details, see the package \code{README.md}.
#'
#' By default, a general logger definition is created when loading the \code{logger} package, that uses
#'
#' \enumerate{
#'   \item \code{\link{INFO}} (or as per the \code{LOGGER_LOG_LEVEL} environment variable override) as the log level threshold
#'   \item \code{\link{layout_simple}} as the layout function showing the log level, timestamp and log message
#'   \item \code{\link{formatter_glue}} (or \code{\link{formatter_sprintf}} if \pkg{glue} is not installed) as the default formatter function transforming the R objects to be logged to a character vector
#'   \item \code{\link{appender_console}} as the default log record destination
#' }
#' @param threshold omit log messages below this \code{\link{log_levels}}
#' @param formatter function pre-processing the message of the log record when it's not wrapped in a \code{\link{skip_formatter}} call
#' @param layout function rendering the layout of the actual log record
#' @param appender function writing the log record
#' @return A function taking the log \code{level} to compare with the set threshold, all the \code{...} arguments passed to the formatter function, besides the standard \code{namespace}, \code{.logcall}, \code{.topcall} and \code{.topenv} arguments (see \code{\link{log_level}} for more details). The function invisibly returns a list including the original \code{level}, \code{namespace}, all \code{...} transformed to a list as \code{params}, the log \code{message} (after calling the \code{formatter} function) and the log \code{record} (after calling the \code{layout} function), and a list of \code{handlers} with the \code{formatter}, \code{layout} and \code{appender} functions.
#' @export
#' @references For more details, see the Anatomy of a Log Request vignette at \url{https://daroczig.github.io/logger/articles/anatomy.html}.
#' @note It's quite unlikely that you need to call this function directly, but instead set the logger parameters and functions at \code{\link{log_threshold}}, \code{\link{log_formatter}}, \code{\link{log_layout}} and \code{\link{log_appender}} and then call \code{\link{log_levels}} and its derivatives, such as \code{\link{log_info}} directly.
#' @examples \dontrun{
#' do.call(logger, logger:::namespaces$global[[1]])(INFO, 42)
#' do.call(logger, logger:::namespaces$global[[1]])(INFO, '{pi}')
#' x <- 42
#' do.call(logger, logger:::namespaces$global[[1]])(INFO, '{x}^2 = {x^2}')
#' }
logger <- function(threshold, formatter, layout, appender) {

    force(threshold)
    threshold <- validate_log_level(threshold)
    force(layout)
    force(appender)

    function(level, ..., namespace = NA_character_, .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {

        if (level > threshold) {
            return(invisible(NULL))
        }

        params <- list(...)

        ## workaround to be able to avoid any formatter function, eg when passing in a string
        if (length(params) == 1 && isTRUE(attr(params[[1]], 'skip_formatter', exact = TRUE))) {
            message <- params[[1]]
        } else {
            message <- do.call(formatter, c(params, list(
                .logcall = substitute(.logcall),
                .topcall = substitute(.topcall),
                .topenv = .topenv)))
        }

        record <- layout(
            level, message, namespace = namespace,
            .logcall = substitute(.logcall), .topcall = substitute(.topcall), .topenv = .topenv)

        appender(record)

        invisible(list(
            level = level,
            namespace = namespace,
            params = params,
            message = message,
            handlers = list(
                formatter = formatter,
                layout = layout,
                appender = appender
            ),
            record = record
        ))

    }
}


#' Checks if provided namespace exists and falls back to global if not
#' @param namespace string
#' @return string
#' @keywords internal
fallback_namespace <- function(namespace) {
    if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
        namespace <- 'global'
    }
    namespace
}

#' Base Logging Function
#' @param fun_name string a full name of log function
#' @param arg see \code{\link{log_levels}}
#' @param namespace logger namespace
#' @param index index of the logger within the namespace
#' @return currently set or return log function property
#' @keywords internal
log_config_setter <- function(fun_name, arg, namespace, index) {

    if (length(namespace) > 1) {
        for (ns in namespace) {
          log_config_setter(fun_name, arg, ns, index)
        }
        return(invisible())
    }

    fun_name_base <- strsplit(fun_name, '_')[[1]][2]

    configs <- get(fallback_namespace(namespace), envir = namespaces)
    config  <- configs[[min(index, length(configs))]]

    if (fun_name_base == 'threshold') {
      if (is.null(arg)) {
        return(config[[fun_name_base]])
      }
      config[[fun_name_base]] <- validate_log_level(arg)
    } else {
      if (is.null(arg)) {
        res <- config[[fun_name_base]]
        if (!is.null(attr(res, 'generator'))) {
          res <- parse(text = attr(res, 'generator'))[[1]]
        }
        return(res)
      }

      config[[fun_name_base]] <- arg
    }

    configs[[min(index, length(config) + 1)]] <- config
    assign(namespace, configs, envir = namespaces)
}


#' Delete an index from a logger namespace
#' @inheritParams log_threshold
#' @export
delete_logger_index <- function(namespace = 'global', index) {
    configs <- get(fallback_namespace(namespace), envir = namespaces)
    if (index > length(configs)) {
        stop(sprintf('%s namespace has only %i indexes', namespace, length(configs)))
    }
    configs[index] <- NULL
    assign(namespace, configs, envir = namespaces)
}


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
#'
#' ## set the log level threshold in all namespaces to ERROR
#' log_threshold(ERROR, namespace =  log_namespaces())
#' }
#' @seealso \code{\link{logger}}, \code{\link{log_layout}}, \code{\link{log_formatter}}, \code{\link{log_appender}}
log_threshold <- function(level = NULL, namespace = 'global', index = 1) {
    log_config_setter(fun_name = 'log_threshold', arg = level, namespace = namespace, index = index)
}


#' Get or set log record layout
#' @param layout function defining the structure of a log record, eg \code{\link{layout_simple}}, \code{\link{layout_glue}} or \code{\link{layout_glue_colors}}, \code{\link{layout_json}}, or generator functions such as \code{\link{layout_glue_generator}}, default NULL
#' @inheritParams log_threshold
#' @export
#' @examples \dontrun{
#' log_layout(layout_json())
#' log_info(42)
#' }
#' @seealso \code{\link{logger}}, \code{\link{log_threshold}}, \code{\link{log_appender}} and \code{\link{log_formatter}}
log_layout <- function(layout = NULL, namespace = 'global', index = 1) {
    log_config_setter(fun_name = 'log_layout', arg = layout, namespace = namespace, index = index)
}


#' Get or set log message formatter
#' @param formatter function defining how R objects are converted into a single string, eg \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_or_sprintf}}, \code{\link{formatter_logging}}, default NULL
#' @inheritParams log_threshold
#' @export
#' @seealso \code{\link{logger}}, \code{\link{log_threshold}}, \code{\link{log_appender}} and \code{\link{log_layout}}
log_formatter <- function(formatter = NULL, namespace = 'global', index = 1) {
    log_config_setter(fun_name = 'log_formatter', arg = formatter, namespace = namespace, index = index)
}


#' Get or set log record appender function
#' @param appender function delivering a log record to the destination, eg \code{\link{appender_console}}, \code{\link{appender_file}} or \code{\link{appender_tee}}, default NULL
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
log_appender <- function(appender = NULL, namespace = 'global', index = 1) {
    log_config_setter(fun_name = 'log_appender', arg = appender, namespace = namespace, index = index)
}


#' Find the logger definition(s) specified for the current namespace with a fallback to the global namespace
#' @return list of function(s)
#' @keywords internal
#' @importFrom utils getFromNamespace
#' @param namespace override the default / auto-picked namespace with a custom string
get_logger_definitions <- function(namespace = NA_character_, .topenv = parent.frame()) {
    namespace <- ifelse(is.na(namespace), top_env_name(.topenv), namespace)
    if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
        namespace <- 'global'
    }
    get(namespace, envir = getFromNamespace('namespaces', 'logger'))
}


#' Looks up logger namespaces
#' @return character vector of namespace names
#' @export
log_namespaces <- function() {
    ls(envir = namespaces)
}


#' Log a message with given log level
#' @param level log level, see \code{\link{log_levels}} for more details
#' @param ... R objects that can be converted to a character vector via the active message formatter function
#' @param namespace string referring to the \code{logger} environment / config to be used to override the target of the message record to be used instead of the default namespace, which is defined by the R package name from which the logger was called, and falls back to a common, global namespace.
#' @param .logcall the logging call being evaluated (useful in formatters and layouts when you want to have access to the raw, unevaluated R expression)
#' @param .topcall R expression from which the logging function was called (useful in formatters and layouts to extract the calling function's name or arguments)
#' @param .topenv original frame of the \code{.topcall} calling function where the formatter function will be evaluated and that is used to look up the \code{namespace} as well via \code{logger:::top_env_name}
#' @seealso \code{\link{logger}}
#' @export
#' @aliases log_level log_fatal log_error log_warn log_success log_info log_debug log_trace
#' @usage
#' log_level(level, ..., namespace = NA_character_,
#'   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame())
#'
#' log_trace(..., namespace = NA_character_,
#'   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame())
#'
#' log_debug(..., namespace = NA_character_,
#'   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame())
#'
#' log_info(..., namespace = NA_character_,
#'   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame())
#'
#' log_success(..., namespace = NA_character_,
#'   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame())
#'
#' log_warn(..., namespace = NA_character_,
#'   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame())
#'
#' log_error(..., namespace = NA_character_,
#'   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame())
#'
#' log_fatal(..., namespace = NA_character_,
#'   .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame())
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
#'
#' log_layout(layout_json())
#' log_info('ok {1:3} + {1:3} = {2*(1:3)}')
#'
#' ## note for the JSON output, glue is not automatically applied
#' log_info(glue::glue('ok {1:3} + {1:3} = {2*(1:3)}'))
#' }
#' @return Invisible \code{list} of \code{logger} objects. See \code{\link{logger}} for more details on the format/
log_level <- function(level, ..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {

    log_arg <- list(...)

    ## guess namespace
    if (is.na(namespace)) {
        topenv    <- top_env_name(.topenv)
        namespace <-  ifelse(topenv == 'R_GlobalEnv', 'global', topenv)
    }

    definitions <- get_logger_definitions(namespace, .topenv = .topenv)
    level <- validate_log_level(level)

    log_arg$level <- level
    log_arg$.logcall <- .logcall
    log_arg$.topcall  <- if(!is.null(.topcall)) {
        .topcall
    } else {
        ## cannot pass NULL
        NA
    }
    log_arg$.topenv <- .topenv
    log_arg$namespace <- namespace

    invisible(lapply(definitions, function(definition) {

        if (level > definition$threshold) {
            return(NULL)
        }

        log_fun <- do.call(logger, definition)

        ## TODO try with match.call and replace [[1]]?
        structure(do.call(log_fun, log_arg), class = 'logger')

    }))

}


#' Assure valid log level
#' @param level \code{\link{log_levels}} object or string representation
#' @return \code{\link{log_levels}} object
#' @keywords internal
validate_log_level <- function(level) {
    if (inherits(level, 'loglevel')) {
        return(level)
    }
    if (is.character(level) & level %in% log_levels_supported) {
        return(get(level))
    }
    stop('Invalid log level')
}


#' @export
log_fatal <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    log_level(FATAL, ..., namespace = namespace, .logcall = .logcall, .topcall = .topcall, .topenv = .topenv)
}
#' @export
log_error <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    log_level(ERROR, ..., namespace = namespace, .logcall = .logcall, .topcall = .topcall, .topenv = .topenv)
}
#' @export
log_warn <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    log_level(WARN, ..., namespace = namespace, .logcall = .logcall, .topcall = .topcall, .topenv = .topenv)
}
#' @export
log_success <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    log_level(SUCCESS, ..., namespace = namespace, .logcall = .logcall, .topcall = .topcall, .topenv = .topenv)
}
#' @export
log_info <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    log_level(INFO, ..., namespace = namespace, .logcall = .logcall, .topcall = .topcall, .topenv = .topenv)
}
#' @export
log_debug <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    log_level(DEBUG, ..., namespace = namespace, .logcall = .logcall, .topcall = .topcall, .topenv = .topenv)
}
#' @export
log_trace <- function(..., namespace = NA_character_,
                      .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    log_level(TRACE, ..., namespace = namespace, .logcall = .logcall, .topcall = .topcall, .topenv = .topenv)
}


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
