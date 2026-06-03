# State Procedures

<cite>
**Referenced Files in This Document**
- [PROJECT.md](file://PROJECT.md)
- [prg_1f.aligned.asm](file://asm/banks/prg_1f.aligned.asm)
- [prg_1f.asm.bak](file://asm/banks/prg_1f.asm.bak)
- [namco163.h](file://include/namco163.h)
- [macros.h](file://include/macros.h)
- [bank_1f_raw.asm](file://code/bank_1f_raw.asm)
- [bank_1f_plan.md](file://code/bank_1f_plan.md)
</cite>

## Update Summary
**Changes Made**
- Enhanced dual-player controller support documentation with new pad2 addresses (addr_pad2_edge, addr_pad2_raw, addr_pad2_prev)
- Updated all state handlers from State_SystemInit to State_TurnSummary to reflect integration of dual-player input processing
- Added detailed coverage of ControllerRead implementation supporting both players
- Updated State_IdleWait and State_AdvisorCouncil handlers with improved dual-player implementations
- Expanded memory address documentation for controller input handling

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
This document describes the individual state procedures that drive the gameplay flow in the disassembly. It focuses on the 15 distinct game states and their implementations, detailing initialization sequences, display setup, user input handling, data manipulation, transitions, and the modular .proc organization. The system now features enhanced dual-player controller support with dedicated memory addresses for both Player 1 and Player 2 input processing.

## Project Structure
The game uses a vector-based dispatch mechanism located in bank 0x1F. The reset handler initializes the system and then dispatches to state handlers via a 15-entry vector table. Each state is implemented as a .proc and typically:
- Calls FrameInit to prepare PPU and working RAM
- Sets up display modes and windows
- Performs bank-switched drawing calls
- Reads dual-player controller input
- Updates state machine and transitions

```mermaid
graph TB
Reset["Reset Handler<br/>Bank 0x1F $E000"] --> Dispatch["Vector Dispatch<br/>$E066"]
Dispatch --> State0["State_SystemInit<br/>$E09A"]
Dispatch --> State1["State_NewGameInit<br/>$E0DA"]
Dispatch --> State2["State_RandomDisplay2A<br/>$E17D"]
Dispatch --> State3["State_KingdomSelect<br/>$E18B"]
Dispatch --> State4["State_RandomDisplay28<br/>$E221"]
Dispatch --> State5["State_DomesticAffairs<br/>$E22F"]
Dispatch --> State6["State_RandomAdvance1<br/>$E2E2"]
Dispatch --> State7["State_BattlePhase<br/>$E2E8"]
Dispatch --> State8["State_RandomAdvance2<br/>$E36A"]
Dispatch --> State9["State_TerritoryView<br/>$E37C"]
Dispatch --> State10["State_IdleWait<br/>$E3EB"]
Dispatch --> State11["State_AdvisorCouncil<br/>$E3EE"]
Dispatch --> State12["State_IdleWait<br/>$E3EB"]
Dispatch --> State13["State_TurnSummary<br/>$E46A"]
Dispatch --> State14["State_IdleWait<br/>$E3EB"]
```

**Diagram sources**
- [prg_1f.aligned.asm:161-177](file://asm/banks/prg_1f.aligned.asm#L161-L177)
- [prg_1f.aligned.asm:174-202](file://asm/banks/prg_1f.aligned.asm#L174-L202)
- [prg_1f.aligned.asm:210-276](file://asm/banks/prg_1f.aligned.asm#L210-L276)
- [prg_1f.aligned.asm:281-287](file://asm/banks/prg_1f.aligned.asm#L281-L287)
- [prg_1f.aligned.asm:295-365](file://asm/banks/prg_1f.aligned.asm#L295-L365)
- [prg_1f.aligned.asm:370-376](file://asm/banks/prg_1f.aligned.asm#L370-L376)
- [prg_1f.aligned.asm:383-433](file://asm/banks/prg_1f.aligned.asm#L383-L433)
- [prg_1f.aligned.asm:483-486](file://asm/banks/prg_1f.aligned.asm#L483-L486)
- [prg_1f.aligned.asm:493-550](file://asm/banks/prg_1f.aligned.asm#L493-L550)
- [prg_1f.aligned.asm:555-558](file://asm/banks/prg_1f.aligned.asm#L555-L558)
- [prg_1f.aligned.asm:575-619](file://asm/banks/prg_1f.aligned.asm#L575-L619)
- [prg_1f.aligned.asm:624-625](file://asm/banks/prg_1f.aligned.asm#L624-L625)
- [prg_1f.aligned.asm:630-680](file://asm/banks/prg_1f.aligned.asm#L630-L680)
- [prg_1f.aligned.asm:686-735](file://asm/banks/prg_1f.aligned.asm#L686-L735)
- [prg_1f.aligned.asm:624-625](file://asm/banks/prg_1f.aligned.asm#L624-L625)

**Section sources**
- [PROJECT.md:101-117](file://PROJECT.md#L101-L117)
- [prg_1f.aligned.asm:161-177](file://asm/banks/prg_1f.aligned.asm#L161-L177)

## Core Components
- Vector Dispatch: Central dispatcher that selects the current state routine using a 15-entry table.
- State Handlers: Modular .proc routines implementing each game state's logic and transitions.
- Helper Procedures: FrameInit, DisplayInit, WindowDisplaySetup, ControllerRead, BankSwitch, PpuMaskHelper, PpuCtrlNmiHelpers, and others.
- Dual-Player Controller Support: Enhanced input handling with separate memory addresses for Player 1 and Player 2.
- Bank Switching: Uses the Namco-163 mapper to load code/data from other banks during state execution.

Key helper and utility locations:
- FrameInit: Prepares PPU, clears working RAM, initializes sentinel values, and initializes sprite buffers.
- DisplayInit: Clears window, invokes bank-switched display mode, and switches CHR banks.
- WindowDisplaySetup/WindowSetup2: Configure bank parameters and write to mapper registers for banked calls.
- BankSwitch: Applies PRG bank configurations to mapper registers.
- ControllerRead: Polls both controller ports and computes edge-triggered and previous states for both players.
- PpuMaskHelper/PpuCtrlNmiHelpers: Control PPU mask and NMI enablement.

**Section sources**
- [prg_1f.aligned.asm:746-770](file://asm/banks/prg_1f.aligned.asm#L746-L770)
- [prg_1f.aligned.asm:573-579](file://asm/banks/prg_1f.aligned.asm#L573-L579)
- [prg_1f.aligned.asm:2302-2309](file://asm/banks/prg_1f.aligned.asm#L2302-L2309)
- [prg_1f.aligned.asm:2315-2318](file://asm/banks/prg_1f.aligned.asm#L2315-L2318)
- [prg_1f.aligned.asm:776-809](file://asm/banks/prg_1f.aligned.asm#L776-L809)
- [prg_1f.aligned.asm:1049-1085](file://asm/banks/prg_1f.aligned.asm#L1049-L1085)
- [prg_1f.aligned.asm:1118-1151](file://asm/banks/prg_1f.aligned.asm#L1118-L1151)

## Architecture Overview
The state machine is driven by a single global variable (game state index) and a vector table. Each state routine:
- Prepares the frame (PPU, RAM, sprites)
- Chooses a display mode and sets up windows
- Invokes bank-switched drawing routines
- Reads dual-player input and applies logic
- Updates state and transitions

```mermaid
sequenceDiagram
participant CPU as "CPU"
participant Dispatch as "StateDispatch"
participant State as "Current State Proc"
participant Helpers as "Helpers"
participant Mapper as "Namco-163 Mapper"
CPU->>Dispatch : Read addr_game_state
Dispatch->>Dispatch : AND #$1F, ASL, TAY
Dispatch->>Dispatch : Load VectorTable[Y]
Dispatch->>State : JMP (vector)
State->>Helpers : FrameInit
State->>Helpers : DisplayInit
State->>Helpers : WindowDisplaySetup
State->>Mapper : BankSwitch (PRG)
State->>State : Draw display (banked)
State->>Helpers : ControllerRead (Dual-Player)
State->>State : Update state index
State->>Dispatch : JMP StateDispatch
```

**Diagram sources**
- [prg_1f.aligned.asm:146-156](file://asm/banks/prg_1f.aligned.asm#L146-L156)
- [prg_1f.aligned.asm:746-770](file://asm/banks/prg_1f.aligned.asm#L746-L770)
- [prg_1f.aligned.asm:573-579](file://asm/banks/prg_1f.aligned.asm#L573-L579)
- [prg_1f.aligned.asm:2302-2309](file://asm/banks/prg_1f.aligned.asm#L2302-L2309)
- [prg_1f.aligned.asm:776-809](file://asm/banks/prg_1f.aligned.asm#L776-L809)
- [prg_1f.aligned.asm:1049-1085](file://asm/banks/prg_1f.aligned.asm#L1049-L1085)

## Detailed Component Analysis

### State_SystemInit (index 0)
Purpose: Initialize PPU, clear palettes, disable rendering, patch mapper, switch to initial state.
Behavior:
- Waits for VBlank, disables PPU mask, runs banked PPU init, fills sprite palette.
- Patches RAM and mapper registers, switches to bank 0x00, enables NMI and sets PPU control/mask.
- Transitions to State_TerritoryView (index 9).

Parameters: None (internal initialization).

Transition: addr_game_state = 9, then StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:182-210](file://asm/banks/prg_1f.aligned.asm#L182-L210)
- [prg_1f.aligned.asm:832-840](file://asm/banks/prg_1f.aligned.asm#L832-L840)

### State_NewGameInit (index 1)
Purpose: Initialize new game screen, set up display parameters, optionally initialize SRAM flags, and transition to next state.
Behavior:
- Calls FrameInit, sets sub-state, DisplayInit, and draws initial windows.
- Sets pointer to $8000, configures width/params, draws overlay, reads dual-player controller.
- Optionally sets SRAM flags based on input.
- Sets display mode, uploads palettes, switches to bank 0x01, increments state, plays music, enables PPU/NMI.

Parameters:
- $0400: dual-player controller input result
- $0098: display param
- SRAM: $6F41, $6F3F, $6F8B: kingdom initialization

Transition: INC addr_game_state, then StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:218-284](file://asm/banks/prg_1f.aligned.asm#L218-L284)

### State_RandomDisplay2A (index 2)
Purpose: Draw a random display using window mode 0x2A and advance RNG.
Behavior:
- Calls RandomByte, sets window mode 0x2A, invokes bank-switched display, then StateDispatch.

Parameters: None (uses internal RNG).

Transition: StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:289-295](file://asm/banks/prg_1f.aligned.asm#L289-L295)
- [prg_1f.aligned.asm:1250-1260](file://asm/banks/prg_1f.aligned.asm#L1250-L1260)

### State_KingdomSelect (index 3)
Purpose: Allow player to select a kingdom; supports scenario mode and normal mode.
Behavior:
- FrameInit, sets sub-state, DisplayInit, draws kingdom display.
- Checks mode: scenario vs normal, calls appropriate banked function.
- Copies selected coordinates to working RAM, sets flags, overlays, reads dual-player controller.
- Uploads palettes, switches to bank 0x01, increments state, plays music, enables PPU/NMI.

Parameters:
- $0500: kingdom mode ($0B=scenario)
- $0510-$0513: kingdom coordinate data
- $0068/$0069: territory data pointer

Transition: INC addr_game_state, then StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:303-373](file://asm/banks/prg_1f.aligned.asm#L303-L373)

### State_RandomDisplay28 (index 4)
Purpose: Draw a random display using window mode 0x28 and advance RNG.
Behavior:
- Calls RandomByte, sets window mode 0x28, invokes bank-switched display, then StateDispatch.

Parameters: None (uses internal RNG).

Transition: StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:378-384](file://asm/banks/prg_1f.aligned.asm#L378-L384)
- [prg_1f.aligned.asm:1250-1260](file://asm/banks/prg_1f.aligned.asm#L1250-L1260)

### State_DomesticAffairs (index 5)
Purpose: Present domestic action interface and handle sprite indicators.
Behavior:
- FrameInit, sets sub-state, DisplayInit with action type, switches to bank 0x02, draws domestic display.
- Uses DomesticActionDisplay to draw action-specific graphics.
- Loads sprite positions from a table and renders overlay.
- Reads dual-player controller input, uploads palettes, increments state, plays sound, enables PPU/NMI.

Parameters:
- $0544: domestic action type (0-6)
- $0562/$0563: sprite position indices

Transition: INC addr_game_state, then StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:391-440](file://asm/banks/prg_1f.aligned.asm#L391-L440)
- [prg_1f.aligned.asm:448-470](file://asm/banks/prg_1f.aligned.asm#L448-L470)
- [prg_1f.aligned.asm:472-485](file://asm/banks/prg_1f.aligned.asm#L472-L485)

### State_RandomAdvance1 (index 6)
Purpose: Advance random seed (RNG) without drawing.
Behavior:
- Calls RandomByte, then StateDispatch.

Parameters: None (uses internal RNG).

Transition: StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:492-495](file://asm/banks/prg_1f.aligned.asm#L492-L495)
- [prg_1f.aligned.asm:1250-1260](file://asm/banks/prg_1f.aligned.asm#L1250-L1260)

### State_BattlePhase (index 7)
Purpose: Render and manage battle interface; handle army status and transitions.
Behavior:
- FrameInit, sets sub-state, sets display mode, draws battle background and overlay.
- Reads army status flags and clears sprites accordingly.
- Reads dual-player controller input, uploads palettes, switches to bank 0x03, increments state, plays music, enables PPU/NMI.

Parameters:
- $04AB/$04AC: army status flags

Transition: INC addr_game_state, then StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:502-559](file://asm/banks/prg_1f.aligned.asm#L502-L559)

### State_RandomAdvance2 (index 8)
Purpose: Advance random seed (RNG) without drawing.
Behavior:
- Calls RandomByte, then StateDispatch.

Parameters: None (uses internal RNG).

Transition: StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:564-567](file://asm/banks/prg_1f.aligned.asm#L564-L567)
- [prg_1f.aligned.asm:1250-1260](file://asm/banks/prg_1f.aligned.asm#L1250-L1260)

### State_TerritoryView (index 9)
Purpose: Display the world map and handle scrolling/palettes.
Behavior:
- FrameInit, sets sub-state, DisplayInit, draws map background and overlay.
- Sets up pointers and parameters for map data, reads dual-player controller input, uploads palettes.
- Switches to bank 0x02, increments state, enables PPU/NMI.

Transition: INC addr_game_state, then StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:584-627](file://asm/banks/prg_1f.aligned.asm#L584-L627)

### State_IdleWait (indices 10, 12, 14)
Purpose: No-op idle states that simply re-dispatch.
Behavior:
- JMP StateDispatch without changing state.

Transition: StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:632-633](file://asm/banks/prg_1f.aligned.asm#L632-L633)

### State_AdvisorCouncil (index 11)
Purpose: Show advisor/council dialogue and handle dual-player input.
Behavior:
- FrameInit, sets sub-state, DisplayInit, draws advisor background and dialogue.
- Sets up parameters for dialog, reads dual-player controller input, uploads palettes.
- Switches to bank 0x02, increments state, plays sound, enables PPU/NMI.

Transition: INC addr_game_state, then StateDispatch.

**Updated** Enhanced with dual-player controller support for improved input handling.

**Section sources**
- [prg_1f.aligned.asm:638-686](file://asm/banks/prg_1f.aligned.asm#L638-L686)

### State_TurnSummary (index 13)
Purpose: Display turn summary; play normal or victory music depending on completion flag.
Behavior:
- FrameInit, sets sub-state, DisplayInit, draws report background and overlay.
- Reads completion flag, selects music (normal or victory), uploads palettes.
- Switches to bank 0x02, increments state, enables PPU/NMI.

Parameters:
- $0541: completion flag (0=normal, nonzero=victory)

Transition: INC addr_game_state, then StateDispatch.

**Section sources**
- [prg_1f.aligned.asm:692-740](file://asm/banks/prg_1f.aligned.asm#L692-L740)

### StateDispatch
Purpose: Central dispatcher that selects the next state routine.
Behavior:
- Reads addr_game_state, masks to 0-31, multiplies by 2 for word index, loads vector, jumps to routine.

Transition: JMP (vector)

**Section sources**
- [prg_1f.aligned.asm:146-156](file://asm/banks/prg_1f.aligned.asm#L146-L156)

### Helper Procedures and Utilities

#### FrameInit
- Clears display working RAM, sets sentinel values, disables PPU, runs banked PPU init, fills nametables, resets counters, and initializes sprite buffers.

**Section sources**
- [prg_1f.aligned.asm:746-770](file://asm/banks/prg_1f.aligned.asm#L746-L770)

#### DisplayInit
- Clears window, invokes bank-switched display mode, and switches CHR banks.

**Section sources**
- [prg_1f.aligned.asm:573-579](file://asm/banks/prg_1f.aligned.asm#L573-L579)

#### WindowDisplaySetup / WindowSetup2
- Stores bank parameters to $00E2/$00E3 and writes to mapper registers for banked calls.

**Section sources**
- [prg_1f.aligned.asm:2302-2309](file://asm/banks/prg_1f.aligned.asm#L2302-L2309)
- [prg_1f.aligned.asm:2315-2318](file://asm/banks/prg_1f.aligned.asm#L2315-L2318)

#### BankSwitch
- Applies PRG bank configuration from a table to mapper registers.

**Section sources**
- [prg_1f.aligned.asm:776-809](file://asm/banks/prg_1f.aligned.asm#L776-L809)
- [prg_1f.aligned.asm:815-819](file://asm/banks/prg_1f.aligned.asm#L815-L819)

#### ControllerRead (Enhanced Dual-Player Support)
- Strobes both controller ports, reads 8-bit serial data for both players, computes raw, previous, and edge-triggered states for each player.
- Player 1 addresses: addr_pad1_edge, addr_pad1_raw, addr_pad1_prev
- Player 2 addresses: addr_pad2_edge, addr_pad2_raw, addr_pad2_prev

**Section sources**
- [prg_1f.aligned.asm:1049-1085](file://asm/banks/prg_1f.aligned.asm#L1049-L1085)

#### PpuMaskHelper / PpuCtrlNmiHelpers
- Control PPU mask and enable NMI via PPU registers.

**Section sources**
- [prg_1f.aligned.asm:1118-1151](file://asm/banks/prg_1f.aligned.asm#L1118-L1151)

### Bank Switching Integration
- The game uses the Namco-163 mapper to dynamically load code/data from other banks during state execution.
- BankSwitch applies a configuration from a table to mapper registers.
- WindowDisplaySetup and WindowSetup2 set parameters that are later written to mapper registers to select PRG/CHR banks.
- Banked drawing routines are invoked via addresses in the $A0xx range (e.g., $A003 for text, $A006 for scenario/action, $A009 for kingdom, $A015 for overlays, $A018 for advisor dialogue, $A024 for domestic, $A027 for kingdom select, etc.).

**Section sources**
- [namco163.h:10-14](file://include/namco163.h#L10-L14)
- [prg_1f.aligned.asm:776-809](file://asm/banks/prg_1f.aligned.asm#L776-L809)
- [prg_1f.aligned.asm:2302-2309](file://asm/banks/prg_1f.aligned.asm#L2302-L2309)
- [bank_1f_plan.md:226-242](file://code/bank_1f_plan.md#L226-L242)

### Modular .proc Organization and Local Variables
- Each state is implemented as a .proc with its own local variables in zero-page/working RAM (e.g., $0500–$0513 for kingdom select, $0544 for domestic action type, $0562/$0563 for sprite indices, $0541 for turn summary completion flag).
- Helper procedures are reusable across states and operate on shared memory areas.
- Banked routines are invoked indirectly through window setup and bank switching, keeping state procs agnostic of exact bank addresses.
- Dual-player controller support is integrated throughout all state handlers via unified ControllerRead procedure.

**Section sources**
- [prg_1f.aligned.asm:303-311](file://asm/banks/prg_1f.aligned.asm#L303-L311)
- [prg_1f.aligned.asm:391-395](file://asm/banks/prg_1f.aligned.asm#L391-L395)
- [prg_1f.aligned.asm:692-694](file://asm/banks/prg_1f.aligned.asm#L692-L694)

## Dependency Analysis
- State_SystemInit depends on PPU init, palette upload, and mapper patching.
- State_NewGameInit depends on FrameInit, DisplayInit, dual-player controller input, and SRAM initialization.
- State_KingdomSelect depends on DisplayInit, banked kingdom display, and coordinate handling.
- State_DomesticAffairs depends on DisplayInit, DomesticActionLookup/DomesticActionDisplay, sprite position tables, and dual-player controller input.
- State_BattlePhase depends on DisplayInit, army status flags, and banked battle display.
- State_TerritoryView depends on DisplayInit and banked map display.
- State_AdvisorCouncil depends on DisplayInit and banked advisor dialogue.
- State_TurnSummary depends on DisplayInit, completion flag, and music selection.
- All states depend on StateDispatch for transitions and on helpers for PPU, input, and bank switching.

```mermaid
graph TB
State_SystemInit --> PPU_Init["PPU Init / Patch"]
State_NewGameInit --> FrameInit
State_NewGameInit --> DisplayInit
State_NewGameInit --> DualController["Dual-Player Controller Read"]
State_NewGameInit --> ControllerRead
State_KingdomSelect --> DisplayInit
State_KingdomSelect --> BankedKingdom["Banked Kingdom Display"]
State_DomesticAffairs --> DisplayInit
State_DomesticAffairs --> DomesticLookup["DomesticActionLookup"]
State_DomesticAffairs --> SpriteTable["DomesticSpriteYPos"]
State_DomesticAffairs --> DualController
State_BattlePhase --> DisplayInit
State_BattlePhase --> ArmyFlags["Army Status Flags"]
State_BattlePhase --> DualController
State_TerritoryView --> DisplayInit
State_TerritoryView --> BankedMap["Banked Map Display"]
State_TerritoryView --> DualController
State_AdvisorCouncil --> DisplayInit
State_AdvisorCouncil --> BankedAdvisor["Banked Advisor Dialogue"]
State_AdvisorCouncil --> DualController
State_TurnSummary --> DisplayInit
State_TurnSummary --> CompletionFlag["Completion Flag"]
StateDispatch --> AllStates["All States"]
```

**Diagram sources**
- [prg_1f.aligned.asm:182-210](file://asm/banks/prg_1f.aligned.asm#L182-L210)
- [prg_1f.aligned.asm:218-284](file://asm/banks/prg_1f.aligned.asm#L218-L284)
- [prg_1f.aligned.asm:303-373](file://asm/banks/prg_1f.aligned.asm#L303-L373)
- [prg_1f.aligned.asm:391-440](file://asm/banks/prg_1f.aligned.asm#L391-L440)
- [prg_1f.aligned.asm:502-559](file://asm/banks/prg_1f.aligned.asm#L502-L559)
- [prg_1f.aligned.asm:584-627](file://asm/banks/prg_1f.aligned.asm#L584-L627)
- [prg_1f.aligned.asm:638-686](file://asm/banks/prg_1f.aligned.asm#L638-L686)
- [prg_1f.aligned.asm:692-740](file://asm/banks/prg_1f.aligned.asm#L692-L740)
- [prg_1f.aligned.asm:146-156](file://asm/banks/prg_1f.aligned.asm#L146-L156)

**Section sources**
- [prg_1f.aligned.asm:182-210](file://asm/banks/prg_1f.aligned.asm#L182-L210)
- [prg_1f.aligned.asm:218-284](file://asm/banks/prg_1f.aligned.asm#L218-L284)
- [prg_1f.aligned.asm:303-373](file://asm/banks/prg_1f.aligned.asm#L303-L373)
- [prg_1f.aligned.asm:391-440](file://asm/banks/prg_1f.aligned.asm#L391-L440)
- [prg_1f.aligned.asm:502-559](file://asm/banks/prg_1f.aligned.asm#L502-L559)
- [prg_1f.aligned.asm:584-627](file://asm/banks/prg_1f.aligned.asm#L584-L627)
- [prg_1f.aligned.asm:638-686](file://asm/banks/prg_1f.aligned.asm#L638-L686)
- [prg_1f.aligned.asm:692-740](file://asm/banks/prg_1f.aligned.asm#L692-L740)
- [prg_1f.aligned.asm:146-156](file://asm/banks/prg_1f.aligned.asm#L146-L156)

## Performance Considerations
- Bank switching occurs infrequently per state but is essential for loading graphics and text data. Keep state routines compact to minimize overhead.
- PPU operations (mask, NMI, palette upload) are performed once per state to reduce flicker and maintain timing.
- Dual-player controller polling is centralized in ControllerRead and reused across states to avoid redundant reads.
- Edge-triggered input detection is optimized for both players to ensure responsive gameplay.

## Troubleshooting Guide
Common issues and checks:
- PPU flicker or incorrect palette: Verify PpuMaskHelper and PaletteUpload calls occur before enabling rendering.
- Incorrect banked drawing: Confirm BankSwitch and WindowDisplaySetup/WindowSetup2 are executed before invoking $A0xx routines.
- Dual-player input not responding: Ensure ControllerRead is called and edge-triggered flags are checked appropriately for both addr_pad1_edge and addr_pad2_edge.
- State stuck: Confirm StateDispatch is reached after each state completes its logic.
- Controller input conflicts: Verify proper edge-triggered detection using XOR and AND operations on raw and previous states.

**Section sources**
- [prg_1f.aligned.asm:1118-1151](file://asm/banks/prg_1f.aligned.asm#L1118-L1151)
- [prg_1f.aligned.asm:1049-1085](file://asm/banks/prg_1f.aligned.asm#L1049-L1085)
- [prg_1f.aligned.asm:146-156](file://asm/banks/prg_1f.aligned.asm#L146-L156)

## Conclusion
The state system is a clean, modular design centered on a vector dispatch mechanism. Each state manages its own local variables, prepares the frame, performs bank-switched drawing, handles dual-player input, and transitions cleanly. The enhanced dual-player controller support provides comprehensive input handling with separate memory addresses for both players, while the helper procedures encapsulate common tasks (PPU control, input, bank switching), and the vector table ensures predictable control flow across 15 distinct game states.