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
B1F_State_KingdomSelect   = $E18B   ; State 3: Kingdom select, scenario/normal
B1F_State_RandomDisplay28 = $E221   ; State 4: Random + display (Y=$28)
B1F_State_DomesticAffairs = $E22F   ; State 5: Domestic affairs, action select
B1F_DomesticActionLookup  = $E29C   ; Domestic action display by $0544
B1F_DomesticGraphicPtrs   = $E2C2   ; 7 graphic pointers for domestic actions
B1F_DomesticBaseDataPtrs  = $E2D0   ; Base data pointers for domestic display
B1F_DomesticSpriteYPos    = $E2DE   ; Sprite Y position table (4 bytes)
B1F_State_RandomAdvance1  = $E2E2   ; State 6: Pure RNG advance
B1F_State_BattlePhase     = $E2E8   ; State 7: Battle phase, army status
B1F_State_RandomAdvance2  = $E36A   ; State 8: Pure RNG advance
B1F_DisplayInit           = $E370   ; Display init: window clear + bank display
B1F_State_TerritoryView   = $E37C   ; State 9: Territory/map view
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
B1F_GetNameDisplayScale   = $F308   ; Hero kata name: id*10+$901A + width
B1F_NameScaleTable        = $F35F   ; Kata name character width table
B1F_GetRulerDataPtr       = $F368   ; Ruler data from pointer table
B1F_RulerDataPtrTable     = $F379   ; 7 kingdom SRAM pointers
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
B1F_NmiState5_Diplomacy   = $F9A0   ; NMI state 5: Diplomacy rendering
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
; Bank $3D - Primary display/gameplay bank
; Called from state handlers (default) and NMI sub-dispatch
;-------------------------------------------------------------------------------
B3D_RenderScene           = $A000   ; Scene rendering (generic display)
B3D_RenderMap             = $A003   ; Map/battle/UI rendering (most common)
B3D_ScenarioAction        = $A006   ; Scenario/action display
B3D_InputAndRender        = $A009   ; Input handling + render pass
B3D_WeatherEffects        = $A00C   ; Weather/battle effects (NMI dispatch)
B3D_BattleEffects         = $A00F   ; Battle effects processing (NMI dispatch)
B3D_BattleDispatch        = $A012   ; Battle dispatch (NMI dispatch)
B3D_OverlayDisplay        = $A015   ; Overlay/window display
B3D_AdvisorDialogue       = $A018   ; Advisor dialogue rendering
B3D_DisplayAndChrSetup    = $A01B   ; Display + CHR setup (from DisplayInit)
B3D_OfficerManagement     = $A01E   ; Officer management display
B3D_DomesticDisplay       = $A024   ; Domestic affairs display
B3D_KingdomDisplay        = $A027   ; Kingdom select display
B3D_TurnSummaryExtra      = $A03F   ; Turn summary extra rendering
B3D_BankedPaletteUpload   = $A045   ; Banked palette upload variant

;-------------------------------------------------------------------------------
; Bank $3B - NMI rendering
;-------------------------------------------------------------------------------
B3B_RenderScene           = $A000   ; Scene rendering (NMI context)

;-------------------------------------------------------------------------------
; Bank $39 - NMI battle
;-------------------------------------------------------------------------------
B39_BattleEffects         = $A00F   ; Battle effects (NMI context)

;-------------------------------------------------------------------------------
; Banks $17+$18 - Domestic/Kingdom display (combined 16KB $A000-$DFFF)
; Loaded via SwitchBankAC with Y=$37
;
; Jump table entry points ($A000-$A029)
;-------------------------------------------------------------------------------
B17_18_PpuWriteRle        = $A000   ; Entry00: RLE-encoded PPU data writer
B17_18_PpuCopyRaw         = $A003   ; Entry01: Raw 1KB PPU data copy
B17_18_PpuWriteTileOffset = $A006   ; Entry02: PPU tile data write with offset
B17_18_DisplayScrollLoop  = $A009   ; Entry03: Display scroll and render loop
B17_18_DisplayAndChrSetup = $A00C   ; Entry04: Display coordinate check + CHR setup
B17_18_BattleEffects      = $A00F   ; Entry05: Battle visual effects
B17_18_BattleDispatch     = $A012   ; Entry06: Battle dispatch
B17_18_OverlayWindow      = $A015   ; Entry07: Overlay/window rendering
B17_18_SetupAdvisorTiles  = $A018   ; Entry08: Setup advisor/council tiles
B17_18_MainGameDispatch   = $A01B   ; Entry09: Main game mode dispatcher
B17_18_DomesticActionDispatch = $A01E ; Entry0A: Domestic action dispatcher
B17_18_AnimationDispatch  = $A021   ; Entry0B: Animation dispatch
B17_18_DomesticDisplay    = $A024   ; Entry0C: Domestic affairs display
B17_18_DataRecordLoader   = $A027   ; Entry0D: Data record loader

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
B17_18_DomesticAffairsDispatch = $B144
B17_18_DomesticAffairs_InitOfficers = $B15A
B17_18_DomesticAffairs_StoreOfficerSlot = $B1A2
B17_18_DomesticAffairs_ShowMessage = $B1A6
B17_18_DomesticAffairs_ShowDialog = $B1BB
B17_18_DomesticAffairs_LoadPortrait = $B1D4
B17_18_DomesticAffairs_BuildSpriteData = $B1EE
B17_18_DomesticAffairs_FinalizeSprites = $B21C
B17_18_DomesticAffairs_CalcTroopStats = $B230
B17_18_DomesticAffairs_SetupDisplay = $B2E0
B17_18_TroopAssignmentDispatch = $B34F
B17_18_TroopAssign_SelectTarget = $B361
B17_18_TroopAssign_Execute = $B3F0
B17_18_TroopAssign_ShowMenu = $B407
B17_18_TroopAssign_HandleResult = $B47E
B17_18_TroopAssign_Confirm = $B552
B17_18_TroopAssign_ShowSummary = $B569
B17_18_CombatCalcDispatch = $B5C8
B17_18_CombatCalc_CompareForces = $B5D8
B17_18_CombatCalc_MoraleCheck = $B626
B17_18_CombatCalc_DefenseCheck = $B659
B17_18_CombatCalc_OfficerDuel = $B689
B17_18_CombatCalc_DetermineOutcome = $B719
B17_18_CombatCalc_SetActionResult = $B7A8
B17_18_CombatCalc_MoraleCalc = $B7B3
B17_18_CombatCalc_DefenseCalc = $B7DD
B17_18_CombatCalc_LeadershipCheck = $B816
B17_18_CombatCalc_DuelCheck = $B851
B17_18_CombatCalc_FinalCalc = $B89B
B17_18_BattleResultDispatch = $B8C7
B17_18_BattleResult_Calculate = $B8D3
B17_18_BattleResult_ApplyTroopLoss = $B96D
B17_18_BattleResult_ShowVictory = $B9A0
B17_18_BattleResult_CheckContinue = $B9A5
B17_18_BattleResult_Finalize = $B9C8
B17_18_SingleCombatDispatch = $BA6D
B17_18_SingleCombat_Init  = $BA87
B17_18_SingleCombat_CheckContinue = $BAA5
B17_18_SingleCombat_ShowMenu = $BAC0
B17_18_SingleCombat_PlayerAction = $BADA
B17_18_SingleCombat_RandomEvent = $BB03
B17_18_SingleCombat_ShowMenu2 = $BB41
B17_18_SingleCombat_ApplyDamage = $BB5B
B17_18_SingleCombat_CheckFlee = $BB93
B17_18_SingleCombat_NextRound = $BBC0
B17_18_SingleCombat_CheckEnd = $BC00
B17_18_SingleCombat_SwapActive = $BC16
B17_18_DiplomacyDispatch  = $BC3B
B17_18_Diplomacy_Init     = $BC47
B17_18_Diplomacy_ShowMenu = $BC5C
B17_18_Diplomacy_HandleAction = $BC8C
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
B17_18_BattleSetup_Exec   = $C08A
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
; Bank $2E - NMI rendering
;-------------------------------------------------------------------------------
B2E_RenderScene           = $A000   ; Scene rendering (NMI context)
B2E_RenderMap             = $A003   ; Map rendering (NMI context)

;-------------------------------------------------------------------------------
; Bank $2C - NMI rendering
;-------------------------------------------------------------------------------
B2C_RenderScene           = $A000   ; Scene rendering (NMI context)

;-------------------------------------------------------------------------------
; Bank $2A - NMI rendering
;-------------------------------------------------------------------------------
B2A_RenderMap             = $A003   ; Map rendering (NMI context)

;-------------------------------------------------------------------------------
; Bank $28 - NMI domestic
;-------------------------------------------------------------------------------
B28_DomesticDisplay       = $A024   ; Domestic display (NMI context)

;-------------------------------------------------------------------------------
; Banks $1D+$1E - Combined 16KB ($A000-$DFFF)
; Jump table entry points ($A000-$A047) - 24 entries
;-------------------------------------------------------------------------------
B1D_1E_PPUTileRender      = $A000   ; Entry00: PPU tile render
B1D_1E_MenuUpdate         = $A003   ; Entry01: Menu update
B1D_1E_VRAMBufferWrite    = $A006   ; Entry02: VRAM buffer write
B1D_1E_StateHandler       = $A009   ; Entry03: State handler
B1D_1E_MapDisplaySetup    = $A00C   ; Entry04: Map display setup
B1D_1E_OfficerListHandler = $A00F   ; Entry05: Officer list handler
B1D_1E_FlushTileBuffer    = $A012   ; Entry06: Upload 64-byte tile buffer to VRAM
B1D_1E_LoadScenarioData   = $A015   ; Entry07: Copy 32 bytes from scenario table
B1D_1E_SramInit           = $A018   ; Entry08: SRAM initialization
B1D_1E_OfficerParamDisp   = $A01B   ; Entry09: Officer parameter display
B1D_1E_YearDisplaySetup   = $A01E   ; Entry10: Year display setup
B1D_1E_SlowPeriodic       = $A021   ; Entry11: Slow periodic overlay refresh
B1D_1E_ImmediateOverlay   = $A024   ; Entry12: Immediate overlay refresh
B1D_1E_ProvinceDataHandler = $A027  ; Entry13: Province data handler
B1D_1E_OfficerDisplay_Lookup = $A02A ; Entry14: Officer display lookup
B1D_1E_FastPeriodic       = $A02D   ; Entry15: Fast periodic overlay refresh
B1D_1E_OfficerDisplay_Render = $A030 ; Entry16: Officer display render
B1D_1E_OfficerNameDisplay = $A033   ; Entry17: Officer name display
B1D_1E_ClearWorkBuffer    = $A036   ; Entry18: Clear work buffer
B1D_1E_SceneRenderer      = $A039   ; Entry19: Scene renderer
B1D_1E_DataFormatter      = $A03C   ; Entry20: Data formatter
B1D_1E_MenuRenderer       = $A03F   ; Entry21: Menu renderer
B1D_1E_BankedDataHandler  = $A042   ; Entry22: Banked data handler
B1D_1E_OfficerRecLookup   = $A045   ; Entry23: Officer record lookup

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
B1D_1E_KingdomTemplatePtrs = $AD84  ; Kingdom template pointers (4 entries)
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
B1D_1E_MenuAction02_LandDevelop = $BF2F ; Menu action 02: land development
B1D_1E_MenuAction03_FloodControlSetup = $BF70 ; Menu action 03: flood control setup
B1D_1E_MenuAction04_FloodControl = $BFBF ; Menu action 04: flood control
B1D_1E_MenuAction05_CastleRepairSetup = $BFF3 ; Menu action 05: castle repair setup
B1D_1E_MenuAction06_CastleRepair = $C046 ; Menu action 06: castle repair
B1D_1E_MenuAction07_TaxRate = $C090 ; Menu action 07: tax rate
B1D_1E_MenuAction08_GoldDistribution = $C0C8 ; Menu action 08: gold distribution
B1D_1E_MenuAction09_FoodDistribution = $C123 ; Menu action 09: food distribution
B1D_1E_MenuAction0A_RecruitSoldiers = $C168 ; Menu action 0A: recruit soldiers
B1D_1E_MenuAction0B_HireOfficer = $C1AC ; Menu action 0B: hire officer
B1D_1E_MenuAction0C_TransferOfficer = $C1FA ; Menu action 0C: transfer officer
B1D_1E_MenuAction0D_ExecuteOfficer = $C25D ; Menu action 0D: execute officer
B1D_1E_MenuAction0E_ExileOfficer = $C2DD ; Menu action 0E: exile officer
B1D_1E_MenuAction0F_GiveItem = $C33D ; Menu action 0F: give item
B1D_1E_MenuAction10_MoveCapital = $C3A2 ; Menu action 10: move capital
B1D_1E_MenuAction11_Diplomacy = $C3F6 ; Menu action 11: diplomacy
B1D_1E_MenuAction12_War   = $C43E   ; Menu action 12: war
B1D_1E_MenuAction13_Spy   = $C4E1   ; Menu action 13: spy
B1D_1E_MenuAction14_Accounting = $C511 ; Menu action 14: accounting
B1D_1E_MenuAction15_Exchange = $C556 ; Menu action 15: exchange
B1D_1E_MenuAction16_Trade = $C5B1   ; Menu action 16: trade
B1D_1E_MenuAction17_SearchOfficer = $C5F7 ; Menu action 17: search officer
B1D_1E_MenuAction18_SearchItem = $C636 ; Menu action 18: search item
B1D_1E_MenuAction19_InspectLand = $C67D ; Menu action 19: inspect land
B1D_1E_MenuAction1A_PersonalAffairs = $C6C6 ; Menu action 1A: personal affairs
B1D_1E_MenuAction1B_DomesticDispatch = $C75F ; Menu action 1B: domestic dispatch
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
B1D_1E_DomesticMenu_Return = $C934  ; Domestic menu return / shared return
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
; Jump Table Entry Points:
;   B0A_Entry00 ($A000) -> B0A_MainDispatch
;   B0A_Entry01 ($A003) -> B0B_SubStateDispatch
;   B0A_Entry02 ($A006) -> B0B_ArmyValueCalc
;   B0A_Entry03 ($A009) -> B0B_DataRecordLookup
;   B0A_Entry04 ($A00C) -> B0B_DistanceClamp
;
