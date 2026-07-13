status_matrix_source_statuses <- c(
  "CODING_COMPLETE",
  "INTENDED_INCOMPLETE",
  "CODING_INCOMPLETE",
  "DERIVE_PENDING",
  "UNSET",
  "NOT_REACHED",
  "DISPLAYED",
  "PARTLY_DISPLAYED",
  "DERIVE_ERROR",
  "NO_CODING",
  "INVALID",
  "CODING_ERROR"
)

expected_sum_score_status <- function(status_a, status_b) {
  source_statuses <- c(status_a, status_b)
  valid_or_pending <- c(
    "CODING_COMPLETE",
    "INTENDED_INCOMPLETE",
    "CODING_INCOMPLETE",
    "DERIVE_PENDING"
  )

  if (any(source_statuses == "UNSET")) {
    return("UNSET")
  }

  if (any(source_statuses %in% c("DERIVE_ERROR", "NO_CODING"))) {
    return("DERIVE_ERROR")
  }

  if (any(source_statuses == "CODING_ERROR")) {
    return("CODING_ERROR")
  }

  if (any(source_statuses == "INVALID")) {
    return("INVALID")
  }

  if (
    any(source_statuses %in% c("CODING_INCOMPLETE", "DERIVE_PENDING")) &&
      all(source_statuses %in% valid_or_pending)
  ) {
    return("DERIVE_PENDING")
  }

  if (
    any(source_statuses %in% valid_or_pending) &&
      any(!source_statuses %in% valid_or_pending)
  ) {
    return("INVALID")
  }

  if (
    any(source_statuses %in% c("PARTLY_DISPLAYED", "DISPLAYED")) &&
      any(source_statuses == "NOT_REACHED")
  ) {
    return("PARTLY_DISPLAYED")
  }

  if (
    any(source_statuses == "PARTLY_DISPLAYED") &&
      any(source_statuses == "DISPLAYED")
  ) {
    return("PARTLY_DISPLAYED")
  }

  if (
    any(source_statuses == "INTENDED_INCOMPLETE") &&
      all(source_statuses %in% c("CODING_COMPLETE", "INTENDED_INCOMPLETE"))
  ) {
    return("CODING_COMPLETE")
  }

  if (length(unique(source_statuses)) == 1) {
    return(source_statuses[1])
  }

  stop(
    "No expected status rule for: ",
    paste(source_statuses, collapse = " x "),
    call. = FALSE
  )
}

sum_score_status_matrix <- function() {
  matrix <- data.frame(
    status_a = rep(
      status_matrix_source_statuses,
      each = length(status_matrix_source_statuses)
    ),
    status_b = rep(
      status_matrix_source_statuses,
      times = length(status_matrix_source_statuses)
    ),
    stringsAsFactors = FALSE
  )

  matrix$case <- seq_len(nrow(matrix))
  matrix$expected_status <- mapply(
    expected_sum_score_status,
    matrix$status_a,
    matrix$status_b,
    USE.NAMES = FALSE
  )

  matrix[c("case", "status_a", "status_b", "expected_status")]
}

status_matrix_base_coding <- function(id) {
  list(
    id = id,
    alias = id,
    label = "",
    sourceType = "BASE",
    sourceParameters = list(
      solverExpression = "",
      processing = list()
    ),
    deriveSources = list(),
    processing = list(),
    fragmenting = "",
    manualInstruction = "",
    codeModel = "RULES_ONLY",
    codes = list()
  )
}

status_matrix_sum_score_coding_scheme <- function() {
  list(
    variableCodings = list(
      status_matrix_base_coding("01a"),
      status_matrix_base_coding("01b"),
      list(
        id = "sum_score",
        alias = "sum_score",
        label = "",
        sourceType = "SUM_SCORE",
        sourceParameters = list(
          solverExpression = "",
          processing = list()
        ),
        deriveSources = list("01a", "01b"),
        processing = list(),
        fragmenting = "",
        manualInstruction = "",
        codeModel = "RULES_ONLY",
        codes = list(
          list(
            id = 0,
            type = "RESIDUAL_AUTO",
            label = "",
            score = 0,
            ruleSetOperatorAnd = FALSE,
            ruleSets = list(),
            manualInstruction = ""
          )
        )
      )
    ),
    version = "3.0"
  )
}

status_matrix_response <- function(id, status) {
  response <- list(
    id = id,
    status = status,
    value = NULL
  )

  if (identical(status, "CODING_COMPLETE")) {
    response$value <- 1
    response$code <- 1
    response$score <- 1
  }

  response
}

code_sum_score_status_pair <- function(status_a, status_b) {
  coded <- code_responses(
    coding_scheme = jsonlite::toJSON(
      status_matrix_sum_score_coding_scheme(),
      auto_unbox = TRUE,
      null = "null"
    ),
    responses = jsonlite::toJSON(
      list(
        status_matrix_response("01a", status_a),
        status_matrix_response("01b", status_b)
      ),
      auto_unbox = TRUE,
      null = "null"
    )
  )

  coded$status[coded$id == "sum_score"]
}

test_that("SUM_SCORE covers every source status crossing", {
  matrix <- sum_score_status_matrix()

  expect_equal(nrow(matrix), length(status_matrix_source_statuses)^2)
  expect_setequal(matrix$status_a, status_matrix_source_statuses)
  expect_setequal(matrix$status_b, status_matrix_source_statuses)

  matrix$actual_status <- mapply(
    code_sum_score_status_pair,
    matrix$status_a,
    matrix$status_b,
    USE.NAMES = FALSE
  )

  failures <- matrix[
    matrix$actual_status != matrix$expected_status,
    c("case", "status_a", "status_b", "expected_status", "actual_status")
  ]

  expect_equal(failures, matrix[FALSE, names(failures)])
})
