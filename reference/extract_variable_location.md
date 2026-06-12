# Extract variable locations from unit definition

Extract variable locations from unit definition

## Usage

``` r
extract_variable_location(
  units,
  collapse = ";;;",
  wrap_start = "[[[",
  wrap_end = "]]]",
  missing = "___MISSING___"
)
```

## Arguments

- units:

  Tibble. Must contain a column \`definition\` that contains unit
  definitions. Please note, that it is recommended to not extract more
  than 20 unit definitions at a time as the call is memory-consuming.

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

A data frame.
