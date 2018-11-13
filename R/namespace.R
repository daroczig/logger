#' Checks if provided namespace exists and falls back to global if not
#' @param namespace string
#' @return string
#' @keywords internal
fallback_namespace <- function(namespace) {
    if (!exists(namespace, envir = namespaces, inherits = FALSE)) {
        namespace <- 'global'
    }
    namespace
}


#' Find the namespace, function name and call from which the logging function was called
#' @return list
#' @keywords internal
find_parents <- function() {

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

    list(namespace = namespace, call = call, fn = fn)

}


#' Find the namespace from which the logging function was called
#' @return string
#' @keywords internal
find_namespace <- function() {
    find_parents()$namespace
}


#' Find the call from which the logging function was called
#' @return string
#' @keywords internal
find_call <- function() {
    find_parents()$call
}


#' Find the function from which the logging function was called
#' @return string
#' @keywords internal
find_fn <- function() {
    find_parents()$fn
}
