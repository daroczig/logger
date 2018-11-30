## init storage for all logger settings
namespaces <- new.env()

## default namespace's logger settings
namespaces$global <- list(
    ## there can be multiple loggers for a namespace
    default = list(
        threshold = INFO,
        layout    = layout_simple,
        formatter = formatter_glue,
        appender  = appender_console))