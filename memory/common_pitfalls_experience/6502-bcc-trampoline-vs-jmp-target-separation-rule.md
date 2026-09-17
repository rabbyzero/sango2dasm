# 6502 BCC trampoline vs JMP target separation rule

- **Category:** common_pitfalls_experience
- **Memory ID:** 7570b8cc-e3c9-4c00-a454-404de48d2920
- **Keywords:** 6502 assembly, branch range, trampoline label, JMP operand, byte-exact verification, ca65

## Content

## Bug class: 6502 branch-range violation causing operand byte drift
Root cause: In ca65 assembly, a BCC (branch) instruction has an 8-bit signed offset (-128 to +127). When the target is beyond this range, the assembler requires an intermediate trampoline label (local jump) to bridge the gap. If the JMP target and BCC branch target are merged into the same label, the JMP operand bytes change from the ROM-correct address to the trampoline's address, causing a byte mismatch.

Fix pattern: Keep BCC branch targets as separate local labels (e.g., @ColumnAligned at $C0F9) that immediately precede the actual JMP destination. The JMP must target the final destination directly ($C123), not the trampoline label. Example: Loc_C064 at $C064-$C1CC had BCCs at $C0F4/$C111 targeting trampolines at $C0F9/$C106, while adjacent JMPs at $C0F6/$C106 targeted $C123 directly. Merging them caused mismatches at $C0F7/$C107 (asm=20 vs rom=23).

Reusable lesson: Don't merge BCC branch targets with JMP destinations when branch range is insufficient because it changes the JMP operand bytes and breaks byte-exact verification; instead use separate local trampoline labels for branches and keep JMPs pointing to the final destination. Applies when refactoring raw 6502 code with far branch targets; does not apply when all targets fit within ±127 bytes of the branch instruction.
