# Nested proc coverage by call-graph analysis

- **Category:** development_practice_specification
- **Memory ID:** 146ccffb-3c2a-450e-aea1-7ab97f38b5c5
- **Keywords:** nested proc, call graph, .proc, .endproc, caller analysis

## Content

When analyzing disassembly, if proc B, proc C, etc. follow proc A and are only called by proc A (or by each other within the same group), they are considered nested functions of proc A. In this case, proc A's .proc/.endproc block should cover these nested functions (B, C, ...) as well, not just A's own code. This is determined by call-graph analysis: a proc qualifies as nested if its only callers are proc A or other procs already nested under A. Do NOT create separate top-level .proc blocks for these nested procs; instead, place their code inside A's .proc scope.
