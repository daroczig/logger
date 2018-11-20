#' Concatenate strings
#' @param ... R objects that can be converted to string
#' @return string
#' @export
formatter_paste <- function(...) {
    paste(...)
}


#' Apply \code{sprintf}
#' @param ... passed to \code{sprintf}
#' @return character vector
#' @export
formatter_sprintf <- function(fmt, ...) {
    sprintf(fmt, ...)
}


#' Apply \code{glue}
#' @param ... passed to \code{glue} for the text interpolation
#' @return character vector
#' @export
formatter_glue <- function(...) {
    glue(...)
}
