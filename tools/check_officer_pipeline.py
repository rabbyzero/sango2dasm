#!/usr/bin/env python3
"""End-to-end checks for the officer pipeline: ROM <-> CSVs <-> asm <-> editors.

The new-game officer data is spread over five tables in the two seed banks
(`$30`/`$31` = `rom/prg/prg_10.bin`/`prg_11.bin`), and three CSV twins in
`docs/` are the editing surface for them. This harness proves the whole loop is
lossless and that both front-ends drive the same codec.

Run it after touching tools/officer_model.py, tools/gen_data_bank_asm.py,
tools/verify_data_banks.py, editor/officer_editor.py or editor/officer_cli.py:

    python3 tools/check_officer_pipeline.py            # make checkofficers
    python3 tools/check_officer_pipeline.py --no-gui   # skip the widget pass

Proves, in order:

  1. the codec rebuilds every stock table byte-for-byte from the CSVs: the 237
     master records (bank $31 `$8000`), the 237 katakana names (bank $30
     `$901A`), the death-year table (bank $31 `$9C58`), all 30 arrival-schedule
     blocks (bank $31 `$8B1C`) and all 30 province records (bank $30 `$8C00`);
  2. the name encoder is the exact inverse of `charmap_kana.decode_name` on all
     237 stock names, agrees with `tools/charmap_kana.py` on the code space, and
     refuses kanji, over-long names and unknown characters;
  3. saving the three CSVs back is byte-identical (column order, CRLF, derived
     columns included), so an editing session that changes nothing changes
     nothing;
  4. the invariants actually bite: seventeen synthetic breaks are each refused
     at the field or reported by `problems()`, a refused roster move leaves the
     model untouched, a half-filled arrival pair still renders, and the stock
     data trips none of them;
  5. the generator agrees with the codec - `--from-csv` on the stock CSVs
     re-renders the committed `asm/banks/data_10_initial_data.asm` / `data_11_officer.asm` unchanged,
     on an edited CSV set the record / name / schedule / death bytes and the
     roster-derived province comments it renders are the ones the codec
     predicts, and an emptied name or an over-full arrival block stops the
     render instead of falling back to the ROM;
  6. the repo's own gate still passes: `tools/verify_data_banks.py` assembles
     both banks byte-exact and re-proves the cross-bank 状態 == roster set;
  7. both front-ends are wired to the codec: an AST audit finds no unresolved
     `self.<attr>` in either file, the GUI's column widths cover every model
     column, the placement-driven fields really are model fields, and the CLI's
     `list` / `show` / `fields` / `check` / `diff` subcommands run headless with
     the documented exit codes and never write without `--write`;
  8. standalone mode degrades instead of breaking: with only `officer_data.csv`
     the roster and death surfaces switch off, say so, refuse 状態 2, still run
     the arrival-block capacity check, refuse a 死亡年 edit that could not be
     saved, still report a rename as leaving the kanji plate behind, and a save
     leaves the two roster columns exactly as they were;
  9. the real GUI, when a display is available: every officer renders in the
     detail pane, a widget edit lands in the model and in the table cell, an
     out-of-range value is refused, undo/redo restore the bytes, the filters and
     sorting select the same officers as the codec, and a save writes CSVs that
     reload clean;
 10. the 計略 stratagem tier display is `BuildCommandList` ($D3EE): the 知力
     windows and the four strategist-id rosters are re-derived over every
     id / レベル / 知力 combination, the code order is the handler table, the
     stock census is 233 知力 tiers plus 4 roster boosts, and both front-ends
     print the same verdict;
 11. arrival provenance: the 16 `OfficerPreferredCountryTable` ($BA50) pairs
     are parsed from bank $19, every preferred officer is hidden and scheduled,
     his placement reports the 14/16-vs-3/16 情報集め join odds, no other
     scheduled officer gets that line, the 26 reinforcement-pool officers
     report their auto-arrival Country, and standalone mode degrades cleanly.

Sections 1-8, 10 and 11 need no display; section 9 prints `skipped` without
one.
"""
import argparse
import ast
import contextlib
import csv
import io
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(ROOT, 'editor'))

import officer_model as model                     # noqa: E402
from bank_asm_names import data_asm_path           # noqa: E402

FAILED = []
CSV_NAMES = ('officer_data.csv', 'province_data.csv',
             'officer_death_years.csv', 'officer_reinforcement.csv')


def check(label, condition, detail=''):
    """One named assertion; the detail is printed only when it fails."""
    print('  %-62s %s%s' % (label, 'ok' if condition else 'FAIL',
                            '' if condition or not detail
                            else ' - ' + str(detail)))
    if not condition:
        FAILED.append(label)
    return condition


def section(title):
    print('\n%s' % title)


class _Event:
    """The one attribute the GUI's <Configure> handler reads."""

    def __init__(self, width):
        self.width = width


def bank(name):
    with open(os.path.join(ROOT, 'rom', 'prg', name), 'rb') as f:
        return f.read()


def load_stock():
    return model.load_default(ROOT)


def temp_csvs(edits=None):
    """A temp dir holding the three CSVs, optionally edited through the model."""
    tmp = tempfile.mkdtemp(prefix='officer-pipeline-')
    for name in CSV_NAMES:
        shutil.copy(os.path.join(ROOT, 'docs', name), os.path.join(tmp, name))
    if edits:
        m = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                             province_csv=os.path.join(tmp, 'province_data.csv'),
                             death_csv=os.path.join(tmp,
                                                    'officer_death_years.csv'),
                             reinforce_csv=os.path.join(
                                 tmp, 'officer_reinforcement.csv'))
        edits(m)
        m.save()
    return tmp


def raw_csvs(mutate):
    """A temp CSV set edited as text, for the breaks the model refuses to make.

    `mutate` maps a CSV name to a function that edits its dict rows in place.
    """
    tmp = temp_csvs()
    for name, fn in mutate.items():
        path = os.path.join(tmp, name)
        with open(path, newline='', encoding='utf-8') as f:
            rows = list(csv.DictReader(f))
            cols = list(rows[0])
        fn(rows)
        with open(path, 'w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=cols, lineterminator='\r\n')
            w.writeheader()
            w.writerows(rows)
    return tmp


# --- 1 the codec reproduces the stock ROM --------------------------------
def test_codec_matches_rom():
    section('1. codec rebuilds every stock table from the CSVs')
    m = load_stock()
    b10, b11 = bank('prg_10.bin'), bank('prg_11.bin')
    check('%d master records == bank $31 $8000' % model.OFFICER_COUNT,
          m.record_bytes() == b11[:model.OFFICER_COUNT * model.RECORD_STRIDE])
    names = b10[model.NAME_CPU - 0x8000:]
    check('%d katakana names == bank $30 $901A' % model.OFFICER_COUNT,
          m.name_bytes() == names[:model.OFFICER_COUNT * model.NAME_STRIDE])
    base = model.DEATH_CPU - model.WINDOW_CPU
    check('death years == bank $31 $9C58',
          m.death_bytes() == b11[base:base + model.OFFICER_COUNT])
    base = model.ARRIVAL_CPU - model.WINDOW_CPU
    blocks = m.schedule_blocks()
    bad = []
    for pid, pairs in blocks.items():
        raw = b11[base + pid * model.ARRIVAL_STRIDE:
                  base + (pid + 1) * model.ARRIVAL_STRIDE]
        rom = []
        for i in range(model.ARRIVAL_PAIRS):
            oid, year = raw[i * 2], raw[i * 2 + 1]
            if oid == 0xFF:
                break
            rom.append((oid, year))
        if rom != pairs:
            bad.append(pid)
    check('all %d arrival blocks == bank $31 $8B1C' % model.PROVINCE_COUNT,
          not bad, bad)
    base = model.PROV_RECORD_CPU - model.WINDOW_CPU
    bad = [p.id for p in m.provinces
           if p.roster_record() != b10[base + p.id * model.PROV_RECORD_STRIDE:
                                       base + (p.id + 1)
                                       * model.PROV_RECORD_STRIDE]]
    check('all %d province records == bank $30 $8C00' % model.PROVINCE_COUNT,
          not bad, bad)
    check('the kanji plates are read from bank $31 $8DB4',
          all(o.glyph for o in m.officers)
          and m.officer(0).glyph == b11[model.NAME_GLYPH_CPU - model.WINDOW_CPU:
                                        model.NAME_GLYPH_CPU - model.WINDOW_CPU
                                        + model.NAME_GLYPH_STRIDE])
    # The plate's CHR font page: page V -> rom/chr/chr_(V//8).bin @ (V%8)*$400,
    # tile n -> n*$10, one kanji = the (n, n+1, n+$10, n+$11) quad. Proved by
    # decoding every surname group to its kanji; these assertions pin it.
    check('plate glyph pages load from rom/chr',
          m.has_chr and len(m.chr_pages) == len({o.glyph[0]
                                                 for o in m.officers}),
          (m.has_chr, len(m.chr_pages)))
    check('every plate glyph decodes with ink',
          all(any(v for row in k for v in row)
              for o in m.officers for k in o.plate_pixels()))
    check('plate glyph pixels stay inside the sprite palette',
          all(v < len(model.NAME_SPRITE_PALETTE)
              for o in m.officers for k in o.plate_pixels()
              for row in k for v in row))
    check('shared surnames share their first plate glyph',
          m.officer(3).plate_pixels()[0] == m.officer(4).plate_pixels()[0]
          and m.officer(7).plate_pixels()[0] == m.officer(9).plate_pixels()[0])
    check('different surnames decode differently',
          m.officer(3).plate_pixels()[0] != m.officer(11).plate_pixels()[0])
    # The card portraits: page table prg_1a $CED6, body/face OAM blobs in bank
    # $01 (see the PORTRAIT_* notes in the codec). The compose was verified
    # against the on-screen 武将カード art (and officer 131 曹操 against the
    # manual scan card); these assertions pin the structure.
    check('the card portraits are read from prg_01 + prg_1a',
          m.has_portraits and len(m.portrait_chunks) == 62,
          (m.has_portraits, len(m.portrait_chunks)))
    check('every officer has an authored portrait page',
          all(o.portrait_page is not None and o.portrait_chr is not None
              for o in m.officers))
    check('the four reinforcement-only officers share two late pages',
          m.officer(13).portrait_page == m.officer(116).portrait_page == 0x9F
          and m.officer(19).portrait_page == m.officer(228).portrait_page == 0xDB
          and m.officer(13).portrait_pixels(0)
          != m.officer(116).portrait_pixels(0)
          and m.officer(19).portrait_pixels(0)
          != m.officer(228).portrait_pixels(0))
    check('every authored portrait parses to a body + four 6-sprite faces',
          all(len(o.portrait_body) >= 10
              and all(len(f) == 6 for f in o.portrait_faces.values())
              for o in m.officers))
    check('every portrait render has ink',
          all(any(v for row in o.portrait_pixels(0)[1] for v in row)
              for o in m.officers))
    check('portrait pixels are NES palette triples',
          all(v == 0 or v in model.NES_RGB
              for o in m.officers
              for row in o.portrait_pixels(0)[1] for v in row))
    check('expressions render different faces',
          m.officer(2).portrait_pixels(0) != m.officer(2).portrait_pixels(2)
          and m.officer(2).portrait_pixels(2) != m.officer(2).portrait_pixels(3)
          and m.officer(2).portrait_pixels(3) != m.officer(2).portrait_pixels(4))
    check('expression 1 is the normal face again',
          m.officer(2).portrait_pixels(1) == m.officer(2).portrait_pixels(0))
    # The AI ruler successor priority lists (bank $0B $CAD8): read-only, and
    # the decode must match the committed asm table byte for byte.
    check('the AI successor lists parse from bank $0B $CAD8',
          m.has_heirs and len(m.heir_priority) == 7,
          (m.has_heirs, len(m.heir_priority)))
    check('the successor lists decode to the committed officers',
          m.heir_priority_lines(names=False) == [
              'Country 0: 218 > 219 > 211',
              'Country 1: 9 > 7',
              'Country 2: 132 > 123 > 127 > 128 > 133 > 130',
              'Country 3: 137 > 139 > 93',
              'Country 4: 224 > 109 > 38 > 153',
              'Country 5: 66 > 151',
              'Country 6: 180 > 176 > 181 > 179'],
          m.heir_priority_lines(names=False))
    check('heir_successor_lists finds the listed heirs',
          m.heir_successor_lists(180) == [(6, 0, [180, 176, 181, 179])]
          and m.heir_successor_lists(131) == [])
    # The auto-arrival reinforcement pools (bank $31 $8D74): EventReinforceGate
    # $A33C is sub-state 2 of the monthly event dispatch, and
    # OfficerReinforceScene $AEC0 inspects the first still-hidden officer whose
    # year has arrived - these are where the unscheduled 26 go.
    check('the reinforcement pools parse from bank $31 $8D74',
          len(m.reinforce_pools) == 4
          and [country for country, _ in m.reinforce_pools] == [2, 3, 4, 6],
          m.reinforce_pools[:1])
    check('the pools hold exactly the unscheduled hidden officers',
          {oid for _, pairs in m.reinforce_pools for oid, _ in pairs}
          == {o.id for o in m.officers
              if o.is_hidden and o.appear_year is None})
    check('pool entries carry a sane join year',
          all(150 <= year <= 255
              for _, pairs in m.reinforce_pools for _, year in pairs))
    check('reinforce_entry finds the pool officers',
          m.reinforce_entry(180) == (6, 193)
          and m.reinforce_entry(93) == (3, 192)
          and m.reinforce_entry(0) is None)
    bank_only = model.Model.load(
        os.path.join(ROOT, 'docs', 'officer_data.csv'),
        glyph_bank=os.path.join(ROOT, 'rom', 'prg', 'prg_11.bin'))
    check('the pools CSV twin matches the bank parse',
          m.reinforce_pools == bank_only.reinforce_pools)
    try:
        bank_only.set_reinforce_year(180, 200)
        check('join-year edits are refused without the CSV', False,
              'it was accepted')
    except model.FieldError:
        check('join-year edits are refused without the CSV', True)
    m = load_stock()
    check('stock data trips no invariant', not m.problems(), m.problems()[:2])
    check('labels come from include/officer_ids.inc',
          all(o.label for o in m.officers))


# --- 2 the name codec ----------------------------------------------------
def test_name_codec():
    section('2. name encoder is the inverse of charmap_kana.decode_name')
    import charmap_kana
    check('the two kana code tables are identical',
          charmap_kana.KATAKANA == model.KATAKANA
          and charmap_kana.DAKUTEN == model.DAKUTEN
          and charmap_kana.HANDAKUTEN == model.HANDAKUTEN)
    check('the voiced/handakuten folds agree',
          all(charmap_kana._voiced(c) == model._voiced(c)
              and charmap_kana._semi_voiced(c) == model._semi_voiced(c)
              for c in model.KATAKANA.values()))
    b10 = bank('prg_10.bin')
    raw = b10[model.NAME_CPU - 0x8000:]
    entries = [raw[i * model.NAME_STRIDE:(i + 1) * model.NAME_STRIDE]
               for i in range(model.OFFICER_COUNT)]
    check('decode agrees with charmap_kana on all %d names'
          % model.OFFICER_COUNT,
          all(model.decode_name(e) == charmap_kana.decode_name(e)
              for e in entries))
    check('encode(decode(bytes)) == bytes for all %d names'
          % model.OFFICER_COUNT,
          all(model.encode_name(model.decode_name(e)) == e for e in entries))
    check('a name field keeps its $00 terminator and padding',
          all(model.encode_name(model.decode_name(e))[-1] == 0
              and len(model.encode_name(model.decode_name(e)))
              == model.NAME_STRIDE for e in entries))
    check('hiragana input encodes to the same codes as katakana',
          model.encode_name('りゅうび') == model.encode_name('リュウビ'))
    check('a postfix ゛ encodes as the voiced katakana',
          model.encode_name('ヒ゛') == model.encode_name('ビ')
          and model.encode_name('ヘ゜') == model.encode_name('ペ'))
    longest = max(entries, key=lambda e: len(e.rstrip(b'\x00')))
    check('the longest stock name fits (%d codes)'
          % len(longest.rstrip(b'\x00')),
          len(longest.rstrip(b'\x00')) <= model.NAME_MAX_CODES)
    for text, why in (('呂布', 'kanji have no code'),
                      ('アイウエオカキクコサ', '10 codes leave no terminator'),
                      ('ー', 'the prolonged sound mark is not in the space'),
                      ('', 'every officer has a name'),
                      ('   ', 'and whitespace is not one')):
        try:
            model.encode_name(text)
            check('refuses %s (%s)' % (text, why), False, 'it encoded')
        except model.NameEncodeError:
            check('refuses %s (%s)' % (text, why), True)


# --- 3 CSV losslessness --------------------------------------------------
def test_csv_lossless():
    section('3. saving the CSVs back changes nothing')
    m = load_stock()
    tmp = tempfile.mkdtemp(prefix='officer-csv-')
    try:
        saved = {}
        for key in ('officer', 'province', 'death', 'reinforce'):
            saved[key] = os.path.join(tmp, os.path.basename(m.paths[key]))
        m.save(**{key + '_csv': path for key, path in saved.items()})
        for key, path in saved.items():
            with open(m.paths[key], 'rb') as a, open(path, 'rb') as b:
                same = a.read() == b.read()
            check('%s is byte-identical' % os.path.basename(path), same)
            if not same:
                with open(m.paths[key], encoding='utf-8') as f:
                    head = f.readline()
                with open(path, encoding='utf-8') as f:
                    other = f.readline()
                check('  header preserved', head == other,
                      '%r vs %r' % (head[:60], other[:60]))
    finally:
        shutil.rmtree(tmp)


# --- 4 the invariants bite ----------------------------------------------
def test_invariants():
    section('4. the invariants catch broken data')
    breaks = (
        ('a stat leaves 1-100', lambda m: m.set(0, 'vitality', 101)),
        ('レベル leaves 1-5', lambda m: m.set(0, 'officer_level', 6)),
        ('a weapon index leaves the catalog',
         lambda m: m.set(0, 'weapon_index', 24)),
        ('an armor index leaves the catalog',
         lambda m: m.set(0, 'armor_index', 8)),
        ('軍の属性 3 does not exist',
         lambda m: m.set(0, 'army_affinity_bits', 3)),
        ('a death year below 100 does not fit the byte',
         lambda m: m.set(0, 'death_year', 99)),
        ('a 16-bit field overflows', lambda m: m.set(0, 'experience', 70000)),
    )
    for label, edit in breaks:
        m = load_stock()
        try:
            edit(m)
            check('%s is refused at the field' % label, False, 'it was accepted')
        except model.FieldError:
            check('%s is refused at the field' % label, True)

    # Breaks the field setter cannot see, which problems() must still report.
    def corrupt(m, mutate):
        mutate(m)
        return m.problems()

    cases = (
        ('状態 2 with no roster slot',
         lambda m: setattr(m.officer(0), 'officer_status_bits', 2)),
        ('状態 1 while still rostered',
         lambda m: setattr(m.officer(16), 'officer_status_bits', 1)),
        ('an officer in two rosters',
         lambda m: m.province(5).roster.append(222)),
        ('a roster slot past the officer table',
         lambda m: m.province(5).roster.append(250)),
        ('an 11th roster slot',
         lambda m: m.province(5).roster.extend(range(11))),
        ('an arrival entry for a rostered officer',
         lambda m: (setattr(m.officer(222), 'schedule_province_id', 3),
                    setattr(m.officer(222), 'appear_year', 200))),
        ('an 11th arrival entry in one block',
         lambda m: [(setattr(m.officer(o), 'schedule_province_id', 0),
                     setattr(m.officer(o), 'appear_year', 200))
                    for o in [x.id for x in m.officers if x.is_hidden][:11]]),
        ('an arrival year that does not fit a byte',
         lambda m: setattr(m.officer(3), 'appear_year', 300)),
        ('two 忠誠度-100 rulers in one province',
         lambda m: setattr(m.officer(38), 'loyalty', 100)),
        ('a name that lost its terminator',
         lambda m: setattr(m.officer(0), 'katakana', 'アイウエオカキクコサ')),
    )
    for label, mutate in cases:
        m = load_stock()
        problems = corrupt(m, mutate)
        check('%s is reported as a problem' % label, bool(problems),
              problems[:1])

    # An assign that raises must leave nothing behind: a half-applied move
    # takes the officer out of one roster and puts him in none.
    m = load_stock()
    before = m.snapshot()
    for bad, label in (('nonsense', 'a non-numeric roster slot'),
                       (model.ROSTER_SLOTS, 'an 11th roster slot'),
                       (-1, 'a negative roster slot')):
        try:
            m.assign(16, 5, bad)
            check('%s is refused' % label, False, 'it was accepted')
        except model.FieldError:
            check('%s is refused' % label, True)
        check('  and a refused assign changes nothing',
              m.snapshot() == before)

    # A half-filled arrival pair is a problem, but every rendering path still
    # has to print it: one cell that raises blanks the whole table.
    m = load_stock()
    off = m.officer(4)
    m.clear_schedule(off.id)
    setattr(off, 'appear_year', 205)
    check('a half-filled arrival pair still renders a list cell',
          model.cell_text(m, off, 'placement') == 'arrives 205 @?'
          and len(model.row_values(m, off)) == len(model.COLUMNS),
          model.cell_text(m, off, 'placement'))
    check('  and is still reported', bool(m.problems()), m.problems()[:1])
    setattr(off, 'appear_year', None)
    setattr(off, 'schedule_province_id', 9)
    check('the other half of the pair renders too',
          model.cell_text(m, off, 'placement') == 'arrival entry incomplete')

    # A death CSV that lacks a row would render $00 = year 100 for that id.
    tmp = temp_csvs()
    try:
        path = os.path.join(tmp, 'officer_death_years.csv')
        with open(path, newline='', encoding='utf-8') as f:
            text = f.read().splitlines(True)
        with open(path, 'w', newline='', encoding='utf-8') as f:
            f.writelines(text[:-1])          # drop the last row (id 236)
        m = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                             province_csv=os.path.join(tmp,
                                                       'province_data.csv'),
                             death_csv=path)
        problems = m.problems()
        check('a death CSV missing a row is reported',
              any('death-year CSV has no row' in p for p in problems),
              problems[:2])
    finally:
        shutil.rmtree(tmp)

    m = load_stock()
    check('the stock notes name the one documented slip (id 71)',
          len(m.notes()) == 1 and '71' in m.notes()[0], m.notes())


# --- 5 the generator agrees with the codec -------------------------------
def test_generator():
    section('5. gen_data_bank_asm.py --from-csv agrees with the codec')
    import gen_data_bank_asm as gen

    def render(bank_id, from_csv, docs=None):
        saved = gen.DOCS
        try:
            if docs:
                gen.DOCS = docs
            gen.init_names()
            ctx = gen.build_context(bank_id, from_csv)
            return gen.render_bank(bank_id, ctx), ctx
        finally:
            gen.DOCS = saved

    for bank_id in (0x10, 0x11):
        path = data_asm_path(bank_id, ROOT)
        with open(path, encoding='utf-8') as f:
            committed = f.read()
        for flag in (False, True):
            with contextlib.redirect_stderr(io.StringIO()):
                lines, _ = render(bank_id, flag)
            label = '--from-csv' if flag else 'the ROM path'
            check('bank %02X %s re-renders the committed asm' % (bank_id, label),
                  '\n'.join(lines) + '\n' == committed)

    def edits(m):
        m.set(218, 'might', 100)
        m.set(0, 'katakana', 'テスト')
        m.set(0, 'death_year', 250)
        m.set(3, 'officer_level', 5)
        m.set(3, 'experience', 5000)
        m.set(3, 'weapon_index', 21)
        m.set(3, 'armor_index', 5)
        m.set(3, 'army_affinity_bits', 2)
        m.unassign(16)
        m.assign(16, 5, 0)
        m.set(4, 'appear_year', None)
        m.set_schedule(4, 9, 205)
        m.set_reinforce_year(180, 200)

    tmp = temp_csvs(edits)
    try:
        edited = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                                  province_csv=os.path.join(
                                      tmp, 'province_data.csv'),
                                  death_csv=os.path.join(
                                      tmp, 'officer_death_years.csv'),
                                  reinforce_csv=os.path.join(
                                      tmp, 'officer_reinforcement.csv'))
        with contextlib.redirect_stderr(io.StringIO()):
            lines11, ctx11 = render(0x11, True, tmp)
            _, ctx10 = render(0x10, True, tmp)
        by_id = {r['id']: r for r in ctx11['officers']}
        check('the generator renders the codec\'s record bytes',
              all(by_id[o.id]['record'] == o.record() for o in edited.officers))
        by_id10 = {r['id']: r for r in ctx10['officers']}
        check('the generator renders the codec\'s encoded names',
              all(by_id10[o.id]['name_bytes'] == o.name_bytes()
                  for o in edited.officers))
        check('the renamed officer is re-encoded, not copied from the ROM',
              by_id10[0]['name_bytes'] == model.encode_name('テスト')
              != bank('prg_10.bin')[model.NAME_CPU - 0x8000:
                                    model.NAME_CPU - 0x8000 + 10])
        check('the generator renders the codec\'s death bytes',
              bytes(r['byte'] for r in ctx11['deaths']) == edited.death_bytes())
        check('the generator renders the codec\'s arrival blocks',
              ctx11['schedule'] == edited.schedule_blocks())
        text11 = '\n'.join(lines11)
        check('the edited join year lands in the rendered pool',
              edited.reinforce_entry(180) == (6, 200)
              and '180(马超)->200' in text11, '180(马超)->200' in text11)
        check('  and the rendered pool pointers still tile the region',
              '$2D7C' in text11 and '$8DAB' in text11)
        check('the moved roster lands in the province record',
              ctx10['provinces'][5]['record'][model.ROSTER_START] == 16
              and ctx10['provinces'][26]['record'][model.ROSTER_START + 1]
              != 16)
        check('an edited set still trips no invariant',
              not edited.problems(), edited.problems()[:2])
    finally:
        shutil.rmtree(tmp)

    # The generator has to refuse what the codec refuses: a fallback here would
    # render bytes the editor never showed, from the very same CSV.
    def render_error(bank_id, name, mutate):
        tmp = raw_csvs({name: mutate})
        try:
            with contextlib.redirect_stderr(io.StringIO()):
                render(bank_id, True, tmp)
        except SystemExit as exc:
            return str(exc)
        return None

    err = render_error(0x10, 'officer_data.csv',
                       lambda rows: rows[3].__setitem__('katakana', ''))
    check('an emptied CSV name stops the render (no silent ROM fallback)',
          err is not None and 'officer 3' in err, err)

    def pile(rows):
        n = 0
        for r in rows:
            if n > model.ARRIVAL_PAIRS:
                return
            if r['officer_status_bits'] == '1' and not r['appear_year']:
                r['schedule_province_id'] = '0'
                r['appear_year'] = str(200 + n)
                n += 1

    err = render_error(0x11, 'officer_data.csv', pile)
    check('an over-full arrival block stops the render (no silent truncation)',
          err is not None and 'province 0' in err, err)

    def add_pool_entry(rows):
        rows.append({'pool': '3', 'country': '6', 'officer_id': '1',
                     'katakana': 'x', 'zh_hans': 'x', 'table_byte': '100',
                     'join_year': '200'})

    err = render_error(0x11, 'officer_reinforcement.csv', add_pool_entry)
    check('an over-full pool stops the render (26 pairs fill $8D74-$8DB3)',
          err is not None and 'overflow' in err, err)

    # The province comment's roster-derived columns must follow the CSV: the
    # codec recomputes them on every save, so quoting the stock ROM would print
    # a 現役= and ruler= that contradict the roster on the same line.
    tmp = temp_csvs()
    try:
        path = os.path.join(tmp, 'province_data.csv')
        with open(path, newline='', encoding='utf-8') as f:
            rows = list(csv.DictReader(f))
            cols = list(rows[0])
        target = next(r for r in rows if r['ruler_officer_id']
                      and r['officer_ids'])
        pid = int(target['id'])
        ids = target['officer_ids'].split()
        target['officer_ids'] = ' '.join(o for o in ids
                                         if o != target['ruler_officer_id'])
        with open(path, 'w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=cols, lineterminator='\r\n')
            w.writeheader()
            w.writerows(rows)
        with contextlib.redirect_stderr(io.StringIO()):
            _, ctx10 = render(0x10, True, tmp)
        edited = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                                  province_csv=path,
                                  death_csv=os.path.join(
                                      tmp, 'officer_death_years.csv'))
        by_pid = {r['id']: r for r in ctx10['provinces']}
        mismatch = []
        for prov in edited.provinces:
            row = edited.province_row(prov)
            got = by_pid[prov.id]
            want_ruler = None if row['ruler_officer_id'] == '' \
                else int(row['ruler_officer_id'])
            if (got['officer_count'] != int(row['officer_count'])
                    or got['active_troops'] != int(row['active_troops'])
                    or got['ruler_officer_id'] != want_ruler):
                mismatch.append(prov.id)
        check('the province comments follow the edited rosters',
              not mismatch, mismatch)
        check('  and the dropped ruler is gone from his province',
              by_pid[pid]['ruler_officer_id'] is None
              and by_pid[pid]['officer_count'] == len(ids) - 1,
              by_pid[pid]['ruler_officer_id'])
    finally:
        shutil.rmtree(tmp)


# --- 6 the repo byte gate ------------------------------------------------
def test_repo_gate():
    section('6. tools/verify_data_banks.py still gates both banks')
    r = subprocess.run([sys.executable, 'tools/verify_data_banks.py'],
                       cwd=ROOT, capture_output=True, text=True)
    out = r.stdout + r.stderr
    check('strict verify exits 0', r.returncode == 0,
          ' '.join(out.split())[:200])
    check('both banks assemble byte-exact',
          out.count('byte-exact') == 2)
    check('the cross-bank 状態 == roster set is re-proved',
          'cross-bank' in out)
    r = subprocess.run([sys.executable, 'tools/verify_data_banks.py',
                        '--dump-csv'], cwd=ROOT, capture_output=True, text=True)
    check('--dump-csv decodes the asm back to a CSV', r.returncode == 0,
          ' '.join((r.stdout + r.stderr).split())[:200])
    if r.returncode == 0:
        path = os.path.join(ROOT, 'build', 'officer_from_asm.csv')
        with open(path, newline='', encoding='utf-8') as f:
            rows = {int(row['id']): row for row in csv.DictReader(f)}
        m = load_stock()
        check('the asm-decoded records equal the codec\'s',
              all(rows[o.id]['hex'].upper() == o.record().hex().upper()
                  for o in m.officers if o.id in rows),
              len(rows))


# --- 7 both front-ends ---------------------------------------------------
# Methods inherited from tkinter.Tk / the widget API, so they are never
# assigned in the editor source but are still valid `self.<name>` reads.
TK_BASE_API = {'title', 'geometry', 'minsize', 'protocol', 'bind', 'bind_all',
               'destroy', 'mainloop', 'winfo_children', 'winfo_exists',
               'focus_get', 'focus_set', 'config', 'configure', 'update',
               'update_idletasks', 'withdraw', 'pack', 'grid', 'place',
               'cget', 'set'}


def audit_attributes(path, label):
    """Every self.<attr> the code reads must be assigned or inherited."""
    tree = ast.parse(open(path, encoding='utf-8').read(), path)
    defined, reads = set(), {}
    for cls in [n for n in tree.body if isinstance(n, ast.ClassDef)]:
        for stmt in cls.body:
            if isinstance(stmt, (ast.FunctionDef, ast.AsyncFunctionDef)):
                defined.add(stmt.name)
            elif isinstance(stmt, ast.Assign):
                for target in stmt.targets:
                    if isinstance(target, ast.Name):
                        defined.add(target.id)
        for node in ast.walk(cls):
            if (isinstance(node, ast.Attribute)
                    and isinstance(node.value, ast.Name)
                    and node.value.id == 'self'):
                if isinstance(node.ctx, ast.Store):
                    defined.add(node.attr)
                else:
                    reads.setdefault(node.attr, node.lineno)
    missing = {k: v for k, v in reads.items()
               if k not in defined and k not in TK_BASE_API}
    check('%s has no unresolved self attribute (%d reads)' % (label,
                                                              len(reads)),
          not missing,
          '; '.join('self.%s line %d' % kv for kv in
                    sorted(missing.items(), key=lambda x: x[1])))


def test_front_ends():
    section('7. both front-ends are wired to the codec')
    gui_path = os.path.join(ROOT, 'editor', 'officer_editor.py')
    cli_path = os.path.join(ROOT, 'editor', 'officer_cli.py')
    audit_attributes(gui_path, 'the GUI')
    audit_attributes(cli_path, 'the CLI')

    import officer_editor as gui
    keys = [key for key, _, _ in model.COLUMNS]
    check('the GUI widths cover every model column',
          set(gui.COLUMN_WIDTHS) == set(keys),
          sorted(set(keys) ^ set(gui.COLUMN_WIDTHS)))
    check('the placement-driven fields are model fields',
          set(gui.PAIRED) <= set(model.EDITABLE),
          sorted(set(gui.PAIRED) - set(model.EDITABLE)))
    check('the GUI edits every field either by widget or by placement control',
          set(model.EDITABLE) - set(gui.PAIRED) == {
              f.key for f in model.FIELDS if f.key not in gui.PAIRED})
    check('the codec exports the helpers both front-ends use',
          all(hasattr(model, name) for name in
              ('cell_text', 'row_values', 'matches', 'visible', 'sort',
               'status_filter', 'COLUMNS', 'STATUS_FILTERS', 'FIELDS',
               'EDITABLE', 'FIELD_BY_KEY')))
    m = load_stock()
    check('the GUI parses a province dropdown label',
          gui.province_index(' 2 イシュウ 益州') == 2
          and gui.province_index('(none)') is None
          and gui.province_index('all provinces') is None)
    check('sorting agrees with the codec',
          [o.id for o in model.sort(m, m.officers, 'might', True)][:3]
          == [o.id for o in sorted(m.officers, key=lambda o: -o.might)][:3])

    # The CLI, headless, on a temp copy so nothing in docs/ can be written.
    import officer_cli as cli

    def half_fill(rows):
        """Blank one arrival province while its year stays set."""
        row = next(r for r in rows if r['appear_year'])
        row['schedule_province_id'] = ''
        half_fill.oid = row['id']

    tmp = temp_csvs()
    stdout = io.StringIO()
    try:
        for argv, code in (
                (['list', '--brief', '--limit', '3', '--csv',
                  os.path.join(tmp, 'officer_data.csv')], 0),
                (['show', '218', '--csv', os.path.join(tmp,
                                                       'officer_data.csv')], 0),
                (['fields', '--csv', os.path.join(tmp, 'officer_data.csv')], 0),
                (['check', '--csv', os.path.join(tmp, 'officer_data.csv')], 0),
                (['list', '--status', 'bogus', '--csv',
                  os.path.join(tmp, 'officer_data.csv')], 2),
                (['set', '218', 'might=900', '--csv',
                  os.path.join(tmp, 'officer_data.csv')], 1),
                (['show', '999', '--csv', os.path.join(tmp,
                                                       'officer_data.csv')], 2)):
            with contextlib.redirect_stdout(stdout), \
                    contextlib.redirect_stderr(stdout):
                try:
                    got = cli.main(argv)
                except SystemExit as exc:
                    got = exc.code
            check('cli %s exits %d' % (' '.join(argv[:2]), code), got == code,
                   'got %s' % got)
        # A half-filled arrival pair is a data problem, not a crash: the full
        # `list` and `show` must render the broken cell, and `check` name it.
        broken = raw_csvs({'officer_data.csv': half_fill})
        try:
            for argv, code, expect_word in (
                    (['list', '--csv',
                      os.path.join(broken, 'officer_data.csv')], 0, None),
                    (['show', half_fill.oid, '--csv',
                      os.path.join(broken, 'officer_data.csv')], 1,
                     'half filled'),
                    (['check', '--csv',
                      os.path.join(broken, 'officer_data.csv')], 1,
                     'half filled')):
                out = io.StringIO()
                with contextlib.redirect_stdout(out), \
                        contextlib.redirect_stderr(io.StringIO()):
                    try:
                        got = cli.main(argv)
                    except SystemExit as exc:
                        got = exc.code
                check('cli %s on a half-filled pair exits %d'
                      % (' '.join(argv[:2]), code), got == code,
                      'got %s' % got)
                if expect_word:
                    check('  and %s names it' % ' '.join(argv[:2]),
                          expect_word in out.getvalue(),
                          out.getvalue().strip().splitlines()[:2])
        finally:
            shutil.rmtree(broken)

        before = {name: open(os.path.join(tmp, name), 'rb').read()
                  for name in CSV_NAMES}
        with contextlib.redirect_stdout(stdout), \
                contextlib.redirect_stderr(stdout):
            try:
                cli.main(['set', '218', 'might=100', '--csv',
                          os.path.join(tmp, 'officer_data.csv')])
            except SystemExit:
                pass
        after = {name: open(os.path.join(tmp, name), 'rb').read()
                 for name in CSV_NAMES}
        check('a CLI edit without --write writes nothing', before == after)
        with contextlib.redirect_stdout(stdout), \
                contextlib.redirect_stderr(stdout):
            cli.main(['set', '218', 'might=100', '--write', '--csv',
                      os.path.join(tmp, 'officer_data.csv')])
        changed = open(os.path.join(tmp, 'officer_data.csv'), 'rb').read()
        check('a CLI edit with --write saves the CSV',
              changed != before['officer_data.csv'])
        out = stdout.getvalue()
        check('the CLI reports edits in decoded terms',
              '武力 Might: 99 -> 100' in out, out.strip().splitlines()[-3:])
        stdout = io.StringIO()
        with contextlib.redirect_stdout(stdout), \
                contextlib.redirect_stderr(io.StringIO()):
            try:
                got = cli.main(['reinforce', '0', '200', '--csv',
                                os.path.join(tmp, 'officer_data.csv')])
            except SystemExit as exc:
                got = exc.code
        check('cli reinforce on a non-pool officer exits 1', got == 1, 'got %s' % got)
        stdout = io.StringIO()
        with contextlib.redirect_stdout(stdout), \
                contextlib.redirect_stderr(io.StringIO()):
            cli.main(['reinforce', '180', '210', '--write', '--csv',
                      os.path.join(tmp, 'officer_data.csv')])
        check('cli reinforce edits and saves the join year',
              'reinforcement join year: 193 -> 210' in stdout.getvalue(),
              stdout.getvalue().strip().splitlines()[-2:])
        with contextlib.redirect_stdout(io.StringIO()) as diff_out, \
                contextlib.redirect_stderr(io.StringIO()):
            cli.main(['diff', os.path.join(ROOT, 'docs', 'officer_data.csv'),
                      '--csv', os.path.join(tmp, 'officer_data.csv')])
        check('cli diff names the edited field',
              '武力 Might' in diff_out.getvalue(),
              diff_out.getvalue().strip()[:120])
    finally:
        shutil.rmtree(tmp)

    # The portrait surfaces: the CLI needs the card banks, so these pass
    # --repo; the temp CSV keeps the writes away from docs/.
    tmp = temp_csvs()
    try:
        shown = io.StringIO()
        with contextlib.redirect_stdout(shown):
            cli.main(['show', '2', '--repo', ROOT, '--csv',
                      os.path.join(tmp, 'officer_data.csv')])
        check('cli show renders the card portrait',
              'portrait  $CED6[2] -> page $4E' in shown.getvalue(),
              shown.getvalue()[:200])
        marker = io.StringIO()
        with contextlib.redirect_stdout(marker):
            cli.main(['show', '13', '--repo', ROOT, '--csv',
                      os.path.join(tmp, 'officer_data.csv')])
        check('cli show renders the late-arrival page $9F card',
              'portrait  $CED6[13] -> page $9F' in marker.getvalue(),
              marker.getvalue()[:200])
        successors = io.StringIO()
        with contextlib.redirect_stdout(successors):
            cli.main(['successors', '--repo', ROOT, '--csv',
                      os.path.join(tmp, 'officer_data.csv')])
        check('cli successors prints all seven country lists',
              'Country 2: 曹丕 > 曹叡 > 曹彰 > 曹植 > 曹熊 > 曹仁'
              in successors.getvalue()
              and successors.getvalue().count('Country ') == 7,
              successors.getvalue()[:200])
    finally:
        shutil.rmtree(tmp)


# --- 8 standalone mode ---------------------------------------------------
def test_standalone():
    section('8. standalone mode (one CSV, no repo)')
    tmp = tempfile.mkdtemp(prefix='officer-standalone-')
    try:
        lone = os.path.join(tmp, 'officer_data.csv')
        shutil.copy(os.path.join(ROOT, 'docs', 'officer_data.csv'), lone)
        m = model.Model.load(lone)
        check('loads without the province or death CSVs',
              len(m.officers) == model.OFFICER_COUNT and not m.has_rosters
              and not m.has_deaths)
        notes = ' '.join(m.notes())
        check('says which surfaces switched off',
              'province data not loaded' in notes
              and 'death-year CSV not loaded' in notes)
        check('the records still rebuild', len(m.record_bytes())
              == model.OFFICER_COUNT * model.RECORD_STRIDE)
        try:
            m.set(0, 'officer_status_bits', 2)
            check('状態 2 is refused without the rosters', False)
        except model.FieldError:
            check('状態 2 is refused without the rosters', True)
        try:
            m.assign(0, 5)
            check('roster edits are refused without the province CSV', False)
        except model.FieldError:
            check('roster edits are refused without the province CSV', True)
        try:
            m.set(0, 'death_year', 250)
            check('死亡年 is refused with nowhere to save it', False,
                  'it was accepted')
        except model.FieldError:
            check('死亡年 is refused with nowhere to save it', True)
        # A schedule block is $14 bytes wide with or without the province names,
        # so the capacity bound has to hold here too - the CSV, not the roster,
        # is what the renderer reads.
        piled = 0
        for off in m.officers:
            if off.is_hidden and off.appear_year is None \
                    and piled <= model.ARRIVAL_PAIRS:
                off.schedule_province_id = 0
                off.appear_year = 200 + piled
                piled += 1
        check('the arrival-block capacity check runs standalone',
              any('arrival entries' in p for p in m.problems()),
              m.problems()[:2])
        m.set(0, 'katakana', 'テスト')
        check('a rename is still reported with no glyph bank loaded',
              any('kanji name plate' in n for n in m.notes()), m.notes()[:2])
        check('  and the note says the plate is not in hand',
              any('not loaded here' in n for n in m.notes()))
        m.set(0, 'might', 100)
        m.save(officer_csv=lone)
        reloaded = model.Model.load(lone)
        check('the edit survives a save', reloaded.officer(0).might == 100)
        check('the two roster columns are left untouched',
              all(a == b for a, b in zip(
                  (r['roster_province_id'] for r in
                   reloaded.rows['officer'].values()),
                  (r['roster_province_id'] for r in
                   load_stock().rows['officer'].values()))))
    finally:
        shutil.rmtree(tmp)


# --- 9 the real GUI ------------------------------------------------------
def test_gui(args):
    section('9. the real GUI drives the same codec')
    if args.no_gui:
        print('  %-62s skipped (--no-gui)' % 'widget pass')
        return
    import tkinter as tk
    try:
        probe = tk.Tk()
        probe.withdraw()
        probe.destroy()
    except tk.TclError as exc:
        print('  %-62s skipped (no display: %s)' % ('widget pass', exc))
        return

    import officer_editor as gui
    tmp = temp_csvs()
    app = None
    try:
        app = gui.OfficerEditor(
            model, repo=ROOT, officer_csv=os.path.join(tmp, 'officer_data.csv'),
            province_csv=os.path.join(tmp, 'province_data.csv'),
            death_csv=os.path.join(tmp, 'officer_death_years.csv'))
        app.withdraw()
        app.update_idletasks()
        check('the table lists all %d officers' % model.OFFICER_COUNT,
              len(app.tree.get_children()) == model.OFFICER_COUNT)
        errors = []
        for off in app.model.officers:
            try:
                app.tree.selection_set(str(off.id))
                app._on_select()
            except Exception as exc:                      # noqa: BLE001
                errors.append('%d: %s' % (off.id, exc))
        check('every officer renders in the detail pane', not errors,
              errors[:2])
        # The plate pane draws the authored CHR: officer 3 尹楷 has two kanji,
        # each zoomed from 16 px to PLATE_SCALE, with ink inside the paper cell.
        app.tree.selection_set('3')
        app._on_select()
        check('the plate pane renders the game tiles',
              len(app.plate_images) == 2
              and all(img.width() == 16 * gui.PLATE_SCALE
                      and img.height() == 16 * gui.PLATE_SCALE
                      for img in app.plate_images),
              [getattr(img, 'width', lambda: '?')() for img in
               app.plate_images])
        check('  and the first glyph has ink',
              any(not app.plate_images[0].transparency_get(x, y)
                  for y in range(0, 16 * gui.PLATE_SCALE, 2)
                  for x in range(0, 16 * gui.PLATE_SCALE, 2)))
        # The portrait pane draws the officer's own CHR page (officer 3 尹楷,
        # page $20): all four expressions side by side, no selector.
        app.tree.selection_set('3')
        app._on_select()
        check('the portrait pane renders all four expressions',
              len(app.portrait_images) == 4
              and all(img.width() % gui.PLATE_SCALE == 0
                      for img in app.portrait_images)
              and 'page $%02X' % app.model.officer(3).portrait_page
              in app.portrait_var.get(),
              app.portrait_var.get())
        check('  and the cards have ink',
              all(any(not img.transparency_get(x, y)
                      for y in range(0, img.height(), 4)
                      for x in range(0, img.width(), 4))
                  for img in app.portrait_images))
        check('  and the expressions differ',
              any(app.portrait_images[0].get(x, y)
                  != app.portrait_images[2].get(x, y)
                  for y in range(0, app.portrait_images[0].height(), 4)
                  for x in range(0, app.portrait_images[0].width(), 4)))
        app.tree.selection_set('13')
        app._on_select()
        check('the late-arrival page $9F card renders too',
              len(app.portrait_images) == 4
              and 'page $9F' in app.portrait_var.get(),
              app.portrait_var.get())
        # The successor group: read-only, per-officer line + all-countries
        # popup behind Show text.
        app.tree.selection_set('180')
        app._on_select()
        check('the successor group names his country list position',
              'Country 6' in app.successor_var.get()
              and '(he is #1 of 4)' in app.successor_var.get(),
              app.successor_var.get())
        app.tree.selection_set('131')
        app._on_select()
        check('an unlisted officer says so',
              'not in any AI successor list' in app.successor_var.get(),
              app.successor_var.get())
        # The decode text lives behind a Show text button, not on the pane.
        boxes = [w for w in app.detail.winfo_children()
                 if isinstance(w, gui.ttk.LabelFrame)
                 and w.cget('text') in (dict(gui.GROUP_TITLES)['portrait'],
                                        dict(gui.GROUP_TITLES)['plate'])]
        buttons = [b for box in boxes for b in box.winfo_children()
                   if isinstance(b, gui.ttk.Button) and b.cget('text')
                   == 'Show text']
        check('the read-only views hide their text behind Show text buttons',
              len(boxes) == 2 and len(buttons) == 2
              and not [w for box in boxes for w in box.winfo_children()
                       if isinstance(w, gui.ttk.Label)
                       and w.cget('textvariable')],
              [(box.cget('text'), len(buttons)) for box in boxes])
        buttons[0].invoke()
        popups = [w for w in app.winfo_children() if isinstance(w, gui.tk.Toplevel)]
        shown = popups and any(
            isinstance(w, gui.tk.Text)
            for w in popups[0].winfo_children()[0].winfo_children())
        check('  and the popup shows the decode text',
              bool(shown), [str(w) for w in app.winfo_children()])
        for w in popups:
            w.destroy()
        # The auto-arrival row: officer 180 馬超 sits in Country 6's pool (193).
        app.tree.selection_set('180')
        app._on_select()
        check('the auto-arrival row shows the pool and join year',
              'Country 6' in app.auto_arrival_info.get()
              and app.auto_arrival_year.get() == '193',
              (app.auto_arrival_info.get(), app.auto_arrival_year.get()))
        app.auto_arrival_year.delete(0, 'end')
        app.auto_arrival_year.insert(0, '210')
        app.set_auto_arrival_year()
        check('the auto-arrival year edit lands in the model',
              app.model.reinforce_entry(180) == (6, 210),
              app.model.reinforce_entry(180))
        app.undo_edit()
        check('  and undoes back to the stock year',
              app.model.reinforce_entry(180) == (6, 193)
              and not app.model.changes())
        app.tree.selection_set('0')
        app._on_select()
        check('an officer outside the pools shows no auto-arrival spinbox',
              'not in a pool' in app.auto_arrival_info.get()
              and str(app.auto_arrival_year.cget('state')) == 'disabled',
              (app.auto_arrival_info.get(), app.auto_arrival_year.cget('state')))
        # A withdrawn window has no allocation, so drive the pane pinning the
        # way the canvas <Configure> would and measure the requested widths.
        app._on_detail_configure(_Event(gui.DETAIL_W))
        widest = max(c.winfo_reqwidth() for c in app.detail.winfo_children())
        check('the widest detail widget fits the default pane',
              widest <= gui.DETAIL_W,
              '%d px of content in a %d px pane' % (widest, gui.DETAIL_W))
        # The row height must cover the fonts the table actually renders: the
        # CJK cells fall back to fonts taller than the theme default, and the
        # default rowheight clips them mid-glyph.
        import tkinter.font as tkfont
        row_h = int(gui.ttk.Style(app).lookup('Officer.Treeview', 'rowheight'))
        need = max(tkfont.nametofont(name).metrics('linespace')
                   for name in ('TkTextFont', 'TkDefaultFont',
                                'TkHeadingFont')) + gui.ROW_PAD
        check('the table row height covers the fonts it renders',
              row_h >= need, 'row %d px < %d px of type' % (row_h, need))
        # Every dropdown must fit its longest value: Tk counts width in
        # average-size characters, which clips the mixed CJK province labels.
        def fits(box):
            values = list(box.cget('values'))
            if not values:
                return True
            widest = max(tkfont.nametofont('TkTextFont').measure(str(v))
                         for v in values)
            return box.winfo_reqwidth() >= widest + 24

        app.tree.selection_set('16')
        app._on_select()
        app.update_idletasks()
        narrow = [name for name in ('prov_box', 'status_box', 'roster_box',
                                    'sched_box') if not fits(getattr(app, name))]
        narrow += ['field:%s' % key for key, w in app.w.items()
                   if isinstance(w, gui.ttk.Combobox) and not fits(w)]
        check('every dropdown fits its longest value', not narrow, narrow)
        check('the pane is pinned to the canvas width (scrolls, never clips)',
              app.detail_canvas.itemcget(app.detail_win, 'width')
              == str(gui.DETAIL_W),
              app.detail_canvas.itemcget(app.detail_win, 'width'))
        check('the prose labels re-wrap with the pane',
              app.wrapping and all(
                  int(w.cget('wraplength')) == gui.DETAIL_W - gui.WRAP_MARGIN
                  for w in app.wrapping),
              [w.cget('wraplength') for w in app.wrapping])
        app._on_detail_configure(_Event(gui.DETAIL_W - 120))
        check('a narrower pane re-wraps instead of clipping',
              all(int(w.cget('wraplength')) == gui.DETAIL_W - 120
                  - gui.WRAP_MARGIN for w in app.wrapping))
        app._on_detail_configure(_Event(gui.DETAIL_W))

        app.tree.selection_set('218')
        app._on_select()
        stock = app.model.officer(218).might
        app.w['might'].delete(0, 'end')
        app.w['might'].insert(0, str(min(100, stock + 1)))
        app._commit('might')
        check('a widget edit lands in the model',
              app.model.officer(218).might == min(100, stock + 1))
        check('and in the table cell',
              app.tree.set('218', 'might') == str(min(100, stock + 1)))

        import tkinter.messagebox as messagebox
        refused, infos = [], []
        messagebox.showerror = lambda *a, **k: refused.append(a)
        messagebox.showinfo = lambda *a, **k: infos.append(a)
        app.w['vitality'].delete(0, 'end')
        app.w['vitality'].insert(0, '900')
        app._commit('vitality')
        check('an out-of-range value is refused and reported',
              refused and app.model.officer(218).vitality != 900,
              refused[-1][1][:60] if refused else 'no dialog')
        app.undo_edit()
        check('undo restores the bytes',
              app.model.officer(218).might == stock
              and not app.model.changes())
        app.redo_edit()
        check('redo re-applies them',
              app.model.officer(218).might == min(100, stock + 1))
        app.undo_edit()

        app.tree.selection_set('16')
        app._on_select()
        home = app.model.officer(16).roster_province
        app.unassign_officer()
        check('unassign drops the roster slot and sets 状態 1',
              app.model.officer(16).roster_province is None
              and app.model.officer(16).officer_status_bits == 1)
        app.roster_box.set(app.roster_box.cget('values')[home + 1])
        app.slot_box.delete(0, 'end')
        app.slot_box.insert(0, '1')
        app.assign_officer()
        check('assign puts him back in slot 1',
              app.model.officer(16).roster_province == home
              and app.model.officer(16).roster_slot == 1)
        check('unassign + assign keep the cross-bank invariant',
              not app.model.problems(), app.model.problems()[:1])
        check('a widget set covers every non-placement field',
              set(app.w) == set(model.EDITABLE) - set(gui.PAIRED),
              sorted(set(model.EDITABLE) - set(gui.PAIRED) - set(app.w)))

        app.filter_var.set('張')
        app._refresh_table()
        shown = [int(i) for i in app.tree.get_children()]
        check('the filter selects what the codec selects',
              shown == [o.id for o in model.visible(app.model, '張')],
              shown[:5])
        app.filter_var.set('')
        app.status_var.set(model.STATUS_FILTERS[3])
        app._refresh_table()
        check('the ruler filter finds the seven 君主',
              len(app.tree.get_children()) == model.STOCK_RULERS,
              len(app.tree.get_children()))
        app.status_var.set(model.STATUS_FILTERS[0])
        app._refresh_table()
        app._sort_by('might')
        first = int(app.tree.set(app.tree.get_children()[0], 'might'))
        app._sort_by('might')
        last = int(app.tree.set(app.tree.get_children()[0], 'might'))
        check('clicking a header toggles the sort direction', first <= last,
              '%d .. %d' % (first, last))
        app.sort_key, app.sort_reverse = 'id', False
        app._refresh_table()

        check('Save CSVs writes the open CSV set', app.save_csv() is not None)
        reloaded = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                                    province_csv=os.path.join(
                                        tmp, 'province_data.csv'),
                                    death_csv=os.path.join(
                                        tmp, 'officer_death_years.csv'),
                                    reinforce_csv=os.path.join(
                                        tmp, 'officer_reinforcement.csv'))
        check('the saved CSVs reload with no invariant problem',
              not reloaded.problems(), reloaded.problems()[:2])
        check('the saved edits are in the CSVs',
              reloaded.officer(218).might == stock)
    finally:
        if app is not None:
            app.destroy()
        shutil.rmtree(tmp)


# --- 10 the 計略 stratagem tier display -----------------------------------
# The evidence these restate: BuildCommandList ($D3EE, prg_08_09) compares 知力
# against $28/$3C/$4B/$55 ($D4D2-$D4E5) and selects SlotList_2/4/6/8/10/12/14/
# 15/16 through SlotTierPtrs ($D509); the four strategist id rosters and their
# stored-レベル floors are the CMP chain at $D412-$D4C4. The code order is the
# ValidateActionTarget handler table ($ADAC-$ADCA, prg_0c_0d).
def test_stratagem_tier():
    section('10. the 計略 stratagem tier display matches BuildCommandList')
    windows = {2: (0x00, 0x27), 4: (0x28, 0x3B), 6: (0x3C, 0x4A),
               8: (0x4B, 0x54), 10: (0x55, 100)}
    wrong = [(intel, count, slots) for intel in range(0, 101)
             for slots, (lo, hi) in windows.items()
             if lo <= intel <= hi
             for count in [model.stratagem_intelligence_count(intel)]
             if count != slots]
    check('every 知力 value lands in its BuildCommandList window', not wrong,
          wrong[:3])
    check('the ladder constants are the ROM CMP chain',
          [value for value, _ in model.STRATAGEM_INTELLIGENCE_LADDER]
          == [0x00, 0x28, 0x3C, 0x4B, 0x55]
          and [slots for _, slots in model.STRATAGEM_INTELLIGENCE_LADDER]
          == [2, 4, 6, 8, 10])
    check('handler-table order pins codes $08/$09/$0B/$0F',
          [name[1] for name in model.STRATAGEM_NAMES] == [
              'FireAttack', 'PitfallTrap', 'FeintTroops', 'AmbushStrike',
              'BoatSabotage', 'SupplyBurning', 'CastleRaid', 'FriendlyFire',
              'Enticement', 'Rockfall', 'ChainLink', 'TenfoldAmbush',
              'FloodAttack', 'RepeatingCrossbow', 'Inferno', 'MysticalStasis'])
    listed = model.STRATAGEM_LEVEL_ROSTERS
    check('the four strategist rosters are the $D412-$D4C4 sets',
          sorted(sum((sorted(ids) for ids, _ in listed), [])) == sorted([
              0xA1, 0x63, 0xA7, 0x16, 0xC4, 0xDB, 0xEA, 0x6B, 0xCE, 0xEB, 0xB7,
              0x18, 0x37, 0x70, 0xD5, 0x6E, 0x67, 0xC5, 0x56, 0x5D, 0x6D]))

    def rom_count(oid, stored_level, intel):
        """The gate as the ROM reads it, walked in $D412-$D4E5 order."""
        for ids, floors in listed:
            if oid in ids:
                for floor, slots in floors:
                    if stored_level >= floor:
                        return slots
        for value, slots in sorted(model.STRATAGEM_INTELLIGENCE_LADDER,
                                   reverse=True):
            if intel >= value:
                return slots
        return 2

    mismatched = []
    for oid in range(model.OFFICER_COUNT):
        for stored in range(0, 8):
            for intel in (1, 39, 40, 74, 75, 84, 85, 100):
                got = model.stratagem_access(oid, stored + 1, intel)
                want = rom_count(oid, stored, intel)
                if got.count != want or got.codes != tuple(range(want)):
                    mismatched.append('%d/%d/%d: %s != %s'
                                      % (oid, stored, intel, got.count, want))
    check('the codec reproduces the gate over every id/レベル/知力',
          not mismatched, mismatched[:3])
    boosted = [off.id for off in load_stock().officers
               if off.stratagem_access().source == 'level']
    counts = [off.stratagem_access().count for off in load_stock().officers]
    check('the stock seed tops out at 12 slots (no stored レベル reaches 5)',
          max(counts) == 12 and counts.count(12) == 4,
          sorted(set(counts)))
    check('the stock seed breaks down as 233 知力 tiers + 4 roster boosts',
          len(boosted) == 4 and set(boosted) == {0x37, 0x67, 0x6E, 0xD5},
          boosted)

    import officer_editor as gui
    import officer_cli as cli
    check('the GUI owns a stratagem pane and its note cites $D3EE',
          hasattr(gui.OfficerEditor, '_build_stratagems')
          and hasattr(gui.OfficerEditor, '_show_stratagems')
          and 'stratagem' in dict(gui.GROUP_TITLES)
          and '$D3EE' in gui.STRATAGEM_NOTE)
    tmp = temp_csvs()
    out = io.StringIO()
    try:
        with contextlib.redirect_stdout(out), \
                contextlib.redirect_stderr(io.StringIO()):
            code = cli.main(['show', str(0x37), '--csv',
                             os.path.join(tmp, 'officer_data.csv')])
    finally:
        shutil.rmtree(tmp)
    text = out.getvalue()
    check('the CLI prints the same verdict for 姜维',
          code == 0 and 'now 12 of 16 ($00-$0B)' in text
          and 'next レベル 5 -> 14 slots' in text
          and '+$0C 水攻 FloodAttack' in text,
          [line for line in text.splitlines() if line.startswith('now')])
    # The pane shows the usable list, then only the tiers a level-up reaches.
    # Codes beyond the officer's own steps must not appear at all.
    def codes_in(line):
        found = []
        for token in line.split():
            token = token.lstrip('+(').rstrip(')')
            if token.startswith('$') and len(token) == 3:
                found.append(int(token[1:], 16))
        return found

    bad = []
    for off in load_stock().officers:
        acc = off.stratagem_access()
        allowed = set(acc.codes)
        previous = acc.count
        for level, slots in acc.steps:
            if not 1 <= level <= 8:
                bad.append('%d: level %d' % (off.id, level))
            if slots <= previous:
                bad.append('%d: step %d after %d' % (off.id, slots, previous))
            allowed.update(range(previous, slots))
            previous = slots
        for line in off.stratagem_lines():
            if line.startswith('locked'):
                bad.append('%d: locked line' % off.id)
            beyond = [code for code in codes_in(line) if code not in allowed]
            if beyond:
                bad.append('%d: %s' % (off.id, beyond))
    check('only available and level-up codes are shown', not bad, bad[:3])
    bad = ['%d: %s' % (off.id, line) for off in load_stock().officers
           for line in off.stratagem_lines()
           if '->' in line and 'レベル' not in line]
    check('every potential unlock is a レベル step', not bad, bad[:2])
    bad = ['%d' % off.id for off in load_stock().officers
           if not model.stratagem_roster(off.id)[0]
           and off.stratagem_access().steps]
    check('a non-rostered officer has no level-up steps', not bad, bad[:3])
    zhuge = load_stock().by_id[0x6D].stratagem_lines()
    zhuge_text = '\n'.join(zhuge)
    check('诸葛亮 shows the レベル ladder above his 10 知力 slots',
          'now 10 of 16 ($00-$09)' in zhuge[0]
          and 'next レベル 4 -> 12 slots' in zhuge_text
          and '+$0A 連環 ChainLink  +$0B 十面埋伏 TenfoldAmbush' in zhuge_text
          and 'then レベル 7 -> 16 slots: +$0F 奇門遁甲 MysticalStasis'
          in zhuge_text,
          [line for line in zhuge if line.startswith(('next', 'then'))])
    capped = next(off for off in load_stock().officers
                  if not model.stratagem_roster(off.id)[0]
                  and off.intelligence >= 0x55)
    capped_lines = capped.stratagem_lines()
    capped_codes = [code for line in capped_lines for code in codes_in(line)]
    check('a non-rostered officer sees no unreachable tier',
          not any(line.startswith(('next ', 'then ', 'locked'))
                  for line in capped_lines)
          and max(capped_codes) < capped.stratagem_access().count,
          capped_lines[-2:])
    ceiling = load_stock().by_id[0x37].stratagem_lines()
    ceiling_codes = [code for line in ceiling for code in codes_in(line)]
    check('a roster ceiling hides the tiers above it (姜维 top 14)',
          max(ceiling_codes) == 0x0D
          and not any(line.startswith('locked') for line in ceiling),
          ceiling[-2:])
    lines = model.stratagem_ladder_lines(load_stock().by_id)
    check('the ladder table names both gates and all 21 ids',
          lines[1].startswith('  知力 $00-$27')
          and sum(line.count('$') for line in lines[7:]) >= 21,
          lines[7:9])


# --- 11 arrival provenance -------------------------------------------------
# Evidence: OfficerPreferredCountryTable ($BA50, prg_19_1a_event_scenes) holds
# 16 (officer id, Country) pairs and is read only by OfficerArrivalScan's
# scheduled path; the roll at prg_1b_1c_strategy_mode $AB75 compares the scouted
# province's owner Country and uses threshold 2 (14/16 join) on a match, $0D
# (3/16) otherwise. The reinforcement pools (bank $31 $8D74) carry the
# auto-arrival Country.
def test_arrival_provenance():
    section('11. arrival provenance: 情報集め preferred Country + auto arrival')
    m = load_stock()
    expected = {
        0x6D: 4, 0x70: 4, 0x56: 2, 0x37: 4, 0xB7: 4, 0x63: 2, 0x6B: 3,
        0x2F: 3, 0xA1: 2, 0xEA: 3, 0xEB: 3, 0xD5: 3, 0x90: 4, 0x39: 2,
        0xA5: 2, 0x9C: 2,
    }
    check('the $BA50 table parses its 16 pairs',
          m.has_preferred and m.preferred_countries == expected,
          sorted(m.preferred_countries.items()))
    check('every preferred officer is hidden and scheduled',
          all(m.by_id[oid].is_hidden
              and m.by_id[oid].schedule_province_id is not None
              and m.by_id[oid].appear_year is not None for oid in expected),
          [oid for oid in expected if not m.by_id[oid].is_hidden])
    zhuge = m.by_id[0x6D].placement()
    check('a preferred officer reports the 情報集め odds',
          'preferred Country 4' in zhuge and '14/16' in zhuge
          and '3/16' in zhuge, zhuge)
    plain = next(off for off in m.officers
                 if off.schedule_province_id is not None
                 and off.preferred_country is None)
    check('a scheduled officer outside $BA50 has no recruit line',
          '情報集め' not in plain.placement(), plain.placement())
    pool = [off for off in m.officers if off.reinforce_country is not None]
    check('the 26 auto-arrival officers report their Country',
          len(pool) == 26
          and all('auto-arrival Country %d' % off.reinforce_country
                  in off.placement()
                  and 'monthly' in off.placement()
                  and 'January' not in off.placement()
                  and model.cell_text(m, off, 'placement')
                  == 'auto-join Country %d' % off.reinforce_country
                  for off in pool),
          [(off.id, off.reinforce_country) for off in pool[:3]])
    with open(os.path.join(ROOT, 'rom', 'prg', 'prg_19.bin'), 'rb') as f:
        bank = f.read()

    def at(cpu, size):
        return bank[cpu - 0xA000:cpu - 0xA000 + size]

    # $A29C+4 is the MonthlyEventDispatch table's sub-state 2 =
    # EventReinforceGate. EventDisasterRoute ($A338) advances to it in
    # non-disaster months, and the drought/flood handlers ($A755/$AA06) resume
    # there when their scene ends. EventReinforceGate tests $6F03 (Country) and
    # never $6F01 (month), so the pool is checked every month.
    check('the pool gate is monthly, not a January-only handler',
          at(0xA2A0, 2) == b'\x3C\xA3'
          and at(0xA338, 4) == b'\xEE\x01\x04\x60'
          and at(0xA755, 5) == b'\xA9\x02\x8D\x01\x04'
          and at(0xAA06, 5) == b'\xA9\x02\x8D\x01\x04'
          and b'\xAD\x01\x6F' not in at(0xA33C, 0x27),
          [at(0xA2A0, 2).hex(), at(0xA338, 4).hex(),
           at(0xA755, 5).hex(), at(0xAA06, 5).hex()])
    # @ReinforceScan compares the join year at $AF12, then counts the home
    # Province roster $11-$1A (10 slots): all occupied -> fail with no state
    # change, so the same officer is reconsidered on the next monthly pass.
    check('a full 10-slot home roster defers the join to the next month',
          at(0xAF10, 5) == b'\xB1\x10\xCD\x00\x6F'
          and at(0xAF32, 2) == b'\xC0\x1B'
          and at(0xAF36, 4) == b'\xE0\x0A\xF0\xDF'
          and at(0xAF19, 4) == b'\xA9\x03\x8D\x01',
          [at(0xAF10, 5).hex(), at(0xAF32, 2).hex(),
           at(0xAF36, 4).hex(), at(0xAF19, 4).hex()])
    stale = []
    old = ('auto-arrives each January', 'each January `EventReinforceGate`',
           'runs each January per acting Country')
    for rel in ('editor/README_officer.md', 'docs/officer_reinforcement.md',
                'editor/officer_cli.py', 'tools/officer_model.py',
                'tools/extract_reinforcement_pools.py',
                'tools/gen_data_bank_asm.py',
                'asm/banks/data_11_officer.asm'):
        with open(os.path.join(ROOT, rel), encoding='utf-8') as f:
            text = f.read()
        stale += [(rel, phrase) for phrase in old if phrase in text]
    check('the old January-only wording is gone', not stale, stale)
    bare = model.Model.load(os.path.join(ROOT, 'docs', 'officer_data.csv'))
    check('standalone mode degrades to the plain arrival line',
          not bare.has_preferred
          and '情報集め' not in bare.by_id[0x6D].placement()
          and bare.by_id[0x6D].reinforce_country is None,
          bare.by_id[0x6D].placement())


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--no-gui', dest='no_gui', action='store_true',
                    help='skip the widget pass (section 9)')
    args = ap.parse_args()
    print('officer seed-data pipeline check (banks $30/$31, 237 officers)')
    print('=' * 72)
    test_codec_matches_rom()
    test_name_codec()
    test_csv_lossless()
    test_invariants()
    test_generator()
    test_repo_gate()
    test_front_ends()
    test_standalone()
    test_gui(args)
    test_stratagem_tier()
    test_arrival_provenance()
    print('\n' + '=' * 72)
    if FAILED:
        print('FAILED: %d check(s)\n  - %s' % (len(FAILED),
                                               '\n  - '.join(FAILED)))
        return 1
    print('all checks passed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
