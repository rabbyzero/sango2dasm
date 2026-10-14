#!/usr/bin/env python3
"""Verify asm/banks/data_06_placement_and_scroll.asm reproduces rom/prg/prg_06.bin byte-for-byte.

Bank $06 (war-scene unit placement geometry + 命令書 OrderScroll graphics) is
rendered by tools/gen_data_bank_06_asm.py. This harness assembles the bank on
its own (its own linker config, $8000-$9FFF window) and compares the result with
the stock ROM. Any difference is reported in decoded terms - region, label,
scene, side type and field - so an edit produces a readable diff.

Three checks, all of which must pass:
  1. ca65 + ld65 succeed and the assembled bank is 8KB.
  2. Every byte equals rom/prg/prg_06.bin.
  3. The file on disk still equals what the generator renders (a hand edit to a
     generated region is a drift failure), and the geometry the comments claim
     (record counts vs the bank-$10/$11 side-type selectors, blob chains, the
     $80 terminators) re-derives from the ROM.

Modes:
    python3 tools/verify_data_bank_06.py              # all three checks
    python3 tools/verify_data_bank_06.py --dump       # print the decoded pools
"""
import argparse
import difflib
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_data_bank_06_asm as gen          # noqa: E402

ROOT = gen.ROOT
CC65 = '/home/zero/.local/bin/ca65'
LD65 = '/home/zero/.local/bin/ld65'
BUILD = os.path.join(ROOT, 'build')

# Region boundaries used only to describe a differing byte in human terms.
REGIONS = [
    (0x8000, 0x8C52, 'attack-side unit placement pools (base $8000 table + records)'),
    (0x8C52, 0x932E, 'defense-side unit placement pools (base $8C52 table + records)'),
    (0x932E, 0x94D6, 'attack-side city bounds rectangles (base $932E table + records)'),
    (0x94D6, 0x95E6, 'defense-side city bounds rectangles (base $94D6 table + records)'),
    (0x95E6, 0x9A7E, 'OrderScroll panel tile blocks'),
    (0x9A7E, 0x9E75, 'OrderScroll sprite blob tables + blobs'),
    (0x9E75, 0x9FBB, 'OrderScroll text-phase blob table + blobs'),
    (0x9FBB, 0xA000, 'unused $FF filler'),
]


def linker_cfg():
    return ('MEMORY {\n'
            '    BANK06: start = $8000, size = $2000, type = ro, fill = yes,\n'
            '            fillval = $FF, file = "build/_d06.bin";\n'
            '}\n'
            'SEGMENTS {\n'
            '    CODE_BANK06: load = BANK06, type = ro;\n'
            '}\n')


def assemble():
    """ca65 + ld65 the single bank; returns the built bytes or None."""
    os.makedirs(BUILD, exist_ok=True)
    src = os.path.join(ROOT, 'asm', 'banks', 'data_06_placement_and_scroll.asm')
    obj = os.path.join(BUILD, '_d06.o')
    cfg = os.path.join(BUILD, '_d06.cfg')
    out = os.path.join(BUILD, '_d06.bin')
    with open(cfg, 'w', encoding='utf-8') as f:
        f.write(linker_cfg())
    r = subprocess.run([CC65, '-I', os.path.join(ROOT, 'include'),
                        '-I', os.path.join(ROOT, 'asm', 'banks'),
                        src, '-o', obj], capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('CA65 FAILED:\n%s' % r.stderr[:3000], file=sys.stderr)
        return None
    if r.stderr.strip():
        print('ca65 notes: %s' % r.stderr.strip()[:600])
    r = subprocess.run([LD65, '-C', cfg, obj, '-o', out],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('LD65 FAILED:\n%s' % r.stderr[:3000], file=sys.stderr)
        return None
    with open(out, 'rb') as f:
        return f.read()


def describe(addr):
    for lo, hi, name in REGIONS:
        if lo <= addr < hi:
            return '$%04X  %s' % (addr, name)
    return '$%04X  (outside the known map)' % addr


def nearest_label(text, addr):
    """The label owning a differing byte, from the file's address stream."""
    owner = None
    for raw in text.splitlines():
        if raw.startswith(('Tactical', 'OrderScroll', 'Bank06', '  .')):
            if not raw.startswith('  .'):
                owner = raw.split(':')[0]
        if ('$%04X' % addr) in raw:
            return (owner or '?'), raw.strip()[:90]
    return (owner or '?'), '(line not found)'


def check_geometry(data):
    """Re-derive the structural claims the source makes; return problem lines."""
    problems = []
    for side in ('Attack', 'Defense'):
        try:
            groups = gen.scene_groups(data, gen.POOL_CPU[side], gen.POOL_STRIDE[side],
                                      gen.POOL_END[side], side)
            bounds = gen.scene_groups(data, gen.BOUNDS_CPU[side], gen.BOUNDS_STRIDE,
                                      gen.BOUNDS_END[side], side)
            gen.check_side_types(groups, side)
            if [len(g) for g in groups] != [len(g) for g in bounds]:
                problems.append('%s: pool/bounds counts diverge per scene' % side)
        except SystemExit as exc:
            problems.append(str(exc))
    # Blob chains: each table's blobs must run out to the next table, exactly.
    end = gen.PANEL_CPU + gen.PANEL_COUNT * gen.PANEL_SIZE
    for spec in gen.BLOB_TABLES:
        if spec['cpu'] != end:
            problems.append('blob table $%04X expected at $%04X' % (spec['cpu'], end))
            break
        prev = 0
        for i in range(spec['count']):
            p = gen.cpu16(data, spec['cpu'] + 2 * i)
            # Blobs follow one another in table order; a group is 4n+1 bytes,
            # so the pointers alternate in parity by construction.
            if not (spec['cpu'] + 2 * spec['count'] <= p < 0xA000):
                problems.append('%s index %d -> blob $%04X outside the bank/past its table'
                                % (spec['name'], i + 1, p))
                break
            if i and p <= prev:
                problems.append('%s index %d -> blob $%04X not past the previous $%04X'
                                % (spec['name'], i + 1, p, prev))
            _recs, end = gen.decode_blob(data, p)
            prev = p
            end += 1
    if end != gen.FF_CPU:
        problems.append('last blob ends $%04X, expected the $FF filler at $%04X'
                        % (end, gen.FF_CPU))
    filler = data[gen.FF_CPU - gen.WINDOW_CPU:]
    if any(b != 0xFF for b in filler):
        problems.append('$%04X-$9FFF is not pure $FF filler' % gen.FF_CPU)
    panels = data[gen.PANEL_CPU - gen.WINDOW_CPU:
                  gen.PANEL_CPU + gen.PANEL_COUNT * gen.PANEL_SIZE - gen.WINDOW_CPU]
    if len(panels) != gen.PANEL_COUNT * gen.PANEL_SIZE:
        problems.append('panel blocks do not span %d B' % (gen.PANEL_COUNT * gen.PANEL_SIZE))
    return problems


def dump(data):
    print('\n  attack-side pools (scene, type -> anchor, unit tiles):')
    groups = gen.scene_groups(data, gen.POOL_CPU['Attack'], gen.POOL_STRIDE['Attack'],
                              gen.POOL_END['Attack'], 'attack')
    for scene, recs in enumerate(groups):
        for k, addr in enumerate(recs):
            bs = gen.take(data, addr, gen.POOL_STRIDE['Attack'])
            print('    $%02X/%d  anchor (%2d,%2d)  %s'
                  % (scene, k, bs[0], bs[1],
                     ' '.join('(%d,%d)' % (bs[i], bs[i + 1]) for i in range(2, 34, 2))))


def check_address_stream(text, stock):
    """Prove every emitted line's `; $ADDR: bytes` annotation against the ROM.

    The byte-compare alone cannot catch a wrong comment: ca65 places bytes
    sequentially whatever the note says. So walk the file's own address stream,
    recompute the length from the directive (.byte -> operand count, .word -> 2),
    and require (a) contiguity with the previous line, (b) the quoted hex bytes
    to equal rom/prg/prg_06.bin at that address, and (c) full 8KB coverage.
    """
    problems = []
    expect = gen.WINDOW_CPU
    covered = 0
    directive = re.compile(r'^\s*\.(byte|word)\s+(.*)$')
    annot = re.compile(r';\s*\$([0-9A-Fa-f]{4}):\s+((?:[0-9A-Fa-f]{2}\s*)+)')
    for lineno, raw in enumerate(text.splitlines(), 1):
        code = raw.split(';', 1)[0]
        m = directive.match(code)
        if not m:
            continue
        n = 2 if m.group(1) == 'word' else len(
            [t for t in re.split(r',\s*', m.group(2)) if t.strip()])
        a = annot.search(raw)
        if not a:
            problems.append('line %d: emitting .%s line has no `; $ADDR: bytes` note'
                            % (lineno, m.group(1)))
            continue
        addr = int(a.group(1), 16)
        quoted = [int(t, 16) for t in a.group(2).split()]
        if addr != expect:
            problems.append('line %d: address gap/overlap - stream at $%04X, line says'
                            ' $%04X' % (lineno, expect, addr))
        if len(quoted) != n:
            problems.append('line %d: .%s emits %d byte(s) but the note lists %d'
                            % (lineno, m.group(1), n, len(quoted)))
        if quoted and quoted != list(stock[addr - gen.WINDOW_CPU:
                                           addr - gen.WINDOW_CPU + len(quoted)]):
            problems.append('line %d: note bytes $%s != ROM at $%04X'
                            % (lineno, ' '.join('%02X' % b for b in quoted), addr))
        expect = addr + n
        covered += n
    if expect != 0xA000:
        problems.append('address stream ends at $%04X, expected $A000' % expect)
    if covered != gen.BANK_SIZE:
        problems.append('annotations cover %d B, expected %d' % (covered, gen.BANK_SIZE))
    return problems, expect, covered


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--dump', action='store_true',
                    help='print the assembled placement-pool decode')
    args = ap.parse_args()

    src_path = os.path.join(ROOT, 'asm', 'banks', 'data_06_placement_and_scroll.asm')
    with open(src_path, encoding='utf-8') as f:
        text = f.read()
    stock = gen.read(gen.ROM_BANK)
    built = assemble()
    if built is None:
        return 1
    rc = 0
    print('bank 06 (asm/banks/data_06_placement_and_scroll.asm): %d bytes assembled' % len(built))
    if len(built) != len(stock):
        print('  FAIL: length %d, expected %d' % (len(built), len(stock)))
        return 1
    diffs = [i for i, (a, b) in enumerate(zip(built, stock)) if a != b]
    if not diffs:
        print('  byte-exact vs rom/prg/prg_06.bin (%d/%d bytes compared, 0 mismatches)'
              % (len(built), len(stock)))
    else:
        print('  %d byte(s) differ from the stock ROM:' % len(diffs))
        rc = 1
        for i in diffs[:40]:
            addr = gen.WINDOW_CPU + i
            owner, src_line = nearest_label(text, addr)
            print('    %s: $%02X -> $%02X   [%s] %s'
                  % (describe(addr), stock[i], built[i], owner, src_line))
        if len(diffs) > 40:
            print('     ... %d more' % (len(diffs) - 40))

    for problem in check_geometry(stock):
        print('  GEOMETRY: %s' % problem)
        rc = 1
    stream_problems, end, covered = check_address_stream(text, stock)
    for problem in stream_problems:
        print('  ADDRESS NOTE: %s' % problem)
        rc = 1
    if not stream_problems:
        print('  every line note matches the ROM (%d B annotated, stream $8000->$%04X)'
              % (covered, end))
    if rc == 0:
        print('  geometry re-derives from the ROM (pools tile, selectors match, '
              'blob chains closed)')

    rendered = gen.render(stock)
    if rendered != text:
        print('  DRIFT: data_06_placement_and_scroll.asm is not what the generator renders; run '
              'tools/gen_data_bank_06_asm.py --write')
        for d in list(difflib.unified_diff(rendered.splitlines(), text.splitlines(),
                                           'generated', 'on-disk', lineterm=''))[:40]:
            print('    ' + d)
        rc = 1
    else:
        print('  on-disk file matches tools/gen_data_bank_06_asm.py output')

    if args.dump:
        dump(stock)
    return rc


if __name__ == '__main__':
    sys.exit(main())
