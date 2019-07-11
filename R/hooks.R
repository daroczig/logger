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
        tracer = substitute(logger::log_warn(logger::skip_formatter(paste(list(...), collapse = '')))),
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
        tracer = substitute(logger::log_error(logger::skip_formatter(paste(list(...), collapse = '')))),
        print = FALSE,
        where = baseenv())))
}


#' Auto logging input changes in Shiny app
#'
#' This is to be called in the \code{server} section of the Shiny app.
#' @export
#' @importFrom utils assignInMyNamespace
log_shiny_input_changes <- function(input) {

    fail_on_missing_package('shiny')
    fail_on_missing_package('jsonlite')
    if (!shiny::isRunning()) {
        stop('No Shiny app running, it makes no sense to call this function outside of a Shiny app')
    }

    input_values <- isolate(reactiveValuesToList(input))
    assignInMyNamespace('shiny_input_values', input_values)
    log_info(skip_formatter(paste(
        'Default Shiny inputs initialized:',
        as.character(jsonlite::toJSON(input_values, auto_unbox = TRUE)))))

    observe({
        old_input_alues <- shiny_input_values
        new_input_alues <- reactiveValuesToList(input)
        mapply(function(name, old, new) {
            if (!identical(old, new)) {
                log_info('Shiny input change detected on {name}: {old} -> {new}')
            }
        }, names(old_input_alues), old_input_alues, new_input_alues)
        assignInNamespace('shiny_input_values', new_input_alues, ns = 'logger')
    })


}
shiny_input_values <- NULL
