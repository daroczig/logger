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
            deparse(pc[[1]])))
    }
}
