# PRG bank switch linkage mapping for Sangokushi 2 disassembly

- **Category:** task_summary_experience
- **Memory ID:** 81d60193-bb83-4819-a594-2a2f303ca9be
- **Keywords:** PRG bank linkage map, Namco-163, bank switching, SwitchBankAC, BankedCallbackTrampoline, call graph
- **Usage scenarios:**
  - Analyzing cross-bank calls in NES disassembly
  - Locating which bank holds target routines
  - Extending or verifying bank switch scan

## Task description

- Core requirement: Map PRG bank switching relationships from prg_1f and all disassembled PRG banks (prg_08_09, prg_0a_0b, prg_0c_0d, prg_17_18, prg_1d_1e)
- Task background: The Sangokushi 2 NES disassembly uses Namco-163 mapper with 32 PRG banks. Bank switching occurs via SwitchBankAC_A/B, SwitchBank8_A/B primitives and BankedCallbackTrampoline mechanism. Need to identify all cross-bank call sites and their target banks.

## Execution process

1. Retrieved memories about Namco-163 bank switching mechanism (Y & $1F mask formula, BankedCallbackTrampoline patterns)
2. Searched codebase for bank-switching primitives: SwitchBankAC_A/B ($F237/$F24B), SwitchBank8_A/B ($F25F/$F266), BankedCallbackTrampoline ($EE07)
3. Created Python scanner script (tools/scan_bank_links.py) to parse asm/banks/*.asm for LDY+JSR patterns, trampoline .word targets, and direct NAMCO_PRG writes
4. Scanner tracked Y register values backward from each JSR call, applied 5-bit mask (effective_bank = Y & $1F), resolved target addresses to functions.h symbols where available
5. Identified 307 total bank-switch call sites across 6 disassembled files
6. Analyzed dynamic bank tables: TileBankTable (prg_08_09), BattleBankTable (prg_17_18), PosDataBankTable (prg_1d_1e), MenuUpdate restore patterns
7. Documented NMI sub-dispatch behavior: always JMPs into bank $1D entries after switching to $1D/$1E
8. Generated comprehensive markdown map (code/bank_switch_map.md) with mechanisms overview, per-source call tables, target-bank roles, and mermaid graph
9. Saved raw scan output (code/bank_switch_scan_raw.txt) for reference

## Related files

- /home/zero/project/sango2dasm/tools/scan_bank_links.py
- /home/zero/project/sango2dasm/code/bank_switch_map.md
- /home/zero/project/sango2dasm/code/bank_switch_scan_raw.txt

## Notes

- Initial grep attempts failed due to fish shell limitations; switched to Python scripts for reliable multi-line operations
- False positives detected in JMP-after-switch pattern detection (self-loops); manually verified NmiSubDispatch cases only
- Some trampoline targets point to undisassembled banks ($00, $0E, $0F, $10, $11, $19, $1B, $1C) - kept as raw addresses since no functions.h symbols exist
- Dynamic $8000-window restores use PLA/TAY/JSR SwitchBank8_B pattern to restore saved bank from stack

## Task overview

Completed: successfully mapped all PRG bank switching relationships across disassembled banks. Produced 307 call site records, identified key linkage patterns ($1F -> $17+$18/$1D+$1E, $0C+$0D heaviest user with 7 target banks), documented dynamic bank table mappings, and created reusable scanner tool. Final deliverables include comprehensive markdown map and raw scan data.
