# Fix BankedCallbackTrampoline targets and raw address references in prg_08_09.asm

- **Category:** task_summary_experience
- **Memory ID:** c32c72a8-b470-4291-8c36-dd114dbb3f89
- **Keywords:** BankedCallbackTrampoline, symbolic naming, Y bank mapping, prg_08_09.asm, multi-entry procedure

## Content

## Task description
- Core requirement: replace raw address references in BankedCallbackTrampoline .word targets and other instruction operands with symbolic names from functions.h or local labels
- Task background: prg_08_09.asm contained 8 BankedCallbackTrampoline .word targets using raw addresses ($A000-$A02A range), plus additional raw address accesses in JSR/BNE/LDA instructions; user requested replacing these with proper symbolic references

## Execution process
1. Analyzed BankedCallbackTrampoline .word targets: initially assumed Y=$3B mapped to bank $1D+$1E, but user questioned this mapping
2. Investigated Namco-163 bank switching: discovered PRG ROM has 32 banks (5 bits), mapper masks Y with $1F, so effective_bank = Y & $1F
3. Verified mapping: Y=$3B & $1F = $1B (banks $1B+$1C), Y=$3D & $1F = $1D (banks $1D+$1E); only lines with banks present in functions.h can be replaced
4. Replaced 1 of 8 .word targets: line 7814 `.word $A02A` → `.word B1D_1E_OfficerDisplay_Lookup` (Y=$3D maps to $1D+$1E which exists in functions.h)
5. Skipped 7 .word targets because their banks ($1B+$1C, $0E+$0F, $19+$1A) are not yet in functions.h (WIP status)
6. Identified 7 non-.word raw address accesses to fix: JSR operand at line 3350 ($A8E8), BNE operands at lines 3651/3676 ($BBDF/$BBF4), LDA table accesses at lines 4197/4281/4287/4298 ($C015/$C01A/$C01B/$C022)
7. Added new label `AiFindNearbyOfficers_ScanLoop:` at $A8E8 for multi-entry procedure access from BattleResultProcess
8. Split TurnThresholds data region into three labeled sub-tables: TurnThresholds ($C015), SearchThresholdTable ($C01A), ThresholdResultTable ($C022)
9. Applied all replacements: JSR→AiTurnProcess::AiFindNearbyOfficers_ScanLoop, BNE→@PostBattlePatch/@CallProvinceAndSwap, LDA→TurnThresholds/SearchThresholdTable/ThresholdResultTable, BCC→@ThresholdResult
10. Verified assembly: no errors introduced by new symbols (pre-existing undefined symbol errors unrelated to changes)

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm

## Notes
- Initial error: incorrectly assumed Y=$3B mapped to bank $1D+$1E; corrected after user questioning and investigation revealed effective_bank = Y & $1F formula due to 32 8KB PRG banks
- Only 1 of 8 BankedCallbackTrampoline .word targets could be replaced because most target banks are not yet in functions.h (disassembly WIP)
- Multi-entry procedure required adding a new label inside .proc AiTurnProcess and referencing it as ProcName::LabelName from outside proc
- Pre-existing build errors in prg_0a_0b.asm and prg_17_18.asm (duplicate symbols) unrelated to changes; standalone ca65 check on prg_08_09.asm showed no new errors

## Task overview
Partially completed: successfully replaced 1 of 8 BankedCallbackTrampoline .word targets and all 7 non-.word raw address accesses with symbolic names; added multi-entry procedure label; remaining 7 .word targets skipped pending functions.h updates for banks $1B+$1C, $0E+$0F, $19+$1A
