.onLoad <- function(libname, pkgname) {
    namespaces_reset()
}

.onAttach <- function(libname, pkgname) {

    ## warn user about using sprintf instead of glue due to missing dependency
    if (!requireNamespace('glue', quietly = TRUE)) {
        packageStartupMessage('logger: As the "glue" R package is not installed, using "sprintf" as the default log message formatter instead of "glue".')
    }

}
