#' Check if R package can be loaded and fails loudly otherwise
#' @param pkg string
#' @param min_version optional minimum version needed
#' @export
#' @importFrom utils packageVersion compareVersion
#' @examples \dontrun{
#' f <- function() fail_on_missing_package('foobar')
#' f()
#' g <- function() fail_on_missing_package('stats')
#' g()
#' }
fail_on_missing_package <- function(pkg, min_version) {
    pc <- sys.call(which = 1)
    if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(sprintf(
            'Please install the %s package to use %s',
            shQuote(pkg),
            deparse(pc[[1]])),
            call. = FALSE)
    }
    if (!missing(min_version)) {
        if (compareVersion(min_version, as.character(packageVersion(pkg))) == 1) {
            stop(sprintf(
                'Please install min. %s version of %s to use %s',
                min_version,
                pkg,
                deparse(pc[[1]])),
                call. = FALSE)
        }
    }
}


#' Returns the name of the top level environment from which the logger was called
#' @return string
#' @keywords internal
#' @param .topenv call environment
top_env_name <- function(.topenv = parent.frame()) {
    environmentName(topenv(.topenv))
}


#' Deparse and join all lines into a single line
#'
#' Calling \code{deparse} and joining all the returned lines into a
#' single line, separated by whitespace, and then cleaning up all the
#' duplicated whitespace (except for excessive whitespace in strings
#' between single or double quotes).
#' @param x object to \code{deparse}
#' @return string
#' @export
deparse_to_one_line <- function(x) {
    gsub('\\s+(?=(?:[^\\\'"]*[\\\'"][^\\\'"]*[\\\'"])*[^\\\'"]*$)', ' ',
         paste(deparse(x), collapse = ' '),
         perl = TRUE)
}

#' Catch the log header
#' @return string
#' @keywords internal
#' @param level see \code{\link{log_levels}}
#' @param namespace string
catch_base_log <- function(level, namespace) {
    res <- suppressMessages(capture.output(log_level(level = level,
                                                     namespace = namespace),
                                           type = "message"))
    if (length(res) == 0) {
        res <- capture.output(log_level(level = level,
                                        namespace = namespace),
                              type = "output")
    }
    res
}
