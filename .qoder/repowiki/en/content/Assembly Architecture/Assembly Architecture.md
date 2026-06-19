# Assembly Architecture

<cite>
**Referenced Files in This Document**
- [linker.cfg](file://linker.cfg)
- [main.asm](file://asm/main.asm)
- [prg_1f.aligned.asm](file://asm/banks/prg_1f.aligned.asm)
- [prg_1f.asm.bak](file://asm/banks/prg_1f.asm.bak)
- [prg_1f_E843_F2AE.asm](file://asm/banks/prg_1f_E843_F2AE.asm)
- [prg_1f_F2AF_F3BC.asm](file://asm/banks/prg_1f_F2AF_F3BC.asm)
- [namco163.h](file://include/namco163.h)
- [6502_registers.h](file://include/6502_registers.h)
- [macros.h](file://include/macros.h)
- [all_banks.asm](file://asm/banks/all_banks.asm)
- [prg_00.asm](file://asm/banks/prg_00.asm)
- [prg_01.asm](file://asm/banks/prg_01.asm)
- [PROJECT.md](file://PROJECT.md)
</cite>

## Update Summary
**Changes Made**
- Updated documentation to reflect the complete transition from legacy CDL format to modern assembly syntax
- Removed references to deprecated pbank31.cdl.asm format while maintaining coverage of modern assembly practices
- Updated bank organization structure to reflect current prg_1f.aligned.asm format with enhanced code organization
- Revised formatting standards to match modern assembly conventions with proper label definitions and address mappings
- Enhanced debugging capabilities documentation through structured code organization and improved readability

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Modern Assembly Formatting Standards](#modern-assembly-formatting-standards)
7. [Enhanced Code Organization](#enhanced-code-organization)
8. [Debugging and Verification Tools](#debugging-and-verification-tools)
9. [Dependency Analysis](#dependency-analysis)
10. [Performance Considerations](#performance-considerations)
11. [Troubleshooting Guide](#troubleshooting-guide)
12. [Conclusion](#conclusion)

## Introduction
This document explains the assembly architecture for the Namco-163 (Mapper 19) implementation used in the disassembly of a classic NES strategy game. It focuses on the 32-bank structure with 8KB banks, the fixed boot bank at $E000-$FFFF, the switchable PRG slots at $8000-$DFFF, and the state machine orchestrated by the vector dispatch table at $E07C. The architecture now features modern assembly formatting standards with the new prg_1f.aligned.asm structure representing a complete rewrite using contemporary assembly syntax for enhanced code organization and debugging capabilities.

## Project Structure
The project is organized around a modular bank-based approach with modern assembly formatting standards:
- A central linker configuration defines memory layout and segments.
- A main entry module provides reset/NMI/IRQ stubs and initializes the mapper.
- A dedicated boot bank (0x1F) contains the reset handler, state dispatch table, and core runtime helpers in the new aligned format with comprehensive code organization.
- Separate bank stubs represent the remaining 31 banks, each mapped to a specific PRG slot.
- Modern assembly formatting standards provide improved readability and debugging support.

```mermaid
graph TB
subgraph "Linker Configuration"
LCFG["linker.cfg"]
end
subgraph "Boot Bank (0x1F) - Modern Assembly Format"
ALIGNED["asm/banks/prg_1f.aligned.asm<br/>Aligned Format with Structured Organization"]
BACKUP["asm/banks/prg_1f.asm.bak<br/>Backup of Legacy Format"]
VTABLE["$E07C VectorTable<br/>$E000 Reset Handler<br/>Structured State Handlers"]
end
subgraph "Mapper Layer"
NAMCO["include/namco163.h<br/>Bank Switch Macros"]
REGS["include/6502_registers.h<br/>PPU/APU/Namco-163 Regs"]
end
subgraph "Runtime Helpers"
MACROS["include/macros.h<br/>Common 6502 Macros"]
MAIN["asm/main.asm<br/>Reset/NMI/IRQ Stubs"]
end
subgraph "Other Banks"
ALLB["asm/banks/all_banks.asm"]
B00["asm/banks/prg_00.asm"]
B01["asm/banks/prg_01.asm"]
end
LCFG --> ALIGNED
LCFG --> BACKUP
MAIN --> ALIGNED
ALIGNED --> VTABLE
ALIGNED --> NAMCO
ALIGNED --> REGS
ALIGNED --> MACROS
ALLB --> B00
ALLB --> B01
```

**Diagram sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [prg_1f.aligned.asm:1-200](file://asm/banks/prg_1f.aligned.asm#L1-L200)
- [prg_1f.asm.bak:1-50](file://asm/banks/prg_1f.asm.bak#L1-L50)
- [namco163.h:65-87](file://include/namco163.h#L65-L87)
- [6502_registers.h:1-88](file://include/6502_registers.h#L1-L88)
- [macros.h:1-72](file://include/macros.h#L1-L72)
- [all_banks.asm:1-38](file://asm/banks/all_banks.asm#L1-L38)
- [prg_00.asm:1-13](file://asm/banks/prg_00.asm#L1-L13)
- [prg_01.asm:1-13](file://asm/banks/prg_01.asm#L1-L13)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [all_banks.asm:1-38](file://asm/banks/all_banks.asm#L1-L38)

## Core Components
- Fixed boot bank 0x1F mapped to $E000-$FFFF at startup with modern assembly formatting and structured code organization.
- Vector dispatch table at $E07C orchestrates game flow across execution contexts with enhanced code readability.
- Four PRG slots ($8000-$FFFF) managed by the Namco-163 mapper via write-only registers.
- Hardware abstraction layer for PPU/APU and mapper register access.
- Modular bank stubs representing 31 additional banks.
- Modern assembly formatting standards with proper label definitions and address mappings.

**Section sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [prg_1f.aligned.asm:400-466](file://asm/banks/prg_1f.aligned.asm#L400-L466)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)
- [6502_registers.h:6-39](file://include/6502_registers.h#L6-L39)

## Architecture Overview
The system uses a state machine driven by a vector table in the boot bank. The reset handler initializes hardware, clears RAM, and dispatches to the first state via an indirect jump. The mapper enables dynamic loading of code from other banks into PRG slots, allowing the state handlers to call bank-switched routines. The modern assembly format provides enhanced code organization with structured state handlers and improved debugging support.

```mermaid
sequenceDiagram
participant CPU as "CPU"
participant BOOT as "Boot Bank 0x1F (Aligned Format)"
participant MAP as "Namco-163 Mapper"
participant SLOTS as "PRG Slots ($8000-$DFFF)"
participant STATE as "State Handler (Banked)"
participant DEBUG as "Debug Tools"
CPU->>BOOT : Reset
BOOT->>BOOT : Initialize PPU/APU, clear RAM
BOOT->>BOOT : Read addr_game_state & mask to 0-31
BOOT->>BOOT : Load VectorTable entry (indirect)
BOOT->>MAP : Write bank numbers to mapper registers
MAP-->>SLOTS : Switch 8KB PRG banks into slots
BOOT->>STATE : Jump to state handler (banked)
STATE->>MAP : Optional bank switch for next state
STATE-->>BOOT : Return to StateDispatch
BOOT->>BOOT : Update addr_game_state and loop
DEBUG->>BOOT : Analyze aligned formatted code
DEBUG->>BOOT : Validate structured state handlers
```

**Diagram sources**
- [prg_1f.aligned.asm:406-459](file://asm/banks/prg_1f.aligned.asm#L406-L459)
- [prg_1f.aligned.asm:467-694](file://asm/banks/prg_1f.aligned.asm#L467-L694)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)
- [main.asm:115-121](file://asm/main.asm#L115-L121)

## Detailed Component Analysis

### Memory Mapping and Segment Organization
The linker configuration defines:
- Zero-page RAM and uninitialized RAM segments.
- Four PRG slots ($8000-$FFFF) sized 8KB each.
- Segments for code and read-only data, with optional assignments for additional banks.
- The CODE segment starts at PRG_SLOT0 and includes the interrupt vectors at $9FFA.

```mermaid
flowchart TD
MEM["Memory Map"] --> RAM["$0000-$07FF RAM"]
MEM --> PPUREG["$2000-$2007 PPU"]
MEM --> IOREG["$4000-$401F APU/IO"]
MEM --> EXPROM["$4800 Expansion (Namco-163)"]
MEM --> SRAM["$6000-$7FFF SRAM"]
MEM --> PRG["$8000-$FFFF PRG ROM (4 slots)"]
PRG --> SLOT0["$8000-$9FFF"]
PRG --> SLOT1["$A000-$BFFF"]
PRG --> SLOT2["$C000-$DFFF"]
PRG --> SLOT3["$E000-$FFFF (Boot Bank 0x1F)"]
```

**Diagram sources**
- [linker.cfg:4-12](file://linker.cfg#L4-L12)
- [linker.cfg:18-30](file://linker.cfg#L18-L30)
- [linker.cfg:32-54](file://linker.cfg#L32-L54)

**Section sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [PROJECT.md:70-83](file://PROJECT.md#L70-L83)

### Fixed Boot Bank 0x1F and Reset Flow (Modern Assembly Format)
- The reset handler at $E000 performs CPU initialization, PPU warmup, APU initialization, and RAM clearing.
- It initializes the mapper and sets the initial game state, then dispatches to the state handler via the vector table.
- The vector table at $E07C contains 15 entries, each a 2-byte address within bank 0x1F, organized in a structured aligned format.

**Updated** Enhanced with modern assembly formatting standards featuring structured code organization and improved readability.

```mermaid
flowchart TD
START(["Reset"]) --> INITCPU["SEI/CLD, Stack Setup<br/>$E000: 78 D8"]
INITCPU --> PPUWARM["PPU Warmup (VBlank)<br/>$E00C: AD 02 20"]
PPUWARM --> APUCLEAR["APU Init & Silence<br/>$E019: A9 00 8D 10 40"]
APUCLEAR --> RAMCLR["Clear RAM $0000-$07FF<br/>$E042: A9 04 8D 01 00"]
RAMCLR --> MAPINIT["Mapper Init (Set Banks)<br/>$E05E: 20 BD F3"]
MAPINIT --> READSTATE["Load addr_game_state & mask<br/>$E066: AD 7A 00 29 1F"]
READSTATE --> LOADVEC["Load VectorTable[Y]<br/>$E06D: B9 7C E0"]
LOADVEC --> DISPATCH["Indirect Jump to State<br/>$E079: 6C 4E 00"]
DISPATCH --> LOOP["StateDispatch Loop"]
```

**Diagram sources**
- [prg_1f.aligned.asm:406-459](file://asm/banks/prg_1f.aligned.asm#L406-L459)
- [prg_1f.aligned.asm:460-466](file://asm/banks/prg_1f.aligned.asm#L460-L466)
- [prg_1f.aligned.asm:451-459](file://asm/banks/prg_1f.aligned.asm#L451-L459)

**Section sources**
- [prg_1f.aligned.asm:406-459](file://asm/banks/prg_1f.aligned.asm#L406-L459)
- [prg_1f.aligned.asm:460-466](file://asm/banks/prg_1f.aligned.asm#L460-L466)
- [prg_1f.aligned.asm:451-459](file://asm/banks/prg_1f.aligned.asm#L451-L459)
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)

### State Machine and Vector Dispatch (Structured Organization)
- The game state is stored in a global RAM location and masked to 0-31 to index the vector table.
- Each state handler performs frame initialization, prepares display buffers, calls bank-switched display routines, updates state, and re-invokes the dispatcher.
- The dispatcher reloads the vector table entry and jumps to the next state.
- Modern assembly formatting provides structured organization with labeled state handlers for improved readability.

**Updated** Enhanced with modern assembly formatting standards featuring structured state handler organization and improved debugging support.

```mermaid
sequenceDiagram
participant DIS as "StateDispatch"
participant VT as "VectorTable ($E07C)"
participant SH as "State Handler"
participant MAP as "Mapper"
DIS->>DIS : Load addr_game_state & mask<br/>$E066 : AD 7A 00 29 1F
DIS->>VT : Fetch 2-byte entry<br/>$E06D : B9 7C E0 B9 7D E0
VT-->>DIS : Target address (in bank 0x1F)<br/>$E07C : 9A E0 DA E0...
DIS->>SH : Jump to state handler<br/>$E079 : 6C 4E 00
SH->>MAP : Optional bank switch (if needed)
SH->>SH : Frame init, display, controller
SH->>DIS : Increment addr_game_state
DIS->>VT : Reload entry
DIS-->>SH : Continue loop
```

**Diagram sources**
- [prg_1f.aligned.asm:451-459](file://asm/banks/prg_1f.aligned.asm#L451-L459)
- [prg_1f.aligned.asm:467-694](file://asm/banks/prg_1f.aligned.asm#L467-L694)
- [prg_1f.aligned.asm:460-466](file://asm/banks/prg_1f.aligned.asm#L460-L466)

**Section sources**
- [prg_1f.aligned.asm:451-459](file://asm/banks/prg_1f.aligned.asm#L451-L459)
- [prg_1f.aligned.asm:467-694](file://asm/banks/prg_1f.aligned.asm#L467-L694)
- [prg_1f.aligned.asm:460-466](file://asm/banks/prg_1f.aligned.asm#L460-L466)

### Bank Switching Implementation (Enhanced Macros)
- The mapper exposes four write-only registers to select 8KB PRG banks for each slot.
- The project provides enhanced macros to simplify bank switching for each slot with modern formatting.
- A bank switching helper reads a configuration table and writes to the mapper registers for PRG slots and extended configuration.
- Modern assembly format provides structured organization with labeled bank switching routines.

**Updated** Enhanced with modern assembly formatting standards and improved macro organization.

```mermaid
flowchart TD
CALL["BankSwitch(A)"] --> TABLEIDX["Compute table offset (A*8)<br/>$E0BF: 20 1F E5"]
TABLEIDX --> LOAD1["Load PRG bank reg 1 ($C000)"]
LOAD1 --> WRITE1["Write to $C000<br/>$E0C2: A9 10 8D 8B 00"]
TABLEIDX --> LOAD2["Load PRG bank reg 2 ($C800)"]
LOAD2 --> WRITE2["Write to $C800"]
TABLEIDX --> LOAD3["Load PRG bank reg 3 ($D000)"]
LOAD3 --> WRITE3["Write to $D000"]
TABLEIDX --> LOAD4["Load PRG bank reg 4 ($D800)"]
LOAD4 --> WRITE4["Write to $D800"]
WRITE4 --> DONE["Return"]
```

**Diagram sources**
- [prg_1f.aligned.asm:785-818](file://asm/banks/prg_1f.aligned.asm#L785-L818)
- [prg_1f.aligned.asm:824-828](file://asm/banks/prg_1f.aligned.asm#L824-L828)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)

**Section sources**
- [namco163.h:65-87](file://include/namco163.h#L65-L87)
- [prg_1f.aligned.asm:785-818](file://asm/banks/prg_1f.aligned.asm#L785-L818)
- [prg_1f.aligned.asm:824-828](file://asm/banks/prg_1f.aligned.asm#L824-L828)

### Interrupt Service Routines and Hardware Abstraction
- The main module provides minimal NMI and IRQ stubs that preserve registers and return via RTI.
- The boot bank implements PPU initialization helpers and provides macros for common operations like VBlank waits, PPU address setting, and DMA transfers.
- The mapper initialization routine sets up the initial bank configuration for the first three slots.
- Modern assembly formatting provides structured organization with labeled interrupt handlers and hardware abstraction routines.

**Updated** Enhanced with modern assembly formatting standards and improved hardware abstraction organization.

```mermaid
flowchart TD
NMI["NMI Handler"] --> SAVE["Push A/X/Y<br/>$E000: 78 D8 A9 00"]
SAVE --> PROC["Process NMI (placeholder)"]
PROC --> RESTORE["Pop Y/X/A<br/>$E000: 78 D8 A9 00"]
RESTORE --> RTI["RTI<br/>$E000: 40"]
IRQ["IRQ Handler"] --> SAVE2["Push A/X/Y<br/>$E000: 78 D8 A9 00"]
SAVE2 --> PROC2["Process IRQ (placeholder)"]
PROC2 --> RESTORE2["Pop Y/X/A<br/>$E000: 78 D8 A9 00"]
RESTORE2 --> RTI2["RTI<br/>$E000: 40"]
```

**Diagram sources**
- [main.asm:65-99](file://asm/main.asm#L65-L99)
- [prg_1f.aligned.asm:1040-1065](file://asm/banks/prg_1f.aligned.asm#L1040-L1065)
- [macros.h:8-12](file://include/macros.h#L8-L12)

**Section sources**
- [main.asm:65-99](file://asm/main.asm#L65-L99)
- [prg_1f.aligned.asm:1040-1065](file://asm/banks/prg_1f.aligned.asm#L1040-L1065)
- [macros.h:8-12](file://include/macros.h#L8-L12)

### Modular Assembly Approach and Bank Assignment
- The project uses a modular approach: each bank is represented by a separate assembly stub that includes the corresponding binary.
- The linker configuration assigns segments to specific PRG slots and allows optional assignment of additional banks.
- The include files centralize register definitions and macros for consistent access patterns across banks.
- Modern assembly formatting provides improved organization and debugging support across all bank files.

**Updated** Enhanced with modern assembly formatting standards and improved bank assignment organization.

```mermaid
graph LR
ALLB["asm/banks/all_banks.asm"] --> B00["prg_00.asm"]
ALLB --> B01["prg_01.asm"]
ALLB --> ALIGNED["prg_1f.aligned.asm (Boot)<br/>Modern Assembly Format"]
LCFG["linker.cfg"] --> SEG0["CODE (PRG_SLOT0)"]
LCFG --> SEG1["CODE1 (PRG_SLOT1)"]
LCFG --> SEG2["CODE2 (PRG_SLOT2)"]
LCFG --> SEG3["CODE3 (PRG_SLOT3)"]
B00 --> BIN0["rom/prg/prg_00.bin"]
B01 --> BIN1["rom/prg/prg_01.bin"]
ALIGNED --> BIN1F["rom/prg/prg_1f.bin"]
ALIGNED --> STRUCT["Structured Assembly Organization"]
```

**Diagram sources**
- [all_banks.asm:1-38](file://asm/banks/all_banks.asm#L1-L38)
- [prg_00.asm:1-13](file://asm/banks/prg_00.asm#L1-L13)
- [prg_01.asm:1-13](file://asm/banks/prg_01.asm#L1-L13)
- [linker.cfg:32-54](file://linker.cfg#L32-L54)

**Section sources**
- [all_banks.asm:1-38](file://asm/banks/all_banks.asm#L1-L38)
- [prg_00.asm:1-13](file://asm/banks/prg_00.asm#L1-L13)
- [prg_01.asm:1-13](file://asm/banks/prg_01.asm#L1-L13)
- [linker.cfg:32-54](file://linker.cfg#L32-L54)

## Modern Assembly Formatting Standards

### Aligned Assembly Format
The modern aligned format provides comprehensive improvements in code organization and readability:

- **Structured Label Organization**: Labels are grouped by functional categories (constants, data, code, subroutines)
- **Address Constants**: Comprehensive address mapping system with clear naming conventions
- **Macro Definitions**: Enhanced macro system with proper parameter handling
- **Data Organization**: Structured data sections with clear labeling and organization
- **Code Readability**: Improved indentation and spacing for better code comprehension

### Enhanced Code Organization Features
The aligned format introduces several organizational improvements:

- **Functional Grouping**: Related functions and data are grouped together for better navigation
- **Consistent Formatting**: Standardized formatting across all code sections
- **Improved Navigation**: Logical organization makes code easier to navigate and understand
- **Enhanced Maintainability**: Better structure supports easier maintenance and updates

### Benefits for Development
The modern assembly formatting provides numerous benefits for developers:

- **Improved Readability**: Structured organization makes code easier to understand
- **Better Navigation**: Logical grouping helps developers quickly locate specific functionality
- **Enhanced Debugging**: Clear organization supports more effective debugging and analysis
- **Maintainability**: Better structure facilitates easier code maintenance and updates
- **Documentation Support**: Organized structure serves as implicit documentation of code functionality

**Section sources**
- [prg_1f.aligned.asm:12-80](file://asm/banks/prg_1f.aligned.asm#L12-L80)
- [prg_1f.aligned.asm:800-1599](file://asm/banks/prg_1f.aligned.asm#L800-L1599)
- [namco163.h:65-87](file://include/namco163.h#L65-L87)

## Enhanced Code Organization

### Address Constant System
The aligned format implements a comprehensive address constant system:

- **RAM Address Constants**: Extensive mapping of RAM locations with descriptive names
- **PPU Register Constants**: Clear mapping of PPU register addresses and bit definitions
- **APU Register Constants**: Complete mapping of APU and I/O register addresses
- **Namco-163 Specific Constants**: Dedicated constants for mapper and expansion ROM registers

### Macro Enhancement System
The macro system provides enhanced functionality:

- **Force Absolute Addressing**: Macros that force 16-bit addressing for absolute operations
- **Bank Switching Macros**: Enhanced macros for PRG bank switching with proper slot selection
- **Hardware Access Macros**: Streamlined macros for common hardware operations
- **Data Transfer Macros**: Optimized macros for efficient data movement and manipulation

### Data Organization Improvements
The aligned format provides better data organization:

- **Structured Data Sections**: Logical grouping of related data items
- **Clear Labeling**: Descriptive labels for easy identification of data purposes
- **Address Mapping**: Clear correlation between logical names and physical addresses
- **Constant Definitions**: Well-organized constants for easy modification and maintenance

**Section sources**
- [prg_1f.aligned.asm:80-399](file://asm/banks/prg_1f.aligned.asm#L80-L399)
- [prg_1f.aligned.asm:1228-1256](file://asm/banks/prg_1f.aligned.asm#L1228-L1256)
- [prg_1f.aligned.asm:1319-1372](file://asm/banks/prg_1f.aligned.asm#L1319-L1372)

## Debugging and Verification Tools

### Aligned Format Benefits
The modern aligned format provides enhanced debugging capabilities:

- **Structured Code Analysis**: Organized code structure supports more effective analysis
- **Improved Symbol Resolution**: Clear label organization aids in symbol resolution during debugging
- **Enhanced Readability**: Better formatting supports faster code comprehension during debugging
- **Logical Organization**: Functional grouping makes it easier to isolate specific debugging scenarios

### Legacy Format Preservation
The project maintains backward compatibility through:

- **Backup Files**: Original format preserved in .bak files for reference
- **Aligned Versions**: Alternative formatting preserved for comparison and analysis
- **Migration Support**: Clear evidence of transformation supports migration and analysis

### Development Workflow Integration
The modern format integrates well with development workflows:

- **Tool Compatibility**: Format compatible with standard assembly development tools
- **Analysis Support**: Enhanced structure supports automated analysis and verification
- **Documentation Support**: Organized structure serves as built-in documentation

**Section sources**
- [prg_1f.aligned.asm:1-200](file://asm/banks/prg_1f.aligned.asm#L1-L200)
- [prg_1f.asm.bak:1-50](file://asm/banks/prg_1f.asm.bak#L1-L50)

## Dependency Analysis
The architecture exhibits clear separation of concerns with modern assembly formatting standards:
- The boot bank depends on the mapper definitions and register abstractions.
- State handlers depend on the dispatcher and bank switching helpers.
- The linker configuration ties together segments and memory regions.
- The main module coordinates initialization and provides minimal ISR stubs.
- Modern assembly formatting provides improved organization and debugging support.

**Updated** Enhanced with modern assembly formatting standards and improved dependency management.

```mermaid
graph TB
ALIGNED["prg_1f.aligned.asm<br/>Modern Assembly Format"] --> NAMCO["namco163.h"]
ALIGNED --> REGS["6502_registers.h"]
ALIGNED --> MACROS["macros.h"]
MAIN["main.asm"] --> ALIGNED
MAIN --> NAMCO
LCFG["linker.cfg"] --> ALIGNED
LCFG --> MAIN
ALIGNED --> STRUCT["Structured Organization"]
ALIGNED --> DEBUG["Enhanced Debugging"]
```

**Diagram sources**
- [prg_1f.aligned.asm:10-11](file://asm/banks/prg_1f.aligned.asm#L10-L11)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)
- [6502_registers.h:6-39](file://include/6502_registers.h#L6-L39)
- [macros.h:1-72](file://include/macros.h#L1-L72)
- [main.asm:6-7](file://asm/main.asm#L6-L7)
- [linker.cfg:18-55](file://linker.cfg#L18-L55)

**Section sources**
- [prg_1f.aligned.asm:10-11](file://asm/banks/prg_1f.aligned.asm#L10-L11)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)
- [6502_registers.h:6-39](file://include/6502_registers.h#L6-L39)
- [macros.h:1-72](file://include/macros.h#L1-L72)
- [main.asm:6-7](file://asm/main.asm#L6-L7)
- [linker.cfg:18-55](file://linker.cfg#L18-L55)

## Performance Considerations
- Bank switching involves writing to mapper registers; minimize unnecessary switches to reduce overhead.
- Use the provided enhanced macros to keep register writes compact and consistent.
- Leverage the vector dispatch to avoid frequent branching and to centralize state transitions.
- Keep PPU/APU operations synchronized with VBlank to prevent flicker and timing issues.
- **Enhanced Organization**: The modern assembly format provides improved code organization for better performance analysis.
- **Debugging Efficiency**: Structured organization improves debugging efficiency and performance optimization.
- **Maintenance Overhead**: Modern formatting adds minimal overhead while providing significant development benefits.

## Troubleshooting Guide
- If the game does not enter the intended state, verify the vector table indexing and ensure the state counter is properly masked.
- If graphics appear incorrect after a bank switch, confirm the mapper register writes and palette upload sequences.
- If interrupts are not firing, ensure PPU control bits are set correctly and that the NMI flag is cleared appropriately.
- Use the provided enhanced macros for PPU operations to avoid off-by-one address errors.
- **Modern Format Benefits**: Utilize the structured aligned format to quickly locate and analyze specific code sections.
- **Organization Advantages**: Clear code organization makes troubleshooting more efficient and systematic.
- **Legacy Reference**: Use backup files to compare with original format when needed for analysis.
- **Migration Support**: Modern format supports easier migration and updates compared to legacy formats.

**Section sources**
- [prg_1f.aligned.asm:739-750](file://asm/banks/prg_1f.aligned.asm#L739-L750)
- [prg_1f.aligned.asm:1071-1085](file://asm/banks/prg_1f.aligned.asm#L1071-L1085)
- [prg_1f.aligned.asm:1100-1113](file://asm/banks/prg_1f.aligned.asm#L1100-L1113)
- [prg_1f.asm.bak:1-50](file://asm/banks/prg_1f.asm.bak#L1-L50)

## Conclusion
The assembly architecture employs a robust, modular design centered on a fixed boot bank and a vector-driven state machine. The modern assembly format transformation represents a significant improvement in code organization, readability, and maintainability. The Namco-163 mapper enables efficient bank switching across four PRG slots, while the linker configuration and include files provide a consistent foundation for development. The modern assembly formatting with structured organization and enhanced debugging support significantly improves the development experience, providing developers with immediate visibility into code organization and functionality. The comprehensive tooling infrastructure supports automated analysis and verification, making the development process more efficient and reliable. By following the documented patterns for bank assignment, state transitions, hardware abstraction, and utilizing the modern assembly formatting standards, developers can extend the disassembly with accurate, maintainable code while benefiting from superior debugging and verification support through enhanced code organization and structure.