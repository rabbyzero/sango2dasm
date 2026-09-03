# Semantic naming for control flow labels

- **Category:** development_code_specification
- **Memory ID:** 6c354ee1-5f84-44fd-978e-871b64266810
- **Keywords:** semantic labels, control flow, @-prefix, assembly naming
- **Usage scenarios:**
  - Refactoring assembly procedures with raw address labels
  - Creating new loops or conditional branches in assembly code
  - Reviewing disassembled control flow for readability improvements

## Content

Control flow labels in assembly should use `@`-prefixed semantic names (e.g., `@LoopStart`, `@ExitEarly`, `@BranchTrue`) that describe their functional role instead of raw address-based names like `@D524`. The name should reflect the logic context such as loop boundaries, condition outcomes, or state transitions.
