# Data Structure Layouts

<cite>
**Referenced Files in This Document**
- [bank_1f_analysis.md](file://code/bank_1f_analysis.md)
- [key_functions_analysis.md](file://code/key_functions_analysis.md)
- [bank_1f_function_table.md](file://code/bank_1f_function_table.md)
- [prg_1f.asm](file://asm/banks/prg_1f.asm)
- [bank_1f_plan.md](file://code/bank_1f_plan.md)
- [bank_1f_raw.asm](file://code/bank_1f_raw.asm)
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
This document describes the data structure layouts discovered in the game’s memory, focusing on how entities are laid out and accessed. It covers:
- Heroes, Cities, Kata Names, Hero Initial Data, and Kingdoms
- The pointer table used for Kingdom data and why it differs from other entities
- The random number table and its sequential access pattern
- SRAM usage for persistent save data and its battery-backed nature
- How these structures are accessed through the data access functions and how entity IDs map to memory offsets

## Project Structure
The relevant analysis and assembly sources are primarily located in:
- Bank 0x1F (boot bank) containing state dispatch, NMI/IRQ handlers, sound engine, and data access functions
- Assembly sources that define the address calculation procedures and data tables
- Function tables and analyses that enumerate and summarize the data access routines

```mermaid
graph TB
subgraph "Bank 0x1F (Boot)"
A["Reset Handler<br/>$E000"]
B["Vector Dispatch<br/>$E07C-$E099"]
C["State Handlers<br/>$E09A-$E4D9"]
D["Data Access Functions<br/>$F2AF-$F3BC"]
E["RNG Core<br/>$E87A"]
F["RNG Table<br/>$E8BA"]
end
subgraph "PRG Banks"
G["Hero Data<br/>$6000 + id*32"]
H["City Data<br/>$63C0 + id*12"]
I["Kata Name Data<br/>$901A + id*10"]
J["Hero Initial Data<br/>$8000 + id*12"]
K["Kingdom Data (SRAM)<br/>$6F07 + id*8"]
end
D --> G
D --> H
D --> I
D --> J
D --> K
E --> F
```

**Diagram sources**
- [bank_1f_analysis.md:12-111](file://code/bank_1f_analysis.md#L12-L111)
- [bank_1f_function_table.md:79-85](file://code/bank_1f_function_table.md#L79-L85)
- [prg_1f.asm:2328-2472](file://asm/banks/prg_1f.asm#L2328-L2472)

**Section sources**
- [bank_1f_analysis.md:12-111](file://code/bank_1f_analysis.md#L12-L111)
- [bank_1f_function_table.md:79-85](file://code/bank_1f_function_table.md#L79-L85)
- [prg_1f.asm:2328-2472](file://asm/banks/prg_1f.asm#L2328-L2472)

## Core Components
This section summarizes the five primary data structures and their access patterns.

- Heroes
  - Entry size: 32 bytes
  - Base address: $6000
  - Access formula: hero_id * 32 + $6000
  - Access function: $F2AF

- Cities
  - Entry size: 12 bytes
  - Base address: $63C0
  - Access formula: city_id * 12 + $63C0
  - Access function: $F2D7

- Kata Names
  - Entry size: 10 bytes
  - Base address: $901A
  - Access formula: id * 10 + $901A
  - Access function: $F308

- Hero Initial Data
  - Entry size: 12 bytes
  - Base address: $8000
  - Access formula: hero_id * 12 + $8000
  - Access function: $F387

- Kingdoms (Persistent Save)
  - Entry size: 8 bytes
  - Base address: $6F07 (SRAM)
  - Access method: Pointer table at $F379 (indirect addressing)
  - Access function: $F368

**Section sources**
- [key_functions_analysis.md:33-284](file://code/key_functions_analysis.md#L33-L284)
- [bank_1f_function_table.md:79-85](file://code/bank_1f_function_table.md#L79-L85)
- [prg_1f.asm:2328-2472](file://asm/banks/prg_1f.asm#L2328-L2472)

## Architecture Overview
The game uses bank-switched PRG memory for most data tables. The data access functions compute a 16-bit pointer into banked memory and return it in $0000/$0001 for subsequent indirect reads/writes. Kingdom data is stored in battery-backed SRAM at $6F07 and accessed via a pointer table rather than a simple multiply-plus-offset scheme.

```mermaid
sequenceDiagram
participant Caller as "Caller"
participant Func as "Get*Addr Function"
participant Bank as "Banked PRG"
participant RAM as "Working RAM"
Caller->>Func : Pass entity ID in A
Func->>Func : Compute offset (multiply/shift/add)
Func->>Func : Add base high/low bytes
Func->>RAM : Store pointer in $0000/$0001
Func-->>Caller : RTS (pointer ready)
Caller->>Bank : Indirect read/write via ($0000)
Bank-->>Caller : Data loaded/stored
```

**Diagram sources**
- [prg_1f.asm:2328-2472](file://asm/banks/prg_1f.asm#L2328-L2472)
- [key_functions_analysis.md:33-284](file://code/key_functions_analysis.md#L33-L284)

## Detailed Component Analysis

### Heroes (32 bytes per entry, $6000 base)
- Access function: $F2AF
- Computation: 5 shifts to multiply by 32, plus base $6000
- Entry size: 32 bytes
- Typical usage: Iterate heroes by ID, read stats and attributes from the computed offset

```mermaid
flowchart TD
Start(["Call GetHeroAddr"]) --> SaveID["Save hero_id in A"]
SaveID --> Shifts["Shift left 5 times (x32)"]
Shifts --> AddLo["Add low base ($00)"]
AddLo --> SetLo["Store low pointer"]
SetLo --> Carry["Capture high carry"]
Carry --> AddHi["Add high base ($60) + carry"]
AddHi --> SetHi["Store high pointer"]
SetHi --> End(["Return pointer in $0000/$0001"])
```

**Diagram sources**
- [prg_1f.asm:2333-2354](file://asm/banks/prg_1f.asm#L2333-L2354)
- [key_functions_analysis.md:33-63](file://code/key_functions_analysis.md#L33-L63)

**Section sources**
- [prg_1f.asm:2328-2355](file://asm/banks/prg_1f.asm#L2328-L2355)
- [key_functions_analysis.md:33-63](file://code/key_functions_analysis.md#L33-L63)

### Cities (12 bytes per entry, $63C0 base)
- Access function: $F2D7
- Computation: id * 3 = (id * 2 + id), then multiply by 12 using shifts and adds, plus base $63C0
- Entry size: 12 bytes
- Typical usage: Iterate cities, read location and production data

```mermaid
flowchart TD
Start(["Call GetCityAddr"]) --> SaveID["Save city_id in A"]
SaveID --> Mul3["Compute id * 3"]
Mul3 --> Mul12["Compute id * 12 (shifts)"]
Mul12 --> AddLo["Add low base ($C0)"]
AddLo --> SetLo["Store low pointer"]
SetLo --> Carry["Capture high carry"]
Carry --> AddHi["Add high base ($63) + carry"]
AddHi --> SetHi["Store high pointer"]
SetHi --> End(["Return pointer in $0000/$0001"])
```

**Diagram sources**
- [prg_1f.asm:2363-2381](file://asm/banks/prg_1f.asm#L2363-L2381)
- [key_functions_analysis.md:66-100](file://code/key_functions_analysis.md#L66-L100)

**Section sources**
- [prg_1f.asm:2358-2382](file://asm/banks/prg_1f.asm#L2358-L2382)
- [key_functions_analysis.md:66-100](file://code/key_functions_analysis.md#L66-L100)

### Kata Names (10 bytes per entry, $901A base)
- Access function: $F308
- Computation: id * 10 = (id * 2) << 2 + id << 1, plus base $901A
- Entry size: 10 bytes
- Additional behavior: Scans string, skipping specific markers, then returns display width from a small width table

```mermaid
flowchart TD
Start(["Call GetHeroKataName"]) --> SaveID["Save id in A"]
SaveID --> Mul10["Compute id * 10"]
Mul10 --> AddLo["Add low base ($1A)"]
AddLo --> SetLo["Store low pointer"]
SetLo --> AddHi["Add high base ($90)"]
AddHi --> SetHi["Store high pointer"]
SetHi --> Scan["Scan string (skip markers)"]
Scan --> Width["Load display width from table"]
Width --> End(["Return pointer and width"])
```

**Diagram sources**
- [prg_1f.asm:2390-2414](file://asm/banks/prg_1f.asm#L2390-L2414)
- [key_functions_analysis.md:103-156](file://code/key_functions_analysis.md#L103-L156)

**Section sources**
- [prg_1f.asm:2384-2415](file://asm/banks/prg_1f.asm#L2384-L2415)
- [key_functions_analysis.md:103-156](file://code/key_functions_analysis.md#L103-L156)

### Hero Initial Data (12 bytes per entry, $8000 base)
- Access function: $F387
- Computation: id * 12 (multiply by 3, then by 4), plus base $8000
- Entry size: 12 bytes
- Typical usage: Initialize hero stats and traits at game start

```mermaid
flowchart TD
Start(["Call GetHeroInitialData"]) --> SaveID["Save hero_id in A"]
SaveID --> Mul3["Compute id * 3"]
Mul3 --> Mul12["Compute id * 12 (shifts)"]
Mul12 --> AddLo["Add low base ($00)"]
AddLo --> SetLo["Store low pointer"]
SetLo --> Carry["Capture high carry"]
Carry --> AddHi["Add high base ($80) + carry"]
AddHi --> SetHi["Store high pointer"]
SetHi --> End(["Return pointer in $0000/$0001"])
```

**Diagram sources**
- [prg_1f.asm:2454-2471](file://asm/banks/prg_1f.asm#L2454-L2471)
- [key_functions_analysis.md:192-228](file://code/key_functions_analysis.md#L192-L228)

**Section sources**
- [prg_1f.asm:2450-2472](file://asm/banks/prg_1f.asm#L2450-L2472)
- [key_functions_analysis.md:192-228](file://code/key_functions_analysis.md#L192-L228)

### Kingdoms (8 bytes per entry, SRAM at $6F07, pointer table)
- Access function: $F368
- Pointer table: $F379 contains 7 entries, each 2 bytes, pointing to offsets in SRAM
- Entry size: 8 bytes per kingdom
- SRAM base: $6F07
- Access pattern: AND id to 0-15, ASL for word index, fetch 2-byte pointer from table, return pointer in $0000/$0001

```mermaid
sequenceDiagram
participant Caller as "Caller"
participant Func as "GetKingdomAddr"
participant Table as "KingdomPtrTable ($F379)"
participant SRAM as "SRAM ($6F07..)"
Caller->>Func : kingdom_id in A
Func->>Func : AND #$0F (mask 0-15)
Func->>Func : ASL (index * 2)
Func->>Table : Fetch 2-byte pointer
Table-->>Func : Low/High bytes
Func->>SRAM : Return pointer to SRAM offset
SRAM-->>Caller : Data loaded/stored
```

**Diagram sources**
- [prg_1f.asm:2427-2441](file://asm/banks/prg_1f.asm#L2427-L2441)
- [prg_1f.asm:2446-2447](file://asm/banks/prg_1f.asm#L2446-L2447)
- [key_functions_analysis.md:159-189](file://code/key_functions_analysis.md#L159-L189)

**Section sources**
- [prg_1f.asm:2424-2448](file://asm/banks/prg_1f.asm#L2424-L2448)
- [key_functions_analysis.md:159-189](file://code/key_functions_analysis.md#L159-L189)

### Why Kingdoms Use a Pointer Table
- Other entities use a simple formula: id * stride + base address
- Kingdoms use a pointer table because:
  - Data is stored in battery-backed SRAM, not bank-switched PRG ROM
  - The table allows flexible offsets within SRAM without requiring a fixed stride across all entries
  - It supports potential sparse or variable-length entries within SRAM

**Section sources**
- [key_functions_analysis.md:186-189](file://code/key_functions_analysis.md#L186-L189)
- [bank_1f_analysis.md:146-159](file://code/bank_1f_analysis.md#L146-L159)

### Random Number Table and Sequential Access
- RNG core: $E87A performs a table lookup using an index at $0050
- Sequential access pattern: Each call reads the next byte from a pre-computed table at $E8BA and increments the index
- Variants: Separate RNG instances use $0052/$0054/$0055 for independent streams

```mermaid
flowchart TD
Start(["Call RandomByte ($E87A)"]) --> SaveX["Save X register"]
SaveX --> LoadIdx["Load RNG index ($0050)"]
LoadIdx --> Fetch["Fetch byte from RandomTable ($E8BA + index)"]
Fetch --> IncIdx["Increment index"]
IncIdx --> RestoreX["Restore X register"]
RestoreX --> Return(["Return byte in A"])
```

**Diagram sources**
- [bank_1f_plan.md:65-78](file://code/bank_1f_plan.md#L65-L78)
- [bank_1f_raw.asm:1994-2010](file://code/bank_1f_raw.asm#L1994-L2010)
- [key_functions_analysis.md:9-31](file://code/key_functions_analysis.md#L9-L31)

**Section sources**
- [bank_1f_plan.md:65-78](file://code/bank_1f_plan.md#L65-L78)
- [bank_1f_raw.asm:1994-2010](file://code/bank_1f_raw.asm#L1994-L2010)
- [key_functions_analysis.md:9-31](file://code/key_functions_analysis.md#L9-L31)

### SRAM Usage and Battery-Backed Nature
- Kingdom initialization writes parameters to SRAM locations $6F41 and $6F3F during new game initialization
- SRAM flag is written at $6F8B under certain conditions
- Palette swap logic references SRAM at $6F44 for palette exchange decisions
- These accesses confirm SRAM usage for persistent save data

```mermaid
sequenceDiagram
participant State as "New Game Init"
participant RAM as "Work RAM"
participant SRAM as "SRAM ($6Fxx)"
State->>RAM : Prepare parameters
RAM->>SRAM : Write $6F41, $6F3F
RAM->>SRAM : Optionally write $6F8B
SRAM-->>State : Data retained across power cycles (battery-backed)
```

**Diagram sources**
- [bank_1f_analysis.md:146-159](file://code/bank_1f_analysis.md#L146-L159)
- [prg_1f.asm:245-266](file://asm/banks/prg_1f.asm#L245-L266)

**Section sources**
- [bank_1f_analysis.md:146-159](file://code/bank_1f_analysis.md#L146-L159)
- [prg_1f.asm:245-266](file://asm/banks/prg_1f.asm#L245-L266)

## Dependency Analysis
The data access functions depend on:
- Bank-switched PRG memory for most tables
- Working RAM for intermediate pointer storage
- SRAM for persistent kingdom data
- RNG for procedural generation and events

```mermaid
graph LR
F1["GetHeroAddr ($F2AF)"] --> T1["Hero Data ($6000+)"]
F2["GetCityAddr ($F2D7)"] --> T2["City Data ($63C0+)"]
F3["GetHeroKataName ($F308)"] --> T3["Kata Names ($901A+)"]
F4["GetHeroInitialData ($F387)"] --> T4["Hero Initial Data ($8000+)"]
F5["GetKingdomAddr ($F368)"] --> T5["Kingdom Data (SRAM $6F07+)"]
RNG["RandomByte ($E87A)"] --> RT["RandomTable ($E8BA)"]
```

**Diagram sources**
- [bank_1f_function_table.md:79-85](file://code/bank_1f_function_table.md#L79-L85)
- [prg_1f.asm:2328-2472](file://asm/banks/prg_1f.asm#L2328-L2472)
- [bank_1f_plan.md:65-78](file://code/bank_1f_plan.md#L65-L78)

**Section sources**
- [bank_1f_function_table.md:79-85](file://code/bank_1f_function_table.md#L79-L85)
- [prg_1f.asm:2328-2472](file://asm/banks/prg_1f.asm#L2328-L2472)
- [bank_1f_plan.md:65-78](file://code/bank_1f_plan.md#L65-L78)

## Performance Considerations
- Multiplication by powers of 2 is implemented via 6502 shifts, minimizing overhead
- Sequential RNG avoids expensive arithmetic, trading determinism for speed
- Bank switching is minimized by grouping related operations and reusing bank configurations
- Pointer tables reduce branching and enable fast indirect addressing for SRAM data

## Troubleshooting Guide
- If accessing Kingdom data yields unexpected results:
  - Verify the kingdom_id is masked to 0-15 before indexing the pointer table
  - Ensure SRAM is powered and readable
- If entity data appears offset:
  - Confirm the correct base address and entry size for the entity type
  - Ensure the proper bank is selected before indirect access
- If RNG behavior seems predictable:
  - Confirm the index at $0050 advances as expected
  - Check for separate RNG instances if multiple streams are used

**Section sources**
- [key_functions_analysis.md:159-189](file://code/key_functions_analysis.md#L159-L189)
- [bank_1f_analysis.md:146-159](file://code/bank_1f_analysis.md#L146-L159)

## Conclusion
The game employs a consistent pattern for entity data access: simple multiply-plus-offset formulas for bank-switched PRG tables and a pointer table for SRAM-based persistent data. The RNG uses a pre-computed table for deterministic sequential access. Understanding these patterns enables safe and efficient manipulation of game state across entities and persistence layers.