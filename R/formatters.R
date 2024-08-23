#' Concatenate R objects into a character vector via `paste`
#' @param ... passed to `paste`
#' @inheritParams log_level
#' @return character vector
#' @export
#' @family `log_formatters`
formatter_paste <- function(...,
                            .logcall = sys.call(),
                            .topcall = sys.call(-1),
                            .topenv = parent.frame()) {
  paste(...)
}
attr(formatter_paste, "generator") <- quote(formatter_paste())

#' Apply `sprintf` to convert R objects into a character vector
#' @param fmt passed to `sprintf`
#' @param ... passed to `sprintf`
#' @inheritParams log_level
#' @return character vector
#' @export
#' @family `log_formatters`
formatter_sprintf <- function(fmt,
                              ...,
                              .logcall = sys.call(),
                              .topcall = sys.call(-1),
                              .topenv = parent.frame()) {
  sprintf(fmt, ...)
}
attr(formatter_sprintf, "generator") <- quote(formatter_sprintf())

#' Apply `glue` to convert R objects into a character vector
#'
#' `formatter_glue()` uses [glue::glue()]; `formatter_glue_safe()` uses
#' [glue::glue_safe()].
#'
#' @param ... passed to `glue` for the text interpolation
#' @inheritParams log_level
#' @return character vector
#' @export
#' @note Although this is the default log message formatter function,
#'     but when \pkg{glue} is not installed, [formatter_sprintf()]
#'     will be used as a fallback.
#' @family `log_formatters`
#' @importFrom utils str
formatter_glue <- function(...,
                           .logcall = sys.call(),
                           .topcall = sys.call(-1),
                           .topenv = parent.frame()) {
  fail_on_missing_package("glue")

  withCallingHandlers(
    glue::glue(..., .envir = .topenv),
    error = function(e) {
      args <- paste0(capture.output(str(...)), collapse = "\n")

      stop(paste0(
        "`glue` failed in `formatter_glue` on:\n\n",
        args,
        "\n\nRaw error message:\n\n",
        conditionMessage(e),
        "\n\nPlease consider using another `log_formatter` or ",
        "`skip_formatter` on strings with curly braces."
      ))
    }
  )
}
attr(formatter_glue, "generator") <- quote(formatter_glue())


#' @rdname formatter_glue
#' @export
formatter_glue_safe <- function(...,
                                .logcall = sys.call(),
                                .topcall = sys.call(-1),
                                .topenv = parent.frame()) {
  fail_on_missing_package("glue")
  as.character(
    tryCatch(
      glue::glue_safe(..., .envir = .topenv),
      error = function(e) {
        stop(paste(
          "`glue_safe` failed in `formatter_glue_safe` on:\n\n",
          capture.output(str(...)),
          "\n\nRaw error message:\n\n",
          e$message,
          "\n\nPlease consider using another `log_formatter` or",
          "`skip_formatter` on strings with curly braces."
        ))
      }
    )
  )
}
attr(formatter_glue_safe, "generator") <- quote(formatter_glue_safe())


#' Apply `glue` and `sprintf`
#'
#' The best of both words: using both formatter functions in your log
#' messages, which can be useful eg if you are migrating from
#' `sprintf` formatted log messages to `glue` or similar.
#'
#' Note that this function tries to be smart when passing arguments to
#' `glue` and `sprintf`, but might fail with some edge cases, and
#' returns an unformatted string.
#' @param msg passed to `sprintf` as `fmt` or handled as part of `...`
#'     in `glue`
#' @param ... passed to `glue` for the text interpolation
#' @inheritParams log_level
#' @return character vector
#' @family `log_formatters`
#' @export
#' @examples \dontrun{
#' formatter_glue_or_sprintf("{a} + {b} = %s", a = 2, b = 3, 5)
#' formatter_glue_or_sprintf("{pi} * {2} = %s", pi * 2)
#' formatter_glue_or_sprintf("{pi} * {2} = {pi*2}")
#'
#' formatter_glue_or_sprintf("Hi ", "{c('foo', 'bar')}, did you know that 2*4={2*4}")
#' formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4={2*4}")
#' formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4=%s", 2 * 4)
#' formatter_glue_or_sprintf("Hi %s, did you know that 2*4={2*4}", c("foo", "bar"))
#' formatter_glue_or_sprintf("Hi %s, did you know that 2*4=%s", c("foo", "bar"), 2 * 4)
#' }
formatter_glue_or_sprintf <- function(msg,
                                      ...,
                                      .logcall = sys.call(),
                                      .topcall = sys.call(-1),
                                      .topenv = parent.frame()) {
  params <- list(...)

  ## params without a name are potential sprintf params
  sprintfparams <- which(names(params) == "")
  if (length(params) > 0 && length(sprintfparams) == 0) {
    sprintfparams <- seq_along(params)
  }
  if (is.null(msg) || length(msg) == 0) {
    msg <- ""
  }

  ## early return
  if (is.null(msg) || length(msg) == 0) {
    return("")
  }

  ## but some unnamed params might belong to glue actually, so
  ## let's look for the max number of first unnamed params sprintf expects
  sprintftags <- regmatches(msg, gregexpr("%[0-9.+0]*[aAdifeEgGosxX]", msg))[[1]]
  sprintfparams <- sprintfparams[seq_len(min(length(sprintftags), length(sprintfparams)))]

  ## get the actual params instead of indexes
  glueparams <- params[setdiff(seq_along(params), sprintfparams)]
  sprintfparams <- params[sprintfparams]

  ## first try to apply sprintf
  if (length(sprintfparams) > 0) {
    sprintfparams[vapply(sprintfparams, is.null, logical(1))] <- "NULL"
    msg <- tryCatch(
      do.call(sprintf, c(msg, sprintfparams), envir = .topenv),
      error = function(e) msg
    )
  }

  ## then try to glue
  fail_on_missing_package("glue")
  msg <- tryCatch(
    as.character(sapply(msg, function(msg) {
      do.call(glue::glue, c(msg, glueparams), envir = .topenv)
    }, USE.NAMES = FALSE)),
    error = function(e) msg
  )

  ## return
  msg
}
attr(formatter_glue_or_sprintf, "generator") <- quote(formatter_glue_or_sprintf())


#' Transforms all passed R objects into a JSON list
#' @param ... passed to `toJSON` wrapped into a `list`
#' @inheritParams log_level
#' @return character vector
#' @export
#' @note This functionality depends on the \pkg{jsonlite} package.
#' @family `log_formatters`
#' @examples \dontrun{
#' log_formatter(formatter_json)
#' log_layout(layout_json_parser())
#' log_info(everything = 42)
#' log_info(mtcars = mtcars, species = iris$Species)
#' }
formatter_json <- function(...,
                           .logcall = sys.call(),
                           .topcall = sys.call(-1),
                           .topenv = parent.frame()) {
  fail_on_missing_package("jsonlite")
  eval(as.character(jsonlite::toJSON(list(...), auto_unbox = TRUE)), envir = .topenv)
}
attr(formatter_json, "generator") <- quote(formatter_json())

#' Skip the formatter function
#'
#' Adds the `skip_formatter` attribute to an object so that logger
#' will skip calling the formatter function(s). This is useful if you
#' want to preprocess the log message with a custom function instead
#' of the active formatter function(s). Note that the `message` should
#' be a string, and `skip_formatter` should be the only input for the
#' logging function to make this work.
#' @param message character vector directly passed to the appender
#'     function in [logger()]
#' @param ... should be never set
#' @return character vector with `skip_formatter` attribute set to
#'     `TRUE`
#' @export
skip_formatter <- function(message, ...) {
  if (!inherits(message, "character")) {
    stop("Cannot skip the formatter function if the log message is not already formatter to a character vector")
  }
  if (length(list(...)) > 0) {
    stop("Cannot skip the formatter function if further arguments are passed besides the actual log message(s)")
  }
  structure(message, skip_formatter = TRUE)
}


#' Mimic the default formatter used in the \pkg{logging} package
#'
#' The \pkg{logging} package uses a formatter that behaves differently
#' when the input is a string or other R object. If the first argument
#' is a string, then [sprintf()] is being called -- otherwise it does
#' something like [log_eval()] and logs the R expression(s) and the
#' result(s) as well.
#' @param ... string and further params passed to `sprintf` or R
#'     expressions to be evaluated
#' @inheritParams log_level
#' @return character vector
#' @export
#' @family `log_formatters`
#' @examples \dontrun{
#' log_formatter(formatter_logging)
#' log_info("42")
#' log_info(42)
#' log_info(4 + 2)
#' log_info("foo %s", "bar")
#' log_info("vector %s", 1:3)
#' log_info(12, 1 + 1, 2 * 2)
#' }
formatter_logging <- function(...,
                              .logcall = sys.call(),
                              .topcall = sys.call(-1),
                              .topenv = parent.frame()) {
  params <- list(...)
  .logcall <- substitute(.logcall)

  if (is.character(params[[1]])) {
    return(do.call(sprintf, params, envir = .topenv))
  }

  sapply(seq_along(params), function(i) {
    paste(deparse(as.list(.logcall)[-1][[i]]), params[[i]], sep = ": ")
  })
}
attr(formatter_logging, "generator") <- quote(formatter_logging())


#' Formats R objects with pander
#' @param x object to be logged
#' @param ... optional parameters passed to `pander`
#' @inheritParams log_level
#' @return character vector
#' @note This functionality depends on the \pkg{pander} package.
#' @export
#' @family `log_formatters`
#' @examples \dontrun{
#' log_formatter(formatter_pander)
#' log_info("42")
#' log_info(42)
#' log_info(4 + 2)
#' log_info(head(iris))
#' log_info(head(iris), style = "simple")
#' log_info(lm(hp ~ wt, mtcars))
#' }
formatter_pander <- function(x,
                             ...,
                             .logcall = sys.call(),
                             .topcall = sys.call(-1),
                             .topenv = parent.frame()) {
  fail_on_missing_package("pander")
  pander::pander_return(x, ...)
}
attr(formatter_pander, "generator") <- quote(formatter_pander())
