# Semantic naming convention for common exit routines

- **Category:** development_code_specification
- **Memory ID:** f7908f5f-e89f-4545-9c52-e538e59546ca
- **Keywords:** exit routine, semantic naming, AiAction_EndTurn, trampoline naming, @ExitTo
- **Usage scenarios:**
  - Renaming shared exit points across bank assembly files
  - Updating trampolines and local jump targets consistently
  - Extending the `@ExitToXXXX` pattern with domain-meaningful names

## Content

Common exit routines (e.g., $BEC7) are renamed to descriptive, action-oriented names like `AiAction_EndTurn`, avoiding generic or bank-prefixed labels. Corresponding trampolines (e.g., `JumpToBEC7`) become concise verbs like `EndTurn`, and local trampoline labels follow the `@ExitTo` prefix with the new semantic name (e.g., `@ExitToEndTurn`). This naming reflects domain behavior (e.g., AI turn termination) and aligns with existing local label conventions.
