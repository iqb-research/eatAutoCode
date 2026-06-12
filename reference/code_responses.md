# Automatically code responses with coding scheme

Automatically code responses with coding scheme

## Usage

``` r
code_responses(coding_scheme, responses, manual = "null")
```

## Arguments

- coding_scheme:

  List or character. Coding scheme of a unit from IQB Studio Lite.

- responses:

  List or character. Unit responses from IQB Testcenter.

- manual:

  List or character. Manual codes to potentially overwrite response
  data. Defaults to \`"null"\` (would be treated in the same way as
  \`NA\`).

## Value

A data frame.
