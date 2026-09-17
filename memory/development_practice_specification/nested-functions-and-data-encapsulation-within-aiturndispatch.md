# Nested functions and data encapsulation within AiAction_DomesticTurn

- **Category:** development_practice_specification
- **Memory ID:** be85a01c-3b7e-4dc1-8f85-cdedebc02291
- **Keywords:** nested procedures, encapsulation, AiAction_DomesticTurn, local data, scope awareness
- **Usage scenarios:**
  - Migrating or duplicating logic from AiAction_DomesticTurn to another context
  - Auditing symbol visibility and cross-procedure references
  - Applying scope-aware renaming or linting tools to prg_0a_0b.asm

## Content

When working inside `AiAction_DomesticTurn` (renamed from `AiTurnDispatch`) in `prg_0a_0b.asm`, always account for all nested functions (e.g., `@AiAction_TownDevelopment`) and locally scoped data tables (e.g., `@AiActionParamTable`) as inseparable parts of the same logical and physical procedure unit. Their definitions, references, and lifetime must remain fully contained within the `$B49C-$C50D` address range.
