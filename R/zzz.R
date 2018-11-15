## init storage for all logger settings
namespaces <- new.env()

## default logger settings
namespaces$global <- list(
    threshold = INFO,
    layout    = layout_glue, # TODO make a much faster layout_default without calling glue for perf reasons
    formatter = formatter_glue,
    appender  = appender_console)
