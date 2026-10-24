# V8's default JSON serialization turns an R NULL into {}. Explicit nulls are
# meaningful to the autocoder (including partial-credit derivations), so encode
# list/data-frame inputs before passing them to the JavaScript JSON parser.
serialize_response_input <- function(responses) {
  if (is.list(responses)) {
    return(jsonlite::toJSON(responses, auto_unbox = TRUE, null = "null"))
  }
  responses
}
