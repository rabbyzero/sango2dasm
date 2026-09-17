# BattleSideStatusCounterDraw pointer table and digit stream decoding

- **Category:** task_summary_experience
- **Memory ID:** 925b2408-8ded-4225-b515-4caadb531de0
- **Keywords:** counter streams, PerCounterStreamPtrTable, .word conversion, BattleSideStatusCounterDraw, PPU digit streams

## Content

## Task description
- Core requirement: Convert BattleSideStatusCounterDraw's $BFCF pointer table from raw .byte pairs to symbolic .word directives and decode the four digit stream targets.
- Task background: The @PerCounterStreamPtrTable at $BFCF held four 16-bit addresses as paired .byte values; each address pointed to a 17-byte PPU digit stream used by B1F_SpriteOamWriterScroll to render side-action counters. Streams were incorrectly formatted as merged .byte rows spanning segment boundaries.

## Execution process
1. Verified ROM contents at $BFD7, $BFE8, $BFF9 (prg_0e.bin) and $C00A (prg_0f.bin) to confirm stream data layout and byte sequences.
2. Identified stale mid-data label Loc_BFEB referenced nowhere; confirmed streams are 17 bytes each (four [relY,tile,attr,relX] records + $80 terminator).
3. Replaced .byte pair table with .word directive using symbolic targets: BattleSideStatusCounterStream0-3.
4. Split merged .byte rows at true stream boundaries ($BFDF/$BFF0, $C001/$C00A/$C012), recomputed all address comments.
5. Removed unreferenced Loc_BFEB label artifact.
6. Verified byte-exact match via tools/verify_0e_0f.py: 16384 bytes, 0 mismatches, 10 stubs.

## Related files
- /asm/banks/prg_0e_0f.asm

## Notes
- Pointer tables holding 16-bit addresses must use .word with symbolic targets per project convention, not .byte pairs.
- When splitting merged .byte rows at true stream boundaries, recompute every address comment to maintain traceability.
- Cross-segment data (stream 2 spans $BFFF/$C000) is valid since ca65 resolves labels at link time.

## Task overview
Completed: Converted @PerCounterStreamPtrTable to proper .word pointer table with symbolic targets; decoded all four digit streams with tile patterns and attributes; removed stale label; verified byte-exact build (0 mismatches).
