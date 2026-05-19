# Assembly Architecture

<cite>
**Referenced Files in This Document**
- [linker.cfg](file://linker.cfg)
- [main.asm](file://asm/main.asm)
- [prg_1f.asm](file://asm/banks/prg_1f.asm)
- [namco163.h](file://include/namco163.h)
- [6502_registers.h](file://include/6502_registers.h)
- [macros.h](file://include/macros.h)
- [all_banks.asm](file://asm/banks/all_banks.asm)
- [prg_00.asm](file://asm/banks/prg_00.asm)
- [prg_01.asm](file://asm/banks/prg_01.asm)
- [PROJECT.md](file://PROJECT.md)
</cite>

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
This document explains the assembly architecture for the Namco-163 (Mapper 19) implementation used in the disassembly of a classic NES strategy game. It focuses on the 32-bank structure with 8KB banks, the fixed boot bank at $E000-$FFFF, the switchable PRG slots at $8000-$DFFF, and the state machine orchestrated by the vector dispatch table at $E07C. It also documents the memory mapping configuration, segment organization, bank switching implementation, interrupt service routines, and the hardware abstraction layer for PPU/APU and the Namco-163 mapper.

## Project Structure
The project is organized around a modular bank-based approach:
- A central linker configuration defines memory layout and segments.
- A main entry module provides reset/NMI/IRQ stubs and initializes the mapper.
- A dedicated boot bank (0x1F) contains the reset handler, state dispatch table, and core runtime helpers.
- Separate bank stubs represent the remaining 31 banks, each mapped to a specific PRG slot.

```mermaid
graph TB
subgraph "Linker Configuration"
LCFG["linker.cfg"]
end
subgraph "Boot Bank (0x1F)"
PRG1F["asm/banks/prg_1f.asm"]
VTABLE["$E07C VectorTable<br/>$E000 Reset Handler"]
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
LCFG --> PRG1F
MAIN --> PRG1F
PRG1F --> VTABLE
PRG1F --> NAMCO
PRG1F --> REGS
PRG1F --> MACROS
ALLB --> B00
ALLB --> B01
```

**Diagram sources**
- [linker.cfg:18-55](file://linker.cfg#L18-L55)
- [prg_1f.asm:13-148](file://asm/banks/prg_1f.asm#L13-L148)
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
- Fixed boot bank 0x1F mapped to $E000-$FFFF at startup.
- Vector dispatch table at $E07C orchestrates game flow across execution contexts.
- Four PRG slots ($8000-$FFFF) managed by the Namco-163 mapper via write-only registers.
- Hardware abstraction layer for PPU/APU and mapper register access.
- Modular bank stubs representing 31 additional banks.

**Section sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [prg_1f.asm:153-169](file://asm/banks/prg_1f.asm#L153-L169)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)
- [6502_registers.h:6-39](file://include/6502_registers.h#L6-L39)

## Architecture Overview
The system uses a state machine driven by a vector table in the boot bank. The reset handler initializes hardware, clears RAM, and dispatches to the first state via an indirect jump. The mapper enables dynamic loading of code from other banks into PRG slots, allowing the state handlers to call bank-switched routines.

```mermaid
sequenceDiagram
participant CPU as "CPU"
participant BOOT as "Boot Bank 0x1F ($E000)"
participant MAP as "Namco-163 Mapper"
participant SLOTS as "PRG Slots ($8000-$DFFF)"
participant STATE as "State Handler (Banked)"
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
```

**Diagram sources**
- [prg_1f.asm:74-148](file://asm/banks/prg_1f.asm#L74-L148)
- [prg_1f.asm:739-750](file://asm/banks/prg_1f.asm#L739-L750)
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

### Fixed Boot Bank 0x1F and Reset Flow
- The reset handler at $E000 performs CPU initialization, PPU warmup, APU initialization, and RAM clearing.
- It initializes the mapper and sets the initial game state, then dispatches to the state handler via the vector table.
- The vector table at $E07C contains 15 entries, each a 2-byte address within bank 0x1F.

```mermaid
flowchart TD
START(["Reset"]) --> INITCPU["SEI/CLD, Stack Setup"]
INITCPU --> PPUWARM["PPU Warmup (VBlank)"]
PPUWARM --> APUCLEAR["APU Init & Silence"]
APUCLEAR --> RAMCLR["Clear RAM $0000-$07FF"]
RAMCLR --> MAPINIT["Mapper Init (Set Banks)"]
MAPINIT --> READSTATE["Load addr_game_state & mask"]
READSTATE --> LOADVEC["Load VectorTable[Y]"]
LOADVEC --> DISPATCH["Indirect Jump to State"]
DISPATCH --> LOOP["StateDispatch Loop"]
```

**Diagram sources**
- [prg_1f.asm:74-148](file://asm/banks/prg_1f.asm#L74-L148)
- [prg_1f.asm:153-169](file://asm/banks/prg_1f.asm#L153-L169)
- [prg_1f.asm:739-750](file://asm/banks/prg_1f.asm#L739-L750)

**Section sources**
- [prg_1f.asm:74-148](file://asm/banks/prg_1f.asm#L74-L148)
- [prg_1f.asm:153-169](file://asm/banks/prg_1f.asm#L153-L169)
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)

### State Machine and Vector Dispatch
- The game state is stored in a global RAM location and masked to 0-31 to index the vector table.
- Each state handler performs frame initialization, prepares display buffers, calls bank-switched display routines, updates state, and re-invokes the dispatcher.
- The dispatcher reloads the vector table entry and jumps to the next state.

```mermaid
sequenceDiagram
participant DIS as "StateDispatch"
participant VT as "VectorTable ($E07C)"
participant SH as "State Handler"
participant MAP as "Mapper"
DIS->>DIS : Load addr_game_state & mask
DIS->>VT : Fetch 2-byte entry
VT-->>DIS : Target address (in bank 0x1F)
DIS->>SH : Jump to state handler
SH->>MAP : Optional bank switch (if needed)
SH->>SH : Frame init, display, controller
SH->>DIS : Increment addr_game_state
DIS->>VT : Reload entry
DIS-->>SH : Continue loop
```

**Diagram sources**
- [prg_1f.asm:739-750](file://asm/banks/prg_1f.asm#L739-L750)
- [prg_1f.asm:153-169](file://asm/banks/prg_1f.asm#L153-L169)

**Section sources**
- [prg_1f.asm:739-750](file://asm/banks/prg_1f.asm#L739-L750)
- [prg_1f.asm:153-169](file://asm/banks/prg_1f.asm#L153-L169)

### Bank Switching Implementation
- The mapper exposes four write-only registers to select 8KB PRG banks for each slot.
- The project provides macros to simplify bank switching for each slot.
- A bank switching helper reads a configuration table and writes to the mapper registers for PRG slots and extended configuration.

```mermaid
flowchart TD
CALL["BankSwitch(A)"] --> TABLEIDX["Compute table offset (A*8)"]
TABLEIDX --> LOAD1["Load PRG bank reg 1 ($C000)"]
LOAD1 --> WRITE1["Write to $C000"]
TABLEIDX --> LOAD2["Load PRG bank reg 2 ($C800)"]
LOAD2 --> WRITE2["Write to $C800"]
TABLEIDX --> LOAD3["Load PRG bank reg 3 ($D000)"]
LOAD3 --> WRITE3["Write to $D000"]
TABLEIDX --> LOAD4["Load PRG bank reg 4 ($D800)"]
LOAD4 --> WRITE4["Write to $D800"]
WRITE4 --> DONE["Return"]
```

**Diagram sources**
- [prg_1f.asm:785-818](file://asm/banks/prg_1f.asm#L785-L818)
- [prg_1f.asm:824-828](file://asm/banks/prg_1f.asm#L824-L828)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)

**Section sources**
- [namco163.h:65-87](file://include/namco163.h#L65-L87)
- [prg_1f.asm:785-818](file://asm/banks/prg_1f.asm#L785-L818)
- [prg_1f.asm:824-828](file://asm/banks/prg_1f.asm#L824-L828)

### Interrupt Service Routines and Hardware Abstraction
- The main module provides minimal NMI and IRQ stubs that preserve registers and return via RTI.
- The boot bank implements PPU initialization helpers and provides macros for common operations like VBlank waits, PPU address setting, and DMA transfers.
- The mapper initialization routine sets up the initial bank configuration for the first three slots.

```mermaid
flowchart TD
NMI["NMI Handler"] --> SAVE["Push A/X/Y"]
SAVE --> PROC["Process NMI (placeholder)"]
PROC --> RESTORE["Pop Y/X/A"]
RESTORE --> RTI["RTI"]
IRQ["IRQ Handler"] --> SAVE2["Push A/X/Y"]
SAVE2 --> PROC2["Process IRQ (placeholder)"]
PROC2 --> RESTORE2["Pop Y/X/A"]
RESTORE2 --> RTI2["RTI"]
```

**Diagram sources**
- [main.asm:65-99](file://asm/main.asm#L65-L99)
- [prg_1f.asm:1040-1065](file://asm/banks/prg_1f.asm#L1040-L1065)
- [macros.h:8-12](file://include/macros.h#L8-L12)

**Section sources**
- [main.asm:65-99](file://asm/main.asm#L65-L99)
- [prg_1f.asm:1040-1065](file://asm/banks/prg_1f.asm#L1040-L1065)
- [macros.h:8-12](file://include/macros.h#L8-L12)

### Modular Assembly Approach and Bank Assignment
- The project uses a modular approach: each bank is represented by a separate assembly stub that includes the corresponding binary.
- The linker configuration assigns segments to specific PRG slots and allows optional assignment of additional banks.
- The include files centralize register definitions and macros for consistent access patterns across banks.

```mermaid
graph LR
ALLB["asm/banks/all_banks.asm"] --> B00["prg_00.asm"]
ALLB --> B01["prg_01.asm"]
ALLB --> B1F["prg_1f.asm (Boot)"]
LCFG["linker.cfg"] --> SEG0["CODE (PRG_SLOT0)"]
LCFG --> SEG1["CODE1 (PRG_SLOT1)"]
LCFG --> SEG2["CODE2 (PRG_SLOT2)"]
LCFG --> SEG3["CODE3 (PRG_SLOT3)"]
B00 --> BIN0["rom/prg/prg_00.bin"]
B01 --> BIN1["rom/prg/prg_01.bin"]
B1F --> BIN1F["rom/prg/prg_1f.bin"]
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

## Dependency Analysis
The architecture exhibits clear separation of concerns:
- The boot bank depends on the mapper definitions and register abstractions.
- State handlers depend on the dispatcher and bank switching helpers.
- The linker configuration ties together segments and memory regions.
- The main module coordinates initialization and provides minimal ISR stubs.

```mermaid
graph TB
PRG1F["prg_1f.asm"] --> NAMCO["namco163.h"]
PRG1F --> REGS["6502_registers.h"]
PRG1F --> MACROS["macros.h"]
MAIN["main.asm"] --> PRG1F
MAIN --> NAMCO
LCFG["linker.cfg"] --> PRG1F
LCFG --> MAIN
```

**Diagram sources**
- [prg_1f.asm:10-11](file://asm/banks/prg_1f.asm#L10-L11)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)
- [6502_registers.h:6-39](file://include/6502_registers.h#L6-L39)
- [macros.h:1-72](file://include/macros.h#L1-L72)
- [main.asm:6-7](file://asm/main.asm#L6-L7)
- [linker.cfg:18-55](file://linker.cfg#L18-L55)

**Section sources**
- [prg_1f.asm:10-11](file://asm/banks/prg_1f.asm#L10-L11)
- [namco163.h:10-17](file://include/namco163.h#L10-L17)
- [6502_registers.h:6-39](file://include/6502_registers.h#L6-L39)
- [macros.h:1-72](file://include/macros.h#L1-L72)
- [main.asm:6-7](file://asm/main.asm#L6-L7)
- [linker.cfg:18-55](file://linker.cfg#L18-L55)

## Performance Considerations
- Bank switching involves writing to mapper registers; minimize unnecessary switches to reduce overhead.
- Use the provided macros to keep register writes compact and consistent.
- Leverage the vector dispatch to avoid frequent branching and to centralize state transitions.
- Keep PPU/APU operations synchronized with VBlank to prevent flicker and timing issues.

## Troubleshooting Guide
- If the game does not enter the intended state, verify the vector table indexing and ensure the state counter is properly masked.
- If graphics appear incorrect after a bank switch, confirm the mapper register writes and palette upload sequences.
- If interrupts are not firing, ensure PPU control bits are set correctly and that the NMI flag is cleared appropriately.
- Use the provided macros for PPU operations to avoid off-by-one address errors.

**Section sources**
- [prg_1f.asm:739-750](file://asm/banks/prg_1f.asm#L739-L750)
- [prg_1f.asm:1071-1085](file://asm/banks/prg_1f.asm#L1071-L1085)
- [prg_1f.asm:1100-1113](file://asm/banks/prg_1f.asm#L1100-L1113)
- [macros.h:8-12](file://include/macros.h#L8-L12)

## Conclusion
The assembly architecture employs a robust, modular design centered on a fixed boot bank and a vector-driven state machine. The Namco-163 mapper enables efficient bank switching across four PRG slots, while the linker configuration and include files provide a consistent foundation for development. By following the documented patterns for bank assignment, state transitions, and hardware abstraction, developers can extend the disassembly with accurate, maintainable code.