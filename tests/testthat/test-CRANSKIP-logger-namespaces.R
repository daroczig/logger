test_that('log_info() captures package info', {
    devtools::load_all(
      system.file('demo-packages/logger-tester-package', package = 'logger'),
      quiet = TRUE
    )
    withr::defer(devtools::unload('logger.tester'))
  
    local_test_logger(layout = layout_glue_generator("{ns} {level} {msg}"))
    expect_snapshot({
      logger_tester_function(INFO, 'x = ')
      logger_info_tester_function('everything = ')
    })
})

test_that('log_info() captures local info', {
    local_test_logger(
      layout = layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}")
    )
    f <- function() log_info("foobar")
    g <- function() f()
  
    expect_snapshot({
      log_info("foobar")
      f()
      g()
    })

})
