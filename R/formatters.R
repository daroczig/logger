#' Concatenate R objects into a character vector via \code{paste}
#' @param ... passed to \code{paste}
#' @return character vector
#' @export
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_sprintf}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_or_sprintf}}
formatter_paste <- structure(function(...) {
    paste(...)
}, generator = quote(formatter_paste()))


#' Apply \code{sprintf} to convert R objects into a character vector
#' @param fmt passed to \code{sprintf}
#' @param ... passed to \code{sprintf}
#' @return character vector
#' @export
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_glue}}, \code{\link{formatter_glue_or_sprintf}}
formatter_sprintf <- structure(function(fmt, ...) {
    sprintf(fmt, ...)
}, generator = quote(formatter_sprintf()))


#' Apply \code{glue} to convert R objects into a character vector
#' @param ... passed to \code{glue} for the text interpolation
#' @return character vector
#' @export
#' @note Although this is the default log message formatter function, but when \pkg{glue} is not installed, \code{\link{formatter_sprintf}} will be used as a fallback.
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue_or_sprintf}}
formatter_glue <- structure(function(...) {
    fail_on_missing_package('glue')
    as.character(glue::glue(..., .envir = parent.frame()))
}, generator = quote(formatter_glue()))


#' Apply \code{glue} and \code{sprintf}
#'
#' The best of both words: using both formatter functions in your log messages, which can be useful eg if you are migrating from \code{sprintf} formatted log messages to \code{glue} or similar.
#'
#' Note that this function tries to be smart when passing arguments to \code{glue} and \code{sprintf}, but might fail with some edge cases, and returns an unformatted string.
#' @param msg passed to \code{sprintf} as \code{fmt} or handled as part of \code{...} in \code{glue}
#' @param ... passed to \code{glue} for the text interpolation
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
#' @seealso This is a \code{\link{log_formatter}}, for alternatives, see \code{\link{formatter_paste}}, \code{\link{formatter_sprintf}}, \code{\link{formatter_glue_or_sprintf}}
formatter_glue_or_sprintf <- structure(function(msg, ...) {

    params <- list(...)

    ## params without a name are potential sprintf params
    sprintfparams <- which(names(params) == '')
    if (length(params) > 0 & length(sprintfparams) == 0) {
        sprintfparams <- seq_along(params)
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
            do.call(sprintf, c(msg, sprintfparams)),
            error = function(e) msg)
    }

    ## then try to glue
    fail_on_missing_package('glue')
    msg <- tryCatch(
        as.character(sapply(msg, function(msg) {
            do.call(glue::glue, c(msg, glueparams), envir = parent.frame())
        }, USE.NAMES = FALSE)),
        error = function(e) msg)

    ## return
    msg

}, generator = quote(formatter_glue_or_sprintf()))


#' Adds the skip_formatter attribute to an object so that logger will skip calling the formatter function on the object(s) to be logged
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
