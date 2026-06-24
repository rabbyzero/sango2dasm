# Bank 1F Structure

## Overview

- **Bank Number**: 0x1F (31)
- **Address Range**: $E000-$FFFF (8KB)
- **Role**: Fixed boot bank — reset handler, game state machine, NMI/IRQ handlers, sound engine, math library, menu system, PPU utilities, data tables
- **Mapper**: Namco-163 (Mapper 19)
- **Interrupt Vectors**: NMI=$F800, RESET=$E000, IRQ=$FB2D

## Region Map

| Address Range | Size | Purpose |
|---|---|---|
| $E000–$E079 | 121B | **Reset Handler** — PPU/APU init, RAM clear, mapper init |
| $E07C–$E099 | 30B | **Vector Dispatch Table** — 15 state entry points indexed by `$007A` |
| $E09A–$E4D8 | ~1KB | **Game State Handlers** — 14 entries: system init, new game, kingdom select, domestic affairs, battle, territory, advisor, turn summary, idle waits |
| $E4DA–$E566 | ~110B | **Core Helpers** — FrameInit, BankSwitch (8-byte Namco-163 config) |
| $E57F–$E6C5 | ~295B | **Sound Engine** — init, wavetable upload, note player, 8 sound wrappers |
| $E6C6–$E8B9 | ~470B | **Controller I/O + RNG** — controller read, palette upload, PPU helpers, 6 RNG functions + 256-byte random table |
| $E8BA–$E9B9 | 256B | **RNG Data Table** — pre-computed random bytes |
| $E9BA–$EC66 | ~685B | **Math Library** — BCD↔binary, 16/24-bit division, 24x8/24x16 multiply, mul-div-100, callback dispatcher |
| $EC67–$ED18 | ~178B | **Palette Animation** — color rotation effects |
| $ED19–$EE51 | ~310B | **Menu Cursor System** — 8 entry points (1–8 items/page), D-pad navigation, banked callback trampoline |
| $EE53–$F076 | ~550B | **NMI Sub-Dispatch + PPU Tile Writers** — BG/sprite/attribute tile writes |
| $F077–$F2AE | ~570B | **Sprite OAM, CHR Banking, Window Setup** — OAM writers, CHR bank switch, display setup |
| $F2AF–$F3BC | ~205B | **Data Access Functions** — hero/city/kingdom/kata-name address calculators |
| $F3BD–$F476 | ~185B | **Mapper Init + RAM Test** — controller validation, RAM integrity check |
| $F477–$F676 | 512B | **Sound/Music Data** — instrument definitions |
| $F677–$F7FF | 392B | Padding ($FF) |
| $F800–$FAA8 | 680B | **NMI Handler** — 8 sub-states dispatched by `$0078` |
| $FAA9–$FB2C | ~120B | **Palette Swap + Controller Read** — with NMI scroll mode |
| $FB2D–$FF5E | 990B | **IRQ Handler** — 14+ sub-states for mid-frame raster/CHR effects |
| $FF62–$FFD6 | ~115B | **Scroll Calculations** — two variants |
| $FFD7–$FFF9 | 35B | Padding |
| $FFFA–$FFFF | 6B | **Interrupt Vectors** |

## Game State Machine

15 states dispatched via `$007A AND #$1F` through the vector table at $E07C:

| # | Address | Name | Description |
|---|---------|------|-------------|
| 0 | $E09A | System Init | PPU setup, transition to state 9 |
| 1 | $E0DA | New Game Init | Display, SRAM init, music $81 |
| 2 | $E17D | Random + Display (Y=$2A) | Brief transition |
| 3 | $E18B | Kingdom Select | Scenario/normal mode selection |
| 4 | $E221 | Random + Display (Y=$28) | Brief transition |
| 5 | $E22F | Domestic Affairs | Action selection (farming, commerce, etc.) |
| 6 | $E2E2 | RNG Advance | Pure random seed advance |
| 7 | $E2E8 | Battle Phase | Combat with army status check |
| 8 | $E36A | RNG Advance | Pure random seed advance |
| 9 | $E37C | Territory/Map View | Game map display |
| 10 | $E3EB | Idle/Wait | NMI frame wait |
| 11 | $E3EE | Advisor/Council | Advisor dialogue |
| 12 | $E3EB | Idle/Wait | NMI frame wait |
| 13 | $E46A | Turn Summary | End-of-turn report |
| 14 | $E3EB | Idle/Wait | NMI frame wait |

## Key Subsystems

### Math Library ($E9BA–$EC66)

| Function | Address | Description |
|----------|---------|-------------|
| Binary→BCD | $E9BA | 24-bit binary to 6-digit packed BCD |
| 16-bit Division | $EA7C | 16-bit unsigned division (16 iterations) |
| 24-bit Division | $EAA5 | 24-bit unsigned division (24 iterations) |
| Callback Dispatcher | $EADE | Inline pointer table callback |
| BCD→Binary | $EB2D | 6-digit packed BCD to 24-bit binary |
| Extract Upper Nibble | $EBB1 | 4x LSR |
| 24-bit Accumulate | $EBB6 | 24-bit accumulate add |
| Mul-Div-100 | $EBCA | 16-bit × 8-bit ÷ 100 |
| 24×8 Multiply | $EBE9 | 24×8 multiply (32-bit result) |
| 24×16 Multiply | $EC22 | 24×16 multiply (40-bit result) |

### Menu Cursor System ($ED19–$EE51)

- 8 entry points for 1–8 items per page
- D-pad navigation: Right/Left = within page, Down/Up = between pages
- Edge-triggered input via `$0081`
- Banked callback trampoline ($EE07) for cross-bank function calls

### Data Access Functions ($F2AF–$F3BC)

| Function | Formula | Entry Size | Base |
|----------|---------|------------|------|
| Hero Address | id × 32 + $6000 | 32 bytes | $6000 |
| City Address | id × 12 + $63C0 | 12 bytes | $63C0 |
| Kingdom Address | pointer table at $F379 | 8 bytes | $6F07 (SRAM) |
| Hero Kata Name | id × 10 + $901A | 10 bytes | $901A |
| Hero Initial Data | id × 12 + $8000 | 12 bytes | $8000 |

### Sound Engine ($E57F–$E6C5)

- Namco-163 audio with wavetable synthesis
- Sound init ($E590), wavetable write ($E5FA), note player ($E609)
- 8 sound wrapper variants ($E66B–$E6A4)
- 3 high-level wrappers: $E673 (music A), $E67B (music B), $E683 (sound C)

## Interrupt Handlers

### NMI Handler ($F800–$FAA8)

- Entry at $F800
- Sub-dispatch table at $F87B (8 address pairs)
- 8 sub-state handlers dispatched by `$0078 AND #$0F`
- Includes palette swap ($FAA9/$FABF), scroll mode ($FAD5), controller read ($FB0B)

### IRQ Handler ($FB2D–$FF5E)

- Entry at $FB2D
- Dispatches by `$0060` to 14+ sub-states
- Mid-frame raster/CHR bank switching effects with timing loops

## Bank Switching

Namco-163 PRG bank registers:

| Register | Slot Range | Size |
|----------|------------|------|
| $C000 | $C000–$CFFF | 4KB |
| $C800 | $C800–$CFFF | 4KB |
| $D000 | $D000–$DFFF | 4KB |
| $D800 | $D800–$DFFF | 4KB |
| $F800 | $E000–$FFFF | 8KB (fixed) |

Bank switch function `$E51F` reads 8-byte config from table `$E567` indexed by A×8.

## Source Files

- Assembly: `asm/banks/prg_1f.aligned.asm`
- Analysis: `code/bank_1f_analysis.md`
- Function Table: `code/bank_1f_function_table.md`
