# ROM Analysis and Understanding

<cite>
**Referenced Files in This Document**
- [PROJECT.md](file://PROJECT.md)
- [Makefile](file://Makefile)
- [split_rom.py](file://tools/split_rom.py)
- [analyze_rom.py](file://tools/analyze_rom.py)
- [analyze_bank_1f.py](file://tools/analyze_bank_1f.py)
- [analyze_bank_1f_full.py](file://tools/analyze_bank_1f_full.py)
- [disasm_6502.py](file://tools/disasm_6502.py)
- [disasm_bank_1f.py](file://tools/disasm_bank_1f.py)
- [generate_bank_stubs.py](file://tools/generate_bank_stubs.py)
- [annotate_asm.py](file://tools/annotate_asm.py)
- [rom_info.h](file://rom/rom_info.h)
- [namco163.h](file://include/namco163.h)
- [main.asm](file://asm/main.asm)
- [bank_1f_analysis.md](file://code/bank_1f_analysis.md)
- [bank_1f_plan.md](file://code/bank_1f_plan.md)
- [key_functions_analysis.md](file://code/key_functions_analysis.md)
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
10. [Appendices](#appendices)

## Introduction
This document explains how to understand the original game ROM structure and how to analyze it systematically for disassembly. It focuses on:
- How the ROM is split into 32 PRG banks (8 KB each) and 32 CHR banks (8 KB each) for the Namco-163 (Mapper 19) system
- How to interpret ROM characteristics using bank analysis metrics such as JSR/RTI ratios, interrupt vector patterns, and code density
- How interrupt vectors are detected and how the reset handler location at $E000 in bank 0x1F is identified
- Practical examples of analyzing ROM characteristics, interpreting results, and planning disassembly
- The relationship between ROM structure and the game’s execution flow

## Project Structure
The repository organizes ROM analysis and disassembly around a clear pipeline:
- ROM splitting into PRG/CHR banks
- Bank analysis to identify characteristics and entry points
- Disassembly of individual banks, especially the boot bank (0x1F)
- Assembly and verification against the original ROM

```mermaid
graph TB
A["Original ROM<br/>Sangokushi 2 - Haou no Tairiku (J).nes"] --> B["split_rom.py<br/>Split into PRG/CHR banks"]
B --> C["rom_info.h<br/>Mapper, PRG/CHR counts"]
B --> D["rom/prg/*.bin<br/>32 x 8KB PRG banks"]
B --> E["rom/chr/*.bin<br/>32 x 8KB CHR banks"]
D --> F["analyze_rom.py<br/>Bank characteristics"]
D --> G["disasm_6502.py<br/>Basic disassembly"]
D --> H["disasm_bank_1f.py<br/>Full bank 0x1F disassembly"]
D --> I["generate_bank_stubs.py<br/>Bank stubs for assembly"]
I --> J["asm/banks/*.asm<br/>Assembly stubs"]
J --> K["annotate_asm.py<br/>Annotate with ROM bytes"]
K --> L["asm/main.asm<br/>Vectors and entry points"]
L --> M["Makefile<br/>Build and verify"]
```

**Diagram sources**
- [split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [rom_info.h:1-9](file://rom/rom_info.h#L1-L9)
- [analyze_rom.py:10-135](file://tools/analyze_rom.py#L10-L135)
- [disasm_6502.py:286-363](file://tools/disasm_6502.py#L286-L363)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [annotate_asm.py:315-481](file://tools/annotate_asm.py#L315-L481)
- [main.asm:134-141](file://asm/main.asm#L134-L141)
- [Makefile:54-75](file://Makefile#L54-L75)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [Makefile:54-75](file://Makefile#L54-L75)

## Core Components
- ROM splitter: Parses iNES header, splits PRG/CHR into 8 KB banks, generates rom_info.h and a combined PRG binary
- ROM analyzer: Prints PRG structure, counts JSR/RTI/RTI, detects interrupt vectors, and prints disassembly notes
- Bank analyzers: Specialized analysis of bank 0x1F for vectors, reset handler, bank switching, and key functions
- Disassemblers: Basic 6502 disassembler and a comprehensive bank 0x1F disassembler with labeled regions
- Assembly pipeline: Bank stubs, annotation, and main assembly with vectors
- Mapper definitions: Namco-163 register addresses and bank switching macros

**Section sources**
- [split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [analyze_rom.py:10-135](file://tools/analyze_rom.py#L10-L135)
- [analyze_bank_1f.py:4-157](file://tools/analyze_bank_1f.py#L4-L157)
- [analyze_bank_1f_full.py:4-154](file://tools/analyze_bank_1f_full.py#L4-L154)
- [disasm_6502.py:286-363](file://tools/disasm_6502.py#L286-L363)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [annotate_asm.py:315-481](file://tools/annotate_asm.py#L315-L481)
- [namco163.h:10-87](file://include/namco163.h#L10-L87)

## Architecture Overview
The ROM uses Mapper 19 (Namco-163). The PRG is organized into 32 banks of 8 KB each mapped to $8000–$FFFF. At reset, bank 0x1F is fixed at $E000–$FFFF. The reset handler initializes PPU/APU, clears RAM, and dispatches to a state-specific entry via a vector table. Interrupt vectors are located at $FFFA–$FFFF.

```mermaid
graph TB
subgraph "ROM Layout"
PRG["PRG Banks<br/>32 x 8KB"] --> S8["$8000–$9FFF"]
PRG --> SA["$A000–$BFFF"]
PRG --> SC["$C000–$DFFF"]
PRG --> SF["$E000–$FFFF<br/>Bank 0x1F fixed"]
end
subgraph "Boot Flow"
RST["$E000 Reset Handler"] --> INIT["PPU/APU init"]
INIT --> CLEAR["Clear RAM $0000–$07FF"]
CLEAR --> VEC["Read vector table at $E07C"]
VEC --> JUMP["Jump via indirect vector"]
JUMP --> STATE["State entry point"]
end
subgraph "Interrupts"
NMI["$FFFA NMI"] --> NH["NMI Handler"]
RST2["$FFFC RESET"] --> RST
IRQ["$FFE IRQ"] --> IH["IRQ Handler"]
end
```

**Diagram sources**
- [PROJECT.md:84-117](file://PROJECT.md#L84-L117)
- [bank_1f_analysis.md:1-100](file://code/bank_1f_analysis.md#L1-L100)

**Section sources**
- [PROJECT.md:84-117](file://PROJECT.md#L84-L117)
- [bank_1f_analysis.md:1-100](file://code/bank_1f_analysis.md#L1-L100)

## Detailed Component Analysis

### ROM Splitting and Binary Format
- The splitter reads the iNES header, computes PRG/CHR sizes, and writes 8 KB PRG banks and 8 KB CHR banks
- It also generates rom_info.h with Mapper, PRG/CHR counts, and a combined PRG binary for convenience
- The PRG banks are 8 KB each; the ROM is 32 banks × 8 KB = 256 KB PRG

```mermaid
flowchart TD
Start(["Open ROM"]) --> Parse["Parse iNES header"]
Parse --> Sizes["Compute PRG/CHR sizes"]
Sizes --> SplitPRG["Split PRG into 8KB banks"]
Sizes --> SplitCHR["Split CHR into 8KB banks"]
SplitPRG --> OutPRG["Write prg_00.bin .. prg_1f.bin"]
SplitCHR --> OutCHR["Write chr_00.bin .. chr_1f.bin"]
OutPRG --> Info["Write rom_info.h"]
OutCHR --> Info
Info --> End(["Done"])
```

**Diagram sources**
- [split_rom.py:38-122](file://tools/split_rom.py#L38-L122)

**Section sources**
- [split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [rom_info.h:1-9](file://rom/rom_info.h#L1-L9)

### ROM Structure Analysis Methodology
- The analyzer prints PRG structure with 8 KB bank counts and summarizes each bank using:
  - Non-zero and non-$FF byte counts (density indicators)
  - JSR/RTS/RTI counts (code density)
  - Presence of interrupt vectors (NMI/RST/IRQ) by scanning for plausible 16-bit little-endian pointers near $8000–$FFFF
- It also prints notes about bank switching and reset location

```mermaid
flowchart TD
A["Load PRG data"] --> B["Iterate 8KB banks"]
B --> C["Count NZ and non-$FF bytes"]
C --> D["Scan for JSR/RTS/RTI"]
D --> E["Detect vector candidates"]
E --> F["Print bank summary"]
F --> G["Print disassembly notes"]
```

**Diagram sources**
- [analyze_rom.py:49-128](file://tools/analyze_rom.py#L49-L128)

**Section sources**
- [analyze_rom.py:10-135](file://tools/analyze_rom.py#L10-L135)

### Interrupt Vector Detection and Reset Handler Location
- The reset handler is at $E000 in bank 0x1F (mapped to $E000–$FFFF at boot)
- The vector table at $E07C contains 15 entries (2 bytes each) used to dispatch to state handlers
- Interrupt vectors at $FFFA–$FFFF are decoded from the last 6 bytes of the bank
- The analyzer detects vector tables by scanning for three consecutive 16-bit values within $8000–$FFFF that are close in value and prints their locations

```mermaid
sequenceDiagram
participant ROM as "ROM Bank 0x1F"
participant Analyzer as "analyze_rom.py"
participant VectorTable as "$E07C Vector Table"
participant Reset as "$E000 Reset Handler"
Analyzer->>ROM : Scan bank for vector candidates
ROM-->>Analyzer : Found 3-vector cluster near $E07C
Analyzer-->>Analyzer : Confirm NMI/RST/IRQ pointers
Analyzer-->>Analyzer : Print vector table and reset location
Reset-->>VectorTable : Read entry via $007A AND #$1F
VectorTable-->>Reset : Return state entry address
Reset-->>ROM : Jump to state entry
```

**Diagram sources**
- [analyze_rom.py:68-112](file://tools/analyze_rom.py#L68-L112)
- [bank_1f_analysis.md:22-76](file://code/bank_1f_analysis.md#L22-L76)

**Section sources**
- [analyze_rom.py:68-112](file://tools/analyze_rom.py#L68-L112)
- [bank_1f_analysis.md:22-76](file://code/bank_1f_analysis.md#L22-L76)

### Bank 0x1F Analysis: Characteristics and Key Functions
- Bank 0x1F is the boot bank mapped to $E000–$FFFF at reset
- It contains:
  - Reset handler, vector dispatch table, state handlers
  - PPU utilities, sound engine, math routines, controller I/O, and data access functions
- The specialized analyzers identify:
  - Bank switching patterns (STA $F800/$FA00/$FC00/$FE00 with preceding LDA #imm)
  - Internal JSR targets within $8000–$9FFF
  - RNG core and variants
  - Data tables and lookup patterns
  - Main loop return via JMP $E066

```mermaid
flowchart TD
Start(["Analyze Bank 0x1F"]) --> Vectors["$E07C Vector Table"]
Start --> Reset["$E000 Reset Handler"]
Start --> Switch["Bank Switch Ops"]
Start --> Math["Math Routines"]
Start --> Sound["Sound Engine"]
Start --> RNG["RNG Core/Tables"]
Start --> Data["Data Access Functions"]
Vectors --> Handlers["State Handlers"]
Switch --> Slots["$8000/$A000/$C000/$E000"]
Math --> BCD["BCD Converters"]
Math --> Div["Division Routines"]
Sound --> Init["Sound Init"]
Sound --> Play["Note Player"]
RNG --> Seq["Sequential Table Lookup"]
RNG --> Variants["Variants"]
Data --> Hero["Hero/City/Kingdom/Name"]
```

**Diagram sources**
- [analyze_bank_1f.py:16-154](file://tools/analyze_bank_1f.py#L16-L154)
- [analyze_bank_1f_full.py:14-151](file://tools/analyze_bank_1f_full.py#L14-L151)
- [bank_1f_analysis.md:1-100](file://code/bank_1f_analysis.md#L1-L100)

**Section sources**
- [analyze_bank_1f.py:4-157](file://tools/analyze_bank_1f.py#L4-L157)
- [analyze_bank_1f_full.py:4-154](file://tools/analyze_bank_1f_full.py#L4-L154)
- [bank_1f_analysis.md:1-100](file://code/bank_1f_analysis.md#L1-L100)

### Using the Disassemblers and Planning Disassembly
- Basic disassembler: Disassembles arbitrary binaries with configurable start address and length
- Comprehensive bank 0x1F disassembler: Produces a labeled ca65-compatible assembly with named functions and tables
- Assembly pipeline:
  - Generate bank stubs for all 32 PRG banks
  - Annotate assembly with ROM bytes to verify correctness
  - Build and verify against the original ROM

```mermaid
sequenceDiagram
participant Dev as "Developer"
participant Stubs as "generate_bank_stubs.py"
participant Disasm as "disasm_bank_1f.py"
participant Annot as "annotate_asm.py"
participant Build as "Makefile"
participant ROM as "Original ROM"
Dev->>Stubs : Generate bank stubs
Stubs-->>Dev : asm/banks/*.asm with .incbin
Dev->>Disasm : Produce labeled bank 0x1F assembly
Disasm-->>Dev : code/bank_1f_raw.asm
Dev->>Annot : Annotate assembly with ROM bytes
Annot-->>Dev : asm/banks/prg_1f_annotated.asm
Dev->>Build : make verify
Build-->>ROM : Compare built vs original
```

**Diagram sources**
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [annotate_asm.py:315-481](file://tools/annotate_asm.py#L315-L481)
- [Makefile:58-62](file://Makefile#L58-L62)

**Section sources**
- [disasm_6502.py:286-363](file://tools/disasm_6502.py#L286-L363)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [annotate_asm.py:315-481](file://tools/annotate_asm.py#L315-L481)
- [Makefile:58-62](file://Makefile#L58-L62)

### Practical Examples and Interpretation
- Interpreting bank analysis results:
  - High JSR count indicates code-heavy bank
  - Presence of RTI suggests IRQ/data-heavy or interrupt-related code
  - Vector table detection helps locate dispatch handlers
- Example interpretation:
  - Bank 0x1F: high JSR/RTI, vector table at $E07C, reset at $E000
  - Banks 0x14–0x16: high RTI counts, likely graphics or heavy data banks
  - Bank 0x07: all $FF, empty bank
- Guidance:
  - Start with bank 0x1F to understand reset and dispatch
  - Identify bank switching routines to map cross-bank calls
  - Use the vector table to trace state handlers and plan incremental disassembly

**Section sources**
- [analyze_rom.py:117-128](file://tools/analyze_rom.py#L117-L128)
- [PROJECT.md:118-133](file://PROJECT.md#L118-L133)

## Dependency Analysis
The ROM analysis tools depend on each other in a pipeline:
- split_rom.py depends on the ROM file and produces rom_info.h and bank binaries
- analyze_rom.py consumes the ROM to produce structural insights
- disasm_6502.py and disasm_bank_1f.py consume bank binaries to produce listings
- generate_bank_stubs.py creates assembly stubs for linking
- annotate_asm.py validates assembly against ROM bytes
- main.asm defines vectors and entry points for linking

```mermaid
graph LR
Split["split_rom.py"] --> Info["rom_info.h"]
Split --> PRG["rom/prg/*.bin"]
Split --> CHR["rom/chr/*.bin"]
PRG --> Analyze["analyze_rom.py"]
PRG --> Disasm["disasm_6502.py"]
PRG --> Disasm1F["disasm_bank_1f.py"]
PRG --> Stubs["generate_bank_stubs.py"]
Stubs --> Asm["asm/banks/*.asm"]
Asm --> Annot["annotate_asm.py"]
Asm --> Main["asm/main.asm"]
Main --> Make["Makefile"]
PRG --> Verify["verify_rom.py"]
```

**Diagram sources**
- [split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [analyze_rom.py:10-135](file://tools/analyze_rom.py#L10-L135)
- [disasm_6502.py:286-363](file://tools/disasm_6502.py#L286-L363)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [annotate_asm.py:315-481](file://tools/annotate_asm.py#L315-L481)
- [main.asm:134-141](file://asm/main.asm#L134-L141)
- [Makefile:58-62](file://Makefile#L58-L62)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [Makefile:54-75](file://Makefile#L54-L75)

## Performance Considerations
- Bank analysis scans 8 KB per bank; with 32 banks, total scan time scales linearly with PRG size
- Disassemblers operate on binary data; performance is dominated by I/O and instruction decoding
- Annotation compares instruction mnemonics and sizes; mismatches require resync logic and can add overhead
- Recommendations:
  - Use the combined PRG binary for quick checks
  - Focus analysis on suspect banks first (high JSR/RTI)
  - Leverage vector detection to prioritize state handlers

[No sources needed since this section provides general guidance]

## Troubleshooting Guide
- ROM not recognized:
  - Ensure the file begins with the iNES signature and has a valid header
- Bank switching not visible:
  - Check for STA $F800/$FA00/$FC00/$FE00 patterns and preceding LDA #imm
- Vector table not detected:
  - Verify candidate clusters near $8000–$FFFF and confirm proximity of values
- Disassembly mismatch:
  - Use annotate_asm.py to compare instruction bytes and resync at section headers
- Build verification fails:
  - Confirm rom_info.h and bank stubs are consistent with the ROM layout

**Section sources**
- [split_rom.py:11-36](file://tools/split_rom.py#L11-L36)
- [analyze_bank_1f.py:44-68](file://tools/analyze_bank_1f.py#L44-L68)
- [annotate_asm.py:357-404](file://tools/annotate_asm.py#L357-L404)
- [Makefile:58-62](file://Makefile#L58-L62)

## Conclusion
Understanding the ROM structure hinges on:
- Correctly splitting the ROM into 8 KB PRG/CHR banks and generating rom_info.h
- Interpreting bank characteristics using JSR/RTI ratios, vector detection, and density metrics
- Recognizing that bank 0x1F is fixed at $E000–$FFFF and contains the reset handler and vector table
- Using the analysis tools to plan disassembly, annotate assembly, and verify accuracy against the original ROM

[No sources needed since this section summarizes without analyzing specific files]

## Appendices

### Appendix A: ROM and Bank Switching Reference
- Mapper: 19 (Namco-163)
- PRG: 32 banks × 8 KB
- CHR: 32 banks × 8 KB
- Bank switching registers: $F800, $FA00, $FC00, $FE00
- Reset handler: $E000 in bank 0x1F

**Section sources**
- [PROJECT.md:7-13](file://PROJECT.md#L7-L13)
- [PROJECT.md:84-117](file://PROJECT.md#L84-L117)
- [namco163.h:10-14](file://include/namco163.h#L10-L14)

### Appendix B: Execution Flow and Interrupts
- Reset handler initializes PPU/APU, clears RAM, and dispatches via vector table
- Interrupt vectors at $FFFA–$FFFF: NMI, RESET, IRQ
- Bank 0x1F is mapped to $E000–$FFFF at boot

**Section sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [bank_1f_analysis.md:22-76](file://code/bank_1f_analysis.md#L22-L76)