# %except% logs errors and returns default value

    Code
      out <- FunDoesNotExist(1:10) %except% 1
    Output
      WARN Running '1' as 'FunDoesNotExist(1:10)' failed: 'could not find function "FunDoesNotExist"'

