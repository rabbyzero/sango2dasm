;===============================================================================
; functions.h - Symbolic Function and Data Label Definitions
; Sangokushi 2 - Haou no Tairiku (J) / Namco-163 (Mapper 19)
;
; Defines symbolic names for all known functions and data labels.
; Include from any .asm file:  .include "functions.h"
;
; Naming Convention: BXX_FunctionName
;   XX = PRG bank number (hex, $00-$1F)
;   Bank $1F symbols are at fixed addresses $E000-$FFFF
;   Banked symbols ($8000-$DFFF) share CPU addresses across banks
;
; ca65 allows multiple symbols with the same value:
;   B04_Init = $A000 and B08_Init = $A000 are both valid
;===============================================================================

.ifndef GUARD_FUNCTIONS_H
GUARD_FUNCTIONS_H = 1

;===============================================================================
; SECTION 1: Bank $1F - Fixed Code ($E000-$FFFF)
; Always mapped to $E000-$FFFF (PRG slot 3)
;===============================================================================

;-------------------------------------------------------------------------------
; 1A: Reset and State Machine
;-------------------------------------------------------------------------------
B1F_Reset                 = $E000   ; Reset handler: SEI, CLD, RAM clear, init
B1F_StateDispatch         = $E066   ; Jump to handler via VectorTable[game_state]
B1F_VectorTable           = $E07C   ; State dispatch table (15 entries, 2 bytes each)
B1F_State_SystemInit      = $E09A   ; State 0: System init, PPU setup, -> state 9
B1F_State_NewGameInit     = $E0DA   ; State 1: New game init, SRAM, music $81
B1F_State_RandomDisplay2A = $E17D   ; State 2: Random + display (Y=$2A)
B1F_State_RulerSelect     = $E18B   ; State 3: Ruler select, scenario/normal
B1F_State_RandomDisplay28 = $E221   ; State 4: Random + display (Y=$28)
B1F_State_StrategyMode    = $E22F   ; State 5: Strategy mode, command select
B1F_StrategyCommandLookup = $E29C   ; Strategy command display by $0544
B1F_StrategyCommandGraphicPtrs = $E2C2 ; 7 graphic pointers for strategy commands
B1F_StrategyCommandBaseDataPtrs = $E2D0 ; Base data pointers for strategy display
B1F_StrategyCommandSpriteYPos = $E2DE ; Sprite Y position table (4 bytes)
B1F_State_RandomAdvance1  = $E2E2   ; State 6: Pure RNG advance
B1F_State_TacticalMode    = $E2E8   ; State 7: Tactical mode, army status
B1F_State_RandomAdvance2  = $E36A   ; State 8: Pure RNG advance
B1F_DisplayInit           = $E370   ; Display init: window clear + bank display
B1F_State_CountryMapView  = $E37C   ; State 9: Country map view
B1F_State_IdleWait        = $E3EB   ; State 10/12/14: Idle wait, JMP dispatch
B1F_State_AdvisorCouncil  = $E3EE   ; State 11: Advisor/council dialogue
B1F_State_TurnSummary     = $E46A   ; State 13: Turn summary/report
B1F_FrameInit             = $E4DA   ; Per-frame setup: PPU, bank, clear RAM

;-------------------------------------------------------------------------------
; 1B: Bank Switching
;-------------------------------------------------------------------------------
B1F_BankSwitch            = $E51F   ; 8-byte config bank switch (CHR + ext)
B1F_BankSwitchTable       = $E567   ; Bank switch config table (3 x 8 bytes)
B1F_BankPpuInit           = $E57F   ; Bank + PPU init + JMP patch

;-------------------------------------------------------------------------------
; 1C: Sound Engine
;-------------------------------------------------------------------------------
B1F_SoundInit             = $E590   ; Sound init: APU, RAM clear, wavetable
B1F_WavetableWriteEntry   = $E5F3   ; Wavetable write entry point
B1F_WavetableWriteDelay   = $E5FA   ; Wavetable write timing delay
B1F_SoundNotePlayer       = $E609   ; Sound note player from banked ROM
B1F_SoundChannelTable     = $E667   ; Sound channel table (4 bytes)
B1F_SoundWrapper0         = $E66B   ; Sound wrapper variant 0
B1F_SoundWrapperA         = $E673   ; Sound wrapper variant A
B1F_SoundWrapperB         = $E67B   ; Sound wrapper variant B
B1F_SoundWrapperC         = $E683   ; Sound wrapper variant C
B1F_SoundWrapperD         = $E68B   ; Sound wrapper variant D
B1F_SoundWrapperE         = $E693   ; Sound wrapper variant E
B1F_SoundWrapperF         = $E69B   ; Sound wrapper variant F
B1F_WavetableInitData     = $E6A6   ; Namco-163 wavetable init data (32 bytes)

;-------------------------------------------------------------------------------
; 1D: Controller I/O
;-------------------------------------------------------------------------------
B1F_ControllerRead        = $E6C6   ; Controller read from $4016/$4017

;-------------------------------------------------------------------------------
; 1E: PPU Utilities
;-------------------------------------------------------------------------------
B1F_PaletteUpload         = $E70E   ; Upload palette $0100-$011F to PPU
B1F_PpuMaskEnable         = $E749   ; PPU mask: enable rendering ($1E)
B1F_PpuMaskDisable        = $E74D   ; PPU mask: disable rendering ($00)
B1F_NmiEnable             = $E753   ; Enable NMI (set bit 7 of PPU_CTRL)
B1F_NmiDisable            = $E768   ; Disable NMI (clear bit 7 of PPU_CTRL)
B1F_NametableFill1        = $E774   ; Nametable fill mode 1 (3 nametables)
B1F_NametableFillSub      = $E7B5   ; Fill one nametable (1024 bytes)
B1F_NametableFill2        = $E7DF   ; Nametable fill mode 2
B1F_SpriteBufferInit      = $E823   ; Init sprite buffer from index
B1F_SpriteBufferInitAll   = $E825   ; Fill $0200-$02FF with $F0
B1F_SpriteClearFromIndex  = $E830   ; Clear sprites from X index

;-------------------------------------------------------------------------------
; 1F: Random Number Generator
;-------------------------------------------------------------------------------
B1F_RandomBelow100        = $E843   ; Random byte < 100
B1F_RandomDiv2            = $E84B   ; Random byte / 2
B1F_RandomModPow2         = $E850   ; Random mod 4/8/16 (entry point)
B1F_RandomMod4            = $E850   ; Random mod 4
B1F_RandomMod8            = $E856   ; Random mod 8
B1F_RandomMod16           = $E85C   ; Random mod 16
B1F_RandomBelowThreshold  = $E862   ; Random below threshold
B1F_RandomByte            = $E87A   ; RNG core: table lookup at $E8BA
B1F_RandomVariants        = $E88A   ; RNG variants (entry point)
B1F_RandomByte2           = $E88A   ; RNG variant 2 ($0052 index)
B1F_RandomByte3           = $E89A   ; RNG variant 3 ($0054 index)
B1F_RandomByte4           = $E8AA   ; RNG variant 4 ($0055 index)
B1F_RandomTable           = $E8BA   ; Pre-computed random data (256 bytes)

;-------------------------------------------------------------------------------
; 1G: Math Routines
;-------------------------------------------------------------------------------
B1F_MathBinToBcd          = $E9BA   ; 24-bit binary to 6-digit packed BCD
B1F_MathDiv16             = $EA7C   ; 16-bit unsigned division (16 iterations)
B1F_MathDiv24             = $EAA5   ; 24-bit unsigned division (24 iterations)
B1F_CallbackDispatcher    = $EADE   ; Inline pointer table callback dispatcher
B1F_ScrollSet             = $EAF7   ; PPU scroll register write
B1F_WindowReset           = $EB1A   ; Window/reset PPU helper ($0250)
B1F_MathBcdToBin          = $EB2D   ; 6-digit packed BCD to 24-bit binary
B1F_MathExtractUpperNibble = $EBB1  ; Extract upper nibble (4x LSR)
B1F_MathAccumulate24      = $EBB6   ; 24-bit accumulate add
B1F_MathMulDiv100         = $EBCA   ; 16-bit * 8-bit / 100
B1F_MathMul24x8           = $EBE9   ; 24x8 multiply (32-bit result)
B1F_MathMul24x16          = $EC22   ; 24x16 multiply (40-bit result)

;-------------------------------------------------------------------------------
; 1H: Palette Animation
;-------------------------------------------------------------------------------
B1F_PaletteAnimation      = $EC67   ; Palette color rotation/animation
B1F_PaletteFadeInit       = $ECBF   ; Palette fade initialization
B1F_PaletteCopyBuffer     = $ECEE   ; Palette copy to buffer

;-------------------------------------------------------------------------------
; 1I: Menu System
;-------------------------------------------------------------------------------
B1F_MenuCursorSystem      = $ED19   ; Menu cursor engine (entry point)
B1F_MenuStep1             = $ED19   ; Menu entry: step size 1
B1F_MenuStep2             = $ED1E   ; Menu entry: step size 2
B1F_MenuStep3             = $ED23   ; Menu entry: step size 3
B1F_MenuStep4             = $ED28   ; Menu entry: step size 4
B1F_MenuStep5             = $ED2D   ; Menu entry: step size 5
B1F_MenuStep6             = $ED32   ; Menu entry: step size 6
B1F_MenuStep7             = $ED37   ; Menu entry: step size 7
B1F_MenuStep8             = $ED3C   ; Menu entry: step size 8
B1F_MenuMain              = $ED41   ; Menu main processing
B1F_MenuItemLookup        = $EDDD   ; Menu item lookup by page*step+column
B1F_PointerTableLookup    = $EDF5   ; Pointer table lookup + sprite write

;-------------------------------------------------------------------------------
; 1J: Callback and Trampoline
;-------------------------------------------------------------------------------
B1F_BankedCallbackTrampoline = $EE07 ; Banked call with stack manipulation
B1F_BankedCallbackReturn  = $EE4D   ; Return stub: restore bank, return

;-------------------------------------------------------------------------------
; 1K: NMI Sub-Dispatch
;-------------------------------------------------------------------------------
B1F_NmiSubDispatch        = $EE53   ; NMI sub-dispatch by $007E flags
B1F_NmiPaletteUpload      = $EE72   ; NMI palette upload trampoline
B1F_NmiSubDispatchAlt     = $EEE6   ; NMI sub-dispatch alternate

;-------------------------------------------------------------------------------
; 1L: PPU Tile Writers
;-------------------------------------------------------------------------------
B1F_PpuBgTileWrite        = $EF0B   ; PPU BG tile write from buffer
B1F_PpuSpriteTileWrite    = $EF71   ; PPU sprite tile write from buffer
B1F_PpuAttrTileWrite      = $EFC0   ; PPU attribute tile write
B1F_PpuAttrTileWriteAlt   = $F028   ; PPU attribute tile write (alt)

;-------------------------------------------------------------------------------
; 1M: Namco Sound Register Access
;-------------------------------------------------------------------------------
B1F_NamcoSoundRegRead     = $F077   ; Namco-163 sound register read

;-------------------------------------------------------------------------------
; 1N: Sprite OAM Writers
;-------------------------------------------------------------------------------
B1F_SpriteOamWriterScroll = $F092   ; Sprite OAM writer with scroll offset
B1F_SpriteOamWriterScroll_NoInit = $F09C ; mid-entry: caller preset $0003/$0004
B1F_SpriteOamWriterSimple = $F1AD   ; Sprite OAM writer direct placement

;-------------------------------------------------------------------------------
; 1O: CHR Bank Switching
;-------------------------------------------------------------------------------
B1F_ChrBankSwitch         = $F206   ; CHR bank switch (8 registers)

;-------------------------------------------------------------------------------
; 1P: PRG Bank Switching Helpers
;-------------------------------------------------------------------------------
B1F_SwitchBankAC_B        = $F237   ; Switch $A000+$C000 pair (slot B: $00E2/$00E3)
B1F_SwitchBankAC_A        = $F24B   ; Switch $A000+$C000 pair (slot A: $00DF/$00E0)
B1F_SwitchBank8_B         = $F25F   ; Switch $8000 bank (slot B: $00E1)
B1F_SwitchBank8_A         = $F266   ; Switch $8000 bank (slot A: $00DE)

;-------------------------------------------------------------------------------
; 1Q: UI Mode Helpers
;-------------------------------------------------------------------------------
B1F_SetUI0                = $F26D   ; Set UI mode 0
B1F_SetUI2                = $F283   ; Set UI mode 2
B1F_SetUI4                = $F28B   ; Set UI mode 4
B1F_SetUI5                = $F293   ; Set UI mode 5
B1F_ClearUI               = $F29B   ; Clear UI state

;-------------------------------------------------------------------------------
; 1R: Data Record Accessors
;-------------------------------------------------------------------------------
B1F_GetProvinceRecordAddr = $F2AF   ; Province: id*32+$6000
B1F_GetOfficerRecordAddr  = $F2D7   ; Officer: id*12+$63C0
B1F_GetNameDisplayScale   = $F308   ; Officer kata name: id*10+$901A + width
B1F_NameScaleTable        = $F35F   ; Kata name character width table
B1F_GetCountryDataPtr     = $F368   ; Country base addr from pointer table
B1F_CountryDataPtrTable   = $F379   ; 7 country SRAM base pointers
B1F_GetOfficerRomRecordAddr = $F387 ; Officer ROM: id*12+$8000

;-------------------------------------------------------------------------------
; 1S: Copy Protection / RAM Integrity
;-------------------------------------------------------------------------------
B1F_CopyProtectionCheck   = $F3BD   ; Mapper init + controller validation
B1F_VerifyRamPattern      = $F422   ; RAM integrity test ($AA write/verify)
B1F_WriteRamPattern       = $F43F   ; Write RAM test pattern
B1F_InitRamTestParams     = $F458   ; Init RAM test parameters
B1F_AdvanceHashPattern    = $F468   ; Advance hash/pattern value

;-------------------------------------------------------------------------------
; 1T: Data Tables
;-------------------------------------------------------------------------------
B1F_MetaTileData          = $F477   ; Metatile data / sound+music data

;-------------------------------------------------------------------------------
; 1U: NMI Handler and Sub-States
;-------------------------------------------------------------------------------
B1F_NmiHandler            = $F800   ; NMI handler (8 sub-states)
B1F_NmiDispatchTable      = $F87B   ; NMI game state dispatch table (9 entries)
B1F_NmiEpilogue           = $F88D   ; Restore PRG banks, tick counters, RTI
B1F_NmiState2_MapScreen   = $F8B5   ; NMI state 2: Map screen rendering
B1F_NmiState3_Battle      = $F8FE   ; NMI state 3: Battle rendering
B1F_NmiState4_Menu        = $F96A   ; NMI state 4: Menu rendering
B1F_NmiState5_Intrigue    = $F9A0   ; NMI state 5: Intrigue (策略) rendering
B1F_NmiState6_Event       = $F9E4   ; NMI state 6: Event rendering
B1F_NmiState7_Strategy    = $FA13   ; NMI state 7: Strategy rendering
B1F_NmiState8_Officer     = $FA53   ; NMI state 8: Officer rendering
B1F_NmiState0_Idle        = $FA97   ; NMI state 0: Idle/wait
B1F_SwapPlayerPointers    = $FAA9   ; Palette swap (if $6F44!=0)
B1F_RestorePlayerPointers = $FABF   ; Palette swap reverse
B1F_NmiHandler_Busy       = $FAD5   ; NMI busy: scroll mode + CHR restore
B1F_SetupChrBanksAndWait  = $FB0B   ; Setup CHR banks + wait for VBlank
B1F_WaitVBlank            = $FB28   ; Wait for VBlank

;-------------------------------------------------------------------------------
; 1V: IRQ Handler and Sub-Modes
;-------------------------------------------------------------------------------
B1F_IrqHandler            = $FB2D   ; IRQ handler (14+ sub-states for raster)
B1F_IrqExit               = $FB9E   ; IRQ exit: restore regs, RTI
B1F_IrqMode1_SoundAndChr  = $FBA4   ; IRQ mode 1: Sound regs + CHR dispatch
B1F_IrqChrUpdate_Block1   = $FBCE   ; CHR update block 1
B1F_IrqChrUpdate_Block2   = $FBFC   ; CHR update block 2
B1F_IrqChrUpdate_Block3   = $FC2A   ; CHR update block 3
B1F_IrqChrUpdate_Block4   = $FC58   ; CHR update block 4
B1F_IrqMode2_FullSetup    = $FC8B   ; IRQ mode 2: Full CHR + sound setup
B1F_ScanlineDelayTable    = $FD1A   ; Scanline delay values
B1F_IrqMode4_SimpleChr    = $FD2A   ; IRQ mode 4: Simple CHR update
B1F_IrqMode5_PpuAddrChr   = $FD95   ; IRQ mode 5: PPU addr + CHR update
B1F_IrqMode6_Minimal      = $FDF4   ; IRQ mode 6: Minimal update
B1F_IrqMode7_SoundChr     = $FE03   ; IRQ mode 7: Sound + CHR update
B1F_IrqMode8_SoundChr     = $FE69   ; IRQ mode 8: Sound + CHR update
B1F_IrqMode9_BasicChr     = $FE96   ; IRQ mode 9: Basic CHR update
B1F_IrqMode10_PpuScroll   = $FECD   ; IRQ mode 10: PPU scroll update
B1F_IrqMode11_ScrollFwd   = $FF31   ; IRQ mode 11: Scroll forward
B1F_IrqMode12_ScrollBack  = $FF48   ; IRQ mode 12: Scroll back

;-------------------------------------------------------------------------------
; 1W: Scroll Calculation
;-------------------------------------------------------------------------------
B1F_CalcScrollAddr        = $FF62   ; Scroll calc: $009A/$009B from $0098
B1F_CalcScrollAddrAlt     = $FF9B   ; Scroll calc variant B

;===============================================================================
; SECTION 2: Banked Entry Points ($A000-$BFFF)
;
; These addresses are called after PRG bank switching via SwitchBankAC_B/A.
; The same CPU address maps to different code depending on the active PRG bank.
; The $A000 slot maps to Namco-163 PRG bank Y; $C000 maps to bank Y+1.
;
; Bank numbers below are the Y register values passed to SwitchBankAC_B
; before each call.
;===============================================================================

;-------------------------------------------------------------------------------
; Banks $17+$18 - Strategy Mode display (combined 16KB $A000-$DFFF)
; Loaded via SwitchBankAC with Y=$37
;
; Jump table entry points ($A000-$A029)
;-------------------------------------------------------------------------------
B17_18_PpuWriteRle        = $A000   ; PpuWriteRle_Entry: RLE-encoded PPU data writer
B17_18_PpuCopyRaw         = $A003   ; PpuCopyRaw_Entry: Raw 1KB PPU data copy
B17_18_PpuWriteTileOffset = $A006   ; PpuWriteTileOffset_Entry: PPU tile data write with offset
B17_18_DisplayScrollLoop  = $A009   ; DisplayScrollLoop_Entry: Display scroll and render loop
B17_18_DisplayAndChrSetup = $A00C   ; DisplayAndChrSetup_Entry: Display coordinate check + CHR setup
B17_18_BattleEffects      = $A00F   ; BattleEffects_Entry: Battle visual effects
B17_18_BattleDispatch     = $A012   ; BattleDispatch_Entry: Battle dispatch
B17_18_OverlayWindow      = $A015   ; OverlayWindow_Entry: Overlay/window rendering
B17_18_SetupAdvisorTiles  = $A018   ; SetupAdvisorTiles_Entry: Setup advisor/council tiles
B17_18_MainGameDispatch   = $A01B   ; MainGameDispatch_Entry: Main game mode dispatcher
B17_18_StrategyCommandDispatch = $A01E ; StrategyCommandDispatch_Entry: Strategy command dispatcher
B17_18_AnimationDispatch  = $A021   ; AnimationDispatch_Entry: Animation dispatch
B17_18_StrategyModeDisplay = $A024   ; StrategyModeDisplay_Entry: Strategy Mode display
B17_18_DataRecordLoader   = $A027   ; DataRecordLoader_Entry: Data record loader

;-------------------------------------------------------------------------------
; Internal procs - Bank $17 ($A02A-$BFFF)
;-------------------------------------------------------------------------------
B17_18_SetupDisplayPtrs   = $A04A
B17_18_AdvanceSrcPtr      = $A0D2
B17_18_PpuWriteRawRows    = $A0E4
B17_18_RleDecompressHelper = $A169
B17_18_ReadRleByte        = $A1A5
B17_18_AdvanceSrcPtr2     = $A209
B17_18_AdvanceTilePtr     = $A2E4
B17_18_RewindTilePtr16    = $A2ED
B17_18_DisplayUpdateScroll = $A3B1
B17_18_SceneRenderDispatch = $A3BC
B17_18_RenderSceneHoriz   = $A3C9
B17_18_RenderSceneVert    = $A485
B17_18_CopyTileRowHoriz   = $A545
B17_18_CopyTileRowVert    = $A5A5
B17_18_BankPtrLookup      = $A604
B17_18_BankPtrLookupAlt   = $A610
B17_18_BattleAttrAndHelpers = $A89A
B17_18_ComputeAttributeByte = $A8D3
B17_18_DispatchTileRowHoriz = $A8FD
B17_18_DispatchTileRowVert = $A91E
B17_18_InitTileGridHoriz  = $A93F
B17_18_InitTileGridVert   = $A961
B17_18_CalcTileGridOrigin = $AB26
B17_18_BattleOverlayRender = $AB94
B17_18_WriteBattleAttribute = $AC80
B17_18_BattleOverlayCopy  = $AD69
B17_18_SetScrollWorkOffset4 = $AD9F
B17_18_LoadBattleOverlay  = $ADBC
B17_18_LoadBattleOverlayWithOffset = $AEB5
B17_18_LoadOverlaySecondary = $AF0C
B17_18_PatchAttrAdjacency = $AF1B
B17_18_PatchPrimaryAdjacency = $AF30
B17_18_PatchSecondaryAdjacency = $AF71
B17_18_PatchSingleAdjacency = $AFB5
B17_18_BuildAdjacencyMap  = $AFF9
B17_18_PopulateAdjacencyEntries = $B00F
B17_18_BuildAdjacencyMapSmall = $B055
B17_18_PopulateAdjacencyEntriesSmall = $B06B
B17_18_PrepareAdjacencyPtrs = $B08F
B17_18_StrategyModeDispatch = $B144
B17_18_StrategyMode_InitOfficers = $B15A
B17_18_StrategyMode_StoreOfficerSlot = $B1A2
B17_18_StrategyMode_ShowMessage = $B1A6
B17_18_StrategyMode_ShowDialog = $B1BB
B17_18_StrategyMode_LoadPortrait = $B1D4
B17_18_StrategyMode_BuildSpriteData = $B1EE
B17_18_StrategyMode_FinalizeSprites = $B21C
B17_18_StrategyMode_CalcTroopStats = $B230
B17_18_StrategyMode_SetupDisplay = $B2E0
B17_18_TroopAssignmentDispatch = $B34F
B17_18_TroopAssign_SelectTarget = $B361
B17_18_TroopAssign_Execute = $B3F0
B17_18_TroopAssign_ShowMenu = $B407
B17_18_TroopAssign_HandleResult = $B47E
B17_18_TroopAssign_Confirm = $B552
B17_18_TroopAssign_ShowSummary = $B569
B17_18_WarClashDispatch = $B5C8
B17_18_WarClash_CompareForces = $B5D8
B17_18_WarClash_MoraleCheck = $B626
B17_18_WarClash_DefenseCheck = $B659
B17_18_WarClash_OfficerDuel = $B689
B17_18_WarClash_DetermineOutcome = $B719
B17_18_WarClash_SetActionResult = $B7A8
B17_18_WarClash_MoraleCalc = $B7B3
B17_18_WarClash_DefenseCalc = $B7DD
B17_18_WarClash_LeadershipCheck = $B816
B17_18_WarClash_DuelCheck = $B851
B17_18_WarClash_FinalCalc = $B89B
B17_18_WarResultDispatch = $B8C7
B17_18_WarResult_Calculate = $B8D3
B17_18_WarResult_ApplyTroopLoss = $B96D
B17_18_WarResult_ShowVictory = $B9A0
B17_18_WarResult_CheckContinue = $B9A5
B17_18_WarResult_Finalize = $B9C8
B17_18_DuelDispatch = $BA6D
B17_18_Duel_Init  = $BA87
B17_18_Duel_CheckContinue = $BAA5
B17_18_Duel_ShowMenu = $BAC0
B17_18_Duel_PlayerAction = $BADA
B17_18_Duel_RandomEvent = $BB03
B17_18_Duel_ShowMenu2 = $BB41
B17_18_Duel_ApplyDamage = $BB5B
B17_18_Duel_CheckFlee = $BB93
B17_18_Duel_NextRound = $BBC0
B17_18_Duel_CheckEnd = $BC00
B17_18_Duel_SwapActive = $BC16
B17_18_IntrigueDispatch   = $BC3B
B17_18_Intrigue_Init      = $BC47
B17_18_Intrigue_ShowMenu  = $BC5C
B17_18_Intrigue_HandleAction = $BC8C
B17_18_EventCutsceneDispatch = $BCE9
B17_18_EventCutscene_Init = $BCFB
B17_18_EventCutscene_ShowText = $BD1E
B17_18_EventCutscene_Display = $BD40
B17_18_EventCutscene_NoOp = $BD5C
B17_18_EventCutscene_NoEvent = $BD5D
B17_18_EventCutscene_Execute = $BDA9
B17_18_EventCutscene_Cleanup = $BE3F
B17_18_BattleInitDispatch = $BE78
B17_18_BattleInit_Setup   = $BE86
B17_18_BattleInit_Position = $BF43
B17_18_BattleInit_Configure = $BF66
B17_18_BattleInit_Finalize = $BF7E

;-------------------------------------------------------------------------------
; Internal procs - Bank $18 ($C000-$DFFF)
;-------------------------------------------------------------------------------
B17_18_WarSetup_Exec   = $C08A
B17_18_EventCutsceneDispatch2 = $C116
B17_18_EventCutscene2_Init = $C124
B17_18_EventCutscene2_LoadData = $C13A
B17_18_EventCutscene2_Show = $C14A
B17_18_EventCutscene2_Execute = $C187
B17_18_EventCutscene_LoadOverlay = $C1E2
B17_18_MapFadeDispatch    = $C21C
B17_18_MapFade_Init       = $C22A
B17_18_MapFade_FadeIn     = $C256
B17_18_MapFade_Draw       = $C28E
B17_18_MapFade_Complete   = $C2AA
B17_18_MapFade_DrawColumn = $C2CC
B17_18_TerritoryEventDispatch = $C2F6
B17_18_TerritoryEvent_Init = $C30E
B17_18_TerritoryEvent_Check = $C33B
B17_18_TerritoryEvent_Execute = $C35D
B17_18_TerritoryEvent_ApplyResult = $C40B
B17_18_TerritoryEvent_CaptureOfficer = $C42E
B17_18_TerritoryEvent_Finalize = $C44F
B17_18_PaletteTransitionDispatch = $C464
B17_18_PaletteTransition_Copy = $C46E
B17_18_PaletteTransition_Fade = $C480
B17_18_MapScrollDispatch_A = $C498
B17_18_MapScrollA_Init    = $C4AC
B17_18_MapScrollA_Scroll  = $C4C3
B17_18_MapScrollA_Draw    = $C4E9
B17_18_MapScrollA_Update  = $C55A
B17_18_MapScrollA_Animate = $C598
B17_18_MapScrollA_Finalize = $C5D2
B17_18_MapScrollA_Complete = $C66B
B17_18_MapScrollDispatch_B = $C689
B17_18_MapScrollB_Init    = $C69F
B17_18_MapScrollB_Scroll  = $C6B6
B17_18_MapScrollB_Draw    = $C6DC
B17_18_MapScrollB_Update  = $C72D
B17_18_MapScrollB_Animate = $C773
B17_18_MapScrollB_Finalize = $C809
B17_18_MapScrollB_Complete = $C84A
B17_18_MapScrollB_Extra   = $C884
B17_18_MapScrollDispatch_C = $C949
B17_18_MapScrollC_Init    = $C95F
B17_18_MapScrollC_Scroll  = $C976
B17_18_MapScrollC_Draw    = $C99C
B17_18_MapScrollC_Update  = $C9ED
B17_18_MapScrollC_Animate = $CA50
B17_18_MapScrollC_Finalize = $CAB8
B17_18_MapScrollC_Complete = $CAD4
B17_18_MapScrollC_Extra   = $CB0E
B17_18_MapSlideDispatch_A = $CB9E
B17_18_MapSlideA_Init     = $CBAA
B17_18_MapSlideA_Slide    = $CC0A
B17_18_MapSlideA_Complete = $CC62
B17_18_MapSlideDispatch_B = $CC87
B17_18_MapSlideB_Init     = $CC93
B17_18_MapSlideB_Slide    = $CCAA
B17_18_MapSlideB_Complete = $CCD0
B17_18_MapSlideDispatch_C = $CD3C
B17_18_MapSlideC_Init     = $CD48
B17_18_MapSlideC_Slide    = $CD5F
B17_18_MapSlideC_Complete = $CD85
B17_18_BuildPPUTileBuffer = $CDFD
B17_18_DrawSpriteFromBank = $CEA5
B17_18_MapScroll_UpdatePosition = $CEE1
B17_18_ExpandMetatileToSprites = $CFA3
B17_18_FinalizeSpriteBuffer = $D060
B17_18_ReadMenuSelection  = $D13D
B17_18_SetupMenuPtr       = $D166
B17_18_TroopAssign_NextState = $D17C
B17_18_DrawCompletionSprite = $D235
B17_18_CheckPlayerIsRuler = $D262
B17_18_SetDisplayPointer  = $D283
B17_18_CheckButtonConfirm = $D299
B17_18_DomAction_InitOfficerScroll = $D6AA
B17_18_DomAction_ScrollIntroPanel = $D79B
B17_18_DomAction_ScrollTextPhase2 = $D83A
B17_18_DomAction_ScrollAndWait = $D8C9
B17_18_DomAction_FinalizeCleanup = $D920
B17_18_Finalize_Init      = $D932
B17_18_Finalize_SetupUI   = $D950
B17_18_Finalize_WaitConfirm = $D95A
B17_18_Finalize_ScrollTimer = $D976
B17_18_Finalize_PaletteCopy = $D9B4
B17_18_Finalize_NoOp      = $D9C1
B17_18_Finalize_ExitTransition = $D9C2
B17_18_DomAction_MainInteractive = $D9CA
B17_18_DomAction_BuildOfficerList = $D9DE
B17_18_DomAction_InitOfficerDisplay = $DA41
B17_18_DomAction_RenderOfficerEntry = $DA87
B17_18_DomAction_UpdateOfficerDisplay = $DAB6
B17_18_DomAction_ScrollOfficerList = $DAE0
B17_18_DomAction_FinalizeDisplayBuffer = $DB90
B17_18_DomAction_CheckConfirmInput = $DBDA
B17_18_RenderDispatchSprite = $DBF3
B17_18_ScrollPanel_LoadRow = $DC13
B17_18_ScrollPanel_PrepareRowData = $DCE1
B17_18_AnimSeq_Init       = $DE44
B17_18_AnimSeq_PlayFrames = $DE66
B17_18_AnimSeq_HoldFinalFrame = $DEB9
B17_18_AnimSeq_PrepareTransition = $DEC7
B17_18_AnimSeq_ResetScene = $DED6
B17_18_SpriteFromTable    = $DEFA

;-------------------------------------------------------------------------------
; Banks $1D+$1E - Combined 16KB ($A000-$DFFF)
; Jump table entry points ($A000-$A047) - 24 entries
;-------------------------------------------------------------------------------
B1D_1E_PPUTileRender      = $A000   ; PPUTileRender_Entry: PPU tile render
B1D_1E_MenuUpdate         = $A003   ; MenuUpdate_Entry: Menu update
B1D_1E_VRAMBufferWrite    = $A006   ; VRAMBufferWrite_Entry: VRAM buffer write
B1D_1E_StateHandler       = $A009   ; StateHandler_Entry: State handler
B1D_1E_MapDisplaySetup    = $A00C   ; MapDisplaySetup_Entry: Map display setup
B1D_1E_OfficerListHandler = $A00F   ; OfficerListHandler_Entry: Officer list handler
B1D_1E_FlushTileBuffer    = $A012   ; FlushTileBuffer_Entry: Upload 64-byte tile buffer to VRAM
B1D_1E_LoadScenarioData   = $A015   ; LoadScenarioData_Entry: Copy 32 bytes from scenario table
B1D_1E_SramInit           = $A018   ; SramInit_Entry: SRAM initialization
B1D_1E_OfficerParamDisp   = $A01B   ; OfficerParamDisp_Entry: Officer parameter display
B1D_1E_YearDisplaySetup   = $A01E   ; YearDisplaySetup_Entry: Year display setup
B1D_1E_SlowPeriodic       = $A021   ; SlowPeriodic_Entry: Slow periodic overlay refresh
B1D_1E_ImmediateOverlay   = $A024   ; ImmediateOverlay_Entry: Immediate overlay refresh
B1D_1E_ProvinceDataHandler = $A027  ; ProvinceDataHandler_Entry: Province data handler
B1D_1E_OfficerDisplay_Lookup = $A02A ; OfficerDisplay_Lookup_Entry: Officer display lookup
B1D_1E_FastPeriodic       = $A02D   ; FastPeriodic_Entry: Fast periodic overlay refresh
B1D_1E_OfficerDisplay_Render = $A030 ; OfficerDisplay_Render_Entry: Officer display render
B1D_1E_OfficerNameDisplay = $A033   ; OfficerNameDisplay_Entry: Officer name display
B1D_1E_ClearWorkBuffer    = $A036   ; ClearWorkBuffer_Entry: Clear work buffer
B1D_1E_SceneRenderer      = $A039   ; SceneRenderer_Entry: Scene renderer
B1D_1E_DataFormatter      = $A03C   ; DataFormatter_Entry: Data formatter
B1D_1E_MenuRenderer       = $A03F   ; MenuRenderer_Entry: Menu renderer
B1D_1E_BankedDataHandler  = $A042   ; BankedDataHandler_Entry: Banked data handler
B1D_1E_OfficerRecLookup   = $A045   ; OfficerRecLookup_Entry: Officer record lookup

;-------------------------------------------------------------------------------
; Internal procs - Bank $1D code ($A048-$BFFF)
;-------------------------------------------------------------------------------
B1D_1E_PPUTileRender_Proc = $A048   ; PPU tile render procedure
B1D_1E_VRAMBufferWrite_Proc = $A11B ; VRAM buffer write procedure
B1D_1E_MenuUpdate_Proc    = $A154   ; Menu update procedure
B1D_1E_CheckInputAndProcess = $A158 ; Input check and process
B1D_1E_MenuDispatchTable  = $A208   ; Menu command dispatch table
B1D_1E_CmdEndMenu         = $A248   ; Cmd: end menu
B1D_1E_CmdAdvanceRow      = $A281   ; Cmd: advance row
B1D_1E_CmdPushPosition    = $A2A3   ; Cmd: push position
B1D_1E_CmdPopPosition     = $A2C2   ; Cmd: pop position
B1D_1E_CmdSetOverlayMode  = $A2DD   ; Cmd: set overlay mode
B1D_1E_CmdClearOverlayMode = $A2E5  ; Cmd: clear overlay mode
B1D_1E_CmdSetVramPos      = $A2ED   ; Cmd: set VRAM position
B1D_1E_CmdEnableIndirect  = $A310   ; Cmd: enable indirect tiles
B1D_1E_CmdDisableIndirect = $A318   ; Cmd: disable indirect tiles
B1D_1E_CmdSetTileOffset   = $A320   ; Cmd: set tile offset
B1D_1E_CmdDrawName        = $A32D   ; Cmd: draw name
B1D_1E_CmdDrawNameFromParam = $A397 ; Cmd: draw name from param
B1D_1E_CmdDrawNumber      = $A3B1   ; Cmd: draw number
B1D_1E_CmdDrawNameFromData = $A426  ; Cmd: draw name from data
B1D_1E_CmdDrawNameFixed7  = $A4B0   ; Cmd: draw name fixed 7
B1D_1E_CmdDrawFormattedNumber = $A53E ; Cmd: draw formatted number
B1D_1E_DigitTileOffsetTable = $A607 ; Digit tile offset table (8 bytes)
B1D_1E_ClearTileBuffers   = $A60F   ; Clear tile row buffers
B1D_1E_CalcMenuDataPtr    = $A61D   ; Calculate menu data pointer
B1D_1E_BankPageOffsetTable = $A672  ; Bank page offset table (15 words)
B1D_1E_SelectDataBankByPos = $A690  ; Select data bank by position
B1D_1E_PosDataBankTable   = $A6A7   ; Position data bank table (15 bytes)
B1D_1E_YearDisplaySetup_Proc = $A6B6 ; Year display setup procedure
B1D_1E_ProvinceDataHandler_Proc = $A830 ; Province data handler procedure
B1D_1E_ProvinceDisplayTilemap = $A856 ; Province display tilemap
B1D_1E_OfficerDisplay_LookupProc = $A890 ; Officer display lookup procedure
B1D_1E_OfficerDisplayTilemap = $A8C3 ; Officer display tilemap
B1D_1E_OfficerNameDisplay_Proc = $A8FD ; Officer name display procedure
B1D_1E_OfficerNameTilemap = $A91D   ; Officer name tilemap
B1D_1E_DisplayScaledName  = $A957   ; Display scaled katakana name
B1D_1E_FormatNumberPair   = $A96F   ; Format number pair
B1D_1E_DisplayScaledNumber = $A976  ; Display scaled number
B1D_1E_DataFormatter_Proc = $A991   ; Data formatter procedure
B1D_1E_DisplayData_Table  = $AB08   ; Display data table
B1D_1E_DataFormatter_Table1 = $AA37 ; Data formatter table 1
B1D_1E_DataFormatter_Table2 = $AA88 ; Data formatter table 2
B1D_1E_BankedDataHandler_Proc = $AA37 ; Banked data handler procedure
B1D_1E_SetupBankedData    = $AB38   ; Setup banked data
B1D_1E_StateHandler_Proc  = $ABD2   ; State handler procedure
B1D_1E_CountryTemplatePtrs = $AD84  ; Country template pointers (7 entries)
B1D_1E_DrawOfficerName    = $B0AB   ; Draw officer name
B1D_1E_RenderSubState     = $B14C   ; Render sub-state
B1D_1E_SubStateChrTiles   = $B222   ; Sub-state CHR tiles (4 bytes)
B1D_1E_LoadOfficerNameInfo = $B23A  ; Load officer name info
B1D_1E_MapDisplaySetup_Proc = $B29F ; Map display setup procedure
B1D_1E_ProvinceDetailTilemap = $B305 ; Province detail tilemap
B1D_1E_OfficerListHandler_Proc = $B989 ; Officer list handler procedure
B1D_1E_InitOfficerListState = $B9CF ; Init officer list state
B1D_1E_ProcessOfficerListScroll = $BA0E ; Process officer list scroll
B1D_1E_DrawOfficerRecord  = $BB28   ; Draw officer record
B1D_1E_FlushTileBuffer_Proc = $BC41 ; Flush tile buffer procedure
B1D_1E_ClearWorkBuffer_Proc = $BC66 ; Clear work buffer procedure
B1D_1E_SceneRenderer_Proc = $BC71   ; Scene renderer procedure
B1D_1E_MenuRenderer_Proc  = $BE36   ; Menu renderer procedure
B1D_1E_MenuAction00_InitialSetup = $BEBB ; Menu action 00: initial setup
B1D_1E_MenuAction01_DisplaySetup = $BEEB ; Menu action 01: display setup
B1D_1E_MenuAction02_LandReclamation = $BF2F ; Menu action 02: land reclamation (土地の開墾)
B1D_1E_MenuAction03_DisasterPreventionSetup = $BF70 ; Menu action 03: disaster prevention setup (防災)
B1D_1E_MenuAction04_DisasterPrevention = $BFBF ; Menu action 04: disaster prevention (防災)
B1D_1E_MenuAction05_UnidentifiedCmdSetup = $BFF3 ; Menu action 05: unidentified cmd setup (no castle repair exists in-game)
B1D_1E_MenuAction06_UnidentifiedCmd = $C046 ; Menu action 06: unidentified cmd (candidate: ブッシをはこぶ exec)
B1D_1E_MenuAction07_CountryEnd = $C090 ; Menu action 07: country-end event (このクニにフショウはいません)
B1D_1E_MenuAction08_GoldDistribution = $C0C8 ; Menu action 08: gold distribution
B1D_1E_MenuAction09_RiceDistribution = $C123 ; Menu action 09: rice distribution
B1D_1E_MenuAction0A_Conscription = $C168 ; Menu action 0A: conscription (徴兵)
B1D_1E_MenuAction0B_HireOfficer = $C1AC ; Menu action 0B: hire officer
B1D_1E_MenuAction0C_TransferOfficer = $C1FA ; Menu action 0C: transfer officer
B1D_1E_MenuAction0D_UnidentifiedCmd = $C25D ; Menu action 0D: unidentified cmd (no execute command in-game)
B1D_1E_MenuAction0E_UnidentifiedCmd = $C2DD ; Menu action 0E: unidentified cmd (no exile command in-game)
B1D_1E_MenuAction0F_GiveItem = $C33D ; Menu action 0F: give item
B1D_1E_MenuAction10_SuccessorSelection = $C3A2 ; Menu action 10: select country successor (あらたなクンシュをきめます)
B1D_1E_MenuAction11_Intrigue = $C3F6 ; Menu action 11: intrigue (策略)
B1D_1E_MenuAction12_Sortie = $C43E  ; Menu action 12: sortie (出陣)
B1D_1E_MenuAction13_Reconnaissance = $C4E1 ; Menu action 13: reconnaissance (偵察)
B1D_1E_MenuAction14_Market = $C511 ; Menu action 14: 商店 market (タカラなら1つにつきキン100でひきとりましょう)
B1D_1E_MenuAction15_Exchange = $C556 ; Menu action 15: exchange
B1D_1E_MenuAction16_Trade = $C5B1   ; Menu action 16: trade
B1D_1E_MenuAction17_SearchOfficer = $C5F7 ; Menu action 17: search officer
B1D_1E_MenuAction18_SearchItem = $C636 ; Menu action 18: search item
B1D_1E_MenuAction19_UnidentifiedCmd = $C67D ; Menu action 19: unidentified cmd (no inspect command in-game)
B1D_1E_MenuAction1A_OfficerDeath = $C6C6 ; Menu action 1A: an officer dies ([NAME]がシホウしました)
B1D_1E_MenuAction1B_StrategyCommandDispatch = $C75F ; Menu action 1B: strategy command dispatch
B1D_1E_MenuAction1C_CopyTileData = $C7D1 ; Menu action 1C: copy tile data
B1D_1E_MenuAction1D_SetupActionDisplay = $C800 ; Menu action 1D: setup action display
B1D_1E_MenuAction1E_CalcParams = $C830 ; Menu action 1E: calc params
B1D_1E_MenuAction1F_CalcParams2 = $C87D ; Menu action 1F: calc params 2
B1D_1E_MenuAction20_CalcParams3 = $C8B4 ; Menu action 20: calc params 3
B1D_1E_MenuAction21_Finalize = $C8F1 ; Menu action 21: finalize
B1D_1E_MenuAction22_Cleanup = $C926 ; Menu action 22: cleanup

;-------------------------------------------------------------------------------
; Internal procs - Bank $1E ($C000-$DFFF)
;-------------------------------------------------------------------------------
B1D_1E_StrategyMenu_Return = $C934  ; Strategy Mode menu shared return
B1D_1E_SetupDisplayPtrs   = $C96D   ; Setup display pointers
B1D_1E_ResetDispatchState = $C98A   ; Reset dispatch state
B1D_1E_DisplayTileData    = $C994   ; Tile data display engine
B1D_1E_MenuRenderer_SecondaryDispatch = $C9C2 ; Menu renderer secondary dispatch
B1D_1E_SramSaveBlock      = $C9E8   ; SRAM save block
B1D_1E_SramLoadBlock      = $CA4E   ; SRAM load block
B1D_1E_VerifyChecksum     = $CAC5   ; Verify SRAM checksum
B1D_1E_OfficerRecCalc     = $CB52   ; Officer record address calculator
B1D_1E_ProvinceRecCalc    = $CC09   ; Province record address calculator
B1D_1E_MenuTilemapStream  = $CC40   ; Menu tilemap data stream (large)
B1D_1E_LoadScenarioData_Proc = $DBB1 ; Load scenario data procedure
B1D_1E_ScenarioDataTable  = $DBCF   ; Scenario data pointer table
B1D_1E_SramInit_Proc      = $DD8B   ; SRAM init procedure
B1D_1E_OfficerParamDisp_Proc = $DE7E ; Officer parameter display procedure
B1D_1E_OfficerRecLookup_Proc = $DEB9 ; Officer record lookup procedure

;-------------------------------------------------------------------------------
; Bank $19 - Battle overlay strip rendering ($A000-$BFFF)
; Loaded via SwitchBankAC with Y=$39 ($39 & $1F = $19, $C000 slot = $1A)
;-------------------------------------------------------------------------------
B19_OverlayStripRender_Entry = $A000  ; OverlayStripRender_Entry: redraw one battle overlay strip (X = strip 0/1)

;===============================================================================
; SECTION 3: Banked Code at $8000-$9FFF (Slot 0)
; Banks switched via SwitchBank8_B ($F25F) or SwitchBank8_A ($F266)
; TODO: No banked JSR/JMP calls to $8000-$9FFF found in bank $1F yet
;===============================================================================
; Template for future use:
; B00_FunctionName        = $8000

;===============================================================================
; SECTION 4: Banked Code at $C000-$DFFF (Slot 2)
; Banks paired with $A000 slot via SwitchBankAC_B/SwitchBankAC_A
; (bank at $C000 is always Y+1 when $A000 is Y)
;===============================================================================
; (Bank $18 entries removed - now internal to combined prg_17_18.asm)

;===============================================================================
; SECTION 5: Combined Banks $0A+$0B ($A000-$DFFF)
; Bank $0A at $A000-$BFFF paired with Bank $0B at $C000-$DFFF
; Entry points via jump table at $A000-$A00E
; Labels are defined in prg_0a_0b.asm and available globally.
;===============================================================================

;-------------------------------------------------------------------------------
; Jump Table Entry Points ($A000-$A00E)
;-------------------------------------------------------------------------------
B0A_0B_CheckGameStart_Entry = $A000 ; CheckGameStart_Entry: Game start check
B0A_0B_SubStateDispatch_Entry = $A003 ; SubStateDispatch_Entry: Sub-state dispatch
B0A_0B_ArmyValueCalc_Entry = $A006 ; ArmyValueCalc_Entry: Army value calculation
B0A_0B_DataRecordLookup_Entry = $A009 ; DataRecordLookup_Entry: Data record lookup
B0A_0B_DistanceClamp_Entry = $A00C ; DistanceClamp_Entry: Distance clamp

;-------------------------------------------------------------------------------
; Internal procs - Bank $0A ($A00F-$BFFF)
;-------------------------------------------------------------------------------
B0A_0B_CheckGameStart     = $A00F   ; Check game start flag and dispatch
B0A_0B_InitWorkAreas      = $A043   ; Initialize work areas and tier adjust
B0A_0B_ScanMatchData      = $A0D3   ; Scan province match data
B0A_0B_AiActionWeightedDispatch = $A19C ; AI action weighted dispatch
B0A_0B_CountryExpansionCheck = $A1C5 ; Country expansion check
B0A_0B_EndTurn            = $A23D   ; End turn advance
B0A_0B_FindBestEnemyProvince = $A240 ; Find best enemy province to attack
B0A_0B_FindAbsorptionSource = $A303 ; Find absorption source province
B0A_0B_DispatchOfficerArmies = $A45C ; Dispatch officer armies
B0A_0B_ArmyDispatch       = $A481   ; Army dispatch (main army handler)
B0A_0B_TileRender         = $A55C   ; Tile render
B0A_0B_NameTable          = $A60C   ; Name table operations
B0A_0B_LevelTierDispatch = $A6BC   ; Level tier dispatch (army tier by game level)
B0A_0B_CalcArmyTierAndRender = $A6C0 ; Calc army tier and render
B0A_0B_CalcTierWorkPtr    = $A74A   ; Calc tier work pointer
B0A_0B_ResolveCountryAbsorb = $A79C ; Resolve country absorption
B0A_0B_InitNewGameContext = $A8D7   ; Initialize new game context
B0A_0B_EvalProvinceAbsorption = $B10E ; Evaluate province absorption
B0A_0B_AbsorbPreview      = $B1F9   ; Absorb preview
B0A_0B_TransferProvinceValues = $B1FD ; Transfer province values
B0A_0B_AbsorbUpdateRecord = $B287   ; Absorb update record
B0A_0B_FallbackMergeProvinces = $B357 ; Fallback merge provinces
B0A_0B_AiTurnDispatch     = $B49C   ; AI turn dispatch (large state machine)

;-------------------------------------------------------------------------------
; Internal procs - Bank $0B ($C000-$DFFF)
;-------------------------------------------------------------------------------
B0A_0B_FindBestOfficerAssign = $C50E ; Find best officer assignment
B0A_0B_ProcessAllOfficers = $C5B9   ; Process all officers
B0A_0B_EvaluateAndMarkOfficer = $C5D2 ; Evaluate and mark officer (nested)
B0A_0B_CalcActionProb     = $C66F   ; Calculate action probability
B0A_0B_OfficerSearchAndEvaluate = $C79A ; Officer search and evaluate (merged)
B0A_0B_FindBestOfficerByCategory = $C98F ; Find best officer by category
B0A_0B_ApplyScenarioDeductions = $CD68 ; Apply scenario deductions
B0A_0B_BracketDeductArmy  = $CEDD   ; Bracket deduct army
B0A_0B_ArmyValueCalc      = $CF3F   ; Army value calculation
B0A_0B_DataRecordLookup   = $CF7C   ; Data record lookup
B0A_0B_DistanceClamp      = $D00C   ; Distance clamp
B0A_0B_LoadRecord         = $D03A   ; Load record
B0A_0B_CalcPlayerTerritoryValue = $D05D ; Calc player territory value
B0A_0B_CountPlayerProvinces = $D080 ; Count player provinces
B0A_0B_CountValidPlayerProvinces = $D0AA ; Count valid player provinces
B0A_0B_GetProvinceOwner   = $D105   ; Get province owner
B0A_0B_DeductCounterMultiEntry = $D12D ; Deduct counter (multi-entry)
B0A_0B_CollectEnemyProvinces = $D1A4 ; Collect enemy provinces
B0A_0B_CollectEnemyProvincesX = $D1F4 ; Collect enemy provinces (X variant)
B0A_0B_FindPlayerProvinceByValue = $D249 ; Find player province by value
B0A_0B_ReadRecordField    = $D283   ; Read record field
B0A_0B_ReadBankedRecordField = $D2D3 ; Read banked record field
B0A_0B_CountRecordSlots   = $D304   ; Count record slots
B0A_0B_GetPlayerRecordPtr = $D319   ; Get player record pointer
B0A_0B_Divide24           = $D336   ; 24-bit division
B0A_0B_DeductRecordStat2  = $D36F   ; Deduct record stat (2-byte)
B0A_0B_DeductRecordStat4  = $D3A9   ; Deduct record stat (4-byte)
B0A_0B_CompactRecordSlots = $D3DD   ; Compact record slots
B0A_0B_Divide16           = $D40F   ; 16-bit division
B0A_0B_Multiply32         = $D438   ; 32-bit multiply
B0A_0B_Multiply8x8        = $D471   ; 8x8 multiply
B0A_0B_JumpDispatcher     = $D494   ; Jump dispatcher (indexed JMP)
B0A_0B_RandomBelow        = $D4AD   ; Random below threshold
B0A_0B_BuildAdjacencyBitmap = $D4CB ; Build adjacency bitmap
B0A_0B_MergeAdjacencyBits = $D53E   ; Merge adjacency bits
B0A_0B_CheckPathExists    = $D583   ; Check path exists
B0A_0B_DebugStub_E7       = $D5E7   ; Debug stub (RTS)
B0A_0B_ValidateRecordStats = $D5E8  ; Validate record stats
B0A_0B_DebugStub_1E       = $D61E   ; Debug stub (RTS)
B0A_0B_ValidateRecordStatsAlt = $D61F ; Validate record stats (alt)
B0A_0B_ClampRecordStatPairs = $D655 ; Clamp record stat pairs
B0A_0B_ValidateRecordGold = $D688   ; Validate record gold
B0A_0B_ClampRecordStatPairsAlt = $D69D ; Clamp record stat pairs (alt)
B0A_0B_DebugStub_E5       = $D6E5   ; Debug stub (RTS)
B0A_0B_ValidateProvinceSlots = $D6E6 ; Validate province slots
B0A_0B_SubStateDispatch   = $D717   ; Sub-state dispatch
B0A_0B_CallStrategyModeDisplay = $D72A ; Call Strategy Mode display (trampoline to bank $17)
B0A_0B_StackFill          = $D732   ; Stack fill
B0A_0B_FillStackLoop      = $D73C   ; Fill stack loop
B0A_0B_ActionResultDisplay = $D74C  ; Action result display
B0A_0B_StateWait64Frames  = $D799   ; State: wait 64 frames
B0A_0B_StateScrollDown    = $D7BD   ; State: scroll down
B0A_0B_StateSpriteAnim    = $D7EC   ; State: sprite animation
B0A_0B_StateSetupParams   = $D83B   ; State: setup params
B0A_0B_StatePaletteUpdate = $D856   ; State: palette update
B0A_0B_StateSetupMenu     = $D890   ; State: setup menu
B0A_0B_StateTileScroll    = $D8AD   ; State: tile scroll
B0A_0B_StateWriteText     = $D8D9   ; State: write text
B0A_0B_StateWaitInput     = $D8F8   ; State: wait input
B0A_0B_SkipToTileScroll   = $D90D   ; Skip to tile scroll
B0A_0B_RenderOverlay      = $D99C   ; Render overlay
B0A_0B_OverlayInit        = $D9A8   ; Overlay init
B0A_0B_OverlayFillRows    = $D9D0   ; Overlay fill rows
B0A_0B_OverlayCommit      = $DA1B   ; Overlay commit
B0A_0B_ClearOverlay       = $DA7E   ; Clear overlay (7-phase state machine)
B0A_0B_ClearOverlayInit   = $DA95   ; Clear overlay init
B0A_0B_ClearOverlayMenu   = $DAA6   ; Clear overlay menu
B0A_0B_ClearOverlayWait   = $DAFD   ; Clear overlay wait
B0A_0B_ClearOverlayCopyText = $DB2B ; Clear overlay copy text
B0A_0B_ClearOverlayConfirm = $DB7B  ; Clear overlay confirm
B0A_0B_ClearOverlayExit   = $DBC1   ; Clear overlay exit
B0A_0B_ClearOverlayCancel = $DBF1   ; Clear overlay cancel
B0A_0B_VerifySramChecksum = $DC2F   ; Verify SRAM checksum
B0A_0B_CopySramToWork     = $DC97   ; Copy SRAM to work area
B0A_0B_ScrollUpdate       = $DCC8   ; Scroll update
B0A_0B_ScrollDigitWriter  = $DD0F   ; Scroll digit writer
B0A_0B_DrawSelectionSprites = $DD34 ; Draw selection sprites
B0A_0B_WriteSingleSprite  = $DD53   ; Write single sprite
B0A_0B_MenuInputHandler   = $DD79   ; Menu input handler
B0A_0B_SpriteSetup2       = $DEAF   ; Sprite setup (sound-test cursor)
B0A_0B_PaletteCheck       = $DF4C   ; Palette check

;-------------------------------------------------------------------------------
; Data tables - Bank $0A/$0B
;-------------------------------------------------------------------------------
B0A_0B_ArmyDeductionTable = $CEC9   ; Army deduction table
B0A_0B_ArmyResultTable    = $CED3   ; Army result table
B0A_0B_AdjRowOffsets      = $D5BF   ; Adjacency row offsets (31 bytes)
B0A_0B_OverlayTileData    = $DA3F   ; Overlay PPU tile data
B0A_0B_PlayerPtrTable     = $DBD4   ; SRAM player record pointers
B0A_0B_SoundDispatch      = $DE5F   ; Sound dispatch table

;-------------------------------------------------------------------------------
; Aliases (multi-entry proc sub-labels)
;-------------------------------------------------------------------------------
B0A_0B_DeductCounter_ZeroEnd = $D12D ; DeductCounter: game-over at <=0, no unwind
B0A_0B_DeductCounter_Unwind1 = $D12F ; DeductCounter: unwind 1 frame
B0A_0B_DeductCounter_Unwind2 = $D131 ; DeductCounter: unwind 2 frames
B0A_0B_DeductCounter_Unwind3 = $D133 ; DeductCounter: unwind 3 frames
B0A_0B_RandomBelowFull    = $D4AF   ; RandomBelow: full-range entry
B0A_0B_ProvinceEvalExit   = $B17D   ; Common exit -> EndTurn

;===============================================================================
; SECTION 6: Combined Banks $0C+$0D ($A000-$DFFF)
; Bank $0C at $A000-$BFFF paired with Bank $0D at $C000-$DFFF
; Officer Exchange / Strategic Command system
; Loaded via SwitchBankAC with Y=$28
; Entry points via jump table at $A000-$A006
;===============================================================================

;-------------------------------------------------------------------------------
; Jump Table Entry Points ($A000-$A006)
;-------------------------------------------------------------------------------
B0C_0D_ExchangeFrameUpdate_Entry = $A000 ; ExchangeFrameUpdate_Entry: Main frame update
B0C_0D_ExchangeSceneInit_Entry = $A003 ; ExchangeSceneInit_Entry: Exchange scene init
B0C_0D_OfficerTransferCalc_Entry = $A006 ; OfficerTransferCalc_Entry: Transfer calc

;-------------------------------------------------------------------------------
; Internal procs - Bank $0C ($A009-$BFFF)
;-------------------------------------------------------------------------------
B0C_0D_ExchangeFrameUpdate = $A009  ; Main frame update loop
B0C_0D_PhaseDispatch      = $A04E   ; 5-phase exchange flow dispatcher
B0C_0D_OfficerDetailView  = $A21B   ; Officer detail panel display
B0C_0D_OfficerTransferExecute = $A293 ; Officer transfer animation + result
B0C_0D_OfficerMovePhase   = $A44D   ; Officer movement on strategic map
B0C_0D_OfficerCommandPhase = $A87C  ; Command menu, target select, confirm
B0C_0D_ValidateActionTarget = $AD80 ; Per-action validation (14 action types)
B0C_0D_ExecuteAction      = $B02B   ; Per-action execution engine
B0C_0D_CheckActionSuccess = $B72B   ; Action success check (distance + stats)
B0C_0D_CalcDistance       = $B860   ; Hex distance calculation
B0C_0D_BuildNeighborList  = $B8A1   ; Build adjacent tile neighbor list
B0C_0D_ProvinceSelectDispatch = $B94A ; Province selection UI (6 states)
B0C_0D_OfficerTurnDispatch = $BC93  ; Officer turn cycle (8 states)
B0C_0D_OfficerMarchDispatch = $BE7E ; Army march dispatch (17 states)

;-------------------------------------------------------------------------------
; Internal procs - Bank $0D ($C000-$DFFF)
;-------------------------------------------------------------------------------
B0C_0D_MainLoopDispatch   = $C1FC   ; Trampoline back to frame update
B0C_0D_ArmyDeployDispatch = $C204   ; Army deployment (7 states)
B0C_0D_OfficerExchangeDispatch = $C691 ; Exchange init/select/exit (4 states)
B0C_0D_OfficerTransferCalc = $C766 ; Transfer merit calc + action dispatch
B0C_0D_OfficerExchangeConfirmDispatch = $C98C ; Exchange confirmation (6 states)
B0C_0D_RecalcExchangeStats = $CC29 ; Ruler stat recalculation for exchange
B0C_0D_OfficerExchangeSelectDispatch = $CD16 ; Officer selection (7 states)
B0C_0D_OfficerReserveAssignDispatch = $D2CD ; Reserve assignment (7 states)
B0C_0D_ExchangeScene      = $D4F0   ; Exchange scene: map, cursor, rosters, SFX
B0C_0D_ExchangeScene_Init = $DC99   ; Exchange scene initialization
B0C_0D_CenterMapOnOfficer = $DC33   ; Center map viewport on officer
B0C_0D_CheckExchangePossible = $DF27 ; Check if exchange is possible
B0C_0D_SetupExchangeSfx   = $DF39   ; Setup exchange SFX tone
B0C_0D_UpdateExchangeSfx  = $DF88   ; Update exchange SFX by scroll position
;

;===============================================================================
; SECTION 7: Combined Banks $08+$09 ($A000-$DFFF)
; Bank $08 at $A000-$BFFF paired with Bank $09 at $C000-$DFFF
; AI turn processing / battle system
; Loaded via SwitchBankAC with Y=$28 ($28 & $1F = $08)
; Entry points via jump table at $A000-$A02A
;===============================================================================

;-------------------------------------------------------------------------------
; Jump Table Entry Points ($A000-$A02A)
;-------------------------------------------------------------------------------
B08_09_AiTurnProcess_Entry = $A000 ; AiTurnProcess_Entry: AI turn processing
B08_09_WarSetup_Entry  = $A003  ; WarSetup_Entry: Battle setup
B08_09_WarPhaseProcess_Entry = $A006 ; WarPhaseProcess_Entry: Battle phase process
B08_09_AiOfficerActionDispatch_Entry = $A009 ; AiOfficerActionDispatch_Entry: AI officer action dispatch
B08_09_WarCasualtyResolution_Entry = $A00C ; WarCasualtyResolution_Entry: Casualty/morale resolution
B08_09_WarAttritionRound_Entry = $A00F ; WarAttritionRound_Entry: Attrition round
B08_09_WarStatusPanelDraw_Entry = $A012 ; WarStatusPanelDraw_Entry: Status panel draw
B08_09_StratagemTargetMarker_Entry = $A015 ; StratagemTargetMarker_Entry: Stratagem target markers
B08_09_ValidateSpecialOfficer_Entry = $A018 ; ValidateSpecialOfficer_Entry: Special officer validation
B08_09_BuildCommandList_Entry = $A01B ; BuildCommandList_Entry: Command list build
B08_09_ExpandFormationSlots_Entry = $A01E ; ExpandFormationSlots_Entry: Formation slot expansion
B08_09_WarMapScrollUpdate_Entry = $A021 ; WarMapScrollUpdate_Entry: Battle map scroll update
B08_09_WarResultDispatch_Entry = $A024 ; WarResultDispatch_Entry: Battle result dispatch
B08_09_WarResultSceneInit_Entry = $A027 ; WarResultSceneInit_Entry: Battle result scene init
B08_09_WarSlotClear_Entry = $A02A ; WarSlotClear_Entry: Battle slot clear

;-------------------------------------------------------------------------------
; Internal procs - Bank $08 ($A02D-$BFFF)
;-------------------------------------------------------------------------------
B08_09_AiTurnProcess      = $A02D   ; AI turn process (single proc to $B12F)
B08_09_Action_DefaultDecision = $A0B1 ; Action 0: flee/recruit/attack/move chain
B08_09_Action_Regroup     = $A105   ; Action 1: regroup with main force
B08_09_Action_AttackNearest = $A166 ; Action 2: attack nearest enemy
B08_09_GetOrderedDestination = $A1E5 ; Get ordered destination
B08_09_Action_DefendBase  = $A210   ; Action 3: defend capital
B08_09_Action_SweepRange3 = $A2AD   ; Action 4: sweep range 3
B08_09_Action_CaptureProvince = $A329 ; Action 5: capture province
B08_09_Action_RestoreHP   = $A507   ; Action 6: restore HP
B08_09_Action_Idle        = $A606   ; Action 7: idle
B08_09_AiExecuteMove      = $A60C   ; AI movement engine
B08_09_AiScanAdjacentOfficers = $A837 ; Scan adjacent officers
B08_09_AiCheckAttackNearby = $A8A8  ; Check attack nearby
B08_09_AiFindNearbyOfficers = $A8D3 ; Find nearby officers
B08_09_AiFindNearbyOfficers_ScanLoop = $A8E8 ; Multi-entry: scan loop (target in $20/$21)
B08_09_AiCheckFaction     = $A944   ; Check faction (also called from $CB74)
B08_09_AiCheckMove        = $A95C   ; Check move feasibility
B08_09_AiCheckAttackFeasible = $A9CF ; Check attack feasibility
B08_09_AiCheckRecruit     = $AAF8   ; Check recruit feasibility
B08_09_AiRecruitClassTable = $AC65  ; Recruit class table
B08_09_AiCheckActionFeasible = $AC7B ; Stratagem feasibility dispatcher
B08_09_AiFeasible_FireAttack = $ACCE ; Feasible: FireAttack (火計)
B08_09_AiFeasible_PitfallTrap = $ACDB ; Feasible: PitfallTrap (陥穽)
B08_09_AiFeasible_BoatSabotage = $ACE8 ; Feasible: BoatSabotage (乱水)
B08_09_AiFeasible_SupplyBurning = $ACF3 ; Feasible: SupplyBurning (火箭)
B08_09_AiFeasible_CastleRaid = $AD00 ; Feasible: CastleRaid (偽撃転殺)
B08_09_AiFeasible_FriendlyFire = $AD22 ; Feasible: FriendlyFire (共殺)
B08_09_AiFeasible_Enticement = $AD45 ; Feasible: Enticement (籠絡)
B08_09_AiFeasible_Rockfall  = $AD65   ; Feasible: Rockfall (落石)
B08_09_AiFeasible_ChainLink = $AD92   ; Feasible: ChainLink (連環)
B08_09_AiFeasible_TenfoldAmbush = $ADCF ; Feasible: TenfoldAmbush (十面埋伏)
B08_09_AiFeasible_RepeatingCrossbow = $ADFE ; Feasible: RepeatingCrossbow (連弩)
B08_09_AiFeasible_Inferno   = $AE20   ; Feasible: Inferno (劫火)
B08_09_AiFeasible_MysticalStasis = $AE5D ; Feasible: MysticalStasis (奇門遁甲)
B08_09_AiSortNearbyOfficers = $AE93 ; Sort nearby officers
B08_09_AiCheckFlee        = $AF0D   ; Check flee feasibility
B08_09_AiComputeArmyStats = $B067   ; Compute army stats
B08_09_AiComputeBattleStats = $B0B8 ; Compute battle stats
B08_09_WarSetup        = $B130   ; Battle setup
B08_09_GetProvinceRuntimePtr = $B469 ; Get province runtime pointer
B08_09_GetOfficerRecordPtr = $B491  ; Get officer record pointer
B08_09_GetFactionRecordPtr = $B4C2  ; Get faction record pointer
B08_09_FactionRecordPtrTable = $B4D3 ; Faction record pointer table (7 x 8 bytes)
B08_09_GetOfficerRecordPtrBanked = $B4E1 ; Get officer record pointer (banked)
B08_09_CallbackDispatcher = $B517   ; Inline callback dispatcher + math helpers
B08_09_Div24Bit           = $B536   ; 24-bit division
B08_09_Mul24x8            = $B585   ; 24x8 multiply
B08_09_NextRandomByte     = $B5D5   ; Next random byte ($6F92 indexed)
B08_09_RandomTable        = $B5E5   ; 256-byte random permutation table
B08_09_GetTileTerrainClamped = $B6E5 ; Tile terrain lookup (clamped)
B08_09_TileTerrainTable   = $B74B   ; Tile id -> terrain type table
B08_09_TerrainMapPtrTable = $B7CB   ; Zone id -> 16x16 detail map pointer
B08_09_TileBankTable      = $B8BB   ; Zone id -> PRG bank ($8000 window)
B08_09_WarClashResolve = $B933  ; Battle result process (phase 1 handler)
B08_09_WarPhaseProcess = $BAB3   ; Battle phase process dispatcher
B08_09_WarAttackerSetup = $BAC1  ; Attacker setup
B08_09_WarDefenderSetup = $BB3D  ; Defender setup
B08_09_WarExecute      = $BB93   ; Battle execute
B08_09_WarPostProcess  = $BBA0   ; Battle post-process
B08_09_SetupPostWarState = $BBB8 ; Setup post-battle state
B08_09_SwapFirstUnitToFront = $BC00 ; Swap first unit to front
B08_09_DoDispatch         = $BC46   ; Post-battle dispatch
B08_09_BattleUnitMatcher  = $BC6D   ; Battle unit matcher
B08_09_FindDefenderMatch  = $BD96   ; Find defender match
B08_09_CollectUnitsBySide = $BDCD   ; Collect units by side
B08_09_FrontloadFactionUnit = $BE55 ; Frontload faction unit
B08_09_PopulateOfficerArrays = $BE90 ; Populate officer arrays
B08_09_UpdateOfficerCoords = $BF0A  ; Update officer coordinates
B08_09_LoadCoordPair      = $BF9E   ; Load coordinate pair
B08_09_FindNearestThreshold = $BFEC ; Find nearest threshold
B08_09_TurnThresholds     = $C015   ; Turn threshold table
B08_09_SearchThresholdTable = $C01A ; Search threshold table
B08_09_ThresholdResultTable = $C022 ; Threshold result table
B08_09_ApplyCoordDeltas   = $C027   ; Apply coordinate deltas

;-------------------------------------------------------------------------------
; Internal procs - Bank $09 ($C000-$DFFF)
;-------------------------------------------------------------------------------
B08_09_AiOfficerActionDispatch = $C0BB ; AI officer action state machine ($C0BB-$C982)
B08_09_State0_ShowActionPanel = $C0D5 ; State 0: show action panel
B08_09_State0PanelLayout  = $C1DE   ; State 0 panel layout
B08_09_State1_GrowStatA   = $C1EB   ; State 1: grow stat A
B08_09_State2_GrowStatB   = $C2C0   ; State 2: grow stat B
B08_09_State3_CheckOfficerStat = $C392 ; State 3: check officer stat
B08_09_State4_ConsumeAndRestore = $C3E9 ; State 4: consume and restore
B08_09_State4PanelLayout  = $C4AB   ; State 4 panel layout
B08_09_State5_SetupFormation = $C4B8 ; State 5: setup formation
B08_09_State5PanelLayout  = $C512   ; State 5 panel layout
B08_09_FormationIdTable   = $C525   ; Formation id table
B08_09_State6_RenderFormationSprites = $C543 ; State 6: render formation sprites
B08_09_SlotParamTable     = $C61E   ; Slot parameter table
B08_09_State7_ApplyTileEffect = $C62E ; State 7: apply tile effect
B08_09_State7PanelLayout  = $C728   ; State 7 panel layout
B08_09_CheckSpecialTiles  = $C73B   ; Check special tiles
B08_09_State8_WaitForNextCommand = $C7B0 ; State 8: wait for next command
B08_09_State9_RouteNextAction = $C7C8 ; State 9: route next action
B08_09_State9PanelLayout  = $C844   ; State 9 panel layout
B08_09_ExpandFormationSlots = $C851 ; Expand formation slots
B08_09_TileOffsetTable    = $C89E   ; Tile offset table
B08_09_FormationTileLayouts = $C8DE ; Formation tile layouts
B08_09_GetBattleSideOffset = $C93E  ; Get battle side offset
B08_09_CheckAnimQueueDone = $C948   ; Check animation queue done
B08_09_DrawActionMarker   = $C95A   ; Draw action marker
B08_09_ActionMarkerSprite = $C97E   ; Action marker sprite layout
B08_09_WarCasualtyResolution = $C983 ; Battle casualty/morale resolution
B08_09_SetScaleFactor     = $CD06   ; Set scale factor
B08_09_WarAttritionRound = $CD78 ; Battle attrition round
B08_09_WarStatusPanelDraw = $CFA2 ; Battle status panel draw ($CFA2-$D1EC)
B08_09_DrawStratagemTargetMarkers = $D1ED ; Draw stratagem target markers
B08_09_ValidateSpecialOfficer = $D390 ; Validate special officer
B08_09_BuildCommandList   = $D3EE   ; Build command list
B08_09_SlotTierPtrs       = $D509   ; Slot tier pointers
B08_09_SlotList_2         = $D51B   ; Slot list (2 slots)
B08_09_SlotList_4         = $D51E   ; Slot list (4 slots)
B08_09_SlotList_6         = $D523   ; Slot list (6 slots)
B08_09_SlotList_8         = $D52A   ; Slot list (8 slots)
B08_09_SlotList_10        = $D533   ; Slot list (10 slots)
B08_09_SlotList_12        = $D53E   ; Slot list (12 slots)
B08_09_SlotList_14        = $D54B   ; Slot list (14 slots)
B08_09_SlotList_15        = $D55A   ; Slot list (15 slots)
B08_09_SlotList_16        = $D56A   ; Slot list (16 slots)
B08_09_WarMapScrollUpdate = $D57B ; Battle map scroll update
B08_09_WarResultSceneInit = $D66E ; Battle result scene init
B08_09_WarSlotClear    = $D6CD   ; Battle slot clear
B08_09_WarResultDispatch = $D70F ; Battle result dispatch
B08_09_WarResult_SceneTick = $D723 ; Battle result scene tick
B08_09_WarResult_InitRecords = $D73A ; Phase: init records
B08_09_WarResult_OpenMenuWait = $D778 ; Phase: open menu wait
B08_09_WarResult_SelectMenuEntry = $D7B0 ; Phase: select menu entry
B08_09_WarResult_ConfirmMenuWait = $D80C ; Phase: confirm menu wait
B08_09_WarResult_PickEntry = $D844 ; Phase: pick entry
B08_09_WarResult_InspectEntry = $D8A0 ; Phase: inspect entry
B08_09_WarResult_Finalize = $D8E4 ; Phase: finalize
B08_09_WarResultMenuPoll = $D906 ; Battle result menu poll
B08_09_WarResultEntryInit = $D97A ; Battle result entry init
B08_09_WarResult_RowToRecordMap = $DA07 ; Menu row -> record index
B08_09_WarResult_RecordInitTable = $DA0F ; 7 x 4-byte entry records
B08_09_WarResult_EntryOrderList = $DA2B ; Entry order + $FF sentinels
B08_09_WarResult_CursorPosTable = $DA35 ; Cursor (Y,X) base per row
B08_09_WarResult_CursorSpriteLayout = $DA43 ; Single-tile cursor layout
B08_09_WarResultSceneFrameDraw = $DA48 ; Battle result scene frame draw
B08_09_WarResult_FrameSpriteLayout = $DA68 ; 28 OAM records + terminator
B08_09_WarResultCursorSpriteDraw = $DAD9 ; Battle result cursor sprite draw
B08_09_WarResult_MarkerSpriteLayout = $DAF9 ; Single marker sprite layout
B08_09_WarResultReadyCheck = $DAFE ; Battle result ready check
B08_09_WarResultDirRepeat0 = $DB10 ; Direction repeat state 0
B08_09_WarResultDirRepeat1 = $DB62 ; Direction repeat state 1
B08_09_WarResultDirRepeat2 = $DBB4 ; Direction repeat state 2
B08_09_WarResultDirRepeat3 = $DBFF ; Direction repeat state 3
B08_09_WarResultSlotReset = $DC4A ; Battle result slot reset
B08_09_WarResultSlotTemplateApply = $DC9C ; Battle result slot template apply
B08_09_WarResult_SlotRecordPtrs = $DCB7 ; Slot -> record pointers
B08_09_WarResult_SlotRecordTemplate = $DCC5 ; Template values for offsets 2-$10

;===============================================================================
; SECTION 8: Combined Banks $0E+$0F ($A000-$DFFF)
; Bank $0E at $A000-$BFFF paired with Bank $0F at $C000-$DFFF
; Battle Mode overlay + battle animation/sound engine
; Loaded via SwitchBankAC with Y=$2E ($2E & $1F = $0E)
; Entry points via jump table at $A000-$A00C
;===============================================================================

;-------------------------------------------------------------------------------
; Jump Table Entry Points ($A000-$A00C)
;-------------------------------------------------------------------------------
B0E_0F_BattleVBlankFrameUpdate_Entry = $A000 ; BattleVBlankFrameUpdate_Entry: Battle VBlank frame hook
B0E_0F_BattleAnimSoundEngine_Entry = $A003 ; BattleAnimSoundEngine_Entry: Battle scene animation/sound engine
B0E_0F_OfficerBattleExpLevelCheck_Entry = $A006 ; OfficerBattleExpLevelCheck_Entry: Battle exp/level-up
B0E_0F_OfficerStatSumBattleTransfer_Entry = $A009 ; OfficerStatSumBattleTransfer_Entry: Stat-sum exp transfer
B0E_0F_SoundPlayAlt_Entry       = $A00C  ; SoundPlayAlt_Entry: Battle sound channel alternate play entry

;-------------------------------------------------------------------------------
; Internal procs - Bank $0E ($A00F-$BFFF)
;-------------------------------------------------------------------------------
B0E_0F_BattleVBlankFrameUpdate = $A00F ; Battle Mode VBlank frame hook
B0E_0F_BattleOverlayDispatch = $A030 ; Overlay state-machine dispatcher (phase table $A06F)
B0E_0F_Phase0IntroSubDispatch = $A085 ; Phase 0 (intro) sub-dispatch on $0541
B0E_0F_BattleOverlayIntroSkipCheck = $A095 ; Intro sub 0: skip check ($0087 bit7)
B0E_0F_BattleOverlayIntroRosterWalk = $A0D3 ; Intro sub 1: roster cell walk
B0E_0F_BattleOverlayIntroAnimQueue = $A0F9 ; Intro sub 2: enqueue intro anim
B0E_0F_BattleOverlayIntroDataFormatTop = $A119 ; Intro sub 3: format top panel data
B0E_0F_BattleOverlayIntroDataFormatBottomAndAdvance = $A137 ; Intro sub 4: format bottom + advance
B0E_0F_Phase1NextActorSubDispatch = $A15F ; Phase 1 (next-actor select) sub-dispatch
B0E_0F_Phase1CycleInit          = $A16E ; Phase 1 sub 0: cycle init
B0E_0F_Phase1NextActorSelect    = $A183 ; Phase 1 sub 1: roster scan for next actor
B0E_0F_Phase1RoundPass          = $A235 ; Phase 1 sub 2: round pass (no actor found)
B0E_0F_BattleDefeatEventCheck   = $A2A9 ; Per-side defeat event check
B0E_0F_BattleRetreatEventCheck  = $A32F ; Per-side retreat event check
B0E_0F_BattlePlayerRequestPoll  = $A39D ; Player command-request poll
B0E_0F_Phase4ResultSubDispatch  = $A3BC ; Phase 4 (defeat/retreat result) sub-dispatch
B0E_0F_Phase4ResultAdvance      = $A3D0 ; Phase 4 sub 0: defeat entry stall
B0E_0F_Phase4ResultDefeatInputWait = $A3D4 ; Phase 4 sub 1: defeat input wait
B0E_0F_Phase4ResultFlashTrigger = $A3F2 ; Phase 4 sub 2/6: screen flash trigger
B0E_0F_Phase4ResultRetreatInputWait = $A407 ; Phase 4 sub 3: retreat entry input wait
B0E_0F_Phase4ResultDamageApply  = $A488 ; Phase 4 sub 4: damage apply
B0E_0F_Phase4ResultConfirmInput = $A4B5 ; Phase 4 sub 5: confirm input
B0E_0F_Phase4ResultColumnDamageSelect = $A4D8 ; Helper: troop count of selected column
B0E_0F_Phase4ResultColumnStripSelect = $A4E6 ; Helper: strip flag of selected column
B0E_0F_Phase2ActionSubDispatch  = $A4F7 ; Phase 2 (command resolution) sub-dispatch
B0E_0F_Phase2ActionGate         = $A519 ; Phase 2 sub 0: command value routing gate
B0E_0F_Phase2CursorWalkInit     = $A5C4 ; Phase 2 sub 1: cursor walk init
B0E_0F_Phase2CursorWalkStep     = $A5F3 ; Phase 2 sub 2: cursor walk animation step
B0E_0F_Phase2TurnPassReset      = $A606 ; Turn-pass reset (two entry paths)
B0E_0F_Phase2MoveEventCheck     = $A61D ; Phase 2 sub 3: move path event gate
B0E_0F_Phase2MoveCommit         = $A654 ; Phase 2 sub 4: move commit
B0E_0F_Phase2CursorBlinkIfActive = $A6D0 ; Conditional cursor column blink
B0E_0F_Phase2ActionEndWait      = $A6E4 ; Phase 2 sub 5: action anim done wait
B0E_0F_Phase2AttackSetup        = $A702 ; Phase 2 sub 6: attack setup
B0E_0F_Phase2AttackArrowAnim    = $A72E ; Phase 2 sub 7: attack arrow animation
B0E_0F_Phase2AttackAnimCount    = $A74A ; Phase 2 sub 8: attack marker count
B0E_0F_Phase2AttackDamageApply  = $A75B ; Phase 2 sub 9: attack damage apply
B0E_0F_Phase2DamageSurvived     = $A7B2 ; Damage-survived path of damage apply
B0E_0F_Phase2DamagePanelUpdate  = $A7C5 ; Damage-number panel update setup
B0E_0F_Phase2ActionDoneWait     = $A7E0 ; Phase 2 sub $A: action done wait
B0E_0F_Phase2ColumnResetCheck   = $A7FE ; Side-event pending column reset check
B0E_0F_Phase2AttackComputeDefended = $A84D ; Damage compute: defended target
B0E_0F_Phase2AttackComputeWithBonus = $A871 ; Damage compute: main attack + bonus
B0E_0F_Phase2PercentScale       = $A8CF ; A = A * Y / 100 percent scale
B0E_0F_Phase2AttackDamageCompute = $A8F2 ; Core attack damage compute
B0E_0F_Phase2CursorStep         = $A9A0 ; Walk position one-cell step
B0E_0F_Phase2CommitMarkerAdjust = $A9BD ; Commit walk into column row markers
B0E_0F_Phase2CursorStepFast     = $A9E6 ; Walk position double step
B0E_0F_Phase2ColumnStatusEncode = $AA0F ; Encode acting unit into column status
B0E_0F_Phase3CommandSubDispatch = $AA23 ; Phase 3 (command selection) sub-dispatch
B0E_0F_Phase3CommandPanelInit   = $AA4A ; Phase 3 sub 0: command panel init
B0E_0F_Phase3CommandAnimStep    = $AABD ; Phase 3 sub 1: panel anim step
B0E_0F_Phase3CommandInput       = $AAF0 ; Phase 3 sub 2: player command input
B0E_0F_Phase3CommandConfirmWait = $AB75 ; Phase 3 sub 3: confirm wait
B0E_0F_Phase3CommandResultWait  = $AB9A ; Phase 3 sub 4: result wait
B0E_0F_Phase3CommandDirInput    = $ABC3 ; Command menu direction input handler
B0E_0F_Phase3CommandArrowDraw   = $AC73 ; Command menu selection arrow sprite
B0E_0F_Phase3CommandMarkerUpdate = $ACA8 ; Command menu target marker refresh
B0E_0F_Phase8PanelSubDispatch   = $ACC5 ; Phase 8 (point-spend panel) sub-dispatch
B0E_0F_Phase8PanelInit          = $ACEC ; Phase 8 sub 0: panel init
B0E_0F_Phase8PanelScriptStep    = $AD3C ; Phase 8 sub 1: script step wait
B0E_0F_Phase8PanelMenuInput     = $AD5D ; Phase 8 sub 2: row selection input
B0E_0F_Phase8PanelConfirmWait   = $AE11 ; Phase 8 sub 3: confirm wait
B0E_0F_Phase8PanelReturnToCommand = $AE6C ; Return to phase 3 sub 3
B0E_0F_Phase8PanelAdvanceWait   = $AE8E ; Phase 8 sub 4: advance wait
B0E_0F_Phase8PanelReturnToCommandDup = $AEAE ; Unreferenced dup of ReturnToCommand
B0E_0F_Phase8RowEffectDispatch  = $AF11 ; Purchased row effect dispatch
B0E_0F_Phase8RowStatCheck       = $AF26 ; Row 1: stat check (siege auto-fail)
B0E_0F_Phase8RowCoinFlip        = $AFD2 ; Row 0: coin flip effect
B0E_0F_Phase8RowCounter574      = $AFF6 ; Row effect: status counter $0574 <- 4
B0E_0F_Phase8RowCounter575      = $B00E ; Row 2: status counter $0575 <- 3
B0E_0F_Phase8RowCounter576      = $B02E ; Row 3: status counter $0576 <- 4
B0E_0F_Phase8RowReloadRoll      = $B066 ; Reload roll: A + 5 + rand[0,5)
B0E_0F_Phase8RowCounter577      = $B07C ; Row 4: status counter $0577 <- 3
B0E_0F_Phase8RowAdvance         = $B09C ; Row 5: leave panel -> phase 9
B0E_0F_Phase8RowScriptQueue     = $B0AC ; Queue row script into VRAM script buffer
B0E_0F_BattleSideStatusCountersDecrement = $B15B ; Per-frame status counter tick-down
B0E_0F_Phase9AdvanceSubDispatch = $B1EC ; Phase 9 (formation advance) sub-dispatch
B0E_0F_Phase9AdvanceInit        = $B211 ; Phase 9 sub 0: marker OAM init
B0E_0F_Phase9AdvanceAnimFrame   = $B25B ; Phase 9 sub 1: 32-frame advance animation
B0E_0F_Phase9AdvanceComplete    = $B2A9 ; Advance animation off-strip exit
B0E_0F_Phase9AdvanceMarkerRender = $B2AC ; Advance marker draw
B0E_0F_Phase9AdvanceContactTick = $B2F5 ; Phase 9 sub 2: contact-damage tick
B0E_0F_Phase9AdvanceRosterSweep = $B3EF ; Phase 9 sub 3: roster slot sweep
B0E_0F_Phase9AdvanceFinish      = $B440 ; Shared advance-finish block
B0E_0F_Phase9AdvanceContactScan = $B44B ; Contact-damage tile scan
B0E_0F_Phase9AdvanceContactCheck = $B48A ; Slot proximity check vs marker
B0E_0F_Phase9AdvanceContactApply = $B4AA ; Apply rolled contact damage
B0E_0F_Phase9AdvanceDamageRoll  = $B4E3 ; Contact-damage roll
B0E_0F_BattleRosterSetup        = $B548 ; Build both sides' battle rosters
B0E_0F_BattleAnimQueueIdleCheck = $B870 ; Anim queue status in carry (C=1 idle)
B0E_0F_BattleCellRedraw         = $B882 ; Battlefield cell rebuild (dual-queue)
B0E_0F_BattleCellTroopCountDigitOverlay = $BA18 ; Troop-count digit overlay helper
B0E_0F_BattleCellAdjacencyScan  = $BA56 ; Occupancy adjacency scan into attr byte
B0E_0F_BattleCellSlotAdjacencyMerge = $BA79 ; Slot occupancy mask merge
B0E_0F_Phase2CursorArrowDraw    = $BB8F ; Walk-cursor arrow sprite draw
B0E_0F_Phase2AttackArrowSprSubmit = $BE76 ; Attack arrow sprite submit
B0E_0F_Phase2AttackMarkerSprSubmit = $BF15 ; 2x2 attack-marker sprite submit
B0E_0F_BattleSideStatusCounterDraw = $BF4C ; Status counter bytes $0574-$0577 redraw

;-------------------------------------------------------------------------------
; Internal procs - Bank $0F ($C01B-$DFFF)
;-------------------------------------------------------------------------------
B0E_0F_BattleChrBankAnimate     = $C01B ; Per-VBlank battle CHR bank animation
B0E_0F_Phase2WalkDirectionResolve = $C064 ; Walk-direction resolver (phase 2 gate)
B0E_0F_Phase2StepTileProbe      = $C1CD ; Step-tile probe shared by resolvers
B0E_0F_Phase2MoveRouteResolve   = $C20F ; Move-route direction resolver
B0E_0F_Phase2AttackRouteResolve = $C30F ; Attack-route resolver
B0E_0F_BattleSlotSideCompare    = $C827 ; Side-relation compare for roster slots
B0E_0F_Phase3CommandMarkerRender = $C839 ; Command-menu value marker draw
B0E_0F_FormationConfirmPromptDraw = $C8FD ; Blinking "press A" confirm prompt sprite
B0E_0F_BattleSideCombatStatsInit = $C926 ; Pre-battle combat-parameter setup
B0E_0F_BattleOverlayTotalRefresh = $CA3F ; Commit troop state into roster records
B0E_0F_Phase2ArrowPathTileCheck = $CAC8 ; Line-of-fire tile check
B0E_0F_BattleTerrainPassabilityCheck = $CAF9 ; Terrain passability vs army affinity
B0E_0F_BattlePanelStatsRefresh  = $CBF1 ; Status panel troop field block rebuild
B0E_0F_BattleInputPromptDraw    = $CCA8 ; Blinking input-prompt sprite draw
B0E_0F_BattlePadStateFetch      = $CCDE ; Mode-filtered controller state fetch
B0E_0F_BattleBothPadsStateFetch = $CD22 ; Both pads merged state fetch
B0E_0F_Phase5SideEventSubDispatch = $CD43 ; Phase 5 (side event) sub-dispatch
B0E_0F_Phase5SideEventRosterCommit = $CD4F ; Phase 5 sub 0: roster commit
B0E_0F_Phase5SideEventPanelSetup = $CD59 ; Phase 5 sub 1: panel setup
B0E_0F_Phase5SideEventClose     = $CDCF ; Phase 5 sub 2: event close
B0E_0F_Phase5RetreatSlotMark    = $CE10 ; Helper: retreat slot mark
B0E_0F_Phase6FormationSelectSubDispatch = $CE25 ; Phase 6 (side A formation) sub-dispatch
B0E_0F_Phase6FormationPanelInit = $CE33 ; Phase 6 sub 0: panel init
B0E_0F_Phase6FormationMenuInput = $CE68 ; Phase 6 sub 1: menu input
B0E_0F_Phase6FormationConfirmWait = $CEAE ; Phase 6 sub 2: confirm wait
B0E_0F_Phase6AdvanceToSideBFormation = $CEFA ; Phase 6 sub 3: advance to phase 7
B0E_0F_FormationSelectMenu      = $CF05 ; Side-wrapped 4-wide formation menu
B0E_0F_Phase7FormationSelectSubDispatch = $CF67 ; Phase 7 (side B formation) sub-dispatch
B0E_0F_Phase7FormationPanelInit = $CF77 ; Phase 7 sub 0: panel init
B0E_0F_Phase7FormationPanelOpen = $CF9D ; Phase 7 sub 1: panel open
B0E_0F_Phase7FormationMenuInput = $CFC2 ; Phase 7 sub 2: menu input
B0E_0F_Phase7FormationConfirmWait = $D008 ; Phase 7 sub 3: confirm wait
B0E_0F_Phase7BattleModeStart    = $D054 ; Phase 7 sub 4: Battle Mode start
B0E_0F_Phase1AiSideRefresh      = $D067 ; Phase-1 AI side refresh helper
B0E_0F_AiTacticSpendDispatch    = $D0AE ; AI tactic-point spend dispatch
B0E_0F_AiBattleOrderAssign      = $D0CB ; Battle order slot assignment
B0E_0F_AiCommanderRoutCheck     = $D1D8 ; AI commander rout check
B0E_0F_AiArmyRoutCheck          = $D2D4 ; AI whole-army rout check
B0E_0F_BattleOutnumberedCheck   = $D32A ; Side strength comparison
B0E_0F_AiTacticPointSpend       = $D3C7 ; AI tactic point spend engine
B0E_0F_PhaseATauntSubDispatch   = $D6BA ; Phase $A (AI taunt scene) sub-dispatch
B0E_0F_PhaseATauntSceneOpen     = $D6CC ; Taunt sub 0: opening beat
B0E_0F_PhaseATauntSceneAdvanceWait = $D6DD ; Taunt sub 1: advance wait
B0E_0F_PhaseATauntStripRedraw   = $D72B ; Taunt overlay strip redraw helper
B0E_0F_PhaseATauntSceneStep     = $D743 ; Taunt sub 4: scene step
B0E_0F_PhaseATauntSceneChoice   = $D77F ; Taunt sub 5: two-row choice menu
B0E_0F_OfficerBattleExpLevelCheck = $D7FB ; Battle experience accrual and level-up check
B0E_0F_OfficerStatSumBattleTransfer = $D8B0 ; Donor Might+Intelligence -> recipient exp
B0E_0F_BattleAnimSoundEngine    = $D8D4 ; Battle animation script + sound engine
B0E_0F_BattleSoundChannelProc   = $DC59 ; Sound channel processing engine

;-------------------------------------------------------------------------------
; Aliases (multi-entry proc sub-labels)
;-------------------------------------------------------------------------------
B0E_0F_SoundPlayAlt             = $DF6E ; BattleSoundChannelProc::SoundPlayAlt (alternate play entry)

.endif ; GUARD_FUNCTIONS_H
