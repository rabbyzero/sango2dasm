# Symbolic-reference conversion pitfalls: label drift, @-locals scope, byte-row duplication

- **Category:** common_pitfalls_experience
- **Memory ID:** 5e472fed-3b2d-4502-87a8-51a35c3c90b3
- **Keywords:** symbolic reference conversion, label drift, @-locals scope, byte-row duplication, SearchReplace pitfalls

## Content

Content of this memory: pitfalls discovered while converting raw address references to symbolic names in the disassembly:

1. **Label drift**: after converting numeric branch operands to label references, re-verify with the byte-exact harness — a wrong target mapping shows up as single-byte operand mismatches.
2. **@-locals scope**: @-prefixed local labels cannot be referenced from other procs or from .word tables outside their cheap-local group; converting labels referenced across scopes requires promoting them to bare globals and re-checking group boundaries.
3. **Byte-row duplication**: bulk SearchReplace on data rows can duplicate hex-comment rows when the anchor matches multiple lines; always verify with the per-bank harness and grep for duplicated address comments after batch conversions.
