# Tactical Map Editor — Sangokushi 2 terrain data banks `$00/$03/$04/$05`

> The officer seed-data editor (banks `$10`/`$11`) has its own README:
> [`README_officer.md`](README_officer.md).

A standalone desktop editor for the tactical (war-layer) terrain maps of
*Sangokushi 2 - Haou no Tairiku* (Famicom, Namco-163 / mapper 19). It paints the
terrain maps of all **30 provinces** and writes the result back out as the data
files a disassembly project keeps in its tree.

```
editor/
├── tactical_map_editor.py the GUI (Python 3 + tkinter, no third-party deps)
├── terrain_model.py       optional local copy of the codec (see "Standalone mode")
└── README.md              this file
```

## What it edits

The game's tactical maps live in **four** pure data banks - `$00`, `$03`, `$04`
and `$05` (8 KB each, only ever mapped into `$8000-$9FFF` by `SwitchBank8`).
Together they hold **120 terrain quadrant crops** (30 provinces × 4) - 16×16
cells, one tile byte per cell - that assemble into each province's authored
**32 × 20** tactical map: 15 rows come from the upper crops (TL/TR) and 5 rows
from the lower crops (BL/BR). `@GetTileTerrain` (`$B6EF`) answers "what terrain
is under map coord (x,y)?" from these bytes (via `TileBankTable` + the province
zone table), and Battle Mode re-reads the same bytes as scene/overlay crops.

| provinces | bank |
|---|---|
| 0-7   | `$00` |
| 8-13  | `$03` |
| 14-15, 24-29 | `$05` |
| 16-23 | `$04` |

A province's four crops always live in one bank, so the editor loads all four
banks and switches province freely across them; the title bar shows which bank
the current province lives in.

| Terrain | tile bytes | glyph |
|---|---|---|
| 0 Forest 林 | `$00`, `$2C-$2D`, `$36-$38`, `$3A-$3F`, `$49-$4B`, `$5F-$60`, `$66`, `$7C-$7F` | `f` |
| 1 Sandland 砂地 | `$01`, `$6A-$6D`, `$70`, `$74` | `s` |
| 2 Plain 平地 | `$1C-$1F`, `$22`, `$25`, `$27`, `$2B`, `$2E-$35`, `$39`, `$48`, `$4C-$55`, … | `p` |
| 3 River 川 | `$02-$1B`, `$40-$47`, `$5E`, `$65`, `$67-$69`, `$77-$78` | `r` |
| 4 Mountain 山 | `$20-$21`, `$23-$24`, `$26`, `$28-$2A`, `$56`, `$59`, `$5B-$5D` | `m` |
| 5 Castle 城 | `$61` (`$62-$64` are defined but unused in every crop) | `c` |
| 6/7/8 settlement 村/民家 | `$79` / `$7A` / `$7B` | `h` `a` `b` (or `v`) — see "Settlement objects" |
| blocked → reads as Forest, no table lookup | `$80-$FF` (`$FF` = bank filler) | `@` |

You always edit a **tile byte**, never a terrain id: 128 tile ids collapse into 9
terrain classes, so the mapping is not reversible and the drawn graphic differs
per tile byte. The palette is grouped by the terrain a tile resolves to.

Evidence for all of the above: `code/bank_00_data_layout.md` and
`docs/manual_kb/` in the `sango2dasm` disassembly repo.

## Requirements

Python 3 with `tkinter` (stdlib; on Debian/Ubuntu `sudo apt install python3-tk`).
Nothing else. Developed against Python 3.14.

The **real tiles** render mode additionally reads `rom/prg/prg_1f.bin`
(`MetaTileData`) and `rom/chr/chr_11.bin` (display record 1); outside the repo it
disables itself and the classes view keeps working.

## Running

Inside the disassembly repo (default — full pipeline available):

```sh
python3 editor/tactical_map_editor.py                     # loads all four docs/terrain_bank_XX.csv
python3 editor/tactical_map_editor.py --csv terrain_bank_04.csv   # open one bank's CSV
python3 editor/tactical_map_editor.py --rom prg_03.bin    # open a raw 8 KB bank image
make map-editor                                           # same as the first line
```

On start the editor reads every terrain bank it can find (its CSV twin, else the
stock `rom/prg/prg_XX.bin`), so all 30 provinces are immediately selectable. A
bank with neither is shown as `$FF` filler until you `Open CSV` / `Open ROM bin`.

Outside the repo (standalone mode) — the editor only needs the codec and CSVs:

```sh
mkdir tactical-map-editor && cd tactical-map-editor
cp /path/to/sango2dasm/tools/terrain_model.py .
cp /path/to/sango2dasm/docs/terrain_bank_00.csv .
python3 /path/to/sango2dasm/editor/tactical_map_editor.py --model . --csv terrain_bank_00.csv
```

`--model PATH` may point at a directory holding `terrain_model.py` or at the file
itself. Without the repo the *Write ASM* / *Verify* buttons explain that the
generator lives in the repo; you still get the full editing surface, `Save CSV`
and `Export bin` (an 8 KB image you can patch into any ROM).

## The screen

```
View (o) Province 32x20  ( ) Crop 16x16  ( ) Raw CSV rows   Province [◀][ 3  青州 (セイシュウ) ▼][▶]  title
[Open CSV][Open ROM bin][Save all CSVs][Export bin][Write ASM][Verify][Revert to source][Undo] [x]glyphs [x]objects
+--------------------------------------------+  +--------------------------------+
|   terrain grid (click / drag to paint)     |  | Render (o)classes (o)real tiles|
|   scrollbars: wheel pans, Ctrl+wheel       |  | Zoom  [-][+][ 20 px 100%][Fit] |
|   zooms; ruler shows cell coordinates      |  | Brush [$39] [Set] $39->Plain   |
|   dashed lines at x=16 / y=15 in province  |  | Palette (tile picker)          |
|   view, white ring on the Castle cell      |  | Cell info / census / Output    |
+--------------------------------------------+  +--------------------------------+
status bar: hovered cell / tile / terrain / brush
```

The dropdown label follows the view (`Province` / `Crop zone` / `Terrain bank`) —
see "Switching province (or crop)" below.

* **Province view** — the authored 32 × 20 tactical map of any of provinces 0-29.
  This is the level-designer view: one pixel-per-cell edit maps to exactly one map
  cell. The dashed lines show where the four crops are spliced (x = 16, y = 15),
  the white ring marks the province Castle, and settlement cells carry a letter
  rather than terrain art (see "Settlement objects").
* **Crop view** — one of the 120 raw 16 × 16 windows as the engine addresses them
  (zones 0-119). Ribbon gap rows are drawn grey. For an odd zone, rows 9-15 are
  the *next* crop's rows 0-6 (the ribbon overlap); painting there writes the
  owning bytes, so the alias is kept consistent automatically.
* **Bank CSV rows** — pick one of the four banks and see it exactly as its CSV
  states it: 512-ish owner rows of 16 bytes, so the Battle-Mode head, the
  inter-crop pads, bank `$03`'s leading sound command streams and the `$FF`
  tail are reachable too.
  Double-click the `t0..t15` column and paste 16 hex bytes (`$44`, `44` and
  `0x44` all parse).

Keys: `0`-`9` jump to provinces 0-9 (the rest via the dropdown or stepping),
`PageDown`/`PageUp` step through the current list, `Ctrl+S` save CSVs,
`Ctrl+B` write ASM, `Ctrl+Z`/`Ctrl+Y` undo/redo.

## Zoom and panning

The grid scales from **6 to 96 px per cell**; `20 px` is shown as 100 %, and the
readout next to the `−` / `+` buttons reports both.

| Action | Effect |
|---|---|
| `Ctrl` + wheel | zoom one step (×1.25) about the pointer, which stays on its cell |
| wheel / `Shift` + wheel | pan vertically / horizontally |
| `+` / `-` | zoom one step about the centre of the pane |
| `Ctrl+0` | back to 100 % (20 px) |
| `f` or `Fit` | largest scale where the whole view is visible, scrolled to the origin |
| `−` `+` buttons, readout | same stepping with the mouse |

Below 10 px per cell the terrain glyphs are dropped, and below 16 px the ruler
numbers print every 2nd (every 4th below 8 px) column, so a zoomed-out province
still reads as a map instead of noise. Zooming past the pane is fine: both
scrollbars and the wheel follow the grid. Painting is unaffected by the scale —
a click resolves through the current cell size to the same bank byte it addressed
at 100 %, which is what `tools/check_terrain_pipeline.py` now asserts for every
level from 6 to 96 px.

Zoom is a view-only setting: it changes no bytes, and the `raw` CSV-row table
ignores it.

## Rendering modes

`Render` switches what each cell is painted with. Both modes read and write the
same tile bytes; only the picture changes.

| Mode | Shows | For |
|---|---|---|
| **classes** | one flat colour per terrain class + a letter glyph | seeing the 128→9 terrain decode, spotting gap rows and blocked `$80-$FF` bytes |
| **real tiles** | the graphics the console draws: `MetaTileData[$F477 + byte*4]` → 4 nametable bytes (TL,TR,BL,BR) → 2×2 CHR patterns from display record 1 (`88 89 8A 88`) → the crop's attribute head under palette record `$01` | judging what an edit actually looks like in-game; at 16 px/cell the map is pixel-exact to the console |

The chain is documented and asserted by `tools/terrain_tiles.py` (which is also a
standalone PNG renderer: `python3 tools/terrain_tiles.py --province all --scale 1`
writes `build/terrain_tiles_pNN.png`). `tools/check_terrain_pipeline.py` section 9
proves the table is read from `$F477`, that all 128 tile bytes decode to a 16×16
RGB cell, and that the mode degrades to disabled when `rom/` is not present — so a
standalone CSV-only copy of the editor still runs.

Colour is not a guess. Each crop is preceded by a 64-byte **NES attribute head**
(`BattleOverlayPtrTable == TerrainMapPtrTable - $40`), and the game's own indexing
(`prg_0c_0d_tactical_commands.asm:7543`) is reused verbatim: byte `((x & $0E) >> 1) | ((y & $0E) << 2)`
over the 16×16 crop, 2-bit field `((y & 1) * 2 + (x & 1))`. Read that way the head
is exactly the authored terrain palette — across all 30 provinces it selects
**sub-palette 1 for River and sub-palette 0 for every other class, with zero
exceptions** over 19,200 cells, which `tools/check_terrain_pipeline.py` section 9
asserts. Palette **record $01** is what makes those two read as the manual's
tactical screenshot (gold plains, dark green pines, solid blue water); record $00
swaps land and water, which is why the first cut of this mode looked wrong.

The one thing tile mode does not claim is **blocked bytes**: `$80-$FF` have no
`MetaTileData` entry at all — the engine never looks one up — so they stay
magenta. In practice `$FF` is the only one present in the four banks, and only as
bank filler.

## Settlement objects (castle / village / house)

**These are not in the terrain map.** `$61` (Castle 城) and `$79`/`$7A`/`$7B`
(settlement 村/民家) are *gameplay ids* stamped onto map cells: their
`MetaTileData` entry is byte-for-byte the plain-ground metatile, so there is no
building art behind them. What you see in the game is a **16x16 OAM sprite**
drawn over the cell by `DrawStratagemTargetMarkers` (`prg_08_09_tactical_war.asm:$D24D`):

| Object | Map byte | Sprite | Source of its position |
|---|---|---|---|
| Castle / province city | `$61` | `@ProvinceMarkerOam` (`$D315`, tiles $02 $03 $0E $0F) | the map cell itself |
| 民家 House, 武器屋 Armory, 病院 Hospital | `$79` / `$7A` / `$7B` | `@CityMarkerOam` (`$D326`, tiles $3C $3D $3E $3F) | map cell, cross-checked against `ProvinceTacticalFacilityTiles` |

The two render modes spell these out differently, on purpose:

* **classes** draws a **character**, never game art: `c` for the castle, and for
  a settlement cell the letter of its facility slot — `h` 民家 House, `a` 武器屋
  Armory, `b` 病院 Hospital, or `v` when the table has no pair for that cell. The
  white Castle ring stays.
* **real tiles** draws the **sprites**, when the `objects` checkbox is ticked
  (transparent where the sprite leaves holes, so the map shows through).

The census names the letters it used (`settlement objects (not art in the map):
1 b=Hospital, 1 c=castle`), and hovering such a cell reports the object kind plus
its table slot.

`ProvinceTacticalFacilityTiles` (bank `$31` `$9BA4`, 30 rows x 6 B = three
`(X,Y)` tile pairs, X bit7 = unused, `Y >= $10` normalised by `Y -= 1` for the
map's gap row) is the authored *identity* of each facility. It agrees with the
map bytes on **55 of 67** pairs; the other 12 sit on ordinary terrain, and a
province's `$61` castle is never in the table at all — so the map byte is what
decides *where* a marker is drawn, and the table only labels it.
`tools/check_terrain_pipeline.py` section 9 asserts the ground-not-building
property, that `$62-$64` stay unused, that both sprites decode with
transparency, and that the pairs stay in bounds.

Note `ProvincePixelPositionTable` (bank `$31` `$9D58`, 30 x 4 B) is **not** a
tactical position: its values run to (224, 384), outside the 512x320 px
battlefield, i.e. it is strategy-layer map space. It is deliberately not used
for the overlay.

## How the data is linked

```
rom/prg/prg_XX.bin  (stock reference, never written)  X = 00, 03, 04, 05
        |  read
        v
tools/terrain_model.py  --  the codec: geometry, tile->terrain, CSV, asm renderer
        |                                          ^
        v                                          |
docs/terrain_bank_XX.csv  <-- edit here -->  this editor (Save all CSVs)
        |  --from-csv
        v
asm/banks/data_XX.asm  (annotated .byte hex, one line per 16 map cells)
        |  ca65 + ld65 (per-bank harness)
        v
tools/verify_terrain_banks.py  --  byte-exact gate + decoded edit report
```

Each bank's CSV stores **every byte of that bank exactly once** (one row per 16
physical bytes, tagged `kind = crop/pad/overlay_head/sound_stream/sound_tail/filler`
plus zone/province/quadrant/crop_row), so the round trip ROM → CSV → asm →
assemble →
ROM is the identity for all four banks. The ribbon's overlapping crop windows are
resolved through that owner table, which is why editing an aliased row never
produces a contradictory pair of bytes.

Repo commands doing the same thing as the buttons:

```sh
make terrain         # re-render asm + CSV from the stock ROM (strict verify)
make terrain-csv     # re-render asm from the edited CSV, gate on asm == CSV
make terrain-diff    # list the terrain edits still live vs the stock ROM
make verifyterrain   # assemble the terrain banks standalone, prove byte-exactness
make checkterrain    # prove the whole loop is lossless (incl. these views)
make map-editor      # open this editor
```

## Switching province (or crop)

The selector in the toolbar is labelled by the active view — `Province`,
`Crop zone` or `Terrain bank` — and lists the maps by name, so switching is one of:

| Action | Effect |
|---|---|
| dropdown `Province` | pick `17  建安 (ケンアン)` directly from all 30; names come from `docs/province_names.csv` |
| `◀` / `▶` buttons | step to the previous / next province (wraps around 29 → 0) |
| `PageDown` / `PageUp` | same stepping from the keyboard |
| keys `0` - `9` | jump straight to provinces 0-9 (ignored while the brush entry, dropdown or a text panel has focus) |

Switching province also switches the underlying bank: picking a province in
bank `$04` loads those bytes transparently. In the crop view the same dropdown
lists all 120 zones as `z32  prov  8 TL (bank $03)` (odd zones note the row
alias), and in the bank view the four banks as `bank $04  provinces 16-23`.

## Editing recipe

1. Open the editor, pick any of the 30 provinces, paint.
2. `Save all CSVs` (writes each bank's `docs/terrain_bank_XX.csv`).
3. `Write ASM` — runs `tools/gen_terrain_asm.py --bank all --from-csv --write`
   and then `tools/verify_terrain_banks.py --bank all --against-csv --allow-edits`;
   the Output pane shows the decoded diff ("bank $04 province 20 TR crop row 2:
   col 5 `$5E` River → `$61` Castle") and any warning the terrain invariants raise.
4. `make all && make verify` in the repo to rebuild the ROM image.

Deliberate edits are reported, not hidden: the verifier lists which cell changed
and what it became, and flags structural damage (a province losing its Castle, a
ribbon gap row gaining authored terrain, a new blocked tile `$80-$FE`).

## Caveats

* `@GetTileTerrain` splits the map at `y >= 16` while the data splits at 15, so
  the engine reads the upper crops' blank gap row 15 as a Forest band and never
  sees the lower crops' 5th content row. The province view draws the **authored**
  geometry (what the map was painted as); the gap rows are visible in the crop
  view. Editing a gap row is allowed but reported.
* Column 31 is never queried (`@EvalStepCost` bounds X at `< $1F`), so the
  rightmost column of the TR/BR crops is decorative.
* Terrain ids 6/7/8 are indistinguishable to every consumer (clamped to Plain).
* The four terrain banks share one ribbon geometry; `TerrainMapPtrTable`/`TileBankTable`
  in bank `$08` decide which bank holds which of the 120 zones. The model
  (`tools/terrain_model.py`) is generalised over all four, so a province is never
  split across banks.
* The editor never writes `rom/prg/*.bin`; the stock dumps stay the reference
  images for byte-exactness.
