#!/usr/bin/env python3
"""End-to-end checks for the province pipeline: ROM <-> CSVs <-> asm <-> GUI.

The 30 province master records and their katakana names live in bank `$30`
(`rom/prg/prg_10.bin`); `docs/province_data.csv` is the editing surface for
both, and the roster slots are the province half of the cross-bank officer
status gate. This harness proves the whole loop is lossless and that the GUI
drives the same codec.

Run it after touching tools/officer_model.py, tools/gen_data_bank_asm.py,
tools/verify_data_banks.py or editor/province_editor.py:

    python3 tools/check_province_pipeline.py            # make checkprovinces
    python3 tools/check_province_pipeline.py --no-gui   # skip the widget pass

Proves, in order:

  1. the codec rebuilds all 30 stock records and names byte-for-byte from the
     CSVs, and the stock data trips none of the province invariants;
  2. saving the two CSVs back is byte-identical, derived columns included;
  3. every editable field round-trips through its record bytes, out-of-range
     values and non-x100 populations are refused, names re-encode, and the
     model's snapshot/restore covers the province fields;
  4. roster moves keep the cross-bank 状態 == roster set, a refused move
     changes nothing, full rosters and duplicate/ruler conflicts are reported;
  5. the generator agrees with the codec: --from-csv on the stock CSVs
     re-renders the committed bank $10 asm unchanged, and an edited CSV set
     renders the record/name bytes and comments the codec predicts;
  6. the repo's byte gate assembles both seed banks and re-proves the
     cross-bank roster invariant;
  7. the GUI is wired to the codec: an AST audit finds no unresolved
     self.<attr>, its column spec covers every model column, and (with a
     display) every province renders, a widget edit lands in the model and
     undo puts the bytes back;
  8. standalone mode still edits a lone province+officer CSV pair.

Sections 1-6 and 8 need no display; section 7 prints `skipped` without one.
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
import gen_data_bank_asm as gen                  # noqa: E402
import render_ppu_screen as ref_render           # noqa: E402
from bank_asm_names import data_asm_path          # noqa: E402

FAILED = []
CSV_NAMES = ('officer_data.csv', 'province_data.csv',
             'officer_death_years.csv', 'officer_reinforcement.csv')
# Methods inherited from tkinter.Tk / ttk widgets, so they are never assigned
# in the editor source but are still valid `self.<name>` reads.
TK_BASE_API = {
    'title', 'geometry', 'minsize', 'protocol', 'bind', 'bind_all', 'destroy',
    'mainloop', 'wait_window', 'winfo_children', 'winfo_exists',
    'focus_get', 'focus_set', 'focus', 'config', 'configure', 'update',
    'update_idletasks', 'withdraw', 'pack', 'grid', 'place', 'cget', 'set',
    'wait_visibility', 'after', 'after_idle', 'quit', 'transient',
    'grab_set', 'grab_release',
}


def check(label, condition, detail=''):
    """One named assertion; the detail is printed only when it fails."""
    print('  %-66s %s%s' % (label, 'ok' if condition else 'FAIL',
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
    """A temp dir holding the four CSVs, optionally edited through the model."""
    tmp = tempfile.mkdtemp(prefix='province-pipeline-')
    for name in CSV_NAMES:
        shutil.copy(os.path.join(ROOT, 'docs', name), os.path.join(tmp, name))
    if edits:
        m = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                             province_csv=os.path.join(tmp,
                                                       'province_data.csv'))
        edits(m)
        m.save()
    return tmp


def raw_csvs(mutate):
    """A temp CSV set edited as text, for breaks the model refuses to make."""
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
    section('1. codec rebuilds the stock province records and names')
    m = load_stock()
    b10 = bank('prg_10.bin')
    base = model.PROV_RECORD_CPU - model.WINDOW_CPU
    check('all %d records == bank $30 $8C00' % model.PROVINCE_COUNT,
          m.province_record_bytes()
          == b10[base:base + model.PROVINCE_COUNT * model.PROV_RECORD_STRIDE])
    name_base = model.PROV_NAME_CPU - model.WINDOW_CPU
    check('all %d name fields == bank $30 $9A1A' % model.PROVINCE_COUNT,
          m.province_name_bytes()
          == b10[name_base:name_base
                  + model.PROVINCE_COUNT * model.PROV_NAME_STRIDE])
    bad = [p.id for p in m.provinces
           if bytes.fromhex(m.rows['province'][p.id]['hex'])
           != p.record_bytes()]
    check('every CSV hex column is the codec record', not bad, bad)
    province_problems = [p for p in m.problems()
                         if p.startswith('province ')]
    check('the stock data trips no province invariant',
          not province_problems, province_problems[:2])
    check('the stock data has no province edits',
          not m.province_changes())
    check('the name encoder is the inverse of the ROM on all 30 names',
          all(model.encode_province_name(p.katakana)
              == b10[name_base + p.id * model.PROV_NAME_STRIDE:
                     name_base + (p.id + 1) * model.PROV_NAME_STRIDE]
              for p in m.provinces))


# --- 2 the CSV round trip -------------------------------------------------
def test_save_roundtrip():
    section('2. saving the two CSVs back is byte-identical')
    tmp = temp_csvs()
    try:
        before = {}
        for name in ('officer_data.csv', 'province_data.csv'):
            with open(os.path.join(tmp, name), 'rb') as f:
                before[name] = f.read()
        m = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                             province_csv=os.path.join(tmp,
                                                       'province_data.csv'))
        written = m.save()
        check('save writes both CSVs',
              sorted(os.path.basename(p) for p in written)
              == ['officer_data.csv', 'province_data.csv'], written)
        for name in before:
            with open(os.path.join(tmp, name), 'rb') as f:
                after = f.read()
            check('%s is unchanged' % name, after == before[name])
        m = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                             province_csv=os.path.join(tmp,
                                                       'province_data.csv'))
        check('the reloaded model still equals the stock bank',
              m.province_record_bytes()
              == bank('prg_10.bin')[0x0C00:0x0C00 + 30 * 32])
    finally:
        shutil.rmtree(tmp)


# --- 3 field codec -------------------------------------------------------
def test_fields():
    section('3. field edits, ranges, names and snapshot/restore')
    values = {
        'gold': 1234, 'rice': 2345, 'population': 12300,
        'land_value': 123, 'industry': 234, 'disaster_prevention': 12,
        'governance': 34, 'reserve_troops': 3456, 'treasure': 12,
    }
    offsets = {
        'gold': 0x02, 'rice': 0x04, 'population': 0x06, 'land_value': 0x08,
        'disaster_prevention': 0x0A, 'governance': 0x0B,
        'reserve_troops': 0x0C, 'industry': 0x0E, 'treasure': 0x10,
    }
    for key, value in values.items():
        m = load_stock()
        prov = m.province(5)
        old = prov.get(key)
        m.set_province(5, key, value)
        rec = prov.record_bytes()
        ofs = offsets[key]
        stored = (value // 100 if key == 'population' else value)
        got = rec[ofs] if ofs not in (0x02, 0x04, 0x06, 0x08, 0x0C, 0x0E) \
            else rec[ofs] | rec[ofs + 1] << 8
        check('%s $%02X round-trips (was %s)' % (key, ofs, old),
              got == stored, (got, stored))
    m = load_stock()
    m.set_province(5, 'country_id', 3)
    check('country_id writes +00 low nibble',
          m.province(5).record_bytes()[0] == 3)
    m.set_province(5, 'katakana', 'テスト')
    check('a name edit re-encodes $9A1A',
          model.encode_province_name(m.province(5).katakana)
          == bytes.fromhex('1610170000000000'))

    refused = [
        ('gold', 10000), ('rice', 10000), ('land_value', 1000),
        ('industry', 1000), ('disaster_prevention', 100),
        ('governance', 101), ('reserve_troops', 10000), ('treasure', 100),
        ('country_id', 8), ('population', 12350), ('population', 6560000),
        ('katakana', ''), ('katakana', 'アイウエオカキ'),
        ('katakana', '漢字'),
    ]
    for key, value in refused:
        m = load_stock()
        before = m.snapshot()
        try:
            m.set_province(5, key, value)
            check('%s %r is refused' % (key, value), False, 'accepted')
        except (model.FieldError, model.NameEncodeError):
            check('%s %r is refused' % (key, value), True)
        check('  and the model is untouched', m.snapshot() == before)

    # Direct assignment bypasses set_province; problems() must still catch it.
    m = load_stock()
    m.province(5).gold = 10000
    check('an out-of-range direct field is reported',
          any('金' in p and '10000' in p for p in m.problems()),
          m.problems()[:2])
    m = load_stock()
    m.province(5).katakana = '漢字'
    check('an unencodable direct name is reported',
          any('名前' in p for p in m.problems()), m.problems()[:2])

    m = load_stock()
    before = m.snapshot()
    m.set_province(5, 'gold', 1234)
    m.set_province(5, 'katakana', 'テスト')
    m.assign(16, 5, 0)
    check('the change list names both record edits and the roster moves',
          [ch.field for ch in m.province_changes()] == ['katakana', 'gold']
          and [ch.field for ch in m.changes()]
          == ['officer_ids', 'officer_ids'],
          ([ch.field for ch in m.province_changes()],
           [ch.field for ch in m.changes()]))
    m.restore(before)
    check('snapshot/restore walks the mixed edit back',
          m.snapshot() == before and not m.province_changes()
          and not m.changes())


# --- 4 rosters and the cross-bank invariant ------------------------------
def test_rosters():
    section('4. roster edits keep the 状態 == roster set')
    m = load_stock()
    before = m.snapshot()
    m.assign(16, 5, 0)
    check('assign puts the officer in slot +$11',
          m.province(5).roster == [16]
          and m.province(5).record_bytes()[model.ROSTER_START] == 16)
    check('  the source province loses him',
          16 not in m.province(26).roster)
    check('  his 状態 becomes 2', m.officer(16).officer_status_bits == 2)
    check('  the cross-bank sets still match',
          m.roster_map().keys() == {o.id for o in m.officers
                                    if o.officer_status_bits == 2})
    check('  no problem appears', not m.problems(), m.problems()[:2])
    m.assign(17, 5)
    m.move_slot(17, 0)
    check('move_slot reorders the roster',
          m.province(5).roster == [17, 16])
    m.move_slot(16, 0)
    check('the 太守 is whatever sits in slot 0',
          m.province(5).governor == 16)
    m.unassign(16)
    check('unassign makes him 状態 1 and compacts',
          m.officer(16).officer_status_bits == 1
          and m.province(5).roster == [17])
    m.restore(before)
    check('restore puts the stock rosters back',
          m.province(5).roster == [] and m.province(26).roster == [220, 16, 70, 209]
          and m.officer(16).officer_status_bits == 2)

    m = load_stock()
    before = m.snapshot()
    for bad in ('nonsense', model.ROSTER_SLOTS, -1):
        try:
            m.assign(16, 5, bad)
            check('slot %r is refused' % (bad,), False, 'accepted')
        except model.FieldError:
            check('slot %r is refused' % (bad,), True)
        check('  and a refused assign changes nothing',
              m.snapshot() == before)

    m = load_stock()
    hidden = [o for o in m.officers if o.is_hidden][:10]
    for off in hidden:
        m.assign(off.id, 0)
    check('a province can hold 10 officers', len(m.province(0).roster) == 10)
    before = m.snapshot()
    eleventh = [o for o in m.officers if o.is_hidden
                and o.id not in m.province(0).roster][0]
    try:
        m.assign(eleventh.id, 0)
        check('an 11th officer is refused', False, 'accepted')
    except model.FieldError:
        check('an 11th officer is refused', True)
    check('  and the full roster is unchanged', m.snapshot() == before)
    # Moving an officer into a full province must fail before unassigning him,
    # or he would leave his old roster and join none.
    try:
        m.assign(16, 0)
        check('moving into a full province is refused', False, 'accepted')
    except model.FieldError:
        check('moving into a full province is refused', True)
    check('  and his old province still holds him',
          m.snapshot() == before and 16 in m.province(26).roster)

    m = load_stock()
    m.province(4).roster.append(m.province(4).roster[0])
    check('a duplicated roster slot is reported',
          any('twice' in p for p in m.problems()), m.problems()[:2])
    m = load_stock()
    other_ruler = [o for o in m.officers
                   if o.is_ruler and o.id != m.province(4).roster[0]][0]
    m.province(4).roster.append(other_ruler.id)
    check('two 忠誠度-100 rulers in one province are reported',
          any('only one can be the 君主 ruler' in p for p in m.problems()),
          m.problems()[:3])


# --- 5 the generator agrees with the codec ------------------------------
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


def test_generator():
    section('5. gen_data_bank_asm.py --from-csv agrees with the codec')
    for flag in (False, True):
        with contextlib.redirect_stderr(io.StringIO()):
            lines, _ = render(0x10, flag)
        with open(data_asm_path(0x10, ROOT), encoding='utf-8') as f:
            committed = f.read()
        check('bank $10 %s re-renders the committed asm'
              % ('--from-csv' if flag else 'the ROM path'),
              '\n'.join(lines) + '\n' == committed)

    def edits(m):
        m.set_province(5, 'katakana', 'テスト')
        m.set_province(5, 'gold', 1234)
        m.set_province(5, 'country_id', 3)
        m.set_province(5, 'population', 12300)
        m.assign(16, 5, 0)

    tmp = temp_csvs(edits)
    try:
        edited = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                                  province_csv=os.path.join(
                                      tmp, 'province_data.csv'))
        with contextlib.redirect_stderr(io.StringIO()):
            lines, ctx = render(0x10, True, tmp)
        by_id = {r['id']: r for r in ctx['provinces']}
        check('the generator renders the codec record bytes',
              all(by_id[p.id]['record'] == p.record_bytes()
                  for p in edited.provinces))
        check('the generator renders the codec name bytes',
              all(by_id[p.id]['name_bytes']
                  == model.encode_province_name(p.katakana)
                  for p in edited.provinces))
        stock = bank('prg_10.bin')
        check('the renamed province is re-encoded, not copied from the ROM',
              by_id[5]['name_bytes']
              == model.encode_province_name('テスト')
              != stock[0x1A1A + 5 * 8:0x1A1A + 6 * 8])
        text = '\n'.join(lines)
        check('the rendered comment follows the edited name and gold',
              'テスト' in text and '金=1234' in text, text[:200])
        check('the rendered comment says the roster moved',
              by_id[5]['officer_count'] == 1
              and by_id[5]['ruler_officer_id'] is None)
    finally:
        shutil.rmtree(tmp)

    def blank_name(rows):
        rows[0]['katakana'] = ''

    tmp = raw_csvs({'province_data.csv': blank_name})
    try:
        with contextlib.redirect_stderr(io.StringIO()):
            render(0x10, True, tmp)
        check('an emptied CSV name stops the render', False, 'it rendered')
    except SystemExit as exc:
        check('an emptied CSV name stops the render',
              'province 0' in str(exc), exc)
    finally:
        shutil.rmtree(tmp)

    def long_name(rows):
        rows[0]['katakana'] = 'アイウエオカキ'

    tmp = raw_csvs({'province_data.csv': long_name})
    try:
        with contextlib.redirect_stderr(io.StringIO()):
            render(0x10, True, tmp)
        check('a seven-glyph name stops the render', False, 'it rendered')
    except SystemExit as exc:
        check('a seven-glyph name stops the render',
              'province 0' in str(exc), exc)
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
    check('both banks assemble byte-exact', out.count('byte-exact') == 2)
    check('the cross-bank 状態 == roster set is re-proved',
          'cross-bank' in out)
    r = subprocess.run([sys.executable, 'tools/verify_data_banks.py',
                        '--dump-csv'], cwd=ROOT, capture_output=True, text=True)
    check('--dump-csv decodes the asm back to a CSV', r.returncode == 0,
          ' '.join((r.stdout + r.stderr).split())[:200])
    if r.returncode == 0:
        path = os.path.join(ROOT, 'build', 'province_from_asm.csv')
        with open(path, newline='', encoding='utf-8') as f:
            rows = {int(row['id']): row for row in csv.DictReader(f)}
        m = load_stock()
        check('the asm-decoded records equal the codec records',
              all(rows[p.id]['hex'].upper() == p.record_bytes().hex().upper()
                  for p in m.provinces), len(rows))


# --- 7 the GUI -----------------------------------------------------------
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
    check('%s has no unresolved self attribute' % label, not missing, missing)


def test_gui():
    section('7. the GUI drives the same codec')
    sys.path.insert(0, os.path.join(ROOT, 'editor'))
    import province_editor as gui
    audit_attributes(os.path.join(ROOT, 'editor', 'province_editor.py'),
                     'province_editor.py')
    check('every model column has a GUI width',
          set(gui.COLUMN_WIDTHS) == {k for k, _, _ in
                                     model.PROVINCE_COLUMNS},
          set(gui.COLUMN_WIDTHS) ^ {k for k, _, _ in
                                    model.PROVINCE_COLUMNS})
    check('the model column spec has a heading and alignment for every key',
          all(heading and align in ('w', 'e', 'center')
              for _, heading, align in model.PROVINCE_COLUMNS))
    try:
        app = gui.ProvinceEditor(
            model, repo=ROOT,
            officer_csv=os.path.join(ROOT, 'docs', 'officer_data.csv'),
            province_csv=os.path.join(ROOT, 'docs', 'province_data.csv'))
    except Exception as exc:                          # noqa: BLE001
        print('  widget pass                                                    '
              'skipped (%s)' % str(exc).splitlines()[0])
        return
    try:
        app.withdraw()
        app.update_idletasks()
        errors = []
        for prov in app.model.provinces:
            try:
                app.tree.selection_set(str(prov.id))
                app._on_select()
                if not app.head_var.get().startswith(str(prov.id)):
                    errors.append('%d: head %r' % (prov.id, app.head_var.get()))
                if len(app.tree.item(str(prov.id), 'values')) \
                        != len(model.PROVINCE_COLUMNS):
                    errors.append('%d: column count' % prov.id)
            except Exception as exc:                  # noqa: BLE001
                errors.append('%d: %s' % (prov.id, exc))
        check('every province renders in the detail pane', not errors,
              errors[:2])

        app.tree.selection_set('4')
        app._on_select()
        app.w['gold'].delete(0, 'end')
        app.w['gold'].insert(0, '275')
        app._commit('gold')
        check('a widget edit lands in the model and the table',
              app.model.province(4).gold == 275
              and app.tree.item('4', 'values')[4] == '275')
        app.undo_edit()
        check('  undo restores the stock gold',
              app.model.province(4).gold == 270
              and not app.model.province_changes())

        app.w['katakana'].delete(0, 'end')
        app.w['katakana'].insert(0, 'テスト')
        app._commit('katakana')
        check('a name edit lands in the model',
              app.model.province(4).katakana == 'テスト'
              and app.tree.item('4', 'values')[1] == 'テスト')
        app.undo_edit()
        check('  undo restores the stock name',
              app.model.province(4).katakana == 'キシュウ')

        app.roster_tree.selection_set('1')
        app.remove_officer()
        check('a roster remove lands in both CSVs\' model',
              app.model.province(4).roster == [8, 191, 167]
              and app.model.officer(51).officer_status_bits == 1)
        app.undo_edit()
        check('  undo restores the roster and 状態',
              app.model.province(4).roster == [8, 51, 191, 167]
              and app.model.officer(51).officer_status_bits == 2)

        app.filter_var.set('冀州')
        check('the filter selects exactly the named province',
              list(app.tree.get_children()) == ['4'],
              app.tree.get_children())
        app.filter_var.set('')

        import tkinter.font as tkfont
        row_h = int(gui.ttk.Style(app).lookup('Province.Treeview',
                                              'rowheight'))
        need = max(tkfont.nametofont(name).metrics('linespace')
                   for name in ('TkTextFont', 'TkDefaultFont',
                                'TkHeadingFont')) + gui.ROW_PAD
        check('the table row height covers the fonts it renders',
              row_h >= need, (row_h, need))
        font = tkfont.nametofont('TkTextFont')
        unit = font.measure('0')
        widest = max(font.measure(str(v))
                     for v in app.w['country_id'].cget('values'))
        check('the Country dropdown fits its longest value',
              int(app.w['country_id'].cget('width')) >= widest // unit + 2,
              (app.w['country_id'].cget('width'), widest // unit + 2))
        app._on_detail_configure(_Event(gui.DETAIL_W))
        widest_widget = max(c.winfo_reqwidth()
                            for c in app.detail.winfo_children())
        check('the widest detail widget fits the default pane',
              widest_widget <= gui.DETAIL_W,
              '%d px of content in a %d px pane' % (widest_widget,
                                                    gui.DETAIL_W))
        report = app.report.get('1.0', 'end')
        check('the report says the stock data has no problems',
              'no problems' in report, report[:120])

        # The selector is list + in-game map; the detail pane is record /
        # town / tactical - the map is a selector, not province info.
        check('the selector is a two-tab notebook (list + game map)',
              len(app.selector.tabs()) == 2, app.selector.tabs())
        check('the detail pane is a three-tab notebook',
              len(app.notebook.tabs()) == 3, app.notebook.tabs())
        app.tree.selection_set('4')
        app._on_select()
        app.update_idletasks()
        check('the Town tab decodes 冀州 (town type 9, four facilities)',
              'town type 9' in app.town_head_var.get()
              and '武器屋' in app.town_head_var.get()
              and '学問所' in app.town_head_var.get()
              and '病院' in app.town_head_var.get()
              and '商店' in app.town_head_var.get(),
              app.town_head_var.get())
        check('  and the market rates match the ROM bytes',
              'sell 96' in app.market_var.get()
              and 'buy 79' in app.market_var.get(),
              app.market_var.get())
        check('  and the armory grid shows 16 cells',
              len(app.stock_tree.get_children()) == 16,
              len(app.stock_tree.get_children()))
        check('the strategy map renders the authored band at 3x',
              app._map_photo.width() == 256 * gui.MAP_SCALE
              and app._map_photo.height()
              == gui.MAP_ROWS * 8 * gui.MAP_SCALE,
              (app._map_photo.width(), app._map_photo.height()))
        check('  and the map page lives in the selector, not the detail pane',
              app.nametowidget(app.selector.tabs()[1])
              is app.map_canvas.master,
              (app.selector.tabs(), str(app.map_canvas.master)))
        map_page = app.nametowidget(app.selector.tabs()[1])
        check('  and the map page fits the default selector width',
              map_page.winfo_reqwidth() <= 1440 - gui.DETAIL_W - 40,
              map_page.winfo_reqwidth())
        check('  using display record 0 and palette record 0',
              app.data['map_display'][:8] == bytes(
                  (0x04, 0x04, 0x04, 0x04, 0x00, 0x01, 0x02, 0x10))
              and app.data['palette0'][:4] == bytes(
                  (0x0F, 0x12, 0x1A, 0x2A)),
              (app.data['map_display'][:8], app.data['palette0'][:4]))
        countries = tuple(p.country_id for p in app.model.provinces)
        reference = ref_render.render(
            app.data['map_screen'][:960], app.data['map_screen'][960:1024],
            list(app.data['map_display'][4:8]), 1, app.data['palette0'])
        own = gui.strategy_map_pixels(app.data, countries, scale=1)
        covered = set()
        for pid in range(30):
            for sy in range(8):
                for sx in range(8):
                    covered.add((app.data['zone_y'][pid] + sy,
                                 app.data['zone_x'][pid] + sx))
        mismatch = [(x, y) for y in range(gui.MAP_ROWS * 8)
                    for x in range(256)
                    if (y, x) not in covered
                    and own[y][x] != reference[y][x]]
        check('  and its background matches the map band of '
              'render_ppu_screen', not mismatch, mismatch[:4])
        check('  and every province centre resolves to its own zone',
              [pid for pid in range(30)
               if app._map_hit(*app._map_zone_centre(pid)) == pid]
              == list(range(30)),
              [pid for pid in range(30)
               if app._map_hit(*app._map_zone_centre(pid)) != pid])
        hover = type('E', (), {})()
        hover.x = (app.data['zone_x'][7] + 8) * gui.MAP_SCALE
        hover.y = (app.data['zone_y'][7] + 8) * gui.MAP_SCALE
        app._on_map_motion(hover)
        check('  and hovering a zone previews it',
              app._map_hover == 7
              and len(app.map_canvas.find_withtag('hover')) == 2,
              (app._map_hover,
               len(app.map_canvas.find_withtag('hover'))))
        app._on_map_leave()
        check('  and leaving the map clears the preview',
              app._map_hover is None
              and not app.map_canvas.find_withtag('hover'), app._map_hover)
        pal = app.data['palette0']
        marker_ok, marker_checked = True, 0
        for pid in range(30):
            kind = app.model.province(pid).country_id & 7
            tile = app.data['marker_tiles'][kind]
            attr = app.data['marker_attrs'][kind] & 3
            bmp = gui.chr_tile(app.data['chr_dir'],
                               app.data['map_display'][0], tile)
            for sy in range(8):
                for sx in range(8):
                    ci = bmp[sy][sx]
                    if not ci:
                        continue
                    wx = app.data['zone_x'][pid] + sx
                    wy = app.data['zone_y'][pid] + sy
                    want = gui.NES_RGB[pal[16 + 4 * attr + ci] & 0x3F]
                    marker_checked += 1
                    marker_ok &= app._map_rows[wy * gui.MAP_SCALE][
                        wx * gui.MAP_SCALE] == want
        check('  and the game province marker sprites are drawn',
              marker_ok and marker_checked >= 30, marker_checked)
        before_key = app._map_photo_key
        old_country = app.model.province(4).country_id
        app.model.set_province(4, 'country_id', (old_country + 1) & 7)
        app._refresh_all()
        check('  and a Country edit repaints the marker sprites',
              app._map_photo_key == before_key[:4]
              + ((old_country + 1) & 7,) + before_key[5:],
              (before_key[4], app._map_photo_key[4]))
        app.model.set_province(4, 'country_id', old_country)
        app._refresh_all()
        check('  and the info pane names the 冀州 neighbours',
              '5 neighbours' in app.map_info_var.get()
              and '并州' in app.map_info_var.get(),
              app.map_info_var.get()[:120])
        click = type('E', (), {})()
        cx, cy = app._map_zone_centre(12)
        click.x, click.y = cx * gui.MAP_SCALE, cy * gui.MAP_SCALE
        app._on_map_click(click)
        check('  and clicking a province zone selects that province',
              app.current.id == 12, app.current.id)
        app.tree.selection_set('8')
        app._on_select()
        click.x = click.y = 0
        app._on_map_click(click)
        check('  and a click outside every zone leaves the selection alone',
              app.current.id == 8, app.current.id)
        app.tree.selection_set('4')
        app._on_select()
        check('the tactical map draws the 32x20 terrain grid',
              len(app.tac_canvas.find_all()) >= 640,
              len(app.tac_canvas.find_all()))
        # 冀州 towns: $9BA4 raw (04,03) (1D,12) (16,06) and $9D58 (X=20,Y=224).
        check('  and the marker tables give the buildings it draws',
              app.data['castle_cells'][4] == (20, 14)
              and app.data['facility_tiles'][4] == [(4, 3), (29, 17), (22, 6)],
              '%s %s' % (app.data['castle_cells'][4],
                         app.data['facility_tiles'][4]))
        all_items = len(app.tac_canvas.find_all())
        legend = app.tac_legend_var.get()
        check('  and the legend lists both attack routes with their approaches',
              '2 attack route(s), 1 defense variant(s)' in legend
              and 'atk 0 ← 2 并州, 3 青州, 1 幽州' in legend
              and 'atk 1 ← 12 洛阳, 11 兖州' in legend,
              legend[:200])
        app.atk_type_box.set('1')
        app._draw_tactical_map()
        check('  and isolating one attack route draws fewer cells',
              len(app.tac_canvas.find_all()) < all_items
              and 'atk 1 ← 12 洛阳, 11 兖州' in app.tac_legend_var.get(),
              (all_items, len(app.tac_canvas.find_all())))
        app.atk_type_box.set('all')
        app._draw_tactical_map()
        app.tree.selection_set('4')
        app._on_select()

        # Arrival officers: the pane renders the model's schedule blocks.
        hidden = [o for o in app.model.officers
                  if o.is_hidden and o.appear_year is None][0]
        app.arrival_year.set('195')
        app.model.set_schedule(hidden.id, 4, 195)
        app._refresh_after_roster()
        check('an added arrival entry renders in the province pane',
              str(hidden.id) in app.arrival_tree.get_children(),
              app.arrival_tree.get_children())
        app.model.clear_schedule(hidden.id)
        app._refresh_after_roster()
        check('  and a removed one disappears',
              str(hidden.id) not in app.arrival_tree.get_children()
              and not app.model.changes())
        app.destroy()
    finally:
        try:
            app.destroy()
        except Exception:                             # noqa: BLE001
            pass


# --- 8 standalone --------------------------------------------------------
def test_standalone():
    section('8. standalone mode edits a lone province+officer CSV pair')
    tmp = tempfile.mkdtemp(prefix='province-standalone-')
    try:
        for name in ('officer_data.csv', 'province_data.csv'):
            shutil.copy(os.path.join(ROOT, 'docs', name),
                        os.path.join(tmp, name))
        m = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                             province_csv=os.path.join(tmp,
                                                       'province_data.csv'))
        check('the pair loads without the death/reinforce CSVs',
              m.has_rosters and not m.has_deaths and not m.has_reinforce)
        m.set_province(5, 'gold', 321)
        m.assign(16, 5, 0)
        m.save()
        m = model.Model.load(os.path.join(tmp, 'officer_data.csv'),
                             province_csv=os.path.join(tmp,
                                                       'province_data.csv'))
        check('an edit survives a standalone save',
              m.province(5).gold == 321
              and m.province(5).roster == [16]
              and m.officer(16).officer_status_bits == 2)
        check('the standalone model still has no problems',
              not [p for p in m.problems() if p.startswith('province ')],
              m.problems()[:2])
    finally:
        shutil.rmtree(tmp)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--no-gui', action='store_true',
                    help='skip the widget pass')
    args = ap.parse_args()
    test_codec_matches_rom()
    test_save_roundtrip()
    test_fields()
    test_rosters()
    test_generator()
    test_repo_gate()
    if args.no_gui:
        print('\n7. the GUI drives the same codec')
        print('  widget pass                                                    '
              'skipped (--no-gui)')
    else:
        test_gui()
    test_standalone()
    print('\n' + '=' * 72)
    if FAILED:
        print('%d check(s) failed:' % len(FAILED))
        for label in FAILED:
            print('  - %s' % label)
        return 1
    print('all checks passed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
