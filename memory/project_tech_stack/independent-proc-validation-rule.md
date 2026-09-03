# Independent Proc Validation Rule

- **Category:** project_tech_stack
- **Memory ID:** 090d4481-e810-47b0-b454-f91b0eeac302
- **Keywords:** independent proc, control flow, 6502 assembly
- **Usage scenarios:**
  - Deciding whether to merge or split procedures sharing an endpoint

## Content

Procedures that appear to share a common endpoint should be validated for true control flow dependency. When analysis shows no fall-through execution path, each proc (CombatCalc_MoraleCalc, CombatCalc_DefenseCalc, etc.) must be split into independent `.proc` blocks with proper scope and variable declarations.
