#' Colorize string by the related log level
#'
#' Adding color to a string to be used in terminal output. Supports ANSI standard colors 8 or 256.
#' @param msg string
#' @param level see [log_levels()]
#' @return string with ANSI escape code
#' @export
#' @examplesIf requireNamespace("crayon")
#' cat(colorize_by_log_level('foobar', FATAL), '\n')
#' cat(colorize_by_log_level('foobar', ERROR), '\n')
#' cat(colorize_by_log_level('foobar', WARN), '\n')
#' cat(colorize_by_log_level('foobar', SUCCESS), '\n')
#' cat(colorize_by_log_level('foobar', INFO), '\n')
#' cat(colorize_by_log_level('foobar', DEBUG), '\n')
#' cat(colorize_by_log_level('foobar', TRACE), '\n')
colorize_by_log_level <- function(msg, level) {

    fail_on_missing_package('crayon')

    color <- switch(
        attr(level, 'level'),
        'FATAL'   = crayon::combine_styles(crayon::bold, crayon::make_style('red1')),
        'ERROR'   = crayon::make_style('red4'),
        'WARN'    = crayon::make_style('darkorange'),
        'SUCCESS' = crayon::combine_styles(crayon::bold, crayon::make_style('green4')),
        'INFO'    = crayon::reset,
        'DEBUG'   = crayon::make_style('deepskyblue4'),
        'TRACE'   = crayon::make_style('dodgerblue4'),
        stop('Unknown log level')
    )

    paste0(color(msg), crayon::reset(''))

}


#' Render a string with light/dark gray based on the related log level
#'
#' Adding color to a string to be used in terminal output. Supports ANSI standard colors 8 or 256.
#' @param msg string
#' @param level see [log_levels()]
#' @return string with ANSI escape code
#' @export
#' @examplesIf requireNamespace("crayon")
#' cat(grayscale_by_log_level('foobar', FATAL), '\n')
#' cat(grayscale_by_log_level('foobar', ERROR), '\n')
#' cat(grayscale_by_log_level('foobar', WARN), '\n')
#' cat(grayscale_by_log_level('foobar', SUCCESS), '\n')
#' cat(grayscale_by_log_level('foobar', INFO), '\n')
#' cat(grayscale_by_log_level('foobar', DEBUG), '\n')
#' cat(grayscale_by_log_level('foobar', TRACE), '\n')
grayscale_by_log_level <- function(msg, level) {

    fail_on_missing_package('crayon')

    color <- switch(
        attr(level, 'level'),
        'FATAL'   = crayon::make_style('gray100'),
        'ERROR'   = crayon::make_style('gray90'),
        'WARN'    = crayon::make_style('gray80'),
        'SUCCESS' = crayon::make_style('gray70'),
        'INFO'    = crayon::make_style('gray60'),
        'DEBUG'   = crayon::make_style('gray50'),
        'TRACE'   = crayon::make_style('gray40'),
        stop('Unknown log level')
    )

    paste0(color(msg), crayon::reset(''))

}
