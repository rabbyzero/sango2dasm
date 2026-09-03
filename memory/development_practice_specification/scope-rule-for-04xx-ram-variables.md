# Scope Rule for $04xx RAM Variables

- **Category:** development_practice_specification
- **Memory ID:** c2ce8337-f251-4d3f-a1ae-5cba6bd246b4
- **Keywords:** RAM variables, scope, global, local, procedure
- **Usage scenarios:**
  - Naming RAM equates in prg_17_18.asm

## Content

Global RAM address definitions in prg_17_18.asm should only be used for variables shared across multiple procedures. Variables used within a single procedure must be defined locally within that procedure to prevent namespace pollution and ensure scope clarity.
