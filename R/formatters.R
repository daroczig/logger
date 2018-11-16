#' Concatenate strings and apply glue formatter
#' @param ... first passed to \code{paste} to generate a character vector of all passed objects, then passed to \code{glue}
#' @return character vector
#' @export
formatter_glue <- function(...) {
    msgs <- list(...)
    msgs <- do.call(paste, msgs)
    sapply(msgs, glue, USE.NAMES = FALSE)
}
