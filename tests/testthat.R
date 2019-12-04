library(testthat)
library(logger)

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
    test_check('logger')
} else {
    test_check('logger', filter = '^[a-z]*$')
}
