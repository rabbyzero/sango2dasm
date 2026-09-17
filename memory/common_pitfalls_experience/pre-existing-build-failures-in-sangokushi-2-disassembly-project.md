# Pre-existing build failures in Sangokushi 2 disassembly project

- **Category:** common_pitfalls_experience
- **Memory ID:** 85563596-641a-4d9f-bb45-ff063c4777a5
- **Keywords:** pre-existing build failures, duplicate symbols, per-bank verification, cross-bank conflicts

## Content

Bug class: Pre-existing build failures mistaken as change-induced errors
Root cause: The project has known duplicate-symbol errors across multiple banks (e.g., Loc_D601/Loc_D93D between prg_1b_1c and prg_19_1a; within prg_0a_0b) that exist in HEAD versions; these are unrelated to new edits but cause full `make` to fail.
Fix pattern: Verify whether the build failure exists on HEAD before assuming it's caused by current changes; use per-bank verification harnesses (verify_*.py) which pass even when full build fails due to pre-existing issues.
Reusable lesson: Don't assume full `make` failures indicate your changes are broken because the project has pre-existing cross-bank duplicate symbols; instead verify with per-bank harnesses that compare only the modified bank(s) against ROM slices. Applies when modifying any single bank file in this disassembly project; does not apply to adding new cross-bank dependencies or refactoring shared symbols.
