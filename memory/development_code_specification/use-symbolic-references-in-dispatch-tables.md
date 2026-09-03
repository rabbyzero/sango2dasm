# Use symbolic references in dispatch tables

- **Category:** development_code_specification
- **Memory ID:** 142003aa-4e3d-4561-a1b3-63dd017878cf
- **Keywords:** symbolic references, >label, <label, dispatch table, ca65
- **Usage scenarios:**
  - Defining inline dispatch tables with ca65 assembler
  - Replacing hardcoded address bytes with symbolic labels
  - Handling cross-proc or nested-proc dispatch targets

## Content

Dispatch tables must use symbolic references via `>label` and `<label` operators (high-byte-first) instead of raw address bytes when the target label is accessible. For targets inside nested procs that cannot be symbolically referenced, raw byte values are acceptable.
