# Cross-scope .proc reference convention

- **Category:** development_practice_specification
- **Memory ID:** 5cfeeffa-5533-4b91-9590-9458a5865381
- **Keywords:** cross-scope reference, Proc::Label, .proc, ca65 syntax
- **Usage scenarios:**
  - Calling secondary entries inside a .proc from external code
  - Referencing internal labels across procedure boundaries
  - Updating callers after converting routines to .proc blocks

## Content

Cross-scope references into a `.proc` must use the `Proc::Label` syntax (e.g., `JSR MapProvinceDirtyMark::ByZone`); inner labels must not repeat the proc name prefix, following the precedent of `ProvinceSelect_CheckSlot` and `AiTurnProcess::AiScanAdjacentOfficers`.
