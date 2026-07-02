# Build System and Tools

<cite>
**Referenced Files in This Document**
- [Makefile](file://Makefile)
- [PROJECT.md](file://PROJECT.md)
- [linker.cfg](file://linker.cfg)
- [test_linker.cfg](file://test_linker.cfg)
- [test_17_18.cfg](file://test_17_18.cfg)
- [build/test_17_18.cfg](file://build/test_17_18.cfg)
- [check_baseline.py](file://check_baseline.py)
- [convert_hex.py](file://convert_hex.py)
- [transform_branches.py](file://transform_branches.py)
- [transform_wrap.py](file://transform_wrap.py)
- [transform_final.py](file://transform_final.py)
- [fix_forward.py](file://fix_forward.py)
- [fix_gaps.py](file://fix_gaps.py)
- [fix_labels.py](file://fix_labels.py)
- [fix_scope.py](file://fix_scope.py)
- [fix_syntax.py](file://fix_syntax.py)
- [apply_fixes.py](file://apply_fixes.py)
- [tools/build_nes.py](file://tools/build_nes.py)
- [tools/verify_rom.py](file://tools/verify_rom.py)
- [tools/split_rom.py](file://tools/split_rom.py)
- [tools/disasm_6502.py](file://tools/disasm_6502.py)
- [tools/disasm_bank_1f.py](file://tools/disasm_bank_1f.py)
- [tools/disasm_17_18.py](file://tools/disasm_17_18.py)
- [tools/fix_disasm.py](file://tools/fix_disasm.py)
- [tools/gen_f667_ffff.py](file://tools/gen_f667_ffff.py)
- [tools/update_jsr_labels.py](file://tools/update_jsr_labels.py)
- [tools/verify_f3bd_f667.py](file://tools/verify_f3bd_f667.py)
- [tools/verify_range.py](file://tools/verify_range.py)
- [tools/generate_bank_stubs.py](file://tools/generate_bank_stubs.py)
- [tools/analyze_rom.py](file://tools/analyze_rom.py)
- [tools/annotate_asm.py](file://tools/annotate_asm.py)
- [tools/transform_17_18.py](file://tools/transform_17_18.py)
- [tools/add_procs.py](file://tools/add_procs.py)
- [tools/analyze_17_18.py](file://tools/analyze_17_18.py)
- [tools/debug_regions.py](file://tools/debug_regions.py)
- [tools/proc_scope_17_18.py](file://tools/proc_scope_17_18.py)
- [tools/localize_labels.py](file://tools/localize_labels.py)
- [tools/check_addresses.py](file://tools/check_addresses.py)
- [tools/check_bank18.py](file://tools/check_bank18.py)
- [tools/check_rom_offset.py](file://tools/check_rom_offset.py)
- [tools/dump_chr_table.py](file://tools/dump_chr_table.py)
- [tools/dump_correct_bytes.py](file://tools/dump_correct_bytes.py)
- [tools/search_0530.py](file://tools/search_0530.py)
- [tools/search_chr_loader.py](file://tools/search_chr_loader.py)
- [tools/search_chr_loader2.py](file://tools/search_chr_loader2.py)
- [tools/verify_disasm.py](file://tools/verify_disasm.py)
- [tools/auto_add_local_params.py](file://tools/auto_add_local_params.py)
- [tools/globalize_04xx.py](file://tools/globalize_04xx.py)
- [asm/main.asm](file://asm/main.asm)
- [include/namco163.h](file://include/namco163.h)
- [include/macros.h](file://include/macros.h)
- [include/functions.h](file://include/functions.h)
- [asm/banks/all_banks.asm](file://asm/banks/all_banks.asm)
- [asm/banks/prg_17_18.asm](file://asm/banks/prg_17_18.asm)
</cite>

## Update Summary
**Changes Made**
- Added comprehensive documentation for the new transformation pipeline tools (transform_17_18.py, add_procs.py, analyze_17_18.py, debug_regions.py) providing sophisticated semantic naming conventions, enhanced code organization, and automated tooling for PRG bank $17/$18 assembly code maintainability
- Enhanced disassembly tools with unified pipeline for specialized ROM region processing
- Updated transformation pipeline section to include detailed analysis of the sophisticated semantic naming system and advanced boundary detection capabilities
- Added documentation for the new RAM centralization tool (globalize_04xx.py) for systematic $04xx memory region standardization
- Enhanced automated code organization capabilities with systematic parameter naming and cross-bank reference handling

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Unified Disassembly Pipeline](#unified-disassembly-pipeline)
7. [Enhanced Disassembly Tools](#enhanced-disassembly-tools)
8. [Transformation Pipeline](#transformation-pipeline)
9. [RAM Centralization and Standardization](#ram-centralization-and-standardization)
10. [ROM Analysis and Verification Tools](#rom-analysis-and-verification-tools)
11. [Dependency Analysis](#dependency-analysis)
12. [Performance Considerations](#performance-considerations)
13. [Troubleshooting Guide](#troubleshooting-guide)
14. [Conclusion](#conclusion)
15. [Appendices](#appendices)

## Introduction
This document explains the complete build system and automated workflows for the Sango2Dasm project. It covers the Makefile targets, the ROM generation pipeline from assembly through linking to the final NES ROM with proper iNES headers, the verification system that ensures byte-exact rebuilds, and the enhanced annotation tools used to document and validate disassembly. The project now features a comprehensive unified disassembly approach that provides automated cleanup, cross-bank reference handling, address-to-symbol mapping, and specialized tools for different ROM regions. Additionally, the transformation pipeline now includes sophisticated tools for PRG bank $17/$18 assembly code with semantic naming conventions, enhanced code organization, comprehensive .proc/.endproc boundary analysis, and the new centralized RAM definition system. The recent addition of the automated RAM centralization tool provides systematic approach to maintaining consistent memory address definitions across the codebase, significantly improving code readability and maintainability.

## Project Structure
The project is organized around a Makefile-driven build system, a cc65-based assembler/linker toolchain, and a suite of Python tools for ROM splitting, disassembly, analysis, annotation, verification, and assembly transformation. The structure supports:
- Assembly sources under asm/, with bank stubs under asm/banks/
- Include headers under include/ defining hardware registers and mapper macros
- ROM assets under rom/ (split PRG/CHR banks and combined PRG)
- Build outputs under build/
- Automated tools under tools/
- **New**: Comprehensive transformation pipeline with sophisticated semantic naming, enhanced code organization, and automated tooling for PRG bank $17/$18 assembly code maintainability

```mermaid
graph TB
subgraph "Source"
A_main["asm/main.asm"]
A_banks["asm/banks/*.asm"]
H_regs["include/6502_registers.h"]
H_namco["include/namco163.h"]
H_macros["include/macros.h"]
H_functions["include/functions.h"]
end
subgraph "Build"
MK["Makefile"]
CFG["linker.cfg"]
TEST_CFG["test_linker.cfg"]
TEST_17_18["test_17_18.cfg"]
TEST_17_18_BUILD["build/test_17_18.cfg"]
OUT["build/"]
end
subgraph "Unified Disassembly Pipeline"
UD1["disasm_17_18.py<br/>710 lines"]
UD2["fix_disasm.py"]
UD3["gen_f667_ffff.py"]
UD4["update_jsr_labels.py"]
UD5["verify_f3bd_f667.py"]
UD6["verify_range.py"]
end
subgraph "Enhanced Transformation Pipeline"
TP1["transform_17_18.py<br/>348 lines - Semantic Naming"]
TP2["add_procs.py<br/>189 lines - Basic Scoping"]
TP3["analyze_17_18.py<br/>118 lines - Boundary Analysis"]
TP4["debug_regions.py<br/>98 lines - Transition Debugging"]
TP5["proc_scope_17_18.py<br/>Enhanced .proc/.endproc"]
TP6["localize_labels.py<br/>New tool for @local labels"]
TP7["auto_add_local_params.py<br/>415 lines - Automated parameter naming"]
TP8["globalize_04xx.py<br/>205 lines - RAM centralization"]
end
subgraph "ROM Analysis and Verification"
RA1["check_addresses.py<br/>Address verification"]
RA2["check_bank18.py<br/>Bank verification"]
RA3["check_rom_offset.py<br/>Offset mapping"]
RA4["dump_chr_table.py<br/>CHR table inspection"]
RA5["dump_correct_bytes.py<br/>Correct bytes verification"]
RA6["search_0530.py<br/>$0530 pattern search"]
RA7["search_chr_loader.py<br/>CHR loader pattern"]
RA8["search_chr_loader2.py<br/>Specific CHR loader"]
RA9["verify_disasm.py<br/>Disassembly verification"]
end
subgraph "Tools"
T_build["tools/build_nes.py"]
T_verify["tools/verify_rom.py"]
T_split["tools/split_rom.py"]
T_disasm["tools/disasm_6502.py"]
T_disasm1f["tools/disasm_bank_1f.py"]
T_gen["tools/generate_bank_stubs.py"]
T_analyze["tools/analyze_rom.py"]
T_annotate["tools/annotate_asm.py"]
end
subgraph "ROM Assets"
R_rom["rom/*.bin"]
R_info["rom/rom_info.h"]
R_combined["rom/prg_combined.bin"]
end
A_main --> MK
A_banks --> MK
H_regs --> A_main
H_namco --> A_main
H_macros --> A_main
H_functions --> T_update_jsr
MK --> CFG
MK --> TEST_CFG
MK --> TEST_17_18
MK --> TEST_17_18_BUILD
MK --> OUT
MK --> UD1
MK --> UD2
MK --> UD3
MK --> UD4
MK --> UD5
MK --> UD6
MK --> TP1
MK --> TP2
MK --> TP3
MK --> TP4
MK --> TP5
MK --> TP6
MK --> TP7
MK --> TP8
MK --> RA1
MK --> RA2
MK --> RA3
MK --> RA4
MK --> RA5
MK --> RA6
MK --> RA7
MK --> RA8
MK --> RA9
MK --> T_build
MK --> T_verify
MK --> T_split
MK --> T_disasm
MK --> T_disasm1f
MK --> T_gen
MK --> T_analyze
MK --> T_annotate
T_split --> R_rom
T_split --> R_info
T_split --> R_combined
T_build --> OUT
T_verify --> OUT
```

**Diagram sources**
- [Makefile:1-102](file://Makefile#L1-L102)
- [linker.cfg:1-58](file://linker.cfg#L1-L58)
- [test_linker.cfg:1-13](file://test_linker.cfg#L1-L13)
- [test_17_18.cfg:1-9](file://test_17_18.cfg#L1-L9)
- [build/test_17_18.cfg:1-11](file://build/test_17_18.cfg#L1-L11)
- [tools/disasm_17_18.py:1-710](file://tools/disasm_17_18.py#L1-L710)
- [tools/fix_disasm.py:1-56](file://tools/fix_disasm.py#L1-L56)
- [tools/gen_f667_ffff.py:1-396](file://tools/gen_f667_ffff.py#L1-L396)
- [tools/update_jsr_labels.py:1-137](file://tools/update_jsr_labels.py#L1-L137)
- [tools/verify_f3bd_f667.py:1-45](file://tools/verify_f3bd_f667.py#L1-L45)
- [tools/verify_range.py:1-42](file://tools/verify_range.py#L1-L42)
- [tools/transform_17_18.py:1-348](file://tools/transform_17_18.py#L1-L348)
- [tools/add_procs.py:1-189](file://tools/add_procs.py#L1-L189)
- [tools/analyze_17_18.py:1-118](file://tools/analyze_17_18.py#L1-L118)
- [tools/debug_regions.py:1-98](file://tools/debug_regions.py#L1-L98)
- [tools/proc_scope_17_18.py:1-813](file://tools/proc_scope_17_18.py#L1-L813)
- [tools/localize_labels.py:1-526](file://tools/localize_labels.py#L1-L526)
- [tools/auto_add_local_params.py:1-416](file://tools/auto_add_local_params.py#L1-L416)
- [tools/globalize_04xx.py:1-205](file://tools/globalize_04xx.py#L1-L205)
- [tools/check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [tools/check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [tools/check_rom_offset.py:1-43](file://tools/check_rom_offset.py#L1-L43)
- [tools/dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [tools/dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [tools/search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [tools/search_chr_loader.py:1-15](file://tools/search_chr_loader.py#L1-L15)
- [tools/search_chr_loader2.py:1-21](file://tools/search_chr_loader2.py#L1-L21)
- [tools/verify_disasm.py:1-34](file://tools/verify_disasm.py#L1-L34)

**Section sources**
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)
- [Makefile:12-31](file://Makefile#L12-L31)

## Core Components
- Makefile targets orchestrate the entire pipeline: assembling, linking, building the final ROM, splitting ROMs, disassembling, analyzing, verifying, cleaning, and the new unified disassembly pipeline with transformation tools.
- The cc65 toolchain (ca65 and ld65) compiles assembly into an object file and links it according to the linker configuration.
- Python tools handle ROM parsing, bank generation, disassembly, analysis, annotation, verification, and the comprehensive unified disassembly pipeline with transformation tools.
- **New**: Enhanced transformation pipeline provides sophisticated tools for PRG bank $17/$18 assembly code with semantic naming conventions, comprehensive .proc/.endproc organization, and advanced boundary analysis.
- **New**: Automated parameter declaration tool provides systematic approach to maintaining consistent parameter naming conventions across assembly code.
- **New**: RAM centralization tool provides systematic approach to standardizing $04xx memory region definitions with centralized global RAM definitions.
- **New**: Comprehensive ROM analysis and verification toolkit provides dedicated tools for byte-level ROM inspection, pattern matching, and cross-referencing.

Key capabilities:
- Assemble and link to produce a raw PRG binary.
- Add an iNES header and pad to the correct size to form a complete ROM.
- Split an original ROM into PRG/CHR banks for disassembly.
- Disassemble and annotate assembly for documentation and validation.
- Analyze ROM structure to identify code-heavy banks and vectors.
- Verify byte-exact rebuilds against the original ROM.
- Generate bank stubs to bootstrap disassembly.
- **New**: Unified disassembly with specialized tools for Bank $17/$18 paired disassembly, Bank $1F range disassembly, and cross-bank reference mapping.
- **New**: Enhanced transformation pipeline with semantic naming (B17_18_), comprehensive .proc/.endproc organization, cross-bank reference handling, and automated code organization.
- **New**: Automated parameter declaration system that generates meaningful local parameter names for .proc blocks.
- **New**: RAM centralization system that standardizes $04xx memory region definitions with globally defined canonical names.
- **New**: Dedicated ROM analysis tools for address verification, bank validation, offset mapping, pattern searching, and disassembly verification.

**Section sources**
- [Makefile:31-101](file://Makefile#L31-L101)
- [tools/build_nes.py:10-51](file://tools/build_nes.py#L10-L51)
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/disasm_6502.py:286-362](file://tools/disasm_6502.py#L286-L362)
- [tools/disasm_bank_1f.py:329-442](file://tools/disasm_bank_1f.py#L329-L442)
- [tools/analyze_rom.py:10-128](file://tools/analyze_rom.py#L10-L128)
- [tools/verify_rom.py:10-51](file://tools/verify_rom.py#L10-L51)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)

## Architecture Overview
The build system follows a linear pipeline with branching points for analysis and verification. The primary flow is:
- Assemble and link to produce a PRG binary.
- Convert PRG to a full NES ROM with an iNES header.
- Optionally split an original ROM into banks for comparison and disassembly.
- Disassemble and annotate assembly for documentation and validation.
- Verify the rebuilt ROM against the original.
- **New**: Apply unified disassembly pipeline for specialized ROM region processing with cross-bank reference handling.
- **New**: Apply enhanced transformation pipeline for PRG bank $17/$18 assembly code with semantic naming, comprehensive .proc/.endproc organization, and advanced boundary analysis.
- **New**: Utilize automated parameter declaration tool for systematic parameter naming in assembly code.
- **New**: Utilize RAM centralization tool for standardizing $04xx memory region definitions with centralized global RAM definitions.
- **New**: Utilize dedicated ROM analysis tools for detailed byte-level verification and pattern matching.

```mermaid
sequenceDiagram
participant Dev as "Developer"
participant MK as "Makefile"
participant CA as "ca65"
participant LD as "ld65"
participant BN as "build_nes.py"
participant VR as "verify_rom.py"
participant UD as "Unified Disassembly Pipeline"
participant TP as "Enhanced Transformation Pipeline"
participant GC as "Globalize 04xx Tool"
participant RA as "ROM Analysis Tools"
Dev->>MK : "make"
MK->>CA : "Assemble main.asm"
CA-->>MK : "main.o"
MK->>LD : "Link with linker.cfg"
LD-->>MK : "prg.bin"
MK->>BN : "Add iNES header"
BN-->>Dev : "sango2.nes"
Dev->>MK : "make verify"
MK->>VR : "Compare original vs rebuilt"
VR-->>Dev : "Byte-exact pass/fail"
Dev->>MK : "make disasm_17_18"
MK->>UD : "Unified disassembly for banks $17/$18"
UD-->>Dev : "Cross-bank labeled assembly"
Dev->>MK : "make transform_17_18"
MK->>TP : "Apply enhanced transformation pipeline"
TP->>GC : "Centralize $04xx RAM definitions"
GC-->>TP : "Standardized memory definitions"
TP-->>Dev : "Semantic naming, .proc/.endproc organization"
Dev->>MK : "make check_addresses"
MK->>RA : "Address verification and ROM analysis"
RA-->>Dev : "Detailed byte-level inspection"
```

**Diagram sources**
- [Makefile:31-48](file://Makefile#L31-L48)
- [tools/build_nes.py:10-51](file://tools/build_nes.py#L10-L51)
- [tools/verify_rom.py:10-69](file://tools/verify_rom.py#L10-L69)

## Detailed Component Analysis

### Makefile Targets and Orchestration
- make (default): Builds the final ROM by assembling, linking, and packaging with the iNES header.
- make split: Splits an original ROM into PRG/CHR banks and generates a combined PRG for disassembly.
- make banks: Generates bank stub assembly files for all 32 PRG banks.
- make disasm: Disassembles a specified binary region into ca65 assembly format.
- make analyze: Analyzes ROM structure to identify code-heavy banks and vectors.
- make verify: Compares the rebuilt ROM with the original for byte-exact accuracy.
- make clean: Removes build artifacts.
- make distclean: Removes build artifacts plus ROM dump directories.
- **New**: make disasm_17_18: Unified disassembly for paired Bank $17/$18 region with cross-bank references.
- **New**: make gen_f667_ffff: Specialized disassembly for Bank $1F range $F667-$FFFF.
- **New**: make update_jsr_labels: Update JSR/JMP operands using functions.h address map.
- **New**: make transform_17_18: Apply semantic naming transformation to PRG bank $17/$18 assembly code.
- **New**: make add_procs: Add .proc/.endproc scoping to PRG bank $17/$18 assembly code.
- **New**: make analyze_17_18: Analyze PRG bank $17/$18 assembly code boundaries and function structure.
- **New**: make debug_regions: Debug region transitions in PRG bank $17/$18 assembly code.
- **New**: make proc_scope_17_18: Enhanced .proc/.endproc scoping with advanced boundary analysis for PRG bank $17/$18 assembly code.
- **New**: make localize_labels: Convert branch-only labels to @local format with proper scoping.
- **New**: make auto_add_local_params: Automatically add local parameter declarations to .proc blocks.
- **New**: make globalize_04xx: Centralize $04xx RAM definitions with standardized global memory definitions.
- **New**: make check_addresses: Verify ROM bytes at specific addresses for disassembly accuracy.
- **New**: make check_bank18: Validate bank $18 content and cross-check with bank $17.
- **New**: make check_rom_offset: Map CPU addresses to ROM file offsets for verification.
- **New**: make dump_chr_table: Inspect CHR table data in combined ROM.
- **New**: make dump_correct_bytes: Verify correct bytes in ROM for disassembly validation.
- **New**: make search_0530: Search for $0530 store patterns in ROM.
- **New**: make search_chr_loader: Find CHR loader patterns in ROM.
- **New**: make search_chr_loader2: Locate specific CHR loader with $0530/$0531 stores.
- **New**: make verify_disasm: Comprehensive disassembly verification against ROM bytes.

Usage patterns:
- Start with make split to prepare ROM assets.
- Use make banks to bootstrap disassembly.
- Disassemble and annotate code with make disasm and tools/annotate_asm.py.
- **New**: Apply unified disassembly pipeline with make disasm_17_18 for paired bank processing.
- **New**: Use make gen_f667_ffff for specialized Bank $1F range disassembly.
- **New**: Use make update_jsr_labels to map addresses to symbols in Bank $1F assembly.
- **New**: Use transformation pipeline for PRG bank $17/$18 assembly code organization.
- **New**: Use make proc_scope_17_18 for enhanced .proc/.endproc organization with advanced boundary analysis.
- **New**: Use make localize_labels for converting branch-only labels to @local format.
- **New**: Use make auto_add_local_params for automated parameter declaration generation.
- **New**: Use make globalize_04xx for centralized RAM definition standardization.
- **New**: Utilize ROM analysis tools for detailed verification and debugging workflows.
- Iterate assembly and linking, then verify with make verify.

**Section sources**
- [Makefile:31-101](file://Makefile#L31-L101)
- [PROJECT.md:58-69](file://PROJECT.md#L58-L69)

### ROM Generation Pipeline (Assembly to Final NES ROM)
The pipeline converts assembly into a playable ROM with:
- Assembling: ca65 compiles main.asm into an object file.
- Linking: ld65 links with linker.cfg to produce a PRG binary.
- Packaging: build_nes.py adds an iNES header and pads PRG to 16KB pages, creates empty CHR, and prints ROM metadata.

```mermaid
flowchart TD
Start(["Start"]) --> Assemble["Assemble with ca65"]
Assemble --> Link["Link with ld65 and linker.cfg"]
Link --> BuildHeader["Add iNES header<br/>Pad PRG to 16KB pages<br/>Empty CHR"]
BuildHeader --> Output(["Final ROM"])
```

**Diagram sources**
- [Makefile:38-48](file://Makefile#L38-L48)
- [tools/build_nes.py:10-51](file://tools/build_nes.py#L10-L51)
- [linker.cfg:18-54](file://linker.cfg#L18-L54)

**Section sources**
- [Makefile:38-48](file://Makefile#L38-L48)
- [tools/build_nes.py:10-51](file://tools/build_nes.py#L10-L51)
- [linker.cfg:18-54](file://linker.cfg#L18-L54)

### ROM Splitting and Bank Generation
- split_rom.py parses the iNES header, splits PRG/CHR into 8KB banks, and writes rom_info.h with mapper and bank counts.
- generate_bank_stubs.py creates 32 bank stubs and an all_banks.asm include file to simplify assembly inclusion.

```mermaid
flowchart TD
SplitStart(["ROM File"]) --> Parse["Parse iNES Header"]
Parse --> SplitPRG["Split PRG into 8KB banks"]
Parse --> SplitCHR["Split CHR into 8KB banks"]
SplitPRG --> WriteBanks["Write prg_*.bin files"]
SplitCHR --> WriteBanks
WriteBanks --> Info["Write rom_info.h"]
Info --> Combined["Write prg_combined.bin"]
```

**Diagram sources**
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)

**Section sources**
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)

### Disassembly and Annotation Tools
- disasm_6502.py disassembles 6502 binaries into ca65 assembly with address and byte columns, supporting various addressing modes.
- disasm_bank_1f.py provides comprehensive disassembly for Bank 0x1F with structured function definitions, named regions, and inline binary comments.
- **New**: disasm_17_18.py provides unified recursive descent disassembly for paired Bank $17/$18 region with cross-bank reference handling.
- **New**: gen_f667_ffff.py generates specialized disassembly for Bank $1F range $F667-$FFFF with detailed interrupt handler analysis.
- **New**: update_jsr_labels.py maps JSR/JMP operands to symbolic names using functions.h address map.
- **New**: verify_f3bd_f667.py verifies Bank $1F range $F3BD-$F667 assembly against binary with detailed error reporting.
- annotate_asm.py annotates existing assembly with ROM addresses and actual opcode bytes, using a symbol table and instruction size heuristics. It can optionally verify assembly with ca65.

**Updated** Enhanced with improved output format supporting inline binary comments and detailed address mapping for precise ROM analysis.

```mermaid
sequenceDiagram
participant DS as "disasm_6502.py"
participant DS1F as "disasm_bank_1f.py"
participant DS17_18 as "disasm_17_18.py"
participant GEN as "gen_f667_ffff.py"
participant UPDATE as "update_jsr_labels.py"
participant VERIFY as "verify_f3bd_f667.py"
participant AN as "annotate_asm.py"
participant ASM as "Assembly Source"
participant BIN as "Binary Bank"
BIN->>DS : "Binary data"
DS-->>ASM : "Listing with addresses and bytes"
DS1F-->>ASM : "Structured assembly with inline comments"
DS17_18-->>ASM : "Cross-bank labeled assembly"
GEN-->>ASM : "Interrupt handler disassembly"
UPDATE-->>ASM : "Address-to-symbol mapping"
VERIFY-->>ASM : "Range verification"
ASM->>AN : "Assembly with placeholders"
AN->>BIN : "Lookup opcode bytes"
AN-->>ASM : "Annotated assembly with addresses and bytes"
```

**Diagram sources**
- [tools/disasm_6502.py:286-362](file://tools/disasm_6502.py#L286-L362)
- [tools/disasm_bank_1f.py:329-442](file://tools/disasm_bank_1f.py#L329-L442)
- [tools/disasm_17_18.py:1-710](file://tools/disasm_17_18.py#L1-L710)
- [tools/gen_f667_ffff.py:1-396](file://tools/gen_f667_ffff.py#L1-L396)
- [tools/update_jsr_labels.py:1-137](file://tools/update_jsr_labels.py#L1-L137)
- [tools/verify_f3bd_f667.py:1-45](file://tools/verify_f3bd_f667.py#L1-L45)
- [tools/annotate_asm.py:315-478](file://tools/annotate_asm.py#L315-L478)

**Section sources**
- [tools/disasm_6502.py:286-362](file://tools/disasm_6502.py#L286-L362)
- [tools/disasm_bank_1f.py:329-442](file://tools/disasm_bank_1f.py#L329-L442)
- [tools/disasm_17_18.py:1-710](file://tools/disasm_17_18.py#L1-L710)
- [tools/gen_f667_ffff.py:1-396](file://tools/gen_f667_ffff.py#L1-L396)
- [tools/update_jsr_labels.py:1-137](file://tools/update_jsr_labels.py#L1-L137)
- [tools/verify_f3bd_f667.py:1-45](file://tools/verify_f3bd_f667.py#L1-L45)
- [tools/annotate_asm.py:315-478](file://tools/annotate_asm.py#L315-L478)

### ROM Verification System
- verify_rom.py performs a byte-by-byte comparison of two ROM files, reporting total mismatches, first mismatch address, and accuracy percentage. It exits with success when identical.
- **New**: verify_f3bd_f667.py verifies Bank $1F range $F3BD-$F667 assembly against binary with detailed error reporting.
- **New**: verify_range.py verifies disassembly bytes in prg_1f.aligned.asm against the binary for range $E843-$F2AE.
- **New**: verify_disasm.py provides comprehensive disassembly verification by checking multiple known addresses for byte-level accuracy.

```mermaid
flowchart TD
VStart(["Run verify_rom.py"]) --> ReadOrig["Read original ROM"]
VStart --> ReadRebuilt["Read rebuilt ROM"]
ReadOrig --> Compare["Compare bytes"]
ReadRebuilt --> Compare
Compare --> Report["Report mismatches and accuracy"]
Report --> Exit(["Exit code 0 if identical, else 1"])
```

**Diagram sources**
- [tools/verify_rom.py:10-69](file://tools/verify_rom.py#L10-L69)

**Section sources**
- [tools/verify_rom.py:10-69](file://tools/verify_rom.py#L10-L69)

### Linker Configuration and Bank Segments
- linker.cfg defines 4 PRG slots ($8000-$FFFF) and segments for code/data. As banks are disassembled, new segments are added to map code into the correct bank slots.
- **New**: test_17_18.cfg provides a temporary configuration for standalone verification of paired Bank $17/$18 assembly code.
- **New**: build/test_17_18.cfg provides a test linker configuration specifically for Bank $17/$18 disassembly pipeline.

```mermaid
classDiagram
class LinkerConfig {
+MEMORY PRG slots
+SEGMENTS CODE/VECTORS/RODATA
+Optional banked segments
}
class TestLinkerConfig {
+Standalone Bank $1F verification
+Minimal memory layout
}
class Test17_18Config {
+Paired Bank $17/$18 disassembly
+Cross-bank reference handling
}
class Test17_18BuildConfig {
+Build-time validation
+Separate PRG regions
}
LinkerConfig --> Test17_18Config : "inspiration"
Test17_18Config --> Test17_18BuildConfig : "build variant"
```

**Diagram sources**
- [linker.cfg:18-54](file://linker.cfg#L18-L54)
- [test_linker.cfg:1-13](file://test_linker.cfg#L1-13)
- [test_17_18.cfg:1-9](file://test_17_18.cfg#L1-L9)
- [build/test_17_18.cfg:1-11](file://build/test_17_18.cfg#L1-L11)

**Section sources**
- [linker.cfg:18-54](file://linker.cfg#L18-L54)
- [test_linker.cfg:1-13](file://test_linker.cfg#L1-13)
- [test_17_18.cfg:1-9](file://test_17_18.cfg#L1-L9)
- [build/test_17_18.cfg:1-11](file://build/test_17_18.cfg#L1-L11)

### Assembly Entry Points and Mapper Integration
- asm/main.asm sets up reset/NMI/IRQ handlers, initializes PPU/APU, and switches PRG banks via macros from include/namco163.h.
- include/namco163.h defines mapper registers and bank switching macros used by the assembly.
- include/macros.h provides convenience macros for PPU operations and DMA.
- **New**: include/functions.h provides address-to-symbol mapping for Bank $1F code with $E000-$FFFF addresses.

```mermaid
graph LR
M["asm/main.asm"] --> N["include/namco163.h"]
M --> H["include/6502_registers.h"]
M --> G["include/macros.h"]
M --> F["include/functions.h"]
M --> L["linker.cfg"]
```

**Diagram sources**
- [asm/main.asm:1-141](file://asm/main.asm#L1-L141)
- [include/namco163.h:1-87](file://include/namco163.h#L1-L87)
- [include/macros.h:1-72](file://include/macros.h#L1-L72)
- [include/functions.h:1-87](file://include/functions.h#L1-L87)
- [linker.cfg:18-54](file://linker.cfg#L18-L54)

**Section sources**
- [asm/main.asm:25-141](file://asm/main.asm#L25-L141)
- [include/namco163.h:10-87](file://include/namco163.h#L10-L87)
- [include/macros.h:8-72](file://include/macros.h#L8-L72)
- [include/functions.h:1-87](file://include/functions.h#L1-L87)

## Unified Disassembly Pipeline

### Overview
The unified disassembly pipeline provides a comprehensive automated workflow for processing different ROM regions with specialized tools. The pipeline consists of six specialized tools that work together to provide cross-bank reference handling, address-to-symbol mapping, and region-specific disassembly capabilities.

### Pipeline Architecture
The unified disassembly pipeline operates on different ROM regions with specialized tools:

```mermaid
flowchart TD
Stage1["disasm_17_18.py<br/>710 lines - Paired Bank $17/$18"] --> Stage2["fix_disasm.py<br/>Cross-bank reference fix"]
Stage2 --> Stage3["gen_f667_ffff.py<br/>Bank $1F range $F667-$FFFF"]
Stage3 --> Stage4["update_jsr_labels.py<br/>Address-to-symbol mapping"]
Stage4 --> Stage5["verify_f3bd_f667.py<br/>Range verification"]
Stage5 --> Stage6["verify_range.py<br/>Aligned assembly verification"]
```

**Diagram sources**
- [tools/disasm_17_18.py:1-710](file://tools/disasm_17_18.py#L1-L710)
- [tools/fix_disasm.py:1-56](file://tools/fix_disasm.py#L1-L56)
- [tools/gen_f667_ffff.py:1-396](file://tools/gen_f667_ffff.py#L1-L396)
- [tools/update_jsr_labels.py:1-137](file://tools/update_jsr_labels.py#L1-L137)
- [tools/verify_f3bd_f667.py:1-45](file://tools/verify_f3bd_f667.py#L1-L45)
- [tools/verify_range.py:1-42](file://tools/verify_range.py#L1-L42)

### Stage-by-Stage Breakdown

#### Stage 1: Paired Bank Disassembly (disasm_17_18.py)
- **Recursive Descent Analysis**: Uses sophisticated recursive descent algorithm to distinguish code from data across paired Bank $17/$18 region ($A000-$DFFF).
- **Cross-Bank Reference Handling**: Automatically detects and handles cross-bank references between $A000-$BFFF and $C000-$DFFF.
- **Inline Table Detection**: Identifies callback dispatcher tables and banked callback trampolines with automatic table size calculation.
- **Known Function Integration**: Incorporates known function addresses from Bank $1F for better disassembly accuracy.
- **Output Generation**: Produces labeled assembly with proper cross-bank equates and inline byte comments.

#### Stage 2: Cross-Bank Reference Fix (fix_disasm.py)
- **Automated Enhancement**: Enhances existing disasm_17_18.py with cross-bank reference computation and equate generation.
- **Integration Point**: Inserts cross-reference collection after label building and before output generation.
- **Equation Generation**: Creates proper equate statements for cross-bank references in both directions.

#### Stage 3: Bank $1F Range Disassembly (gen_f667_ffff.py)
- **Specialized Range Processing**: Focuses on Bank $1F range $F667-$FFFF with detailed interrupt handler analysis.
- **Interrupt Handler Coverage**: Provides comprehensive disassembly of NMI/IRQ handlers, scroll routines, and interrupt vectors.
- **Structural Organization**: Groups code into logical sections with proper procedure boundaries and data tables.
- **Padding Detection**: Identifies and formats unused ROM regions with appropriate comments.

#### Stage 4: Address-to-Symbol Mapping (update_jsr_labels.py)
- **Symbol Resolution**: Maps JSR/JMP operands to symbolic names using functions.h address map for $E000-$FFFF.
- **Inline Comment Parsing**: Decodes target addresses from inline byte comments in assembly files.
- **Idempotent Processing**: Safe to run multiple times without changing output.
- **Scoped Reference Handling**: Excludes local (@) and scoped (::) references from automatic mapping.

#### Stage 5: Range Verification (verify_f3bd_f667.py)
- **Targeted Verification**: Verifies Bank $1F range $F3BD-$F667 assembly against original binary.
- **Pattern Matching**: Uses strict regex pattern matching for inline byte comments with 2-digit hex validation.
- **Error Reporting**: Provides detailed error reports with expected vs actual byte comparisons.
- **Count Validation**: Ensures both byte content and count match the expected 683 bytes.

#### Stage 6: Aligned Assembly Verification (verify_range.py)
- **Range-Specific Validation**: Verifies disassembly bytes in prg_1f.aligned.asm against binary for range $E843-$F2AE.
- **Pattern Validation**: Ensures all tokens are exactly 2 hex characters for reliable parsing.
- **Comprehensive Coverage**: Validates the aligned Bank $1F assembly file for the specified address range.

**Section sources**
- [tools/disasm_17_18.py:1-710](file://tools/disasm_17_18.py#L1-L710)
- [tools/fix_disasm.py:1-56](file://tools/fix_disasm.py#L1-L56)
- [tools/gen_f667_ffff.py:1-396](file://tools/gen_f667_ffff.py#L1-L396)
- [tools/update_jsr_labels.py:1-137](file://tools/update_jsr_labels.py#L1-L137)
- [tools/verify_f3bd_f667.py:1-45](file://tools/verify_f3bd_f667.py#L1-L45)
- [tools/verify_range.py:1-42](file://tools/verify_range.py#L1-L42)

### Integration with Build System
The unified disassembly pipeline integrates seamlessly with the Makefile build system:
- **New**: make disasm_17_18 target triggers the complete paired bank disassembly workflow.
- **New**: make gen_f667_ffff target generates specialized Bank $1F range disassembly.
- **New**: make update_jsr_labels target updates JSR/JMP operands using address mapping.
- **New**: make verify_f3bd_f667 target validates Bank $1F range assembly.
- Each stage produces detailed logging and validation feedback.
- Intermediate results are saved to maintain progress and enable debugging.
- Final output provides comprehensive cross-bank labeled assembly ready for compilation.

**Section sources**
- [Makefile:31-101](file://Makefile#L31-L101)

## Enhanced Disassembly Tools

### Advanced Disassembly Capabilities
The project now features significantly enhanced disassembly tools with improved output formats that provide detailed address mapping and inline binary comments:

#### disasm_6502.py - Enhanced Basic Disassembler
- Produces formatted output with address, byte columns, and instruction mnemonics
- Supports various addressing modes with proper operand formatting
- Provides truncated instruction handling for boundary conditions
- Includes base address mapping for accurate CPU address translation

#### disasm_bank_1f.py - Comprehensive Bank 0x1F Disassembler
- **Structured Function Analysis**: Organizes Bank 0x1F into named functions and data regions
- **Inline Binary Comments**: Each instruction includes detailed address and raw byte information
- **Named Region Definitions**: Groups code into logical sections (Reset, State Handlers, Sound Engine, etc.)
- **Complete Interrupt Vector Support**: Properly handles NMI/RESET/IRQ vectors with inline comments
- **Data Table Formatting**: Formats data regions with inline address and byte comments
- **Padding Detection**: Identifies and formats unused ROM regions

#### disasm_17_18.py - Unified Paired Bank Disassembler
- **Recursive Descent Analysis**: Sophisticated algorithm to distinguish code from data across paired banks
- **Cross-Bank Reference Handling**: Automatic detection and labeling of cross-bank references
- **Inline Table Detection**: Identifies callback dispatcher tables and banked callback patterns
- **Known Function Integration**: Incorporates Bank $1F function addresses for better accuracy
- **Cross-Bank Equates**: Generates proper equate statements for inter-bank references
- **Output Generation**: Produces labeled assembly with inline byte comments

#### gen_f667_ffff.py - Specialized Bank $1F Range Disassembler
- **Interrupt Handler Focus**: Comprehensive disassembly of NMI/IRQ handlers and scroll routines
- **Structural Organization**: Logical grouping of interrupt handlers, state machines, and data tables
- **Padding Detection**: Identifies and formats unused ROM regions with appropriate comments
- **Vector Table Analysis**: Proper handling of interrupt vectors and dispatch tables

#### update_jsr_labels.py - Address-to-Symbol Mapping Tool
- **Symbol Resolution**: Maps JSR/JMP operands to symbolic names using functions.h address map
- **Inline Comment Parsing**: Decodes target addresses from assembly inline comments
- **Scoped Reference Handling**: Excludes local (@) and scoped (::) references from mapping
- **Idempotent Processing**: Safe to run multiple times without changing output

#### verify_f3bd_f667.py - Range Verification Tool
- **Targeted Verification**: Validates Bank $1F range $F3BD-$F667 assembly against original binary
- **Pattern Matching**: Strict regex validation for inline byte comments with 2-digit hex
- **Error Reporting**: Detailed comparison of expected vs actual byte content
- **Count Validation**: Ensures both byte content and count match expected values

**Enhanced Output Format Features**:
- Address mapping: `${addr:04X}:` provides precise ROM address information
- Inline binary comments: Raw byte sequences appended as `; ${addr:04X}: ${raw_str}`
- Structured organization: Logical grouping of functions, tables, and data sections
- Complete coverage: Handles all 8KB of Bank 0x1F with detailed analysis
- Cross-bank references: Proper handling of inter-bank code and data references

```mermaid
flowchart TD
Start(["Binary Input"]) --> Parse["Parse Instructions"]
Parse --> Structure["Structure by Named Regions"]
Structure --> CrossRef["Handle Cross-Bank References"]
CrossRef --> LabelMap["Apply Address-to-Symbol Mapping"]
LabelMap --> Comment["Add Inline Binary Comments"]
Comment --> Format["Format Assembly Output"]
Format --> End(["Enhanced Assembly Listing"])
```

**Diagram sources**
- [tools/disasm_17_18.py:1-710](file://tools/disasm_17_18.py#L1-L710)
- [tools/gen_f667_ffff.py:1-396](file://tools/gen_f667_ffff.py#L1-L396)
- [tools/update_jsr_labels.py:1-137](file://tools/update_jsr_labels.py#L1-L137)

**Section sources**
- [tools/disasm_6502.py:286-362](file://tools/disasm_6502.py#L286-L362)
- [tools/disasm_bank_1f.py:329-442](file://tools/disasm_bank_1f.py#L329-L442)
- [tools/disasm_17_18.py:1-710](file://tools/disasm_17_18.py#L1-L710)
- [tools/gen_f667_ffff.py:1-396](file://tools/gen_f667_ffff.py#L1-L396)
- [tools/update_jsr_labels.py:1-137](file://tools/update_jsr_labels.py#L1-L137)
- [tools/verify_f3bd_f667.py:1-45](file://tools/verify_f3bd_f667.py#L1-L45)

### Advanced Annotation and Address Mapping
- annotate_asm.py provides sophisticated address mapping with section header resynchronization
- Supports both address-only and full annotation modes
- Includes forward search capability to handle ROM instruction variations
- Provides verification support with optional ca65 compilation checks
- **New**: Integrated with unified disassembly pipeline for cross-bank reference handling

**Enhanced Annotation Features**:
- Address hint parsing: Resynchronizes address mapping using section header comments
- Forward instruction search: Handles cases where ROM has extra instructions
- Symbol resolution: Integrates with include files for accurate operand resolution
- Verification integration: Optional ca65 compilation to validate annotated assembly
- Cross-bank reference support: Handles inter-bank code and data references

**Section sources**
- [tools/annotate_asm.py:315-478](file://tools/annotate_asm.py#L315-L478)

## Transformation Pipeline

### Overview
The transformation pipeline provides a comprehensive automated workflow for organizing and enhancing PRG bank $17/$18 assembly code with semantic naming conventions, enhanced .proc/.endproc organization, and advanced boundary analysis. The pipeline consists of eight specialized tools that work together to provide systematic parameter naming, code organization, naming standardization, and comprehensive debugging capabilities.

### Pipeline Architecture
The transformation pipeline operates on PRG bank $17/$18 assembly code with eight specialized stages:

```mermaid
flowchart TD
Stage1["transform_17_18.py<br/>348 lines - Semantic Naming"] --> Stage2["add_procs.py<br/>189 lines - Basic Scoping"]
Stage2 --> Stage3["analyze_17_18.py<br/>118 lines - Boundary Analysis"]
Stage3 --> Stage4["debug_regions.py<br/>98 lines - Transition Debugging"]
Stage4 --> Stage5["proc_scope_17_18.py<br/>Enhanced .proc/.endproc"]
Stage5 --> Stage6["localize_labels.py<br/>New @local conversion"]
Stage6 --> Stage7["auto_add_local_params.py<br/>415 lines - Automated parameter naming"]
Stage7 --> Stage8["globalize_04xx.py<br/>205 lines - RAM centralization"]
Stage8 --> Output["Optimized Assembly Code"]
```

**Diagram sources**
- [tools/transform_17_18.py:1-348](file://tools/transform_17_18.py#L1-L348)
- [tools/add_procs.py:1-189](file://tools/add_procs.py#L1-L189)
- [tools/analyze_17_18.py:1-118](file://tools/analyze_17_18.py#L1-L118)
- [tools/debug_regions.py:1-98](file://tools/debug_regions.py#L1-L98)
- [tools/proc_scope_17_18.py:1-813](file://tools/proc_scope_17_18.py#L1-L813)
- [tools/localize_labels.py:1-526](file://tools/localize_labels.py#L1-L526)
- [tools/auto_add_local_params.py:1-416](file://tools/auto_add_local_params.py#L1-L416)
- [tools/globalize_04xx.py:1-205](file://tools/globalize_04xx.py#L1-L205)

### Stage-by-Stage Breakdown

#### Stage 1: Semantic Naming Transformation (transform_17_18.py)
- **Region-Based Organization**: Uses a comprehensive region map to identify function boundaries and data sections across Bank $17 ($A000-$BFFF) and Bank $18 ($C000-$DFFF).
- **Semantic Naming Convention**: Applies B17_18_ prefix to all identified functions and data structures for clear identification.
- **Cross-Bank Reference Handling**: Automatically detects and handles cross-bank references between $A000-$BFFF and $C000-$DFFF.
- **Section Headers**: Adds detailed section headers with address ranges, function types, and descriptions.
- **Label Renaming**: Renames LXXXX labels to semantic B17_18_ names and updates all references.
- **Dry Run Mode**: Supports --dry-run flag for previewing changes without modification.

#### Stage 2: Basic Procedure Scoping (add_procs.py)
- **Block Parsing**: Parses assembly code into structured blocks including section headers, labels, code, data, and comments.
- **Region Classification**: Classifies regions as code or data based on content analysis and section headers.
- **Cross-Reference Analysis**: Identifies cross-referenced Lxxxx labels that need proper scoping.
- **Scoping Implementation**: Adds .proc/.endproc directives around identified regions to improve code organization.
- **Block Grouping**: Groups related blocks into logical regions for better maintainability.

#### Stage 3: Advanced Boundary Analysis (analyze_17_18.py)
- **Address Mapping**: Builds comprehensive address-to-line mappings from inline byte comments.
- **Function Boundary Detection**: Analyzes RTS instructions, JSR/JMP patterns, and label relationships to identify function boundaries.
- **Entry Point Analysis**: Identifies jump table entry targets and traces function extents.
- **Cross-Bank Reference Analysis**: Detects and analyzes cross-bank references and their implications.
- **Statistical Analysis**: Provides counts of JSR/JMP instructions and function sizes for code analysis.

#### Stage 4: Region Transition Debugging (debug_regions.py)
- **Transition Analysis**: Tracks region transitions throughout the assembly code to ensure proper boundary detection.
- **Boundary Validation**: Validates that region boundaries align with actual code structure and address ranges.
- **Debug Output**: Provides detailed transition reports showing when and where region changes occur.
- **Boundary Verification**: Compares detected transitions with expected region counts and boundaries.

#### Stage 5: Enhanced .proc/.endproc Organization (proc_scope_17_18.py)
- **Advanced Boundary Detection**: Implements sophisticated algorithm to determine optimal .proc/.endproc boundaries based on code structure and data regions.
- **Proc Boundary Calculation**: Uses comprehensive analysis of label definitions, data ranges, and inline dispatch tables to determine proc boundaries.
- **Inner Global Detection**: Identifies labels that appear in multiple contexts and marks them as inner globals requiring special handling.
- **At-Candidate Analysis**: Detects labels that could be @-scoped references and analyzes their usage patterns.
- **Word Target Processing**: Handles word-sized targets and their relationship to proc boundaries.
- **Boundary Optimization**: Optimizes proc boundaries to minimize overlap and maximize code clarity.

#### Stage 6: Localized Label Conversion (localize_labels.py)
- **Branch-Only Label Detection**: Identifies labels that are only referenced by branch instructions (BCC, BCS, BEQ, etc.).
- **@Local Conversion**: Converts these labels to @local format for proper scoping within procedures.
- **Safety Verification**: Ensures that @local labels are only used within the same procedure context.
- **Descriptive Naming**: Generates meaningful @ names based on branch direction and context (loop, done, skip, target).
- **Cross-Reference Handling**: Manages cross-procedure references appropriately.

#### Stage 7: Automated Parameter Declaration (auto_add_local_params.py)
- **Parameter Extraction**: Parses all .proc/.endproc blocks and extracts zero-page/RAM memory addresses used in each proc.
- **Global Definition Filtering**: Skips addresses that are already globally defined, focusing only on local parameters.
- **Meaningful Naming**: Generates descriptive parameter names based on context, usage patterns, and address ranges.
- **Pointer Pair Detection**: Automatically identifies consecutive addresses that form pointer pairs (lo/hi) and renames them systematically.
- **Parameter Insertion**: Inserts parameter definitions at the start of each .proc block with proper formatting.
- **Address Replacement**: Replaces raw addresses in proc bodies with named parameters, handling both full and zero-page forms.
- **Well-Known Address Support**: Uses predefined naming conventions for common addresses (pointers, counters, flags, etc.).

#### Stage 8: RAM Centralization (globalize_04xx.py)
- **Canonical Name Mapping**: Defines comprehensive mapping from $04xx addresses to globally standardized canonical names.
- **Global Definition Block Generation**: Creates centralized global RAM definition block outside .proc scopes.
- **Local Definition Removal**: Removes all local $04xx = $04XX definitions from inside .proc blocks.
- **Alias Renaming**: Replaces old alias names with canonical names in instruction lines.
- **Functional Grouping**: Organizes $04xx addresses into logical functional groups (Pointer/State, Officer/Selection, Map/Scroll pointers, Main game state, Extended state).
- **Comment Integration**: Adds descriptive comments to canonical names for improved code documentation.

### Integration with Build System
The transformation pipeline integrates seamlessly with the Makefile build system:
- **New**: make transform_17_18 target applies semantic naming transformation to PRG bank $17/$18 assembly code.
- **New**: make add_procs target adds basic .proc/.endproc scoping to organized assembly code.
- **New**: make analyze_17_18 target analyzes function boundaries and cross-bank references.
- **New**: make debug_regions target validates region transitions and boundary detection.
- **New**: make proc_scope_17_18 target applies enhanced .proc/.endproc organization with advanced boundary analysis.
- **New**: make localize_labels target converts branch-only labels to @local format with proper scoping.
- **New**: make auto_add_local_params target automatically adds local parameter declarations to .proc blocks.
- **New**: make globalize_04xx target centralizes $04xx RAM definitions with standardized global memory definitions.
- Each stage produces detailed logging and validation feedback.
- Intermediate results are saved to maintain progress and enable debugging.
- Final output provides well-organized, semantically-named assembly code with optimized .proc/.endproc boundaries, systematic parameter naming, and centralized RAM definitions ready for compilation.

**Section sources**
- [tools/transform_17_18.py:1-348](file://tools/transform_17_18.py#L1-L348)
- [tools/add_procs.py:1-189](file://tools/add_procs.py#L1-L189)
- [tools/analyze_17_18.py:1-118](file://tools/analyze_17_18.py#L1-L118)
- [tools/debug_regions.py:1-98](file://tools/debug_regions.py#L1-L98)
- [tools/proc_scope_17_18.py:1-813](file://tools/proc_scope_17_18.py#L1-L813)
- [tools/localize_labels.py:1-526](file://tools/localize_labels.py#L1-L526)
- [tools/auto_add_local_params.py:1-416](file://tools/auto_add_local_params.py#L1-L416)
- [tools/globalize_04xx.py:1-205](file://tools/globalize_04xx.py#L1-L205)

### Semantic Naming Conventions
The transformation pipeline implements a comprehensive semantic naming system for PRG bank $17/$18 assembly code:

#### Naming Pattern
- **Prefix**: B17_18_ (identifies Bank $17/$18 origin)
- **Function Names**: Descriptive names based on functionality (e.g., B17_18_ PpuWriteRle, B17_18_ DisplayRenderScene)
- **Data Names**: Descriptive names indicating data purpose (e.g., B17_18_ BattleTileData, B17_18_ TileLookupTable)
- **Table Names**: Descriptive names indicating table purpose (e.g., B17_18_ JumpTable, B17_18_ AnimFrameTable)

#### Cleaner Naming Examples
Recent refactoring has introduced cleaner, more descriptive function names:
- **PpuWriteRle**: Replaces generic LXXXX naming with clear PPU RLE writing functionality
- **PpuCopyRaw**: Clear indication of raw PPU data copying operation
- **PpuWriteTileOffset**: Describes tile offset writing to PPU
- **DomesticDisplay**: Self-explanatory domestic affairs display routine

#### Region Classification
- **Functions**: Code regions ending with RTS, tail-call JMP, or region boundaries
- **Data Tables**: Static data arrays and lookup tables
- **Jump Tables**: Dispatch tables with multiple entry points
- **State Machines**: Complex control flow with multiple states

#### Cross-Bank Reference Handling
- **Automatic Detection**: Identifies cross-bank references between $A000-$BFFF and $C000-$DFFF
- **Proper Labeling**: Ensures cross-bank references use semantic naming conventions
- **Equation Generation**: Creates proper equate statements for cross-bank references
- **Scope Management**: Maintains proper scoping across bank boundaries

### Enhanced .proc/.endproc Organization
The proc_scope_17_18.py tool provides advanced .proc/.endproc organization with sophisticated boundary analysis:

#### Advanced Boundary Detection Algorithm
- **Proc Start Analysis**: Identifies potential proc start locations based on label definitions and code structure
- **Data Region Integration**: Incorporates data region boundaries into proc boundary calculations
- **Next Boundary Determination**: Calculates optimal end points by finding the nearest proc start or data region
- **Boundary Optimization**: Minimizes overlap and maximizes code clarity through boundary optimization

#### Inner Global Detection
- **Multi-Context Labels**: Identifies labels that appear in multiple contexts requiring special handling
- **Inner Global Marking**: Marks inner globals with appropriate scope qualifiers
- **Cross-Reference Handling**: Ensures proper handling of cross-references to inner globals

#### At-Candidate Analysis
- **At-Reference Detection**: Identifies labels that could be @-scoped references
- **Usage Pattern Analysis**: Analyzes usage patterns to determine appropriate scoping
- **Candidate Classification**: Classifies labels as potential @-references for further processing

#### Word Target Processing
- **Word-Sized Target Detection**: Identifies word-sized targets and their relationship to proc boundaries
- **Target Analysis**: Analyzes word targets to determine their impact on proc boundaries
- **Boundary Adjustment**: Adjusts proc boundaries based on word target relationships

### Localized Label Conversion
The localize_labels.py tool provides systematic conversion of branch-only labels to @local format:

#### Branch-Only Label Detection
- **Reference Analysis**: Identifies labels that are only referenced by branch instructions (BCC, BCS, BEQ, etc.)
- **Usage Pattern Recognition**: Analyzes instruction patterns to determine label scope requirements
- **Safety Verification**: Ensures @local labels are only used within the same procedure context

#### Descriptive @Naming Strategy
- **Direction-Based Naming**: Generates meaningful names based on branch direction and context
- **Loop Detection**: Identifies loop constructs and names them appropriately
- **Conditional Logic**: Handles conditional branches with descriptive naming (skip, done)
- **Fallback Naming**: Uses target as default when context doesn't indicate a specific pattern

#### Safety and Validation
- **Cross-Procedure Reference Checking**: Verifies that @local labels aren't referenced across procedure boundaries
- **Iteration-Based Promotion**: Promotes labels with cross-procedure references to proc_starts
- **Deterministic Ordering**: Processes labels in a consistent order for reproducible results

### Automated Parameter Declaration System
The auto_add_local_params.py tool provides systematic approach to maintaining consistent parameter naming conventions:

#### Parameter Extraction and Analysis
- **Proc Block Parsing**: Identifies all .proc/.endproc blocks and extracts memory addresses used within each block
- **Address Range Filtering**: Skips hardware registers, ROM, and expansion memory ranges, focusing on RAM and zero-page addresses
- **Usage Pattern Analysis**: Records instruction types, read/write operations, and access frequencies for each address
- **Global Definition Detection**: Filters out addresses that are already globally defined, focusing on local parameters only

#### Intelligent Parameter Naming
- **Well-Known Address Support**: Uses predefined naming conventions for common addresses (pointers, counters, flags, etc.)
- **Context-Aware Naming**: Generates descriptive names based on instruction patterns, address ranges, and usage characteristics
- **Pointer Pair Detection**: Automatically identifies consecutive addresses that form pointer pairs and renames them systematically
- **Name Collision Prevention**: Ensures unique parameter names by appending numeric suffixes when conflicts occur

#### Parameter Insertion and Replacement
- **Parameter Definition Generation**: Creates formatted parameter definitions with proper alignment and spacing
- **Address Replacement**: Replaces raw addresses in proc bodies with named parameters, handling both absolute and zero-page forms
- **Comment Preservation**: Maintains inline comments and formatting while replacing addresses with meaningful parameter names
- **Pointer Form Handling**: Properly handles both full 16-bit addresses and 8-bit zero-page forms in address replacement

#### Advanced Features
- **Skip Range Management**: Excludes hardware registers, ROM, expansion ROM, and SRAM from parameter consideration
- **Instruction Type Analysis**: Differentiates between read-only, write-only, and read-write operations for better naming decisions
- **Branch Instruction Detection**: Identifies status flags and loop variables through branch instruction patterns
- **State Variable Recognition**: Detects state machine variables through specific address range patterns

### RAM Centralization System
The globalize_04xx.py tool provides systematic approach to standardizing $04xx memory region definitions:

#### Canonical Name Mapping
- **Comprehensive Address Coverage**: Maps all $04xx addresses to globally standardized canonical names
- **Functional Grouping**: Organizes addresses into logical functional groups for better code organization
- **Descriptive Naming**: Uses meaningful names that describe the purpose and usage of each memory location
- **Comment Integration**: Adds descriptive comments to explain the function and context of each canonical name

#### Global Definition Generation
- **Centralized Block Creation**: Generates a centralized global RAM definition block outside .proc scopes
- **Functional Organization**: Groups related memory addresses by their functional purpose (pointer/state, officer/selection, map/scroll, etc.)
- **Consistent Formatting**: Uses consistent formatting and spacing for easy reading and maintenance
- **Documentation Integration**: Includes explanatory comments for each functional group

#### Local Definition Removal
- **Alias Detection**: Identifies all local $04xx = $04XX definitions within .proc blocks
- **Selective Removal**: Removes only those local definitions that correspond to canonical addresses
- **Reference Tracking**: Counts and reports the number of local definitions removed
- **Scope Preservation**: Maintains proper scoping for non-canonical addresses

#### Alias Renaming
- **Pattern Matching**: Uses regex patterns to identify and replace old alias names with canonical names
- **Whole-Word Replacement**: Ensures complete replacement without partial matches
- **Reference Counting**: Tracks and reports the number of references renamed
- **Scope Awareness**: Preserves local @-scoped references and ::-scoped references

#### Functional Grouping Strategy
The tool organizes $04xx addresses into five functional groups:
- **Pointer/State ($0400-$0411)**: General-purpose pointer and state variables
- **Officer/Selection ($0424-$0435)**: Officer selection and assignment variables
- **Map/Scroll pointers ($0470-$0473)**: Map scrolling and display pointer variables
- **Main game state ($04A8-$04C0)**: Core game state and control variables
- **Extended state ($04C9-$04D5)**: Extended state and data pointer variables

**Section sources**
- [tools/transform_17_18.py:30-168](file://tools/transform_17_18.py#L30-L168)
- [tools/proc_scope_17_18.py:315-813](file://tools/proc_scope_17_18.py#L315-L813)
- [tools/localize_labels.py:1-526](file://tools/localize_labels.py#L1-L526)
- [tools/auto_add_local_params.py:1-416](file://tools/auto_add_local_params.py#L1-L416)
- [tools/globalize_04xx.py:1-205](file://tools/globalize_04xx.py#L1-L205)

## RAM Centralization and Standardization

### Overview
The RAM centralization system provides a comprehensive automated workflow for standardizing $04xx memory region definitions in PRG bank $17/$18 assembly code. This system addresses the challenge of inconsistent memory address aliasing by creating a centralized global RAM definition system that replaces local memory address aliases with globally defined canonical names.

### Centralization Architecture
The RAM centralization system operates on PRG bank $17/$18 assembly code with a four-stage process:

```mermaid
flowchart TD
Stage1["Alias Detection<br/>Find all local $04xx = $04XX definitions"] --> Stage2["Global Block Generation<br/>Create centralized RAM definition block"]
Stage2 --> Stage3["Local Definition Removal<br/>Remove local $04xx definitions from .proc blocks"]
Stage3 --> Stage4["Alias Renaming<br/>Replace old aliases with canonical names"]
Stage4 --> Output["Standardized Assembly Code"]
```

**Diagram sources**
- [tools/globalize_04xx.py:1-205](file://tools/globalize_04xx.py#L1-L205)

### Stage-by-Stage Breakdown

#### Stage 1: Alias Detection (build_alias_map)
- **Pattern Recognition**: Uses regex patterns to identify all local memory address alias definitions in the format `name = $04XX`
- **Address Validation**: Validates that detected addresses fall within the $04xx range and are included in the canonical mapping
- **Alias Collection**: Builds a comprehensive map of old alias names to their corresponding canonical names
- **Duplicate Handling**: Ensures that only unique aliases are processed, avoiding redundant operations

#### Stage 2: Global Block Generation (make_global_block)
- **Functional Grouping**: Organizes $04xx addresses into five logical functional groups based on their purpose and usage patterns
- **Canonical Name Application**: Applies the predefined canonical names to each address in the mapping
- **Comment Integration**: Adds descriptive comments explaining the function and context of each canonical name
- **Formatting Consistency**: Uses consistent formatting and spacing for easy reading and maintenance

#### Stage 3: Local Definition Removal
- **Scope Detection**: Identifies .proc/.endproc block boundaries to ensure proper scope management
- **Selective Removal**: Removes only local $04xx definitions that correspond to canonical addresses
- **Reference Tracking**: Counts and reports the number of local definitions removed
- **Scope Preservation**: Maintains proper scoping for non-canonical addresses and local variables

#### Stage 4: Alias Renaming
- **Pattern Matching**: Uses regex patterns with word boundaries to ensure complete replacement without partial matches
- **Whole-Word Replacement**: Replaces old alias names with canonical names while preserving local @-scoped references
- **Reference Counting**: Tracks and reports the number of references successfully renamed
- **Scope Awareness**: Preserves scoped references (e.g., `::name`, `@name`) that should not be globally replaced

### Functional Grouping Strategy
The system organizes $04xx addresses into five functional groups based on their role in the game's memory management:

#### Pointer/State ($0400-$0411)
- **Domestic Work Pointer**: `domestic_work_ptr_lo` and `domestic_work_ptr_hi` for domestic dispatch operations
- **Scroll Pointer**: `scroll_ptr_lo` and `scroll_ptr_hi` for scroll position management
- **Cursor Pointer**: `domestic_cursor_lo` and `domestic_cursor_hi` for domestic display navigation
- **Officer List Pointer**: `domestic_officer_list_lo` and `domestic_officer_list_hi` for officer selection lists

#### Officer/Selection ($0424-$0435)
- **Troop Assignment Counter**: `troop_assign_counter_lo` and `troop_assign_counter_hi` for troop assignment progress
- **Selected Officer ID**: `selected_officer_id` for active/selected officer identification
- **Battle Result Phase**: `battle_result_phase` for shared battle result processing
- **Dispatch Timer**: `dispatch_timer` for general dispatch timing
- **Menu Blink Timer**: `menu_blink_timer` for menu selection feedback

#### Map/Scroll Pointers ($0470-$0473)
- **Animation PPU Pointer**: `anim_ppu_ptr_lo` and `anim_ppu_ptr_hi` for animation display
- **Map Scroll Pointer**: `map_scroll_ptr_lo` and `map_scroll_ptr_hi` for map scrolling operations

#### Main Game State ($04A8-$04C0)
- **Game State**: `game_state` for major game state (0-14) indexing dispatch table
- **Sub-State**: `sub_state` for sub-state within each major state
- **Active Player Slot**: `active_player_slot` for current player index (0 or 1)
- **Player Flags**: `player_flag_0` for player 0 status
- **Player Officer IDs**: `player_officer_id_0` and `player_officer_id_1` for officer assignments
- **Name Tile Index**: `name_tile_index` for name tile and scroll tile data
- **Domestic Action Index**: `domestic_action_index` for domestic affairs actions
- **Player Army Values**: `player_army_value_0` and `player_army_value_1` for army statistics
- **Player Random Offsets**: `player_random_offset_0` for player 0 randomization
- **Player Action Timers**: `player_action_timer_0` for player action timing
- **Animation Timer**: `anim_timer` for general animation timing
- **Map Scroll Phase**: `map_scroll_phase` for map scrolling animation
- **Scroll Row Count**: `scroll_row_count` for scroll positioning
- **Slide Y Position**: `slide_y_pos` for slide animation positioning
- **Cutscene Load Progress**: `cutscene_load_progress` for cutscene loading
- **Display Pointer**: `display_ptr_lo` and `display_ptr_hi` for display management
- **Sub-Action Type**: `sub_action_type` for sub-action type selection
- **Frame Counter**: `frame_counter` for frame-based timing
- **Player Scene Index**: `player_scene_index` for per-player scene management
- **Event Overlay Flag**: `event_overlay_flag` for event overlay and battle formation
- **UI State**: `ui_state` for user interface state management
- **Name Tile Pointer**: `name_tile_ptr_lo` and `name_tile_ptr_hi` for name tile display

#### Extended State ($04C9-$04D5)
- **Dispatch Step**: `dispatch_step` for dispatch phase counting
- **Dispatch Source/Destination Pointers**: `dispatch_src_ptr_lo`/`dispatch_src_ptr_hi`, `dispatch_dst_ptr_lo`/`dispatch_dst_ptr_hi`
- **Dispatch Data/Offset Pointers**: `dispatch_data_ptr_lo`/`dispatch_data_ptr_hi`, `dispatch_offset_ptr_lo`/`dispatch_offset_ptr_hi`

### Integration with Build System
The RAM centralization system integrates seamlessly with the Makefile build system:
- **New**: make globalize_04xx target executes the complete RAM centralization workflow
- **New**: Direct tool execution: python3 tools/globalize_04xx.py
- **New**: Dry run mode: python3 tools/globalize_04xx.py --dry-run
- **New**: Custom input/output specification: python3 tools/globalize_04xx.py --input asm/banks/prg_17_18.asm --output asm/banks/prg_17_18_globalized.asm

The tool processes the assembly file in-place by default, but supports custom input/output paths for testing and validation purposes. The tool provides detailed logging of its operations, including the number of aliases detected, local definitions removed, and references renamed.

**Section sources**
- [tools/globalize_04xx.py:1-205](file://tools/globalize_04xx.py#L1-L205)

### Advanced RAM Centralization Features
The globalize_04xx.py tool provides several advanced features for comprehensive RAM standardization:

#### Canonical Name Mapping
- **Comprehensive Coverage**: Maps all $04xx addresses from $0400 to $04D5 to globally standardized names
- **Descriptive Naming**: Uses meaningful names that clearly indicate the purpose and usage context of each memory location
- **Comment Integration**: Adds explanatory comments to clarify the function and context of each canonical name
- **Well-Known Address Support**: Leverages predefined naming conventions for common memory locations

#### Scope Preservation
- **Local Reference Protection**: Preserves local @-scoped references and ::-scoped references that should not be globally replaced
- **Non-Canonical Address Handling**: Maintains local definitions for addresses not included in the canonical mapping
- **Proc Boundary Awareness**: Properly handles .proc/.endproc scope boundaries to avoid unintended global replacements

#### Functional Organization
- **Logical Grouping**: Organizes memory addresses into five functional groups based on their purpose and usage patterns
- **Consistent Formatting**: Uses consistent formatting and spacing for easy reading and maintenance
- **Documentation Integration**: Includes explanatory comments for each functional group and individual addresses

#### Error Handling and Validation
- **Pattern Validation**: Uses regex patterns with word boundaries to ensure accurate pattern matching
- **Reference Tracking**: Counts and reports the number of aliases detected, local definitions removed, and references renamed
- **Scope Verification**: Ensures proper handling of scope boundaries and preserves intended local references

**Section sources**
- [tools/globalize_04xx.py:13-132](file://tools/globalize_04xx.py#L13-L132)
- [tools/globalize_04xx.py:135-201](file://tools/globalize_04xx.py#L135-L201)

## ROM Analysis and Verification Tools

### Overview
The ROM analysis and verification toolkit provides dedicated tools for detailed byte-level ROM inspection, pattern matching, and cross-referencing. These tools complement the existing verification system by offering specialized analysis capabilities for ROM reconstruction and debugging.

### Analysis Tool Architecture
The ROM analysis toolkit consists of nine specialized tools that work together to provide comprehensive ROM verification and debugging capabilities:

```mermaid
flowchart TD
AT1["check_addresses.py<br/>Address verification"] --> AT2["check_bank18.py<br/>Bank validation"]
AT2 --> AT3["check_rom_offset.py<br/>Offset mapping"]
AT3 --> AT4["dump_chr_table.py<br/>CHR table inspection"]
AT4 --> AT5["dump_correct_bytes.py<br/>Correct bytes verification"]
AT5 --> AT6["search_0530.py<br/>$0530 pattern search"]
AT6 --> AT7["search_chr_loader.py<br/>CHR loader pattern"]
AT7 --> AT8["search_chr_loader2.py<br/>Specific CHR loader"]
AT8 --> AT9["verify_disasm.py<br/>Comprehensive verification"]
```

**Diagram sources**
- [tools/check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [tools/check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [tools/check_rom_offset.py:1-43](file://tools/check_rom_offset.py#L1-L43)
- [tools/dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [tools/dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [tools/search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [tools/search_chr_loader.py:1-15](file://tools/search_chr_loader.py#L1-L15)
- [tools/search_chr_loader2.py:1-21](file://tools/search_chr_loader2.py#L1-L21)
- [tools/verify_disasm.py:1-34](file://tools/verify_disasm.py#L1-L34)

### Individual Tool Analysis

#### check_addresses.py - Address Verification Tool
- **Purpose**: Verifies ROM bytes at specific disassembly addresses for accuracy
- **Functionality**: Reads ROM data from prg_17.bin and displays bytes at addresses $A8D3, $A944, and user-specified data table pointers
- **Address Mapping**: Converts disassembly addresses to ROM file offsets (e.g., $A8D3 -> offset $08D3)
- **Output Format**: Displays 16-byte chunks in hexadecimal format with CPU addresses
- **Use Case**: Validates that ROM bytes match expected disassembly at critical addresses

#### check_bank18.py - Bank Validation Tool
- **Purpose**: Validates bank $18 content and cross-checks with bank $17
- **Functionality**: Checks target byte sequences at specific offsets in prg_18.bin and prg_17.bin
- **Cross-Bank Verification**: Compares bank $18 content with expected patterns and validates combined bank layout
- **Target Bytes**: Searches for specific byte sequences (e.g., A0 00 AD 0D 00) to verify ROM structure
- **Combined Bank Analysis**: Validates combined bank layout where bank $17 occupies $0000-$1FFF and bank $18 occupies $2000-$3FFF

#### check_rom_offset.py - Offset Mapping Tool
- **Purpose**: Maps CPU addresses to ROM file offsets for verification
- **Functionality**: Calculates file offsets for CPU addresses within combined ROM structure
- **Bank Calculation**: Computes bank-specific offsets using standard 8KB bank sizing ($2000 bytes per bank)
- **Pattern Searching**: Searches for target byte sequences anywhere in the combined ROM
- **Verification Workflow**: Provides systematic approach to verify ROM address mappings

#### dump_chr_table.py - CHR Table Inspection Tool
- **Purpose**: Inspects CHR table data in combined ROM for verification
- **Functionality**: Dumps 256 bytes of ROM data centered around address $A8FD for detailed analysis
- **Context Analysis**: Provides broader context around specific CHR table addresses
- **Combined ROM Usage**: Works with prg_17_18_combined.bin for unified bank analysis
- **Verification Support**: Supports CHR loader verification and table structure analysis

#### dump_correct_bytes.py - Correct Bytes Verification Tool
- **Purpose**: Verifies correct bytes in ROM for disassembly validation
- **Functionality**: Dumps specific byte ranges from prg_17.bin and analyzes data table structures
- **Range Analysis**: Covers disassembly addresses $A8D3-$A988 with detailed byte-by-byte output
- **Data Table Processing**: Analyzes 10-byte entries in data tables with pointer extraction and address calculation
- **ASCII Representation**: Provides ASCII character representation alongside hexadecimal data

#### search_0530.py - $0530 Pattern Search Tool
- **Purpose**: Searches for $0530 store patterns in ROM for CHR loader identification
- **Functionality**: Searches for STA $0530 instructions (8D 30 05) and similar patterns (STA $0531)
- **Pattern Recognition**: Identifies specific store instructions targeting $0530/$0531 addresses
- **Context Display**: Shows instruction context around detected patterns for analysis
- **CHR Loader Support**: Aids in identifying CHR loading routines and data structures

#### search_chr_loader.py - CHR Loader Pattern Tool
- **Purpose**: Finds general CHR loader patterns in ROM
- **Functionality**: Searches for TAY followed by LDA absolute,Y instruction sequences
- **Pattern Matching**: Identifies TAY (A8) followed by LDA absolute,Y (B9) patterns
- **Loader Identification**: Supports identification of CHR loading routines using Y-indexed addressing
- **Instruction Context**: Displays instruction context for pattern analysis

#### search_chr_loader2.py - Specific CHR Loader Tool
- **Purpose**: Locates specific CHR loader with $0530/$0531 stores
- **Functionality**: Searches for complex pattern: TAY, LDA abs,Y, STA $0530, LDA abs,Y, STA $0531
- **Multi-Step Verification**: Identifies complete CHR loading sequences with specific store addresses
- **Pattern Validation**: Confirms complex instruction sequences for accurate loader identification
- **Address Verification**: Supports verification of CHR loader address patterns

#### verify_disasm.py - Comprehensive Disassembly Verification Tool
- **Purpose**: Provides comprehensive disassembly verification against ROM bytes
- **Functionality**: Checks multiple known addresses from disassembly for byte-level accuracy
- **Test Addresses**: Validates addresses $A8D3 (LDY #$00), $A8D5 (LDA a:$000D), $A8FD (PHA), $A8FE (LDY a:$0019), $A901 (LDA $0680,Y)
- **Multi-Address Testing**: Tests multiple addresses to ensure comprehensive disassembly accuracy
- **Context Verification**: Displays actual ROM bytes at target addresses for comparison

### Integration with Build System
The ROM analysis toolkit integrates seamlessly with the Makefile build system:
- **New**: make check_addresses target verifies ROM bytes at specific disassembly addresses.
- **New**: make check_bank18 target validates bank $18 content and cross-checks with bank $17.
- **New**: make check_rom_offset target maps CPU addresses to ROM file offsets for verification.
- **New**: make dump_chr_table target inspects CHR table data in combined ROM.
- **New**: make dump_correct_bytes target verifies correct bytes in ROM for disassembly validation.
- **New**: make search_0530 target searches for $0530 store patterns in ROM.
- **New**: make search_chr_loader target finds general CHR loader patterns in ROM.
- **New**: make search_chr_loader2 target locates specific CHR loader with $0530/$0531 stores.
- **New**: make verify_disasm target provides comprehensive disassembly verification.
- Each tool produces detailed logging and validation feedback for ROM debugging.
- Tools utilize ROM assets generated by make split and make banks targets.
- Results support iterative assembly and linking workflows for accurate ROM reconstruction.

**Section sources**
- [tools/check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [tools/check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [tools/check_rom_offset.py:1-43](file://tools/check_rom_offset.py#L1-L43)
- [tools/dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [tools/dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [tools/search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [tools/search_chr_loader.py:1-15](file://tools/search_chr_loader.py#L1-L15)
- [tools/search_chr_loader2.py:1-21](file://tools/search_chr_loader2.py#L1-L21)
- [tools/verify_disasm.py:1-34](file://tools/verify_disasm.py#L1-L34)

### Advanced Verification Workflows
The ROM analysis toolkit enables sophisticated verification workflows:

#### Byte-Level Verification Workflow
1. **Address Verification**: Use check_addresses.py to verify critical ROM addresses
2. **Bank Validation**: Use check_bank18.py to validate bank-specific content
3. **Offset Mapping**: Use check_rom_offset.py to verify CPU-to-file address mappings
4. **Pattern Search**: Use search_0530.py, search_chr_loader.py, and search_chr_loader2.py to identify specific ROM patterns
5. **Comprehensive Testing**: Use verify_disasm.py to test multiple addresses for accuracy

#### CHR Loader Verification Workflow
1. **Pattern Identification**: Use search_chr_loader.py and search_chr_loader2.py to locate CHR loaders
2. **Table Analysis**: Use dump_chr_table.py and dump_correct_bytes.py to analyze CHR table structures
3. **Address Validation**: Use check_addresses.py and verify_disasm.py to confirm ROM addresses
4. **Cross-Reference Validation**: Use check_bank18.py to validate bank-specific CHR loader content

#### Data Table Verification Workflow
1. **Table Location**: Use dump_correct_bytes.py to locate and analyze data tables
2. **Pointer Extraction**: Analyze 10-byte entries to extract and validate table pointers
3. **Address Calculation**: Verify calculated addresses against ROM content
4. **Pattern Matching**: Use search_0530.py to identify store patterns in data tables

**Section sources**
- [tools/check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [tools/check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [tools/check_rom_offset.py:1-43](file://tools/check_rom_offset.py#L1-L43)
- [tools/dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [tools/search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [tools/search_chr_loader.py:1-15](file://tools/search_chr_loader.py#L1-L15)
- [tools/search_chr_loader2.py:1-21](file://tools/search_chr_loader2.py#L1-L21)
- [tools/verify_disasm.py:1-34](file://tools/verify_disasm.py#L1-L34)

## Dependency Analysis
The build system exhibits clear separation of concerns:
- Makefile orchestrates tool invocations and manages dependencies between assembly, linking, and ROM packaging.
- Python tools encapsulate domain-specific tasks (ROM parsing, disassembly, analysis, annotation, verification).
- **New**: Unified disassembly pipeline provides specialized tools for different ROM regions with cross-bank reference handling.
- **New**: Enhanced transformation pipeline provides sophisticated tools for PRG bank $17/$18 assembly code organization with comprehensive .proc/.endproc boundary analysis, automated parameter naming, and RAM centralization.
- **New**: RAM centralization tool provides systematic approach to standardizing $04xx memory region definitions with centralized global RAM definitions.
- **New**: ROM analysis and verification toolkit provides dedicated tools for byte-level ROM inspection and pattern matching.
- Assembly sources depend on include headers for hardware and mapper definitions.
- Bank stubs and include files coordinate the assembly of multiple banks.
- **New**: Cross-dependencies between unified disassembly tools, enhanced transformation pipeline, RAM centralization tool, ROM analysis tools, and automated parameter declaration system for comprehensive ROM coverage.

```mermaid
graph TB
MK["Makefile"] --> CA["ca65"]
MK --> LD["ld65"]
MK --> BN["build_nes.py"]
MK --> VR["verify_rom.py"]
MK --> SP["split_rom.py"]
MK --> DS["disasm_6502.py"]
MK --> DS1F["disasm_bank_1f.py"]
MK --> GS["generate_bank_stubs.py"]
MK --> AZ["analyze_rom.py"]
MK --> AN["annotate_asm.py"]
MK --> UD1["disasm_17_18.py"]
MK --> UD2["fix_disasm.py"]
MK --> UD3["gen_f667_ffff.py"]
MK --> UD4["update_jsr_labels.py"]
MK --> UD5["verify_f3bd_f667.py"]
MK --> UD6["verify_range.py"]
MK --> TP1["transform_17_18.py"]
MK --> TP2["add_procs.py"]
MK --> TP3["analyze_17_18.py"]
MK --> TP4["debug_regions.py"]
MK --> TP5["proc_scope_17_18.py"]
MK --> TP6["localize_labels.py"]
MK --> TP7["auto_add_local_params.py"]
MK --> TP8["globalize_04xx.py"]
MK --> RA1["check_addresses.py"]
MK --> RA2["check_bank18.py"]
MK --> RA3["check_rom_offset.py"]
MK --> RA4["dump_chr_table.py"]
MK --> RA5["dump_correct_bytes.py"]
MK --> RA6["search_0530.py"]
MK --> RA7["search_chr_loader.py"]
MK --> RA8["search_chr_loader2.py"]
MK --> RA9["verify_disasm.py"]
M_main["asm/main.asm"] --> H_namco["include/namco163.h"]
M_main --> H_macros["include/macros.h"]
M_main --> H_functions["include/functions.h"]
M_main --> L_cfg["linker.cfg"]
AB["asm/banks/all_banks.asm"] --> M_main
UD1 --> UD2
UD2 --> UD3
UD3 --> UD4
UD4 --> UD5
UD5 --> UD6
TP1 --> TP2
TP2 --> TP3
TP3 --> TP4
TP4 --> TP5
TP5 --> TP6
TP6 --> TP7
TP7 --> TP8
TP8 --> Output["Enhanced Assembly Output"]
RA1 --> RA2
RA2 --> RA3
RA3 --> RA4
RA4 --> RA5
RA5 --> RA6
RA6 --> RA7
RA7 --> RA8
RA8 --> RA9
```

**Diagram sources**
- [Makefile:31-101](file://Makefile#L31-L101)
- [tools/build_nes.py:10-51](file://tools/build_nes.py#L10-L51)
- [tools/verify_rom.py:10-69](file://tools/verify_rom.py#L10-L69)
- [tools/split_rom.py:38-122](file://tools/split_rom.py#L38-L122)
- [tools/disasm_6502.py:286-362](file://tools/disasm_6502.py#L286-L362)
- [tools/disasm_bank_1f.py:329-442](file://tools/disasm_bank_1f.py#L329-L442)
- [tools/generate_bank_stubs.py:12-46](file://tools/generate_bank_stubs.py#L12-L46)
- [tools/analyze_rom.py:10-128](file://tools/analyze_rom.py#L10-L128)
- [tools/annotate_asm.py:315-478](file://tools/annotate_asm.py#L315-L478)
- [tools/disasm_17_18.py:1-710](file://tools/disasm_17_18.py#L1-L710)
- [tools/fix_disasm.py:1-56](file://tools/fix_disasm.py#L1-L56)
- [tools/gen_f667_ffff.py:1-396](file://tools/gen_f667_ffff.py#L1-L396)
- [tools/update_jsr_labels.py:1-137](file://tools/update_jsr_labels.py#L1-L137)
- [tools/verify_f3bd_f667.py:1-45](file://tools/verify_f3bd_f667.py#L1-L45)
- [tools/verify_range.py:1-42](file://tools/verify_range.py#L1-L42)
- [tools/transform_17_18.py:1-348](file://tools/transform_17_18.py#L1-L348)
- [tools/add_procs.py:1-189](file://tools/add_procs.py#L1-L189)
- [tools/analyze_17_18.py:1-118](file://tools/analyze_17_18.py#L1-L118)
- [tools/debug_regions.py:1-98](file://tools/debug_regions.py#L1-L98)
- [tools/proc_scope_17_18.py:1-813](file://tools/proc_scope_17_18.py#L1-L813)
- [tools/localize_labels.py:1-526](file://tools/localize_labels.py#L1-L526)
- [tools/auto_add_local_params.py:1-416](file://tools/auto_add_local_params.py#L1-L416)
- [tools/globalize_04xx.py:1-205](file://tools/globalize_04xx.py#L1-L205)
- [tools/check_addresses.py:1-33](file://tools/check_addresses.py#L1-L33)
- [tools/check_bank18.py:1-50](file://tools/check_bank18.py#L1-L50)
- [tools/check_rom_offset.py:1-43](file://tools/check_rom_offset.py#L1-L43)
- [tools/dump_chr_table.py:1-13](file://tools/dump_chr_table.py#L1-L13)
- [tools/dump_correct_bytes.py:1-35](file://tools/dump_correct_bytes.py#L1-L35)
- [tools/search_0530.py:1-23](file://tools/search_0530.py#L1-L23)
- [tools/search_chr_loader.py:1-15](file://tools/search_chr_loader.py#L1-L15)
- [tools/search_chr_loader2.py:1-21](file://tools/search_chr_loader2.py#L1-L21)
- [tools/verify_disasm.py:1-34](file://tools/verify_disasm.py#L1-L34)

**Section sources**
- [Makefile:31-101](file://Makefile#L31-L101)
- [PROJECT.md:14-47](file://PROJECT.md#L14-L47)

## Performance Considerations
- Disassembly and annotation operate on 8KB banks; keep input binaries small and targeted for faster iteration.
- The verification step compares entire ROMs; ensure original and rebuilt files are present and sized correctly to avoid unnecessary overhead.
- Linker segmentation should be kept minimal until needed to reduce linking complexity and runtime.
- Enhanced disassembly tools provide more detailed output but may require additional processing time for complex bank analysis.
- **New**: Unified disassembly pipeline processes multiple ROM regions with sophisticated algorithms; expect significant processing time for large assembly files.
- **New**: Enhanced transformation pipeline applies multiple passes with detailed analysis and advanced boundary detection; expect substantial processing time for PRG bank $17/$18 assembly code.
- **New**: Automated parameter declaration tool processes entire .proc blocks with comprehensive address analysis; expect processing time proportional to code complexity and parameter count.
- **New**: RAM centralization tool processes entire assembly files with comprehensive alias detection and replacement; expect processing time proportional to code complexity and alias count.
- **New**: ROM analysis toolkit provides specialized tools for detailed byte-level inspection; expect processing time proportional to ROM size and search scope.
- **New**: Each disassembly, transformation, and analysis stage provides detailed logging; use make targets with verbose output to monitor progress during long-running operations.
- **New**: Advanced .proc/.endproc organization with boundary analysis requires additional processing time but provides optimal code structure and maintainability.
- **New**: Localized label conversion adds another processing stage but significantly improves code readability and maintainability.
- **New**: Automated parameter declaration system requires comprehensive address analysis but provides systematic parameter naming improvements.
- **New**: RAM centralization system requires comprehensive alias detection and replacement but provides standardized memory definitions across the codebase.
- **New**: Pattern searching tools may require scanning entire ROM files; consider performance implications for large ROM images.

## Troubleshooting Guide
Common issues and resolutions:
- Missing toolchain: Ensure ca65 and ld65 are installed and on PATH. The Makefile expects them under ~/.local/bin/.
- Missing ROM assets: Run make split to generate rom/prg/ and rom/chr/ banks and rom_info.h.
- Bank stubs not included: Run make banks to generate asm/banks/*.asm and include all_banks.asm.
- Verification fails due to size mismatch: Confirm both ROMs are padded to the same size; build_nes.py pads PRG to 16KB pages.
- Disassembly address drift: Use annotate_asm.py with address hints in assembly comments to resynchronize.
- Linker errors: Update linker.cfg with new segments as banks are disassembled; ensure segments map to correct PRG slots.
- Enhanced disassembly output issues: Ensure proper base address mapping and inline comment formatting for accurate analysis.
- **New**: Unified disassembly pipeline failures: Check individual stage logs in the terminal output; each stage prints detailed progress and error information.
- **New**: Enhanced transformation pipeline failures: Check individual stage logs for transform_17_18.py, add_procs.py, analyze_17_18.py, debug_regions.py, proc_scope_17_18.py, localize_labels.py, auto_add_local_params.py, and globalize_04xx.py.
- **New**: Cross-bank reference issues: Verify that fix_disasm.py has been run to enhance disasm_17_18.py output.
- **New**: Address-to-symbol mapping failures: Ensure functions.h contains proper address-to-symbol mappings for $E000-$FFFF.
- **New**: Range verification failures: Check that verify_f3bd_f667.py and verify_range.py are run with correct file paths and address ranges.
- **New**: Semantic naming conflicts: Ensure transform_17_18.py runs before add_procs.py to avoid naming conflicts.
- **New**: .proc/.endproc boundary issues: Use proc_scope_17_18.py for advanced boundary analysis and optimization.
- **New**: Localized label conversion failures: Check that localize_labels.py runs after proc_scope_17_18.py to ensure proper label classification.
- **New**: Automated parameter declaration failures: Verify that auto_add_local_params.py runs after proc_scope_17_18.py to ensure proper parameter insertion.
- **New**: Parameter naming conflicts: Check that auto_add_local_params.py handles well-known address collisions properly.
- **New**: RAM centralization failures: Verify that globalize_04xx.py runs after proc_scope_17_18.py to ensure proper alias detection and replacement.
- **New**: Alias replacement issues: Check that globalize_04xx.py properly handles @-scoped and ::-scoped references.
- **New**: ROM analysis tool failures: Verify ROM files exist in rom/prg/ directory; check file permissions and sizes.
- **New**: Address verification issues: Ensure check_addresses.py uses correct ROM file paths and address mappings.
- **New**: Pattern search failures: Verify ROM files contain expected patterns; adjust search parameters if needed.
- **New**: Offset mapping errors: Check bank sizing assumptions (8KB per bank) and CPU address calculations.
- **New**: CHR loader identification problems: Use multiple search tools (search_chr_loader.py, search_chr_loader2.py) for comprehensive pattern detection.

Practical examples:
- Disassemble a specific bank region: make disasm FILE=rom/prg/prg_1f.bin ADDR=E000 LEN=256
- Analyze ROM structure: make analyze
- Verify rebuilt ROM: make verify
- **New**: Apply unified disassembly: make disasm_17_18
- **New**: Generate Bank $1F range disassembly: make gen_f667_ffff
- **New**: Update JSR labels: make update_jsr_labels
- **New**: Verify specific range: make verify_f3bd_f667
- **New**: Transform PRG bank $17/$18: make transform_17_18
- **New**: Add basic procedure scoping: make add_procs
- **New**: Analyze boundaries: make analyze_17_18
- **New**: Debug regions: make debug_regions
- **New**: Enhanced .proc/.endproc organization: make proc_scope_17_18
- **New**: Localized label conversion: make localize_labels
- **New**: Automated parameter declaration: make auto_add_local_params
- **New**: RAM centralization: make globalize_04xx
- **New**: Transform specific stage: python3 tools/transform_17_18.py, python3 tools/add_procs.py, etc.
- **New**: Advanced boundary analysis: python3 tools/proc_scope_17_18.py
- **New**: Localized label conversion: python3 tools/localize_labels.py
- **New**: Automated parameter declaration: python3 tools/auto_add_local_params.py
- **New**: RAM centralization: python3 tools/globalize_04xx.py
- **New**: Address verification: make check_addresses
- **New**: Bank validation: make check_bank18
- **New**: Offset mapping: make check_rom_offset
- **New**: CHR table inspection: make dump_chr_table
- **New**: Correct bytes verification: make dump_correct_bytes
- **New**: $0530 pattern search: make search_0530
- **New**: CHR loader pattern search: make search_chr_loader
- **New**: Specific CHR loader search: make search_chr_loader2
- **New**: Comprehensive disassembly verification: make verify_disasm
- **New**: Direct tool execution: python3 tools/check_addresses.py, python3 tools/check_bank18.py, etc.
- **New**: RAM centralization: python3 tools/globalize_04xx.py --input asm/banks/prg_17_18.asm --output asm/banks/prg_17_18_globalized.asm
- Generate enhanced Bank 0x1F disassembly: python3 tools/disasm_bank_1f.py rom/prg/prg_1f.bin
- Clean build artifacts: make clean
- Clean and remove ROM dumps: make distclean

**Section sources**
- [Makefile:51-101](file://Makefile#L51-L101)
- [tools/verify_rom.py:22-51](file://tools/verify_rom.py#L22-L51)
- [tools/annotate_asm.py:357-404](file://tools/annotate_asm.py#L357-L404)
- [tools/split_rom.py:124-139](file://tools/split_rom.py#L124-L139)

## Conclusion
The Sango2Dasm build system integrates cc65 assembly/linking with a robust set of Python tools to support ROM disassembly, analysis, annotation, and verification. The recent addition of the comprehensive unified disassembly pipeline provides unprecedented automation for different ROM regions, featuring six specialized tools that work together to provide cross-bank reference handling, address-to-symbol mapping, and region-specific disassembly capabilities. The newly enhanced transformation pipeline extends this automation to PRG bank $17/$18 assembly code with sophisticated semantic naming conventions, comprehensive .proc/.endproc organization, advanced boundary analysis capabilities, and the new automated parameter declaration system. The latest additions include proc_scope_17_18.py for enhanced .proc/.endproc organization, localize_labels.py for converting branch-only labels to @local format, auto_add_local_params.py for systematic parameter naming in assembly code, and globalize_04xx.py for centralized RAM definition standardization, significantly improving code readability and maintainability. The newly integrated ROM analysis and verification toolkit provides dedicated tools for detailed byte-level ROM inspection, pattern matching, and cross-referencing, enabling comprehensive ROM reconstruction and validation workflows. The Makefile provides a unified interface to orchestrate the complete pipeline, while tools like split_rom.py, disasm_6502.py, disasm_bank_1f.py, the unified disassembly tools, the enhanced transformation pipeline tools, the RAM centralization tool, the ROM analysis toolkit, and the improved verification system enable comprehensive ROM reconstruction and validation. By following the documented targets and procedures, developers can efficiently reconstruct and validate the ROM while maintaining byte-exact fidelity and ensuring clean, maintainable assembly code with proper cross-bank reference handling, semantic naming conventions, optimized .proc/.endproc organization, systematic parameter naming, centralized RAM definitions, and comprehensive ROM analysis capabilities.

## Appendices

### Practical Workflows
- Initial setup: make split, make banks
- Enhanced disassembly: make disasm, tools/disasm_bank_1f.py, tools/annotate_asm.py
- **New**: Unified disassembly: make disasm_17_18, make gen_f667_ffff, make update_jsr_labels
- **New**: Range verification: make verify_f3bd_f667, make verify_range
- **New**: Enhanced transformation pipeline: make transform_17_18, make add_procs, make analyze_17_18, make debug_regions, make proc_scope_17_18, make localize_labels, make auto_add_local_params
- **New**: RAM centralization workflow: make globalize_04xx
- **New**: ROM analysis workflow: make check_addresses, make check_bank18, make check_rom_offset, make dump_chr_table, make dump_correct_bytes, make search_0530, make search_chr_loader, make search_chr_loader2, make verify_disasm
- Iterative assembly: make, make verify
- Cleanup: make clean, make distclean

### Example Commands
- make disasm FILE=rom/prg/prg_1f.bin ADDR=E000 LEN=1024
- make analyze
- make verify
- **New**: make disasm_17_18
- **New**: make gen_f667_ffff
- **New**: make update_jsr_labels
- **New**: make verify_f3bd_f667
- **New**: make verify_range
- **New**: make transform_17_18
- **New**: make add_procs
- **New**: make analyze_17_18
- **New**: make debug_regions
- **New**: make proc_scope_17_18
- **New**: make localize_labels
- **New**: make auto_add_local_params
- **New**: make globalize_04xx
- **New**: make check_addresses
- **New**: make check_bank18
- **New**: make check_rom_offset
- **New**: make dump_chr_table
- **New**: make dump_correct_bytes
- **New**: make search_0530
- **New**: make search_chr_loader
- **New**: make search_chr_loader2
- **New**: make verify_disasm
- **New**: python3 tools/transform_17_18.py
- **New**: python3 tools/add_procs.py
- **New**: python3 tools/analyze_17_18.py
- **New**: python3 tools/debug_regions.py
- **New**: python3 tools/proc_scope_17_18.py
- **New**: python3 tools/localize_labels.py
- **New**: python3 tools/auto_add_local_params.py
- **New**: python3 tools/globalize_04xx.py
- **New**: python3 tools/check_addresses.py
- **New**: python3 tools/check_bank18.py
- **New**: python3 tools/check_rom_offset.py
- **New**: python3 tools/dump_chr_table.py
- **New**: python3 tools/dump_correct_bytes.py
- **New**: python3 tools/search_0530.py
- **New**: python3 tools/search_chr_loader.py
- **New**: python3 tools/search_chr_loader2.py
- **New**: python3 tools/verify_disasm.py
- **New**: python3 tools/transform_17_18.py --dry-run
- **New**: python3 tools/proc_scope_17_18.py --dry-run
- **New**: python3 tools/localize_labels.py --dry-run
- **New**: python3 tools/auto_add_local_params.py --input asm/banks/prg_17_18.asm --output asm/banks/prg_17_18_auto.asm
- **New**: python3 tools/globalize_04xx.py --input asm/banks/prg_17_18.asm --output asm/banks/prg_17_18_globalized.asm
- **New**: python3 tools/add_procs.py asm/banks/prg_17_18.asm
- **New**: python3 tools/analyze_17_18.py
- **New**: python3 tools/debug_regions.py
- **New**: python3 tools/proc_scope_17_18.py
- **New**: python3 tools/localize_labels.py
- **New**: python3 tools/auto_add_local_params.py
- **New**: python3 tools/globalize_04xx.py
- **New**: python3 tools/check_addresses.py --address $A8D3
- **New**: python3 tools/check_bank18.py --offset $08D3
- **New**: python3 tools/check_rom_offset.py --cpu $A8D3
- **New**: python3 tools/dump_chr_table.py --range 256
- **New**: python3 tools/dump_correct_bytes.py --start $08D3 --end $0988
- **New**: python3 tools/search_0530.py --pattern 8D3005
- **New**: python3 tools/search_chr_loader.py --pattern A8B9
- **New**: python3 tools/search_chr_loader2.py --pattern A8B98D3005B98D3105
- **New**: python3 tools/verify_disasm.py --addresses A8D3,A8D5,A8FD,A8FE,A901
- python3 tools/disasm_bank_1f.py rom/prg/prg_1f.bin
- python3 tools/annotate_asm.py --in-place --verify