# Bank 0x1F Analysis Plan

## Overview
Bank 0x1F ($E000-$FFFF) is the boot bank (8KB). It contains the reset handler, state dispatch, NMI/IRQ handlers, sound engine, PPU utilities, math routines, controller I/O, and data tables. This document tracks which regions are analyzed and plans future sessions.

## Analysis Status

### DONE (Session 1)
- $E000-$E079: Reset handler
- $E07C-$E099: Vector dispatch table (15 entries)
- $E09A-$E4D9: All 15 vector destination handlers (entries 0-14)
- $E4DA-$E51E: Frame Init helper
- $E51F-$E566: Bank Switch helper
- $E567-$E57E: Bank switch data table
- $E2C2-$E2DD: Domestic affairs data tables
- $E87A-$E889: RNG function
- $F2AF-$F3BC: Data access functions (hero/city/kingdom/kata/initial)

### DONE (Session 2 - Math Library)
- $E9BA-$EA7B: 24-bit binary to 6-digit BCD conversion (repeated subtraction by powers of 10)
- $EA7C-$EAA4: 16-bit unsigned division (shift-and-subtract, 16 iterations)
- $EAA5-$EADD: 24-bit unsigned division (shift-and-subtract, 24 iterations)
- $EADE-$EAF6: Callback dispatcher (inline pointer table, JMP to banked function)
- $EB2D-$EBB0: BCD to binary converter (6 packed BCD digits -> 24-bit binary)
- $EBB1-$EBC9: Arithmetic helpers (nibble extract, 24-bit accumulate)
- $EBCA-$EBE8: Multiply-then-divide-by-100 (16-bit * 8-bit / 100)
- $EBE9-$EC21: 24x8 multiply (shift-and-add, 8 iterations, 32-bit result)
- $EC22-$EC66: 24x16 multiply (shift-and-add, 16 iterations, 40-bit result)

### NOT DONE - Grouped by Session

---

## Session 2: PPU & Display Infrastructure ($E57F-$E842)
Functions that handle PPU setup, palette upload, nametable fill, and sprite buffer init. These are called by the vector handlers and are prerequisites for understanding display flow.

| Range | Function | Notes |
|-------|----------|-------|
| $E57F-$E58F | Bank+PPU init + JMP patch | Called by Entry 0 and Frame Init |
| $E70E-$E748 | Palette upload | Uploads $0100-$011F to PPU $3F00 |
| $E749-$E752 | PPU mask helper | A=$1E or A=$00 |
| $E753-$E773 | PPU ctrl/NMI helpers | VBlank flag, NMI control |
| $E768-$E773 | PPU ctrl read | Also called as JSR $E768 |
| $E774-$E7DE | Nametable fill (mode 1) | Fills 3 nametables with value from $02/$03 |
| $E7DF-$E822 | Nametable fill (mode 2) | Same but with different init values ($AA) |
| $E823-$E842 | Sprite buffer init | Fills $0200-$02FF with $F0 |
| $EAF7-$EB2C | Scroll + PPU helpers | Scroll registers, BG offset, window reset |

---

## Session 3: Sound Engine ($E590-$E6A5)
The Namco-163 sound engine. Critical for understanding how music and SFX work.

| Range | Function | Notes |
|-------|----------|-------|
| $E590-$E608 | Sound init + IRQ timer | APU init, sound RAM clear, wavetable upload |
| $E5FA-$E608 | Wavetable write delay loop | Timing helper for $4800 writes |
| $E609-$E666 | Sound note player | Reads note data from banked ROM, writes to $0700-X RAM |
| $E667 | Sound channel table | 4 bytes: $0E, $0D, $0B, $07 |
| $E66B-$E6A5 | 8 sound wrapper functions | Chained PHA/JSR $E609/ADC #$01 sequences |
| $E6A6-$E6C5 | Wavetable init data | 32 bytes for Namco-163 $4800 |

---

## Session 4: Controller & RNG Helpers ($E6C6-$E8B9)
Controller reading and random number generation utilities.

| Range | Function | Notes |
|-------|----------|-------|
| $E6C6-$E70D | Controller read | 8-bit serial read from $4016/$4017 |
| $E843-$E84A | Random < 100 | JSR $E87A, loop if >= 100 |
| $E84B-$E851 | Random / 2 | JSR $E87A, LSR |
| $E850-$E861 | Random mod 4/8/16 | JSR $E87A, AND #$03/#$07/#$0F |
| $E862-$E879 | Random below threshold | Two variants: mod 16 or full range |
| $E87A-$E889 | RNG core | Table lookup, index at $0050 |
| $E88A-$E8B9 | RNG variants | 3 more RNG instances using $0052/$0054/$0055 |
| $E8BA-$E9B9 | RNG table | ~256 bytes of pre-computed random data |

---

## ~~Session 5: Math Library ($E9BA-$EC66)~~ - COMPLETED in Session 2

---

## Session 6: Number Display & Palette Animation ($EB2D-$ECEE)
PPU tile writing, number rendering, and palette animation effects. Note: $EB2D-$EBB0 (BCD to binary converter) was already analyzed in Session 2 (Math Library). Only $EC67-$ECEE remains.

| Range | Function | Notes |
|-------|----------|-------|
| $EB2D-$EBB0 | ~~BCD to binary converter~~ | **DONE** - Analyzed in Session 2 (Math Library) |
| $EC67-$ECED | Palette animation | Color rotation with frame counter $0087-$0089 |
| $ECEE-$ED18 | Palette scroll effects | Copy palette data between buffers |

---

## Session 7: Menu System ($ED19-$EE4D)
Menu cursor, scrolling, string lookup, and callback dispatch.

| Range | Function | Notes |
|-------|----------|-------|
| $ED19-$EDEC | Menu cursor/scroll | 8 entry points, directional movement via $0081 bits |
| $EDED-$EDF4 | Menu string lookup | Calculates offset from cursor position |
| $EDF5-$EE06 | Pointer table lookup | Reads 16-bit pointer from table |
| $EE07-$EE4D | Callback trampoline | Complex return-address manipulation for banked calls |

---

## Session 8: NMI Sub-Dispatch ($EE53-$EF70)
The $007E flag-based sub-dispatch system used by NMI handler.

| Range | Function | Notes |
|-------|----------|-------|
| $EE53-$EEE5 | NMI sub-dispatch (8 bits) | Tests bits of $007E, calls PPU writers |
| $EEE6-$EEF4 | NMI sub-dispatch (alt) | Same pattern but for different bit fields |
| $EF0B-$EF70 | PPU BG tile write | Writes tiles from $0140-X to PPU via $2006/$2007 |
| $EF71-$EFBF | PPU sprite tile write | Writes tiles from $0164-X to PPU |
| $EFC0-$F027 | PPU attr tile write | Writes attribute data from $0188-X |
| $F028-$F076 | PPU attr tile write (alt) | Same pattern from $019C-X |

---

## Session 9: PPU Tile Writers & CHR Banking ($F077-$F2AE)
Sprite OAM, CHR bank switching, and window setup.

| Range | Function | Notes |
|-------|----------|-------|
| $F077-$F091 | Namco-163 sound reg read | Reads $4800 via auto-increment |
| $F092-$F1A6 | Sprite OAM writer (scroll) | Converts sprite data with scroll offsets |
| $F1AD-$F205 | Sprite OAM writer (simple) | Direct sprite placement |
| $F206-$F236 | CHR bank switch | Writes 8 values to $8000-$B800 |
| $F237-$F265 | Window/display setup (3 variants) | Sets $00E2/$00E3, writes to $F000/$E800/$E000 |
| $F266-$F2AE | Window setup helpers | Various parameter formats |

---

## Session 10: Mapper Init & RAM Test ($F3BD-$F476)
Extended mapper init, controller validation, and RAM integrity check.

| Range | Function | Notes |
|-------|----------|-------|
| $F3BD-$F421 | Mapper init + ctrl check | Already partly documented |
| $F422-$F476 | RAM integrity test | Write/verify $AA pattern, LFSR-based |
| $F477-$F676 | Sound/music data | Large data block (instrument definitions?) |
| $F677-$F7FF | Padding ($FF fill) | Unused ROM space |

---

## Session 11: NMI Handler ($F800-$FAA8)
The main NMI handler - this is the biggest and most complex piece.

| Range | Function | Notes |
|-------|----------|-------|
| $F800-$F8B4 | NMI entry | Save regs, CHR setup, scroll, OAM DMA, sub-dispatch |
| $F87B-$F88C | NMI sub-dispatch table | 16 entries (8 pairs) pointing to handlers |
| $F88D-$F8B4 | NMI post-dispatch | Restore banks, inc RNG counters, RTI |
| $F8B5-$F8FE | NMI sub-state 0 | Main game frame: process input, display, scroll |
| $F8FE-$F967 | NMI sub-state 1 | Kingdom select frame |
| $F96A-$F99D | NMI sub-state 2 | Map view frame |
| $F9A0-$F9E1 | NMI sub-state 3 | Domestic affairs frame |
| $F9E4-$FA10 | NMI sub-state 4 | Simple display frame |
| $FA13-$FA50 | NMI sub-state 5 | Battle frame |
| $FA53-$FA94 | NMI sub-state 6 | Advisor frame |
| $FA97-$FAA8 | NMI sub-state 7 | Minimal frame |

---

## Session 12: Palette Swap, NMI Scroll, IRQ Handler ($FAA9-$FB2C)
Palette manipulation, NMI alternate mode, and helper functions.

| Range | Function | Notes |
|-------|----------|-------|
| $FAA9-$FABE | Palette swap A | Exchanges $81/$82 and $83/$85 if $6F44 != 0 |
| $FABF-$FAD4 | Palette swap B | Reverse of above |
| $FAD5-$FB0B | NMI scroll mode | Saves/restores CHR banks, special display |
| $FB0B-$FB2C | Controller read + bank restore | Reads input, restores bank regs from RAM |
| $FB28-$FB2C | Wait for $0062=0 | Spin loop |

---

## Session 13: IRQ Handler & Raster Effects ($FB2D-$FF5F)
The IRQ handler manages mid-frame raster effects via CHR bank switching.

| Range | Function | Notes |
|-------|----------|-------|
| $FB2D-$FB93 | IRQ entry | Save regs, check $5800, dispatch by $0060 |
| $FB94-$FBA4 | IRQ sub-state 0 | CHR bank setup from $006A/X table |
| $FBA4-$FC8B | IRQ sub-states 1-3 | CHR bank sequences with timing |
| $FC8B-$FD19 | IRQ sub-state 4 | Mid-frame raster with delay loops |
| $FD1A-$FD29 | IRQ timing data | Delay constant table |
| $FD2A-$FD94 | IRQ sub-state 5 | Raster with scroll write |
| $FD95-$FDF1 | IRQ sub-state 6 | Raster with bank switch |
| $FDF4-$FE02 | IRQ sub-state 7 | Minimal (SEI + restore) |
| $FE03-$FE68 | IRQ sub-states 8-9 | CHR bank with palette changes |
| $FE69-$FE95 | IRQ sub-state 10 | Direct CHR write |
| $FE96-$FECC | IRQ sub-state 11 | CHR + scroll + bank |
| $FECD-$FF30 | IRQ sub-state 12 | Raster with timing + PPU setup |
| $FF31-$FF5F | IRQ sub-states 13-14 | CHR bank changes |

---

## Session 14: Scroll Calculations & Vectors ($FF62-$FFFF)
Scroll address computation and interrupt vector table.

| Range | Function | Notes |
|-------|----------|-------|
| $FF62-$FF9A | Scroll calc A | Computes $009A/$009B from $0098, sets $00EA/$00EC |
| $FF9B-$FFD6 | Scroll calc B | Similar but adjusts $009B by +4 based on $0097 bit 0 |
| $FFD7-$FFF7 | Padding | $FF fill |
| $FFF8-$FFFF | Interrupt vectors | NMI=$00F8, RESET=$E000, IRQ=$FB2D (little-endian) |

---

## Priority & Dependencies

The sessions are ordered by dependency:
1. **Sessions 2-3** are highest priority - PPU and sound infrastructure is called by almost everything
2. **Session 4** is needed for understanding game flow (controller input drives state changes)
3. **Session 11** (NMI handler) is critical but large - it's what makes idle states work and drives per-frame logic
4. **Session 8** (NMI sub-dispatch) is a prerequisite for Session 11
5. **Sessions 5-7** (math, display, menu) are more self-contained
6. **Session 13** (IRQ/raster) is important for visual effects but can be deferred
7. **Session 10** (RAM test) and **Session 14** (vectors) are straightforward

## Cross-References to Other Banks

Functions in bank 0x1F frequently call bank-switched code at $A000-$A045:
- $A000: General display
- $A003: Text display
- $A006: Scenario/action display
- $A009: Kingdom display
- $A00C: Status display
- $A00F: Battle display
- $A012: Unknown
- $A015: Overlay display
- $A018: Advisor dialogue
- $A01B: Display mode setup
- $A01E: Unknown
- $A024: Domestic display
- $A027: Kingdom select display
- $A036: Unknown
- $A03F: Unknown
- $A045: Parameter display

These live in other banks and would need separate analysis sessions.
