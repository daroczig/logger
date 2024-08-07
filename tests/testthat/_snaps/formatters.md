# glue gives informative error if message contains curlies

    Code
      log_info("hi{")
    Condition
      Error in `h()`:
      ! `glue` failed in `formatter_glue` on:
      
       chr "hi{"
      
      Raw error message:
      
      Expecting '}'
      
      Please consider using another `log_formatter` or `skip_formatter` on strings with curly braces.

