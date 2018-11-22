#' Append log record to stdout
#' @param lines character vector
#' @export
#' @seealso This is a \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_file}} or \code{\link{appender_tee}}
appender_console <- function(lines) {
    cat(lines, sep = '\n')
}


#' Append log messages to a file
#' @param file path
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}} or \code{\link{appender_tee}}
appender_file <- function(file) {
    structure(
        function(lines) {
            cat(lines, sep = '\n', file = file, append = TRUE)
        }, generator = deparse(match.call()))
}


#' Append log messages to a file and stdout as well
#' @param file path
#' @export
#' @return function taking \code{lines} argument
#' @seealso This is generator function for \code{\link{log_appender}}, for alternatives, see eg \code{\link{appender_console}} or \code{\link{appender_file}}
appender_tee <- function(file) {
    structure(
        function(lines) {
            appender_console(lines)
            appender_file(file)(lines)
        }, generator = deparse(match.call()))
}
