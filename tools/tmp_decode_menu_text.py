#!/usr/bin/env python3
"""Decode strategy-menu text with the full kana char map.

Char map (verified):
  $04-$31 katakana ア-ン (gojuon), $32-34 ァィゥ, $35-38 ャュョッ
  $39 ゛ / $3A ゜ postfix
  $44-$71 hiragana あ-ん (gojuon), $72-75 ゃゅょっ
  $01 space, $00 terminator, $76-$7F digits 0-9
"""
data = open('rom/prg_combined.bin', 'rb').read()

K = {0x04: 'ア', 0x05: 'イ', 0x06: 'ウ', 0x07: 'エ', 0x08: 'オ',
     0x09: 'カ', 0x0A: 'キ', 0x0B: 'ク', 0x0C: 'ケ', 0x0D: 'コ',
     0x0E: 'サ', 0x0F: 'シ', 0x10: 'ス', 0x11: 'セ', 0x12: 'ソ',
     0x13: 'タ', 0x14: 'チ', 0x15: 'ツ', 0x16: 'テ', 0x17: 'ト',
     0x18: 'ナ', 0x19: 'ニ', 0x1A: 'ヌ', 0x1B: 'ネ', 0x1C: 'ノ',
     0x1D: 'ハ', 0x1E: 'ヒ', 0x1F: 'フ', 0x20: 'ヘ', 0x21: 'ホ',
     0x22: 'マ', 0x23: 'ミ', 0x24: 'ム', 0x25: 'メ', 0x26: 'モ',
     0x27: 'ヤ', 0x28: 'ユ', 0x29: 'ヨ', 0x2A: 'ラ', 0x2B: 'リ',
     0x2C: 'ル', 0x2D: 'レ', 0x2E: 'ロ', 0x2F: 'ワ', 0x30: 'ヲ',
     0x31: 'ン', 0x32: 'ァ', 0x33: 'ィ', 0x34: 'ゥ', 0x35: 'ャ',
     0x36: 'ュ', 0x37: 'ョ', 0x38: 'ッ'}
H = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんゃゅょっ'
HMAP = {0x44 + i: c for i, c in enumerate(H)}
VOICED = {'ツ': 'ヅ', 'ハ': 'バ', 'ヒ': 'ビ', 'フ': 'ブ', 'ヘ': 'ベ', 'ホ': 'ボ',
          'カ': 'ガ', 'キ': 'ギ', 'ク': 'グ', 'ケ': 'ゲ', 'コ': 'ゴ',
          'サ': 'ザ', 'シ': 'ジ', 'ス': 'ズ', 'セ': 'ゼ', 'ソ': 'ゾ',
          'タ': 'ダ', 'チ': 'ヂ', 'テ': 'デ', 'ト': 'ド', 'ウ': 'ヴ',
          'つ': 'づ', 'は': 'ば', 'ひ': 'び', 'ふ': 'ぶ', 'へ': 'べ', 'ほ': 'ぼ',
          'か': 'が', 'き': 'ぎ', 'く': 'ぐ', 'け': 'げ', 'こ': 'ご',
          'さ': 'ざ', 'し': 'じ', 'す': 'ず', 'せ': 'ぜ', 'そ': 'ぞ',
          'た': 'だ', 'ち': 'ぢ', 'て': 'で', 'と': 'ど', 'う': 'ゔ'}
SEMI = {'ハ': 'パ', 'ヒ': 'ピ', 'フ': 'プ', 'ヘ': 'ペ', 'ホ': 'ポ',
        'は': 'ぱ', 'ひ': 'ぴ', 'ふ': 'ぷ', 'へ': 'ぺ', 'ほ': 'ぽ'}


def dec(bs):
    out = []
    for b in bs:
        if b == 0x00:
            break
        if b == 0x01:
            out.append(' ')
        elif b == 0x39:
            if out and out[-1] in VOICED:
                out[-1] = VOICED[out[-1]]
        elif b == 0x3A:
            if out and out[-1] in SEMI:
                out[-1] = SEMI[out[-1]]
        elif 0x76 <= b <= 0x7F:
            out.append(str(b - 0x76))
        elif b in K:
            out.append(K[b])
        elif b in HMAP:
            out.append(HMAP[b])
        elif b in (0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43):
            out.append(f'[{b:02X}]')
        else:
            out.append(f'<{b:02X}>')
    return ''.join(out)


def stream_text(bank_val, addr, maxb=300):
    ofs = (bank_val & 0x1F) * 0x2000 + (addr - 0x8000)
    out = []
    i = 0
    while i < maxb and ofs + i < len(data):
        b = data[ofs + i]
        if b == 0x80:
            out.append('[END]')
            break
        if b == 0x81:
            out.append('/')
            i += 1
        elif b == 0x89:
            out.append(f'[ofs{data[ofs+i+1]:02X}]')
            i += 2
        elif b == 0x86 or 0x8A <= b <= 0x8F:
            out.append(f'[vram{data[ofs+i+1]:02X}{data[ofs+i+2]:02X}]')
            i += 3
        elif 0x82 <= b <= 0x85 or b in (0x87, 0x88):
            out.append(f'[{b:02X}]')
            i += 1
        elif 0x90 <= b <= 0x9F:
            out.append(f'[name{b:02X}]' if b < 0x98 else f'[cmd{b:02X}]')
            i += 2 if b >= 0x9C else 1
        else:
            out.append(dec([b]))
            i += 1
    return ''.join(out)


print('=== bank 13 text region $8200-$8900 ===')
for base in range(0x8200, 0x8900, 0x10):
    ofs = 0x13 * 0x2000 + (base - 0x8000)
    row = data[ofs:ofs + 16]
    print(f'  ${base:04X}: ' + ' '.join(f'{b:02X}' for b in row) + '  | ' + dec(row))

print()
print('=== bank 13 army/town lists ===')
for lo, hi in [(0x8A40, 0x8AE0), (0x8C40, 0x8DC0), (0x8890, 0x88C0)]:
    for base in range(lo, hi, 0x10):
        ofs = 0x13 * 0x2000 + (base - 0x8000)
        row = data[ofs:ofs + 16]
        print(f'  ${base:04X}: ' + ' '.join(f'{b:02X}' for b in row) + '  | ' + dec(row))
    print()

print()
print('=== bank 12 text region $8500-$8800 ===')
for base in range(0x8500, 0x8800, 0x10):
    ofs = 0x12 * 0x2000 + (base - 0x8000)
    row = data[ofs:ofs + 16]
    print(f'  ${base:04X}: ' + ' '.join(f'{b:02X}' for b in row) + '  | ' + dec(row))

HANDLERS = {
    0x00: ('InitialSetup', 0xE8), 0x01: ('DisplaySetup', 0xDC),
    0x02: ('LandReclamation', 0xE1), 0x03: ('DisasterPreventionSetup', 0xC6),
    0x05: ('CastleRepairSetup', 0xC6), 0x06: ('CastleRepair', 0xEA),
    0x07: ('TaxRate', 0xB7), 0x08: ('GoldDistribution', 0xCA),
    0x09: ('RiceDistribution', 0xF1), 0x0A: ('Conscription', 0xF0),
    0x0B: ('HireOfficer', 0xE9), 0x0C: ('TransferOfficer', 0xF8),
    0x0D: ('ExecuteOfficer', 0xF7), 0x0E: ('ExileOfficer', 0xF3),
    0x0F: ('GiveItem', 0xF0), 0x10: ('MoveCapital', 0xD0),
    0x11: ('Intrigue', 0xF5), 0x12: ('Sortie', 0xF8),
    0x13: ('Reconnaissance', 0xE7), 0x14: ('Accounting', 0xFB),
    0x15: ('Exchange', 0xEA), 0x16: ('Trade', 0xF6),
    0x17: ('SearchOfficer', 0xF7), 0x18: ('SearchItem', 0xC5),
    0x19: ('InspectLand', 0xF4), 0x1A: ('PersonalAffairs', 0xC1),
    0x1B: ('StrategyCmdDispatch', 0xFC),
}


def stream_text2(bank_val, addr, maxb=200):
    """Decode treating $A0-$FF and $C8 etc. as cmd+operand."""
    ofs = (bank_val & 0x1F) * 0x2000 + (addr - 0x8000)
    out = []
    i = 0
    while i < maxb and ofs + i < len(data):
        b = data[ofs + i]
        if b == 0x80:
            out.append('[END]')
            break
        if b == 0x81:
            out.append('/')
            i += 1
        elif b == 0x89:
            out.append(f'[ofs{data[ofs+i+1]:02X}]')
            i += 2
        elif b == 0x86 or 0x8A <= b <= 0x8F:
            out.append(f'[v{data[ofs+i+1]:02X}{data[ofs+i+2]:02X}]')
            i += 3
        elif 0x82 <= b <= 0x85 or b in (0x87, 0x88):
            out.append(f'[{b:02X}]')
            i += 1
        elif 0x90 <= b <= 0x97:
            out.append(f'[NAME{b-0x90}]')
            i += 1
        elif 0x98 <= b <= 0x9F:
            out.append(f'[cmd{b:02X}]')
            i += 2 if b >= 0x9C else 1
        elif b >= 0xA0:
            out.append(f'[c{b:02X}{data[ofs+i+1]:02X}]')
            i += 2
        else:
            out.append(dec([b]))
            i += 1
    return ''.join(out)


print()
print('=== handler streams decoded ===')
for hid in sorted(HANDLERS):
    name, pos = HANDLERS[hid]
    tbl = pos * 2 + 0x8000
    print(f'--- ${hid:02X} {name} pos=${pos:02X}')
    for bank_val in (0x32, 0x33):
        o = (bank_val & 0x1F) * 0x2000 + (tbl - 0x8000)
        lo, hi_raw = data[o], data[o + 1]
        for adj in (0x20, 0x40):
            addr = ((hi_raw + adj) & 0xFF) << 8 | lo
            if not (0x8000 <= addr <= 0x9FFF):
                continue
            txt = stream_text2(bank_val, addr)
            print(f'  b{bank_val:X}+{adj:X} ${addr:04X}: {txt}')
