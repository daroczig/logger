#' Check if R package can be loaded and fails loudly otherwise
#'
#' We do not recommend using this function in new code; it only exported
#' for historical reasons.
#'
#' @param pkg string
#' @param min_version optional minimum version needed
#' @export
#' @importFrom utils packageVersion compareVersion
#' @keywords internal
#' @examples \dontrun{
#' f <- function() fail_on_missing_package("foobar")
#' f()
#' g <- function() fail_on_missing_package("stats")
#' g()
#' }
fail_on_missing_package <- function(pkg, min_version) {
  pc <- sys.call(which = 1)
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      sprintf(
        "Please install the %s package to use %s",
        shQuote(pkg),
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
#' @keywords internal
#' @param .topenv call environment
top_env_name <- function(.topenv = parent.frame()) {
  environmentName(topenv(.topenv))
}


#' Deparse and join all lines into a single line
#'
#' We do not recommend using this function in new code; it only exported
#' for historical reasons.
#'
#' @param x object to `deparse`
#' @return string
#' @keywords internal
#' @export
deparse_to_one_line <- function(x) {
  gsub('\\s+(?=(?:[^\\\'"]*[\\\'"][^\\\'"]*[\\\'"])*[^\\\'"]*$)', " ",
    paste(deparse(x), collapse = " "),
    perl = TRUE
  )
}


#' Catch the log header
#' @return string
#' @keywords internal
#' @param level see [log_levels()]
#' @param namespace string
#' @examples
#' \dontrun{
#' catch_base_log(INFO, NA_character_)
#' logger <- layout_glue_generator(format = "{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}")
#' log_layout(logger)
#' catch_base_log(INFO, NA_character_)
#' fun <- function() catch_base_log(INFO, NA_character_)
#' fun()
#' catch_base_log(INFO, NA_character_, .topcall = call("funLONG"))
#' }
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

in_pkgdown <- function() {
  identical(Sys.getenv("IN_PKGDOWN"), "true")
}
