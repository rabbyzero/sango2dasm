# Banked callback trampoline Y=$3B targets bank 1B/1C $A003

- **Category:** project_architecture
- **Memory ID:** 7b44d044-ae5e-4811-b616-3794c8a0cd0b
- **Keywords:** banked callback, trampoline, Y=$3B, prg_1b_1c, $A003 stub, AiOfficerActionDispatch

## Content

The project uses a banked callback trampoline mechanism where the LDY value determines which PRG bank pair is selected (Y & $1F mask). When Y=$3B, it selects PRG bank pair 1B+$1C. The entry stub at $A003 in this bank is called via `LDY #$3B; JSR $EE07; .word $A003` pattern from other banks (specifically prg_08_09 AiOfficerActionDispatch State1_GrowStatA and State2_GrowStatB). This stub serves as a dispatch callback target for war-scene action delta input polling, not a PPU copy helper as previously misdocumented. The trampoline resolves the target address within the currently mapped banks based on the Y mask.
