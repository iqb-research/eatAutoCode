# Reference cases were established with @iqb/responses 5.3.1 before the
# 5.5.0 update. Expected matrices are deliberately independent of the coder.
# Profiles distinguish a response's value, code and score, including zero,
# negative codes, fractional values/scores and duplicate values with other codes.
valid_derivation_profiles <- data.frame(
  name = c("negative", "zero", "fraction", "positive", "same_value"),
  value = c(-2, 0, 1.5, 3, 3),
  code = c(-3, 0, 2, 7, 11),
  score = c(1.5, 0, 2.25, 4, 0.5),
  stringsAsFactors = FALSE
)

valid_derivation_expected <- list(
  SUM_CODE = matrix(c(
    -6, -3, -1, 4, 8,
    -3, 0, 2, 7, 11,
    -1, 2, 4, 9, 13,
    4, 7, 9, 14, 18,
    8, 11, 13, 18, 22
  ), nrow = 5, byrow = TRUE),
  SUM_SCORE = matrix(c(
    3, 1.5, 3.75, 5.5, 2,
    1.5, 0, 2.25, 4, 0.5,
    3.75, 2.25, 4.5, 6.25, 2.75,
    5.5, 4, 6.25, 8, 4.5,
    2, 0.5, 2.75, 4.5, 1
  ), nrow = 5, byrow = TRUE),
  CONCAT_CODE = matrix(c(
    "-3_-3", "-3_0", "-3_2", "-3_7", "-3_11",
    "0_-3", "0_0", "0_2", "0_7", "0_11",
    "2_-3", "2_0", "2_2", "2_7", "2_11",
    "7_-3", "7_0", "7_2", "7_7", "7_11",
    "11_-3", "11_0", "11_2", "11_7", "11_11"
  ), nrow = 5, byrow = TRUE),
  UNIQUE_VALUES = matrix(c(
    FALSE, TRUE, TRUE, TRUE, TRUE,
    TRUE, FALSE, TRUE, TRUE, TRUE,
    TRUE, TRUE, FALSE, TRUE, TRUE,
    TRUE, TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, TRUE, FALSE, FALSE
  ), nrow = 5, byrow = TRUE),
  # SOLVER expression: 2 * a - b (not a sum of codes or scores).
  SOLVER = matrix(c(
    -2, -4, -5.5, -7, -7,
    2, 0, -1.5, -3, -3,
    5, 3, 1.5, 0, 0,
    8, 6, 4.5, 3, 3,
    8, 6, 4.5, 3, 3
  ), nrow = 5, byrow = TRUE)
)

valid_derivation_code <- function(value, id = 41, score = 2.5) {
  rule <- if (is.null(value)) {
    list(method = "IS_NULL")
  } else if (is.logical(value)) {
    list(method = if (value) "IS_TRUE" else "IS_FALSE")
  } else {
    list(
      method = if (is.numeric(value)) "NUMERIC_MATCH" else "MATCH",
      parameters = list(as.character(value))
    )
  }
  list(id = id, score = score, type = "FULL_CREDIT",
       ruleSets = list(list(rules = list(rule))))
}

valid_derivation_coding <- function(id, method = "BASE", sources = list(),
                                    codes = list(), processing = list(),
                                    expression = "", alias = id) {
  list(
    id = id, alias = alias, sourceType = method,
    deriveSources = sources,
    sourceParameters = list(processing = processing,
                            solverExpression = expression),
    processing = list(), codeModel = "RULES_ONLY", codes = codes
  )
}

valid_derivation_response <- function(id, value, code, score) {
  list(id = id, status = "CODING_COMPLETE", value = value,
       code = code, score = score)
}

valid_derivation_source <- function(id, profile) {
  valid_derivation_response(id, profile$value, profile$code, profile$score)
}

valid_derivation_json <- function(x) {
  jsonlite::toJSON(x, auto_unbox = TRUE, null = "null", digits = NA)
}

# These helpers normalize only the public return format. The array API converts
# scalars to strings and arrays to [[[...]]], whereas the single-unit API uses
# jsonlite's normal data-frame simplification (e.g. mixed numbers/booleans).
valid_derivation_array_value <- function(value) {
  if (is.null(value) || length(value) == 0) return(NA_character_)
  if (is.list(value) || length(value) > 1) {
    return(paste0("[[[", paste(unlist(value), collapse = ";;;"), "]]]"))
  }
  if (is.logical(value)) return(tolower(as.character(value)))
  as.character(value)
}

valid_derivation_assert <- function(scheme, responses, expected, info,
                                    manual = NULL) {
  for (entry in c("single", "array")) {
    for (input in c("list", "json")) {
      encode <- if (input == "json") valid_derivation_json else identity
      if (entry == "single") {
        args <- list(coding_scheme = encode(scheme), responses = encode(responses))
        if (!is.null(manual)) args$manual <- encode(manual)
        actual <- do.call(code_responses, args)
        reference <- jsonlite::fromJSON(valid_derivation_json(expected))
      } else {
        unit <- list(unit_key = "valid-matrix", responses = responses)
        if (!is.null(manual)) unit$manual <- manual
        actual <- code_responses_array(encode(scheme), encode(list(unit)))
        expect_true(all(actual$unit_key == "valid-matrix"), info = info)
        reference <- jsonlite::fromJSON(valid_derivation_json(expected))
        reference$value <- vapply(expected, function(x) {
          valid_derivation_array_value(x$value)
        }, character(1))
      }
      fields <- c("id", "status", "value", "code", "score")
      for (field in setdiff(fields, names(actual))) actual[[field]] <- NA_real_
      for (field in setdiff(fields, names(reference))) reference[[field]] <- NA_real_
      actual <- as.data.frame(actual[order(actual$id), fields])
      reference <- as.data.frame(reference[order(reference$id), fields])
      rownames(actual) <- rownames(reference) <- NULL
      expect_equal(actual, reference, info = paste(info, entry, input))
    }
  }
}

test_that("valid code, score and value profiles cover every derivation pair", {
  for (method in names(valid_derivation_expected)) {
    expected_matrix <- valid_derivation_expected[[method]]
    expect_equal(dim(expected_matrix), c(5L, 5L))
    for (a in seq_len(5)) {
      for (b in seq_len(5)) {
        response_a <- valid_derivation_source("a", valid_derivation_profiles[a, ])
        response_b <- valid_derivation_source("b", valid_derivation_profiles[b, ])
        expected_value <- expected_matrix[a, b]
        # An exact rule gives the target code/score. A distinguishable fallback
        # detects a derivation that remains complete but computes the wrong value.
        derived <- valid_derivation_coding(
          "derived", method, list("a", "b"),
          codes = list(valid_derivation_code(expected_value),
                       list(id = 99, score = -1, type = "RESIDUAL_AUTO")),
          expression = "2 * (${a}) - (${b})"
        )
        scheme <- list(variableCodings = list(
          derived, valid_derivation_coding("b"), valid_derivation_coding("a")
        ))
        # Reverse input order deliberately: CONCAT_CODE follows deriveSources.
        valid_derivation_assert(
          scheme, list(response_b, response_a),
          list(response_b, response_a,
               valid_derivation_response("derived", expected_value, 41, 2.5)),
          paste(method, valid_derivation_profiles$name[a],
                valid_derivation_profiles$name[b])
        )
      }
    }
  }
})

test_that("sorted CONCAT_CODE uses string code order and preserves zeros", {
  expected <- matrix(c(
    "-3_-3", "-3_0", "-3_2", "-3_7", "-3_11",
    "-3_0", "0_0", "0_2", "0_7", "0_11",
    "-3_2", "0_2", "2_2", "2_7", "11_2",
    "-3_7", "0_7", "2_7", "7_7", "11_7",
    "-3_11", "0_11", "11_2", "11_7", "11_11"
  ), nrow = 5, byrow = TRUE)
  for (a in seq_len(5)) {
    for (b in seq_len(5)) {
      responses <- list(
        valid_derivation_source("a", valid_derivation_profiles[a, ]),
        valid_derivation_source("b", valid_derivation_profiles[b, ])
      )
      scheme <- list(variableCodings = list(
        valid_derivation_coding("a"), valid_derivation_coding("b"),
        valid_derivation_coding("derived", "CONCAT_CODE", list("a", "b"),
          codes = list(valid_derivation_code(expected[a, b])),
          processing = list("SORT"))
      ))
      valid_derivation_assert(scheme, responses,
        c(responses, list(valid_derivation_response("derived", expected[a, b], 41, 2.5))),
        paste("CONCAT_CODE SORT", a, b))
    }
  }
})

test_that("COPY_VALUE preserves ordinary scalar and array values", {
  cases <- list(-2, 1.5, "0", "false", "Gr\u00fc\u00dfe", TRUE,
                list("left", "right"), list(0, 2))
  for (i in seq_along(cases)) {
    value <- cases[[i]]
    code <- if (is.list(value)) {
      list(id = 41, score = 2.5, ruleSetOperatorAnd = TRUE,
           ruleSets = lapply(seq_along(value), function(pos) {
             rule <- valid_derivation_code(value[[pos]])$ruleSets[[1]]
             rule$valueArrayPos <- pos - 1L
             rule
           }))
    } else valid_derivation_code(value)
    scheme <- list(variableCodings = list(
      valid_derivation_coding("a"),
      valid_derivation_coding("derived", "COPY_VALUE", list("a"), list(code))
    ))
    source <- valid_derivation_response("a", value, 7, 4)
    valid_derivation_assert(scheme, list(source),
      list(source, valid_derivation_response("derived", value, 41, 2.5)),
      paste("COPY_VALUE", i))
  }
})

test_that("COPY_VALUE zero and false retain the documented 5.3.1 baseline", {
  # Characterization, not the desired copying semantics: 5.3.1 converts numeric
  # zero and FALSE to null. Keep this visible when comparing upstream releases.
  for (value in list(0, FALSE)) {
    scheme <- list(variableCodings = list(
      valid_derivation_coding("a"),
      valid_derivation_coding("derived", "COPY_VALUE", list("a"),
        list(valid_derivation_code(NULL, id = 43, score = 0)))
    ))
    source <- valid_derivation_response("a", value, 7, 4)
    valid_derivation_assert(scheme, list(source),
      list(source, valid_derivation_response("derived", NULL, 43, 0)),
      paste("COPY_VALUE known falsy behavior", value))
  }
})

test_that("MANUAL valid source pairs preserve automatic and supplied outcomes", {
  for (a in seq_len(5)) {
    for (b in seq_len(5)) {
      sources <- list(
        valid_derivation_source("a", valid_derivation_profiles[a, ]),
        valid_derivation_source("b", valid_derivation_profiles[b, ])
      )
      scheme <- list(variableCodings = list(
        valid_derivation_coding("a"), valid_derivation_coding("b"),
        valid_derivation_coding("derived", "MANUAL", list("a", "b"))
      ))
      # MANUAL marks the derivation complete but supplies no automatic code/score.
      expected <- c(sources, list(list(id = "derived", status = "CODING_COMPLETE",
                                      value = NULL)))
      valid_derivation_assert(scheme, sources, expected, paste("MANUAL", a, b))
    }
  }
  for (manual_code in list(c(0, 0), c(73, 3.5))) {
    supplied <- valid_derivation_response("derived", "rated", manual_code[1], manual_code[2])
    valid_derivation_assert(scheme, sources, c(sources, list(supplied)),
      paste("MANUAL supplied", manual_code[1]), manual = list(supplied))
  }
})

test_that("valid answers propagate through aliased multilevel derivations", {
  # Input values 2 and 5 produce codes 7/11 and scores 0.5/2. A first-level
  # score sum (2.5) is coded 21/4; the next code sum is 21 + 11 = 32.
  a <- valid_derivation_coding("technical_a", alias = "answer_a",
    codes = list(valid_derivation_code(2, 7, 0.5)))
  b <- valid_derivation_coding("technical_b", alias = "answer_b",
    codes = list(valid_derivation_code(5, 11, 2)))
  subtotal <- valid_derivation_coding("technical_subtotal", "SUM_SCORE",
    list("technical_a", "technical_b"),
    list(valid_derivation_code(2.5, 21, 4)), alias = "subtotal")
  total <- valid_derivation_coding("technical_total", "SUM_CODE",
    list("technical_subtotal", "technical_b"),
    list(valid_derivation_code(32, 31, 8)), alias = "total")
  solver <- valid_derivation_coding("technical_solver", "SOLVER",
    list("technical_a", "technical_b"),
    list(valid_derivation_code(13, 51, 6)),
    expression = "2 * ${answer_a} + ${answer_b} + sqrt(16)", alias = "formula")
  scheme <- list(variableCodings = list(total, solver, b, subtotal, a))
  responses <- list(list(id = "answer_b", status = "VALUE_CHANGED", value = 5),
                    list(id = "answer_a", status = "VALUE_CHANGED", value = 2))
  expected <- list(
    valid_derivation_response("answer_a", 2, 7, 0.5),
    valid_derivation_response("answer_b", 5, 11, 2),
    valid_derivation_response("subtotal", 2.5, 21, 4),
    valid_derivation_response("total", 32, 31, 8),
    valid_derivation_response("formula", 13, 51, 6)
  )
  valid_derivation_assert(scheme, responses, expected, "aliased multilevel chain")
})
