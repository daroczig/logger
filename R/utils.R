#' Check if R package can be loaded and fails loudly otherwise
#' @param pkg string
#' @export
#' @examples \dontrun{
#' f <- function() fail_on_missing_package('foobar')
#' f()
#' g <- function() fail_on_missing_package('stats')
#' g()
#' }
fail_on_missing_package <- function(pkg) {
    pc <- sys.call(which = 1)
    if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(sprintf(
            'Please install the %s package to use %s',
            shQuote(pkg),
            deparse(pc[[1]])),
            call. = FALSE)
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
