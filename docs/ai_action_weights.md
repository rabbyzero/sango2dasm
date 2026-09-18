# AI Action Weights — Expansion / Domestic / Loop Thresholds by Country and Game Level

Source: `prg_0a_0b.asm` `InitWorkAreas` ($A043) + `AiCountExpansionRoom` ($A0D3),
consumed by `AiActionChoose` ($A19C). All data verified against the ROM bytes.
Country slot → ruler mapping follows the scenario seed table documented in
[province_data.md](province_data.md) (Country records, 7 × 8 bytes at SRAM
`$6F07`, byte 0 = Ruler officer id).

## 1. How the weights work

Once per weight-seeding cycle, `InitWorkAreas` computes three SRAM weights for
the acting country (`sram_player_id` `$6F03`) at the current game level
(`sram_game_level` `$6F02`, 0–2):

```
W_expand    ($6F5F) = AiWeightExpandBase   [level*8 + country] + AiWeightExpandTierAdj   [level*4 + tier]
W_domestic  ($6F60) = AiWeightDomesticBase [level*8 + country] + AiWeightDomesticTierAdj [level*4 + tier]
W_loop      ($6F61) = AiWeightLoopBase     [level*8 + country] + AiWeightLoopTierAdj     [level*4 + tier]
```

`AiActionChoose` then rolls `random(W_E + W_D + W_L)` and compares down the
chain (these comparisons are the *thresholds*):

| Roll (r) | Action |
|---|---|
| `r < W_expand` | `AiAction_ExpandProvinces` ($A1C5) — expansion / conquest |
| `r < W_expand + W_domestic` | `AiAction_DomesticTurn` ($B49C) — domestic turn |
| otherwise | `@AiAction_Loop` ($BEC7) via `AiAction_LoopTramp` ($A23D) — straight to the shared action loop |

## 2. Tier thresholds — `AiCountExpansionRoom`

The tier (0–2) is not random: it measures each country's expansion opportunity.
`AiCountExpansionRoom` scans the bank-switched province adjacency table
(`$9D72`, 8 neighbors per province, `$FF`-terminated) and produces:

- `$0037` = **own/empty border edges** — adjacency entries whose neighbor
  province is unowned (owner 7) or owned by the current player.
- `$0038` = **expansion-capable provinces** — provinces that have such an edge
  *and* hold fewer than 4 officers (`CountRecordSlots < 4`), counted once per
  province.

`InitWorkAreas` computes the ratio `100 * $0038 / $0037` (`Multiply32` by 100,
`Divide16`) and buckets it:

| Ratio (percent) | Tier |
|---|---|
| `< $1F` (31) | 0 |
| `< $47` (71) | 1 |
| `>= $47` (71) | 2 |

A country whose borders are mostly its own or empty while its provinces still
have officer room lands in a high tier (expansion-favoring adjustments), and
vice versa.

## 3. Base weight tables (ROM data)

Indexed by `[level*8 + country]`, country slot 7 is unused (`$00` padding).
Raw bytes at `$A133` / `$A14B` / `$A163` in bank `$0A`.

### AiWeightExpandBase (`$A133`)

| Level | C0 董卓 Dong Zhuo | C1 袁紹 Yuan Shao | C2 曹操 Cao Cao | C3 孫策 Sun Ce | C4 劉備 Liu Bei | C5 劉璋 Liu Zhang | C6 馬騰 Ma Teng |
|---|---|---|---|---|---|---|---|
| 0 | `$0D` | `$08` | `$0A` | `$0A` | `$04` | `$06` | `$07` |
| 1 | `$0C` | `$07` | `$06` | `$08` | `$04` | `$02` | `$04` |
| 2 | `$09` | `$08` | `$08` | `$08` | `$05` | `$02` | `$06` |

### AiWeightDomesticBase (`$A14B`)

| Level | C0 董卓 | C1 袁紹 | C2 曹操 | C3 孫策 | C4 劉備 | C5 劉璋 | C6 馬騰 |
|---|---|---|---|---|---|---|---|
| 0 | `$03` | `$05` | `$04` | `$04` | `$04` | `$06` | `$05` |
| 1 | `$04` | `$06` | `$08` | `$06` | `$06` | `$0A` | `$08` |
| 2 | `$06` | `$06` | `$06` | `$07` | `$08` | `$0B` | `$08` |

### AiWeightLoopBase (`$A163`)

| Level | C0 董卓 | C1 袁紹 | C2 曹操 | C3 孫策 | C4 劉備 | C5 劉璋 | C6 馬騰 |
|---|---|---|---|---|---|---|---|
| 0 | `$04` | `$07` | `$06` | `$06` | `$0C` | `$08` | `$08` |
| 1 | `$04` | `$07` | `$06` | `$06` | `$0A` | `$08` | `$08` |
| 2 | `$05` | `$06` | `$06` | `$05` | `$07` | `$07` | `$06` |

## 4. Tier adjustment tables (ROM data)

Indexed by `[level*4 + tier]`; the tier-3 slot of each level is unused
(`$00` padding). Raw bytes at `$A17B` / `$A186` / `$A191` in bank `$0A`.

| Table | Level | Tier 0 | Tier 1 | Tier 2 |
|---|---|---|---|---|
| AiWeightExpandTierAdj (`$A17B`) | 0 | `$02` | `$04` | `$05` |
| | 1 | `$00` | `$03` | `$05` |
| | 2 | `$01` | `$02` | `$04` |
| AiWeightDomesticTierAdj (`$A186`) | 0 | `$02` | `$02` | `$00` |
| | 1 | `$04` | `$03` | `$00` |
| | 2 | `$03` | `$02` | `$01` |
| AiWeightLoopTierAdj (`$A191`) | 0 | `$02` | `$00` | `$01` |
| | 1 | `$02` | `$00` | `$01` |
| | 2 | `$02` | `$02` | `$01` |

## 5. Combined final weights (Base + TierAdj)

Cell format: `W_expand / W_domestic / W_loop` (hex). The AiActionChoose
compare-chain thresholds are `W_expand` (expand) and `W_expand + W_domestic`
(domestic); everything above that goes to the action loop.

### Level 0

| Tier | C0 董卓 | C1 袁紹 | C2 曹操 | C3 孫策 | C4 劉備 | C5 劉璋 | C6 馬騰 |
|---|---|---|---|---|---|---|---|
| 0 | `0F/05/06` | `0A/07/09` | `0C/06/08` | `0C/06/08` | `06/06/0E` | `08/08/0A` | `09/07/0A` |
| 1 | `11/05/04` | `0C/07/07` | `0E/06/06` | `0E/06/06` | `08/06/0C` | `0A/08/08` | `0B/07/08` |
| 2 | `12/03/05` | `0D/05/08` | `0F/04/07` | `0F/04/07` | `09/04/0D` | `0B/06/09` | `0C/05/09` |

### Level 1

| Tier | C0 董卓 | C1 袁紹 | C2 曹操 | C3 孫策 | C4 劉備 | C5 劉璋 | C6 馬騰 |
|---|---|---|---|---|---|---|---|
| 0 | `0C/08/06` | `07/0A/09` | `06/0C/08` | `08/0A/08` | `04/0A/0C` | `02/0E/0A` | `04/0C/0A` |
| 1 | `0F/07/04` | `0A/09/07` | `09/0B/06` | `0B/09/06` | `07/09/0A` | `05/0D/08` | `07/0B/08` |
| 2 | `11/04/05` | `0C/06/08` | `0B/08/07` | `0D/06/07` | `09/06/0B` | `07/0A/09` | `09/08/09` |

### Level 2

| Tier | C0 董卓 | C1 袁紹 | C2 曹操 | C3 孫策 | C4 劉備 | C5 劉璋 | C6 馬騰 |
|---|---|---|---|---|---|---|---|
| 0 | `0A/09/07` | `09/09/08` | `09/09/08` | `09/0A/07` | `06/0B/09` | `03/0E/09` | `07/0B/08` |
| 1 | `0B/08/07` | `0A/08/08` | `0A/08/08` | `0A/09/07` | `07/0A/09` | `04/0D/09` | `08/0A/08` |
| 2 | `0D/07/06` | `0C/07/07` | `0C/07/07` | `0C/08/06` | `09/09/08` | `06/0C/08` | `0A/09/07` |

## 6. Observations

- **Expand weight rises with tier, falls with level**: at higher game levels
  the base expand weights shrink while the domestic bases grow, so expansion
  is comparatively rarer and domestic development more frequent on Hard.
- **劉備 (C4) and 劉璋 (C5) lean loop-heavy** at low levels (large `W_loop`),
  meaning they most often skip straight to the passive action loop instead of
  choosing a proactive expansion or domestic action.
- **董卓 (C0) is the most expansion-biased** at every level/tier combination.
- Level effect on tier adjustments: expand tier-adj shrinks as the level grows
  (max `+5` at level 0 vs `+4` at level 2), while the domestic tier-adj
  flattens (level 0/1 tier 2 = `+0`, level 2 keeps `+1`).
- Weights are re-seeded only once per `InitWorkAreas` pass (`$6F5B` AI
  turn-cycle counter alternates seed → act → idle in `StrategyAiTurnDispatch`), so the
  tier reflects border/officer-room conditions at seeding time, not per action.

## 7. Related level-dependent thresholds (context)

`AiAction_ExpandProvinces` ($A1C5) applies further game-level gates before a
chosen expansion executes:

| Gate | Level 0 | Level 1 | Level 2 |
|---|---|---|---|
| Value-absorption chance (`EvalProvinceAbsorption`) | 20% (`random(100) < $14`) | 20% (`< $14`) | 30% (`< $1E`) |
| Readiness check | year `$6F00 >= $5A` (190+) | year `>= $5A` **OR** month `$6F01 >= 6` (July+) | always ready |

## Related documents

- `code/strategy_ai_decision_tree.md` — full AI flow, section 5 covers the
  same weight seeding with the dispatch verification.
- `code/cpu_ram_map.md` — `$6F5B`–`$6F61` cell semantics.
- `docs/province_data.md` — scenario seed (Country slot → Ruler mapping).
- `docs/manual_kb/13-ruler-guide.md` — the 7 rulers.
