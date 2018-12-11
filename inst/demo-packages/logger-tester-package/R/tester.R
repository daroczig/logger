#' Testing logging from package
#' @param level foo
#' @param msg bar
#' @export
#' @importFrom logger log_level
logger_tester_function <- function(level, msg) {
    log_level(level, msg)
}

#' Testing logging INFO from package
#' @param msg bar
#' @export
#' @importFrom logger log_info
logger_info_tester_function <- function(msg) {
    log_info(msg)
}
