#' Concatenate R objects into a character vector via \code{paste}
#' @param ... passed to \code{paste}
#' @inheritParams log_level
#' @return character vector
#' @export
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_sprintf}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_safe}}, \code{\link{formatter_glue_or_sprintf}}, \code{\link{formatter_logging}}, \code{\link{formatter_json}}, \code{\link{formatter_pander}} and \code{\link{skip_formatter}} for marking a string not to apply the formatter on it.
formatter_paste <- structure(function(..., .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    eval(paste(...), envir = .topenv)
}, generator = quote(formatter_paste()))


#' Apply \code{sprintf} to convert R objects into a character vector
#' @param fmt passed to \code{sprintf}
#' @param ... passed to \code{sprintf}
#' @inheritParams log_level
#' @return character vector
#' @export
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_safe}}, \code{\link{formatter_glue_or_sprintf}}, \code{\link{formatter_logging}}, \code{\link{formatter_json}}, \code{\link{formatter_pander}} and \code{\link{skip_formatter}} for marking a string not to apply the formatter on it.
formatter_sprintf <- structure(function(fmt, ..., .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    eval(sprintf(fmt, ...), envir = .topenv)
}, generator = quote(formatter_sprintf()))


#' Apply \code{glue} to convert R objects into a character vector
#' @param ... passed to \code{glue} for the text interpolation
#' @inheritParams log_level
#' @return character vector
#' @export
#' @note Although this is the default log message formatter function, but when \pkg{glue} is not installed, \code{\link{formatter_sprintf}} will be used as a fallback.
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue_or_sprintf}}, \code{\link{formatter_glue_safe}}, \code{\link{formatter_logging}}, \code{\link{formatter_json}}, \code{\link{formatter_pander}} and \code{\link{skip_formatter}} for marking a string not to apply the formatter on it.
#' @importFrom utils str
formatter_glue <- structure(function(..., .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    fail_on_missing_package('glue')
    message <- as.character(
        tryCatch(
            glue::glue(..., .envir = .topenv),
            error = function(e) {
                stop(paste(
                    '`glue` failed in `formatter_glue` on:\n\n',
                    capture.output(str(...)),
                    '\n\nRaw error message:\n\n',
                    e$message,
                    '\n\nPlease consider using another `log_formatter` or',
                    '`skip_formatter` on strings with curly braces.'))
            }))
    ## throw warning with logger inputs on empty response
    if (length(message) == 0) {
        try(warning(paste(
            "glue in formatter_glue returned nothing with the following parameters:",
            paste(..., sep = ' | ')
        )), silent = TRUE)
    }
    message
}, generator = quote(formatter_glue()))


#' Apply \code{glue_safe} to convert R objects into a character vector
#' @param ... passed to \code{glue_safe} for the text interpolation
#' @inheritParams log_level
#' @return character vector
#' @export
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_glue}}, \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_or_sprintf}}, \code{\link{formatter_logging}}, \code{\link{formatter_json}}, \code{\link{formatter_pander}} and \code{\link{skip_formatter}} for marking a string not to apply the formatter on it.
#' @importFrom utils str
formatter_glue_safe <- structure(function(..., .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    fail_on_missing_package('glue')
    as.character(
        tryCatch(
            glue::glue_safe(..., .envir = .topenv),
            error = function(e) {
                stop(paste(
                    '`glue_safe` failed in `formatter_glue_safe` on:\n\n',
                    capture.output(str(...)),
                    '\n\nRaw error message:\n\n',
                    e$message,
                    '\n\nPlease consider using another `log_formatter` or',
                    '`skip_formatter` on strings with curly braces.'))
            }))
}, generator = quote(formatter_glue_safe()))


#' Apply \code{glue} and \code{sprintf}
#'
#' The best of both words: using both formatter functions in your log messages, which can be useful eg if you are migrating from \code{sprintf} formatted log messages to \code{glue} or similar.
#'
#' Note that this function tries to be smart when passing arguments to \code{glue} and \code{sprintf}, but might fail with some edge cases, and returns an unformatted string.
#' @param msg passed to \code{sprintf} as \code{fmt} or handled as part of \code{...} in \code{glue}
#' @param ... passed to \code{glue} for the text interpolation
#' @inheritParams log_level
#' @return character vector
#' @export
#' @examples \dontrun{
#' formatter_glue_or_sprintf("{a} + {b} = %s", a = 2, b = 3, 5)
#' formatter_glue_or_sprintf("{pi} * {2} = %s", pi*2)
#' formatter_glue_or_sprintf("{pi} * {2} = {pi*2}")
#'
#' formatter_glue_or_sprintf("Hi ", "{c('foo', 'bar')}, did you know that 2*4={2*4}")
#' formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4={2*4}")
#' formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4=%s", 2*4)
#' formatter_glue_or_sprintf("Hi %s, did you know that 2*4={2*4}", c('foo', 'bar'))
#' formatter_glue_or_sprintf("Hi %s, did you know that 2*4=%s", c('foo', 'bar'), 2*4)
#' }
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_safe}}, \code{\link{formatter_logging}}, \code{\link{formatter_json}}, \code{\link{formatter_pander}} and \code{\link{skip_formatter}} for marking a string not to apply the formatter on it.
formatter_glue_or_sprintf <- structure(function(msg, ..., .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {

    params <- list(...)

    ## params without a name are potential sprintf params
    sprintfparams <- which(names(params) == '')
    if (length(params) > 0 & length(sprintfparams) == 0) {
        sprintfparams <- seq_along(params)
    }
    if (is.null(msg) || length(msg) == 0) {
	    msg <- ''
    }

    ## early return
    if (is.null(msg) || length(msg) == 0) {
        return('')
    }

    ## but some unnamed params might belong to glue actually, so
    ## let's look for the max number of first unnamed params sprintf expects
    sprintftags <- regmatches(msg, gregexpr('%[0-9.+0]*[aAdifeEgGosxX]', msg))[[1]]
    sprintfparams <- sprintfparams[seq_len(min(length(sprintftags), length(sprintfparams)))]

    ## get the actual params instead of indexes
    glueparams    <- params[setdiff(seq_along(params), sprintfparams)]
    sprintfparams <- params[sprintfparams]

    ## first try to apply sprintf
    if (length(sprintfparams) > 0) {
        sprintfparams[vapply(sprintfparams, is.null, logical(1))] <- 'NULL'
        msg <- tryCatch(
            do.call(sprintf, c(msg, sprintfparams), envir = .topenv),
            error = function(e) msg)
    }

    ## then try to glue
    fail_on_missing_package('glue')
    msg <- tryCatch(
        as.character(sapply(msg, function(msg) {
            do.call(glue::glue, c(msg, glueparams), envir = .topenv)
        }, USE.NAMES = FALSE)),
        error = function(e) msg)

    ## return
    msg

}, generator = quote(formatter_glue_or_sprintf()))


#' Transforms all passed R objects into a JSON list
#' @param ... passed to \code{toJSON} wrapped into a \code{list}
#' @inheritParams log_level
#' @return character vector
#' @export
#' @note This functionality depends on the \pkg{jsonlite} package.
#' @examples \dontrun{
#' log_formatter(formatter_json)
#' log_layout(layout_json_parser())
#' log_info(everything = 42)
#' log_info(mtcars = mtcars, species = iris$Species)
#' }
#' @seealso This is a \code{\link{log_formatter}} potentially to be used with \code{\link{layout_json_parser}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_safe}}, \code{\link{formatter_glue_or_sprintf}}, \code{\link{formatter_logging}}, \code{\link{formatter_pander}} and \code{\link{skip_formatter}} for marking a string not to apply the formatter on it.
formatter_json <- structure(function(..., .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {
    fail_on_missing_package('jsonlite')
    eval(as.character(jsonlite::toJSON(list(...), auto_unbox = TRUE)), envir = .topenv)
}, generator = quote(formatter_json()))


#' Skip the formatter function
#'
#' Adds the \code{skip_formatter} attribute to an object so that logger will skip calling the formatter function(s). This is useful if you want to preprocess the log message with a custom function instead of the active formatter function(s). Note that the \code{message} should be a string, and \code{skip_formatter} should be the only input for the logging function to make this work.
#' @param message character vector directly passed to the appender function in \code{\link{logger}}
#' @param ... should be never set
#' @return character vector  with \code{skip_formatter} attribute set to \code{TRUE}
#' @export
skip_formatter <- function(message, ...) {
    if (!inherits(message, 'character')) {
        stop('Cannot skip the formatter function if the log message is not already formatter to a character vector')
    }
    if (length(list(...)) > 0) {
        stop('Cannot skip the formatter function if further arguments are passed besides the actual log message(s)')
    }
    structure(message, skip_formatter = TRUE)
}


#' Mimic the default formatter used in the \pkg{logging} package
#'
#' The \pkg{logging} package uses a formatter that behaves differently when the input is a string or other R object. If the first argument is a string, then \code{\link{sprintf}} is being called -- otherwise it does something like \code{\link{log_eval}} and logs the R expression(s) and the result(s) as well.
#' @examples \dontrun{
#' log_formatter(formatter_logging)
#' log_info('42')
#' log_info(42)
#' log_info(4+2)
#' log_info('foo %s', 'bar')
#' log_info('vector %s', 1:3)
#' log_info(12, 1+1, 2 * 2)
#' }
#' @param ... string and further params passed to \code{sprintf} or R expressions to be evaluated
#' @inheritParams log_level
#' @return character vector
#' @export
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_safe}}, \code{\link{formatter_glue_or_sprintf}}, \code{\link{formatter_json}}, \code{\link{formatter_pander}} and \code{\link{skip_formatter}} for marking a string not to apply the formatter on it.
formatter_logging <- structure(function(..., .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {

    params <- list(...)
    .logcall <- substitute(.logcall)

    if (is.character(params[[1]])) {
        return(do.call(sprintf, params, envir = .topenv))
    }

    sapply(1:length(params), function(i) {
        paste(deparse(as.list(.logcall)[-1][[i]]), params[[i]], sep = ': ')
    })

}, generator = quote(formatter_logging()))


#' Formats R objects with pander
#' @param x object to be logged
#' @param ... optional parameters passed to \code{pander}
#' @inheritParams log_level
#' @return character vector
#' @examples \dontrun{
#' log_formatter(formatter_pander)
#' log_info('42')
#' log_info(42)
#' log_info(4+2)
#' log_info(head(iris))
#' log_info(head(iris), style = 'simple')
#' log_info(lm(hp ~ wt, mtcars))
#' }
#' @note This functionality depends on the \pkg{pander} package.
#' @export
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_safe}}, \code{\link{formatter_glue_or_sprintf}}, \code{\link{formatter_logging}}
formatter_pander <- structure(function(x, ..., .logcall = sys.call(), .topcall = sys.call(-1), .topenv = parent.frame()) {

    fail_on_missing_package('pander')
    eval(pander::pander_return(x, ...), envir = .topenv)

}, generator = quote(formatter_pander()))
