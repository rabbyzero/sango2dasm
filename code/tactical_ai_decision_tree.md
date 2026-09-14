# Battle AI Decision Tree — prg_08_09.asm (`AiTurnProcess`, $A02D–$B12F)

Source: `asm/banks/prg_08_09.asm`, `.proc AiTurnProcess` and its nested helpers.
All decisions below are reconstructed from the byte-exact disassembly.

## Key inputs

| RAM | Meaning |
|-----|---------|
| `sram_game_start_flag` ($6F8B) | Turn state: `$FF` = turn complete/idle, `$01` = phase 1 (→ `WarClashResolve`) |
| `war_side_flag` ($0504) | Acting side (bit7 = AI side acting) |
| `war_action_points` ($0505) | AI action budget (attacking costs 2; stratagems cost 4–$0C) |
| `war_faction_pair` ($0507) | lo = side0 faction, hi = side1 faction |
| `officer_state_table` ($6FA1,Y) | Officer state; **low nibble = AI action type 0–7** |
| `ai_action_result` ($6F8F) | Result code: 0=moved, 1=attack/engage, 2=act on target (stratagem), 3=no action, 4=flee |
| `ai_officer_idx` ($6F8C), `ai_target_slot` ($6F8D), `ai_target_officer` ($6F8E) | Current officer / chosen action code or direction / target officer slot |

## Master decision tree

```mermaid
flowchart TD
    Entry["AiTurnProcess ($A02D)\ncalled via dispatch stub $A000"] --> G1{"sram_game_start_flag\n== $FF?"}
    G1 -- "yes (idle)" --> Exit["RTS"]
    G1 -- no --> G2{"flag == $01\n(phase 1)?"}
    G2 -- "yes" --> Clash["JMP WarClashResolve\n(engagement resolver)"]
    G2 -- no --> Loop["Officer scan loop\nofficer_scan_idx 0..19"]
    Loop --> G3{"state_table[Y] == $FF?\n(slot inactive)"}
    G3 -- yes --> Cont["next officer"]
    G3 -- no --> G4{"AiCheckFaction(Y)\nofficer on acting side?"}
    G4 -- "enemy ($80)" --> Cont
    G4 -- ally --> G5{"war_roster[Y] == $FF?"}
    G5 -- yes --> Cont
    G5 -- no --> Count["INC valid_officer_cnt\nY = ai_officer_idx"]
    Count --> Decide["@AiOfficerActionDecide\n(A = state low nibble 0-7)"]
    Decide --> G6{"ai_action_result == 3\n(no action)?"}
    G6 -- "yes: officer finished" --> IncActed["INC acted_officer_cnt"] --> Cont
    G6 -- "no (0,1,2,4)" --> Done["sram_game_start_flag = $FF\nRTS — action executed by caller"]
    Cont --> G7{"scan_idx < 20?"}
    G7 -- yes --> Loop
    G7 -- no --> G8{"valid_officer_cnt\n== acted_officer_cnt?"}
    G8 -- "yes: all idle" --> Phase3["ai_action_result = 3\nscan_idx = 0"]
    G8 -- no --> Reset["reset scan/acted/valid\ncounters and rescan"] --> Loop
    Phase3 --> Done
```

## Action-type dispatch (`@AiOfficerActionDecide`, $A099)

The officer state's **low nibble** selects one of 8 handlers through the inline
`CallbackDispatcher` table at $A0A1:

| Nibble | Handler | Behavior |
|--------|---------|----------|
| 0 | `Action_DefaultDecision` | Priority chain: flee → advanced stratagem → attack → stratagem vs best enemy → random idle → march |
| 1 | `Action_Regroup` | Rejoin main force / march to capital or ordered destination |
| 2 | `Action_AttackNearest` | Attack nearest enemy within range 2 of self |
| 3 | `Action_DefendBase` | Intercept nearest enemy within range 2 of own capital |
| 4 | `Action_SweepRange3` | Attack nearest enemy within range 3 of self |
| 5 | `Action_BuyRice` | March to ordered province ($9BA4); on arrival **buy rice with gold** (up to 70% of remaining gold) |
| 6 | `Action_RestoreHP` | March to province entry+4, pay 50 gold, heal random 0–10 (cap at base HP) |
| 7 | `Action_Idle` | Result 3 (no action) |

```mermaid
flowchart TD
    D{"officer state\nlow nibble"} -- 0 --> A0["Action_DefaultDecision"]
    D -- 1 --> A1["Action_Regroup"]
    D -- 2 --> A2["Action_AttackNearest"]
    D -- 3 --> A3["Action_DefendBase"]
    D -- 4 --> A4["Action_SweepRange3"]
    D -- 5 --> A5["Action_BuyRice"]
    D -- 6 --> A6["Action_RestoreHP"]
    D -- 7 --> A7["Action_Idle → result 3"]
```

## Action 0: Default decision priority chain ($A0B1)

```mermaid
flowchart TD
    A0["Action_DefaultDecision"] --> Side{"war_side_flag bit7?"}
    Side -- "set (Path1)" --> Flee1{"AiCheckFlee\nC=1?"}
    Side -- "clear (Path2)" --> Flee2{"AiCheckFlee\nC=1?"}
    Flee1 -- "yes" --> Ret1["return (result 4 = flee)"]
    Flee1 -- no --> Rec1{"AiCheckAdvancedStratagem\nC=1?"}
    Flee2 -- "yes" --> Ret1
    Flee2 -- no --> Rec2{"AiCheckAdvancedStratagem\nC=1?"}
    Rec1 -- "yes" --> Ret2["return (result 2 = act on target)"]
    Rec1 -- no --> Atk1{"AiCheckAttackNearby\nC=1? (adjacent enemy,\nbudget ≥ 2)"}
    Rec2 -- "yes" --> Ret2
    Rec2 -- no --> Mv2["JMP AiPickStratagemTarget\n(best enemy → stratagem)"]
    Atk1 -- "yes" --> Ret3["return (result 1 = attack)"]
    Atk1 -- no --> Mv1{"AiPickStratagemTarget\nC=1?"}
    Mv1 -- "yes" --> Ret4["return (result 2)"]
    Mv1 -- no --> Rand{"NextRandomByte AND 3\n== 0? (25%)"}
    Rand -- "yes: idle" --> Idle3["result 3 (no action)"]
    Rand -- no --> March["march to capital city coords\nAiExecuteMove"]
```

## Actions 1–4: common sub-chain and scans

All of `Action_Regroup`, `Action_AttackNearest`, `Action_DefendBase`,
`Action_SweepRange3` first run the same **flee → stratagem → adjacent-attack**
cascade, then diverge:

```mermaid
flowchart TD
    S["flee → advanced stratagem → AiCheckAttackNearby\n(any C=1 → return immediately)"] --> H{"handler"}
    H -- "Regroup (1)" --> RG{"war_action_points < 2?"}
    RG -- "yes" --> RC["march to capital /\nordered destination ($8C52)"]
    RG -- no --> RA["scan $6FDD: main-force slot\n(slot 0 or $0A) adjacent?\n→ result 1 (attack/engage)"]
    RA -- not found --> RC
    H -- "AttackNearest (2)" --> AN["scan proximity $6FC9\nradius 2 from SELF\n→ nearest enemy"]
    AN -- found --> AM["march to enemy coords"]
    AN -- none --> AF["fallback: march to capital /\nordered destination"]
    H -- "DefendBase (3)" --> DB["scan proximity $6FC9\nradius 2 from OWN CAPITAL"]
    DB -- "enemy found" --> DA["ally adjacent? → AiPickStratagemTarget\nelse march to enemy"]
    DB -- none --> DM["AiPickStratagemTarget → fallback\nmarch to capital"]
    H -- "SweepRange3 (4)" --> SW["scan proximity $6FC9\nradius 3 from SELF"]
    SW -- found --> SM["march to enemy coords"]
    SW -- none --> SF["AiPickStratagemTarget → fallback\nmarch to capital"]
```

## Action 5/6: buy rice and heal (arrive → effect)

- **BuyRice ($A329):** march to `$9BA4[$050E*3]` (bank $31). When
  `ai_action_result == 0` (arrived): set state nibble to 7 (done), then
  **buy rice with gold** — verified rice-for-gold transaction:
  `rice_needed = troops * 4 / 1000 * days_remaining` (AiComputeBattleStats,
  i.e. consumption for the rest of the 30-day month); `shortfall =
  rice_needed - remaining_rice` ($0522); `gold_cost = shortfall * 100 /
  ProvinceRiceBuyRate[$050E]` ($8FC0 bank $30 — the same buy-rate table as
  the market, rice per 100 gold: 68, 0, 86, 57, 79, 0, ...); spending is
  capped at `remaining_gold * 7 / 10` ($0526). Affordable → gold -= cost,
  rice += shortfall; otherwise → spend the whole 70% cap (`gold -= cap`,
  `rice += cap * rate / 100`). War resources were verified via war setup
  (prg_0a_0b $A84E: province record +2/+3 gold → $0526, +4/+5 rice → $0522),
  the war-end write-back, and the market states of AiOfficerActionDispatch.
- **RestoreHP ($A507):** march to `$9BA4[$050E*3 + 4]`. When arrived: abort if
  faction gold < 50, else deduct 50 gold, roll `random & $0F` (reroll ≥ $0B →
  0–10), boost HP +$23 offset, clamp to banked base record HP. State nibble → 7.

## `AiCheckFlee` ($AF0D) — retreat decision tree

```mermaid
flowchart TD
    F["AiCheckFlee"] --> Home{"officer id ==\ncountry Ruler id\n(country record byte 0)?"}
    Home -- "yes: ruler path" --> CP["thresholds: troops < $012D (301),\nVitality < $33 (51)"]
    Home -- no --> Slot{"officer slot 0 or $0A\n(side leader unit)?"}
    Slot -- "yes: leader path" --> AP1{"ally army ≥ $06DD?"}
    AP1 -- no --> AP2{"ally army + $0DAB\n≥ enemy army?"}
    AP2 -- "no: badly outnumbered" --> Flee["flee"]
    AP2 -- yes --> AP3["thresholds: troops < $0065 (101),\nVitality < $29 (41)"]
    AP1 -- yes --> AP3
    Slot -- "no: field officer path" --> FP["thresholds: troops < $00C9 (201),\nVitality < $64 (100)"]
    CP --> CS{"@CheckStrength:\ntroops ≥ threshold OR\nVitality ≥ ceiling? (C=1 = stay)"}
    AP3 --> CS
    FP --> CS
    CS -- "too strong or healthy" --> NoFlee["no flee (C=0)"]
    CS -- "weak AND wounded" --> RGate{"field officer path only:\nrandom < $46 (70)?"}
    RGate -- "≥ 70: stay" --> NoFlee
    RGate -- "< 70" --> Flee
    Flee --> Dest{"@FindDest: acting side?"}
    Dest -- "AI side" --> Pre["dest = preset $052A\n(war_target_province)"]
    Dest -- "player side" --> Scan["scan 8 group provinces ($9D72):\nowned by faction AND no garrison\nelse ownerless fallback, else none"]
    Scan -- "none found" --> NoFlee
    Scan -- found --> OK["result 4 (flee),\n$6F8D = destination province"]
    Pre --> OK
```

## `AiCheckAdvancedStratagem` ($AAF8) — caster gates and advanced stratagems ($0A–$0F)

Self gates: officer record **field +2 (rating) ≥ $5C** and **field +11 high
nibble (rank) ≥ 3**. Then candidates = enemies within radius 5, sorted by
troop strength (strongest first). Per candidate, try stratagems $0A–$0F
(ChainLink/TenfoldAmbush/FloodAttack/RepeatingCrossbow/Inferno/MysticalStasis)
in order; each additionally requires `AiCheckStratagemFeasible`:

| Stratagem | Rank gate | Officer-table group | Extra condition | Budget ($0505) |
|--------|-----------|-------------------|-----------------|----------------|
| $0A | ≥ 3 | offset $00 | candidate idle (immobilized low nibble = 0) | ≥ 9 |
| $0B | ≥ 3 | offset $00 | — | ≥ $0A |
| $0C | ≥ 4 | offset $0B | candidate has troops | ≥ $0A |
| $0D | ≥ 4 | offset $0B | candidate has troops | ≥ 8 |
| $0E | ≥ 5 | offset $11 | candidate has troops | ≥ $0C |
| $0F | ≥ 6 | self officer id == $6D | candidate state high nibble clear | ≥ $0A |

Success → result 2, `$6F8D` = stratagem code, `$6F8E` = target officer.
`AiAdvancedStratagemOfficerTable` ($AC65) lists eligible self **officer ids**
per rank group ($FF-terminated); the caster's id (from `war_roster`) must be
listed. Stratagem 8 (Enticement, 籠絡) is NOT part of this routine — it is
requested only by `AiPickStratagem` (tier ≥ 8, budget ≥ $0A).

## `AiPickStratagemTarget` + `AiPickStratagem` ($A95C/$A9CF) — stratagem target + code selection

1. **Rating tier** from record field +2: `< $28`→1, `< $3C`→3, `< $4B`→5,
   `< $55`→7, else 9.
2. Scan enemies within radius 5 (`AiFindNearbyOfficers`), compact and sort by
   troop strength (`AiSortNearbyOfficers`, strongest first).
3. For each candidate, run the feasibility cascade below. The **first candidate**
   with any feasible stratagem wins (result 2); the code is whatever the cascade
   picks — there is no best-stratagem search across candidates.

```mermaid
flowchart TD
    C["AiPickStratagem\ntier T, candidate troops G,\nbudget B"] --> A6{"T≥6 and G≠0\nand B≥8"}
    A6 -- yes --> F6["stratagem 6 CastleRaid"]
    A6 -- no --> A5{"T≥5 and B≥8"}
    A5 -- yes --> F5["stratagem 5 SupplyBurning"]
    A5 -- no --> A8{"T≥8 and B≥$0A"}
    A8 -- yes --> F8["stratagem 8 Enticement"]
    A8 -- no --> A9{"T≥9 and G≠0 and B≥9"}
    A9 -- yes --> F9["stratagem 9 Rockfall"]
    A9 -- no --> A7{"T≥7 and G≠0 and B≥8"}
    A7 -- yes --> F7["stratagem 7 FriendlyFire"]
    A7 -- no --> A1{"AiCheckStratagemFeasible(1)\nPitfallTrap"}
    A1 -- "yes" --> R{"random 1-3\n(0 rerolled)"}
    A1 -- no --> A4
    R -- "1: T≥2, target idle, B≥4" --> F2["stratagem 2 FeintTroops"]
    R -- "2: B≥5" --> F1["stratagem 1 PitfallTrap"]
    R -- "3: G≠0, T≥3, B≥6" --> F3["stratagem 3 AmbushStrike"]
    R -- "gate failed" --> A4
    F2 --> Win
    F1 --> Win
    F3 --> Win
    A4{"T≥4 and G≠0 and B≥7"}
    A4 -- yes --> F4["stratagem 4 BoatSabotage"]
    A4 -- no --> A0{"G≠0 and B≥6"}
    A0 -- yes --> F0["stratagem 0 FireAttack"]
    A0 -- no --> None["result 3, no action"]
    F6 --> Win
    F5 --> Win
    F8 --> Win
    F9 --> Win
    F7 --> Win
    F4 --> Win
    F0 --> Win
    Win["choose stratagem: $6F8D = code,\n$6F8E = target, result 2"]
```

Every stratagem code is finally gated by `AiCheckStratagemFeasible` ($AC7B), which
computes terrain at the **target** ($0028) and at **self** ($0029) and
dispatches per stratagem:

| Code | Stratagem | Feasibility condition (terrain: 0=woods, 2=plains, 3=water, 4=mountain, 5=castle) |
|------|-----------|-----------------------------------------------------------------------------------|
| 0 | FireAttack 火攻 | target terrain = 0 or 2 |
| 1 | PitfallTrap 陷阱 | target terrain = 0 or 4 |
| 2 | FeintTroops 虚兵 | (alias of 1) |
| 3 | AmbushStrike 要击 | (alias of 1) |
| 4 | BoatSabotage 乱水 | target terrain = 3 |
| 5 | SupplyBurning 火箭 | target slot = faction base (0 or $0A) |
| 6 | CastleRaid 伪击转杀 | target terrain = 5 AND self adjacent to target |
| 7 | FriendlyFire 共杀 | target terrain = 0 or 4 AND enemy adjacent to target |
| 8 | Enticement 笼络 | target terrain ≠ 5 AND target record +3 < $32 |
| 9 | Rockfall 落石 | self terrain = 4 or 5 AND target adjacent to self AND target terrain = 5 |
| 10 | ChainLink 连环 | target terrain = 3 AND an adjacent enemy officer stands on terrain 3 |
| 11 | TenfoldAmbush 十面埋伏 | self terrain = 0 AND (record +9 ≠ 0 or record +8 ≥ $64) AND faction $04D8 slot empty |
| 12 | FloodAttack 水攻 | (alias of 10) |
| 13 | RepeatingCrossbow 連弩 | self terrain = 5 AND target adjacent to self |
| 14 | Inferno 劫火 | target terrain ≠ 5 AND an adjacent enemy officer NOT on terrain 5 |
| 15 | MysticalStasis 奇门遁甲 | target terrain ≠ 5 AND (record +1 ≥ $55 or record +2 ≥ $55) AND record +9 ≥ 2 AND record +8 ≥ $BC |

## `AiExecuteMove` ($A60C) — movement engine

Input: target ($0020,$0021). Output: `ai_action_result` (0/1/3), direction in
`ai_target_slot` ($6F8D), step cost in `ai_move_cost` ($6F97).

```mermaid
flowchart TD
    M["AiExecuteMove"] --> Scan["AiScanAdjacentOfficers\nN/S/W/E into $6FDD"]
    Scan --> Axis["primary axis = larger |delta|\ncandidates (dir, cost) ranked\ncheapest first"]
    Axis --> Eval["evaluate cost: terrain<<2 | move type\n(table $A7CD full / $A7E9 reduced\nwhen record byte 8 ≤ 2)"]
    Eval --> Aff{"cost ≤ budget $0505?"}
    Aff -- no --> Cost15["cost = 15 (impassable)"]
    Aff -- yes --> Rank["keep (cost<<4)|dir"]
    Cost15 --> Rank
    Rank --> G1{"best candidate tile\nempty ($FF)?"}
    G1 -- yes --> G2{"unit immobilized?"}
    G2 -- yes --> Res3["result 3 (no action)"]
    G2 -- no --> Move["result 0 (moved),\ndir = candidate, save reverse dir"]
    G1 -- "no (both blocked)" --> G3{"state = regroup (1)\nor capture (5)?"}
    G3 -- no --> Res3
    G3 -- yes --> Enc{"@CheckEnemyEncounter:\nenemy on candidate dir\nand budget ≥ 2?"}
    Enc -- yes --> Atk1["result 1 (engage),\n$6F8D = enemy officer idx"]
    Enc -- no --> Res3
```

## Support routines

- **AiScanAdjacentOfficers** ($A837): fills `$6FDD-$6FE0` with N/S/W/E
  occupant = officer index | faction bit ($80 = enemy), `$FF` = empty.
- **AiCheckFaction** ($A944): enemy iff bit7($0504) ≠ bit7($0628,Y); returns
  $80/$00. (Byte-identical duplicate at $CC92 must remain for ROM parity.)
- **AiFindNearbyOfficers** ($A8D3): radius scan into `$6FC9` —
  bit7 = enemy, bits0-6 = Manhattan distance.
- **AiSortNearbyOfficers** ($AE93): compacts enemy slots, bubble-sorts by
  16-bit troop count (record +8/+9), strongest first.
- **AiComputeArmyStats** ($B067) / **AiComputeBattleStats** ($B0B8): ally/enemy
  16-bit troop totals; battle stats time-scaled by `total * 4 / 1000 *
  days_remaining` where `days_remaining = $1E − war_round_counter`.
