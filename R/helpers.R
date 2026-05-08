#' Evaluate an expression and log results
#' @param expr R expression to be evaluated while logging the
#'   expression itself along with the result
#' @param level [log_levels()]
#' @param multiline setting to `FALSE` will print both the expression
#'   (enforced to be on one line by removing line-breaks if any) and
#'   its result on a single line separated by `=>`, while setting to
#'   `TRUE` will log the expression and the result in separate
#'   sections reserving line-breaks and rendering the printed results
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
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
#' log_eval(system.time(for (i in 1:100) mad(runif(1000))), multiline = TRUE)
#' \dontshow{logger:::namespaces_set(old)}
#' @importFrom utils capture.output
#' @export
log_eval <- function(expr, level = TRACE, multiline = FALSE) {
  ## capture call
  expr <- substitute(expr)
  exprs <- gsub("\n", " ", deparse(expr), fixed = TRUE)

  ## evaluate call and store results
  timer <- Sys.time()
  res <- withVisible(eval.parent(expr))

  ## log expression and results
  if (multiline == FALSE) {
    log_level(level, skip_formatter(
      paste(
        shQuote(paste(exprs, collapse = " ")),
        "=>",
        shQuote(paste(gsub("\n", " ", deparse(res$value)), collapse = " "))
      )
    ))
  } else {
    log_level(level, "Running expression: ====================")
    log_level(level, skip_formatter(exprs))
    log_level(level, "Results: ===============================")
    log_level(level, skip_formatter(capture.output(res$value)))
    log_level(level, paste(
      "Elapsed time:",
      round(difftime(Sys.time(), timer, units = "secs"), 2),
      "sec"
    ))
  }

  ## return the results of the call
  if (res$visible == TRUE) {
    res$value
  } else {
    invisible(res$value)
  }
}


#' Logs a long line to stand out from the console
#' @inheritParams log_level
#' @param separator character to be used as a separator
#' @param width max width of message -- longer text will be wrapped into multiple lines
#' @export
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' log_separator()
#' log_separator(ERROR, separator = "!", width = 60)
#' log_separator(ERROR, separator = "!", width = 100)
#' logger <- layout_glue_generator(format = "{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}")
#' log_layout(logger)
#' log_separator(ERROR, separator = "!", width = 100)
#' log_layout(layout_blank)
#' log_separator(ERROR, separator = "!", width = 80)
#' \dontshow{logger:::namespaces_set(old)}
#' @seealso [log_with_separator()]
log_separator <- function(level = INFO,
                          namespace = NA_character_,
                          separator = "=",
                          width = 80,
                          .logcall = sys.call(),
                          .topcall = sys.call(-1),
                          .topenv = parent.frame(),
                          .timestamp = Sys.time()) {
  stopifnot(length(separator) == 1, nchar(separator) == 1)

  base_info_chars <- nchar(catch_base_log(level, namespace, .topcall = .topcall, .topenv = .topenv))

  log_level(
    paste(rep(separator, max(0, width - base_info_chars)), collapse = ""),
    level = level,
    namespace = namespace,
    .logcall = .logcall,
    .topcall = .topcall,
    .topenv = .topenv,
    .timestamp = .timestamp
  )
}


#' Logs a message in a very visible way
#' @inheritParams log_level
#' @inheritParams log_separator
#' @export
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' log_with_separator("An important message")
#' log_with_separator("Some critical KPI down!!!", separator = "$")
#' log_with_separator("This message is worth a {1e3} words")
#' log_with_separator(paste(
#'   "A very important message with a bunch of extra words that will",
#'   "eventually wrap into a multi-line message for our quite nice demo :wow:"
#' ))
#' log_with_separator(
#'   paste(
#'     "A very important message with a bunch of extra words that will",
#'     "eventually wrap into a multi-line message for our quite nice demo :wow:"
#'   ),
#'   width = 60
#' )
#' log_with_separator("Boo!", level = FATAL)
#' log_layout(layout_blank)
#' log_with_separator("Boo!", level = FATAL)
#' logger <- layout_glue_generator(format = "{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}")
#' log_layout(logger)
#' log_with_separator("Boo!", level = FATAL, width = 120)
#' \dontshow{logger:::namespaces_set(old)}
#' @seealso [log_separator()]
log_with_separator <- function(...,
                               level = INFO,
                               namespace = NA_character_,
                               separator = "=",
                               width = 80) {
  base_info_chars <- nchar(catch_base_log(level, namespace, .topcall = sys.call(-1)))

  log_separator(
    level = level,
    separator = separator,
    width = width,
    namespace = namespace,
    .logcall = sys.call(),
    .topcall = sys.call(-1),
    .topenv = parent.frame()
  )

  message <- do.call(eval(log_formatter()), list(...))
  message <- strwrap(message, max(0, width - base_info_chars - 4))
  message <- sapply(message, function(m) {
    paste0(
      separator, " ", m,
      paste(rep(" ", max(0, width - base_info_chars - 4 - nchar(m))), collapse = ""),
      " ", separator
    )
  })

  log_level(skip_formatter(message), level = level, namespace = namespace, .topenv = parent.frame())

  log_separator(
    level = level,
    separator = separator,
    width = width,
    namespace = namespace,
    .logcall = sys.call(),
    .topcall = sys.call(-1),
    .topenv = parent.frame()
  )
}


#' Tic-toc logging
#' @param ... passed to [log_level()]
#' @param level see [log_levels()]
#' @param namespace x
#' @export
#' @examples
#' log_tictoc("warming up")
#' Sys.sleep(0.1)
#' log_tictoc("running")
#' Sys.sleep(0.1)
#' log_tictoc("running")
#' Sys.sleep(runif(1))
#' log_tictoc("and running")
#' @author Thanks to Neal Fultz for the idea and original implementation!
log_tictoc <- function(..., level = INFO, namespace = NA_character_) {
  ns <- fallback_namespace(namespace)

  on.exit({
    assign(ns, toc, envir = tictocs)
  })

  tic <- get0(ns, envir = tictocs, ifnotfound = Sys.time())
  toc <- Sys.time()
  tictoc <- difftime(toc, tic)

  log_level(
    paste(
      ns, "timer",
      ifelse(round(tictoc, 2) == 0, "tic", "toc"),
      round(tictoc, 2), attr(tictoc, "units"), "-- "
    ),
    ...,
    level = level, namespace = namespace,
    .logcall = sys.call(),
    .topcall = sys.call(-1),
    .topenv = parent.frame()
  )
}
tictocs <- new.env(parent = emptyenv())

#' Log cumulative running time
#'
#' This function is working like [log_tictoc()] but differs in that it continues
#' to count up rather than resetting the timer at every call. You can set the
#' start time using `log_elapsed_start()`, but if that hasn't been called it
#' will show the time since the R session started.
#'
#' @inheritParams log_tictoc
#'
#' @export
#'
#' @examples
#' log_elapsed_start()
#' Sys.sleep(0.4)
#' log_elapsed("Tast 1")
#' Sys.sleep(0.2)
#' log_elapsed("Task 2")
#'
log_elapsed <- function(..., level = INFO, namespace = NA_character_) {
  ns <- fallback_namespace(namespace)

  start <- get0(ns, envir = elapsed, ifnotfound = 0)

  time_elapsed <- as.difftime(proc.time()["elapsed"] - start, units = "secs")

  log_level(
    paste(
      ns, "timer",
      round(time_elapsed, 2), attr(time_elapsed, "units"), "elapsed -- "
    ),
    ...,
    level = level, namespace = namespace,
    .logcall = sys.call(),
    .topcall = sys.call(-1),
    .topenv = parent.frame()
  )
}
#' @rdname log_elapsed
#' @param quiet Should starting the time emit a log message
#' @export
log_elapsed_start <- function(level = INFO, namespace = NA_character_, quiet = FALSE) {
  ns <- fallback_namespace(namespace)

  assign(ns, proc.time()["elapsed"], envir = elapsed)

  if (!quiet) {
    log_level(
      paste(
        "starting", ns, "timer"
      ),
      level = level, namespace = namespace,
      .logcall = sys.call(),
      .topcall = sys.call(-1),
      .topenv = parent.frame()
    )
  }
}
elapsed <- new.env(parent = emptyenv())

#' Logs the error message to console before failing
#' @param expression call
#' @export
#' @examples
#' log_failure("foobar")
#' try(log_failure(foobar))
log_failure <- function(expression) {
  withCallingHandlers(
    expression,
    error = function(e) {
      log_error(conditionMessage(e))
    }
  )
}

#' Automatically log execution time of knitr chunks
#'
#' Calling this function in the first chunk of a document will instruct knitr
#' to automatically log the execution time of each chunk. If using
#' [formatter_glue()] or [formatter_cli()] then the `options` variable will be
#' available, providing the chunk options such as chunk label etc.
#'
#' @inheritParams log_elapsed
#'
#' @export
#'
#' @examples
#' # To be put in the first chunk of a document
#' log_chunk_time("chunk {options$label}")
#'
log_chunk_time <- function(..., level = INFO, namespace = NA_character_) {
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop("knitr is required to use this functionality", call. = FALSE)
  }
  if (!isTRUE(getOption("knitr.in.progress"))) {
    return(invisible())
  }
  args <- list(...)
  args$level <- level
  args$namespace <- namespace
  knitr::knit_hooks$set(logger_timer = function(before, options) {
    if (before) {
      log_elapsed_start(namespace = namespace, quiet = TRUE)
    } else {
      do.call(log_elapsed, args)
    }
  })
  knitr::opts_chunk$set(logger_timer = TRUE)

  invisible()
}
