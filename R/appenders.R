#' Append log messages to stdout
#' @param lines character vector
#' @export
appender_console <- function(lines) {
    cat(lines, sep = '\n')
}


#' Append log messages to a file
#' @param file path
#' @export
#' @return function taking \code{lines} argument
appender_file <- function(file) {
    function(lines) {
        cat(lines, sep = '\n', file = file, append = TRUE)
    }
}


#' Append log messages to a file and stdout as well
#' @param file path
#' @export
#' @return function taking \code{lines} argument
appender_tee <- function(file) {
    function(lines) {
        appender_console(lines)
        appender_file(file)(lines)
    }
}


## TODO graylog, cloudwatch, datadog, kinesis etc
