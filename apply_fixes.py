#!/usr/bin/env python3
"""Apply all manual fixes to prg_1f.asm after the transformation pipeline."""
import re

SOURCE = 'asm/banks/prg_1f.asm'

with open(SOURCE) as f:
    content = f.read()

# 1. Fix orphan .endproc and spurious .byte at $E841/$E842
content = content.replace(
    "  BNE @loc_e837                                ; $E840: D0 F5\n\n  .byte $00                 ; $E841: 00\n.endproc\npad_e842:\n  .byte $00                 ; $E842: 00\n",
    "  BNE @loc_e837                                ; $E840: D0 F5\npad_e842:\n  .byte $60                 ; $E842: 60\n"
)

# 2. Add global aliases before .segment
ALIASES = """
; Global aliases - cross-bank function targets
BankXX_Func_A000 = $A000
BankXX_Func_A003 = $A003
BankXX_Func_A006 = $A006
BankXX_Func_A009 = $A009
BankXX_Func_A00C = $A00C
BankXX_Func_A00F = $A00F
BankXX_Func_A012 = $A012
BankXX_Func_A015 = $A015
BankXX_Func_A018 = $A018
BankXX_Func_A01B = $A01B
BankXX_Func_A01E = $A01E
BankXX_Func_A024 = $A024
BankXX_Func_A027 = $A027
BankXX_Func_A036 = $A036
BankXX_Func_A03F = $A03F
BankXX_Func_A045 = $A045

; Global aliases - internal entry points
PpuMaskHelper_Clear = $E74D
PpuCtrlNmiHelpers_NmiDisable = $E768
NametableFill_entry = $E7B5
SoundInit_entry = $E5F3
PaletteAnimation_alt = $ECBF
MenuCursorSystem_entry = $ED41
MenuCursorSystem_btnA = $ED71
MenuCursorSystem_btnB = $ED8D
MenuCursorSystem_btnSelect = $EDA9
MenuCursorSystem_btnStart = $EDBE
WindowDisplaySetup_alt = $F24B
RamIntegrityTest_copy = $F43F
RamIntegrityTest_init = $F458
NmiHandler_dispatch = $F88D
NmiHandler_common = $F8AF
IrqFlagWait = $FB28
IrqHandler_deadloop = $FB3C
IrqHandler_exit = $FB9E
IrqHandler_fe61 = $FE61

; Global aliases - dead code labels
loc_ede2 = $EDE2
loc_eded = $EDED
loc_e4d1 = $E4D1

; Global aliases - sub-state dispatch targets
sub_state_1 = $FBA4
sub_state_2 = $FC8B
sub_state_3 = $FD2A
sub_state_4 = $FD95
sub_state_5 = $FDF4
sub_state_6 = $FE03
sub_state_7 = $FE69
sub_state_8 = $FE96
sub_state_9 = $FECD
sub_state_10 = $FF31
sub_state_11 = $FF48
sub_state_1a = $FBCE
sub_state_1b = $FBFC
sub_state_1c = $FC2A
sub_state_1d = $FC58

"""
content = content.replace('.segment "CODE_BANK1F"\n', ALIASES + '.segment "CODE_BANK1F"\n')

# 3. Add dispatch_loop label at $E066
content = content.replace(
    "  STA $007A                 ; $E063: 8D 7A 00\n  LDA $007A                 ; $E066: AD 7A 00\n",
    "  STA $007A                 ; $E063: 8D 7A 00\ndispatch_loop:\n  LDA $007A                 ; $E066: AD 7A 00\n"
)

# 4. Add loc_e1ba label at $E1BA
content = content.replace(
    "  JSR $A003                 ; $E1B7: 20 03 A0\n  LDA $0510                 ; $E1BA: AD 10 05\n",
    "  JSR $A003                 ; $E1B7: 20 03 A0\nloc_e1ba:\n  LDA $0510                 ; $E1BA: AD 10 05\n"
)

# 5. Replace loc_f8af with NmiHandler_common and remove physical label
content = content.replace('loc_f8af', 'NmiHandler_common')
content = content.replace(
    "  INC $5F                   ; $F8AD: E6 5F\nNmiHandler_common:\n  PLA                       ; $F8AF: 68\n",
    "  INC $5F                   ; $F8AD: E6 5F\n  PLA                       ; $F8AF: 68\n"
)

# 6. Replace @loc_fb28 with IrqFlagWait and remove physical label
content = content.replace('@loc_fb28', 'IrqFlagWait')
content = content.replace(
    "  RTS                       ; $FB27: 60\nIrqFlagWait:\n  LDA $62                   ; $FB28: A5 62\n",
    "  RTS                       ; $FB27: 60\n  LDA $62                   ; $FB28: A5 62\n"
)

with open(SOURCE, 'w') as f:
    f.write(content)

lines = content.split('\n')
print(f"Applied all fixes. {len(lines)} lines.")
print(f"  .proc count: {content.count('.proc ')}")
print(f"  .endproc count: {content.count('.endproc')}")
