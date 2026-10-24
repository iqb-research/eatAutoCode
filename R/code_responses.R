#' Automatically code responses with coding scheme
#'
#' @param coding_scheme List or character. Coding scheme of a unit from IQB Studio Lite.
#' @param responses List or character. Unit responses from IQB Testcenter.
#' @param manual List or character. Manual codes to potentially overwrite response data. Defaults to `"null"` (would be treated in the same way as `NA`).
#'
#' @return A data frame.
#' @export
code_responses <- function(coding_scheme, responses, manual = "null") {
  eatAutoCode$call("codeResponses",
                   list(codingScheme = coding_scheme,
                        responses = responses,
                        manual = manual))
}
