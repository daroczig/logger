---
name: Bug report
about: File a bug report with a reproducible example
title: ''
labels: bug
assignees: ''

---

**Describe the bug**

Please be as clear and thorough as possible.

**Reproducible example**

Share a short code chunk reproducing the bug, ideally using `reprex`. To make sure that the log output is visible, either switch the appender to `stdout`, or use the `std_out_err` option of `reprex`. For example, you could copy one of the below code chunks and run `reprex` to get a markdown chunk that you can paste in the bug report:

1. For using `reprex::reprex()` (updating the appender function as part of the example):

    ```r
    library(logger)
    log_appender(appender_stdout)
    log_info(42)
    ```

2. For using `reprex::reprex(std_out_err = TRUE)` (without updating the appender function):

    ```r
    logger::log_info(42)
    ```

**<summary>Session info</summary>**

<details>
``` r
# Paste here the output of `sessionInfo()`
```
</details>
