#!/usr/bin/env python3
"""Sangokushi 2 officer editor - standalone GUI for the new-game seed data.

What it edits
-------------
The 237 officers of *Sangokushi 2 - Haou no Tairiku* (Famicom, Namco-163 /
mapper 19) as the new game seeds them, across every table that describes one:

| table | bank | CPU | shape | edited through |
|---|---|---|---|---|
| master records | `$31` | `$8000` | 237 x 12 B | `docs/officer_data.csv` |
| katakana names | `$30` | `$901A` | 237 x 10 B | `docs/officer_data.csv` |
| arrival schedule | `$31` | `$8B1C` | 30 x `$14` | `docs/officer_data.csv` |
| natural-death years | `$31` | `$9C58` | 237 x 1 B | `docs/officer_death_years.csv` |
| province rosters | `$30` | `$8C00 + $11..$1A` | 30 x 10 slots | `docs/province_data.csv` |

The master record is the seed image of the officer's SRAM record at
`id * 12 + $63C0`; `SramInit` (`$DD8B`, `asm/banks/prg_1d_1e_menu_screens.asm`) copies it
into SRAM and `B1F_GetOfficerRomRecordAddr` (`$F387`) also reads the ROM seed at
runtime, so these bytes are the new game:

    +0 体力 Vitality   +1 武力 Might   +2 知力 Intelligence   +3 忠誠度 Loyalty
    +4 人徳 Virtue     +5 位置 LocationProvince (runtime-only, stays 0)
    +6/+7 経験値 Experience (LE)       +8/+9 兵数 TroopCount (LE)
    +A bits 0-4 武器 Weapon (0-23), bits 5-7 防具 Armor (0-7)
    +B bits 4-7 レベル OfficerLevel (0-based) | bits 2-3 軍の属性 ArmyAffinity
       (0 平 / 1 山 / 2 水) | bits 0-1 状態 OfficerStatus (seed: 1 hidden,
       2 rostered)

Placement is spread over three tables, which is why the editor owns all of them:
a rostered officer (状態 2) sits in a province roster slot - slot `+$11` is the
太守 governor - and has no arrival entry, while a hidden officer (状態 1) may
carry an (appear year, province) pair in the bank `$31` `$8B1C` schedule walked
by `OfficerArrivalScan` (`$B964`, `prg_19_1a_event_scenes.asm`). That `状態 2 == the union of
all roster slots` is a cross-bank invariant `tools/verify_data_banks.py` proves
on the assembled bytes, so the editor never lets the two drift apart: Assign and
Unassign are the only way to move 状態.

The kanji name plate is *not* editable. Bank `$31` `$8DB4` holds 13 authored
bytes per officer (a name-font CHR page + up to three kanji as 2x2 tile
quadruples) that `CmdDrawNameFromData` (`$A426`) posts as sprites on the ruler
card. Tile ids are page-local and the pages are laid out per surname group
(`code/ruler_card_decode.md` section 4), so no kanji -> tiles function exists to
re-derive it: renaming an officer re-encodes the kana string only, and the
editor says so in the Notes pane and in the plate readout.

Running it
----------
    python3 editor/officer_editor.py                          # the repo's CSVs
    python3 editor/officer_editor.py --csv officer_data.csv    # one CSV, anywhere
    python3 editor/officer_editor.py --model . --csv officer_data.csv
    make officer-editor

Dependencies: Python 3 with `tkinter` only (stdlib). The codec is
`tools/officer_model.py`; `--model PATH` (or a copy of that file next to this
script) points the editor at it, which is what lets the same editor travel
outside the disassembly repo with nothing but the CSVs. Without the repo the
*Write ASM* / *Verify* buttons explain that the generator lives there; editing,
the invariant report, `Save CSVs` and `Diff` all keep working.

Editing model
-------------
The CSVs are the editing surface, exactly as for the terrain banks: `Save CSVs`
writes them, and `Write ASM` then runs

    tools/gen_data_bank_asm.py --bank all --from-csv --write
    tools/verify_data_banks.py --allow-edits

so the assembly is re-rendered by the repo's own generator and the byte gate
reports every deliberate edit in decoded terms (which officer, which field, old
-> new). Nothing here writes `rom/prg/*.bin`; the stock dumps stay the reference
images for byte-exactness. The headless twin of this editor is
`editor/officer_cli.py`, over the same model.
"""
import argparse
import os
import subprocess
import sys
import tkinter as tk
import tkinter.font as tkfont
from tkinter import filedialog, messagebox, ttk

MAX_UNDO = 60
TABLE_H = 18                   # table rows requested; the pane stretches anyway
ROW_PAD = 8                    # row height = font linespace + this, so CJK
                               # fallback glyphs are never clipped mid-stroke
PLATE_SCALE = 4                # plate glyph zoom: a 16 px kanji -> 64 px
PLATE_BACKDROP = '#f6f0e0'     # behind the transparent sprite pixels only -
                               # the sprite colours themselves come from the ROM
PORTRAIT_BACKDROP = '#1e1e1e'  # neutral dark behind the card portraits: the
                               # card colours are white/gold/brown, which the
                               # pale paper tone washes out (this is the same
                               # backdrop tools/check_officer_pipeline.py's
                               # render sheets use)
DETAIL_W = 560                 # requested detail pane width: the placement
                               # rows (roster label + province dropdown +
                               # slot spinbox) set the floor
WRAP_MARGIN = 40               # pane padding a wrapped label must stay inside
GROUP_TITLES = (
    ('portrait', '肖像 Portrait (read-only)'),
    ('identity', '身分 Identity'),
    ('stats', '能力 Stats (+00..+04)'),
    ('career', '経歴 Career'),
    ('equipment', '装備 Equipment / 軍の属性 ArmyAffinity'),
    ('placement', '配置 Placement (状態 / roster / arrival)'),
    ('successors', 'AI継承 Successor priority (read-only)'),
    ('stratagem', '計略 Stratagem tier (read-only)'),
    ('life', '寿命 Life'),
    ('plate', '漢字 name plate (read-only)'),
)
# Fields the placement group drives through the paired model API instead of one
# widget each: an arrival entry is province+year together, and 状態 only moves
# with a roster slot (the cross-bank gate).
PAIRED = ('officer_status_bits', 'schedule_province_id', 'appear_year')
PLATE_NOTE = (
    'Bank $31 $8DB4 + id*$0D: [0] the name-font CHR page, then up to three '
    'kanji as four 8x8 tile ids each, $FF terminated. CmdDrawNameFromData '
    '($A426) posts them as OAM sprites on the ruler card. The pages are '
    'authored per surname group and the tile ids are page-local, so nothing '
    're-derives them: this table is read-only, and renaming an officer '
    're-encodes the kana name at $901A only.')
PORTRAIT_NOTE = (
    'prg_1a $CED6 + id: the officer\'s 1KB portrait CHR page; OfficerCardRender '
    '($CE1F) draws a 14-sprite body + 6-sprite face from the bank-$01 tables '
    '(records [y, tile, attr, x], IRQ-latched into CHR regs 2/3). Every card '
    'sprite is attr palette 3, and the card scenes load palette record 0 '
    'before drawing, so the colours are $0F $20 $27 $17 (white / gold / '
    'brown; verified against the manual scan card). Left to right: normal '
    '(strategy card), angry (duel), sad (defeat), happy (victory). All 237 '
    'officers have authored pages: $18-$53 shared across the roster, plus '
    '$9F for 13/116 and $DB for 19/228 (the reinforcement-only heirs). '
    'Read-only.')
HEIR_NOTE = (
    'prg_0b $CAD8 (AppointSuccessor $CA68, runs when a country\'s ruler '
    'dies): per Country 0-6, the first listed officer governing one of the '
    'country\'s provinces (roster slot $11, the 太守) becomes the new ruler. '
    'If none qualifies, the AI installs the country\'s governor with the '
    'highest 人徳 Virtue. Read-only authored data - no CSV twin, no editing '
    'surface.')
STRATAGEM_NOTE = (
    'BuildCommandList ($D3EE, prg_08_09), called by StratagemState_Init '
    '($A89E, prg_0c_0d), fills the 計略 menu with the first N stratagem codes, '
    'and $0542 = N-1 is what StratagemState_Menu ($A917) reads. Two authored '
    'gates, tried in that order: the officer id against four strategist '
    'rosters, each with a レベル floor (record +$0B bits 4-7, stored 0-based); '
    'otherwise 知力 (record +$02) against $28 / $3C / $4B / $55 for 2/4/6/8/10 '
    'slots. A roster member below every floor of his roster falls through to '
    'the 知力 gate, and a member above one never has his 知力 read, so for '
    'those 21 ids レベル replaces the 知力 gate outright. The 15/16 tiers need '
    'stored レベル 5/6, above the seed maximum (董卓, stored 4), so they arrive '
    'only through OfficerLevelUp ($C691, prg_0c_0d) or an edit here. The AI '
    'uses the same thresholds as a 1/3/5/7/9 tier (AiPickStratagemTarget '
    '$A95C) and AiCheckAdvancedStratagem ($AAF8) adds a 知力 >= $5C floor on '
    'top of these rosters for codes $0A-$0F. Derived from the record - nothing '
    'here is stored per officer.')


# --- codec import --------------------------------------------------------
def load_model(cli_path=None):
    """Import officer_model from --model, a local copy, or the parent repo.

    Search order: the explicit path, this directory (so the editor travels with
    a copy of the codec), then `tools/` of the repo that holds `editor/`.

    editor/officer_cli.py carries the same bootstrap because it has to run
    before the codec is importable - there is nowhere shared to put it.
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


# --- table shape ---------------------------------------------------------
# The columns, their headings and the filter/sort logic live in the codec
# (tools/officer_model.py) so this GUI and editor/officer_cli.py show the same
# thing; only the pixel widths are a widget concern.
COLUMN_WIDTHS = {
    'id': 42, 'katakana': 104, 'zh_hans': 66, 'vitality': 34, 'might': 34,
    'intelligence': 34, 'loyalty': 34, 'virtue': 34, 'officer_level': 32,
    'experience': 52, 'troop_count': 52, 'army_affinity': 32,
    'officer_status': 66, 'weapon': 84, 'armor': 76, 'placement': 168,
    'death_year': 58,
}


def province_index(label):
    """`' 2 イシュウ 益州'` -> 2 (None for the `(none)` / `all` entries)."""
    if not label or label.startswith(('(none)', 'all')):
        return None
    try:
        return int(label.split()[0])
    except ValueError:
        return None


def combo_width(values):
    """Width units for a combobox that must show every value unclipped.

    Tk counts `width` in average-size characters, but these labels mix CJK
    with ASCII, so a fixed count (e.g. 15) clips ` 9 セイヘイカン 西平关`.
    Measure the longest value with the font the widget actually renders and
    convert through '0'.
    """
    font = tkfont.nametofont('TkTextFont')
    unit = font.measure('0')
    return max(4, max((font.measure(str(v)) for v in values), default=unit)
               // unit + 2)


class OfficerEditor(tk.Tk):
    """The officer seed-data editor: one table, one detail pane, one gate."""

    def __init__(self, m, repo=None, officer_csv=None, province_csv=None,
                 death_csv=None):
        super().__init__()
        self.m = m
        self.repo = repo
        self.undo = []
        self.redo = []
        self.sort_key = 'id'
        self.sort_reverse = False
        self.w = {}
        self.wrapping = []
        self.current = None
        self._loading = False
        self.title('Sangokushi 2 officer editor')
        self.geometry('1440x860')
        self.minsize(1100, 640)
        self._build_ui()
        self.load_paths(officer_csv, province_csv, death_csv)
        self._refresh_all()
        self.protocol('WM_DELETE_WINDOW', self.on_close)

    # -- construction ----------------------------------------------------
    def _build_ui(self):
        self.status = tk.StringVar(value='')
        self._build_toolbar()
        body = ttk.PanedWindow(self, orient='horizontal')
        body.pack(fill='both', expand=True, padx=4, pady=(0, 2))
        body.add(self._build_table(), weight=1)
        body.add(self._build_detail(), weight=0)
        bottom = ttk.PanedWindow(self, orient='horizontal')
        bottom.pack(fill='x', padx=4, pady=(0, 2))
        bottom.add(self._build_report(), weight=1)
        bottom.add(self._build_log(), weight=1)
        ttk.Label(self, textvariable=self.status, anchor='w',
                  relief='sunken').pack(fill='x', side='bottom')
        self.bind('<Control-s>', lambda e: self.save_csv())
        self.bind('<Control-b>', lambda e: self.write_asm())
        self.bind('<Control-z>', lambda e: self.undo_edit())
        self.bind('<Control-y>', lambda e: self.redo_edit())
        self.bind('<Control-f>', lambda e: self.focus_filter())
        self.bind('<Escape>', lambda e: self.clear_filter())
        self.bind_all('<KeyPress>', self._on_key, add='+')

    def _build_toolbar(self):
        bar = ttk.Frame(self)
        bar.pack(fill='x', padx=4, pady=3)
        left = ttk.Frame(bar)
        left.pack(side='left')
        for text, command, tip in (
                ('Open CSV…', self.open_csv, 'load another officer_data.csv'),
                ('Save CSVs', self.save_csv,
                 'write every loaded CSV twin (Ctrl+S)'),
                ('Write ASM', self.write_asm,
                 'save, then re-render asm/banks/data_10_seed.asm + data_11_officer.asm '
                 'and report the decoded edits (Ctrl+B)'),
                ('Verify', self.verify,
                 'run tools/verify_data_banks.py --allow-edits'),
                ('Diff', self.show_diff, 'list the edits not yet in the CSVs'),
                ('Revert', self.reload, 'reload the CSVs, discarding edits'),
                ('Undo', self.undo_edit, 'Ctrl+Z'),
                ('Redo', self.redo_edit, 'Ctrl+Y')):
            button = ttk.Button(left, text=text, command=command)
            button.pack(side='left', padx=(0, 3))
            self._tip(button, tip)
        right = ttk.Frame(bar)
        right.pack(side='right')
        ttk.Label(right, text='Filter').pack(side='left')
        self.filter_var = tk.StringVar()
        self.filter_entry = ttk.Entry(right, textvariable=self.filter_var,
                                      width=18)
        self.filter_entry.pack(side='left', padx=(2, 8))
        self.filter_entry.bind('<Return>', lambda e: self._refresh_table())
        self.filter_var.trace_add('write', lambda *a: self._refresh_table())
        ttk.Label(right, text='Province').pack(side='left')
        self.prov_var = tk.StringVar()
        self.prov_box = ttk.Combobox(right, textvariable=self.prov_var,
                                     state='readonly', width=16)
        self.prov_box.pack(side='left', padx=(2, 8))
        self.prov_box.bind('<<ComboboxSelected>>',
                           lambda e: self._refresh_table())
        ttk.Label(right, text='状態').pack(side='left')
        self.status_var = tk.StringVar(value=self.m.STATUS_FILTERS[0])
        self.status_box = ttk.Combobox(
            right, textvariable=self.status_var,
            values=self.m.STATUS_FILTERS, state='readonly',
            width=combo_width(self.m.STATUS_FILTERS))
        self.status_box.pack(side='left')
        self.status_box.bind('<<ComboboxSelected>>',
                             lambda e: self._refresh_table())

    def _build_table(self):
        frame = ttk.Frame(self)
        # The row height has to come from the fonts the table actually renders:
        # the CJK cells and headings fall back to fonts whose linespace exceeds
        # the theme default, and the default rowheight clips them mid-glyph.
        row_h = max(tkfont.nametofont(name).metrics('linespace')
                    for name in ('TkTextFont', 'TkDefaultFont',
                                 'TkHeadingFont')) + ROW_PAD
        style = ttk.Style(self)
        style.configure('Officer.Treeview', rowheight=row_h)
        style.configure('Officer.Treeview.Heading', padding=(2, 4))
        self.tree = ttk.Treeview(frame, columns=[c for c, _, _ in
                                                 self.m.COLUMNS],
                                 show='headings', selectmode='browse',
                                 style='Officer.Treeview', height=TABLE_H)
        for key, heading, anchor in self.m.COLUMNS:
            self.tree.heading(key, text=heading,
                              command=lambda k=key: self._sort_by(k))
            self.tree.column(key, width=COLUMN_WIDTHS[key], anchor=anchor,
                             stretch=False)
        vsb = ttk.Scrollbar(frame, orient='vertical', command=self.tree.yview)
        hsb = ttk.Scrollbar(frame, orient='horizontal', command=self.tree.xview)
        self.tree.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        self.tree.grid(row=0, column=0, sticky='nsew')
        vsb.grid(row=0, column=1, sticky='ns')
        hsb.grid(row=1, column=0, sticky='ew')
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        self.tree.bind('<<TreeviewSelect>>', self._on_select)
        self.tree.tag_configure('edited', foreground='#0a58ca')
        self.tree.tag_configure('ruler', foreground='#8a6d00')
        self.tree.tag_configure('problem', foreground='#b00020')
        return frame

    def _build_detail(self):
        frame = ttk.Frame(self, width=DETAIL_W)
        canvas = tk.Canvas(frame, highlightthickness=0, width=DETAIL_W)
        vsb = ttk.Scrollbar(frame, orient='vertical', command=canvas.yview)
        self.detail = ttk.Frame(canvas)
        self.detail.bind('<Configure>', lambda e: canvas.configure(
            scrollregion=canvas.bbox('all')))
        self.detail_canvas = canvas
        self.detail_win = canvas.create_window((0, 0), window=self.detail,
                                               anchor='nw')
        canvas.configure(yscrollcommand=vsb.set)
        canvas.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        # Pin the pane to the canvas width: without it the frame requests the
        # natural width of its widest label (a full province roster line is
        # ~700 px) and the overflow is silently clipped.
        canvas.bind('<Configure>', self._on_detail_configure)
        for event, step in (('<MouseWheel>', None), ('<Button-4>', -1),
                            ('<Button-5>', 1)):
            canvas.bind(event, lambda e, s=step: self._on_wheel(e, s))
        self._build_fields()
        return frame

    def _on_detail_configure(self, event):
        self.detail_canvas.itemconfigure(self.detail_win, width=event.width)
        for widget in self.wrapping:
            widget.configure(wraplength=max(160, event.width - WRAP_MARGIN))

    def _wrap(self, widget):
        """Register a label whose prose re-wraps with the pane width.

        Without a wraplength a Label requests the full width of its longest
        line (a province roster runs to ~700 px), and since the pane is pinned
        to the canvas that overflow would be clipped rather than scrolled.
        """
        self.wrapping.append(widget)
        widget.configure(wraplength=DETAIL_W - WRAP_MARGIN, justify='left')
        return widget

    def _on_wheel(self, event, step=None):
        if step is None:
            step = -1 if getattr(event, 'delta', 0) > 0 else 1
        self.detail_canvas.yview_scroll(step, 'units')

    def _build_fields(self):
        """One labelled widget per editable field, grouped as the record is."""
        parent = self.detail
        self.head_var = tk.StringVar(value='(no officer selected)')
        ttk.Label(parent, textvariable=self.head_var,
                  font=('TkDefaultFont', 11, 'bold')).pack(fill='x', padx=8,
                                                           pady=(8, 2))
        self.record_var = tk.StringVar(value='')
        self._wrap(ttk.Label(parent, textvariable=self.record_var,
                             font=('TkFixedFont', 9))).pack(
                                 fill='x', padx=8, pady=(0, 6))

        groups = {}
        for spec in self.m.FIELDS:
            if spec.key not in PAIRED:
                groups.setdefault(spec.group, []).append(spec)
        self._build_portrait(parent)
        for group, title in GROUP_TITLES:
            if group not in groups:
                continue
            box = ttk.LabelFrame(parent, text=title)
            box.pack(fill='x', padx=8, pady=4)
            for row, spec in enumerate(groups[group]):
                ttk.Label(box, text='%s  %s' % (spec.jp, spec.en),
                          justify='left').grid(row=row, column=0, sticky='w',
                                               padx=6, pady=2)
                self._field_widget(box, spec).grid(row=row, column=1,
                                                   sticky='ew', padx=6, pady=2)
                box.columnconfigure(1, weight=1)
        self._build_placement(parent)
        self._build_successors(parent)
        self._build_stratagems(parent)
        self._build_plate(parent)

    def _field_widget(self, parent, spec):
        if spec.kind == 'choice':
            values = [label for _, label in spec.choices]
            widget = ttk.Combobox(parent, values=values,
                                  state='readonly',
                                  width=combo_width(values))
            widget.bind('<<ComboboxSelected>>',
                        lambda e, k=spec.key: self._commit(k))
        else:
            var = tk.StringVar()
            widget = (ttk.Entry(parent, textvariable=var)
                      if spec.kind == 'text' else
                      ttk.Spinbox(parent, from_=spec.lo, to=spec.hi,
                                  textvariable=var, width=10))
            widget.bind('<Return>', lambda e, k=spec.key: self._commit(k))
            widget.bind('<FocusOut>', lambda e, k=spec.key: self._commit(k))
        self.w[spec.key] = widget
        return widget

    def _build_placement(self, parent):
        box = ttk.LabelFrame(parent, text=dict(GROUP_TITLES)['placement'])
        box.pack(fill='x', padx=8, pady=4)
        self.placement_var = tk.StringVar(value='')
        self._wrap(ttk.Label(box, textvariable=self.placement_var,
                             font=('TkFixedFont', 9))).grid(
                                 row=0, column=0, columnspan=4, sticky='w',
                                 padx=6, pady=2)
        # Widths are set from the province labels in _show_placement, once the
        # model knows them.
        provinces = ttk.Combobox(box, state='readonly')
        self.roster_box = provinces
        ttk.Label(box, text='武将 roster').grid(row=1, column=0, sticky='w',
                                                padx=6, pady=2)
        provinces.grid(row=1, column=1, sticky='w', padx=2, pady=2)
        self.slot_box = ttk.Spinbox(box, from_=0, to=self.m.ROSTER_SLOTS - 1,
                                    width=4)
        self.slot_box.grid(row=1, column=2, sticky='w', padx=2)
        ttk.Label(box, text='slot').grid(row=1, column=3, sticky='w')
        buttons = ttk.Frame(box)
        buttons.grid(row=2, column=0, columnspan=4, sticky='w', padx=6, pady=2)
        for text, command in (('Assign', self.assign_officer),
                              ('Unassign', self.unassign_officer),
                              ('Make 太守', self.make_governor)):
            ttk.Button(buttons, text=text, command=command).pack(
                side='left', padx=(0, 4))
        ttk.Label(box, text='出現 arrival').grid(row=3, column=0, sticky='w',
                                                padx=6, pady=2)
        self.sched_box = ttk.Combobox(box, state='readonly')
        self.sched_box.grid(row=3, column=1, sticky='w', padx=2, pady=2)
        self.year_box = ttk.Spinbox(box, from_=self.m.STOCK_ARRIVAL_YEARS[0],
                                    to=self.m.STOCK_ARRIVAL_YEARS[1], width=6)
        self.year_box.grid(row=3, column=2, sticky='w', padx=2)
        ttk.Label(box, text='year').grid(row=3, column=3, sticky='w')
        arrival = ttk.Frame(box)
        arrival.grid(row=4, column=0, columnspan=4, sticky='w', padx=6, pady=2)
        for text, command in (('Set', self.set_arrival),
                              ('Clear', self.clear_arrival)):
            ttk.Button(arrival, text=text, command=command).pack(
                side='left', padx=(0, 4))
        heir = ttk.Frame(box)
        heir.grid(row=5, column=0, columnspan=4, sticky='w', padx=6, pady=2)
        ttk.Label(heir, text='継承 heir').pack(side='left')
        self.heir_info = tk.StringVar(value='')
        ttk.Label(heir, textvariable=self.heir_info, width=14).pack(
            side='left', padx=(6, 6))
        self.heir_year = ttk.Spinbox(heir, from_=100, to=255, width=6,
                                     state='disabled')
        self.heir_year.pack(side='left')
        ttk.Button(heir, text='Set', command=self.set_heir_year).pack(
            side='left', padx=(4, 0))
        self.roster_info = tk.StringVar(value='')
        self._wrap(ttk.Label(box, textvariable=self.roster_info,
                             foreground='#555')).grid(
                                 row=6, column=0, columnspan=4, sticky='w',
                                 padx=6, pady=(0, 4))

    def _build_successors(self, parent):
        box = ttk.LabelFrame(parent, text=dict(GROUP_TITLES)['successors'])
        box.pack(fill='x', padx=8, pady=4)
        self.successor_var = tk.StringVar(value='')
        self._wrap(ttk.Label(box, textvariable=self.successor_var)).grid(
            row=0, column=0, columnspan=2, sticky='w', padx=6, pady=3)
        ttk.Button(box, text='Show text',
                   command=lambda: self._text_popup(
                       'AI継承 Successor priority', self.successor_var,
                       HEIR_NOTE,
                       text='\n'.join(self.model.heir_priority_lines())
                       if self.model.has_heirs else
                       'heir priority lists not loaded '
                       '(rom/prg/prg_0b.bin beside the CSVs)')).grid(
                           row=1, column=0, sticky='e', padx=6, pady=(0, 4))

    def _show_successors(self, off):
        if off is None:
            self.successor_var.set('')
            return
        if not self.model.has_heirs:
            self.successor_var.set('prg_0b not loaded beside the CSVs')
            return
        hits = self.model.heir_successor_lists(off.id)
        if not hits:
            self.successor_var.set(
                'not in any AI successor list - the fallback installs the '
                'country\'s governor with the highest 人徳 Virtue')
            return
        self.successor_var.set('; '.join(
            'Country %d: %s (he is #%d of %d)'
            % (country, ' > '.join(self.model.by_id[oid].name for oid in ids),
               pos + 1, len(ids))
            for country, pos, ids in hits))

    def _build_stratagems(self, parent):
        box = ttk.LabelFrame(parent, text=dict(GROUP_TITLES)['stratagem'])
        box.pack(fill='x', padx=8, pady=4)
        self.stratagem_var = tk.StringVar(value='')
        self._wrap(ttk.Label(box, textvariable=self.stratagem_var,
                             font=('TkFixedFont', 9))).grid(
                                 row=0, column=0, columnspan=2, sticky='w',
                                 padx=6, pady=3)
        self.stratagem_detail = []
        ttk.Button(box, text='Show text',
                   command=lambda: self._text_popup(
                       '計略 Stratagem tier', self.stratagem_var,
                       STRATAGEM_NOTE,
                       text='\n'.join(
                           list(self.stratagem_detail)
                           + [''] + self.m.stratagem_ladder_lines(
                               self.model.by_id)))).grid(
                               row=1, column=0, sticky='e', padx=6, pady=(0, 4))

    def _show_stratagems(self, off):
        if off is None:
            self.stratagem_detail = []
            self.stratagem_var.set('')
            return
        lines = off.stratagem_lines()
        self.stratagem_detail = lines
        # The pane carries the verdict and the reason; the full name lists and
        # the tier ladder stay in the popup, where the column text can wrap.
        self.stratagem_var.set('\n'.join(lines[:3]))

    def _build_plate(self, parent):
        box = ttk.LabelFrame(parent, text=dict(GROUP_TITLES)['plate'])
        box.pack(fill='x', padx=8, pady=4)
        # One paper-toned cell per kanji: pixel 0 is transparent in the sprite
        # palette, so the glyphs need a backdrop to be readable at all. The
        # decode text stays off the pane - a button opens it in a popup.
        self.plate_glyphs = ttk.Frame(box)
        self.plate_images = []
        self.plate_glyphs.grid(row=0, column=0, sticky='w', padx=6, pady=3)
        self.plate_var = tk.StringVar(value='')
        ttk.Button(box, text='Show text',
                   command=lambda: self._text_popup(
                       '漢字 name plate', self.plate_var, PLATE_NOTE)).grid(
                           row=1, column=0, sticky='e', padx=6, pady=(0, 4))

    def _build_portrait(self, parent):
        box = ttk.LabelFrame(parent, text=dict(GROUP_TITLES)['portrait'])
        box.pack(fill='x', padx=8, pady=4)
        # Sprite pixel 0 is transparent and the card's own background colour
        # belongs to the screen, not the sprites, so this viewer supplies a
        # neutral dark one (the pale paper tone washes the gold/brown out).
        # The decode text stays off the pane - a button opens it in a popup.
        self.portrait_cell = ttk.Frame(box)
        self.portrait_images = []
        self.portrait_cell.grid(row=0, column=0, columnspan=2, sticky='nw',
                                padx=6, pady=4)
        self.portrait_var = tk.StringVar(value='')
        ttk.Button(box, text='Show text',
                   command=lambda: self._text_popup(
                       '肖像 Portrait', self.portrait_var, PORTRAIT_NOTE)).grid(
                           row=1, column=1, sticky='e', padx=6, pady=(0, 4))

    def _text_popup(self, title, var, note, text=None):
        """The decode text of a read-only view, in its own window."""
        win = tk.Toplevel(self)
        win.title(title)
        win.transient(self)
        frame = ttk.Frame(win, padding=8)
        frame.pack(fill='both', expand=True)
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        info = tk.Text(frame, wrap='word', width=68, height=14,
                       font=('TkFixedFont', 9), state='disabled')
        vsb = ttk.Scrollbar(frame, orient='vertical', command=info.yview)
        info.configure(yscrollcommand=vsb.set)
        info.grid(row=0, column=0, sticky='nsew')
        vsb.grid(row=0, column=1, sticky='ns')
        info.configure(state='normal')
        info.insert('1.0', ((text if text is not None else var.get())
                            + '\n\n' + note).strip())
        info.configure(state='disabled')
        ttk.Button(frame, text='Close', command=win.destroy).grid(
            row=1, column=0, columnspan=2, sticky='e', pady=(6, 0))

    def _show_portrait(self, off):
        for child in self.portrait_cell.winfo_children():
            child.destroy()
        self.portrait_images = []
        if off is None:
            self.portrait_var.set('')
            return
        if not self.model.has_portraits:
            self.portrait_var.set('card banks not loaded (rom/prg/prg_01.bin '
                                  '+ prg_1a.bin beside the CSVs)')
            return
        if off.portrait_chr is None:
            self.portrait_var.set('portrait page $%02X (rom/chr/chr_%02x.bin '
                                  'not found beside the CSVs)'
                                  % (off.portrait_page, off.portrait_page // 8))
            return
        for expr, name in self.m.PORTRAIT_EXPRESSIONS:
            pixels = off.portrait_pixels(expr)
            if pixels is None:
                continue
            w, rows = pixels
            img = tk.PhotoImage(width=w, height=len(rows))
            for y, row in enumerate(rows):
                for x, rgb in enumerate(row):
                    if rgb:
                        img.put('#%02x%02x%02x' % rgb, (x, y))
            img = img.zoom(PLATE_SCALE, PLATE_SCALE)
            self.portrait_images.append(img)
            ttk.Label(self.portrait_cell, image=img,
                      background=PORTRAIT_BACKDROP, padding=2).pack(
                          side='left', padx=(0, 2))
        self.portrait_var.set('$CED6[%d] -> page $%02X  rom/chr/chr_%02x.bin '
                              '@ $%03X\nnormal / angry / sad / happy - every '
                              'card sprite is attr palette 3, so the colours '
                              'are\nsprite palette 3 of palette record 0 '
                              '($0F $20 $27 $17), uploaded at $3F1C'
                              % (off.id, off.portrait_page,
                                 off.portrait_page // 8,
                                 (off.portrait_page % 8) * 0x400))

    def _build_report(self):
        frame = ttk.LabelFrame(self, text='Invariants (problems) and '
                                          'conventions (notes)')
        self.report = tk.Text(frame, height=6, wrap='word', state='disabled',
                              font=('TkFixedFont', 9))
        for tag, colour in (('problem', '#b00020'), ('note', '#6a4b00'),
                            ('ok', '#0a6b2a')):
            self.report.tag_configure(tag, foreground=colour)
        vsb = ttk.Scrollbar(frame, orient='vertical',
                            command=self.report.yview)
        self.report.configure(yscrollcommand=vsb.set)
        self.report.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        return frame

    def _build_log(self):
        frame = ttk.LabelFrame(self, text='Output')
        self.log = tk.Text(frame, height=6, wrap='none', state='disabled',
                           font=('TkFixedFont', 9))
        vsb = ttk.Scrollbar(frame, orient='vertical', command=self.log.yview)
        self.log.configure(yscrollcommand=vsb.set)
        self.log.grid(row=0, column=0, sticky='nsew')
        vsb.grid(row=0, column=1, sticky='ns')
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        return frame

    def _tip(self, widget, text):
        """A short hover hint in the status bar; Tk 8.6 has no tooltip."""
        widget.bind('<Enter>', lambda e: self.status.set(text))
        widget.bind('<Leave>', lambda e: self.status.set(self._status_text()))

    # -- loading ---------------------------------------------------------
    def _twins(self, officer_csv, province_csv=None, death_csv=None):
        """Everything that follows one officer CSV.

        An explicitly opened CSV brings its own siblings (province, death years,
        the id equates, the stock bank holding the kanji plates); the repo's
        docs/ copies are only the fallback. Mixing a CSV from one place with the
        rosters of another would write files the user did not ask about.
        """
        paths = self.m.default_paths(self.repo) if self.repo else {}
        sibling = self.m.sibling_path
        return {
            'officer': officer_csv,
            'province': province_csv
                        or sibling(officer_csv, 'province_data.csv')
                        or paths.get('province'),
            'death': death_csv
                     or sibling(officer_csv, 'officer_death_years.csv')
                     or paths.get('death'),
            'reinforce': sibling(officer_csv, 'officer_reinforcement.csv')
                         or paths.get('reinforce'),
            'labels': sibling(officer_csv,
                              os.path.join('include', 'officer_ids.inc'))
                      or paths.get('labels'),
            'glyph_bank': sibling(officer_csv, os.path.join('rom', 'prg',
                                                            'prg_11.bin'))
                          or paths.get('glyph_bank'),
            'card_bank': sibling(officer_csv, os.path.join('rom', 'prg',
                                                           'prg_01.bin'))
                         or paths.get('card_bank'),
            'portrait_page_bank': sibling(officer_csv,
                                          os.path.join('rom', 'prg',
                                                       'prg_1a.bin'))
                                  or paths.get('portrait_page_bank'),
            'heir_bank': sibling(officer_csv,
                                 os.path.join('rom', 'prg', 'prg_0b.bin'))
                         or paths.get('heir_bank'),
            'chr_dir': sibling(officer_csv, os.path.join('rom', 'chr'))
                       or paths.get('chr_dir'),
        }

    def _load(self, paths):
        """Model.load from a `_twins` dict, recording what it actually read."""
        self.model = self.m.Model.load(
            paths['officer'], province_csv=paths.get('province'),
            death_csv=paths.get('death'), labels_inc=paths.get('labels'),
            glyph_bank=paths.get('glyph_bank'), chr_dir=paths.get('chr_dir'),
            reinforce_csv=paths.get('reinforce'),
            card_bank=paths.get('card_bank'),
            portrait_page_bank=paths.get('portrait_page_bank'),
            heir_bank=paths.get('heir_bank'))
        self.source = dict(self.model.paths)
        self.log_line('loaded %s (%d officers, %d provinces, death years %s, '
                      'kanji plates %s)'
                      % (self.model.paths['officer'], len(self.model.officers),
                         len(self.model.provinces),
                         'yes' if self.model.has_deaths else 'no',
                         'tiles' if self.model.has_chr else
                         ('hex only' if self.model.has_glyphs else 'no')))
        if not self.repo:
            self.log_line('standalone mode: no repo tools beside the model, so '
                          'Write ASM / Verify are unavailable')

    def load_paths(self, officer_csv=None, province_csv=None, death_csv=None):
        """Work out which CSV twins to read, then read them."""
        paths = self.m.default_paths(self.repo) if self.repo else {}
        officer_csv = officer_csv or paths.get('officer')
        if not officer_csv or not os.path.exists(officer_csv):
            officer_csv = filedialog.askopenfilename(
                title='Open docs/officer_data.csv',
                filetypes=[('CSV', '*.csv'), ('all files', '*')])
            if not officer_csv:
                raise SystemExit('no officer CSV to edit')
        self._load(self._twins(officer_csv, province_csv, death_csv))

    def reload(self):
        if not self._confirm_discard():
            return
        self._load(dict(self.source))
        self.undo, self.redo = [], []
        self.log_line('reverted to the CSVs on disk')
        self._refresh_all()

    def open_csv(self):
        if not self._confirm_discard():
            return
        path = filedialog.askopenfilename(
            title='Open an officer_data.csv',
            filetypes=[('CSV', '*.csv'), ('all files', '*')])
        if not path:
            return
        try:
            self._load(self._twins(path))
        except self.m.OfficerError as exc:
            messagebox.showerror('Cannot open', str(exc))
            return
        self.undo, self.redo = [], []
        self.log_line('opened %s' % path)
        self._refresh_all()

    # -- selection -------------------------------------------------------
    def _refresh_all(self):
        self._fill_filter_choices()
        self._refresh_table()
        self._refresh_report()
        self._refresh_title()

    def _fill_filter_choices(self):
        labels = [label for _, label in self.model.province_choices()]
        choices = ['all provinces'] + labels
        self.prov_box.configure(values=choices, width=combo_width(choices))
        if self.prov_var.get() not in choices:
            self.prov_var.set(choices[0])

    def _refresh_table(self):
        keep = self.current.id if self.current else None
        officers = self.m.visible(self.model, self.filter_var.get(),
                                  province_index(self.prov_var.get()),
                                  self.status_var.get())
        officers = self.m.sort(self.model, officers, self.sort_key,
                               self.sort_reverse)
        edited = {ch.oid for ch in self.model.changes()}
        problem_ids = self.model.problem_ids()
        self.tree.delete(*self.tree.get_children())
        for off in officers:
            tags = []
            if off.id in problem_ids:
                tags.append('problem')
            elif off.id in edited:
                tags.append('edited')
            if off.is_ruler:
                tags.append('ruler')
            self.tree.insert('', 'end', iid=str(off.id), tags=tags,
                             values=self.m.row_values(self.model, off))
        ids = self.tree.get_children()
        if keep is not None and str(keep) in ids:
            self.tree.selection_set(str(keep))
            self.tree.see(str(keep))
        elif ids:
            self.tree.selection_set(ids[0])
            self.tree.see(ids[0])
        else:
            self.current = None
            self._show_officer(None)
        self.status.set(self._status_text(len(ids)))

    def _sort_by(self, key):
        if self.sort_key == key:
            self.sort_reverse = not self.sort_reverse
        else:
            self.sort_key, self.sort_reverse = key, False
        self._refresh_table()

    def _on_select(self, event=None):
        selection = self.tree.selection()
        if not selection:
            return
        self.current = self.model.officer(int(selection[0]))
        self._show_officer(self.current)
        self.status.set(self._status_text())

    def current_officer(self):
        if self.current is None:
            messagebox.showinfo('No officer', 'Select an officer first.')
        return self.current

    # -- detail pane -----------------------------------------------------
    def _show_officer(self, off):
        self._loading = True
        try:
            if off is None:
                self.head_var.set('(no officer selected)')
                for var in (self.record_var, self.placement_var,
                            self.plate_var, self.roster_info,
                            self.successor_var):
                    var.set('')
                for widget in self.w.values():
                    widget.configure(state='disabled')
                self._show_portrait(None)
                self._show_stratagems(None)
                return
            for spec in self.m.FIELDS:
                widget = self.w.get(spec.key)
                if widget is not None:
                    widget.configure(state='readonly' if spec.kind == 'choice'
                                     else 'normal')
            self.head_var.set('%d  %s  %s%s' % (
                off.id, off.katakana, off.zh_hans,
                '  [%s]' % off.label if off.label else ''))
            self.record_var.set(self._record_text(off))
            for spec in self.m.FIELDS:
                if spec.key not in PAIRED:
                    self._fill_widget(spec, off.get(spec.key))
            self.w['death_year'].configure(
                state='normal' if self.model.has_deaths else 'disabled')
            self._show_placement(off)
            self._show_successors(off)
            self._show_stratagems(off)
            self._show_plate(off)
            self._show_portrait(off)
        finally:
            self._loading = False

    def _record_text(self, off):
        rec = off.record()
        return ('record $%04X  %s\n'
                '              %s\n'
                '       +0A $%02X  +0B $%02X\n'
                'SRAM   $%04X   name $%04X\n'
                'name   %s'
                % (off.record_cpu(), ' '.join('%02X' % b for b in rec[:6]),
                   ' '.join('%02X' % b for b in rec[6:]), rec[10], rec[11],
                   off.sram_addr(), off.name_cpu(),
                   ' '.join('%02X' % b for b in off.name_bytes())))

    def _fill_widget(self, spec, value):
        widget = self.w[spec.key]
        if spec.kind == 'choice':
            values = [code for code, _ in spec.choices]
            labels = [label for _, label in spec.choices]
            widget.set(labels[values.index(value)] if value in values
                       else '(invalid: %s)' % value)
            return
        widget.delete(0, 'end')
        widget.insert(0, '' if value is None else str(value))

    def _show_placement(self, off):
        choices = self.model.province_choices()
        provinces = ['(none)'] + [label for _, label in choices]
        # Look the label up by province id, not by position: the dropdown is
        # only a list of strings, and a CSV missing a province row would
        # otherwise select the wrong one.
        by_id = {pid: label for pid, label in choices}
        state = 'readonly' if self.model.has_rosters else 'disabled'
        width = combo_width(provinces)
        for box in (self.roster_box, self.sched_box):
            box.configure(values=provinces, state=state, width=width)
        self.placement_var.set('状態 OfficerStatus  %d %-9s  %s'
                               % (off.officer_status_bits, off.officer_status,
                                  off.placement()))
        pool = self.model.reinforce_entry(off.id)
        if pool:
            self.heir_info.set('Country %d pool' % pool[0])
            self.heir_year.configure(state='normal'
                                     if self.model.has_reinforce
                                     else 'disabled')
            self.heir_year.delete(0, 'end')
            self.heir_year.insert(0, str(pool[1]))
        else:
            self.heir_info.set('not an heir')
            self.heir_year.configure(state='disabled')
        self.roster_box.set(by_id.get(off.roster_province, provinces[0]))
        self.sched_box.set(by_id.get(off.schedule_province_id, provinces[0]))
        for widget, value in ((self.slot_box, off.roster_slot or 0),
                              (self.year_box, off.appear_year
                               if off.appear_year is not None
                               else self.m.STOCK_ARRIVAL_YEARS[0])):
            widget.delete(0, 'end')
            widget.insert(0, str(value))
            widget.configure(state='normal' if self.model.has_rosters
                             else 'disabled')
        if off.roster_province is not None:
            prov = self.model.province(off.roster_province)
            self.roster_info.set('%s roster: %s   (* = slot +$11, the 太守 '
                                 'governor)' % (prov.name, ' '.join(
                                     '%d%s' % (oid, '*' if i == 0 else '')
                                     for i, oid in enumerate(prov.roster))))
        else:
            self.roster_info.set(
                'not in any province roster' if self.model.has_rosters else
                'province data not loaded - rosters are read-only here')

    def _show_plate(self, off):
        pixels = off.plate_pixels()
        for child in self.plate_glyphs.winfo_children():
            child.destroy()
        self.plate_images = []
        if not off.glyph:
            self.plate_var.set('kanji plate not loaded '
                               '(no rom/prg/prg_11.bin beside the CSVs)')
            return
        if not off.chr_page:
            self.plate_var.set('the plate record loaded, but no rom/chr beside '
                               'the CSVs, so the glyph shapes cannot be shown')
            return
        if not pixels:
            self.plate_var.set('the plate record is empty '
                               '($FF terminated at slot 0)')
            return
        for kanji in pixels:
            img = tk.PhotoImage(width=16, height=16)
            for y, row in enumerate(kanji):
                for x, value in enumerate(row):
                    if value:
                        img.put('#%02x%02x%02x'
                                % self.m.NES_RGB[
                                    self.m.NAME_SPRITE_PALETTE[value]],
                                (x, y))
            img = img.zoom(PLATE_SCALE, PLATE_SCALE)
            self.plate_images.append(img)
            ttk.Label(self.plate_glyphs, image=img,
                      background=PLATE_BACKDROP, padding=2).pack(
                          side='left', padx=(0, 4))
        quads = off.glyph_kanji()
        body = '\n'.join('%d: %s   (tiles $%02X $%02X / $%02X $%02X)'
                         % (i, ' '.join('%02X' % t for t in quad), *quad)
                         for i, quad in enumerate(quads))
        self.plate_var.set('$%04X  page $%02X  %d kanji  (strokes $0F, sprite '
                           'palette 1 of strategy palette record 0; the paper '
                           'tone is this viewer\'s)\n%s'
                           % (off.glyph_cpu(), off.glyph_page, len(quads),
                              body or 'empty ($FF terminated at slot 0)'))

    # -- editing ---------------------------------------------------------
    def _commit(self, key):
        """Push one widget's value into the model (Enter / FocusOut / select)."""
        if self._loading or self.current is None:
            return
        try:
            widget = self.w[key]
            text = widget.get()
        except tk.TclError:
            return                      # the widget is being torn down
        spec = self.m.FIELD_BY_KEY[key]
        if spec.kind == 'choice':
            labels = [label for _, label in spec.choices]
            if text not in labels:
                return
            value = spec.choices[labels.index(text)][0]
        else:
            value = text
        self._apply(key, value)

    def _apply(self, key, value, action=None):
        """Run one model edit, with undo, validation and a full refresh."""
        off = self.current
        if off is None:
            return
        snapshot = self.model.snapshot()
        try:
            if action is not None:
                action()
                what = key
            else:
                old = self.model.set(off.id, key, value)
                if old == off.get(key):
                    return
                what = '%s %s' % (key, self.m._show(key, off.get(key)))
        except self.m.OfficerError as exc:
            messagebox.showerror('Cannot apply that edit', str(exc))
            self._show_officer(off)
            return
        self._push_undo(snapshot)
        self._refresh_table()
        self._show_officer(self.current)
        self._refresh_report()
        self._refresh_title()
        self.log_line('edit %s: %s' % (off.title(), what))

    def _push_undo(self, snapshot):
        self.undo.append(snapshot)
        if len(self.undo) > MAX_UNDO:
            self.undo.pop(0)
        self.redo.clear()

    def undo_edit(self):
        if not self.undo:
            return
        self.redo.append(self.model.snapshot())
        self.model.restore(self.undo.pop())
        self._after_undo('undo')

    def redo_edit(self):
        if not self.redo:
            return
        self.undo.append(self.model.snapshot())
        self.model.restore(self.redo.pop())
        self._after_undo('redo')

    def _after_undo(self, what):
        self._refresh_all()
        self._show_officer(self.current)
        self.log_line('%s (%d undo, %d redo)' % (what, len(self.undo),
                                                 len(self.redo)))

    def assign_officer(self):
        off = self.current_officer()
        if off is None:
            return
        pid = province_index(self.roster_box.get())
        if pid is None:
            messagebox.showinfo('Assign', 'Pick a province first.')
            return
        slot = self.slot_box.get().strip() or None
        self._apply('roster', None,
                    action=lambda: self.model.assign(off.id, pid, slot))

    def unassign_officer(self):
        off = self.current_officer()
        if off is None:
            return
        self._apply('roster', None, action=lambda: self.model.unassign(off.id))

    def make_governor(self):
        off = self.current_officer()
        if off is None:
            return
        self._apply('roster', None,
                    action=lambda: self.model.move_slot(off.id, 0))

    def set_arrival(self):
        off = self.current_officer()
        if off is None:
            return
        pid = province_index(self.sched_box.get())
        if pid is None:
            messagebox.showinfo('Arrival', 'Pick a province first.')
            return
        year = self.year_box.get().strip()
        self._apply('arrival', None,
                    action=lambda: self.model.set_schedule(off.id, pid, year))

    def clear_arrival(self):
        off = self.current_officer()
        if off is None:
            return
        self._apply('arrival', None,
                    action=lambda: self.model.clear_schedule(off.id))

    def set_heir_year(self):
        off = self.current_officer()
        if off is None:
            return
        year = self.heir_year.get().strip()
        self._apply('reinforce_year', None,
                    action=lambda: self.model.set_reinforce_year(off.id, year))

    # -- report ----------------------------------------------------------
    def _refresh_report(self):
        problems, notes = self.model.report()
        lines = [('problem', 'FAIL: %s' % p) for p in problems]
        if not problems:
            lines.insert(0, ('ok', 'no invariant problems - the assembled '
                                   'banks would pass verify_data_banks.py'))
        lines += [('note', 'note: %s' % n) for n in notes]
        self.report.config(state='normal')
        self.report.delete('1.0', 'end')
        for tag, line in lines:
            self.report.insert('end', line + '\n', tag)
        self.report.config(state='disabled')

    def show_diff(self):
        changes = self.model.changes()
        if not changes:
            self.log_line('no edits since the CSVs were last saved')
            return
        self.log_line('%d edit%s not yet in the CSVs:'
                      % (len(changes), '' if len(changes) == 1 else 's'))
        for line in self.model.change_lines(changes):
            self.log_line('  ' + line)

    def _refresh_title(self):
        changes = len(self.model.changes())
        self.title('Sangokushi 2 officer editor - %s%s'
                   % (os.path.basename(self.model.paths.get('officer', '')),
                      '  [%d unsaved edit%s]'
                      % (changes, '' if changes == 1 else 's')
                      if changes else ''))

    def _status_text(self, count=None):
        shown = count if count is not None else len(self.tree.get_children())
        changes = len(self.model.changes())
        problems = len(self.model.problems())
        parts = ['%d of %d officers' % (shown, len(self.model.officers)),
                 '%d unsaved edit%s' % (changes, '' if changes == 1 else 's'),
                 '%d problem%s' % (problems, '' if problems == 1 else 's')]
        if self.current is not None:
            parts.append(self.current.summary())
        return '   |   '.join(parts)

    # -- file actions ----------------------------------------------------
    def save_csv(self):
        try:
            written = self.model.save()
        except OSError as exc:
            messagebox.showerror('Cannot write CSV', str(exc))
            return None
        self.model.commit()
        self.log_line('saved %s' % ', '.join(os.path.basename(p)
                                             for p in written))
        self._refresh_all()
        self._show_officer(self.current)
        return written

    def write_asm(self):
        """CSVs are the source of truth: save them, then let the repo render.

        The generator and verifier stay the single rendering path, so the GUI
        can never disagree with `make databanks-csv`.
        """
        if not self._repo_tools():
            return
        if self.save_csv() is None:
            return
        self._run([sys.executable, 'tools/gen_data_bank_asm.py', '--bank',
                   'all', '--from-csv', '--write'])
        self._run([sys.executable, 'tools/verify_data_banks.py',
                   '--allow-edits'])

    def verify(self):
        if not self._repo_tools():
            return
        self._run([sys.executable, 'tools/verify_data_banks.py',
                   '--allow-edits'])

    def _repo_tools(self):
        if not self.repo:
            messagebox.showinfo(
                'Standalone mode',
                'The disassembly repo tools are not next to this model copy,\n'
                'so the assembly cannot be regenerated from here.\n'
                'Save the CSVs and run, in the repo:\n'
                '  python3 tools/gen_data_bank_asm.py --bank all --from-csv '
                '--write\n'
                '  python3 tools/verify_data_banks.py --allow-edits')
            return False
        return True

    def _run(self, argv):
        self.log_line('$ ' + ' '.join(a if not a.endswith('.py')
                                      else os.path.relpath(a, self.repo)
                                      for a in argv))
        try:
            r = subprocess.run(argv, cwd=self.repo, capture_output=True,
                               text=True)
        except OSError as exc:
            self.log_line('failed to run: %s' % exc)
            return None
        for line in ((r.stdout or '') + (r.stderr or '')).strip().splitlines():
            self.log_line(line)
        self.log_line('[exit %d]' % r.returncode)
        return r.returncode

    def log_line(self, line):
        self.log.config(state='normal')
        self.log.insert('end', line + '\n')
        self.log.see('end')
        self.log.config(state='disabled')

    # -- keys ------------------------------------------------------------
    def _on_key(self, event):
        if self._typing_focus():
            return
        if event.char == '/':
            self.focus_filter()
        elif event.keysym == 'PageDown':
            self._step(1)
        elif event.keysym == 'PageUp':
            self._step(-1)

    def _typing_focus(self):
        try:
            widget = self.focus_get()
        except (tk.TclError, KeyError):
            return False
        return isinstance(widget, (ttk.Entry, tk.Entry, tk.Text, ttk.Spinbox,
                                   tk.Spinbox, ttk.Combobox))

    def focus_filter(self):
        self.filter_entry.focus_set()
        self.filter_entry.select_range(0, 'end')

    def clear_filter(self):
        if self.filter_var.get():
            self.filter_var.set('')

    def _step(self, delta):
        ids = list(self.tree.get_children())
        if not ids:
            return
        selection = self.tree.selection()
        index = ids.index(selection[0]) if selection else 0
        index = max(0, min(len(ids) - 1, index + delta))
        self.tree.selection_set(ids[index])
        self.tree.see(ids[index])

    # -- closing ---------------------------------------------------------
    def _confirm_discard(self):
        # The model's change set is the only dirty flag: undo can walk back to
        # the saved state, and a second copy of that fact would go stale.
        if not self.model.changes():
            return True
        return messagebox.askyesno(
            'Unsaved edits',
            'Discard the %d edit%s that are not in the CSVs?'
            % (len(self.model.changes()),
               '' if len(self.model.changes()) == 1 else 's'))

    def on_close(self):
        if self._confirm_discard():
            self.destroy()


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--csv', help="officer_data.csv to open (default: the "
                                  "repo's docs/officer_data.csv)")
    ap.add_argument('--province-csv', dest='province_csv',
                    help='province_data.csv holding the roster slots')
    ap.add_argument('--death-csv', dest='death_csv',
                    help='officer_death_years.csv')
    ap.add_argument('--model', help='directory holding officer_model.py')
    ap.add_argument('--repo', help='disassembly checkout whose tools/ render '
                                   'the assembly (default: auto-detect)')
    args = ap.parse_args()
    model, _model_dir = load_model(args.model)
    here = os.path.dirname(os.path.abspath(__file__))
    repo = model.find_repo(args.repo, os.path.dirname(here))
    app = OfficerEditor(model, repo=repo, officer_csv=args.csv,
                        province_csv=args.province_csv,
                        death_csv=args.death_csv)
    app.mainloop()


if __name__ == '__main__':
    main()
