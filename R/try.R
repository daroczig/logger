#' Try to evaluate an expressions and evaluate another expression on exception
#' @param try R expression
#' @param except fallback R expression to be evaluated if \code{try} fails
#' @export
#' @note Suppress log messages in the \code{except} namespace if you don't want to throw a \code{WARN} log message on the exception branch.
#' @examples
#' everything %except% 42
#' everything <- '640kb'
#' everything %except% 42
#'
#' FunDoesNotExist(1:10) %except% sum(1:10) / length(1:10)
#' FunDoesNotExist(1:10) %except% (sum(1:10) / length(1:10))
#' FunDoesNotExist(1:10) %except% MEAN(1:10) %except% mean(1:10)
#' FunDoesNotExist(1:10) %except% (MEAN(1:10) %except% mean(1:10))
`%except%` <- function(try, except) {

    call <- sys.call(-1)
    env <- parent.frame()
    try <- substitute(try)
    fallback <- substitute(except)

    tryCatch(
        eval(try, envir = env),
        error = function(e) {
            log_level(
                WARN,
                paste(
                    'Running', shQuote(deparse(fallback)), 'as',
                    shQuote(deparse(try)), 'failed:',
                    shQuote(e$message)),
                namespace = 'except',
                .topcall = call, .topenv = env)
            eval(fallback, envir = env)
        })

}
