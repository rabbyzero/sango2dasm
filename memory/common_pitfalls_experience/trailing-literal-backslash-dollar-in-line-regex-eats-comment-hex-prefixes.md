# Trailing literal backslash-dollar in line regex eats comment hex prefixes

- **Category:** common_pitfalls_experience
- **Memory ID:** 9b9da25f-3365-4df6-b430-e3274e52929e
- **Keywords:** regex literal dollar, comment corruption, line rewrite, git restore, verifier blind spot

## Content

## Bug class
Bulk line rewrite via regex silently corrupted comment text (dropped `$` hex prefixes) while the byte-parity verifier still passed, because comments do not affect assembled bytes.

## Root cause
A line-rewrite pattern like `^  JSR \$D5BD *(; .*)\$` was built with a trailing literal `\$` instead of an end-of-line anchor. In regex `\$` matches a literal dollar character, so greedy `(.*)` backtracked to the LAST `$` in the line, consumed it as the operand, and truncated the captured comment before it - e.g. `; $A570: 20 BD D5` became `; A570: 20 BD D5`.

## Fix pattern
When capturing the tail of a line, anchor with `$` (end of line), never a literal `\$`: use `^PATTERN *(; .*)$`. Even better, reconstruct rewritten lines from the pristine `git show HEAD:<file>` copy: extract the original comment per call site, then rebuild `mnemonic.ljust(41) + '; ' + original_comment`. After any bulk comment rewrite, diff a few sample lines against git before trusting the verifier.

## Reusable lesson
Byte-parity verification cannot catch comment corruption; any transformation that touches text outside the byte stream needs its own textual spot-check (grep the rewritten lines for the expected `$` hex prefixes, or diff against git HEAD).
