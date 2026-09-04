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
- [code/cpu_ram_map.md](file://code/cpu_ram_map.md)
- [tools/split_rom.py](file://tools/split_rom.py)
- [tools/analyze_rom.py](file://tools/analyze_rom.py)
- [tools/generate_bank_stubs.py](file://tools/generate_bank_stubs.py)
- [tools/disasm_6502.py](file://tools/disasm_6502.py)
- [tools/verify_rom.py](file://tools/verify_rom.py)
- [tools/rename_battle_to_war.py](file://tools/rename_battle_to_war.py)
- [tools/extract_province_data.py](file://tools/extract_province_data.py)
- [tools/extract_officer_data.py](file://tools/extract_officer_data.py)
- [tools/scan_raw_ram_refs.py](file://tools/scan_raw_ram_refs.py)
- [tools/extract_ram_equates.py](file://tools/extract_ram_equates.py)
- [asm/main.asm](file://asm/main.asm)
- [asm/banks/prg_1f.asm](file://asm/banks/prg_1f.asm)
- [asm/banks/prg_00.asm](file://asm/banks/prg_00.asm)
- [asm/banks/prg_08_09.asm](file://asm/banks/prg_08_09.asm)
- [asm/banks/prg_1d_1e.asm](file://asm/banks/prg_1d_1e.asm)
- [asm/banks/prg_19_1a.asm](file://asm/banks/prg_19_1a.asm)
- [code/bank_1f_plan.md](file://code/bank_1f_plan.md)
- [code/key_functions_analysis.md](file://code/key_functions_analysis.md)
- [docs/manual_kb/README.md](file://docs/manual_kb/README.md)
- [docs/manual_kb/terminology.md](file://docs/manual_kb/terminology.md)
- [docs/manual_kb/01-overview.md](file://docs/manual_kb/01-overview.md)
- [docs/manual_kb/04-strategy-commands.md](file://docs/manual_kb/04-strategy-commands.md)
- [docs/manual_kb/07-war-rules.md](file://docs/manual_kb/07-war-rules.md)
- [docs/manual_kb/09-battle-mode.md](file://docs/manual_kb/09-battle-mode.md)
- [docs/manual_kb/14-map.md](file://docs/manual_kb/14-map.md)
- [memory/README.md](file://memory/README.md)
</cite>

## Update Summary
**Changes Made**
- Added comprehensive CPU memory mapping documentation covering 19 functional groups across internal RAM ($0000-$07FF) and PRG-RAM window ($6000-$7FFF)
- Enhanced data extraction capabilities with sophisticated province and officer data analysis tools
- Expanded tooling infrastructure with extensive ROM parsing and analysis scripts
- Integrated automated memory reference scanning for raw bank analysis
- Strengthened knowledge base with consolidated memory architecture documentation

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Knowledge Base Framework](#knowledge-base-framework)
6. [Detailed Component Analysis](#detailed-component-analysis)
7. [Data Extraction Capabilities](#data-extraction-capabilities)
8. [Memory Mapping Architecture](#memory-mapping-architecture)
9. [Map-Screen Scene Subsystem](#map-screen-scene-subsystem)
10. [Dependency Analysis](#dependency-analysis)
11. [Performance Considerations](#performance-considerations)
12. [Troubleshooting Guide](#troubleshooting-guide)
13. [Conclusion](#conclusion)
14. [Appendices](#appendices)

## Introduction
This project is a complete reverse engineering and disassembly effort for the Namco-163 (Mapper 19) strategy game Sangokushi 2 - Haou no Tairiku (J) for the Nintendo Entertainment System (NES). The goal is to produce a faithful, byte-accurate recreation of the original ROM using modern tooling and a modular, bank-based organization. The project covers 32 programmable PRG banks (256KB) and mirrors the game's mapper abstraction to support 8KB bank switching across four PRG slots ($8000–$FFFF). It also documents the reset handler, vector dispatch mechanism, and the bank-switched code that implements gameplay states, display, audio, and I/O.

Beyond technical reconstruction, this project serves as an educational resource for retro gaming preservation. It demonstrates how to split, analyze, and rebuild a complex mapper-based ROM while maintaining byte-for-byte fidelity, and it provides a reusable framework applicable to other games using similar mappers. **The project now includes a comprehensive knowledge base structure containing 94 structured documents across multiple categories**, establishing a canonical reference framework for terminology standardization and game mechanics understanding throughout the disassembly process.

**Updated** The project has undergone significant enhancements including comprehensive CPU memory mapping documentation covering 19 functional groups, advanced data extraction capabilities for province and officer data, and expanded tooling infrastructure. The automated `rename_battle_to_war.py` tool ensures consistent application of war-focused terminology across all relevant files including PRG banks, function headers, and assembly code. The project now features sophisticated data extraction tools with verified ROM analysis and automated memory reference scanning capabilities.

## Project Structure
The repository is organized around a modular bank-based approach and a cc65 toolchain integration, enhanced by a structured knowledge base system and advanced data extraction capabilities. The structure supports incremental disassembly and verification:

- asm/: Assembly entry point and per-bank stubs with consolidated scene subsystems
- include/: 6502/PPU/APU/Namco-163 register and macro definitions
- rom/: Split PRG/CHR banks and combined binaries
- tools/: Python scripts for ROM splitting, analysis, disassembly, bank stub generation, verification, and data extraction
- code/: Disassembly plans, analyses, and comprehensive memory mapping documentation
- docs/manual_kb/: **Enhanced** Comprehensive knowledge base with 94 structured documents covering all aspects of the game
- memory/: **New** Extensive memory dump documentation with categorized experiences and specifications
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
J["docs/manual_kb/*"]
K["memory/*"]
end
subgraph "Build System"
L["ca65/ld65"]
M["build/"]
end
A --> B --> L
C --> L
D --> L
E --> L
F --> L
H --> L
I --> L
J --> L
K --> L
L --> M
M --> G
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
- **Enhanced knowledge base framework**: Structured documentation system providing canonical terminology and game mechanics reference for consistent disassembly naming and understanding, now covering 94 articles across multiple categories.
- **Advanced data extraction capabilities**: Sophisticated tools for extracting and analyzing province and officer data from the ROM with verified field mappings and semantic English terminology.
- **Comprehensive memory mapping**: Consolidated view of CPU address space usage across internal RAM and PRG-RAM window with 19 functional groups and detailed semantic documentation.

**Updated** The core components now feature comprehensive CPU memory mapping documentation, enhanced data extraction capabilities, and standardized war terminology throughout. All battle-related functionality has been renamed to use War* prefixes, including WarSetup, WarPhaseProcess, WarCasualtyResolution, and WarResultDispatch, reflecting the game's focus on strategic warfare rather than individual battles. The automated terminology alignment tool ensures consistency across all war-related components.

Practical outcomes:
- Byte-accurate ROM verification against the original
- Incremental disassembly workflow from the boot bank to other banks
- Reusable bank stubs and linker segments for ongoing analysis
- **Standardized terminology framework for consistent label naming across all disassembled code**
- **Comprehensive data extraction and analysis capabilities for game content**
- **Detailed memory architecture documentation for development guidance**

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
KB["Knowledge Base<br/>docs/manual_kb/*"]
EXTRACT["Data Extraction<br/>tools/*"]
SCENE["Scene Subsystem<br/>banks 1D/1E, 19/1A"]
MEM["Memory Mapping<br/>code/cpu_ram_map.md"]
end
RST --> VEC
VEC --> STATE
STATE --> MAP
STATE --> KB
STATE --> EXTRACT
STATE --> SCENE
STATE --> MEM
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

## Knowledge Base Framework
**Updated** The project now includes a comprehensive knowledge base structure consisting of 94 structured documents transcribed from the original Japanese manual scans and extensive development documentation. This framework establishes a canonical reference system for terminology standardization and game mechanics understanding throughout the disassembly process.

### Knowledge Base Structure
The knowledge base is organized into thematic categories covering all aspects of the game and development experience:

| Category | Documents | Purpose |
|----------|-----------|---------|
| **Overview & Setup** | 01-overview.md | Game premise, modes, victory rules, setup flow |
| **Statistics & Data** | 02-general-stats.md, 03-country-stats.md | Officer attributes, country statistics |
| **Gameplay Mechanics** | 04-strategy-commands.md, 05-events.md | Strategy mode commands, monthly events |
| **Reference Tables** | 06-reference-tables.md | Quick reference tables for operations |
| **War System** | 07-war-rules.md | War rules, victory conditions, processing |
| **Tactical Systems** | 08-tactical-mode.md, 09-battle-mode.md, 10-duel-mode.md | Tactical, battle, and duel mode mechanics |
| **Progression** | 11-levelup.md | Officer level-up system |
| **Strategy & Guidance** | 12-strategy-advice.md, 13-ruler-guide.md | Strategic advice and ruler-specific guides |
| **World Map** | 14-map.md | Complete 30-country faction map |
| **Development Specifications** | 12+ documents | Code conventions, naming standards, best practices |
| **Common Pitfalls** | 21+ documents | Lessons learned and troubleshooting guidance |
| **Architectural Decisions** | 7+ documents | Design rationale and implementation patterns |

### Terminology Standardization System
The consolidated semantic English glossary ([terminology.md](file://docs/manual_kb/terminology.md)) serves as the authoritative vocabulary source for naming labels, procedures, and RAM symbols throughout the disassembly. Key features include:

- **PascalCase Convention**: All identifiers follow established PascalCase semantic-English convention (e.g., `StratagemExecute`, `FormationSelect`)
- **Domain-Specific Naming**: Dispatch/handler routines follow patterns like `<Domain>ActionDispatch`, `<Domain>CommandSelect`
- **Mode Hierarchy**: Clear distinction between Strategy Mode, Tactical Mode, Battle Mode, and Duel Mode
- **Statistical Terminology**: Canonical names for officer stats, country data, and game variables

**Updated** The terminology system now emphasizes war-focused language throughout, with systematic replacement of battle-related terms with war equivalents. This includes strategic command names such as LandReclamation (formerly LandDevelop), DisasterPrevention (formerly FloodControl), and UnidentifiedCmd (formerly CastleRepair), ensuring consistency with the game's actual terminology. The automated `rename_battle_to_war.py` tool applies these changes consistently across all code files.

```mermaid
flowchart TD
KB[Knowledge Base] --> TERM[Terminology Glossary]
TERM --> NAMING[Disassembly Naming]
NAMING --> CODE[Consistent Code Labels]
CODE --> UNDERSTANDING[Enhanced Understanding]
UNDERSTANDING --> MAINTENANCE[Easier Maintenance]
```

**Diagram sources**
- [docs/manual_kb/README.md:1-15](file://docs/manual_kb/README.md#L1-L15)
- [docs/manual_kb/terminology.md:1-16](file://docs/manual_kb/terminology.md#L1-L16)

**Section sources**
- [docs/manual_kb/README.md:16-97](file://docs/manual_kb/README.md#L16-L97)
- [docs/manual_kb/terminology.md:17-293](file://docs/manual_kb/terminology.md#L17-L293)

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

### Enhanced Section 7: Combined Banks 08+09 - AI Turn Processing and War System
**Updated** Enhanced Section 7 coverage now includes comprehensive jump-table entries and internal procedures for combined banks 08+09 with B08_09_* prefixed function declarations. This section implements the core AI turn processing and war system functionality with standardized war terminology throughout.

The combined banks 08+09 provide a 16KB memory space ($A000-$DFFF) containing:
- **Jump Table Entry Points**: 14 entry points at $A000-$A02A handling AI turn processing, war setup, casualty resolution, and result scenes
- **AI Decision Engine**: Complete AI officer action system with strategic decision-making, movement planning, and combat evaluation
- **War System**: Full war phase processing including unit positioning, combat calculations, and result scene management
- **Strategic Elements**: Formation management, terrain effects, and special officer validation

**Updated Terminology**: All war-related functions now use War* prefix instead of Battle*:
- WarSetup_Entry, WarPhaseProcess_Entry, WarCasualtyResolution_Entry
- WarAttritionRound_Entry, WarStatusPanelDraw_Entry, WarMapScrollUpdate_Entry
- WarResultDispatch_Entry, WarResultSceneInit_Entry, WarSlotClear_Entry

The automated terminology alignment tool (`rename_battle_to_war.py`) ensures consistent application of these changes across all war-related components, including RAM equates, procedure labels, and entry stubs.

```mermaid
flowchart TD
AITP[AiTurnProcess_Entry] --> AILOOP[Officer Loop]
AILOOP --> DECIDE[AiOfficerActionDecide]
DECIDE --> ACTION[Action Handler]
ACTION --> MOVE[AiExecuteMove]
ACTION --> ATTACK[War Setup]
MOVE --> EVAL[Evaluate Options]
ATTACK --> PHASE[WarPhaseProcess]
PHASE --> RESOLVE[WarResultDispatch]
RESOLVE --> SCENE[WarResultSceneInit]
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
- [linker.cfg:18-54](file://linker.cfg#L18-54)

**Section sources**
- [linker.cfg:18-54](file://linker.cfg#L18-54)
- [PROJECT.md:152-158](file://PROJECT.md#L152-L158)

### Practical Workflow: From ROM to Verified Disassembly
- Start with the original ROM and split it into 32 PRG banks and 32 CHR banks
- Analyze the ROM to identify hotspots and likely reset/vector locations
- Generate bank stubs for all PRG banks
- Disassemble the boot bank (0x1F) first to understand the reset handler and vector dispatch
- Replace stubs with real disassembly and update linker.cfg segments accordingly
- Build with cc65 and verify byte-for-byte against the original
- **Use knowledge base terminology for consistent labeling throughout the process**

**Updated** The workflow now incorporates the standardized war terminology system, ensuring that all labels and procedures use consistent War* prefixes and strategic command names like LandReclamation and DisasterPrevention. The automated `rename_battle_to_war.py` tool can be applied to maintain consistency across all war-related components.

```mermaid
sequenceDiagram
participant Dev as "Developer"
participant Split as "split_rom.py"
participant Analyze as "analyze_rom.py"
participant Stubs as "generate_bank_stubs.py"
participant Disasm as "disasm_6502.py"
participant KB as "Knowledge Base"
participant Rename as "rename_battle_to_war.py"
participant Build as "Makefile + ld65"
participant Verify as "verify_rom.py"
Dev->>Split : Split original ROM
Split-->>Dev : 32 PRG + 32 CHR banks
Dev->>Analyze : Analyze ROM structure
Analyze-->>Dev : Vector/table candidates
Dev->>Stubs : Generate bank stubs
Stubs-->>Dev : .asm stubs for all banks
Dev->>KB : Consult terminology guide
KB-->>Dev : Canonical naming conventions
Dev->>Rename : Apply war terminology
Rename-->>Dev : Updated labels and functions
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
- [tools/rename_battle_to_war.py:1-135](file://tools/rename_battle_to_war.py#L1-L135)
- [Makefile:37-48](file://Makefile#L37-L48)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)

**Section sources**
- [PROJECT.md:134-151](file://PROJECT.md#L134-L151)
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/analyze_rom.py:10-128](file://tools/analyze_rom.py#L10-L128)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)
- [tools/disasm_6502.py:286-334](file://tools/disasm_6502.py#L286-L334)
- [tools/rename_battle_to_war.py:1-135](file://tools/rename_battle_to_war.py#L1-L135)
- [Makefile:37-48](file://Makefile#L37-L48)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)

## Data Extraction Capabilities
**New** The project now includes sophisticated data extraction capabilities for analyzing game content directly from the ROM image. These tools provide comprehensive analysis of province and officer data with verified field mappings and semantic English terminology.

### Province Data Extraction
The `extract_province_data.py` tool extracts complete province information including:
- **Province Names**: Katakana names decoded from ROM with Chinese translations
- **Master Records**: 32-byte starting records for each of the 30 provinces
- **Field Mapping**: Verified field layouts based on code analysis with semantic English names
- **Country Ownership**: Starting ownership and ruler identification
- **Statistical Data**: Gold, rice, population, land value, industry, disaster prevention, governance, troops, treasure, and revolt cooldown

### Officer Data Extraction  
The `extract_officer_data.py` tool provides detailed officer analysis:
- **Officer Records**: 12-byte master records for 237 officers with verified field layouts
- **Equipment Data**: Weapon and armor assignments with Japanese terminology
- **Statistical Attributes**: Vitality, might, intelligence, loyalty, virtue, experience, troop count
- **Army Affinity**: Terrain affinity codes (plains, mountain, naval)
- **Level Information**: Officer levels and experience values

```mermaid
flowchart TD
ROM["Original ROM"] --> PROV["extract_province_data.py"]
ROM --> OFFICER["extract_officer_data.py"]
PROV --> PROV_CSV["province_data.csv"]
PROV --> PROV_MD["province_data.md"]
PROV --> PROV_INC["province_ids.inc"]
OFFICER --> OFFICER_CSV["officer_data.csv"]
OFFICER --> OFFICER_MD["officer_data.md"]
PROV_CSV --> ANALYSIS["Data Analysis"]
OFFICER_CSV --> ANALYSIS
ANALYSIS --> INSIGHTS["Game Insights"]
```

**Diagram sources**
- [tools/extract_province_data.py:1-616](file://tools/extract_province_data.py#L1-L616)
- [tools/extract_officer_data.py:1-311](file://tools/extract_officer_data.py#L1-L311)

**Section sources**
- [tools/extract_province_data.py:1-616](file://tools/extract_province_data.py#L1-L616)
- [tools/extract_officer_data.py:1-311](file://tools/extract_officer_data.py#L1-L311)

## Memory Mapping Architecture
**New** The project now features comprehensive CPU memory mapping documentation that provides a consolidated view of the entire CPU address space used by data across both internal RAM ($0000-$07FF) and PRG-RAM window ($6000-$7FFF).

### Functional Group Organization
The memory map is organized into 19 distinct functional groups that provide clear separation of concerns:

| Group | Range | Purpose |
|-------|-------|---------|
| 1 | `$0000-$001F`, `$0020-$0029` | Math ABI / proc-local scratch |
| 2 | `$0030-$0045` | Shared search & work area |
| 3 | `$004E-$005D` | Dispatch, RNG, banked-call trampoline |
| 4 | `$005E-$0062`, `$0068-$0069`, `$0078-$007E` | Frame / IRQ / NMI kernel cells |
| 5 | `$0081-$0086` | Controller latches |
| 6 | `$0087-$0099` | PPU shadows, palette animation, scroll |
| 7 | `$00A5`, `$00AE-$00B5`, `$00DE-$00ED` | Mapper shadows (CHR / PRG / write-protect) |
| 8 | `$00A6-$00DD` | Scene/state-handler pointers (bank `$1D/$1E`) |
| 9 | `$0100-$01FF` | Stack page + reused scratch buffers |
| 10 | `$0200-$02FF` | OAM shadow |
| 11 | `$0300-$03FF` | VRAM update queue + display buffers |
| 12 | `$0400-$04FF` | Scene / menu / UI handshake page |
| 13 | `$0500-$05FF` | Mode state machines (war / exchange / battle) |
| 14 | `$0600-$06FF` | Unit rosters and map tile grids |
| 15 | `$0700-$07F9` | Sound engine channel array + scratch |
| 16 | `$6000-$63BF` | Province records (30 × 32 B) |
| 17 | `$63C0-$6EFF` | Officer records (12 B each) |
| 18 | `$6F00-$6FFF` | Global game state, Country records, AI scratch |
| 19 | `$7000-$7FFF` | Save snapshot + magic + checksum |

### Advanced Memory Analysis Tools
The memory mapping documentation leverages several sophisticated analysis tools:
- **Automated Equate Extraction**: `tools/extract_ram_equates.py` generates comprehensive equate inventories
- **Raw Reference Scanning**: `tools/scan_raw_ram_refs.py` analyzes comment-documented banks for memory usage patterns
- **Cross-Bank Alias Detection**: Identifies addresses with different meanings across different game modes
- **Semantic Naming Integration**: Follows project conventions with `addr_*` prefixes for shared kernel cells

```mermaid
flowchart TD
MEMDOC["Memory Mapping Doc"] --> GROUPS["19 Functional Groups"]
GROUPS --> ZERO_PAGE["Zero Page $0000-$00FF"]
GROUPS --> STACK_PAGE["Stack Page $0100-$01FF"]
GROUPS --> MODE_PAGES["Mode Pages $0200-$07FF"]
GROUPS --> WRAM["WRAM $6000-$7FFF"]
ZERO_PAGE --> KERNEL["Kernel Cells"]
ZERO_PAGE --> MODE_SCOPED["Mode-Scoped Cells"]
MODE_PAGES --> SOUND["Sound Engine"]
MODE_PAGES --> DISPLAY["Display Buffers"]
WRAM --> PROVINCES["Province Records"]
WRAM --> OFFICERS["Officer Records"]
WRAM --> GLOBAL["Global State"]
WRAM --> SAVE["Save Snapshot"]
```

**Diagram sources**
- [code/cpu_ram_map.md:49-71](file://code/cpu_ram_map.md#L49-L71)
- [code/cpu_ram_map.md:75-133](file://code/cpu_ram_map.md#L75-L133)
- [code/cpu_ram_map.md:291-416](file://code/cpu_ram_map.md#L291-L416)

**Section sources**
- [code/cpu_ram_map.md:1-494](file://code/cpu_ram_map.md#L1-L494)

## Map-Screen Scene Subsystem
**New** The map-screen scene subsystem has been consolidated across banks 1D/1E and 19/1A, providing comprehensive map display and interaction capabilities with enhanced scene management.

### Scene Architecture
The consolidated scene subsystem includes:
- **SceneRenderer**: Centralized rendering system for map display and sprite management
- **StateHandler**: Unified state management for different map interactions
- **BankedDataHandler**: Efficient data loading and caching for large map datasets
- **Sprite Management**: OAM buffer management for map elements and units

### Key Components
- **MapDisplaySetup**: Configures map display parameters and viewport settings
- **OfficerListHandler**: Manages officer selection and list display on the map
- **ArmyDeploySceneTrigger**: Handles army deployment transitions between scenes
- **Work Buffer Management**: Optimized memory usage for map rendering operations

```mermaid
stateDiagram-v2
[*] --> MapDisplay
MapDisplay --> OfficerList : Select Officer
MapDisplay --> ArmyDeploy : Deploy Army
OfficerList --> MapDisplay : Deselect
ArmyDeploy --> MapDisplay : Deployment Complete
MapDisplay --> [*] : Exit Game
```

**Diagram sources**
- [asm/banks/prg_1d_1e.asm:120-167](file://asm/banks/prg_1d_1e.asm#L120-L167)
- [asm/banks/prg_19_1a.asm:5677-5697](file://asm/banks/prg_19_1a.asm#L5677-L5697)

**Section sources**
- [asm/banks/prg_1d_1e.asm:120-167](file://asm/banks/prg_1d_1e.asm#L120-L167)
- [asm/banks/prg_19_1a.asm:5677-5697](file://asm/banks/prg_19_1a.asm#L5677-L5697)

## Dependency Analysis
The project exhibits strong cohesion within its modular bank structure and clean separation of concerns:

- asm/main.asm depends on include/namco163.h and include/6502_registers.h for mapper and register definitions
- Bank stubs in asm/banks/ depend on rom/prg/ for original binary inclusion and on linker.cfg for segment placement
- Tools are decoupled and invoked via Makefile targets, enabling reproducible builds
- **Enhanced knowledge base documents provide cross-references between game mechanics and implementation details**
- **Data extraction tools create dependencies between ROM analysis and documentation generation**
- **Memory mapping documentation provides comprehensive reference for address space usage**

**Updated** The dependency analysis now includes the automated terminology alignment tool (rename_battle_to_war.py), data extraction capabilities, and memory mapping documentation which ensure consistency across all war-related components, game content analysis, and address space understanding.

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
KB["docs/manual_kb/*"]
MEMORY["memory/*"]
RENAME["rename_battle_to_war.py"]
EXTRACT["extract_*_data.py"]
MEMMAP["cpu_ram_map.md"]
MAIN --> REG
MAIN --> MAP
STUBS --> ROM
STUBS --> LCFG
MK --> MAIN
MK --> LCFG
MK --> TOOLS
KB --> STUBS
KB --> TOOLS
MEMORY --> TOOLS
RENAME --> STUBS
RENAME --> TOOLS
RENAME --> KB
EXTRACT --> ROM
EXTRACT --> KB
EXTRACT --> MEMORY
MEMMAP --> STUBS
MEMMAP --> TOOLS
MEMMAP --> KB
```

**Diagram sources**
- [asm/main.asm:6-7](file://asm/main.asm#L6-L7)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [include/6502_registers.h:5-43](file://include/6502_registers.h#L5-L43)
- [linker.cfg:18-54](file://linker.cfg#L18-54)
- [Makefile:19-28](file://Makefile#L19-L28)
- [tools/rename_battle_to_war.py:1-135](file://tools/rename_battle_to_war.py#L1-L135)
- [code/cpu_ram_map.md:1-494](file://code/cpu_ram_map.md#L1-L494)

**Section sources**
- [asm/main.asm:6-7](file://asm/main.asm#L6-L7)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [include/6502_registers.h:5-43](file://include/6502_registers.h#L5-L43)
- [linker.cfg:18-54](file://linker.cfg#L18-54)
- [Makefile:19-28](file://Makefile#L19-L28)

## Performance Considerations
- Bank switching overhead: Frequent bank switches incur extra cycles and must be minimized in tight loops. The project's vector dispatch and state handlers are designed to reduce unnecessary switches.
- PPU/APU initialization: Warmup sequences and register writes are batched to avoid flicker and ensure deterministic timing.
- Disassembly accuracy: Using a dedicated disassembler with correct addressing modes and base addresses prevents misinterpretation of data as code, reducing rework during verification.
- AI processing efficiency: The enhanced Section 7 implementation optimizes AI turn processing through efficient officer scanning and decision trees.
- **Enhanced knowledge base integration**: Terminology consistency reduces cognitive load during development and maintenance, improving overall productivity.
- **Optimized data extraction**: Streamlined ROM parsing and analysis reduce processing time for large datasets.
- **Memory mapping optimization**: The 19-group functional organization enables targeted performance analysis and optimization strategies.

**Updated** The performance considerations now include the benefits of standardized war terminology, consolidated scene subsystems, and comprehensive memory mapping documentation. The automated terminology alignment tool helps maintain consistency without manual intervention, reducing potential errors and improving development efficiency. The detailed memory mapping enables precise performance analysis of address space usage patterns.

## Troubleshooting Guide
Common issues and remedies:
- Incorrect bank mapping: Ensure bank indices and switch addresses are aligned with include/namco163.h and linker.cfg. Misalignment leads to incorrect code execution or crashes.
- Vector table misreads: Verify the vector table at $E07C and the state index at $007A. Off-by-one errors here cause jumps to invalid addresses.
- Disassembler base address errors: When disassembling banked code, use the correct base address so that CPU addresses map to file offsets accurately.
- Verification failures: Use tools/verify_rom.py to pinpoint mismatch locations and iterate until byte-identical matches are achieved.
- Section 7 integration: When working with combined banks 08+09, ensure proper bank switching between $A000-$BFFF and $C000-$DFFF ranges.
- **Terminology inconsistencies**: Refer to docs/manual_kb/terminology.md for canonical naming conventions when creating new labels or procedures.
- **Data extraction issues**: Validate ROM integrity and ensure correct file paths when using extraction tools.
- **Memory mapping conflicts**: Use the comprehensive memory mapping documentation to identify address aliasing issues and functional group boundaries.

**Updated** Additional troubleshooting guidance for enhanced features:
- **War vs Battle terminology**: Use rename_battle_to_war.py to automatically align terminology across the codebase
- **Strategic command names**: Verify that commands use updated names (LandReclamation, DisasterPrevention, UnidentifiedCmd)
- **Function naming**: Ensure all war-related functions use War* prefix instead of Battle*
- **Siege equipment references**: Check for correct siege ladder terminology (連弩 vs 雲梯) in strategic tables
- **Scene subsystem issues**: Verify proper bank switching between map screen scenes in banks 1D/1E and 19/1A
- **Data extraction validation**: Use --check flag with extraction tools to validate ROM integrity and data consistency
- **Memory aliasing problems**: Consult cpu_ram_map.md for cross-bank address aliasing patterns and mode-specific usage
- **Functional group conflicts**: Use the 19-group organization to isolate and resolve memory conflicts

**Section sources**
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [linker.cfg:18-54](file://linker.cfg#L18-54)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)
- [tools/rename_battle_to_war.py:1-135](file://tools/rename_battle_to_war.py#L1-L135)
- [code/cpu_ram_map.md:1-494](file://code/cpu_ram_map.md#L1-L494)

## Conclusion
This project demonstrates a robust, modular approach to reverse engineering a mapper-based NES game. By combining a mapper abstraction, bank-stubbed assembly, an automated analysis pipeline, and a comprehensive knowledge base framework, it achieves both educational clarity and technical fidelity. The enhanced Section 7 coverage for combined banks 08+09 provides comprehensive documentation of the AI turn processing and war system, contributing significantly to understanding the game's strategic mechanics. **The addition of the knowledge base structure represents a major advancement in the project's ability to preserve and communicate game terminology and mechanics.** The workflow from ROM splitting to verified disassembly provides a template applicable to other classic games, contributing to the preservation and understanding of NES architecture.

**Updated** The major enhancements include comprehensive CPU memory mapping documentation covering 19 functional groups, advanced data extraction capabilities, and expanded knowledge base coverage to 94 articles. The systematic renaming from 'battle' to 'war' terminology throughout the codebase represents a significant improvement in clarity and consistency. The automated tools ensure that terminology consistency is maintained across all relevant files, making the codebase more maintainable and easier to understand for future contributors. The sophisticated data extraction capabilities provide unprecedented insight into game content and structure, while the comprehensive memory mapping documentation enables precise development and debugging workflows.

## Appendices

### Beginner-Friendly Concepts
- Bank switching: The act of replacing the contents of an 8KB window in the $8000–$FFFF range by writing to special addresses. This lets a cartridge fit more code than the console's fixed window allows.
- Vector dispatch: A table of addresses that the reset handler consults to decide where to jump next. It enables a compact dispatch mechanism across many states.
- Mapper abstraction: Encapsulating mapper-specific details (register addresses, bank indices, macros) in a single header file simplifies code reuse and reduces errors.
- Combined banks: Multiple 8KB banks can be logically combined to create larger functional units, such as the 16KB AI and war system in banks 08+09.
- **Enhanced knowledge base utilization**: The structured documentation system provides authoritative references for game terminology, mechanics, and implementation guidance throughout the disassembly process.

**Updated** New concepts specific to the enhanced project:
- **War terminology**: Systematic use of 'war' instead of 'battle' to reflect the strategic nature of the game's conflict resolution
- **Data extraction workflows**: Understanding how to use extraction tools for province and officer data analysis
- **Scene subsystem architecture**: Consolidated map-screen scene management across multiple banks
- **Automated terminology alignment**: The rename_battle_to_war.py tool ensures consistent application of war terminology across all code files
- **Memory mapping concepts**: Understanding the 19 functional groups and their roles in the overall system architecture
- **Address aliasing patterns**: Recognizing how the same addresses can have different meanings across different game modes

**Section sources**
- [PROJECT.md:84-117](file://PROJECT.md#L84-L117)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)

### Experienced Developer Notes
- Segment management: As new banks are disassembled, add corresponding segments in linker.cfg and assign code to the correct PRG slots.
- Interrupt vectors: Ensure the reset vector points to the boot bank and that NMI/IRQ vectors are correctly placed in the vector area.
- Data vs code: Use tools/disasm_6502.py with accurate base addresses to distinguish data from code. Replace stubs with proper segments and labels.
- Section 7 development: When extending the AI system, maintain consistency with existing B08_09_* naming conventions and follow the established jump table pattern.
- **Enhanced knowledge base integration**: Leverage the terminology glossary and game mechanics documentation to ensure consistent naming and understanding across all disassembled components.
- **Data extraction development**: Utilize extraction tools for analyzing game content and generating documentation from ROM data.

**Updated** Additional guidance for enhanced features:
- **Terminology alignment**: Use rename_battle_to_war.py to ensure consistent war terminology across all components
- **War function patterns**: Follow established patterns for War* prefixed functions in the war system
- **Strategic command implementation**: Implement commands using updated names (LandReclamation, DisasterPrevention, UnidentifiedCmd)
- **Scene subsystem development**: Work with consolidated scene architecture across banks 1D/1E and 19/1A
- **Data extraction workflows**: Use extraction tools to analyze and document game content systematically
- **Memory mapping utilization**: Leverage the 19-group functional organization for targeted development and debugging
- **Address aliasing awareness**: Understand cross-bank address aliasing patterns when implementing new features

**Section sources**
- [linker.cfg:32-54](file://linker.cfg#L32-L54)
- [PROJECT.md:134-151](file://PROJECT.md#L134-L151)
- [tools/disasm_6502.py:286-334](file://tools/disasm_6502.py#L286-L334)
- [include/functions.h:887-1071](file://include/functions.h#L887-L1071)
- [tools/rename_battle_to_war.py:1-135](file://tools/rename_battle_to_war.py#L1-L135)
- [code/cpu_ram_map.md:1-494](file://code/cpu_ram_map.md#L1-L494)

### Knowledge Base Integration Guide
**Enhanced** The knowledge base serves as a central reference for understanding game mechanics and ensuring consistent terminology throughout the disassembly process, now covering 94 articles across multiple categories.

#### Key Resources
- **Primary Reference**: [docs/manual_kb/README.md](file://docs/manual_kb/README.md) - Complete index and scan-to-page mapping
- **Terminology Authority**: [docs/manual_kb/terminology.md](file://docs/manual_kb/terminology.md) - Consolidated semantic English glossary
- **Game Mechanics**: Individual documents covering specific aspects of gameplay (strategy commands, battle systems, etc.)
- **Development Documentation**: Extensive memory dump documentation with categorized experiences and specifications
- **Memory Architecture**: Comprehensive CPU memory mapping documentation with 19 functional groups

#### Usage Patterns
1. **Before implementing new features**: Consult relevant knowledge base documents for canonical terminology
2. **When naming labels/procedures**: Follow PascalCase semantic-English conventions from terminology.md
3. **For understanding game logic**: Reference specific mechanic documents for accurate implementation
4. **During code review**: Verify terminology consistency against the knowledge base
5. **For data analysis**: Use extraction tools to generate documentation from ROM content

**Updated** Enhanced usage patterns for the expanded knowledge base:
- **War terminology verification**: Cross-reference war-related components with terminology.md to ensure consistent 'war' vs 'battle' usage
- **Strategic command alignment**: Verify command names match updated terminology (LandReclamation, DisasterPrevention, UnidentifiedCmd)
- **Scene subsystem consistency**: Use consolidated documentation for map-screen scene development
- **Data extraction workflows**: Leverage extraction tools for systematic ROM analysis and documentation generation
- **Memory dump navigation**: Utilize categorized memory documentation for troubleshooting and development guidance
- **Memory mapping consultation**: Reference cpu_ram_map.md for address space usage patterns and functional group boundaries
- **Address aliasing analysis**: Use memory mapping documentation to understand cross-bank address relationships

**Section sources**
- [docs/manual_kb/README.md:1-97](file://docs/manual_kb/README.md#L1-L97)
- [docs/manual_kb/terminology.md:1-293](file://docs/manual_kb/terminology.md#L1-L293)
- [memory/README.md:1-148](file://memory/README.md#L1-L148)
- [tools/rename_battle_to_war.py:1-135](file://tools/rename_battle_to_war.py#L1-L135)
- [code/cpu_ram_map.md:1-494](file://code/cpu_ram_map.md#L1-L494)