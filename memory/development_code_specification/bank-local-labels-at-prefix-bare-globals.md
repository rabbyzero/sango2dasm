# Bank-local labels: @-prefix for nearby refs, bare globals for forward/cross-proc

- **Category:** development_code_specification
- **Memory ID:** efe7d886-f473-4014-bbc5-a6782e89519e
- **Keywords:** @-prefix, local labels, ca65 cheap locals, cross-proc references, same bank, forward reference, bare globals
- **Usage scenarios:**
  - Naming labels in bank assembly files
  - Referencing functions within same bank
  - Cross-proc JSR/JMP calls
  - Local labels inside .proc blocks
  - Forward-referenced table lookups across procs

## Content

In bank-specific assembly files (e.g., prg_1d_1e.asm):
- Local labels inside .proc/.endproc blocks must use the `@` prefix (ca65 cheap local labels), e.g., `@Loop:`, `@Skip:`, `BCC @Loop`.
- Multi-entry point labels that may be called from outside the proc remain without `@` if externally referenced.
- The .proc name itself (matching the function name) stays without `@`.
- Only use the Bxx_functionname prefix (e.g., B1F_functionname) for cross-bank JSR/JMP calls.
- Cross-proc references within the same bank (e.g., JMP VerifyChecksum from SramLoadBlock) use the bare .proc name without `@`.
