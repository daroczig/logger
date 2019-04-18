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


#' Logs a long line to stand out from the console
#' @inheritParams log_level
#' @param separator character to be used as a separator
#' @param width max width of message -- longer text will be wrapped into multiple lines
#' @export
#' @examples
#' log_separator()
#' log_separator(ERROR, '!', width = 60)
log_separator <- function(level = INFO, namespace = NA_character_, separator = '=', width = 80) {
    log_level(
        paste(rep(separator, width - 23 - nchar(attr(level, 'level'))), collapse = ''),
        level = level,
        namespace = namespace)
}


#' Logs a message in a very visible way
#' @inheritParams log_level
#' @inheritParams log_separator
#' @export
#' @examples
#' log_with_separator('An important message')
#' log_with_separator('Some critical KPI down!!!', separator = '$')
#' log_with_separator('This message is worth a {1e3} words')
#' log_with_separator(paste(
#'   'A very important message with a bunch of extra words that will',
#'   'eventually wrap into a multi-line message for our quite nice demo :wow:'))
#' log_with_separator(paste(
#'   'A very important message with a bunch of extra words that will',
#'   'eventually wrap into a multi-line message for our quite nice demo :wow:'),
#'   width = 60)
#' log_with_separator('Boo!', level = FATAL)
log_with_separator <- function(..., level = INFO, namespace = NA_character_, separator = '=', width = 80) {

    log_separator(level = level, separator = separator, width = width)

    message <- do.call(eval(log_formatter()), list(...))
    message <- strwrap(message, width - 23 - nchar(attr(level, 'level')) - 4)
    message <- sapply(message, function(m) {
        paste0(
            separator, ' ', m,
            paste(rep(' ', width - 23 - nchar(attr(level, 'level')) - 4 - nchar(m)), collapse = ''),
            ' ', separator)
    })
    log_level(skip_formatter(message), level = level)

    log_separator(level = level, separator = separator, width = width)

}


#' Tic-toc logging
#' @param ... passed to \code{log_level}
#' @param level x
#' @param namespace x
#' @export
#' @examples \dontrun{
#' log_tictoc('warming up')
#' Sys.sleep(0.1)
#' log_tictoc('running')
#' Sys.sleep(0.1)
#' log_tictoc('running')
#' Sys.sleep(runif(1))
#' log_tictoc('and running')
#' }
#' @author Thanks to Neal Fultz for the idea and original implementation!
log_tictoc <- function(..., level = INFO, namespace = NA_character_) {

    ns <- fallback_namespace(namespace)

    on.exit({
        assign(ns, toc, envir = tictocs)
    })

    nsenv <- get(fallback_namespace(namespace), envir = namespaces)
    tic <- get0(ns, envir = tictocs, ifnotfound = Sys.time())
    toc <- Sys.time()
    tictoc <- difftime(toc, tic)

    log_level(paste(ns, 'timer',
                    ifelse(round(tictoc, 2) == 0, 'tic', 'toc'),
                    round(tictoc, 2), attr(tictoc, 'units') , '-- '),
              ..., level = level, namespace = namespace)

}
tictocs <- new.env()


#' Logs the error message to console before failing
#' @param expression call
#' @export
#' @examples \dontrun{
#' log_failure('foobar')
#' log_failure(foobar)
#' }
log_failure <- function(expression) {
  tryCatch(expression, error = function(e) {
    log_error(e$message)
    stop(e)
  })
}
