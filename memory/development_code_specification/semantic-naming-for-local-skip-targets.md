# Semantic naming for local skip targets

- **Category:** development_code_specification
- **Memory ID:** 304cd88e-df25-4d3f-b4e6-8b3d0cb62c8b
- **Keywords:** local label, skip target, verb-initial naming, @ prefix, semantic naming
- **Usage scenarios:**
  - Renaming raw address labels to meaningful local labels
  - Adding new skip targets in loop or conditional branches
  - Reviewing or refactoring branch target labels for clarity

## Content

Local labels used as skip targets inside loop or conditional logic (e.g., `LB5C8`) must use descriptive, verb-initial names prefixed with `@`, such as `@FindBestSkip`, to clearly indicate their purpose and maintain consistency with existing local label conventions.
