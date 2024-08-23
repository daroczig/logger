# glue works

    Code
      formatter_glue("malformed {")
    Condition
      Error in `h()`:
      ! `glue` failed in `formatter_glue` on:
      
       chr "malformed {"
      
      Raw error message:
      
      Expecting '}'
      
      Please consider using another `log_formatter` or `skip_formatter` on strings with curly braces.

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

# glue_safe works

    Code
      formatter_glue_safe("Hi {42}")
    Condition
      Error in `value[[3L]]()`:
      ! `glue_safe` failed in `formatter_glue_safe` on:
      
        chr "Hi {42}" 
      
      Raw error message:
      
       object '42' not found 
      
      Please consider using another `log_formatter` or `skip_formatter` on strings with curly braces.
    Code
      formatter_glue_safe("malformed {")
    Condition
      Error in `value[[3L]]()`:
      ! `glue_safe` failed in `formatter_glue_safe` on:
      
        chr "malformed {" 
      
      Raw error message:
      
       Expecting '}' 
      
      Please consider using another `log_formatter` or `skip_formatter` on strings with curly braces.

# sprintf works

    Code
      formatter_sprintf("%s and %i", 1)
    Condition
      Error in `sprintf()`:
      ! too few arguments

# skip formatter

    Code
      log_info(skip_formatter("hi {x}", x = 4))
    Condition
      Error in `skip_formatter()`:
      ! Cannot skip the formatter function if further arguments are passed besides the actual log message(s)

