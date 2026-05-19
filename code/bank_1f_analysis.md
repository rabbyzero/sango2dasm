# Bank 0x1F Disassembly Analysis - Sangokushi 2

## Overview
- **Bank Number**: 0x1F (31)
- **Address Range**: $E000-$FFFF (8KB)
- **Role**: Boot bank - contains reset handler, state dispatch, NMI/IRQ handlers, sound engine, PPU utilities, math routines, controller I/O, and data tables
- **Fixed Slot**: Mapped to $E000-$FFFF at reset (PRG slot 3)
- **Interrupt Vectors** ($FFFA-$FFFF): NMI=$F800, RESET=$E000, IRQ=$FB2D

---

## Analysis Progress

| Session | Regions Analyzed | Status |
|---------|-----------------|--------|
| 1 | $E000-$E079 (Reset), $E07C-$E099 (Vectors), $E09A-$E4D9 (Handlers), $E4DA-$E566 (Helpers), $E87A-$E889 (RNG), $F2AF-$F3BC (Data Access) | DONE |
| 2 | $E9BA-$EC66 (Math Library - 10 functions: BCD conv, division x2, multiply x2, callback, helpers, mul/div100) | DONE |
| 3 | $ED19-$EE4D (Menu System - cursor engine, string lookup, pointer table, callback trampoline), $E6C6 (Controller Read) | IN PROGRESS |

---

## $E000-$E079: Reset Handler

```asm
$E000: SEI              ; Disable interrupts
$E001: CLD              ; Clear decimal mode
$E002-$E018: PPU warmup ; Wait for 3 VBlanks ($2002 polling)
$E019-$E027: APU init   ; Initialize $4010, $4015, $4017
$E028-$E03E: PPU warmup ; Second VBlank wait (4 times)
$E03F: LDX #$FF         ; Set stack pointer
$E041: TXS
$E042-$E05C: Clear RAM  ; Zero out $0000-$07FF (2KB)
$E05E: JSR $F3BD        ; Mapper init + controller check
$E061: LDA #$00
$E063: STA $007A        ; Initialize state counter to 0
$E066: LDA $007A        ; Read state counter
$E069: AND #$1F         ; Mask to 0-31
$E06B: ASL              ; Multiply by 2 (16-bit vectors)
$E06C: TAY
$E06D: LDA $E07C,Y      ; Load vector from table
$E070: STA $004E
$E073: LDA $E07D,Y
$E076: STA $004F
$E079: JMP ($004E)      ; Jump to entry point
```

**Key Variables**:
- `$007A` - Game state counter (determines which entry point to call)
- `$E07C-$E099` - Vector table (15 entries, 2 bytes each)
- `$004E/$004F` - Indirect jump target

---

## $E07C-$E099: Vector Dispatch Table

15 entries (indices 0-14), each 2 bytes (little-endian pointers), spanning $E07C-$E099 (30 bytes). Indexed by `$007A AND #$1F * 2`. Index 15+ reads into the code area starting at $E09A, which is NOT a valid vector.

| Entry | Addr | Raw Bytes | Purpose |
|-------|------|-----------|---------|
| 0 | $E09A | $9A $E0 | System Init |
| 1 | $E0DA | $DA $E0 | New Game Init |
| 2 | $E17D | $7D $E1 | Random + Display (Y=#2A) |
| 3 | $E18B | $8B $E1 | Kingdom Select |
| 4 | $E221 | $21 $E2 | Random + Display (Y=#28) |
| 5 | $E22F | $2F $E2 | Domestic Affairs |
| 6 | $E2E2 | $E2 $E2 | Random Seed Advance |
| 7 | $E2E8 | $E8 $E2 | Battle Phase |
| 8 | $E36A | $6A $E3 | Random Seed Advance |
| 9 | $E37C | $7C $E3 | Territory / Map View |
| 10 | $E3EB | $EB $E3 | Idle / Wait State |
| 11 | $E3EE | $EE $E3 | Advisor / Council |
| 12 | $E3EB | $EB $E3 | Idle / Wait State (same as 10) |
| 13 | $E46A | $6A $E4 | Turn Summary |
| 14 | $E3EB | $EB $E3 | Idle / Wait State (same as 10) |

**Note**: The table ends at $E099. The bytes at $E09A (`$20 $68`) are the first two bytes of Entry 0's code (`JSR $E768`), not a 16th vector entry. They coincidentally decode to $6820 when misread as a pointer. The dispatch loop masks `$007A` to `AND #$1F` (0-31), but only indices 0-14 are valid; index 15+ would read code bytes as vector data, producing garbage addresses. Entries 10, 12, 14 all point to the same idle handler at $E3EB.

---

## $E09A: Entry 0 - System Init (61 bytes, JMP $E066)

```asm
$E09A: JSR $E768       ; Read PPU status
$E09D: JSR $E74D       ; Wait for VBlank
$E0A0: STA $2001       ; PPU mask - disable rendering
$E0A3: JSR $E57F       ; Bank switch setup + PPU init
$E0A6: LDX #$1F       ; Fill sprite buffer
$E0A8: LDA #$0F
$E0AA: STA $0100,X    ; $0100-$011F = $0F (palette data)
$E0AD: DEX
$E0AE: BPL $E0AA
$E0B0: LDA $2002      ; Wait for VBlank
$E0B3: BPL $E0B0
$E0B5: LDA #$4C       ; JMP opcode ($4C)
$E0B7: STA $00A5      ; Patch RAM at $00A5
$E0BA: STA $F800      ; Patch mapper register
$E0BD: LDA #$00
$E0BF: JSR $E51F      ; Bank switch (config 0)
$E0C2: LDA #$10       ; NMI enable + sprite height
$E0C4: STA $008B      ; RAM copy of PPU ctrl
$E0C7: STA $2000      ; PPU control register
$E0CA: LDA #$00       ; Rendering off
$E0CC: STA $008C      ; RAM copy of PPU mask
$E0CF: STA $2001      ; PPU mask register
$E0D2: LDA #$09       ; Next state = 9
$E0D4: STA $007A
$E0D7: JMP $E066      ; Return to dispatch
```

**Analysis**: Boot sequence initialization. Sets up PPU (NMI enabled, rendering disabled), fills sprite palette buffer ($0100-$011F) with $0F, patches a JMP opcode into RAM ($00A5) and mapper ($F800), switches to bank config 0, then transitions to state 9 (Idle/Wait).

---

## $E0DA: Entry 1 - New Game Init (~160 bytes, JMP $E066)

```asm
$E0DA: JSR $E4DA       ; Frame init
$E0DD: LDA #$02
$E0DF: STA $0078       ; Sub-state = 2
$E0E2: LDA #$00
$E0E4: JSR $E370       ; Display init (mode 0)
$E0E7: LDY #$30
$E0E9: JSR $F25F      ; Window setup
$E0EC: LDA #$00
$E0EE: STA $000A       ; Ptr low
$E0F1: LDA #$80
$E0F3: STA $000B       ; Ptr high -> $8000
$E0F6: LDA #$20
$E0F8: STA $0001       ; Width param
$E0FB-$E10B: Clear $0000,$0004-$0006; set $0007=04
$E10E: LDY #$37
$E110: JSR $F237
$E113: JSR $A003      ; Display (bank-switched)
$E116-$E120: Window + render calls
$E123: JSR $EAF7      ; Read controller input
$E126: LDA $0400      ; Check input
$E129: CMP #$0D       ; Button check
$E12B: BEQ $E132      ; Skip flag if $0D
$E12D: LDA #$FF
$E12F: STA $6F8B      ; Set SRAM flag
$E132-$E144: More display + render calls
$E147: LDA #$A0
$E149: STA $0098
$E14C-$E15A: Clear $0420,$04E0-$04E3
$E15D: LDA #$F0
$E15F: STA $6F41      ; SRAM init: kingdom param
$E162: LDA #$80
$E164: STA $6F3F      ; SRAM init: kingdom param
$E167: LDA #$00
$E169: JSR $E51F      ; Bank switch (config 0)
$E16C: INC $007A      ; Next state
$E16F: LDA #$81
$E171: JSR $E673      ; Music ($81)
$E174: JSR $E749
$E177: JSR $E753
$E17A: JMP $E066      ; Return to dispatch
```

**Analysis**: New game initialization. Sets up display (sub-state 2, display mode 0), shows content via bank-switched functions, reads controller input checking for button $0D. Initializes kingdom SRAM ($6F41=$F0, $6F3F=$80, $6F8B=$FF). Plays music $81.

---

## $E17D: Entry 2 - Random + Display (11 bytes, JMP $E066)

```asm
$E17D: JSR $E87A      ; Get random byte
$E180: LDY #$2A
$E182: JSR $F24B      ; Window/display function
$E185: JSR $A000      ; Display function (bank-switched)
$E188: JMP $E066      ; Return to dispatch
```

**Analysis**: Brief transition state. Generates random value, displays content with Y=#$2A, returns to dispatch. Likely a dice-roll or splash screen between phases.

---

## $E18B: Entry 3 - Kingdom Select (~160 bytes, JMP $E066)

```asm
$E18B: JSR $E4DA      ; Frame init
$E18E: LDA #$03
$E190: STA $0078      ; Sub-state = 3
$E193: LDA #$01
$E195: JSR $E370       ; Display init (mode 1)
$E198: LDY #$37
$E19A: JSR $F237
$E19D: JSR $A027      ; Kingdom display (bank-switched)
$E1A0: LDA $0500      ; Load kingdom mode
$E1A3: CMP #$0B       ; Scenario mode?
$E1A5: BNE $E1B2      ; If not, normal path
$E1A7: LDY #$2C
$E1A9: JSR $F237      ; Scenario display
$E1AC: JSR $A006      ; Scenario function
$E1AF: JMP $E1BA
$E1B2: LDY #$28
$E1B4: JSR $F237      ; Normal display
$E1B7: JSR $A003      ; Normal function
$E1BA: LDA $0510      ; Kingdom coords
$E1BD: STA $0090
$E1C0: LDA $0511
$E1C3: STA $0091
$E1C6: LDA $0512
$E1C9: STA $008E
$E1CC: LDA $0513
$E1CF: STA $008F
$E1D2: LDA #$FF
$E1D4: STA $0518      ; Kingdom flag
$E1D7-$E1EC: Display + render + input
$E1EF: LDA #$00
$E1F1: STA $0508
$E1F4: LDA #$70
$E1F6: STA $0068      ; Ptr low -> $AF70
$E1F9: LDA #$AF
$E1FB: STA $0069      ; Ptr high
$E1FE: LDA #$01
$E200: JSR $E51F      ; Bank switch (config 1)
$E203-$E20D: Display params
$E210: INC $007A      ; Next state
$E213: LDA #$1D
$E215: JSR $E673      ; Music ($1D)
$E218-$E21E: Display updates
$E21E: JMP $E066      ; Return to dispatch
```

**Analysis**: Kingdom selection screen. Player chooses which kingdom to play. Checks $0500 for game mode: if $0B, scenario mode ($A006); otherwise normal ($A003). Loads kingdom position data ($0510-$0513 -> $0090/$0091/$008E/$008F). Sets pointer $0068/$0069 = $AF70 (territory data). Bank switch config 1, music $1D.

---

## $E221: Entry 4 - Random + Display (11 bytes, JMP $E066)

```asm
$E221: JSR $E87A      ; Get random byte
$E224: LDY #$28
$E226: JSR $F24B      ; Window/display function
$E229: JSR $A000      ; Display function (bank-switched)
$E22C: JMP $E066      ; Return to dispatch
```

**Analysis**: Same pattern as Entry 2 but with Y=#$28 instead of Y=#$2A. Different display content.

---

## $E22F: Entry 5 - Domestic Affairs (114 bytes, JMP $E066)

```asm
$E22F: JSR $E4DA      ; Frame init
$E232: LDA #$04
$E234: STA $0078      ; Sub-state = 4
$E237: LDA $0544      ; Domestic action type
$E23A: CLC
$E23B: ADC #$02       ; Action + 2
$E23D: JSR $E370       ; Display init (dynamic mode)
$E240: LDA #$02
$E242: JSR $E51F      ; Bank switch (config 2)
$E245-$E25B: Window + display + render calls
$E25E: LDY $0563      ; Sprite Y index
$E261: LDA $E2DE,Y    ; Sprite position from table
$E264: STA $0107      ; Position for action indicator
$E267: STA $0113      ; Mirror
$E26A: LDY $0562      ; Second sprite Y index
$E26D: LDA $E2DE,Y
$E270: STA $010F
$E273: STA $0117
$E276: JSR $EAF7      ; Read controller input
$E279-$E288: Display + render + update
$E28B: INC $007A      ; Next state
$E28E: LDA #$0D
$E290: JSR $E683      ; Sound ($0D)
$E293-$E299: Display updates
$E299: JMP $E066      ; Return to dispatch
```

**Sub-function $E29C (RTS $E2C1)**: Domestic action display lookup
```asm
$E29C: LDA $0544      ; Action type (0-6)
$E29F: ASL            ; * 2 for table index
$E2A0: TAY
$E2A1: LDA $E2C2,Y   ; Action graphic ptr low
$E2A4: STA $000A
$E2A7: LDA $E2C3,Y   ; Action graphic ptr high
$E2AA: STA $000B
$E2AD: LDA $E2D0,Y   ; Base data ptr low
$E2B0: STA $000C
$E2B3: LDA $E2D1,Y   ; Base data ptr high
$E2B6: STA $000D
$E2B9: LDY #$37
$E2BB: JSR $F237
$E2BE: JSR $A006      ; Action display (bank-switched)
$E2C1: RTS
```

**Data tables at $E2C2**:
- **$E2C2** (action graphic pointers, 7 entries): $8440, $8570, $86A0, $87D0, $8900, $8A30, $8B60
- **$E2D0** (base data pointers, 7 entries): all 7 entries point to $8000
- **$E2DE** (sprite Y positions, 4 bytes): $10, $0F, $00, $16

**Analysis**: Domestic affairs / strategy phase. Player selects actions (farming, commerce, etc.). $0544 selects action type (0-6). Each action has dedicated graphics ($E2C2 table) and base data ($8000). Sprite positions from table $E2DE via $0563/$0562.

---

## $E2E2: Entry 6 - Random Seed Advance (8 bytes, JMP $E066)

```asm
$E2E2: JSR $E87A      ; Get random byte
$E2E5: JMP $E066      ; Return to dispatch
```

**Analysis**: Pure RNG advance with no display. Used before states that need a fresh random value.

---

## $E2E8: Entry 7 - Battle Phase (~120 bytes, JMP $E066)

```asm
$E2E8: JSR $E4DA      ; Frame init
$E2EB: LDA #$05
$E2ED: STA $0078      ; Sub-state = 5
$E2F0: LDA #$0A       ; Battle display mode
$E2F2: JSR $E370       ; Display init (mode $0A)
$E2F5: LDA #$A0
$E2F7: STA $0098
$E2FA: LDY #$30
$E2FC: JSR $F25F      ; Window setup
$E2FF: LDA #$00
$E301: STA $000A       ; Ptr low
$E304: LDA #$84
$E306: STA $000B       ; Ptr high -> $8400
$E309-$E325: Display params + render calls
$E328: JSR $EAF7      ; Read controller input
$E32B: LDX #$00
$E32D: LDA $04AB      ; Army status 1
$E330: CMP #$01
$E332: BNE $E33A
$E334: STX $0106      ; Clear sprite if army=1
$E337: STX $0116
$E33A: LDA $04AC      ; Army status 2
$E33D: CMP #$01
$E33F: BNE $E347
$E341: STX $010E      ; Clear sprite if army=1
$E344: STX $011A
$E347-$E358: Screen update + render
$E359: INC $007A      ; Next state
$E35C: LDA #$12
$E35E: JSR $E67B      ; Battle music ($12)
$E361-$E367: Display updates
$E367: JMP $E066      ; Return to dispatch
```

**Analysis**: Battle/combat phase. Display data from $8400 (army graphics). Checks army status flags $04AB/$04AC: if flag=1, clears corresponding sprite data. Plays battle music $12 via $E67B.

---

## $E36A: Entry 8 - Random Seed Advance (8 bytes, JMP $E066)

```asm
$E36A: JSR $E87A      ; Get random byte
$E36D: JMP $E066      ; Return to dispatch
```

**Analysis**: Same as Entry 6. Pure RNG advance, no display.

---

## $E370: Display Init Helper (12 bytes, RTS at $E37B)

```asm
$E370: LDY #$3D
$E372: JSR $F237      ; Window clear
$E375: JSR $A01B      ; Bank-switched display
$E378: JSR $F206      ; Window/display helper
$E37B: RTS
```

Called by most complex entries to set up display mode before rendering. Parameter A is passed through to $E370's caller context (used as display mode index by the caller before calling $E370).

---

## $E37C: Entry 9 - Territory / Map View (~108 bytes, JMP $E066)

```asm
$E37C: JSR $E4DA      ; Frame init
$E37F: LDA #$06
$E381: STA $0078      ; Sub-state = 6
$E384: LDA #$0B       ; Territory display mode
$E386: JSR $E370       ; Display init (mode $0B)
$E389: LDY #$35
$E38B: JSR $F25F      ; Window setup
$E38E: LDA #$90
$E390: STA $000A       ; Ptr low
$E393: LDA #$9A
$E395: STA $000B       ; Ptr high -> $9A90
$E398-$E3C5: Display params + render + input + update
$E3C8: JSR $ECBF      ; Screen update
$E3CB-$E3D7: More render + display
$E3DA: LDA #$02
$E3DC: JSR $E51F      ; Bank switch (config 2)
$E3DF: INC $007A      ; Next state
$E3E2-$E3E8: Display updates
$E3E8: JMP $E066      ; Return to dispatch
```

**Analysis**: Territory/map view. Displays game map with territory data from $9A90. Bank switch config 2.

---

## $E3EB: Entry 10/12/14 - Idle / Wait State (3 bytes, JMP $E066)

```asm
$E3EB: JMP $E066      ; Immediately return to dispatch
```

**Analysis**: Null state that immediately loops back to dispatch. The NMI handler at $F800 likely modifies $007A to break out of this loop. Used as a frame wait state.

---

## $E3EE: Entry 11 - Advisor / Council (~120 bytes, JMP $E066)

```asm
$E3EE: JSR $E4DA      ; Frame init
$E3F1: LDA #$07
$E3F3: STA $0078      ; Sub-state = 7
$E3F6: LDA #$0C       ; Advisor display mode
$E3F8: JSR $E370       ; Display init (mode $0C)
$E3FB: LDY #$32
$E3FD: JSR $F25F      ; Window setup
$E400: LDA #$E3
$E402: STA $000A       ; Ptr low
$E405: LDA #$9A
$E407: STA $000B       ; Ptr high -> $9AE3
$E40A-$E427: Display params + render calls
$E42A-$E437: Window + advisor dialogue ($A018)
$E43F: JSR $EAF7      ; Read controller input
$E442-$E458: Screen update + render + bank switch
$E459: INC $007A      ; Next state
$E45C: LDA #$08
$E45E: JSR $E683      ; Sound ($08)
$E461-$E467: Display updates
$E467: JMP $E066      ; Return to dispatch
```

**Analysis**: Advisor/council phase. Displays advisor dialogue with data from $9AE3. Uses unique bank-switched function $A018 (advisor dialogue). Sound $08. Bank switch config 2.

---

## $E46A: Entry 13 - Turn Summary (~108 bytes, JMP $E066)

```asm
$E46A: JSR $E4DA      ; Frame init
$E46D: LDA #$08
$E46F: STA $0078      ; Sub-state = 8
$E472: LDA #$0D       ; Report display mode
$E474: JSR $E370       ; Display init (mode $0D)
$E477: LDY #$36
$E479: JSR $F25F      ; Window setup
$E47C: LDA #$92
$E47E: STA $000A       ; Ptr low
$E481: LDA #$9B
$E483: STA $000B       ; Ptr high -> $9B92
$E486-$E4A5: Display params + render + input
$E4A8-$E4B9: Render + bank switch
$E4BC: INC $007A      ; Next state
$E4BF: LDY $0541      ; Check completion flag
$E4C2: BNE $E4CC      ; If nonzero, victory music
$E4C4: LDA #$98
$E4C6: JSR $E673      ; Normal music ($98)
$E4C9: JMP $E4D1
$E4CC: LDA #$AA
$E4CE: JSR $E67B      ; Victory music ($AA)
$E4D1-$E4D7: Display updates
$E4D7: JMP $E066      ; Return to dispatch
```

**Analysis**: Turn summary/report screen. Shows end-of-turn results with data from $9B92. Checks $0541: if 0, plays normal music ($98 via $E673); if nonzero, plays victory music ($AA via $E67B). Bank switch config 2.

---

## $E4DA: Frame Init Helper

Called by entries 1, 3, 5, 7, 9, 11, 13. Per-frame setup:

```asm
$E4DA: JSR $E768      ; Read PPU status
$E4DD: JSR $E74D      ; Wait for VBlank
$E4E0: STA $2001      ; PPU mask (disable rendering)
$E4E3: JSR $E57F      ; Bank switch + PPU init
$E4E6: JSR $E7DF      ; Additional display update
$E4E9: LDA #$00       ; Clear working RAM
$E4EB-$E511: Clear $0090,$0091,$008E,$008F,$0098,$0099,$0096,$0097,$007E,$005E,$005F,$008D,$00A4
$E514: LDA #$FF       ; Set sentinel values
$E516: STA $0300
$E519: STA $0304
$E51C: JMP $E823      ; Continue init (sprite/PPU setup)
```

Clears display working RAM, sets sentinel values, then jumps to $E823 for additional initialization.

---

## $E51F: Bank Switch (32 bytes, RTS at $E566)

```asm
$E51F: ASL            ; A * 2
$E520: ASL            ; A * 4
$E521: ASL            ; A * 8 -> Y = table offset
$E522: TAY
$E523: LDA $E567,Y   ; Load bank config from table
$E526: STA $00E6      ; RAM copy
$E529: STA $C000      ; Write mapper register 1
$E52C: INY
$E52D: LDA $E567,Y   ; Next bank config
$E530: STA $00E7
$E533: STA $C800      ; Write mapper register 2
$E536: INY
$E537: LDA $E567,Y
$E53A: STA $00E8
$E53D: STA $D000      ; Write mapper register 3
$E540: INY
$E541: LDA $E567,Y
$E544: STA $00E9
$E547: STA $D800      ; Write mapper register 4
$E54A-$E566: Load 4 more values to $00EA-$00ED
$E566: RTS
```

Reads 8-byte config from table $E567 at offset A*8. First 4 bytes write to Namco-163 mapper registers $C000/$C800/$D000/$D800 (PRG bank switching). Last 4 bytes stored in RAM $00EA-$00ED.

**Bank switch table $E567** (8 bytes per config):
- Config 0: $E0,$E1,$E1,$E1,$E0,$E1,$E0,$E1 (all banks 0/1, init state)
- Config 1: $E0,$E0,$E0,$E0,... (all bank 0, data access)
- Config 2: $E0,$E1,$E0,$E1,... (alternating banks 0/1, game display)

(Note: exact bank numbers need Namco-163 decoding: low 5 bits = bank number, high 3 bits = flags)

---

## $E57F-$E58F: Bank+PPU Init *(not yet analyzed in detail)*

Called by Entry 0 and Frame Init. Bank switch setup + PPU initialization + JMP patch.

---

## $E590-$E6A5: Sound Engine *(not yet analyzed)*

Namco-163 sound engine. Includes sound init + IRQ timer ($E590), wavetable write ($E5FA), note player ($E609), channel table ($E667), 8 sound wrapper functions ($E66B-$E6A5), wavetable init data ($E6A6-$E6C5).

---

## $E673/$E67B/$E683: Sound Wrapper Functions

- `$E673`: Music/sound A - called with sound ID in A. Used by entries 1 ($81), 3 ($1D)
- `$E67B`: Music/sound B - called with sound ID in A. Used by entry 7 ($12)
- `$E683`: Music/sound C - called with sound ID in A. Used by entries 5 ($0D), 11 ($08)

These are likely thin wrappers that push A, call a common sound engine ($E609), then increment A and call again (chained note sequences). Each plays a different pattern of notes.

---

## $E6C6-$E8B9: Controller & RNG Helpers *(partially analyzed)*

### $E87A: Random Seed - RNG Core (10 bytes, RTS at $E889)

```asm
$E87A: STX $0051     ; Save X register
$E87D: LDX $0050     ; Load current RNG index from $0050
$E880: LDA $E8BA,X   ; Read byte from pre-computed random table
$E883: INC $0050     ; Advance table index
$E886: LDX $0051     ; Restore X register
$E889: RTS            ; Return with random byte in A
```

**Type**: Sequential table lookup (NOT LCG). Reads bytes one-by-one from a pre-computed table at $E8BA. Index stored at $0050, incremented each call.

**Other RNG functions** *(not yet analyzed)*:
- $E843: Random < 100
- $E84B: Random / 2
- $E850: Random mod 4/8/16
- $E862: Random below threshold
- $E88A-$E8B9: RNG variants using $0052/$0054/$0055
- $E8BA-$E9B9: RNG table (~256 bytes of pre-computed random data)

---

## $E9BA-$EA7B: Math - 24-bit Binary to 6-digit BCD Conversion (194 bytes, RTS at $EA7B)

Converts a 24-bit binary value to 6 packed BCD digits using repeated subtraction by powers of 10.

**Input**: $01/$02/$03 = 24-bit little-endian value (mod 1,000,000)
**Output**: $07/$08/$09 = 6 packed BCD digits (tens/ones, hundreds/thousands, ten-thousands/hundred-thousands)
**Clobbers**: $01-$05 (dividend reduced to remainder, then reused)

### Algorithm

The function uses 6 successive subtraction loops, one for each power of 10 from largest to smallest. Each loop subtracts a constant and increments a BCD digit accumulator. The BCD encoding uses the upper nibble for the higher place and lower nibble for the lower place within each byte.

### Detailed Disassembly

```asm
; === Initialize BCD digit accumulators ===
$E9BA: LDA #$00
$E9BC: STA $07       ; BCD digits 5-4 (tens/ones)
$E9BE: STA $08       ; BCD digits 3-2 (hundreds/thousands)
$E9C0: STA $09       ; BCD digits 1-0 (ten-thousands/hundred-thousands)

; === Loop 1: Subtract 1,000,000 ($0F4240) - safety clamp ===
; This loop reduces values >= 1,000,000 without counting.
; If input is always < 1,000,000 (as expected), this loop never executes.
$E9C2: LDA $01       ; Low byte
$E9C4: SEC
$E9C5: SBC #$40      ; Subtract $0F4240 low
$E9C7: STA $04       ; Temp store
$E9C9: LDA $02       ; Mid byte
$E9CB: SBC #$42      ; Subtract $0F4240 mid
$E9CD: STA $05
$E9CF: LDA $03       ; High byte
$E9D1: SBC #$0F      ; Subtract $0F4240 high
$E9D3: BCC $E9E2     ; Borrow = value < 1,000,000, skip
$E9D5: STA $03       ; Update dividend (mod 1,000,000)
$E9D7: LDA $04
$E9D9: STA $01
$E9DB: LDA $05
$E9DD: STA $02
$E9DF: JMP $E9C2     ; Repeat

; === Loop 2: Subtract 100,000 ($0186A0) ===
; Counts into upper nibble of $09 (hundred-thousands digit)
$E9E2: LDA $01       ; Low byte
$E9E4: SEC
$E9E5: SBC #$A0      ; Subtract $0186A0 low
$E9E7: STA $04
$E9E9: LDA $02       ; Mid byte
$E9EB: SBC #$86      ; Subtract $0186A0 mid
$E9ED: STA $05
$E9EF: LDA $03       ; High byte
$E9F1: SBC #$01      ; Subtract $0186A0 high
$E9F3: BCC $EA07     ; Borrow = done with 100,000s
$E9F5: STA $03       ; Update dividend
$E9F7: LDA $04
$E9F9: STA $01
$E9FB: LDA $05
$E9FD: STA $02
$E9FF: LDA $09       ; Increment hundred-thousands digit
$EA01: ADC #$0F      ; ADC #$0F with carry=1 = ADC #$10 = add 1 to upper nibble
$EA03: STA $09
$EA05: BNE $E9E2     ; Always loops (BNE, $09 won't be 0 after adding $10)

; === Loop 3: Subtract 10,000 ($002710) ===
; Counts into lower nibble of $09 (ten-thousands digit)
$EA07: LDA $01
$EA09: SEC
$EA0A: SBC #$10      ; Subtract $002710 low
$EA0C: STA $04
$EA0E: LDA $02
$EA10: SBC #$27      ; Subtract $002710 mid
$EA12: STA $05
$EA14: LDA $03
$EA16: SBC #$00      ; Subtract $002710 high (= 0)
$EA18: BCC $EA28     ; Borrow = done with 10,000s
$EA1A: STA $03
$EA1C: LDA $04
$EA1E: STA $01
$EA20: LDA $05
$EA22: STA $02
$EA24: INC $09       ; Add 1 to lower nibble of $09
$EA26: BNE $EA07     ; Always loops

; === Loop 4: Subtract 1,000 ($03E8) ===
; Counts into upper nibble of $08 (thousands digit)
$EA28: LDA $01
$EA2A: SEC
$EA2B: SBC #$E8      ; Subtract $03E8 low
$EA2D: STA $04
$EA2F: LDA $02
$EA31: SBC #$03      ; Subtract $03E8 mid
$EA33: BCC $EA43     ; Borrow = done with 1,000s
$EA35: STA $02
$EA37: LDA $04
$EA39: STA $01
$EA3B: LDA $08       ; Increment thousands digit
$EA3D: ADC #$0F      ; ADC #$0F with carry=1 = add $10 to upper nibble
$EA3F: STA $08
$EA41: BNE $EA28     ; Always loops

; === Loop 5: Subtract 100 ($0064) ===
; Counts into lower nibble of $08 (hundreds digit)
$EA43: LDA $01
$EA45: SEC
$EA46: SBC #$64      ; Subtract $64 = 100
$EA48: STA $04
$EA4A: LDA $02
$EA4C: SBC #$00      ; High byte = 0
$EA4E: BCC $EA5A     ; Borrow = done with 100s
$EA50: STA $02
$EA52: LDA $04
$EA54: STA $01
$EA56: INC $08       ; Add 1 to lower nibble of $08
$EA58: BNE $EA43     ; Always loops

; === Loop 6: Subtract 10 ($000A) ===
; Counts into upper nibble of $07 (tens digit)
$EA5A: LDA $01
$EA5C: SEC
$EA5D: SBC #$0A      ; Subtract 10
$EA5F: STA $04
$EA61: LDA $02
$EA63: SBC #$00
$EA65: BCC $EA75     ; Borrow = done with 10s
$EA67: STA $02
$EA69: LDA $04
$EA6B: STA $01
$EA6D: LDA $07       ; Increment tens digit
$EA6F: ADC #$0F      ; Add $10 to upper nibble
$EA71: STA $07
$EA73: BNE $EA5A     ; Always loops

; === Final: Combine ones digit ===
$EA75: LDA $01       ; Remaining value = ones digit (0-9)
$EA77: ORA $07       ; Merge into lower nibble of $07
$EA79: STA $07       ; $07 = (tens << 4) | ones
$EA7B: RTS
```

### BCD Digit Layout

| Byte | Upper Nibble | Lower Nibble |
|------|-------------|-------------|
| $09 | Hundred-thousands | Ten-thousands |
| $08 | Thousands | Hundreds |
| $07 | Tens | Ones |

### Subtraction Constants

| Constant | Hex (24-bit) | Decimal | BCD Digit Updated |
|----------|-------------|---------|-------------------|
| 1,000,000 | $0F4240 | 10^6 | (clamp only, no digit) |
| 100,000 | $0186A0 | 10^5 | $09 upper nibble |
| 10,000 | $002710 | 10^4 | $09 lower nibble |
| 1,000 | $0003E8 | 10^3 | $08 upper nibble |
| 100 | $000064 | 10^2 | $08 lower nibble |
| 10 | $00000A | 10^1 | $07 upper nibble |
| 1 | (remainder) | 10^0 | $07 lower nibble |

### Design Notes

- The BCD accumulation uses `ADC #$0F` with carry=1 (from successful subtraction), which equals `ADC #$10`. This sets the upper nibble bit pattern directly, producing valid BCD encoding.
- `INC` is used for lower nibble positions, incrementing by 1 within the nibble (digits 0-9).
- The first loop (1,000,000 subtraction) acts as a mod operation. For values >= 1,000,000, it silently discards the millions place. The function is designed for values 0-999,999.
- The `BNE` at each loop end always branches because the BCD accumulator byte is never zero after being incremented (either $10+ or $01+). This is an optimization over `JMP` - saves 1 byte per loop.

---

## $EA7C-$EAA4: Math - 16-bit Unsigned Division (41 bytes, RTS at $EAA4)

Standard shift-and-subtract (non-restoring) division algorithm with 16 iterations.

**Input**:
- $01/$02 = dividend (16-bit, little-endian)
- $03/$04 = divisor (16-bit, little-endian)

**Output**:
- $01/$02 = quotient (16-bit, replaces dividend)
- $05/$06 = remainder (16-bit)

```asm
$EA7C: LDA #$00
$EA7E: STA $05       ; Clear remainder low
$EA80: STA $06       ; Clear remainder high
$EA82: LDY #$0F      ; 16 iterations (bits 15..0)
$EA84: ASL $01       ; Shift dividend left, MSB -> carry
$EA86: ROL $02       ; Propagate carry through dividend high
$EA88: ROL $05       ; Shift carry into remainder low
$EA8A: ROL $06       ; Propagate carry through remainder high
$EA8C: LDA $05       ; Trial subtraction: remainder - divisor
$EA8E: SEC
$EA8F: SBC $03       ; Subtract divisor low
$EA91: STA $07       ; Temp store
$EA93: LDA $06
$EA95: SBC $04       ; Subtract divisor high
$EA97: BCC $EAA1     ; Borrow = remainder < divisor, skip
$EA99: STA $06       ; Update remainder high
$EA9B: LDA $07
$EA9D: STA $05       ; Update remainder low
$EA9F: INC $01       ; Set quotient bit (bit 0 of $01 was 0 from ASL)
$EAA1: DEY
$EAA2: BPL $EA84     ; Next iteration
$EAA4: RTS
```

### Algorithm Trace

For each of 16 iterations:
1. Shift the dividend left by 1 bit (MSB exits into carry)
2. Rotate carry into the remainder workspace
3. Trial-subtract divisor from remainder
4. If remainder >= divisor: commit the subtraction, set quotient bit (INC $01 fills the 0 bit shifted in by ASL)
5. If remainder < divisor: discard the trial subtraction (BCC skips the store)

This is the textbook 6502 non-restoring division. The quotient builds up in $01/$02 from the bottom as bits are shifted out the top.

---

## $EAA5-$EADD: Math - 24-bit Unsigned Division (57 bytes, RTS at $EADD)

Extended version of the 16-bit division with 24-bit dividend and 24 iterations.

**Input**:
- $00/$01/$02 = dividend (24-bit, little-endian)
- $03/$04 = divisor (16-bit, little-endian)

**Output**:
- $00/$01/$02 = quotient (24-bit, replaces dividend)
- $05/$06/$07 = remainder (24-bit)

```asm
$EAA5: LDA #$00
$EAA7: STA $05       ; Clear remainder byte 0
$EAA9: STA $06       ; Clear remainder byte 1
$EAAB: STA $07       ; Clear remainder byte 2
$EAAD: LDY #$17      ; 24 iterations (bits 23..0)
$EAAF: ASL $00       ; Shift dividend bit 0
$EAB1: ROL $01       ; Propagate through dividend
$EAB3: ROL $02
$EAB5: ROL $05       ; Shift carry into remainder
$EAB7: ROL $06
$EAB9: ROL $07
$EABB: LDA $05       ; Trial subtraction
$EABD: SEC
$EABE: SBC $03       ; Subtract divisor low
$EAC0: STA $08       ; Temp byte 0
$EAC2: LDA $06
$EAC4: SBC $04       ; Subtract divisor high
$EAC6: STA $09       ; Temp byte 1
$EAC8: LDA $07
$EACA: SBC #$00      ; Propagate borrow through byte 2
$EACC: BCC $EADA     ; Borrow = remainder < divisor
$EACE: STA $07       ; Update remainder byte 2
$EAD0: LDA $08
$EAD2: STA $05       ; Update remainder byte 0
$EAD4: LDA $09
$EAD6: STA $06       ; Update remainder byte 1
$EAD8: INC $00       ; Set quotient bit
$EADA: DEY
$EADB: BPL $EAAF     ; Next iteration
$EADD: RTS
```

### Design Notes

- The divisor is only 16-bit ($03/$04), but the remainder is 24-bit. The third byte comparison uses `SBC #$00` which only propagates the borrow from the lower bytes. This means divisors up to $FFFF are supported with dividends up to $FFFFFF.
- The quotient builds up in $00/$01/$02 from bit 0 as bits are shifted out the top.
- Temp storage uses $08/$09 which overlap with other functions' variable space.

---

## $EADE-$EAF6: Callback Dispatcher (25 bytes, JMP at $EAF4)

Inline pointer table dispatcher for calling bank-switched functions. Not a math function, but located between math routines.

**Input**: A = index into inline pointer table, Y = parameter for target function

**Usage Pattern**:
```asm
    LDA #index         ; Index into pointer table
    LDY #parameter     ; Y parameter for the target function
    JSR $EADE
    .dw ptr0, ptr1, ptr2, ...  ; Inline pointer table follows JSR
```

```asm
$EADE: STY $00       ; Save Y parameter
$EAE0: ASL            ; A * 2 (word index into pointer table)
$EAE1: TAY
$EAE2: INY            ; Y = A*2 + 1 (account for 6502 JSR pushing PC+2, not PC+3)
$EAE3: PLA            ; Pull return address low byte
$EAE4: STA $01        ; $01/$02 = address of last byte of JSR instruction
$EAE6: PLA            ; Pull return address high byte
$EAE7: STA $02
$EAE9: LDA ($01),Y    ; Read pointer low from inline table
$EAEB: STA $03
$EAED: INY
$EAEE: LDA ($01),Y    ; Read pointer high from inline table
$EAF0: STA $04
$EAF2: LDY $00        ; Restore Y parameter
$EAF4: JMP ($0003)    ; Jump to target function
```

### Design Notes

- On 6502, `JSR` pushes PC+2 (the address of the last byte of the JSR instruction), so the return address points to the high byte of the JSR target, not the instruction after JSR. The `INY` at $EAE2 adds 1 to compensate, making the base of the inline data accessible at offset +1 from the return address.
- The target function receives Y as a parameter. When the target function executes `RTS`, it returns to the caller of `JSR $EADE` (not back to $EADE), because the return address was popped off the stack.
- This pattern enables bank-crossing function calls: the pointer table can reference addresses in any bank, and the caller doesn't need to know which bank the target lives in.

---

## $EAF7-$EB2C: PPU Scroll Helpers *(not yet analyzed)*

PPU scroll register writes and BG offset configuration. Includes scroll set ($EAF7), PPU ctrl nametable bit update ($EB03), and window reset ($EB1A).

---

## $EB2D-$EBB0: BCD to Binary Converter (132 bytes, RTS at $EBB0)

Inverse of $E9BA: converts 6 packed BCD digits to a 24-bit binary value. Uses the multiply ($EBE9) and accumulate ($EBB6) helpers.

**Input**: $0A/$0B/$0C = 6 packed BCD digits
**Output**: $0D/$0E/$0F = 24-bit binary value

### BCD Digit Layout (same as $E9BA output)

| Byte | Upper Nibble | Lower Nibble |
|------|-------------|-------------|
| $0A | Tens | Ones |
| $0B | Hundreds | Thousands (wait, this is wrong - let me verify) |
| $0C | Ten-thousands | Hundred-thousands |

Actually, based on the code trace below, the layout is:

| Byte | Upper Nibble | Lower Nibble |
|------|-------------|-------------|
| $0A | Tens | Ones |
| $0B | Thousands | Hundreds |
| $0C | Hundred-thousands | Ten-thousands |

Wait, let me re-examine by looking at what power of 10 each nibble is multiplied by.

### Detailed Disassembly

```asm
; === Initialize accumulator ===
$EB2D: LDA #$00
$EB2F: STA $0E
$EB31: STA $0F       ; Clear $0E/$0F (accumulator $0D/$0E/$0F, $0D set below)

; === Digit 0: Ones (lower nibble of $0A) × 1 ===
$EB33: LDA $0A       ; BCD byte (tens | ones)
$EB35: PHA           ; Save for upper nibble extraction
$EB36: AND #$0F      ; Extract ones digit
$EB38: STA $0D       ; Directly store as accumulator low byte (× 1)

; === Digit 1: Tens (upper nibble of $0A) × 10 ===
$EB3A: PLA           ; Restore $0A
$EB3B: JSR $EBB1     ; Extract upper nibble (LSR 4 times)
$EB3E: STA $03       ; Multiplier for multiply call
$EB40: LDA #$0A      ; 10 ($000A)
$EB42: STA $00
$EB44: LDA #$00
$EB46: STA $01
$EB48: STA $02       ; Multiplicand = $00000A = 10
$EB4A: JSR $EBE9     ; Multiply: 10 × tens_digit
$EB4D: JSR $EBB6     ; Accumulate result into $0D/$0E/$0F

; === Digit 2: Hundreds (lower nibble of $0B) × 100 ===
$EB50: LDA $0B       ; BCD byte (thousands | hundreds)
$EB52: PHA
$EB53: AND #$0F      ; Extract hundreds digit
$EB55: STA $03       ; Multiplier
$EB57: LDA #$64      ; 100 ($0064)
$EB59: STA $00
$EB5B: LDA #$00
$EB5D: STA $01
$EB5F: STA $02       ; Multiplicand = $000064 = 100
$EB61: JSR $EBE9     ; Multiply: 100 × hundreds_digit
$EB64: JSR $EBB6     ; Accumulate

; === Digit 3: Thousands (upper nibble of $0B) × 1,000 ===
$EB67: PLA           ; Restore $0B
$EB68: JSR $EBB1     ; Extract upper nibble
$EB6B: STA $03
$EB6D: LDA #$E8      ; 1,000 ($03E8)
$EB6F: STA $00
$EB71: LDA #$03
$EB73: STA $01
$EB75: LDA #$00
$EB77: STA $02       ; Multiplicand = $0003E8 = 1000
$EB79: JSR $EBE9     ; Multiply: 1000 × thousands_digit
$EB7C: JSR $EBB6     ; Accumulate

; === Digit 4: Ten-thousands (lower nibble of $0C) × 10,000 ===
$EB7F: LDA $0C       ; BCD byte (hundred-thousands | ten-thousands)
$EB81: PHA
$EB82: AND #$0F      ; Extract ten-thousands digit
$EB84: STA $03
$EB86: LDA #$10      ; 10,000 ($2710)
$EB88: STA $00
$EB8A: LDA #$27
$EB8C: STA $01
$EB8E: LDA #$00
$EB90: STA $02       ; Multiplicand = $002710 = 10000
$EB92: JSR $EBE9     ; Multiply: 10000 × ten_thousands_digit
$EB95: JSR $EBB6     ; Accumulate

; === Digit 5: Hundred-thousands (upper nibble of $0C) × 100,000 ===
$EB98: PLA           ; Restore $0C
$EB99: JSR $EBB1     ; Extract upper nibble
$EB9C: STA $03
$EB9E: LDA #$A0      ; 100,000 ($0186A0)
$EBA0: STA $00
$EBA2: LDA #$86
$EBA4: STA $01
$EBA6: LDA #$01
$EBA8: STA $02       ; Multiplicand = $0186A0 = 100000
$EBAA: JSR $EBE9     ; Multiply: 100000 × hundred_thousands_digit
$EBAD: JSR $EBB6     ; Accumulate
$EBB0: RTS
```

### Corrected BCD Layout

From the code, the BCD byte layout is:

| Byte | Upper Nibble (×10) | Lower Nibble (×1) |
|------|-------------------|-------------------|
| $0A | Tens digit | Ones digit |
| $0B | Thousands digit | Hundreds digit |
| $0C | Hundred-thousands digit | Ten-thousands digit |

This matches the output format of $E9BA.

### Multiply Constants Used

| Power | Value | Hex (24-bit) | Nibble Source |
|-------|-------|-------------|---------------|
| 10^0 | 1 | (direct store) | $0A lower |
| 10^1 | 10 | $00000A | $0A upper |
| 10^2 | 100 | $000064 | $0B lower |
| 10^3 | 1,000 | $0003E8 | $0B upper |
| 10^4 | 10,000 | $002710 | $0C lower |
| 10^5 | 100,000 | $0186A0 | $0C upper |

---

## $EBB1-$EBC9: Math Helpers (25 bytes)

### $EBB1: Extract Upper Nibble (5 bytes, RTS at $EBB5)

```asm
$EBB1: LSR            ; Shift A right 4 times
$EBB2: LSR
$EBB3: LSR
$EBB4: LSR
$EBB5: RTS            ; Return with upper nibble in bits 3-0
```

Extracts the upper nibble of A into the lower nibble position. Used by the BCD conversion functions to decompose packed BCD bytes.

### $EBB6: 24-bit Accumulate Add (20 bytes, RTS at $EBC9)

```asm
$EBB6: LDA $06       ; Load multiply result low byte
$EBB8: CLC
$EBB9: ADC $0D       ; Add accumulator byte 0
$EBBB: STA $0D
$EBBD: LDA $07       ; Load multiply result mid byte
$EBBF: ADC $0E       ; Add accumulator byte 1 with carry
$EBC1: STA $0E
$EBC3: LDA $08       ; Load multiply result high byte
$EBC5: ADC $0F       ; Add accumulator byte 2 with carry
$EBC7: STA $0F
$EBC9: RTS
```

Performs 24-bit addition: `$0D/$0E/$0F += $06/$07/$08`. Used by $EB2D to accumulate each digit's contribution after multiplication by the appropriate power of 10.

---

## $EBCA-$EBE8: Math - Multiply-then-Divide-by-100 (31 bytes, RTS at $EBE8)

Compound operation: multiplies a 16-bit value by an 8-bit multiplier, then divides the 24-bit product by 100.

**Input**: $00/$01 = 16-bit value, $03 = 8-bit multiplier
**Output**: $00/$01/$02 = quotient (divided by 100), $05/$06/$07 = remainder (mod 100)

```asm
$EBCA: LDA #$00
$EBCC: STA $02       ; Clear multiplicand byte 2 (make 16-bit * 8-bit)
$EBCE: JSR $EBE9     ; Multiply: ($00/$01/$02) * $03 -> $06/$07/$08/$09
$EBD1: LDA $06       ; Product low -> dividend
$EBD3: STA $00
$EBD5: LDA $07       ; Product mid
$EBD7: STA $01
$EBD9: LDA $08       ; Product high
$EBDB: STA $02       ; 24-bit dividend = product
$EBDD: LDA #$64      ; Divisor = 100
$EBDF: STA $03
$EBE1: LDA #$00      ; Divisor high = 0
$EBE3: STA $04
$EBE5: JSR $EAA5     ; 24-bit divide by 100
$EBE8: RTS
```

### Use Case

This function is likely used for score/stat display: multiply a digit by a place value, then divide by 100 to extract hundreds and higher digits separately from tens and ones. The remainder ($05/$06/$07) gives the value mod 100 (last two digits), while the quotient gives the value divided by 100 (upper digits).

---

## $EBE9-$EC21: Math - 24x8 Multiply (57 bytes, RTS at $EC21)

Shift-and-add multiplication with 8 iterations for an 8-bit multiplier. Supports a 24-bit multiplicand with 32-bit result.

**Input**:
- $00/$01/$02 = multiplicand (24-bit, little-endian; $04 cleared internally as extension)
- $03 = multiplier (8-bit)

**Output**: $06/$07/$08/$09 = product (32-bit, little-endian)

```asm
$EBE9: LDY #$07      ; 8 iterations (for 8-bit multiplier)
$EBEB: LDA #$00
$EBED: STA $04       ; Clear multiplicand extension byte
$EBEF: STA $05
$EBF1: STA $06       ; Clear result bytes
$EBF3: STA $07
$EBF5: STA $08
$EBF7: STA $09
$EBF9: LSR $03       ; Shift multiplier right, LSB -> carry
$EBFB: BCC $EC16     ; If bit was 0, skip addition
$EBFD: LDA $00       ; Add multiplicand to result
$EBFF: CLC
$EC00: ADC $06
$EC02: STA $06
$EC04: LDA $01
$EC06: ADC $07
$EC08: STA $07
$EC0A: LDA $02
$EC0C: ADC $08
$EC0E: STA $08
$EC10: LDA $04       ; Extension byte
$EC12: ADC $09
$EC14: STA $09
$EC16: ASL $00       ; Shift multiplicand left
$EC18: ROL $01
$EC1A: ROL $02
$EC1C: ROL $04       ; Carry propagates into extension byte
$EC1E: DEY
$EC1F: BPL $EBF9     ; Next iteration
$EC21: RTS
```

### Algorithm Trace

For each of 8 iterations:
1. Shift multiplier right by 1 bit (LSR $03)
2. If the shifted-out bit was 1: add current multiplicand to result
3. Shift multiplicand left by 1 bit (double it for next iteration)
4. Repeat

After 8 iterations, the result in $06/$07/$08/$09 contains the 32-bit product. The multiplicand in $00/$01/$02/$04 is destroyed (shifted left 8 times).

### Variable Map

| Variable | Role |
|----------|------|
| $00/$01/$02/$04 | Multiplicand (24-bit + 8-bit extension) |
| $03 | Multiplier (8-bit, destroyed) |
| $06/$07/$08/$09 | Product (32-bit) |
| $05 | Unused (cleared but not used) |
| Y | Loop counter (7 down to 0) |

---

## $EC22-$EC66: Math - 24x16 Multiply (69 bytes, RTS at $EC66)

Shift-and-add multiplication with 16 iterations for a 16-bit multiplier. Supports a 24-bit multiplicand with 40-bit result.

**Input**:
- $00/$01/$02 = multiplicand (24-bit, little-endian; $0B/$0C cleared internally as extension)
- $03/$04 = multiplier (16-bit, little-endian)

**Output**: $06/$07/$08/$09/$0A = product (40-bit, little-endian)

```asm
$EC22: LDY #$0F      ; 16 iterations (for 16-bit multiplier)
$EC24: LDA #$00
$EC26: STA $06       ; Clear result bytes
$EC28: STA $07
$EC2A: STA $08
$EC2C: STA $09
$EC2E: STA $0A
$EC30: STA $0B       ; Clear multiplicand extension bytes
$EC32: STA $0C
$EC34: LSR $04       ; Shift multiplier high byte right
$EC36: ROR $03       ; Rotate through multiplier low byte, LSB -> carry
$EC38: BCC $EC59     ; If bit was 0, skip addition
$EC3A: LDA $00       ; Add multiplicand to result (5 bytes)
$EC3C: CLC
$EC3D: ADC $06
$EC3F: STA $06
$EC41: LDA $01
$EC43: ADC $07
$EC45: STA $07
$EC47: LDA $02
$EC49: ADC $08
$EC4B: STA $08
$EC4D: LDA $0B       ; Extension byte 0
$EC4F: ADC $09
$EC51: STA $09
$EC53: LDA $0C       ; Extension byte 1
$EC55: ADC $0A
$EC57: STA $0A
$EC59: ASL $00       ; Shift multiplicand left (5 bytes)
$EC5B: ROL $01
$EC5D: ROL $02
$EC5F: ROL $0B       ; Carry propagates into extension bytes
$EC61: ROL $0C
$EC63: DEY
$EC64: BPL $EC34     ; Next iteration
$EC66: RTS
```

### Algorithm Trace

Same shift-and-add pattern as the 24x8 multiply, but with 16 iterations and wider data paths:
1. Shift 16-bit multiplier right by 1 bit (LSR $04; ROR $03)
2. If the shifted-out bit was 1: add current 5-byte multiplicand to 5-byte result
3. Shift 5-byte multiplicand left by 1 bit
4. Repeat 16 times

### Variable Map

| Variable | Role |
|----------|------|
| $00/$01/$02/$0B/$0C | Multiplicand (24-bit + 16-bit extension) |
| $03/$04 | Multiplier (16-bit, destroyed) |
| $06/$07/$08/$09/$0A | Product (40-bit) |
| $05 | Not used by this function |
| Y | Loop counter (15 down to 0) |

### Design Notes

- The multiplicand extension bytes ($0B/$0C) start at 0 and accumulate carry bits as the multiplicand is shifted left over 16 iterations. After the first few iterations, the original 24-bit value has grown beyond its initial width, and the extension bytes capture the overflow.
- Maximum result: $FFFFFF * $FFFF = $FFFF00000001 (40 bits), which fits in 5 bytes.
- This function shares the $06-$0A result space with the 24x8 multiply but extends it with $0A for the 40-bit product.

---

## $EC67-$ECEE: Palette Animation *(not yet analyzed)*

Color rotation with frame counter $0087-$0089 and palette scroll effects.

---

## $ED19-$EDEC: Menu Cursor System

### Overview

Generic menu cursor/scroll engine with 8 entry points for different page sizes (1-8 items per page). Navigates a 2D cursor over a data table using D-pad input. Returns the selected item value in $12.

### Controller Input Format ($0081)

Written by $E6C6 controller read subroutine. $0081 is edge-triggered (newly pressed only, not held):

```
$0083 = raw pad 1 state (8 ROR reads from $4016)
$0084 = previous frame $0083
$0081 = ($0083 XOR $0084) AND $0083 = new presses this frame
```

| Bit | Value | Button |
|-----|-------|--------|
| 7 | $80 | Right |
| 6 | $40 | Left |
| 5 | $20 | Down |
| 4 | $10 | Up |
| 3 | $08 | Start |
| 2 | $04 | Select |
| 1 | $02 | B |
| 0 | $01 | A |

### Variable Map

| Address | Name | Description |
|---------|------|-------------|
| $00 | step_size | Items per page (1-8), set by entry point |
| $10/$11 | data_ptr | Pointer to menu item data table |
| $12 | cur_item | Current item value (returned from $EDDD) |
| $0424 | column | Cursor column (item index within page, 0-based) |
| $0425 | page | Cursor page (page index, 0-based) |
| $0081 | pad1_edge | Pad 1 newly-pressed buttons |
| $0083 | pad1_raw | Pad 1 raw button state |
| $0084 | pad1_prev | Pad 1 previous frame state |

### Data Table Format

The data table at ($10) is a flat byte array organized as pages of `step_size` items:
- **$00-$7F**: Valid menu items (indices, character codes, etc.)
- **$80-$FE**: Page/row terminators (bit 7 set = end of row)
- **$FF**: Empty slot marker (no valid item at this position)

Layout: `[item0][item1]...[itemN][term][item0]...[term]...`
Each page occupies `step_size` bytes. The total table length = (num_pages + 1) * step_size.

### $ED19-$ED40: Entry Points (40 bytes)

8 entry points, each sets a step size and falls through to the main handler:

```
$ED19: LDA #$01 : JMP $ED41   ; step=1 (1 item per page)
$ED1E: LDA #$02 : JMP $ED41   ; step=2
$ED23: LDA #$03 : JMP $ED41   ; step=3
$ED28: LDA #$04 : JMP $ED41   ; step=4
$ED2D: LDA #$05 : JMP $ED41   ; step=5
$ED32: LDA #$06 : JMP $ED41   ; step=6
$ED37: LDA #$07 : JMP $ED41   ; step=7
$ED3C: LDA #$08 : JMP $ED41   ; step=8 (8 items per page)
```

**Caller convention**: Set $10/$11 to data table pointer before calling. Most common entry point is $ED1E (step=2), used by 30+ callers across banks 09, 0C, 0D, 0E, 0F, 17, 19, 1A, 1B, 1C.

**Cross-reference summary** (from PRG ROM scan):

| Entry | Step | Callers |
|-------|------|---------|
| $ED19 | 1 | prg_0b (x2), prg_1b (x3), prg_1c (x1) |
| $ED1E | 2 | prg_09 (x5), prg_0c (x3), prg_0d (x2), prg_0e (x1), prg_0f (x1), prg_17 (x2), prg_19 (x1), prg_1a (x1), prg_1b (x8), prg_1c (x8) |
| $ED23 | 3 | prg_0d (x2) |
| $ED28 | 4 | prg_0f (x1), prg_1b (x1), prg_1c (x1, JMP) |
| $ED2D-$ED3C | 5-8 | No callers found |

### $ED41-$ED70: Main Cursor Handler (48 bytes)

```
$ED41: STA $00           ; store step_size
$ED43: LDA $0081 : AND #$80 : BEQ $ED4D   ; Right pressed?
$ED4A: JSR $ED71                              ; → next item
$ED4D: LDA $0081 : AND #$40 : BEQ $ED57   ; Left pressed?
$ED54: JSR $ED8D                              ; → prev item
$ED57: LDA $0081 : AND #$20 : BEQ $ED61   ; Down pressed?
$ED5E: JSR $EDA9                              ; → next page
$ED61: LDA $0081 : AND #$10 : BEQ $ED6B   ; Up pressed?
$ED68: JSR $EDBE                              ; → prev page
$ED6B: JSR $EDDD                              ; lookup current item
$ED6E: STA $12                               ; store result
$ED70: RTS
```

All 4 directions are checked each frame (not mutually exclusive). After processing direction input, the current item is looked up via $EDDD and stored to $12.

### $ED71-$ED8C: Right Handler — Next Item (28 bytes)

```
$ED71: INC $0424          ; column++
$ED74: JSR $EDDD          ; lookup new position
$ED77: BMI $ED80          ; bit 7 set = past end of data → clamp
$ED79: LDA $0424
$ED7C: CMP $00            ; column >= step_size?
$ED7E: BCC $ED8C          ; no → valid, done
$ED80: DEC $0424          ; revert: column--
$ED83: LDA $12            ; check current item
$ED85: BNE $ED8C          ; non-zero → on valid item, keep position
$ED87: LDA #$00
$ED89: STA $0424          ; current is $00 (empty) → reset to column 0
$ED8C: RTS
```

**Logic**: Increment column. If new position is past end (terminator byte with bit 7 set) or >= step_size, revert. If reverted position holds $00 (empty slot), reset to column 0.

### $ED8D-$EDA8: Left Handler — Prev Item (28 bytes)

```
$ED8D: DEC $0424          ; column--
$ED90: BPL $EDA8          ; column >= 0 → valid, done
$ED92: INC $0424          ; was -1, revert to 0
$ED95: LDA $12            ; check current item
$ED97: BNE $EDA8          ; non-zero → on valid item, keep position
$ED99: LDA $00            ; step_size
$ED9B: STA $0424          ; column = step_size
$ED9E: DEC $0424          ; column = step_size - 1
$EDA1: JSR $EDDD          ; lookup at this column
$EDA4: CMP #$FF           ; empty slot?
$EDA6: BEQ $ED9E          ; yes → try column - 1
$EDA8: RTS
```

**Logic**: Decrement column. If goes negative, scan backward from (step_size - 1) until a non-$FF item is found. This handles pages with fewer items than step_size.

### $EDA9-$EDBD: Down Handler — Next Page (21 bytes)

```
$EDA9: INC $0425          ; page++
$EDAC: JSR $EDDD          ; lookup new position
$EDAF: BPL $EDBD          ; item valid (bit 7 clear) → done
$EDB1: DEC $0425          ; past end, revert page--
$EDB4: LDA $12            ; check current item
$EDB6: BNE $EDBD          ; non-zero → on valid item, keep position
$EDB8: LDA #$00
$EDBA: STA $0425          ; current is $00 → reset to page 0
$EDBD: RTS
```

**Logic**: Increment page. If new page hits a terminator (bit 7 set), revert. If current position holds $00, reset to page 0.

### $EDBE-$EDDC: Up Handler — Prev Page (31 bytes)

```
$EDBE: DEC $0425          ; page--
$EDC1: BPL $EDDC          ; page >= 0 → valid, done
$EDC3: INC $0425          ; was -1, revert to 0
$EDC6: LDA $12            ; check current item
$EDC8: BNE $EDDC          ; non-zero → on valid item, keep position
$EDCA: LDX #$FF           ; X = -1 (row counter)
$EDCC: LDY $0424          ; Y = current column
$EDCF: INX                ; X++ (count rows)
$EDD0: TYA
$EDD1: CLC
$EDD2: ADC $00            ; Y += step_size (advance to next row)
$EDD4: TAY
$EDD5: LDA ($10),Y        ; read item at row Y
$EDD7: BPL $EDCF          ; valid item (bit 7 clear) → keep counting
$EDD9: STX $0425          ; X = number of valid rows → new page
$EDDC: RTS
```

**Logic**: Decrement page. If goes negative, scan forward through data table from current column position, counting rows (stepping by step_size) until a terminator is found. The count of valid rows becomes the new page number, effectively wrapping to the last page.

### Design Notes

- The cursor engine is fully generic — any menu with 1-8 items per page can use it by setting $10/$11 and calling the appropriate entry point.
- $0081 is edge-triggered, so holding a direction moves the cursor only once per press.
- D-pad Right/Left navigates items within a page; Down/Up navigates between pages. This is consistent with Koei's horizontal-list menu style common in strategy games.
- The wrap-around logic in Left/Up handlers gracefully handles variable-length pages where the last page may have fewer items than step_size.
- The $12 return value is the raw byte from the data table, which callers use as an index into further tables or as a command identifier.

---

## $EDED-$EE4D: Menu String Lookup & Callback Functions

### $EDDD-$EDF4: String/Item Lookup (24 bytes)

*(Entry at $EDDD, spans into this section)*

```
$EDDD: LDA #$00           ; accumulator = 0
$EDDF: LDY $0425          ; Y = page
$EDE2: CPY #$00           ; page == 0?
$EDE4: BEQ $EDED          ; yes → skip multiply
$EDE6: CLC
$EDE7: ADC $00            ; A += step_size
$EDE9: DEY                ; Y--
$EDEA: JMP $EDE2          ; loop (multiply: A = page * step_size)
$EDED: CLC
$EDEE: ADC $0424          ; A += column
$EDF1: TAY                ; Y = page * step_size + column
$EDF2: LDA ($10),Y        ; A = data_table[Y]
$EDF4: RTS
```

**Formula**: `Y = $0425 * step_size + $0424`, then `A = ($10),Y`

Returns the byte at the cursor position in the data table pointed to by $10/$11. The multiply loop at $EDE2-$EDEA is a simple repeated-addition (no MUL instruction on 6502). Result is also available in Y as the computed offset.

### $EDF5-$EE06: Pointer Table Lookup (18 bytes)

```
$EDF5: ASL                ; A *= 2 (word index)
$EDF6: TAY                ; Y = index
$EDF7: LDA ($10),Y        ; lo byte of pointer
$EDF9: STA $0A            ; → $0A
$EDFB: INY
$EDFC: LDA ($10),Y        ; hi byte of pointer
$EDFE: STA $0C            ; → $0C
$EE00: LDA #$00
$EE02: STA $02            ; $02 = 0 (flag?)
$EE04: JMP $F1AD          ; → sprite OAM writer
```

**Purpose**: Reads a 16-bit pointer from a word-sized pointer table at ($10). Input A = entry index (0-based). The pointer is stored to $0A/$0C, $02 is cleared, then control transfers to $F1AD (sprite OAM DMA writer) which presumably uses the pointer to fetch sprite tile data.

**Note**: This is a separate utility from the cursor system — it reads a pointer table, not a flat item array. The $02 = 0 may select sprite vs. BG tile destination.

### $EE07-$EE4C: Banked Callback Trampoline (70 bytes)

A sophisticated mechanism for calling functions in other PRG banks from bank 1F code. Manipulates the 6502 stack to insert a bank-restore return stub.

**Calling convention**:
```
    LDY #bank_number       ; Y = PRG bank parameter for $F237
    JSR $EE07              ; call trampoline
    .word target_address   ; inline 2-byte pointer (in bank-switched region)
    ; execution continues here after callback returns
```

**Detailed operation**:

```
$EE07: LDA $00E2          ; save current PRG bank (for $A000-$BFFF)
$EE0A: STA $0058          ; → $0058
$EE0D: STY $005D          ; save Y (bank parameter) → $005D
$EE10: PLA                ; pop return address lo (points to last byte of JSR)
$EE11: CLC
$EE12: ADC #$01           ; +1 → points to first inline byte
$EE14: STA $0059          ; → $0059 (pointer to inline data)
$EE17: PLA                ; pop return address hi
$EE18: ADC #$00           ; + carry
$EE1A: STA $005A          ; → $005A
$EE1D: LDY #$00
$EE1F: LDA ($59),Y        ; read inline pointer lo
$EE21: STA $005B          ; → $005B (target address lo)
$EE24: INY
$EE25: LDA ($59),Y        ; read inline pointer hi
$EE27: STA $005C          ; → $005C (target address hi)
$EE2A: LDY $005D          ; restore Y = bank parameter
$EE2D: JSR $F237          ; switch PRG banks (Y sets $A000-$BFFF and $C000-$DFFF)
$EE30: INC $0059          ; advance past 1st inline byte
$EE33: BNE $EE38
$EE35: INC $005A          ; 16-bit increment
$EE38: LDA $005A          ; push adjusted return address (points to 2nd inline byte)
$EE3B: PHA                ; RTS will add 1 → past both inline bytes
$EE3C: LDA $0059
$EE3F: PHA
$EE40: LDA $0058          ; push saved PRG bank
$EE43: PHA
$EE44: LDA #$EE           ; push $EE4C as return address for target function
$EE46: PHA
$EE47: LDA #$4C
$EE49: PHA
$EE4A: JMP ($005B)        ; jump to target function
```

**Return stub** (target function RTS's here):
```
$EE4D: PLA                ; pop saved PRG bank
$EE4E: TAY                ; Y = original $00E2 value
$EE4F: JSR $F237          ; restore original PRG banks
$EE52: RTS                ; return to caller (past inline pointer)
```

**Stack state at JMP ($005B)** (top to bottom):
1. $EE4C (return to bank-restore stub) — target function returns here
2. $0058 (saved PRG bank) — restored by stub
3. $0059/$005A (adjusted return address) — returns to caller past inline data

**Example** (from prg_0e at $A024):
```
$A024: LDY #$3D           ; bank = $3D → $1D (prg_1d.bin) for $A000-$BFFF
$A026: JSR $EE07          ; trampoline call
$A029: .word $A003        ; inline target = $A003 (in bank-switched region)
                             ; execution resumes at $A02B
```

### Temporary Variables Used by Trampoline

| Address | Purpose |
|---------|---------|
| $0058 | Saved $00E2 (PRG bank for $A000-$BFFF) |
| $0059/$005A | Adjusted return address (past inline pointer after RTS+1) |
| $005B/$005C | Target function address (from inline pointer) |
| $005D | Saved Y register (bank parameter) |

---

## $EE53-$F076: NMI Sub-Dispatch & PPU Tile Writers *(not yet analyzed)*

$007E flag-based sub-dispatch ($EE53), PPU BG tile write ($EF0B), sprite tile write ($EF71), attribute tile write ($EFC0/$F028).

---

## $F077-$F2AE: Sprite OAM, CHR Banking & Window Setup *(not yet analyzed)*

Namco-163 sound reg read ($F077), sprite OAM writers ($F092/$F1AD), CHR bank switch ($F206), window/display setup ($F237/$F25F/$F266).

---

## $F2AF-$F3BC: Data Access Functions

### $F2AF: Get Hero Address (30 bytes, RTS at $F2D6)

**Formula**: `hero_id * 32 + $6000`, 32 bytes per hero, data at $6000 (bank-switched)

### $F2D7: Get City Address (48 bytes, RTS at $F307)

**Formula**: `city_id * 12 + $63C0`, 12 bytes per city, data at $63C0 (bank-switched)

### $F308: Hero Kata Name (57 bytes, RTS at $F35E)

**Formula**: `id * 10 + $901A`, 10 bytes per kata name, data at $901A (bank-switched). Width table at $F35F maps character count to display width.

### $F368: Get Kingdom Address (17 bytes, RTS at $F378)

Pointer table at $F379, 8 bytes per kingdom, data at $6F07 (battery-backed SRAM). 7 entries: $6F07, $6F0F, $6F17, $6F1F, $6F27, $6F2F, $6F37.

### $F387: Hero Initial Data (54 bytes, RTS at $F3BC)

**Formula**: `hero_id * 12 + $8000`, 12 bytes per entry, data at $8000 (bank-switched)

---

## $F3BD-$F421: Mapper Init + Controller Check

Called by reset handler at $E05E. Performs mapper configuration and controller validation:

```asm
$F3BD: LDA #$00
$F3BF: STA $5000     ; Namco-163 CHR bank register
$F3C2: STA $5800     ; Namco-163 CHR bank register
$F3C5: LDA #$E0
$F3C7: STA $C000     ; Mapper register (bank 0)
$F3CA: STA $D000     ; Mapper register (bank 0)
$F3CD: LDA #$E1
$F3CF: STA $C800     ; Mapper register (bank 1)
$F3D2: STA $D800     ; Mapper register (bank 1)
$F3D5: LDX #$00      ; Controller validation loop
$F3D7: LDA $F3BD,X   ; Read from self (data table)
$F3DA: AND #$01
$F3DC: STA $0001
$F3DF: STA $4016     ; Write to controller port 1
$F3E2: LDA $4017     ; Read controller port 2
$F3E5: LSR
$F3E6: EOR #$FF
$F3E8: AND #$01
$F3EA: CMP $0001     ; Compare values
$F3ED: BNE $F421     ; Mismatch -> skip
$F3EF: INX
$F3F0: CPX #$46      ; 70 iterations
$F3F2: BNE $F3D7
```

---

## $F422-$F7FF: RAM Test & Sound Data *(not yet analyzed)*

- $F422-$F476: RAM integrity test (write/verify $AA pattern, LFSR-based)
- $F477-$F676: Sound/music data (instrument definitions)
- $F677-$F7FF: Padding ($FF fill)

---

## $F800-$FAA8: NMI Handler *(not yet analyzed)*

Main NMI handler entry ($F800), sub-dispatch table ($F87B, 8 address pairs), 8 sub-state handlers ($F8B5-$FAA8) dispatched by `$0078 AND #$0F`.

---

## $FAA9-$FB2C: Palette Swap & Controller Read *(not yet analyzed)*

Palette swap functions ($FAA9/$FABF), NMI scroll mode ($FAD5), controller read + bank restore ($FB0B).

---

## $FB2D-$FF5F: IRQ Handler *(not yet analyzed)*

IRQ entry ($FB2D), dispatches by `$0060` to 14+ sub-states for mid-frame raster/CHR effects with timing loops.

---

## $FF62-$FFD6: Scroll Calculations *(not yet analyzed)*

Computes $009A/$009B from $0098, sets $00EA/$00EC. Two variants with different $0097 bit 0 handling.

---

## $FFFA-$FFFF: Interrupt Vectors

- **NMI**: $F800 (little-endian: $00 $F8)
- **RESET**: $E000 (little-endian: $00 $E0)
- **IRQ**: $FB2D (little-endian: $2D $FB)

---

## Reference: Data Structure Summary

| Entity | Address Function | Formula | Entry Size | Table Base |
|--------|-----------------|---------|------------|------------|
| Hero | $F2AF | id * 32 + $6000 | 32 bytes | $6000 |
| City | $F2D7 | id * 12 + $63C0 | 12 bytes | $63C0 |
| Kingdom | $F368 | pointer table at $F379 | 8 bytes | $6F07 |
| Hero Kata Name | $F308 | id * 10 + $901A | 10 bytes | $901A |
| Hero Initial Data | $F387 | id * 12 + $8000 | 12 bytes | $8000 |
| Random Byte | $E87A | table[$0050]++ | 1 byte | $E8BA |
| Domestic Action | $E2C2 | pointer table, 7 entries | varies | $8440-$8B60 |

**Note**: Table base addresses $6000, $63C0, $8000, $901A are in bank-switched memory regions. Kingdom data at $6F07 is in battery-backed SRAM.

---

## Reference: Math Library Summary

| Function | Address | Size | Input | Output |
|----------|---------|------|-------|--------|
| Binary to BCD | $E9BA | 194 bytes | $01/$02/$03 (24-bit) | $07/$08/$09 (6-digit packed BCD) |
| 16-bit Division | $EA7C | 41 bytes | $01/$02 div $03/$04 | $01/$02 = quot, $05/$06 = rem |
| 24-bit Division | $EAA5 | 57 bytes | $00/$01/$02 div $03/$04 | $00/$01/$02 = quot, $05/$06/$07 = rem |
| Callback Dispatcher | $EADE | 25 bytes | A=index, Y=param | Jumps to inline pointer |
| BCD to Binary | $EB2D | 132 bytes | $0A/$0B/$0C (6-digit BCD) | $0D/$0E/$0F (24-bit) |
| Extract Upper Nibble | $EBB1 | 5 bytes | A (packed BCD byte) | A (upper nibble in lower) |
| 24-bit Accumulate | $EBB6 | 20 bytes | $06/$07/$08 + $0D/$0E/$0F | $0D/$0E/$0F |
| Multiply/Div100 | $EBCA | 31 bytes | $00/$01 * $03 / 100 | $00/$01/$02 = quot, $05-$07 = rem |
| 24x8 Multiply | $EBE9 | 57 bytes | $00/$01/$02 * $03 | $06/$07/$08/$09 (32-bit) |
| 24x16 Multiply | $EC22 | 69 bytes | $00/$01/$02 * $03/$04 | $06-$0A (40-bit) |

---

## Reference: Key Memory Addresses

| Address | Purpose |
|---------|---------|
| $0000-$0002 | Math: dividend / multiplicand |
| $0003-$0004 | Math: divisor / multiplier |
| $0005-$0009 | Math: remainder / product temp |
| $000A-$000C | Math: BCD input bytes |
| $000D-$000F | Math: BCD accumulator / binary output |
| $004E/$004F | Indirect jump target |
| $0050 | RNG table index |
| $0051 | Saved X register (RNG) |
| $0068/$0069 | Pointer (territory data $AF70) |
| $0078 | Sub-state within each major state |
| $007A | State counter (0-15), vector dispatch |
| $0081 | Controller input (bits 7-4: U/D/L/R) |
| $008B | RAM copy of PPU control register |
| $008C | RAM copy of PPU mask register |
| $008E/$008F | Kingdom position data |
| $0090/$0091 | Kingdom position data |
| $0098/$0099 | Display mode parameter |
| $00E6-$00ED | Bank register RAM copies |
| $0100-$011F | Sprite palette buffer |
| $0140-$019C | PPU tile buffers (BG, sprite, attr) |
| $0300/$0304 | Sentinel values ($FF) |
| $0400 | Controller input result |
| $0424/$0425 | Menu cursor position |
| $04AB/$04AC | Army status flags (battle) |
| $04E0-$04E3 | Sprite data |
| $0500 | Kingdom mode ($0B = scenario) |
| $0508 | Kingdom select flag |
| $0510-$0513 | Kingdom coordinate data |
| $0518 | Kingdom flag ($FF) |
| $0541 | Game completion flag (music selector) |
| $0544 | Domestic action type (0-6) |
| $0562/$0563 | Sprite position indices |
| $6F07-$6F37 | Kingdom data (battery SRAM) |
| $6F3F/$6F41 | Kingdom init params (SRAM) |
| $6F8B | Game start flag (SRAM) |

---

## Reference: Game State Flow

```
State 0: System Init -> sets $007A=9 (Idle/Wait)
State 9: Idle/Wait -> NMI handler changes state
State 1: New Game Init -> display, input, SRAM init
State 2: Random + Display (Y=#2A) -> brief transition
State 3: Kingdom Select -> choose kingdom
State 4: Random + Display (Y=#28) -> brief transition
State 5: Domestic Affairs -> action selection
State 6: Random Seed Advance -> RNG refresh
State 7: Battle Phase -> combat
State 8: Random Seed Advance -> RNG refresh
State 9: Territory / Map View -> game map
State 10: Idle/Wait -> frame wait
State 11: Advisor/Council -> advisor dialogue
State 12: Idle/Wait -> frame wait
State 13: Turn Summary -> end-of-turn report
State 14: Idle/Wait -> frame wait
```

States 0-14 are valid (15 entries in the vector table). Index 15+ would read code bytes at $E09A as vector data, producing garbage addresses. States 6, 8, 10, 12, 14 are brief/idle states (RNG advance or NMI loop). Main game phases are 1, 3, 5, 7, 9, 11, 13.

---

## Reference: Bank Switching

Namco-163 PRG bank registers:

| Register | Slot Range | Size |
|----------|------------|------|
| $C000 | $C000-$CFFF | 4KB |
| $C800 | $C800-$CFFF | 4KB |
| $D000 | $D000-$DFFF | 4KB |
| $D800 | $D800-$DFFF | 4KB |
| $F800 | $E000-$FFFF | 8KB (fixed bank register) |

**Bank number encoding**: Low 5 bits (D4-D0) = actual bank number (0-31), high 3 bits (D7-D5) = control flags.

Bank switch function $E51F reads 8-byte config from table $E567 indexed by A*8. First 4 bytes map to $C000/$C800/$D000/$D800.
