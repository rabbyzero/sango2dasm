# Refactor $A983-$AB25: Advisor Tile Setup Procedure

## Context

The address range $A983-$AB25 in `prg_17_18.asm` is currently split across three separate `.proc` blocks (`AdvisorDialogue`, `Sub_A986`, `Sub_AB26`) with generic labels (`@skip`, `@skip_2`...`@skip_16`) and an unnamed helper (`LA9A8`). The code is actually a cohesive advisor tile setup system: it takes a ruler index, fetches the ruler's dialogue type from SRAM, dispatches to one of three cases, and writes four CHR tile indices into the $01B0-$01B3 metatile buffer. The goal is to merge related procs, give everything semantic names, label the data tables, and update all references.

## Files to Modify

- `/home/zero/project/sango2dasm/asm/banks/prg_17_18.asm` (lines 1355-1578)

## Task 1: Merge and Rename Procedures

**Current structure (3 procs):**
- `AdvisorDialogue` ($A983-$A985): 1 instruction, falls through
- `Sub_A986` ($A986-$AAE3): main logic with 3 cases + helper LA9A8
- `Sub_AB26` ($AB26-$AB52): scroll-to-tile coordinate conversion

**New structure (2 procs):**

| Current | New Name | Rationale |
|---|---|---|
| `AdvisorDialogue` + `Sub_A986` | `SetupAdvisorTiles` (single .proc) | Merged: entry thunk falls through to main logic |
| `LA9A8` (inside proc) | `@GetRulerDialogueType` | Local helper: fetches byte 3 from ruler SRAM |
| `Sub_AB26` | `CalcTileGridOrigin` | Converts scroll coords to tile grid indices |

Merge `AdvisorDialogue` into `SetupAdvisorTiles` so the `LDY a:$0000` is the first instruction of the proc. Remove the separate `.proc AdvisorDialogue` / `.endproc` block.

## Task 2: Rename Branch Labels

Replace all generic `@skip_N` labels with semantic names inside `SetupAdvisorTiles`:

| Current | New Label | Meaning |
|---|---|---|
| `@skip` (line 1380) | `@no_shift` | Bit 7 of $0628[Y] is clear, no shift needed |
| `@skip_2` (line 1406) | `@type0` | Dialogue type == 0 handler |
| `@skip_3` (line 1421) | `@type0_ruler_special` | Ruler 0 or 10 override entry |
| `@skip_4` (line 1431) | `@type0_overrides_done` | Past ruler 0/10 overrides |
| `@skip_5` (line 1443) | `@type0_subtile_not0` | ($0628&3) != 0 |
| `@skip_6` (line 1452) | `@type0_subtile_not1` | ($0628&3) != 1 |
| `@skip_7` (line 1454) | `@type1` | Dialogue type == 1 handler |
| `@skip_8` (line 1469) | `@type1_ruler_special` | Ruler 0 or 10 override entry |
| `@skip_9` (line 1479) | `@type1_overrides_done` | Past ruler 0/10 overrides |
| `@skip_10` (line 1491) | `@type1_subtile_not0` | ($0628&3) != 0 |
| `@skip_11` (line 1500) | `@type1_subtile_not2` | ($0628&3) != 2 |
| `@skip_12` (line 1502) | `@type2` | Dialogue type == 2 handler |
| `@skip_13` (line 1517) | `@type2_ruler_special` | Ruler 0 or 10 override entry |
| `@skip_14` (line 1527) | `@type2_overrides_done` | Past ruler 0/10 overrides |
| `@skip_15` (line 1539) | `@type2_subtile_not0` | ($0628&3) != 0 |
| `@skip_16` (line 1548) | `@type2_subtile_not2` | ($0628&3) != 2 |

## Task 3: Name the Data Tables

Replace anonymous `.byte` directives ($AAE4-$AB25) with labeled tables:

```asm
; Dialogue type 0 tile tables
AdvisorTileTbl0_Lo:    ; $AAE4
  .byte $BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$AA,$A0
AdvisorTileTbl0_Hi:    ; $AAEF
  .byte $A5,$A6,$A7,$A8,$A9,$AB,$B2,$B2,$B2,$B2,$B2,$B2

; Dialogue type 1 tile tables
AdvisorTileTbl1_Lo:    ; $AAFA
  .byte $8A,$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8B
AdvisorTileTbl1_Hi:    ; $AB05
  .byte $B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7,$B7

; Dialogue type 2 tile tables
AdvisorTileTbl2_Lo:    ; $AB10
  .byte $9A,$90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9B
AdvisorTileTbl2_Hi:    ; $AB1B
  .byte $9B,...
```

Update all references: `$AAE4,Y` -> `AdvisorTileTbl0_Lo,Y`, etc.

## Task 4: Update External References

Two callers reference `Sub_A986` via JSR:

| Location | Current | New |
|---|---|---|
| Line 1275 (DispatchTileRowHoriz) | `JSR Sub_A986` | `JSR SetupAdvisorTiles` |
| Line 1297 (DispatchTileRowVert) | `JSR Sub_A986` | `JSR SetupAdvisorTiles` |

The dispatch table at line 96 already references `AdvisorDialogue` -- update to `SetupAdvisorTiles`.

## Task 5: Add Proc Header Comment

Add a descriptive header explaining the procedure's purpose, inputs, outputs, and flow:
- Input: Y = ruler index (from $0000 for AdvisorDialogue entry)
- Output: $01B0-$01B3 = 4 CHR tile indices for advisor metatile
- Dispatch: based on ruler SRAM byte 3 (dialogue type 0/1/2)
- Special overrides for ruler index 0 and 10
- Sub-tile overrides based on $0628[Y] bits 0-1

## Verification

1. Assemble with `make` to confirm no syntax/label errors
2. Run `python3 tools/verify_disasm.py` or equivalent to verify byte-for-byte match against original ROM
3. Grep for any remaining references to old labels (`Sub_A986`, `LA9A8`, `AdvisorDialogue`)
