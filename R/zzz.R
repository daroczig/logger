## init storage for all logger settings
namespaces <- new.env()

.onLoad <- function(libname, pkgname) {

    default_formatter <- formatter_glue
    ## warn user about using sprintf instead of glue due to missing dependency
    if (!requireNamespace('glue', quietly = TRUE)) {
        packageStartupMessage('logger: As the "glue" R package is not installed, using "sprintf" as the default log message formatter.')
        default_formatter <- formatter_sprintf
    }

    ## default namespace's logger settings
    namespaces$global <- list(
        ## there can be multiple loggers for a namespace
        default = list(
            threshold = INFO,
            layout    = layout_simple,
            formatter = default_formatter,
            appender  = appender_console))

}
