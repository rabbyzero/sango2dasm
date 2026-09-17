# Equipment catalog adds weight column from ROM table

- **Category:** task_summary_experience
- **Memory ID:** 0feb9e64-aabd-48fe-81d9-4b17004cfa94
- **Keywords:** equipment catalog, weight column, StrategyMode_EquipWeightTable, CSV update, generator synchronization

## Content

## Task description
- Core requirement: add weight information to docs/equipment_catalog.csv sourced from the ROM's StrategyMode_EquipWeightTable
- Task background: The equipment catalog documents 32 items (24 weapons, 8 armors) used in officer records; the ROM contains a 32-byte weight table at $B2C0-$B2DF in prg_17_18.asm that is used by StrategyMode_CalcEquipSpeed to calculate initiative speed; the CSV previously lacked this field

## Execution process
1. Verified functions.h rename consistency: checked grep for AiCheckActionFeasible/AiCheckStratagemFeasible across asm/include/code/tools directories; confirmed prg_08_09.asm already uses AiCheckStratagemFeasible so no propagation needed
2. Extracted weight table bytes from StrategyMode_EquipWeightTable ($B2C0-$B2DF): .byte $04,$03,$05,$08,$09,$06,$07,$04,$04,$06,$07,$08,$07,$06,$08,$10,$04,$05,$06,$08,$07,$08,$06,$10,$01,$02,$04,$06,$05,$10,$03,$07
3. Updated tools/extract_town_data.py: added EQUIP_WEIGHTS constant array with provenance comment pointing to asm table and StrategyMode_CalcEquipSpeed formula; modified catalog_rows.append to include 'weight': EQUIP_WEIGHTS[cell]; added 'weight' to write_csv column list
4. Updated docs/equipment_catalog.csv: inserted weight column after category field for all 32 rows using SearchReplace with unique row patterns
5. Verification: parsed CSV with csv.DictReader confirming 32 rows with 0 weight mismatches against the ROM table; spot-checked 方天画戟 (id 21) = 8, 甲冑 (id 29) = 10, 綸巾 (id 24) = 1; verified extract_town_data.py syntax with ast.parse

## Related files
- /docs/equipment_catalog.csv
- /tools/extract_town_data.py

## Notes
- The generator tool (extract_town_data.py) uses a fixed column list when writing CSVs, so adding a new column requires updating both the data source constant AND the column list or the column would be silently dropped on regeneration
- Did not re-run extract_town_data.py to regenerate the CSV because it rewrites multiple town/armory/rice documentation files at once and could churn unrelated changes; instead performed standalone verification
- Weight values are used in StrategyMode_CalcEquipSpeed: speed = (Vitality + Might)/10 + $14 − (weapon_weight + armor_weight); lower weight increases initiative chance

## Task overview
Completed: added weight column to equipment_catalog.csv for all 32 items with byte-exact mapping to ROM table; synchronized extract_town_data.py generator to preserve the column on future regenerations; verification confirmed 0 mismatches across all rows
