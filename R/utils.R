#' Check if R package can be loaded and fails loudly otherwise
#' @param pkg string
#' @param min_version optional minimum version needed
#' @param call Call to include in error message.
#' @export
#' @importFrom utils packageVersion compareVersion
#' @examples
#' f <- function() fail_on_missing_package("foobar")
#' try(f())
#' g <- function() fail_on_missing_package("stats")
#' g()
fail_on_missing_package <- function(pkg, min_version, call = NULL) {
  pc <- call %||% sys.call(which = 1)
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      sprintf(
        "Please install the '%s' package to use %s",
        pkg,
        deparse(pc[[1]])
      ),
      call. = FALSE
    )
  }
  if (!missing(min_version)) {
    if (compareVersion(min_version, as.character(packageVersion(pkg))) == 1) {
      stop(
        sprintf(
          "Please install min. %s version of %s to use %s",
          min_version,
          pkg,
          deparse(pc[[1]])
        ),
        call. = FALSE
      )
    }
  }
}


#' Returns the name of the top level environment from which the logger was called
#' @return string
#' @noRd
#' @param .topenv call environment
top_env_name <- function(.topenv = parent.frame()) {
  environmentName(topenv(.topenv))
}

#' Finds the location of the logger call (file and line)
#' @return list with path and line element
#' @noRd
#' @param .logcall The call that emitted the log
log_call_location <- function(.logcall) {
  call_string <- deparse(.logcall)
  loc <- list(
    path = "<console>",
    line = ""
  )
  for (trace in .traceback(0)) {
    if (identical(call_string, as.vector(trace))) {
      ref <- attr(trace, "srcref")
      loc$line <- ref[1L]
      file <- attr(ref, "srcfile")
      if (!is.null(file)) {
        loc$path <- normalizePath(file$filename, winslash = "/", mustWork = FALSE)
      }
      break
    }
  }
  loc
}

#' Deparse and join all lines into a single line
#'
#' Calling `deparse` and joining all the returned lines into a
#' single line, separated by whitespace, and then cleaning up all the
#' duplicated whitespace (except for excessive whitespace in strings
#' between single or double quotes).
#' @param x object to `deparse`
#' @return string
#' @export
deparse_to_one_line <- function(x) {
  gsub('\\s+(?=(?:[^\\\'"]*[\\\'"][^\\\'"]*[\\\'"])*[^\\\'"]*$)', " ",
    paste(deparse(x), collapse = " "),
    perl = TRUE
  )
}


#' Catch the log header
#' @return string
#' @param level see [log_levels()]
#' @param namespace string
#' @noRd
#' @examples
#' \dontshow{old <- logger:::namespaces_set()}
#' catch_base_log(INFO, NA_character_)
#' logger <- layout_glue_generator(format = "{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}")
#' log_layout(logger)
#' catch_base_log(INFO, NA_character_)
#' fun <- function() catch_base_log(INFO, NA_character_)
#' fun()
#' catch_base_log(INFO, NA_character_, .topcall = call("funLONG"))
#' \dontshow{logger:::namespaces_set(old)}
catch_base_log <- function(level, namespace, .topcall = sys.call(-1), .topenv = parent.frame()) {
  namespace <- fallback_namespace(namespace)

  old <- log_appender(appender_console, namespace = namespace)
  on.exit(log_appender(old, namespace = namespace))

  # catch error, warning or message
  capture.output(
    log_level(
      level = level,
      "",
      namespace = namespace,
      .topcall = .topcall,
      .topenv = .topenv
    ),
    type = "message"
  )
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

in_pkgdown <- function() {
  identical(Sys.getenv("IN_PKGDOWN"), "true")
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

is_checking_logger <- function() {
  Sys.getenv("_R_CHECK_PACKAGE_NAME_", "") == "logger"
}

needs_stdout <- function() {
  in_pkgdown() || is_testing() || is_checking_logger()
}

# allow mocking
Sys.time <- NULL # nolint
proc.time <- NULL # nolint
