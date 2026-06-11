# eatAutoCode 0.5.0.9003 (2026-06-11)

* Updated the declared JavaScript autocoder dependency `@iqb/responses` from `^5.0.0` to `^5.1.0`. The lockfile already resolved `@iqb/responses` to `5.1.0`; this change makes the package manifest and startup message match the bundled dependency.
* Fixed `code_responses()` when optional `geometry_variables` are not supplied to the JavaScript wrapper.
* Rebuilt the bundled JavaScript autocoder in `inst/index.js`.
* Added this `NEWS.md` changelog.

# Historical Changes Since Initial Repository Creation

* Initial package scaffold, README, JavaScript build setup, and bundled autocoder integration were added in July 2024.
* Raw JSON string input support for coding schemes and responses was added in September 2024.
* The bundled `@iqb/responses` autocoder was updated repeatedly across the package history, including updates to the 3.x series, 5.0.0, and now 5.1.0.
* `get_dependency_tree()` was added to expose coding-scheme dependency information.
* Bulk and manual code insertion support was added, including behavior for manual overwrite of automatically prepared response data.
* `code_responses_array()` was added and later fixed to support mixed response value types and consistent character output in the `value` column.
* Unit-definition/dependency work was added, including dependency algorithm changes and performance fixes.
* Geometry variable support was added to the coding workflow, with ordering adjusted so manual codes can overwrite geometry-derived variables.
* Documentation was expanded, then migrated from a bookdown-style site to pkgdown.
* Package governance, maintainer metadata, logo/docs assets, and the license were updated.
