# MenuRenderer Dispatch Target Analysis & Labeling Plan

## Context

The `MenuRenderer` proc in `prg_1d_1e.asm` ($BE02–$C9E7) is a large menu rendering engine for Sangokushi 2. It uses a **two-level dispatch pattern**: a primary dispatch table at $BE64 routes to ~15 sub-handler blocks, many of which contain their own secondary dispatch tables. Currently, most dispatch targets are raw addresses (`.byte >$XXXX`) with no meaningful labels, and numerous data regions (text strings, lookup tables, sub-dispatch tables) lack labels entirely. This makes the code extremely difficult to read and maintain.

## Scope

- **File**: `asm/banks/prg_1d_1e.asm`
- **Range**: $BE36–$C9E7 (MenuRenderer body + all dispatch targets)
- **Focus**: Label data blocks, local branch targets, and dispatch subroutines

## Analysis Summary

### Primary Dispatch Table ($BE64, 29 entries)

| Index | Target | Current Label | Purpose |
|-------|--------|---------------|---------|
| 00 | $BE7F | `MenuInit` | Init overlay, draw frame, load BG |
| 01 | $BEF3 | `MenuUpdate` | Main update: cursor, confirm/cancel |
| 02 | $BF09 | `MenuConfirm` | A-button confirm handler |
| 03 | $BF25 | `MenuCancel` | B-button cancel (sets $04B5=0, exit) |
| 04 | $C00A | `LAB1D_C00A` | **Has secondary dispatch table** (14 entries at $C017) |
| 05 | $C09B | `LAB1D_C09B` | **Has secondary dispatch table** (8 entries at $C0A8) |
| 06 | $C0D8 | `LAB1D_C0D8` | **Has secondary dispatch table** (9 entries at $C0E5) |
| 07 | $C11D | `LAB1D_C11D` | **Has secondary dispatch table** (7 entries at $C12A) |
| 08 | $C15C | `LAB1D_C15C` | **Has secondary dispatch table** (9 entries at $C169) |
| 09 | $C1A3 | `LAB1D_C1A3` | **Has secondary dispatch table** (14 entries at $C1B0) |
| 0A | $C242 | `LAB1D_C242` | **Has secondary dispatch table** (14 entries at $C24F) |
| 0B | $C2D1 | `LAB1D_C2D1` | **Has secondary dispatch table** (14 entries at $C2DE) |
| 0C | $C360 | `LAB1D_C360` | **Has secondary dispatch table** (14 entries at $C36D) |
| 0D | $C3EF | `LAB1D_C3EF` | **Has secondary dispatch table** (14 entries at $C3FC) |
| 0E | $C47E | `LAB1D_C47E` | **Has secondary dispatch table** (14 entries at $C48B) |
| 0F | $C50D | `LAB1D_C50D` | **Has secondary dispatch table** (14 entries at $C51A) |
| 10 | $C59C | `LAB1D_C59C` | **Has secondary dispatch table** (14 entries at $C5A9) |
| 11 | $C62B | `LAB1D_C62B` | **Has secondary dispatch table** (14 entries at $C638) |
| 12 | $C6BA | `LAB1D_C6BA` | **Has secondary dispatch table** (14 entries at $C6C7) |
| 13 | $C749 | `LAB1D_C749` | **Has secondary dispatch table** (14 entries at $C756) |
| 14 | $C7D8 | `LAB1D_C7D8` | **Has secondary dispatch table** (14 entries at $C7E5) |
| 15 | $C867 | `LAB1D_C867` | **Has secondary dispatch table** (14 entries at $C874) |
| 16 | $C8F6 | `LAB1D_C8F6` | **Has secondary dispatch table** (14 entries at $C903) |
| 17 | $C032 | `LAB1D_C032` | Sub-handler (secondary dispatch) |
| 18 | $C064 | `LAB1D_C064` | Sub-handler (secondary dispatch) |
| 19 | $C145 | `LAB1D_C145` | Sub-handler (secondary dispatch) |
| 1A | $C18B | `LAB1D_C18B` | Sub-handler (secondary dispatch) |
| 1B | $C1D0 | `LAB1D_C1D0` | Sub-handler (secondary dispatch) |
| 1C | $C215 | `LAB1D_C215` | Sub-handler (secondary dispatch) |

### Secondary Dispatch Pattern (repeated for indices 04–16, 18–1C)

Each sub-handler block follows this structure:
```
LAB1D_CXXX:
    LDY $04B7            ; sub-state index
    LDA secondary_table,Y
    JSR call_dispatch    ; indirect JSR via ($04C4)
    RTS
secondary_table:
    .byte >$XXXX, >$XXXX, ...  ; 7–14 entries each
```

### Secondary Dispatch Targets (all unlabeled)

**~200+ secondary dispatch targets** across 21 secondary tables, all currently raw addresses. These are menu-item-specific renderers (draw item text, handle selection, etc.).

### Key Unlabeled Data Regions

| Address | Size | Type | Description |
|---------|------|------|-------------|
| $BF39 | ~13 bytes | text | "こうき" (Kouki era) text string |
| $BF46 | ~13 bytes | text | "ちゅうへい" (Chuhei era) text string |
| $BF53 | ~13 bytes | text | "こうえん" (Kouen era) text string |
| $BF60 | ~13 bytes | text | "けんこう" (Kenkou era) text string |
| $BF6D–$BF9F | ~50 bytes | data | Unknown lookup data |
| $BFCD | ~4 bytes | data | Small lookup table |
| $BFD1 | ~14 bytes | data | Unknown data |
| $C017 | 14 words | dispatch table | Secondary table for index 04 |
| $C0A8 | 8 words | dispatch table | Secondary table for index 05 |
| $C0E5 | 9 words | dispatch table | Secondary table for index 06 |
| ... (21 total secondary tables) | | | |
| $C936 | ~176 bytes | large data | Large data block at end of range |

### Local Branch Targets Needing Labels

Numerous local `BNE`/`BEQ`/`BCS`/`BCC` targets within sub-handlers are currently raw `loc_XXXX` labels. These should be reviewed and given meaningful names where they represent logical decision points.

## Task 1: Label Primary Dispatch Table Entries

Give meaningful names to the 4 core handlers and 23 sub-handler entry points:
- `MenuInit`, `MenuUpdate`, `MenuConfirm`, `MenuCancel` → rename if needed for consistency
- `LAB1D_C00A` through `LAB1D_C8F6` → give semantic names based on their menu function (e.g., `MenuDrawItemText`, `MenuHandleScroll`, etc.)
- File: `asm/banks/prg_1d_1e.asm`

## Task 2: Label Secondary Dispatch Tables and Their Targets

For each of the 21 secondary dispatch tables:
- Label the table itself (e.g., `subDispatch_C017`)
- Label each target within the table with a meaningful name based on function
- This covers ~200+ addresses

## Task 3: Label Data Blocks

- Label all text strings (era names at $BF39–$BF60)
- Label lookup/data tables with descriptive names
- Mark the large data block at $C936 with appropriate `.byte`/`.word` directives
- Label the dispatch mechanism data ($04C4 indirect pointer storage)

## Task 4: Label Local Branch Targets

Review and rename `loc_XXXX` labels within sub-handlers where they represent meaningful decision points (e.g., `skipDraw`, `exitHandler`, `nextItem`).

## Verification

1. Run `make` to ensure the assembled output still matches the original ROM binary
2. Verify no label conflicts or undefined references
3. Spot-check that renamed labels are semantically appropriate
