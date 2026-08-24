#!/usr/bin/env python3
"""Kana/digit char map for Sangokushi 2 (Namco) name-string encoding.

Derived from officer name strings at bank $30 $901A (10 bytes/entry,
addressed like GetNameDisplayScale: id*10 + $901A; officer id =
(sram_addr - $63C0) / 12 per GetOfficerRecordAddr).

The code space is SERIAL in gojuon order, verified against known readings:
  id 222 Liubei      2B 36 06 1E 39        = リュウヒ゛  = リュウビ
  id  38 Guanyu      09 31 06              = カンウ
  id 153 Zhangfei    14 37 06 1E           = チョウヒ
  id 109 Zhugeliang  0F 37 09 15 2B 37 06  = ショカツリョウ
  id 121 (Xue Zong)  11 38 12 06           = セッソウ  (pins $38 = ッ)
  id  26 (Yue Jin)   09 39 0B 0F 31        = カ゛クシン = ガクシン

$39/$3A are POSTFIX combining marks (dakuten/handakuten); GetNameDisplayScale
and DisplayScaledName treat them as width-only bytes routed to an overlay.
"""

# code -> katakana (serial gojuon from $04; small kana + sokuon after ン)
KATAKANA = {
    0x04: 'ア', 0x05: 'イ', 0x06: 'ウ', 0x07: 'エ', 0x08: 'オ',
    0x09: 'カ', 0x0A: 'キ', 0x0B: 'ク', 0x0C: 'ケ', 0x0D: 'コ',
    0x0E: 'サ', 0x0F: 'シ', 0x10: 'ス', 0x11: 'セ', 0x12: 'ソ',
    0x13: 'タ', 0x14: 'チ', 0x15: 'ツ', 0x16: 'テ', 0x17: 'ト',
    0x18: 'ナ', 0x19: 'ニ', 0x1A: 'ヌ', 0x1B: 'ネ', 0x1C: 'ノ',
    0x1D: 'ハ', 0x1E: 'ヒ', 0x1F: 'フ', 0x20: 'ヘ', 0x21: 'ホ',
    0x22: 'マ', 0x23: 'ミ', 0x24: 'ム', 0x25: 'メ', 0x26: 'モ',
    0x27: 'ヤ', 0x28: 'ユ', 0x29: 'ヨ',
    0x2A: 'ラ', 0x2B: 'リ', 0x2C: 'ル', 0x2D: 'レ', 0x2E: 'ロ',
    0x2F: 'ワ', 0x30: 'ヲ', 0x31: 'ン',
    0x32: 'ァ', 0x33: 'ィ', 0x34: 'ゥ',          # serial guess (unused in names)
    0x35: 'ャ', 0x36: 'ュ', 0x37: 'ョ', 0x38: 'ッ',
}

# postfix combining marks (apply to previous character)
DAKUTEN = 0x39      # ゛  voiced:     カ゛=ガ ヒ゛=ビ ヘ゛+? etc.
HANDAKUTEN = 0x3A   # ゜  semi-voiced: ヘ゜=ペ

# Menu-screen hiragana block: serial gojuon at $44 (verified against the
# strategy command lists in PRG bank $33: ジョウホウあつめ=0F 39 37 06 21 06 +
# 44 55 65, クニづくり=0B 19 55 39 4B 6B, しますか/ましょう suffixes, を=$70,
# の=$5C). Same gojuon order as KATAKANA; ゛/゜ postfix applies here too
# (づ = 55 39, ぶ = 1F 39 ...).
HIRAGANA_MENU = {0x44 + i: c for i, c in enumerate(
    'あいうえおかきくけこさしすせそたちつてとなにぬねの'
    'はひふへほまみむめもやゆよらりるれろわをんゃゅょっ')}

TERMINATOR = 0x00
SPACE_TILE = 0x01   # tile-level space used by name pad loops

# hiragana reading mirror (same codes, for transliteration of decoded text)
_K2H = str.maketrans(
    'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥャュョッ',
    'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅゃゅょっ')
HIRAGANA = {c: k.translate(_K2H) for c, k in KATAKANA.items()}

# Digits: not present in the name code space; the game draws numbers at the
# tile level with tile = nibble + $76 (CmdDrawNumber/CmdDrawFormattedNumber,
# digits verified on strategy font page $78 tiles $76-$7F).
DIGIT_TILE_BASE = 0x76


def officer_id(sram_addr):
    """Officer index from SRAM record address (12-byte records at $63C0)."""
    return (sram_addr - 0x63C0) // 12


def name_entry_offset(officer_id_):
    """File offset in prg_combined.bin of the 10-byte name string
    (bank $30 $901A + id*10)."""
    return 0x20000 + 0x101A + officer_id_ * 10


def decode_name(bytes_, hiragana=False):
    """Decode a $00-terminated name byte string; applies ゛/゜ postfix."""
    table = HIRAGANA if hiragana else KATAKANA
    out = []
    for b in bytes_:
        if b == TERMINATOR:
            break
        if b == DAKUTEN:
            if out:
                out[-1] = _voiced(out[-1])
            continue
        if b == HANDAKUTEN:
            if out:
                out[-1] = _semi_voiced(out[-1])
            continue
        out.append(table.get(b, f'[{b:02X}]'))
    return ''.join(out)


def _voiced(ch):
    rows = 'カキクケコサシスセソタチツテトハヒフヘホウ'
    voiced = 'ガギグゲゴザジズゼゾダヂヅデドバビブベボヴ'
    hrows = 'かきくけこさしすせそたちつてとはひふへほう'
    hvoiced = 'がぎぐげござじずぜぞだぢづでどばびぶべぼゔ'
    if ch in rows:
        return voiced[rows.index(ch)]
    if ch in hrows:
        return hvoiced[hrows.index(ch)]
    return ch + '゛'


def _semi_voiced(ch):
    rows = 'ハヒフヘホ'
    semi = 'パピプペポ'
    hrows = 'はひふへほ'
    hsemi = 'ぱぴぷぺぽ'
    if ch in rows:
        return semi[rows.index(ch)]
    if ch in hrows:
        return hsemi[hrows.index(ch)]
    return ch + '゜'


if __name__ == '__main__':
    data = open('rom/prg_combined.bin', 'rb').read()
    anchors = {'Liubei': 0x6E28, 'Guanyu': 0x6588,
               'Zhangfei': 0x6AEC, 'Zhugeliang': 0x68DC}
    for nm, addr in anchors.items():
        oid = officer_id(addr)
        e = data[name_entry_offset(oid):name_entry_offset(oid) + 10]
        print(f"{nm:12s} id={oid:3d}  {e.hex()}  "
              f"kata={decode_name(e)}  hira={decode_name(e, True)}")
