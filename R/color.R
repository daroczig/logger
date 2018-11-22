#' Colorize string by related log level
#'
#' Adding color to a string to be used in terminal output. Supports ANSI standard colors 8 or 256.
#' @param msg string
#' @param level see \code{\link{log_levels}}
#' @return string with ANSI escape code
#' @export
#' @examples \dontrun{
#' cat(colorize_by_log_level(FATAL, 'foobar'), '\n')
#' cat(colorize_by_log_level(ERROR, 'foobar'), '\n')
#' cat(colorize_by_log_level(WARN, 'foobar'), '\n')
#' cat(colorize_by_log_level(INFO, 'foobar'), '\n')
#' cat(colorize_by_log_level(DEBUG, 'foobar'), '\n')
#' cat(colorize_by_log_level(TRACE, 'foobar'), '\n')
#' }
colorize_by_log_level <- function(msg, level) {

    if (!requireNamespace('crayon', quietly = TRUE)) {
        warning('Colored logging requires the "crayon" package to be installed.')
        return(msg)
    }

    color <- switch(
        attr(level, 'level'),
        'FATAL'   = crayon::combine_styles(crayon::bold, crayon::make_style('red1')),
        'ERROR'   = crayon::make_style('red4'),
        'WARN'    = crayon::make_style('darkorange'),
        'SUCCESS' = crayon::combine_styles(crayon::bold, crayon::make_style('green4')),
        'INFO'    = crayon::reset,
        'DEBUG'   = crayon::make_style('deepskyblue4'),
        'TRACE'   = crayon::make_style('greenyellow'),
        stop('Unknown log level')
    )

    paste0(color(msg), crayon::reset(''))

}
