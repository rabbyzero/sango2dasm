# Symbolic-reference conversion pitfalls: label drift, @-locals scope, byte-row duplication

- **Category:** common_pitfalls_experience
- **Memory ID:** 5e472fed-3b2d-4502-87a8-51a35c3c90b3
- **Keywords:** ca65 scoping errors, byte drift verification harness, label misplacement, cheap locals forward reference
- **Usage scenarios:**
  - Replacing raw addresses with labels
  - Fixing verification mismatches after symbolization
  - Diagnosing ca65 undefined-symbol or overflow errors

## Content

Bug class: silently wrong label values / byte drift when converting raw `$xxxx` operands to symbolic references in ca65 bank files. Root causes hit in practice on prg_0e_0f.asm: (1) data-table labels placed at row boundaries that did not match the true ROM addresses (AiOrderVectorWindow was 8 bytes late, FlankProbeRowDeltas 3 bytes early), so symbolic operands emitted different bytes than the raw ones even though the source "looked" right — only caught by assembling and diffing against the ROM; (2) cheap-local `@` labels referenced across procs must not use `Proc::Label` (that only works for plain labels); they also failed as forward references across many intervening labels in the sound-engine region, so cross-proc-referenced intra-bank tables were made bare globals and qualified with `Proc::Label`; (3) a `.byte` pseudo-disassembly row can carry duplicated/extra bytes that pass unnoticed until symbols resolve (the $DE42 row had +6 bytes shifting every later label by -6 while segment overflow only surfaced at link time). Fix pattern: always run the per-bank verification harness (e.g., tools/verify_0e_0f.py) before AND after edits; it stubs external JSR/JMP targets, lays out segments at real bases, and diffs against rom/prg/*.bin — "external stubs: 0" additionally proves no raw long-address JSR/JMP remains. Reusable lesson: any operand replacement from literal to symbol is only safe once parity-diff is green; drift diagnosis via ca65 -l listing compare of emitted PC vs the file's `$xxxx:` comments localizes the first bad row quickly.
