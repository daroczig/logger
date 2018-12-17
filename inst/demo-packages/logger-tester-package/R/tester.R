#' Testing logging from package
#' @param level foo
#' @param msg bar
#' @export
#' @importFrom logger log_level
logger_tester_function <- function(level, msg) {
    x <- runif(1)
    log_level(level, '{msg} {x}')
}

#' Testing logging INFO from package
#' @param msg bar
#' @export
#' @importFrom logger log_info
logger_info_tester_function <- function(msg) {
    everything <- 42
    log_info('{msg} {everything}')
}
