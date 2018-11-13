#' Append log messages to stdout
#' @param lines character vector
#' @export
appender_console <- function(lines) {
    cat(lines, sep = '\n')
}
