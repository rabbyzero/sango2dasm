# ca65 @-prefixed local labels must be placed inline at target instructions

- **Category:** development_code_specification
- **Memory ID:** 152208ab-78ea-4d78-937e-1fdb66ee91a1
- **Keywords:** @-prefix, inline labels, ca65, cheap local labels, label scoping
- **Usage scenarios:**
  - Writing or editing ca65 assembly code with local labels
  - Reviewing pull requests for correct label syntax and placement
  - Onboarding new contributors on proper label declaration style

## Content

All `@`-prefixed labels must be placed inline at their target instruction (e.g., `@ScanSlots:` before `INY`), not declared later via `@label = $ADDR` equates. This ensures labels are scoped correctly and avoids ambiguity in ca65 assembly.
