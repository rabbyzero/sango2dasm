#!/usr/bin/env python3
"""Verify the annotated seed-data banks asm/banks/data_10.asm and data_11.asm.

The banks are rendered by tools/gen_data_bank_asm.py: analysed tables are
labelled `.byte` records, everything else is a sliced `.incbin`. This harness
assembles each bank on its own (its own linker config, $8000-$9FFF window) and
compares the result byte-for-byte with rom/prg/prg_XX.bin.

Any difference is reported in human terms, not just as an offset: the byte is
mapped to its table, record label, field and old/new decoded value, so editing
a `.byte` (or regenerating from an edited docs/*.csv) produces a readable diff.

Modes:
    python tools/verify_data_banks.py                 # strict: must be byte-exact
    python tools/verify_data_banks.py --allow-edits   # list the edits, exit 0 if
                                                      # they stay structurally sane
    python tools/verify_data_banks.py --dump-csv      # also write build/<bank>_from_asm.csv
    python tools/verify_data_banks.py --bank 10

`--dump-csv` decodes the records *as the assembly currently states them*, which
is the link back to the CSV world: diff that file against docs/officer_data.csv /
docs/province_data.csv to see edits made on the assembly side.
"""
import argparse
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import extract_officer_data as officer_tool        # noqa: E402
import extract_province_data as province_tool      # noqa: E402
import gen_data_bank_asm as gen                    # noqa: E402

ROOT = gen.ROOT
CC65 = '/home/zero/.local/bin/ca65'
LD65 = '/home/zero/.local/bin/ld65'
BUILD = os.path.join(ROOT, 'build')

# (bank, table regions) reused from the generator so both tools agree exactly.
BANKS = {0x10: None, 0x11: None}


def linker_cfg(bank):
    return ('MEMORY {\n'
            '    BANK%02X: start = $8000, size = $2000, type = ro, fill = yes,\n'
            '            fillval = $FF, file = "build/_seed%02x.bin";\n'
            '}\n'
            'SEGMENTS {\n'
            '    CODE_BANK%02X: load = BANK%02X, type = ro;\n'
            '}\n' % (bank, bank, bank, bank))


def assemble_bank(bank):
    """ca65 + ld65 the single bank; returns the built bytes or None."""
    os.makedirs(BUILD, exist_ok=True)
    src = os.path.join(ROOT, 'asm', 'banks', 'data_%02x.asm' % bank)
    obj = os.path.join(BUILD, '_seed%02x.o' % bank)
    asm = os.path.join(BUILD, '_seed%02x.asm' % bank)
    cfg = os.path.join(BUILD, '_seed%02x.cfg' % bank)
    out = os.path.join(BUILD, '_seed%02x.bin' % bank)
    # The bank files declare `.segment "CODE_BANKxx"`; assembling standalone
    # needs the segment to exist in the config, which linker_cfg provides.
    with open(src, encoding='utf-8') as f:
        text = f.read()
    with open(asm, 'w', encoding='utf-8') as f:
        f.write(text)
    with open(cfg, 'w', encoding='utf-8') as f:
        f.write(linker_cfg(bank))
    r = subprocess.run([CC65, '-I', os.path.join(ROOT, 'include'),
                        '-I', os.path.join(ROOT, 'asm', 'banks'),
                        asm, '-o', obj], capture_output=True, text=True,
                       cwd=ROOT)
    if r.returncode != 0:
        print('CA65 FAILED (bank %02X):\n%s' % (bank, r.stderr[:3000]),
              file=sys.stderr)
        return None
    if r.stderr.strip():
        print('ca65 notes (bank %02X): %s' % (bank, r.stderr.strip()[:400]))
    r = subprocess.run([LD65, '-C', cfg, obj, '-o', out],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('LD65 FAILED (bank %02X):\n%s' % (bank, r.stderr[:3000]),
              file=sys.stderr)
        return None
    with open(out, 'rb') as f:
        return f.read()


def label_index(bank):
    """[(start_off, end_off, kind, stride, labels)] for one bank, in file order.

    `labels` maps a record's bank offset to its label text, read back from the
    generated assembly so the report names records the way the source does.
    """
    src = os.path.join(ROOT, 'asm', 'banks', 'data_%02x.asm' % bank)
    with open(src, encoding='utf-8') as f:
        text = f.read()
    labels = {}
    for m in re.finditer(r'^(OfficerRecord|ProvinceRecord|OfficerName|'
                         r'ProvinceName|ArrivalSchedule|OfficerRecordPadding|'
                         r'OfficerName_Unused)_([A-Za-z0-9_]+):', text, re.M):
        # offset comes from the first address comment on the following byte line
        tail = text[m.end():m.end() + 4000]
        addr = re.search(r'; \$([0-9A-F]{4})', tail)
        if addr:
            labels[int(addr.group(1), 16) - gen.WINDOW_CPU] = m.group(0)[:-1]
    # multi-line record labels: a bare `Name:` followed by an indented .byte
    for m in re.finditer(r'^(\w+):\n\s+\.byte[^;]*; \$(\w{4})', text, re.M):
        labels.setdefault(int(m.group(2), 16) - gen.WINDOW_CPU, m.group(1))
    regions = []
    strides = {'off_records': gen.OFF_RECORD_STRIDE,
               'prov_records': gen.PROV_RECORD_STRIDE,
               'off_names': gen.OFF_NAME_STRIDE,
               'prov_names': gen.PROV_NAME_STRIDE,
               'schedule': gen.ARRIVAL_STRIDE,
               'death_years': 1,
               'ppu_screens': gen.SCREEN_SIZE,
               'prov_facility': 1}
    for cpu, length, kind in gen.bank_regions(bank):
        stride = strides[kind]
        regions.append((cpu - gen.WINDOW_CPU, cpu - gen.WINDOW_CPU + length,
                        kind, stride))
    return regions, labels


def describe(bank, offset, expected, actual, regions, labels, ctx):
    """One differing byte -> a human-readable line."""
    for start, end, kind, stride in regions:
        if not (start <= offset < end):
            continue
        rec_off = start + ((offset - start) // stride) * stride
        name = labels.get(rec_off, 'offset $%04X' % (gen.WINDOW_CPU + rec_off))
        field = 'byte +$%02X of the record' % (offset - rec_off)
        if kind == 'off_records':
            rid = (rec_off - (gen.OFF_RECORD_CPU - gen.WINDOW_CPU)) // stride
            row = ctx['off_by_id'][rid]
            field = OFFICER_FIELDS.get(offset - rec_off, field)
            return ('%s (%s %s): %s changed $%02X -> $%02X'
                    % (name, rid, row['zh_hans'], field, expected, actual))
        if kind == 'prov_records':
            rid = (rec_off - (gen.PROV_RECORD_CPU - gen.WINDOW_CPU)) // stride
            prov = ctx['prov_by_id'][rid]
            in_off = offset - rec_off
            if PROVINCE_ROSTER_FIRST <= in_off < PROVINCE_ROSTER_FIRST + 10:
                slot = in_off - PROVINCE_ROSTER_FIRST
                who = lambda oid: ('empty' if oid == 0xFF else
                                   ('%d %s' % (oid, ctx['off_by_id'][oid]['zh_hans'])
                                    if oid < gen.OFF_RECORD_COUNT
                                    else '%d (no such officer)' % oid))
                field = '武将 roster slot %d (%s -> %s)' % (
                    slot, who(expected), who(actual))
            else:
                field = PROVINCE_FIELDS.get(in_off, field)
            return ('%s (province %d %s): %s changed $%02X -> $%02X'
                    % (name, rid, prov['kanji'].get('zh_hans', ''), field,
                       expected, actual))
        if kind in ('off_names', 'prov_names'):
            return '%s: name code byte $%02X -> $%02X' % (name, expected, actual)
        if kind == 'schedule':
            pair = (offset - rec_off) // 2
            what = 'officer id' if (offset - rec_off) % 2 == 0 else 'appear year'
            return '%s: schedule pair %d %s $%02X -> $%02X' % (
                name, pair, what, expected, actual)
        if kind == 'death_years':
            oid = offset - start
            return ('death year of officer %d (%s): %d -> %d'
                    % (oid, ctx['off_by_id'].get(oid, {}).get('zh_hans', '?'),
                       expected + gen.DEATH_YEAR_OFFSET,
                       actual + gen.DEATH_YEAR_OFFSET))
    return 'offset $%04X: $%02X -> $%02X (unanalysed gap?)' % (
        gen.WINDOW_CPU + offset, expected, actual)


OFFICER_FIELDS = {
    0x00: '体力 Vitality', 0x01: '武力 Might', 0x02: '知力 Intelligence',
    0x03: '忠誠度 Loyalty', 0x04: '人徳 Virtue', 0x05: '位置 LocationProvince',
    0x06: '経験値 Experience lo', 0x07: '経験値 Experience hi',
    0x08: '兵数 TroopCount lo', 0x09: '兵数 TroopCount hi',
    0x0A: '武器/防具 equipment', 0x0B: 'レベル/軍の属性/状態',
}
PROVINCE_FIELDS = {
    0x00: '所属国 Country', 0x01: 'unused (runtime)',
    0x02: '金 Gold lo', 0x03: '金 Gold hi', 0x04: '米 Rice lo', 0x05: '米 Rice hi',
    0x06: '人口 Population lo', 0x07: '人口 Population hi',
    0x08: '土地 LandValue lo', 0x09: '土地 LandValue hi',
    0x0A: '防災 DisasterPrevention', 0x0B: '統治度 Governance',
    0x0C: '控え ReserveTroops lo', 0x0D: '控え ReserveTroops hi',
    0x0E: '産業 Industry lo', 0x0F: '産業 Industry hi',
    0x10: '宝 Treasure', 0x1B: '反乱クールダウン RevoltCooldown',
    0x1C: 'unused (runtime)', 0x1D: 'unused (runtime)',
    0x1E: 'unused (runtime)', 0x1F: 'unused (runtime)',
}
# roster slots +$11..+$1A are handled separately (they carry officer ids)
PROVINCE_ROSTER_FIRST = 0x11


def structural_check(bank, assembled):
    """Re-validate the invariants of one assembled bank (edits included)."""
    problems = []
    if bank == 0x11:
        for oid in range(gen.OFF_RECORD_COUNT):
            rec = assembled[oid * gen.OFF_RECORD_STRIDE:
                            (oid + 1) * gen.OFF_RECORD_STRIDE]
            if rec[5] != 0:
                problems.append('officer %d: +05 位置 is $%02X, must stay 0'
                                % (oid, rec[5]))
            st = rec[11] & 0x03
            if st not in officer_tool.SEED_STATUSES:
                problems.append('officer %d: +0B 状態 is %d, seed must be 1 or 2'
                                % (oid, st))
            aff = (rec[11] >> 2) & 0x03
            if aff > 2:
                problems.append('officer %d: +0B 軍の属性 is %d, valid 0-2'
                                % (oid, aff))
            for i in (0, 1, 2, 3, 4):
                if not 1 <= rec[i] <= 100:
                    problems.append('officer %d: field +%02X is %d, out of 1-100'
                                    % (oid, i, rec[i]))
            if (rec[11] >> 4) > 4:
                problems.append('officer %d: +0B レベル %d above 5'
                                % (oid, rec[11] >> 4))
    if bank == 0x10:
        for pid in range(gen.PROV_COUNT):
            base = ((gen.PROV_RECORD_CPU - gen.WINDOW_CPU)
                    + pid * gen.PROV_RECORD_STRIDE)
            rec = assembled[base:base + gen.PROV_RECORD_STRIDE]
            if rec[0] & 0xF0:
                problems.append('province %d: +00 high nibble set ($%02X)'
                                % (pid, rec[0]))
            if rec[0] & 0x0F > 7:
                problems.append('province %d: 所属国 %d > 7'
                                % (pid, rec[0] & 0x0F))
            if rec[1] or any(rec[0x1C:]):
                problems.append('province %d: runtime bytes +01/+1C..+1F not 0'
                                % pid)
            if rec[0x0B] > 100 or rec[0x0A] > 99 or rec[0x10] > 99:
                problems.append('province %d: 統治/防災/宝 over cap' % pid)
            for off in (0x02, 0x04, 0x0C):
                if (rec[off] | rec[off + 1] << 8) > 9999:
                    problems.append('province %d: +$%02X over 9999' % (pid, off))
            for off in (0x08, 0x0E):
                if (rec[off] | rec[off + 1] << 8) > 999:
                    problems.append('province %d: +$%02X over 999' % (pid, off))
            for off in range(0x11, 0x1B):
                if rec[off] != 0xFF and rec[off] >= gen.OFF_RECORD_COUNT:
                    problems.append('province %d roster +$%02X = %d >= 237'
                                    % (pid, off, rec[off]))
    return problems


def cross_check(b10, b11):
    """Officer 状態 must equal the province roster set, from the asm bytes only."""
    rostered = set()
    base = gen.PROV_RECORD_CPU - gen.WINDOW_CPU
    for pid in range(gen.PROV_COUNT):
        rec = b10[base + pid * 32:base + (pid + 1) * 32]
        for off in range(0x11, 0x1B):
            if rec[off] != 0xFF:
                rostered.add(rec[off])
    status2 = {oid for oid in range(gen.OFF_RECORD_COUNT)
               if b11[oid * 12 + 11] & 0x03 == 2}
    if rostered != status2:
        return ['roster / 状態 mismatch: roster-only %s, status-2-only %s'
                % (sorted(rostered - status2), sorted(status2 - rostered))]
    print('  cross-bank: officer 状態 == province roster set (%d officers)'
          % len(rostered))
    return []


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--bank', default='all', choices=['10', '11', 'all'])
    ap.add_argument('--allow-edits', action='store_true',
                    help='report decoded edits instead of failing on them')
    ap.add_argument('--dump-csv', action='store_true',
                    help='write build/<bank>_from_asm.csv decoded from the asm')
    args = ap.parse_args()

    gen.init_names()
    ctx = {'off_by_id': {r['id']: r for r in officer_tool.load_rows(gen.NES_PATH)[0]},
           'prov_by_id': {r['id']: r for r in
                          list(province_tool.load_provinces(gen.PRG_COMBINED))}
           }
    banks = [0x10, 0x11] if args.bank == 'all' else [int(args.bank, 16)]
    rc = 0
    built_all = {}
    for bank in banks:
        built = assemble_bank(bank)
        if built is None:
            return 1
        built_all[bank] = built
        stock = gen.read_bank(bank)
        print('bank %02X (asm/banks/data_%02x.asm): %d bytes assembled'
              % (bank, bank, len(built)))
        if len(built) != len(stock):
            print('  FAIL: length %d, expected %d' % (len(built), len(stock)))
            return 1
        diffs = [i for i, (a, b) in enumerate(zip(built, stock)) if a != b]
        if not diffs:
            print('  byte-exact vs rom/prg/prg_%02x.bin' % bank)
        else:
            regions, labels = label_index(bank)
            print('  %d byte(s) differ from the stock ROM:' % len(diffs))
            for i in diffs[:60]:
                print('   ', describe(bank, i, stock[i], built[i], regions,
                                      labels, ctx))
            if len(diffs) > 60:
                print('     ... %d more' % (len(diffs) - 60))
            if not args.allow_edits:
                rc = 1
        problems = structural_check(bank, built)
        for p in problems[:20]:
            print('  INVALID: %s' % p, file=sys.stderr)
        if problems:
            rc = 1
        else:
            print('  structural invariants hold')
        if args.dump_csv and bank == 0x11:
            path = os.path.join(BUILD, 'officer_from_asm.csv')
            dump_officer_csv(built, path, ctx)
            print('  wrote %s' % os.path.relpath(path, ROOT))
        if args.dump_csv and bank == 0x10:
            path = os.path.join(BUILD, 'province_from_asm.csv')
            dump_province_csv(built, path, ctx)
            print('  wrote %s' % os.path.relpath(path, ROOT))
    if len(built_all) == 2:
        problems = cross_check(built_all[0x10], built_all[0x11])
        for p in problems:
            print('  INVALID: %s' % p, file=sys.stderr)
        if problems:
            rc = 1
    return rc


def dump_officer_csv(built, path, ctx):
    """Decode the assembled bank $11 officer records into a CSV."""
    import csv
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        w.writerow(['id', 'label', 'katakana', 'zh_hans', 'vitality', 'might',
                    'intelligence', 'loyalty', 'virtue', 'officer_level',
                    'experience', 'troop_count', 'army_affinity_bits',
                    'officer_status', 'weapon_index', 'armor_index', 'hex'])
        for oid in range(gen.OFF_RECORD_COUNT):
            rec = built[oid * 12:(oid + 1) * 12]
            row = ctx['off_by_id'][oid]
            w.writerow([oid, gen.OFF_LABELS.get(oid, ''), row['katakana'],
                        row['zh_hans'], rec[0], rec[1], rec[2], rec[3], rec[4],
                        (rec[11] >> 4) + 1, rec[6] | rec[7] << 8,
                        rec[8] | rec[9] << 8, (rec[11] >> 2) & 3,
                        officer_tool.OFFICER_STATUS.get(rec[11] & 3, ''),
                        rec[10] & 0x1F, rec[10] >> 5, rec.hex().upper()])


def dump_province_csv(built, path, ctx):
    import csv
    base = gen.PROV_RECORD_CPU - gen.WINDOW_CPU
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        w.writerow(['id', 'label', 'katakana', 'zh_hans', 'country_id', 'gold',
                    'rice', 'population', 'land_value', 'disaster_prevention',
                    'governance', 'reserve_troops', 'industry', 'treasure',
                    'officer_ids', 'hex'])
        for pid in range(gen.PROV_COUNT):
            row = ctx['prov_by_id'][pid]
            rec = built[base + pid * 32:base + (pid + 1) * 32]
            w.writerow([pid, gen.PROV_LABELS.get(pid, ''), row['katakana'],
                        row['kanji'].get('zh_hans', ''), rec[0] & 0x0F,
                        rec[2] | rec[3] << 8, rec[4] | rec[5] << 8,
                        (rec[6] | rec[7] << 8) * 100, rec[8] | rec[9] << 8,
                        rec[10], rec[11], rec[12] | rec[13] << 8,
                        rec[14] | rec[15] << 8, rec[16],
                        ' '.join(str(rec[o]) for o in range(0x11, 0x1B)
                                 if rec[o] != 0xFF), rec.hex().upper()])


if __name__ == '__main__':
    sys.exit(main())
