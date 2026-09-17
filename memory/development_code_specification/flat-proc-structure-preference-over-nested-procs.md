# Flat proc structure preference over nested procs

- **Category:** development_code_specification
- **Memory ID:** b7d43d81-cc76-4873-bb18-a5866a41464d
- **Keywords:** flat procs, no nesting, proc scope, global symbols, cross-scope references

## Content

In the Sangokushi 2 disassembly project, flat top-level .proc structures are preferred over nested procs. Parent .proc blocks should close before the next function begins (e.g., ProvinceOfficerRosterDispatch ends at $B2D6, then OfficerCardAnimStep starts), rather than enclosing subsequent functions as nested scopes. This simplifies cross-scope references (top-level proc names are global symbols requiring no Proc::Label syntax) and aligns with the project's established flat architecture style.
