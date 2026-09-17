# Wrapping functions in .proc requires consistent index space and size-filtered ROM gap recovery

- **Category:** common_pitfalls_experience
- **Memory ID:** bc7b89c2-9422-4893-9268-f87de4a44cb2
- **Keywords:** wrapping scripts, index shift bug, ROM gap scan, byte drift recovery, procedural refactoring, verification harness

## Content

Bug class: Index-shift errors when refactoring assembly procedures into `.proc` blocks. When a script computes label positions before inserting `.endproc` lines but applies replacements after insertion, the indices become stale, causing instructions to be clobbered (e.g., replacing an `.endproc` line or a real instruction). Recovery pattern: (1) Delete misplaced `.proc` lines; (2) Perform a ROM byte-gap scan using address continuity of hex comments (`$XXXX:`); (3) Filter gaps by size (instruction-sized gaps <=4 bytes are likely clobbered code; larger gaps like $B399 card-anim table are legitimate data and must NOT be restored); (4) Re-apply wraps with operations computed in a single index space, applied bottom-up (process anchors from end of file to start). Critical detail: Restored instructions must be placed at the exact position relative to intervening labels; misplacing a restored instruction even one line early/late causes branch-offset mismatches caught by the byte-exact verifier.
