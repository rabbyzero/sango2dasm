# Sangokushi 2 - Haou no Tairiku (J) - NES Disassembly Project

## Overview

Disassembly project for **Sangokushi 2 - Haou no Tairiku (J)** (三國志II 覇王の大陸), a Namco strategy game for NES.

### ROM Info
- **Mapper**: 19 (Namco-163)
- **PRG ROM**: 32 banks x 8KB = 256KB
- **CHR ROM**: 32 banks x 8KB = 256KB
- **Mirroring**: Horizontal
- **Battery**: Yes (save data at $6000-$7FFF)

## Project Structure

```
sango2dasm/
├── Sangokushi 2 - Haou no Tairiku (J).nes  # Original ROM
├── Makefile                                 # Build system
├── linker.cfg                               # ca65 linker config
├── asm/
│   ├── main.asm                             # Entry point (reset/NMI/IRQ stubs)
│   └── banks/                               # 32 bank stub files (prg_00.asm - prg_1f.asm)
├── include/
│   ├── 6502_registers.h                     # PPU/APU register definitions
│   ├── namco163.h                           # Namco-163 mapper definitions + bank switch macros
│   └── macros.h                             # Common 6502 macros
├── rom/
│   ├── prg/                                 # 32 x 8KB PRG binary banks
│   ├── chr/                                 # 32 x 8KB CHR binary banks
│   ├── prg_combined.bin                     # Combined PRG (256KB)
│   └── rom_info.h                           # Auto-generated ROM info
├── tools/
│   ├── split_rom.py                         # Split ROM into banks
│   ├── disasm_6502.py                       # 6502 disassembler (listing format)
│   ├── analyze_rom.py                       # ROM structure analyzer
│   ├── generate_bank_stubs.py               # Generate bank stub .asm files
│   ├── verify_rom.py                        # Verify rebuilt ROM matches original
│   └── build_nes.py                         # Add iNES header to PRG binary
├── code/                                    # Place for disassembled code
└── build/                                   # Build output
    ├── sango2.nes                           # Built ROM
    ├── prg.bin                              # Raw PRG output from linker
    ├── main.o                               # Object file
    ├── main.lst                             # Assembly listing
    └── map.txt                              # Linker map file
```

## Toolchain

### cc65
Installed from source (GitHub master) to `~/.local/`:
- `ca65` V2.19 - 6502 assembler
- `ld65` V2.19 - linker

Path: `/home/zero/.local/bin/` (added to PATH in `.bashrc`/`.zshrc`)

### Makefile Targets

| Target | Description |
|--------|-------------|
| `make` | Build NES ROM from assembly |
| `make split` | Split original ROM into PRG/CHR banks |
| `make banks` | Generate PRG bank stub files |
| `make analyze` | Analyze original ROM structure |
| `make disasm FILE=rom/prg/prg_XX.bin ADDR=XXXX LEN=256` | Disassemble binary (use ADDR=E000 for bank 0x1F) |
| `make verify` | Compare built ROM with original |
| `make clean` | Remove build artifacts |

## Memory Map

| Range | Description |
|-------|-------------|
| $0000-$07FF | RAM (2KB) |
| $2000-$2007 | PPU registers |
| $4000-$401F | APU/IO registers |
| $4800 | Namco-163 IRQ/sound register |
| $6000-$7FFF | SRAM (8KB, battery-backed) |
| $8000-$9FFF | PRG slot 0 (switchable 8KB) |
| $A000-$BFFF | PRG slot 1 (switchable 8KB) |
| $C000-$DFFF | PRG slot 2 (switchable 8KB) |
| $E000-$FFFF | PRG slot 3 (switchable 8KB, **bank 0x1F fixed at boot**) |

## Namco-163 Bank Switching

Write bank number to these addresses to switch 8KB PRG banks:

| Address | Slot |
|---------|------|
| $F800 | $8000-$9FFF |
| $FA00 | $A000-$BFFF |
| $FC00 | $C000-$DFFF |
| $FE00 | $E000-$FFFF |

Use macros from `include/namco163.h`:
```asm
switch_bank_8000 BANK_05   ; Load bank 5 into $8000-$9FFF
switch_bank_A000 BANK_0A   ; Load bank 10 into $A000-$BFFF
```

## Reset Handler

Located at **Bank 0x1F, address $E000** (`rom/prg/prg_1f.bin` mapped to $E000-$FFFF).

The reset code at $E000 does:
1. SEI/CLD, init stack
2. PPU warmup (3 VBlank waits)
3. APU init
4. Clear RAM $0000-$07FF
5. Init stack pointer
6. Reads a vector table at $E07C (indexed by a counter at $007A & $1F)
7. Jumps through the indirect vector

The vector table at $E07C contains entries for each game state, each a 2-byte address within bank 0x1F. The game uses this as a dispatch mechanism.

**Important**: Bank 0x1F is mapped to $E000-$FFFF (PRG slot 3) at boot, NOT $8000-$9FFF. This is the fixed boot bank for Namco-163 mapper.

## ROM Bank Analysis

Key banks identified by `make analyze`:

| Bank | Characteristics | Likely Purpose |
|------|----------------|----------------|
| 0x1F | RESET marker, 445 JSR | Reset handler, main dispatch |
| 0x14 | 655 JSR, 719 RTI | Heavy code (graphics?) |
| 0x15 | 429 JSR, 930 RTI | Heavy code (graphics?) |
| 0x16 | 428 JSR, 549 RTI | Heavy code |
| 0x10 | 341 RTI, low JSR | IRQ/data heavy |
| 0x1E | 384 RTI | IRQ/data heavy |
| 0x07 | All 0xFF | Empty bank |

Banks with `[CODE]` marker have high JSR counts and are likely code-heavy.

## Disassembly Workflow

1. **Start with Bank 0x1F** - Contains reset handler and dispatch logic
   ```
   make disasm FILE=rom/prg/prg_1f.bin ADDR=E000 LEN=1024
   ```

2. **Follow the dispatch** - The reset handler reads vectors from $E07C and jumps to the actual game code

3. **Replace stubs** - Edit `asm/banks/prg_XX.asm` files:
   - Remove `.incbin` directive
   - Add actual disassembled code
   - Use proper `.segment` directives

4. **Update linker.cfg** - Add segments for each bank as you disassemble

5. **Verify** - Run `make verify` to check byte-exact match with original

## Linker Config

`linker.cfg` defines 4 PRG slots ($8000-$FFFF). As you disassemble more banks:
- Add new MEMORY regions for each bank
- Add corresponding SEGMENTS
- Assign code to the correct bank segment

## Include Files

- **6502_registers.h** - PPU ($2000-$2007), APU ($4000-$4017) register addresses and bit definitions
- **namco163.h** - Bank switch addresses, bank indices (BANK_00-BANK_1F), `switch_bank_*` macros
- **macros.h** - Common macros: `wait_vblank`, `set_ppu_addr`, `ppu_write`, `dma_sprites`

## Current Status

- Build system: Working
- ROM split: Done (32 PRG + 32 CHR banks)
- Bank stubs: Generated (all `.incbin` based)
- Disassembly: Not started (stub code only)
- Accuracy: 0% (stub code replaces all banks)

## Next Steps

1. Disassemble Bank 0x1F reset handler ($E000-$E100)
2. Map the vector table at $E07C
3. Identify bank switching routines
4. Begin disassembling other banks based on dispatch targets
5. Replace `.incbin` stubs with real code incrementally
6. Use `make verify` to track progress
