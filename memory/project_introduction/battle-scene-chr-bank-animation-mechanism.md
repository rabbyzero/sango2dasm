# Battle scene CHR bank animation mechanism with 8-frame cycle

- **Category:** project_introduction
- **Memory ID:** ed1df3b6-d69e-4b50-ae03-1a94230a0638
- **Keywords:** CHR bank animation, BattleChrBankAnimate, Namco-163, VBlank handler, tile bank cycling, shadow registers

## Content

## Battle Scene CHR Bank Animation Mechanism

**Location**: `BattleChrBankAnimate` proc in prg_0e_0f.asm ($C01B-$C053)

**Purpose**: Per-VBlank animated CHR bank switching for battle scene terrain/effects. Creates visual animation by cycling between different tile banks every 8 frames.

**Registers involved**:
- `$005E`: Frame tick counter (incremented each NMI in `NmiEpilogue`)
- `$0544`: Battle scene phase indicator (value 3 triggers secondary animation set)
- `$00B3`, `$00B5`: Primary CHR bank 5/7 shadow registers (mirrors of Namco-163 CHR bank controls)
- `$00C3`, `$00CB`, `$00D3`, `$00DB`: Redundant copy pairs of the same slots (5 total pairs with stride +8)

**Animation logic**:
1. Row index = `(bits 3-4 of $005E) & 3` → changes every 8 frames (frame >> 3) & 3
2. If `$0544 == 3` (battle state), offset +4 into table (second animation set)
3. Table lookup at `$C054,Y` and `$C05C,Y` yields two CHR bank values per row
4. Values written to all 5 register pairs simultaneously

**Tile bank patterns**:
- Slot 5 (primary): cycles `$78/$79/$7A/$7B` (animated water/fire/effect tiles)
- Slot 7 (secondary): alternates `$18/$19` (complementary animation frame)

**Caller**: Solely invoked from `BattleVBlankFrameUpdate` ($A017: `JSR BattleChrBankAnimate`)

**Data structure**: `BattleChrBankAnimTable` encapsulated inside the proc scope (16 bytes at $C054-$C063)

This mechanism demonstrates the game's use of slow-per-frame animation (8-frame cycle) combined with phase-dependent variations to create dynamic battle scene visuals without excessive CPU overhead.
