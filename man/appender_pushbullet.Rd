% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/appenders.R
\name{appender_pushbullet}
\alias{appender_pushbullet}
\title{Send log messages to Pushbullet}
\usage{
appender_pushbullet(...)
}
\arguments{
\item{...}{parameters passed to \link[RPushbullet:pbPost]{RPushbullet::pbPost}, such as \code{recipients}
or \code{apikey}, although it's probably much better to set all these
in the \verb{~/.rpushbullet.json} as per package docs at
\url{http://dirk.eddelbuettel.com/code/rpushbullet.html}}
}
\description{
Send log messages to Pushbullet
}
\note{
This functionality depends on the \pkg{RPushbullet} package.
}
\seealso{
Other log_appenders: 
\code{\link{appender_async}()},
\code{\link{appender_console}()},
\code{\link{appender_file}()},
\code{\link{appender_kinesis}()},
\code{\link{appender_slack}()},
\code{\link{appender_stdout}()},
\code{\link{appender_syslog}()},
\code{\link{appender_tee}()},
\code{\link{appender_telegram}()}
}
\concept{log_appenders}
