# Log levels

The standard Apache logj4 log levels plus a custom level for `SUCCESS`.
For the full list of these log levels and suggested usage, check the
below Details.

## Usage

``` r
OFF

FATAL

ERROR

WARN

SUCCESS

INFO

DEBUG

TRACE
```

## Details

List of supported log levels:

- `OFF` No events will be logged

- `FATAL` Severe error that will prevent the application from continuing

- `ERROR` An error in the application, possibly recoverable

- `WARN` An event that might possible lead to an error

- `SUCCESS` An explicit success event above the INFO level that you want
  to log

- `INFO` An event for informational purposes

- `DEBUG` A general debugging event

- `TRACE` A fine-grained debug message, typically capturing the flow
  through the application.

## References

<https://logging.apache.org/log4j/2.x/javadoc/log4j-api/org/apache/logging/log4j/Level.html>,
<https://logging.apache.org/log4j/2.x/manual/customloglevels.html>
