derivation_statuses_510 <- c(
  "VALUE_CHANGED",
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

multi_source_derivation_methods_510 <- c(
  "MANUAL",
  "CONCAT_CODE",
  "SUM_CODE",
  "SUM_SCORE",
  "UNIQUE_VALUES",
  "SOLVER"
)

status_matrix_valid_states_510 <- function(method) {
  switch(
    method,
    MANUAL = c(
      "INVALID",
      "VALUE_CHANGED",
      "NO_CODING",
      "CODING_ERROR",
      "CODING_COMPLETE",
      "INTENDED_INCOMPLETE"
    ),
    COPY_VALUE = c(
      "VALUE_CHANGED",
      "NO_CODING",
      "CODING_INCOMPLETE",
      "CODING_ERROR",
      "CODING_COMPLETE",
      "INTENDED_INCOMPLETE"
    ),
    UNIQUE_VALUES = c(
      "VALUE_CHANGED",
      "NO_CODING",
      "CODING_INCOMPLETE",
      "CODING_ERROR",
      "CODING_COMPLETE",
      "INTENDED_INCOMPLETE"
    ),
    SOLVER = c(
      "VALUE_CHANGED",
      "NO_CODING",
      "CODING_INCOMPLETE",
      "CODING_ERROR",
      "CODING_COMPLETE",
      "INTENDED_INCOMPLETE"
    ),
    CONCAT_CODE = c("CODING_COMPLETE", "INTENDED_INCOMPLETE"),
    SUM_CODE = c("CODING_COMPLETE", "INTENDED_INCOMPLETE"),
    SUM_SCORE = c("CODING_COMPLETE", "INTENDED_INCOMPLETE"),
    stop("Unknown derivation method: ", method, call. = FALSE)
  )
}

expected_derivation_status_510 <- function(method, source_statuses) {
  if (any(source_statuses == "UNSET")) {
    return("UNSET")
  }

  if (any(source_statuses == "DERIVE_ERROR")) {
    return("DERIVE_ERROR")
  }

  if (!identical(method, "SOLVER") && any(source_statuses == "NO_CODING")) {
    return("DERIVE_ERROR")
  }

  if (any(source_statuses == "CODING_ERROR")) {
    return("CODING_ERROR")
  }

  if (any(source_statuses == "INVALID")) {
    return("INVALID")
  }

  aggregate_from_code <- method %in% c("CONCAT_CODE", "SUM_CODE", "SUM_SCORE")
  valid_for_pending <- c(
    "CODING_INCOMPLETE",
    "CODING_COMPLETE",
    "DERIVE_PENDING",
    "INTENDED_INCOMPLETE"
  )

  if (
    aggregate_from_code &&
      any(source_statuses %in% c("CODING_INCOMPLETE", "DERIVE_PENDING")) &&
      all(source_statuses %in% valid_for_pending)
  ) {
    return("DERIVE_PENDING")
  }

  false_states <- sum(
    !source_statuses %in% status_matrix_valid_states_510(method)
  )

  if (false_states > 0) {
    if (all(source_statuses == source_statuses[1])) {
      return(status_matrix_finalize_success_510(source_statuses[1]))
    }

    partly_displayed_statuses <- c(
      "NOT_REACHED",
      "DISPLAYED",
      "PARTLY_DISPLAYED"
    )

    if (all(source_statuses %in% partly_displayed_statuses)) {
      return("PARTLY_DISPLAYED")
    }

    return("INVALID")
  }

  if (identical(method, "MANUAL")) {
    if (all(source_statuses == "INTENDED_INCOMPLETE")) {
      return("CODING_INCOMPLETE")
    }

    return("CODING_COMPLETE")
  }

  status_matrix_finalize_success_510("VALUE_CHANGED")
}

status_matrix_finalize_success_510 <- function(status) {
  if (identical(status, "VALUE_CHANGED")) {
    return("CODING_COMPLETE")
  }

  status
}

derivation_status_pair_matrix_510 <- function(method) {
  matrix <- data.frame(
    status_a = rep(
      derivation_statuses_510,
      each = length(derivation_statuses_510)
    ),
    status_b = rep(
      derivation_statuses_510,
      times = length(derivation_statuses_510)
    ),
    stringsAsFactors = FALSE
  )

  matrix$case <- seq_len(nrow(matrix))
  matrix$method <- method
  matrix$expected_status <- mapply(
    function(status_a, status_b) {
      expected_derivation_status_510(method, c(status_a, status_b))
    },
    matrix$status_a,
    matrix$status_b,
    USE.NAMES = FALSE
  )

  matrix[
    c("case", "method", "status_a", "status_b", "expected_status")
  ]
}

copy_value_status_matrix_510 <- function() {
  matrix <- data.frame(
    status = derivation_statuses_510,
    stringsAsFactors = FALSE
  )

  matrix$case <- seq_len(nrow(matrix))
  matrix$method <- "COPY_VALUE"
  matrix$expected_status <- vapply(
    matrix$status,
    function(status) {
      expected_derivation_status_510("COPY_VALUE", status)
    },
    character(1)
  )

  matrix[c("case", "method", "status", "expected_status")]
}

status_matrix_base_coding_510 <- function(id) {
  list(
    id = id,
    alias = id,
    label = "",
    sourceType = "BASE",
    sourceParameters = list(
      solverExpression = "",
      processing = list("TAKE_EMPTY_AS_VALID")
    ),
    deriveSources = list(),
    processing = list(),
    fragmenting = "",
    manualInstruction = "",
    codeModel = "RULES_ONLY",
    codes = list()
  )
}

status_matrix_residual_codes_510 <- function() {
  list(
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
}

status_matrix_source_parameters_510 <- function(method, source_ids) {
  if (identical(method, "SOLVER")) {
    expression <- paste0(
      paste0("${", source_ids, "}"),
      collapse = " + "
    )

    return(list(
      solverExpression = expression,
      processing = list()
    ))
  }

  list(
    solverExpression = "",
    processing = list()
  )
}

status_matrix_derived_coding_510 <- function(method, source_ids) {
  list(
    id = "derived",
    alias = "derived",
    label = "",
    sourceType = method,
    sourceParameters = status_matrix_source_parameters_510(method, source_ids),
    deriveSources = as.list(source_ids),
    processing = list(),
    fragmenting = "",
    manualInstruction = "",
    codeModel = "RULES_ONLY",
    codes = status_matrix_residual_codes_510()
  )
}

status_matrix_coding_scheme_510 <- function(method, source_ids) {
  list(
    variableCodings = c(
      lapply(source_ids, status_matrix_base_coding_510),
      list(status_matrix_derived_coding_510(method, source_ids))
    ),
    version = "3.0"
  )
}

status_matrix_response_510 <- function(id, status) {
  response <- list(
    id = id,
    status = status,
    value = 1
  )

  if (identical(status, "CODING_COMPLETE")) {
    response$code <- 1
    response$score <- 1
  }

  response
}

code_derivation_status_510 <- function(method, source_statuses) {
  source_ids <- paste0("source_", seq_along(source_statuses))
  coded <- code_responses(
    coding_scheme = jsonlite::toJSON(
      status_matrix_coding_scheme_510(method, source_ids),
      auto_unbox = TRUE,
      null = "null"
    ),
    responses = jsonlite::toJSON(
      unname(Map(status_matrix_response_510, source_ids, source_statuses)),
      auto_unbox = TRUE,
      null = "null"
    )
  )

  coded$status[coded$id == "derived"]
}

test_that("multi-source derivation methods cover every source status crossing", {
  for (method in multi_source_derivation_methods_510) {
    matrix <- derivation_status_pair_matrix_510(method)

    expect_equal(nrow(matrix), length(derivation_statuses_510)^2)
    expect_setequal(matrix$status_a, derivation_statuses_510)
    expect_setequal(matrix$status_b, derivation_statuses_510)

    matrix$actual_status <- mapply(
      function(status_a, status_b) {
        code_derivation_status_510(method, c(status_a, status_b))
      },
      matrix$status_a,
      matrix$status_b,
      USE.NAMES = FALSE
    )

    failures <- matrix[
      matrix$actual_status != matrix$expected_status,
      c(
        "case",
        "method",
        "status_a",
        "status_b",
        "expected_status",
        "actual_status"
      )
    ]

    expect_equal(
      failures,
      matrix[FALSE, names(failures)],
      info = method
    )
  }
})

test_that("COPY_VALUE covers every valid single-source status", {
  matrix <- copy_value_status_matrix_510()

  expect_equal(nrow(matrix), length(derivation_statuses_510))
  expect_setequal(matrix$status, derivation_statuses_510)

  matrix$actual_status <- vapply(
    matrix$status,
    function(status) {
      code_derivation_status_510("COPY_VALUE", status)
    },
    character(1)
  )

  failures <- matrix[
    matrix$actual_status != matrix$expected_status,
    c("case", "method", "status", "expected_status", "actual_status")
  ]

  expect_equal(failures, matrix[FALSE, names(failures)])
})
