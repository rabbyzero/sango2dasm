#!/usr/bin/env python3
"""Decode UI panel scripts (B1F_SetUI ids) from PRG banks $32/$33.

Path: B1F_SetUI0 writes panel id to $0311; B1D_1E_MenuUpdate renders via
CalcMenuDataPtr (prg_1d_1e $A61D):
  word ptr = [$8000 + id*2] in bank PosDataBankTable[...] ($33 or $32)
  script   = ptr + $20 (or + $40 for bank table index 3-8)
Script stream: $00-$7F tiles (chars), $80-$9F commands (MenuDispatchTable),
operands of $86-$8F/$9C-$9F are raw bytes skipped here.
"""
import sys
sys.path.insert(0, '/home/zero/project/sango2dasm/tools')
from charmap_kana import KATAKANA, HIRAGANA_MENU, DAKUTEN, HANDAKUTEN

BASE = '/home/zero/project/sango2dasm/rom/prg'
banks = {}
for b in (0x12, 0x13):
    with open(f'{BASE}/prg_{b:02x}.bin', 'rb') as f:
        banks[b] = f.read()

def bank_key(table_idx):
    # PosDataBankTable values $32/$33 -> PRG $12/$13 via 5-bit mask
    table = [0x33,0x33,0x33,0x32,0x32,0x32,0x32,0x32,0x32,0x33,0x33,0x33,
             0x33,0x33,0x33]
    return table[table_idx] & 0x1F

def charof(t):
    if t in KATAKANA: return KATAKANA[t]
    if t in HIRAGANA_MENU: return HIRAGANA_MENU[t]
    if 0x76 <= t <= 0x7F: return f'{t-0x76}'
    if t == 0x01: return ' '
    if t == 0x00: return '\n'
    if t == DAKUTEN: return ''
    if t == HANDAKUTEN: return ''
    return None

CMD_NAMES = {0x80:'END',0x81:'ROW',0x82:'PUSH',0x83:'POP',0x84:'OVL+',0x85:'OVL-',
             0x86:'POS',0x87:'IND+',0x88:'IND-',0x89:'TILOFF',
             0x90:'NAME0',0x91:'NAME1',0x92:'NAME2',0x93:'NAME3',0x94:'NAME4',
             0x95:'NAME5',0x96:'NAME6',0x97:'NAME7',
             0x98:'NUM0',0x99:'NUM1',0x9A:'NUM2',0x9B:'NUM3',
             0x9C:'NAME6D',0x9D:'NAME7D',0x9E:'FMTNUM',0x9F:'NAMEP'}
# operand byte counts for commands that consume raw bytes
CMD_OPERANDS = {0x86:2,0x8A:2,0x8B:2,0x8C:2,0x8D:2,0x8E:2,0x8F:2,0x89:1,
                0x9C:1,0x9D:1,0x9E:1,0x9F:1}

def decode(script, limit=220):
    out, i = [], 0
    while i < len(script) and i < limit:
        b = script[i]
        if b < 0x80:
            c = charof(b)
            out.append(c if c is not None else f'<{b:02X}>')
            i += 1
            continue
        if b in CMD_OPERANDS:
            out.append(f"[{CMD_NAMES.get(b,hex(b))}:{script[i+1:i+1+CMD_OPERANDS[b]].hex()}]")
            i += 1 + CMD_OPERANDS[b]
            continue
        out.append(f"[{CMD_NAMES.get(b,hex(b))}]")
        i += 1
        if b == 0x80:  # END
            break
    return ''.join(out)

ids = [int(x,16) for x in sys.argv[1:]] or list(range(0x21, 0x45))
for pid in ids:
    for bk in (0x13, 0x12):
        data = banks[bk]
        off = 0x0000 + pid*2  # $8000 window = file offset 0 of the 8K bank
        ptr = data[off] | (data[off+1] << 8)
        if ptr == 0 or ptr == 0xFFFF:
            continue
        # CalcMenuDataPtr adds +$20/+$40 to the HIGH byte:
        #   +$20 (bank-table idx 0-2, 9+): cpu addr = ptr + $2000 -> file off = ptr-$6000
        #   +$40 (bank-table idx 3-8):     cpu addr = ptr + $4000 -> file off = ptr-$4000
        for off, add in ((ptr - 0x6000, 0x20), (ptr - 0x4000, 0x40)):
            if 0 <= off < len(data):
                txt = decode(data[off:])
                if txt.strip('[]\n '):
                    print(f'panel ${pid:02X} (bank ${bk:02X} ptr ${ptr:04X}+${add:02X}00): {txt}')

