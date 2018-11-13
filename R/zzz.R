namespaces <- new.env()
namespaces$global <- logger(threshold = INFO, layout = layout_glue, appender = appender_console)

