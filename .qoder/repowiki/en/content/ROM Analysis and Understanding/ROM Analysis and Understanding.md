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
- [transform_branches.py](file://transform_branches.py)
- [transform_final.py](file://transform_final.py)
- [transform_wrap.py](file://transform_wrap.py)
- [apply_fixes.py](file://apply_fixes.py)
- [fix_gaps.py](file://fix_gaps.py)
- [fix_labels.py](file://fix_labels.py)
- [check_addresses.py](file://tools/check_addresses.py)
- [check_bank18.py](file://tools/check_bank18.py)
- [dump_chr_table.py](file://tools/dump_chr_table.py)
- [dump_correct_bytes.py](file://tools/dump_correct_bytes.py)
- [search_0530.py](file://tools/search_0530.py)
- [search_chr_loader.py](file://tools/search_chr_loader.py)
- [search_chr_loader2.py](file://tools/search_chr_loader2.py)
- [verify_disasm.py](file://tools/verify_disasm.py)
- [verify_f3bd_f667.py](file://tools/verify_f3bd_f667.py)
- [verify_range.py](file://tools/verify_range.py)
- [rom_info.h](file://rom/rom_info.h)
- [namco163.h](file://include/namco163.h)
- [main.asm](file://asm/main.asm)
- [prg_1f.asm](file://asm/banks/prg_1f.asm)
- [all_banks.asm](file://asm/banks/all_banks.asm)
- [bank_1f_analysis.md](file://code/bank_1f_analysis.md)
- [bank_1f_plan.md](file://code/bank_1f_plan.md)
- [key_functions_analysis.md](file://code/key_functions_analysis.md)
</cite>

## Update Summary
**Changes Made**
- Enhanced ROM analysis capabilities with new tools for address checking, bank validation, CHR table dumping, byte verification, and pattern searching
- Added comprehensive ROM verification tools including disassembly verification, range verification, and targeted pattern searches
- Integrated specialized tools for CHR loader verification and bank-specific byte validation
- Expanded the analysis toolkit with systematic approaches for ROM-accurate verification and debugging

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Enhanced Transformation Pipeline](#enhanced-transformation-pipeline)
7. [Advanced ROM Verification Tools](#advanced-rom-verification-tools)
8. [Dependency Analysis](#dependency-analysis)
9. [Performance Considerations](#performance-considerations)
10. [Troubleshooting Guide](#troubleshooting-guide)
11. [Conclusion](#conclusion)
12. [Appendices](#appendices)

## Introduction
This document explains how to understand the original game ROM structure and how to analyze it systematically for disassembly. It focuses on:
- How the ROM is split into 32 PRG banks (8 KB each) and 32 CHR banks (8 KB each) for the Namco-163 (Mapper 19) system
- How to interpret ROM characteristics using bank analysis metrics such as JSR/RTI ratios, interrupt vector patterns, and code density
- How interrupt vectors are detected and how the reset handler location at $E000 in bank 0x1F is identified
- **Enhanced** Advanced ROM verification tools for systematic byte-level validation and pattern analysis
- **Enhanced** Comprehensive bank validation and address checking capabilities for ROM-accurate disassembly
- Practical examples of analyzing ROM characteristics, interpreting results, and planning disassembly
- The relationship between ROM structure and the game's execution flow

## Project Structure
The repository organizes ROM analysis and disassembly around a comprehensive pipeline with enhanced transformation capabilities and advanced verification tools:
- ROM splitting into PRG/CHR banks
- Bank analysis to identify characteristics and entry points
- Disassembly of individual banks, especially the boot bank (0x1F)
- **Enhanced** Advanced verification pipeline for ROM-accurate validation and debugging
- Assembly and verification against the original ROM with enhanced error checking

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
J --> K["transform_pipeline<br/>Enhanced assembly validation"]
K --> L["transform_branches.py<br/>Branch-to-label conversion"]
K --> M["transform_wrap.py<br/>.proc wrapping & sub-labels"]
K --> N["transform_final.py<br/>Final assembly cleanup"]
K --> O["fix_gaps.py<br/>Gap byte detection & insertion"]
K --> P["fix_labels.py<br/>Label scope correction"]
K --> Q["apply_fixes.py<br/>Manual fixes application"]
J --> R["annotate_asm.py<br/>Annotate with ROM bytes"]
R --> S["asm/main.asm<br/>Vectors and entry points"]
S --> T["Makefile<br/>Build and verify"]
T --> U["verify_disasm.py<br/>Disassembly verification"]
T --> V["verify_range.py<br/>Range-based verification"]
T --> W["verify_f3bd_f667.py<br/>Targeted verification"]
U --> X["check_addresses.py<br/>Address validation"]
V --> Y["check_bank18.py<br/>Bank validation"]
W --> Z["dump_chr_table.py<br/>CHR table verification"]
X --> AA["dump_correct_bytes.py<br/>Byte verification"]
Y --> AB["search_0530.py<br/>Pattern searching"]
Z --> AC["search_chr_loader.py<br/>CHR loader verification"]
AB --> AD["search_chr_loader2.py<br/>Secondary verification"]
AC --> AE["Advanced ROM Verification"]
```

**Diagram sources**
- [split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [rom_info.h:1-9](file://rom/rom_info.h#L1-L9)
- [analyze_rom.py:10-135](file://tools/analyze_rom.py#L10-L135)
- [disasm_6502.py:286-363](file://tools/disasm_6502.py#L286-L363)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [transform_branches.py:19-156](file://transform_branches.py#L19-L156)
- [transform_wrap.py:134-303](file://transform_wrap.py#L134-L303)
- [transform_final.py:1-235](file://transform_final.py#L1-L235)
- [fix_gaps.py:1-346](file://fix_gaps.py#L1-L346)
- [fix_labels.py:1-68](file://fix_labels.py#L1-L68)
- [apply_fixes.py:1-115](file://apply_fixes.py#L1-L115)
- [verify_disasm.py:1-100](file://tools/verify_disasm.py#L1-L100)
- [verify_range.py:1-100](file://tools/verify_range.py#L1-L100)
- [verify_f3bd_f667.py:1-100](file://tools/verify_f3bd_f667.py#L1-L100)
- [check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [search_chr_loader.py:1-100](file://tools/search_chr_loader.py#L1-L100)
- [search_chr_loader2.py:1-100](file://tools/search_chr_loader2.py#L1-L100)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [Makefile:54-75](file://Makefile#L54-L75)

## Core Components
- ROM splitter: Parses iNES header, splits PRG/CHR into 8 KB banks, generates rom_info.h and a combined PRG binary
- ROM analyzer: Prints PRG structure, counts JSR/RTI/RTI, detects interrupt vectors, and prints disassembly notes
- **Enhanced** Bank analyzers: Specialized analysis of bank 0x1F for vectors, reset handler, bank switching, and key functions with comprehensive function boundary detection
- Disassemblers: Basic 6502 disassembler and a comprehensive bank 0x1F disassembler with labeled regions
- **Enhanced** Advanced verification tools: Systematic ROM verification including disassembly validation, range checking, pattern searching, and byte-level accuracy
- **Enhanced** Bank validation tools: Address checking, bank-specific verification, and CHR table dumping for ROM-accurate analysis
- **Enhanced** Pattern search tools: Targeted searches for specific opcodes and memory patterns across the ROM
- Assembly pipeline: Bank stubs, enhanced annotation, and main assembly with vectors
- Mapper definitions: Namco-163 register addresses and bank switching macros

**Section sources**
- [split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [analyze_rom.py:10-135](file://tools/analyze_rom.py#L10-L135)
- [analyze_bank_1f.py:4-157](file://tools/analyze_bank_1f.py#L4-L157)
- [analyze_bank_1f_full.py:4-154](file://tools/analyze_bank_1f_full.py#L4-L154)
- [disasm_6502.py:286-363](file://tools/disasm_6502.py#L286-L363)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [verify_disasm.py:1-100](file://tools/verify_disasm.py#L1-L100)
- [verify_range.py:1-100](file://tools/verify_range.py#L1-L100)
- [verify_f3bd_f667.py:1-100](file://tools/verify_f3bd_f667.py#L1-L100)
- [check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [search_chr_loader.py:1-100](file://tools/search_chr_loader.py#L1-L100)
- [search_chr_loader2.py:1-100](file://tools/search_chr_loader2.py#L1-L100)

## Architecture Overview
The ROM uses Mapper 19 (Namco-163). The PRG is organized into 32 banks of 8 KB each mapped to $8000–$FFFF. At reset, bank 0x1F is fixed at $E000–$FFFF. The reset handler initializes PPU/APU, clears RAM, and dispatches to a state-specific entry via a vector table. Interrupt vectors are located at $FFFA–$FFFF.

**Enhanced** The enhanced analysis pipeline now includes automated validation, comprehensive verification tools, and systematic ROM-accurate analysis capabilities.

```mermaid
graph TB
subgraph "ROM Layout"
PRG["PRG Banks<br/>32 x 8KB"] --> S8["$8000–$9FFF"]
PRG --> SA["$A000–$BFFF"]
PRG --> SC["$C000–$DFFF"]
PRG --> SF["$E000–$FFFF<br/>Bank 0x1F fixed"]
end
subgraph "Enhanced Boot Flow"
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
subgraph "Enhanced Verification Pipeline"
VERIFICATION["Advanced ROM Verification"] --> DISASM["Disassembly Validation"]
VERIFICATION --> RANGE["Range Verification"]
VERIFICATION --> PATTERN["Pattern Searching"]
VERIFICATION --> BYTE["Byte-Level Accuracy"]
DISASM --> ADDR["Address Checking"]
RANGE --> BANK["Bank Validation"]
PATTERN --> CHR["CHR Verification"]
BYTE --> SEARCH["Targeted Searches"]
end
```

**Diagram sources**
- [PROJECT.md:84-117](file://PROJECT.md#L84-L117)
- [bank_1f_analysis.md:1-100](file://code/bank_1f_analysis.md#L1-L100)
- [verify_disasm.py:1-100](file://tools/verify_disasm.py#L1-L100)
- [verify_range.py:1-100](file://tools/verify_range.py#L1-L100)
- [verify_f3bd_f667.py:1-100](file://tools/verify_f3bd_f667.py#L1-L100)
- [check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [search_0530.py:1-23](file://tools/search_0530.py#L1-L23)

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

**Enhanced** The enhanced bank $1f analysis now includes comprehensive function boundary detection and internal JSR target analysis.

```mermaid
flowchart TD
A["Load PRG data"] --> B["Iterate 8KB banks"]
B --> C["Count NZ and non-$FF bytes"]
C --> D["Scan for JSR/RTS/RTI"]
D --> E["Detect vector candidates"]
E --> F["Enhanced bank 0x1F analysis"]
F --> G["Function boundary detection"]
G --> H["Internal JSR target analysis"]
H --> I["Print bank summary"]
I --> J["Print disassembly notes"]
```

**Diagram sources**
- [analyze_rom.py:49-128](file://tools/analyze_rom.py#L49-L128)
- [analyze_bank_1f_full.py:14-151](file://tools/analyze_bank_1f_full.py#L14-L151)

**Section sources**
- [analyze_rom.py:10-135](file://tools/analyze_rom.py#L10-L135)
- [analyze_bank_1f_full.py:4-154](file://tools/analyze_bank_1f_full.py#L4-L154)

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
- **Enhanced** The specialized analyzers now provide comprehensive function boundary detection and internal JSR target analysis:
  - Function boundaries identified using RTS/RTI as end markers
  - Internal JSR targets within $8000–$9FFF counted and prioritized
  - Bank switching patterns (STA $F800/$FA00/$FC00/$FE00 with preceding LDA #imm)
  - RNG core and variants detection
  - Data tables and lookup patterns identification
  - Main loop return via JMP $E066

```mermaid
flowchart TD
Start(["Enhanced Bank 0x1F Analysis"]) --> Vectors["$E07C Vector Table"]
Start --> Reset["$E000 Reset Handler"]
Start --> Switch["Bank Switch Ops"]
Start --> Functions["Function Boundary Detection"]
Start --> InternalJSR["Internal JSR Targets"]
Start --> RNG["RNG Core/Tables"]
Start --> Data["Data Access Functions"]
Vectors --> Handlers["State Handlers"]
Switch --> Slots["$8000/$A000/$C000/$E000"]
Functions --> Boundaries["RTS/RTI Detection"]
Functions --> Counts["JSR Counting"]
InternalJSR --> Priority["Call Frequency Analysis"]
RNG --> Patterns["LFSR Detection"]
Data --> Tables["Lookup Pattern Analysis"]
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
- **Enhanced** Transformation pipeline:
  - Transform branches to labels for better readability
  - Wrap functions in .proc/.endproc blocks with proper scope management
  - Insert gap bytes with correct ROM data alignment
  - Apply manual fixes for cross-proc label issues
  - Validate assembly against original ROM byte-by-byte

```mermaid
sequenceDiagram
participant Dev as "Developer"
participant Stubs as "generate_bank_stubs.py"
participant Disasm as "disasm_bank_1f.py"
participant Transform as "Transform Pipeline"
participant Annot as "annotate_asm.py"
participant Build as "Makefile"
participant ROM as "Original ROM"
Dev->>Stubs : Generate bank stubs
Stubs-->>Dev : asm/banks/*.asm with .incbin
Dev->>Disasm : Produce labeled bank 0x1F assembly
Disasm-->>Dev : prg_1f.asm
Dev->>Transform : Apply transformation pipeline
Transform-->>Dev : Enhanced assembly with validation
Dev->>Annot : Annotate assembly with ROM bytes
Annot-->>Dev : asm/banks/prg_1f_annotated.asm
Dev->>Build : make verify
Build-->>ROM : Compare built vs original
```

**Diagram sources**
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [transform_branches.py:19-156](file://transform_branches.py#L19-L156)
- [transform_wrap.py:134-303](file://transform_wrap.py#L134-L303)
- [transform_final.py:1-235](file://transform_final.py#L1-L235)
- [fix_gaps.py:1-346](file://fix_gaps.py#L1-L346)
- [fix_labels.py:1-68](file://fix_labels.py#L1-L68)
- [apply_fixes.py:1-115](file://apply_fixes.py#L1-L115)
- [annotate_asm.py:315-481](file://tools/annotate_asm.py#L315-L481)

**Section sources**
- [disasm_6502.py:286-363](file://tools/disasm_6502.py#L286-L363)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [transform_branches.py:19-156](file://transform_branches.py#L19-L156)
- [transform_wrap.py:134-303](file://transform_wrap.py#L134-L303)
- [transform_final.py:1-235](file://transform_final.py#L1-L235)
- [fix_gaps.py:1-346](file://fix_gaps.py#L1-L346)
- [fix_labels.py:1-68](file://fix_labels.py#L1-L68)
- [apply_fixes.py:1-115](file://apply_fixes.py#L1-L115)
- [annotate_asm.py:315-481](file://tools/annotate_asm.py#L315-L481)
- [Makefile:58-62](file://Makefile#L58-L62)

### Practical Examples and Interpretation
- Interpreting bank analysis results:
  - High JSR count indicates code-heavy bank
  - Presence of RTI suggests IRQ/data-heavy or interrupt-related code
  - Vector table detection helps locate dispatch handlers
- **Enhanced** Example interpretation with new capabilities:
  - Bank 0x1F: high JSR/RTI, vector table at $E07C, reset at $E000
  - Banks 0x14–0x16: high RTI counts, likely graphics or heavy data banks
  - Bank 0x07: all $FF, empty bank
  - **New** Function boundary detection reveals 45+ functions in bank 0x1F with internal call patterns
  - **New** Gap detection identifies 15+ data gaps requiring ROM-accurate byte insertion
- Guidance:
  - Start with bank 0x1F to understand reset and dispatch
  - Identify bank switching routines to map cross-bank calls
  - Use the vector table to trace state handlers and plan incremental disassembly
  - **New** Leverage transformation pipeline for automated assembly validation and gap detection
  - **New** Utilize advanced verification tools for systematic ROM-accurate validation

**Section sources**
- [analyze_rom.py:117-128](file://tools/analyze_rom.py#L117-L128)
- [analyze_bank_1f_full.py:35-44](file://tools/analyze_bank_1f_full.py#L35-L44)
- [PROJECT.md:118-133](file://PROJECT.md#L118-L133)

## Enhanced Transformation Pipeline

### Automated Assembly Validation
The transformation pipeline automatically validates assembly code against the original ROM by:
- Converting branch hex targets to descriptive labels with context-aware naming
- Detecting and inserting gap bytes with correct ROM data alignment
- Wrapping functions in .proc/.endproc blocks with proper scope management
- Applying manual fixes for cross-proc label issues and address alignment

```mermaid
flowchart TD
A["Raw Assembly"] --> B["transform_branches.py<br/>Branch-to-label conversion"]
B --> C["transform_wrap.py<br/>.proc wrapping & sub-labels"]
C --> D["transform_final.py<br/>Final assembly cleanup"]
D --> E["fix_gaps.py<br/>Gap byte detection & insertion"]
E --> F["fix_labels.py<br/>Label scope correction"]
F --> G["apply_fixes.py<br/>Manual fixes application"]
G --> H["Validated Assembly"]
```

**Diagram sources**
- [transform_branches.py:19-156](file://transform_branches.py#L19-L156)
- [transform_wrap.py:134-303](file://transform_wrap.py#L134-L303)
- [transform_final.py:1-235](file://transform_final.py#L1-L235)
- [fix_gaps.py:1-346](file://fix_gaps.py#L1-L346)
- [fix_labels.py:1-68](file://fix_labels.py#L1-L68)
- [apply_fixes.py:1-115](file://apply_fixes.py#L1-L115)

### Branch-to-Label Conversion
The branch transformation tool converts hex branch targets to descriptive labels:
- Identifies all branch instructions with hex targets
- Builds address-to-line mapping from instruction comments
- Generates context-aware labels based on function and target address
- Inserts labels at target addresses and replaces hex references

**Section sources**
- [transform_branches.py:19-156](file://transform_branches.py#L19-L156)

### Gap Detection and Insertion
The gap detection tool ensures ROM-accurate byte alignment:
- Removes previous incorrect gap byte insertions
- Fixes data overlap issues (like DomesticGraphicPtrs)
- Detects gaps between instructions and inserts correct ROM bytes
- Handles special cases like memory copy routines and padding sections

**Section sources**
- [fix_gaps.py:1-346](file://fix_gaps.py#L1-L346)

### Function Wrapping and Scope Management
The function wrapping tool manages .proc scope and sub-labels:
- Defines function boundaries with proper .proc/.endproc blocks
- Converts function-specific sub-labels to @sublabel format
- Manages cross-proc label scope issues
- Applies export directives for global functions

**Section sources**
- [transform_wrap.py:134-303](file://transform_wrap.py#L134-L303)

### Final Assembly Cleanup
The final transformation consolidates all changes:
- Applies predefined JMP/branch label mappings
- Inserts gap bytes with proper labeling
- Balances .proc/.endproc directives
- Reports remaining hex targets and structural issues

**Section sources**
- [transform_final.py:1-235](file://transform_final.py#L1-L235)

## Advanced ROM Verification Tools

### Disassembly Verification
The verification pipeline provides systematic ROM-accurate validation:
- **verify_disasm.py**: Compares generated assembly against original ROM bytes to ensure perfect disassembly accuracy
- **verify_range.py**: Validates specific memory ranges for expected byte patterns and addresses
- **verify_f3bd_f667.py**: Performs targeted verification of critical memory regions and patterns

```mermaid
flowchart TD
A["Generated Assembly"] --> B["verify_disasm.py<br/>Complete ROM verification"]
B --> C["verify_range.py<br/>Range-based validation"]
C --> D["verify_f3bd_f667.py<br/>Targeted verification"]
D --> E["Validation Results"]
B --> F["check_addresses.py<br/>Address accuracy checking"]
C --> G["check_bank18.py<br/>Bank-specific validation"]
D --> H["dump_chr_table.py<br/>CHR table verification"]
F --> I["dump_correct_bytes.py<br/>Byte-level accuracy"]
G --> J["search_0530.py<br/>Pattern searching"]
H --> K["search_chr_loader.py<br/>CHR loader verification"]
I --> L["search_chr_loader2.py<br/>Secondary verification"]
J --> M["Comprehensive ROM Validation"]
K --> M
L --> M
```

**Diagram sources**
- [verify_disasm.py:1-100](file://tools/verify_disasm.py#L1-L100)
- [verify_range.py:1-100](file://tools/verify_range.py#L1-L100)
- [verify_f3bd_f667.py:1-100](file://tools/verify_f3bd_f667.py#L1-L100)
- [check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [search_chr_loader.py:1-100](file://tools/search_chr_loader.py#L1-L100)
- [search_chr_loader2.py:1-100](file://tools/search_chr_loader2.py#L1-L100)

### Address Checking and Bank Validation
Specialized tools for precise ROM verification:
- **check_addresses.py**: Verifies specific memory addresses and byte sequences to confirm disassembly accuracy
- **check_bank18.py**: Validates bank-specific byte patterns and confirms proper bank mapping and addressing
- **dump_chr_table.py**: Extracts and displays CHR table data for verification against expected patterns
- **dump_correct_bytes.py**: Provides detailed byte-by-byte verification of specific memory regions

**Section sources**
- [check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)

### Pattern Search and CHR Loader Verification
Targeted analysis tools for specific ROM patterns:
- **search_0530.py**: Searches for specific opcode patterns (like STA $0530) across the entire ROM
- **search_chr_loader.py**: Locates and verifies CHR loading routines and patterns
- **search_chr_loader2.py**: Provides secondary verification and cross-referencing of CHR loader implementations

**Section sources**
- [search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [search_chr_loader.py:1-100](file://tools/search_chr_loader.py#L1-L100)
- [search_chr_loader2.py:1-100](file://tools/search_chr_loader2.py#L1-L100)

## Dependency Analysis
The ROM analysis tools depend on each other in an enhanced pipeline with comprehensive verification capabilities:
- split_rom.py depends on the ROM file and produces rom_info.h and bank binaries
- analyze_rom.py consumes the ROM to produce structural insights
- disasm_6502.py and disasm_bank_1f.py consume bank binaries to produce listings
- generate_bank_stubs.py creates assembly stubs for linking
- **Enhanced** transform_* tools provide automated assembly validation and gap detection
- **Enhanced** verify_* tools provide systematic ROM-accurate validation and debugging
- **Enhanced** check_* and search_* tools provide specialized verification and pattern analysis
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
Asm --> Transform["transform_pipeline<br/>Enhanced validation"]
Transform --> Branches["transform_branches.py"]
Transform --> Wrap["transform_wrap.py"]
Transform --> Final["transform_final.py"]
Transform --> Gaps["fix_gaps.py"]
Transform --> Labels["fix_labels.py"]
Transform --> Fixes["apply_fixes.py"]
Asm --> Annot["annotate_asm.py"]
Asm --> Main["asm/main.asm"]
Main --> Make["Makefile"]
PRG --> Verify["verify_pipeline<br/>Advanced verification"]
Verify --> DisasmVer["verify_disasm.py"]
Verify --> RangeVer["verify_range.py"]
Verify --> F3BDVer["verify_f3bd_f667.py"]
Verify --> AddrCheck["check_addresses.py"]
Verify --> Bank18["check_bank18.py"]
Verify --> ChrDump["dump_chr_table.py"]
Verify --> ByteDump["dump_correct_bytes.py"]
Verify --> PatSearch["search_0530.py"]
Verify --> ChrLoader["search_chr_loader.py"]
Verify --> ChrLoader2["search_chr_loader2.py"]
Make --> Build["Build and verify"]
Build --> ROM["Original ROM"]
```

**Diagram sources**
- [split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [analyze_rom.py:10-135](file://tools/analyze_rom.py#L10-L135)
- [disasm_6502.py:286-363](file://tools/disasm_6502.py#L286-L363)
- [disasm_bank_1f.py:545-561](file://tools/disasm_bank_1f.py#L545-L561)
- [generate_bank_stubs.py:12-53](file://tools/generate_bank_stubs.py#L12-L53)
- [transform_branches.py:19-156](file://transform_branches.py#L19-L156)
- [transform_wrap.py:134-303](file://transform_wrap.py#L134-L303)
- [transform_final.py:1-235](file://transform_final.py#L1-L235)
- [fix_gaps.py:1-346](file://fix_gaps.py#L1-L346)
- [fix_labels.py:1-68](file://fix_labels.py#L1-L68)
- [apply_fixes.py:1-115](file://apply_fixes.py#L1-L115)
- [verify_disasm.py:1-100](file://tools/verify_disasm.py#L1-L100)
- [verify_range.py:1-100](file://tools/verify_range.py#L1-L100)
- [verify_f3bd_f667.py:1-100](file://tools/verify_f3bd_f667.py#L1-L100)
- [check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [search_chr_loader.py:1-100](file://tools/search_chr_loader.py#L1-L100)
- [search_chr_loader2.py:1-100](file://tools/search_chr_loader2.py#L1-L100)
- [annotate_asm.py:315-481](file://tools/annotate_asm.py#L315-L481)
- [main.asm:134-141](file://asm/main.asm#L134-L141)
- [Makefile:58-62](file://Makefile#L58-L62)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [Makefile:54-75](file://Makefile#L54-L75)

## Performance Considerations
- Bank analysis scans 8 KB per bank; with 32 banks, total scan time scales linearly with PRG size
- **Enhanced** Transformation pipeline adds computational overhead but improves accuracy:
  - Branch-to-label conversion requires regex processing and label generation
  - Gap detection involves ROM byte comparison and intelligent insertion logic
  - Function wrapping requires parsing and restructuring of assembly blocks
- **Enhanced** Advanced verification tools add significant computational overhead for comprehensive ROM validation:
  - Disassembly verification requires byte-by-byte comparison across entire ROM
  - Pattern searching scans through millions of bytes for specific opcode sequences
  - Range verification performs targeted analysis of specific memory regions
  - Address checking and bank validation require precise memory mapping and validation
- Disassemblers operate on binary data; performance is dominated by I/O and instruction decoding
- Annotation compares instruction mnemonics and sizes; mismatches require resync logic and can add overhead
- Recommendations:
  - Use the combined PRG binary for quick checks
  - Focus analysis on suspect banks first (high JSR/RTI)
  - Leverage vector detection to prioritize state handlers
  - **New** Utilize enhanced transformation pipeline for automated validation and gap detection
  - **New** Employ systematic verification approach for ROM-accurate results

## Troubleshooting Guide
- ROM not recognized:
  - Ensure the file begins with the iNES signature and has a valid header
- Bank switching not visible:
  - Check for STA $F800/$FA00/$FC00/$FE00 patterns and preceding LDA #imm
- Vector table not detected:
  - Verify candidate clusters near $8000–$FFFF and confirm proximity of values
- Disassembly mismatch:
  - Use annotate_asm.py to compare instruction bytes and resync at section headers
- **New** Advanced verification pipeline issues:
  - Disassembly verification failures: check for ROM corruption or incorrect bank mapping
  - Range verification errors: verify memory addresses and expected byte patterns
  - Pattern search false positives: validate opcode sequences and context
  - Address checking failures: confirm proper memory mapping and bank addressing
  - Bank validation errors: check bank switching logic and register writes
  - CHR table verification failures: verify CHR loading routines and data formats
  - Byte-level accuracy issues: confirm ROM integrity and disassembly correctness
  - Pattern searching timeouts: optimize search algorithms and target specific regions
- Build verification fails:
  - Confirm rom_info.h and bank stubs are consistent with the ROM layout
  - **New** Check transformation pipeline output for validation errors
  - **New** Verify advanced verification tools produce expected results

**Section sources**
- [split_rom.py:11-36](file://tools/split_rom.py#L11-L36)
- [analyze_bank_1f.py:44-68](file://tools/analyze_bank_1f.py#L44-L68)
- [transform_branches.py:139-151](file://transform_branches.py#L139-L151)
- [fix_gaps.py:337-345](file://fix_gaps.py#L337-L345)
- [fix_labels.py:13-60](file://fix_labels.py#L13-L60)
- [apply_fixes.py:108-115](file://apply_fixes.py#L108-L115)
- [annotate_asm.py:357-404](file://tools/annotate_asm.py#L357-L404)
- [Makefile:58-62](file://Makefile#L58-L62)
- [verify_disasm.py:1-100](file://tools/verify_disasm.py#L1-L100)
- [verify_range.py:1-100](file://tools/verify_range.py#L1-L100)
- [verify_f3bd_f667.py:1-100](file://tools/verify_f3bd_f667.py#L1-L100)
- [check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [search_chr_loader.py:1-100](file://tools/search_chr_loader.py#L1-L100)
- [search_chr_loader2.py:1-100](file://tools/search_chr_loader2.py#L1-L100)

## Conclusion
Understanding the ROM structure hinges on:
- Correctly splitting the ROM into 8 KB PRG/CHR banks and generating rom_info.h
- Interpreting bank characteristics using JSR/RTI ratios, vector detection, and density metrics
- Recognizing that bank 0x1F is fixed at $E000–$FFFF and contains the reset handler and vector table
- **Enhanced** Leveraging the transformation pipeline for automated assembly validation, gap detection, and address alignment verification
- **Enhanced** Utilizing advanced verification tools for systematic ROM-accurate validation and debugging
- **Enhanced** Employing specialized tools for pattern searching, bank validation, and CHR table verification
- Using the enhanced analysis tools to plan disassembly, annotate assembly, and verify accuracy against the original ROM
- **New** Integrating comprehensive verification processes to ensure ROM-accurate assembly output with systematic validation

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
- **Enhanced** Transformation pipeline ensures accurate interrupt vector handling and validation
- **Enhanced** Advanced verification tools provide systematic ROM-accurate validation of interrupt handling

**Section sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [bank_1f_analysis.md:22-76](file://code/bank_1f_analysis.md#L22-L76)

### Appendix C: Enhanced Transformation Tools
- **transform_branches.py**: Converts branch hex targets to descriptive labels with context-aware naming
- **transform_wrap.py**: Wraps functions in .proc/.endproc blocks with proper scope management
- **transform_final.py**: Consolidates transformations and applies final assembly cleanup
- **fix_gaps.py**: Detects and inserts gap bytes with correct ROM data alignment
- **fix_labels.py**: Resolves cross-proc label scope issues and manages label placement
- **apply_fixes.py**: Applies manual fixes for assembly accuracy and ROM compliance

**Section sources**
- [transform_branches.py:19-156](file://transform_branches.py#L19-L156)
- [transform_wrap.py:134-303](file://transform_wrap.py#L134-L303)
- [transform_final.py:1-235](file://transform_final.py#L1-L235)
- [fix_gaps.py:1-346](file://fix_gaps.py#L1-L346)
- [fix_labels.py:1-68](file://fix_labels.py#L1-L68)
- [apply_fixes.py:1-115](file://apply_fixes.py#L1-L115)

### Appendix D: Advanced ROM Verification Tools
- **verify_disasm.py**: Systematic disassembly verification against original ROM bytes
- **verify_range.py**: Range-based verification for specific memory regions
- **verify_f3bd_f667.py**: Targeted verification of critical memory patterns
- **check_addresses.py**: Precise address validation and byte sequence verification
- **check_bank18.py**: Bank-specific validation and addressing accuracy
- **dump_chr_table.py**: CHR table data extraction and verification
- **dump_correct_bytes.py**: Detailed byte-by-byte verification of memory regions
- **search_0530.py**: Pattern searching for specific opcode sequences
- **search_chr_loader.py**: CHR loader routine verification and analysis
- **search_chr_loader2.py**: Secondary CHR loader verification and cross-referencing

**Section sources**
- [verify_disasm.py:1-100](file://tools/verify_disasm.py#L1-L100)
- [verify_range.py:1-100](file://tools/verify_range.py#L1-L100)
- [verify_f3bd_f667.py:1-100](file://tools/verify_f3bd_f667.py#L1-L100)
- [check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [search_chr_loader.py:1-100](file://tools/search_chr_loader.py#L1-L100)
- [search_chr_loader2.py:1-100](file://tools/search_chr_loader2.py#L1-L100)