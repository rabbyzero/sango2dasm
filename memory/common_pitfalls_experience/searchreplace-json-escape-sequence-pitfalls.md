# SearchReplace JSON escape sequence pitfalls

- **Category:** common_pitfalls_experience
- **Memory ID:** 484c373b-3e57-4703-8dbc-0b6dfc846521
- **Keywords:** SearchReplace, JSON escape, silent failure, batch rename, verification

## Content

Bug class: SearchReplace batch operation silent failure due to JSON escape sequence corruption
Root cause: When constructing SearchReplace operations in JSON format, literal backslash-r (\r) escape sequences in string values (e.g., "@\rSliderScale10") are interpreted as carriage return characters by the JSON parser, causing the replacement pattern to mismatch the actual file content. This results in some entries being silently skipped while others succeed.
Fix pattern: Always verify that all intended replacements were applied by grepping for the old names after the batch operation; if any remain, re-apply the failed entry individually with properly escaped strings or direct character literals.
Reusable lesson: Don't assume all SearchReplace entries in a batch succeeded without verification because malformed JSON escape sequences can cause silent skips; must grep for remaining old names and re-apply failed entries individually. Applies when performing multi-entry batch renames via SearchReplace with JSON parameters; does not apply to single-entry replacements or non-JSON tool invocations.
