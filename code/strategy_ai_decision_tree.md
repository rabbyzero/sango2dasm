# Strategy AI Decision Tree — prg_0a_0b.asm

Bank pair `$0A/$0B` (`$A000-$DFFF`) implements the **Strategy Mode AI**: the
per-country turn engine that expands territory, manages officers and
resources, and posts its results back to the map screen through the `$6F8B`
strategy-layer request mailbox. Naming follows
`docs/manual_kb/terminology.md` (Country / Province / Officer / Strategy /
Intrigue). All decisions below are verified against the ROM bytes.

Related documents — the four AI layers of the nested mode hierarchy
(Strategy > Tactical > Battle > Duel):

- `code/tactical_ai_decision_tree.md` — the **war/tactical** AI decision tree
  (`AiTurnProcess`, prg_08_09); this file covers the strategy-layer AI.
- `code/battle_ai_decision_tree.md` — the **Battle Mode** side director
  (prg_0e_0f).
- `code/duel_ai_decision_tree.md` — the **one-on-one duel** AI (prg_17_18).
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
    CYC -->|"0 - first cycle"| IWA["InitWorkAreas $A043<br/>seed AI weights $6F5F-$6F61<br/>base + tier adj - see section 5"]
    CYC -->|"1"| WD
    CYC -->|">= 2"| X
    IWA --> WD
    WD{"AiActionChoose $A19C<br/>random over weights<br/>A = $6F5F, B = $6F60, C = $6F61"}
    WD -->|"weight A"| CEC["AiAction_ExpandProvinces $A1C5<br/>expansion / absorption path"]
    WD -->|"weight B"| ATD["AiAction_DomesticTurn $B49C<br/>domestic turn actions - see section 3"]
    WD -->|"weight C"| ET["AiAction_LoopTramp $A23D<br/>jump straight to the AI action loop<br/>@AiAction_Loop - see section 4"]

    CEC -->|"posts $6F8B"| MB["$6F8B mailbox:<br/>$FE = battle pending<br/>$FD = fully absorbed"]
    ATD -.-> MB
```

`$6F5B` (`sram_counter`) is incremented once per `InitWorkAreas` pass, so the
AI does one weight-seeding cycle, one weighted-action cycle, then idles until
the map screen calls again.

---

## 2. AiAction_ExpandProvinces — expansion / conquest step

```mermaid
flowchart TD
    CEC["AiAction_ExpandProvinces $A1C5"] --> LVL{"$6F02 game level"}
    LVL -->|"0/1"| R20{"random 100 < 20?"}
    LVL -->|"2"| R30{"random 100 < 30?"}
    R20 -->|"yes"| EPA
    R30 -->|"yes"| EPA
    R20 -->|"no"| RDY{"readiness check"}
    R30 -->|"no"| RDY
    RDY -->|"L0: year $6F00 >= $5A<br/>L1: year >= $5A OR month $6F01 >= 6<br/>L2: always"| READY["expansion ready"]
    RDY -->|"not ready"| ET2["AiAction_LoopTramp $A23D"]
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

## 3. AiAction_DomesticTurn — domestic turn decision tree

`AiAction_DomesticTurn` ($B49C-$C50D, `.endproc` must sit immediately before
`Proc_C50E`) is one `.proc` with ~30 nested `@`-labels. The full workflow is
documented in the proc header; the decision tree:

```mermaid
flowchart TD
    A0["entry $B49C"] --> R1{"random AND $7F >= 50?"}
    R1 -->|"yes"| A0
    R1 -->|"no"| R2{"random < 10?"}
    R2 -->|"yes"| SEL
    R2 -->|"no 10-49"| SRCH["Officer Transfer Search<br/>@ScanInteriorProvinces / @ScanFrontierProvinces<br/>@FindTransferCandidate $B53E<br/>strongest officer to weakest connected target"]
    SRCH --> DEV

    subgraph SEL["@AiIntrigueSelect $B5FC — AI intrigue decision tree"]
        S1{"random AND $7F"} -->|"0-29"| DIS["@AiAction_SowDiscord $BBB2<br/>離間 Discord: lower a rival<br/>officer's loyalty (no move)"]
        S1 -->|"30-59"| POACH["@AiAction_PoachOfficer $B98B<br/>引き抜き Poaching: recruit a rival<br/>officer into an own province"]
        S1 -->|"60-89"| SWP["@AiAction_ProposeAlliance $B619<br/>alliance proposal with tribute gift<br/>(gold/rice to strongest bordering country;<br/>at-war targets accept silently, others via<br/>mailbox $F8 Yes/No; sets alliance nibbles)"]
    end

    DIS --> DEV
    POACH --> DEV
    SWP --> DEV

    DEV["@AiDev_Main $BD7A<br/>officer development loop:<br/>train best candidate, ability = $03E8"] --> LOOP

    LOOP["@AiAction_Loop $BEC7 - shared cycle point<br/>every completed action JMPs back here;<br/>also the AiActionChoose weight C target"] --> ADV

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
    TR --> LOOP
    SU --> LOOP
    MO --> LOOP
    SB --> LOOP
    CB --> LOOP

    subgraph CONT["@AiAction_ContinueTurn $C1E0 - the actions of the loop"]
        CLR["clear processed markers $6F73-$6F82 = $FF"] --> C1{"random 100"}
        C1 -->|"0-29 - 30%"| LWL["@FindWeakestLoyaltyOfficer $C248<br/>lowest Loyalty field $03<br/>skips 100 and processed slots"]
        C1 -->|"30-99 - 70%"| MOL["@AiAction_TrainIntelligence $C298<br/>lowest Intelligence field $02<br/>via @FindLowestAttributeOfficer $C2EB"]
        LWL --> L70{"loyalty 70 or more?"}
        L70 -->|"yes - next weakest"| LWL
        L70 -->|"no"| LG["pay 20 + random(10) gold<br/>Loyalty += random(5)<br/>+ @LevelTrainingBonus level"]
        MOL --> I50{"intelligence 50-79?"}
        I50 -->|"outside - next candidate"| MOL
        I50 -->|"in range"| IG["pay 20 + random(10) gold<br/>Intelligence += random(5)<br/>+ @LevelTrainingBonus level"]
        LG --> BUD
        IG --> BUD
        BUD["spend 5 action budget points $6F5D<br/>zero or underflow = budget over"]
        LWL -.->|"no candidate"| EVAL
        MOL -.->|"no candidate"| LOOP
    end
    BUD --> LOOP

    EVAL["@AiAction_EvaluateAndExecute $C337<br/>bank 1F strategic evaluation loop:<br/>@FindBestActionField - @DeductActionCost<br/>- write result - re-evaluate"] --> GRP{"$003A bitfields"}
    GRP -->|"low 5 bits"| SM["strategy / military actions<br/>cost tables $C3BF / $C3CF"]
    GRP -->|"upper 3 bits"| INTR["intrigue actions<br/>cost tables $C3DF / $C3EF"]
    SM -->|"cost underflow"| LOOP
    INTR -->|"cost underflow"| LOOP
    SM --> EVLOOP["loop until done"]
    INTR --> EVLOOP
```

Per-player aggression thresholds (`@AiDev_ActionThreshold`, random-80):
P0 `$14` (25% extra action), P1 `$32` (63%), P2 `$28` (50%), P3 `$1E` (38%),
P4 `$28` (50%), P5 `$3C` (75%), P6 `$32` (63%).

---

## 4. AiAction_Loop — the shared action loop

`@AiAction_Loop` ($BEC7, inside `.proc AiAction_DomesticTurn`) is the cycle
point of the whole strategy AI turn. It is reached from three directions:

- `AiActionChoose` weight C, via the `AiAction_LoopTramp` $A23D trampoline
  (do nothing proactive this cycle);
- `AiAction_ExpandProvinces` when the readiness gate fails;
- every completed domestic action (`@AiDev_Main` exit,
  `@AiAction_LandReclamation`, `@AiAction_IndustryDevelopment`,
  `@AiAction_TownDevelopment`, `@AiAction_DisasterPrevention`,
  `@AiAction_GovernanceBoost`, `@AiAction_ContinueTurn` actions,
  `@AiAction_EvaluateAndExecute`).

Each pass:

1. `JSR @AiTurn_AdvancePhase` ($BEE6): increments the per-player action
   counter `$6F83,X`; every 30 actions advances the global phase `$6F62`;
   when the phase reaches 3 the game state transitions via `$D140` — that,
   not this label, is where the AI turn actually ends. Otherwise the counter
   resets and the province cursor `$6F5E` advances to the next province
   owned by the current player.
2. Rolls random(80) against the per-player threshold
   `@AiDev_ActionThreshold` ($BEDF): below → `@RollAction` ($BF16)
   development actions; at/above → `@AiAction_ContinueTurn` ($C1E0), the
   officer actions of the loop (decoded below). Each completed
   action JMPs back here, so steps 5-8 of section 3 repeat until the
   phase counter ends the turn.

### 4.1 `@AiAction_ContinueTurn` — the officer actions of the loop

Each pass first clears the per-slot processed-marker work area
`$6F73-$6F82` to `$FF`, then random(100) picks one of two officer actions.
Both find their target officer by scanning province officer slots `$11-$1A`
(skip empty, skip slots already marked processed in `$6F73+slot`), and the
finder marks each pick processed so a retry picks the next candidate:

- **30% Loyalty boost** (`@BranchRandom` → `@FindWeakestLoyaltyOfficer`
  $C248): picks the lowest loyalty (officer field[$03], skips 100). Officers
  at 70+ are not trained — the retry loop re-scans for the next-weakest.
  Pays **20 + random(10) gold** from the province record ($02/$03,
  `DeductRecordStat2`; insufficient gold → back to the loop without
  spending budget), then adds **random(5) + `@LevelTrainingBonus`[level]**
  ($03/$05/$07) to loyalty. No candidate at all → falls through to
  `@AiAction_EvaluateAndExecute` ($C337).
- **70% Intelligence training** (`@AiAction_TrainIntelligence` $C298 via
  `@FindLowestAttributeOfficer` $C2EB): only officers with intelligence
  (field[$02]) in **[50, 80)** are trained; otherwise retry with the
  next-lowest candidate. Same gold cost and gain formula, applied to
  intelligence. No candidate → straight back to `@AiAction_Loop` (no
  strategic-eval fallback).

An executed action (either path) spends **5 action-budget points** from
`$6F5D` (`DeductCounter_ZeroEnd`): when the budget hits zero or underflows,
the AI turn ends through the game-over exit at `$D140`. (The officer
training in `@AiDev_Main` spends 2 points per officer the same way.)

---

## 5. AI action weights `$6F5F-$6F61` — how they are determined

Seeded once per weight-seeding cycle by `InitWorkAreas` ($A043):

```
weight = AiWeightExpandBase[level*8 + player_id] + AiWeightExpandTierAdj[level*4 + tier]   -> $6F5F
weight = AiWeightDomesticBase[level*8 + player_id] + AiWeightDomesticTierAdj[level*4 + tier] -> $6F60
weight = AiWeightLoopBase[level*8 + player_id] + AiWeightLoopTierAdj[level*4 + tier]       -> $6F61
```

The roles match the `AiActionChoose` entries: weight A →
`AiAction_ExpandProvinces`, weight B → `AiAction_DomesticTurn`, weight C →
`@AiAction_Loop` (verified against the `random(sum)` compare chain).

- Base tables at $A133/$A14B/$A163, 24 bytes each = 3 levels x 8 player
  slots; player slot 7 is unused (`$00` padding).
- Tier adjustment tables at $A17B/$A186/$A191, 11 bytes = 3 levels x 4 tier
  slots; the tier-3 slot of each level is unused (`$00` padding).

The tier is computed by `AiCountExpansionRoom` ($A0D3; renamed from
`ScanMatchData`) from the bank-switched province adjacency table `$9D72`
(8 neighbors per province, `$FF`-terminated):

- `$0037` = **own/empty border edges**: adjacency entries whose neighbor
  province is unowned (owner 7) or owned by the current player (`$6F03`).
- `$0038` = **expansion-capable provinces**: provinces with at least one
  such edge that also hold fewer than 4 officers (`CountRecordSlots < 4`),
  counted once per province (the scan then breaks to the next province).

`InitWorkAreas` computes the expansion-opportunity ratio
`100 * $0038 / $0037` (`Multiply32` by 100, `Divide16`) and buckets it:
`< 31` → tier 0, `< 71` → tier 1, else tier 2. A country whose borders are
mostly its own or empty while its provinces still have officer room lands
in a high tier (expansion-favoring adjustments), and vice versa.

Example (level 0, player 0, tier 0): expand `$0D+$02 = $0F`, domestic
`$03+$02 = $05`, loop `$04+$02 = $06` → about 58% expand / 19% domestic /
24% straight to the loop.

---

## 6. File structure

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
        A1["CheckGameStart / InitWorkAreas / AiCountExpansionRoom<br/>AiActionChoose / AiAction_ExpandProvinces<br/>AiAction_DomesticTurn $B49C-$C50D<br/>FindBestOfficerAssign / ProcessAllOfficers<br/>CalcActionProb / OfficerSearchAndEvaluate<br/>FindBestOfficerByCategory / ApplyScenarioDeductions"]
    end
    subgraph ABS["Conquest pipeline $A79C-$B49B"]
        direction TB
        B1["ResolveCountryAbsorb<br/>InitNewGameContext $A8D7-$B10D<br/>EvalProvinceAbsorption / AbsorbPreview<br/>TransferProvinceValues / AbsorbUpdateRecord<br/>FallbackMergeProvinces"]
    end
    subgraph DOM["Record / domain helpers $CF3F-$D335"]
        direction TB
        C1["ArmyValueCalc / DataRecordLookup / DistanceClamp<br/>CalcOfficersPerProvince / CalcOfficersPerProvinceDup<br/>CountCountryProvinces / GetProvinceOwner $D105<br/>DeductCounterMultiEntry / CollectEnemyBorderProvinces X<br/>FindCountryProvinceOfOfficer / GetOfficerRecordField<br/>CountRecordSlots / GetCountryRecordPtr<br/>DeductRecordStat2/4 / CompactRecordSlots"]
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
| AI engine | `CheckGameStart` $A00F, `InitWorkAreas` $A043, `AiCountExpansionRoom` $A0D3, `AiActionChoose` $A19C, `AiAction_ExpandProvinces` $A1C5, `AiAction_LoopTramp` $A23D, `FindBestEnemyProvince` $A240, `FindAbsorptionSource` $A303, `DispatchOfficerArmies` $A45C, `ArmyDispatch` $A481, `AiAction_DomesticTurn` $B49C, `FindBestOfficerAssign` $C50E, `ProcessAllOfficers` $C5B9, `CalcActionProb` $C66F, `OfficerSearchAndEvaluate` $C79A, `FindBestOfficerByCategory` $C98F, `ApplyScenarioDeductions` $CD68, `BracketDeductArmy` $CEDD |
| Conquest | `ResolveCountryAbsorb` $A79C, `InitNewGameContext` $A8D7, `EvalProvinceAbsorption` $B10E, `AbsorbPreview` $B1F9, `TransferProvinceValues` $B1FD, `AbsorbUpdateRecord` $B287, `FallbackMergeProvinces` $B357 |
| Tier / render | `LevelTierDispatch` $A6BC, `CalcArmyTierAndRender` $A6C9, `CalcTierWorkPtr` $A74A, `TileRender` $A55C, `NameTable` $A60C |
| Record helpers | `ArmyValueCalc` $CF3F, `DataRecordLookup` $CF7C, `DistanceClamp` $D00C, `CalcOfficersPerProvince` $D03A, `CalcOfficersPerProvinceDup` $D05D, `CountCountryProvinces` $D080, `CountDefendedBorderProvinces` $D0AA, `GetProvinceOwner` $D105, `DeductCounterMultiEntry` $D12D, `CollectEnemyBorderProvinces` $D1A4, `CollectEnemyBorderProvincesX` $D1F4, `FindCountryProvinceOfOfficer` $D249, `GetOfficerRecordField` $D283, `ReadBankedRecordField` $D2D3, `CountRecordSlots` $D304, `GetCountryRecordPtr` $D319, `DeductRecordStat2` $D36F, `DeductRecordStat4` $D3A9, `CompactRecordSlots` $D3DD |
| Math / geometry | `Divide24` $D336, `Divide16` $D40F, `Multiply32` $D438, `Multiply8x8` $D471, `JumpDispatcher` $D494, `RandomBelow` $D4AD, `BuildAdjacencyBitmap` $D4CB, `MergeAdjacencyBits` $D53E, `CheckPathExists` $D583 |
| Debug / validation | `DebugStub_E7` $D5E7, `ValidateRecordStats` $D5E8, `DebugStub_1E` $D61E, `ValidateRecordStatsAlt` $D61F, `ClampRecordStatPairs` $D655, `ValidateRecordGold` $D688, `ClampRecordStatPairsAlt` $D69D, `DebugStub_E5` $D6E5, `ValidateProvinceSlots` $D6E6 |
| Display / overlay | `SubStateDispatch` $D717, `CallStrategyModeDisplay` $D72A, `StackFill` $D732, `FillStackLoop` $D73C, `ActionResultDisplay` $D74C, `StateWait64Frames` $D799, `StateScrollDown` $D7BD, `StateSpriteAnim` $D7EC, `StateSetupParams` $D83B, `StatePaletteUpdate` $D856, `StateSetupMenu` $D890, `StateTileScroll` $D8AD, `StateWriteText` $D8D9, `StateWaitInput` $D8F8, `SkipToTileScroll` $D90D, `RenderOverlay` $D99C, `OverlayInit` $D9A8, `OverlayFillRows` $D9D0, `OverlayCommit` $DA1B, `ClearOverlay` $DA7E, `ClearOverlayInit` $DA95, `ClearOverlayMenu` $DAA6, `ClearOverlayWait` $DAFD, `ClearOverlayCopyText` $DB2B, `ClearOverlayConfirm` $DB7B, `ClearOverlayExit` $DBC1, `ClearOverlayCancel` $DBF1, `ScrollUpdate` $DCC8, `ScrollDigitWriter` $DD0F, `DrawSelectionSprites` $DD34, `WriteSingleSprite` $DD53, `MenuInputHandler` $DD79, `SpriteSetup2` $DEAF, `PaletteCheck` $DF4C |
| SRAM | `VerifySramChecksum` $DC2F, `CopySramToWork` $DC97 |

---

## 7. `$6Fxx` SRAM cells used by this bank

Review result (cross-checked against `code/cpu_ram_map.md`):

| Cell | Equate / meaning in prg_0a_0b | Notes |
|------|-------------------------------|-------|
| `$6F00` | `sram_game_year` — calendar year − 100 | Seeded `$59` (year 189) at new game (prg_1d_1e `$DE59`); expansion gate `>= $5A`; demo year tick reuse |
| `$6F01` | `sram_game_month` — calendar month − 1 | Troop reinforcement in April–August (raw 3–7); level-1 expansion gate `>= 6` (July+); demo rotation step reuse |
| `$6F02` | `sram_game_level` — difficulty 0-2 | Indexes AiWeight*Base/AiWeight*TierAdj, LevelTierDispatch, LevelActionModifiers |
| `$6F03` | `sram_current_country` — acting country slot | Owner comparisons, `@AiDev_ActionThreshold` index (`& 7`), `@ScanBorderingCountries` |
| `$6F07-$6F3E` | Country records, 7 × 8 B (stride 8) | Read via `GetCountryRecordPtr`/`B1F_GetCountryDataPtr`; status byte +3 gates the final absorption path |
| `$6F43` | latched result parameter | `ClearOverlayMenu` `$DAF4` |
| `$6F44` | display param for AI action notices | `$B783` recipient status byte for the alliance-gift confirm (`@AiAction_ProposeAlliance`), `$BD04` absorbed-officer flag |
| `$6F5B` | `sram_counter` — AI turn-cycle counter | Dispatch selector in `CheckGameStart` |
| `$6F5D` | `sram_action_budget` — AI action-point budget | Spent via `DeductCounter_ZeroEnd`: 5 per ContinueTurn/development action, 2 per `@AiDev_Main` officer training; zero/underflow ends the AI turn via `$D140` |
| `$6F5E` | AI province cursor | Reset by `@AiTurn_AdvancePhase`, read by every action handler |
| `$6F5F-$6F61` | AI action weights A/B/C (`sram_ai_weight_a/b/c` proc-local) | Seeded by `InitWorkAreas` (base + tier adj, see section 5), consumed by `AiActionChoose` |
| `$6F62` | AI global phase | Advances every 30 actions; wraps at 3 with a game-state transition through `$D140`. The `$6F62,Y` accesses in the ContinueTurn officer finders index Y = `$11-$1A` and actually address `$6F73-$6F7C` (processed-slot markers) |
| `$6F73-$6F78` | per-owner "has provinces" marks; army-pool accumulators in `InitNewGameContext` | Dual use, documented in cpu_ram_map.md |
| `$6F8B` | `sram_game_start_flag` — strategy-layer mailbox | AI action requests `$F8` alliance-gift confirm, `$F9` absorb-sweep notice, `$FA` province-sweep notice, `$FB`/`$FC` officer notices; plus `$FE` battle pending, `$FD` fully absorbed, `$FF` turn complete, `$01` consumed |
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
9. Doc renamed from `code/prg_0a_0b_ai_architecture.md` to
   `code/strategy_ai_decision_tree.md` so all four AI-layer documents share the
   `*_ai_decision_tree.md` naming; the stale companion link
   `code/ai_decision_tree.md` (renamed earlier to
   `code/tactical_ai_decision_tree.md`) was corrected and the battle/duel
   siblings added to the related-documents list.

Verification: standalone `ca65` on this file produces the identical
pre-existing error set (48 duplicate-symbol errors, line numbers shifted
only); all edits are comments, equate definitions, or equal-valued equate
substitutions, so assembled bytes are unchanged.
