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
│   └── banks/                               # Bank files: code prg_XX.asm, seed data data_XX.asm
│       ├── data_00_terrain.asm                       # Terrain DATA bank (reg $20, prov 0-7): annotated .byte hex, CSV-linked
│       ├── data_02_sound.asm                       # Sound DATA bank (reg $22): note descriptors + command streams (tail in $03)
│       ├── data_03_terrain.asm                       # Terrain DATA bank (reg $23, prov 8-13): annotated .byte hex
│       ├── data_04_terrain.asm                       # Terrain DATA bank (reg $24, prov 16-23): annotated .byte hex
│       ├── data_05_terrain.asm                       # Terrain DATA bank (reg $25, prov 14-15,24-29): annotated .byte hex
│       ├── data_06_placement_and_scroll.asm                       # DATA bank (reg $26): war unit-placement pools + ending-scroll panel graphics
│       ├── data_10_seed.asm                       # Seed DATA bank (reg $30): annotated .byte records
│       └── data_11_officer.asm                       # Seed DATA bank (reg $31): annotated .byte records
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
│   ├── verify_seed_tables.py                # Re-check the new-game seed tables and the SramInit copies
│   ├── analyze_disaster_pick_rng.py         # All 256 disaster pick RNG indices + same-month Province pair coherence
│   ├── gen_data_bank_asm.py                 # Render seed banks $10/$11 as annotated .byte asm
│   ├── verify_data_banks.py                 # Assemble those banks, prove byte-exact, decode edits
│   ├── gen_data_bank_02_asm.py              # Render sound bank $02 as descriptors + decoded command streams
│   ├── sound_streams.py                     # Namco-163 command-stream decoder: format, walk, coverage proof
│   ├── verify_data_bank_02.py               # Assemble bank $02, prove byte-exact, decode diffs by soundID/cell
│   ├── gen_data_bank_06_asm.py              # Render bank $06 as placement pools / bounds rects / scroll tile + sprite tables
│   ├── verify_data_bank_06.py               # Assemble bank $06, prove byte-exact, re-derive its geometry from the ROM
│   ├── dump_bank_00_terrain.py              # Decode/draw the tactical terrain crops of banks $00/$03/$04/$05
│   ├── terrain_model.py                     # Terrain codec (4 banks, 120 zones): geometry, driver tables, tile->terrain, CSV, asm renderer
│   ├── gen_terrain_asm.py                   # Render the terrain banks as annotated .byte hex (+ their CSV twins)
│   ├── verify_terrain_banks.py              # Assemble the terrain banks, prove byte-exact, decode terrain edits
│   ├── check_terrain_pipeline.py            # Prove ROM <-> CSV <-> asm <-> editor views is lossless (all banks)
│   ├── terrain_tiles.py                     # Tile byte -> MetaTileData -> CHR (record 1) -> 16x16 RGB cell, for real-tile rendering
│   ├── data/
│   │   ├── officer_kanji.tsv                # id -> kanji / 繁體 / 简体 / pinyin map
│   │   └── province_kanji.tsv               # Province id -> kanji / 繁體 / 简体 / pinyin map
│   └── build_nes.py                         # Add iNES header to PRG binary
├── code/                                    # Place for disassembled code
│   └── disaster_pick_rng_coherence.md       # Flood/drought pick: 256 indices + same-month Province pair coherence
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
│   ├── terrain_bank_00.csv                   # Terrain of provinces 0-7: one owner row x 16 tile bytes per 16 B (editable)
│   ├── terrain_bank_03.csv                   # provinces 8-13 (same shape)
│   ├── terrain_bank_04.csv                   # provinces 16-23
│   ├── terrain_bank_05.csv                   # provinces 14-15, 24-29
│   ├── disaster_pick_rng_sequences.csv      # All 256 random indices -> flood/drought hit Provinces (generated)
│   ├── disaster_pick_rng_pair_coherence.csv # Per-Province-pair joint hit counts / lift / phi in one month (generated)
│   └── manual_kb/                           # Knowledge base transcribed from the original Japanese manual
├── res/
│   └── manual_jpn/                          # Scanned pages of the original user manual (37 JPGs)
├── editor/                                  # Standalone GUI project: tactical map editor (tkinter)
│   ├── tactical_map_editor.py               # Paint any of the 30 provinces (terrain-class or real CHR tiles), save CSVs, drive gen/verify tools
│   └── README.md                            # Usage, views, pipeline link, terrain semantics
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
| `make databanks` | Re-render the annotated seed-data banks `$10`/`$11` from the ROM, then verify |
| `make databanks-csv` | Re-render them from the decoded `docs/*.csv` (the CSV editing path) |
| `make verifydata` | Assemble banks `$10`/`$11` standalone and prove byte-exactness |
| `make databank02` | Re-render the sound/note bank `$02` from the ROM (descriptors + decoded streams), then verify |
| `make verifydata02` | Assemble bank `$02` standalone, prove byte-exactness and re-walk the stream area |
| `make databank06` | Re-render war-placement / strategy-scroll data bank `$06` from the ROM, then verify |
| `make verifydata06` | Assemble bank `$06` standalone, prove byte-exactness and re-derive its region geometry |
| `make terrain` | Re-render the four terrain banks `$00/$03/$04/$05` (30 provinces) as hex + `docs/terrain_bank_XX.csv` from the ROM, then verify |
| `make terrain-csv` | Re-render them from the edited terrain CSVs (the CSV editing path) |
| `make verifyterrain` | Assemble the terrain banks standalone and prove byte-exactness |
| `make checkterrain` | Prove the ROM <-> CSV <-> asm <-> editor loop is lossless |
| `make map-editor` | Launch the standalone tactical-map GUI editor (`editor/`) |
| `make analyze` | Analyze original ROM structure |
| `make disasterrng` | Re-enumerate the 256 disaster province-pick RNG indices and rebuild the same-month coherence doc/CSVs |
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
| 0x10 | 341 RTI, low JSR | **Data bank** (register `$30`): province records, officer/province name tables |
| 0x11 | - | **Data bank** (register `$31`): officer master records, arrival schedule, death-year table |
| 0x1E | 384 RTI | IRQ/data heavy |
| 0x07 | All 0xFF | Empty bank |

Banks with `[CODE]` marker have high JSR counts and are likely code-heavy.
The RTI-based heuristic misreads dense data as code: banks `0x10`/`0x11` are only
ever selected into the `$8000-$9FFF` data window and every region decoded so far
is a lookup table, so they stay `.incbin` stubs - see
[code/initial_data_tables.md](./code/initial_data_tables.md).

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
(PRG offset `$22000`, `.nes` offset `$22010`, `rom/prg/prg_11.bin + $0000`),
which seeds the SRAM record at `id * 12 + $63C0` at new game. `SramInit`
(`$DD8B`) copies `$0B40` bytes = 240 slots, so slots `$ED`-`$EF` are padding and
the real count is 237 — every officer scan loop stops at `CMP #$ED`.
`tools/extract_officer_data.py` reads the original `.nes` image directly — it
parses the iNES header rather than assuming a fixed data start — decodes all
237 records, and joins the ROM katakana names (bank `$30` `$901A`, 10 B/entry)
with the simplified-Chinese names from `tools/data/officer_kanji.tsv`.

```
python tools/extract_officer_data.py [--rom PATH] [--check] [--print]
```

| Offset | Field |
|--------|-------|
| `+0` … `+4` | 体力 Vitality, 武力 Might, 知力 Intelligence, 忠誠度 Loyalty, 人徳 Virtue |
| `+5` | always `0` in ROM (runtime-only 位置 LocationProvince) |
| `+6/+7` | 経験値 Experience, 16-bit LE |
| `+8/+9` | 兵数 TroopCount, 16-bit LE (non-zero only for the officers already on the map at the 189 start) |
| `+10` | bits 0-4 = 武器 Weapon, bits 5-7 = 防具 Armor |
| `+11` | bits 4-7 = レベル OfficerLevel (0-based), bits 2-3 = 軍の属性 ArmyAffinity (0 平 / 1 山 / 2 水), bits 0-1 = 状態 OfficerStatus (seed: 1 hidden, 2 rostered) |

The two low bit pairs of `+11` are independent fields: the seed status `2` set
is *exactly* the set of officers listed in the Province roster slots (57 of
them), which is what separated the status bits from the affinity bits.
Column names in the generated files use the canonical semantic English terms
from `docs/manual_kb/terminology.md`.

| Path | Contents |
|------|----------|
| `docs/officer_data.md` | Record layout, weapon/armor code tables, and all 237 officers |
| `docs/officer_data.csv` | Same as CSV, plus equipment indices, status, roster/schedule cross-references and the raw 12 record bytes |

The decode is confirmed by the manual's 呂布 duel data
(`docs/manual_kb/10-duel-mode.md`), which matches record 218 field for field.
`--check` validates without writing (it also asserts the roster/OfficerStatus
agreement and the arrival-schedule counts). The hidden officers' starting
Province and appearance year come from the arrival schedule in the same bank at
`$8B1C`; the byte-exact evidence for all of this is in
[code/initial_data_tables.md](./code/initial_data_tables.md), machine-checked by
`tools/verify_seed_tables.py`.

The bank itself is checked out as readable data: `asm/banks/data_11_officer.asm` renders
all 237 officer records as labelled `.byte` rows (`OfficerRecord_<NAME>`, one
decoded summary per row) with the unanalysed ranges kept as sliced `.incbin`.
Edit it directly, or edit `docs/officer_data.csv` and run `make databanks-csv`;
`make verifydata` assembles the bank, proves it byte-exact against the ROM and
reports any change as `OfficerRecord_RYOFU (218 吕布): 武力 Might $63 -> $64`.
Labels come from `include/officer_ids.inc`, so label, code symbol and CSV row
name the same officer.

## Province Data Table

The 30 provinces (the manual calls them 国) have two ROM tables, both in PRG
bank `$30`:

| Table | CPU | PRG offset | Bank file + offset | Stride |
|-------|-----|------------|--------------------|--------|
| Province katakana names | `$9A1A` | `$21A1A` | `prg_10.bin + $1A1A` | 8 bytes, `$00`-terminated |
| Province master records | `$8C00` | `$20C00` | `prg_10.bin + $0C00` | 32 bytes |

`SramInit` (`$DD8B`, `asm/banks/prg_1d_1e_menu_screens.asm`) copies the whole `$3C0`-byte
record block verbatim to SRAM `$6000` (`@Copy1Loop`, `$DDCD`-`$DE10`: bank `$30`,
source `$8C00`, length test `CMP #$03` / `CPX #$C0`), so the ROM block *is* the
new-game starting state: `sram_record = id * 32 + $6000`. The block fills
`$6000-$63BF` exactly and the officer seed block starts at the next byte,
`$63C0`. Names are drawn by `CmdDrawNameFromData` (`$A426`: bank `$30`,
`ptr = id * 8 + $9A1A`, up to 6 glyphs).

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
| `+17..+26` | 武将 Officer roster, 10 slots, `$FF` = empty (these ids are exactly the officer seed records with 状態 = 2) |
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
`asm/banks/prg_19_1a_event_scenes.asm`: `$A60B` scales `+8/+9` into 米 (土地) and `$A446`
scales `+14/+15` into 金 (産業), both multiplied by the 統治度 tier. This also
resolves three province readings the manual scan could not
(`docs/manual_kb/14-map.md`): 襄陽, 涪陵, 永昌. `--check` validates without
writing, including that the roster set equals the officer seed's status-2 set.
Byte-exact location evidence: [code/initial_data_tables.md](./code/initial_data_tables.md).

`asm/banks/data_10_seed.asm` renders both province tables as labelled `.byte` records
(`ProvinceRecord_<NAME>` with a decoded summary per province, plus
`ProvinceName_<NAME>`), verified byte-exact by `make verifydata`.

## Sound Data (Banks $02 + $03 Head)

`make databank02` renders `asm/banks/data_02_sound.asm`; `make verifydata02` (or
`python tools/verify_data_bank_02.py`) assembles it standalone, proves it is
byte-exact against `rom/prg/prg_02.bin`, re-walks the stream area and describes
any diff as *soundID / stream address / cell index / opcode-or-operand*.
`python tools/sound_streams.py --validate` is the coverage proof, `--dump 08 98`
prints a stream as annotated text. Streams are labelled `SoundStream_B02_SndXX`;
the bank $03 half is decoded the same way in `data_03_terrain.asm` (`SoundStream_B03_*`,
owned by `tools/terrain_model.py` / `make terrain`).

**Access path.** `B1F_SoundNotePlayer` ($E609) is the only reader of the
descriptor table: `LDY #$22 ; JSR SwitchBank8_B`, then it reads `$8000+soundID*4`
and copies it into a sound-RAM track block at `$0700+X` (stride $16, 11 tracks).
The per-frame driver is `B0E/B0F BattleAnimSoundEngine` ($D8D4) with
`BattleSoundChannelProc` ($DC59); it maps **two** windows - bank $02 at $8000 and
**bank $03 at $A000** ($23 | $C0 -> `NAMCO_PRG_A000`) - so stream pointers with
high byte $A0-$A8 read bank $03. The wavetable is not in these banks: it is
`B1F_WavetableInitData` ($E6A6, bank $1F), uploaded by `SoundInit` ($E590).

**Header entries (184 rows, $8000-$82DF).** The last 2 bytes of every entry are
one 16-bit stream pointer (b2 = low, b3 stored at `$0703,X` as b3 + $40 = high).
b0 = sound-RAM track slot (X = b0, stride $16, 11 tracks at `$0700`; `$0700,X <- $00`
arms the track, `$FF` is the idle sentinel), b1 = hardware channel 0-7 (0-3 APU
pulse1/pulse2/triangle/noise, 4-7 Namco-163); on a retrigger of a busy track the
player mutes that track's previous APU channel via `$4015` (SoundChannelTable
$E667). Entry $B7's pointer ($4010) is never followed - its 4 bytes at $82DC are
the note that 17 pointers target (so `SoundCommandStreams` starts there and its
`$FF` terminator lands at $82E0), which is how the `SoundWrapper0..F` fall-through
chain leaves individual tracks of a fanfare silent.

**Stream.** 4-byte record header (tick divisor, duty source, channel control byte
= volume/env/duty, sweep byte) then 2-byte command cells `[opcode][operand]`:
`<$A0` pitch (low nibble = semitone over `NoteFreqTable` row 1 = F1..E2, bits4-6 =
octaves up, `$C-$F` = rest, operand = sustain in ticks), `$A0/$A1/$A2/$A3/$A4`
control/sweep/duty/vibrato-on/off, `$B0 nn` goto cell nn, `$Bn nn` that jump n
more times over a `$FD` marker, `$Cn nn` tremolo, `$Dn/$En nn` volume LFO,
`$AD` reloc (unused by this ROM), `$FF` end. `$FF`'s operand byte is **not**
consumed, so the next stream starts on the very next byte: 166 streams pack
$82DC-$A965 with zero gaps and zero unknown opcodes (3136 pitch cells; song
lengths quantise to 14-frame ticks, the duel music to 12).

Note names in the generated comments are the pulse reference; the triangle
channel sounds 3 octaves higher and the 163 channels use `NoteFreqTable`'s
separate divisor rows (index base +$30).

**Bank $03.** Offsets $0000-$0965 are sound data (the tail of the stream area,
reached at $A000 while the driver runs) - which is why that bank's terrain ribbon
only starts at $89A6. `tools/terrain_model.py` owns that boundary and labels the
area `sound_stream`/`sound_tail`; the 64 bytes at $0966-$09A5 in front of the
first crop are its NES attribute head, the same head every crop carries
(`code/bank_00_data_layout.md` §5a/§7).

## War Placement + Strategy Scroll Data (Bank $06)

`make databank06` renders `asm/banks/data_06_placement_and_scroll.asm`; `make verifydata06` (or
`python tools/verify_data_bank_06.py`) assembles it standalone, proves it
byte-exact against `rom/prg/prg_06.bin`, re-derives the region geometry from the
ROM (pointer runs, per-scene record counts against the bank $10/$11 selectors,
the blob chains, the filler tail) and fails if the on-disk file has drifted from
what the generator renders.

**Access path.** The bank is only ever selected into the `$8000-$9FFF` window
(`LDY #$26 ; JSR B1F_SwitchBank8_A/B`), from eight sites in three code banks:
`prg_08_09_tactical_war` war AI placement (`GetOrderedDestination` $A1E5,
`@SetupDefenderRoster` $B2E4, `@SetupAttackerRoster` $B343), `prg_0c_0d_tactical_commands`
army-deploy (`@BuildOfficerList` $C3DC/$C42B, `@CheckBoundsForPosition`
$C455/$C495) and `prg_17_18_duel_and_display`'s event-message / ending scroll scene
(`EventMessageSceneDispatch` $D693, `ScrollPanel_LoadRow` $DC13,
`RenderDispatchSprite` $DBF3).

**Placement geometry ($8000-$95E5).** Four parallel 30-entry `.word` tables
keyed by `war_province_idx` ($050E) - the row index into bank $10's
`ProvinceAdjacencyTable` $9D72: attack pools ($8000, 91 x 34 B), defense pools
($8C52, 53 x 32 B), and the matching city-bounds rectangle tables ($932E /
$94D6, 91/53 x 4 B of `[row_min,col_min,row_max,col_max]`). Within a province the
*side type* selects the record: `TacticalAttackSideTypeTable` (bank $10 $9E62,
0-$03) scaled by 34, `TacticalDefenseSideTypeTable` (bank $11 $9AB4, 0-$01) scaled
by 32 - both keyed on the adjacency *slot* holding the target province, so the
choice is per approach route. Each pool is an entry **anchor** `(row,col)` then 15
**unit tiles**; `@Setup*Roster` seeds four per-slot read cursors
(`@AttackerCursorSeeds` $02/$0C/$16/$1C, `@DefenderCursorSeeds` $02/$08/$0C/$14)
which split those 15 pairs 5/5/3/2 and 3/2/4/6, each unit consuming one pair and
advancing its cursor by 2 into `unit_coord_y/x` ($0614/$0600).
`@CheckBoundsForPosition` uses the rectangle to gate which map tile the army-deploy
command may select. Pool rows skip 15 (observed $01-$0E then $10-$14), the same
row-15 quirk the terrain codec carries.

**Event-message / ending scroll graphics ($95E6-$9FBB).** Three 392-byte tile
blocks = 14 rows x 28 tiles, one per ending panel (scene phase $0541 = 1/2/3, the
three `ScrollPanel_LoadRow` call sites), streamed to PPU `$2082` - nametable $2000
rows 4-17, columns 2-29;
the attributes for that area come from the *local* `ScrollPanel_RowTemplate_*`
records in bank $17, not from this bank. Then three OAM sprite-blob tables (21 /
4 / 6 entries, 1-based) armed by scene phases 0 / 1 / 2 (`EventMessageScene_ChronPanel`,
`_HeroRisePanel`, `_HeroNamePanel`), in the shared `[y_off,tile,attr,x]` + `$80` terminator
format consumed by `B1F_SpriteOamWriterSimple` ($F1AD), with writer bases X $10 /
Y $1F forced by `RenderDispatchSprite`. `SpriteBlobIndexTable` ($D755, bank $17) that
selects blob indexes 9-21 is a pass *sequence*, not a bank or command lookup.
$9FBB-$9FFF is unused `$FF` filler.

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
