# Bank 0x1F Function Table

| Address | End | Name | Type | Size | Description |
|---------|-----|------|------|------|-------------|
| $E000 | $E078 | Reset | func | 121 | Reset handler: init PPU, RAM, mapper, dispatch state |
| $E07C | $E099 | VectorTable | table | 30 | State dispatch table (15 entries, 2 bytes each) |
| $E09A | $E0D8 | State_SystemInit | func | 63 | Entry 0: System init, PPU setup, transition to state 9 |
| $E0DA | $E17B | State_NewGameInit | func | 162 | Entry 1: New game init, display, SRAM init, music $81 |
| $E17D | $E189 | State_RandomDisplay2A | func | 13 | Entry 2: Random + display (Y=$2A), brief transition |
| $E18B | $E21F | State_KingdomSelect | func | 150 | Entry 3: Kingdom select, scenario/normal mode |
| $E221 | $E22D | State_RandomDisplay28 | func | 13 | Entry 4: Random + display (Y=$28), brief transition |
| $E22F | $E2C0 | State_DomesticAffairs | func | 146 | Entry 5: Domestic affairs, action selection |
| $E29C | $E2C0 | DomesticActionLookup | func | 37 | Domestic action display lookup by $0544 |
| $E2C2 | $E2DD | DomesticGraphicPtrs | table | 28 | 7 graphic pointers for domestic actions |
| $E2DE | $E2E1 | DomesticSpriteYPos | table | 4 | Sprite Y position table (4 bytes) |
| $E2E2 | $E2E6 | State_RandomAdvance1 | func | 5 | Entry 6: Pure RNG advance, no display |
| $E2E8 | $E368 | State_BattlePhase | func | 225 | Entry 7: Battle phase, army status check |
| $E36A | $E36E | State_RandomAdvance2 | func | 5 | Entry 8: Pure RNG advance, no display |
| $E370 | $E37A | DisplayInit | func | 11 | Display init helper: window clear + bank display |
| $E37C | $E3E9 | State_TerritoryView | func | 110 | Entry 9: Territory/map view |
| $E3EB | $E3EC | State_IdleWait | func | 3 | Entry 10/12/14: Idle wait, JMP dispatch |
| $E3EE | $E468 | State_AdvisorCouncil | func | 123 | Entry 11: Advisor/council dialogue |
| $E46A | $E4D8 | State_TurnSummary | func | 111 | Entry 13: Turn summary/report |
| $E4DA | $E51D | FrameInit | func | 68 | Per-frame setup: PPU, bank, clear working RAM |
| $E51F | $E565 | BankSwitch | func | 71 | 8-byte config bank switch (Namco-163 PRG) |
| $E567 | $E57D | BankSwitchTable | table | 23 | Bank switch configuration table |
| $E57F | $E58E | BankPpuInit | func | 16 | Bank + PPU init + JMP patch |
| $E590 | $E5F8 | SoundInit | func | 105 | Sound init: APU, RAM clear, wavetable upload |
| $E5FA | $E607 | WavetableWriteDelay | func | 14 | Wavetable write timing delay |
| $E609 | $E665 | SoundNotePlayer | func | 93 | Sound note player from banked ROM |
| $E667 | $E669 | SoundChannelTable | table | 3 | Sound channel table (4 bytes) |
| $E66B | $E6A4 | SoundWrappers | func | 58 | Sound wrapper functions (8 variants) |
| $E6A6 | $E6C4 | WavetableInitData | table | 32 | Namco-163 wavetable init data |
| $E6C6 | $E70C | ControllerRead | func | 71 | Controller read from $4016/$4017 |
| $E70E | $E747 | PaletteUpload | func | 58 | Upload palette $0100-$011F to PPU |
| $E749 | $E751 | PpuMaskHelper | func | 9 | PPU mask helper ($1E or $00) |
| $E753 | $E772 | PpuCtrlNmiHelpers | func | 32 | PPU ctrl/NMI helpers |
| $E774 | $E7DD | NametableFill1 | func | 106 | Nametable fill mode 1 |
| $E7DF | $E821 | NametableFill2 | func | 68 | Nametable fill mode 2 |
| $E823 | $E841 | SpriteBufferInit | func | 31 | Fill sprite buffer $0200-$02FF with $F0 |
| $E843 | $E849 | RandomBelow100 | func | 7 | Random byte < 100 |
| $E84B | $E84E | RandomDiv2 | func | 4 | Random byte / 2 |
| $E850 | $E860 | RandomModPow2 | func | 17 | Random mod 4/8/16 |
| $E862 | $E878 | RandomBelowThreshold | func | 23 | Random below threshold |
| $E87A | $E888 | RandomByte | func | 15 | RNG core: table lookup at $E8BA |
| $E88A | $E8B8 | RandomVariants | func | 47 | RNG variants ($0052/$0054/$0055) |
| $E8BA | $E9B8 | RandomTable | table | 256 | Pre-computed random data |
| $E9BA | $EA7A | MathBinToBcd | func | 193 | 24-bit binary to 6-digit packed BCD |
| $EA7C | $EAA3 | MathDiv16 | func | 40 | 16-bit unsigned division (16 iterations) |
| $EAA5 | $EADC | MathDiv24 | func | 56 | 24-bit unsigned division (24 iterations) |
| $EADE | $EAF5 | CallbackDispatcher | func | 24 | Inline pointer table callback dispatcher |
| $EAF7 | $EB01 | ScrollSet | func | 11 | PPU scroll register write |
| $EB03 | $EB18 | PpuCtrlNametableUpdate | func | 22 | PPU ctrl nametable bit update |
| $EB1A | $EB2B | WindowReset | func | 18 | Window/reset PPU helper |
| $EB2D | $EBAF | MathBcdToBin | func | 131 | 6-digit packed BCD to 24-bit binary |
| $EBB1 | $EBB4 | MathExtractUpperNibble | func | 4 | Extract upper nibble (4x LSR) |
| $EBB6 | $EBC8 | MathAccumulate24 | func | 19 | 24-bit accumulate add |
| $EBCA | $EBE7 | MathMulDiv100 | func | 30 | 16-bit * 8-bit / 100 |
| $EBE9 | $EC20 | MathMul24x8 | func | 56 | 24x8 multiply (32-bit result) |
| $EC22 | $EC65 | MathMul24x16 | func | 68 | 24x16 multiply (40-bit result) |
| $EC67 | $ECED | PaletteAnimation | func | 40 | Palette color rotation/animation |
| $ED19 | $EDEB | MenuCursorSystem | func | 212 | Menu cursor engine (8 entry points) |
| $EDDD | $EDF3 | MenuItemLookup | func | 23 | Menu item lookup by page*step+column |
| $EDF5 | $EE05 | PointerTableLookup | func | 17 | Pointer table lookup + sprite write |
| $EE07 | $EE4B | BankedCallbackTrampoline | func | 69 | Banked call with stack manipulation |
| $EE4D | $EE51 | BankedCallbackReturn | func | 5 | Return stub: restore bank, return |
| $EE53 | $EF09 | NmiSubDispatch | func | 183 | NMI sub-dispatch by $007E flags |
| $EF0B | $EF6F | PpuBgTileWrite | func | 102 | PPU BG tile write from buffer |
| $EF71 | $EFBF | PpuSpriteTileWrite | func | 78 | PPU sprite tile write from buffer |
| $EFC0 | $F026 | PpuAttrTileWrite | func | 103 | PPU attribute tile write |
| $F028 | $F075 | PpuAttrTileWriteAlt | func | 78 | PPU attribute tile write (alt) |
| $F077 | $F090 | NamcoSoundRegRead | func | 26 | Namco-163 sound register read |
| $F092 | $F1AB | SpriteOamWriterScroll | func | 186 | Sprite OAM writer with scroll offset |
| $F1AD | $F204 | SpriteOamWriterSimple | func | 88 | Sprite OAM writer direct placement |
| $F206 | $F235 | ChrBankSwitch | func | 48 | CHR bank switch (8 registers) |
| $F237 | $F25D | WindowDisplaySetup | func | 39 | Window/display setup variant 1 |
| $F25F | $F264 | WindowSetup2 | func | 6 | Window setup variant 2 |
| $F266 | $F2AD | WindowSetupHelpers | func | 72 | Window setup helper functions |
| $F2AF | $F2D5 | GetHeroAddr | func | 39 | Hero address: id*32+$6000 |
| $F2D7 | $F306 | GetCityAddr | func | 48 | City address: id*12+$63C0 |
| $F308 | $F35D | GetHeroKataName | func | 86 | Hero kata name: id*10+$901A |
| $F35F | $F366 | KataNameWidthTable | table | 8 | Kata name character width table |
| $F368 | $F385 | GetKingdomAddr | func | 30 | Kingdom address from pointer table |
| $F379 | $F385 | KingdomPtrTable | table | 13 | 7 kingdom SRAM pointers |
| $F387 | $F3BB | GetHeroInitialData | func | 53 | Hero initial data: id*12+$8000 |
| $F3BD | $F420 | MapperInitCtrlCheck | func | 102 | Mapper init + controller validation |
| $F422 | $F475 | RamIntegrityTest | func | 84 | RAM integrity test ($AA write/verify) |
| $F477 | $F675 | SoundMusicData | data | 512 | Sound/music instrument data |
| $F677 | $F7FE | Padding1 | padding | 392 | Unused ROM padding ($FF) |
| $F800 | $FAA7 | NmiHandler | func | 680 | NMI handler (8 sub-states) |
| $FAA9 | $FABD | PaletteSwapA | func | 21 | Palette swap (if $6F44!=0) |
| $FABF | $FAD3 | PaletteSwapB | func | 21 | Palette swap reverse |
| $FAD5 | $FB09 | NmiScrollMode | func | 53 | NMI scroll mode with CHR restore |
| $FB0B | $FB2B | ControllerReadBankRestore | func | 33 | Controller read + bank restore |
| $FB2D | $FF5E | IrqHandler | func | 990 | IRQ handler (14+ sub-states for raster) |
| $FF62 | $FF99 | ScrollCalcA | func | 56 | Scroll calc: $009A/$009B from $0098 |
| $FF9B | $FFD5 | ScrollCalcB | func | 59 | Scroll calc variant B |
| $FFD7 | $FFF9 | Padding2 | padding | 35 | Unused ROM padding ($FF) |