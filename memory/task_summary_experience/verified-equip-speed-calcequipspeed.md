# Verified equipment weight speed calc and renamed StrategyMode_CalcEquipSpeed in prg_17_18.asm

- **Category:** task_summary_experience
- **Memory ID:** d490ea93-0eeb-4f07-b797-d1ceda5e2eb6
- **Keywords:** equipment weight calculation, StrategyMode_CalcEquipSpeed, semantic renaming, zp-vs-abs drift, .endproc fix, byte-exact verification

## Content

## Task description
- Core requirement: verify user's suspicion that StrategyMode_CalcTroopStats ($B230-$B2BF in prg_17_18.asm) performs weapon/armor weight calculation, then rename accordingly
- Task background: The proc was misnamed; needed to verify semantics against officer record structure, equipment catalog, and math helper routines before renaming across asm file and functions.h

## Execution process
1. Verified officer record byte +$0A layout: bits 0-4 weapon id (0-31), bits 5-7 armor id (0-7), cross-checked against docs/equipment_catalog.csv (24 weapons + 8 armors) and docs/officer_data.md
2. Confirmed two table lookups decode as weapon weight (AND #$1F → EquipWeightTable[id]) and armor weight (LSR×5 + ADC #$18 → EquipWeightTable[armor id + 24]); table renamed StrategyMode_EquipWeightTable with 32 entries ($00-$17 weapons, $18-$1F armors)
3. Verified speed calculation logic: B1F_MathDiv16 divides (record+0 Vitality + record+1 Might)/10, then +$14 − total weight → per-commander speed stored to player_random_offset_0,X; random 0-10 roll elects faster side as active_player_slot (first actor)
4. Applied renames in prg_17_18.asm: StrategyMode_CalcTroopStats → StrategyMode_CalcEquipSpeed, StrategyMode_TroopStatAdjTable → StrategyMode_EquipWeightTable, updated all references including dispatch table entry at $B156
5. Updated functions.h: B17_18_StrategyMode_CalcTroopStats → B17_18_StrategyMode_CalcEquipSpeed
6. Fixed pre-existing bug: added missing .endproc for AdvanceSrcPtr ($A0D2) whose absence nested entire rest of file and cascaded ~240 undefined-symbol errors
7. Fixed zp-vs-abs encoding drift: added forced-absolute `a:` prefix to 16 $00xx work-cell accesses in the proc (ROM uses absolute opcodes 8D/AD/6D/ED but plain zp equates emit zeropage 85/A5)
8. Created custom verification harness tools/tmp_verify_b230_proc.py to assemble renamed proc + table standalone and compare against ROM slice $B230-$B2DF
9. Verification result: compared 176 bytes, 0 mismatches (byte-exact); remaining pre-existing blockers: 21 undefined work_marker uses and other missing zp aliases in other procs, ~55 duplicate-symbol errors in full build

## Related files
- asm/banks/prg_17_18.asm
- include/functions.h
- tools/tmp_verify_b230_proc.py

## Notes
- The standalone bank harness (tools/assemble_17_18.py) initially failed due to the unclosed .proc cascade; fixing it reduced errors from ~240 to 238 (other pre-existing undefined symbols remain)
- Custom harness approach necessary because full build has pre-existing duplicate-symbol errors; created temporary verifier instead of modifying existing harness
- The zp-vs-abs drift is a latent bug class in this bank; other procs likely need same treatment but not addressed in this task scope

## Task overview
Completed: verified equipment-weight speed calculation semantics, performed byte-exact semantic renaming (StrategyMode_CalcEquipSpeed, StrategyMode_EquipWeightTable), fixed two pre-existing bugs (missing .endproc, zp-vs-abs drift), created verification harness confirming 0 mismatches over 176 bytes. Remaining whole-bank assembly blocked by unrelated pre-existing issues (work_marker undefined, duplicate symbols).
