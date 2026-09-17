# Linker configuration for CODE_BANK1D and CODE_BANK1E

- **Category:** project_build_configuration
- **Memory ID:** 6d4a300b-cf1c-47f3-b4b1-8ebdb55c2a63
- **Keywords:** linker.cfg, CODE_BANK1D, PRG_SLOT1, PRG_SLOT2

## Content

Added CODE_BANK1D and CODE_BANK1E segments to linker.cfg:
- CODE_BANK1D: load = PRG_SLOT1, type = ro, optional = yes
- CODE_BANK1E: load = PRG_SLOT2, type = ro, optional = yes
This enables proper linking of code spanning $BFFF/$C000 boundary between banks $1D and $1E.
