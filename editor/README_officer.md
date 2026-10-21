# Officer Editor — Sangokushi 2 seed data, banks `$10`/`$11`

A standalone editor for the **237 officers** of *Sangokushi 2 - Haou no Tairiku*
(Famicom, Namco-163 / mapper 19) as the new game seeds them. Two front-ends share
one codec, so the GUI and the shell agree byte for byte:

```
editor/
├── officer_editor.py  the GUI (Python 3 + tkinter, no third-party deps)
├── officer_cli.py     the headless front-end, same codec and same rules
└── README_officer.md  this file
```

Both import the codec `tools/officer_model.py` (searching `--model`, their own
directory, then the repo's `tools/`), so a copied-out `officer_model.py` dropped
next to the script or pointed at with `--model` travels with them — see
"Standalone mode". The terrain editor's twin is `README.md` in this directory.

## What it edits

Every table that describes an officer at new-game start. All of them live in the
two banks that are only ever mapped into the `$8000-$9FFF` data window (mapper
register `$30` → physical bank `$10`, `$31` → `$11`):

| table | bank | CPU | shape | CSV twin |
|---|---|---|---|---|
| master records | `$11` | `$8000` | 237 × 12 B | `docs/officer_data.csv` |
| katakana names | `$10` | `$901A` | 237 × 10 B, `$00`-terminated | `docs/officer_data.csv` (`katakana`) |
| arrival schedule | `$11` | `$8B1C` | 30 × `$14` = ten (id, year) pairs | `docs/officer_data.csv` (`schedule_province_id`, `appear_year`) |
| natural-death years | `$11` | `$9C58` | 237 × 1 B = year − 100 | `docs/officer_death_years.csv` |
| province rosters | `$10` | `$8C00 + $11..$1A` | 30 × 10 slots, `$FF` = empty | `docs/province_data.csv` (`officer_ids`) |
| reinforcement pools | `$11` | `$8D74` | 4 pointers + `$FF`-terminated (id, year − 100) lists | `docs/officer_reinforcement.csv` |
| kanji name plates | `$11` | `$8DB4` | 237 × 13 B | **read-only** — see "Renaming" |
| card portraits | `$1A` `$CED6` + `$01` `$99A0`/`$9AA0`/`$9BAC` | — | 237 × 1 B page id + OAM blobs | **read-only** — see "Portraits" |
| AI successor priority | `$0B` | `$CAD8` | 7 pointers + `$FF`-terminated officer-id lists | **read-only** — see "AI ruler successor priority" |
| 計略 stratagem tier | derived | — | 知力 `+$02` + レベル `+$0B` bits 4-7 + the officer id | **read-only** — see "計略 Stratagem tier" |

The master record is the seed image of the officer's SRAM record at
`id * 12 + $63C0`: `SramInit` (`$DD8B`, `asm/banks/prg_1d_1e_menu_screens.asm`) copies
`$0B40` bytes = 240 slots (the last three are padding), and
`B1F_GetOfficerRomRecordAddr` (`$F387`) also reads the ROM seed at runtime.

| Offset | Field | Edited as | Notes |
|---|---|---|---|
| `+0` | 体力 Vitality | `vitality` | 1-100 |
| `+1` | 武力 Might | `might` | 1-100 |
| `+2` | 知力 Intelligence | `intelligence` | 1-100 |
| `+3` | 忠誠度 Loyalty | `loyalty` | 100 = a playable 君主 ruler (stock: 7) |
| `+4` | 人徳 Virtue | `virtue` | 1-100 |
| `+5` | 位置 LocationProvince | — | runtime-only, always `$00` in the seed |
| `+6/+7` | 経験値 Experience | `experience` | 16-bit LE |
| `+8/+9` | 兵数 TroopCount | `troop_count` | 16-bit LE |
| `+A` | 武器 Weapon / 防具 Armor | `weapon_index`, `armor_index` | bits 0-4 weapon (0-23), bits 5-7 armor (0-7) |
| `+B` | レベル / 軍の属性 / 状態 | `officer_level`, `army_affinity_bits`, `officer_status_bits` | bits 4-7 level (stored 0-based, shown 1-5), bits 2-3 affinity (0 平 / 1 山 / 2 水), bits 0-1 status (1 hidden / 2 rostered) |

## Invariants

The **Problems** pane (GUI) / `check` (CLI) reports two tiers.

*Problems* are exactly the rules `tools/verify_data_banks.py` re-checks on the
**assembled** bytes, so an edit that trips one can never pass the repo's byte
gate:

* `+00..+04` are 1-100, レベル is 1-5, 軍の属性 is 0-2, seed 状態 is 1 or 2;
* **状態 2 == the union of all province roster slots** (the cross-bank gate), no
  officer holds two slots, no slot is ≥ 237, no roster exceeds 10;
* the arrival schedule only lists 状態 1 officers, at most ten per province
  block, and never a half-filled (province, year) pair — the renderer drops one
  silently, which is why the editor refuses to create it;
* a name fits nine kana codes plus its `$00` terminator;
* a death year fits its byte (year − 100);
* a reinforcement join year fits its byte (year − 100), and every pool officer
  id stays inside the officer table;
* one province cannot hold two 忠誠度-100 officers (its 君主 would be ambiguous).

*Notes* are the conventions the stock ROM follows but no reader enforces, each
labelled with the stock figure so a deliberate edit reads as a change of fact:
経験値 on a level boundary (id 71 侯成 is the one documented slip), seven rulers,
154 scheduled / 26 unscheduled hidden officers, 57 roster slots, hidden officers
carrying 兵数, a 死亡年 that is not after the 出現年.

## Requirements

Python 3 with `tkinter` for the GUI (stdlib; on Debian/Ubuntu
`sudo apt install python3-tk`). The CLI needs nothing but the stdlib. Developed
against Python 3.14.

The repo-side buttons (`Write ASM`, `Verify`) additionally need `ca65`/`ld65` at
`/home/zero/.local/bin`, as every other byte gate in this project does.

## Running

Inside the disassembly repo (default — full pipeline available):

```sh
python3 editor/officer_editor.py        # loads all three docs/*.csv
make officer-editor                     # same
python3 editor/officer_cli.py list --status rostered --sort might --reverse
python3 editor/officer_cli.py show 218
python3 tools/check_officer_pipeline.py # the lossless-loop gate
```

Outside the repo (standalone mode) the editors need only the codec and a CSV:

```sh
mkdir officer-editor && cd officer-editor
cp /path/to/sango2dasm/tools/officer_model.py .
cp /path/to/sango2dasm/docs/officer_data.csv .
python3 /path/to/sango2dasm/editor/officer_editor.py --model . --csv officer_data.csv
python3 /path/to/sango2dasm/editor/officer_cli.py --model . --csv officer_data.csv list
```

`--model PATH` may point at a directory holding `officer_model.py` or at the file
itself. Without the repo the roster, death-year and reinforcement surfaces
switch off (and say so in the Notes pane — pool years fall back to a read-only
decode of the glyph bank), `Write ASM` / `Verify` / `write-asm` explain that the
generator lives in the repo, and everything else keeps working: editing, the
invariant report, `Save CSVs`, `Diff`, `save`.

## The screen

```
[Open CSV…][Save CSVs][Write ASM][Verify][Diff][Revert][Undo][Redo]  Filter[…] Province[…] 状態[…]
+-----------------------------------------------+-------------------------------------------+
| id 名前 kana 漢字 体 武 知 忠 徳 Lv 経験 兵数   | 218  リョフ  吕布   [RYOFU]              |
|     軍 状態 武器 防具 配置 placement 死亡年     | record $8A38  63 63 11 1E 0A 00          |
|                                               |               AC 0D E8 03 B5 36          |
|  (click a header to sort; blue = unsaved edit,|        +0A $B5  +0B $36                   |
|   red = trips an invariant, gold = a ruler)   | SRAM   $6DF8   name $989E                 |
|                                               | name   2B 37 1F 00 00 00 00 00 00 00     |
|  237 rows, filtered by the toolbar            | 身分 Identity      名前 Name [リョフ     ] |
|                                               | 肖像 Portrait  [normal][angry][sad][happy] |
|                                               | 能力 Stats (+00..+04) 体力 Vitality [ 99] |
|                                               | 経歴 Career        レベル OfficerLevel [4]|
|                                               | 装備 Equipment     武器 Weapon [21 方天画戟]|
|                                               | 配置 Placement     状態 2 rostered        |
|                                               |   武将 roster [province ▾][slot]          |
|                                               |     [Assign][Unassign][Make 太守]         |
|                                               |   出現 arrival [province ▾][year]         |
|                                               |     [Set][Clear]                          |
|                                               | 計略 Stratagem tier 12/16 ($00-$0B)       |
|                                               | 寿命 Life          死亡年 DeathYear [215] |
|                                               | 漢字 name plate  [kanji][kanji] [Show text]|
+-----------------------------------------------+-------------------------------------------+
| Invariants (problems) and conventions (notes) | Output (commands, decoded edits)          |
+-----------------------------------------------+-------------------------------------------+
status bar: rows shown | unsaved edits | problems | the selected officer's record decode
```

The detail pane is a scrollable column pinned to the canvas width, so the prose
lines (the province roster) re-wrap instead of being clipped. The read-only
portrait and name-plate views show only the graphics; their decode text opens
in a popup window via the **Show text** button.

Keys: `Ctrl+S` save the CSVs, `Ctrl+B` write ASM + verify, `Ctrl+Z` / `Ctrl+Y`
undo / redo, `Ctrl+F` or `/` focus the filter, `Escape` clear it,
`PageDown` / `PageUp` step through the list. A field commits on `Enter` or when
it loses focus; a value the model refuses pops up with the reason and the widget
snaps back.

The **Filter** box matches id, kana, kanji (both forms), pinyin, the assembly
label (`RYOFU`) and the equipment names. **Province** narrows to the officers
rostered in *or* arriving at one province, **状態** to `all` / `hidden` /
`rostered` / `rulers` / `unscheduled hidden`.

## Placement: roster, governor, arrival

Placement is spread over three tables, so the editor owns all three and moves
状態 only through them:

| Action | What it writes |
|---|---|
| `Assign` | adds the officer to that province's roster (`docs/province_data.csv` `officer_ids`) **and** sets 状態 2, and clears any arrival entry |
| `Unassign` | removes the roster slot **and** sets 状態 1 |
| `Make 太守` | moves him to slot `+$11`, which is what makes him the governor |
| `Set` (arrival) | writes both halves of the (province, year) pair at once |
| `Clear` (arrival) | drops the pair; he stays hidden and unscheduled |

The governor is not a flag: **whoever occupies roster slot `+$11` is the 太守**,
and `CompactRecordSlots` (`$D3DD`, `asm/banks/prg_0a_0b_strategy_ai.asm`) slides entries left,
so removing a governor silently promotes the next officer. The roster line under
the controls shows the whole province roster with a `*` on slot `+$11`.

A rostered officer has no arrival entry (`OfficerArrivalScan` `$B964`,
`prg_19_1a_event_scenes.asm`, only considers 状態 1), so `Assign` clears one and reports it in
the change list. Setting 状態 directly is refused in the direction that would
break the cross-bank gate — that is deliberate, not a missing feature.

The 状態 line at the top of the pane spells out where a hidden officer will come
from. A scheduled officer whose id is in `OfficerPreferredCountryTable` gets his
preferred Country and the 情報集め join odds, e.g. 諸葛亮:
`arrives 194 in province 21 - preferred Country 4 (情報集め recruit there: 14/16
when its owner is Country 4, else 3/16)`. A reinforcement-pool officer gets his
Country instead: `auto-arrival Country 2 (monthly pool check once his join
year arrives; needs a free home-province roster slot)`,
and the list's 配置 column shows `auto-join Country 2` for him. Both come from
read-only ROM tables, so the CSV-only standalone mode falls back to the plain
`arrives YEAR in province P` line.

## How hidden officers appear

Three independent mechanisms read 状態 1, and the editor surfaces all three:

| Mechanism | Where | Who |
|---|---|---|
| Arrival schedule | bank `$31` `$8B1C` (this editor's 出現 columns) | 154 officers; once the year is reached, scouting the block's province finds them |
| Preferred-country gate | `OfficerPreferredCountryTable` `$BA50` (prg_19_1a_event_scenes) | 16 officers among those 154; only the scheduled path consults the table, and after the find the roll compares the scouting province's owner with the preferred Country: match → 14/16 join, otherwise 3/16 |
| Reinforcement pools | bank `$31` `$8D74` (`docs/officer_reinforcement.csv`) | the 26 auto-arrival officers with **no** schedule entry: in every month's event dispatch `EventReinforceGate` (`$A33C`) picks Countries 2/3/4/6's (id, year) list and `OfficerReinforceScene` (`$AEC0`) inspects the first still-hidden officer; once his year has arrived he joins the Country's home Province roster (10 slots) if a slot is free, otherwise the check retries next month |

The pools are as editable as every other table: `docs/officer_reinforcement.csv`
(one row per officer in stored list order, `tools/extract_reinforcement_pools.py`
writes it) is re-rendered into `data_11_officer.asm` by `make databanks-csv`. The GUI's
placement pane has a 自動出現 auto arrival row (pool + join year, `Set` applies), the CLI has
`reinforce ID YEAR`, and moving an officer between countries or re-ordering a pool
is a CSV edit — the row order *is* the stored list order, which the pool scan
walks pairwise. The stock grouping is the 曹操/曹丕 family → Country 2, the 孫堅/孫権
family → Country 3, the 劉備 family → Country 4, the 馬騰 family → Country 6. The region is
exactly full at 26 pairs (pointers + lists = `$40` bytes), so adding an officer
requires dropping one.

## Renaming

`名前 Name` re-encodes the ten-byte katakana string at bank `$10` `$901A`
(read by `GetNameDisplayScale` `$F308`). Input may be katakana or hiragana, in
either the composed (`ガ`) or the ROM-literal postfix (`カ゛`) form; a character
outside the code space, or a name that would not leave room for the `$00`
terminator, is refused with the reason.

**The kanji name plate does not follow.** Bank `$11` `$8DB4 + id*$0D` holds 13
authored bytes per officer — a name-font CHR page id, then up to three kanji as
2×2 tile quadruples `(n, n+1, n+$10, n+$11)`, `$FF`-terminated — which
`CmdDrawNameFromData` (`$A426`) posts as OAM sprites on the ruler card. The
editor renders that table **with the game's own tiles**: page `V` is the 1KB CHR
chunk `rom/chr/chr_(V//8).bin` at `(V%8)*$400` (the mapping the BG display
records use), tile `n` sits at `n*$10`, and the colours are sprite palette 1 of
the strategy layer's palette record 0 (`$0F $0F $2B $28` — black strokes; the
paper tone behind them is the viewer's, since pixel 0 is transparent). Tile ids
are page-local and the pages are authored per surname group
(`code/ruler_card_decode.md` §4), so there is no kanji → tiles function to
re-derive it from: the pane is read-only, and renaming adds a note saying the
card keeps drawing the old kanji. Renaming an officer is a *kana-display*
change, not a re-branding.

## Portraits

Every officer carries a 武将カード card portrait, and the 肖像 Portrait group
renders it with the game's own tiles. `prg_1a` `$CED6 + id`
(`@OfficerPortraitChrPageTable`) holds the officer's **1KB CHR page id**;
`OfficerCardRender` (`$CE1F`, `prg_19_1a_event_scenes`) draws a 14-sprite body plus a
6-sprite face from the bank-`$01` tables — class base `$99A0` (values
0/5/10/15), body pointers `$9AA0`, face pointers `$9BAC`, records
`[y, tile, attr, x]` + `$80` — and the IRQ handler (`prg_1f_boot` `$FD03`) latches
the page into the Namco-163 CHR registers, so the card's OAM tiles resolve
inside that page (tile `& $3F`). Every card sprite in the blobs carries attr
`$23`/`$63` — palette 3 either way — and the card scenes load palette record 0
before drawing (`ProvinceOfficerRosterDispatch` `$AFF5`, `SceneRenderSetup`
`$BD2B`; `PaletteUpload` `$E70E` puts buffer bytes 16-31 at `$3F10-$3F1F`), so
the visible colours are sprite palette 3 = `$0F $20 $27 $17` (white / gold /
brown). That matches the manual's card screenshot (scan 10: the face measures
gold `$27`); pixel 0 is transparent and the paper tone behind it is the
viewer's, as with the plates.

The pane shows **all four expressions side by side** — normal (strategy card),
angry (duel pursuer, `prg_17_18_duel_and_display` `$BAF7`), sad (war defeat, `prg_08_09_tactical_war`
`$D691`), happy (war victory, `$D6BA`); offsets 0/1 are both the normal face.
The talking frames (`$9D64`) only swap the mouth tile every 8 frames, so they
are not shown.

**All 237 officers have authored portraits.** Pages `$18-$53` form the shared
authored block; the four reinforcement-only officers sit outside it — 13 王双 and
116 申耽 share page `$9F`, 19 蒯良 and 228 凌统 share page `$DB` (verified by
rendering: each pair shares the page but the class bases differ, so each
officer's card is distinct). Everything here is read-only authored data: the
page table and the OAM blobs have no CSV twin and no editing surface.

## AI ruler successor priority

When a country's ruler dies, `AppointSuccessor` (`$CA68`, bank `$0B`) walks
that country's successor priority list — `HeirPriorityListPtrs` (`$CAD8`), 7 word
pointers (Country 0-6) each to a `$FF`-terminated officer-id list — and the
**first listed officer governing one of the country's provinces** (roster slot
`$11`, the 太守) becomes the new ruler. If none qualifies, the fallback scans
the country's governors for the highest 人徳 Virtue. The 配置 Placement group's
**AI継承 Successor priority** line shows, for the selected officer, each list
that contains him and his position; the **Show text** button opens all seven
lists (also `officer_cli.py successors`). This is read-only authored data — no CSV
twin and no editing surface.

## 計略 Stratagem tier

Which of the 16 stratagems an officer can select as a war commander is derived
from his record, never stored: `BuildCommandList` (`$D3EE`, bank `$08/$09`) is
what `StratagemState_Init` (`$A89E`, bank `$0C/$0D`) calls to fill the 計略 menu,
and it leaves the slot count − 1 in `$0542`. Two authored gates, tried in that
order:

| gate | evidence | slots |
|---|---|---|
| 知力 Intelligence (record `+$02`) | `CMP #$28 / #$3C / #$4B / #$55` at `$D4D2`-`$D4E5` | 2 / 4 / 6 / 8 / 10 |
| officer id + レベル OfficerLevel (record `+$0B` bits 4-7, stored 0-based) | the `CMP` chain at `$D412`-`$D4C4` over four authored id rosters | 12 / 14 / 15 / 16 |

Every list is the sequential codes `$00..count-1`, so the count *is* the tier:
知力 buys the basic stratagems, and only the 21 rostered strategists (程昱, 荀彧,
田丰, 贾诩, 法正, 李儒, 吕蒙, 诸葛瑾, 杨修, 鲁肃, 马良 / 郭嘉, 姜维, 徐庶, 陆逊,
诸葛恪, 钟会 / 庞统, 司马懿, 周瑜 / 诸葛亮) reach 連環, 十面埋伏, 水攻, 連弩, 劫火
and 奇門遁甲. A roster member below every floor of his roster falls through to
the 知力 gate; a member at or above one never has his 知力 read. The 15/16 tiers
need stored レベル 5/6, above the stock maximum (董卓, stored 4), so in the seed
data the ceiling is 12 slots — reached by 姜维, 陆逊, 诸葛恪 and 钟会 — and the
rest is `OfficerLevelUp` (`$C691`, bank `$0C/$0D`) territory.

The **計略 Stratagem tier** pane lists what is usable now (code, kana, English),
then each higher レベル that adds more — `next` / `then` lines naming the exact
stratagems gained. Only the rostered strategists have a レベル tier, so nobody
else gets a potential line, and tiers that stay out of reach (a non-rostered id,
or above a roster's top) are not listed at all. **Show text** adds the
whole ladder table. `officer_cli.py show <id>` prints the same lines, and
`tools/check_officer_pipeline.py` section 10 re-derives the gate over every
id / レベル / 知力 combination. Read-only: it is arithmetic over 知力, レベル and
the officer id, so nothing here needs a CSV twin.

## How the data is linked

```
rom/prg/prg_10.bin, prg_11.bin   (stock reference, never written)
        |  read by tools/extract_officer_data.py, extract_province_data.py,
        |       extract_death_years.py
        v
docs/officer_data.csv  docs/province_data.csv  docs/officer_death_years.csv
        ^   |  <-- edit here (GUI or CLI)
        |   v
tools/officer_model.py   -- the codec: record/name/schedule/death/roster, invariants
        |   ^
        |   +-- editor/officer_editor.py (GUI) and editor/officer_cli.py
        v
tools/gen_data_bank_asm.py --bank all --from-csv --write
        v
asm/banks/data_10_initial_data.asm, data_11_officer.asm   (annotated .byte, one line per record)
        |  ca65 + ld65 (per-bank harness)
        v
tools/verify_data_banks.py   -- byte-exact gate + decoded edit report
```

`Save CSVs` writes the CSVs; `Write ASM` then runs the generator and the
verifier, so the GUI renders exactly what `make databanks-csv` renders. The
difference is the gate, not the bytes: the GUI's verify passes `--allow-edits`
(deliberate edits report and exit 0), while `make databanks-csv` ends in the
strict run, which exits 1 until the edited assembly is committed.

Repo commands doing the same thing as the buttons:

```sh
make databanks-csv   # re-render data_10_initial_data.asm + data_11_officer.asm from the edited CSVs
make verifydata      # assemble both banks, prove byte-exactness (strict)
make officer-diff    # list the seed edits still live vs the stock ROM
make checkofficers   # prove the whole loop is lossless (incl. both editors)
make officer-editor  # open the GUI
```

## Editing recipe

1. Open the editor, pick an officer, edit fields / placement.
2. Watch the **Problems** pane: it must stay at `no invariant problems`.
3. `Save CSVs` (`Ctrl+S`) — writes the three `docs/*.csv`.
4. `Write ASM` (`Ctrl+B`) — re-renders both banks and prints the decoded diff
   (`OfficerRecord_RYOFU (218 吕布): 武力 Might changed $63 -> $64`,
   `ProvinceRecord_SEITO (province 26 成都): 武将 roster slot 1 (16 王甫 ->
   70 黄权) changed $10 -> $46`, `death year of officer 0 (阿会喃): 243 -> 250`).
5. `make all && make verify` in the repo to rebuild the ROM image.

Deliberate edits are reported, not hidden: `verify_data_banks.py` names the
record, the field and the old → new byte, and `--allow-edits` exits 0 while the
strict run exits 1 until the edit is committed on purpose.

## The CLI

Same codec, same rules, scriptable. Every editing subcommand is a **dry run**
unless `--write` is given, mirroring `tools/gen_data_bank_asm.py` — the one
exception is `write-asm`, whose whole job is save + render + verify, so it saves
unconditionally. A `--write` that would leave a hard invariant broken is refused;
`--force` overrides, e.g. to stage a half-finished edit and let the verifier
describe it.

```sh
python3 editor/officer_cli.py list [--filter TEXT] [--province N] [--status S]
                                   [--sort KEY] [--reverse] [--limit N]
                                   [--brief] [--problems-only]
python3 editor/officer_cli.py show ID            # every byte, decoded
python3 editor/officer_cli.py fields             # the editable keys and ranges
python3 editor/officer_cli.py set ID K=V [K=V …] [--write]
python3 editor/officer_cli.py schedule ID PROVINCE YEAR [--write]
python3 editor/officer_cli.py schedule ID --clear [--write]
python3 editor/officer_cli.py roster add ID PROVINCE [--slot N] [--write]
python3 editor/officer_cli.py roster remove|governor ID [--write]
python3 editor/officer_cli.py reinforce ID YEAR [--write]   # an officer's join year
python3 editor/officer_cli.py check              # exit 1 on any problem
python3 editor/officer_cli.py diff OTHER_CSV     # field-level diff
python3 editor/officer_cli.py write-asm          # save + render + verify
python3 editor/officer_cli.py verify
```

Worked example — make 王甫 a free agent, promote 尹楷 to 5 山軍 with 方天画戟,
and move his arrival to 安定 in 201:

```sh
python3 editor/officer_cli.py roster remove 16 --write
python3 editor/officer_cli.py set 3 officer_level=5 experience=5000 \
        army_affinity_bits=1 weapon_index='$15' --write
python3 editor/officer_cli.py schedule 3 7 201 --write
python3 editor/officer_cli.py check && python3 editor/officer_cli.py write-asm
```

Numbers accept `$hex` and `0xhex`. `--status` takes the short names (`hidden`,
`rostered`, `rulers`, `unscheduled`) or the GUI's full labels. Exit codes: 0
clean, 1 invariant problems or a refused edit, 2 bad usage — so `check` works as
a pre-commit gate.

`--csv` may be given before or after the subcommand, and everything follows it:
an explicit `--csv` brings its own sibling `province_data.csv` /
`officer_death_years.csv`, so a scratch copy is never written through to the
repo's `docs/`.

## The gate

`tools/check_officer_pipeline.py` (`make checkofficers`) is what to run after
touching the codec, the generator, the verifier or either front-end. Nine
sections: the codec rebuilds all five stock tables byte-for-byte and decodes the
kanji plates from their CHR font pages (shared surnames share their first
glyph); the name encoder is the exact inverse of `charmap_kana.decode_name` on
all 237 names and agrees with it on the code space; saving the CSVs changes
nothing; seventeen synthetic breaks are each caught; `--from-csv` re-renders the
committed assembly unchanged *and* renders an edited set to exactly the bytes
the codec predicts; `verify_data_banks.py` still gates both banks; both
front-ends are wired to the codec (an AST audit plus a real widget pass when a
display is present); and standalone mode degrades instead of breaking.

## Caveats

* The kanji name plate (`$8DB4`) is authored CHR data and stays as it is — see
  "Renaming".
* The card portraits (`$CED6` page table + bank-`$01` OAM blobs) are likewise
  authored and read-only; all 237 officers have one — see "Portraits".
* `+5` 位置 LocationProvince is runtime state; the seed keeps it `$00` and the
  verifier fails the bank if it does not. Starting province and appearance year
  live in the arrival schedule, not in the record.
* 経験値 is redundant with レベル in the seed (five boundary values), except for
  id 71 侯成 — the original data-entry slip, kept and reported as a note.
* Records 237-239 exist in the 240-slot SRAM array but hold the head of the
  arrival schedule; no scan reaches them (`CMP #$ED`), so the officer count is
  237 and the editor does not offer slots beyond it.
* Province *stats* (gold, rice, population, …) are not this editor's business:
  it writes only the roster slots of `docs/province_data.csv`, plus the five
  columns derived from them (`officer_count`, `active_troops`, `officer_names`,
  `ruler_officer_id`, `hex`). Everything else in that file is passed through
  untouched.
* Neither editor writes `rom/prg/*.bin`; the stock dumps stay the reference
  images for byte-exactness.
