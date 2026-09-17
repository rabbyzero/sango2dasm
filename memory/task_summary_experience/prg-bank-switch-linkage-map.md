# PRG bank switch linkage map in code/bank_switch_map.md

- **Category:** task_summary_experience
- **Memory ID:** dc33b0dc-30c3-4236-b28e-a196d4abfad5
- **Keywords:** bank linkage map, scan_bank_links, find_undisassembled_targets, trampoline targets, SwitchBankAC, SwitchBank8, NMI bank restore

## Content

PRG bank-switch linkage for prg_1f and all disassembled bank pairs is mapped via tools/find_undisassembled_targets.py (updated from tools/scan_bank_links.py), with raw per-line scan in code/bank_switch_scan_raw.txt. Scanner parses asm/banks/*.asm for LDY+JSR SwitchBankAC_A/B, SwitchBank8_A/B, BankedCallbackTrampoline (+inline .word targets), LDA+JSR BankSwitch (CHR-only), resolving Y via 5-bit mask (& $1F). Key findings: $1F state handlers use $17+$18/$1D+$1E/$08+$09/$0A+$0B/$0C+$0D; NMI handlers always touch $0E+$0F first; $0C+$0D is heaviest trampoline user (targets $08,$0A,$0E,$17,$19,$1D); dynamic $8000 tables: TileBankTable/BattleBankTable -> banks $00/$03/$04/$05, PosDataBankTable -> $12/$13, DrawSpriteFromBank -> $14/$15. Scanner stops backwards-tracking at non-immediate Y writes (LDY addr, TAY, PLY) to avoid trampoline self-reference false positives.

## Corrections (2026-09-09, doc rebuilt per user directive)
code/bank_switch_map.md was rebuilt structured by switch family. User-stated classification: SwitchBankAC_A/B ($F24B/$F237, $A000=Y & $C000=Y+1) and BankedCallbackTrampoline ($EE07) + BankedCallbackReturn ($EE4D) are CODE PRG bank switches — they change code banks $A000-$FFFF. SwitchBank8_A/B ($F266/$F25F, $8000=Y) are DATA PRG bank switches — they change only the $8000-$9FFF window and never touch code banks $A000-$FFFF. Only bank $1F calls SwitchBankAC_A/B directly; all other banks reach foreign code exclusively via BankedCallbackTrampoline. The doc now has separate code-linkage and data-linkage matrices, per-source details split into code/data subsections, target roles split into code banks ($08-$0F,$17-$1F) vs data banks ($00-$07,$10-$16), and two mermaid graphs.

## Corrections 2 (2026-09-09, bank-$00 call verified false)
The earlier claim "$0C+$0D trampolines to bank $00 entry $A015" (site $0C $A022, scan raw line 134, LDY #$20) is FALSE. Verified against ROM bytes prg_0c.bin $A020-$A027 (A0 28 20 07 EE 15 A0 60): LDY #$28 -> bank $08, .word $A015 = B08_09_StratagemTargetMarker_Entry (JMP DrawStratagemTargetMarkers, prg_08_09 $A015: 4C ED D1). The stale scan record predated an asm fix. bank_switch_scan_raw.txt was regenerated (no $00+$01 code edge exists) and bank_switch_map.md corrected: $0C+$0D code targets are $08+$09,$0A+$0B,$0E,$17+$18,$19,$1D+$1E; banks $00-$07 have NO code callers, only $8000 data usage.
