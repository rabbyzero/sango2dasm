# Project Overview

<cite>
**Referenced Files in This Document**
- [PROJECT.md](file://PROJECT.md)
- [Makefile](file://Makefile)
- [linker.cfg](file://linker.cfg)
- [include/namco163.h](file://include/namco163.h)
- [include/macros.h](file://include/macros.h)
- [include/6502_registers.h](file://include/6502_registers.h)
- [include/functions.h](file://include/functions.h)
- [tools/split_rom.py](file://tools/split_rom.py)
- [tools/analyze_rom.py](file://tools/analyze_rom.py)
- [tools/generate_bank_stubs.py](file://tools/generate_bank_stubs.py)
- [tools/disasm_6502.py](file://tools/disasm_6502.py)
- [tools/verify_rom.py](file://tools/verify_rom.py)
- [asm/main.asm](file://asm/main.asm)
- [asm/banks/prg_1f.asm](file://asm/banks/prg_1f.asm)
- [asm/banks/prg_00.asm](file://asm/banks/prg_00.asm)
- [asm/banks/prg_08_09.asm](file://asm/banks/prg_08_09.asm)
- [code/bank_1f_plan.md](file://code/bank_1f_plan.md)
- [code/key_functions_analysis.md](file://code/key_functions_analysis.md)
</cite>

## Update Summary
**Changes Made**
- Enhanced Section 7 coverage in functions.h with comprehensive B08_09_* function declarations for combined banks 08+09
- Updated bank organization documentation to reflect the complete AI turn processing and battle system implementation
- Removed references to stale bank entries (B3D, B3B, B39, B2E, B2C, B2A, B28) that are no longer relevant
- Expanded technical details for the battle system architecture and AI decision-making processes

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
10. [Appendices](#appendices)

## Introduction
This project is a complete reverse engineering and disassembly effort for the Namco-163 (Mapper 19) strategy game Sangokushi 2 - Haou no Tairiku (J) for the Nintendo Entertainment System (NES). The goal is to produce a faithful, byte-accurate recreation of the original ROM using modern tooling and a modular, bank-based organization. The project covers 32 programmable PRG banks (256KB) and mirrors the game's mapper abstraction to support 8KB bank switching across four PRG slots ($8000–$FFFF). It also documents the reset handler, vector dispatch mechanism, and the bank-switched code that implements gameplay states, display, audio, and I/O.

Beyond technical reconstruction, this project serves as an educational resource for retro gaming preservation. It demonstrates how to split, analyze, and rebuild a complex mapper-based ROM while maintaining byte-for-byte fidelity, and it provides a reusable framework applicable to other games using similar mappers.

## Project Structure
The repository is organized around a modular bank-based approach and a cc65 toolchain integration. The structure supports incremental disassembly and verification:

- asm/: Assembly entry point and per-bank stubs
- include/: 6502/PPU/APU/Namco-163 register and macro definitions
- rom/: Split PRG/CHR banks and combined binaries
- tools/: Python scripts for ROM splitting, analysis, disassembly, bank stub generation, and verification
- code/: Disassembly plans and analyses for key banks and functions
- build/: Build outputs (object files, listings, map, and final ROM)
- Top-level configuration: Makefile and linker.cfg

```mermaid
graph TB
subgraph "Source"
A["PROJECT.md"]
B["Makefile"]
C["linker.cfg"]
D["include/*"]
E["asm/main.asm"]
F["asm/banks/*.asm"]
G["rom/*"]
H["tools/*"]
I["code/*"]
end
subgraph "Build System"
J["ca65/ld65"]
K["build/"]
end
A --> B --> J
C --> J
D --> J
E --> J
F --> J
H --> J
J --> K
K --> G
```

**Diagram sources**
- [Makefile:1-102](file://Makefile#L1-L102)
- [linker.cfg:1-55](file://linker.cfg#L1-L55)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [Makefile:12-31](file://Makefile#L12-L31)
- [linker.cfg:18-54](file://linker.cfg#L18-L54)

## Core Components
- Modular bank organization: 32 PRG banks (8KB each) mapped to four 8KB slots ($8000–$FFFF). Bank switching is performed via writes to $F800–$FFFF.
- cc65 toolchain integration: ca65 assembler and ld65 linker are orchestrated via Makefile and linker.cfg to assemble and link the project into a final ROM.
- Automated analysis pipeline: Python tools split the ROM, analyze structure, generate bank stubs, disassemble binaries, and verify byte-identical rebuilds.
- Mapper abstraction: include/namco163.h defines register addresses, bank indices, and macros for bank switching, enabling consistent mapper usage across code.
- Reset handler and vector dispatch: asm/main.asm and asm/banks/prg_1f.asm implement the reset routine and a vector table-driven state machine that dispatches to game logic across banks.

Practical outcomes:
- Byte-accurate ROM verification against the original
- Incremental disassembly workflow from the boot bank to other banks
- Reusable bank stubs and linker segments for ongoing analysis

**Section sources**
- [PROJECT.md:84-117](file://PROJECT.md#L84-L117)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [asm/main.asm:25-141](file://asm/main.asm#L25-L141)
- [asm/banks/prg_1f.asm:74-148](file://asm/banks/prg_1f.asm#L74-L148)

## Architecture Overview
The architecture centers on a mapper abstraction layer and a bank-based code layout. The reset handler in bank 0x1F initializes the system and reads a vector table to dispatch to state handlers. These handlers may branch to bank-switched routines at $A000–$A045 and beyond, depending on the current game state.

```mermaid
graph TB
subgraph "NES Hardware"
PPU["PPU"]
APU["APU"]
CART["Cartridge (Namco-163 Mapper)"]
end
subgraph "System Software"
RST["Reset Handler<br/>Bank 0x1F $E000"]
VEC["Vector Dispatch<br/>Bank 0x1F $E07C"]
STATE["State Handlers<br/>Bank 0x1F + Others"]
MAP["Mapper Abstraction<br/>include/namco163.h"]
end
RST --> VEC
VEC --> STATE
STATE --> MAP
MAP --> CART
CART --> PPU
CART --> APU
```

**Diagram sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [asm/banks/prg_1f.asm:153-169](file://asm/banks/prg_1f.asm#L153-L169)

**Section sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)

## Detailed Component Analysis

### Bank 0x1F: Reset Handler, Vector Dispatch, and Boot Bank Responsibilities
Bank 0x1F is the boot bank mapped to $E000–$FFFF at startup. It contains:
- Reset handler that initializes PPU/APU, clears RAM, and performs mapper initialization
- Vector dispatch table indexing into state handlers
- State handlers for system initialization, menus, gameplay phases, and turn summaries
- Supporting utilities: RNG, data access functions, PPU helpers, sound engine, and IRQ/NMI infrastructure

```mermaid
sequenceDiagram
participant CPU as "CPU"
participant RST as "Reset Handler<br/>Bank 0x1F $E000"
participant VEC as "Vector Table<br/>$E07C"
participant ST0 as "State 0<br/>SystemInit"
participant ST1 as "State 1<br/>NewGameInit"
CPU->>RST : Assert Reset
RST->>RST : PPU/APU warmup and init
RST->>VEC : Read state index from $007A
VEC-->>RST : 2-byte target address
RST->>ST0 : Jump to State 0
ST0->>ST0 : Initialize display and state
ST0->>RST : Update state index
RST->>VEC : Re-read vector
VEC-->>RST : Target address for State 1
RST->>ST1 : Jump to State 1
```

**Diagram sources**
- [asm/banks/prg_1f.asm:74-148](file://asm/banks/prg_1f.asm#L74-L148)
- [asm/banks/prg_1f.asm:153-169](file://asm/banks/prg_1f.asm#L153-L169)

**Section sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [asm/banks/prg_1f.asm:74-148](file://asm/banks/prg_1f.asm#L74-L148)
- [code/bank_1f_plan.md:8-18](file://code/bank_1f_plan.md#L8-L18)

### Enhanced Section 7: Combined Banks 08+09 - AI Turn Processing and Battle System
**Updated** Enhanced Section 7 coverage now includes comprehensive jump-table entries and internal procedures for combined banks 08+09 with B08_09_* prefixed function declarations. This section implements the core AI turn processing and battle system functionality.

The combined banks 08+09 provide a 16KB memory space ($A000-$DFFF) containing:
- **Jump Table Entry Points**: 14 entry points at $A000-$A02A handling AI turn processing, battle setup, casualty resolution, and result scenes
- **AI Decision Engine**: Complete AI officer action system with strategic decision-making, movement planning, and combat evaluation
- **Battle System**: Full battle phase processing including unit positioning, combat calculations, and result scene management
- **Strategic Elements**: Formation management, terrain effects, and special officer validation

```mermaid
flowchart TD
AITP[AiTurnProcess_Entry] --> AILOOP[Officer Loop]
AILOOP --> DECIDE[AiOfficerActionDecide]
DECIDE --> ACTION[Action Handler]
ACTION --> MOVE[AiExecuteMove]
ACTION --> ATTACK[Battle Setup]
MOVE --> EVAL[Evaluate Options]
ATTACK --> PHASE[BattlePhaseProcess]
PHASE --> RESOLVE[Casualty Resolution]
RESOLVE --> RESULT[BattleResultDispatch]
RESULT --> SCENE[BattleResultSceneInit]
SCENE --> MENU[Menu Interaction]
MENU --> FINALIZE[Finalize Results]
```

**Diagram sources**
- [include/functions.h:897-911](file://include/functions.h#L897-L911)
- [asm/banks/prg_08_09.asm:84-113](file://asm/banks/prg_08_09.asm#L84-L113)

**Section sources**
- [include/functions.h:887-1071](file://include/functions.h#L887-L1071)
- [asm/banks/prg_08_09.asm:1-200](file://asm/banks/prg_08_09.asm#L1-L200)

### Mapper Abstraction and Bank Switching
The project encapsulates mapper behavior behind include/namco163.h, which defines:
- Register addresses for bank switching ($F800–$FFFF)
- Bank indices (BANK_00–BANK_1F)
- Macros for switching PRG banks at $8000, $A000, $C000, and $E000

```mermaid
classDiagram
class Namco163 {
+registers
+bank_indices
+switch_bank_8000(bank)
+switch_bank_A000(bank)
+switch_bank_C000(bank)
+switch_bank_E000(bank)
}
class BankSwitching {
+$F800
+$FA00
+$FC00
+$FE00
}
class BankIndices {
+BANK_00..BANK_1F
}
Namco163 --> BankSwitching : "defines"
Namco163 --> BankIndices : "defines"
```

**Diagram sources**
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)

**Section sources**
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [PROJECT.md:84-99](file://PROJECT.md#L84-L99)

### Automated Analysis Pipeline
The pipeline integrates Python tools with the cc65 toolchain to split, analyze, disassemble, and verify ROMs:

```mermaid
flowchart TD
Start(["Start"]) --> Split["Split ROM<br/>tools/split_rom.py"]
Split --> Analyze["Analyze ROM<br/>tools/analyze_rom.py"]
Analyze --> Stubs["Generate Bank Stubs<br/>tools/generate_bank_stubs.py"]
Stubs --> Disasm["Disassemble Banks<br/>tools/disasm_6502.py"]
Disasm --> Assemble["Assemble with cc65<br/>Makefile + linker.cfg"]
Assemble --> Verify["Verify Against Original<br/>tools/verify_rom.py"]
Verify --> End(["End"])
```

**Diagram sources**
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/analyze_rom.py:10-128](file://tools/analyze_rom.py#L10-L128)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)
- [tools/disasm_6502.py:286-334](file://tools/disasm_6502.py#L286-L334)
- [Makefile:37-48](file://Makefile#L37-L48)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)

**Section sources**
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/analyze_rom.py:10-128](file://tools/analyze_rom.py#L10-L128)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)
- [tools/disasm_6502.py:286-334](file://tools/disasm_6502.py#L286-L334)
- [Makefile:37-48](file://Makefile#L37-L48)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)

### Linker Configuration and Segments
linker.cfg defines the memory map and segments for the four PRG slots. As banks are disassembled, new segments are added to map code into the correct slots. The configuration ensures that the reset vector and interrupt vectors are placed correctly for the boot bank.

```mermaid
graph LR
ZP["ZEROPAGE"]
RAM["RAM"]
PRG0["PRG_SLOT0 $8000-$9FFF"]
PRG1["PRG_SLOT1 $A000-$BFFF"]
PRG2["PRG_SLOT2 $C000-$DFFF"]
PRG3["PRG_SLOT3 $E000-$FFFF"]
ZP --> PRG0
RAM --> PRG0
PRG0 --> PRG1
PRG1 --> PRG2
PRG2 --> PRG3
```

**Diagram sources**
- [linker.cfg:18-54](file://linker.cfg#L18-L54)

**Section sources**
- [linker.cfg:18-54](file://linker.cfg#L18-L54)
- [PROJECT.md:152-158](file://PROJECT.md#L152-L158)

### Practical Workflow: From ROM to Verified Disassembly
- Start with the original ROM and split it into 32 PRG banks and 32 CHR banks
- Analyze the ROM to identify hotspots and likely reset/vector locations
- Generate bank stubs for all PRG banks
- Disassemble the boot bank (0x1F) first to understand the reset handler and vector dispatch
- Replace stubs with real disassembly and update linker.cfg segments accordingly
- Build with cc65 and verify byte-for-byte against the original

```mermaid
sequenceDiagram
participant Dev as "Developer"
participant Split as "split_rom.py"
participant Analyze as "analyze_rom.py"
participant Stubs as "generate_bank_stubs.py"
participant Disasm as "disasm_6502.py"
participant Build as "Makefile + ld65"
participant Verify as "verify_rom.py"
Dev->>Split : Split original ROM
Split-->>Dev : 32 PRG + 32 CHR banks
Dev->>Analyze : Analyze ROM structure
Analyze-->>Dev : Vector/table candidates
Dev->>Stubs : Generate bank stubs
Stubs-->>Dev : .asm stubs for all banks
Dev->>Disasm : Disassemble boot bank (0x1F)
Disasm-->>Dev : Listing with addresses
Dev->>Build : Assemble and link
Build-->>Dev : sango2.nes
Dev->>Verify : Compare rebuilt vs original
Verify-->>Dev : Byte-accurate pass/fail
```

**Diagram sources**
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/analyze_rom.py:10-128](file://tools/analyze_rom.py#L10-L128)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)
- [tools/disasm_6502.py:286-334](file://tools/disasm_6502.py#L286-L334)
- [Makefile:37-48](file://Makefile#L37-L48)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)

**Section sources**
- [PROJECT.md:134-151](file://PROJECT.md#L134-L151)
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/analyze_rom.py:10-128](file://tools/analyze_rom.py#L10-L128)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)
- [tools/disasm_6502.py:286-334](file://tools/disasm_6502.py#L286-L334)
- [Makefile:37-48](file://Makefile#L37-L48)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)

## Dependency Analysis
The project exhibits strong cohesion within its modular bank structure and clean separation of concerns:

- asm/main.asm depends on include/namco163.h and include/6502_registers.h for mapper and register definitions
- Bank stubs in asm/banks/ depend on rom/prg/ for original binary inclusion and on linker.cfg for segment placement
- Tools are decoupled and invoked via Makefile targets, enabling reproducible builds

```mermaid
graph TB
MAIN["asm/main.asm"]
REG["include/6502_registers.h"]
MAP["include/namco163.h"]
LCFG["linker.cfg"]
STUBS["asm/banks/*.asm"]
ROM["rom/prg/*.bin"]
MK["Makefile"]
TOOLS["tools/*"]
MAIN --> REG
MAIN --> MAP
STUBS --> ROM
STUBS --> LCFG
MK --> MAIN
MK --> LCFG
MK --> TOOLS
```

**Diagram sources**
- [asm/main.asm:6-7](file://asm/main.asm#L6-L7)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [include/6502_registers.h:5-43](file://include/6502_registers.h#L5-L43)
- [linker.cfg:18-54](file://linker.cfg#L18-L54)
- [Makefile:19-28](file://Makefile#L19-L28)

**Section sources**
- [asm/main.asm:6-7](file://asm/main.asm#L6-L7)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [include/6502_registers.h:5-43](file://include/6502_registers.h#L5-L43)
- [linker.cfg:18-54](file://linker.cfg#L18-L54)
- [Makefile:19-28](file://Makefile#L19-L28)

## Performance Considerations
- Bank switching overhead: Frequent bank switches incur extra cycles and must be minimized in tight loops. The project's vector dispatch and state handlers are designed to reduce unnecessary switches.
- PPU/APU initialization: Warmup sequences and register writes are batched to avoid flicker and ensure deterministic timing.
- Disassembly accuracy: Using a dedicated disassembler with correct addressing modes and base addresses prevents misinterpretation of data as code, reducing rework during verification.
- AI processing efficiency: The enhanced Section 7 implementation optimizes AI turn processing through efficient officer scanning and decision trees.

## Troubleshooting Guide
Common issues and remedies:
- Incorrect bank mapping: Ensure bank indices and switch addresses are aligned with include/namco163.h and linker.cfg. Misalignment leads to incorrect code execution or crashes.
- Vector table misreads: Verify the vector table at $E07C and the state index at $007A. Off-by-one errors here cause jumps to invalid addresses.
- Disassembler base address errors: When disassembling banked code, use the correct base address so that CPU addresses map to file offsets accurately.
- Verification failures: Use tools/verify_rom.py to pinpoint mismatch locations and iterate until byte-identical matches are achieved.
- Section 7 integration: When working with combined banks 08+09, ensure proper bank switching between $A000-$BFFF and $C000-$DFFF ranges.

**Section sources**
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [linker.cfg:18-54](file://linker.cfg#L18-L54)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)

## Conclusion
This project demonstrates a robust, modular approach to reverse engineering a mapper-based NES game. By combining a mapper abstraction, bank-stubbed assembly, and an automated analysis pipeline, it achieves both educational clarity and technical fidelity. The enhanced Section 7 coverage for combined banks 08+09 provides comprehensive documentation of the AI turn processing and battle system, contributing significantly to understanding the game's strategic mechanics. The workflow from ROM splitting to verified disassembly provides a template applicable to other classic games, contributing to the preservation and understanding of NES architecture.

## Appendices

### Beginner-Friendly Concepts
- Bank switching: The act of replacing the contents of an 8KB window in the $8000–$FFFF range by writing to special addresses. This lets a cartridge fit more code than the console's fixed window allows.
- Vector dispatch: A table of addresses that the reset handler consults to decide where to jump next. It enables a compact dispatch mechanism across many states.
- Mapper abstraction: Encapsulating mapper-specific details (register addresses, bank indices, macros) in a single header file simplifies code reuse and reduces errors.
- Combined banks: Multiple 8KB banks can be logically combined to create larger functional units, such as the 16KB AI and battle system in banks 08+09.

**Section sources**
- [PROJECT.md:84-117](file://PROJECT.md#L84-L117)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)

### Experienced Developer Notes
- Segment management: As new banks are disassembled, add corresponding segments in linker.cfg and assign code to the correct PRG slots.
- Interrupt vectors: Ensure the reset vector points to the boot bank and that NMI/IRQ vectors are correctly placed in the vector area.
- Data vs code: Use tools/disasm_6502.py with accurate base addresses to distinguish data from code. Replace stubs with proper segments and labels.
- Section 7 development: When extending the AI system, maintain consistency with existing B08_09_* naming conventions and follow the established jump table pattern.

**Section sources**
- [linker.cfg:32-54](file://linker.cfg#L32-L54)
- [PROJECT.md:134-151](file://PROJECT.md#L134-L151)
- [tools/disasm_6502.py:286-334](file://tools/disasm_6502.py#L286-L334)
- [include/functions.h:887-1071](file://include/functions.h#L887-L1071)