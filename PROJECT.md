# Sangokushi 2 - Haou no Tairiku (J) - NES Disassembly Project

## Overview

Disassembly project for **Sangokushi 2 - Haou no Tairiku (J)** (三國志II 覇王の大陸), a Namco strategy game for NES.

### ROM Info
- **Mapper**: 19 (Namco-163)
- **PRG ROM**: 32 banks x 8KB = 256KB
- **CHR ROM**: 32 banks x 8KB = 256KB
- **Mirroring**: Horizontal
- **Battery**: Yes (save data at $6000-$7FFF)

## Project Structure

```
sango2dasm/
├── Sangokushi 2 - Haou no Tairiku (J).nes  # Original ROM
├── Makefile                                 # Build system
├── linker.cfg                               # ca65 linker config
├── asm/
│   ├── main.asm                             # Entry point (reset/NMI/IRQ stubs)
│   └── banks/                               # 32 bank stub files (prg_00.asm - prg_1f.asm)
├── include/
│   ├── 6502_registers.h                     # PPU/APU register definitions
│   ├── namco163.h                           # Namco-163 mapper definitions + bank switch macros
│   └── macros.h                             # Common 6502 macros
├── rom/
│   ├── prg/                                 # 32 x 8KB PRG binary banks
│   ├── chr/                                 # 32 x 8KB CHR binary banks
│   ├── prg_combined.bin                     # Combined PRG (256KB)
│   └── rom_info.h                           # Auto-generated ROM info
├── tools/
│   ├── split_rom.py                         # Split ROM into banks
│   ├── disasm_6502.py                       # 6502 disassembler (listing format)
│   ├── analyze_rom.py                       # ROM structure analyzer
│   ├── generate_bank_stubs.py               # Generate bank stub .asm files
│   ├── verify_rom.py                        # Verify rebuilt ROM matches original
│   ├── charmap_kana.py                      # Kana char map + name-string decoder
│   ├── extract_officer_names.py             # Dump the officer katakana names (237 in 240 slots)
│   ├── map_officer_kanji.py                 # Join officer ids to kanji/Chinese names
│   ├── extract_officer_data.py              # Decode the 12-byte officer records from the .nes
│   ├── extract_province_data.py             # Decode the 30 province names + 32-byte records
│   ├── data/
│   │   ├── officer_kanji.tsv                # id -> kanji / 繁體 / 简体 / pinyin map
│   │   └── province_kanji.tsv               # Province id -> kanji / 繁體 / 简体 / pinyin map
│   └── build_nes.py                         # Add iNES header to PRG binary
├── code/                                    # Place for disassembled code
├── docs/
│   ├── officer_names.txt                    # Extracted officer katakana name table
│   ├── officer_names.csv                    # Same, as CSV
│   ├── officer_names_kanji.md               # Officer names with kanji/Chinese + provenance
│   ├── officer_names_kanji.csv              # Same, as CSV
│   ├── officer_data.md                      # Officer katakana + 简体 + decoded starting stats
│   ├── officer_data.csv                     # Same, as CSV (adds raw record bytes)
│   ├── province_names.csv                   # 30 province katakana names + kanji/繁體/简体/pinyin
│   ├── province_data.md                     # Province record layout, countries, starting data, raw dumps
│   ├── province_data.csv                    # Same, as CSV (adds raw record bytes)
│   └── manual_kb/                           # Knowledge base transcribed from the original Japanese manual
├── res/
│   └── manual_jpn/                          # Scanned pages of the original user manual (37 JPGs)
└── build/                                   # Build output
    ├── sango2.nes                           # Built ROM
    ├── prg.bin                              # Raw PRG output from linker
    ├── main.o                               # Object file
    ├── main.lst                             # Assembly listing
    └── map.txt                              # Linker map file
```

## Toolchain

### cc65
Installed from source (GitHub master) to `~/.local/`:
- `ca65` V2.19 - 6502 assembler
- `ld65` V2.19 - linker

Path: `/home/zero/.local/bin/` (added to PATH in `.bashrc`/`.zshrc`)

### Makefile Targets

| Target | Description |
|--------|-------------|
| `make` | Build NES ROM from assembly |
| `make split` | Split original ROM into PRG/CHR banks |
| `make banks` | Generate PRG bank stub files |
| `make analyze` | Analyze original ROM structure |
| `make disasm FILE=rom/prg/prg_XX.bin ADDR=XXXX LEN=256` | Disassemble binary (use ADDR=E000 for bank 0x1F) |
| `make verify` | Compare built ROM with original |
| `make clean` | Remove build artifacts |

## Memory Map

| Range | Description |
|-------|-------------|
| $0000-$07FF | RAM (2KB) |
| $2000-$2007 | PPU registers |
| $4000-$401F | APU/IO registers |
| $4800 | Namco-163 IRQ/sound register |
| $6000-$7FFF | SRAM (8KB, battery-backed) |
| $8000-$9FFF | PRG slot 0 (switchable 8KB) |
| $A000-$BFFF | PRG slot 1 (switchable 8KB) |
| $C000-$DFFF | PRG slot 2 (switchable 8KB) |
| $E000-$FFFF | PRG slot 3 (switchable 8KB, **bank 0x1F fixed at boot**) |

Consolidated semantic map of `$0000-$07FF` and `$6000-$7FFF` (grouped by
function, with per-bank aliases): [code/cpu_ram_map.md](./code/cpu_ram_map.md).

## Namco-163 Bank Switching

Write bank number to these addresses to switch 8KB PRG banks:

| Address | Slot |
|---------|------|
| $F800 | $8000-$9FFF |
| $FA00 | $A000-$BFFF |
| $FC00 | $C000-$DFFF |
| $FE00 | $E000-$FFFF |

Use macros from `include/namco163.h`:
```asm
switch_bank_8000 BANK_05   ; Load bank 5 into $8000-$9FFF
switch_bank_A000 BANK_0A   ; Load bank 10 into $A000-$BFFF
```

## Reset Handler

Located at **Bank 0x1F, address $E000** (`rom/prg/prg_1f.bin` mapped to $E000-$FFFF).

The reset code at $E000 does:
1. SEI/CLD, init stack
2. PPU warmup (3 VBlank waits)
3. APU init
4. Clear RAM $0000-$07FF
5. Init stack pointer
6. Reads a vector table at $E07C (indexed by a counter at $007A & $1F)
7. Jumps through the indirect vector

The vector table at $E07C contains entries for each game state, each a 2-byte address within bank 0x1F. The game uses this as a dispatch mechanism.

**Important**: Bank 0x1F is mapped to $E000-$FFFF (PRG slot 3) at boot, NOT $8000-$9FFF. This is the fixed boot bank for Namco-163 mapper.

## ROM Bank Analysis

Key banks identified by `make analyze`:

| Bank | Characteristics | Likely Purpose |
|------|----------------|----------------|
| 0x1F | RESET marker, 445 JSR | Reset handler, main dispatch |
| 0x14 | 655 JSR, 719 RTI | Heavy code (graphics?) |
| 0x15 | 429 JSR, 930 RTI | Heavy code (graphics?) |
| 0x16 | 428 JSR, 549 RTI | Heavy code |
| 0x10 | 341 RTI, low JSR | IRQ/data heavy |
| 0x1E | 384 RTI | IRQ/data heavy |
| 0x07 | All 0xFF | Empty bank |

Banks with `[CODE]` marker have high JSR counts and are likely code-heavy.

## Disassembly Workflow

1. **Start with Bank 0x1F** - Contains reset handler and dispatch logic
   ```
   make disasm FILE=rom/prg/prg_1f.bin ADDR=E000 LEN=1024
   ```

2. **Follow the dispatch** - The reset handler reads vectors from $E07C and jumps to the actual game code

3. **Replace stubs** - Edit `asm/banks/prg_XX.asm` files:
   - Remove `.incbin` directive
   - Add actual disassembled code
   - Use proper `.segment` directives

4. **Update linker.cfg** - Add segments for each bank as you disassemble

5. **Verify** - Run `make verify` to check byte-exact match with original

## Linker Config

`linker.cfg` defines 4 PRG slots ($8000-$FFFF). As you disassemble more banks:
- Add new MEMORY regions for each bank
- Add corresponding SEGMENTS
- Assign code to the correct bank segment

## Include Files

- **6502_registers.h** - PPU ($2000-$2007), APU ($4000-$4017) register addresses and bit definitions
- **namco163.h** - Bank switch addresses, bank indices (BANK_00-BANK_1F), `switch_bank_*` macros
- **macros.h** - Common macros: `wait_vblank`, `set_ppu_addr`, `ppu_write`, `dma_sprites`
- **officer_ids.inc** - `OFFICER_*` id equates (generated, see below)

## Officer Name Table

**The game has 237 officers** (ids 0-236). The name table and the SRAM officer
array are both sized for **240 slots**, so ids 237-239 exist but are blank
spares - don't mistake the array capacity for the officer count.

The name slots live in PRG bank `$30` (physical bank `$10`) at
`$901A`, 10 bytes per entry, `$00`-terminated, encoded in the serial-gojuon
kana code space documented in `tools/charmap_kana.py`. The entry index is the
officer id, so `name = id * 10 + $901A` (`GetNameDisplayScale` `$F308`) pairs
with `sram_record = id * 12 + $63C0` (`GetOfficerRecordAddr` `$F2D7`).

```
python tools/extract_officer_names.py [--print]
```

Outputs:

| Path | Contents |
|------|----------|
| `docs/officer_names.txt` | Aligned table: id, `$901A` address, file offset, SRAM record, raw bytes, glyph count, display scale, katakana, romaji |
| `docs/officer_names.csv` | Same data as CSV (adds a hiragana column) |
| `include/officer_ids.inc` | `OFFICER_<ROMAJI> = <id>` equates, plus `OFFICER_COUNT` (237) and `OFFICER_SLOT_COUNT` (240) |
| `include/province_ids.inc` | `PROVINCE_<ROMAJI> = <id>` equates, plus the province table base/stride constants (see [Province Data Table](#province-data-table)) |

Three independent facts pin the 237/240 split: name slots 237-239 are blank,
the ROM master stat table in bank `$31` at `$8000` stops after record 236, and
indices 240/241 of the name table are the resource labels キン/コメ, which is
where the officer block ends.

### Kanji and Chinese names

The game's font has no kanji, so the ROM only ever stores the katakana reading.
`tools/data/officer_kanji.tsv` is a checked-in map from officer id to the kanji
name plus its traditional/simplified Chinese forms and pinyin. Each entry was
tied to its ROM id by an exact match on the five visible stats in the master
stat table, then reading-checked against the ROM katakana by composing the
on-yomi of its characters.

```
python tools/map_officer_kanji.py [--check] [--print]
```

| Path | Contents |
|------|----------|
| `tools/data/officer_kanji.tsv` | Source map: id, katakana, `kanji_ja`, `zh_hant`, `zh_hans`, `pinyin`, `note` |
| `docs/officer_names_kanji.md` | Readable table plus the provenance/method write-up and caveats |
| `docs/officer_names_kanji.csv` | Same joined against the ROM extraction (adds hiragana/romaji) |

`--check` re-validates the map against the ROM (ids line up, names are
one-to-one, every reading composes) without writing anything.

## Officer Data Table

Each officer also has a 12-byte master record in PRG bank `$31` at `$8000`
(PRG offset `$22000`, `.nes` offset `$22010`), which seeds the SRAM record at
`id * 12 + $63C0` at new game. `tools/extract_officer_data.py` reads the
original `.nes` image directly — it parses the iNES header rather than assuming
a fixed data start — decodes all 237 records, and joins the ROM katakana names
with the simplified-Chinese names from `tools/data/officer_kanji.tsv`.

```
python tools/extract_officer_data.py [--rom PATH] [--check] [--print]
```

| Offset | Field |
|--------|-------|
| `+0` … `+4` | 体力 Vitality, 武力 Might, 知力 Intelligence, 忠誠度 Loyalty, 人徳 Virtue |
| `+5` | always `0` in ROM (runtime-only field) |
| `+6/+7` | 経験値 Experience, 16-bit LE |
| `+8/+9` | 兵数 TroopCount, 16-bit LE (non-zero only for the officers already on the map at the 189 start) |
| `+10` | bits 0-4 = 武器 Weapon, bits 5-7 = 防具 Armor |
| `+11` | bits 4-7 = レベル OfficerLevel (0-based), bits 0-3 = 軍の属性 ArmyAffinity (平/山/水) |

Column names in the generated files use the canonical semantic English terms
from `docs/manual_kb/terminology.md`.

| Path | Contents |
|------|----------|
| `docs/officer_data.md` | Record layout, weapon/armor code tables, and all 237 officers |
| `docs/officer_data.csv` | Same as CSV, plus equipment indices and the raw 12 record bytes |

The decode is confirmed by the manual's 呂布 duel data
(`docs/manual_kb/10-duel-mode.md`), which matches record 218 field for field.
`--check` validates without writing.

## Province Data Table

The 30 provinces (the manual calls them 国) have two ROM tables, both in PRG
bank `$30`:

| Table | CPU | PRG offset | Stride |
|-------|-----|------------|--------|
| Province katakana names | `$9A1A` | `$21A1A` | 8 bytes, `$00`-terminated |
| Province master records | `$8C00` | `$20C00` | 32 bytes |

`SramInit` (`$DD8B`, `asm/banks/prg_1d_1e.asm`) copies the whole `$3C0`-byte
record block verbatim to SRAM `$6000`, so the ROM block *is* the new-game
starting state: `sram_record = id * 32 + $6000`. Names are drawn by
`CmdDrawNameFromData` (`ptr = id * 8 + $9A1A`, up to 6 glyphs).

```
python tools/extract_province_data.py [--rom PATH] [--check] [--print]
```

| Offset | Field |
|--------|-------|
| `+0` | 所属国 Country: low nibble = Country id 0-6, `7` = 空白地 UnclaimedLand |
| `+2/+3` | 金 Gold, 16-bit LE |
| `+4/+5` | 米 Rice, 16-bit LE |
| `+6/+7` | 人口 Population, 16-bit LE, stored / 100 |
| `+8/+9` | 土地 LandValue, 16-bit LE (drives the annual 米 harvest) |
| `+10` | 防災 DisasterPrevention |
| `+11` | 統治度 Governance (below 50 the annual check rolls a revolt) |
| `+12/+13` | 控え ReserveTroops, 16-bit LE (徴兵 target, capped 10000) |
| `+14/+15` | 産業 Industry, 16-bit LE (drives the annual 金 tax) |
| `+16` | 宝 Treasure |
| `+17..+26` | 武将 Officer roster, 10 slots, `$FF` = empty |
| `+27` | 反乱クールダウン RevoltCooldown, in months |

| Path | Contents |
|------|----------|
| `tools/data/province_kanji.tsv` | Source map: id, katakana, `kanji_ja`, `zh_hant`, `zh_hans`, `pinyin`, `note` |
| `docs/province_names.csv` | Name table: id, address, raw bytes, katakana/hiragana/romaji, kanji + Chinese + pinyin |
| `docs/province_data.md` | Record layout with its code evidence, the 7 countries and their rulers, starting data, rosters, raw hex dumps |
| `docs/province_data.csv` | Same as CSV, plus the raw 32 record bytes; its column names are documented in the *CSV columns* table of `docs/province_data.md` |
| `include/province_ids.inc` | `PROVINCE_<ROMAJI> = <id>` equates plus the table base/stride constants |

Column names in the generated CSV are the snake_case form of the canonical
semantic English terms from `docs/manual_kb/terminology.md` (`country_id`,
`land_value`, `industry`, `treasure`, `reserve_troops`, `active_troops`, ...);
the full column glossary is in `docs/province_data.md`.

The two 999-capped stats are told apart by the annual income routines in
`asm/banks/prg_19_1a.asm`: `$A60B` scales `+8/+9` into 米 (土地) and `$A446`
scales `+14/+15` into 金 (産業), both multiplied by the 統治度 tier. This also
resolves three province readings the manual scan could not
(`docs/manual_kb/14-map.md`): 襄陽, 涪陵, 永昌. `--check` validates without
writing.

## Game Manual Knowledge Base

`docs/manual_kb/` contains a structured knowledge base transcribed from the
scanned original Japanese manual in `res/manual_jpn/` (see
`docs/manual_kb/README.md` for the index and scan-to-page map). It documents
the canonical Japanese terminology — mode names (戦略/戦術/戦闘/一騎討ち),
strategy-mode commands, tactical commands, 計略/戦術 lists, formations,
duel commands, stats, events, rulers, and the 30-country map. Use it as the
authoritative vocabulary source when naming labels/procs during disassembly.

## Current Status

- Build system: Working
- ROM split: Done (32 PRG + 32 CHR banks)
- Bank stubs: Generated (all `.incbin` based)
- Disassembly: Not started (stub code only)
- Accuracy: 0% (stub code replaces all banks)

## Next Steps

1. Disassemble Bank 0x1F reset handler ($E000-$E100)
2. Map the vector table at $E07C
3. Identify bank switching routines
4. Begin disassembling other banks based on dispatch targets
5. Replace `.incbin` stubs with real code incrementally
6. Use `make verify` to track progress
