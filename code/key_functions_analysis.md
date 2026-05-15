# Key Functions Analysis - Sangokushi 2

## Summary

Verified key game functions in **Bank 0x1F** (mapped to $E000-$FFFF at boot). These are core data access and utility functions used throughout the game.

---

## 1. Random Seed - $E87A

**Address**: $E87A (offset $087A in bank 0x1F)
**Size**: 10 bytes, RTS at $E889

```asm
$E87A: STX $0051     ; Save X register
$E87D: LDX $0050     ; Load current RNG index
$E880: LDA $E8BA,X   ; Read byte from pre-computed random table
$E883: INC $0050     ; Advance table index
$E886: LDX $0051     ; Restore X register
$E889: RTS            ; Return with random byte in A
```

**Type**: Sequential table lookup. Each call reads the next byte from a pre-computed table at $E8BA and increments the index at $0050. This is NOT an LCG algorithm - it uses a fixed random value table.

**Random Value Table at $E8BA** (first 32 bytes):
```
$3E $4E $4F $83 $0E $C9 $7F $5D $FC $E6 $BA $01 $F8 $00 $F4 $0A
$E5 $A9 $8D $D1 $E8 $DB $DE $81 $95 $72 $08 $9A $C7 $49 $C8 $23
```

---

## 2. Get Hero Address - $F2AF

**Address**: $F2AF (offset $12AF in bank 0x1F)
**Size**: 30 bytes, RTS at $F2D6

```asm
$F2AF: LDY #$00
$F2B1: STY $0001     ; Clear high byte
$F2B4: ASL           ; hero_id * 2
$F2B5: ROL $0001
$F2B8: ASL           ; hero_id * 4
$F2B9: ROL $0001
$F2BC: ASL           ; hero_id * 8
$F2BD: ROL $0001
$F2C0: ASL           ; hero_id * 16
$F2C1: ROL $0001
$F2C4: ASL           ; hero_id * 32
$F2C5: ROL $0001
$F2C8: CLC
$F2C9: ADC #$00      ; Add low offset (0)
$F2CB: STA $0000
$F2CE: LDA $0001
$F2D1: ADC #$60      ; Add high offset ($6000)
$F2D3: STA $0001
$F2D6: RTS            ; Return pointer in $0000/$0001
```

**Formula**: `hero_id * 32 + $6000`
**Entry Size**: 32 bytes per hero
**Table Base**: $6000 (bank-switched, requires appropriate bank loaded)

---

## 3. Get City Address - $F2D7

**Address**: $F2D7 (offset $12D7 in bank 0x1F)
**Size**: 48 bytes, RTS at $F307

```asm
$F2D7: LDY #$00
$F2D9: STY $0001     ; Clear high byte
$F2DC: STA $0000     ; Save city_id (original A value)
$F2DF: ASL           ; city_id * 2
$F2E0: ROL $0001
$F2E3: CLC
$F2E4: ADC $0000     ; city_id * 2 + city_id = city_id * 3
$F2E7: PHA           ; Push A*3
$F2E8: LDA $0001
$F2EB: ADC #$00      ; Handle carry
$F2ED: STA $0001
$F2F0: PLA           ; Pull A*3
$F2F1: ASL           ; city_id * 6
$F2F2: ROL $0001
$F2F5: ASL           ; city_id * 12
$F2F6: ROL $0001
$F2F9: CLC
$F2FA: ADC #$C0      ; Add low offset
$F2FC: STA $0000
$F2FF: LDA $0001
$F302: ADC #$63      ; Add high offset ($63C0)
$F304: STA $0001
$F307: RTS            ; Return pointer in $0000/$0001
```

**Formula**: `city_id * 12 + $63C0`
**Entry Size**: 12 bytes per city
**Table Base**: $63C0 (bank-switched)

---

## 4. Hero Kata Name - $F308

**Address**: $F308 (offset $1308 in bank 0x1F)
**Size**: 57 bytes, RTS at $F35E

```asm
$F308: STA $0002     ; Save id
$F30B: LDY #$30      ; Display parameter
$F30D: JSR $F25F     ; Window/display function
$F310: LDA #$00
$F312: STA $0001     ; Clear high byte
$F315: LDA $0002     ; Reload id
$F318: ASL           ; id * 2
$F319: ROL $0001
$F31C: ASL           ; id * 4
$F31D: ROL $0001
$F320: CLC
$F321: ADC $0002     ; id * 4 + id = id * 5
$F324: STA $0000
$F327: LDA $0001
$F32A: ADC #$00      ; Handle carry
$F32C: STA $0001
$F32F: ASL $0000     ; id * 5 * 2 = id * 10
$F332: ROL $0001
$F335: LDA $0000
$F338: CLC
$F339: ADC #$1A      ; Low offset
$F33B: STA $0000
$F33E: LDA $0001
$F341: ADC #$90      ; High offset ($901A)
$F343: STA $0001     ; Pointer to kata name string
; String scan loop:
$F346: LDY #$00      ; String index
$F348: LDX #$00      ; Character count
$F34A: LDA ($00),Y   ; Read character
$F34C: BEQ $F35B     ; Null -> done
$F34E: INY
$F34F: CMP #$39      ; Skip '9' marker
$F351: BEQ $F34A
$F353: CMP #$3A      ; Skip ':' marker
$F355: BEQ $F34A
$F357: INX           ; Count real characters
$F358: JMP $F34A
$F35B: LDA $F35F,X   ; Load display width from table
$F35E: RTS
; Width table at $F35F:
$F35F: $03 $03 $03 $02 $02 $02 $01 $01 $00 $00
```

**Formula**: `id * 10 + $901A`
**Entry Size**: 10 bytes per kata name
**Table Base**: $901A (bank-switched)
**Additional logic**: Scans string to count characters (skipping '9' and ':' markers), then returns display width from table at $F35F

---

## 5. Get Kingdom Address - $F368

**Address**: $F368 (offset $1368 in bank 0x1F)
**Size**: 17 bytes, RTS at $F378

```asm
$F368: AND #$0F      ; Mask to 0-15 (max 16 kingdoms)
$F36A: ASL           ; kingdom_id * 2
$F36B: TAY
$F36C: LDA $F379,Y   ; Load pointer low byte
$F36F: STA $0000
$F372: LDA $F37A,Y   ; Load pointer high byte
$F375: STA $0001
$F378: RTS
```

**Pointer table at $F379** (7 entries):
```
$6F07  Kingdom 0
$6F0F  Kingdom 1  (offset +8)
$6F17  Kingdom 2  (offset +8)
$6F1F  Kingdom 3  (offset +8)
$6F27  Kingdom 4  (offset +8)
$6F2F  Kingdom 5  (offset +8)
$6F37  Kingdom 6  (offset +8)
```

**Entry Size**: 8 bytes per kingdom
**Table Base**: $6F07 (battery-backed SRAM)
**Note**: Uses indirect pointer table instead of multiply+offset formula

---

## 6. Hero Initial Data - $F387

**Address**: $F387 (offset $1387 in bank 0x1F)
**Size**: 54 bytes, RTS at $F3BC

```asm
$F387: LDY #$31      ; Display parameter
$F389: JSR $F25F     ; Window/display function
$F38C: LDY #$00
$F38E: STY $0001     ; Clear high byte
$F391: STA $0000     ; Save hero_id
$F394: ASL           ; hero_id * 2
$F395: ROL $0001
$F398: CLC
$F399: ADC $0000     ; hero_id * 2 + hero_id = hero_id * 3
$F39C: PHA           ; Push A*3
$F39D: LDA $0001
$F3A0: ADC #$00      ; Handle carry
$F3A2: STA $0001
$F3A5: PLA           ; Pull A*3
$F3A6: ASL           ; hero_id * 6
$F3A7: ROL $0001
$F3AA: ASL           ; hero_id * 12
$F3AB: ROL $0001
$F3AE: CLC
$F3AF: ADC #$00      ; Low offset (0)
$F3B1: STA $0000
$F3B4: LDA $0001
$F3B7: ADC #$80      ; High offset ($8000)
$F3B9: STA $0001
$F3BC: RTS
```

**Formula**: `hero_id * 12 + $8000`
**Entry Size**: 12 bytes per hero initial data
**Table Base**: $8000 (bank-switched)

---

## 7. Mapper Init - $F3BD

**Address**: $F3BD (offset $13BD in bank 0x1F)

Called by reset handler at $E05E. Performs Namco-163 mapper configuration and controller validation. NOT a simple hardware init.

Key operations:
- CHR bank register initialization ($5000, $5800)
- Cartridge RAM/mapper setup ($C000, $D000, $C800, $D800)
- Controller validation loop (70 iterations reading $4016/$4017)
- Bank switching (writes to $F800)
- Continues with more initialization

---

## 8. Multiply Patterns Used

The address calculation functions use these multiplication patterns on the 6502:

| Multiplier | Pattern | Used By |
|-----------|---------|---------|
| * 32 | 5x ASL + ROL chain | Get Hero ($F2AF) |
| * 12 | * 3 (ASL+ADC) then * 4 (2x ASL+ROL) | Get City ($F2D7), Hero Init ($F387) |
| * 10 | * 5 (2x ASL+ROL+ADC) then ASL+ROL | Hero Kata Name ($F308) |
| * 2 | Pointer table index | Get Kingdom ($F368) |

---

## 9. Data Structure Summary

| Entity | Address Function | Formula | Entry Size | Table Base | Memory Type |
|--------|-----------------|---------|------------|------------|-------------|
| Hero | $F2AF | id*32+$6000 | 32 bytes | $6000 | Bank-switched PRG |
| City | $F2D7 | id*12+$63C0 | 12 bytes | $63C0 | Bank-switched PRG |
| Kingdom | $F368 | Pointer table | 8 bytes | $6F07 | Battery SRAM |
| Kata Name | $F308 | id*10+$901A | 10 bytes | $901A | Bank-switched PRG |
| Hero Init | $F387 | id*12+$8000 | 12 bytes | $8000 | Bank-switched PRG |
| RNG | $E87A | Table[$0050]++ | 1 byte | $E8BA | Fixed in bank 0x1F |

---

## Key Findings

1. **RNG**: Table-based lookup at $E87A, NOT LCG. Reads sequential bytes from pre-computed table at $E8BA. Index at $0050, preserved across calls.

2. **Address Functions**: All data access functions compute pointers into bank-switched memory. They return the pointer in $0000/$0001 for indirect access.

3. **Multiply Patterns**: Hero uses *32 (5 ASL), City/Init use *12 (*3 then *4), Kata uses *10 (*5 then *2), Kingdom uses pointer table.

4. **Kingdom Data**: Stored in battery-backed SRAM at $6F07, accessed via pointer table at $F379 (not multiply+offset like others).

5. **Mapper Init**: $F3BD is mapper configuration + controller check, NOT hardware init as previously assumed.

6. **Disassembler Bug Fixed**: The previous analysis was incorrect because the disassembler calculated file offsets wrong (used `addr - start_addr` instead of `addr - base_addr`). Added `base_addr` parameter to fix this. Also added missing opcode 0x6D (ADC abs).