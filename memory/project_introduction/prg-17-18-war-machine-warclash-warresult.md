# prg_17_18 war machine: WarClash (engagement calc) and WarResult (war tally) semantics

- **Category:** project_introduction
- **Memory ID:** 8847445d-de01-4ef6-b018-0505ae6cf897
- **Keywords:** war machine, WarClash, WarResult, engagement resolution, TroopLosses, formation select, Tactical Mode, Battle Mode distinction
- **Usage scenarios:**
  - Analyzing prg_17_18 game-state machine
  - Renaming CombatCalc or BattleResult routines
  - Tracing war flow between banks

## Content

prg_17_18.asm's MainGameDispatch ($B100, game_state $04A8, 22 entries) is the WAR machine: two armies (player_officer_id_0/1 $04AD/$04AE = commanding officer per side; player_army_value_0/1 $04B1/$04B2 = TroopCount). State 1 TroopAssignmentDispatch routes sub_action_type via HandleResult; state 2 WarClashDispatch ($B5C8, renamed from CombatCalcDispatch) is the Tactical-layer engagement resolver: 5 sequential stat-threshold + RandomBelow100 checks (CompareForces/MoraleCheck/DefenseCheck/OfficerDuel/DetermineOutcome) over officer-record bytes 1-4 and army values, outcomes 0/2/6 -> MapScroll A/B/C (states 16-18, army movement), 3 -> ruler check -> EventCutscene (6), 7 -> BattleInitDispatch (7, formation pick 1-4 from BattleInit_FormationData = Serpent/Goose/Wedge/FishScale) or 8 -> BattleSetup_Exec -> battle opening via EventCutscene2 (state 9). Entry to state 2: TroopAssign_SelectTarget when player_flag_0 bit7 set. State 3 WarResultDispatch ($B8C7, renamed from BattleResultDispatch) is the war-result tally: ComputeDifferential roll ($0560/$056E/$0570 params), WarResult_ApplyTroopLoss subtracts losses from army value (損兵 TroopLosses), ShowVictory, Finalize -> both armies alive: back to state 1 sub 0 (next war round); one army 0: winner flag $0515, state $0D MapFade -> war end / TerritoryEvent_CaptureOfficer. No disassembled code writes game_state=3 (checked all banks, indexed/INC included) — entry presumed via record restore or undecoded path. RAM war_result_phase ($042E, renamed from battle_result_phase) is shared with strategy command dispatch. Officer record byte 0 = Vitality confirmed (Duel_ApplyDamage, 0=death); bytes 1-4 = remaining combat stats (old comments "leadership/morale" are non-glossary guesses). WarClash/WarResult are NOT Battle Mode (real battle is banks $08-$0F; B08_09_BattleResult* are the true battle-phase handlers and keep that name) and NOT Duel (state 4 DuelDispatch is the true 一騎討ち); WarClash_OfficerDuel/DuelCheck are probability checks gating escalation, not duels.
