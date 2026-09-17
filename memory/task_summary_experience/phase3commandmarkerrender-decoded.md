# Phase3CommandMarkerRender decoded and refactored in prg_0e_0f.asm

- **Category:** task_summary_experience
- **Memory ID:** 9d87bac2-fbdd-4ceb-abed-2e5dafd9c50b
- **Keywords:** Phase3CommandMarkerRender, command menu marker, VRAM script, NMI dispatch, battle UI

## Content

## Task description
- Core requirement: decode and refactor Loc_C839 in prg_0e_0f.asm ($C839-$C8BA)
- Task background: the routine was an anonymous label; needed semantic renaming, data table identification, and documentation for phase-3 command-menu marker rendering

## Execution process
1. Read prg_0e_0f.asm around $C839 to understand the code structure and callers
2. Traced VRAM script consumer through NmiSubDispatch bit-2 handler to B1D_1E_VRAMBufferWrite in prg_1d_1e.asm
3. Identified two data tables: Phase3CommandMarkerAddrTable ($C8BB, 8 words) and Phase3CommandMarkerTiles ($C8CB, 5 rows × 10 bytes)
4. Renamed Loc_C839 to .proc Phase3CommandMarkerRender with full header block and per-line semantic comments
5. Restructured anonymous data region into named tables with hex-verification comments
6. First restructure attempt caused 32 byte mismatches due to incorrect row ordering; restored exact original byte stream
7. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches)

## Related files
- asm/banks/prg_0e_0f.asm

## Notes
- The physical row order of tile IDs is non-monotonic (v0, v1, v2, v3, v4 are stored in scrambled order); must preserve exact byte layout during refactoring
- VRAM script format: [count, addr hi, addr lo, tiles×count]... terminated by $FF; horizontal PPU increment enabled

## Task overview
Completed: renamed Loc_C839 to Phase3CommandMarkerRender, added semantic comments, named data tables, verified byte-exact (16384 bytes, 0 mismatches). The routine draws a 4×2-tile command icon for action slot value at menu step position using a two-segment VRAM script dispatched via NMI bit-2.
