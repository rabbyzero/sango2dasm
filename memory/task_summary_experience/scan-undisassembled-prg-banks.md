# Scan for un-disassembled PRG banks using bank-switch call patterns

- **Category:** task_summary_experience
- **Memory ID:** 68c836a6-6326-49a3-899f-2dcffb3c03a4
- **Keywords:** un-disassembled banks, bank switch scan, SwitchBank8, trampoline targets, Namco-163, call site analysis

## Content

## Task description
- Core requirement: Find all un-disassembled PRG banks in the Sangokushi 2 NES disassembly by scanning for bank-switch call patterns (LDY #$xx followed by JSR SwitchBankAC_A/B, SwitchBank8_A/B, or B1F_BankedCallbackTrampoline)
- Task background: The project uses Namco-163 mapper with 32 PRG banks. Disassembled banks are $08-$0F, $17-$1F; stubs are $00-$07 and $10-$16. Need to identify which undisassembled banks are still referenced by existing disassembled code.

## Execution process
1. Created Python scanner script (tools/find_undisassembled_targets.py) to parse asm/banks/*.asm for LDY+JSR patterns and trampoline .word targets
2. Initial scan found only bank $00, but cross-checking with existing code/bank_switch_scan_raw.txt revealed missed SwitchBank8 patterns targeting banks $10-$16
3. Updated scanner to include SwitchBank8_A/B primitives (target = Y & $1F, single bank) and re-ran
4. Detected false positive at prg_1f.asm:2405 (inside trampoline implementation itself); refined scanner to stop backwards-tracking at non-immediate Y writes (LDY addr, TAY, PLY)
5. Fixed indentation bug in SearchReplace operation that nested results.append inside if block
6. Verified notable sites; final scan identified call sites to un-disassembled banks: $02, $10, $11, $12, $15, $16

## Related files
- /home/zero/project/sango2dasm/tools/find_undisassembled_targets.py

## Notes
- Scanner limitations: Cannot resolve dynamic Y values from tables (TileBankTable, PosDataBankTable, DrawSpriteFromBank reference additional undisassembled banks $03,$04,$05,$13,$14)
- False positive elimination critical: Trampoline implementation self-references can mimic call sites; must detect and exclude them
- SwitchBank8 pattern was initially overlooked; comprehensive scan requires covering all bank-switch primitives

## Task overview
Completed: identified call sites to un-disassembled data banks ($02, $10, $11, $12, $15, $16). Scanner tool is reusable for future verification. Dynamic table references additionally touch $03,$04,$05,$13,$14 but require separate analysis.

## Corrections (2026-09-09)
The original finding "prg_0c_0d:233 trampoline to $00 with target .word $A015" was FALSE. Verified against ROM bytes (prg_0c.bin $A020: A0 28 20 07 EE 15 A0): that site is LDY #$28 -> bank $08, .word $A015 = B08_09_StratagemTargetMarker_Entry in bank $08. Bank $00 has no code callers; it is data-only ($8000 window via TileBankTable/BattleBankTable). Bank $00 was removed from code-target lists in code/bank_switch_map.md, and code/bank_switch_scan_raw.txt was regenerated without the $00+$01 edge.
