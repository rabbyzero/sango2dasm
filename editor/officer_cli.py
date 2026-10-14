#!/usr/bin/env python3
"""Headless officer editor - the CLI twin of editor/officer_editor.py.

Same codec (`tools/officer_model.py`), same CSV twins, same repo pipeline, no
display needed - so the officer seed data can be inspected, edited and gated
from a shell or a script:

    docs/officer_data.csv          records + katakana names + arrival schedule
    docs/officer_death_years.csv   the bank $31 $9C58 natural-death table
    docs/province_data.csv         the province roster slots (+$11 is the 太守)

Commands
--------
    list                 the officer table, with the GUI's filters and sorting
    show ID              every byte of one officer, decoded
    fields               the editable field keys, kinds and ranges
    set ID K=V ...       edit record fields (numbers accept $hex / 0xhex)
    schedule ID P Y      set an arrival entry;  schedule ID --clear  drops it
    roster add|remove|governor ID [PROVINCE] [--slot N]
    check                the invariant report; exit 1 on any problem
    diff PATH            field-level diff against another set of CSVs
    write-asm            save, re-render asm/banks/data_10_seed.asm + data_11_officer.asm,
                         then report the decoded edits (repo only)
    verify               run tools/verify_data_banks.py --allow-edits

Editing is a dry run unless `--write` is given, mirroring
`tools/gen_data_bank_asm.py` (which prints unless told to write). A `--write`
that would leave a hard invariant broken is refused; `--force` overrides, e.g.
to stage a half-finished edit and let `tools/verify_data_banks.py` describe it.

Examples
--------
    python3 editor/officer_cli.py list --status rostered --sort might --reverse
    python3 editor/officer_cli.py list --filter 張 --brief
    python3 editor/officer_cli.py show 218
    python3 editor/officer_cli.py set 218 might=100 weapon_index=$15 --write
    python3 editor/officer_cli.py roster remove 16 --write
    python3 editor/officer_cli.py roster add 16 5 --slot 0 --write
    python3 editor/officer_cli.py schedule 3 7 201 --write
    python3 editor/officer_cli.py check
    python3 editor/officer_cli.py diff /tmp/pristine/officer_data.csv
    python3 editor/officer_cli.py write-asm

Exit codes: 0 clean, 1 invariant problems or a refused edit, 2 bad usage.

Outside the repo, pass the CSVs and the codec explicitly; `write-asm` and
`verify` then say that the generator lives in the disassembly checkout:

    python3 editor/officer_cli.py list --model . --csv officer_data.csv
"""
import argparse
import os
import subprocess
import sys
import unicodedata

MAX_DIFF_LINES = 400


# --- codec import (same search order as editor/officer_editor.py) --------
def load_model(cli_path=None):
    """Import officer_model from --model, beside this script, or the repo.

    Both front-ends carry this bootstrap because it has to run before the codec
    is importable - there is nowhere shared to put it.
    """
    here = os.path.dirname(os.path.abspath(__file__))
    repo = os.path.dirname(here)
    directories = []
    if cli_path:
        directories.append(cli_path if os.path.isdir(cli_path)
                           else os.path.dirname(os.path.abspath(cli_path)))
    directories += [here, os.path.join(repo, 'tools')]
    for directory in directories:
        candidate = os.path.join(directory, 'officer_model.py')
        if os.path.exists(candidate):
            if directory not in sys.path:
                sys.path.insert(0, directory)
            import officer_model
            return officer_model, directory
    raise SystemExit(
        'officer_model.py not found (looked in: %s).\n'
        'Pass --model PATH, drop a copy next to this script, or keep it inside\n'
        'the sango2dasm repo where tools/officer_model.py lives.'
        % ', '.join(directories))


# --- text helpers --------------------------------------------------------
def text_width(text):
    """Columns a string takes in a terminal (CJK counts double)."""
    return sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1
               for c in str(text))


def pad(text, width, align='w'):
    text = str(text)
    gap = max(0, width - text_width(text))
    if align == 'e':
        return ' ' * gap + text
    if align == 'center':
        return ' ' * (gap // 2) + text + ' ' * (gap - gap // 2)
    return text + ' ' * gap


def print_table(headers, rows, aligns):
    """Print rows under headers, widths measured from the content."""
    widths = [text_width(h) for h in headers]
    for row in rows:
        for i, cell in enumerate(row):
            widths[i] = max(widths[i], text_width(cell))
    print('  '.join(pad(h, widths[i], aligns[i])
                    for i, h in enumerate(headers)).rstrip())
    print('  '.join('-' * w for w in widths).rstrip())
    for row in rows:
        print('  '.join(pad(cell, widths[i], aligns[i])
                        for i, cell in enumerate(row)).rstrip())


def die(message, code=1):
    print('error: %s' % message, file=sys.stderr)
    raise SystemExit(code)


# --- commands ------------------------------------------------------------
HEADINGS = None            # filled in main(): column key -> heading text


def cmd_list(m, model, args):
    status = m.status_filter(args.status)
    if status is None:
        die('--status must be one of: all, hidden, rostered, rulers, '
            'unscheduled (or the full label: %s)'
            % ' | '.join(m.STATUS_FILTERS), 2)
    keys = tuple(key for key, _, _ in m.COLUMNS)
    if args.sort not in keys and args.sort not in m.FIELD_BY_KEY:
        die('--sort must be a list column (%s) or an editable field (%s)'
            % (', '.join(keys), ', '.join(m.EDITABLE)), 2)
    officers = m.visible(model, args.filter or '', args.province, status)
    officers = m.sort(model, officers, args.sort, args.reverse)
    if args.problems_only:
        bad = model.problem_ids()
        officers = [o for o in officers if o.id in bad]
    if args.limit:
        officers = officers[:args.limit]
    if args.brief:
        keys = ('id', 'katakana', 'zh_hans', 'might', 'intelligence',
                'officer_level', 'officer_status', 'placement')
    aligns = {key: align for key, _, align in m.COLUMNS}
    headers = [HEADINGS[key] for key in keys]
    rows = [[m.cell_text(model, o, key) for key in keys] for o in officers]
    print_table(headers, rows, [aligns[key] for key in keys])
    print('\n%d of %d officers' % (len(officers), len(model.officers)))
    return 0


def _record_line(prefix, jp, en, value, note='', align='e'):
    """One annotated line of the record dump, columns aligned on display width."""
    return '  %s  %s%s%s%s' % (
        pad(prefix, 12), pad(jp, 10), pad(en, 17), pad(value, 6, align),
        '   %s' % note if note else '')


def cmd_show(m, model, args):
    off = _officer(m, model, args.id)
    name = '  '.join(x for x in (off.katakana, off.zh_hans, off.kanji_ja,
                                 off.pinyin) if x)
    print('officer %d  %s%s' % (off.id, name,
                                '   [%s]' % off.label if off.label else ''))
    rec = off.record()
    fields = off.fields()
    print('  record  $%04X  %s' % (off.record_cpu(),
                                   ' '.join('%02X' % b for b in rec)))
    print('  SRAM    $%04X  (id * %d + $%04X)'
          % (off.sram_addr(), m.RECORD_STRIDE, m.SRAM_RECORD_BASE))
    for offset, key in ((0, 'vitality'), (1, 'might'), (2, 'intelligence'),
                        (3, 'loyalty'), (4, 'virtue')):
        spec = m.FIELD_BY_KEY[key]
        note = '100 = a playable 君主 ruler' \
            if key == 'loyalty' and off.is_ruler else ''
        print(_record_line('+%02X $%02X' % (offset, rec[offset]), spec.jp,
                           spec.en, fields[key], note))
    print(_record_line('+05 $%02X' % rec[5], '位置', 'LocationProvince', 0,
                       'runtime-only, 0 in the seed'))
    print(_record_line('+06 $%02X $%02X' % (rec[6], rec[7]), '経験値',
                       'Experience', fields['experience']))
    print(_record_line('+08 $%02X $%02X' % (rec[8], rec[9]), '兵数',
                       'TroopCount', fields['troop_count']))
    print(_record_line('+0A $%02X' % rec[10], '武器/防具', 'Weapon / Armor',
                       '%d/%d' % (fields['weapon_index'],
                                  fields['armor_index']),
                       '%s / %s' % (off.weapon, off.armor), 'w'))
    print(_record_line('+0B $%02X' % rec[11], 'レベル他', 'Lvl|Affinity|Status',
                       '$%02X' % rec[11],
                       'level %d (stored %d) | %s軍 %sArmy | 状態 %d %s'
                       % (fields['officer_level'], fields['officer_level'] - 1,
                          off.army_affinity,
                          m.AFFINITY_EN.get(off.army_affinity_bits, '?'),
                          off.officer_status_bits, off.officer_status), 'w'))
    print('  name    $%04X  %s   %s'
          % (off.name_cpu(), ' '.join('%02X' % b for b in off.name_bytes()),
             off.katakana))
    print('  placement  %s' % off.placement())
    if off.roster_province is not None:
        prov = model.province(off.roster_province)
        print('  province %d %s %s roster: %s'
              % (prov.id, prov.katakana, prov.zh_hans,
                 ' '.join('%d%s' % (oid, '*' if i == 0 else '')
                          for i, oid in enumerate(prov.roster))))
        if prov.roster:
            print('             (* = slot +$11, the 太守 governor)')
    if off.appear_year is not None and off.schedule_province_id is not None:
        print('  arrival block province %d: %s'
              % (off.schedule_province_id, ' '.join(
                  '%d@%d' % pair
                  for pair in model.schedule_blocks()[off.schedule_province_id])))
    elif off.appear_year is not None or off.schedule_province_id is not None:
        print('  arrival entry half filled (province %s, year %s) - the '
              'renderer drops it'
              % (off.schedule_province_id, off.appear_year))
    pool = model.reinforce_entry(off.id)
    if pool:
        print('  reinforcement pool: joins Country %d in %d (bank $31 $8D74 - '
              'each January the Country inducts the first still-hidden heir '
              'whose year has arrived)'
              % pool)
    if model.has_heirs:
        hits = model.heir_successor_lists(off.id)
        if hits:
            print('  AI successor priority: %s (first listed officer governing '
                  'one of the Country\'s provinces takes it on ruler death)'
                  % '; '.join('Country %d #%d of %d' % (c, pos + 1, len(ids))
                              for c, pos, ids in hits))
    if off.death_year is None:
        print('  death year  (death-year CSV not loaded)')
    else:
        print('  death year  %d  (bank $31 $%04X byte $%02X = year - %d)'
              % (off.death_year, m.DEATH_CPU + off.id, off.death_byte(),
                 m.DEATH_YEAR_OFFSET))
    if model.has_portraits:
        if off.portrait_chr is None:
            print('  portrait  page $%02X  (rom/chr/chr_%02x.bin not found, so '
                  'the shapes cannot be shown)'
                  % (off.portrait_page, off.portrait_page // 8))
        else:
            art = off.portrait_pixels(0)
            if art is None:
                print('  portrait  page $%02X  (no rom/chr beside the CSVs, so '
                      'the shapes cannot be shown)' % off.portrait_page)
            else:
                w, rows = art
                tones = sorted({v for row in rows for v in row if v},
                               key=lambda rgb: sum(rgb))
                char = {0: ' '}
                for i, rgb in enumerate(tones):
                    char[rgb] = ' .o@#%'[min(i, 5)]
                print('  portrait  $CED6[%d] -> page $%02X  (normal; angry/sad/'
                      'happy are the same card with a different face, see the '
                      'GUI)' % (off.id, off.portrait_page))
                for row in rows:
                    print('   |%s|' % ''.join(char[v] for v in row))
    pixels = off.plate_pixels()
    if off.glyph and not pixels:
        print('  kanji plate $%04X  (no rom/chr beside the CSVs, so the glyph '
              'shapes cannot be shown)' % off.glyph_cpu())
    for kanji in pixels:
        for row in kanji:
            print('   |%s|' % ''.join(' .o@'[v] for v in row))
    if off.glyph:
        quads = off.glyph_kanji()
        print('  kanji plate $%04X  page $%02X  %d kanji  %s'
              % (off.glyph_cpu(), off.glyph_page, len(quads),
                 ' / '.join(' '.join('%02X' % t for t in q) for q in quads)))
        print('              read-only authored CHR data - a rename does not '
              're-derive it')
    problems = [p for p in model.problems()
                if p.startswith('officer %d ' % off.id)]
    for line in problems:
        print('  FAIL: %s' % line)
    return 1 if problems else 0


def cmd_fields(m, model, args):
    rows = []
    for spec in m.FIELDS:
        if spec.kind == 'choice':
            span = 'one of: ' + ', '.join(str(code) for code, _ in spec.choices)
        elif spec.kind == 'text':
            span = 'kana, max %d codes + $00' % m.NAME_MAX_CODES
        elif spec.kind == 'province':
            span = '0-%d, or blank' % (m.PROVINCE_COUNT - 1)
        else:
            span = '%s-%s%s' % (spec.lo, spec.hi,
                                ', or blank' if spec.nullable else '')
        rows.append([spec.key, spec.jp, spec.en, spec.group, span])
    print_table(('key', '日本語', 'English', 'group', 'accepted values'), rows,
                ('w', 'w', 'w', 'w', 'w'))
    print('\nset them with: officer_cli.py set ID key=value [key=value ...]')
    print('`set` also takes 状態 and the two arrival columns, but only for the')
    print('edits that cannot break the cross-bank gate: rostering goes through')
    print('`roster` (状態 2 must equal a province roster slot) and a whole')
    print('arrival entry through `schedule` (the renderer drops a half-filled')
    print('pair). The rest are refused with the command to use instead.')
    return 0


def cmd_set(m, model, args):
    off = _officer(m, model, args.id)
    if not args.assignments:
        die('nothing to set: give key=value pairs (see `fields`)', 2)
    snapshot = model.snapshot()
    for assignment in args.assignments:
        if '=' not in assignment:
            die('%r is not a key=value pair' % assignment, 2)
        key, value = assignment.split('=', 1)
        try:
            model.set(off.id, key.strip(), value.strip())
        except m.OfficerError as exc:
            die(str(exc))
    return _finish(model, args, snapshot, 'officer %d' % off.id)


def cmd_schedule(m, model, args):
    off = _officer(m, model, args.id)
    snapshot = model.snapshot()
    try:
        if args.clear:
            model.clear_schedule(off.id)
        else:
            if args.province is None or args.year is None:
                die('schedule needs PROVINCE and YEAR (or --clear)', 2)
            model.set_schedule(off.id, args.province, args.year)
    except m.OfficerError as exc:
        die(str(exc))
    return _finish(model, args, snapshot, 'officer %d arrival' % off.id)


def cmd_roster(m, model, args):
    off = _officer(m, model, args.id)
    snapshot = model.snapshot()
    try:
        if args.action == 'add':
            if args.province is None:
                die('roster add needs a PROVINCE', 2)
            model.assign(off.id, args.province, args.slot)
        elif args.action == 'remove':
            model.unassign(off.id)
        else:
            model.move_slot(off.id, 0)
    except m.OfficerError as exc:
        die(str(exc))
    return _finish(model, args, snapshot, 'officer %d roster' % off.id)


def cmd_reinforce(m, model, args):
    """Change one heir's reinforcement join year (bank $31 $8D74 pools)."""
    off = _officer(m, model, args.id)
    snapshot = model.snapshot()
    try:
        model.set_reinforce_year(off.id, args.year)
    except m.OfficerError as exc:
        die(str(exc))
    return _finish(model, args, snapshot, 'officer %d reinforcement' % off.id)


def cmd_heirs(m, model, args):
    """The AI ruler successor priority lists, all seven countries."""
    if not model.has_heirs:
        print('heir priority lists not loaded (pass --repo, or keep '
              'rom/prg/prg_0b.bin beside the CSVs)')
        return 0
    print('AI ruler successor priority (prg_0b $CAD8, AppointSuccessor $CA68)')
    for line in model.heir_priority_lines():
        print('  %s' % line)
    print('  on ruler death the first listed officer governing one of the '
          'country\'s provinces (slot $11, the 太守) takes the country;')
    print('  if none qualifies the AI installs the governor with the highest '
          '人徳 Virtue. Read-only authored data.')
    return 0


def cmd_check(m, model, args):
    problems, notes = model.report()
    for line in problems:
        print('FAIL: %s' % line)
    for line in notes:
        print('note: %s' % line)
    print('%d officers from %s: %d problem%s, %d note%s'
          % (len(model.officers), os.path.basename(model.paths['officer']),
             len(problems), '' if len(problems) == 1 else 's',
             len(notes), '' if len(notes) == 1 else 's'))
    return 1 if problems else 0


def cmd_diff(m, model, args):
    other = _load(m, args, officer_csv=args.path)
    changes = model.changes(other.snapshot())
    if not changes:
        print('no field differences against %s' % args.path)
        return 0
    lines = model.change_lines(changes)
    print('%d field difference%s between %s (old) and %s (new):'
          % (len(changes), '' if len(changes) == 1 else 's', args.path,
             model.paths['officer']))
    for line in lines[:MAX_DIFF_LINES]:
        print('  %s' % line)
    if len(lines) > MAX_DIFF_LINES:
        print('  ... %d more' % (len(lines) - MAX_DIFF_LINES))
    return 0


def cmd_write_asm(m, model, args):
    repo = _need_repo(args)
    code = _save(model, args)
    if code:
        return code
    code = _run(repo, [sys.executable, 'tools/gen_data_bank_asm.py', '--bank',
                       'all', '--from-csv', '--write'])
    if code:
        return code
    return _run(repo, [sys.executable, 'tools/verify_data_banks.py',
                       '--allow-edits'])


def cmd_verify(m, model, args):
    return _run(_need_repo(args),
                [sys.executable, 'tools/verify_data_banks.py', '--allow-edits'])


# --- shared bits ---------------------------------------------------------
def _officer(m, model, raw):
    text = str(raw).strip()
    try:
        oid = int(text[1:], 16) if text.startswith('$') else int(text, 0)
    except ValueError:
        die('officer id %r is not a number' % raw, 2)
    try:
        return model.officer(oid)
    except m.OfficerError as exc:
        die(str(exc), 2)


def _load(m, args, officer_csv=None):
    """Load the CSV set a command works on.

    Everything follows the officer CSV: an explicit `--csv` brings its own
    siblings, and the repo's docs/ copies are only the fallback. Mixing a CSV
    from one place with the rosters of another would write files the user did
    not ask about.
    """
    paths = m.default_paths(args.repo) if args.repo else {}
    officer_csv = officer_csv or args.csv or paths.get('officer')
    if not officer_csv or not os.path.exists(officer_csv):
        die('no officer CSV to read (pass --csv PATH; looked for %s)'
            % (officer_csv or 'docs/officer_data.csv'), 2)
    # An explicit --csv brings its own siblings: mixing one directory's officer
    # rows with another's rosters would write files the caller did not name.
    province_csv = args.province_csv \
        or m.sibling_path(officer_csv, 'province_data.csv') \
        or paths.get('province')
    death_csv = args.death_csv \
        or m.sibling_path(officer_csv, 'officer_death_years.csv') \
        or paths.get('death')
    reinforce_csv = m.sibling_path(officer_csv,
                                   'officer_reinforcement.csv') \
        or paths.get('reinforce')
    labels = m.sibling_path(officer_csv,
                            os.path.join('include', 'officer_ids.inc')) \
        or paths.get('labels')
    glyph = m.sibling_path(officer_csv,
                           os.path.join('rom', 'prg', 'prg_11.bin')) \
        or paths.get('glyph_bank')
    card = m.sibling_path(officer_csv,
                          os.path.join('rom', 'prg', 'prg_01.bin')) \
        or paths.get('card_bank')
    page_bank = m.sibling_path(officer_csv,
                               os.path.join('rom', 'prg', 'prg_1a.bin')) \
        or paths.get('portrait_page_bank')
    heir_bank = m.sibling_path(officer_csv,
                               os.path.join('rom', 'prg', 'prg_0b.bin')) \
        or paths.get('heir_bank')
    chr_dir = m.sibling_path(officer_csv, os.path.join('rom', 'chr')) \
        or paths.get('chr_dir')
    try:
        return m.Model.load(
            officer_csv, province_csv=province_csv, death_csv=death_csv,
            labels_inc=labels if labels and os.path.exists(labels) else None,
            glyph_bank=glyph if glyph and os.path.exists(glyph) else None,
            chr_dir=chr_dir,
            reinforce_csv=reinforce_csv
            if reinforce_csv and os.path.exists(reinforce_csv) else None,
            card_bank=card if card and os.path.exists(card) else None,
            portrait_page_bank=page_bank
            if page_bank and os.path.exists(page_bank) else None,
            heir_bank=heir_bank if heir_bank and os.path.exists(heir_bank)
            else None)
    except m.OfficerError as exc:
        die(str(exc), 2)


def _finish(model, args, snapshot, what):
    """Report one edit command, then save it only when --write was given."""
    changes = model.changes(snapshot)
    if not changes:
        print('%s: no change' % what)
        return 0
    for line in model.change_lines(changes):
        print('  %s' % line)
    problems = model.problems()
    if problems and not args.force:
        for line in problems:
            print('FAIL: %s' % line, file=sys.stderr)
        print('refusing to write %d problem%s (fix them, or pass --force to '
              'stage the edit anyway)'
              % (len(problems), '' if len(problems) == 1 else 's'),
              file=sys.stderr)
        return 1
    if not args.write:
        print('dry run: pass --write to save %s'
              % ', '.join(os.path.basename(p) for p in model.paths.values()
                          if str(p).endswith('.csv')))
        return 0
    return _save(model, args)


def _display(path):
    """A path as the user would type it: repo-relative, else as given."""
    rel = os.path.relpath(path)
    return path if rel.startswith(os.pardir + os.sep) else rel


def _save(model, args):
    """Write the CSVs, refusing a set that trips a hard invariant."""
    problems = model.problems()
    if problems and not args.force:
        for line in problems:
            print('FAIL: %s' % line, file=sys.stderr)
        return 1
    try:
        written = model.save()
    except OSError as exc:
        die(str(exc))
    print('wrote %s' % ', '.join(_display(p) for p in written))
    model.commit()
    return 0


def _need_repo(args):
    if not args.repo:
        die('the disassembly repo tools were not found, so the assembly cannot '
            'be rendered from here - pass --repo PATH, or run in the repo:\n'
            '  python3 tools/gen_data_bank_asm.py --bank all --from-csv '
            '--write\n'
            '  python3 tools/verify_data_banks.py --allow-edits')
    return args.repo


def _run(repo, argv):
    print('$ ' + ' '.join(os.path.relpath(a, repo) if a.endswith('.py') else a
                          for a in argv))
    try:
        r = subprocess.run(argv, cwd=repo)
    except OSError as exc:
        die('failed to run %s: %s' % (argv[1], exc))
    return r.returncode


def build_parser(m):
    # Shared options appear both before and after the subcommand. argparse
    # copies a subparser's namespace over the parent's, so a plain default here
    # would silently discard `--csv PATH` given before the subcommand; SUPPRESS
    # leaves the attribute unset instead, and main() fills the defaults in.
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument('--csv', default=argparse.SUPPRESS,
                        help="officer_data.csv (default: the repo's "
                             'docs/officer_data.csv)')
    common.add_argument('--province-csv', dest='province_csv',
                        default=argparse.SUPPRESS,
                        help='province_data.csv holding the roster slots')
    common.add_argument('--death-csv', dest='death_csv',
                        default=argparse.SUPPRESS,
                        help='officer_death_years.csv')
    common.add_argument('--write', action='store_true',
                        default=argparse.SUPPRESS,
                        help='save the CSVs (without it an edit is a dry run)')
    common.add_argument('--force', action='store_true',
                        default=argparse.SUPPRESS,
                        help='write even with invariant problems')
    common.add_argument('--model', default=argparse.SUPPRESS,
                        help='directory holding officer_model.py')
    common.add_argument('--repo', default=argparse.SUPPRESS,
                        help='disassembly checkout whose tools/ render the '
                             'assembly')

    ap = argparse.ArgumentParser(
        prog='officer_cli.py', description=__doc__, parents=[common],
        formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='command')

    p = sub.add_parser('list', parents=[common], help='list officers')
    p.add_argument('--filter', help='substring of id / kana / kanji / pinyin / '
                                    'label / equipment')
    p.add_argument('--province', type=int, help='only officers rostered in or '
                                                'arriving at this province')
    p.add_argument('--status', default='all',
                   help='all | hidden | rostered | rulers | unscheduled')
    p.add_argument('--sort', default='id', help='column or field to sort by')
    p.add_argument('--reverse', action='store_true', help='sort descending')
    p.add_argument('--limit', type=int, help='stop after N rows')
    p.add_argument('--brief', action='store_true', help='narrow column set')
    p.add_argument('--problems-only', dest='problems_only', action='store_true',
                   help='only officers that trip an invariant')
    p.set_defaults(func=cmd_list)

    p = sub.add_parser('show', parents=[common],
                       help='decode one officer byte by byte')
    p.add_argument('id')
    p.set_defaults(func=cmd_show)

    p = sub.add_parser('fields', parents=[common],
                       help='the editable field keys and ranges')
    p.set_defaults(func=cmd_fields)

    p = sub.add_parser('set', parents=[common], help='edit record fields')
    p.add_argument('id')
    p.add_argument('assignments', nargs='*', metavar='KEY=VALUE')
    p.set_defaults(func=cmd_set)

    p = sub.add_parser('schedule', parents=[common],
                       help='set or clear an arrival entry')
    p.add_argument('id')
    p.add_argument('province', nargs='?', type=int)
    p.add_argument('year', nargs='?', type=int)
    p.add_argument('--clear', action='store_true', help='drop the entry')
    p.set_defaults(func=cmd_schedule)

    p = sub.add_parser('roster', parents=[common],
                       help='move an officer between province rosters')
    p.add_argument('action', choices=('add', 'remove', 'governor'))
    p.add_argument('id')
    p.add_argument('province', nargs='?', type=int)
    p.add_argument('--slot', type=int, help='roster slot to insert at '
                                            '(0 = the 太守 governor)')
    p.set_defaults(func=cmd_roster)

    p = sub.add_parser('reinforce', parents=[common],
                       help='set one heir\'s reinforcement join year')
    p.add_argument('id')
    p.add_argument('year', help='display year 100-255 (the stored byte is '
                                'year - 100)')
    p.set_defaults(func=cmd_reinforce)

    p = sub.add_parser('heirs', parents=[common],
                       help='the AI ruler successor priority lists (read-only)')
    p.set_defaults(func=cmd_heirs)

    p = sub.add_parser('check', parents=[common],
                       help='the invariant report (exit 1 on problems)')
    p.set_defaults(func=cmd_check)

    p = sub.add_parser('diff', parents=[common],
                       help='field-level diff against another CSV set')
    p.add_argument('path', help='the other officer_data.csv (its sibling '
                                'province/death CSVs are used too)')
    p.set_defaults(func=cmd_diff)

    p = sub.add_parser('write-asm', parents=[common],
                       help='save, re-render the banks, verify')
    p.set_defaults(func=cmd_write_asm)

    p = sub.add_parser('verify', parents=[common],
                       help='run tools/verify_data_banks.py --allow-edits')
    p.set_defaults(func=cmd_verify)
    return ap


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    # --model decides which codec copy to import, so it has to be read before
    # the real parser (whose help text comes from that codec) is built.
    pre = argparse.ArgumentParser(add_help=False)
    pre.add_argument('--model')
    model_module, _model_dir = load_model(pre.parse_known_args(argv)[0].model)

    global HEADINGS
    HEADINGS = {key: heading for key, heading, _ in model_module.COLUMNS}

    ap = build_parser(model_module)
    args = ap.parse_args(argv)
    if not getattr(args, 'command', None):
        ap.print_help()
        return 2
    for key, default in (('csv', None), ('province_csv', None),
                         ('death_csv', None), ('write', False),
                         ('force', False), ('model', None), ('repo', None)):
        if not hasattr(args, key):
            setattr(args, key, default)
    here = os.path.dirname(os.path.abspath(__file__))
    args.repo = model_module.find_repo(args.repo
                                       or os.environ.get('SANGO2_REPO'),
                                       os.path.dirname(here))
    model = _load(model_module, args)
    return args.func(model_module, model, args)


if __name__ == '__main__':
    raise SystemExit(main())
