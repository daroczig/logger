log_levels_supported <- c("OFF", "FATAL", "ERROR", "WARN", "SUCCESS", "INFO", "DEBUG", "TRACE")

#' Log levels
#'
#' The standard Apache logj4 log levels plus a custom level for `SUCCESS`. For the full list of these log levels and suggested usage, check the below Details.
#'
#' List of supported log levels:
#'
#' *  `OFF` No events will be logged
#' *  `FATAL` Severe error that will prevent the application from continuing
#' *  `ERROR` An error in the application, possibly recoverable
#' *  `WARN` An event that might possible lead to an error
#' *  `SUCCESS` An explicit success event above the INFO level that you want to log
#' *  `INFO` An event for informational purposes
#' *  `DEBUG` A general debugging event
#' *  `TRACE` A fine-grained debug message, typically capturing the flow through the application.
#' @references <https://logging.apache.org/log4j/2.x/javadoc/log4j-api/org/apache/logging/log4j/Level.html>, <https://logging.apache.org/log4j/2.x/manual/customloglevels.html>
#' @name log_levels
NULL

#' @rdname log_levels
#' @export
#' @format NULL
OFF <- structure(0L, level = "OFF", class = c("loglevel", "integer"))
#' @export
#' @rdname log_levels
#' @format NULL
FATAL <- structure(100L, level = "FATAL", class = c("loglevel", "integer"))
#' @export
#' @rdname log_levels
#' @format NULL
ERROR <- structure(200L, level = "ERROR", class = c("loglevel", "integer"))
#' @export
#' @rdname log_levels
#' @format NULL
WARN <- structure(300L, level = "WARN", class = c("loglevel", "integer"))
#' @export
#' @rdname log_levels
#' @format NULL
SUCCESS <- structure(350L, level = "SUCCESS", class = c("loglevel", "integer"))
#' @export
#' @rdname log_levels
#' @format NULL
INFO <- structure(400L, level = "INFO", class = c("loglevel", "integer"))
#' @export
#' @rdname log_levels
#' @format NULL
DEBUG <- structure(500L, level = "DEBUG", class = c("loglevel", "integer"))
#' @export
#' @rdname log_levels
#' @format NULL
TRACE <- structure(600L, level = "TRACE", class = c("loglevel", "integer"))

#' @export
print.loglevel <- function(x, ...) {
  cat("Log level: ", attr(x, "level"), "\n", sep = "")
}


#' Convert R object into a logger log-level
#' @param x string or integer
#' @return pander log-level, e.g. `INFO`
#' @export
#' @examples
#' as.loglevel(INFO)
#' as.loglevel(400L)
#' as.loglevel(400)
as.loglevel <- function(x) {
  UseMethod("as.loglevel", x)
}


#' @export
as.loglevel.default <- function(x) {
  stop(paste(
    "Do not know how to convert",
    shQuote(class(x)[1]),
    "to a logger log-level."
  ))
}


#' @export
as.loglevel.character <- function(x) {
  stopifnot(
    length(x) == 1,
    x %in% log_levels_supported
  )
  getFromNamespace(x, "logger")
}


#' @export
as.loglevel.integer <- function(x) {
  loglevels <- mget(log_levels_supported, envir = asNamespace("logger"))
  stopifnot(
    length(x) == 1,
    x %in% as.integer(loglevels)
  )
  loglevels[[which(loglevels == x)]]
}


#' @export
as.loglevel.numeric <- as.loglevel.integer
