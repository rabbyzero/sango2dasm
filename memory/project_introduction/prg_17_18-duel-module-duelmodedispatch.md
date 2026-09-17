# prg_17_18 is the DUEL module; MainGameDispatch->DuelModeDispatch, game_state->duel_state

- **Category:** project_introduction
- **Memory ID:** 8847445d-de01-4ef6-b018-0505ae6cf897
- **Keywords:** duel module, DuelModeDispatch, duel_state, war_side_strength, superseded

## Content

prg_17_18.asm's DuelModeDispatch ($B100, entry stub DuelModeDispatch_Entry $A01B; duel_state $04A8 — renamed from game_state 2026-09-14 because it indexes ONLY the duel mode's 22-entry state table, not a full-game state; the full-game NMI mode cell is addr_game_state $007A in prg_1f) — SUPERSESSION NOTICE 2026-09-11: the "WAR machine" interpretation below is SUPERSEDED. The whole $B100-$DBDA state machine is the DUEL module (一騎討ち); the "war clash / war result" framing came from mislabeled procs that have all been renamed (canonical names and verified semantics in the common_pitfalls memory "Duel module procs renamed: DuelModeDispatch, duel_state $04A8, verified semantics"; cross-check code/bank_switch_map.md and prg_17_18.asm headers). Tactical Mode war logic (AI turns, engagements, war tallies) lives in other banks (prg_08_09, prg_0e_0f, prg_0a_0b), not here.

Still-valid verified facts from the earlier analysis (kept):
- $04B1/$04B2, renamed war_side_strength_0/1 (formerly player_army_value_0/1), are 1-byte side gauges in [0,100] snapshotting officer-record byte +0 (体力 Vitality) of each commander at duel start (DuelScene_InitOfficers $B16F), then decremented only by duel losses (DuelStrike_ApplyGauge $B985, DuelStrike_Resolve $B95C backfire), floored at 0. No re-sync or write-back between gauge and officer record exists in any bank ($04B1/$04B2 raw operands appear only in prg_17_18) — pursuit damage (DuelPursue_ApplyStrike $BB89) and war-end processing write record +0 directly. The 16-bit 兵数 TroopCount lives at officer record +8/+9 in SRAM and is never stored here.
- DuelScene_CalcEquipSpeed $B230: per commander, speed = (record+0 Vitality + record+1 Might)/10 + $14 − (weapon weight + armor weight) into player_random_offset_0,X; a random 0-10 roll per side (display_ptr_lo/hi) elects the faster side as first actor. Record+$0A = equipment byte (bits 0-4 weapon id, bits 5-7 armor id; armors are item ids 24-31 indexing StrategyMode_EquipWeightTable at +$18, cross-checked against docs/equipment_catalog.csv).
- Assembler/verification workflow notes remain valid: byte-exact per-proc verification via tools/tmp_verify_* harnesses; zp-vs-abs `a:` prefix pitfall for $00xx work cells in this bank; whole-bank standalone assembly still has ~238 pre-existing errors (missing zp aliases etc.) — verify edits by diffing the sorted symbol-error profile against baseline, not by reaching 0 errors.
