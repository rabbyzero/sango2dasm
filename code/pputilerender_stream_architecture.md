# PPUTileRender Stream Architecture

## Overview

The strategy mode display engine uses a bytecode stream format to render menu UI tiles. The core renderer is `PPUTileRender` ($A048-$A11A) and the stream decoder is `MenuUpdate` ($A153-$A1C6), both in `prg_1d_1e_menu_screens.asm`.

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

## MenuAction handler display latches

Each handler calls `SetupDisplayPtrs` and sometimes `ResetDispatchState` on
its first frame (`$04A1 == 0`). **These immediates are NOT stream positions**
- they only latch the display cell block `$00BF/$00C7/$00CF` and
`$00C0/$00C8/$00D0`, which the prg_19_1a cutscene handlers animate and
prg_17_18 reuses as a tile buffer, and which nothing reads back as
`pos_buf_0` (`$0310`). The stream a screen actually shows is pushed by its
opener through `B1F_OpenMsgWindow0/2/4/5` (prg_1f_boot `$F26D-$F29B`); each
handler block in `asm/banks/prg_1d_1e_menu_screens.asm` names that opener and
quotes its message text.

| id $04A2 | handler | `$00BF/$00C7/$00CF` | `$00C0/$00C8/$00D0` |
|----------|---------|--------------------|--------------------|
| `$00` | MenuAction00_SortieResult | $E8 | - |
| `$01` | MenuAction01_AcademyResult | $DC | $DF |
| `$02` | MenuAction02_SaveGameResult | $E1 | - |
| `$03` | MenuAction03_DiscordResult | $E9 | $EA |
| `$04` | MenuAction04_WarRulerCard | $D1 | - |
| `$05` | MenuAction05_WarRivalRulerCard | $C6 | $CF |
| `$06` | MenuAction06_DisasterPreventionResult | $EA | $EB |
| `$07` | MenuAction07_ArmoryResult | $B7 | - |
| `$08` | MenuAction08_WarOutbreakNotice | $CA | - |
| `$09` | MenuAction09_LandReclamationResult0A | $F1 | $F2 |
| `$0A` | MenuAction0A_LandReclamationResult0B | $F0 | - |
| `$0B` | MenuAction0B_CivilianReliefResult | $E9 | $EB |
| `$0C` | MenuAction0C_HospitalResult | $F8 | $F9 |
| `$0D` | MenuAction0D_LandReclamationResult0E | $F7 | - |
| `$0E` | MenuAction0E_TownDevelopmentResult0F | $F3 | $F4 |
| `$0F` | MenuAction0F_IndustryAndTownResult10 | $F0 | - |
| `$10` | MenuAction10_OfficerTransferResult | $D0 | $D1 |
| `$11` | MenuAction11_IndustryDevelopmentResult12 | $F5 | $F7 |
| `$12` | MenuAction12_PoachingResult | $F8 | $FA |
| `$13` | MenuAction13_IndustryDevelopmentResult14 | $E7 | - |
| `$14` | MenuAction14_LandAndIndustryResult15 | $FB | $FC |
| `$15` | MenuAction15_IndustryAndTownResult16 | $EA | $EB |
| `$16` | MenuAction16_OfficerGiftResult | $F6 | - |
| `$17` | MenuAction17_IndustryAndTownResult18 | $F7 | $DF |
| `$18` | MenuAction18_AllianceResult | $C5 | - |
| `$19` | MenuAction19_ConscriptionResult | $F4 | $F5 |
| `$1A` | MenuAction1A_IntelligenceGatheringResult | $C1 | - |
| `$1B` | MenuAction1B_DroughtDamageWindow | $FC | - |
| `$1C` | MenuAction1C_RiceHarvestWindow | $C2 | - |
| `$1D` | MenuAction1D_FloodDamageWindow | $D1 | - |
| `$1E` | MenuAction1E_RebellionWindow | $C6 | - |
| `$1F` | MenuAction1F_TaxCollectionWindow | $BD | - |
| `$20` | MenuAction20_MarketPanel | $B7 | $B7 |
| `$21` | MenuAction21_SupplyTransportResult | $AA | $AB |
| `$22` | MenuAction22_WindowTeardown | - | - |

Handler `$22` (`MenuAction22_WindowTeardown`) latches nothing: it is the
teardown step `StrategyMenu_Return` forces, not a screen.

## PosDataBankTable ($A6A7)

Maps pos_buf_0 ranges to PRG banks:
- pos 0-2: bank $33
- pos 3-8: bank $32
- pos 9-14: bank $33

For pos >= $20, uses $007A for dynamic bank selection.

## Name Data (Bank $30)

Location: PRG bank $30 (physical $10), address $901A

Name entries are stored as null-terminated tile index sequences in the serial
gojuon katakana code space ($04=ア..$31=ン; see code/font_analysis.md). The
same code space is what the streams' low tile range $04-$38 renders with, so
CmdDrawName bytes pass through StoreTileByte unchanged and land on katakana
glyphs. Full stream text decode (both code spaces, dakuten marks, dynamic
placeholders): tools/menu_text_map.py + tools/report_stream_text.txt.

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

- `tools/decode_menu_streams.py` - Decodes the stream whose id equals each handler
  display latch; its header records that that pairing is a coincidence, not a
  content link (see the correction above), so it is not a naming source
- `tools/report_stream_text.py` - the full decoded text of every bank $12/$13 stream
- `tools/extract_names.py` - Extracts name data from bank $30
