#' Warn to update R to 4+
#' @keywords internal
warn_if_globalCallingHandlers_is_not_available <- function() {
    log_warn(
        'Using legacy version of global message/warning/error hook, ',
        'please update your R installation to at least 4.0.0 ',
        'to make use of the much more elegant globalCallingHandlers approach.')
}


#' Injects a logger call to standard messages
#'
#' This function uses \code{trace} to add a \code{log_info} function call when \code{message} is called to log the informative messages with the \code{logger} layout and appender.
#' @export
#' @examples \dontrun{
#' log_messages()
#' message('hi there')
#' }
log_messages <- function() {
    if (R.Version()$major >= 4) {
        if (any(sapply(globalCallingHandlers()[names(globalCallingHandlers()) == 'message'],
                       attr, which = 'implements') == 'log_messages')) {
            warning('Ignoring this call to log_messages as it was registered previously.')
        } else {
            globalCallingHandlers(
                message = structure(function(m) {
                    logger::log_level(logger::INFO, m$message, .topcall = m$call)
                }, implements = 'log_messages'))
        }
    } else {
        warn_if_globalCallingHandlers_is_not_available()
        invisible(suppressMessages(trace(
            what = 'message',
            exit = substitute(logger::log_info(logger::skip_formatter(cond$message))),
            print = FALSE,
            where = baseenv())))
    }
}


#' Injects a logger call to standard warnings
#'
#' This function uses \code{trace} to add a \code{log_warn} function call when \code{warning} is called to log the warning messages with the \code{logger} layout and appender.
#' @param muffle if TRUE, the warning is not shown after being logged
#' @export
#' @examples \dontrun{
#' log_warnings()
#' for (i in 1:5) { Sys.sleep(runif(1)); warning(i) }
#' }
log_warnings <- function(muffle = getOption('logger_muffle_warnings', FALSE)) {
    if (R.Version()$major >= 4) {
        if (any(sapply(globalCallingHandlers()[names(globalCallingHandlers()) == 'warning'],
                       attr, which = 'implements') == 'log_warnings')) {
            warning('Ignoring this call to log_warnings as it was registered previously.')
        } else {
            globalCallingHandlers(
                warning = structure(function(m) {
                    logger::log_level(logger::WARN, m$message, .topcall = m$call)
                    if (isTRUE(muffle)) {
                        invokeRestart('muffleWarning')
                    }
                }, implements = 'log_warnings'))
        }
    } else {
        warn_if_globalCallingHandlers_is_not_available()
        invisible(suppressMessages(trace(
            what = 'warning',
            tracer = substitute(logger::log_warn(logger::skip_formatter(paste(list(...), collapse = '')))),
            print = FALSE,
            where = baseenv())))
    }
}


#' Injects a logger call to standard errors
#'
#' This function uses \code{trace} to add a \code{log_error} function call when \code{stop} is called to log the error messages with the \code{logger} layout and appender.
#' @param muffle if TRUE, the error is not thrown after being logged
#' @export
#' @examples \dontrun{
#' log_errors()
#' stop('foobar')
#' }
log_errors <- function(muffle = getOption('logger_muffle_errors', FALSE)) {
    if (R.Version()$major >= 4) {
        if (any(sapply(globalCallingHandlers()[names(globalCallingHandlers()) == 'error'],
                       attr, which = 'implements') == 'log_errors')) {
            warning('Ignoring this call to log_errors as it was registered previously.')
        } else {
            globalCallingHandlers(
                error = structure(function(m) {
                    logger::log_level(logger::ERROR, m$message, .topcall = m$call)
                    if (isTRUE(muffle)) {
                        invokeRestart('abort')
                    }
                }, implements = 'log_errors'))
        }
    } else {
        warn_if_globalCallingHandlers_is_not_available()
        invisible(suppressMessages(trace(
            what = 'stop',
            tracer = substitute(logger::log_error(logger::skip_formatter(paste(list(...), collapse = '')))),
            print = FALSE,
            where = baseenv())))
    }
}


#' Auto logging input changes in Shiny app
#'
#' This is to be called in the \code{server} section of the Shiny app.
#' @export
#' @param input passed from Shiny's \code{server}
#' @param level log level
#' @param excluded_inputs character vector of input names to exclude from logging
#' @param namespace the name of the namespace
#' @importFrom utils assignInMyNamespace assignInNamespace
#' @examples \dontrun{
#' library(shiny)
#'
#' ui <- bootstrapPage(
#'     numericInput('mean', 'mean', 0),
#'     numericInput('sd', 'sd', 1),
#'     textInput('title', 'title', 'title'),
#'     textInput('foo', 'This is not used at all, still gets logged', 'foo'),
#'     passwordInput('password', 'Password not to be logged', 'secret'),
#'     plotOutput('plot')
#' )
#'
#' server <- function(input, output) {
#'
#'     logger::log_shiny_input_changes(input, excluded_inputs = 'password')
#'
#'     output$plot <- renderPlot({
#'         hist(rnorm(1e3, input$mean, input$sd), main = input$title)
#'     })
#'
#' }
#'
#' shinyApp(ui = ui, server = server)
#' }
log_shiny_input_changes <- function(input,
                                    level = INFO,
                                    namespace = NA_character_,
                                    excluded_inputs = character()) {

    fail_on_missing_package('shiny')
    fail_on_missing_package('jsonlite')
    if (!shiny::isRunning()) {
        stop('No Shiny app running, it makes no sense to call this function outside of a Shiny app')
    }

    input_values <- shiny::isolate(shiny::reactiveValuesToList(input))
    assignInMyNamespace('shiny_input_values', input_values)
    log_level(level, skip_formatter(paste(
        'Default Shiny inputs initialized:',
        as.character(jsonlite::toJSON(input_values, auto_unbox = TRUE)))), namespace = namespace)

    shiny::observe({
        old_input_values <- shiny_input_values
        new_input_values <- shiny::reactiveValuesToList(input)
        names <- unique(c(names(old_input_values), names(new_input_values)))
        names <- setdiff(names, excluded_inputs)
        for (name in names) {
            old <- old_input_values[name]
            new <- new_input_values[name]
            if (!identical(old, new)) {
                log_level(level, 'Shiny input change detected on {name}: {old} -> {new}', namespace = namespace)
            }
        }
        assignInNamespace('shiny_input_values', new_input_values, ns = 'logger')
    })


}
shiny_input_values <- NULL
