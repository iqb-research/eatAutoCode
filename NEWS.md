# eatAutoCode 0.5.0.9003 (2026-06-11)

* Updated the declared JavaScript autocoder dependency `@iqb/responses` from `^5.0.0` to `^5.1.0`. The lockfile already resolved `@iqb/responses` to `5.1.0`; this change makes the package manifest and startup message match the bundled dependency.
* Fixed `code_responses()` when optional `geometry_variables` are not supplied to the JavaScript wrapper.
* Rebuilt the bundled JavaScript autocoder in `inst/index.js`.
* Added a GitHub Actions workflow for R CMD check on pull requests and pushes to `main`.
* Updated the npm lockfile to resolve the `fast-uri` build-toolchain audit finding.
* Added this `NEWS.md` changelog.
* Historical changes since initial repository creation include: initial package scaffold, README, JavaScript build setup, raw JSON string input support, repeated autocoder updates, `get_dependency_tree()`, manual code insertion, `code_responses_array()`, unit-definition/dependency work, geometry variable support, documentation migration to pkgdown, package governance updates, maintainer metadata updates, logo/docs assets, and the PolyForm Noncommercial license update.
