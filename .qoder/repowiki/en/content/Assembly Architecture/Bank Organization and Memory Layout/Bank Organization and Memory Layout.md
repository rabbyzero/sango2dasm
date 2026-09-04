# Bank Organization and Memory Layout

<cite>
**Referenced Files in This Document**
- [linker.cfg](file://linker.cfg)
- [PROJECT.md](file://PROJECT.md)
- [namco163.h](file://include/namco163.h)
- [functions.h](file://include/functions.h)
- [all_banks.asm](file://asm/banks/all_banks.asm)
- [prg_0a_0b.asm](file://asm/banks/prg_0a_0b.asm)
- [prg_0c_0d.asm](file://asm/banks/prg_0c_0d.asm)
- [prg_17_18.asm](file://asm/banks/prg_17_18.asm)
- [prg_1d_1e.asm](file://asm/banks/prg_1d_1e.asm)
- [prg_08_09.asm](file://asm/banks/prg_08_09.asm)
- [prg_0e_0f.asm](file://asm/banks/prg_0e_0f.asm)
- [prg_19_1a.asm](file://asm/banks/prg_19_1a.asm)
- [prg_1b_1c.asm](file://asm/banks/prg_1b_1c.asm)
- [main.asm](file://asm/main.asm)
- [bank_1f_analysis.md](file://code/bank_1f_analysis.md)
- [bank_1f_plan.md](file://code/bank_1f_plan.md)
- [Makefile](file://Makefile)
- [analyze_0c_0d_callbacks.py](file://tools/analyze_0c_0d_callbacks.py)
- [verify_0c_0d_directives.py](file://tools/verify_0c_0d_directives.py)
- [check_trampoline_pattern.py](file://tools/check_trampoline_pattern.py)
- [verify_19_1a.py](file://tools/verify_19_1a.py)
- [verify_1b_1c.py](file://tools/verify_1b_1c.py)
- [init_19_1a.py](file://tools/init_19_1a.py)
- [extract_officer_data.py](file://tools/extract_officer_data.py)
- [extract_province_data.py](file://tools/extract_province_data.py)
- [officer_data.md](file://docs/officer_data.md)
- [province_data.md](file://docs/province_data.md)
</cite>

## Update Summary
**Changes Made**
- Updated to reflect major expansion of map-screen scene decoding with complete attract demo system implementation in banks $19/$1A
- Enhanced documentation of strategy request handler and demo event playback sequencer functionality
- Added comprehensive officer status display and province officer roster management systems
- Documented unification ending sequences and ruler introduction sequences in consolidated bank architecture
- Enhanced officer and province data extraction tools providing detailed analysis of 237 officers and 30 provinces
- Updated bank switching mechanisms to document sophisticated state machine architecture for attract demo and map screen processing

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Dependency Analysis](#dependency-analysis)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Conclusion](#conclusion)

## Introduction
This document explains the bank organization and memory layout used by the Sango2DASM project for the Namco-163 (Mapper 19) implementation. It covers the 32-bank structure with 8KB banks, the fixed boot bank 0x1F mapped to $E000-$FFFF, the three switchable PRG slots at $8000-$DFFF, and the memory mapping configuration defined in linker.cfg. **Updated**: Recent major enhancements include the addition of comprehensive attract demo system in banks $19/$1A with sophisticated state machine architecture, complete strategy request handling, demo event playback sequencer, officer status display, and unification ending sequences. Banks $1B/$1C provide enhanced map screen frame processing with ruler intro sequences and province sprite management. The project now includes advanced data extraction tools that provide comprehensive analysis of 237 officers and 30 provinces with detailed field mappings and validation. Practical examples demonstrate how code is distributed across banks, how bank numbers relate to memory addresses, and how the 6502 address space is utilized with the new consolidated architecture.

## Project Structure
The project organizes PRG banks as 32 individual 8KB files (rom/prg/prg_XX.bin), each mapped into one of four PRG slots on the 6502 address bus. The linker.cfg defines the four PRG slots and how segments are loaded into them. The bank stub files under asm/banks/ include the ROM binaries and provide placeholders for disassembly. The include/namco163.h file defines mapper registers and bank switching macros. **Updated**: PRG banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E are now consolidated into single files that occupy both $A000-$BFFF and $C000-$DFFF, providing unified 16KB code spaces with sophisticated game systems. **New**: PRG banks $19/$1A implement a complete attract demo system with state machine architecture, country selection, camera focus functionality, and enhanced data table organization, while banks $1B/$1C offer comprehensive map screen frame processing with ruler intro sequences and province sprite management.

```mermaid
graph TB
subgraph "ROM Banks"
B00["rom/prg/prg_00.bin"]
B01["rom/prg/prg_01.bin"]
B08_09["rom/prg/prg_08.bin + prg_09.bin (consolidated)"]
B0A_0B["rom/prg/prg_0a.bin + prg_0b.bin (consolidated)"]
B0C_0D["rom/prg/prg_0c.bin + prg_0d.bin (consolidated)"]
B0E_0F["rom/prg/prg_0e.bin + prg_0f.bin (consolidated)"]
B17_18["rom/prg/prg_17_18.bin (consolidated)"]
B19_1A["rom/prg/prg_19.bin + prg_1a.bin (consolidated)"]
B1B_1C["rom/prg/prg_1b.bin + prg_1c.bin (consolidated)"]
B1D_1E["rom/prg/prg_1d_1e.bin (refactored)"]
B1F["rom/prg/prg_1f.bin"]
end
subgraph "Assembler Stubs"
S00["asm/banks/prg_00.asm"]
S01["asm/banks/prg_01.asm"]
S08_09["asm/banks/prg_08_09.asm (consolidated)"]
S0A_0B["asm/banks/prg_0a_0b.asm (consolidated)"]
S0C_0D["asm/banks/prg_0c_0d.asm (consolidated)"]
S0E_0F["asm/banks/prg_0e_0f.asm (consolidated)"]
S17_18["asm/banks/prg_17_18.asm (consolidated)"]
S19_1A["asm/banks/prg_19_1a.asm (consolidated)"]
S1B_1C["asm/banks/prg_1b_1c.asm (consolidated)"]
S1D_1E["asm/banks/prg_1d_1e.asm (refactored)"]
S1F["asm/banks/prg_1f.asm"]
end
subgraph "Main Assembly"
MAIN["asm/main.asm<br/>includes all_banks.asm"]
ALL_BANKS["asm/banks/all_banks.asm<br/>includes prg_19_1a.asm & prg_1b_1c.asm"]
end
subgraph "Analysis Tools"
AT01["analyze_0c_0d_callbacks.py"]
AT02["verify_0c_0d_directives.py"]
AT03["check_trampoline_pattern.py"]
AT04["verify_19_1a.py"]
AT05["verify_1b_1c.py"]
AT06["init_19_1a.py"]
AT07["extract_officer_data.py"]
AT08["extract_province_data.py"]
end
subgraph "Data Documentation"
DOC01["officer_data.md<br/>237 officers analyzed"]
DOC02["province_data.md<br/>30 provinces documented"]
end
B00 --> S00
B01 --> S01
B08_09 --> S08_09
B0A_0B --> S0A_0B
B0C_0D --> S0C_0D
B0E_0F --> S0E_0F
B17_18 --> S17_18
B19_1A --> S19_1A
B1B_1C --> S1B_1C
B1D_1E --> S1D_1E
B1F --> S1F
MAIN --> ALL_BANKS
ALL_BANKS -. includes .-> CFG
S00 -. includes .-> CFG
S01 -. includes .-> CFG
S08_09 -. includes .-> CFG
S0A_0B -. includes .-> CFG
S0C_0D -. includes .-> CFG
S0E_0F -. includes .-> CFG
S17_18 -. includes .-> CFG
S19_1A -. includes .-> CFG
S1B_1C -. includes .-> CFG
S1D_1E -. includes .-> CFG
S1F -. includes .-> CFG
AT01 -. analyzes .-> S0C_0D
AT02 -. verifies .-> S0C_0D
AT03 -. checks .-> S0C_0D
AT04 -. verifies .-> S19_1A
AT05 -. verifies .-> S1B_1C
AT06 -. initializes .-> S19_1A
AT07 -. extracts .-> DOC01
AT08 -. extracts .-> DOC02
```

**Diagram sources**
- [all_banks.asm:13](file://asm/banks/all_banks.asm#L13)
- [all_banks.asm:14](file://asm/banks/all_banks.asm#L14)
- [all_banks.asm:16](file://asm/banks/all_banks.asm#L16)
- [all_banks.asm:17](file://asm/banks/all_banks.asm#L17)
- [all_banks.asm:26](file://asm/banks/all_banks.asm#L26)
- [all_banks.asm:27](file://asm/banks/all_banks.asm#L27)
- [all_banks.asm:28](file://asm/banks/all_banks.asm#L28)
- [prg_08_09.asm:1-7](file://asm/banks/prg_08_09.asm#L1-L7)
- [prg_0a_0b.asm:1-8](file://asm/banks/prg_0a_0b.asm#L1-L8)
- [prg_0c_0d.asm:1-8](file://asm/banks/prg_0c_0d.asm#L1-L8)
- [prg_0e_0f.asm:1-7](file://asm/banks/prg_0e_0f.asm#L1-L7)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_19_1a.asm:1-7](file://asm/banks/prg_19_1a.asm#L1-L7)
- [prg_1b_1c.asm:1-7](file://asm/banks/prg_1b_1c.asm#L1-L7)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)
- [linker.cfg:41-43](file://linker.cfg#L41-L43)
- [linker.cfg:45-47](file://linker.cfg#L45-L47)
- [linker.cfg:49-51](file://linker.cfg#L49-L47)
- [linker.cfg:53-55](file://linker.cfg#L53-L55)
- [linker.cfg:70-72](file://linker.cfg#L70-L72)
- [linker.cfg:74-76](file://linker.cfg#L74-L76)
- [linker.cfg:78-80](file://linker.cfg#L78-L80)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [all_banks.asm:1-31](file://asm/banks/all_banks.asm#L1-L31)
- [main.asm:1-18](file://asm/main.asm#L1-L18)

## Core Components
- 32 PRG banks × 8KB = 256KB total PRG ROM
- Four PRG slots on the 6502 address bus:
  - Slot 0: $8000-$9FFF (8KB)
  - Slot 1: $A000-$BFFF (8KB)
  - Slot 2: $C000-$DFFF (8KB)
  - Slot 3: $E000-$FFFF (8KB)
- Fixed boot bank 0x1F mapped to $E000-$FFFF at reset
- Bank switching controlled via mapper registers at $F800-$FE00
- **Updated**: Consolidated bank switching mechanism for PRG banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E using unified 16KB blocks at $A000-$DFFF
- **New**: PRG banks $19/$1A provide attract demo functionality with sophisticated state machine architecture, country selection, camera focus, and enhanced data table organization, while banks $1B/$1C offer comprehensive map screen frame processing with ruler intro sequences

Key implementation references:
- Memory map and slot definitions in linker.cfg
- Bank indices and macros in include/namco163.h
- Consolidated bank stubs for PRG banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E in asm/banks/prg_08_09.asm, asm/banks/prg_0a_0b.asm, asm/banks/prg_0c_0d.asm, asm/banks/prg_0e_0f.asm, asm/banks/prg_17_18.asm, asm/banks/prg_19_1a.asm, asm/banks/prg_1b_1c.asm, and asm/banks/prg_1d_1e.asm
- Bank switching helpers in include/functions.h
- Boot bank 0x1F and vector table in bank_1f_analysis.md
- **New**: Attract demo system implementation in prg_19_1a.asm with complete state machine and helper functions, and map screen processing in prg_1b_1c.asm

**Section sources**
- [linker.cfg:14-30](file://linker.cfg#L14-L30)
- [PROJECT.md:70-117](file://PROJECT.md#L70-L117)
- [namco163.h:10-14](file://include/namco163.h#L10-L14)
- [functions.h:187-190](file://include/functions.h#L187-L190)
- [prg_1f.asm:1-148](file://asm/banks/prg_1f.asm#L1-L148)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)
- [prg_08_09.asm:46-109](file://asm/banks/prg_08_09.asm#L46-L109)
- [prg_19_1a.asm:16-52](file://asm/banks/prg_19_1a.asm#L16-L52)
- [prg_1b_1c.asm:16-54](file://asm/banks/prg_1b_1c.asm#L16-L54)

## Architecture Overview
The system uses a 4-slot PRG mapping scheme with 8KB banks. At reset, bank 0x1F is fixed in slot 3 ($E000-$FFFF). The remaining three slots ($8000-$DFFF) are switchable via mapper registers. **Updated**: PRG banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E are now managed as consolidated units, sharing the $A000-$DFFF address space through unified bank switching routines. Bank switching is performed by writing the desired bank number to specific addresses. **New**: The $19/$1A banks implement attract demo functionality with sophisticated state machine architecture, country selection, camera focus, and enhanced data table organization, while $1B/$1C provide comprehensive map screen frame processing with ruler intro sequences and province sprite management.

```mermaid
graph TB
CPU["6502 CPU"]
MAPPER["Namco-163 Mapper"]
REG8000["$F800<br/>Switch $8000-$9FFF"]
REGA000["$FA00<br/>Switch $A000-$BFFF"]
REGC000["$FC00<br/>Switch $C000-$DFFF"]
REGE000["$FE00<br/>Switch $E000-$FFFF"]
SWITCHAC["B1F_SwitchBankAC ($F237)<br/>Switch $A000-$BFFF + $C000-$DFFF"]
TRAMPOLINE["BankedCallbackTrampoline ($EE07)<br/>Dynamic function dispatch"]
DISPATCHER["CallbackDispatcher ($EADE)<br/>State-based routing"]
SWITCH0809["Consolidated $08/$09<br/>Battle & AI Systems"]
SWITCH0A0B["Consolidated $0A/$0B<br/>AI Turn Processing & Province Evaluation"]
SWITCH0C0D["Consolidated $0C/$0D<br/>Officer Exchange System"]
SWITCH0E0F["Consolidated $0E/$0F<br/>Battle Overlay System"]
SWITCH1718["Consolidated $17/$18<br/>Display & Battle Systems"]
SWITCH191A["Consolidated $19/$1A<br/>Attract Demo System with State Machine"]
SWITCH1B1C["Consolidated $1B/$1C<br/>Map Screen Frame Processing"]
SWITCH1D1E["Enhanced $1D/$1E<br/>SceneRenderer System"]
CPU --> REG8000
CPU --> REGA000
CPU --> REGC000
CPU --> REGE000
REG8000 --> MAPPER
REGA000 --> MAPPER
REGC000 --> MAPPER
REGE000 --> MAPPER
SWITCHAC --> MAPPER
TRAMPOLINE --> SWITCH0C0D
DISPATCHER --> SWITCH0C0D
SWITCH0809 --> MAPPER
SWITCH0A0B --> MAPPER
SWITCH0C0D --> MAPPER
SWITCH0E0F --> MAPPER
SWITCH1718 --> MAPPER
SWITCH191A --> MAPPER
SWITCH1B1C --> MAPPER
SWITCH1D1E --> MAPPER
```

**Diagram sources**
- [PROJECT.md:84-94](file://PROJECT.md#L84-L94)
- [namco163.h:10-14](file://include/namco163.h#L10-L14)
- [functions.h:187-188](file://include/functions.h#L187-L188)
- [prg_08_09.asm:1-7](file://asm/banks/prg_08_09.asm#L1-L7)
- [prg_0a_0b.asm:1-8](file://asm/banks/prg_0a_0b.asm#L1-L8)
- [prg_0c_0d.asm:1-8](file://asm/banks/prg_0c_0d.asm#L1-L8)
- [prg_0e_0f.asm:1-7](file://asm/banks/prg_0e_0f.asm#L1-L7)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_19_1a.asm:1-7](file://asm/banks/prg_19_1a.asm#L1-L7)
- [prg_1b_1c.asm:1-7](file://asm/banks/prg_1b_1c.asm#L1-L7)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)
- [prg_1f.asm:2376-2397](file://asm/banks/prg_1f.asm#L2376-L2397)

**Section sources**
- [PROJECT.md:84-117](file://PROJECT.md#L84-L117)
- [namco163.h:68-87](file://include/namco163.h#L68-L87)
- [functions.h:187-188](file://include/functions.h#L187-L188)

## Detailed Component Analysis

### 32-Bank Structure and Address Mapping
- Bank numbering: 0x00 through 0x1F (32 banks)
- Each bank: 8KB ($0000-$1FFF within bank)
- Slots:
  - $8000-$9FFF: Slot 0 (switchable via $F800)
  - $A000-$BFFF: Slot 1 (switchable via $FA00)
  - $C000-$DFFF: Slot 2 (switchable via $FC00)
  - $E000-$FFFF: Slot 3 (fixed boot bank 0x1F via $FE00)

**Updated**: PRG banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E are now consolidated into single 16KB blocks occupying both $A000-$BFFF and $C000-$DFFF. This consolidation allows the $A000-$BFFF and $C000-$DFFF slots to be switched as unified pairs using the SwitchBankAC routines. **New**: The $19/$1A banks implement attract demo functionality with sophisticated state machine architecture, country selection, camera focus, and enhanced data table organization, while $1B/$1C provide comprehensive map screen frame processing with ruler intro sequences.

Memory mapping configuration in linker.cfg:
- MEMORY regions define four PRG slots with fill and fillval
- SEGMENTS map code and data into these slots
- CODE segment defaults to PRG slot 0; optional CODE0/CODE1/CODE2/CODE3 map to slots 0/1/2/3 respectively
- RODATA segments can be placed in any slot

Practical distribution examples:
- Bank 0x00: $8000-$9FFF (mapped via slot 0)
- Bank 0x01: $A000-$BFFF (mapped via slot 1)
- **Updated**: Banks 0x08/$0x09: $A000-$DFFF (consolidated 16KB block via SwitchBankAC with battle and AI systems)
- **Updated**: Banks 0x0A/$0x0B: $A000-$DFFF (consolidated 16KB block via SwitchBankAC)
- **Updated**: Banks 0x0C/$0x0D: $A000-$DFFF (consolidated 16KB block via SwitchBankAC with advanced callback systems)
- **Updated**: Banks 0x0E/$0x0F: $A000-$DFFF (consolidated 16KB block via SwitchBankAC with battle overlay system)
- **Updated**: Banks 0x17/$0x18: $A000-$DFFF (consolidated 16KB block via SwitchBankAC)
- **Updated**: Banks 0x19/$0x1A: $A000-$DFFF (consolidated 16KB block via SwitchBankAC with attract demo system and sophisticated state machine)
- **Updated**: Banks 0x1B/$0x1C: $A000-$DFFF (consolidated 16KB block via SwitchBankAC with map screen processing)
- **Updated**: Banks 0x1D/$0x1E: $A000-$DFFF (consolidated 16KB block via B1F_SwitchBank1D1E)
- Bank 0x1F: $E000-$FFFF (boot bank, fixed)

**Section sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [PROJECT.md:70-83](file://PROJECT.md#L70-L83)
- [prg_00.asm:1-13](file://asm/banks/prg_00.asm#L1-L13)
- [prg_01.asm:1-13](file://asm/banks/prg_01.asm#L1-L13)
- [prg_08_09.asm:1-7](file://asm/banks/prg_08_09.asm#L1-L7)
- [prg_0a_0b.asm:1-8](file://asm/banks/prg_0a_0b.asm#L1-L8)
- [prg_0c_0d.asm:1-8](file://asm/banks/prg_0c_0d.asm#L1-L8)
- [prg_0e_0f.asm:1-7](file://asm/banks/prg_0e_0f.asm#L1-L7)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_19_1a.asm:1-7](file://asm/banks/prg_19_1a.asm#L1-L7)
- [prg_1b_1c.asm:1-7](file://asm/banks/prg_1b_1c.asm#L1-L7)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)
- [prg_1f.asm:1-13](file://asm/banks/prg_1f.asm#L1-L13)

### Fixed Boot Bank 0x1F at $E000-$FFFF
- Bank 0x1F is mapped to $E000-$FFFF at reset
- Contains reset handler, vector dispatch table, and core runtime functions
- Interrupt vectors are located at $FFFA-$FFFF:
  - NMI: $F800
  - RESET: $E000
  - IRQ: $FB2D

Boot sequence and dispatch:
- Reset handler initializes hardware, clears RAM, and reads the vector table at $E07C
- The vector table holds 15 entries (2 bytes each) for game states
- The state counter at $007A determines which entry to jump to

**Section sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [bank_1f_analysis.md:1-11](file://code/bank_1f_analysis.md#L1-L11)
- [bank_1f_analysis.md:22-45](file://code/bank_1f_analysis.md#L22-L45)
- [bank_1f_analysis.md:54-77](file://code/bank_1f_analysis.md#L54-L77)

### Three Switchable PRG Slots at $8000-$DFFF
- Slot 0: $8000-$9FFF (switchable via $F800)
- Slot 1: $A000-$BFFF (switchable via $FA00)
- Slot 2: $C000-$DFFF (switchable via $FC00)
- Slot 3: $E000-$FFFF (fixed to bank 0x1F via $FE00)

**Updated**: Consolidated bank switching for PRG banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E:
- The $A000-$BFFF and $C000-$DFFF slots are now managed as unified pairs
- Bank switching uses B1F_SwitchBankAC routines (B1F_SwitchBankAC_A/B) instead of individual $FA00/$FC00 writes
- Bank parameter Y determines both $A000-$BFFF and $C000-$DFFF banks simultaneously
- **New**: Specialized handling for banks $19/$1A with sophisticated attract demo state machine functionality and banks $1B/$1C with map screen processing following the established consolidation pattern

Bank switching macros:
- switch_bank_8000(BANK_XX)
- switch_bank_A000(BANK_XX)
- switch_bank_C000(BANK_XX)
- switch_bank_E000(BANK_XX)

**Section sources**
- [PROJECT.md:84-94](file://PROJECT.md#L84-L94)
- [namco163.h:68-87](file://include/namco163.h#L68-L87)
- [functions.h:187-188](file://include/functions.h#L187-L188)

### Memory Mapping Configuration in linker.cfg
- MEMORY:
  - ZEROPAGE: $0000-$00FF
  - RAM: $0100-$07FF
  - PRG_SLOT0: $8000-$9FFF
  - PRG_SLOT1: $A000-$BFFF
  - PRG_SLOT2: $C000-$DFFF
  - PRG_SLOT3: $E000-$FFFF
- SEGMENTS:
  - ZEROPAGE: maps to ZEROPAGE
  - BSS: maps to RAM
  - CODE: maps to PRG_SLOT0 (reset/NMI/IRQ vectors)
  - VECTORS: maps to PRG_SLOT0, starts at $9FFA
  - CODE0/CODE1/CODE2/CODE3: optional segments for banked code
  - RODATA/RODATA0/RODATA1/RODATA2: optional read-only data segments

**Updated**: Segment organization for consolidated banks:
- CODE_BANK08: load = BANK08, type = ro, optional = yes (maps to $A000-$BFFF)
- CODE_BANK09: load = BANK09, type = ro, optional = yes (maps to $C000-$DFFF)
- CODE_BANK0A: load = PRG_SLOT1, type = ro, optional = yes (maps to $A000-$BFFF)
- CODE_BANK0B: load = PRG_SLOT2, type = ro, optional = yes (maps to $C000-$DFFF)
- CODE_BANK0C: load = PRG_SLOT1, type = ro, optional = yes (maps to $A000-$BFFF)
- CODE_BANK0D: load = PRG_SLOT2, type = ro, optional = yes (maps to $C000-$DFFF)
- **Updated**: CODE_BANK0E: load = BANK0E, type = ro, optional = yes (maps to $A000-$BFFF)
- **Updated**: CODE_BANK0F: load = BANK0F, type = ro, optional = yes (maps to $C000-$DFFF)
- CODE_BANK17: load = PRG_SLOT1, type = ro, optional = yes (maps to $A000-$BFFF)
- CODE_BANK18: load = PRG_SLOT2, type = ro, optional = yes (maps to $C000-$DFFF)
- **Updated**: CODE_BANK19: load = BANK19, type = ro, optional = yes (maps to $A000-$BFFF)
- **Updated**: CODE_BANK1A: load = BANK1A, type = ro, optional = yes (maps to $C000-$DFFF)
- **Updated**: CODE_BANK1B: load = BANK1B, type = ro, optional = yes (maps to $A000-$BFFF)
- **Updated**: CODE_BANK1C: load = BANK1C, type = ro, optional = yes (maps to $C000-$DFFF)
- CODE_BANK1D: load = PRG_SLOT1, type = ro, optional = yes (maps to $A000-$BFFF)
- CODE_BANK1E: load = PRG_SLOT2, type = ro, optional = yes (maps to $C000-$DFFF)
- All segments share source files but are loaded into different slots for unified management

Segment organization strategy:
- Place reset/NMI/IRQ vectors in CODE/VECTORS so they remain accessible from slot 0
- Use CODE0/CODE1/CODE2/CODE3 to allocate additional code to slots 0/1/2/3
- Use RODATA segments to place constants and tables in appropriate slots
- **Updated**: Consolidated bank 08/09 code uses CODE_BANK08 and CODE_BANK09 segments for unified management with battle and AI systems
- **Updated**: Consolidated bank 0A/0B code uses CODE_BANK0A and CODE_BANK0B segments for unified management
- **Updated**: Consolidated bank 0C/0D code uses CODE_BANK0C and CODE_BANK0D segments for unified management with advanced callback systems
- **Updated**: Consolidated bank 0E/0F code uses CODE_BANK0E and CODE_BANK0F segments for unified management with battle overlay system
- **Updated**: Consolidated bank 17/18 code uses CODE_BANK17 and CODE_BANK18 segments for unified management
- **Updated**: Consolidated bank 19/1A code uses CODE_BANK19 and CODE_BANK1A segments for unified management with sophisticated attract demo state machine
- **Updated**: Consolidated bank 1B/1C code uses CODE_BANK1B and CODE_BANK1C segments for unified management with map screen processing
- **Updated**: Consolidated bank 1D/1E code uses CODE_BANK1D and CODE_BANK1E segments for unified management

**Section sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)

### Practical Distribution Examples
- Bank 0x00: $8000-$9FFF
  - Stub: asm/banks/prg_00.asm includes rom/prg/prg_00.bin
- Bank 0x01: $A000-$BFFF
  - Stub: asm/banks/prg_01.asm includes rom/prg/prg_01.bin
- **Updated**: Banks 0x08/$0x09: $A000-$DFFF (consolidated with comprehensive battle and AI systems)
  - Stub: asm/banks/prg_08_09.asm includes rom/prg/prg_08.bin and rom/prg/prg_09.bin
  - Contains dispatch handlers at $A000-$A02A including AiTurnProcess, BattleSetup, and BattleCasualtyResolution
  - Provides unified 16KB code space for AI turn processing, officer action decision-making, movement engines, and complete battle system
  - Implements sophisticated AI with province evaluation, army calculations, and strategic command validation
- **Updated**: Banks 0x0A/$0x0B: $A000-$DFFF (consolidated with enhanced AI system)
  - Stub: asm/banks/prg_0a_0b.asm includes rom/prg/prg_0a.bin and rom/prg/prg_0b.bin
  - Contains jump table and main dispatch at $A000-$A00E
  - Provides unified 16KB code space for AI turn processing, province evaluation, and battle system logic
- **Updated**: Banks 0x0C/$0x0D: $A000-$DFFF (consolidated following established pattern with advanced callback systems)
  - Stub: asm/banks/prg_0c_0d.asm includes rom/prg/prg_0c.bin and rom/prg/prg_0d.bin
  - Contains jump table and dispatch handlers at $A000-$A00E
  - **New**: Implements BankedCallbackTrampoline ($EE07) for dynamic function dispatching with inline target specifications
  - **New**: Features CallbackDispatcher ($EADE) for state-based routing with variable-length dispatch tables
  - **New**: Provides unified 16KB code space following the same consolidation pattern as other bank pairs
- **Updated**: Banks 0x0E/$0x0F: $A000-$DFFF (consolidated with comprehensive battle overlay system)
  - Stub: asm/banks/prg_0e_0f.asm includes rom/prg/prg_0e.bin and rom/prg/prg_0f.bin
  - Contains BattleVBlankFrameUpdate_Entry at $A000 with battle scene VBlank frame hook
  - Provides unified 16KB code space for battle overlay processing, phase-based state management, and player input handling
  - Implements comprehensive battle overlay system with VBlank frame processing, overlay strip rendering, and phase dispatch
- **Updated**: Banks 0x17/$0x18: $A000-$DFFF (consolidated)
  - Stub: asm/banks/prg_17_18.asm includes rom/prg/prg_17_18.bin
  - Contains domestic/kingdom display functions at $A000-$A029
  - Provides unified 16KB code space for both $A000-$BFFF and $C000-$DFFF
- **Updated**: Banks 0x19/$0x1A: $A000-$DFFF (consolidated with sophisticated attract demo state machine)
  - Stub: asm/banks/prg_19_1a.asm includes rom/prg/prg_19.bin and rom/prg/prg_1a.bin
  - Contains AttractDemoDispatch_Entry at $A003 with complete attract demo state machine
  - Provides unified 16KB code space for attract demo functionality with sophisticated state machine, country selection, camera focus, and enhanced data table organization
  - Implements comprehensive attract demo with CountrySelect, OverlayInit, OverlayPoll, and ResetCheck phases, plus helper functions for province counting, officer census building, and marker sprite drawing
- **Updated**: Banks 0x1B/$0x1C: $A000-$DFFF (consolidated with map screen processing)
  - Stub: asm/banks/prg_1b_1c.asm includes rom/prg/prg_1b.bin and rom/prg/prg_1c.bin
  - Contains MapScreenFrameUpdate_Entry at $A000 with map screen frame processing
  - Provides unified 16KB code space for map screen rendering, ruler intro sequences, and province sprite management
  - Implements comprehensive map screen frame processing with ruler marker drawing, province sprite refresh, and state-based frame handling
- **Updated**: Banks 0x1D/$0x1E: $A000-$DFFF (consolidated with enhanced display system)
  - Stub: asm/banks/prg_1d_1e.asm includes rom/prg/prg_1d_1e.bin
  - Contains jump table and menu handlers at $A000-$A047
  - Provides unified 16KB code space for both $A000-$BFFF and $C000-$DFFF
- Bank 0x1F: $E000-$FFFF
  - Stub: asm/banks/prg_1f.asm includes rom/prg/prg_1f.bin
  - Contains boot code and dispatch logic

**Updated**: Consolidated bank switching in practice:
- To call bank-switched functions in $A000-$A029, bank 0x1F writes a JMP instruction into RAM at $00A5 and also writes to mapper register $F800 to patch the mapper
- **Updated**: For consolidated bank 0x08/$0x09, bank 0x1F uses B1F_SwitchBankAC routines to switch both $A000-$BFFF and $C000-$DFFF simultaneously
- **Updated**: For consolidated bank 0x0A/$0x0B, bank 0x1F uses B1F_SwitchBankAC routines to switch both $A000-$BFFF and $C000-$DFFF simultaneously
- **Updated**: For consolidated bank 0x0C/$0x0D, bank 0x1F uses B1F_SwitchBankAC routines to switch both $A000-$BFFF and $C000-$DFFF simultaneously
- **Updated**: For consolidated bank 0x0E/$0x0F, bank 0x1F uses B1F_SwitchBankAC routines to switch both $A000-$BFFF and $C000-$DFFF simultaneously
- **Updated**: For consolidated bank 0x17/$0x18, bank 0x1F uses B1F_SwitchBankAC routines to switch both $A000-$BFFF and $C000-$DFFF simultaneously
- **Updated**: For consolidated bank 0x19/$0x1A, bank 0x1F uses B1F_SwitchBankAC routines to switch both $A000-$BFFF and $C000-$DFFF simultaneously with sophisticated attract demo state machine functionality
- **Updated**: For consolidated bank 0x1B/$0x1C, bank 0x1F uses B1F_SwitchBankAC routines to switch both $A000-$BFFF and $C000-$DFFF simultaneously with map screen processing
- **Updated**: For consolidated bank 0x1D/$0x1E, bank 0x1F uses B1F_SwitchBank1D1E routine to switch the entire $A000-$DFFF 16KB block
- Bank switching routine reads a configuration table and writes to mapper registers $C000/$C800/$D000/$D800

**Section sources**
- [prg_00.asm:1-13](file://asm/banks/prg_00.asm#L1-L13)
- [prg_01.asm:1-13](file://asm/banks/prg_01.asm#L1-L13)
- [prg_08_09.asm:1-7](file://asm/banks/prg_08_09.asm#L1-L7)
- [prg_0a_0b.asm:1-8](file://asm/banks/prg_0a_0b.asm#L1-L8)
- [prg_0c_0d.asm:1-8](file://asm/banks/prg_0c_0d.asm#L1-L8)
- [prg_0e_0f.asm:1-7](file://asm/banks/prg_0e_0f.asm#L1-L7)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_19_1a.asm:1-7](file://asm/banks/prg_19_1a.asm#L1-L7)
- [prg_1b_1c.asm:1-7](file://asm/banks/prg_1b_1c.asm#L1-L7)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)
- [prg_1f.asm:1-13](file://asm/banks/prg_1f.asm#L1-L13)
- [bank_1f_analysis.md:80-111](file://code/bank_1f_analysis.md#L80-L111)
- [bank_1f_analysis.md:499-533](file://code/bank_1f_analysis.md#L499-L533)

### Relationship Between Bank Numbers and Memory Addresses
- Bank 0x00 maps to $8000-$9FFF
- Bank 0x01 maps to $A000-$BFFF
- **Updated**: Banks 0x08/$0x09 map to $A000-$DFFF (consolidated 16KB block with battle and AI systems)
- **Updated**: Banks 0x0A/$0x0B map to $A000-$DFFF (consolidated 16KB block)
- **Updated**: Banks 0x0C/$0x0D map to $A000-$DFFF (consolidated 16KB block with advanced callback systems)
- **Updated**: Banks 0x0E/$0x0F map to $A000-$DFFF (consolidated 16KB block with battle overlay system)
- **Updated**: Banks 0x17/$0x18 map to $A000-$DFFF (consolidated 16KB block)
- **Updated**: Banks 0x19/$0x1A map to $A000-$DFFF (consolidated 16KB block with sophisticated attract demo state machine)
- **Updated**: Banks 0x1B/$0x1C map to $A000-$DFFF (consolidated 16KB block with map screen processing)
- **Updated**: Banks 0x1D/$0x1E map to $A000-$DFFF (consolidated 16KB block)
- Bank 0x1F maps to $E000-$FFFF (fixed)

**Updated**: Consolidated bank relationship:
- Bank 0x08 provides code for $A000-$BFFF (slot 1) paired with bank 0x09 at $C000-$DFFF (slot 2)
- Bank 0x0A provides code for $A000-$BFFF (slot 1) paired with bank 0x0B at $C000-$DFFF (slot 2)
- **New**: Bank 0x0C provides code for $A000-$BFFF (slot 1) paired with bank 0x0D at $C000-$DFFF (slot 2)
- **New**: Bank 0x0E provides code for $A000-$BFFF (slot 1) paired with bank 0x0F at $C000-$DFFF (slot 2)
- **New**: Bank 0x19 provides code for $A000-$BFFF (slot 1) paired with bank 0x1A at $C000-$DFFF (slot 2)
- **New**: Bank 0x1B provides code for $A000-$BFFF (slot 1) paired with bank 0x1C at $C000-$DFFF (slot 2)
- Together they form unified 16KB blocks at $A000-$DFFF managed by consolidated bank switching
- Bank switching uses B1F_SwitchBankAC routines to manage both slots simultaneously

This mapping is enforced by the mapper registers:
- $F800 selects bank for $8000-$9FFF
- $FA00 selects bank for $A000-$BFFF
- $FC00 selects bank for $C000-$DFFF
- $FE00 selects bank for $E000-$FFFF

**Section sources**
- [PROJECT.md:84-94](file://PROJECT.md#L84-L94)
- [namco163.h:10-14](file://include/namco163.h#L10-L14)
- [functions.h:316-332](file://include/functions.h#L316-L332)

### 6502 Address Space Utilization
- $0000-$07FF: 2KB RAM (including zero page)
- $2000-$2007: PPU registers
- $4000-$401F: APU/IO registers
- $6000-$7FFF: SRAM (8KB)
- $8000-$FFFF: PRG ROM (switchable 8KB banks)
  - $8000-$9FFF: Slot 0 (switchable)
  - $A000-$BFFF: Slot 1 (switchable)
  - $C000-$DFFF: Slot 2 (switchable)
  - $E000-$FFFF: Slot 3 (boot bank 0x1F)

**Updated**: Consolidated bank utilization:
- $A000-$BFFF: Slot 1 - Bank 0x08 (battle and AI systems), Bank 0x0A (enhanced AI/province evaluation), Bank 0x0C (new consolidated module with callback systems), Bank 0x0E (battle overlay system), Bank 0x17 (display systems), Bank 0x19 (sophisticated attract demo state machine), Bank 0x1B (map screen processing), and Bank 0x1D (enhanced display system)
- $C000-$DFFF: Slot 2 - Bank 0x09 (paired with bank 0x08), Bank 0x0B (paired with bank 0x0A), Bank 0x0D (paired with bank 0x0C), Bank 0x0F (paired with bank 0x0E), Bank 0x18 (paired with bank 0x17), Bank 0x1A (paired with bank 0x19), Bank 0x1C (paired with bank 0x1B), and Bank 0x1E (paired with bank 0x1D)
- Unified 16KB blocks at $A000-$DFFF managed by consolidated bank switching
- Bank switching occurs by writing to mapper registers at $F800-$FE00. The mapper decodes the bank number and maps it into the selected 8KB window. **Updated**: Consolidated banks use specialized switching routines for unified management.

**Section sources**
- [linker.cfg:4-12](file://linker.cfg#L4-L12)
- [PROJECT.md:70-83](file://PROJECT.md#L70-L83)
- [PROJECT.md:84-94](file://PROJECT.md#L84-L94)
- [functions.h:316-332](file://include/functions.h#L316-L332)

### Bank Switching Mechanisms
- Writing bank number to $F800 switches $8000-$9FFF
- Writing bank number to $FA00 switches $A000-$BFFF
- Writing bank number to $FC00 switches $C000-$DFFF
- Writing bank number to $FE00 switches $E000-$FFFF

**Updated**: Consolidated bank switching:
- B1F_SwitchBankAC_A/B routines switch both $A000-$BFFF and $C000-$DFFF simultaneously
- Uses bank parameter Y to set both slots to related bank numbers
- Bank 0x08 at $A000-$BFFF paired with bank 0x09 at $C000-$DFFF (comprehensive battle and AI systems)
- Bank 0x0A at $A000-$BFFF paired with bank 0x0B at $C000-$DFFF (enhanced AI/province evaluation)
- **New**: Bank 0x0C at $A000-$BFFF paired with bank 0x0D at $C000-$DFFF (new consolidated module with advanced callback systems)
- **New**: Bank 0x0E at $A000-$BFFF paired with bank 0x0F at $C000-$DFFF (battle overlay system)
- Bank 0x17 at $A000-$BFFF paired with bank 0x18 at $C000-$DFFF (display systems)
- **New**: Bank 0x19 at $A000-$BFFF paired with bank 0x1A at $C000-$DFFF (sophisticated attract demo state machine)
- **New**: Bank 0x1B at $A000-$BFFF paired with bank 0x1C at $C000-$DFFF (map screen processing)
- Bank 0x1D at $A000-$BFFF paired with bank 0x1E at $C000-$DFFF (enhanced display system)
- B1F_SwitchBank1D1E routine switches the entire $A000-$DFFF 16KB block for banks 0x1D/$0x1E

**New**: BankedCallbackTrampoline system ($EE07):
- Enables dynamic function dispatching with inline target specifications
- Pattern: LDY #bank; JSR $EE07; .word target_addr
- Automatically handles bank switching and restoration
- Supports multiple consecutive targets for complex dispatch scenarios

**New**: CallbackDispatcher system ($EADE):
- Provides state-based routing with variable-length dispatch tables
- Table length determined by maximum index value before JSR call
- Enables efficient multi-state function routing without conditional branches

The bank switching routine in bank 0x1F demonstrates how configurations are applied:
- Reads a table of 8-byte bank configurations
- Writes the first 4 bytes to mapper registers $C000/$C800/$D000/$D800
- Stores the last 4 bytes in RAM for later use

**Section sources**
- [PROJECT.md:84-94](file://PROJECT.md#L84-L94)
- [functions.h:187-188](file://include/functions.h#L187-L188)
- [bank_1f_analysis.md:499-533](file://code/bank_1f_analysis.md#L499-L533)
- [prg_1f.asm:2376-2397](file://asm/banks/prg_1f.asm#L2376-L2397)

### Attract Demo System in Banks $19/$1A
**New**: Major expansion of PRG banks $19/$1A introduces comprehensive attract demo functionality with sophisticated state machine architecture:

#### Complete Attract Demo State Machine
**New**: Sophisticated attract demo with complete state machine implementation:
- **AttractDemoDispatch**: Main attract demo dispatcher with 4 distinct phases (CountrySelect, OverlayInit, OverlayPoll, ResetCheck) using CallbackDispatcher for state-based routing
- **CountrySelect**: Country selection sub-state with rotation step management, officer census building, province counting, and transition to camera-focus mode
- **OverlayInit**: Status overlay initialization with country information display, province count setup, and camera positioning to ruler's home province
- **OverlayPoll**: Interactive overlay polling with Start button detection for demo exit and integration with slow periodic updates
- **ResetCheck**: Demo idle state with soft reset capability when too few officers remain

#### Advanced Helper Functions and Data Tables
**New**: Comprehensive helper functions and organized data structures:
- **ProvinceCountByOwner**: Counts provinces owned by specific countries for display purposes with efficient province record scanning
- **MarkerSpriteDraw**: Draws interactive marker sprites for country selection with optimized OAM writing
- **FindOfficerProvince**: Locates officer positions within province rosters through systematic scanning
- **DecayCountryTimers**: Manages packed-nibble timers for country records with efficient field processing
- **AttractDemoCensusBuild**: Builds country lists and performs officer census calculations with SRAM integration

#### Enhanced Data Table Organization
**New**: Structured data tables for improved maintainability:
- **CountryRecordPtrTable**: Organized pointer table for 7 country records with consistent stride
- **ProvinceCountDisplayTable**: Lookup table mapping province counts (0-31) to display values
- **AttractCountryOrderTable**: 5-row rotation order table (8 entries each) defining country selection sequences
- **Demo RAM Layout**: Organized memory layout at $6F00-$6F45 for demo state management

#### Player Interaction and Camera Control
**New**: Sophisticated player interaction and camera control:
- **Camera positioning**: Automatic camera targeting based on ruler's home province with smooth transitions
- **Input handling**: Start button detection for demo exit and transition to title screen
- **Status overlays**: Dynamic display of country information and province counts
- **Animation integration**: Smooth camera transitions and sprite animations

**Section sources**
- [prg_19_1a.asm:16-52](file://asm/banks/prg_19_1a.asm#L16-L52)
- [prg_19_1a.asm:68-155](file://asm/banks/prg_19_1a.asm#L68-L155)
- [prg_19_1a.asm:185-252](file://asm/banks/prg_19_1a.asm#L185-L252)
- [prg_19_1a.asm:259-330](file://asm/banks/prg_19_1a.asm#L259-L330)
- [prg_19_1a.asm:378-423](file://asm/banks/prg_19_1a.asm#L378-L423)

### Map Screen Frame Processing in Banks $1B/$1C
**New**: Major expansion of PRG banks $1B/$1C introduces comprehensive map screen frame processing:

#### Complete Map Screen Frame Processing
**New**: Sophisticated map screen frame update system:
- **MapScreenFrameUpdate**: Main map screen frame handler with ruler marker drawing, province sprite refresh, and state machine dispatch
- **MapScreenFrameStateDispatch**: Frame state dispatcher with 15 states covering ruler intro, camera sync, and various UI modes
- **MapRulerIntroInit**: Ruler introduction sequence initialization with province ownership checking and UI mode setup
- **MapRulerIntroCameraSync**: Interactive camera synchronization with province selection and input handling
- **MapRulerIntroWait**: Transition waiting state with busy flag monitoring

#### Advanced Ruler Introduction Sequence
**New**: Comprehensive ruler introduction system:
- **Province ownership checking**: Determines if ruler owns all 30 provinces for ending/unification scenes
- **Camera positioning**: Automatic camera targeting to ruler's home province with smooth transitions
- **Input handling**: A-button province selection, B/Select button cancellation, and edge detection
- **UI mode management**: Seamless transitions between attract/demo, ruler intro, and main game modes

#### Province Sprite Management
**New**: Advanced province sprite animation and refresh:
- **MapProvinceSpriteRefresh**: Rebuilds animated province marker sprites in OAM page $0200
- **Dirty bitmap management**: Tracks and updates province sprite changes efficiently
- **Animation phase tick**: Coordinates province sprite animations with game timing
- **Sprite optimization**: Minimizes unnecessary sprite updates for performance

**Section sources**
- [prg_1b_1c.asm:16-54](file://asm/banks/prg_1b_1c.asm#L16-L54)
- [prg_1b_1c.asm:131-169](file://asm/banks/prg_1b_1c.asm#L131-L169)
- [prg_1b_1c.asm:186-262](file://asm/banks/prg_1b_1c.asm#L186-L262)
- [prg_1b_1c.asm:268-278](file://asm/banks/prg_1b_1c.asm#L268-L278)

### Strategy Request Handler and Demo Event Playback
**New**: Enhanced strategy request handling and demo event playback sequencer in banks $19/$1A:

#### Strategy Request Dispatch System
**New**: Comprehensive strategy request processing with 17-entry state machine:
- **StrategyRequestDispatch**: Main dispatcher handling ruler panel operations, war deployment, and post-war menus
- **RequestPoll**: Centralized polling mechanism for strategy layer requests with result code handling
- **ArmyDeploySceneTrigger**: Coordinated army deployment scene triggering with proper state management
- **PostWarRulerMenu**: Post-war ruler menu handling with proper cleanup and state transitions

#### Demo Event Playback Sequencer
**New**: Sophisticated demo event playback with 16-entry state machine:
- **DemoEventPlaybackDispatch**: Complete attract demo event sequencer playing simulated turns for focused country
- **PlaybackPaceGate**: Timing control with overlay sentinels and demo step routing
- **PlaybackStepRoute**: Event routing based on demo steps (damage, loss, reinforcement scenes)
- **ProvinceRecountScenes**: Automated troop and gold recounting across all provinces
- **OfficerManagementScenes**: Officer reinforcement, removal, succession, and reassessment scenes

#### Unification Ending Sequences
**New**: Complete unification ending system triggered when ruler owns all 30 provinces:
- **UnificationEndingDispatch**: End-game celebration sequence with census calculation and scoring
- **CensusRecount**: Comprehensive census of provinces, officers, and resources
- **BestOfficerSelection**: Identification and display of best performing officer
- **VerdictSystem**: Scoring system determining ending tier based on performance metrics

**Section sources**
- [prg_19_1a.asm:421-5267](file://asm/banks/prg_19_1a.asm#L421-L5267)
- [prg_19_1a.asm:4810-4843](file://asm/banks/prg_19_1a.asm#L4810-L4843)

### Officer Status Display and Province Officer Roster Management
**New**: Comprehensive officer status display and province officer roster management systems:

#### Province Officer Roster Dispatch
**New**: Advanced officer roster display with scrolling card carousel:
- **ProvinceOfficerRosterDispatch**: Main dispatcher for province officer roster viewing with 5 sub-states
- **CardPanelSetup**: Card panel window configuration and parameter setup
- **RosterScroll**: Smooth scrolling animation with row-based navigation
- **CardAnimation**: 32-byte PPU strip record generation with frame-by-frame animation

#### Officer Status Scene Integration
**New**: Integrated officer status scene with shared sub-states:
- **OfficerStatusScene**: Shared sub-states for officer management across different game modes
- **OfficerReinforcement**: Officer arrival and assignment to provinces
- **OfficerRemoval**: Probabilistic officer defection and removal mechanics
- **RulerSuccession**: Officer transfer and new ruler coronation procedures

#### Enhanced Data Extraction Tools
**New**: Comprehensive officer and province data extraction capabilities:
- **Officer Data Analysis**: Complete analysis of 237 officers with detailed field mappings and validation
- **Province Data Analysis**: Comprehensive documentation of 30 provinces with starting conditions and relationships
- **Field Validation**: Code-backed verification of all data field offsets and usage patterns
- **Cross-Reference Integration**: Links between officers, provinces, and game mechanics

**Section sources**
- [prg_19_1a.asm:2182-2202](file://asm/banks/prg_19_1a.asm#L2182-L2202)
- [extract_officer_data.py:1-200](file://tools/extract_officer_data.py#L1-L200)
- [extract_province_data.py:1-200](file://tools/extract_province_data.py#L1-L200)
- [officer_data.md:1-200](file://docs/officer_data.md#L1-L200)
- [province_data.md:1-200](file://docs/province_data.md#L1-L200)

### Memory Overlap Considerations
- Bank 0x1F is fixed in slot 3 ($E000-$FFFF) at boot
- Other banks can be mapped into slots 0/1/2 at runtime
- **Updated**: Consolidated banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E overlap in the $A000-$DFFF region but are managed as unified pairs
- Care must be taken when bank-switching to avoid clobbering code or data currently resident in the target slot
- **Updated**: Consolidated bank switching uses B1F_SwitchBankAC and B1F_SwitchBank1D1E routines to prevent slot conflicts
- Bank 0x1F's bank-switching routine stores configuration in RAM ($00E6-$00ED) to preserve state across switches

**Section sources**
- [PROJECT.md:116-117](file://PROJECT.md#L116-L117)
- [bank_1f_analysis.md:499-533](file://code/bank_1f_analysis.md#L499-L533)
- [functions.h:316-332](file://include/functions.h#L316-L332)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)

### Rationale Behind the 8KB Bank Size Limitation
- 8KB aligns with the mapper's granularity for PRG bank switching
- Provides sufficient space for code and data while keeping the number of banks manageable (32 banks)
- Allows efficient bank switching with minimal overhead
- **Updated**: Consolidation of banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E demonstrates the benefits of unified management for related functionality
- The linker.cfg and bank stubs reflect this constraint by organizing code into 8KB segments
- **Updated**: Consolidated approach reduces complexity for related functions that benefit from shared memory space while maintaining the flexibility of the underlying 8KB architecture

**Section sources**
- [linker.cfg:14-16](file://linker.cfg#L14-L16)
- [PROJECT.md:8-12](file://PROJECT.md#L8-L12)
- [prg_08_09.asm:1-7](file://asm/banks/prg_08_09.asm#L1-L7)
- [prg_0a_0b.asm:1-8](file://asm/banks/prg_0a_0b.asm#L1-L8)
- [prg_0c_0d.asm:1-8](file://asm/banks/prg_0c_0d.asm#L1-L8)
- [prg_0e_0f.asm:1-7](file://asm/banks/prg_0e_0f.asm#L1-L7)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_19_1a.asm:1-7](file://asm/banks/prg_19_1a.asm#L1-L7)
- [prg_1b_1c.asm:1-7](file://asm/banks/prg_1b_1c.asm#L1-L7)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)

## Dependency Analysis
The bank organization depends on several components working together:
- linker.cfg defines the memory layout and segment-to-slot mapping
- include/namco163.h provides bank indices and macros for bank switching
- **Updated**: include/functions.h provides consolidated bank switching helpers (B1F_SwitchBankAC_A/B and B1F_SwitchBank1D1E)
- asm/banks/* stubs include the ROM binaries for each bank
- **Updated**: Consolidated bank stubs for PRG banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E in asm/banks/prg_08_09.asm, asm/banks/prg_0a_0b.asm, asm/banks/prg_0c_0d.asm, asm/banks/prg_0e_0f.asm, asm/banks/prg_17_18.asm, asm/banks/prg_19_1a.asm, asm/banks/prg_1b_1c.asm, and asm/banks/prg_1d_1e.asm
- bank_1f_analysis.md documents the boot bank's role and dispatch mechanism
- **New**: Attract demo system implementation in prg_19_1a.asm with sophisticated state machine and helper functions, and map screen processing in prg_1b_1c.asm
- **New**: Enhanced data extraction tools providing comprehensive analysis of officer and province data

```mermaid
graph TB
LCFG["linker.cfg"]
N163["include/namco163.h"]
FUNCS["include/functions.h<br/>(Consolidated Bank Switching)"]
STUBS["asm/banks/*.asm<br/>(Consolidated PRG 08/09, 0A/0B, 0C/0D, 0E/0F, 17/18, 19/1A, 1B/1C & 1D/1E)"]
ENHANCED_AI["PRG 08/09 Battle & AI Systems<br/>Comprehensive Turn Processing & Battle Resolution"]
ENHANCED_AI2["PRG 0A/0B Enhanced AI System<br/>Province Evaluation & Battle Logic"]
NEW_OFFICER_EXCHANGE["PRG 0C/0D New Officer Exchange System<br/>with Callback Systems"]
BATTLE_OVERLAY["PRG 0E/0F Battle Overlay System<br/>VBlank Processing & Phase Management"]
DISPLAY_SYSTEMS["PRG 17/18 Display Systems<br/>Strategy Mode Rendering"]
ATTRACT_DEMO["PRG 19/1A Attract Demo System<br/>Sophisticated State Machine & Camera Focus"]
MAP_SCREEN["PRG 1B/1C Map Screen Processing<br/>Ruler Intro & Province Sprites"]
ENHANCED_DISPLAY["PRG 1D/1E Enhanced System<br/>Zero-Page Variables & SceneRenderer"]
ROM["rom/prg/*.bin"]
BOOT["bank_1f_analysis.md"]
ANALYSIS_TOOLS["Analysis Tools Suite<br/>(Callback Analysis & Verification)"]
VERIFICATION_TOOLS["Verification Tools<br/>(Byte-Exact ROM Matching)"]
INIT_TOOLS["Initialization Tools<br/>(Attract Demo Setup)"]
EXTRACTION_TOOLS["Data Extraction Tools<br/>(Officer & Province Analysis)"]
DATA_DOCS["Documentation<br/>(Officer & Province Data)"]
LCFG --> STUBS
N163 --> STUBS
FUNCS --> STUBS
ENHANCED_AI --> STUBS
ENHANCED_AI2 --> STUBS
NEW_OFFICER_EXCHANGE --> STUBS
BATTLE_OVERLAY --> STUBS
DISPLAY_SYSTEMS --> STUBS
ATTRACT_DEMO --> STUBS
MAP_SCREEN --> STUBS
ENHANCED_DISPLAY --> STUBS
ROM --> STUBS
BOOT --> STUBS
ANALYSIS_TOOLS --> NEW_OFFICER_EXCHANGE
VERIFICATION_TOOLS --> ATTRACT_DEMO
VERIFICATION_TOOLS --> MAP_SCREEN
INIT_TOOLS --> ATTRACT_DEMO
EXTRACTION_TOOLS --> DATA_DOCS
DATA_DOCS --> STUBS
```

**Diagram sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [namco163.h:30-62](file://include/namco163.h#L30-L62)
- [functions.h:187-188](file://include/functions.h#L187-L188)
- [all_banks.asm:13](file://asm/banks/all_banks.asm#L13)
- [all_banks.asm:14](file://asm/banks/all_banks.asm#L14)
- [all_banks.asm:16](file://asm/banks/all_banks.asm#L16)
- [all_banks.asm:17](file://asm/banks/all_banks.asm#L17)
- [all_banks.asm:26](file://asm/banks/all_banks.asm#L26)
- [all_banks.asm:27](file://asm/banks/all_banks.asm#L26)
- [all_banks.asm:28](file://asm/banks/all_banks.asm#L28)
- [prg_08_09.asm:1-7](file://asm/banks/prg_08_09.asm#L1-L7)
- [prg_0a_0b.asm:1-8](file://asm/banks/prg_0a_0b.asm#L1-L8)
- [prg_0c_0d.asm:1-8](file://asm/banks/prg_0c_0d.asm#L1-L8)
- [prg_0e_0f.asm:1-7](file://asm/banks/prg_0e_0f.asm#L1-L7)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_19_1a.asm:1-7](file://asm/banks/prg_19_1a.asm#L1-L7)
- [prg_1b_1c.asm:1-7](file://asm/banks/prg_1b_1c.asm#L1-L7)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)
- [bank_1f_analysis.md:1-11](file://code/bank_1f_analysis.md#L1-L11)
- [analyze_0c_0d_callbacks.py:1-20](file://tools/analyze_0c_0d_callbacks.py#L1-L20)
- [verify_0c_0d_directives.py:1-20](file://tools/verify_0c_0d_directives.py#L1-L20)
- [check_trampoline_pattern.py:1-20](file://tools/check_trampoline_pattern.py#L1-L20)
- [verify_19_1a.py:1-90](file://tools/verify_19_1a.py#L1-L90)
- [verify_1b_1c.py:1-90](file://tools/verify_1b_1c.py#L1-L90)
- [init_19_1a.py:1-285](file://tools/init_19_1a.py#L1-L285)
- [extract_officer_data.py:1-200](file://tools/extract_officer_data.py#L1-L200)
- [extract_province_data.py:1-200](file://tools/extract_province_data.py#L1-L200)
- [officer_data.md:1-200](file://docs/officer_data.md#L1-L200)
- [province_data.md:1-200](file://docs/province_data.md#L1-L200)

**Section sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [namco163.h:30-62](file://include/namco163.h#L30-L62)
- [functions.h:187-188](file://include/functions.h#L187-L188)
- [all_banks.asm:1-31](file://asm/banks/all_banks.asm#L1-L31)
- [prg_08_09.asm:1-7](file://asm/banks/prg_08_09.asm#L1-L7)
- [prg_0a_0b.asm:1-8](file://asm/banks/prg_0a_0b.asm#L1-L8)
- [prg_0c_0d.asm:1-8](file://asm/banks/prg_0c_0d.asm#L1-L8)
- [prg_0e_0f.asm:1-7](file://asm/banks/prg_0e_0f.asm#L1-L7)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_19_1a.asm:1-7](file://asm/banks/prg_19_1a.asm#L1-L7)
- [prg_1b_1c.asm:1-7](file://asm/banks/prg_1b_1c.asm#L1-L7)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)
- [bank_1f_analysis.md:1-11](file://code/bank_1f_analysis.md#L1-L11)

## Performance Considerations
- Bank switching involves writing to mapper registers and potentially updating RAM copies of bank registers
- **Updated**: Consolidated bank switching reduces switching overhead for related functions
- Frequent bank switching can introduce overhead; minimize unnecessary switches
- **Updated**: Consolidated banks eliminate the need for separate slot management for paired functionality
- Place frequently accessed data and code in the same bank to reduce switching frequency
- Use the bank switching configuration table to batch changes when possible
- **Updated**: Consolidated approach improves cache locality for related functions
- **Updated**: Unified 16KB blocks reduce memory fragmentation and improve code organization
- **New**: Attract demo system in banks $19/$1A provides efficient country selection with optimized camera positioning, state machine dispatch, and enhanced data table lookups
- **New**: Map screen processing in banks $1B/$1C offers optimized province sprite management with dirty bitmap tracking and animation phase coordination
- **New**: Callback systems minimize overhead for dynamic function dispatching and state-based routing
- **New**: Enhanced data extraction tools provide offline analysis capabilities without runtime performance impact

## Troubleshooting Guide
Common issues and resolutions:
- Incorrect bank mapping at runtime:
  - Verify mapper register writes and bank indices
  - Ensure bank switching macros are used consistently
  - **Updated**: For consolidated banks, use B1F_SwitchBankAC or B1F_SwitchBank1D1E routines instead of individual slot writes
- Vector table misreads:
  - Confirm the state counter mask and indexing logic
  - Validate vector table entries and bounds
- Bank collision:
  - Ensure bank-switched code does not overwrite active code in the target slot
  - Use RAM patches (e.g., $00A5) and mapper register writes carefully
  - **Updated**: Consolidated bank switching prevents slot conflicts through unified management
- **Updated**: Consolidated bank switching issues:
  - Verify B1F_SwitchBankAC parameter Y contains correct bank number
  - Verify B1F_SwitchBank1D1E routine is used for banks 0x1D/$0x1E
  - Ensure both $A000-$BFFF and $C000-$DFFF are intended for the same functional area
  - Check that bank 0x08 and 0x09 are properly paired in the switching routine
  - Check that bank 0x0A and 0x0B are properly paired in the switching routine
  - **New**: Check that bank 0x0C and 0x0D are properly paired in the switching routine
  - **New**: Check that bank 0x0E and 0x0F are properly paired in the switching routine
  - Check that bank 0x17 and 0x18 are properly paired in the switching routine
  - **New**: Check that bank 0x19 and 0x1A are properly paired in the switching routine with sophisticated attract demo state machine
  - **New**: Check that bank 0x1B and 0x1C are properly paired in the switching routine with map screen processing
  - **New**: Check that bank 0x1D and 0x1E are properly paired in the B1F_SwitchBank1D1E routine
  - **New**: Verify CODE_BANK08 and CODE_BANK09 segments are properly configured in linker.cfg
  - **New**: Ensure prg_08_09.asm follows the same consolidation pattern as other consolidated bank modules
- **New**: Attract demo system issues:
  - Verify AttractDemoDispatch flow through all 4 phases (CountrySelect, OverlayInit, OverlayPoll, ResetCheck)
  - Check country selection logic with rotation step management and officer census building
  - Verify camera positioning based on ruler's home province and province count display
  - Ensure Start button detection works correctly for demo exit and title screen transition
  - Check province ownership counting and ending/unification scene triggering
  - Verify helper functions (ProvinceCountByOwner, MarkerSpriteDraw, FindOfficerProvince, DecayCountryTimers, AttractDemoCensusBuild) are properly implemented
  - Check enhanced data table organization (CountryRecordPtrTable, ProvinceCountDisplayTable, AttractCountryOrderTable)
- **New**: Map screen processing issues:
  - Verify MapScreenFrameUpdate flow through ruler intro sequence states
  - Check province sprite refresh and dirty bitmap management
  - Ensure ruler marker drawing works correctly with camera position updates
  - Verify input handling for province selection and camera navigation
  - Check UI mode transitions between attract/demo, ruler intro, and main game modes
- **New**: Strategy request handler issues:
  - Verify StrategyRequestDispatch flow through all 17 sub-states
  - Check request polling mechanism and result code handling
  - Ensure proper state transitions between ruler panels, war deployment, and post-war menus
  - Verify army deployment scene triggering and cleanup procedures
- **New**: Demo event playback issues:
  - Verify DemoEventPlaybackDispatch flow through all 16 playback states
  - Check event pacing and timing controls
  - Ensure proper province recounting and officer management scenes
  - Verify unification ending sequence triggers and scoring calculations
- **New**: Data extraction tool issues:
  - Run extract_officer_data.py to verify 237 officers are properly extracted and validated
  - Run extract_province_data.py to verify 30 provinces are properly documented
  - Check field mappings against code evidence in the ROM
  - Verify cross-references between officers and provinces
- **New**: Byte-exact verification issues:
  - Run verify_19_1a.py to ensure banks $19/$1A assemble to exact ROM match
  - Run verify_1b_1c.py to ensure banks $1B/$1C assemble to exact ROM match
  - Check external stub generation for cross-bank references
  - Verify segment organization matches original ROM layout at $A000/$C000
  - Use init_19_1a.py for proper initialization of attract demo assembly

**Section sources**
- [bank_1f_analysis.md:54-77](file://code/bank_1f_analysis.md#L54-L77)
- [bank_1f_analysis.md:499-533](file://code/bank_1f_analysis.md#L499-L533)
- [functions.h:316-332](file://include/functions.h#L316-L332)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)
- [prg_08_09.asm:1-7](file://asm/banks/prg_08_09.asm#L1-L7)
- [prg_0c_0d.asm:1-8](file://asm/banks/prg_0c_0d.asm#L1-L8)
- [prg_19_1a.asm:16-52](file://asm/banks/prg_19_1a.asm#L16-L52)
- [prg_1b_1c.asm:16-54](file://asm/banks/prg_1b_1c.asm#L16-L54)
- [prg_19_1a.asm:421-5267](file://asm/banks/prg_19_1a.asm#L421-L5267)
- [extract_officer_data.py:1-200](file://tools/extract_officer_data.py#L1-L200)
- [extract_province_data.py:1-200](file://tools/extract_province_data.py#L1-L200)
- [analyze_0c_0d_callbacks.py:1-20](file://tools/analyze_0c_0d_callbacks.py#L1-L20)
- [verify_0c_0d_directives.py:1-20](file://tools/verify_0c_0d_directives.py#L1-L20)
- [check_trampoline_pattern.py:1-20](file://tools/check_trampoline_pattern.py#L1-L20)
- [verify_19_1a.py:1-90](file://tools/verify_19_1a.py#L1-L90)
- [verify_1b_1c.py:1-90](file://tools/verify_1b_1c.py#L1-L90)
- [init_19_1a.py:1-285](file://tools/init_19_1a.py#L1-L285)

## Conclusion
The Sango2DASM project employs a 32-bank, 8KB-per-bank scheme with four PRG slots on the 6502 address bus. Bank 0x1F is fixed at $E000-$FFFF and serves as the boot bank, while slots 0/1/2 are switchable via mapper registers. **Updated**: PRG banks $08/$09, $0A/$0B, $0C/$0D, $0E/$0F, $17/$18, $19/$1A, $1B/$1C, and $1D/$1E have been consolidated into unified 16KB blocks at $A000-$DFFF, managed through specialized bank switching routines. **New**: PRG banks $19/$1A provide a comprehensive attract demo system with sophisticated state machine architecture, country selection, camera focus, and enhanced data table organization, while banks $1B/$1C offer complete map screen frame processing with ruler intro sequences and province sprite management. **Updated**: PRG banks $08/$09 provide a comprehensive battle and AI system with sophisticated turn processing, officer action decision-making, movement engines, strategic command validation, and complete battle phase management with casualty resolution. **Updated**: PRG banks $0A/$0B provide enhanced AI turn processing with comprehensive province evaluation, army calculations, and battle system logic with extensive work area organization and SRAM integration. **Updated**: PRG banks $0C/$0D provide a comprehensive officer exchange system with 1760+ lines of documented code, complete state machine implementation with 5-phase exchange flow, officer management systems, command validation, army operations, and UI scene management. **Updated**: PRG banks $0E/$0F provide a comprehensive battle overlay system with VBlank frame processing, phase-based state management, and player input handling for battle scenarios. **Updated**: PRG banks $1D/$1E have undergone major refactoring with comprehensive zero-page variable organization, improved SceneRenderer callback architecture, and better code structure through systematic reorganization while maintaining complete functional equivalence. **New**: The BankedCallbackTrampoline ($EE07) and CallbackDispatcher ($EADE) systems enable sophisticated dynamic function dispatching and state-based routing throughout the codebase. **New**: Enhanced strategy request handler and demo event playback sequencer provide complete game flow management with 17-entry and 16-entry state machines respectively. **New**: Comprehensive officer status display and province officer roster management systems integrate seamlessly with the existing game architecture. **New**: Enhanced data extraction tools provide comprehensive analysis of 237 officers and 30 provinces with detailed field mappings, validation, and cross-reference capabilities. **New**: Unification ending sequences trigger when rulers achieve complete conquest, providing celebratory gameplay with census calculation and scoring systems. **New**: Byte-exact verification tools (verify_19_1a.py, verify_1b_1c.py) ensure consolidated bank assemblies match original ROM binaries precisely. **New**: Initialization tools (init_19_1a.py) provide robust setup and verification for attract demo assembly with byte-exact ROM matching. The linker.cfg defines the memory layout and segment-to-slot mapping, and the bank stubs integrate ROM binaries into the build. **Updated**: The consolidated approach simplifies management of related functionality while maintaining the flexibility of the 8KB bank architecture. **Updated**: Consolidated bank switching reduces overhead and improves code organization through unified 16KB block management. Bank switching is handled through macros and a configuration table, with specialized routines for consolidated bank management, enabling flexible code distribution across banks. Understanding these relationships is essential for accurate disassembly and reliable runtime behavior.