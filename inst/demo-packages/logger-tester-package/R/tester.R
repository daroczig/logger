#' Testing logging from package
#' @param level foo
#' @param msg bar
#' @export
#' @importFrom logger log_level
logger_tester_function <- function(level, msg) {
    log_level(level, msg)
}
