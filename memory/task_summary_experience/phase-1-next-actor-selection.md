# Phase 1 next-actor selection handler decoded in prg_0e_0f.asm

- **Category:** task_summary_experience
- **Memory ID:** f9a88597-49d1-4a17-a157-f5cb753819a4
- **Keywords:** phase 1 decode, next-actor selection, BattleOverlayDispatch, roster scan, side status counters, byte verification

## Content

## Task description
- Core requirement: analyze and decode Loc_A15F in prg_0e_0f.asm, which was encoded as raw .byte data but is actually the phase-1 handler of the BattleOverlayDispatch state machine (next-actor selection).
- Task background: following the BattleOverlayDispatch refactoring memory that decoded phase 0, the remaining work included decoding phase handlers 1-$A. Loc_A15F ($A15F-$A39C) was misclassified as data but contains code for selecting the next acting unit during battle overlay.

## Execution process
1. Verified raw bytes at $A15F using hex dump from prg_0e.bin; identified JSR $BF4C pattern indicating actual code.
2. Analyzed structure: sub-dispatch at $A15F-$A16D calls BattleSideStatusCounterDraw ($BF4C), then dispatches on $0541 via inline 3-entry table to sub-handlers at $A16E, $A183, $A235.
3. Decoded sub-handler 0 (Phase1CycleInit $A16E): clears scan cursor $0545-$0547 and pass counter $057A, refreshes side panels via $D067.
4. Decoded sub-handler 1 (Phase1NextActorSelect $A183): checks battle-end events ($0580/$058B for retreat/defeat flags), player handoff flags ($0568/$0569), scans roster $05C2 in priority order [3,2,1,0] via Phase1SidePriorityOrder table at $A231.
5. Decoded sub-handler 2 (Phase1RoundPass $A235): passes round when no actor found, increments pass counter $057A, ticks status counters via BattleSideStatusCountersDecrement ($B15B).
6. Renamed helper routines: BattleSideStatusCounterDraw ($BF4C), BattleSideStatusCountersDecrement ($B15B), BattleDefeatEventCheck ($A2A9), BattleRetreatEventCheck ($A32F).
7. Added semantic proc boundaries and comments throughout the region $A15F-$A39C.
8. Verification harness execution: tools/verify_0e_0f.py initially failed with 6941 mismatches due to dropped LDA #$00 instruction at $A34F causing cascade offset; fixed by restoring missing instruction. Second failure at $A2B8 branch target corrected from @Done to @SideB. Final verification: 16384 bytes, 0 mismatches.

## Related files
- /asm/banks/prg_0e_0f.asm — refactored Loc_A15F region into semantic procedures, updated phase-table entry at $A071, added BattleOverlayDispatch header documentation

## Notes
- Two bugs caught during verification: (1) accidentally removed LDA #$00 / STA $0545 pair at $A34F causing -2 byte drift cascading through all subsequent labels; (2) wrong branch target BNE @Done instead of BNE @SideB at $A2B7. Both fixed before final byte-exact confirmation.
- Cross-reference check confirmed no stale Loc_ label references or symbol collisions with other bank files.

## Task overview
Completed: fully decoded phase-1 handler of BattleOverlayDispatch ($A15F-$A39C), renamed 8 routines with semantic names, verified byte-exact match (16384 bytes, 0 mismatches). Remaining per roadmap: decode phase handlers 2-$A ($A4F7, $AA23, $A3BC, $CD43, $CE25, $CF67, $ACC5, $B1EC, $D6BA).
