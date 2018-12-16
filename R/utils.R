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


#' Simple helper to record both the parent call and its environment
#' @return list of parent call and frame
#' @keywords internal
get_parent <- function() {
    list(
        ## ## commented out not to waste time on this currently not used anyway
        ## log_call = sys.call(-1),
        parent_call = sys.call(-2),
        parent_frame = parent.frame(2)
    )
}
