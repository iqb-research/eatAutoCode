# Integration cases for the opt-in partial-credit options introduced in 5.4.0.
# Keep these separate from the unchanged pre-update valid/status matrices.
partial_credit_options <- c(
  displayed = "TAKE_DISPLAYED_AS_ZERO_IF_PARTIAL",
  empty = "TAKE_EMPTY_AS_ZERO_IF_PARTIAL"
)

partial_credit_scheme <- function(method, options, source_ids = c("a", "b")) {
  match_code <- function(id, value, score) {
    list(
      id = id, type = "FULL_CREDIT", score = score,
      ruleSets = list(list(rules = list(list(
        method = if (method == "CONCAT_CODE") "MATCH" else "NUMERIC_MATCH",
        parameters = list(as.character(value))
      ))))
    )
  }
  values <- switch(method,
    SUM_CODE = c(2, 4, 0), SUM_SCORE = c(3, 6, 0),
    CONCAT_CODE = c("2_x", "2_2", "0_x")
  )
  base <- lapply(source_ids, function(id) list(
    id = id, alias = id, sourceType = "BASE", codeModel = "RULES_ONLY",
    codes = list(list(
      id = 2, type = "FULL_CREDIT", score = 3,
      ruleSets = list(list(rules = list(list(
        method = "NUMERIC_MATCH", parameters = list("8")
      ))))
    ))
  ))
  derived <- list(
    id = "derived", alias = "derived", sourceType = method,
    sourceParameters = list(processing = as.list(unname(options))),
    deriveSources = as.list(source_ids), codeModel = "RULES_ONLY",
    codes = list(
      match_code(70, values[1], 0.5),
      match_code(80, values[2], 1),
      match_code(90, values[3], 0),
      list(id = 99, type = "RESIDUAL_AUTO", score = -1)
    )
  )
  list(version = "3.0", variableCodings = c(base, list(derived)))
}

partial_credit_response <- function(id, status, value = NULL,
                                    code = NULL, score = NULL) {
  response <- list(id = id, status = status, value = value)
  if (!is.null(code)) response$code <- code
  if (!is.null(score)) response$score <- score
  response
}

partial_credit_run <- function(method, options, responses, api, input) {
  scheme <- partial_credit_scheme(method, options, vapply(responses, `[[`, "", "id"))
  if (api == "array") responses <- list(list(unit_key = "unit", responses = responses))
  if (input == "json") {
    scheme <- jsonlite::toJSON(scheme, auto_unbox = TRUE, null = "null")
    responses <- jsonlite::toJSON(responses, auto_unbox = TRUE, null = "null")
  }
  if (api == "array") {
    code_responses_array(scheme, responses)
  } else {
    code_responses(scheme, responses)
  }
}

partial_credit_expect <- function(result, status, value = NULL,
                                 code = NULL, score = NULL, info = "") {
  row <- result[result$id == "derived", , drop = FALSE]
  expect_equal(nrow(row), 1L, info = info)
  expect_equal(row$status, status, info = info)
  if (!is.null(value)) {
    expect_equal(as.character(row$value), as.character(value), info = info)
    expect_equal(row$code, code, info = info)
    expect_equal(row$score, score, info = info)
  } else {
    for (field in c("code", "score")) {
      expect_true(is.null(row[[field]]) || all(is.na(row[[field]])), info = info)
    }
  }
}

partial_credit_expect_sources <- function(result, responses, api,
                                          derived_value = NULL, info = "") {
  # Include the derived value when simplifying, since mixed columns may become
  # character vectors in the single-unit API. Only source rows are compared.
  reference <- jsonlite::fromJSON(jsonlite::toJSON(
    c(responses, list(list(id = "derived", value = derived_value))),
    auto_unbox = TRUE, null = "null"
  ))
  if (api == "array") {
    reference$value <- c(vapply(responses, function(response) {
      value <- response$value
      if (length(value) == 0L) return(NA_character_)
      if (is.logical(value)) return(tolower(as.character(value)))
      as.character(value)
    }, character(1)), NA_character_)
  }
  fields <- c("id", "status", "value", "code", "score")
  for (field in setdiff(fields, names(reference))) reference[[field]] <- NA_real_
  for (field in setdiff(fields, names(result))) result[[field]] <- NA_real_
  actual <- as.data.frame(result[result$id != "derived", fields])
  expected <- reference[reference$id != "derived", fields]
  rownames(actual) <- rownames(expected) <- NULL
  expect_equal(actual, expected, info = info)
}

test_that("partial-credit options are independent and preserve source statuses", {
  partials <- list(
    list(status = "DISPLAYED", value = NULL, option = "displayed"),
    list(status = "DISPLAYED", value = FALSE, option = "displayed"),
    list(status = "DISPLAYED", value = 0, option = "displayed"),
    list(status = "INVALID", value = NULL, option = "empty"),
    list(status = "INVALID", value = "", option = "empty"),
    list(status = "INVALID", value = list(), option = "empty")
  )
  option_sets <- list(character(), partial_credit_options[1],
                      partial_credit_options[2], partial_credit_options)
  for (method in c("SUM_CODE", "SUM_SCORE", "CONCAT_CODE")) {
    expected_value <- switch(method, SUM_CODE = 2, SUM_SCORE = 3, CONCAT_CODE = "2_x")
    for (partial in partials) for (options in option_sets) {
      for (api in c("single", "array")) for (input in c("list", "json")) {
        info <- paste(method, partial$status, partial$option, paste(options, collapse = ","), api, input)
        responses <- list(
          partial_credit_response("a", "CODING_COMPLETE", 8, 2, 3),
          partial_credit_response("b", partial$status, partial$value)
        )
        before <- responses
        result <- partial_credit_run(method, options, responses, api, input)
        enabled <- partial_credit_options[[partial$option]] %in% options
        if (enabled) {
          partial_credit_expect(result, "CODING_COMPLETE", expected_value, 70, 0.5, info)
        } else {
          partial_credit_expect(result, "INVALID", info = info)
        }
        expect_identical(responses, before, info = info)
        expect_equal(result$status[result$id == "b"], partial$status, info = info)
        expect_equal(result$code[result$id == "a"], 2, info = info)
        expect_equal(result$score[result$id == "a"], 3, info = info)
        expect_true(is.na(result$code[result$id == "b"]), info = info)
        partial_credit_expect_sources(result, responses, api,
          if (enabled) expected_value else NULL, info)
      }
    }
  }
})

test_that("partial credit keeps invalid values, pending coding and untouched tasks", {
  for (method in c("SUM_CODE", "SUM_SCORE", "CONCAT_CODE")) {
    cases <- list()
    for (value in list(FALSE, 0, "wrong", " ", list(NULL))) {
      cases[[length(cases) + 1L]] <- list(
        status = "INVALID",
        responses = list(
          partial_credit_response("a", "CODING_COMPLETE", 8, 2, 3),
          partial_credit_response("b", "INVALID", value)
        )
      )
    }
    for (status in c("DISPLAYED", "INVALID")) {
      cases[[length(cases) + 1L]] <- list(
        status = status,
        responses = list(partial_credit_response("a", status), partial_credit_response("b", status))
      )
    }
    for (status in c("CODING_INCOMPLETE", "DERIVE_PENDING")) {
      cases[[length(cases) + 1L]] <- list(
        status = "DERIVE_PENDING",
        responses = list(
          partial_credit_response("a", status, 8),
          partial_credit_response("b", "DISPLAYED")
        )
      )
    }
    cases[[length(cases) + 1L]] <- list(
      status = "INVALID",
      responses = list(
        partial_credit_response("a", "DISPLAYED"),
        partial_credit_response("b", "INVALID", "")
      )
    )
    cases[[length(cases) + 1L]] <- list(
      status = "DERIVE_PENDING",
      responses = list(
        partial_credit_response("a", "CODING_COMPLETE", 8, 2, 3),
        partial_credit_response("b", "DISPLAYED"),
        partial_credit_response("c", "CODING_INCOMPLETE", 8)
      )
    )
    for (i in seq_along(cases)) {
      for (api in c("single", "array")) for (input in c("list", "json")) {
        result <- partial_credit_run(method, partial_credit_options, cases[[i]]$responses, api, input)
        partial_credit_expect(result, cases[[i]]$status, info = paste(method, i, api, input))
      }
    }
  }
})

test_that("empty values normalized by base coding work through both R input formats", {
  for (method in c("SUM_CODE", "SUM_SCORE", "CONCAT_CODE")) {
    expected_value <- switch(method, SUM_CODE = 2, SUM_SCORE = 3, CONCAT_CODE = "2_x")
    for (value in list("", list())) {
      for (api in c("single", "array")) for (input in c("list", "json")) {
        result <- partial_credit_run(method, partial_credit_options, list(
          partial_credit_response("a", "VALUE_CHANGED", 8),
          partial_credit_response("b", "VALUE_CHANGED", value)
        ), api, input)
        partial_credit_expect(result, "CODING_COMPLETE", expected_value, 70, 0.5, paste(method, api, input))
        expect_equal(result$status[result$id == "b"], "INVALID")
      }
    }
  }
})

test_that("null answers awaiting coding remain pending in both input formats", {
  # Unlike an already INVALID null, a VALUE_CHANGED null is not an empty
  # invalid response here: the base rule cannot code it and leaves it pending.
  for (method in c("SUM_CODE", "SUM_SCORE", "CONCAT_CODE")) {
    for (api in c("single", "array")) for (input in c("list", "json")) {
      result <- partial_credit_run(method, partial_credit_options, list(
        partial_credit_response("a", "VALUE_CHANGED", 8),
        partial_credit_response("b", "VALUE_CHANGED", NULL)
      ), api, input)
      partial_credit_expect(result, "DERIVE_PENDING", info = paste(method, api, input))
      expect_equal(result$status[result$id == "b"], "CODING_INCOMPLETE")
    }
  }
})

test_that("data-frame response inputs preserve null list-column values", {
  scheme <- partial_credit_scheme("SUM_CODE", partial_credit_options)
  for (status in c("INVALID", "VALUE_CHANGED")) {
    responses <- data.frame(id = c("a", "b"),
      status = c("VALUE_CHANGED", status), stringsAsFactors = FALSE)
    responses$value <- list(8, NULL)
    for (api in c("single", "array")) {
      result <- if (api == "single") code_responses(scheme, responses) else
        code_responses_array(scheme, list(list(unit_key = "unit", responses = responses)))
      if (status == "INVALID") {
        partial_credit_expect(result, "CODING_COMPLETE", 2, 70, 0.5, api)
      } else {
        partial_credit_expect(result, "DERIVE_PENDING", info = api)
      }
      expect_true(is.na(result$value[result$id == "b"]), info = api)
    }
  }
})

test_that("a coded zero remains distinguishable from an untouched contribution", {
  for (api in c("single", "array")) for (input in c("list", "json")) {
    zero <- partial_credit_response("a", "CODING_COMPLETE", 0, 0, 0)
    partial <- partial_credit_run("CONCAT_CODE", partial_credit_options, list(
      zero, partial_credit_response("b", "DISPLAYED")
    ), api, input)
    partial_credit_expect(partial, "CODING_COMPLETE", "0_x", 90, 0, paste(api, input))
    full <- partial_credit_run("CONCAT_CODE", partial_credit_options, list(
      zero, partial_credit_response("b", "CODING_COMPLETE", 0, 0, 0)
    ), api, input)
    partial_credit_expect(full, "CODING_COMPLETE", "0_0", 99, -1, paste(api, input))
  }
})
