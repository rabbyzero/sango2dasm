;===============================================================================
; functions.h - Symbolic Function and Data Label Definitions
; Sangokushi 2 - Haou no Tairiku (J) / Namco-163 (Mapper 19)
;
; Defines symbolic names for all known functions and data labels.
; Include from any .asm file:  .include "functions.h"
;
; Naming Convention: Bxx_yy_FunctionName for a switchable bank pair (e.g.
;   B1D_1E_...), Bxx_FunctionName for a single bank (B1F_ for the fixed engine
;   bank $1F, B02_ for the singly-mapped sound-data window)
;   XX/yy = PRG bank number (hex, $00-$1F)
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
B1F_StateDispatch         = $E066   ; Jump to handler via VectorTable[duel_state]
B1F_VectorTable           = $E07C   ; State dispatch table (15 entries, 2 bytes each)
B1F_State_SystemInit      = $E09A   ; State 0: System init, PPU setup, -> state 9
B1F_State_StrategyMapLaunch = $E0DA   ; State 1: launch the Strategy Mode map screen (sub-state 2, uploads bank $10 $8000, arms $6F8B mailbox, music $81)
B1F_State_StrategyAiTurnFrame = $E17D   ; State 2: strategy AI turn frame (Y=$2A -> bank $0A+$0B)
B1F_State_WarSceneLaunch  = $E18B   ; State 3: war scene launch, dispatch on $0500 ($0B = officer-transfer commit, else WarSetup battle deployment) -> state 4
B1F_State_WarAiTurnFrame = $E221   ; State 4: War/tactical AI turn frame (Y=$28 -> bank $08+$09, AiTurnProcess)
B1F_State_StrategyMode    = $E22F   ; State 5: Strategy mode, command select
B1F_StrategyCommandLookup = $E29C   ; Strategy command display by $0544
B1F_StrategyCommandGraphicPtrs = $E2C2 ; 7 graphic pointers for strategy commands
B1F_StrategyCommandBaseDataPtrs = $E2D0 ; Base data pointers for strategy display
B1F_StrategyCommandSpriteYPos = $E2DE ; Sprite Y position table (4 bytes)
B1F_State_RandomAdvance1  = $E2E2   ; State 6: Pure RNG advance
B1F_State_DuelSceneLaunch = $E2E8   ; State 7: Duel Mode launch (sub-state 5 -> NmiState5_Duel, uploads bank $10 $8400, duel music $12)
B1F_State_RandomAdvance2  = $E36A   ; State 8: Pure RNG advance
B1F_DisplayInit           = $E370   ; Display init: window clear + bank display
B1F_State_CountryMapView  = $E37C   ; State 9: Country map view
B1F_State_IdleWait        = $E3EB   ; State 10/12/14: Idle wait, JMP dispatch
B1F_State_NewGameSetup   = $E3EE   ; State 11: New-game setup (SramInit re-seed, menu record $0C, -> state 12)
B1F_State_EventMessageScene = $E46A   ; State 13: Event message scene (event notices / title-cancel / unification verdict)
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
B1F_SpriteBufferInit      = $E823   ; Fill $0200-$02FF with $F0 (LDY #$04 dead; same behavior as $E825)
B1F_SpriteBufferInitAll   = $E825   ; Fill $0200-$02FF with $F0 (effective entry; fall-through target of $E823)
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
B1F_SpriteOamWriterSimple_NoInit = $F1B7 ; mid-entry: caller preset $0003/$0004

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
; 1Q: Message Window Helpers
;-------------------------------------------------------------------------------
B1F_OpenMsgWindow0        = $F26D   ; Open message window mode 0 (blank at $22A8)
B1F_OpenMsgWindow2        = $F283   ; Open message window mode 2 (blank at $2428)
B1F_OpenMsgWindow4        = $F28B   ; Open message window mode 4 (blank at $22A0)
B1F_OpenMsgWindow5        = $F293   ; Open message window mode 5 (blank at $2420)
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
; $F800 is the mapper WRAM write-protect register / sound address port, not an
; NMI handler address (see namco163.h NAMCO_WRAM_WRITE_PROTECT).
B1F_NmiDispatchTable      = $F87B   ; NMI game state dispatch table (9 entries)
B1F_NmiEpilogue           = $F88D   ; Restore PRG banks, tick counters, RTI
B1F_NmiState2_StrategyMap = $F8B5   ; NMI state 2: strategy map screen frame
B1F_NmiState3_WarScene    = $F8FE   ; NMI state 3: war scene (Tactical Mode map) frame
B1F_NmiState4_Battle      = $F96A   ; NMI state 4: Battle Mode screen frame (bank $0E VBlank hook)
B1F_NmiState5_Duel        = $F9A0   ; NMI state 5: Duel Mode frame; runs Duel Mode dispatcher (DuelModeDispatch, bank $17/$18)
B1F_NmiState6_TitleScreen = $F9E4   ; NMI state 6: title screen frame (title overlay menu, bank $0A)
B1F_NmiState7_CountrySelect = $FA13 ; NMI state 7: new-game country select frame (card grid machine, bank $08)
B1F_NmiState8_EventMessage = $FA53  ; NMI state 8: event message screen frame (bank $17 scroll machine)
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
B17_18_DuelModeDispatch   = $A01B   ; DuelModeDispatch_Entry: Duel mode main dispatcher
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
B17_18_DuelSceneDispatch = $B144
B17_18_DuelScene_InitOfficers = $B15A
B17_18_DuelScene_StoreNameTile = $B1A2
B17_18_DuelScene_ShowMsg = $B1A6
B17_18_DuelScene_ShowDialog = $B1BB
B17_18_DuelScene_LoadPortrait = $B1D4
B17_18_DuelScene_BuildRiderSprites = $B1EE
B17_18_DuelScene_FinalizeSprites = $B21C
B17_18_StrategyMode_CalcTroopStats = $B230
B17_18_DuelScene_ShowChallenge = $B2E0
B17_18_DuelCommandDispatch = $B34F
B17_18_DuelCmd_RoundSetup = $B361
B17_18_DuelCmd_RenderStats = $B3F0
B17_18_DuelCmd_CommandMenu = $B407
B17_18_DuelCmd_CommandRoute = $B47E
B17_18_DuelCmd_TacticConfirm = $B552
B17_18_DuelCmd_TacticSelect = $B569
B17_18_DuelAiDispatch = $B5C8
B17_18_DuelAi_SurrenderCheck = $B5D8
B17_18_DuelAi_DesperateCheck = $B626
B17_18_DuelAi_StrikeCheck = $B659
B17_18_DuelAi_TacticCheck = $B689
B17_18_DuelAi_PickFeintStrike = $B719
B17_18_DuelAi_CommitCommand = $B7A8
B17_18_WarClash_MoraleCalc = $B7B3
B17_18_DuelAi_DesperateThreshold = $B7DD
B17_18_DuelAi_StrikeThreshold = $B816
B17_18_DuelAi_PersuadeThreshold = $B851
B17_18_DuelAi_InsultThreshold = $B89B
B17_18_DuelStrikeResolveDispatch = $B8C7
B17_18_DuelStrike_Resolve = $B8D3
B17_18_DuelStrike_ApplyGauge = $B96D
B17_18_DuelStrike_ShowParried = $B9A0
B17_18_DuelStrike_WaitConfirm = $B9A5
B17_18_DuelStrike_NextRound = $B9C8
B17_18_DuelPursueDispatch = $BA6D
B17_18_DuelPursue_Init = $BA87
B17_18_DuelPursue_WaitIntro = $BAA5
B17_18_DuelPursue_WindowSlideIn = $BAC0
B17_18_DuelPursue_SetupPursuer = $BADA
B17_18_DuelPursue_EscapeRoll = $BB03
B17_18_DuelPursue_WindowSlideOut = $BB41
B17_18_DuelPursue_ApplyStrike = $BB5B
B17_18_DuelPursue_CheckDeath = $BB93
B17_18_DuelPursue_DeadHandoff = $BBC0
B17_18_DuelPursue_EscapeFinish = $BC00
B17_18_Duel_SwapActive = $BC16
B17_18_DuelDataToggleDispatch = $BC3B
B17_18_DuelData_Init = $BC47
B17_18_DuelData_ShowCard = $BC5C
B17_18_DuelData_HandleInput = $BC8C
B17_18_SurrenderSceneDispatch = $BCE9
B17_18_Surrender_Init = $BCFB
B17_18_Surrender_ShowText = $BD1E
B17_18_Surrender_Display = $BD40
B17_18_Surrender_NoOp = $BD5C
B17_18_Surrender_NoEvent = $BD5D
B17_18_Surrender_Execute = $BDA9
B17_18_Surrender_Cleanup = $BE3F
B17_18_PersuadeResolveDispatch = $BE78
B17_18_PersuadeRollEvent = $BE86
B17_18_Persuade_FadeOut = $BF43
B17_18_Persuade_WaverHandoff = $BF66
B17_18_Persuade_AcceptHandoff = $BF7E

;-------------------------------------------------------------------------------
; Internal procs - Bank $18 ($C000-$DFFF)
;-------------------------------------------------------------------------------
B17_18_InsultResolve_Exec = $C08A
B17_18_TacticDialogDispatch = $C116
B17_18_TacticDialog_Init = $C124
B17_18_TacticDialog_LoadName = $C13A
B17_18_TacticDialog_ShowAppeal = $C14A
B17_18_TacticDialog_Execute = $C187
B17_18_TacticDialog_LoadCards = $C1E2
B17_18_MapFadeDispatch    = $C21C
B17_18_MapFade_Init       = $C22A
B17_18_MapFade_FadeIn     = $C256
B17_18_MapFade_Draw       = $C28E
B17_18_MapFade_Complete   = $C2AA
B17_18_MapFade_DrawColumn = $C2CC
B17_18_SpoilsEventDispatch = $C2F6
B17_18_Spoils_PickFallenSide = $C30E
B17_18_Spoils_ExitFade = $C33B
B17_18_Spoils_RollLoot = $C35D
B17_18_Spoils_GrantWeapon = $C40B
B17_18_Spoils_GrantArmor = $C42E
B17_18_Spoils_WaitConfirm = $C44F
B17_18_PaletteTransitionDispatch = $C464
B17_18_PaletteTransition_Copy = $C46E
B17_18_PaletteTransition_Fade = $C480
B17_18_FeintSceneDispatch = $C498
B17_18_FeintScene_Init    = $C4AC
B17_18_FeintScene_Scroll  = $C4C3
B17_18_FeintScene_Draw    = $C4E9
B17_18_FeintScene_Update  = $C55A
B17_18_FeintScene_Animate = $C598
B17_18_FeintScene_Finalize = $C5D2
B17_18_FeintScene_Complete = $C66B
B17_18_StrikeSceneDispatch = $C689
B17_18_StrikeScene_Init    = $C69F
B17_18_StrikeScene_Scroll  = $C6B6
B17_18_StrikeScene_Draw    = $C6DC
B17_18_StrikeScene_Update  = $C72D
B17_18_StrikeScene_Animate = $C773
B17_18_StrikeScene_Finalize = $C809
B17_18_StrikeScene_Complete = $C84A
B17_18_StrikeScene_Extra   = $C884
B17_18_DesperateSceneDispatch = $C949
B17_18_DesperateScene_Init    = $C95F
B17_18_DesperateScene_Scroll  = $C976
B17_18_DesperateScene_Draw    = $C99C
B17_18_DesperateScene_Update  = $C9ED
B17_18_DesperateScene_Animate = $CA50
B17_18_DesperateScene_Finalize = $CAB8
B17_18_DesperateScene_Complete = $CAD4
B17_18_DesperateScene_Extra   = $CB0E
B17_18_StrikeSlideDispatch = $CB9E
B17_18_StrikeSlide_Init     = $CBAA
B17_18_StrikeSlide_Slide    = $CC0A
B17_18_StrikeSlide_Complete = $CC62
B17_18_DuelMenuSlideInDispatch = $CC87
B17_18_DuelMenuSlideIn_Init     = $CC93
B17_18_DuelMenuSlideIn_Slide    = $CCAA
B17_18_DuelMenuSlideIn_Complete = $CCD0
B17_18_DuelMenuSlideOutDispatch = $CD3C
B17_18_DuelMenuSlideOut_Init     = $CD48
B17_18_DuelMenuSlideOut_Slide    = $CD5F
B17_18_DuelMenuSlideOut_Complete = $CD85
B17_18_BuildPPUTileBuffer = $CDFD
B17_18_DrawSpriteFromBank = $CEA5
B17_18_MapScroll_UpdatePosition = $CEE1
B17_18_ExpandMetatileToSprites = $CFA3
B17_18_FinalizeSpriteBuffer = $D060
B17_18_ReadMenuSelection  = $D13D
B17_18_SetupMenuPtr       = $D166
B17_18_DuelCmd_FillStatTiles = $D17C
B17_18_DrawCompletionSprite = $D235
B17_18_CheckPlayerIsRuler = $D262
B17_18_SetDisplayPointer  = $D283
B17_18_CheckButtonConfirm = $D299
B17_18_StrategyCommand_InitOfficerScroll = $D6AA
B17_18_StrategyCommand_ScrollIntroPanel = $D79B
B17_18_StrategyCommand_ScrollTextPhase2 = $D83A
B17_18_StrategyCommand_ScrollAndWait = $D8C9
B17_18_StrategyCommand_FinalizeCleanup = $D920
B17_18_Finalize_Init      = $D932
B17_18_Finalize_SetupUI   = $D950
B17_18_Finalize_WaitConfirm = $D95A
B17_18_Finalize_ScrollTimer = $D976
B17_18_Finalize_PaletteCopy = $D9B4
B17_18_Finalize_NoOp      = $D9C1
B17_18_Finalize_ExitTransition = $D9C2
B17_18_StrategyCommand_MainInteractive = $D9CA
B17_18_StrategyCommand_BuildOfficerList = $D9DE
B17_18_StrategyCommand_InitOfficerDisplay = $DA41
B17_18_StrategyCommand_RenderOfficerEntry = $DA87
B17_18_StrategyCommand_UpdateOfficerDisplay = $DAB6
B17_18_StrategyCommand_ScrollOfficerList = $DAE0
B17_18_StrategyCommand_FinalizeDisplayBuffer = $DB90
B17_18_StrategyCommand_CheckConfirmInput = $DBDA
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
B1D_1E_ProvinceDataWindowFrame = $A009 ; ProvinceDataWindowFrame_Entry: Province data window frame
B1D_1E_MapDisplaySetup    = $A00C   ; MapDisplaySetup_Entry: Map display setup
B1D_1E_OfficerListHandler = $A00F   ; OfficerListHandler_Entry: Officer list handler
B1D_1E_FlushTileBuffer    = $A012   ; FlushTileBuffer_Entry: Upload 64-byte tile buffer to VRAM
B1D_1E_PaletteRecordLoad   = $A015   ; PaletteRecordLoad_Entry: Load 32-byte palette record to $0100 (uploaded to $3F00)
B1D_1E_SramInit           = $A018   ; SramInit_Entry: SRAM initialization
B1D_1E_MenuFontRecordLoad = $A01B   ; MenuFontRecordLoad_Entry: Menu font record load
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
B1D_1E_BattleOfficerPanelCompose = $A03C ; BattleOfficerPanelCompose_Entry: battle officer panel compose
B1D_1E_MenuRenderer       = $A03F   ; MenuRenderer_Entry: Menu renderer
B1D_1E_RulerCardRefresh   = $A042   ; RulerCardRefresh_Entry: Ruler card compose (label kanji row + name sprites)
B1D_1E_SceneRecordLookup  = $A045   ; SceneRecordLookup_Entry: Scene record lookup

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
B1D_1E_DigitTileOffsetTable = $A607 ; MenuUpdate @DigitTileOffsetTable (8 bytes)
B1D_1E_ClearTileBuffers   = $A60F   ; Clear tile row buffers
B1D_1E_CalcMenuDataPtr    = $A61D   ; Calculate menu data pointer
B1D_1E_BankPageOffsetTable = $A672  ; MenuUpdate @BankPageOffsetTable (15 words)
B1D_1E_SelectDataBankByPos = $A690  ; Select data bank by position
B1D_1E_PosDataBankTable   = $A6A7   ; MenuUpdate @PosDataBankTable (15 bytes)
B1D_1E_YearDisplaySetup_Proc = $A6B6 ; Year display setup procedure
B1D_1E_ProvinceDataHandler_Proc = $A830 ; Province data handler procedure
B1D_1E_ProvinceDisplayTilemap = $A856 ; ProvinceDataHandler @ProvinceDisplayTilemap (59 bytes)
B1D_1E_OfficerDisplay_LookupProc = $A890 ; Officer display lookup procedure
B1D_1E_OfficerDisplayTilemap = $A8C3 ; OfficerDisplay_Lookup @OfficerDisplayTilemap
B1D_1E_OfficerNameDisplay_Proc = $A8FD ; Officer name display procedure
B1D_1E_OfficerNameTilemap = $A91D   ; OfficerNameDisplay @OfficerNameTilemap
B1D_1E_DisplayScaledName  = $A957   ; kana dakuten/handakuten layer of the name strip
B1D_1E_FormatNumberPair   = $A96F   ; internal branch target inside DisplayScaledName (no cross-bank caller)
B1D_1E_DisplayScaledNumber = $A976  ; kana tile layer of the name strip (formats no numbers)
B1D_1E_BattleOfficerPanelCompose_Proc = $A991 ; battle overlay officer panel compose (was DataFormatter)
B1D_1E_RulerCardLabelTiles = $AB08  ; RulerCardRefresh @RulerCardLabelTiles (4 label variants x 12 kanji tile halves)
B1D_1E_BattleOfficerPanelBottomRowTiles = $A9C3 ; BattleOfficerPanelCompose @PanelRowTiles_Bottom (panel selector != 0)
B1D_1E_BattleOfficerPanelTopRowTiles = $A9FD ; BattleOfficerPanelCompose @PanelRowTiles_Top (panel selector = 0)
B1D_1E_RulerCardRefresh_Proc = $AA37 ; Ruler card compose procedure
B1D_1E_OfficerNameSpritePost = $AB38 ; Officer name kanji sprite post
B1D_1E_ProvinceDataWindowFrame_Proc = $ABD2 ; Province data window frame procedure
B1D_1E_CountryTemplatePtrs = $AD84  ; Country template pointers (7 entries)
B1D_1E_DrawProvinceName   = $B0AB   ; Draw province name (detail window)
B1D_1E_RenderSubState     = $B14C   ; Render sub-state
B1D_1E_SubStateChrTiles   = $B222   ; ProvinceDataWindowFrame @SubStateChrTiles (24 bytes)
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
B1D_1E_MenuAction00_SortieResult                  = $BEBB ; screen id $00: 出陣 Sortie result panel (Army @WarRequestCommit)
B1D_1E_MenuAction01_AcademyResult                 = $BEEB ; screen id $01: 学問所 Academy training result (Town @AcademyTrainApply)
B1D_1E_MenuAction02_SaveGameResult                = $BF2F ; screen id $02: 記録する SaveGame result (Castle CastleSaveExecute)
B1D_1E_MenuAction03_DiscordResult                 = $BF70 ; screen id $03: 離間 Discord outcome (Intrigue @DiscordBranch)
B1D_1E_MenuAction04_WarRulerCard                  = $BFBF ; screen id $04: war-outbreak Ruler card, current country (prg_19_1a)
B1D_1E_MenuAction05_WarRivalRulerCard             = $BFF3 ; screen id $05: war-outbreak rival Ruler card (prg_19_1a)
B1D_1E_MenuAction06_DisasterPreventionResult      = $C046 ; screen id $06: 防災 DisasterPrevention result (Castle @DisasterResultSetup)
B1D_1E_MenuAction07_ArmoryResult                  = $C090 ; screen id $07: 武器屋 Armory purchase result (Town @EquipApply)
B1D_1E_MenuAction08_WarOutbreakNotice             = $C0C8 ; screen id $08: war-outbreak notice, Province conquered (prg_19_1a)
B1D_1E_MenuAction09_LandReclamationResult0A             = $C123 ; screen id $09: 国造り result, 開墾 roll 0 (@DevResultIndexTable)
B1D_1E_MenuAction0A_LandReclamationResult0B             = $C168 ; screen id $0A: 国造り result, 開墾 roll 1 (@DevResultIndexTable)
B1D_1E_MenuAction0B_CivilianReliefResult          = $C1AC ; screen id $0B: 与える CivilianRelief result (Warehouse @PopulaceApplyStore)
B1D_1E_MenuAction0C_HospitalResult                = $C1FA ; screen id $0C: 病院 Hospital heal result (Town @HealResultUI)
B1D_1E_MenuAction0D_LandReclamationResult0E             = $C25D ; screen id $0D: 国造り result, 開墾 rolls 5/6/8 (@DevResultIndexTable)
B1D_1E_MenuAction0E_TownDevelopmentResult0F             = $C2DD ; screen id $0E: 国造り result, 町の開発 roll 7 (@DevResultIndexTable)
B1D_1E_MenuAction0F_IndustryAndTownResult10             = $C33D ; screen id $0F: 国造り result, 産業 roll 0 + 開発 rolls 4/5/8
B1D_1E_MenuAction10_OfficerTransferResult         = $C3A2 ; screen id $10: 武将の移動 OfficerTransfer result (Castle CastleMoveExecute)
B1D_1E_MenuAction11_IndustryDevelopmentResult12             = $C3F6 ; screen id $11: 国造り result, 産業の発展 rolls 4/5 (@DevResultIndexTable)
B1D_1E_MenuAction12_PoachingResult                = $C43E ; screen id $12: 引き抜き Poaching outcome (Intrigue @PoachingBranch)
B1D_1E_MenuAction13_IndustryDevelopmentResult14             = $C4E1 ; screen id $13: 国造り result, 産業 rolls 1/6/8 (@DevResultIndexTable)
B1D_1E_MenuAction14_LandAndIndustryResult15             = $C511 ; screen id $14: 国造り result, 開墾+産業 roll 7 (@DevResultIndexTable)
B1D_1E_MenuAction15_IndustryAndTownResult16             = $C556 ; screen id $15: 国造り result, 産業 roll 3 + 開発 rolls 0/2
B1D_1E_MenuAction16_OfficerGiftResult             = $C5B1 ; screen id $16: 与える OfficerGift result (Warehouse @OfficerApplyStore)
B1D_1E_MenuAction17_IndustryAndTownResult18             = $C5F7 ; screen id $17: 国造り result, 産業 roll 2 + 開発 rolls 1/3/6
B1D_1E_MenuAction18_AllianceResult                = $C636 ; screen id $18: 同盟 Alliance acceptance (Intrigue @ConfirmAccepted)
B1D_1E_MenuAction19_ConscriptionResult            = $C67D ; screen id $19: 徴兵 Conscription panel (Army @ApplyAmount)
B1D_1E_MenuAction1A_IntelligenceGatheringResult   = $C6C6 ; screen id $1A: 情報集め IntelligenceGathering panel (Castle)
B1D_1E_MenuAction1B_DroughtDamageWindow           = $C75F ; screen id $1B: drought (日照り) damage window (prg_19_1a)
B1D_1E_MenuAction1C_RiceHarvestWindow             = $C7D1 ; screen id $1C: 米の収穫 RiceHarvest window (prg_19_1a)
B1D_1E_MenuAction1D_FloodDamageWindow             = $C800 ; screen id $1D: flood (洪水) damage window (prg_19_1a)
B1D_1E_MenuAction1E_RebellionWindow               = $C830 ; screen id $1E: 反乱 Rebellion window (prg_19_1a)
B1D_1E_MenuAction1F_TaxCollectionWindow           = $C87D ; screen id $1F: 税金の徴収 TaxCollection window (prg_19_1a)
B1D_1E_MenuAction20_MarketPanel                   = $C8B4 ; screen id $20: 商店 Market buy/sell panel (Town @FacilitySelect)
B1D_1E_MenuAction21_SupplyTransportResult         = $C8F1 ; screen id $21: 物資を運ぶ SupplyTransport result (Warehouse)
B1D_1E_MenuAction22_WindowTeardown                = $C926 ; id $22: window teardown step, not a screen (StrategyMenu_Return)

;-------------------------------------------------------------------------------
; Internal procs - Bank $1E ($C000-$DFFF)
;-------------------------------------------------------------------------------
B1D_1E_StrategyMenu_Return = $C934  ; Strategy Mode menu shared return
B1D_1E_SetupDisplayPtrs   = $C96D   ; Setup display pointers
B1D_1E_ResetDispatchState = $C98A   ; Reset dispatch state
B1D_1E_DisplayTileData    = $C994   ; Tile data display engine
B1D_1E_MenuRenderer_SecondaryDispatch = $C9C2 ; Menu renderer secondary dispatch
B1D_1E_SaveScreenBlock    = $C9E8   ; Save-screen display block builder (no SRAM access)
B1D_1E_LoadScreenBlock    = $CA4E   ; Load-screen display block builder (no SRAM access)
B1D_1E_SaveSlotHeaderLoad = $CAC5   ; Load per-slot display header (no checksum involved)
B1D_1E_OfficerNameRowsEmit = $CB52  ; Emit officer name row records to $0380
B1D_1E_SaveScreenSoundSelect = $CC09 ; Select save-screen sound by $04D6
B1D_1E_MenuTilemapStream  = $CC40   ; Menu tilemap data stream (large)
B1D_1E_PaletteRecordLoad_Proc = $DBB1 ; Palette record loader (14 records; see prg_1d_1e_menu_screens header for caller map)
B1D_1E_PalRecordPtrTable = $DBCF  ; PaletteRecordLoad @RecordPtrTable - palette record ptrs (14 x .word, $DBCF-$DBEA)
B1D_1E_SramInit_Proc      = $DD8B   ; SRAM init procedure
B1D_1E_MenuFontRecordLoad_Proc = $DE7E ; Menu font record load procedure
B1D_1E_SceneRecordLookup_Proc = $DEB9 ; Scene record lookup procedure

;-------------------------------------------------------------------------------
; Banks $19+$1A - Map screen scenes (combined 16KB $A000-$DFFF)
; Loaded via SwitchBankAC with Y=$39 ($39 & $1F = $19, $C000 slot = $1A)
;
; Jump table entry points ($A000-$A032)
;-------------------------------------------------------------------------------
B19_1A_OverlayStripRender_Entry = $A000  ; legacy alias of B19_1A_OfficerCardRender_Entry (pre-rename name)
B19_1A_OfficerCardRender_Entry = $A000   ; $A000 stub alias: officer card render (body + face expression)
B19_1A_CountryRotationDispatch            = $A003 ; CountryRotationDispatch_Entry: per-Country turn rotation (frame $0B) entry
B19_1A_StrategyRequestDispatch       = $A006 ; StrategyRequestDispatch_Entry: strategy request dispatch
B19_1A_MonthlyEventDispatch              = $A009 ; MonthlyEventDispatch_Entry: per-Country monthly event dispatch (frame $0A)
B19_1A_OfficerStatusScene            = $A00C ; Officer status scene entry stub
B19_1A_StratagemCutscene              = $A00F ; StratagemCutscene_Entry: war-map stratagem cutscene (per-frame)
B19_1A_OfficerCardAnimStep_Entry     = $A012 ; OfficerCardAnimStep_Entry: officer card slide-in animation step
B19_1A_SortieWarCommit               = $A015 ; SortieWarCommit_Entry: commit the sortie (seize stocks, build war roster)
B19_1A_TransferCapacityCalc          = $A018 ; TransferCapacityCalc_Entry: transport capacity min() per good
B19_1A_OfficerArrivalScan            = $A01B ; OfficerArrivalScan_Entry: find arriving/available Officer for $0402
B19_1A_UnificationEndingDispatch     = $A01E ; UnificationEndingDispatch_Entry: unification ending scene
B19_1A_ProvinceOfficerRosterDispatch = $A021 ; ProvinceOfficerRosterDispatch_Entry: province officer roster
B19_1A_CastleDevResultRoll           = $A024 ; CastleDevResultRoll_Entry: castle dev result roll (message/gold cost/overlay index)
B19_1A_GoodsSendPrepare              = $A027 ; GoodsSendPrepare_Entry: goods send type roll + amount scale
B19_1A_GoodsSendApply                = $A030 ; GoodsSendApply_Entry: goods send apply to Officer $042C Province
B19_1A_MapProvinceDirtyMark          = $A02A ; MapProvinceDirtyMark_Entry: marks province $0402 dirty in $04E0-$04E3
B19_1A_SramSaveCommit                = $A02D ; SramSaveCommit_Entry: SRAM save commit (backup copy + "ID" magic + 16-bit checksum)

;-------------------------------------------------------------------------------
; Internal procs - Bank $19 ($A033-$BFFF)
; (stubs above share names with procs below, hence the _Proc suffix)
;-------------------------------------------------------------------------------
B19_1A_CountryRotationDispatch_Proc = $A033  ; Frame state $0B: per-Country turn rotation / next-Ruler handoff
B19_1A_ProvinceCountByOwner = $A19F      ; Count Provinces whose owner matches A
B19_1A_MarkerSpriteDraw = $A1C2          ; Draw rotation marker sprite (MarkerSpriteData)
B19_1A_FindOfficerProvince = $A1EB       ; Find Province housing Officer id $000A
B19_1A_DecayCountryTimers = $A209        ; Decay packed-nibble Country record timers ($04-$07)
B19_1A_CountryCensusBuild = $A240    ; Build acting-Country list + Officer census
B19_1A_MonthlyEventDispatch_Proc = $A296        ; Per-Country monthly event dispatch (frame state $0A)
B19_1A_EventPaceGate = $A2BC                 ; Event pace gate (month scheduler front door)
B19_1A_EventDisasterRoute = $A30C            ; Flood/drought disaster router (month $6F01)
B19_1A_EventReinforceGate = $A33C        ; Officer-arrival gate by acting Country $6F03
B19_1A_EventControlHandoff = $A363       ; Handoff on Country control byte ($09 engine/$0B rotation)
B19_1A_EventRulerLoad = $A389                ; Load acting Country's Ruler officer id
B19_1A_EventRulerDeathCheck = $A39B      ; Ruler out-of-action check -> succession or exit
B19_1A_TaxCollectionEvent = $A3E5          ; TaxCollection 税金の徴収: annual Gold payout event
B19_1A_ClampStatPair = $A52A             ; Clamp 16-bit stat pair
B19_1A_ValidateProvinceStats = $A540       ; Debug validation of recalculated Province record
B19_1A_ValidateProvinceSlots = $A582       ; Debug validation: Province Officer slots $11-$1A
B19_1A_RiceHarvestEvent = $A5AA            ; RiceHarvest 米の収穫: annual Rice payout event
B19_1A_DroughtDamageScene = $A6EF          ; Drought (日照り) event scene, Aug/Sep
B19_1A_ProvincePickListBuild = $A896       ; Disaster Province pick list (pool by Y)
B19_1A_DisasterSeverityRoll = $A8E0        ; 防災 severity tier x + 防災 decay roll
B19_1A_DisasterFractionSubtract = $A93E    ; Subtract tier fraction from 16-bit record field
B19_1A_DirtyMarkAndCard = $A985          ; Mark Province dirty + officer card redraw
B19_1A_FloodDamageScene = $A9A0            ; Flood (洪水) event scene, May/Jun
B19_1A_ProvinceRebellionEvent = $AB15           ; Monthly peasant-rebellion processor (統治度<50 roll + drain)
B19_1A_OfficerStatusScene_Proc = $AD81   ; Officer status scene
B19_1A_OfficerReinforceScene = $AEC0     ; Officer reinforce scene
B19_1A_ProvinceOfficerRosterDispatch_Proc = $AFE5 ; Province officer roster dispatch
B19_1A_OfficerCardAnimStep_Proc = $B2D7  ; Officer card slide-in animation step
B19_1A_CardFillDispatch = $B4BF          ; Officer card fill dispatch (animation frames)
B19_1A_SortieWarCommit_Proc = $B7D9      ; Commit the sortie: seize stocks, build war roster
B19_1A_TransferCapacityCalc_Proc = $B8D7 ; Transport capacity min() per good
B19_1A_OfficerArrivalScan_Proc = $B964   ; Find arriving/available Officer for $0402
B19_1A_CastleDevResultRoll_Proc = $BA70  ; Castle dev result roll (message/gold cost/overlay index)
B19_1A_GoodsSendPrepare_Proc = $BB03     ; Goods send type roll + amount scale
B19_1A_GoodsSendApply_Proc = $BB73       ; Apply goods send to Officer $042C Province
B19_1A_MapProvinceDirtyMark_Proc = $BBDE ; Mark province $0402 dirty in $04E0-$04E3
B19_1A_SramSaveCommit_Proc = $BC02       ; SRAM save commit (backup copy + "ID" magic + checksum)
B19_1A_OfficerNaturalDeathScene = $BC80   ; Officer natural-death (シホウ) roll scene
B19_1A_RulerSuccessionScene = $BE01      ; Ruler succession scene

;-------------------------------------------------------------------------------
; Internal procs - Bank $1A ($C000-$DFFF)
;-------------------------------------------------------------------------------
B19_1A_RosterSwapFirst = $C101           ; Swap first roster slot to front
B19_1A_SuccessionApplyScene = $C132      ; Apply succession: install heir/strongest Officer as Ruler
B19_1A_ScenarioHandoffPrep = $C37A       ; Scenario handoff preparation
B19_1A_UnificationEndingDispatch_Proc = $C435 ; Unification ending scene dispatch
B19_1A_MapCameraScrollRepeat = $C67C     ; Map camera scroll with auto-repeat (bank pair twin)
B19_1A_MapProvinceUnderCamera = $C708    ; Find Province under camera center
B19_1A_StrategyRequestDispatch_Proc = $C773 ; Strategy request processing dispatch
B19_1A_CountryControlToggle = $CD8C      ; Country control (player/AI) toggle
B19_1A_OfficerCardRender = $CE1F         ; Officer card renderer (body + face expression, portrait CHR page $CED6)
B19_1A_StratagemCutscene_Proc = $CFD6 ; War-map stratagem cutscene (per-frame)

;===============================================================================
; SECTION 3: Banked Code/Data at $8000-$9FFF (Slot 0)
; Banks switched via SwitchBank8_B ($F25F) or SwitchBank8_A ($F266)
; TODO: No banked JSR/JMP calls to $8000-$9FFF found in bank $1F yet
;===============================================================================
; Template for future use:
; B00_FunctionName        = $8000

;-------------------------------------------------------------------------------
; 3A: Bank $02 - Sound/note data (player: B1F_SoundNotePlayer, $E609; driver:
; B0E/B0F BattleAnimSoundEngine $D8D4 + BattleSoundChannelProc $DC59)
; Reached via LDY #$22 ; JSR SwitchBank8_B (Y & $1F = $02). Descriptors are
; addressed as $8000 + soundID*4, so code uses the computed pointer, not a
; per-ID symbol; the equates below document the decoded layout. In each entry
; the last 2 bytes are ONE 16-bit stream pointer (b2 -> $0702 lo, b3+$40 ->
; $0703 hi), and the driver maps bank $03
; at $A000 while it walks a stream (LDA #$23 / ORA #$C0 / STA NAMCO_PRG_A000),
; so the command-stream area spans bank $02 $82DC-$9FFF plus bank $03
; $8000-$8965. The wavetable itself is B1F_WavetableInitData ($E6A6, bank $1F),
; NOT in this bank. Format and validation: tools/sound_streams.py.
; Evidence: asm/banks/data_02_sound.asm, code/bank_switch_map.md 5.2.
;-------------------------------------------------------------------------------
B02_SoundNoteHeaderTable  = $8000   ; 184 x 4-byte entries (index = soundID)
B02_SoundNoteEntrySize    = $04     ; entry width: ptr = $8000 + soundID*4
B02_SoundNoteHeaderCount  = $B8     ; soundID range $00-$B7
B02_SoundTrackStride      = $16     ; sound-RAM track block (descriptor b0 = stride*track)
B02_SoundTrackCount       = $0B     ; 11 tracks in $0700 sound RAM (SoundInit bound $F2)
B02_SoundStreamPtrBias    = $40     ; b3 + $40 = command-stream pointer high byte
B02_SoundCommandStreams   = $82DC   ; starts on entry $B7's row: the note 17 ptr words target
B02_SoundCellSize         = $02     ; command cell = [opcode][operand]
B02_SoundStreamTailB03    = $0966   ; area ends at bank $03 offset $0966 ($8965)

;===============================================================================
; SECTION 4: Banked Code at $C000-$DFFF (Slot 2)
; Banks paired with $A000 slot via SwitchBankAC_B/SwitchBankAC_A
; (bank at $C000 is always Y+1 when $A000 is Y)
;===============================================================================
; (Bank $18 entries removed - now internal to combined prg_17_18_display.asm)

;===============================================================================
; SECTION 5: Combined Banks $0A+$0B ($A000-$DFFF)
; Bank $0A at $A000-$BFFF paired with Bank $0B at $C000-$DFFF
; Entry points via jump table at $A000-$A00E
; Labels are defined in prg_0a_0b_strategy_ai.asm and available globally.
;===============================================================================

;-------------------------------------------------------------------------------
; Jump Table Entry Points ($A000-$A00E)
;-------------------------------------------------------------------------------
B0A_0B_StrategyAiTurnDispatch_Entry = $A000 ; StrategyAiTurnDispatch_Entry: Strategy Mode per-country turn driver
B0A_0B_TitleScreenPhaseDispatch_Entry = $A003 ; TitleScreenPhaseDispatch_Entry: title screen scene phase machine
B0A_0B_ArmyValueCalc_Entry = $A006 ; ArmyValueCalc_Entry: Army value calculation
B0A_0B_DataRecordLookup_Entry = $A009 ; DataRecordLookup_Entry: Data record lookup
B0A_0B_DistanceClamp_Entry = $A00C ; DistanceClamp_Entry: Distance clamp

;-------------------------------------------------------------------------------
; Internal procs - Bank $0A ($A00F-$BFFF)
;-------------------------------------------------------------------------------
B0A_0B_StrategyAiTurnDispatch = $A00F   ; Strategy Mode AI turn dispatch (mailbox gate, officer phase, action-cycle dispatch)
B0A_0B_InitWorkAreas      = $A043   ; Initialize work areas and tier adjust
B0A_0B_AiCountExpansionRoom = $A0D3 ; Count own/empty border edges + expansion-capable provinces
B0A_0B_AiActionChoose     = $A19C   ; AI action weighted choose (expand/domestic/loop)
B0A_0B_AiAction_ExpandProvinces = $A1C5 ; AI action step: province expansion/absorption
B0A_0B_AiAction_LoopTramp = $A23D   ; Trampoline to AI action loop step
B0A_0B_FindBestEnemyProvince = $A240 ; Find best enemy province to attack
B0A_0B_FindAbsorptionSource = $A303 ; Find absorption source province
B0A_0B_DispatchOfficerArmies = $A45C ; Dispatch officer armies
B0A_0B_ArmyDispatch       = $A481   ; Army dispatch (main army handler)
B0A_0B_CoverGoldShortfall = $A55C   ; Expedition gold shortfall top-up (was TileRender)
B0A_0B_CoverRiceShortfall = $A60C   ; Expedition rice shortfall top-up (was NameTable)
B0A_0B_LevelTierDispatch = $A6BC   ; Level tier dispatch (attack tier roll by game level)
B0A_0B_CalcArmyTierAndCosts = $A6C9 ; Calc attack tier, committed officers, expedition costs
B0A_0B_CalcExpeditionCosts = $A74A ; Calc expedition gold/rice costs
B0A_0B_ResolveProvinceConquest = $A79C ; Resolve province conquest & stage follow-up war
B0A_0B_SettleStagedOfficers = $A8D7 ; Settle staged officer columns (war/march aftermath)
B0A_0B_EvalProvinceAbsorption = $B10E ; Evaluate province absorption
B0A_0B_AbsorbPreview      = $B1F9   ; Absorb preview
B0A_0B_TransferProvinceValues = $B1FD ; Transfer province values
B0A_0B_AbsorbUpdateRecord = $B287   ; Absorb update record
B0A_0B_FallbackMergeProvinces = $B357 ; Fallback merge provinces
B0A_0B_AiAction_DomesticTurn = $B49C ; AI action step: domestic turn (large state machine)

;-------------------------------------------------------------------------------
; Internal procs - Bank $0B ($C000-$DFFF)
;-------------------------------------------------------------------------------
B0A_0B_AiOfficer_RulerToFrontier = $C50E ; AI officer phase: move ruler to best enemy-bordering own province
B0A_0B_AiOfficer_RosterFill = $C5B9   ; AI officer phase: hire free officers into own province rosters
B0A_0B_EvaluateAndMarkOfficer = $C5D2 ; Evaluate and mark officer (nested)
B0A_0B_CalcActionProb     = $C66F   ; Calculate action probability
B0A_0B_AiOfficer_RecruitTransfer = $C79A ; AI officer phase: pay gold, recruit/transfer officers between provinces
B0A_0B_PromoteBestOfficerForCountry = $C98F ; Promote best officer to governor for a country
B0A_0B_ApplyScenarioDeductions = $CD68 ; Apply scenario deductions
B0A_0B_BracketDeductArmy  = $CEDD   ; Bracket deduct army
B0A_0B_ArmyValueCalc      = $CF3F   ; Army value calculation
B0A_0B_DataRecordLookup   = $CF7C   ; Data record lookup
B0A_0B_DistanceClamp      = $D00C   ; Distance clamp
B0A_0B_CalcOfficersPerProvince = $D03A ; Provinces $003E + officers $003F, $0040 = officers/province
B0A_0B_CalcOfficersPerProvinceDup = $D05D ; Byte-identical dup of $D03A, no callers
B0A_0B_CountCountryProvinces = $D080 ; Count owned provinces ($2B) + total officers ($2C)
B0A_0B_CountDefendedBorderProvinces = $D0AA ; Count current country's provinces with officers that border a rival
B0A_0B_GetProvinceOwner   = $D105   ; Get province owner
B0A_0B_DeductCounterMultiEntry = $D12D ; Deduct counter (multi-entry)
B0A_0B_CollectEnemyBorderProvinces = $D1A4 ; Collect rival-held neighbour provinces of $0036 into $6F73, A = count
B0A_0B_CollectEnemyBorderProvincesX = $D1F4 ; X-variant, count also in $0037
B0A_0B_FindCountryProvinceOfOfficer = $D249 ; Find current country's province whose roster holds the officer id at ($EE)
B0A_0B_GetOfficerRecordField = $D283   ; Officer: read record field (A=id, Y=offset)
B0A_0B_ReadBankedRecordField = $D2D3 ; Read banked record field
B0A_0B_CountRecordSlots   = $D304   ; Count officers in province roster $11-$1A
B0A_0B_GetCountryRecordPtr = $D319   ; Get country record pointer ($6F07 + id*8)
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
B0A_0B_TitleScreenPhaseDispatch = $D717 ; Title screen scene phase machine ($0540), run by NmiState6_TitleScreen
B0A_0B_CallTitleAnimationDispatch = $D72A ; Banked call to bank $17 AnimationDispatch_Entry ($A021)
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
; Tactical Mode player turn: the acting player's war-map officer commands
; (move/attack/stratagem/march/deploy/exchange/retreat); AI side = banks $08+$09
; Loaded via SwitchBankAC with Y=$28
; Entry points via jump table at $A000-$A006
;===============================================================================

;-------------------------------------------------------------------------------
; Jump Table Entry Points ($A000-$A006)
;-------------------------------------------------------------------------------
B0C_0D_TacticalTurnFrameUpdate_Entry = $A000 ; TacticalTurnFrameUpdate_Entry: Main frame update
B0C_0D_TacticalMapSceneInit_Entry = $A003 ; TacticalMapSceneInit_Entry: Tactical map scene init
B0C_0D_OfficerFateCommit_Entry = $A006 ; OfficerFateCommit_Entry: Post-battle officer fate commit

;-------------------------------------------------------------------------------
; Internal procs - Bank $0C ($A009-$BFFF)
;-------------------------------------------------------------------------------
B0C_0D_TacticalTurnFrameUpdate = $A009  ; Main frame update loop
B0C_0D_WarOrderMenu = $A04E ; 5-phase war-order menu dispatcher (state 0)
B0C_0D_OfficerDetailView  = $A21B   ; Officer detail panel display
B0C_0D_UnitAttack   = $A293   ; Attack (こうげき) flow: enemy unit target select, animation, battle result
B0C_0D_UnitMove     = $A44D   ; Unit movement on the war map
B0C_0D_UnitStratagem = $A87C  ; Stratagem (けいりゃく) menu, target select, confirm
B0C_0D_ValidateActionTarget = $AD80 ; Per-action validation (14 action types)
B0C_0D_ExecuteAction      = $B02B   ; Per-action execution engine
B0C_0D_CheckActionSuccess = $B72B   ; Action success check (distance + stats)
B0C_0D_CalcDistance       = $B860   ; Hex distance calculation
B0C_0D_BuildNeighborList  = $B8A1   ; Build adjacent tile neighbor list
B0C_0D_UnitRetreat = $B94A ; Retreat (たいきゃく) castle selection (6 states)
B0C_0D_ArmyTurnEnd = $BC93 ; All-army hold / day-end cycle (8 states)
B0C_0D_AiMarch   = $BE7E   ; Queued march-order execution (17 states)

;-------------------------------------------------------------------------------
; Internal procs - Bank $0D ($C000-$DFFF)
;-------------------------------------------------------------------------------
B0C_0D_TownAction  = $C1FC   ; tactical_turn_state 9: trampolines to B08_09_WarTownActionDispatch
B0C_0D_ArmyDeploy = $C204   ; Army deployment (7 states)
B0C_0D_OfficerLevelUp = $C691 ; Post-battle officer level-up, parties $0514/$0516 (4 states)
B0C_0D_OfficerFateCommit = $C766 ; Post-battle officer fate commit (kill/queue/toggle handlers)
B0C_0D_CountrySelectPanel = $C98C ; War-end strength/result panel (6 states)
B0C_0D_WarSideStatDigitsRender = $CC29 ; Both sides' stat digit OAM render for war result panel
B0C_0D_UnitWithdraw = $CD16 ; Post-war unit withdrawal selection (7 states)
B0C_0D_UnitGarrison = $D2CD ; Garrison assignment, 10-per-castle cap (7 states)
B0C_0D_TacticalMapScene      = $D4F0   ; Tactical map scene: map, cursor, rosters, SFX
B0C_0D_TacticalMapScene_Init = $DC99   ; Tactical map scene initialization
B0C_0D_CenterMapOnOfficer = $DC33   ; Center map viewport on officer
B0C_0D_TacticalOverlayIdleCheck = $DF27 ; C=1 while overlay sentinels $0300/$0304 idle
B0C_0D_MapSfxSetup        = $DF39   ; Setup war-map SFX parameters ($0518 state)
B0C_0D_MapSfxUpdate       = $DF88   ; Update war-map SFX tone by scroll position
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
B08_09_WarTownActionDispatch_Entry = $A009 ; WarTownActionDispatch_Entry: war-map town facility action dispatch
B08_09_WarCasualtyResolution_Entry = $A00C ; WarCasualtyResolution_Entry: Casualty/morale resolution
B08_09_WarAttritionRound_Entry = $A00F ; WarAttritionRound_Entry: Attrition round
B08_09_WarStatusPanelDraw_Entry = $A012 ; WarStatusPanelDraw_Entry: Status panel draw
B08_09_StratagemTargetMarker_Entry = $A015 ; StratagemTargetMarker_Entry: Stratagem target markers
B08_09_ValidateSpecialOfficer_Entry = $A018 ; ValidateSpecialOfficer_Entry: Special officer validation
B08_09_BuildCommandList_Entry = $A01B ; BuildCommandList_Entry: Command list build
B08_09_ExpandArmoryGridSlots_Entry = $A01E ; ExpandArmoryGridSlots_Entry: Armory grid slot expansion
B08_09_WarMapScrollUpdate_Entry = $A021 ; WarMapScrollUpdate_Entry: Battle map scroll update
B08_09_CountrySelectDispatch_Entry = $A024 ; CountrySelectDispatch_Entry: new-game country select dispatch (card grid)
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
B08_09_Action_BuyRice = $A329 ; Action 5: march to ordered province, buy rice with gold
B08_09_Action_RestoreHP   = $A507   ; Action 6: restore HP
B08_09_Action_Idle        = $A606   ; Action 7: idle
B08_09_AiExecuteMove      = $A60C   ; AI movement engine
B08_09_AiScanAdjacentOfficers = $A837 ; Scan adjacent officers
B08_09_AiCheckAttackNearby = $A8A8  ; Check attack nearby
B08_09_AiFindNearbyOfficers = $A8D3 ; Find nearby officers
B08_09_AiFindNearbyOfficers_ScanLoop = $A8E8 ; Multi-entry: scan loop (target in $20/$21)
B08_09_AiCheckFaction     = $A944   ; Check faction (also called from $CB74)
B08_09_AiPickStratagemTarget = $A95C ; Pick stratagem target: radius-5 enemies strongest-first, first candidate with a feasible stratagem wins
B08_09_AiPickStratagem = $A9CF ; Pick feasible stratagem code vs candidate (tier cascade + random)
B08_09_AiCheckAdvancedStratagem = $AAF8 ; Attempt stratagems $0A-$0F vs nearby enemies (caster-id gated)
B08_09_AiAdvancedStratagemOfficerTable = $AC65 ; Caster-id whitelist for stratagems $0A-$0F, per rank group
B08_09_AiCheckStratagemFeasible = $AC7B ; Per-stratagem precondition dispatcher (X = stratagem code 0-$0F)
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
B08_09_InlineTableDispatcher = $B517  ; Bank-local twin of B1F_CallbackDispatcher + math helpers
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
B08_09_WarTownActionDispatch = $C0BB ; war-map town facility action state machine, player-side Market/Armory/Hospital ($C0BB-$C982)
B08_09_State0_ShowActionPanel = $C0D5 ; State 0: show action panel
B08_09_State0PanelLayout  = $C1DE   ; State 0 panel layout
B08_09_State1_BuyRice    = $C1EB   ; State 1: buy rice (market)
B08_09_State2_SellRice   = $C2C0   ; State 2: sell rice (market)
B08_09_State3_CheckVitalityDeficit = $C392 ; State 3: vitality deficit check (hospital gate)
B08_09_State4_HospitalHeal = $C3E9 ; State 4: hospital heal (50 gold)
B08_09_State4PanelLayout  = $C4AB   ; State 4 panel layout
B08_09_State5_ArmoryGridSetup = $C4B8 ; State 5: armory grid setup
B08_09_State5PanelLayout  = $C512   ; State 5 panel layout
B08_09_ArmoryGridSetTable = $C525   ; Armory grid set per province (0-5)
B08_09_State6_RenderArmoryItems = $C543 ; State 6: render armory grid items
B08_09_SlotParamTable     = $C61E   ; Slot parameter table
B08_09_State7_ArmoryPurchaseApply = $C62E ; State 7: armory purchase apply
B08_09_State7PanelLayout  = $C728   ; State 7 panel layout
B08_09_CheckSpecialEquipment = $C73B ; Check special equipment (famous weapons)
B08_09_State8_WaitForNextCommand = $C7B0 ; State 8: wait for next command
B08_09_State9_RouteNextAction = $C7C8 ; State 9: route next action
B08_09_State9PanelLayout  = $C844   ; State 9 panel layout
B08_09_ExpandArmoryGridSlots = $C851 ; Expand armory grid set into 4 item slots
B08_09_ItemPriceTable     = $C89E   ; Item sale price table (equipment cell -> price word)
B08_09_ArmoryGridLayouts = $C8DE ; Armory grid layouts (6 sets x 4 categories x 4 items)
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
B08_09_CountrySelectDispatch = $D70F ; New-game country select dispatch (card grid)
B08_09_CountrySelect_SceneTick = $D723 ; Country select scene tick
B08_09_CountrySelect_InitRecords = $D73A ; Phase: seed the 7 faction records
B08_09_CountrySelect_OpenMenuWait = $D778 ; Phase: open menu wait
B08_09_CountrySelect_SelectMenuEntry = $D7B0 ; Phase: select menu entry
B08_09_CountrySelect_ConfirmMenuWait = $D80C ; Phase: confirm menu wait
B08_09_CountrySelect_PickEntry = $D844 ; Phase: pick entry
B08_09_CountrySelect_InspectEntry = $D8A0 ; Phase: inspect entry
B08_09_CountrySelect_Finalize = $D8E4 ; Phase: finalize
B08_09_CountrySelectMenuPoll = $D906 ; Country select menu poll
B08_09_CountrySelectEntryInit = $D97A ; Country select faction record init
B08_09_CountrySelect_RowToRecordMap = $DA07 ; Menu row -> record index
B08_09_CountrySelect_RecordInitTable = $DA0F ; 7 x 4-byte faction entry seeds
B08_09_CountrySelect_EntryOrderList = $DA2B ; Entry order + $FF sentinels
B08_09_CountrySelect_CursorPosTable = $DA35 ; Cursor (Y,X) base per row
B08_09_CountrySelect_CursorSpriteLayout = $DA43 ; Single-tile cursor layout
B08_09_CountrySelectSceneFrameDraw = $DA48 ; Country select scene frame draw
B08_09_CountrySelect_FrameSpriteLayout = $DA68 ; 28 OAM records + terminator
B08_09_CountrySelectCursorSpriteDraw = $DAD9 ; Country select cursor sprite draw
B08_09_CountrySelect_MarkerSpriteLayout = $DAF9 ; Single marker sprite layout
B08_09_CountrySelectReadyCheck = $DAFE ; Country select ready check
B08_09_CountrySelectCheatCheck0 = $DB10 ; Cheat sequence input check 0
B08_09_CountrySelectCheatCheck1 = $DB62 ; Cheat sequence input check 1
B08_09_CountrySelectCheatCheck2 = $DBB4 ; Cheat sequence input check 2
B08_09_CountrySelectCheatCheck3 = $DBFF ; Cheat sequence input check 3
B08_09_CountrySelectCheatExecute = $DC4A ; Cheat execution at finalize (max claimed country's capital Province)
B08_09_CountrySelectCheatMaxProvince = $DC9C ; Cheat: copy maxed-BCD stat template into one Province record

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
B0E_0F_OfficerBattleExpAccrueAndLevelUp_Entry = $A006 ; OfficerBattleExpAccrueAndLevelUp_Entry: Battle exp accrual + level-up
B0E_0F_OfficerStatSumExpGrant_Entry = $A009 ; OfficerStatSumExpGrant_Entry: Donor stat-sum experience grant
B0E_0F_SoundPlayAlt_Entry       = $A00C  ; SoundPlayAlt_Entry: Battle sound channel alternate play entry

;-------------------------------------------------------------------------------
; Internal procs - Bank $0E ($A00F-$BFFF)
;-------------------------------------------------------------------------------
B0E_0F_BattleVBlankFrameUpdate = $A00F ; Battle Mode VBlank frame hook
B0E_0F_BattleModeStateLoop = $A030 ; Overlay state-machine dispatcher (phase table $A06F)
B0E_0F_BattleIntro = $A085 ; Phase 0 (intro) sub-dispatch on $0541
B0E_0F_BattleOverlayIntroSkipCheck = $A095 ; Intro sub 0: skip check ($0087 bit7)
B0E_0F_BattleOverlayIntroRosterWalk = $A0D3 ; Intro sub 1: roster cell walk
B0E_0F_BattleOverlayIntroAnimQueue = $A0F9 ; Intro sub 2: enqueue intro anim
B0E_0F_BattleOverlayIntroDataFormatTop = $A119 ; Intro sub 3: format top panel data
B0E_0F_BattleOverlayIntroDataFormatBottomAndAdvance = $A137 ; Intro sub 4: format bottom + advance
B0E_0F_NextActor = $A15F ; Phase 1 (next-actor select) sub-dispatch
B0E_0F_NextActorCycleInit          = $A16E ; Phase 1 sub 0: cycle init
B0E_0F_NextActorSelect    = $A183 ; Phase 1 sub 1: roster scan for next actor
B0E_0F_NextActorRoundPass          = $A235 ; Phase 1 sub 2: round pass (no actor found)
B0E_0F_BattleDefeatEventCheck   = $A2A9 ; Per-side defeat event check
B0E_0F_BattleRetreatEventCheck  = $A32F ; Per-side retreat event check
B0E_0F_BattlePlayerRequestPoll  = $A39D ; Player command-request poll
B0E_0F_BattleResult  = $A3BC ; Phase 4 (defeat/retreat result) sub-dispatch
B0E_0F_BattleResultAdvance      = $A3D0 ; Phase 4 sub 0: defeat entry stall
B0E_0F_BattleResultDefeatInputWait = $A3D4 ; Phase 4 sub 1: defeat input wait
B0E_0F_BattleResultFlashTrigger = $A3F2 ; Phase 4 sub 2/6: screen flash trigger
B0E_0F_BattleResultRetreatInputWait = $A407 ; Phase 4 sub 3: retreat entry input wait
B0E_0F_BattleResultDamageApply  = $A488 ; Phase 4 sub 4: damage apply
B0E_0F_BattleResultConfirmInput = $A4B5 ; Phase 4 sub 5: confirm input
B0E_0F_BattleResultColumnDamageSelect = $A4D8 ; Helper: troop count of selected column
B0E_0F_BattleResultColumnStripSelect = $A4E6 ; Helper: strip flag of selected column
B0E_0F_ActionResolve = $A4F7 ; Phase 2 (command resolution) sub-dispatch
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
B0E_0F_CommandSelect = $AA23 ; Phase 3 (command selection) sub-dispatch
B0E_0F_Phase3CommandPanelInit   = $AA4A ; Phase 3 sub 0: command panel init
B0E_0F_Phase3CommandAnimStep    = $AABD ; Phase 3 sub 1: panel anim step
B0E_0F_Phase3CommandInput       = $AAF0 ; Phase 3 sub 2: player command input
B0E_0F_Phase3CommandConfirmWait = $AB75 ; Phase 3 sub 3: confirm wait
B0E_0F_Phase3CommandResultWait  = $AB9A ; Phase 3 sub 4: result wait
B0E_0F_Phase3CommandDirInput    = $ABC3 ; Command menu direction input handler
B0E_0F_Phase3CommandArrowDraw   = $AC73 ; Command menu selection arrow sprite
B0E_0F_Phase3CommandMarkerUpdate = $ACA8 ; Command menu target marker refresh
B0E_0F_BattleTacticsMenu   = $ACC5 ; Phase 8 (battle tactics menu) sub-dispatch
B0E_0F_BattleTacticsMenuInit          = $ACEC ; Phase 8 sub 0: panel init
B0E_0F_BattleTacticsMenuScriptStep    = $AD3C ; Phase 8 sub 1: script step wait
B0E_0F_BattleTacticsMenuInput     = $AD5D ; Phase 8 sub 2: row selection input
B0E_0F_BattleTacticsMenuConfirmWait   = $AE11 ; Phase 8 sub 3: confirm wait
B0E_0F_BattleTacticsMenuReturnToCommand = $AE6C ; Return to phase 3 sub 3
B0E_0F_BattleTacticsMenuAdvanceWait   = $AE8E ; Phase 8 sub 4: advance wait
B0E_0F_BattleTacticsMenuReturnToCommandDup = $AEAE ; Unreferenced dup of ReturnToCommand
B0E_0F_Phase8RowEffectDispatch  = $AF11 ; Purchased row effect dispatch
B0E_0F_Phase8RowTaunt           = $AF26 ; Row 1: Taunt stat check (siege auto-fail)
B0E_0F_Phase8RowBind            = $AFD2 ; Row 0: Bind effect (coin-flip hit)
B0E_0F_Phase8RowCounter574      = $AFF6 ; Row effect: status counter $0574 <- 4
B0E_0F_Phase8RowCrossbowVolley  = $B00E ; Row 2: status counter $0575 <- 3
B0E_0F_Phase8RowMoraleBoost     = $B02E ; Row 3: status counter $0576 <- 4
B0E_0F_Phase8RowReloadRoll      = $B066 ; Reload roll: A + 5 + rand[0,5)
B0E_0F_Phase8RowFireArrows      = $B07C ; Row 4: status counter $0577 <- 3
B0E_0F_Phase8RowExplosion       = $B09C ; Row 5: Explosion purchase -> phase 9
B0E_0F_Phase8RowScriptQueue     = $B0AC ; Queue row script into VRAM script buffer
B0E_0F_BattleSideStatusCountersDecrement = $B15B ; Per-frame status counter tick-down
B0E_0F_FormationAdvance = $B1EC ; Phase 9 (formation advance) sub-dispatch
B0E_0F_FormationAdvanceInit        = $B211 ; Phase 9 sub 0: marker OAM init
B0E_0F_FormationAdvanceAnimFrame   = $B25B ; Phase 9 sub 1: 32-frame advance animation
B0E_0F_FormationAdvanceComplete    = $B2A9 ; Advance animation off-strip exit
B0E_0F_FormationAdvanceMarkerRender = $B2AC ; Advance marker draw
B0E_0F_FormationAdvanceContactTick = $B2F5 ; Phase 9 sub 2: contact-damage tick
B0E_0F_FormationAdvanceRosterSweep = $B3EF ; Phase 9 sub 3: roster slot sweep
B0E_0F_FormationAdvanceFinish      = $B440 ; Shared advance-finish block
B0E_0F_FormationAdvanceContactScan = $B44B ; Contact-damage tile scan
B0E_0F_FormationAdvanceContactCheck = $B48A ; Slot proximity check vs marker
B0E_0F_FormationAdvanceContactApply = $B4AA ; Apply rolled contact damage
B0E_0F_FormationAdvanceDamageRoll  = $B4E3 ; Contact-damage roll
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
B0E_0F_SideEvent = $CD43 ; Phase 5 (side event) sub-dispatch
B0E_0F_SideEventRosterCommit = $CD4F ; Phase 5 sub 0: roster commit
B0E_0F_SideEventPanelSetup = $CD59 ; Phase 5 sub 1: panel setup
B0E_0F_SideEventClose     = $CDCF ; Phase 5 sub 2: event close
B0E_0F_SideEventRetreatSlotMark    = $CE10 ; Helper: retreat slot mark
B0E_0F_SideAFormation = $CE25 ; Phase 6 (side A formation) sub-dispatch
B0E_0F_SideAFormationPanelInit = $CE33 ; Phase 6 sub 0: panel init
B0E_0F_SideAFormationMenuInput = $CE68 ; Phase 6 sub 1: menu input
B0E_0F_SideAFormationConfirmWait = $CEAE ; Phase 6 sub 2: confirm wait
B0E_0F_AdvanceToSideBFormation = $CEFA ; Phase 6 sub 3: advance to phase 7
B0E_0F_FormationSelectMenu      = $CF05 ; Side-wrapped 4-wide formation menu
B0E_0F_SideBFormation = $CF67 ; Phase 7 (side B formation) sub-dispatch
B0E_0F_SideBFormationPanelInit = $CF77 ; Phase 7 sub 0: panel init
B0E_0F_SideBFormationPanelOpen = $CF9D ; Phase 7 sub 1: panel open
B0E_0F_SideBFormationMenuInput = $CFC2 ; Phase 7 sub 2: menu input
B0E_0F_SideBFormationConfirmWait = $D008 ; Phase 7 sub 3: confirm wait
B0E_0F_BattleModeStart    = $D054 ; Phase 7 sub 4: Battle Mode start
B0E_0F_NextActorAiSideRefresh      = $D067 ; Phase-1 AI side refresh helper
B0E_0F_AiTacticSpendDispatch    = $D0AE ; AI tactic-point spend dispatch
B0E_0F_AiBattleOrderAssign      = $D0CB ; Battle order slot assignment
B0E_0F_AiCommanderRoutCheck     = $D1D8 ; AI commander rout check
B0E_0F_AiArmyRoutCheck          = $D2D4 ; AI whole-army rout check
B0E_0F_BattleOutnumberedCheck   = $D32A ; Side strength comparison
B0E_0F_AiTacticPointSpend       = $D3C7 ; AI tactic point spend engine
B0E_0F_AiTaunt   = $D6BA ; Phase $A (AI taunt scene) sub-dispatch
B0E_0F_AiTauntSceneOpen     = $D6CC ; Taunt sub 0: opening beat
B0E_0F_AiTauntSceneAdvanceWait = $D6DD ; Taunt sub 1: advance wait
B0E_0F_AiTauntStripRedraw   = $D72B ; Taunt overlay strip redraw helper
B0E_0F_AiTauntSceneStep     = $D743 ; Taunt sub 4: scene step
B0E_0F_AiTauntSceneChoice   = $D77F ; Taunt sub 5: two-row choice menu
B0E_0F_OfficerBattleExpAccrueAndLevelUp = $D7FB ; Battle experience accrual and level-up application
B0E_0F_OfficerStatSumExpGrant = $D8B0 ; Donor Might+Intelligence -> recipient experience
B0E_0F_BattleAnimSoundEngine    = $D8D4 ; Battle animation script + sound engine
B0E_0F_BattleSoundChannelProc   = $DC59 ; Sound channel processing engine

;===============================================================================
; SECTION 9: Combined Banks $1B+$1C ($A000-$DFFF)
; Bank $1B at $A000-$BFFF paired with Bank $1C at $C000-$DFFF
; Strategy Mode frame update + command menu module (castle/army/warehouse/town/intrigue)
; Loaded via SwitchBankAC with Y=$3B ($3B & $1F = $1B)
; Entry points via jump table at $A000-$A00B
;===============================================================================

;-------------------------------------------------------------------------------
; Jump Table Entry Points ($A000-$A00B)
;-------------------------------------------------------------------------------
B1B_1C_StrategyFrameUpdate_Entry = $A000 ; StrategyFrameUpdate_Entry: per-frame Strategy Mode update (NmiState2_StrategyMap)
B1B_1C_ActionDeltaInputPoll_Entry = $A003 ; ActionDeltaInputPoll_Entry: war-scene action delta input poll
B1B_1C_OfficerSelectDialogPoll_Entry = $A006 ; OfficerSelectDialogPoll_Entry: Officer select dialog poll (dispatch callback target)
B1B_1C_ProvinceZoneOriginGet_Entry = $A009 ; ProvinceZoneOriginGet_Entry: Province id $000A -> map zone origin $000B/$000C

;-------------------------------------------------------------------------------
; Internal procs - Bank $1B ($A00C-$BFFF)
;-------------------------------------------------------------------------------
B1B_1C_StrategyFrameUpdate = $A00C      ; Per-frame Strategy Mode update (invoked by NmiState2_StrategyMap)
B1B_1C_CallCountryRotationDispatch = $A045   ; Banked-call wrapper -> B19_1A_CountryRotationDispatch
B1B_1C_CallProvinceOfficerRosterDispatch = $A04D ; Banked-call wrapper -> B19_1A_ProvinceOfficerRosterDispatch
B1B_1C_CallStrategyRequestDispatch = $A055 ; Banked-call wrapper -> B19_1A_StrategyRequestDispatch
B1B_1C_CallMonthlyEventDispatch = $A05D     ; Banked-call wrapper -> B19_1A_MonthlyEventDispatch
B1B_1C_CallOfficerStatusScene = $A065    ; Banked-call wrapper -> B19_1A_OfficerStatusScene
B1B_1C_CallSceneRenderer = $A06D         ; Banked-call wrapper -> B1D_1E_SceneRenderer
B1B_1C_CallUnificationEndingDispatch = $A075 ; Banked-call wrapper -> B19_1A_UnificationEndingDispatch
B1B_1C_MapRulerIntroDispatch = $A07D     ; Map ruler-intro sequence sub-state dispatch
B1B_1C_CommandCategoryMenuDispatch = $A18B ; Command category selection menu (state 1)
B1B_1C_CastleCommandDispatch = $A295     ; Castle command screen (state 2)
B1B_1C_ArmyCommandDispatch = $ADF2       ; Army command screen (state 3)
B1B_1C_WarehouseCommandDispatch = $B759  ; Warehouse command screen (state 4)
B1B_1C_TownCommandDispatch = $BFB7       ; Town command screen (state 5)
B1B_1C_IntrigueCommandDispatch = $CADF   ; Intrigue command screen (state 6)

;-------------------------------------------------------------------------------
; Internal procs - Bank $1C ($D2E3-$DFFF)
;-------------------------------------------------------------------------------
B1B_1C_PoachOddsCalc = $D2E3             ; Poach odds calculation
B1B_1C_DiscordLoyaltyDropCalc = $D3C5    ; Discord loyalty drop calculation
B1B_1C_PoachRosterTransfer = $D41B       ; Poached officer roster transfer
B1B_1C_AllianceListRowRender = $D472     ; Alliance list row render
B1B_1C_AllianceStateGet = $D4ED          ; Alliance state get (country pair)
B1B_1C_AllianceStateSet = $D508          ; Alliance state set
B1B_1C_MapCursorArrowDraw = $D543        ; Map cursor arrow sprite draw
B1B_1C_MapTransitionStateSave = $D568    ; Save map transition state
B1B_1C_MapTransitionStateRestore = $D58C ; Restore map transition state
B1B_1C_ConfirmDialogPoll = $D5BD         ; Shared confirm dialog poll
B1B_1C_OfficerSelectDialogPoll = $D64A   ; Officer select dialog poll (strategy mode)
B1B_1C_OfficerSelectRowMarkDraw = $D773  ; Officer select row mark repaint
B1B_1C_DialogWindowClose = $D7A8         ; Shared dialog/roster window close step
B1B_1C_OfficerTroopPoolAssignPoll = $D7C5 ; Troop pool distribution poll (dialog phase $10)
B1B_1C_TroopPoolRemainderSweep = $D987   ; Round troop count down + pool remainder sweep
B1B_1C_ActionDeltaInputPoll = $DA02      ; War-scene action delta input poll
B1B_1C_MathDivideProduct = $DB72         ; Tail-call wrapper for B1F_MathDiv24
B1B_1C_ActionDeltaWorkReset = $DB87      ; Clear numeric-input work area $048B-$048F
B1B_1C_CastleScoutOutcomeRoll = $DB99    ; Scout outcome roll for province $0402
B1B_1C_ProvinceOfficerCount = $DC6B      ; Count officers in province roster
B1B_1C_HospitalWoundedRosterBuild = $DC7C ; Hospital wounded candidate roster build
B1B_1C_TownFacilityMenuLayoutSelect = $DCD0 ; Facility menu layout selector
B1B_1C_ProvinceRulerIdGet = $DD4F        ; A = ruler id of province
B1B_1C_CountryRulerIdGet = $DD56         ; A = ruler id of country
B1B_1C_OfficerCardShow = $DD5E           ; Draw standing Officer card sprite
B1B_1C_MenuCursorReset = $DD70           ; Clear shared menu cursor
B1B_1C_ProvinceAdjacencyValidate = $DD79 ; Castle-move target adjacency validation
B1B_1C_OverlayIdleCheck = $DDAD          ; C=1 while overlay/anim queues $0300/$0301 idle
B1B_1C_CountryProvinceCount = $DDBF      ; Count provinces of country
B1B_1C_ClampProvinceGoldRice = $DDDC     ; Clamp 16-bit province Gold/Rice field
B1B_1C_MapCameraScroll = $DDF2           ; Map camera D-pad scroll with auto-repeat
B1B_1C_MapRulerMarkerDraw = $DE83        ; Ruler marker sprites at camera position
B1B_1C_MapProvinceHitTest = $DEBA        ; Hit-test province under map cursor
B1B_1C_ProvinceZoneOriginGet = $DF25     ; Province id -> map zone origin
B1B_1C_MapProvinceSpriteRefresh = $DF35  ; Rebuild animated province marker sprites + clear dirty bitmap

;-------------------------------------------------------------------------------
; Aliases (multi-entry proc sub-labels)
;-------------------------------------------------------------------------------
B0E_0F_SoundPlayAlt             = $DF6E ; BattleSoundChannelProc::SoundPlayAlt (alternate play entry)

.endif ; GUARD_FUNCTIONS_H
