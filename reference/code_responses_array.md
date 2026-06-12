# Automatically code responses with coding scheme

Automatically code responses with coding scheme

## Usage

``` r
code_responses_array(
  coding_scheme,
  responses,
  collapse = ";;;",
  wrap_start = "[[[",
  wrap_end = "]]]",
  missing = "___MISSING___"
)
```

## Arguments

- coding_scheme:

  List. Coding scheme of a unit from IQB Studio Lite.

- responses:

  List. Unit responses from IQB Testcenter.

- collapse:

  Character. List values will be concatenated with this character.
  Defaults to \`";;;"\`.

- wrap_start:

  Character. List values will be wrapped with this character. Defaults
  to \`"\[\[\["\`.

- wrap_end:

  Character. List values will be wrapped with this character. Defaults
  to \`"´\]\]\]"\`.

- missing:

  Character. Placeholder for missing values. Will be transformed to
  \`NA\`. Defaults to \`"\_\_\_MISSING\_\_\_"\`.

## Value

A data frame. Please not that the value column is coerced to a
character, i.e., list entries of \`c("a", "b")\` are concatenated to
\`\[\[\[a;;;b\]\]\]\` (e.g., for drag-and-drop or from marker
variables).
