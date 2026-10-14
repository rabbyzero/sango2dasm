# New-game seed data: officer and province tables in the PRG data banks

Scope: where the *initial* (new-game) officer and province data lives in the
256 KB PRG-ROM, how it reaches SRAM, and how each field decodes. Everything
below is machine-checked by `tools/verify_seed_tables.py` and re-generated into
`docs/officer_data.md` / `docs/province_data.md` by
`tools/extract_officer_data.py` / `tools/extract_province_data.py`.

## 1. Locations

The data lives in the two PRG banks that are only ever selected into the
$8000-$9FFF window (`SwitchBank8_A/B`); no code has been identified in either.
PRG is 32 x 8 KB, so mapper register value `$3n` selects physical bank `$0n`
= `rom/prg/prg_0n.bin`; PRG-file offset = `bank * $2000 + (CPU - $8000)`.

| Table | Bank reg | CPU | PRG offset | Bank file + offset | Stride | Count |
|---|---|---|---|---|---|---|---|
| Province katakana names | `$30` | `$9A1A` | `$21A1A` | `prg_10.bin + $1A1A` | 8, `$00`-term | 30 |
| Province master records | `$30` | `$8C00` | `$20C00` | `prg_10.bin + $0C00` | 32 | 30 |
| Province 町 rice-rate byte pairs | `$30` | `$8FC0` | `$20FC0` | `prg_10.bin + $0FC0` | 2 | 30 |
| Province facility flags | `$30` | `$8FFC` | `$20FFC` | `prg_10.bin + $0FFC` | 1 | 30 |
| Officer katakana names | `$30` | `$901A` | `$2101A` | `prg_10.bin + $101A` | 10, `$00`-term | 237 (+3 blank) |
| Officer master records | `$31` | `$8000` | `$22000` | `prg_11.bin + $0000` | 12 | 237 |
| Officer arrival schedule | `$31` | `$8B1C` | `$22B1C` | `prg_11.bin + $0B1C` | `$14` | 30 blocks |
| Officer death-year table | `$31` | `$9C58` | `$23C58` | `prg_11.bin + $1C58` | 1 | 237 |

Code that proves each base address:

| Routine | Address | What it computes |
|---|---|---|
| `GetProvinceRecordAddr` | `$F2AF` | `id * 32 + $6000` (SRAM) |
| `GetOfficerRecordAddr` | `$F2D7` | `id * 12 + $63C0` (SRAM) |
| `GetOfficerRomRecordAddr` | `$F387` | `LDY #$31`, `SwitchBank8_B`, `id * 12 + $8000` - the ROM seed is also read *directly* at runtime (the hospital compares live 体力 against the seed) |
| `GetNameDisplayScale` | `$F308` | `LDY #$30`, `id * 10 + $901A` (officer names) |
| `@RiceBuySeed` (prg_1b_1c_map_screen) | `$C254` | `LDY #$30`, `($02) = province * 2 + $8FC0`, buys rice: `gold = ceil(rice * 100 / rate)` at the `+0` byte |
| `State 0` of the war buy/sell panel (prg_08_09_tactical_war) | `$C129` | same pair dereferenced as the action parameter record (`($02),Y` with `Y=0/1` picking the leg) |
| `SellSurplusRice` (prg_0a_0b_strategy_ai) | `$CC9E` | `LDA $8FC0,Y` with `Y = province * 2 + 1` - the `+1` byte is the sell rate (rice/100 gold) |
| `@CheckEligibility` / `@AiAction_EvaluateAndExecute` / `SellSurplusRice` gate | `$C872` / `$C33F` / `$CC45` | `LDA $8FFC,Y` with `Y = province`, testing facility bit 3 / bit 0 / bit 2 |
| `@TownScreenInit` (prg_1b_1c_map_screen) | `$C014` | `LDY $0402`, `@TownFacilitySetTable[province]` -> facility set id (`$C025`), expanded by `@FacilityActionCodeTable` (`$C10E`) |
| `CmdDrawNameFromData` | `$A426` | `LDY #$30`, `id * 8 + $9A1A`, up to 6 glyphs (province names) |
| `OfficerArrivalScan` | `$B964` | `LDY #$31`, `$8B1C + province * $14` |

## 2. `SramInit` seeds SRAM from these two blocks

`SramInit` (`$DD8B`, `asm/banks/prg_1d_1e_menu_screens.asm`) clears `$6000-$6FFF`, then runs
two blind block copies. `tools/verify_seed_tables.py` re-parses them from the
disassembly rather than trusting this text:

| Loop | Bank | Source | Destination | Length test | Bytes | Records |
|---|---|---|---|---|---|---|
| `@Copy1Loop` `$DDED` | `$30` | `$8C00` | `$6000` | `CMP #$03` / `CPX #$C0` (`$DE0A`/`$DE0E`) | `$3C0` | 30 x 32 province |
| `@Copy2Loop` `$DE32` | `$31` | `$8000` | `$63C0` | `CMP #$0B` / `CPX #$40` (`$DE4F`/`$DE53`) | `$0B40` | 240 x 12 officer slots |

Resulting SRAM map (contiguous, which is what pins the record sizes):

```
$6000-$63BF  30 province records   (32 B each)
$63C0-$6EDB  237 officer records   (12 B each)   \ together $0B40 copied
$6EDC-$6EFF  3 padding officer slots ($ED-$EF)   /
$6F07-$6F3F  7 country records      (8 B each, see docs/country_data.md)
```

**Gotcha (officer slots 237-239).** The copy is `$0B40` = 240 slots, but only
237 officers exist: the officer table ends at `$8B1C`, exactly where the
arrival schedule begins, so the last `$24` bytes of the copy window stage the
schedule's head into `$6EDC-$6EFF`. Nothing ever reads those slots - every
officer scan loop bounds itself with `CMP #$ED` (237): `prg_19_1a_event_scenes.asm` `$A291`
("Officer ids $00-$EC") and `$BA22` ("all Officers scanned"), plus
`prg_0a_0b_strategy_ai.asm` `$C760` (`CPX #$ED` while stepping the `$0C`-byte records).
(The `CMP #$ED` at `prg_19_1a_event_scenes.asm` `$B4C5` is a different use: `CardFillDispatch`
rejects every roster card slot whose id is >= `$ED`, so `$ED` doubles as the
"not a real officer" / pending-transfer marker.) The officer count is
therefore 237, not 240.

## 3. Province master record (32 bytes)

Field offsets and their code evidence are listed in `docs/province_data.md`;
summary:

```
+00 lo nibble  Country id 0-6, 7 = 空白地 UnclaimedLand
+02/+03 Gold   +04/+05 Rice   +06/+07 Population (stored / 100)
+08/+09 LandValue   +0A DisasterPrevention   +0B Governance
+0C/+0D ReserveTroops   +0E/+0F Industry   +10 Treasure
+11..+1A Officer roster (10 slots, $FF = empty)
+1B RevoltCooldown     +1C..+1F unused (0 in the seed)
```

Ruler: the rostered officer whose 忠誠度 Loyalty is 100 (7 such officers, one
per Country). Name table index == province id == record index (`$00-$1D`).

## 4. Officer master record (12 bytes)

```
+00 体力 Vitality   +01 武力 Might   +02 知力 Intelligence
+03 忠誠度 Loyalty  +04 人徳 Virtue  +05 位置 LocationProvince (0 in the seed)
+06/+07 経験値 Experience (LE)       +08/+09 兵数 TroopCount (LE)
+0A bits 0-4 武器 Weapon, bits 5-7 防具 Armor
+0B bits 4-7 レベル OfficerLevel (0-based), bits 2-3 軍の属性 ArmyAffinity,
    bits 0-1 状態 OfficerStatus
```

### `+0B` holds two independent bit pairs

The low nibble of `+0B` only ever takes the six values `1, 2, 5, 6, 9, 10`,
which earlier read as one "affinity code" table. Splitting it:

* **bits 2-3 = 軍の属性 ArmyAffinity**: `0` 平 (111 officers), `1` 山 (70),
  `2` 水 (56). The battle AI masks it with `AND #$0C` and then
  `LSR LSR AND #$03` (`prg_0e_0f_battle.asm` `@OrderResolve` `$D110`).
* **bits 0-1 = 状態 OfficerStatus**: every runtime reader tests `AND #$03`
  (`OfficerKill` sets it with `ORA #$03`), i.e. the two low bits are a
  separate field sitting right below the affinity pair.

The seed carries a real status, which is what makes the new-game roster. Two
values occur, and they agree with the province rosters *exactly*:

| seed bits 0-1 | count | cross-check |
|---|---:|---|
| `2` rostered | 57 | identical set to the 57 distinct ids in the 30 province roster slots; 55 also have a non-zero TroopCount (exceptions: 王甫 id 16, 黄権 id 70) |
| `1` hidden | 180 | none is rostered; 154 of them have an arrival-schedule entry |
| `0` free / `3` out of action | 0 | runtime-only states |

### Arrival schedule (bank `$31` `$8B1C`)

30 blocks of `$14` bytes, one per province, each holding up to ten
`(officer id, appear year)` pairs, `$FF $FF`-padded to the block end. Years are
plain binary (`$BD` = 189 .. `$D2` = 210) and ascend within a block - all 30
blocks validate. It supplies the starting province and appearance year for the
hidden officers; 26 hidden officers have no entry and can only be picked up by
the reinforcement / free-officer scans.

`+05` 位置 LocationProvince is *not* seeded: it is 0 in every ROM record and is
written at runtime when an officer changes location.

## 5. Country (国) data is derived, not stored

There is no per-country stat table: a Country's resources are the sum over the
provinces it owns, and its Ruler comes from a hard-coded 7-entry seed
(`CountrySelect_RecordInitTable`, `$DA0F`, `asm/banks/prg_08_09_tactical_war.asm`). See
`docs/country_data.md` and `tools/extract_country_data.py`.

## 6. Re-verify

```
python tools/verify_seed_tables.py        # locations, copy lengths, invariants
python tools/extract_officer_data.py --check
python tools/extract_province_data.py  --check
python tools/extract_country_data.py   --check
```

`verify_seed_tables.py` checks the bank-file/combined-image correspondence,
re-parses both `SramInit` loops out of `prg_1d_1e_menu_screens.asm`, asserts the table
extents and the roster/OfficerStatus equality, and validates the schedule
geometry.

## 7. The banks as editable, annotated assembly

`asm/banks/data_10_seed.asm` and `data_11_officer.asm` are no longer blind `.incbin` stubs: the
analysed tables are rendered as labelled `.byte` records with the decoded values
in the comment, and only the still-unanalysed ranges stay as sliced includes
(`ca65` supports `.incbin "file", skip, length`) so the bank always reproduces
the ROM exactly.

```
ProvinceRecord_RYOUTOU:                    ; id  0  リョウトウ 辽东 (Ryoutou) | 国=7 no ruler ...
  .byte $07, $00, $A0, $00, $F0, $00, $96, $00 ; $8C00 国 country / - / 金 gold / 米 rice / 人口 population/100
  .byte $14, $00, $19, $23, $64, $00, $23, $00 ; $8C08 土地 land / 防災 disaster / 統治 governance / ...

OfficerRecord_RYOFU: .byte $63, $63, $11, $1E, $0A, $00, $AC, $0D, $E8, $03, $B5, $36   ; $8A38 id 218 リョフ 吕布 体99 武99 知17 忠30 徳10 Lv4 経験3500 兵1000 | 山軍 rostered | 方天画戟/甲冑 (+0B=$06)

ArrivalSchedule_YUUSHUU:
  .byte $9D, $BD, $90, $BE, $31, $BF, $41, $C0, $FF, $FF   ; $8B30 157(陈震)->189 144(赵云)->190 49(韩猛)->191 65(严纲)->192
  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF   ; $8B3A empty

  .byte $68, $8D, $8A, $95, $75, $96, $90, $99     ; $9C60 id   8- 15: 袁绍=204 袁谭=241 ...
```

Record labels are derived from the id equates in `include/officer_ids.inc` and
`include/province_ids.inc`, so `OfficerRecord_RYOFU`, `OFFICER_RYOFU = 218` and
the `docs/officer_data.csv` row 218 are the same officer everywhere.

Three generated views of the same data, all cross-checked:

| Direction | Command | What it proves |
|---|---|---|
| ROM -> asm | `make databanks` (`tools/gen_data_bank_asm.py --write`) | the listing reproduces `rom/prg/prg_10.bin` / `prg_11.bin` byte-for-byte |
| CSV -> asm | `make databanks-csv` (`--from-csv`) | the decoded CSV columns express every record byte (round-trips to the identical listing) |
| asm -> CSV | `python tools/verify_data_banks.py --dump-csv` | `build/officer_from_asm.csv` / `province_from_asm.csv` match the `docs/*.csv` columns |

`tools/verify_data_banks.py` is the gate: it assembles each bank standalone
(its own `$8000` linker config, like `linker.cfg`) and compares against the ROM.
Mode semantics:

* default - any byte drift fails, with each byte reported as record label,
  field name and old -> new value (roster slots additionally resolve the officer
  id to `15 王平` style).
* `--allow-edits` - deliberate edits are accepted, but the structural rules still
  reject invalid ones: 位置 `+5` must stay 0, 状態 in {1,2}, 軍の属性 in 0-2,
  stats within their caps, roster ids < 237.
* cross-bank (both banks) - the officer 状態 = 2 set must equal the province
  roster set, so a roster edit that forgets the officer's status is caught.

Editing rules: change a `.byte` (or the CSV, then regenerate) only inside the
analysed regions. The sliced `.incbin` gaps are not editable here - they follow
`rom/prg/prg_XX.bin`.

The death-year comments use the table's own scale (`byte + 100`, see
`docs/officer_death_years.md`), so values past the 208 turn limit are expected:
they are relative lifespans, and 袁紹 = 204 is the earliest in the table.

## 8. Corrections to earlier notes

* `docs/officer_data.md` previously stated that `+5` *and* the `+11` status
  bits are runtime-only and 0 in the seed. Only `+5` is; the status pair
  (`1`/`2`) is seeded and is the authoritative new-game roster flag.
* `docs/officer_data.md` / `code/cpu_ram_map.md` keyed ArmyAffinity on the
  whole low nibble (`1`/`2` 平, `5`/`6` 山, `9`/`10` 水). The field is bits
  2-3 only; the pairs were affinity shifted left by the status bit.
* The earlier "240-slot array" note had no evidence; the copy length is
  `$0B40` (`@Copy2Loop`) and the 237 bound is the `CMP #$ED` of the scan loops.

## 9. Bank `$30` `$8000-$8BFF` - pre-baked PPU screens (not seed data)

The 3 KB in front of the province records are three whole nametable images:
960 tile bytes (30 rows x 32 cols of 8 px) + 64 attribute bytes (one 2-bit
palette index per 2x2 tile block) = 1024 bytes each. No code lives here and no
byte is ever read as a scalar - each block is streamed to the PPU as a picture.
`asm/banks/data_10_seed.asm` renders them as `StrategyMapBaseScreen`,
`DuelBaseScreen`, `TacticalTerrainScreen` (tile row + attribute row per `.byte`
line).

**Mode attribution rule - do not trust the proc names.** Several `prg_1f_boot.asm`
state procs are misnamed, so the mode a screen belongs to is settled by two
other facts: (a) `addr_sub_state` (`$0078`) selects the VBlank handler from
`NmiDispatchTable` (`$F87B`), so the sub-state a state proc stores names the
frames that follow it; (b) every `STA $007A` in the ROM (opcode `8D 7A 00`, 17
sites) says who can enter that state at all. Both are mechanical now:
`python tools/scan_ram_writers.py --addr 007A` (or `0078`, `0400`) lists every
writer with its value and enclosing proc. Two of the state procs have already
been renamed on this evidence (`State_NewGameInit` -> `State_StrategyMapLaunch`,
`State_TacticalMode` -> `State_DuelSceneLaunch`); `docs/manual_kb/terminology.md`
keeps the mode hierarchy.

The seven `addr_sub_state` stores - all in `prg_1f_boot.asm` - give the real identity
of each state proc:

| State proc (`$007A`) | Stores `$0078` | VBlank handler that runs | Screen it shows |
|---|---|---|---|
| `$E0DA` `State_StrategyMapLaunch` (1) | 2 | `NmiState2_StrategyMap` `$F8B5` - strategy map | `$8000` |
| `$E18B` `State_WarSceneLaunch` (3) | 3 | `NmiState3_WarScene` `$F8FE` | (arms display rec 1 = `$8800`) |
| `$E22F` `State_StrategyMode` (5) | 4 | `NmiState4_Battle` `$F96A` | - |
| `$E2E8` `State_DuelSceneLaunch` (7) | 5 | `NmiState5_Duel` `$F9A0` -> `DuelModeDispatch` | `$8400` |
| `$E37C` `State_CountryMapView` (9) | 6 | `NmiState6_TitleScreen` `$F9E4` | bank `$15` `$9A90` -> `$2000` (title logo) |
| `$E3EE` `State_NewGameSetup` (11) | 7 | `NmiState7_CountrySelect` `$FA13` | bank `$12` `$9AE3` -> `$2000` |
| `$E46A` `State_EventMessageScene` (13) | 8 | `NmiState8_EventMessage` `$FA53` | bank `$16` `$9B92` -> `$2000` |

| Screen | CPU | PPU dest | Mode | Loader proc (rename history noted) | Uploader | CHR rec | Palette rec |
|---|---|---|---|---|---|---|---|
| `StrategyMapBaseScreen` | `$8000-$83FF` | `$2000` | Strategy (map screen) | `$E0DA` `State_StrategyMapLaunch` (was `State_NewGameInit`) - sub-state 2 -> `NmiState2_StrategyMap` | `B17_18_PpuCopyRaw` `$E113` | 0 `00 01 02 10` | 0 |
| `DuelBaseScreen` | `$8400-$87FF` | `$2000` | Duel (一騎討ち) | `$E2E8` `State_DuelSceneLaunch` (was `State_TacticalMode`, earlier `State_BattlePhase`) - sub-state 5 -> `NmiState5_Duel` -> `DuelModeDispatch` `$F9CD` | `B17_18_PpuCopyRaw` `$E318` | 10 `8D 8E 8F 90` | `$0A` |
| `TacticalTerrainScreen` | `$8800-$8BBF` | `$2400-$27FF` | Tactical (war scene) | `SceneRenderer` callback 1 - display record 1 armed by `$E18B` (`State_WarSceneLaunch`, "war" = tactical layer) | `ScenePageCopy` `$BC9B` | 1 `88 89 8A 88` | 0 |

Callers - every writer found in the ROM, not just the obvious path:

| Screen | Call chain |
|---|---|
| `$8000` | `addr_game_state = 1` <- `ClearOverlayWait` `$DB0C` (prg_0a_0b_strategy_ai: clear overlay done -> `CopySramToWork`, frame state `$0400 = $0D` / `$0401 = 3`, player country `$6F03` via `PlayerPtrTable`) · `WarPostProcess` `$BBAA` (prg_08_09_tactical_war: tactical war layer finished, also sets frame state `$0400 = $0D`) · `CountrySelect_Finalize` `$D8FF` (prg_08_09_tactical_war) · `StrategyCommand_InitOfficerScroll` `$D74E` (prg_17_18_display: A pressed while `sram_scroll_pending $6F43` is set) -> state proc `$E0DA` `State_StrategyMapLaunch` -> `PpuCopyRaw`. The proc itself separates the families: it writes the `$6F8B` request mailbox with `$FF` (turn complete) only when the caller has not staged a scene handoff at `$0400 = $0D` - `ClearOverlayWait` and `WarPostProcess` do stage it, `CountrySelect_Finalize` and `StrategyCommand_InitOfficerScroll` do not. Either way the screen is re-uploaded on every return to the map. |
| `$8400` | `addr_game_state = 7` <- `SideEventPanelSetup` `$CD66` (prg_0e_0f_battle: Battle Mode phase 5 side-event panel; it disables NMI and stores through the `$007A` slot, which that bank aliases as `btl_flash_counter`) - the **only** writer of 7 -> state proc `$E2E8` -> `PpuCopyRaw`. |
| `$8800` | `NmiState2_StrategyMap` `$F8EF` (`LDY #$3B` = banks `$1B+$1C`, `JSR $A000`; the label there read `B19_1A_OverlayStripRender_Entry`, wrong for that bank pair - fixed) -> `MapScreenFrameUpdate` `$A00C` -> frame state `$0E` = `CallSceneRenderer` `$A06D` -> `B1D_1E_SceneRenderer` `$A039` -> `SceneRenderer` `$BC71` callbacks 0 then 1 (x16 frames) -> `ScenePageCopy`. Frame state `$0400 = $0E` is written by exactly one site in the ROM: `MapRulerIntroCancelCheck` `$A172` (Select during the ruler intro / camera-focus phase). Display record 1 comes from the state-3 proc, entered by `WarSceneLaunch` `$B5E3`, `Spoils_ExitFade` `$C356`, `ArmyDeploySceneTrigger` `$CA4C` and `BattleResultFlashTrigger` `$A403`. |

The date plate on screen 1 confirms the attribution independently:
`YearDisplaySetup` (`$A6B6`, prg_1d_1e_menu_screens) converts the scenario year `$6F00 + $64`
and month `$6F01 + 1` to BCD digit tiles `nibble + $04` / `+ $14`, and those land
in the plate's gaps - the plate's own kanji are the screen's only sub-`$40`
tiles, `$0E/$1E` (年) and `$0F/$1F` (月) at tile rows 2-3, cols 6 and 10 (8x16
glyphs: upper + lower tile).

Access mechanics, per loader:

* `PpuCopyRaw` (`$A212`, `prg_17_18_display.asm`): sets `PPUADDR` from `$0001`/`$0000`,
  then loops `LDA ($0A),Y : STA $2007` with a 16-bit counter `$000C/$000D` up to
  `$0400` - exactly one screen. The caller in `prg_1f_boot.asm` does
  `LDY #$30 / JSR SwitchBank8_B`, writes the source pointer into
  `$000A/$000B` (`$8000` or `$8400`) and the PPU address into `$0000/$0001`
  (`$2000`), switches the code bank to `$17+$18` and calls it.
* `ScenePageCopy` (`$BC9B`): `LDY #$30 / JSR B1F_SwitchBank8_B`, then copies 64
  bytes from `($00)` = `$0470/$0471` into the PPU-stream packet at `$0380`
  (count `$40`, destination hi/lo from `$0473/$0472`, 64 tile bytes, `$FF`
  terminator written back through `$03C3`), and advances both pointers by `$40`.
  It stops when the destination high byte reaches `$28`, i.e. after 16 packets =
  the 1 KB at `$8800`. Callback 0 of the same renderer (`$BC83`) is what seeds
  `$0470/$0471 = $8800` and `$0472/$0473 = $2400`.
* CHR page choice comes from `DisplayInit` -> `MenuFontRecordLoad` (`$DE7E`,
  bank `$21` record table at `$946C`, 48 B/record). Record bytes 4-7 are the
  NAMCO-163 slot 4-7 pages = BG tiles `$00-3F / $40-7F / $80-BF / $C0-FF`
  (BG pattern table `$1000`, `PPUCTRL` mirror `$008B = $10`); page value `V`
  maps to `rom/chr/chr_(V/8).bin` at offset `(V%8)*$400`. Verified by rendering:
  screen 1 with record 0 gives the map plus the 年/月 plate, screen 3 with
  record 1 gives coherent terrain, and the same blocks with any other record are
  noise. See `code/font_analysis.md` for the CHR chain.
* Colour comes from a second, independent table: `LoadScenarioData` (`$DBB1`,
  prg_1d_1e_menu_screens) is really a **palette load** - its `@RecordPtrTable` (`$DBCF`, 14
  entries, index 9 repeats 8) points at 32-byte palettes at `$DBEB` (bank `$1E`
  file offset `$1BEB`), copied to `$0100` and uploaded to PPU `$3F00` by
  `PaletteUpload` (`$E70E`). Layout is the NES `$3F00-$3F1F` block: byte 0 =
  shared backdrop, then 4 colours per palette; BG palette *k* occupies bytes
  `1+4k .. 3+4k`, which is what the attribute table's 2-bit index selects. The
  record index is passed in `$0000`: `0` in `State_StrategyMapLaunch` (`$E11B`-`$E120`),
  `$0A` in `State_DuelSceneLaunch` (`$E320`-`$E325`), `0` again in `SceneRenderSetup`
  (`$BD26`-`$BD2B`) - the scene that uploads screen 3.
* Both `tools/render_ppu_screen.py --pages ... --palette ...` (this repo) and the
  grayscale fallback reproduce the pictures: `build/strategy_map_base.png`,
  `build/duel_base.png`, `build/tactical_terrain.png`, plus
  `build/title_15_9a90.png` as the control render (palette record `$0B` reproduces
  the grey stone 三国志 logo with the red II, which is what validates the
  `$3F00` mapping above).

Consequence for the earlier notes: `bank_switch_map.md` lists bank `$10` as
"record/menu/province data"; the `$8000-$8BFF` third of it is picture data, and
the `$8FC0` rice-buy-rate table and the `$9B12` pattern-pointer table (whose
32 entries point into `$9B52-$9D61`) are the only other byte tables there.

## 10. Bank `$30` `$8FC0-$9019` - 町 trade rates and province facility flags

The 90 bytes between the province master records (`$8C00-$8FBF`) and the officer
katakana names (`$901A`) are **two parallel 30-entry tables, one row per province
id**, not one blob: 60 rate bytes at `$8FC0` immediately followed by 30 facility
flag bytes at `$8FFC` (there is no gap - `$8FFC = $8FC0 + 30 * 2`). Rendered in
`asm/banks/data_10_seed.asm` as `ProvinceRiceTradeRateTable` (`.byte`, 2 bytes per
province) + `ProvinceFacilityFlags`.

### Rate byte pairs (`ProvinceRiceTradeRateTable`, `$8FC0 + province * 2`)

Each pair is two rice-per-100-gold rates, always read byte-wise:

* `+0` (`($02)` / `$8FC0+2p`): the **buy rice** leg - `@RiceBuySeed` (prg_1b_1c_map_screen
  `$C254`) computes `gold = ceil(rice * 100 / rate)`; the same pair is what
  war-layer State 0 (prg_08_09_tactical_war `$C129`) dereferences as the "action parameter
  record" of the buy/sell panel (`($02),Y` with `Y=0/1` selecting the leg).
* `+1` (`$8FC0+2p+1`, reached with `INY` after `ASL`): the **sell rice** rate -
  `SellSurplusRice` (prg_0a_0b_strategy_ai `$CC9E`) and `Action_BuyRice`'s rice cost
  (prg_08_09_tactical_war `$A457`) use it as a `Div24Bit` divisor.
* The twelve provinces with no 町 rice trade hold `$00, $00`.
* Cross-check: every (`+0`, `+1`) pair equals the `sell_rate` / `buy_rate` columns
  of `docs/rice_prices.csv`, and the `$00, $00` entries are exactly its
  `has_market = no` rows (facility bit `$04` below).

### Facility flags (`ProvinceFacilityFlags`, `$8FFC + province`)

The per-province facility flags behind the town commands. This is a second, finer
layer than the town screen's menu tables: `@TownFacilitySetTable` (prg_1b_1c_map_screen
`$C025`) maps a province to one of 10 facility *sets*, and `@FacilityActionCodeTable`
(`$C10E`) expands a set into up to 4 action codes (0=兵器工房 armory, 1=学校 academy,
2=医院 hospital, 3=町 market) - that pair is what draws the menu. These flag bytes
gate the individual commands, and are *not* a bijection onto those 4 codes: a bit is
read per command, and the same set id carries different flags in different provinces
(set `$05` 兵器工房+医院+町 -> `$0F` in 长安/安定 but `$0C` in 零陵; set `$09`
all four facilities -> `$0F` in 冀州/凉州/洛阳/江夏/成都), so the menu layout and
the command gate are two separate layers.

Every consumer switches in bank `$30` and tests one bit of `LDA $8FFC,Y` with
`Y` = province id (the table can only be 30 bytes before the name table at `$901A`
- earlier notes calling these "officer flags indexed by officer id" were wrong,
officer ids reach 236):

| Bit | Facility / verified consumer | Provinces with the bit **clear** |
|---|---|---|
| `$01` | gate read by the war AI before it evaluates the province: `@AiAction_EvaluateAndExecute` (prg_0a_0b_strategy_ai `$C33F`) - clear => skip to the next province | 0, 3, 7, 10, 14, 16, 22, 24 |
| `$02` | additional town-command facility flag, not yet tied to a named command: 14 provinces, overlapping but *not* contained in the 町 bit below (only 襄阳/永昌 carry it without a 町) | 1, 2, 5, 7, 9, 11, 13, 14, 17, 18, 19, 20, 24, 25, 27, 28 |
| `$04` | 町 rice market: set on exactly the 23 provinces whose rate pair is non-zero, i.e. `docs/rice_prices.csv` `has_market` matches this bit. Also the AI sell gate: `SellSurplusRice` (prg_0a_0b_strategy_ai `$CC45`) - clear => the AI does not liquidate rice here | 1, 5, 9, 17, 19, 22, 29 |
| `$08` | recruit/transfer facility: `@CheckEligibility` (prg_0a_0b_strategy_ai `$C872`, with the `<10 subordinate count`) and the `$C7F1` recruit-vs-transfer routing. Clear on exactly the seven ruler capitals (并州 刘备/冀州 袁绍/凉州 马腾/兖州 曹操/洛阳 董卓/江夏 孙策/成都 刘璋) | 0, 16, 18, 21, 23, 27, 29 |

Bits `$02` and `$04` are independent, not nested: 11 provinces have the 町
(`$04`) without `$02`, and only 襄阳 (22, `$0A`) and 永昌 (29, `$03`) have `$02`
without a 町 - those two are also the only provinces whose rate pair is `$00, $00`
while still owning a facility bit.

