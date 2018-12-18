#' Check if R package can be loaded and fails loudly otherwise
#' @param pkg string
#' @keywords internal
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
