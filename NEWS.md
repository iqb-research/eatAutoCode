# eatAutoCode 0.5.0.9005 (2026-07-13)

* Updated the bundled JavaScript autocoder dependency `@iqb/responses` from `^5.1.0` to `^5.2.2` and aligned the `@iqbspecs/response` type dependency with the 2.0.0 response specification used by the autocoder.
* Updated the derivation status-crossing regression tests for the `@iqb/responses` 5.2.2 `SOLVER` handling of `NO_CODING` base-source responses.
* Added status-crossing regression tests for all derivation methods handled by the bundled `@iqb/responses` 5.1.0 autocoder.
* Added a pkgdown article documenting the 5.1.0 status matrices for all derivation methods and linked it from the pkgdown articles navigation.

# eatAutoCode 0.5.0.9004 (2026-07-13)

* Added a complete `SUM_SCORE` status-crossing regression test for all 144 combinations of the 12 source statuses handled by the bundled `@iqb/responses` 5.1.0 autocoder.
* Added a pkgdown article documenting the `SUM_SCORE` status matrix and linked it from the pkgdown articles navigation.

# eatAutoCode 0.5.0.9003 (2026-06-11)

* Updated the declared JavaScript autocoder dependency `@iqb/responses` from `^5.0.0` to `^5.1.0`. The lockfile already resolved `@iqb/responses` to `5.1.0`; this change makes the package manifest and startup message match the bundled dependency.
* Fixed `code_responses()` when optional `geometry_variables` are not supplied to the JavaScript wrapper.
* Rebuilt the bundled JavaScript autocoder in `inst/index.js`.
* Added a GitHub Actions workflow for R CMD check on pull requests and pushes to `main`.
* Added a GitHub Actions workflow to build the pkgdown site and deploy it to GitHub Pages.
* Updated the npm lockfile to resolve the `fast-uri` build-toolchain audit finding.
* Added this `NEWS.md` changelog.
* Historical changes since initial repository creation include: initial package scaffold, README, JavaScript build setup, raw JSON string input support, repeated autocoder updates, `get_dependency_tree()`, manual code insertion, `code_responses_array()`, unit-definition/dependency work, geometry variable support, documentation migration to pkgdown, package governance updates, maintainer metadata updates, logo/docs assets, and the PolyForm Noncommercial license update.
