# Banks 00-07 remain .incbin data stubs, not disassembled

- **Category:** important_decision_experience
- **Memory ID:** 3c6bf6c8-54bf-432d-918a-7fa038ba7182
- **Keywords:** banks 00-07, data-only stubs, .incbin, no disassembly

## Content

## Conclusion
PRG banks $00-$07 (rom/prg/prg_00.bin through prg_07.bin) must remain .incbin stubs in asm/banks/; they are not to be initialized as combined bank-pair disassemblies, and bank pairs prg_00_01.asm etc. must not be created for them.

## Rationale trade-off
The user stated these banks are not code — they hold data (terrain detail maps, battle scene tiles, sprite/animation frames). Even though bank $00 has a trampoline entry at $A015 called from $0C/$0D, the user's directive is that these banks stay as data stubs; the .incbin approach preserves byte-exactness without misclassifying tile data as code (disasm_prg.py classified 72.6% of bank 00/01 as "code", which was wrong).

## Rejected alternatives
- Initializing prg_00_01.asm via the disasm_prg.py bank-pair pipeline (attempted 2026-09-09 and reverted at the user's request: "revoke the change. bank 00 01 are not code.")
- Linker mapping BANK00/BANK01 at $A000/$C000 — reverted back to $8000 stubs in linker.cfg.

## Applicable and expiry conditions
Applies to banks $00-$07 in this project (all referenced only as tile/sprite data via the $8000 slot per code/bank_switch_map.md). Stays in force unless the user later requests bank-specific disassembly of these banks.
