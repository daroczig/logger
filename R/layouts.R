#' Collect useful information about the logging environment to be used in log messages
#'
#' Available variables to be used in the log formatter functions, eg in \code{\link{layout_glue_generator}}:
#' \itemize{
#'   \item levelr: log level as an R object, eg \code{\link{INFO}}
#'   \item level: log level as a string, eg \code{\link{INFO}}
#'   \item time: current time as \code{POSIXct}
#'   \item node: name by which the machine is known on the network as reported by \code{Sys.info}
#'   \item arch: machine type, typically the CPU architecture
#'   \item os_name: Operating System's name
#'   \item os_release: Operating System's release
#'   \item os_version: Operating System's version
#'   \item user: name of the real user id as reported by \code{Sys.info}
#'   \item pid: the process identification number of the R session
#'   \item node: name by which the machine is known on the network as reported by \code{Sys.info}
#'   \item namespace: R package (if any) calling the logging function
#'   \item call: parent call (if any) calling the logging function
#'   \item fn: function's (if any) name calling the logging function
#' }
#' @param log_level log level as per \code{\link{log_levels}}
#' @return list
#' @export
#' @seealso layout_glue_generator
get_logger_meta_variables <- function(log_level = NULL) {

    sysinfo <- Sys.info()

    list(

        namespace = find_namespace(),
        fn        = find_fn(),
        call      = find_call(),

        time      = Sys.time(),
        levelr    = log_level,
        level     = attr(log_level, 'level'),

        pid       = Sys.getpid(),

        ## stuff from Sys.info
        node       = sysinfo[['nodename']],
        arch       = sysinfo[['machine']],
        os_name    = sysinfo[['sysname']],
        os_release = sysinfo[['release']],
        os_version = sysinfo[['version']],
        user       = sysinfo[['user']]

        ## TODO jenkins (or any) env vars => no need to get here, users can write custom layouts
        ## TODO seed

    )

}


#' Generate logging function using common variables available via glue syntax
#'
#' \code{format} is passed to \code{glue} with access to the below variables:
#' \itemize{
#'  \item msg: the actual log message
#'  \item further variables set by \code{\link{get_logger_meta_variables}}
#' }
#' @param format \code{glue}-flavored layout of the message using the above variables
#' @return function taking \code{level} and \code{msg} arguments - keeping the original call creating the generator in the \code{generator} attribute that is returned when calling \code{\link{log_layout}} for the currently used layout
#' @importFrom glue glue
#' @export
#' @examples \dontrun{
#' logger <- layout_glue_generator(format = '{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}')
#' logger(INFO, 'try {runif(1)}')
#'
#' log_layout(logger)
#' log_info('try {runif(1)}')
#' }
layout_glue_generator <- function(format = '{level} [{format(time, "%Y-%d-%m %H:%M:%S")}] {msg}') {

    force(format)

    structure(function(level, msg) {

        if (!inherits(level, 'loglevel')) {
            stop('Invalid log level, see ?log_levels')
        }

        with(get_logger_meta_variables(level), glue(format))

    }, generator = deparse(match.call()))

}


#' Format a log record by concatenating the log level, timestamp and message
#' @param level log level, see \code{\link{log_levels}} for more details
#' @param msg string message
#' @return character vector
#' @export
layout_simple <- function(level, msg) {
    paste0(attr(level, 'level'), ' [', format(Sys.time(), "%Y-%d-%m %H:%M:%S"), '] ', msg)
}


#' Format a log message with \code{glue}
#' @inheritParams layout_simple
#' @return character vector
#' @importFrom glue glue
#' @export
layout_glue <- layout_glue_generator()


#' Format a log message with \code{glue} and ANSI escape codes to add colors
#' @inheritParams layout_simple
#' @return character vector
#' @importFrom glue glue
#' @export
#' @examples \dontrun{
#' log_layout(layout_glue_colors)
#' log_threshold(TRACE)
#' log_info('Starting the script...')
#' log_debug('This is the second line')
#' log_trace('That is being placed right after the first one.')
#' log_warn('Some errors might come!')
#' log_error('This is a problem')
#' log_debug('Getting an error is usually bad')
#' log_error('This is another problem')
#' log_fatal('The last problem.')
#' }
layout_glue_colors <- layout_glue_generator(
    format = paste(
        '{crayon::bold(colorize_by_log_level(level, levelr))}',
        '[{crayon::italic(format(time, "%Y-%d-%m %H:%M:%S"))}]',
        '{grayscale_by_log_level(msg, levelr)}'))


#' Format a log message as JSON
#' @inheritParams layout_simple
#' @return character vector
#' @export
#' @examples \dontrun{
#' log_layout(layout_json)
#' log_info(42:44)
#' }
layout_json <- function(level, msg) {

    if (!requireNamespace('jsonlite', quietly = TRUE)) {
        stop('Please install the jsonlite package for logging messages in JSON format')
    }

    sapply(msg, function(msg)
        jsonlite::toJSON(list(
            level = attr(level, 'level'),
            timestamp = Sys.time(),
            message = as.character(msg)
        ), auto_unbox = TRUE))

}
