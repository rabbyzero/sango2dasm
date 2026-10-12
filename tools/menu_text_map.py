#!/usr/bin/env python3
"""Text charmap for the MenuUpdate display-list streams (data banks $12/$13).

Two code spaces share the stream literal range, proven by decode anchors
(2026-10-10; see code/font_analysis.md and output/charmap_* renders):

  low tiles  $04-$38  katakana, serial gojuon from ア (the officer-name code
                      space: リュウビ = 2B 36 06 1E at $901A decodes through it)
  high tiles $44-$75  hiragana, serial gojuon from あ (しますか = $4F $62 $50 $49,
                      まちましょう = ... $62 $4F $74 $46, コマ = $0D $22 low)

  $01       space (ClearTileBuffers fill value)
  $39/$3A   dakuten/handakuten postfix marks - StoreTileByte routes them to the
            row-2 overlay buffer ($034B,X) when indirect mode is off
  $74-$75   ょ/っ in the hiragana block (glyph row at $76+ on the number font
            page is a different display mode - see CmdDrawNumber note below)

Dynamic commands contribute no literal text: $90-$97/$9F draw officer names
from bank $10 $901A via RAM $042C, $9C draws 6-char province names from $9A1A,
$9D draws fixed-7 names, $98-$9B/$9E draw BCD numbers ('0' = tile $76 through
StoreTileByte, digit glyphs live on the number-mode font page).
"""

KATAKANA = {0x04 + i: ch for i, ch in enumerate(
    'アイウエオカキクケコサシスセソタチツテトナニヌネノ'
    'ハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥャュョッ')}
# Menu-stream extensions past the serial katakana block, all proven by decode:
#   ダメージ = $13 $39 $25 $32 $0F $39, データ = $16 $39 $32 $13 (32 = ー)
#   まて! = $53 $45 $33, けておくぞ! = ... $52 $39 $33 (33 = !)
#   コーディネーター = $0D $32 $16 $39 $34 $1B $32 $13 $32 (34 = ィ, 1 hit)
KATAKANA.update({0x32: 'ー', 0x33: '!', 0x34: 'ィ'})
# $32-$34 sit where officer names guess ァィゥ; officer names never use them.
HIRAGANA = {0x44 + i: ch for i, ch in enumerate(
    'あいうえおかきくけこさしすせそたちつてとなにぬねの'
    'はひふへほまみむめもやゆよらりるれろわをんゃゅょっ')}
DIGITS = {0x76 + n: str(n) for n in range(10)}
TEN_HUNDRED = {0x7E: '10', 0x7F: '100'}

DAKUTEN = 0x39
HANDAKUTEN = 0x3A
SPACE = 0x01

_VOICED_KATA = str.maketrans(
    'カキクケコサシスセソタチツテトハヒフヘホウ',
    'ガギグゲゴザジズゼゾダヂヅデドバビブベボヴ')
_SEMI_KATA = str.maketrans('ハヒフヘホ', 'パピプペポ')
_VOICED_HIRA = str.maketrans(
    'かきくけこさしすせそたちつてとはひふへほう',
    'がぎぐげござじずぜぞだぢづでどばびぶべぼゔ')
_SEMI_HIRA = str.maketrans('はひふへほ', 'ぱぴぷぺぽ')

_COMMAND_TEXT = {
    'name': '〈武将名〉', 'name_data': '〈省名〉', 'name7': '〈7字名〉',
    'name_param': '〈武将名〉', 'num': '⟨数値⟩', 'fmtnum': '⟨数値⟩',
}


def glyph_char(tile):
    """Single tile -> character, or None when the tile is not text."""
    if tile in HIRAGANA:
        return HIRAGANA[tile]
    if tile in KATAKANA:
        return KATAKANA[tile]
    if tile in TEN_HUNDRED:
        return TEN_HUNDRED[tile]
    if tile in DIGITS:
        return DIGITS[tile]
    return None


def decode_tiles(tiles):
    """Tile-id list (marks excluded) -> Japanese string with dakuten applied.

    Non-text tiles render as [XX]; marks postfix the previous character."""
    out = []
    for t in tiles:
        if t == SPACE:
            out.append(' ')
            continue
        ch = glyph_char(t)
        if ch is None:
            out.append('[%02X]' % t)
            continue
        out.append(ch)
    return ''.join(out)


def apply_marks(text, mark_stream):
    """Interleave $39/$3A marks (same order as their tiles) into decoded text."""
    if not mark_stream:
        return text
    out = []
    for ch in text:
        out.append(ch)
        if mark_stream and mark_stream[0] == 'mark':
            kind = mark_stream.pop(0)[1]
            if kind == DAKUTEN:
                ch2 = out[-1]
                out[-1] = ch2.translate(_VOICED_KATA).translate(_VOICED_HIRA) \
                    if ch2 != (ch2.translate(_VOICED_KATA).translate(_VOICED_HIRA)) else ch2 + '゛'
            else:
                ch2 = out[-1]
                out[-1] = ch2.translate(_SEMI_KATA).translate(_SEMI_HIRA) \
                    if ch2 != (ch2.translate(_SEMI_KATA).translate(_SEMI_HIRA)) else ch2 + '゜'
    return ''.join(out)


def decode_tokens(tokens, tile_base_offset=0):
    """walk_stream token list -> display string for the stream's static text.

    Tokens are (nbytes, tag) pairs from gen_data_bank_12_asm.walk_stream.
    Literal bytes pass through tile_base_offset exactly as StoreTileByte does;
    only offsets of $00 leave the code spaces intact, so a nonzero offset
    marks the span as graphics and it renders as [..] placeholders."""
    chars = []
    pending_marks = []   # (position_in_chars, kind)
    for n, tag in tokens:
        parts = tag.split()
        key = parts[0]
        if key == 'tile':
            tile = int(parts[1], 16)
            eff = (tile + tile_base_offset) & 0xFF
            ch = glyph_char(eff) if tile_base_offset == 0 else None
            if tile == SPACE and tile_base_offset == 0:
                ch = ' '
            chars.append(ch if ch is not None else '[%02X]' % eff)
        elif key == 'mark':
            pending_marks.append((len(chars) - 1, int(parts[1], 16)))
        elif key in _COMMAND_TEXT:
            chars.append(_COMMAND_TEXT[key])
        elif key in ('name_data', 'name7', 'name_param', 'fmtnum'):
            chars.append('%s%s⟩' % (_COMMAND_TEXT[key][:-1], parts[1]))
        elif key == 'num':
            chars.append(_COMMAND_TEXT[key])
        # row/push/pop/vram/ovl/ind/tile_ofs/end: layout, not text
    text = ''.join(chars)
    for pos, kind in reversed(pending_marks):
        if 0 <= pos < len(text):
            ch = text[pos]
            voiced = ch.translate(_VOICED_KATA).translate(_VOICED_HIRA)
            semi = ch.translate(_SEMI_KATA).translate(_SEMI_HIRA)
            if kind == DAKUTEN:
                new = voiced if voiced != ch else ch + '゛'
            else:
                new = semi if semi != ch else ch + '゜'
            text = text[:pos] + new + text[pos + 1:]
    return text


# --------------------------------------------------------------------------
# Stream VM walker shared by the data-bank generators and the report tool.
# --------------------------------------------------------------------------

_VOICED_K = str.maketrans(
    'カキクケコサシスセソタチツテトハヒフヘホウ',
    'ガギグゲゴザジズゼゾダヂヅデドバビブベボヴ')
_VOICED_H = str.maketrans(
    'かきくけこさしすせそたちつてとはひふへほう',
    'がぎぐげござじずぜぞだぢづでどばびぶべぼゔ')
_SEMI_K = str.maketrans('ハヒフヘホ', 'パピプペポ')
_SEMI_H = str.maketrans('はひふへほ', 'ぱぴぷぺぽ')


def _apply_mark(chars, kind):
    if not chars:
        return '゛' if kind == DAKUTEN else '゜'
    ch = chars[-1]
    new = ch.translate(_VOICED_K).translate(_VOICED_H) if kind == DAKUTEN \
        else ch.translate(_SEMI_K).translate(_SEMI_H)
    if new == ch:
        new = ch + ('゛' if kind == DAKUTEN else '゜')
    chars[-1] = new
    return new


def walk_stream(data, ofs, queue=False, push_macro=False):
    """Walk one MenuUpdate display list from file offset `ofs` (bank-relative).

    Returns (tokens, end, lines):
      tokens  list of (nbytes, tag, char) in stream order; tag is one of
              'tile XX'/'mark 39'/'row'/'push XX'/'pop'/'pop (returns to
              pusher)'/'ovl on'/'ovl off'/'vram XXXX'/'ind on'/'ind off'/
              'tile_ofs XX'/'nameN'/'numN'/'name_data XX'/'name7 XX'/
              'fmtnum XX'/'name_param XX'/'end'; char is the decoded text
              character for the token, or None for layout/graphics.
      end     first offset past the stream ($80 end / pop-return boundary)
      lines   decoded static text, one string per rendered row (rows break on
              $81/$86 layout commands); marks are applied inline.

    queue=True consumes the leading 2-byte PPU address stored [lo][hi]
    (UI-queue init path); push_macro=True stops at the $83 pop that returns
    to the pusher. Literal bytes pass through tile_base_offset exactly as
    StoreTileByte does."""
    tokens = []
    chars = []
    lines = []
    tile_ofs = 0
    i = ofs
    if queue:
        lo, hi = data[i], data[i + 1]
        tokens.append((2, 'vram %04X' % (hi << 8 | lo), None))
        i += 2
    while i < 0x2000:
        b = data[i]
        i += 1
        if b == 0x80:
            tokens.append((1, 'end', None))
            break
        if b == 0x83 and push_macro:
            tokens.append((1, 'pop (returns to pusher)', None))
            break
        if b < 0x80 or b >= 0xC0:
            if b in (0x39, 0x3A) and tile_ofs == 0:
                kind = _apply_mark(chars, b)
                tokens.append((1, 'mark %02X' % b, kind))
                continue
            eff = (b + tile_ofs) & 0xFF
            if b == SPACE and tile_ofs == 0:
                ch = ' '
            else:
                ch = glyph_char(eff) if tile_ofs == 0 else None
            if ch is None:
                ch = '[%02X]' % eff
                tokens.append((1, 'tile %02X' % b, ch))
            else:
                tokens.append((1, 'tile %02X' % b, ch))
                chars.append(ch)
            continue
        if b == 0x81:
            tokens.append((1, 'row', None))
            lines.append(''.join(chars))
            chars = []
        elif b == 0x82:
            tokens.append((2, 'push %02X' % data[i], None))
            i += 1
        elif b == 0x83:
            tokens.append((1, 'pop', None))
        elif b == 0x84:
            tokens.append((1, 'ovl on', None))
        elif b == 0x85:
            tokens.append((1, 'ovl off', None))
        elif b == 0x86 or 0x8A <= b <= 0x8F:
            tokens.append((3, 'vram %04X' % (data[i] << 8 | data[i + 1]), None))
            lines.append(''.join(chars))
            chars = []
            i += 2
        elif b == 0x87:
            tokens.append((1, 'ind on', None))
        elif b == 0x88:
            tokens.append((1, 'ind off', None))
        elif b == 0x89:
            tile_ofs = data[i]
            tokens.append((2, 'tile_ofs %02X' % data[i], None))
            i += 1
        elif 0x90 <= b <= 0x97:
            tokens.append((1, 'name%d' % (b - 0x90), '〈名〉'))
            chars.append('〈名〉')
        elif 0x98 <= b <= 0x9B:
            tokens.append((1, 'num%d' % (b - 0x98), '⟨数⟩'))
            chars.append('⟨数⟩')
        elif b == 0x9C:
            tokens.append((2, 'name_data %02X' % data[i], '〈省%02X〉' % data[i]))
            chars.append('〈省%02X〉' % data[i])
            i += 1
        elif b == 0x9D:
            tokens.append((2, 'name7 %02X' % data[i], '〈名7 %02X〉' % data[i]))
            chars.append('〈名7 %02X〉' % data[i])
            i += 1
        elif b == 0x9E:
            tokens.append((2, 'fmtnum %02X' % data[i], '⟨数%02X⟩' % data[i]))
            chars.append('⟨数%02X⟩' % data[i])
            i += 1
        elif b == 0x9F:
            tokens.append((2, 'name_param %02X' % data[i], '〈名p %02X〉' % data[i]))
            chars.append('〈名p %02X〉' % data[i])
            i += 1
        else:
            raise AssertionError('unhandled byte %02X at %04X' % (b, 0x8000 + i - 1))
    lines.append(''.join(chars))
    return tokens, i, [ln for ln in lines if ln.strip()]
