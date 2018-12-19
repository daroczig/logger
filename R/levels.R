#' Log levels
#'
#' The standard Apache logj4 log levels plus a custom level for \code{SUCCESS}. For the full list of these log levels and suggested usage, check the below Details.
#'
#' List of supported log levels:
#' \enumerate{
#'   \item \code{FATAL} severe error that will prevent the application from continuing
#'   \item \code{ERROR} An error in the application, possibly recoverable
#'   \item \code{WARN} An event that might possible lead to an error
#'   \item \code{SUCCESS} An explicit success event above the INFO level that you want to log
#'   \item \code{INFO} An event for informational purposes
#'   \item \code{DEBUG} A general debugging event
#'   \item \code{TRACE} A fine-grained debug message, typically capturing the flow through the application.
#' }
#' @references \url{https://logging.apache.org/log4j/2.0/log4j-api/apidocs/org/apache/logging/log4j/Level.html}, \url{https://logging.apache.org/log4j/2.x/manual/customloglevels.html}
#' @aliases log_levels FATAL ERROR WARN SUCCESS INFO DEBUG TRACE
#' @rdname log_levels
#' @usage
#' ?log_levels
#'
#' TRACE
#'
#' DEBUG
#'
#' INFO
#'
#' SUCCESS
#'
#' WARN
#'
#' ERROR
#'
#' FATAL
#' @export
FATAL <- structure(100L, level = 'FATAL', class = c('loglevel', 'integer'))
#' @export
ERROR <- structure(200L, level = 'ERROR', class = c('loglevel', 'integer'))
#' @export
WARN  <- structure(300L, level = 'WARN', class = c('loglevel', 'integer'))
#' @export
SUCCESS <- structure(350L, level = 'SUCCESS', class = c('loglevel', 'integer'))
#' @export
INFO  <- structure(400L, level = 'INFO', class = c('loglevel', 'integer'))
#' @export
DEBUG <- structure(500L, level = 'DEBUG', class = c('loglevel', 'integer'))
#' @export
TRACE <- structure(600L, level = 'TRACE', class = c('loglevel', 'integer'))

print.loglevel <- function(x) {
    cat('Log level: ', attr(x, 'level'), '\n', sep = '')
}
