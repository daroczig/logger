#' Generating logging function
#' @param level log level, eg \code{INFO}
#' @param msg character vector
#' @param msg_format \code{glue}-flavored layout of the message
#' @param time_format see \code{strptime} for details
#' @return function taking \code{level} and \code{msg} arguments
#' @importFrom glue glue
#' @export
layout_generator <- function(msg_format = '{level} [{time}] {msg}',
                             time_format = '%Y-%d-%m %H:%M:%S') {

    force(msg_format)
    force(time_format)

    function(level, msg) {

        if (!inherits(level, 'loglevel')) {
            stop('Invalid log level, see ?log_levels')
        }

        time  <- as.character(Sys.time(), time_format)
        level <- attr(level, 'level')
        msg   <- glue(msg)

        glue(msg_format)

    }

}


#' Formats a log message
#' @inheritParams layout_generator
#' @return character vector
#' @importFrom glue glue
#' @export
layout_glue <- layout_generator(
    msg_format = '{level} [{time}] {msg}',
    time_format = '%Y-%d-%m %H:%M:%S')
