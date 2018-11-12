#' Log levels
#'
#' Apache logj4 log levels:
#'
#' \enumerate{
#'   \item FATAL
#'   \item ERROR
#'   \item WARN
#'   \item INFO
#'   \item DEBUG
#'   \item TRACE
#' }
#' @references \url{https://logging.apache.org/log4j/2.0/log4j-api/apidocs/org/apache/logging/log4j/Level.html}
#' @aliases log_levels FATAL ERROR WARN INFO DEBUG TRACE
#' @rdname log_levels
#' @export
FATAL <- structure(1L, level = 'FATAL', class = c('loglevel', 'integer'))
#' @export
ERROR <- structure(2L, level = 'ERROR', class = c('loglevel', 'integer'))
#' @export
WARN  <- structure(3L, level = 'WARN', class = c('loglevel', 'integer'))
#' @export
INFO  <- structure(4L, level = 'INFO', class = c('loglevel', 'integer'))
#' @export
DEBUG <- structure(5L, level = 'DEBUG', class = c('loglevel', 'integer'))
#' @export
TRACE <- structure(6L, level = 'TRACE', class = c('loglevel', 'integer'))

print.loglevel <- function(x) {
    cat('Log level:', attr(x, 'level'), '\n')
}
