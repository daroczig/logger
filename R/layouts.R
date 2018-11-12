#' Formats a log message
#' @param level log level, eg \code{INFO}
#' @param msg character vector
#' @return character vector
#' @importFrom glue glue
#' @export
layout_glue <- function(level, msg) {

    if (!inherits(level, 'loglevel')) {
        stop('Invalid log level, see ?log_levels')
    }

    time  <- as.character(Sys.time(), '%Y-%d-%m %H:%M:%S')
    level <- attr(level, 'level')
    msg   <- glue(msg)

    glue('{level} [{time}] {msg}')

}
