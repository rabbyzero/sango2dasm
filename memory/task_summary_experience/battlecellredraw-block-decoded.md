# BattleCellRedraw block decoded in prg_0e_0f.asm ($B870-$BB8E)

- **Category:** task_summary_experience
- **Memory ID:** 4cfc8dce-2be9-453d-b837-1a729eeed8f0
- **Keywords:** BattleCellRedraw, BattleAnimQueueIdleCheck, PPU update queue, adjacency mask, phase map tables, prg_0e_0f

## Content

## Task description
Decoded Loc_B870 block in asm/banks/prg_0e_0f.asm ($B870-$BB8E): battle animation queue idle check, the battle cell redraw engine, and its tables. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches).

## Key findings
1. BattleAnimQueueIdleCheck ($B870): C=1 when both queue slot headers $0300/$0304 hold $FF; polled by intro substates and phase 2-4/8 handlers before enqueueing work.
2. BattleCellRedraw ($B882): params $0012 mode (0=plain terrain redraw skipping self occupancy bit; nonzero=highlight with status tiles+HP digits), $0013 roster slot. Builds dual-nametable PPU update record $0380-$039C (FF-terminated), raises $007E bit2. Flow: bank-switch $8000 via BattleCellMapBankTable[$0544] (all $21) + B1F_SwitchBank8_B; map tile = MapPtrTable[phase][row*16+col]; pattern = PatternPtrTable[phase] + tile*4 (4-byte 2x2); nametable offset = row*64+col*2 (grid coords are 2x2-tile cells), records go to $2000 and $2400; attribute addr = $23C0/$27C0 + (row&0E)*4 + (col&0E)/2; highlight tiles from BattleCellHighlightTiles[status_index*4] where status_index = (($05C2&$F0)>>2)|($05C2&3) capped < $10 (NOP at $B97E is unreached ROM artifact).
3. BattleCellHpDigitOverlay ($BA18): HP $05AC[slot] via B1F_MathBinToBcd; tens/ones -> tiles $B4+d at $0396/$0397; BCD byte $0008 low nibble nonzero -> $BE/$BF overflow marker.
4. BattleCellAdjacencyScan ($BA56) + BattleCellSlotAdjacencyMerge ($BA79): scans 22 slots, probes 4 sub-cells (col,row),(col+1,row),(col+1,row+1),(col,row+1) of the even-aligned target 2x2 block; side A slots 0-$0A masks $03/$0C/$30/$C0, side B slots $0B-$15 masks $01/$04/$10/$40; bits are cleared before OR (last writer wins).
5. Tables: BattleCellMapPtrTable $BB1E 7 words ($8440+$130*i); BattleCellPatternPtrTable $BB2C 7 words ALL $8000 (pattern data at $8000 of switched bank); BattleCellAttrPtrTable $BB3A 7 words ($8400+$130*i); BattleCellMapBankTable $BB48 7 bytes $21; BattleCellHighlightTiles $BB4F 16x4 bytes starting $FD.

## Notes
- Pitfall 1: the 8th map word $8000 I assumed as filler was actually pattern table entry 0; pattern table is seven $8000 words ($BB2C-$BB39) — mis-splitting caused +3-byte overflow. Always cross-check table splits against code index ranges (phases 0-6 only).
- Pitfall 2: highlight table starts at $BB4F ($FD...), not $BB4E; the $21 at $BB4E is the last bank-table byte (+1-byte overflow when mis-split).
- All 32 JSR $B870/$B882 call sites and doc comments updated to symbolic names; verify harness stub count returned to baseline 10.
- Full make fails pre-existing (duplicate symbols prg_17_18 vs prg_0c_0d/prg_0a_0b), unrelated.
- Remaining roadmap for prg_0e_0f: phases 5 ($CD43), 6 ($CE25), 7 ($CF67), $A ($D6BA); $BB8F cursor-arrow draw still raw.
