#!/usr/bin/env python3
"""Extract the officer katakana names from PRG bank $30 ($901A).

The game defines 237 officers, but the name table and the SRAM officer array
are both sized for 240 slots, so this dumps all 240 and marks 237-239 blank.

Table layout (verified against GetNameDisplayScale $F308 / CmdDrawName $A32D):

  bank register $30 -> physical PRG bank $10 (256 KB PRG => reg & $1F)
  name address      = index * 10 + $901A
  file offset       = 0x20000 + (0x901A - 0x8000) + index * 10 = 0x2101A + index*10
  entry             = 10 bytes, $00-terminated, zero padded

Index == officer id, i.e. id = (sram_record_addr - $63C0) / 12, so the table
covers exactly the 240 SRAM officer slots $63C0-$6EFF. Index 240/241 hold the
resource labels キン/コメ, which confirms the officer block ends at index 239.

Encoding is the serial gojuon code space documented in tools/charmap_kana.py
($04=ア .. $31=ン, $35-$38 = ャュョッ, $39/$3A = postfix ゛/゜).

Usage:
    python tools/extract_officer_names.py            # write output files
    python tools/extract_officer_names.py --print     # also dump to stdout
"""
import argparse
import csv
import os
import sys
import unicodedata

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from charmap_kana import DAKUTEN, HANDAKUTEN, KATAKANA, decode_name  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRG_COMBINED = os.path.join(ROOT, 'rom', 'prg_combined.bin')

NAME_TABLE_OFFSET = 0x2101A   # file offset of index 0
NAME_TABLE_ADDR = 0x901A      # CPU address in bank $30
ENTRY_SIZE = 10
OFFICER_COUNT = 240           # name-table / SRAM slots ($6F00 - $63C0) / 12
NAMED_OFFICERS = 237          # slots actually filled in; 237-239 are blank
OFFICER_RECORD_BASE = 0x63C0
OFFICER_RECORD_SIZE = 12

# NameScaleTable @ $F35F: leading-space padding, indexed by glyph count
NAME_SCALE_TABLE = [3, 3, 3, 2, 2, 1, 1, 0, 0]

# Hepburn romanisation, applied to the decoded (already voiced) katakana.
_ROMAJI = {
    'ア': 'a', 'イ': 'i', 'ウ': 'u', 'エ': 'e', 'オ': 'o',
    'カ': 'ka', 'キ': 'ki', 'ク': 'ku', 'ケ': 'ke', 'コ': 'ko',
    'ガ': 'ga', 'ギ': 'gi', 'グ': 'gu', 'ゲ': 'ge', 'ゴ': 'go',
    'サ': 'sa', 'シ': 'shi', 'ス': 'su', 'セ': 'se', 'ソ': 'so',
    'ザ': 'za', 'ジ': 'ji', 'ズ': 'zu', 'ゼ': 'ze', 'ゾ': 'zo',
    'タ': 'ta', 'チ': 'chi', 'ツ': 'tsu', 'テ': 'te', 'ト': 'to',
    'ダ': 'da', 'ヂ': 'ji', 'ヅ': 'zu', 'デ': 'de', 'ド': 'do',
    'ナ': 'na', 'ニ': 'ni', 'ヌ': 'nu', 'ネ': 'ne', 'ノ': 'no',
    'ハ': 'ha', 'ヒ': 'hi', 'フ': 'fu', 'ヘ': 'he', 'ホ': 'ho',
    'バ': 'ba', 'ビ': 'bi', 'ブ': 'bu', 'ベ': 'be', 'ボ': 'bo',
    'パ': 'pa', 'ピ': 'pi', 'プ': 'pu', 'ペ': 'pe', 'ポ': 'po',
    'マ': 'ma', 'ミ': 'mi', 'ム': 'mu', 'メ': 'me', 'モ': 'mo',
    'ヤ': 'ya', 'ユ': 'yu', 'ヨ': 'yo',
    'ラ': 'ra', 'リ': 'ri', 'ル': 'ru', 'レ': 're', 'ロ': 'ro',
    'ワ': 'wa', 'ヲ': 'wo', 'ン': 'n', 'ヴ': 'vu',
}
_YOON = {'ャ': 'ya', 'ュ': 'yu', 'ョ': 'yo'}


def romanize(kata):
    """Hepburn romanisation of a decoded katakana name (ASCII, capitalised)."""
    out = []
    i = 0
    while i < len(kata):
        ch = kata[i]
        nxt = kata[i + 1] if i + 1 < len(kata) else ''
        if ch == 'ッ':
            follow = _ROMAJI.get(nxt, '')
            out.append(follow[0] if follow else 't')
            i += 1
            continue
        base = _ROMAJI.get(ch)
        if base is None:
            out.append(ch)
            i += 1
            continue
        if ch == 'ン' and nxt and (_ROMAJI.get(nxt, 'x')[0] in 'aiueo' or nxt in _YOON):
            out.append("n'")                          # Hepburn: カンウ -> Kan'u
            i += 1
            continue
        if nxt in _YOON:
            if base.endswith('i') and len(base) > 1:
                base = base[:-1]                     # ki+ya -> kya
                if base.endswith('sh') or base.endswith('ch') or base == 'j':
                    out.append(base + _YOON[nxt][1:])  # shi+yo -> sho
                else:
                    out.append(base + _YOON[nxt])
            else:
                out.append(base + _YOON[nxt])
            i += 2
            continue
        out.append(base)
        i += 1
    return ''.join(out).capitalize()


def glyph_count(entry):
    """Character count as computed by GetNameDisplayScale (marks excluded)."""
    n = 0
    for b in entry:
        if b == 0:
            break
        if b in (DAKUTEN, HANDAKUTEN):
            continue
        n += 1
    return n


def load_entries(path=PRG_COMBINED, count=OFFICER_COUNT):
    """Yield one dict per officer slot."""
    with open(path, 'rb') as f:
        prg = f.read()
    end = NAME_TABLE_OFFSET + count * ENTRY_SIZE
    if len(prg) < end:
        raise SystemExit(f'{path}: too small ({len(prg)} bytes, need {end})')

    for oid in range(count):
        ofs = NAME_TABLE_OFFSET + oid * ENTRY_SIZE
        entry = prg[ofs:ofs + ENTRY_SIZE]
        raw = entry.split(b'\x00')[0]
        unknown = sorted({b for b in raw
                          if b not in KATAKANA and b not in (DAKUTEN, HANDAKUTEN)})
        kata = decode_name(entry)
        n = glyph_count(entry)
        yield {
            'id': oid,
            'name_addr': NAME_TABLE_ADDR + oid * ENTRY_SIZE,
            'file_offset': ofs,
            'sram_record': OFFICER_RECORD_BASE + oid * OFFICER_RECORD_SIZE,
            'hex': raw.hex().upper(),
            'katakana': kata,
            'hiragana': decode_name(entry, hiragana=True),
            'romaji': romanize(kata),
            'glyphs': n,
            'scale': NAME_SCALE_TABLE[n] if n < len(NAME_SCALE_TABLE) else None,
            'unknown': unknown,
            'blank': not raw,
        }


def _pad(text, width):
    """Left-align accounting for double-width kana cells."""
    cells = sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in text)
    return text + ' ' * max(0, width - cells)


def write_txt(rows, path):
    named = [r for r in rows if not r['blank']]
    with open(path, 'w', encoding='utf-8') as f:
        f.write('Sangokushi 2 - Haou no Tairiku (J): officer katakana names\n')
        f.write(f'Source: rom/prg_combined.bin @ {NAME_TABLE_OFFSET:#07x} '
                f'(PRG bank $30 = physical $10, ${NAME_TABLE_ADDR:04X}), '
                f'{ENTRY_SIZE} bytes/entry, $00-terminated\n')
        f.write(f'Address formula: name = id * {ENTRY_SIZE} + ${NAME_TABLE_ADDR:04X} '
                f'(GetNameDisplayScale $F308); '
                f'SRAM record = id * {OFFICER_RECORD_SIZE} + ${OFFICER_RECORD_BASE:04X}\n')
        f.write(f'{OFFICER_COUNT} slots, {len(named)} named, '
                f'{OFFICER_COUNT - len(named)} blank\n\n')
        f.write(f'{"id":>4} {"addr":>6} {"file":>8} {"sram":>6} '
                f'{"bytes":<16} {"g":>1} {"s":>1} {"katakana":<15} {"romaji"}\n')
        f.write('-' * 84 + '\n')
        for r in rows:
            f.write(f'{r["id"]:>4} ${r["name_addr"]:04X} '
                    f'{r["file_offset"]:#08x} ${r["sram_record"]:04X} '
                    f'{r["hex"]:<16} {r["glyphs"]:>1} '
                    f'{"-" if r["scale"] is None else r["scale"]:>1} '
                    f'{_pad(r["katakana"] or "(blank)", 15)} {r["romaji"]}\n')


def write_csv(rows, path):
    cols = ['id', 'name_addr', 'file_offset', 'sram_record', 'hex',
            'katakana', 'hiragana', 'romaji', 'glyphs', 'scale', 'blank']
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction='ignore')
        w.writeheader()
        for r in rows:
            row = dict(r)
            row['name_addr'] = f'${r["name_addr"]:04X}'
            row['file_offset'] = f'{r["file_offset"]:#07x}'
            row['sram_record'] = f'${r["sram_record"]:04X}'
            row['blank'] = int(r['blank'])
            w.writerow(row)


def write_inc(rows, path):
    """ca65 include: OFFICER_<ROMAJI> = <id> equates for use in disassembly."""
    seen = {}
    with open(path, 'w', encoding='utf-8') as f:
        f.write('; Officer id equates, generated by tools/extract_officer_names.py\n')
        f.write(f'; Name table: id * {ENTRY_SIZE} + ${NAME_TABLE_ADDR:04X} in PRG bank $30\n')
        f.write(f'; SRAM record: id * {OFFICER_RECORD_SIZE} + ${OFFICER_RECORD_BASE:04X}\n\n')
        named = sum(1 for r in rows if not r['blank'])
        f.write(f'OFFICER_COUNT       = {named}   ; officers actually defined in ROM\n')
        f.write(f'OFFICER_SLOT_COUNT  = {OFFICER_COUNT}   ; name-table / SRAM array capacity\n')
        f.write(f'OFFICER_NAME_BASE   = ${NAME_TABLE_ADDR:04X}\n')
        f.write(f'OFFICER_NAME_STRIDE = {ENTRY_SIZE}\n\n')
        for r in rows:
            if r['blank']:
                f.write(f'; OFFICER_{r["id"]:03d} unused (blank name slot)\n')
                continue
            sym = 'OFFICER_' + ''.join(
                c for c in r['romaji'].upper() if c.isalnum() or c == '_')
            seen[sym] = seen.get(sym, 0) + 1
            if seen[sym] > 1:
                sym = f'{sym}_{seen[sym]}'
            f.write(f'{sym:<28} = {r["id"]:>3}   ; {r["katakana"]}\n')


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--rom', default=PRG_COMBINED, help='combined PRG binary')
    ap.add_argument('--count', type=int, default=OFFICER_COUNT, help='slots to read')
    ap.add_argument('--print', dest='do_print', action='store_true',
                    help='dump the table to stdout as well')
    args = ap.parse_args()

    rows = list(load_entries(args.rom, args.count))

    bad = [r for r in rows if r['unknown']]
    if bad:
        print('WARNING: unmapped byte codes found:', file=sys.stderr)
        for r in bad:
            codes = ' '.join(f'${b:02X}' for b in r['unknown'])
            print(f'  id {r["id"]}: {codes} ({r["hex"]})', file=sys.stderr)

    out_dir = os.path.join(ROOT, 'docs')
    os.makedirs(out_dir, exist_ok=True)
    txt = os.path.join(out_dir, 'officer_names.txt')
    csv_path = os.path.join(out_dir, 'officer_names.csv')
    inc = os.path.join(ROOT, 'include', 'officer_ids.inc')
    write_txt(rows, txt)
    write_csv(rows, csv_path)
    write_inc(rows, inc)

    named = sum(1 for r in rows if not r['blank'])
    print(f'{len(rows)} officer slots read ({named} named, '
          f'{len(rows) - named} blank), no unmapped codes'
          if not bad else f'{len(rows)} officer slots read ({named} named)')
    for p in (txt, csv_path, inc):
        print(f'  wrote {os.path.relpath(p, ROOT)}')

    if args.do_print:
        for r in rows:
            print(f'{r["id"]:>3} ${r["name_addr"]:04X} {r["hex"]:<16} '
                  f'{_pad(r["katakana"] or "(blank)", 15)} {r["romaji"]}')


if __name__ == '__main__':
    main()
