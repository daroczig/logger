#' Testing logging from package
#' @param level foo
#' @param msg bar
#' @export
#' @importFrom logger log
logger.tester.function <- function(level, msg) {
    log_level(level, msg)
}
