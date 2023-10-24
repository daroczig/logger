log_levels_supported <- c('FATAL', 'ERROR', 'WARN', 'SUCCESS', 'INFO', 'DEBUG', 'TRACE')

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
#' @references \url{https://logging.apache.org/log4j/2.0/javadoc/log4j-api/org/apache/logging/log4j/Level.html}, \url{https://logging.apache.org/log4j/2.x/manual/customloglevels.html}
#' @aliases log_levels FATAL ERROR WARN SUCCESS INFO DEBUG TRACE
#' @rdname log_levels
#' @usage
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


#' Convert R object into a logger log-level
#' @param x string or integer
#' @return pander log-level, e.g. \code{INFO}
#' @export
#' @examples
#' as.loglevel(INFO)
#' as.loglevel(400L)
#' as.loglevel(400)
as.loglevel <- function(x) {
    UseMethod('as.loglevel', x)
}


#' @export
as.loglevel.default <- function(x) {
    stop(paste(
        'Do not know how to convert',
        shQuote(class(x)[1]),
        'to a logger log-level.'
    ))
}


#' @export
as.loglevel.character <- function(x) {
    stopifnot(
        length(x) == 1,
        x %in% log_levels_supported
    )
    getFromNamespace(x, 'logger')
}


#' @export
as.loglevel.integer <- function(x) {
    loglevels <- mget(log_levels_supported, envir = asNamespace('logger'))
    stopifnot(
        length(x) == 1,
        x %in% as.integer(loglevels)
    )
    loglevels[[which(loglevels == x)]]
}


#' @export
as.loglevel.numeric <- as.loglevel.integer
