#!/usr/bin/env python3
"""Decode every menu stream in banks $12/$13 to text; print a review report.

Uses the generators' build_plan for the authoritative stream spans and the
shared VM walker in tools/menu_text_map.py for the decode.
Output: build/stream_text_report.txt
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_data_bank_12_asm as g12
import gen_data_bank_13_asm as g13
import menu_text_map as mtm


def report_bank(mod, title, out):
    data = mod.read_bank()
    streams = mod.build_plan(data)[1]
    out.append('=' * 78)
    out.append(title)
    out.append('=' * 78)
    for tgt in sorted(streams):
        st = streams[tgt]
        if st['alias']:
            continue
        tokens, end, lines = mtm.walk_stream(data, tgt, queue=st['queue'],
                                             push_macro=st['push_macro'])
        assert end == st['end'], 'walk mismatch at %04X' % (0x8000 + tgt)
        ids = ' '.join('%02X' % p for p in st['ids'])
        out.append('')
        out.append('--- pos %s  %s-%s (%d B) ---' % (
            ids, mod.hexw(mod.cpu_ofs(tgt)), mod.hexw(mod.cpu_ofs(end) - 1),
            end - tgt))
        for line in lines:
            out.append('    | ' + line)
    out.append('')


def main():
    out = []
    report_bank(g12, 'BANK $12 (data_12.asm)', out)
    report_bank(g13, 'BANK $13 (data_13.asm)', out)
    os.makedirs('build', exist_ok=True)
    with open('build/stream_text_report.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(out))
    print('wrote build/stream_text_report.txt (%d lines)' % len(out))


if __name__ == '__main__':
    main()
