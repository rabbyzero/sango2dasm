# Cheat & debug inputs (game-start country select, portraits, capital boost)

Scope: hidden input features reported by the user for the game-start
country(ruler)-selection stage, traced to code. All addresses are ROM
addresses; file references are `asm/banks/*.asm` line numbers at the time
of writing. Every mechanism below was verified against the byte-exact
disassembly (opcode + operand shown in the asm comments).

Controller bit convention (ControllerRead $E6C6, prg_1f_boot.asm:1222):
raw/held pad 1 = `$0083`, pad 2 = `$0085`; edge (newly pressed) pad 1 =
`$0081`, pad 2 = `$0082`. Bits: 0=A, 1=B, 2=Select, 3=Start, 4=Up,
5=Down, 6=Left, 7=Right.

## 0. The $D70F "CountrySelectDispatch" machine is the new-game COUNTRY SELECTOR

The per-frame dispatcher `CountrySelectDispatch` ($D70F,
prg_08_09_tactical_war.asm:7816, entered via bank stub $A024) is NOT the
war-result scene. It is the game-start country(ruler)-selection machine,
and it is also where all the cheat input sequences live. Evidence:

- Its ONLY caller is `NmiState7_CountrySelect` ($FA44: 20 24 A0,
  prg_1f_boot.asm:3928), and `addr_sub_state` 7 — the only way to reach
  that NMI handler — is written by exactly one proc: `State_NewGameSetup`
  $E3F3 (prg_1f_boot.asm:799). No other writers of `$0078` exist
  (verified: seven immediate stores, one per state proc, no INC/DEC or
  register forms ROM-wide). So the machine runs **exclusively during the
  new-game country-select stage**.
- Phase 0 (`CountrySelect_InitRecords` $D73A) calls `CountrySelectEntryInit`
  $D97A, which seeds the seven Country records `$6F07-$6F3A` (stride 8)
  with byte 0 = Ruler id `$AD/$08/$83/$8A/$DE/$DC/$B6`, bytes 1-2 = 0,
  byte 3 (control/status) = `$03` (AI) — the game-start roster:
  $AD = トウタク 董卓, $08 = エンショウ 袁紹, $83 = ソウソウ 曹操,
  $8A = ソンサク 孫策, $DC = リュウショウ 劉璋, $DE = リュウビ 劉備,
  $B6 = バトウ 馬騰 (docs/officer_names.csv ids 173/8/131/138/220/222/182).
- Phase 2 (`CountrySelect_SelectMenuEntry` $D7B0) is the CLAIM: on an A edge
  it clears the selected record's control byte to `$00`
  (`STA faction_rec_status,Y` $D7D2, `99 0A 6F` indexed into
  `$6F0A/$6F12/...`) — the only writer anywhere that turns a Country
  human-controlled. "A + `$0083` bit3 (Start; the comment mislabels it
  B) held" jumps straight to finalize.
- Phases 3-5 are the confirm / pick / inspect flow, ending in an
  `OfficerCardRender` of the picked ruler (banked trampoline to
  `B19_1A_OfficerCardRender_Entry`, OAM base `$A7`).
- Phase 6 (`CountrySelect_Finalize` $D8E4) renders the card again, then when
  the `$0087` animation flag's bit7 is set: `game_state ($007A) = 1` and
  tail-JMP to `CountrySelectCheatExecute` — the handoff into the strategy map.

The ACTUAL war-result scene is a different machine: `WarResultSceneInit`
$D66E sets the war-scene state `$0500 = 7 / $0501 = 2` (victory $51 /
defeat $50 scene ids), which runs under the `$0500` dispatch of the
tactical/battle NMI — not through bank-$08 stub $A024 under NmiState7.
Some helpers genuinely shared with the result flow (e.g. the `$6F44`
outcome flag) contributed to the old whole-cluster "war result" naming;
the dispatcher itself is the country selector.

Renamed 2026-10-13 (user ruling): `WarResultDispatch` ->
`CountrySelectDispatch`; its phases, `WarResultMenuPoll`,
`WarResultEntryInit`, `WarResult_RecordInitTable`,
`WarResult_RowToRecordMap`, the `WarResultDirRepeat*` handlers (now
`CountrySelectCheatCheck*` — they are cheat-sequence detectors, not
dir-repeat handlers), `WarResultSlotReset` (now `CountrySelectCheatExecute`) /
`WarResultSlotTemplateApply` (now `CountrySelectCheatMaxProvince`) and the
private data tables (now proc-local `@SlotRecord*` labels) all became
`CountrySelect*` / `CountrySelect_*` equivalents (the `result_*` proc RAM
became `csel_*`; the step counters are `csel_cheat_step`, the latch
`csel_cheat_latch`, and `$6F02` is `csel_game_level` = `sram_game_level`).
Kept war names: `WarResultSceneInit` ($D66E, arms war_scene_id `$0500` = 7
inside the war-scene machine) and bank $0C's `WarResultPanel`.

## 1. Cheat sequences — the four cheat-sequence checkers

`CountrySelectDispatch` runs four input trackers
unconditionally at the top of every frame ($D70F-$D718), before the
phase dispatch. Hold mask and tap sequence are both table-driven by the
per-group counter (`LDA $0083 / AND @HoldMasks,Y` for the hold, edge
masks on `$0081` for the taps); releasing the held button mid-sequence
resets the counter:

| Group | Proc | Hold (masks at) | Tap sequence (edge masks at) | Latch | Gate |
|-------|------|-----------------|------------------------------|-------|------|
| 0 | CountrySelectCheatCheck0 $DB10 | Start+Select `$0C` ($DB51) | Up,Down,Up,Down,Left,Right,Left,Right ($DB5A) | `$6FEA` bit0 | `$0541 == 1` |
| 1 | CountrySelectCheatCheck1 $DB62 | pad-2 twin on `$0085` ($DBA3) | ($DBAC) | `$6FEA` bit1 | `$0541 == 3` |
| 2 | CountrySelectCheatCheck2 $DBB4 | Select `$04` ($DBEE) | Right,Right,Down,Down,Up,Down,Up,Down ($DBF7) | `$6FEA` bit2 | ungated |
| 3 | CountrySelectCheatCheck3 $DBFF | Start `$08` ($DC39) | Up,Right,Down,Left,Up,Left,Down,Right ($DC42) | `$6FEA` bit3 | ungated |

Each completed sequence fires sound $62 and ORAs its bit into the
outcome latch `$6FEA`. `$6FEA` has no clearing write anywhere (the only
four `8D EA 6F` stores are the ORAs above); `SramInit` wipes it on a
new game. Since NmiState7 runs only at country select, all of these are
live **during the ruler-selection stage** — matching the user's report.

## 2. Portrait always sad / happy (`$6FEA` bits 2/3)

`OfficerCardRender` $CE1F (prg_19_1a_event_scenes.asm:6936) overrides
every officer card's face expression from the latch:

```
LDA $6FEA     ; $CE1F: AD EA 6F
AND #$04      ; $CE22: 29 04     bit2 -> sad
BEQ @OverrideBit3
LDA #$03      ; $CE26: A9 03
STA a:$00A4   ; $CE28: 8D A4 00  expression 3 = sad
@OverrideBit3:
LDA $6FEA     ; $CE2B: AD EA 6F
AND #$08      ; $CE2E: 29 08     bit3 -> happy
BEQ @BankIn
LDA #$04      ; $CE32: A9 04
STA a:$00A4   ; $CE34: 8D A4 00  expression 4 = happy
```

- hold **Select** + Right,Right,Down,Down,Up,Down,Up,Down -> every
  portrait permanently sad
- hold **Start** + Up,Right,Down,Left,Up,Left,Down,Right -> every
  portrait permanently happy

(`$00A4` low 3 bits = card slot: 0/1 normal, 2 angry, 3 sad, 4 happy.)
The latch sticks for the session — including through the selected
ruler's card in phases 5-6, which is presumably the point.

## 3. Capital boost (`$6FEA` bit0/1 + template)

Arming happens in **selector phase 1** (the "wait for A/B" phase before
the ruler menu opens — i.e. the idle time at country select):
hold **Start+Select** + Up,Down,Up,Down,Left,Right,Left,Right ->
`ORA #$01 / STA $6FEA` ($DB29-$DB2B) + sound $62. (The pad-2 twin arms
bit1 during phase 3.)

At finalize, `CountrySelect_Finalize` -> `CountrySelectCheatExecute` $DC4A
(prg_08_09_tactical_war.asm:8538) scans the seven Country records and
applies a template to the first one whose control byte matches the
latch class — bit0 -> record[3] == `$00` (the country the player just
claimed). `CountrySelectCheatMaxProvince` $DC9C then copies 15 bytes of
`@SlotRecordTemplate` ($DCC5, proc-local in
`CountrySelectCheatMaxProvince`) into offsets 2-$10 of that
country's capital Province record (pointer table $DCB7:
`$6180 $6080 $6160 $6280 $6040 $6340 $60C0` = `$6000 + id*32`, ids
12/4/11/20/2/26/6 for Country slots 0-6, i.e. 洛阳/董卓 冀州/袁绍
兖州/曹操 江夏/孙策 并州/刘备 成都/刘璋 凉州/马腾):

| Offset | Bytes | Value |
|--------|-------|-------|
| 2-3    | `0F 27` | 9999 |
| 4-5    | `0F 27` | 9999 |
| 6-7    | `0F 27` | 9999 |
| 8-9    | `0F 27` | 9999 |
| A      | `63`  | 99 |
| B      | `63`  | 99 |
| C-D    | `0F 27` | 9999 |
| E-F    | `E7 03` | 999 |
| 10     | `63`  | 99 |

So: **enter the Start+Select sequence while the selector waits, then
claim a ruler — its home Province starts maxed.** Without the latch
armed, `CountrySelectCheatExecute` finds no matching bit and returns
immediately (the normal path).

## 4. "Hold Start+Select = demo play"

Two unrelated A-gated waits wear this folklore; no Start+Select handler
exists anywhere in the ROM:

- On the **title/attract path** (NmiState2 map frames),
  `CountryRotationDispatch` $A033 (prg_19_1a_event_scenes.asm:71) cycles
  the rulers unattended; sub-state 2 `OverlayPoll` exits only on an A
  edge ($A176: `AND #$01`). Holding Start+Select (or simply not
  pressing A) keeps the attract cycle running.
- On the **new-game selector** (NmiState7), phase 1 similarly waits for
  an A/B edge before opening the ruler menu; idling there keeps the
  stage in its unattended state.

The true all-AI demo toggle is `CountryControlToggle` $CD8C
(prg_19_1a_event_scenes.asm:6825), polled once per tick from the
strategy request poll (StrategyRequestDispatch $C7E0): Start held
(`$0083 AND #$08`) + A edge (`$0081 AND #$01`) plays sound $62 and
toggles the seven Country control bytes (record[3] at
`$6F0A/$6F12/$6F1A/$6F22/$6F2A/$6F32/$6F3A`, stride 8) between their
backup `$6FE2-$6FE8` and **all `$03` (computer-controlled)** — a real
self-playing demo. Arm gate:

```
LDA $FFF9     ; $CD8C: AD F9 FF  fixed-bank padding byte
CMP #$FF      ; $CD8F: C9 FF     armed only if $FF
```

`$FFF9 = $00` in the shipped ROM (prg_1f_boot.asm:4683 shows the
`$FFF7: FF FF 00` tail), so the first test always fails. Patching that
single byte to `$FF` enables it.

Which of the two waits the user's remembered "demo play" refers to is
best settled by running the ROM.

## Summary

| Input | Stage | Effect | Code |
|-------|-------|--------|------|
| (no input) | title attract / idled selector | unattended cycle continues (the "demo") | OverlayPoll $A176; selector phase 1 |
| patch `$FFF9`=$FF, then Start+A | strategy poll | all 7 countries <-> AI control ($03) | CountryControlToggle $CD8C (inert in shipped ROM) |
| hold Select + R,R,D,D,U,D,U,D | country select (any phase) | all portraits permanently sad (`$6FEA` bit2) | CountrySelectCheatCheck2 $DBB4 -> OfficerCardRender $CE1F |
| hold Start + U,R,D,L,U,L,D,R | country select (any phase) | all portraits permanently happy (`$6FEA` bit3) | CountrySelectCheatCheck3 $DBFF |
| hold Start+Select + U,D,U,D,L,R,L,R | country select phase 1 (before opening the menu) | claimed country's capital Province stats maxed at finalize (template $DCC5) | CountrySelectCheatCheck0 $DB10 -> CountrySelect_Finalize $D8E4 -> CountrySelectCheatExecute $DC4A -> CountrySelectCheatMaxProvince $DC9C |
