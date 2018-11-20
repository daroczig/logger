#' Concatenate strings via \code{paste}
#' @param ... R objects that can be converted to string
#' @return string
#' @export
formatter_paste <- function(...) {
    paste(...)
}


#' Apply \code{sprintf}
#' @param ... passed to \code{sprintf}
#' @return character vector
#' @export
formatter_sprintf <- function(fmt, ...) {
    sprintf(fmt, ...)
}


#' Apply \code{glue}
#' @param ... passed to \code{glue} for the text interpolation
#' @return character vector
#' @export
formatter_glue <- function(...) {
    as.character(glue(...))
}


#' Apply \code{glue} and \code{sprintf}
#'
#' The best of both words: using both formatter functions in your log messages, which can be useful eg if you are migrating from \code{sprintf} formatted log messages to \code{glue} or similar.
#'
#' Note that this function tries to be smart when passing arguments to \code{glue} and \code{sprintf}, but might fail with some edge cases, and returns an unformatted string.
#' @param ... passed to \code{glue} for the text interpolation
#' @return character vector
#' @export
formatter_glue_or_sprinf <- function(msg, ...) {

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
    msg <- tryCatch(
        as.character(sapply(msg, function(msg) {
            do.call(glue, c(msg, glueparams))
        }, USE.NAMES = FALSE)),
        error = function(e) msg)

    ## return
    msg

}
