# Semantic naming for local labels applying computed indices

- **Category:** development_code_specification
- **Memory ID:** 8b199117-fe91-4ca6-ba6c-17f3a4bfe511
- **Keywords:** local label, semantic naming, ApplyTierAdjust, table lookup, ca65
- **Usage scenarios:**
  - Renaming local labels inside .proc after conditional computation
  - Consistently naming convergence points that dispatch to table-driven logic
  - Reviewing or extending tier- or state-based adjustment routines

## Content

Local labels inside .proc blocks that mark the start of logic applying computed values (e.g., tier index) to data tables should use descriptive names prefixed with `@` and verb-initial form, such as `@ApplyTierAdjust`, clearly indicating the action and operand.
