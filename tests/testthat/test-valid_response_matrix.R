# Fixed, independently specified examples for the 5.3.1 -> 5.5.0 comparison.
# Every response is a regular VALUE_CHANGED answer, including valid no-credit
# answers. The expected codes/scores are deliberately different from the values.
valid_response_json <- function(x) {
  as.character(jsonlite::toJSON(x, auto_unbox = TRUE, null = "null"))
}

valid_response_rule <- function(method, parameters = character(), ...) {
  c(list(method = method, parameters = as.list(parameters)), list(...))
}

valid_response_case <- function(name, value, rule, matches,
                                processing = character(), array_pos = NULL,
                                fragmenting = "", array_value = NULL) {
  rule_set <- list(rules = list(rule))
  if (!is.null(array_pos)) rule_set$valueArrayPos <- array_pos
  if (is.null(array_value)) {
    array_value <- if (is.logical(value)) tolower(as.character(value)) else
      as.character(value)
  }
  list(
    name = name,
    value = value,
    expected_value = unlist(value, use.names = FALSE),
    array_value = array_value,
    coding = list(
      id = "answer", alias = "answer", sourceType = "BASE",
      processing = as.list(processing), fragmenting = fragmenting,
      codeModel = "RULES_ONLY",
      codes = list(
        list(id = 17, score = 2.5, type = "FULL_CREDIT",
             ruleSets = list(rule_set)),
        list(id = 0, score = 0, type = "RESIDUAL_AUTO")
      )
    ),
    code = if (matches) 17 else 0,
    score = if (matches) 2.5 else 0
  )
}

valid_response_matrix <- function() {
  cases <- list()
  add <- function(x) cases[[length(cases) + 1L]] <<- x

  # Boundaries have explicit truth tables: NUMERIC_RANGE is (-1, 1],
  # NUMERIC_FULL_RANGE is [-1, 1]. Zero is an ordinary scored answer.
  numeric_rules <- list(
    list("NUMERIC_MATCH", "0", c(FALSE, FALSE, TRUE, FALSE, FALSE)),
    list("NUMERIC_LESS_THAN", "0", c(TRUE, TRUE, FALSE, FALSE, FALSE)),
    list("NUMERIC_MAX", "0", c(TRUE, TRUE, TRUE, FALSE, FALSE)),
    list("NUMERIC_MORE_THAN", "0", c(FALSE, FALSE, FALSE, TRUE, TRUE)),
    list("NUMERIC_MIN", "0", c(FALSE, FALSE, TRUE, TRUE, TRUE)),
    list("NUMERIC_RANGE", c("-1", "1"), c(FALSE, FALSE, TRUE, TRUE, FALSE)),
    list("NUMERIC_FULL_RANGE", c("-1", "1"), c(FALSE, TRUE, TRUE, TRUE, FALSE))
  )
  numeric_values <- c(-2, -1, 0, 1, 2)
  for (row in numeric_rules) {
    for (i in seq_along(numeric_values)) {
      add(valid_response_case(
        paste(row[[1]], numeric_values[i], sep = "/"), numeric_values[i],
        valid_response_rule(row[[1]], row[[2]]), row[[3]][i]
      ))
    }
  }

  numeric_spellings <- list(-1.25, "-1.25", "-1,25", " -1,25 ", 0, "0", 1.25)
  for (i in seq_along(numeric_spellings)) {
    add(valid_response_case(
      paste0("numeric_decimal/", i), numeric_spellings[[i]],
      valid_response_rule("NUMERIC_MATCH", "-1.25"),
      c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)[i]
    ))
  }

  boolean_values <- list(TRUE, FALSE, 1, 0, "true", "false", "1", "0")
  true_matches <- c(TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE)
  for (method in c("IS_TRUE", "IS_FALSE")) {
    for (i in seq_along(boolean_values)) {
      add(valid_response_case(
        paste(method, i, sep = "/"), boolean_values[[i]],
        valid_response_rule(method),
        if (method == "IS_TRUE") true_matches[i] else !true_matches[i]
      ))
    }
  }

  strings <- list(
    list("exact", "Berlin", "Berlin", TRUE, character()),
    list("case_sensitive", "berlin", "Berlin", FALSE, character()),
    list("ignore_case", "BERLIN", "Berlin", TRUE, "IGNORE_CASE"),
    list("space_sensitive", "a b", "ab", FALSE, character()),
    list("ignore_all_spaces", " a\t b ", "ab", TRUE, "IGNORE_ALL_SPACES"),
    list("normalize_spaces", "  a\t b  ", "a b", TRUE, "IGNORE_DISPENSABLE_SPACES"),
    list("keep_required_space", "ab", "a b", FALSE, "IGNORE_DISPENSABLE_SPACES"),
    list("combined_processing", " A\t B ", "ab", TRUE,
         c("IGNORE_CASE", "IGNORE_ALL_SPACES")),
    list("unicode", "\u00c4rger", "\u00c4rger", TRUE, character()),
    list("multiple_alternatives", "blue", "red\nblue", TRUE, character())
  )
  for (row in strings) {
    add(valid_response_case(
      paste0("string/", row[[1]]), row[[2]],
      valid_response_rule("MATCH", row[[3]]), row[[4]], processing = row[[5]]
    ))
  }

  regexes <- list(
    list("unicode", "^\u00c4pfel$", "\u00c4pfel", "Apfel"),
    list("lookahead", "^a(?=b)b$", "ab", "ac"),
    list("lookbehind", "(?<=a)b$", "ab", "cb"),
    list("backreference", "^(ab)\\1$", "abab", "abac"),
    list("unicode_escape", "^\\u00e4$", "\u00e4", "a"),
    list("hex_escape", "^\\x41$", "A", "B")
  )
  for (row in regexes) {
    for (i in 3:4) {
      add(valid_response_case(
        paste("regex", row[[1]], i - 2L, sep = "/"), row[[i]],
        valid_response_rule("MATCH_REGEX", row[[2]]), i == 3L
      ))
    }
  }
  add(valid_response_case(
    "regex/ignore_case", "AB", valid_response_rule("MATCH_REGEX", "^ab$"),
    TRUE, processing = "IGNORE_CASE"
  ))

  arrays <- list(
    list("position_first", list("B", "A"), "MATCH", "B", 0, TRUE, "[[[B;;;A]]]"),
    list("position_second", list("B", "A"), "MATCH", "B", 1, FALSE, "[[[B;;;A]]]"),
    list("any_open", list("B", "A"), "MATCH", "A", "ANY_OPEN", TRUE, "[[[B;;;A]]]"),
    list("all_match", list("A", "A"), "MATCH", "A", "ANY", TRUE, "[[[A;;;A]]]"),
    list("not_all_match", list("B", "A"), "MATCH", "A", "ANY", FALSE, "[[[B;;;A]]]"),
    list("sum", list(-2, 0, 3.5), "NUMERIC_MATCH", "1.5", "SUM", TRUE, "[[[-2;;;0;;;3.5]]]"),
    list("length", list(-2, 0, 3.5), "NUMERIC_MATCH", "3", "LENGTH", TRUE, "[[[-2;;;0;;;3.5]]]"),
    list("singleton", list(0), "NUMERIC_MATCH", "0", 0, TRUE, "[[[0]]]")
  )
  for (row in arrays) {
    add(valid_response_case(
      paste0("array/", row[[1]]), row[[2]],
      valid_response_rule(row[[3]], row[[4]]), row[[6]],
      array_pos = row[[5]], array_value = row[[7]]
    ))
  }
  add(valid_response_case(
    "array/sort_for_matching_only", list("B", "A"),
    valid_response_rule("MATCH", "A"), TRUE, processing = "SORT_ARRAY",
    array_pos = 0, array_value = "[[[B;;;A]]]"
  ))

  for (row in list(list(0, "NUMERIC_MATCH", "2", TRUE),
                   list(1, "MATCH", "AB", TRUE),
                   list(1, "MATCH", "AC", FALSE))) {
    add(valid_response_case(
      paste("fragment", row[[1]], row[[3]], sep = "/"), "2-AB",
      valid_response_rule(row[[2]], row[[3]], fragment = row[[1]]), row[[4]],
      fragmenting = "^(\\d+)-(\\w+)$"
    ))
  }

  # Rule-level AND/OR and code-level AND/OR are independent choices.
  for (rule_and in c(FALSE, TRUE)) {
    for (value in c(-1, 0, 1, 3)) {
      fixture <- valid_response_case(
        paste("rule_logic", rule_and, value, sep = "/"), value,
        valid_response_rule("NUMERIC_MIN", "0"),
        if (rule_and) value %in% c(0, 1) else TRUE
      )
      fixture$coding$codes[[1]]$ruleSets[[1]] <- list(
        ruleOperatorAnd = rule_and,
        rules = list(valid_response_rule("NUMERIC_MIN", "0"),
                     valid_response_rule("NUMERIC_LESS_THAN", "2"))
      )
      add(fixture)
    }
  }
  for (sets_and in c(FALSE, TRUE)) {
    for (value in c(-1, 0, 1, 3)) {
      fixture <- valid_response_case(
        paste("ruleset_logic", sets_and, value, sep = "/"), value,
        valid_response_rule("NUMERIC_MIN", "0"),
        if (sets_and) value %in% c(0, 1) else TRUE
      )
      fixture$coding$codes[[1]]$ruleSetOperatorAnd <- sets_and
      fixture$coding$codes[[1]]$ruleSets <- list(
        list(rules = list(valid_response_rule("NUMERIC_MIN", "0"))),
        list(rules = list(valid_response_rule("NUMERIC_LESS_THAN", "2")))
      )
      add(fixture)
    }
  }

  # Overlapping rules must pick the first matching code; scores are not codes.
  for (row in list(list(-1, 91, -0.5), list(0, 0, 0),
                   list(1, 23, 0.5), list(2, 47, 3))) {
    fixture <- valid_response_case(
      paste0("credit_levels/", row[[1]]), row[[1]],
      valid_response_rule("NUMERIC_MATCH", "1"), TRUE
    )
    fixture$coding$codes <- list(
      list(id = 91, score = -0.5, type = "NO_CREDIT",
           ruleSets = list(list(rules = list(valid_response_rule("NUMERIC_MATCH", "-1"))))),
      list(id = 23, score = 0.5, type = "PARTIAL_CREDIT",
           ruleSets = list(list(rules = list(valid_response_rule("NUMERIC_MATCH", "1"))))),
      list(id = 47, score = 3, type = "FULL_CREDIT",
           ruleSets = list(list(rules = list(valid_response_rule("NUMERIC_MIN", "1"))))),
      list(id = 0, score = 0, type = "RESIDUAL_AUTO")
    )
    fixture$code <- row[[2]]
    fixture$score <- row[[3]]
    add(fixture)
  }
  cases
}

for (entry_point in c("single", "array")) {
  for (input_format in c("list", "json")) {
    test_that(paste("valid-answer matrix preserves values, codes and scores:",
                    entry_point, input_format), {
      fixtures <- valid_response_matrix()
      for (fixture in fixtures) {
        scheme <- list(version = "3.0", variableCodings = list(fixture$coding))
        responses <- list(list(id = "answer", status = "VALUE_CHANGED",
                               value = fixture$value, key = "response-key"))
        if (entry_point == "array") {
          responses <- list(list(unit_key = "unit-1", responses = responses))
        }
        if (input_format == "json") {
          scheme <- valid_response_json(scheme)
          responses <- valid_response_json(responses)
        }
        actual <- if (entry_point == "array") {
          code_responses_array(scheme, responses)
        } else {
          code_responses(scheme, responses)
        }
        info <- paste(entry_point, input_format, fixture$name, sep = " / ")
        expected_value <- if (entry_point == "array") fixture$array_value else
          fixture$expected_value
        expect_equal(nrow(actual), 1L, info = info)
        expect_identical(actual$id, "answer", info = info)
        expect_identical(actual$status, "CODING_COMPLETE", info = info)
        expect_equal(actual$value[[1]], expected_value, info = info)
        expect_equal(actual$code, fixture$code, info = info)
        expect_equal(actual$score, fixture$score, info = info)
        expect_identical(actual$key, "response-key", info = info)
        if (entry_point == "array") {
          expect_identical(actual$unit_key, "unit-1", info = info)
        }
      }
    })
  }
}
