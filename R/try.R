#' Try to evaluate an expressions and evaluate another expression on
#' exception
#' @param try R expression
#' @param except fallback R expression to be evaluated if `try` fails
#' @export
#' @note Suppress log messages in the `except` namespace if you don't
#'   want to throw a `WARN` log message on the exception branch.
#' @examples
#' everything %except% 42
#' everything <- "640kb"
#' everything %except% 42
#'
#' FunDoesNotExist(1:10) %except% sum(1:10) / length(1:10)
#' FunDoesNotExist(1:10) %except% (sum(1:10) / length(1:10))
#' FunDoesNotExist(1:10) %except% MEAN(1:10) %except% mean(1:10)
#' FunDoesNotExist(1:10) %except% (MEAN(1:10) %except% mean(1:10))
`%except%` <- function(try, except) {

  # Need to capture these in the evaluation frame of `%except%` but only want
  # to do the work if there's an error
  delayedAssign("call", sys.call(-1))
  delayedAssign("env", parent.frame())
  delayedAssign("except_text", deparse(substitute(except)))
  delayedAssign("try_text", deparse(substitute(try)))

  tryCatch(
    try,
    error = function(e) {
      log_level(
        WARN,
        paste0("Running '", except_text, "' as '", try_text, "' failed: '", e$message, "'"),
        namespace = "except",
        .topcall = call,
        .topenv = env
      )
      except
    })

}
