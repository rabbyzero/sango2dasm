# war_side_strength lifecycle verification: Vitality snapshot with no re-sync to officer record

- **Category:** task_summary_experience
- **Memory ID:** 63c69309-d107-4238-b829-900951d6f73a
- **Keywords:** war_side_strength, Vitality snapshot, no re-sync, Duel_ApplyDamage, officer record, LoyaltyCalc, DefenseCalc formula, prg_17_18 verification

## Content

## Verification Workflow Summary

**Task**: Verify semantics of `war_side_strength_0/1` ($04B1/$04B2) in prg_17_18.asm and correct naming/comments.

**Key Findings**:
1. **$04B1/$04B2 are 1-byte values**, not 16-bit TroopCount. User's "[0,1000]" premise was incorrect for this variable; TroopCount is the 16-bit field at officer record +8/+9.
2. **Initialization**: `StrategyMode_InitOfficers` ($B16F) copies officer record byte +0 (体力 Vitality/HP) into each side's gauge at war start. This is a **snapshot** of the commander's HP.
3. **Evolution during war**: Gauges are **decremented only** by war losses (`WarResult_Calculate` $B95C, `WarResult_ApplyTroopLoss` $B985), floored at 0. Range [0,100].
4. **No re-sync/write-back**: Verified via raw-operand scan — `$04B1/$04B2` appear **only in prg_17_18.asm**. Officer-record writes exist (`Duel_ApplyDamage` $BB89 writes record +0 directly; `TerritoryEvent_ApplyResult` writes record +10 equipment), but nothing ever copies the gauge back to record +0 or re-reads the record after init. Thus, the gauge is an **independent war-round strength tracker** seeded from initial HP.
5. **Formula corrections**: 
   - `WarClash_LoyaltyCalc`: threshold = `$8C − (loyalty + war_side_strength)`, floored at 0 (not "capped at $8C").
   - `WarClash_DefenseCalc`: threshold = `$7C − (min(Might+1, Int+2) + war_side_strength)`, floored at 0.
6. **Naming updates**: Renamed `player_army_value_0/1` → `war_side_strength_0/1` (all 21 use sites); updated equate comments, cpu_ram_map.md, ram_equates_full.txt, globalize_04xx.py. Renamed `WarClash_MoraleCalc` → `WarClash_LoyaltyCalc` (verified byte +3 = 忠誠度 Loyalty). Fixed header comments for both procs.

**Outcome**: Zero remaining references to old names; purely symbolic changes; no byte alterations. Memory updated with verified lifecycle semantics.

**Notes**: Open question remains where war-end healing restores officer HP (manual says "treats wounded generals") — likely outside prg_17_18.asm.
