# RequestPoll mechanics — map frame state 9 (`prg_19_1a.asm` $C773-$CD8B)

Deep read of the map screen's strategy-playback poll: `RequestPoll` ($C7E0) plus
the `$040C`/`$6F8B` handshake it shares with the Ruler card refresher
(`RulerCardRefresh`, see `code/ruler_card_decode.md`) and the strategy engine in
banks `$0A/$0B` and `$08/$09`. All claims verified against the disassembly and
the ROM bytes (`tools/verify_19_1a.py`, `tools/verify_0a_0b`-style byte scans).

## 1. Where it runs, and how often

```
NMI -> NmiState2_MapScreen -> MapScreenFrameUpdate ($A00C, prg_1b_1c)
      -> BIT-test on $0087 (palette animation direction)   ; BMI = bit7 set
      -> MapScreenFrameStateDispatch ($A01F, table by $0400)
      -> state 9 = CallStrategyRequestDispatch ($A055)
      -> LDY #$39 / JSR B1F_BankedCallbackTrampoline / .word B19_1A_StrategyRequestDispatch
      -> bank $19 $A006 -> JMP $C773 StrategyRequestDispatch
```

Cadence, precisely:

- The handler runs **at most once per frame**, and only while the palette
  animation is parked: `MapScreenFrameUpdate` branches to the state machine only
  when `$0087` has bit 7 set. `PaletteFadeInit` writes `$0087 = $00` and
  `PaletteCopyBuffer` writes `$0087 = $01` (animation running), and
  `PaletteAnimation` marks completion with `$0087 = $FF`. So a window
  open/close fade freezes frame state 9 entirely — every `$040C` count below is a
  count of *unfrozen* frames, not of wall-clock frames (240 ≈ 4 s at 60 Hz only
  when no fade is in flight).
- Two sites enter frame state 9 (scanned across all banks):
  - `prg_19_1a` `$A370`: `$0400 ← 9`, `$0401 ← 0` → starts at `RulerPanelOpen`.
  - `prg_19_1a` `$AE6D`: `$0400 ← 9`, `$0401 ← 1`, `$040C ← 0` → starts directly
    in `RequestPoll` with the poll re-armed (full card rebuild next tick).

## 2. Sub-state inventory ($0401)

`StrategyRequestDispatch` is one `.proc` ($C773-$CD8B) that dispatches `$0401`
through a 17-entry inline table via `B1F_CallbackDispatcher` ($EADE):

| `$0401` | Handler | Note |
|---|---|---|
| 0 | `RulerPanelOpen` ($C79B) | opens overlay `$BB`, seeds the AI action budget, clears `$6F8B`, `$040C ← 0`, → 1 |
| 1, 2, 3 | `RequestPoll` ($C7E0) | one handler, three table entries |
| 4 | `WarMenuCloseWait` ($C9D2) | waits for bank-$1D menu 9 + transition, → 5 |
| 5, 6, 7 | `ArmyDeploySceneTrigger` ($CA42) | one handler for three sub-states |
| 8 | `PostWarRulerMenu` ($CA84) | menus 9/5, card variants 1 and 2 |
| 9 | `PostWarPairedRulerMenu` ($CAD4) | card variants 1 and 3 (opposing Ruler) |
| $A | `WarPhaseHandoff` ($CB2F) | `$6F8B ← $01` = hand over to the War phase |
| $B, $D | `NoticeDelayWait` ($CB7F) | shared 240-frame delay |
| $C | `RulerPanelAck` ($CB9D) | second 240-frame delay, then `$6F8B ← $01` |
| $E | `SweepOfficerPrompt` ($CBC3) | mailbox `$FA` prompt chain |
| $F | `AbsorbOfficerPrompt` ($CC26) | mailbox `$F9` prompt chain |
| $10 | `TransferConfirmPrompt` ($CC89) | mailbox `$F8`, 3 phases via `$0402` |

**Unreachable entries.** Nothing in the shipped code sets `$0401` to 2, 3 or `$D`
while `$0400 = 9`: all `$0401` writes inside the proc were enumerated (`$C7AC`
INC→1, `$C87E`←0, `$C8C6`←4, `$C8FC`←8, `$C912`←$B, `$C931`←$C, `$C962`←$E,
`$C99D`←$F, `$C9C4`←$10, `$C9FE`/`$CAD0`/`$CB2B`/`$CB94` INC, `$CB71`/`$CBB5`/
`$CD83`←1) and both frame-state-9 entry points leave `$0401 ∈ {0, 1}`. The
duplicate table entries are therefore aliases: `RequestPoll` is written to be
sub-state-agnostic (it drives itself from `$040C`), and `NoticeDelayWait` is
written to be entered at either `$B` or `$D` and simply `INC`s to the next
sub-state.

## 3. RequestPoll flow ($C7E0-$C898), annotated

**Naming decision (kept).** `RequestPoll` names the state's reason to exist and
what terminates it — sampling the engine's mailbox `$6F8B` and routing the
request — not everything it does. Two facts the name does *not* carry, now
documented in the proc's own header block (`prg_19_1a.asm` $C7E0):

- the bank-$1D `RulerCardRefresh` call is **unconditional** (all three sites:
  arming $C813, polling $C838, teardown $C896), while the mailbox read at $C83A
  exists only in the polling phase;
- the arming phase ($040C == 0) never touches the mailbox at all — its job is to
  draw the card once and arm the poll.

Alternatives considered and rejected: `TurnPlaybackPoll` (covers both duties but
"playback" is not glossary vocabulary), `RulerCardRefreshPoll` (names the
subordinate duty and loses the termination condition), `RequestMailboxPoll`
(same gap as today, only longer). It is a bank-local `@`-label, so the similar
global `B0E_0F_BattlePlayerRequestPoll` ($A39D, where "request" = player command)
costs nothing at link time.

```
C7E0  JSR CountryControlToggle        ; debug hook: Start+A hands every Country to the
                                      ; player. Inert in the shipped ROM: the arm check
                                      ; reads fixed-bank padding $FFF9 which is $00.
C7E3  LDA $040C ; BNE @DecodeMailbox  ; $040C == 0 -> "first tick" branch
C7E8    LDA $0304 ; CMP #$FF ; BNE exit ; overlay slot 1 must be idle
C7EF    LDA $0300 ; CMP #$FF ; BNE exit ; overlay slot 0 must be idle
C7F6    ($6F03 -> GetCountryDataPtr) -> $000B = Ruler Officer id
C803    $000A ← 0 ; $000C ← $040C (= 0) ; card label variant 0, FULL rebuild
C80E    JSR trampoline (Y=$3D) -> B1D_1E_RulerCardRefresh
C815    INC $040C                     ; arm the mailbox path (now permanently non-zero)
C818    JMP @PollDone ; RTS

C81B  @DecodeMailbox (every later tick):
C81B    ($6F03 -> GetCountryDataPtr) -> $000B = Ruler Officer id
C828    $000A ← 0 ; $000C ← $040C (non-zero) ; card refresh = name sprites ONLY
C833    JSR trampoline (Y=$3D) -> B1D_1E_RulerCardRefresh
C83A    LDA $6F8B ; cascade CMP/BEQ decode:
        $FE -> ReqWarPending          ($C899, sub-state 4 chain)
        $FD -> ReqCountryAbsorbed     ($C8CF, sub-state 8 chain)
        $FC -> ReqOfficerSwapNotice   ($C905, -> sub-state $B)
        $FB -> ReqOfficerRemovalNotice($C91B, -> sub-state $C)
        $FA -> ReqProvinceSweepNotice ($C942, -> sub-state $E)
        $F9 -> ReqAbsorbSweepNotice   ($C97D, -> sub-state $F)
        $F8 -> ReqTransferConfirm     ($C9AB, -> sub-state $10)
        $FF -> turn-exhausted counter (below)
        anything else -> @PollDone (idle, mailbox $00)
```

Key asymmetry between the two branches: both call `RulerCardRefresh`, but the
first passes mode 0 (clear `$0380-$03B0` and rebuild the BG label row) and every
later tick passes mode ≠ 0 (name sprites only). Since the NMI zeroes the OAM slot
cursor `$007C` each frame, the sprite half *must* be re-posted every frame the
card is on screen — which is exactly what the armed branch does — while the BG
half is written once per arming. Any handler that resets `$040C ← 0` therefore
schedules a full card rebuild for the next unfrozen tick.

### The `$FF` (turn exhausted) path

```
C86B  CMP #$FF ; BNE @PollDone
C86F  INC $040C                 ; $040C acts as a counter of exhausted turns here
C872  CMP #$20 ; BCC @PollDone  ; 32 exhausted turns -> tear the map screen down
C879  $0400 ← 0 ; $0401 ← 0     ; back to frame state 0 (ruler intro)
C881  $6F05 ← 0                 ; OrderScroll = 0 (no active game)
C884  $000B ← $FF ; $000A ← $FF ; RulerCardRefresh with no Officer and no label
C88C  $000C ← 0                 ; mode 0 -> the card buffer is blanked
```

The engine side (`DeductCounterMultiEntry` `$D140`, and `prg_08_09` `$A093`/`$BAAD`)
also sets `$6F5B ← 2` and `$6F8D ← 0` when it posts `$FF`, i.e. the AI turn-cycle
counter is parked at "idle" — the poll's job is only to shut the presentation
down after 32 further exhausted-turn frames.

## 4. `$040C`, one cell with four roles

| Context | Role | Values |
|---|---|---|
| `RequestPoll` | poll phase **and** `RulerCardRefresh` mode | 0 = not yet armed; ≥1 = armed, sprite-only refresh |
| `RequestPoll` `$FF` branch | exhausted-turn counter | 1 … `$20` → teardown |
| `NoticeDelayWait` / `RulerPanelAck` | delay frame counter | 0 … `$F0` (240) |
| prompt sub-states ($E/$F/$10) | result/answer code | e.g. `$0012` cursor index → ack into `$6F8B` |
| every ack (`RequestAckReturn`, `$CB76`, `$CBBA`) | reset to 0 | re-arms the full card rebuild |

`$040C` is written back into the mailbox by `RequestAckReturn` ($CD6F), which is
how a prompt's answer reaches the waiting engine — the cell is the *result
register* of the whole frame state.

## 5. Mailbox `$6F8B` protocol (both sides)

`$6F8B` is the strategy-layer request mailbox (see also
`memory/project_tech_stack/strategy-layer-request-mailbox-protocol.md`). Requester
side, with the verified wait loops:

| Code | Requester | Waits for | Released by |
|---|---|---|---|
| $FE | `ResolveProvinceConquest` $A8C1 (human defender) | nothing — posts and returns (`PLA PLA`) so the map plays the war; next `StrategyAiTurnDispatch` sees `BMI $A012` (bit 7 = busy) and idles | `WarPhaseHandoff` → `$01` |
| $FD | `ResolveProvinceConquest` $A8D1 (AI defender) | same post-and-return shape (instantly conquered, no war scene) | `WarPhaseHandoff` → `$01` via the sub-state 8/9 chain |
| $FC | prg_0a_0b $CB74 (Officer staged into a record) | spin `CMP #$01 / BNE` at $CB79 | `RulerPanelAck` `$CBBF` |
| $FB | prg_0a_0b $CA7A (Officer record deleted) | spin for `$01` | `RulerPanelAck` |
| $FA | prg_0a_0b $BB3B (province sweep) | spin `BNE` — waits for the cell to become **0** | `RequestAckReturn` with `$040C = 0` |
| $F9 | prg_0a_0b $BD31 (absorb sweep) | spin `BNE` for **0** | `RequestAckReturn` |
| $F8 | prg_0a_0b $B786 (province transfer, needs an answer) | spin `CMP #$F8 / BEQ` then branch on `$00` = accept | `TransferConfirmPrompt` phase 2 → `RequestAckReturn` with `$040C = $0012` |
| $FF | `DeductCounterMultiEntry` $D147, prg_08_09 $A093/$BAAD | no wait; also `$6F5B ← 2`, `$6F8D ← 0` | poll teardown after 32 ticks |
| $01 | written by the map, read by the War engine (`WarClashResolve`) | — | — |
| $00 | cleared by `RulerPanelOpen` | — | idle |

Consequences worth remembering:

- Because the engine busy-waits with `BNE`/`CMP` loops, a `$FA`/`$FC`-class
  request **halts the AI turn** until the map acknowledges it. The ack is the
  only way out, so every presentation chain in frame state 9 must end at
  `RequestAckReturn` (or the two direct `$6F8B ← $01` writers).
- `RequestAckReturn` also restores the Ruler status overlay (`$BB`) and re-copies
  the current Ruler's Officer id into `$042C`, then sets `$0401 ← 1`, `$040C ← 0`
  — i.e. returning to the poll always re-arms a full card rebuild.

## 6. Companion cells

| Cell | Role in frame state 9 |
|---|---|
| `$0400` | map frame state (9 = this handler) |
| `$0401` | sub-state (dispatch index) |
| `$0402` | phase inside the prompt sub-states ($E/$F/$10) |
| `$0300`/`$0304` | overlay/animation queue slots; `$FF` = idle — the gate for the first card rebuild and for every prompt phase |
| `$042C` | overlay parameter: Officer/Ruler id for the `$BB`/`$C2`/`$E0`/`$E3`/`$E4`/`$E5` overlays |
| `$04A0` | bank-$1D menu id (9 = `MenuAction08`, 5, 6) — correlates with the card label variant |
| `$04D6` | menu extra parameter (e.g. `$47` skip PPU re-init, `$A2` re-init) |
| `$6F03` | current Country slot → `B1F_GetCountryDataPtr` → record[0] = Ruler Officer id |
| `$6F05` | OrderScroll (command points); seeds `$6F5D = OrderScroll × 10` (`@AiActionBudgetTable` $C7CC) |
| `$6F5B`/`$6F5C`/`$6F62` | AI turn-cycle counters cleared at panel open |
| `$6F8C`/`$6F8D` | mailbox payload: AI officer selector / absorption adjustment parameter |
| `$0038-$0043` | strategy-layer parameter block shared by the notice/prompt chains ($003D/$0042 Officer, $0040/$0041 Ruler ids, $0039 alternate-overlay flag) |

## 7. Findings and corrections from this pass

- **`PoachRosterTransfer` was mislabelled** (`prg_1b_1c.asm` $D46A-$D46F): the
  site loads `Y = $2A`, which selects banks `$0A+$0B`, so its inline word `$A006`
  is **bank $0A's `ArmyValueCalc_Entry`** ($CF3F), not the identically valued
  bank-$19 `StrategyRequestDispatch` entry. The call recomputes the poached
  Officer's `Loyalty` (`+3`) as
  `clamp(newRuler.Virtue(+4) + 70 − officer.Loyalty(+3), 10, 90)`; `$0030` =
  destination Ruler, `$0031` = moved Officer. Fixed the label, comment and proc
  header; `tools/verify_1b_1c.py` → 16384 bytes, 0 mismatches.
  Follow-up: `ArmyValueCalc`'s own name/header in `prg_0a_0b.asm` ("army strength
  rating") does not match what it computes (Loyalty) and should be renamed.
- **`BankedDataHandler` → `RulerCardRefresh`** and the label table rename
  (`code/ruler_card_decode.md`), with the 11 call sites' "card slot" comments
  corrected to "label variant".
- **Open questions**: whether the alias sub-states 2/3/$D were live in an
  earlier build; what the four label-variant kanji strings are (needs the card
  CHR font page). ~~Which code consumes the name-font page id in `$00B9`~~
  Resolved (2026-10-10): the IRQ handler (`prg_1f.asm` `$FD03-$FD14`) latches
  `$B8`/`$B9` into Namco-163 CHR registers 2/3 — see
  `code/ruler_card_decode.md` §7.

## 8. Related documents

- `code/ruler_card_decode.md` — the callee side.
- `code/strategy_ai_decision_tree.md`, `code/ai_vs_ai_war_resolution.md` — the
  requesters.
- `code/bank_switch_map.md` — banked-call wiring for these banks.
