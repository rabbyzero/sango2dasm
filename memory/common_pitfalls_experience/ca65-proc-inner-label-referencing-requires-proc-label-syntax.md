# ca65 .proc inner label referencing requires Proc::Label syntax

- **Category:** common_pitfalls_experience
- **Memory ID:** e550186b-0534-4cb7-bfcf-3df093db45ac
- **Keywords:** ca65, .proc, scope resolution, JSR, assembly
- **Usage scenarios:**
  - Referencing a label inside a .proc from outside fails with undefined symbol error
  - Migrating a routine to .proc breaks existing JSR calls

## Content

In ca65 assembly, when a label is defined inside a `.proc` block, external references must use the scope-resolution syntax `ProcName::Label`. Direct references (e.g., `JSR Label`) fail with "undefined symbol" errors. For example, after wrapping `MapProvinceDirtyMarkByZone` inside `.proc MapProvinceDirtyMark`, the caller must use `JSR MapProvinceDirtyMark::ByZone`. Inner labels should not repeat the proc name prefix (use `ByZone` instead of `MapProvinceDirtyMarkByZone`). (Source: Bash verify script error)
