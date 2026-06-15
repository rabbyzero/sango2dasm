#!/usr/bin/env python3
"""Generate disassembly for bank $1F range $F667-$FFFF."""

import sys

with open('rom/prg/prg_1f.bin', 'rb') as f:
    data = f.read()

# 6502 opcode table
opcodes = {
    0x00: ('BRK', 'imp', 1), 0x01: ('ORA', 'izx', 2), 0x05: ('ORA', 'zp', 2),
    0x06: ('ASL', 'zp', 2), 0x08: ('PHP', 'imp', 1), 0x09: ('ORA', 'imm', 2),
    0x0A: ('ASL', 'acc', 1), 0x0D: ('ORA', 'abs', 3), 0x0E: ('ASL', 'abs', 3),
    0x10: ('BPL', 'rel', 2), 0x11: ('ORA', 'izy', 2), 0x15: ('ORA', 'zpx', 2),
    0x16: ('ASL', 'zpx', 2), 0x18: ('CLC', 'imp', 1), 0x19: ('ORA', 'aby', 3),
    0x1D: ('ORA', 'abx', 3), 0x1E: ('ASL', 'abx', 3),
    0x20: ('JSR', 'abs', 3), 0x21: ('AND', 'izx', 2), 0x24: ('BIT', 'zp', 2),
    0x25: ('AND', 'zp', 2), 0x26: ('ROL', 'zp', 2), 0x28: ('PLP', 'imp', 1),
    0x29: ('AND', 'imm', 2), 0x2A: ('ROL', 'acc', 1), 0x2C: ('BIT', 'abs', 3),
    0x2D: ('AND', 'abs', 3), 0x2E: ('ROL', 'abs', 3),
    0x30: ('BMI', 'rel', 2), 0x31: ('AND', 'izy', 2), 0x35: ('AND', 'zpx', 2),
    0x36: ('ROL', 'zpx', 2), 0x38: ('SEC', 'imp', 1), 0x39: ('AND', 'aby', 3),
    0x3D: ('AND', 'abx', 3), 0x3E: ('ROL', 'abx', 3),
    0x40: ('RTI', 'imp', 1), 0x41: ('EOR', 'izx', 2), 0x45: ('EOR', 'zp', 2),
    0x46: ('LSR', 'zp', 2), 0x48: ('PHA', 'imp', 1), 0x49: ('EOR', 'imm', 2),
    0x4A: ('LSR', 'acc', 1), 0x4C: ('JMP', 'abs', 3), 0x4D: ('EOR', 'abs', 3),
    0x4E: ('LSR', 'abs', 3),
    0x50: ('BVC', 'rel', 2), 0x51: ('EOR', 'izy', 2), 0x55: ('EOR', 'zpx', 2),
    0x56: ('LSR', 'zpx', 2), 0x58: ('CLI', 'imp', 1), 0x59: ('EOR', 'aby', 3),
    0x5D: ('EOR', 'abx', 3), 0x5E: ('LSR', 'abx', 3),
    0x60: ('RTS', 'imp', 1), 0x61: ('ADC', 'izx', 2), 0x65: ('ADC', 'zp', 2),
    0x66: ('ROR', 'zp', 2), 0x68: ('PLA', 'imp', 1), 0x69: ('ADC', 'imm', 2),
    0x6A: ('ROR', 'acc', 1), 0x6C: ('JMP', 'ind', 3), 0x6D: ('ADC', 'abs', 3),
    0x6E: ('ROR', 'abs', 3),
    0x70: ('BVS', 'rel', 2), 0x71: ('ADC', 'izy', 2), 0x75: ('ADC', 'zpx', 2),
    0x76: ('ROR', 'zpx', 2), 0x78: ('SEI', 'imp', 1), 0x79: ('ADC', 'aby', 3),
    0x7D: ('ADC', 'abx', 3), 0x7E: ('ROR', 'abx', 3),
    0x81: ('STA', 'izx', 2), 0x84: ('STY', 'zp', 2), 0x85: ('STA', 'zp', 2),
    0x86: ('STX', 'zp', 2), 0x88: ('DEY', 'imp', 1), 0x8A: ('TXA', 'imp', 1),
    0x8C: ('STY', 'abs', 3), 0x8D: ('STA', 'abs', 3), 0x8E: ('STX', 'abs', 3),
    0x90: ('BCC', 'rel', 2), 0x91: ('STA', 'izy', 2), 0x94: ('STY', 'zpx', 2),
    0x95: ('STA', 'zpx', 2), 0x96: ('STX', 'zpy', 2), 0x98: ('TYA', 'imp', 1),
    0x99: ('STA', 'aby', 3), 0x9A: ('TXS', 'imp', 1), 0x9D: ('STA', 'abx', 3),
    0xA0: ('LDY', 'imm', 2), 0xA1: ('LDA', 'izx', 2), 0xA2: ('LDX', 'imm', 2),
    0xA4: ('LDY', 'zp', 2), 0xA5: ('LDA', 'zp', 2), 0xA6: ('LDX', 'zp', 2),
    0xA8: ('TAY', 'imp', 1), 0xA9: ('LDA', 'imm', 2), 0xAA: ('TAX', 'imp', 1),
    0xAC: ('LDY', 'abs', 3), 0xAD: ('LDA', 'abs', 3), 0xAE: ('LDX', 'abs', 3),
    0xB0: ('BCS', 'rel', 2), 0xB1: ('LDA', 'izy', 2), 0xB4: ('LDY', 'zpx', 2),
    0xB5: ('LDA', 'zpx', 2), 0xB6: ('LDX', 'zpy', 2), 0xB8: ('CLV', 'imp', 1),
    0xB9: ('LDA', 'aby', 3), 0xBA: ('TSX', 'imp', 1), 0xBC: ('LDY', 'abx', 3),
    0xBD: ('LDA', 'abx', 3), 0xBE: ('LDX', 'aby', 3),
    0xC0: ('CPY', 'imm', 2), 0xC1: ('CMP', 'izx', 2), 0xC4: ('CPY', 'zp', 2),
    0xC5: ('CMP', 'zp', 2), 0xC6: ('DEC', 'zp', 2), 0xC8: ('INY', 'imp', 1),
    0xC9: ('CMP', 'imm', 2), 0xCA: ('DEX', 'imp', 1), 0xCC: ('CPY', 'abs', 3),
    0xCD: ('CMP', 'abs', 3), 0xCE: ('DEC', 'abs', 3),
    0xD0: ('BNE', 'rel', 2), 0xD1: ('CMP', 'izy', 2), 0xD5: ('CMP', 'zpx', 2),
    0xD6: ('DEC', 'zpx', 2), 0xD8: ('CLD', 'imp', 1), 0xD9: ('CMP', 'aby', 3),
    0xDD: ('CMP', 'abx', 3), 0xDE: ('DEC', 'abx', 3),
    0xE0: ('CPX', 'imm', 2), 0xE1: ('SBC', 'izx', 2), 0xE4: ('CPX', 'zp', 2),
    0xE5: ('SBC', 'zp', 2), 0xE6: ('INC', 'zp', 2), 0xE8: ('INX', 'imp', 1),
    0xE9: ('SBC', 'imm', 2), 0xEA: ('NOP', 'imp', 1), 0xEC: ('CPX', 'abs', 3),
    0xED: ('SBC', 'abs', 3), 0xEE: ('INC', 'abs', 3),
    0xF0: ('BEQ', 'rel', 2), 0xF1: ('SBC', 'izy', 2), 0xF5: ('SBC', 'zpx', 2),
    0xF6: ('INC', 'zpx', 2), 0xF8: ('SED', 'imp', 1), 0xF9: ('SBC', 'aby', 3),
    0xFD: ('SBC', 'abx', 3), 0xFE: ('INC', 'abx', 3),
}

def get_byte(addr):
    return data[addr - 0xE000]

def get_bytes(addr, n):
    off = addr - 0xE000
    return data[off:off+n]

def disasm_one(addr):
    b = get_byte(addr)
    if b not in opcodes:
        return None, f'{b:02X}', 1
    mnem, mode, size = opcodes[b]
    raw = get_bytes(addr, size)
    byte_str = ' '.join(f'{x:02X}' for x in raw)
    if mode == 'imp': text = mnem
    elif mode == 'acc': text = f'{mnem} A'
    elif mode == 'imm': text = f'{mnem} #${raw[1]:02X}'
    elif mode == 'zp': text = f'{mnem} ${raw[1]:02X}'
    elif mode == 'zpx': text = f'{mnem} ${raw[1]:02X},X'
    elif mode == 'zpy': text = f'{mnem} ${raw[1]:02X},Y'
    elif mode == 'abs':
        val = raw[1] | (raw[2] << 8)
        text = f'{mnem} ${val:04X}'
    elif mode == 'abx':
        val = raw[1] | (raw[2] << 8)
        text = f'{mnem} ${val:04X},X'
    elif mode == 'aby':
        val = raw[1] | (raw[2] << 8)
        text = f'{mnem} ${val:04X},Y'
    elif mode == 'ind':
        val = raw[1] | (raw[2] << 8)
        text = f'{mnem} (${val:04X})'
    elif mode == 'izx': text = f'{mnem} (${raw[1]:02X},X)'
    elif mode == 'izy': text = f'{mnem} (${raw[1]:02X}),Y'
    elif mode == 'rel':
        offset_val = raw[1]
        if offset_val >= 0x80: offset_val -= 256
        target = addr + 2 + offset_val
        text = f'{mnem} ${target:04X}'
    else: text = mnem
    return text, byte_str, size

# All labels for this range
all_labels = {
    0xF800: 'NmiHandler', 0xF83C: '@skip_to_busy', 0xF83F: '@nmi_main',
    0xF87B: 'NmiDispatchTable', 0xF88D: 'NmiEpilogue',
    0xF8AF: '@restore_regs', 0xF8B5: 'NmiState2_MapScreen',
    0xF8FE: 'NmiState3_Battle', 0xF93D: '@skip_weather',
    0xF96A: 'NmiState4_Menu', 0xF9A0: 'NmiState5_Diplomacy',
    0xF9E4: 'NmiState6_Event', 0xFA13: 'NmiState7_Strategy',
    0xFA53: 'NmiState8_Officer', 0xFA97: 'NmiState0_Idle',
    0xFAA9: 'SwapPlayerPointers', 0xFABE: '@rts_swap',
    0xFABF: 'RestorePlayerPointers', 0xFAD4: '@rts_restore',
    0xFAD5: 'NmiHandler_Busy', 0xFB0B: 'SetupChrBanksAndWait',
    0xFB22: '@wait_vbl_flag', 0xFB28: 'WaitVBlank',
    0xFB2D: 'IrqHandler', 0xFB3C: '@irq_hang',
    0xFB3F: '@irq_dispatch', 0xFB50: '@check_mode2',
    0xFB56: '@check_mode3', 0xFB5C: '@check_mode4',
    0xFB62: '@check_mode5', 0xFB68: '@check_mode6',
    0xFB6E: '@check_mode7', 0xFB74: '@check_mode8',
    0xFB7A: '@check_mode9', 0xFB80: '@check_mode10',
    0xFB86: '@check_mode11', 0xFB8C: '@check_mode12',
    0xFB92: '@irq_exit_sei', 0xFB9E: 'IrqExit',
    0xFBA4: 'IrqMode1_SoundAndChr', 0xFBCE: 'IrqChrUpdate_Block1',
    0xFBFC: 'IrqChrUpdate_Block2', 0xFC2A: 'IrqChrUpdate_Block3',
    0xFC58: 'IrqChrUpdate_Block4', 0xFC8B: 'IrqMode2_FullSetup',
    0xFCC9: '@delay_loop1', 0xFCE5: '@delay_loop2',
    0xFD00: '@delay_loop3', 0xFD1A: 'ScanlineDelayTable',
    0xFD2A: 'IrqMode4_SimpleChr', 0xFD46: '@delay1',
    0xFD62: '@delay2', 0xFD7B: '@delay3',
    0xFD95: 'IrqMode5_PpuAddrChr', 0xFDF4: 'IrqMode6_Minimal',
    0xFE03: 'IrqMode7_SoundChr', 0xFE1F: '@mode7_dispatch',
    0xFE57: '@jmp_block1', 0xFE59: '@jmp_block2',
    0xFE5B: '@jmp_block3', 0xFE61: 'IrqMode7_Exit',
    0xFE69: 'IrqMode8_SoundChr', 0xFE87: '@mode8_check1',
    0xFE8D: '@mode8_check2', 0xFE93: '@mode8_jmp4',
    0xFE96: 'IrqMode9_BasicChr', 0xFECD: 'IrqMode10_PpuScroll',
    0xFF03: '@delay_m10', 0xFF31: 'IrqMode11_ScrollFwd',
    0xFF48: 'IrqMode12_ScrollBack', 0xFF62: 'CalcScrollAddr',
    0xFF9A: '@rts_calc', 0xFF9B: 'CalcScrollAddrAlt',
    0xFFD6: '@rts_calc_alt', 0xFC99: '@delay_spin1',
    0xFF90: '@check_nt', 0xFFC6: '@check_nt_alt',
    0xFBAC: '@check_sub1', 0xFBBA: '@check_sub2',
}

def emit_instr(addr):
    text, byte_str, size = disasm_one(addr)
    if text is None:
        bval = get_byte(addr)
        line = f'  .byte ${bval:02X}' + ' ' * 38 + f'; ${addr:04X}: {byte_str}'
        return line, size
    # Substitute labels for branches/jumps
    b = get_byte(addr)
    if b in opcodes:
        mnem, mode, _ = opcodes[b]
        if mode == 'rel':
            raw = get_bytes(addr, 2)
            ov = raw[1]
            if ov >= 0x80: ov -= 256
            target = addr + 2 + ov
            if target in all_labels:
                text = f'{mnem} {all_labels[target]}'
        elif mode == 'abs' and mnem in ('JMP', 'JSR'):
            raw = get_bytes(addr, 3)
            target = raw[1] | (raw[2] << 8)
            if target in all_labels:
                text = f'{mnem} {all_labels[target]}'
        elif mode == 'aby':
            raw = get_bytes(addr, 3)
            target = raw[1] | (raw[2] << 8)
            if target in all_labels:
                text = f'{mnem} {all_labels[target]},Y'
    padding = max(1, 46 - 2 - len(text))
    line = f'  {text}' + ' ' * padding + f'; ${addr:04X}: {byte_str}'
    return line, size

def emit_code_range(start, end):
    """Emit disassembled instructions for a range, with labels."""
    result = []
    addr = start
    while addr <= end:
        if addr in all_labels:
            lbl = all_labels[addr]
            if lbl.startswith('@'):
                result.append(f'{lbl}:')
        line, size = emit_instr(addr)
        result.append(line)
        addr += size
    return result

def emit_data_line(addr, count):
    bs = get_bytes(addr, count)
    hex_vals = ','.join(f'${b:02X}' for b in bs)
    hex_comment = ' '.join(f'{b:02X}' for b in bs)
    return f'  .byte {hex_vals:<48s}; ${addr:04X}: {hex_comment}'

lines = []
lines.append(';===============================================================================')
lines.append('; Bank $1F Disassembly: $F667-$FFFF')
lines.append('; NMI handler, IRQ handler, scroll routines, and interrupt vectors')
lines.append(';===============================================================================')
lines.append('')
lines.append('.segment "CODE_BANK1F"')
lines.append('')

# Padding zeros $F667-$F67E
lines.append(';===============================================================================')
lines.append('; $F667-$F67E: Unused padding (24 bytes of $00)')
lines.append(';===============================================================================')
addr = 0xF667
while addr <= 0xF67E:
    chunk = min(16, 0xF67E - addr + 1)
    lines.append(emit_data_line(addr, chunk))
    addr += chunk
lines.append('')

# FF padding $F67F-$F7FF
lines.append(';===============================================================================')
lines.append('; $F67F-$F7FF: Unused space (385 bytes of $FF)')
lines.append(';===============================================================================')
addr = 0xF67F
while addr <= 0xF7FF:
    chunk = min(16, 0xF7FF - addr + 1)
    lines.append(emit_data_line(addr, chunk))
    addr += chunk
lines.append('')

# NMI Handler
lines.append(';===============================================================================')
lines.append('; $F800: NmiHandler')
lines.append('; Non-Maskable Interrupt handler. Saves registers, configures Namco-163')
lines.append('; sound/IRQ, sets nametable mirroring, restores PRG banks, performs OAM DMA,')
lines.append('; then dispatches to a game-state-specific VBlank handler via jump table.')
lines.append(';===============================================================================')
lines.append('.proc NmiHandler')
lines.extend(emit_code_range(0xF800, 0xF87A))
lines.append('.endproc')
lines.append('')

# NMI Dispatch Table
lines.append(';===============================================================================')
lines.append('; $F87B: NmiDispatchTable - Jump table for NMI game state dispatch.')
lines.append('; 9 interleaved lo/hi address pairs. Index = ($78 & $0F) * 2.')
lines.append(';===============================================================================')
lines.append('NmiDispatchTable:')
addr = 0xF87B
lines.append(emit_data_line(addr, 10))
addr += 10
lines.append(emit_data_line(addr, 8))
lines.append('')

# NMI Epilogue
lines.append(';===============================================================================')
lines.append('; $F88D: NmiEpilogue')
lines.append('; Restores PRG banks, increments tick counters, restores regs, RTI.')
lines.append(';===============================================================================')
lines.append('.proc NmiEpilogue')
lines.extend(emit_code_range(0xF88D, 0xF8B4))
lines.append('.endproc')
lines.append('')

# Game state handlers
def emit_state(name, start, end, desc):
    lines.append(f';--- {desc} ---')
    lines.append(f'.proc {name}')
    lines.extend(emit_code_range(start, end))
    lines.append('.endproc')
    lines.append('')

emit_state('NmiState2_MapScreen', 0xF8B5, 0xF8FB, '$F8B5: VBlank handler - map screen')
emit_state('NmiState3_Battle', 0xF8FE, 0xF967, '$F8FE: VBlank handler - battle')
emit_state('NmiState4_Menu', 0xF96A, 0xF99D, '$F96A: VBlank handler - menu')
emit_state('NmiState5_Diplomacy', 0xF9A0, 0xF9E1, '$F9A0: VBlank handler - diplomacy')
emit_state('NmiState6_Event', 0xF9E4, 0xFA10, '$F9E4: VBlank handler - event')
emit_state('NmiState7_Strategy', 0xFA13, 0xFA50, '$FA13: VBlank handler - strategy')
emit_state('NmiState8_Officer', 0xFA53, 0xFA94, '$FA53: VBlank handler - officer mgmt')
emit_state('NmiState0_Idle', 0xFA97, 0xFAA6, '$FA97: VBlank handler - idle (states 0,1)')

# Swap/Restore
emit_state('SwapPlayerPointers', 0xFAA9, 0xFABE, '$FAA9: Swap player pointers if 2P')
emit_state('RestorePlayerPointers', 0xFABF, 0xFAD4, '$FABF: Restore player pointers')

# NmiHandler_Busy
emit_state('NmiHandler_Busy', 0xFAD5, 0xFB08, '$FAD5: NMI when busy ($7B != 0)')

# SetupChrBanksAndWait
lines.append(';--- $FB0B: Setup CHR banks and wait for sprite-0 ---')
lines.append('.proc SetupChrBanksAndWait')
lines.extend(emit_code_range(0xFB0B, 0xFB27))
lines.append('.endproc')
lines.append('')

# WaitVBlank
lines.append(';--- $FB28: Wait for VBlank completion (poll $62) ---')
lines.append('.proc WaitVBlank')
lines.extend(emit_code_range(0xFB28, 0xFB2C))
lines.append('.endproc')
lines.append('')

# IRQ Handler
lines.append(';===============================================================================')
lines.append('; $FB2D: IrqHandler')
lines.append('; Scanline IRQ (Namco-163). Dispatches to 12 modes based on $0060.')
lines.append(';===============================================================================')
lines.append('.proc IrqHandler')
lines.extend(emit_code_range(0xFB2D, 0xFB9D))
lines.append('.endproc')
lines.append('')

# IrqExit
lines.append(';--- $FB9E: IrqExit - restore regs and RTI ---')
lines.append('IrqExit:')
lines.extend(emit_code_range(0xFB9E, 0xFBA3))
lines.append('')

# IRQ mode handlers
emit_state('IrqMode1_SoundAndChr', 0xFBA4, 0xFBCB, '$FBA4: IRQ modes 1,3 - sound regs + CHR dispatch')
emit_state('IrqChrUpdate_Block1', 0xFBCE, 0xFBFB, '$FBCE: CHR update block 1')
emit_state('IrqChrUpdate_Block2', 0xFBFC, 0xFC27, '$FBFC: CHR update block 2')
emit_state('IrqChrUpdate_Block3', 0xFC2A, 0xFC55, '$FC2A: CHR update block 3')
emit_state('IrqChrUpdate_Block4', 0xFC58, 0xFC88, '$FC58: CHR update block 4 (resets counter)')
emit_state('IrqMode2_FullSetup', 0xFC8B, 0xFD17, '$FC8B: IRQ mode 2 - full CHR/PPU with delays')

# Scanline delay table
lines.append(';--- $FD1A: Scanline delay table (8 pairs) ---')
lines.append('ScanlineDelayTable:')
lines.append(emit_data_line(0xFD1A, 8))
lines.append(emit_data_line(0xFD22, 8))
lines.append('')

emit_state('IrqMode4_SimpleChr', 0xFD2A, 0xFD92, '$FD2A: IRQ mode 4 - simple CHR with ZP delays')
emit_state('IrqMode5_PpuAddrChr', 0xFD95, 0xFDF3, '$FD95: IRQ mode 5 - PPU addr + CHR + nametable')
emit_state('IrqMode6_Minimal', 0xFDF4, 0xFE02, '$FDF4: IRQ mode 6 - minimal (disable + exit)')
emit_state('IrqMode7_SoundChr', 0xFE03, 0xFE66, '$FE03: IRQ mode 7 - sound + CHR sub-dispatch')
emit_state('IrqMode8_SoundChr', 0xFE69, 0xFE93, '$FE69: IRQ mode 8 - sound + CHR variant')
emit_state('IrqMode9_BasicChr', 0xFE96, 0xFECA, '$FE96: IRQ mode 9 - basic CHR')
emit_state('IrqMode10_PpuScroll', 0xFECD, 0xFF2E, '$FECD: IRQ mode 10 - PPU scroll + CHR')
emit_state('IrqMode11_ScrollFwd', 0xFF31, 0xFF45, '$FF31: IRQ mode 11 - scroll forward')
emit_state('IrqMode12_ScrollBack', 0xFF48, 0xFF5F, '$FF48: IRQ mode 12 - scroll backward')

# Scroll calc routines
lines.append(';===============================================================================')
lines.append('; $FF62: CalcScrollAddr')
lines.append('; Calculates PPU scroll address from map position ($0098).')
lines.append('; Output: $0099=copy, $009A/$009B=PPU addr, $00EA/$00EC=nametable.')
lines.append(';===============================================================================')
lines.append('.proc CalcScrollAddr')
lines.extend(emit_code_range(0xFF62, 0xFF9A))
lines.append('.endproc')
lines.append('')

lines.append(';===============================================================================')
lines.append('; $FF9B: CalcScrollAddrAlt')
lines.append('; Alternate version: adds +4 to $009B when on nametable $E1.')
lines.append(';===============================================================================')
lines.append('.proc CalcScrollAddrAlt')
lines.extend(emit_code_range(0xFF9B, 0xFFD6))
lines.append('.endproc')
lines.append('')

# Final FF padding
lines.append(';===============================================================================')
lines.append('; $FFD7-$FFF9: Unused space (35 bytes of $FF)')
lines.append(';===============================================================================')
addr = 0xFFD7
while addr <= 0xFFF9:
    chunk = min(16, 0xFFF9 - addr + 1)
    lines.append(emit_data_line(addr, chunk))
    addr += chunk
lines.append('')

# Interrupt Vectors
lines.append(';===============================================================================')
lines.append('; $FFFA-$FFFF: 6502 Interrupt Vectors')
lines.append(';===============================================================================')
nmi = get_byte(0xFFFA) | (get_byte(0xFFFB) << 8)
rst = get_byte(0xFFFC) | (get_byte(0xFFFD) << 8)
irq = get_byte(0xFFFE) | (get_byte(0xFFFF) << 8)
lines.append(f'  .word NmiHandler                              ; $FFFA: {get_byte(0xFFFA):02X} {get_byte(0xFFFB):02X} (NMI -> ${nmi:04X})')
lines.append(f'  .word $E000                                   ; $FFFC: {get_byte(0xFFFC):02X} {get_byte(0xFFFD):02X} (RESET -> ${rst:04X})')
lines.append(f'  .word IrqHandler                              ; $FFFE: {get_byte(0xFFFE):02X} {get_byte(0xFFFF):02X} (IRQ -> ${irq:04X})')
lines.append('')

with open('asm/banks/prg_1f_F667_FFFF.asm', 'w') as f:
    f.write('\n'.join(lines))
    f.write('\n')

print(f"Generated {len(lines)} lines")
