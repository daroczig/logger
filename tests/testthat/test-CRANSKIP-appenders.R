## save current settings so that we can reset later
threshold <- log_threshold()
layout    <- log_layout()
appender  <- log_appender()

test_that('async logging', {
    t <- tempfile()
    my_appender <- appender_async(appender_file(file = t))
    log_appender(my_appender)
    log_layout(layout_blank)
    for (i in 1:5) log_info(i)
    Sys.sleep(0.25)
    expect_equal(readLines(t)[1], '1')
    expect_equal(length(readLines(t)), 5)
    unlink(t)
    rm(t)
})

## reset settings
log_threshold(threshold)
log_layout(layout)
log_appender(appender)
