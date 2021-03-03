## this is to be called in the background process of appender_async
## because having library/require calls in that function throws false R CMD check alerts
require('logger')
require('txtq')
