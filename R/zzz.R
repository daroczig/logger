## init storage for all logger settings
namespaces <- new.env()

.onLoad <- function(libname, pkgname) {

    ## default namespace's logger settings
    namespaces$global <- list(
        ## there can be multiple loggers for a namespace
        default = list(
            threshold = INFO,
            layout    = layout_simple,
            formatter = formatter_sprintf,
            appender  = appender_console))

    if (requireNamespace('glue', quietly = TRUE)) {
        log_formatter(formatter_glue, namespace = 'global', index = 1)
    }

    ## internal namespace for debugging logger
    namespaces$logger <- list(
        default = list(
            threshold = ERROR,
            layout    = layout_simple,
            formatter = formatter_sprintf,
            appender  = appender_console))

}

.onAttach <- function(libname, pkgname) {

    ## warn user about using sprintf instead of glue due to missing dependency
    if (!requireNamespace('glue', quietly = TRUE)) {
        packageStartupMessage('logger: As the "glue" R package is not installed, using "sprintf" as the default log message formatter instead of "glue".')
    }

}
