## init storage for all logger settings
namespaces <- new.env()

## default namespace's logger settings
namespaces$global <- list(
    ## there can be multiple loggers for a namespace
    default = list(
        threshold = INFO,
        ## TODO make a much faster layout_default without calling glue for perf reasons
        layout    = layout_glue,
        formatter = formatter_glue,
        appender  = appender_console))
