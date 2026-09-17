# Revoke bank-pair initialization for prg_00_01.asm and restore stub configuration

- **Category:** task_summary_experience
- **Memory ID:** 8946fb9a-717c-4a70-87c5-35258022261b
- **Keywords:** bank revocation, prg_00_01 revert, data-only stubs, user correction, linker restoration

## Content

## Task description
- Core requirement: revoke the previously attempted bank-pair initialization of PRG banks $00/$01
- Task background: earlier in the session, an attempt was made to initialize prg_00_01.asm as a combined bank-pair disassembly with new linker entries at $A000/$C000 and associated tool scripts; the user explicitly stated "bank 00 01 are not code" and requested revocation

## Execution process
1. linker.cfg: restore BANK00 and BANK01 entries back to `$8000` stub addresses; restore the "Banks 00-07" comment indicating data-only stubs
2. asm/banks/all_banks.asm: restore `.include "prg_00.asm"` and `.include "prg_01.asm"` lines for the original stub includes
3. Delete newly created files: asm/banks/prg_00_01.asm, output/prg_00_01_raw.asm, tools/init_00_01.py, tools/verify_00_01.py
4. Delete the task-summary memory created during the initial (now-reverted) attempt (id: 807ec0e0-...)

## Related files
- /linker.cfg
- /asm/banks/all_banks.asm
- /asm/banks/prg_00_01.asm (deleted)
- /output/prg_00_01_raw.asm (deleted)
- /tools/init_00_01.py (deleted)
- /tools/verify_00_01.py (deleted)

## Notes
- The initial bank-pair initialization attempt was based on incorrect assumptions about banks $00-$07 being code; the user correction clarified these are data-only (terrain/tile/sprite) and must remain .incbin stubs
- The Memory dump task exporting 96 items to filesystem was unrelated to this revoke operation

## Task overview
Fully reverted: workspace restored to prior state with banks $00-$07 as .incbin data stubs; no disassembly artifacts remain; the correction has been persisted so this error won't be repeated
