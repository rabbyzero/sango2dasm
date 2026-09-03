# Sound Engine Procedure Structure and Code Regions

- **Category:** project_introduction
- **Memory ID:** 4447e113-bc82-41cf-97f9-f10fca7acc23
- **Keywords:** sound engine, procedure split, ca65 scoping, code region, NES disassembly
- **Usage scenarios:**
  - Disassembling or analyzing NES ROM sound routines
  - Resolving ca65 label scoping issues in assembly
  - Correctly identifying code vs data regions in PRG banks

## Content

The project disassembles a NES ROM with two main sound engine procedures:
- `BattleAnimSoundEngine`: $D8D4-$DC58, handles volume extraction and namco processing
- `BattleSoundChannelProc`: $DC59-$DFB4, primary entry at $DF6E (`SoundPlayAlt`)
Branch instructions at $DF74 (BMI) and $DF79 (BEQ) are valid code, not data, with targets at $DFB5 and $DF7E respectively.
Cross-proc references use qualified labels (e.g., `ProcName::Label`) due to ca65 scoping rules; `@` labels are local to `.proc` blocks.
