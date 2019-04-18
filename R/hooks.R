#' Injects a logger call to standard messages
#'
#' This function uses \code{trace} to add a \code{log_info} function call when \code{message} is called to log the informative messages with the \code{logger} layout and appender.
#' @export
#' @examples \dontrun{
#' log_messages()
#' message('hi there')
#' }
log_messages <- function() {
    invisible(suppressMessages(trace(
        what = 'message',
        exit = substitute(logger::log_info(logger::skip_formatter(cond$message))),
        print = FALSE,
        where = baseenv())))
}


#' Injects a logger call to standard warnings
#'
#' This function uses \code{trace} to add a \code{log_warn} function call when \code{warning} is called to log the warning messages with the \code{logger} layout and appender.
#' @export
#' @examples \dontrun{
#' log_warnings()
#' for (i in 1:5) { Sys.sleep(runif(1)); warning(i) }
#' }
log_warnings <- function() {
    invisible(suppressMessages(trace(
        what = 'warning',
        trace = substitute(logger::log_warn(logger::skip_formatter(paste(list(...), collapse = '')))),
        print = FALSE,
        where = baseenv())))
}


#' Injects a logger call to standard errors
#'
#' This function uses \code{trace} to add a \code{log_error} function call when \code{stop} is called to log the error messages with the \code{logger} layout and appender.
#' @export
#' @examples \dontrun{
#' log_errors()
#' stop('foobar')
#' }
log_errors <- function() {
    invisible(suppressMessages(trace(
        what = 'stop',
        trace = substitute(logger::log_error(logger::skip_formatter(paste(list(...), collapse = '')))),
        print = FALSE,
        where = baseenv())))
}
