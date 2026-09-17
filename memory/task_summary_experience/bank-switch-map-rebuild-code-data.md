# Bank switch map rebuild with code/data classification and bank $00 verification

- **Category:** task_summary_experience
- **Memory ID:** 506afd3c-2cae-406b-a277-db2a76e483b3
- **Keywords:** bank switch map, code/data classification, bank verification, ROM bytes, trampoline targets, bank $00, data-only banks

## Content

## Task description
- Core requirement: Rebuild code/bank_switch_map.md structured by PRG bank switch families (code vs data switches), verify bank $00 classification, and correct false findings about trampoline targets.
- Task background: User stated SwitchBankAC_A/B ($F24B/$F237) and BankedCallbackTrampoline ($EE07) are CODE PRG bank switches affecting $A000-$FFFF; SwitchBank8_A/B ($F266/$F25F) are DATA PRG bank switches affecting only $8000 window. Existing documentation contained false claim that prg_0c_0d.asm at $A022 called bank $00 via trampoline.

## Execution process
1. Read existing bank_switch_map.md to understand current structure and identify false claims
2. Verified primitive implementations in prg_1f.asm: SwitchBankAC_B ($F237), SwitchBankAC_A ($F24B), BankedCallbackTrampoline ($EE07), BankedCallbackReturn ($EE4D), SwitchBank8_B ($F25F), SwitchBank8_A ($F266), BankSwitch ($E51F)
3. Rebuilt bank_switch_map.md restructured into two categories: Code PRG switches (affecting $A000-$FFFF) and Data PRG switches (affecting only $8000)
4. Created separate linkage matrices: code-bank matrix (direct SwitchBankAC calls + trampoline) and data-bank matrix (SwitchBank8 traffic)
5. Identified false claim: old doc claimed $0C+$0D at $A022 used LDY #$20 -> bank $00, but actual code shows LDY #$28 -> bank $08
6. Verified against ROM bytes: prg_0c.bin offset $20-$27 = A0 28 20 07 EE 15 A0 60 confirms LDY #$28 (not #$20)
7. Confirmed target resolution: .word $A015 in bank $08 = B08_09_StratagemTargetMarker_Entry (JMP DrawStratagemTargetMarkers)
8. Regenerated bank_switch_scan_raw.txt using tools/scan_bank_links.py - confirmed no $00+$01 edge exists in fresh scan
9. Updated bank_switch_map.md: removed all bank-$00 code-call claims from matrices, graphs, and per-source details
10. Updated project memories (dc33b0dc, 68c836a6) with corrections noting bank-$00 claim was false

## Related files
- /home/zero/project/sango2dasm/code/bank_switch_map.md
- /home/zero/project/sango2dasm/code/bank_switch_scan_raw.txt

## Notes
- The stale bank_switch_scan_raw.txt predated an asm fix that corrected LDY #$20 to LDY #$28 at $A022
- Bank $00 is purely data-only; all access is via $8000 window (TileBankTable, BattleBankTable), never via trampoline
- Scanner tool doesn't cover prg_0e_0f and prg_1b_1c; their trampoline usage documented manually in map

## Task overview
Completed: Rebuilt bank_switch_map.md with code/data switch classification; verified bank $00 has NO code callers via ROM byte analysis; removed phantom $00+$01 edge from documentation and regenerated raw scan; corrected two project memories documenting the false finding.
