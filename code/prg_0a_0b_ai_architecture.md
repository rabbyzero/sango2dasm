# prg_0a_0b.asm — Strategy-Mode AI architecture

Bank pair `$0A/$0B` (`$A000-$DFFF`) implements the **Strategy Mode AI**: the
per-country turn engine that expands territory, manages officers and
resources, and posts its results back to the map screen through the `$6F8B`
strategy-layer request mailbox. Naming follows
`docs/manual_kb/terminology.md` (Country / Province / Officer / Strategy /
Intrigue). All decisions below are verified against the ROM bytes.

Related documents:

- `code/ai_decision_tree.md` — the **war/battle** AI decision tree
  (`AiTurnProcess`, prg_08_09); this file covers the strategy-layer AI.
- `code/cpu_ram_map.md` — WRAM `$6Fxx` semantic map (updated with the 0a_0b
  aliases pinned during this review).
- `memory/project_tech_stack/strategy-layer-request-mailbox-protocol.md` —
  the `$6F8B` handshake contract.

---

## 1. Top-level AI decision flow

```mermaid
flowchart TD
    E["CheckGameStart_Entry $A000"] --> CGS{"CheckGameStart $A00F<br/>$6F8B mailbox flag"}
    CGS -->|"negative - no request"| X["RTS"]
    CGS -->|"== $01 - new game"| NG["BuildAdjacencyBitmap<br/>InitNewGameContext $A8D7<br/>full post-conquest setup"]
    CGS -->|"other"| OFF["BuildAdjacencyBitmap<br/>FindBestOfficerAssign $C50E<br/>ProcessAllOfficers $C5B9<br/>OfficerSearchAndEvaluate $C79A<br/>FindBestOfficerByCategory $C98F"]
    OFF --> CYC{"$6F5B<br/>AI turn-cycle counter"}
    CYC -->|"0 - first cycle"| IWA["InitWorkAreas $A043<br/>seed AI weights $6F5F-$6F61 from<br/>ProvinceDataA/B/C + TierAdjustA/B/C"]
    CYC -->|"1"| WD
    CYC -->|">= 2"| X
    IWA --> WD
    WD{"AiActionWeightedDispatch $A19C<br/>random over weights<br/>A = $6F5F, B = $6F60, C = $6F61"}
    WD -->|"weight A"| CEC["CountryExpansionCheck $A1C5<br/>expansion / absorption path"]
    WD -->|"weight B"| ATD["AiTurnDispatch $B49C<br/>main AI turn actions - see section 2"]
    WD -->|"weight C"| ET["EndTurn $A23D<br/>skip straight to end of turn"]

    CEC -->|"posts $6F8B"| MB["$6F8B mailbox:<br/>$FE = battle pending<br/>$FD = fully absorbed"]
    ATD -.-> MB
```

`$6F5B` (`sram_counter`) is incremented once per `InitWorkAreas` pass, so the
AI does one weight-seeding cycle, one weighted-action cycle, then idles until
the map screen calls again.

---

## 2. CountryExpansionCheck — expansion / conquest gate

```mermaid
flowchart TD
    CEC["CountryExpansionCheck $A1C5"] --> LVL{"$6F02 game level"}
    LVL -->|"0/1"| R20{"random 100 < 20?"}
    LVL -->|"2"| R30{"random 100 < 30?"}
    R20 -->|"yes"| EPA
    R30 -->|"yes"| EPA
    R20 -->|"no"| RDY{"readiness check"}
    R30 -->|"no"| RDY
    RDY -->|"L0: year $6F00 >= $5A<br/>L1: year >= $5A OR month $6F01 >= 6<br/>L2: always"| READY["expansion ready"]
    RDY -->|"not ready"| ET2["EndTurn $A23D"]
    READY --> FBEP["FindBestEnemyProvince $A240<br/>best enemy target"]
    FBEP --> SLOTS["slot-capture counter +3, cap 10<br/>$0037"]
    SLOTS --> FAS["FindAbsorptionSource $A303<br/>if source lacks slots"]
    FAS --> DOA["DispatchOfficerArmies $A45C"]
    DOA --> LTD["LevelTierDispatch $A6BC<br/>CalcArmyTierAndRender $A6C9"]
    LTD --> RCA["ResolveCountryAbsorb $A79C<br/>deduct attacker stats, move officers,<br/>zero conquered province, pack war params"]
    RCA --> POST{"country status +3 == 3?"}
    POST -->|"no"| FE["$6F8B = $FE battle pending<br/>reset $6F8D adjust param"]
    POST -->|"yes"| SUM["SumEnemyRecords +<br/>$6F8B = $FD fully absorbed"]
    EPA["EvalProvinceAbsorption $B10E<br/>value-based absorption<br/>AbsorbUpdateRecord $B287 /<br/>FallbackMergeProvinces $B357"]
```

---

## 3. AiTurnDispatch — main AI turn decision tree

`AiTurnDispatch` ($B49C-$C50D, `.endproc` must sit immediately before
`Proc_C50E`) is one `.proc` with ~30 nested `@`-labels. The full workflow is
documented in the proc header; the decision tree:

```mermaid
flowchart TD
    A0["entry $B49C"] --> R1{"random AND $7F >= 50?"}
    R1 -->|"yes"| A0
    R1 -->|"no"| R2{"random < 10?"}
    R2 -->|"yes"| SEL
    R2 -->|"no 10-49"| SRCH["Province Search<br/>@ScanOwnedProvinces / @ScanEnemyProvinces<br/>@FindTransferCandidate $B53E<br/>weakest connected target"]
    SRCH --> DEV

    subgraph SEL["@AiActionSelect $B5FC"]
        S1{"random AND $7F"} -->|"0-29"| ABS["@AiAbsorbProvinceAction $BBB2<br/>absorb rival province officers"]
        S1 -->|"30-59"| STR["@AiStrategyAction $B98B<br/>strategy development / recruitment"]
        S1 -->|"60-89"| SWP["@AiAction_OfficerSwap $B619<br/>swap officers between provinces"]
    end

    ABS --> DEV
    STR --> DEV
    SWP --> DEV

    DEV["@AiDev_Main $BD7A<br/>officer development loop:<br/>train best candidate, ability = $03E8"] --> ADV

    ADV["@AiTurn_AdvancePhase $BEE6<br/>$6F83,X +1; every 30 actions:<br/>$6F62 phase +1, wrap at 3 via $D140"] --> TH{"random 80 vs<br/>@AiDev_ActionThreshold $BEDF<br/>per-player aggression"}
    TH -->|"random < threshold"| ROLL
    TH -->|">= threshold"| CONT

    subgraph ROLL["@RollAction $BF16 - random 100"]
        P1{"0-39"} -->|"yes"| MON{"calendar month $6F01<br/>raw 3-7 = April-August?"}
        MON -->|"yes"| TR["@AiAction_LandReclamation $BF44<br/>spend gold, LandValue += spent x mod / 10; cap 999"]
        MON -->|"no"| SU["@AiAction_IndustryDevelopment $BFC3<br/>same, to Industry +$0E/$0F"]
        P2{"40-69"} -->|"yes"| MO["@AiAction_TownDevelopment $C04E<br/>half-strength Population gain +$06/$07"]
        P3{"70-89"} -->|"yes"| SB["@AiAction_DisasterPrevention $C0CF"]
        P4{"90-99"} -->|"no"| CB["@AiAction_GovernanceBoost $C130<br/>spends gold + rice, bumps Governance"]
    end

    subgraph CONT["@AiAction_ContinueTurn $C1E0 - random 100"]
        C1{"0-29"} -->|"yes"| LWL["@FindWeakestLoyaltyOfficer $C248<br/>officer Loyalty boost field+3"]
        C1 -->|"no 30-99"| MOL["@AiAction_TrainIntelligence $C298<br/>officer Intelligence training field+2"]
        C1 -.->|"no valid officer"| EVAL
    end

    EVAL["@AiAction_EvaluateAndExecute $C337<br/>bank 1F strategic evaluation loop:<br/>@FindBestActionField - @DeductActionCost<br/>- write result - re-evaluate"] --> GRP{"$003A bitfields"}
    GRP -->|"low 5 bits"| SM["strategy / military actions<br/>cost tables $C3BF / $C3CF"]
    GRP -->|"upper 3 bits"| INTR["intrigue actions<br/>cost tables $C3DF / $C3EF"]
    SM -->|"cost underflow"| END["@AiAction_EndTurn $BEC7"]
    INTR -->|"cost underflow"| END
    SM --> LOOP["loop until done"]
    INTR --> LOOP
```

Per-player aggression thresholds (`@AiDev_ActionThreshold`, random-80):
P0 `$14` (25% extra action), P1 `$32` (63%), P2 `$28` (50%), P3 `$1E` (38%),
P4 `$28` (50%), P5 `$3C` (75%), P6 `$32` (63%).

---

## 4. File structure

Bank `$0A` maps at `$A000-$BFFF`, bank `$0B` at `$C000-$DFFF`; the file is one
unit with two linker segments (`CODE_BANK0A` / `CODE_BANK0B`, config
`tools/test_0a_0b.cfg`, verified by `tools/verify_0a_0b.py`).

```mermaid
flowchart LR
    subgraph PUB["Public entry stubs $A000-$A00E"]
        direction TB
        P1["CheckGameStart_Entry<br/>SubStateDispatch_Entry<br/>ArmyValueCalc_Entry<br/>DataRecordLookup_Entry<br/>DistanceClamp_Entry"]
    end
    subgraph AI["AI turn engine $A00F-$A6xx, $B49C-$C50D, $C50E-$C79A"]
        direction TB
        A1["CheckGameStart / InitWorkAreas / ScanMatchData<br/>AiActionWeightedDispatch / CountryExpansionCheck<br/>AiTurnDispatch $B49C-$C50D<br/>FindBestOfficerAssign / ProcessAllOfficers<br/>CalcActionProb / OfficerSearchAndEvaluate<br/>FindBestOfficerByCategory / ApplyScenarioDeductions"]
    end
    subgraph ABS["Conquest pipeline $A79C-$B49B"]
        direction TB
        B1["ResolveCountryAbsorb<br/>InitNewGameContext $A8D7-$B10D<br/>EvalProvinceAbsorption / AbsorbPreview<br/>TransferProvinceValues / AbsorbUpdateRecord<br/>FallbackMergeProvinces"]
    end
    subgraph DOM["Record / domain helpers $CF3F-$D335"]
        direction TB
        C1["ArmyValueCalc / DataRecordLookup / DistanceClamp<br/>LoadRecord / CalcPlayerTerritoryValue<br/>CountPlayerProvinces / GetProvinceOwner $D105<br/>DeductCounterMultiEntry / CollectEnemyProvinces X<br/>FindPlayerProvinceByValue / ReadRecordField<br/>CountRecordSlots / GetPlayerRecordPtr<br/>DeductRecordStat2/4 / CompactRecordSlots"]
    end
    subgraph MATH["Math + geometry $D336-$D5E6"]
        direction TB
        D1["Divide24 / Divide16 / Multiply32 / Multiply8x8<br/>JumpDispatcher / RandomBelow<br/>BuildAdjacencyBitmap / MergeAdjacencyBits<br/>CheckPathExists $D583"]
    end
    subgraph DBG["Debug / validation $D5E7-$D716"]
        direction TB
        E1["DebugStub_E7/E1E/E5<br/>ValidateRecordStats Alt / ValidateRecordGold<br/>ClampRecordStatPairs Alt / ValidateProvinceSlots<br/>write BRK error codes to $6FFF sink"]
    end
    subgraph UI["Display / overlay / input $D717-$DC2E, $A55C-$A6BB"]
        direction TB
        F1["SubStateDispatch $D717 5-way<br/>ActionResultDisplay + State* frame handlers<br/>RenderOverlay / Overlay* / ClearOverlay*<br/>TileRender / NameTable / ScrollUpdate<br/>DrawSelectionSprites / MenuInputHandler<br/>SpriteSetup2 / PaletteCheck"]
    end
    subgraph SRAM["SRAM save / load $DC2F-$DCC7"]
        direction TB
        G1["VerifySramChecksum $DC2F<br/>CopySramToWork $DC97"]
    end
    PUB --> AI
    AI --> ABS
    AI --> DOM
    AI --> MATH
    AI --> UI
    ABS --> UI
    PUB --> SRAM
    UI --> SRAM
```

### Proc inventory (start addresses)

| Group | Procs |
|-------|-------|
| Public stubs | `CheckGameStart_Entry` $A000, `SubStateDispatch_Entry` $A003, `ArmyValueCalc_Entry` $A006, `DataRecordLookup_Entry` $A009, `DistanceClamp_Entry` $A00C |
| AI engine | `CheckGameStart` $A00F, `InitWorkAreas` $A043, `ScanMatchData` $A0D3, `AiActionWeightedDispatch` $A19C, `CountryExpansionCheck` $A1C5, `EndTurn` $A23D, `FindBestEnemyProvince` $A240, `FindAbsorptionSource` $A303, `DispatchOfficerArmies` $A45C, `ArmyDispatch` $A481, `AiTurnDispatch` $B49C, `FindBestOfficerAssign` $C50E, `ProcessAllOfficers` $C5B9, `CalcActionProb` $C66F, `OfficerSearchAndEvaluate` $C79A, `FindBestOfficerByCategory` $C98F, `ApplyScenarioDeductions` $CD68, `BracketDeductArmy` $CEDD |
| Conquest | `ResolveCountryAbsorb` $A79C, `InitNewGameContext` $A8D7, `EvalProvinceAbsorption` $B10E, `AbsorbPreview` $B1F9, `TransferProvinceValues` $B1FD, `AbsorbUpdateRecord` $B287, `FallbackMergeProvinces` $B357 |
| Tier / render | `LevelTierDispatch` $A6BC, `CalcArmyTierAndRender` $A6C9, `CalcTierWorkPtr` $A74A, `TileRender` $A55C, `NameTable` $A60C |
| Record helpers | `ArmyValueCalc` $CF3F, `DataRecordLookup` $CF7C, `DistanceClamp` $D00C, `LoadRecord` $D03A, `CalcPlayerTerritoryValue` $D05D, `CountPlayerProvinces` $D080, `CountValidPlayerProvinces` $D0AA, `GetProvinceOwner` $D105, `DeductCounterMultiEntry` $D12D, `CollectEnemyProvinces` $D1A4, `CollectEnemyProvincesX` $D1F4, `FindPlayerProvinceByValue` $D249, `ReadRecordField` $D283, `ReadBankedRecordField` $D2D3, `CountRecordSlots` $D304, `GetPlayerRecordPtr` $D319, `DeductRecordStat2` $D36F, `DeductRecordStat4` $D3A9, `CompactRecordSlots` $D3DD |
| Math / geometry | `Divide24` $D336, `Divide16` $D40F, `Multiply32` $D438, `Multiply8x8` $D471, `JumpDispatcher` $D494, `RandomBelow` $D4AD, `BuildAdjacencyBitmap` $D4CB, `MergeAdjacencyBits` $D53E, `CheckPathExists` $D583 |
| Debug / validation | `DebugStub_E7` $D5E7, `ValidateRecordStats` $D5E8, `DebugStub_1E` $D61E, `ValidateRecordStatsAlt` $D61F, `ClampRecordStatPairs` $D655, `ValidateRecordGold` $D688, `ClampRecordStatPairsAlt` $D69D, `DebugStub_E5` $D6E5, `ValidateProvinceSlots` $D6E6 |
| Display / overlay | `SubStateDispatch` $D717, `CallStrategyModeDisplay` $D72A, `StackFill` $D732, `FillStackLoop` $D73C, `ActionResultDisplay` $D74C, `StateWait64Frames` $D799, `StateScrollDown` $D7BD, `StateSpriteAnim` $D7EC, `StateSetupParams` $D83B, `StatePaletteUpdate` $D856, `StateSetupMenu` $D890, `StateTileScroll` $D8AD, `StateWriteText` $D8D9, `StateWaitInput` $D8F8, `SkipToTileScroll` $D90D, `RenderOverlay` $D99C, `OverlayInit` $D9A8, `OverlayFillRows` $D9D0, `OverlayCommit` $DA1B, `ClearOverlay` $DA7E, `ClearOverlayInit` $DA95, `ClearOverlayMenu` $DAA6, `ClearOverlayWait` $DAFD, `ClearOverlayCopyText` $DB2B, `ClearOverlayConfirm` $DB7B, `ClearOverlayExit` $DBC1, `ClearOverlayCancel` $DBF1, `ScrollUpdate` $DCC8, `ScrollDigitWriter` $DD0F, `DrawSelectionSprites` $DD34, `WriteSingleSprite` $DD53, `MenuInputHandler` $DD79, `SpriteSetup2` $DEAF, `PaletteCheck` $DF4C |
| SRAM | `VerifySramChecksum` $DC2F, `CopySramToWork` $DC97 |

---

## 5. `$6Fxx` SRAM cells used by this bank

Review result (cross-checked against `code/cpu_ram_map.md`):

| Cell | Equate / meaning in prg_0a_0b | Notes |
|------|-------------------------------|-------|
| `$6F00` | `sram_game_year` — calendar year − 100 | Seeded `$59` (year 189) at new game (prg_1d_1e `$DE59`); expansion gate `>= $5A`; demo year tick reuse |
| `$6F01` | `sram_game_month` — calendar month − 1 | Troop reinforcement in April–August (raw 3–7); level-1 expansion gate `>= 6` (July+); demo rotation step reuse |
| `$6F02` | `sram_game_level` — difficulty 0-2 | Indexes ProvinceDataA/B/C, TierAdjustA/B/C, LevelTierDispatch, LevelActionModifiers |
| `$6F03` | `sram_player_id` — acting country slot | Owner comparisons, `@AiDev_ActionThreshold` index (`& 7`), `@ScanProvinceOwnership` |
| `$6F07-$6F3E` | Country records, 7 × 8 B (stride 8) | Read via `GetPlayerRecordPtr`/`B1F_GetCountryDataPtr`; status byte +3 gates the final absorption path |
| `$6F43` | latched result parameter | `ClearOverlayMenu` `$DAF4` |
| `$6F44` | absorbed-officer display flag | `$B783`, `$BD04` |
| `$6F5B` | `sram_counter` — AI turn-cycle counter | Dispatch selector in `CheckGameStart` |
| `$6F5D` | `sram_action_budget` — AI action-point budget | Decremented per action via `DeductCounterMultiEntry` |
| `$6F5E` | AI province cursor | Reset by `@AiTurn_AdvancePhase`, read by every action handler |
| `$6F5F-$6F61` | AI action weights A/B/C (`sram_ai_weight_a/b/c` proc-local) | Seeded by `InitWorkAreas`, consumed by `AiActionWeightedDispatch` |
| `$6F62` | AI global phase / per-officer active flag (`$6F62,Y`) | Advances every 30 actions; wraps at 3 with a game-state transition through `$D140` |
| `$6F73-$6F78` | per-owner "has provinces" marks; army-pool accumulators in `InitNewGameContext` | Dual use, documented in cpu_ram_map.md |
| `$6F8B` | `sram_game_start_flag` — strategy-layer mailbox | `$FE` battle pending, `$FD` fully absorbed posted here |
| `$6F8C` | `sram_continue_flag` — post-conquest context (0 = new-game setup) | Read/written by `InitNewGameContext` |
| `$6F8D` | `sram_absorb_adjust` — absorption adjustment parameter | Written `$AE96`, drives `ApplyScenarioDeductions` and `×4/10` scaling |
| `$6FFF` | BRK debug error-code sink | Validate routines only; outside the `$6000-$6FFD` save snapshot |

---

## 6. Review corrections applied (2026-09)

1. `$6F00`/`$6F01` were commented as "development counter" / "sub-phase
   counter" (and once as "game state"). Cross-bank evidence (prg_19_1a
   `$B9C5`/`$C3EC` reign-year/calendar comments, prg_1d_1e new-game seed
   `$59`/`$00`) proves they are the **calendar year (−100)** and **month
   (−1)** cells. Comments fixed; `sram_game_year`/`sram_game_month` equates
   added and used at the four read sites.
2. The Level-1 expansion readiness comment said `year >= 90 AND month >= 6`;
   the code implements **OR** (`BCS @expansionReady` after each check). Fixed
   in the proc header and inline.
3. `@AiAction_StatBranch` "game state 3-7" corrected to **calendar month
   4-8 (raw 3-7)** — the AI reinforces troops in spring/summer, supplies
   otherwise.
4. `$6FFF` documented as the BRK error-code sink in all five validate proc
   headers; `$6F8C`/`$6F8D`, `$6F44`, `$6F73-$6F78` aliases recorded in
   `code/cpu_ram_map.md`.
5. Terminology audit: zero stale tokens (`kingdom`, `domestic`, `entity`,
   `character`) remain — the earlier glossary alignment pass is intact.
6. Province-record "morale" deep dive (2026-09): the field does not exist in
   the game. `+$06/$07` is **Population 人口 (stored ÷100)** — proven by the
   ROM seed table (`docs/province_data.md`, bank `$30` `$8C00`, 32 B/record)
   and the human castle-development command (`prg_1b_1c.asm`
   `CastleDevFieldOffsetTable`: `+$08` land, `+$0E` industry, `+$06`
   population, `+$0A` disaster prevention). The whole province record table in
   `code/cpu_ram_map.md` was realigned: Rice `+$04/$05`, LandValue `+$08/$09`,
   DisasterPrevention `+$0A`, Governance `+$0B`, ReserveTroops `+$0C/$0D`
   (cap 10000), Industry `+$0E/$0F`, Treasure `+$10`, RevoltCooldown `+$1B`.
7. AI action renames (proc-local `@`-labels, byte-neutral; ca65 error set
   unchanged): `@AiAction_ReinforceTroops`→`@AiAction_LandReclamation`,
   `@AiAction_ReinforceSupplies`→`@AiAction_IndustryDevelopment`,
   `@AiAction_BoostMorale`→`@AiAction_TownDevelopment`,
   `@AiAction_SmallStatBoost`→`@AiAction_DisasterPrevention`,
   `@AiAction_CompositeBoost`→`@AiAction_GovernanceBoost`,
   `@AiAction_ManageOfficerLoyalty`→`@AiAction_TrainIntelligence` (targets
   officer `+$02` Intelligence, not Loyalty),
   `@AddLoyaltyBonus_*`→`@AddGovernanceBump_*` (bumps province `+$0B`
   Governance, matching `CastleDevFieldAddCapped`).
8. Gain-formula corrections: the development actions **spend resources
   first** — `DeductRecordStat2` deducts `base + random($24)` from Gold
   (`+$02/$03`), `DeductRecordStat4` does the same on Rice (`+$04/$05`);
   the added amount is `spent × level_mod / 10` (TownDevelopment halves it;
   GovernanceBoost divides gold+rice spend by `mod[6]`). The old
   "(province_idx × $0E × mod)" comments misread the calling convention.

Verification: standalone `ca65` on this file produces the identical
pre-existing error set (48 duplicate-symbol errors, line numbers shifted
only); all edits are comments, equate definitions, or equal-valued equate
substitutions, so assembled bytes are unchanged.
