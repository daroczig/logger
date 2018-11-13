#' Find the namespace from which the logging function was called
#' @return string
#' @keywords internal
find_namespace <- function() {



    namespaces <- lapply(sys.frames(), topenv)
    namespaces <- sapply(namespaces, environmentName)

    ## look up the first calling function outside of the logger package
    outer <- which(namespaces != 'logger')

    namespaces <- namespaces[outer]
    namespace  <- tail(namespaces, 1)

    if (length(namespace) == 0) {
        namespace <- 'global'
    }

    calls <- sys.calls()
    calls <- calls[outer]
    call  <- tail(calls, 1)

    if (length(call) == 0) {
        fn   <- NA
        call <- NA
    } else {
        fn   <- deparse(call[[1]][[1]])
        call <- deparse(call[[1]])
    }

    ## ## TODO
    ## cat('namespace: ', namespace, '\n')
    ## cat('fn: ', fn, '\n')
    ## cat('call: ', call, '\n')

    namespace

}
