# PPUTileRender Stream Architecture

## Overview

The strategy mode display engine uses a bytecode stream format to render menu UI tiles. The core renderer is `PPUTileRender` ($A048-$A11A) and the stream decoder is `MenuUpdate` ($A153-$A1C6), both in `prg_1d_1e.asm`.

## Stream Location

- **Data Banks**: PRG banks $32/$33 (physical $12/$13), selected by `PosDataBankTable` at $A6A7
- **Pointer Resolution**: `CalcMenuDataPtr` ($A61D) computes stream address from `pos_buf_0` parameter
  - Formula: `table_offset = pos_buf_0 * 2 + $8000`
  - Reads 2-byte pointer from banked ROM at `table_offset`
  - Bank adjustment: `+$20` if bank >= $09, else `+$40` if bank >= $03
  - Final address: `(hi_raw + adj) << 8 | lo`

## Command Set ($80-$9F)

| Opcode | Name | Parameters | Description |
|--------|------|------------|-------------|
| $00-$7F | Literal tile | - | Tile index (with tile_base_offset added), stored to buffer |
| $39 | Special marker | - | Indirect column offset increment |
| $3A | Special marker | - | Indirect column offset increment |
| $80 | CmdEndMenu | - | Terminates stream processing |
| $81 | CmdAdvanceRow | - | Advances to next display row |
| $82 | CmdPushPosition | - | Pushes current VRAM position to stack |
| $83 | CmdPopPosition | - | Pops VRAM position from stack |
| $84 | CmdSetOverlayMode | - | Enables overlay rendering mode |
| $85 | CmdClearOverlayMode | - | Disables overlay rendering mode |
| $86, $8A-$8F | CmdSetVramPos | hi, lo (2 bytes) | Sets VRAM address register |
| $87 | CmdEnableIndirect | - | Enables indirect tile addressing |
| $88 | CmdDisableIndirect | - | Disables indirect tile addressing |
| $89 | CmdSetTileOffset | offset (1 byte) | Sets tile_base_offset |
| $90-$97 | CmdDrawName | - | Draws null-terminated name from bank $30 table ($901A base) |
| $98-$9B | CmdDrawNumber | - | Draws BCD-converted number (tile base $76 = '0') |
| $9C | CmdDrawNameFromData | index (1 byte) | Draws 6-char name from $9A1A table (blank if negative) |
| $9D | CmdDrawNameFixed7 | index (1 byte) | Draws 7-char name from $901A table |
| $9E | CmdDrawFormattedNumber | index (1 byte) | Draws formatted number from $044C table |
| $9F | CmdDrawNameFromParam | index (1 byte) | Reads index from stream, then draws from $901A table |

## Name Rendering Pipeline

### CmdDrawName ($90-$97)
1. Index = cmd - $90 (0-7)
2. Switches to PRG bank $30
3. Reads entry from RAM $042C table (populated dynamically)
4. Computes address: `ptr = entry * 10 + $901A`
5. Reads null-terminated byte sequence
6. Each byte passed through `StoreTileByte` (handles $39/$3A specially)
7. Restores previous bank

### CmdDrawNameFromData ($9C)
1. Reads index from next stream byte
2. Looks up $042C[index]
3. If bit 7 set: fills 6 tiles with $01 (blank)
4. Otherwise: `ptr = entry * 8 + $9A1A`, reads 6 bytes

### CmdDrawNameFixed7 ($9D)
1. Reads index from next stream byte
2. Same address formula as CmdDrawName: `ptr = entry * 10 + $901A`
3. Reads exactly 7 bytes (not null-terminated)

## Number Rendering

### CmdDrawNumber ($98-$9B)
1. Index = cmd - $98 (0-3)
2. Reads 3-byte descriptor from $042C (offset = index * 3)
3. Calls `B1F_MathBinToBcd` for binary → BCD conversion
4. Converts each BCD nibble to tile: `digit + $76` ('0' = $76, '9' = $7F)
5. Leading zero suppression via $0000 flag

## Handler pos_buf_0 Values

Each MenuAction handler calls `SetupDisplayPtrs` with a specific pos_buf_0 value:

| Handler | Name | pos_buf_0 |
|---------|------|-----------|
| $00 | MenuAction00_InitialSetup | $E8 |
| $01 | MenuAction01_DisplaySetup | $DC |
| $02 | MenuAction02_LandReclamation | $E1 |
| $03 | MenuAction03_DisasterPreventionSetup | $C6 |
| $04 | MenuAction04_DisasterPrevention | (shared with $03) |
| $05 | MenuAction05_UnidentifiedCmdSetup | $C6 |
| $06 | MenuAction06_UnidentifiedCmd | $EA |
| $07 | MenuAction07_CountryEnd | $B7 |
| $08 | MenuAction08_GoldDistribution | $CA |
| $09 | MenuAction09_RiceDistribution | $F1 |
| $0A | MenuAction0A_Conscription | $F0 |
| $0B | MenuAction0B_HireOfficer | $E9 |
| $0C | MenuAction0C_TransferOfficer | $F8 |
| $0D | MenuAction0D_UnidentifiedCmd | $F7 |
| $0E | MenuAction0E_UnidentifiedCmd | $F3 |
| $0F | MenuAction0F_GiveItem | $F0 |
| $10 | MenuAction10_SuccessorSelection | $D0 |
| $11 | MenuAction11_Intrigue | $F5 |
| $12 | MenuAction12_Sortie | $F8 |
| $13 | MenuAction13_Reconnaissance | $E7 |
| $14 | MenuAction14_Market | $FB |
| $15 | MenuAction15_Exchange | $EA |
| $16 | MenuAction16_Trade | $F6 |
| $17 | MenuAction17_SearchOfficer | $F7 |
| $18 | MenuAction18_SearchItem | $C5 |
| $19 | MenuAction19_UnidentifiedCmd | $F4 |
| $1A | MenuAction1A_OfficerDeath | $C1 |
| $1B | MenuAction1B_StrategyCmdDispatch | $FC |

## PosDataBankTable ($A6A7)

Maps pos_buf_0 ranges to PRG banks:
- pos 0-2: bank $33
- pos 3-8: bank $32
- pos 9-14: bank $33

For pos >= $20, uses $007A for dynamic bank selection.

## Name Data (Bank $30)

Location: PRG bank $30 (physical $10), address $901A

Name entries are stored as null-terminated tile index sequences:
- Entry 0: `$04 $09 $05 $18 $31`
- Entry 1: `$05 $0D $06`
- Entry 2: `$05 $11 $0A`
- ...

Tile indices $04-$09 represent character set groups (kanji), and higher values ($31, $36, $37, $39, $3A) are modifiers or second bytes in a multi-byte encoding scheme.

## Tile Rendering Buffers

- **tile_row1**: $031E (30 bytes) - primary tile row buffer
- **tile_row2**: $034E (30 bytes) - secondary tile row buffer
- **Indirect offsets**: $034B+X (for $39/$3A markers)

## Stream Decode Example

Handler $02 (LandReclamation, pos=$E1) from bank $33:
```
Stream: $90 $00 $90 $01 $81 $80
Decode:
  $90 $00 → CmdDrawName[0] (draws name at $042C[0] * 10 + $901A)
  $90 $01 → CmdDrawName[1] (draws name at $042C[1] * 10 + $901A)
  $81     → CmdAdvanceRow
  $80     → CmdEndMenu
```

## Tools

- `tools/decode_menu_streams.py` - Decodes stream bytecode for all handlers
- `tools/extract_names.py` - Extracts name data from bank $30
