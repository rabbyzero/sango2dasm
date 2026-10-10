# Bank $00 data layout: tactical terrain maps (provinces 0-7)

Scope: what actually lives in `rom/prg/prg_00.bin` (= `asm/banks/data_00.asm`,
PRG bank `$00`, one of the banks reachable only through the `$8000-$9FFF`
window). It holds **32 of the game's 120 terrain quadrant crops** - 16x16 cells,
one byte per cell - that the tactical/war layer assembles into each province's
**32 x 20** tactical map to answer "what terrain is under map coord (x,y)?". The
same bytes double as Battle Mode's scene/overlay source (§7).
No code lives here (see [bank_switch_map.md](bank_switch_map.md) §5.2).

The 120 crops are exactly **30 provinces x 4 quadrants**, so bank `$00`
(zones 0-31) covers provinces 0-7. Zone ids run `TL, BL, TR, BR` inside a
province (§2), which is why "32 crops" must not be read as "32 provincial maps".

Everything below is machine-checked: the driver tables were read straight out of
`rom/prg/prg_08.bin` and `rom/prg/prg_18.bin` and cross-checked byte-for-byte
against the trailing hex comments of the disassembly, and the geometry claims
were verified against the data banks themselves. `tools/dump_bank_00_terrain.py`
regenerates the tables, the CSV and the PNG sheets, and offers `--verify-asm`,
`--check-provinces`, `--check-layout` and `--check-alias` as the four checks.

---

## 1. Access path

| Step | Code | What it does |
|---|---|---|
| 1 | `@GetTileTerrain` `$B6EF` | quadrant = `(x >= 16)` \| `(y >= 16) << 1` -> `Y` = 0-3 |
| 2 | `LDA ($A8),Y` `$B705` | zone id for that quadrant, from the 4-byte zone table at ZP `$00A8` (filled by `DataRecordLoader`, §2) |
| 3 | `LDA TerrainMapPtrTable,Y` `$B70A` (word index) | `($22)` = CPU address of the zone's 16x16 map |
| 4 | `LDA TileBankTable,Y` `$B718` / `TAY` / `JSR B1F_SwitchBank8_A` `$B71C` | select the data bank into `$8000` (slot A, shadow `$00DE`); `$E000` only, code banks untouched |
| 5 | `AND #$0F` / `ASL` x4 / `ORA` `$B72C-$B73A`, `LDA ($22),Y` `$B73E` | cell = `map[(y & 15) * 16 + (x & 15)]` |
| 6 | `CMP #$80` `$B741` -> `LDA ($24),Y` `$B748` | terrain = `0` for a tile >= `$80`, else `TileTerrainTable[tile]` |

Map bounds come from the caller `@EvalStepCost`: X is rejected at `>= $1F`
(`$A773`) and Y at `>= $14` (`$A785`), so the engine queries **X 0-30 x Y 0-19**.

### Authored geometry: 15 + 5 rows x 16 + 16 columns

The four crops describe a province map of **20 rows x 32 columns**: the two upper
crops carry **15** content rows each (map rows 0-14) and the two lower crops carry
**5** (map rows 15-19). The proof is the blank tile `$00`: it is never used as
authored terrain, and across all 120 crops it occurs in exactly two places - row
15 of the upper crops and rows 5-8 of the lower crops, i.e. the ribbon's
inter-crop gaps (`python tools/dump_bank_00_terrain.py --check-geometry`):

| Crop class | row profile, % of the row that is tile `$00` (rows 0 -> 15) |
|---|---|
| TL / TR (upper) | `0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 76` |
| BL / BR (lower) | `0 0 0 0 0 77 66 66 71 0 0 0 0 0 0 0` |

No column shows the same structure (every one of the 16 columns of a crop holds
real terrain), so the width is the full 16 + 16 = 32 - and column 31 is the one
the engine never queries, since `X < $1F` stops at 30.

**The lookup and the data disagree by one row.** `@GetTileTerrain` splits on
`y >= $10` and indexes with `y & 15`, so it reads 16 rows from the upper crops and
4 from the lower ones: map row 15 gets the upper crop's *gap* row (blank tile
`$00` -> terrain 0 Forest, a false forest band across the map) and the lower
crops' 5th content row is never read. The tool draws the authored geometry by
default and offers `--model engine` for the literal lookup.

## 2. Province -> 4 quadrant zones (`($A8)` provider)

`DataRecordLoader` (`$DF15`, prg_17_18.asm) is the routine that installs the
`($A8)` table step 2 reads:

```
  LDA param_050e            ; $DF15  battlefield province id
  ASL A / TAY               ; $DF18  word index into the pointer table
  LDA DataRecordPtrTable,Y  ; $DF1A  -> ($00) = PermutationTable + 4*province
  ... copy 4 bytes ($00),0-3 -> $00AA,$00AB,$00AC,$00AD
  LDA #$AA / STA $A8        ; $DF41  ($A8) = $00AA
  LDA #$00 / STA $A9
```

`DataRecordPtrTable` (`$DF4A`, 30 words) has one entry per province, and each
4-byte group in `PermutationTable` (`$DF86`, bank `$18`, CPU `$C000-$FFFF`) is:

| `($A8)` index = quadrant | zone id | area of the 32 x 20 province map |
|---|---|---|
| 0 - `x < 16, y < 15` (TL) | `4p + 0` | cols 0-15, rows 0-14 (crop rows 0-14) |
| 1 - `x >= 16, y < 15` (TR) | `4p + 2` | cols 16-31, rows 0-14 (crop rows 0-14) |
| 2 - `x < 16, y >= 15` (BL) | `4p + 1` | cols 0-15, rows 15-19 (crop rows 0-4) |
| 3 - `x >= 16, y >= 15` (BR) | `4p + 3` | cols 16-31, rows 15-19 (crop rows 0-4) |

So zone ids are packed per province in the order **TL, BL, TR, BR** - the two
left quadrants then the two right quadrants, i.e. column-major, which is also how
the authoring ribbon packs them (§4). The disassembly still carries the stub-era
label `PermutationTable`, a misnomer - it is the province -> quadrant zone table
(rename to `ProvinceTerrainZoneTable` pending: `asm/banks/prg_17_18.asm` does not
assemble standalone yet, so a rename cannot be byte-verified).

Evidence that this grouping is right (`python tools/dump_bank_00_terrain.py
--check-provinces`, all true):

* `DataRecordPtrTable[p] == $DF86 + 4*p` for all 30 provinces, and the 120 zone
  ids are a permutation of 0-119 - every quadrant map is used exactly once.
* Every assembled 32 x 20 map contains **exactly one Castle cell** (terrain 5),
  for all 30 provinces - 30 castles for 30 provinces. As a control, assigning the
  four crops to the wrong corners drops that to 16/30 provinces.
* The castle positions cluster centrally (x 5-24, y 5-16 of a 32 x 20 map) - a
  province stronghold, not a scatter.
* Terrain identity across the two interior seams is **0.739** with the authored
  15/5 row split, against 0.372 for the engine's 16/4 split (which splices a
  blank gap row into the middle of the map) - see `--check-provinces`.
  The vertical seam (`x = 15|16`) is likewise continuous; the crops were painted
  as one picture, then cut.

## 3. Driver tables (all resident in bank `$08`)

Verified: `asm == rom/prg/prg_08.bin` for all three (128 + 240 + 120 bytes) -
reproduce with `python tools/dump_bank_00_terrain.py --verify-asm`.

| Table | CPU | Size | Role |
|---|---|---|---|
| `TileTerrainTable` | `$B74B` | 128 B | tile byte `$00-$7F` -> terrain id (`$80-$FF` never looked up) |
| `TerrainMapPtrTable` | `$B7CB` | 120 words | zone id -> CPU address of its 16x16 map inside the selected bank |
| `TileBankTable` | `$B8BB` | 120 B | zone id -> `$8000` window register value (`& $1F` = physical bank) |

`TileBankTable` splits the 120 zones (provinces) over four data banks:

| Zones | Provinces | Register | Physical bank | Pointer range |
|---|---|---|---|---|
| 0-31 | 0-7 | `$20` | **`$00`** (this file) | `$8040..$9BB0` |
| 32-55 | 8-13 | `$23` | `$03` | `$89A6..$9E16` |
| 56-63 | 14-15 | `$25` | `$05` | `$9540..$9BB0` |
| 64-95 | 16-23 | `$24` | `$04` | `$8040..$9BB0` |
| 96-119 | 24-29 | `$25` | `$05` | `$8040..$94B0` |

Every run boundary is a multiple of 4, so no province straddles two banks. Banks
`$04`/`$05` reuse the *same* CPU pointers as bank `$00` for their zones, so all
four banks share one ribbon geometry (§4) and differ only in terrain content.
`tools/dump_bank_00_terrain.py --bank 3/4/5` decodes the others; `--bank all`
draws all 30 assembled province maps in one sheet.

## 4. Bank `$00` byte layout

Offsets below are inside `rom/prg/prg_00.bin`; CPU address = `offset + $8000`.

```
$0000-$003F  64 B head - no *terrain* zone points here; it is Battle Mode's
             overlay crop for index 0 (see §7). It is NOT terrain bytes: it is a
             packed NES **attribute map** (four 2-bit BG palette fields per byte)
             for the 16x16 crop that follows, which is why the values are all
             nibble-combinations of 0/1 ($44/$54/$55/$11/$40/$05) - see §5a
$0040-$1C3F  16 blocks of $1C0 B (448), block k at $0040 + $1C0*k
             |  crop of zone 2k     at block + $000   (256 B: 15 content rows
             |                                            + row 15 = gap row)
             |  padding             at block + $100   (48 B, 0-7 non-zero bytes)
             |  crop of zone 2k+1   at block + $130   (256 B: 5 content rows,
             |                                            rows 5-8 = gap rows,
             |                                            rows 9-15 = next crop)
             last 112 B (7 rows) of crop(2k+1) == first 112 B of crop(2k+2)
$1C00-$1FFF  $FF filler (1024 B) - overlaps zone 31's crop tail
```

Verified against the ROM by `python tools/dump_bank_00_terrain.py --check-layout`
(0 mismatches): all 32 pointers match the block formula, and all 15 shared bands
(`map(2k+1)+$90 .. +$FF` vs `map(2k+2)+$00 .. +$6F`) are byte-identical; the last
non-`$FF` byte of the bank is `$1BFF`. Consequence: the bank is one continuous
16-byte-wide terrain ribbon, laid out as alternating strips of 15 content rows
(upper crops) and 5 content rows (lower crops) separated by 4-row `$00` gaps, and
each zone is a 16-row window starting at its strip. That is why a window contains
gap rows and why consecutive windows overlap: crop(2k+1)'s rows 9-15 are
crop(2k+2)'s rows 0-6. Zone 31 (province 7, BR) is the last crop and runs into
the `$FF` filler after 80 real bytes - exactly its 5 content rows, so no
authored terrain is lost.

### Crop table (bank `$00`, zones 0-31)

`Forest/Plain/...` counts are terrain ids after the `TileTerrainTable` lookup,
over all 256 cells of the crop window - which includes the gap rows (§4). The
authored content is 240 cells for an upper crop (15 rows) and 80 for a lower one
(5 rows). `+blocked` counts tiles >= `$80` separately (they also yield terrain 0).

| Zone | Prov | Quad | CPU | Bank range | Terrain counts (of 256 cells) |
|---|---|---|---|---|---|
| 0 | 0 | TL | `$8040` | `$0040-$013F` | Forest=40 Plain=159 River=31 Mountain=26 |
| 1 | 0 | BL | `$8170` | `$0170-$026F` | Forest=65 Sandland=1 Plain=83 River=49 Mountain=57 Castle=1 |
| 2 | 0 | TR | `$8200` | `$0200-$02FF` | Forest=22 Plain=147 River=28 Mountain=57 Castle=1 Special6=1 |
| 3 | 0 | BR | `$8330` | `$0330-$042F` | Forest=85 Plain=58 River=69 Mountain=43 Special6=1 |
| 4 | 1 | TL | `$83C0` | `$03C0-$04BF` | Forest=46 Plain=134 River=2 Mountain=73 Special6=1 |
| 5 | 1 | BL | `$84F0` | `$04F0-$05EF` | Forest=86 Sandland=1 Plain=90 River=33 Mountain=46 |
| 6 | 1 | TR | `$8580` | `$0580-$067F` | Forest=32 Plain=161 River=5 Mountain=56 Castle=1 Special7=1 |
| 7 | 1 | BR | `$86B0` | `$06B0-$07AF` | Forest=62 Sandland=3 Plain=71 River=73 Mountain=47 |
| 8 | 2 | TL | `$8740` | `$0740-$083F` | Forest=41 Plain=110 River=35 Mountain=70 |
| 9 | 2 | BL | `$8870` | `$0870-$096F` | Forest=53 Sandland=2 Plain=125 River=27 Mountain=49 |
| 10 | 2 | TR | `$8900` | `$0900-$09FF` | Forest=27 Sandland=1 Plain=149 River=38 Mountain=37 Castle=1 Special6=1 Special7=1 Special8=1 |
| 11 | 2 | BR | `$8A30` | `$0A30-$0B2F` | Forest=67 Sandland=2 Plain=119 River=49 Mountain=19 |
| 12 | 3 | TL | `$8AC0` | `$0AC0-$0BBF` | Forest=41 Plain=130 River=65 Mountain=20 |
| 13 | 3 | BL | `$8BF0` | `$0BF0-$0CEF` | Forest=38 Sandland=1 Plain=92 River=102 Mountain=22 Special6=1 |
| 14 | 3 | TR | `$8C80` | `$0C80-$0D7F` | Forest=12 Plain=94 River=119 Mountain=30 Castle=1 |
| 15 | 3 | BR | `$8DB0` | `$0DB0-$0EAF` | Forest=66 Sandland=2 Plain=120 River=64 Mountain=3 Special6=1 |
| 16 | 4 | TL | `$8E40` | `$0E40-$0F3F` | Forest=35 Plain=161 River=40 Mountain=19 Special6=1 |
| 17 | 4 | BL | `$8F70` | `$0F70-$106F` | Forest=22 Sandland=2 Plain=129 River=91 Mountain=11 Special7=1 |
| 18 | 4 | TR | `$9000` | `$1000-$10FF` | Forest=13 Sandland=1 Plain=90 River=142 Mountain=8 Castle=1 Special7=1 |
| 19 | 4 | BR | `$9130` | `$1130-$122F` | Forest=69 Sandland=42 Plain=102 River=35 Mountain=7 Special8=1 |
| 20 | 5 | TL | `$91C0` | `$11C0-$12BF` | Forest=26 Sandland=45 Plain=165 River=8 Mountain=11 Special6=1 |
| 21 | 5 | BL | `$92F0` | `$12F0-$13EF` | Forest=66 Sandland=16 Plain=136 River=5 Mountain=33 |
| 22 | 5 | TR | `$9380` | `$1380-$147F` | Forest=46 Plain=151 River=21 Mountain=37 Castle=1 |
| 23 | 5 | BR | `$94B0` | `$14B0-$15AF` | Forest=93 Sandland=53 Plain=86 Mountain=22 Special6=1 Special7=1 |
| 24 | 6 | TL | `$9540` | `$1540-$163F` | Forest=16 Sandland=79 Plain=98 Mountain=61 Castle=1 Special6=1 |
| 25 | 6 | BL | `$9670` | `$1670-$176F` | Forest=81 Sandland=16 Plain=86 Mountain=71 Special7=1 Special8=1 |
| 26 | 6 | TR | `$9700` | `$1700-$17FF` | Forest=31 Sandland=28 Plain=121 Mountain=75 Special8=1 |
| 27 | 6 | BR | `$9830` | `$1830-$192F` | Forest=66 Sandland=26 Plain=121 River=2 Mountain=40 Special6=1 |
| 28 | 7 | TL | `$98C0` | `$18C0-$19BF` | Forest=29 Sandland=17 Plain=153 River=13 Mountain=41 Castle=1 Special6=1 Special7=1 |
| 29 | 7 | BL | `$99F0` | `$19F0-$1AEF` | Forest=56 Sandland=2 Plain=111 River=25 Mountain=62 |
| 30 | 7 | TR | `$9A80` | `$1A80-$1B7F` | Forest=35 Plain=127 River=30 Mountain=64 |
| 31 | 7 | BR | `$9BB0` | `$1BB0-$1CAF` | Forest=6 +blocked=176 Plain=43 River=8 Mountain=23 |

## 5. Tile byte format

One byte per map cell, row-major, 16 bytes per row:
`cell = map[(y & 15) * 16 + (x & 15)]`, `x` increasing to the right, `y` down.

* The byte is a **war-map terrain metatile id**, not a CHR pattern index: 128 ids
  (`$00-$7F`) are collapsed into 9 terrain classes by `TileTerrainTable`.
  Its graphics side of that contract is now resolved: the same byte indexes
  `MetaTileData` (`$F477`, bank `$1F`, 512 B = 128 entries x 4) and the 4 bytes
  are the nametable pair-rows TL,TR,BL,BR of one **16x16 px** cell.
  `CalcTileAddrHoriz` (`prg_17_18.asm:1125`) computes `base + byte*4`
  (`ASL/ROL/ASL/ROL/ADC $0002($77)/ADC $0003($F4)`) and `CopyTileRowHoriz`
  (`:1139`) writes 2 of the 4 per PPU row, picking the pair from a row bit. The
  resulting nametable bytes are drawn with display record 1's CHR pages
  (`88 89 8A 88`) and coloured per cell from the crop's attribute head under
  palette record `$01` (§5a) - the same CHR set `TacticalTerrainScreen` (§7) is
  render-verified with. Writing the raw byte to the nametable instead is *wrong*:
  `$00-$3F` of that record is a text page. See `tools/terrain_tiles.py`.
* `$80-$FF` short-circuit to terrain `0` *without* a table lookup (`$B741`). In
  bank `$00` the only such byte is `$FF`, and only inside zone 31's tail, so
  `$FF` is filler/padding rather than authored ground.
* Bank `$00` uses 102 distinct tile bytes across its 32 maps; the most common are
  `$39` (2707 uses, Plain), `$00` (930, the blank tile - classified Forest),
  `$5E` (477, River), `$2A` (257), `$24` (199), `$29` (145) - all Mountain.
* Mountain/Plain blend tiles alternate in `$20-$2B` (`$20,$21,$23,$24,$26,
  $28,$29,$2A` -> Mountain, `$22,$25,$27,$2B` -> Plain), i.e. the id order groups
  by drawn graphic, not by class.

`TileTerrainTable` (`$B74B`) in full, grouped by resulting terrain id:

| Terrain | Tile ids | n |
|---|---|---|
| 0 Forest | `$00`, `$2C-$2D`, `$36-$38`, `$3A-$3F`, `$49-$4B`, `$5F-$60`, `$66`, `$7C-$7F` (+ all `$80-$FF`) | 22 |
| 1 Sandland | `$01`, `$6A-$6D`, `$70`, `$74` | 7 |
| 2 Plain | `$1C-$1F`, `$22`, `$25`, `$27`, `$2B`, `$2E-$35`, `$39`, `$48`, `$4C-$55`, `$57-$58`, `$5A`, `$6E-$6F`, `$71-$73`, `$75-$76` | 38 |
| 3 River | `$02-$1B`, `$40-$47`, `$5E`, `$65`, `$67-$69`, `$77-$78` | 41 |
| 4 Mountain | `$20-$21`, `$23-$24`, `$26`, `$28-$2A`, `$56`, `$59`, `$5B-$5D` | 13 |
| 5 Castle | `$61-$64` | 4 |
| 6 / 7 / 8 | `$79` / `$7A` / `$7B` | 1 each |

## 5a. What the tile byte looks like: `MetaTileData` and the attribute head

The graphics half of the tile byte contract resolves in two steps, and neither
one is the raw byte:

1. **Shapes.** The byte indexes `MetaTileData` (`$F477`, bank `$1F`, 512 B = 128
   entries x 4). The 4 bytes are the nametable pair-rows TL,TR,BL,BR of one
   **16x16 px** cell: `CalcTileAddrHoriz` (`prg_17_18.asm:1125`) computes
   `base + byte*4` (`ASL/ROL/ASL/ROL/ADC $0002($77)/ADC $0003($F4)`) and
   `CopyTileRowHoriz` (`:1139`) writes 2 of the 4 per PPU row, choosing the pair
   from a row bit. Patterns come from display record 1 (`88 89 8A 88`, i.e.
   `chr_11.bin` slots 0-2) - the same record `TacticalTerrainScreen` (§7) is
   render-verified with. Writing the *raw* byte to the nametable instead is
   wrong: record 1's `$00-$3F` page is a font, so it draws digits and 山/水.
2. **Colour.** The 64-byte head in front of every crop is the NES attribute map
   for its 16x16 cells. The game's indexing (`prg_0c_0d.asm:7543`,
   `AND #$0E / LSR / AND #$0E / ASL / ASL / ORA`) is byte
   `((x & $0E) >> 1) | ((y & $0E) << 2)` with the 2-bit field
   `((y & 1) * 2 + (x & 1))` inside it. Read that way the head is exactly the
   authored terrain palette: over all 30 provinces x 640 cells (19,200 samples)
   it selects **sub-palette 1 for every River cell and sub-palette 0 for every
   other class, with no exceptions** - which is also why the head's bytes only
   ever combine the nibbles 0 and 1. With palette record **$01** that yields the
   manual's tactical screenshot (gold plains, dark green pines, solid blue
   water); record `$00` swaps land and water.

`tools/terrain_tiles.py` implements both steps, and
`tools/check_terrain_pipeline.py` section 9 asserts the table offset, the
128-cells-decode property and the River/land sub-palette invariant.

### Settlement ids are not art

`$61` (terrain 5 Castle) and `$79`/`$7A`/`$7B` (terrain 6/7/8) carry the *same*
metatile as plain ground `$39` (`22 23 32 33`), so no building is drawn from the
map: they are gameplay ids stamped on a cell. The visible object is a 16x16 OAM
sprite that `DrawStratagemTargetMarkers` (`prg_08_09.asm:$D24D`) puts at
`(X*16, Y*16)` from `@ProvinceMarkerOam` (`$D315`, tiles $02/$03/$0E/$0F) for the
province city and `@CityMarkerOam` (`$D326`, tiles $3C/$3D/$3E/$3F) for each used
pair of `ProvinceTacticalFacilityTiles`. `$62`/`$63`/`$64` (the other bytes the
table also maps to Castle) occur **zero** times across all 120 crops, and their
metatiles point into the font page - unreachable, which is why they were never
caught as broken. The facility table (bank `$31` `$9BA4`, 30 x 6 B) names which
facility a cell is; it agrees with the settlement bytes on 55 of its 67 used
pairs, and never with the `$61` castle.

## 6. Terrain id semantics

Ids are what `GetTileTerrainClamped` (`$B6E5`) returns; it clamps `>= 6` to `2`
(`$B6E8-$B6EC`), so ids 6/7/8 are indistinguishable to every consumer.

| Id | Name | Evidence |
|---|---|---|
| 0 | Forest (林) | `AiFeasible_TenfoldAmbush` `$ADCF` requires self terrain `0` (十面埋伏 = forest ambush); `AiFeasible_FireAttack` `$ACCE` accepts `0`/`2`; step-cost group 0 = 3/5/5 = manual 林 3(2) |
| 1 | Sandland (砂地) | step-cost group 1 = 4/4/4 full, 3 reduced = manual 砂地 4(3); the only remaining id with its own cost row |
| 2 | Plain (平地) | group 2 = 2/3/3 = manual 平地 2(1); `AiFeasible_FireAttack` accepts it |
| 3 | River (川) | `AiFeasible_BoatSabotage` `$ACE8` (乱水) and `AiFeasible_ChainLink`/`FloodAttack` `$AD92` require `3` |
| 4 | Mountain (山) | `AiFeasible_PitfallTrap` `$ACDB` accepts `0`/`4`; `AiFeasible_Rockfall` `$AD65` requires self `4` or `5` (落石 = 城/山) |
| 5 | Castle (城) | `AiFeasible_CastleRaid` `$AD00` requires target `5`; `AiFeasible_RepeatingCrossbow` `$ADFE` requires self `5`; cost 6/6/6 = manual 城 6(4) |
| 6/7/8 | unresolved | single tile ids `$79/$7A/$7B`, at most one instance per map, always clamped to Plain; probably the 村/民家-type buildings of the tactical map |

Step-cost cross-check (`@StepCostTable_Full` `$A7CD`, index `terrain*4 | move
type`, column 3 unused; move type = officer record `$0B` bits 1-2):

| Group (= terrain id) | 0 Forest | 1 Sandland | 2 Plain | 3 River | 4 Mountain | 5 Castle |
|---|---|---|---|---|---|---|
| move type 0 | 3 | 4 | 2 | 5 | 5 | 6 |
| move type 1 | 5 | 4 | 3 | 6 | 3 | 6 |
| move type 2 | 5 | 4 | 3 | 3 | 6 | 6 |
| manual 平軍 (p. 64) | 林 3 | 砂地 4 | 平地 2 | 川 5 | 山 5 | 城 6 |

`@StepCostTable_Reduced` (`$A7E9`) is the small-garrison column of the manual's
parentheses. It is selected at `$A7B3` when officer record byte `$08` (troop
count, low byte) is <= 2 - the intended test was a 16-bit compare against
`$0259`, but `$A7AA`/`$A7AF` load byte `$08` twice (missing `INY`), so the
threshold degenerates. The values still reproduce the manual's second number for
all six terrains, which is the stronger check:

| Group (= terrain id) | 0 Forest | 1 Sandland | 2 Plain | 3 River | 4 Mountain | 5 Castle |
|---|---|---|---|---|---|---|
| move type 0, reduced | 2 | 3 | 1 | 3 | 3 | 4 |
| manual 平軍 (<= 500) | 林 2 | 砂地 3 | 平地 1 | 川 3 | 山 3 | 城 4 |

Move type 0 reproduces the manual's 平軍 row exactly in both tables, which is
what pins ids 0-5. Types 1/2 swap the River/Mountain costs, matching 水軍
(cheap on 川: 3 vs 6) and 山軍 (cheap on 山: 3 vs 6).

## 7. Second consumer: Battle Mode (banks `$17+$18`)

The very same bytes are re-read by the Battle Mode scene loader. `BattleResolve`
(`$A61F`) and `LoadOverlayPrimary`/`LoadOverlaySecondary` (`$AEF0`/`$AF0C`,
prg_17_18.asm) look up two more pointer tables and select the bank with
`B1F_SwitchBank8_B` (`$A63E`/`$AF08`). Comparing the ROM tables
(`python tools/dump_bank_00_terrain.py --check-alias`):

| Bank `$17` table | CPU | Relation to the bank `$08` tables |
|---|---|---|
| `BattleTilePtrTable` | `$A642` | identical to `TerrainMapPtrTable`, all 120 entries |
| `BattleOverlayPtrTable` | `$A732` | `== TerrainMapPtrTable - $40`, all 120 entries |
| `BattleBankTable` | `$A822` | identical to `TileBankTable`, all 120 entries |

So a Battle Mode scene *is* a terrain zone crop: the scene tile stream starts at
the zone's 16x16 grid, and the overlay stream starts 64 bytes earlier (the
`$0000-$003F` attribute head for index 0). `BattleResolve` sets `$0002 = $77` and
`$0003 = $F4`, which are **not** an RLE marker pair but the low/high bytes of the
`MetaTileData` base address `$F477` that `CalcTileAddrHoriz` adds `byte*4` to
(§5a) - the crop bytes are walked and expanded through that table, not copied to
the PPU verbatim. The full stream format is out of scope here.

## 8. Tool

```
python tools/dump_bank_00_terrain.py                    # bank $00 -> provinces 0-7
python tools/dump_bank_00_terrain.py --bank all         # all 30 province maps, one sheet
python tools/dump_bank_00_terrain.py --zones            # the 32 raw crops, gap rows grey
python tools/dump_bank_00_terrain.py --provinces 0,7 --ascii
python tools/dump_bank_00_terrain.py --model engine     # what @GetTileTerrain reads
python tools/dump_bank_00_terrain.py --width 31         # engine bound X < $1F
python tools/dump_bank_00_terrain.py --view raw         # tile byte as brightness
python tools/dump_bank_00_terrain.py --verify-asm       # tables: asm == prg_08.bin
python tools/dump_bank_00_terrain.py --check-geometry   # 15 + 5 content rows, §1
python tools/dump_bank_00_terrain.py --check-provinces  # province/quadrant model, §2
python tools/dump_bank_00_terrain.py --check-layout     # ribbon model, §4
python tools/dump_bank_00_terrain.py --check-alias      # Battle Mode alias, §7
python tools/dump_bank_00_terrain.py --bank 3 --no-png  # provinces 8-13 from bank $03
```

| File | Content |
|---|---|
| `output/bank_00_terrain_provinces.png` | 8 assembled province maps, 32 x 20 cells each; colour = terrain id, legend digits = terrain id, label = province id, magenta = tile >= `$80` |
| `output/bank_00_terrain_provinces.csv` | one row per cell: `province,y,x,zone,quadrant,cpu,tile,terrain,terrain_name` |
| `output/bank_all_terrain_provinces.png` | the same for all 30 provinces (crosses banks `$00/$03/$04/$05`) |
| `output/bank_00_terrain_zones.png` | the 32 raw crop windows, labelled by zone id; **grey rows are the ribbon's `$00` gaps**, so the 15-row / 5-row content split is visible directly |
| `output/bank_00_terrain_zones.csv` | `zone,province,quadrant,y,x,cpu,tile,terrain,terrain_name` |
| stdout | the §2/§4 tables; `--ascii` adds the char grids (gap rows print as blanks) |

`--check-layout` reports 0 mismatches for banks `$00`, `$03`, `$04` and `$05`, so
the ribbon model holds in all four terrain banks.

### 8.1 Editing surface: hex in the tree, CSV as the edit target, GUI on top

The four terrain banks are no longer blind `.incbin`: `asm/banks/data_00.asm`,
`data_03.asm`, `data_04.asm` and `data_05.asm` each render their whole 8 KB as
labelled `.byte` rows - one line per 16 map cells - with the decoded terrain as
an ASCII preview in every row comment:

```
; --- $8040-$813F  zone 000 - province 0 TL 16x16 crop window, rows 0-15 owned here ---
TerrainCrop_Z000_P00_TL:
  .byte $2C, $2C, ... ; $8040  z000 P00 TL  r00  fffffppppprpmmmm
```

Three tools plus one app share a single codec, `tools/terrain_model.py`, which is
generalised over all four banks and all 120 zones (30 provinces):

| Tool | Role |
|---|---|
| `tools/terrain_model.py` | geometry, the three driver tables, tile -> terrain decode, the owner region walk per bank, CSV reader/writer and the asm renderer (the only place the layout constants live) |
| `tools/gen_terrain_asm.py` | renders `asm/banks/data_XX.asm`; `--bank all` covers all four, `--make-csv`/`--with-csv` write the CSV twins, `--from-csv` takes a CSV as the source of truth |
| `tools/verify_terrain_banks.py` | per-bank harness: assembles each bank at `$8000`, proves byte-exactness, reports drift by bank/province/quadrant/row/col, checks the terrain invariants over all 30 provinces |
| `tools/check_terrain_pipeline.py` | end-to-end losslessness proof for ROM <-> CSV <-> asm <-> editor views, across every bank (no display needed) |
| `tools/terrain_tiles.py` | the graphics chain above: `MetaTileData` + display record 1 + attribute head + palette record `$01` -> a 16x16 RGB cell per tile byte, as a PNG sheet or for the editor's real-tile mode |
| `editor/tactical_map_editor.py` | standalone tkinter editor that paints any of the 30 province maps and drives the two tools above (see `editor/README.md`) |

Ownership is what makes each bank's CSV lossless: every byte has exactly one
owner row, so the ribbon overlap (§4 - an odd crop's rows 9-15 *are* the next
crop's rows 0-6) is stored once and aliased on read instead of being duplicated:

```
docs/terrain_bank_00.csv  ~512 rows x 16 tile bytes = 8192 bytes   (one per bank)
  offset,kind,zone,province,quadrant,crop_row,t0..t15
  kind = crop | pad (48 B, §9) | overlay_head (the 64 B attribute head in front of
              the bank's first crop: $0000-$003F, or $0966-$09A5 in bank $03)
            | sound_stream / sound_tail (bank $03's $0000-$0965, §10)
            | filler ($FF tail) | unanalysed (no byte of a shipped bank is one)
```

Make targets: `make terrain` (re-render asm + CSV for all four banks from the
stock ROM, strict verify), `make terrain-csv` (re-render asm from the edited CSVs
and gate on `asm == CSV`, so an intended edit is accepted there), `make
terrain-diff` (list the edits still live against the stock ROM), `make
verifyterrain` (strict byte-exactness against the stock ROM), `make checkterrain`,
`make map-editor`.

Round-trip evidence (reproduce with `make checkterrain`): for each bank ROM ->
CSV -> bank is the identity over all 8192 bytes, the generated `.byte` lines
decode back to the identical image, `ca65`+`ld65` reproduce every
`rom/prg/prg_XX.bin` byte-for-byte, all 30 provinces keep exactly one Castle, and
a deliberate single-cell edit in a **non-$00** bank (`$39` Plain -> `$61` Castle
in province 20, bank `$04`) is reported as "bank $04 province 20 TL crop row 0:
col 0 `$39` Plain -> `$61` Castle" while the Castle-count invariant notices the
second stronghold.

### 8.2 The authored maps as ASCII (the `--ascii` grids, hand-checkable)

ASCII legend: `f` Forest, `s` Sandland, `p` Plain, `r` River, `m` Mountain,
`c` Castle, `6/7/8` unresolved, `@` blocked (`$FF`). Province 0 (zones 0/1/2/3)
and province 7 (zones 28/29/30/31), 32 x 20 each:

```
ffffffppppprpmmmmmmmmmmmmmppffff    pppssssssspppmmmmmmmmmmmpppfffpm
ffffffppppprpmmmmmmmmmmmmppppfff    pppppsssspppppmmmmmmmmmppppffpmm
ffffppppppprppmmmmmmmmmmpppppfpp    ppppppssspppppmmmmmmmmmpppffppmp
fffppppppprrpppmmmmmmmmppppppppp    ppppppsspppppppmmmmmmmpppppppppp
fppppppmpprfpppmmmmmmmmppppppppm    mpppmpsppp6pfpppmmmmmmpppmppprrr
fppppppmpprfppppmmmmmmppcpppppmm    mpppppppppppfpppmmmmmppppmprrrpp
ppppppmmprrfppppmmpmmmpppppppppm    mpppppppfpppppppppmmmppppprrpppp
ppppppppprfppppppppmpppppppppppp    mmppppmpffpppppppppppppprrrfppmp
ppppppppprfppppppppppppppppppppp    mmmppcmppppfffffffpppprrrpffppmm
ppppmpppprfppppppppppppppppppppp    mmmmppmppppfrrrrrrppprrpppfpppmm
ppppmpppprpppfpppppppppppppppppp    mmmmppppppprrpppprrrrrpppffppppp
pppmmmppprrpfffrrpp6pfffpppppppf    mmmpppppppprppfpppprppppffppmppp
pppmmppppprpffrrrppprrrfffppppff    mmpppp7ppmrrppfpppprffpmppppmppp
pppmmpppmprpprrrrrrrrrrrrrppppff    mmpppppppmrpppffpmprrfpmmpppmmmp
pppppppmmrrrrrrrrrrrrrrrrrrpppff    mppppmppmmrppppfpmpprffpppppppmp
pppppppmprrrrrrrrrrrrrrrrrrrrppp    pppppmppmmrppppppmpprrffpppppfpp
pppppppprrrrrrrrrrrrrrrrrrrrrppp    pppmppppmrrpppppppppprrrmpppffpp
ppppppprrrrrrrrrrrrrrrrrrrrrrrpp    pppmmmppprppppmpmpppppprmpppfpmm
ffppppprrrrrrrrrrrrrrrrrrrrrrrrp    pppppppprrppppmmmmmpppprmmppppmm
fffppprrrrrrrrrrrrrrrrrrrrrrrrpp    pppppppprppppmmmmmmmmpprmmmpppmm
```

Both decode into geographically coherent 32 x 20 maps - forest edge -> plain -> a
river crossing the whole width and continuing unbroken through the y=14|15 crop
seam -> a mountain ridge, exactly one castle per map - which is the visual
confirmation of the 15 + 5 model.

## 9. Caveats

* Terrain ids 6/7/8 (tile bytes `$79`/`$7A`/`$7B`) stay unresolved: they occur at
  most once per map and every consumer sees them clamped to Plain, so no code
  distinguishes them. The manual's 村/民家 (Village/House) entries are the
  plausible candidates; the third id has no obvious referent.
* The 48-byte pads between a pair's crops are not addressed by any zone; they hold
  0-7 stray bytes (mostly `$05`, a River tile), consistent with crops taken from a
  wider authored ribbon rather than hand-placed maps.
* `@GetTileTerrain` reads one row too many from the upper crops (§1): terrain for
  `y = 15` comes from a `$00` gap row, so the AI/step-cost layer sees a Forest
  band there and never sees the lower crops' 5th content row. Anything that must
  match what the *map looks like* should use the authored 15 + 5 split.
* `TileBankTable` values `$23/$24/$25` mean banks `$03/$04/$05`; the same ribbon
  geometry applies there (`--check-layout --bank 3/4/5`), so this document's §4
  model transfers and only the terrain content differs.
* Bank `$00` has no code and no trampoline target - the only way in is a
  `SwitchBank8` read of these grids (see [bank_switch_map.md](bank_switch_map.md) §3).

## 10. Bank `$03`'s leading `$8000-$8965`: sound command streams (§4's exception)

Bank `$03` is dual-purpose, and that is the whole reason its ribbon starts at
`$89A6` instead of `$8040` (§3/§4). Its first 2406 bytes are **Namco-163/APU
sound command streams** - the packed tail of the stream area that begins in bank
`$02` at `$82DC` - and they are reached through a *different* mapper window:

| Window | Register | Set by | Holds while sound plays |
|---|---|---|---|
| `$8000-$9FFF` | `$E000` | `LDY #$22 / JSR B1F_SwitchBank8_B` (`$D8D4`/`$D8D6`) | bank `$02` - descriptors + most streams |
| `$A000-$BFFF` | `$E800` | `LDA #$23 / STA $00E2 / ORA #$C0 / STA $E800` (`$D8D9-$D8E0`) | **bank `$03`** - these bytes |

`@BattleAnimSoundEngine` (`asm/banks/prg_0e_0f.asm:8945-8950`) sets both, and
`@NmiHandler` re-applies the `$A000` shadow `$00E2` to `$E800` on every vblank
(`asm/banks/prg_1f.asm:3690-3692`), so the driver reads the two windows as one
contiguous address space: `$9FFF` is followed by `$A000`. The stream address in a
`SoundNoteHeaderTable` descriptor is therefore a *real* CPU address
(`$0702 = b2`, `$0703 = b3 + $40` - `asm/banks/prg_1f.asm:1136-1141`), and the 19
descriptors whose high byte is `$60-$68` land here. Nothing points at
`$8966` or beyond, which is exactly where the terrain model takes over.

Format, from `@InitChannel` (`$D958`) and `@CmdProcess`/`@CmdLoop`
(`$D99B-$DA15`, `$DB21-$DBF0`); `tools/sound_streams.py` is the standalone
decoder and `--validate` proves the whole `$82DC-$A965` area is claimed by 166
packed streams with 0 gaps:

* **4-byte stream header**: `[tick divisor][duty source][channel control][sweep]`.
  The control byte is what reaches `$4000/$4004/$4008/$400C` (volume bits 0-3,
  envelope mode bit 4, duty bits 6-7); `tick divisor & $0F` + 1 = frames per cell.
* **2-byte command cells** `[opcode][operand]` from offset 4. The driver keeps its
  position as a *cell index* and computes `stream + 2*state`
  (`ASL / ROL / ADC $0702,X` at `$D9A6-$D9B9`), so a jump operand **is a cell
  number**, and the `$FD` marker plus `$B0/$Bn` are what make a loop.
* Alphabet: `< $A0` pitch (low nibble = semitone over `NoteFreqTable` `$DD06`,
  bits 4-6 = period right-shifts, nibble `$C-$F` = rest, the noise channel takes
  the byte as a raw period, Namco rows sit 2 octaves higher) with the operand as
  sustain in ticks; `$A0` control, `$A1` sweep, `$A2` duty, `$A3`/`$A4` vibrato
  on/off, `$AF` tick divisor, `$B0 nn` goto cell `nn` (0 = the marker),
  `$Bn nn` repeat that target `n` more times, `$Cn nn` tremolo depth `n` period
  `nn`, `$Dn`/`$En nn` volume LFO `+/-%d` over `nn` ticks, `$FD` save loop marker
  (its operand byte is inert `$FE`), `$FF` end.
* **`$FF` consumes only its own byte**, so the next stream's first byte follows
  immediately: the area is packed, and a bank-`$03` row boundary can fall in the
  middle of a cell pair.

The 20 owned spans (`SoundStream_B03_Snd<n>` / `SoundStreamTail_B03_Snd<n>` in
`asm/banks/data_03.asm`, CSV kind `sound_stream` / `sound_tail`):

| soundID | descriptor | track | channel | bank `$03` span | cells |
|---|---|---|---|---|---|
| `$A3` | `$828C` | 1 | pulse2 | `$8000-$801E` | 15 |
| `$A4` | `$8290` | 2 | noise | `$801F-$803F` | 14 |
| `$A5` | `$8294` | 3 | namco1 | `$8040-$8064` | 16 |
| `$A6` | `$8298` | 0 | pulse1 | `$8065-$8095` | 22 |
| `$A7` | `$829C` | 1 | pulse2 | `$8096-$80C8` | 23 |
| `$A8` | `$82A0` | 2 | namco1 | `$80C9-$80F9` | 22 |
| `$A9` | `$82A4` | 3 | namco2 | `$80FA-$8122` | 18 |
| `$AA` | `$82A8` | 5 | pulse1 | `$8123-$81F9` | 105 |
| `$AB` | `$82AC` | 6 | pulse2 | `$81FA-$82D0` | 105 |
| `$AC` | `$82B0` | 7 | noise | `$82D1-$8319` | 34 |
| `$AD` | `$82B4` | 8 | namco1 | `$831A-$83D8` | 93 |
| `$AE` | `$82B8` | 9 | namco2 | `$83D9-$8481` | 82 |
| `$AF` | `$82BC` | 10 | namco3 | `$8482-$84DE` | 44 |
| `$B0` | `$82C0` | 4 | pulse1 | `$84DF-$85F7` | 138 |
| `$B1` | `$82C4` | 5 | pulse2 | `$85F8-$8714` | 140 |
| `$B2` | `$82C8` | 6 | noise | `$8715-$8771` | 44 |
| `$B3` | `$82CC` | 7 | namco1 | `$8772-$87E6` | 56 |
| `$B4` | `$82D0` | 8 | namco2 | `$87E7-$888F` | 82 |
| `$B5` | `$82D4` | 9 | namco3 | `$8890-$88F6` | 49 |
| `$B6` | `$82D8` | 10 | namco4 | `$88F7-$8965` | 53 |

`$A3` is the only stream that *starts* in bank `$02` (`$9FF8`) and spills in;
`$A4`/`$A5` are short (14/16 cells) and finish the track run `$A2-$A5` begun in
bank `$02`, while `$A6-$A9` (tracks 0-3), `$AA-$AF` (tracks 5-10) and `$B0-$B6`
(tracks 4-10) are three contiguous multi-voice blocks - i.e. whole songs whose
parts live here. Every pitch cell in the area has a low nibble `<= $B`, and the
melodies cluster on `$30/$32/$34/$37/$39` (a major-pentatonic row), which is the
data-side confirmation that the cell alignment is right.

Consequences for the terrain model: `$8966-$89A5` is the 64-byte attribute head
(§5a) of zone 32's crop, so bank `$03` carries an `overlay_head` region like the
other banks - just at `$0966` rather than `$0000`; the §4 block formula is
relative to the `$09A6` ribbon start, which is why `--check-layout --bank 3`
still reports 0 mismatches; and no terrain byte is entangled with the sound
bytes, so the sound decode cannot move a crop.
