# Province Editor — Sangokushi 2 seed data, bank `$10`

A standalone editor for the **30 provinces** (州) of *Sangokushi 2 - Haou no
Tairiku* (Famicom, Namco-163 / mapper 19) as the new game seeds them.

```
editor/
├── province_editor.py    the GUI (Python 3 + tkinter, no third-party deps)
└── README_province.md    this file
```

It imports the codec `tools/officer_model.py` (searching `--model`, its own
directory, then the repo's `tools/`), the same module the officer editor and
CLI use. The terrain editor is [`README.md`](README.md); the officer editor is
[`README_officer.md`](README_officer.md).

## What it edits

| table | bank | CPU | shape | CSV twin |
|---|---|---|---|---|
| master records | `$30` | `$8C00` | 30 × 32 B | `docs/province_data.csv` |
| katakana names | `$30` | `$9A1A` | 30 × 8 B, `$00`-terminated | `docs/province_data.csv` (`katakana`) |
| officer rosters | `$30` | `$8C00 + $11..+$1A` | 30 × 10 slots, `$FF` = empty | `docs/province_data.csv` (`officer_ids`) |
| arrival schedule | `$31` | `$8B1C` | 30 × `$14` = ten (id, year) pairs | `docs/officer_data.csv` (`schedule_province_id`, `appear_year`) |

The master record is the seed image of the province's SRAM record at
`id * 32 + $6000`. `SramInit` (`$DD8B`, `asm/banks/prg_1d_1e_menu_screens.asm`)
copies exactly `$3C0` bytes = the 30 records, so these bytes are the new game:

| Offset | Field | Edited as | Notes |
|---|---|---|---|
| `+0` | 所属国 Country | `country_id` | low nibble 0-6, `7` = 空白地 UnclaimedLand |
| `+1` | — | — | runtime, always `$00` in the seed |
| `+2/+3` | 金 Gold | `gold` | 16-bit LE, ≤ 9999 |
| `+4/+5` | 米 Rice | `rice` | 16-bit LE, ≤ 9999 |
| `+6/+7` | 人口 Population | `population` | stored / 100; the editor only accepts multiples of 100 |
| `+8/+9` | 土地 LandValue | `land_value` | ≤ 999; drives the annual Rice harvest |
| `+A` | 防災 DisasterPrevention | `disaster_prevention` | ≤ 99 |
| `+B` | 統治度 Governance | `governance` | ≤ 100; below 50 the annual check rolls a rebellion |
| `+C/+D` | 控え ReserveTroops | `reserve_troops` | 16-bit LE, ≤ 9999; 徴兵 adds here |
| `+E/+F` | 産業 Industry | `industry` | ≤ 999; drives the annual Gold tax |
| `+10` | 宝 Treasure | `treasure` | ≤ 99 |
| `+11..+1A` | 武将 roster | `officer_ids` | 10 ids, `$FF` = empty; `+$11` is the 太守 governor |
| `+1B` | 反乱クールダウン | — | runtime, `$00` in the seed; the generator zeroes it |
| `+1C..+1F` | — | — | runtime, always `$00` in the seed |

The **現役** active-soldier total the game shows is not stored here: it is the
sum of the rostered officers' 兵数 TroopCount (`+8/+9` in the 12-byte officer
record). The editor shows that live total; it is not an editable field.

The katakana name is part of the editing surface. The kanji, simplified-Chinese
and pinyin columns are annotations (the game draws only the kana name, through
`CmdDrawNameFromData` `$A426`); `docs/province_names.csv` remains the
extraction-time reference and is no longer the name source once the province
CSV is edited.

## Invariants

The **report pane** shows two tiers.

*Problems* are exactly the rules `tools/verify_data_banks.py` re-checks on the
**assembled** bytes:

* 30 province ids, each exactly once;
* 所属国 is 0-7; 金/米 ≤ 9999, 土地/産業 ≤ 999, 防災/宝 ≤ 99, 統治度 ≤ 100,
  控え ≤ 9999;
* 人口 is a multiple of 100 (the record stores it / 100);
* every name encodes in the 8-byte field and draws at most six glyphs;
* no roster exceeds 10 slots, no slot is ≥ 237, and no officer appears twice;
* one province cannot hold two 忠誠度-100 officers (its 君主 would be ambiguous);
* the arrival schedule only lists 状態 1 officers, at most ten pairs per
  province block, and never a half-filled (province, year) pair.

*Live totals* are the country aggregates the game computes on the fly (there is
no per-country stat table in ROM): provinces owned, 君主, gold, rice, active
troops. The 189-start aggregates in `docs/country_data.csv` are extraction-time
data and are not rewritten by this editor.

## The cross-bank roster rule

A province roster slot and an officer's seed 状態 are two views of the same
fact:

    officer 状態 (record +$0B bits 0-1) == 2  ⇔  he occupies one roster slot

Every officer is 1 (hidden) otherwise. **Add** and **Remove** are the only way
this editor moves 状態: assigning sets the officer to 2 and writes him into
`docs/province_data.csv`; removing sets him back to 1. Moving an officer who is
already rostered in another province removes him from the old roster in the
same save. `tools/verify_data_banks.py` re-proves the two sets are equal on the
assembled banks, so an editor that let them drift would fail the byte gate.

## Requirements

Python 3 with `tkinter` for the GUI (stdlib; on Debian/Ubuntu
`sudo apt install python3-tk`). Developed against Python 3.14.

The repo-side buttons (`Write ASM`, `Verify`) additionally need `ca65`/`ld65`
at `/home/zero/.local/bin`, as every other byte gate in this project does.

## Running

Inside the disassembly repo (default — full pipeline available):

```sh
python3 editor/province_editor.py                 # loads docs/province_data.csv
make province-editor                              # same
python3 editor/province_editor.py \
    --province-csv docs/province_data.csv \
    --officer-csv docs/officer_data.csv
python3 tools/check_province_pipeline.py          # make checkprovinces
```

Outside the repo (standalone mode) the editor needs only the codec and the two
CSVs:

```sh
mkdir province-editor && cd province-editor
cp /path/to/sango2dasm/tools/officer_model.py .
cp /path/to/sango2dasm/docs/province_data.csv .
cp /path/to/sango2dasm/docs/officer_data.csv .
python3 /path/to/sango2dasm/editor/province_editor.py --model .
```

`--model PATH` may point at a directory holding `officer_model.py` or at the
file itself. Without the repo, `Write ASM` / `Verify` explain that the
generator lives there; editing, the invariant report, `Save CSVs` and `Diff`
all keep working.

## The screen

```
[Open CSVs…][Save CSVs][Write ASM][Verify][Diff][Revert][Undo][Redo]  Filter [........]
+----------------------------------------------------------+  +----------------------+
| [List 一覧][Strategy map 戦略図]                          |  | [Record 記録][Town 町]     |
| id 名前 kana 漢字 国 金 米 人口 土地 産業 防災 統治 控え 宝 |  | [Tactical map 戦術図]      |
| 武将 現役 太守  (30 rows, click to select)                |  | (tabbed detail pane)       |
+----------------------------------------------------------+  +----------------------+
Invariants / live province totals              |  Output
status bar
```

The **selector** is the left pane and has two tabs: **List 一覧** (the
editable table) and **Strategy map 戦略図** (the in-game map picker).

### Strategy map 戦略図 (selector)

The selector tab is the game's own strategy screen, not a schematic:
`StrategyMapBaseScreen` (bank $10 `$8000`, 960 tiles + 64 attribute bytes)
rendered with display record 0 (CHR pages `00 01 02 10`) and palette record
0 — the records `State_StrategyMapLaunch` arms — cropped to the authored map
band (tile rows 0-19; rows 20-29 are the blank overlay-panel band) and drawn
at 3× under the province marker sprites (tile `$DFC0[Country & 7]`,
attribute `$DFC8[Country & 7]`, sprite page `$04`). Clicking the map selects
a province through the engine's own hit test, `MapProvinceHitTest` (`$DEBA`):
a 16 × 16 zone anchored at the province's `MapZoneOriginXTable`/`YTable`
entry (bank $1C `$DEE9`/`$DF07`), scanned from id `$1D` down to 0 so the
higher id wins; the top-left `$20 × $20` corner and points outside every zone
select nothing. The visible 8 × 8 marker icon is boxed in white when selected
and in yellow under the cursor. The line below the map lists the adjacency:
every neighbour slot with its attack/defense side type (`$9E62` bank $10 /
`$9AB4` bank $11). Marker colours come from the marker sprites, so editing a
province's Country repaints the map.

The detail pane is a three-tab notebook:

### Record 記録 (editable)

* **Identity** — katakana name (editable), the read-only kanji/simplified/
  pinyin annotations, the name field address, Country dropdown, ruler and
  governor.
* **Resources** — the nine numeric record fields, with the byte ranges in the
  labels. Values commit on Enter, focus-out or a spinbox arrow.
* **Roster** — ten slot rows. **Add officer…** opens a filterable picker;
  **Remove** sets 状態 1; **太守 slot 0** moves the selected officer to `+$11`;
  **Up/Down** reorder the list. Slot 0 is green.
* **Arrival officers 出現武将** — this province's block of the bank $31 `$8B1C`
  arrival schedule, as `(year, officer)` pairs. **Add…** schedules a hidden
  officer (the year spinbox is the pair year), **Set year** re-points the
  selected entry, **Remove** drops it (the officer stays hidden,
  unscheduled). A block holds at most ten pairs; the renderer sorts by
  (year, id). These edits land in `docs/officer_data.csv`, the same surface
  the officer editor drives.
* **Country** — the live aggregate (there is no per-country stat table).
* **Raw record** — the 32 bytes the generator will emit, with the offset map.

### Town 町 (read-only)

The province's town type (`$C025`, bank $1C) and the facility screens it
routes to — 武器屋 armory, 学問所 academy, 病院 hospital, 商店 market
(`$C10E`) —, the `ProvinceFacilityFlags` bits 兵/学/町/募 (bank $30 `$8FFC`),
the rice trade rates (sell/buy per 100 金, bank $30 `$8FC0`) and the armory's
16-cell grid with every cell's equipment id and gold price (formation id
`$C801` fanned through `FormationTileLayouts`, priced by `ItemPriceTable`
bank $09 `$C89E`; unpriced special cells show —).

### Tactical map 戦術図 (read-only)

The province's authored 32 × 20 terrain (the same bytes
`tools/terrain_model.py` decodes, castle ring included), the 民/武/病 facility
tiles (bank $11 `$9BA4`), and the initial deployment geometry from bank $06.
There is not one offense area but one **per approach route**: the side type is
keyed on the adjacency slot holding the opposing province, so every attack
record is the initial area the map uses when a *specific neighbour* marches
in. All routes draw at once, each in its own colour (◆ = that record's
anchor, pair 0; outline = its unit cells; dashed = its city-bounds
rectangle), and the legend names the route — e.g. 冀州
`atk 0 ← 并州, 青州, 幽州` / `atk 1 ← 洛阳, 兖州`. The dropdowns isolate a
single attack route or defense variant; pool rows ≥ `$10` render one row
higher (the `GetOrderedDestination` quirk).

The three ROM-backed views need `rom/prg/prg_01.bin`, `prg_06.bin`,
`prg_09.bin`, `prg_10.bin`, `prg_11.bin`, `prg_1c.bin`, `prg_1e.bin`,
`rom/chr/` and `tools/terrain_model.py`; outside the repo they show a note
instead. They decode the ROM and edit nothing — the town tables live inside
the disassembled code bank $1C and have no CSV editing surface.

Keyboard: `Ctrl+S` save, `Ctrl+B` write asm, `Ctrl+Z`/`Ctrl+Y` undo/redo,
`Ctrl+F` filter, `Esc` clear filter, `PageUp`/`PageDown` step provinces.

## The editing loop

The CSVs are the editing surface, exactly as for the officer and terrain
editors:

1. edit; the table and report update immediately;
2. `Save CSVs` writes `docs/province_data.csv` **and** `docs/officer_data.csv`
   (the roster status half);
3. `Write ASM` saves, then runs
   `tools/gen_data_bank_asm.py --bank all --from-csv --write` and
   `tools/verify_data_banks.py --allow-edits`, so the assembly is re-rendered by
   the repo's own generator and the byte gate reports every deliberate edit;
4. `Diff` lists the field and roster changes not yet in the CSVs.

Nothing here writes `rom/prg/*.bin`; the stock dumps stay the reference images
for byte-exactness. `python3 tools/check_province_pipeline.py` proves the whole
ROM → CSV → asm → GUI loop, including the name re-encode, the field ranges, the
roster invariant and (with a display) a real widget edit/undo pass.
