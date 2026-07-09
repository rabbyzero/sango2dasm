# Bank Organization and Memory Layout

<cite>
**Referenced Files in This Document**
- [linker.cfg](file://linker.cfg)
- [PROJECT.md](file://PROJECT.md)
- [namco163.h](file://include/namco163.h)
- [functions.h](file://include/functions.h)
- [all_banks.asm](file://asm/banks/all_banks.asm)
- [prg_00.asm](file://asm/banks/prg_00.asm)
- [prg_01.asm](file://asm/banks/prg_01.asm)
- [prg_17_18.asm](file://asm/banks/prg_17_18.asm)
- [prg_1d_1e.asm](file://asm/banks/prg_1d_1e.asm)
- [prg_1f.asm](file://asm/banks/prg_1f.asm)
- [bank_1f_analysis.md](file://code/bank_1f_analysis.md)
- [bank_1f_plan.md](file://code/bank_1f_plan.md)
- [Makefile](file://Makefile)
- [main.lst](file://build/main.lst)
- [assemble_prg_1d_1e.py](file://tools/assemble_prg_1d_1e.py)
</cite>

## Update Summary
**Changes Made**
- Updated PRG banks $1D/$1E section to reflect comprehensive zero-page variable organization with detailed workspace definitions
- Enhanced documentation of the improved SceneRenderer callback architecture with 6-stage rendering pipeline
- Added detailed analysis of enhanced RAM variable organization including display buffers, scene state management, and menu system variables
- Updated examples to show new data structures and improved code organization while maintaining functional equivalence
- Revised function references throughout the document to reflect systematic reorganization and better naming conventions

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
This document explains the bank organization and memory layout used by the Sango2DASM project for the Namco-163 (Mapper 19) implementation. It covers the 32-bank structure with 8KB banks, the fixed boot bank 0x1F mapped to $E000-$FFFF, the three switchable PRG slots at $8000-$DFFF, and the memory mapping configuration defined in linker.cfg. The document has been updated to reflect the recent consolidation of PRG banks $17/$18 and $1D/$1E into unified 16KB blocks at $A000-$DFFF, replacing the previous separate bank management approach with a consolidated bank switching mechanism. **Updated**: Recent major refactoring of PRG banks $1D/$1E includes comprehensive zero-page variable organization, improved SceneRenderer callback architecture, and better code structure through systematic reorganization while maintaining complete functional equivalence. Practical examples show how code is distributed across banks, how bank numbers relate to memory addresses, and how the 6502 address space is utilized. It also documents bank switching mechanisms, memory overlap considerations, and the rationale behind the 8KB bank size.

## Project Structure
The project organizes PRG banks as 32 individual 8KB files (rom/prg/prg_XX.bin), each mapped into one of four PRG slots on the 6502 address bus. The linker.cfg defines the four PRG slots and how segments are loaded into them. The bank stub files under asm/banks/ include the ROM binaries and provide placeholders for disassembly. The include/namco163.h file defines mapper registers and bank switching macros. **Updated**: PRG banks $17/$18 and $1D/$1E are now consolidated into single files that occupy both $A000-$BFFF and $C000-$DFFF, providing unified 16KB code spaces. **New**: PRG bank $1D/$1E has undergone major refactoring with comprehensive zero-page variable organization, improved SceneRenderer callback architecture, and better code structure through systematic reorganization.

```mermaid
graph TB
subgraph "ROM Banks"
B00["rom/prg/prg_00.bin"]
B01["rom/prg/prg_01.bin"]
B17_18["rom/prg/prg_17_18.bin (consolidated)"]
B1D_1E["rom/prg/prg_1d_1e.bin (refactored)"]
B1F["rom/prg/prg_1f.bin"]
end
subgraph "Assembler Stubs"
S00["asm/banks/prg_00.asm"]
S01["asm/banks/prg_01.asm"]
S17_18["asm/banks/prg_17_18.asm (consolidated)"]
S1D_1E["asm/banks/prg_1d_1e.asm (refactored)"]
S1F["asm/banks/prg_1f.asm"]
end
subgraph "Linker Configuration"
CFG["linker.cfg"]
end
B00 --> S00
B01 --> S01
B17_18 --> S17_18
B1D_1E --> S1D_1E
B1F --> S1F
S00 -. includes .-> CFG
S01 -. includes .-> CFG
S17_18 -. includes .-> CFG
S1D_1E -. includes .-> CFG
S1F -. includes .-> CFG
```

**Diagram sources**
- [all_banks.asm:28](file://asm/banks/all_banks.asm#L28)
- [prg_17_18.asm:1-800](file://asm/banks/prg_17_18.asm#L1-L800)
- [prg_1d_1e.asm:1-800](file://asm/banks/prg_1d_1e.asm#L1-L800)
- [linker.cfg:18-55](file://linker.cfg#L18-L55)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [all_banks.asm:1-37](file://asm/banks/all_banks.asm#L1-L37)

## Core Components
- 32 PRG banks × 8KB = 256KB total PRG ROM
- Four PRG slots on the 6502 address bus:
  - Slot 0: $8000-$9FFF (8KB)
  - Slot 1: $A000-$BFFF (8KB)
  - Slot 2: $C000-$DFFF (8KB)
  - Slot 3: $E000-$FFFF (8KB)
- Fixed boot bank 0x1F mapped to $E000-$FFFF at reset
- Bank switching controlled via mapper registers at $F800-$FE00
- **Updated**: Consolidated bank switching mechanism for PRG banks $17/$18 and $1D/$1E using unified 16KB blocks at $A000-$DFFF
- **New**: Enhanced display system with comprehensive zero-page variable organization and improved SceneRenderer callback architecture

Key implementation references:
- Memory map and slot definitions in linker.cfg
- Bank indices and macros in include/namco163.h
- Consolidated bank stubs for PRG banks $17/$18 and $1D/$1E in asm/banks/prg_17_18.asm and asm/banks/prg_1d_1e.asm
- Bank switching helpers in include/functions.h
- Boot bank 0x1F and vector table in bank_1f_analysis.md
- **New**: Enhanced zero-page variable organization with comprehensive workspace definitions and improved SceneRenderer callback system

**Section sources**
- [linker.cfg:14-30](file://linker.cfg#L14-L30)
- [PROJECT.md:70-117](file://PROJECT.md#L70-L117)
- [namco163.h:10-14](file://include/namco163.h#L10-L14)
- [functions.h:187-190](file://include/functions.h#L187-L190)
- [prg_1f.asm:1-148](file://asm/banks/prg_1f.asm#L1-L148)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)

## Architecture Overview
The system uses a 4-slot PRG mapping scheme with 8KB banks. At reset, bank 0x1F is fixed in slot 3 ($E000-$FFFF). The remaining three slots ($8000-$DFFF) are switchable via mapper registers. **Updated**: PRG banks $17/$18 and $1D/$1E are now managed as consolidated units, sharing the $A000-$DFFF address space through unified bank switching routines. **New**: PRG bank $1D/$1E features enhanced display functionality with comprehensive zero-page variable organization and improved SceneRenderer callback architecture. Bank switching is performed by writing the desired bank number to specific addresses.

```mermaid
graph TB
CPU["6502 CPU"]
MAPPER["Namco-163 Mapper"]
REG8000["$F800<br/>Switch $8000-$9FFF"]
REGA000["$FA00<br/>Switch $A000-$BFFF"]
REGC000["$FC00<br/>Switch $C000-$DFFF"]
REGE000["$FE00<br/>Switch $E000-$FFFF"]
SWITCHAC["B1F_SwitchBankAC ($F237)<br/>Switch $A000-$BFFF + $C000-$DFFF"]
SWITCH1D1E["B1F_SwitchBank1D1E ($F237)<br/>Switch $A000-$DFFF (16KB)"]
SCENERENDER["Enhanced SceneRenderer<br/>6-Stage Callback System"]
ZEROPAGE["Comprehensive Zero-Page<br/>Variable Organization"]
CPU --> REG8000
CPU --> REGA000
CPU --> REGC000
CPU --> REGE000
REG8000 --> MAPPER
REGA000 --> MAPPER
REGC000 --> MAPPER
REGE000 --> MAPPER
SWITCHAC --> MAPPER
SWITCH1D1E --> MAPPER
SWITCH1D1E --> SCENERENDER
SWITCH1D1E --> ZEROPAGE
```

**Diagram sources**
- [PROJECT.md:84-94](file://PROJECT.md#L84-L94)
- [namco163.h:10-14](file://include/namco163.h#L10-L14)
- [functions.h:187-188](file://include/functions.h#L187-L188)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)

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

**Updated**: PRG banks $17/$18 and $1D/$1E are now consolidated into single 16KB blocks occupying both $A000-$BFFF and $C000-$DFFF. **New**: PRG bank $1D/$1E contains comprehensive zero-page variable organization with detailed workspace definitions, improved SceneRenderer callback architecture, and enhanced display functionality. This consolidation allows the $A000-$BFFF and $C000-$DFFF slots to be switched as unified pairs using the SwitchBankAC routines.

Memory mapping configuration in linker.cfg:
- MEMORY regions define four PRG slots with fill and fillval
- SEGMENTS map code and data into these slots
- CODE segment defaults to PRG slot 0; optional CODE0/CODE1/CODE2/CODE3 map to slots 0/1/2/3 respectively
- RODATA segments can be placed in any slot

Practical distribution examples:
- Bank 0x00: $8000-$9FFF (mapped via slot 0)
- Bank 0x01: $A000-$BFFF (mapped via slot 1)
- **Updated**: Banks 0x17/$0x18: $A000-$DFFF (consolidated 16KB block via SwitchBankAC)
- **Updated**: Banks 0x1D/$0x1E: $A000-$DFFF (consolidated 16KB block via B1F_SwitchBank1D1E)
- **New**: Bank 0x1D/$0x1E includes comprehensive zero-page variable organization and improved SceneRenderer callback system
- Bank 0x1F: $E000-$FFFF (boot bank, fixed)

**Section sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [PROJECT.md:70-83](file://PROJECT.md#L70-L83)
- [prg_00.asm:1-13](file://asm/banks/prg_00.asm#L1-L13)
- [prg_01.asm:1-13](file://asm/banks/prg_01.asm#L1-L13)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
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

**Updated**: Consolidated bank switching for PRG banks $17/$18 and $1D/$1E:
- The $A000-$BFFF and $C000-$DFFF slots are now managed as unified pairs
- Bank switching uses B1F_SwitchBankAC routines (B1F_SwitchBankAC_A/B) instead of individual $FA00/$FC00 writes
- Bank parameter Y determines both $A000-$BFFF and $C000-$DFFF banks simultaneously
- **New**: B1F_SwitchBank1D1E routine specifically handles the $A000-$DFFF 16KB block for banks 0x1D/$0x1E
- **New**: Enhanced display system in bank 0x1D/$0x1E provides comprehensive zero-page variable organization and improved SceneRenderer callback architecture

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
- CODE_BANK17_18: load = PRG_SLOT1, type = ro, optional = yes (maps to $A000-$BFFF)
- CODE_BANK18: load = PRG_SLOT2, type = ro, optional = yes (maps to $C000-$DFFF)
- **New**: CODE_BANK1D: load = PRG_SLOT1, type = ro, optional = yes (maps to $A000-$BFFF)
- **New**: CODE_BANK1E: load = PRG_SLOT2, type = ro, optional = yes (maps to $C000-$DFFF)
- Both segments share the same source file (prg_1d_1e.asm) but are loaded into different slots

Segment organization strategy:
- Place reset/NMI/IRQ vectors in CODE/VECTORS so they remain accessible from slot 0
- Use CODE0/CODE1/CODE2/CODE3 to allocate additional code to slots 0/1/2/3
- Use RODATA segments to place constants and tables in appropriate slots
- **Updated**: Consolidated bank 17/18 code uses CODE_BANK17_18 segment for unified management
- **New**: Consolidated bank 1D/1E code uses CODE_BANK1D and CODE_BANK1E segments for unified management with comprehensive zero-page variable organization

**Section sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)

### Practical Distribution Examples
- Bank 0x00: $8000-$9FFF
  - Stub: asm/banks/prg_00.asm includes rom/prg/prg_00.bin
- Bank 0x01: $A000-$BFFF
  - Stub: asm/banks/prg_01.asm includes rom/prg/prg_01.bin
- **Updated**: Banks 0x17/$0x18: $A000-$DFFF (consolidated)
  - Stub: asm/banks/prg_17_18.asm includes rom/prg/prg_17_18.bin
  - Contains domestic/kingdom display functions at $A000-$A029
  - Provides unified 16KB code space for both $A000-$BFFF and $C000-$DFFF
- **Updated**: Banks 0x1D/$0x1E: $A000-$DFFF (consolidated with enhanced display system)
  - Stub: asm/banks/prg_1d_1e.asm includes rom/prg/prg_1d_1e.bin
  - Contains jump table and menu handlers at $A000-$A047
  - **New**: Comprehensive zero-page variable organization with detailed workspace definitions
  - **New**: Improved SceneRenderer callback architecture with 6-stage rendering pipeline
  - **New**: Enhanced display system with dedicated tilemap structures and improved formatting
  - Provides unified 16KB code space for both $A000-$BFFF and $C000-$DFFF
- Bank 0x1F: $E000-$FFFF
  - Stub: asm/banks/prg_1f.asm includes rom/prg/prg_1f.bin
  - Contains boot code and dispatch logic

**Updated**: Consolidated bank switching in practice:
- To call bank-switched functions in $A000-$A029, bank 0x1F writes a JMP instruction into RAM at $00A5 and also writes to mapper register $F800 to patch the mapper
- **Updated**: For consolidated bank 0x17/$0x18, bank 0x1F uses B1F_SwitchBankAC routines to switch both $A000-$BFFF and $C000-$DFFF simultaneously
- **New**: For consolidated bank 0x1D/$0x1E, bank 0x1F uses B1F_SwitchBank1D1E routine to switch the entire $A000-$DFFF 16KB block
- **New**: Enhanced display system provides efficient rendering through comprehensive zero-page variable organization and improved SceneRenderer callback architecture
- Bank switching routine reads a configuration table and writes to mapper registers $C000/$C800/$D000/$D800

**Section sources**
- [prg_00.asm:1-13](file://asm/banks/prg_00.asm#L1-L13)
- [prg_01.asm:1-13](file://asm/banks/prg_01.asm#L1-L13)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)
- [prg_1f.asm:1-13](file://asm/banks/prg_1f.asm#L1-L13)
- [bank_1f_analysis.md:80-111](file://code/bank_1f_analysis.md#L80-L111)
- [bank_1f_analysis.md:499-533](file://code/bank_1f_analysis.md#L499-L533)
- [prg_1d_1e.asm:1146-1161](file://asm/banks/prg_1d_1e.asm#L1146-L1161)
- [prg_1d_1e.asm:1193-1206](file://asm/banks/prg_1d_1e.asm#L1193-L1206)
- [prg_1d_1e.asm:1225-1238](file://asm/banks/prg_1d_1e.asm#L1225-L1238)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)

### Relationship Between Bank Numbers and Memory Addresses
- Bank 0x00 maps to $8000-$9FFF
- Bank 0x01 maps to $A000-$BFFF
- **Updated**: Banks 0x17/$0x18 map to $A000-$DFFF (consolidated 16KB block)
- **Updated**: Banks 0x1D/$0x1E map to $A000-$DFFF (consolidated 16KB block with enhanced display system)
- Bank 0x1F maps to $E000-$FFFF (fixed)

**Updated**: Consolidated bank relationship:
- Bank 0x17 provides code for $A000-$BFFF (slot 1)
- Bank 0x18 provides code for $C000-$DFFF (slot 2)
- Together they form a unified 16KB block at $A000-$DFFF
- **New**: Bank 0x1D provides code for $A000-$BFFF (slot 1) with comprehensive zero-page variable organization and improved SceneRenderer callback architecture
- **New**: Bank 0x1E provides code for $C000-$DFFF (slot 2) with supporting display functions
- Together they form a unified 16KB block at $A000-$DFFF with enhanced display capabilities
- Bank switching uses B1F_SwitchBankAC routines to manage both slots simultaneously
- **New**: Bank switching uses B1F_SwitchBank1D1E routine to manage the 16KB block with enhanced display support

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
- $A000-$BFFF: Slot 1 - Bank 0x17 (domestic/kingdom display) and Bank 0x1D (enhanced display system with comprehensive zero-page organization)
- $C000-$DFFF: Slot 2 - Bank 0x18 (paired with bank 0x17) and Bank 0x1E (paired with bank 0x1D)
- **New**: Unified 16KB block at $A000-$DFFF managed by consolidated bank switching with comprehensive zero-page variable organization and improved SceneRenderer callback architecture
- **New**: Enhanced display system provides efficient rendering through comprehensive workspace definitions and improved callback system

Bank switching occurs by writing to mapper registers at $F800-$FE00. The mapper decodes the bank number and maps it into the selected 8KB window. **Updated**: Consolidated banks use specialized switching routines for unified management with enhanced display support.

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
- Bank 0x17 at $A000-$BFFF paired with bank 0x18 at $C000-$DFFF
- **New**: B1F_SwitchBank1D1E routine switches the entire $A000-$DFFF 16KB block
- **New**: Bank 0x1D at $A000-$BFFF paired with bank 0x1E at $C000-$DFFF
- **New**: Enhanced display system provides comprehensive zero-page variable organization and improved SceneRenderer callback architecture
- **New**: Improved code organization maintains functional equivalence while enhancing maintainability

The bank switching routine in bank 0x1F demonstrates how configurations are applied:
- Reads a table of 8-byte bank configurations
- Writes the first 4 bytes to mapper registers $C000/$C800/$D000/$D800
- Stores the last 4 bytes in RAM for later use

**Section sources**
- [PROJECT.md:84-94](file://PROJECT.md#L84-L94)
- [functions.h:187-188](file://include/functions.h#L187-L188)
- [bank_1f_analysis.md:499-533](file://code/bank_1f_analysis.md#L499-L533)

### Enhanced Display System in PRG Banks $1D/$1E
**New**: Major refactoring of PRG banks $1D/$1E introduces significant improvements to the display system while maintaining complete functional equivalence:

#### Comprehensive Zero-Page Variable Organization
**New**: Extensive zero-page variable definitions organized into logical sections:
- **Zero-page scratch/workspace ($0000-$001F)**: General-purpose pointers, work variables, and temporary storage
- **Zero-page display/render state ($005E-$0074)**: Frame counters, display parameters, and scene renderer state
- **Zero-page state handler workspace ($00AE-$00DC)**: State management variables, VRAM counters, and row tracking
- **Page $01 workspace ($0100-$0190)**: Display pointer tables, tile buffers, and state management
- **Page $02 OAM buffer ($0200-$0203)**: Sprite buffer management
- **Page $03 display/render buffer ($037C-$03C3)**: Sub-state dispatch, display offsets, and render buffers
- **Page $04 menu/system state ($0400-$04D6)**: Scene callbacks, menu system, officer data, and display state

#### Improved SceneRenderer Callback Architecture
**New**: Enhanced 6-stage callback system for scene rendering:
- **SceneOfficerListInit**: Initialize officer list state registers
- **ScenePageCopy**: Copy scene page data with bank switch and palette update
- **SceneRenderSetup**: Scenario render setup with data loading and timer initialization
- **SceneSpriteSetup**: Sprite OAM setup and input-driven palette copy
- **SceneRenderExit3**: Alternate render exit with scenario data loading
- **SceneBufferFill**: Fill VRAM buffer page with initialization data

#### Enhanced Data Structures and Functions
**New**: Improved data handling and display functions:
- **DisplayScaledName**: Optimized katakana name rendering with scaling support
- **DisplayScaledNumber**: Efficient number display with formatting capabilities
- **DataFormatter_Table1/Table2**: Mode-specific formatting tables for different display scenarios
- **ProvinceDisplayTilemap**: Structured tilemap data for province information display
- **OfficerDisplayTilemap**: Dedicated tilemap for officer display with optimized layout
- **OfficerNameTilemap**: Specialized tilemap for officer name rendering

#### Systematic Code Reorganization
**New**: Better code structure through systematic reorganization:
- Clear separation of concerns between display, rendering, and data management
- Improved function naming conventions for better maintainability
- Enhanced comment documentation for complex algorithms
- Optimized memory access patterns for better performance

**Section sources**
- [prg_1d_1e.asm:19-259](file://asm/banks/prg_1d_1e.asm#L19-L259)
- [prg_1d_1e.asm:3179-3402](file://asm/banks/prg_1d_1e.asm#L3179-L3402)
- [prg_1d_1e.asm:1471-1566](file://asm/banks/prg_1d_1e.asm#L1471-L1566)
- [prg_1d_1e.asm:632-658](file://asm/banks/prg_1d_1e.asm#L632-L658)

### Memory Overlap Considerations
- Bank 0x1F is fixed in slot 3 ($E000-$FFFF) at boot
- Other banks can be mapped into slots 0/1/2 at runtime
- **Updated**: Consolidated banks $17/$18 and $1D/$1E overlap in the $A000-$DFFF region but are managed as unified pairs
- **New**: Enhanced display system in banks $1D/$1E requires careful management of comprehensive zero-page variables and display state
- Care must be taken when bank-switching to avoid clobbering code or data currently resident in the target slot
- **Updated**: Consolidated bank switching uses B1F_SwitchBankAC and B1F_SwitchBank1D1E routines to prevent slot conflicts
- **New**: Display system uses dedicated buffers at $0380-$03BF for tilemap data and temporary storage
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
- **Updated**: Consolidation of banks $17/$18 and $1D/$1E demonstrates the benefits of unified management for related functionality
- **New**: Enhanced display system in banks $1D/$1E shows how larger functional areas benefit from consolidated 16KB blocks with comprehensive zero-page organization
- The linker.cfg and bank stubs reflect this constraint by organizing code into 8KB segments
- **New**: Consolidated approach reduces complexity for related functions that benefit from shared memory space while maintaining the flexibility of the underlying 8KB architecture

**Section sources**
- [linker.cfg:14-16](file://linker.cfg#L14-L16)
- [PROJECT.md:8-12](file://PROJECT.md#L8-L12)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)

## Dependency Analysis
The bank organization depends on several components working together:
- linker.cfg defines the memory layout and segment-to-slot mapping
- include/namco163.h provides bank indices and macros for bank switching
- **Updated**: include/functions.h provides consolidated bank switching helpers (B1F_SwitchBankAC_A/B and B1F_SwitchBank1D1E)
- asm/banks/* stubs include the ROM binaries for each bank
- **Updated**: Consolidated bank stubs for PRG banks $17/$18 and $1D/$1E in asm/banks/prg_17_18.asm and asm/banks/prg_1d_1e.asm
- **New**: Enhanced display system in prg_1d_1e.asm includes comprehensive zero-page variable organization and improved SceneRenderer callback architecture
- bank_1f_analysis.md documents the boot bank's role and dispatch mechanism

```mermaid
graph TB
LCFG["linker.cfg"]
N163["include/namco163.h"]
FUNCS["include/functions.h<br/>(Consolidated Bank Switching)"]
STUBS["asm/banks/*.asm<br/>(Consolidated PRG 17/18 & 1D/1E)"]
ENHANCED["PRG 1D/1E Enhanced System<br/>Zero-Page Variables & SceneRenderer"]
ROM["rom/prg/*.bin"]
BOOT["bank_1f_analysis.md"]
LCFG --> STUBS
N163 --> STUBS
FUNCS --> STUBS
ENHANCED --> STUBS
ROM --> STUBS
BOOT --> STUBS
```

**Diagram sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [namco163.h:30-62](file://include/namco163.h#L30-L62)
- [functions.h:187-188](file://include/functions.h#L187-L188)
- [all_banks.asm:1-38](file://asm/banks/all_banks.asm#L1-L38)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)
- [bank_1f_analysis.md:1-11](file://code/bank_1f_analysis.md#L1-L11)

**Section sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [namco163.h:30-62](file://include/namco163.h#L30-L62)
- [functions.h:187-188](file://include/functions.h#L187-L188)
- [all_banks.asm:1-38](file://asm/banks/all_banks.asm#L1-L38)
- [prg_17_18.asm:1-8](file://asm/banks/prg_17_18.asm#L1-L8)
- [prg_1d_1e.asm:1-10](file://asm/banks/prg_1d_1e.asm#L1-L10)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)
- [bank_1f_analysis.md:1-11](file://code/bank_1f_analysis.md#L1-L11)

## Performance Considerations
- Bank switching involves writing to mapper registers and potentially updating RAM copies of bank registers
- **Updated**: Consolidated bank switching reduces switching overhead for related functions
- **New**: Enhanced display system in banks $1D/$1E provides optimized rendering through comprehensive zero-page variable organization
- **New**: B1F_SwitchBank1D1E routine eliminates the need for separate slot management for banks 0x1D/$0x1E
- Frequent bank switching can introduce overhead; minimize unnecessary switches
- **Updated**: Consolidated banks eliminate the need for separate slot management for paired functionality
- Place frequently accessed data and code in the same bank to reduce switching frequency
- Use the bank switching configuration table to batch changes when possible
- **New**: Enhanced display system improves performance through efficient zero-page variable access and optimized SceneRenderer callback system
- **New**: Comprehensive workspace organization reduces memory access overhead and improves cache locality
- **New**: Consolidated approach improves cache locality for related domestic/kingdom display functions
- **New**: Unified 16KB blocks reduce memory fragmentation and improve code organization

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
- **New**: Enhanced display system issues:
  - Verify comprehensive zero-page variable organization is properly initialized
  - Check SceneRenderer callback state machine progression through all 6 stages
  - Ensure proper memory allocation for display buffers and tilemap data
  - Verify OfficerDisplay_Lookup and OfficerNameDisplay functions use correct tilemap references
  - Check that DisplayScaledName and DisplayScaledNumber functions have proper data formatting
- **Updated**: Consolidated bank switching issues:
  - Verify B1F_SwitchBankAC parameter Y contains correct bank number
  - Verify B1F_SwitchBank1D1E routine is used for banks 0x1D/$0x1E
  - Ensure both $A000-$BFFF and $C000-$DFFF are intended for the same functional area
  - Check that bank 0x17 and 0x18 are properly paired in the switching routine
  - **New**: Check that bank 0x1D and 0x1E are properly paired in the B1F_SwitchBank1D1E routine
  - **New**: Verify comprehensive zero-page variable organization doesn't conflict with other system usage
  - **New**: Ensure SceneRenderer callback system properly manages state transitions and memory access

**Section sources**
- [bank_1f_analysis.md:54-77](file://code/bank_1f_analysis.md#L54-L77)
- [bank_1f_analysis.md:499-533](file://code/bank_1f_analysis.md#L499-L533)
- [functions.h:316-332](file://include/functions.h#L316-L332)
- [prg_1d_1e.asm:1287-1341](file://asm/banks/prg_1d_1e.asm#L1287-L1341)
- [prg_1d_1e.asm:19-259](file://asm/banks/prg_1d_1e.asm#L19-L259)
- [prg_1d_1e.asm:3179-3402](file://asm/banks/prg_1d_1e.asm#L3179-L3402)

## Conclusion
The Sango2DASM project employs a 32-bank, 8KB-per-bank scheme with four PRG slots on the 6502 address bus. Bank 0x1F is fixed at $E000-$FFFF and serves as the boot bank, while slots 0/1/2 are switchable via mapper registers. **Updated**: PRG banks $17/$18 and $1D/$1E have been consolidated into unified 16KB blocks at $A000-$DFFF, managed through specialized bank switching routines. **New**: PRG banks $1D/$1E have undergone major refactoring with comprehensive zero-page variable organization, improved SceneRenderer callback architecture, and better code structure through systematic reorganization while maintaining complete functional equivalence. The enhanced display system includes detailed workspace definitions, 6-stage rendering pipeline, and optimized data formatting capabilities. The linker.cfg defines the memory layout and segment-to-slot mapping, and the bank stubs integrate ROM binaries into the build. **Updated**: The consolidated approach simplifies management of related functionality while maintaining the flexibility of the 8KB bank architecture. **New**: Enhanced display system provides more efficient rendering through comprehensive zero-page variable organization and improved SceneRenderer callback architecture. Bank switching is handled through macros and a configuration table, with specialized routines for consolidated bank management, enabling flexible code distribution across banks. Understanding these relationships is essential for accurate disassembly and reliable runtime behavior.