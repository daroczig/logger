# log_info() captures local info

    Code
      log_info("foobar")
    Output
      logger / global / logger / eval / eval(expr, envir, enclos)
    Code
      f()
    Output
      logger / global / logger / f / f()
    Code
      g()
    Output
      logger / global / logger / f / f()

# log_info() captures package info

    Code
      logger_tester_function(INFO, "x = ")
    Output
      logger.tester INFO x =  0.0807501375675201
    Code
      logger_info_tester_function("everything = ")
    Output
      logger.tester INFO everything =  42

