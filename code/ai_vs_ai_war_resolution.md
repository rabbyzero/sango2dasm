# AI vs AI War Resolution — Decision Tree (prg_0a_0b_strategy_ai conquest pipeline)

Companion to the four AI decision-tree docs (`strategy_ai_decision_tree.md`,
`tactical_ai_decision_tree.md`, `battle_ai_decision_tree.md`,
`duel_ai_decision_tree.md`). This document answers a narrower question:
**when two computer countries go to war, where is the code, and why does the
game never show Tactical / Battle / Duel mode?**

Short answer: an AI-initiated war against an AI-owned province never enters
the banks $08+$09 tactical war machine. It is resolved instantly inside the
Strategy Mode AI turn (banks $0A+$0B, `prg_0a_0b_strategy_ai.asm`) as a **province
conquest**: the target province's roster and stocks are seized, the war
against its owning country is staged, and the owning country's **control byte
`record[$03]`** decides the outcome — `$03` (computer) → `$6F8B = $FD`
*conquest settles instantly, skip the war scene*; anything else (human pad
0–2) → `$6F8B = $FE` *war pending*, the only way the AI conquest pipeline can
launch a real tactical war (the player defending). The branch lives in
`ResolveProvinceConquest` ($A8B7–$A8BD; the `$6F8B` stores are at $A8C3 and
$A8D3). Country destruction and ruler succession are NOT done here — they
happen later in the conquest-continue pass (`SettleStagedOfficers` →
`ProcessRulerSuccession`).

## The control byte (country record[3]) — why "3 = computer", not "at war"

Several legacy comments read `record[3] == $03` as "at war"; the byte-level
evidence says it is the ruler control mode (`0–2` = human pad, `3` =
computer):

| Site | Evidence |
|---|---|
| prg_0c_0d_tactical_commands $A418–$A42F | Loads both countries' record[3] into $0562/$0563 — the Battle Mode per-side control mode; `== 3` gates `AiBattleOrderAssign` and the rout checks inside `NextActorAiSideRefresh` (prg_0e_0f $D067), while human sides get orders from the phase-3 UI (byte-verified in `battle_ai_decision_tree.md`) |
| prg_0a_0b_strategy_ai $B754–$B762 | Alliance gift: recipient with [3]==$03 accepts **silently**; otherwise the Yes/No prompt is posted through mailbox $F8 — only a human needs a prompt |
| prg_0a_0b_strategy_ai $BB05 | Existing comment literally: "Check if new officer is AI-controlled" before the [3]==$03 test |
| prg_0a_0b_strategy_ai $BBF4–$BBFA | SowDiscord target scan skips [3]==$03 countries (scheming only pays off against humans) |
| prg_19_1a_event_scenes $CDDD–$CE1E | Debug hook (armed by ROM-space byte $FFF9, inert in the shipped ROM) backs up and rewrites all seven control bytes $6F0A…$6F3A (stride 8) |
| prg_08_09_tactical_war $D97A–$D98B | Caveat: the new-game CountrySelect entry list reuses the *same* 8-byte record area; there byte 3 is the entry status, not a control mode — `CountrySelectEntryInit` writes $03, phase 2 clears it to $00 for the picked entry, and phase 4 sets $01 once consumed. Do not confuse that reuse with the control byte. |

## Entry points (all prg_0a_0b_strategy_ai unless noted)

| Address | Procedure | Role in the AI-vs-AI war |
|---|---|---|
| $A00F | `StrategyAiTurnDispatch` | State-2 per-frame driver; $6F5B cycle: 0 = seed weights, 1 = act |
| $A043 | `InitWorkAreas` | Seeds expand/domestic/loop weights $6F5F–$6F61 (base[level*8+country] + expansion-room tier adj) |
| $A19C | `AiActionChoose` | Weighted dice → entry 0 = `AiAction_ExpandProvinces` (the war action) |
| $A1C5 | `AiAction_ExpandProvinces` | Readiness gates + target selection sequence |
| $A240 | `FindBestEnemyProvince` | Picks the weakest adjacent enemy province |
| $A303 | `FindAbsorptionSource` / `CompareValues` $A3D6 | Reinforces the launch province with the best officer |
| $A45C | `DispatchOfficerArmies` / `ArmyDispatch` $A481 | Muster bookkeeping per officer (1000-troop cap vs province pool) |
| $A6BC/$A6C9 | `LevelTierDispatch` / `CalcArmyTierAndCosts` | Attack roll: how many officers commit + expedition cost |
| $A74A | `CalcExpeditionCosts` | cost = committed × (120 rice, 100 gold ± noise) |
| $A55C / $A60C | `CoverGoldShortfall` / `CoverRiceShortfall` (solvency top-up helpers, formerly TileRender / NameTable) | Skim 100 from the poorest own province into the launch province; the caller retries until covered |
| $A79C | `ResolveProvinceConquest` | Executes the province conquest + **the AI-vs-AI / vs-human branch** |
| $ACD5 | `SumWarSideStrengths` | Post-conquest settlement math |
| $A8D7 | `SettleStagedOfficers` | Staged-column settlement (mailbox $01): attrition, casualties, war exp, placement, supply, succession |
| prg_19_1a_event_scenes $C7E0 | `RequestPoll` (frame-9 AI-turn panel) | Consumes $FD/$FE: war-report menus vs deployment launch |

## Key RAM

| RAM | Meaning |
|---|---|
| `$6F03` | `sram_current_country` — acting (attacking) country id |
| `$6F02` | game level (0–2); drives every threshold table below |
| `$0037` | garrison threshold → repurposed as committed-officer count `m` |
| `$0038` | target (enemy) province id |
| `$003A` | launch (own) province id |
| `$003B/$003C` | riceCost = 120·m |
| `$003D/$003E` | goldCost = 100·m ± random(0..99) |
| `$066E…` | attacker column (top-m officers), consumed by the settlement |
| `$0664…` | defender column (captured roster), consumed by the settlement |
| `$0522/$0523` | war rice pool (seized defender rice) |
| `$0526/$0527` | war gold pool (seized defender gold) |
| `$0524/$0525`, `$0528/$0529` | staged cost copies (rice/gold) |
| `$0507` | war faction pair = actingCountry<<4 \| targetOwner |
| `$050E` | `war_province_idx` = target province |
| `$0402` | launch province (post-war bookkeeping) |
| `$6F8B` | `sram_request_mailbox` mailbox: $FD / $FE / $01 / $FF |
| `$6F8D` | conquest severity set by `SumWarSideStrengths` (`30 - abs(share/2 - 25)`); scales the `4×$6F8D/10` supply consumption and the `ApplyScenarioDeductions` bracket |
| `$6F73-$6F76` | war loss pools (defender $6F73/$74, attacker $6F75/$76): troop losses + 120×own casualties; paid across as war experience |
| `$6F77/$6F78` | casualty counts (defender/attacker column) |
| `$6F8C` | conquest outcome: 0 = attacker took the province, 1 = defender held |

## Decision tree 1 — will this AI start a war at all?

```mermaid
flowchart TD
    SAD["StrategyAiTurnDispatch $A00F<br/>(game state 2, acting country $6F03)"] --> CYC{"$6F5B cycle"}
    CYC -- "0" --> W["InitWorkAreas $A043<br/>weights $6F5F-61 = base[level,country]<br/>+ expansion-room tier adj"]
    CYC -- "1" --> AC
    CYC -- ">= 2" --> IDLE["RTS - idle this frame"]
    W --> AC["AiActionChoose $A19C<br/>roll random(weightA+B+C)"]
    AC -- "roll < weightA" --> EXP["AiAction_ExpandProvinces $A1C5"]
    AC -- "roll < weightA+B" --> DOM["AiAction_DomesticTurn $B49C"]
    AC -- "else" --> LOOP["idle action loop $BEC7"]
    EXP --> GATE{"game level"}
    GATE -- "L0/L1: 20%<br/>L2: 30%" --> IR["EvalProvinceAbsorption $B10E<br/>internal recombination, NOT war"]
    GATE -- "L0: year >= 190<br/>L1: year >= 190 or Jul+<br/>L2: always" --> TGT
```

## Decision tree 2 — target and muster

```mermaid
flowchart TD
    TGT["FindBestEnemyProvince $A240<br/>scan 30 provinces x 8 adjacency entries $9D72"] --> OWN{"neighbour owned?"}
    OWN -- "owner $07 or self" --> NEXT["next entry"]
    OWN -- "foreign" --> NIB{"acting country's alliance<br/>nibble for that owner == 0?"}
    NIB -- "no" --> NEXT
    NIB -- "yes" --> BEST{"fewest stationed<br/>officers so far?"}
    BEST -- "yes (same-target tie:<br/>more-officer launch wins)" --> KEEP["target = $0038<br/>launch = $003A"]
    BEST -- "no" --> NEXT
    KEEP --> THR["threshold = min(target garrison + 3, 10)<br/>stored in $0037"]
    THR --> THIN{"launch province has<br/>>= threshold officers?"}
    THIN -- "no" --> FAS["FindAbsorptionSource $A303<br/>pull best officer in from<br/>another own province"]
    THIN -- "yes" --> MUSTER
    FAS --> MUSTER["DispatchOfficerArmies $A45C<br/>ArmyDispatch $A481 per officer:<br/>troops vs 1000 cap, province pool $0C/$0D"]
```

## Decision tree 3 — attack tier, cost, solvency

```mermaid
flowchart TD
    TIER["CalcArmyTierAndCosts $A6C9<br/>N = officers in launch province"] --> ROLL{"r = random(100)<br/>threshold row by level<br/>L0: 30/60/90, L1: 20/50/80, L2: 10/40/70"}
    ROLL -- "r < T0" --> K4["tier k = 4"]
    ROLL -- "r < T1" --> K3["tier k = 3"]
    ROLL -- "r < T2" --> K2["tier k = 2"]
    ROLL -- "else" --> K1["tier k = 1"]
    K4 --> M["m = max(1, N - k)<br/>harder levels commit more"]
    K3 --> M
    K2 --> M
    K1 --> M
    M --> COST["CalcExpeditionCosts $A74A<br/>riceCost = 120*m -> $003B/C<br/>goldCost = 100*m +/- random(100) -> $003D/E"]
    COST --> GOLDSolv{"launch province gold $02/$03<br/>>= goldCost?"}
    GOLDSolv -- "no" --> CG["CoverGoldShortfall $A55C<br/>skim 100 from poorest own province<br/>(floor 100), 2 budget; none -> ABORT"]
    CG --> GOLDSolv
    GOLDSolv -- "yes" --> RICESolv{"launch province rice $04/$05<br/>>= riceCost?"}
    RICESolv -- "no" --> CR["CoverRiceShortfall $A60C<br/>same skim on rice pair"]
    CR --> RICESolv
    RICESolv -- "yes" --> CONQ
```

## Decision tree 4 — `ResolveProvinceConquest` $A79C (the conquest, one frame)

```mermaid
flowchart TD
    CONQ["ResolveProvinceConquest $A79C<br/>inputs: launch $003A, target $0038, m in $0037"] --> PAY["1. pay: launch gold $02/$03 -= goldCost<br/>launch rice $04/$05 -= riceCost<br/>(no underflow guard - may wrap)"]
    PAY --> CLR["2. staging $0600-$0678 = $FF"]
    CLR --> PICK["3. attacker pick loop, up to m rounds:<br/>each round scans slots $11-$1A"]
    PICK --> SCAN{"slot empty?"}
    SCAN -- "yes: skip this slot" --> NEXT1["next slot"]
    SCAN -- "no" --> LOY{"officer record[3] == 100?"}
    LOY -- "yes: DEAD BRANCH<br/>BEQ @UpdateBest = empty label,<br/>candidate silently skipped" --> NEXT1
    LOY -- "no" --> SCORE{"score = might/2 + loyalty<br/>(record[1]/2 + record[3])<br/>best so far?"}
    SCORE -- "yes" --> TRACK["best = slot"]
    SCORE -- "no" --> NEXT1
    TRACK --> NEXT1
    NEXT1 --> MORE{"scanned through $1A?"}
    MORE -- "no" --> SCAN
    MORE -- "yes" --> PICK2{"picked < m?"}
    PICK2 -- "yes" --> PICK
    PICK2 -- "no" --> CMP["CompactRecordSlots on launch province"]
    CMP --> CAP["4. capture: whole target roster $11-$1A<br/>-> defender column $0664, slots emptied"]
    CAP --> SEIZE["5. seize: target gold $02/$03 -> $0526/$0527<br/>target rice $04/$05 -> $0522/$0523<br/>zero the four pairs"]
    SEIZE --> STAGE["6. stage: $0507 = country shl 4 + targetOwner<br/>$050E = target, $0402 = launch,<br/>$0524/25 = riceCost, $0528/29 = goldCost"]
    STAGE --> BR{"owning country<br/>record[$03] == $03 ?"}
    BR -- "yes = COMPUTER<br/>(AI vs AI war)" --> SUM["SumWarSideStrengths $ACD5<br/>2x PLA unwind<br/>$6F8B = $FD conquest settled"]
    BR -- "no = HUMAN defender" --> FE["2x PLA unwind<br/>$6F8D = 0<br/>$6F8B = $FE war pending"]
```

## Decision tree 5 — settlement (`SumWarSideStrengths` $ACD5)

```mermaid
flowchart TD
    SUM["SumWarSideStrengths $ACD5<br/>attacker column $066E, defender column $0664<br/>max 10 officers each"] --> IDX["strength = SUM might/10 + SUM troops/100<br/>+ (first officer's record[7] shr 4)*10<br/>attackStr, defendStr"]
    IDX --> SHARE["share% = attackStr*100 / (attackStr + defendStr)"]
    SHARE --> ADJ["$6F8D = 30 - ABS(share/2 - 25)<br/>distance from a 50% fight;<br/>scales 4x$6F8D/10 supply consumption later"]
    ADJ --> RICE{"seized rice pool $0522/23<br/>covers defender column's<br/>(sumTroops/100 x 4x$6F8D/10)?"}
    RICE -- "no" --> C0["$6F8C = 0<br/>attacker conquered:<br/>full re-place path"]
    RICE -- "yes" --> ROLL{"random(100) >= attackShare%?"}
    ROLL -- "yes" --> C1["$6F8C = 1<br/>province held by defender"]
    ROLL -- "no" --> C0
```

## Decision tree 6 — mailbox playback (prg_19_1a_event_scenes frame-9)

```mermaid
flowchart TD
    RP["RequestPoll $C7E0<br/>under the acting ruler's card panel"] --> DEC{"mailbox $6F8B"}
    DEC -- "$FD" --> ABSD["ReqCountryAbsorbed $C8CF<br/>war-report menu 9 ($04D6=$A2)<br/>SKIP deployment, straight to sub-state 8<br/>ruler-card menus 5/6, WarPhaseHandoff $CB2F"]
    DEC -- "$FE" --> PEND["ReqWarPending $C899<br/>war menu 9 ($04D6=$47)<br/>ArmyDeploySceneTrigger $CA42:<br/>game state 3, $0500 = $0A"]
    ABSD --> ACK["WarPhaseHandoff $CB2F stores $6F8B = $01 at $CB7B<br/>-> SettleStagedOfficers settlement pass:<br/>attrition, casualties, war exp,<br/>PlaceColumnsConquest/Held, supply,<br/>owner flip (conquest), succession"]
    PEND --> TACT["Tactical war machine (states 3/4)<br/>prg_08_09_tactical_war WarSetup $B130 + AiTurnProcess $A02D<br/>player defends; Battle/Duel modes possible"]
```

## The algorithm in detail

### 1. War decision (DT1)

- `AiActionChoose` $A19C rolls a weighted die over $6F5F (expand) / $6F60
  (domestic) / $6F61 (idle). Weights are per `(level, country)` base tables
  ($A133/$A14B/$A163) plus a tier adjustment ($A17B…) from
  `AiCountExpansionRoom` $A0D3: the share (100·few-officer border provinces /
  own-or-empty border edges) → tier 0/1/2 at <31% / <71% / else.
- Inside `AiAction_ExpandProvinces` $A1C5: first a 20% (L0/L1) / 30% (L2)
  chance diverts to `EvalProvinceAbsorption` $B10E — that is internal
  recombination (pull thin border provinces into richer ones), **not** a war.
- Readiness gate $A1E4: level 0 attacks only from year 190, level 1 from
  year 190 **or** July onward, level 2 always.

### 2. Attack roll and cost (DT3)

```
r      = random(100)
T[level] = [30,60,90] L0 | [20,50,80] L1 | [10,40,70] L2   ($A6C0 table)
k      = 4 if r<T0, 3 if r<T1, 2 if r<T2, else 1
m      = max(1, N_officers - k)        ; committed officers — harder levels commit more
riceCost  = 120 * m                    ; $003B/$003C
goldCost  = 100 * m + s·random(100)    ; $003D/$003E, s = ± by B1F_RandomByte2 >= $80
```

### 3. ResolveProvinceConquest $A79C — decode

1. **Pay** ($A79C–$A7C4): launch province gold pair `[$02/$03] -= goldCost`,
   rice pair `[$04/$05] -= riceCost`. No underflow guard — pairs may wrap.
2. **Clear staging** ($A7C6): $0600–$0678 ← $FF.
3. **Attacker pick** ($A7D0–$A829): up to m rounds. Each round scans launch
   slots $11–$1A; an empty slot is **skipped**, not a break — the branch byte
   at $A7EC is `F0 1D`, targeting $A80B (`INC $2B`, the next-slot path); the
   old `@ExtractEntries` label on that branch was a mislabel, and the updated
   source relabels it `@NextEntry`. Per officer the score is
   `might/2 + loyalty` (`record[1]/2 + record[3]`), best tracked in $2C/$2D
   (later slot wins ties). **ROM quirk:** the `record[3] == $64` test branches
   to `@UpdateBest`, which is an *empty label* — the intended
   loyalty-100-auto-best body is missing, so loyalty-100 officers are
   silently skipped from selection. Each pick writes $FF into its slot and
   appends the officer id to the attacker column $066E. Ends with
   `CompactRecordSlots` on the launch province.
4. **Capture** ($A831–$A84C): the target province's whole roster $11–$1A is
   lifted into the defender column $0664, slots emptied.
5. **Seize** ($A84E–$A874): target gold `[$02/$03]` → $0526/$0527, target
   rice `[$04/$05]` → $0522/$0523 (same pool layout as the player sortie,
   prg_19_1a_event_scenes `SortieWarCommit` $B7D9); the four pairs are zeroed.
6. **Stage** ($A876–$A8AB): `$0507 = actingCountry<<4 | targetOwner`,
   `$050E` = target province, `$0402` = launch province, $0524/$25 = riceCost,
   $0528/$29 = goldCost.
7. **Branch** ($A8AE–$A8D6): owning country `record[$03] == $03` →
   `SumWarSideStrengths` + `$6F8B = $FD` (instant settlement); otherwise
   `$6F8B = $FE`, `$6F8D = 0`. Both exits unwind two return frames (2× PLA),
   skipping the remainder of `AiAction_ExpandProvinces`.

### 4. Settlement and aftermath (DT5/DT6)

```
$6F8C (conquest outcome):  seized rice pool $0522/23 cannot cover
                           defender column's (sumTroops/100 * 4*$6F8D/10)
                           -> 0 (attacker took the province)
                           else random(100) >= attackerShare% -> 1 (defender held), else 0
```

`$6F8D` is the conquest-severity byte set by `SumWarSideStrengths`. It scales
the supply consumption (`Σtroops/100 × 4×$6F8D/10`) in `@DeductWarSupplies`
$AC67, and on the conquest path it selects the 10/20/30/40/60% bracket that
`ApplyScenarioDeductions` $CD68 subtracts from the conquered Province's land
value, industry and governance fields, plus a random 10–19% from population
(not officers).
`SettleStagedOfficers` $A8D7 is reached because the frame-9 flow hands the
mailbox to $01 at `WarPhaseHandoff` prg_19_1a_event_scenes $CB2F (store at $CB7B).
`$6F8C` selects the placement path ($00 = conquest: `@PlaceColumnsConquest`
then owner flip at $A906; nonzero/$01 = province held: `@PlaceColumnsHeld`, no
flip). The pass runs in this order: `ApplyScenarioDeductions` (conquest only) →
attrition → casualties → war exp → placement with the loyalty rolls → supply
deduction → owner flip (conquest only) → `ProcessRulerSuccession` $CA19 — the
losing ruler's country is extinguished or succeeded, the war Province having
flipped owner nibble by `AND #$F8 / ORA $6F03` ($A906).

### 5. Officer fates: HP, troop attrition, capture, death

All of this runs in `SettleStagedOfficers` $A8D7 after the $FD/
$01 mailbox ack — before it, the conquest path ($6F8C = 0) also runs
`ApplyScenarioDeductions` $CD68, which applies $6F8D-bracket-scaled
deductions to province resource fields (not officers).

**Officer status byte** — `record[$B]` bits 0-1 (bits 2-3 = army affinity,
bits 4-7 = level). Values: `0` = free/released (在野), destination in
record[5]; `1` = hidden/arrival-scheduled (the roster-fill scan tests it at
$C63B and hires the officer once the calendar reaches the appearance year in
the bank-$31 schedule, writing status 2 at $C655); `2` = garrisoned/rostered
(alive); `3` = dead/out of action. The seed ROM stores status (1 hidden or
2 rostered) in bits 0-1 and army affinity (0/1/2) in bits 2-3; the
assign/recruit paths overwrite the low bits with status 2 ($C655/$C769;
human recruit at prg_1b_1c_strategy_mode $AD23). Death marking in this
settlement is `record[$B] = record[$B] AND #$FC OR $03` ($AA79 casualty,
$CA49 ruler), so the affinity pair survives; other kill paths often only
`ORA #$03` (prg_0c_0d $B60D in the loyalty-collapse stratagem, prg_0c_0d
$C7C2 in the post-battle kill, prg_19_1a $BDCA `OfficerKill`) and leave bits
2-3 as they were.

1. **HP/Vitality is never deducted** in the AI-vs-AI settlement. Vitality
   (`record[0]`, the officer's HP stat) acts as the attrition coefficient:
   **troops' = troops × Vitality / 100** (@ApplyTroopAttrition $A91F, all 20
   war-column officers; 10-bit troop pair, record[9] bits 2-7 flags kept).
   Vitality 100 keeps everything, 50 loses half. The loss goes into the
   side's pool ($6F73/$74 defenders, $6F75/$76 attackers) — later converted
   into war experience, see item 3.
2. **Casualties = death** (@CountColumnsMarkCasualties $A9CC + @FindWeakestSlot $AA2D):
   per side with ≥5 surviving officers, **floor(count/4) of the WEAKEST
   officers die** — minimum might+intellect (`record[1]+record[2]`),
   loyalty-100 (rulers) exempt. They are marked status 3, removed from the
   column (never re-placed), and each contributes a flat 120 to the side's
   troop pool.
3. **War experience + level-ups** (`GrantWarExperience` $AF9C — misnomer, it
   grants experience): each side's loss pool = its troop attrition + 120×its
   own casualties ($6F73/$74 defender, $6F75/$76 attacker). The pools are
   then paid **across**: defender survivors receive the attacker pool
   ($6F75/$76) ÷ the defender count ($003C), attacker survivors receive the
   defender pool ($6F73/$74) ÷ the attacker count ($003D) — both counts are
   the pre-casualty roster counts taken by @CountColumnsMarkCasualties.
   `@DistributeToSlot` $B067 halves the receiving side's share and adds it to
   each survivor's **experience** `record[6/7]` (16-bit, capped at $C34F).
   When experience reaches `DistribLevelThresholds` $B0BC (1000/2000/3500/
   5000/7500/10000/15000) the officer levels up (`record[$B]` bits 4-7, max
   14). The level-up bonus is **Might only**: `record[1] += 6` if Might < 51,
   `+5` if < 71, `+4` if < 81, `+2` if < 90, none at ≥ 90 ($B0E9–$B10B; the
   `Y` values 6/5/4/2 are the gain, not stat offsets). The battle-mode
   level-up at prg_0e_0f_battle $D88B is the same routine.
4. **Supply consumption** (@DeductWarSupplies $AC67): per side,
   consumption = (Σ troops / 100) × (4 × $6F8D) / 10. The seized rice pool
   $0522/23 pays the defender's consumption, the expedition rice budget
   $0524/25 pays the attacker's (both clamped at 0). `BracketDeductGold`
   $CE67 (which operates on $0522/$0523, the rice pool) / `BracketDeductArmy`
   $CEDD (on $0526/$0527, the gold pool) then shave a table-bracket fraction
   (ArmyDeductionTable/ArmyResultTable $CEC9/$CED3) off those pools — their
   header comments mislabel the fields. Remainders are written back into the
   province: rice [$04/$05] = $0522+$0524, gold [$02/$03] = $0526+$0528.
5. **Capture** — there is no POW state. "Captured" means the target
   province's whole roster was lifted into the defender column $0664 by
   `ResolveProvinceConquest`; fate is decided by a loyalty roll at
   re-placement (decision tree 7 below). Note the polarity: **high loyalty →
   returns to its own country** (best = own-country neighbor province with
   the fewest officers, else claims an unowned neighbor province),
   **low loyalty → defects** into the war province (overflow: the other
   side's provinces; last resort: status 0 + record[5] = random adjacent
   province — the officer wanders off with a destination marker).
6. **Ruler death / succession** (`ProcessRulerSuccession` $CA19, per computer
   country; country control byte record[3] must be $03): country `record[0]`
   (the ruler officer id) empty → skip; ruler status `record[$B] & 3 == 2`
   (still garrisoned = alive) → skip (the `@RulerAlreadyDead` label is a
   mislabel); otherwise (killed by casualties, or displaced with status 0/1)
   the ruler is marked status 3 and AppointSuccessor runs: first heir from
   the country's `HeirPriorityList` ($CAD8; country 2's list is
   Cao Pi → Cao Rui → Cao Zhang → Cao Zhi → …, the reigning ruler is not in
   it) found governing one of its provinces, else the best-virtue (record[4])
   officer in its rosters;
   install (country record[0] = heir, heir loyalty = 100, mailbox $FC
   card-swap notice) or no successor → record[0] = $FF + mailbox $FB
   card-removal notice. Post-succession defection pass (@ScoreAndAdjust
   $CBA3): officers with loyalty < 31 get a 20% chance to leave (status 0 +
   record[5] destination), rosters compacted, officer-less provinces become
   unowned (owner $07).

Death in AI-vs-AI wars is therefore pure arithmetic — casualty marking and
(on the human-defender $FE path) `WarClashResolve` HP-to-0. No duel scene,
no execution menu.

## Decision tree 7 — officer fates in the settlement

```mermaid
flowchart TD
    SET["SettleStagedOfficers $A8D7<br/>(after ResolveProvinceConquest posts $FD)"] --> SCEN{"$6F8C == 0?"}
    SCEN -- "yes: conquest" --> ASD["ApplyScenarioDeductions $CD68<br/>random 10-19% from population,<br/>10/20/30/40/60% from land/industry/governance"]
    SCEN -- "no" --> ATTR
    ASD --> ATTR["attrition @ApplyTroopAttrition $A91F<br/>all 20 war-column officers:<br/>troops' = troops x Vitality/100<br/>loss -> side pool $6F73-$6F76"]
    ATTR --> CAS{"side has >= 5 officers?"}
    CAS -- "no" --> RED
    CAS -- "yes" --> WK["casualties = count/4 (floor)<br/>@FindWeakestSlot $AA2D:<br/>weakest might+intellect,<br/>loyalty-100 rulers exempt"]
    WK --> DEAD["DEAD: status = record[B] and FC + 3<br/>removed from column, +120 to pool"]
    DEAD --> RED["war experience @GrantWarExperience $AF9C<br/>side pool = troop losses + 120x own casualties;<br/>pools paid ACROSS: opposing pool / own count / 2<br/>-> experience record[6/7] cap $C34F,<br/>level-up Might +6/+5/+4/+2<br/>(<51/<71/<81/<90; >=90 none)"]
    RED --> OUT{"$6F8C: placement path"}
    OUT -- "0 = attacker took it" --> CONQ["@PlaceColumnsConquest $AA80:<br/>attackers garrison the province"]
    OUT -- "nonzero = defender held" --> HOLD["@PlaceColumnsHeld $AB10:<br/>defender column stays in the province"]
    CONQ --> DEF{"defender roll<br/>random(100) vs loyalty"}
    HOLD --> ATK{"attacker roll<br/>random(100) vs loyalty"}
    DEF -- "r < loyalty: stays loyal" --> HOME1["return to defeated country:<br/>own-country neighbor with fewest officers,<br/>else claim an unowned neighbor"]
    DEF -- "r >= loyalty: defects" --> DEFE["join conquered province garrison<br/>overflow: attacker's provinces;<br/>last resort: status 0 + record[5] dest"]
    ATK -- "r < loyalty: goes home" --> HOME2["return to acting country's provinces"]
    ATK -- "r >= loyalty: defects" --> STAY["stay in the defender's province"]
    HOME1 --> SUP["supply @DeductWarSupplies $AC67<br/>consumption = sumTroops/100 x (4*6F8D)/10<br/>rice pool + budget deducted, bracket shave,<br/>remainder -> province stocks"]
    DEFE --> SUP
    HOME2 --> SUP
    STAY --> SUP
    SUP --> FLIP{"$6F8C == 0?"}
    FLIP -- "yes" --> OWN["province owner nibble := $6F03<br/>(AND #$F8 / ORA, $A906)"]
    FLIP -- "no" --> SUC
    OWN --> SUC["ProcessRulerSuccession $CA19 per computer country:<br/>ruler alive (status 2) -> skip;<br/>dead/displaced -> heir list $CAD8,<br/>else best virtue; install (FC card)<br/>or record[0] = FF + FB card removal"]
```

### 6. Why Battle and Duel modes can never appear

Both modes live downstream of the tactical war scene (state 3
WarSceneLaunch → state 4 WarAiTurnFrame; Battle Mode banks $0E+$0F, Duel Mode
banks $17+$18, launched as state 7). The AI-vs-AI branch never
leaves banks $0A+$0B/$19+$1A: `ResolveProvinceConquest` takes the $FD path,
the deployment trigger is skipped, so no scene that could host Battle/Duel UI
is ever launched. Even inside genuine wars, AI-vs-AI officer clashes are
plain arithmetic — `WarClashResolve` prg_08_09_tactical_war $B933 resolves a pending
strike as
`damage = targetRecord[$B]*10 + targetIntelligence*random(30..40)/10`
(the "level" in the bank's comments is record[2], Intelligence) applied to the
striking officer's HP (clamped ≥ 0), with two ROM quirks: the
`random < 101` roll at $B9E2 is discarded, and the Intelligence-difference
+10 bonus at $B9DD is overwritten before use (dead computation).

## Applied renames (2026-09-21)

All renames are comment-column-preserving; ca65 error-set verified unchanged.

| Old | New | Addr | Why |
|---|---|---|---|
| `TileRender` | `CoverGoldShortfall` | $A55C | not a renderer: skims 100 gold from poorest own province (floor 100) into the launch province |
| `NameTable` | `CoverRiceShortfall` | $A60C | same helper for the rice pair $04/$05 |
| `CalcArmyTierAndRender` | `CalcArmyTierAndCosts` | $A6C9 | rolls tier / committed count / costs; no rendering |
| `CalcTierWorkPtr` | `CalcExpeditionCosts` | $A74A | computes rice 120·m and gold 100·m±rand costs |
| `SumEnemyRecords` | `SumWarSideStrengths` | $ACD5 | sums BOTH sides' strength for the settlement |
| `ResolveCountryAbsorb` | `ResolveProvinceConquest` | $A79C | the target is a Province ($0038); no country is absorbed here — country destruction happens later in SettleStagedOfficers/ProcessRulerSuccession |
| `InitNewGameContext` | `SettleStagedOfficers` | $A8D7 | settles the staged officer columns $0664/$066E (attrition, casualties, war exp, re-placement, supply, succession handoff); initializes no new game — name came from misreading $6F8C == 0 as "new-game setup". Internal misnomers renamed too: `@ClearGameStateVars`→`@ApplyTroopAttrition`, `@CountRecords`→`@CountColumnsMarkCasualties`, `@AdjustGold`→`@GrantWarExperience`, `@SumAllResources`→`@SumColumnTroops`, `@SubtractBattleCosts`→`@DeductWarSupplies`, `@PlaceNewArmies`/`@PlaceNewEnemies`→`@PlaceColumnsConquest`/`@PlaceColumnsHeld` |
| `@RenderLoop` | `@GoldSolvencyLoop` | $A705 | gold solvency retry loop |
| `@SubtractLimitB` | `@RiceSolvencyCheck` | $A727 | rice solvency check |
| `@RenderTileLoop`/`@RenderNameLoop` (TransferProvinceValues) | `@GoldSolvencyLoop`/`@RiceSolvencyLoop` | $B242/$B264 | same top-up retry loops; mislabeled branch refs ($B238, $B256, $B278) corrected to the ROM branch-byte targets, exit `@Exit` $B286 labeled |
| `@DeadTarget` | `@Done` | $A79B | plain RTS exit, not a dead target |

## Correction notes for legacy comments

- "status/byte 3 = at war" comments (prg_08_09_tactical_war $B157 region, prg_0a_0b_strategy_ai
  $B758/$BB09/$BBF8, `WarAttackerSetup`/`WarDefenderSetup` headers) describe
  the **computer-control byte** tested against $03, not a war state. The
  branch documented in DT4 is the decisive evidence together with the
  Battle Mode input-mode load.
- "defender still has forces" as the $FE condition (prg_19_1a_event_scenes legacy
  comments) is wrong: $FE means **human defender** (control byte ≠ $03),
  regardless of remaining forces; $FD means **computer defender**.
- `@SubLimitB` ($B224, delta clamp in `TransferProvinceValues`) is a distinct
  label and stays.

## Verification (2026-10-22)

Re-checked against the current bank sources; each pair assembles byte-exact
to the ROM:

```
python tools/verify_0a_0b_standalone.py   # 16384 bytes, 0 mismatches
python tools/verify_0c_0d.py              # 16384 bytes, 0 mismatches
python tools/verify_08_09.py              # 16384 bytes, 0 mismatches
python tools/verify_19_1a.py              # 16384 bytes, 0 mismatches
```

Corrections made in this pass:

- The attacker-pick scan **skips** an empty roster slot and continues; the
  updated source relabels the $A7EC branch from `@ExtractEntries` to
  `@NextEntry` (byte `F0 1D` targets $A80B = `INC $2B`).
- The `$6F8C` rice gate uses the defender column's troop-derived supply
  consumption (`Σtroops/100 × 4×$6F8D/10`), not `defendStr`; the strength
  formula's `record[7]` term is the first officer of each column, not a sum.
- The settlement order is `ApplyScenarioDeductions` (conquest only) →
  attrition → casualties → war exp → placement with the loyalty rolls →
  supply → owner flip (conquest only) → succession.
- The level-up bonus is `Might += 6/5/4/2` (thresholds 51/71/81/90), not
  +1 on four different stats.
- Officer status `1` is hidden/arrival-scheduled and `0` is free/released.
  Death marking in this settlement preserves bits 2-3 (`AND #$FC / ORA #$03`
  at $AA79/$CA49); the cited prg_0c_0d $B60D site only does `ORA #$03`.
- `WarClashResolve`'s "level" operand is record[2] (Intelligence), not the
  record[$B] level nibble; the damage formula now names the bytes by record
  field.
- prg_08_09 $D97A–$D98B is the new-game CountrySelect entry list, not a
  post-war result-entry store.
