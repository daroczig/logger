#' Evaluate an expression and log results
#' @param expr R expression to be evaluated while logging the expression itself along with the result
#' @param level \code{\link{log_levels}}
#' @param multiline setting to \code{FALSE} will print both the expression (enforced to be on one line by removing line-breaks if any) and its result on a single line separated by \code{=>}, while setting to \code{TRUE} will log the expression and the result in separate sections reserving line-breaks and rendering the printed results
#' @examples \dontrun{
#' log_eval(pi * 2, level = INFO)
#'
#' ## lowering the log level threshold so that we don't have to set a higher level in log_eval
#' log_threshold(TRACE)
#' log_eval(x <- 4)
#' log_eval(sqrt(x))
#'
#' ## log_eval can be called in-line as well as returning the return value of the expression
#' x <- log_eval(mean(runif(1e3)))
#' x
#'
#' ## https://twitter.com/krlmlr/status/1067864829547999232
#' f <- sqrt
#' g <- mean
#' x <- 1:31
#' log_eval(f(g(x)), level = INFO)
#' log_eval(y <- f(g(x)), level = INFO)
#'
#' ## returning a function
#' log_eval(f <- sqrt)
#' log_eval(f)
#'
#' ## evaluating something returning a wall of "text"
#' log_eval(f <- log_eval)
#' log_eval(f <- log_eval, multiline = TRUE)
#'
#' ## doing something computationally intensive
#' log_eval(system.time(for(i in 1:100) mad(runif(1000))), multiline = TRUE)
#' }
#' @importFrom utils capture.output
#' @export
log_eval <- function(expr, level = TRACE, multiline = FALSE) {

    ## capture call
    expr  <- substitute(expr)
    exprs <- gsub('\n', ' ', deparse(expr), fixed = TRUE)

    ## evaluate call and store results
    timer <- Sys.time()
    res   <- withVisible(eval.parent(expr))

    ## log expression and results
    if (multiline == FALSE) {

        log_level(level, skip_formatter(
            paste(
                shQuote(paste(exprs, collapse = ' ')),
                '=>',
                shQuote(paste(gsub('\n', ' ', deparse(res$value)), collapse = ' ')))))

    } else {

        log_level(level, 'Running expression: ====================')
        log_level(level, skip_formatter(exprs))
        log_level(level, 'Results: ===============================')
        log_level(level, skip_formatter(capture.output(res$value)))
        log_level(level, paste(
            'Elapsed time:',
            round(difftime(Sys.time(), timer, units = 'secs'), 2),
            'sec'))

    }

    ## return the results of the call
    if (res$visible == TRUE) {
        return(res$value)
    } else {
        return(invisible(res$value))
    }

}
