# eatAutoCode

The goal of eatAutoCode is to code responses from IQB Testcenter.

## Package governance

This package was originally authored and created by Philipp Franikowski.
**Current package maintenance** is provided by Karoline A. Sachse,
Kristoph Schumann, and Jakob Schaefer.

## Installation

You can install the development version of eatAutoCode from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("iqb-research/eatAutoCode")
```

## Update

If you cloned the repository and want to update the version of the auto
coder, follow this guide.

First, all packages need to be installed:

``` r
packer::npm_install()
```

Second, the auto coder needs to be updated:

``` r
packer::npm_install("@iqb/responses")
```

That’s it. To be sure that everything still works, please load the
package (`devtools::load_all(".")`) and run all of the tests
([`devtools::test()`](https://devtools.r-lib.org/reference/test.html))
before pulling.
