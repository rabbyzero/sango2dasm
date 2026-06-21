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
;-------------------------------------------------------------------------------
B17_18_PpuWriteRle        = $A000   ; Entry00: RLE-encoded PPU data writer
B17_18_PpuCopyRaw         = $A003   ; Entry01: Raw 1KB PPU data copy
B17_18_PpuWriteTileOffset = $A006   ; Entry02: PPU tile data write with offset
B17_18_DisplayScrollLoop  = $A009   ; Entry03: Display scroll and render loop
B17_18_DisplayAndChrSetup = $A00C   ; Entry04: Display coordinate check + CHR setup
B17_18_BattleEffects      = $A00F   ; Entry05: Battle visual effects
B17_18_BattleDispatch     = $A012   ; Entry06: Battle dispatch
B17_18_OverlayWindow      = $A015   ; Entry07: Overlay/window rendering
B17_18_AdvisorDialogue    = $A018   ; Entry08: Advisor/council dialogue system
B17_18_MainGameDispatch   = $A01B   ; Entry09: Main game mode dispatcher
B17_18_DomesticActionDispatch = $A01E ; Entry0A: Domestic action dispatcher
B17_18_AnimationDispatch  = $A021   ; Entry0B: Animation dispatch
B17_18_DomesticDisplay    = $A024   ; Entry0C: Domestic affairs display
B17_18_DataRecordLoader   = $A027   ; Entry0D: Data record loader
; Internal function/data symbols in prg_17_18.asm use unprefixed names
; (no B17_18_ prefix). They are only referenced within that file, so
; no = assignments are needed here.

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
