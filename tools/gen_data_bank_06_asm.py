#!/usr/bin/env python3
"""Render asm/banks/data_06_placement_and_scroll.asm from rom/prg/prg_06.bin.

Bank $06 (selected as $26 into the $8000-$9FFF window) holds two things:

  1. The Tactical (war) layer's per-province unit PLACEMENT POOLS and city BOUNDS
     rectangles - the geometry that the `TacticalAttackSideTypeTable` (bank $10
     $9E62) and `TacticalDefenseSideTypeTable` (bank $11 $9AB4) selectors point
     into. Those two selector tables are already documented in data_10_seed.asm and
     data_11_officer.asm; this bank is the arrangement they select.
  2. The strategy 命令書 (OrderScroll) screen graphics: three 14-row panel tile
     blocks and three tables of OAM sprite blobs.

Usage:
    python3 tools/gen_data_bank_06_asm.py              # render to stdout
    python3 tools/gen_data_bank_06_asm.py --write      # overwrite asm/banks/data_06_placement_and_scroll.asm
    python3 tools/verify_data_bank_06.py               # prove it is byte-exact

Every region length, stride and pointer run is asserted against the ROM while the
file is rendered (scene_groups() / check_side_types() / the blob-chain checks in
verify_data_bank_06.py), so a wrong record count fails here rather than showing
up as a byte drift later.
"""
import argparse
import os
import re
import sys
import textwrap

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROM_BANK = os.path.join(ROOT, 'rom', 'prg', 'prg_06.bin')
ASM_PATH = os.path.join(ROOT, 'asm', 'banks', 'data_06_placement_and_scroll.asm')
PROVINCE_IDS = os.path.join(ROOT, 'include', 'province_ids.inc')

WINDOW_CPU = 0x8000
BANK_SIZE = 0x2000
COMMENT_COL = 74
TEXT_WIDTH = 78
BANNER_INDENT = ';   '

SCENE_COUNT = 30                  # war_province_idx ($050E) = adjacency row
ADJ_STRIDE = 8                    # neighbour slots per adjacency row
UNIT_PAIRS = 15                   # unit positions per pool, for unit ids 1-4

POOL_CPU = {'Attack': 0x8000, 'Defense': 0x8C52}
POOL_END = {'Attack': 0x8C52, 'Defense': 0x932E}
POOL_STRIDE = {'Attack': 34, 'Defense': 32}
BOUNDS_CPU = {'Attack': 0x932E, 'Defense': 0x94D6}
BOUNDS_END = {'Attack': 0x94D6, 'Defense': 0x95E6}
BOUNDS_STRIDE = 4
SIDE = {
    'Attack': dict(
        roster='@SetupAttackerRoster $B343', seeds_addr='$B36D',
        seeds=('$02', '$0C', '$16', '$1C'), seeds_name='Attacker',
        selector='bank $10 $9E62 TacticalAttackSideTypeTable',
        selector_file='rom/prg/prg_10.bin', selector_cpu=0x9E62,
        doc='data_10_seed.asm $9E62 block',
        anchor='The anchor itself moves with the type, i.e. the army enters on a flank'),
    'Defense': dict(
        roster='@SetupDefenderRoster $B2E4', seeds_addr='$B30E',
        seeds=('$02', '$08', '$0C', '$14'), seeds_name='Defender',
        selector='bank $11 $9AB4 TacticalDefenseSideTypeTable',
        selector_file='rom/prg/prg_11.bin', selector_cpu=0x9AB4,
        doc='data_11_officer.asm $9AB4 block',
        anchor='Both types keep the same city anchor and only re-array the garrison'),
}

PANEL_CPU = 0x95E6
PANEL_COUNT = 3
PANEL_ROWS = 14
PANEL_COLS = 28
PANEL_SIZE = PANEL_ROWS * PANEL_COLS

BLOB_TABLES = [
    dict(cpu=0x9A7E, count=21, name='StrategyScrollPhase1Sprite',
         title='STRATEGY SCROLL PHASE 1 SPRITE BLOBS'),
    dict(cpu=0x9CD9, count=4, name='StrategyScrollPhase2Sprite',
         title='STRATEGY SCROLL PHASE 2 SPRITE BLOBS'),
    dict(cpu=0x9E75, count=6, name='StrategyScrollPhase3Sprite',
         title='STRATEGY SCROLL PHASE 3 SPRITE BLOBS'),
]
BLOB_RECORD_BYTES = 4             # [y_off, tile, attr, x_off]
BLOB_TERMINATOR = 0x80
FF_CPU = 0x9FBB                   # unused $FF filler to $9FFF


def read(path):
    with open(path, 'rb') as f:
        return f.read()


def cpu16(data, addr):
    o = addr - WINDOW_CPU
    return data[o] | (data[o + 1] << 8)


def take(data, addr, n):
    o = addr - WINDOW_CPU
    return data[o:o + n]


def province_names():
    """id -> 'katakana romaji' from include/province_ids.inc."""
    out = {}
    pat = re.compile(r'^PROVINCE_([A-Z_]+)\s*=\s*(\d+)\s*;\s*(\S+)\s+(\S+)')
    for raw in open(PROVINCE_IDS, encoding='utf-8'):
        m = pat.match(raw)
        if m:
            out[int(m.group(2))] = '%s %s' % (m.group(3), m.group(4))
    return out


NAMES = province_names()


def scene_note(scene):
    return 'province %2d %s' % (scene, NAMES.get(scene, '?'))


def decode_blob(data, addr):
    """One $80-terminated sprite blob -> ([4-byte records], terminator addr)."""
    o = addr - WINDOW_CPU
    recs = []
    while data[o] != BLOB_TERMINATOR:
        recs.append(tuple(data[o:o + BLOB_RECORD_BYTES]))
        o += BLOB_RECORD_BYTES
        if o >= BANK_SIZE:
            raise SystemExit('blob at $%04X never terminates' % addr)
    return recs, WINDOW_CPU + o


# ------------------------------------------------------------- geometry ----
def scene_groups(data, table_cpu, stride, region_end, label):
    """Split a record run into one group per scene from its pointer table."""
    ptrs = [cpu16(data, table_cpu + 2 * i) for i in range(SCENE_COUNT)]
    for a, b in zip(ptrs, ptrs[1:]):
        if b <= a or (b - a) % stride:
            raise SystemExit('%s: pointer run $%04X->$%04X is not a %d-B step'
                             % (label, a, b, stride))
    groups = []
    for i, p in enumerate(ptrs):
        nxt = ptrs[i + 1] if i + 1 < SCENE_COUNT else region_end
        if p + ((nxt - p) // stride) * stride != nxt:
            raise SystemExit('%s: scene $%02X run $%04X..$%04X is not a whole number'
                             ' of %d-B records' % (label, i, p, nxt, stride))
        groups.append([p + stride * k for k in range((nxt - p) // stride)])
    return groups


def selector_maxima(path, cpu):
    """Highest side-type value used in each adjacency row of a selector table."""
    data = read(path)
    out = []
    for scene in range(SCENE_COUNT):
        row = data[cpu + scene * ADJ_STRIDE - WINDOW_CPU:
                   cpu + scene * ADJ_STRIDE - WINDOW_CPU + ADJ_STRIDE]
        vals = [v for v in row if not v & 0x80]
        out.append(max(vals) if vals else 0)
    return out


def check_side_types(groups, side):
    cfg = SIDE[side]
    for scene, (n, top) in enumerate(zip(
            (len(g) for g in groups),
            selector_maxima(os.path.join(ROOT, cfg['selector_file']),
                            cfg['selector_cpu']))):
        if n != top + 1:
            raise SystemExit('%s: %s reserves %d pool(s) but %s reaches side type %d'
                             % (side, scene_note(scene), n, cfg['selector'], top))


def cursor_split(side):
    """Pairs each of the four unit cursors reads. A run ends where the next seed
    starts; the fourth runs out the fixed complement of UNIT_PAIRS."""
    seeds = [int(s.lstrip('$'), 16) for s in SIDE[side]['seeds']]
    runs = [(b - a) // 2 for a, b in zip(seeds, seeds[1:])]
    runs.append(UNIT_PAIRS - sum(runs))
    return runs


# ---------------------------------------------------------------- output ----
def line(directive, operands, addr, emitted, note=None):
    head = '  %s %s' % (directive, operands)
    comment = '; $%04X: %s' % (addr, ' '.join('%02X' % b for b in emitted))
    if note:
        comment += '  ; ' + note
    return head + ' ' * max(1, COMMENT_COL - len(head)) + comment


def byte_line(addr, bs, note=None):
    return line('.byte', ', '.join('$%02X' % b for b in bs), addr, bs, note)


def word_line(addr, value, symbol, note=None):
    return line('.word', symbol, addr, [value & 0xFF, value >> 8], note)


def wrap(paragraph):
    """Re-wrap one prose paragraph to the banner width. A paragraph that starts
    with two spaces is a bullet/continuation block and keeps a deeper indent.
    Every output line carries the `;` - a dropped comment marker would assemble
    as a statement."""
    bullet = paragraph.startswith('  ')
    prefix = ';     ' if bullet else BANNER_INDENT
    return textwrap.wrap(paragraph.strip(), width=TEXT_WIDTH, initial_indent=prefix,
                         subsequent_indent=prefix, break_on_hyphens=False,
                         break_long_words=False)


def banner(title, span, paragraphs):
    out = [';' + '-' * 79, '; %s  (%s)' % (title, span)]
    for i, para in enumerate(paragraphs):
        out += wrap(para)
        if para.startswith('  ') and i + 1 < len(paragraphs) \
                and not paragraphs[i + 1].startswith('  '):
            out.append(';')
    out.append(';' + '-' * 79)
    return out


def emit_pool_table(side, groups):
    cpu, stride = POOL_CPU[side], POOL_STRIDE[side]
    cfg = SIDE[side]
    prose = [
        '30 x .word, indexed by war_province_idx ($050E) * 2 - the row index into bank $10\'s'
        " ProvinceAdjacencyTable $9D72, whose row belongs to province $050E. Each entry is the"
        " BASE of that province's record run. The %s-side type selector (%s) is a list INDEX,"
        ' not a count: it is scaled by %d and added to the base. The selector is keyed on the'
        ' adjacency SLOT holding province $052A in that row, so it is a per-approach-route'
        ' choice, not a per-province one.'
        % (side.lower(), cfg['selector'], stride),
        'Readers, all with this bank armed at $8000:',
        '  prg_08_09_tactical_war %s - war AI / war scene setup. prg_0c_0d_tactical_commands @BuildOfficerList'
        ' $C3DC/$C42B - army-deploy scene.' % cfg['roster'],
    ]
    if side == 'Defense':
        prose += ['  prg_08_09_tactical_war GetOrderedDestination $A1E5 - reads pair 0 (the anchor) as the'
                  ' ordered march destination of a faction-assigned officer.']
    out = banner('TACTICAL %s UNIT PLACEMENT POOL POINTERS' % side.upper(),
                 '$%04X-$%04X' % (cpu, cpu + 2 * SCENE_COUNT - 1), prose)
    out.append('Tactical%sPoolPtrTable:' % side)
    for scene, recs in enumerate(groups):
        out.append(word_line(cpu + 2 * scene, recs[0],
                             'Tactical%sPool_%02d_0' % (side, scene),
                             '%s -> $%04X, %d pool(s) for types 0-%d'
                             % (scene_note(scene), recs[0], len(recs), len(recs) - 1)))
    return out


def emit_pool_records(side, data, groups):
    stride = POOL_STRIDE[side]
    pairs = stride // 2
    first, last = groups[0][0], groups[-1][-1]
    split = cursor_split(side)
    cfg = SIDE[side]
    rows = [b for recs in groups for addr in recs for b in take(data, addr, stride)[0::2]]
    cols = [b for recs in groups for addr in recs for b in take(data, addr, stride)[1::2]]
    tail = stride - 2 - 2 * UNIT_PAIRS
    prose = [
        '%d pools x %d B = %d (row,col) tile pairs in one fixed order: pair 0 is the entry'
        ' ANCHOR, then the %d unit positions used by unit ids 1-4. prg_08_09_tactical_war %s points ($20) at'
        ' the pool chosen by the province/adjacency side type and seeds the four per-unit read'
        ' cursors $0022-$0025 from @%sCursorSeeds %s (%s). A cursor run ends where the next one'
        ' starts, so the seeds split the %d unit pairs %s by slot; each unit reads the pair at'
        ' its own cursor and advances it by 2 (@StoreCoordinates $B266 / $B285-$B2A4), storing'
        ' into unit_coord_y/x ($0614/$0600).'
        % (sum(len(g) for g in groups), stride, pairs, UNIT_PAIRS, cfg['roster'],
           cfg['seeds_name'], '/'.join(cfg['seeds']), cfg['seeds_addr'],
           UNIT_PAIRS, '/'.join(str(x) for x in split)),
    ]
    if tail:
        prose += ['The final %d bytes of every pool - one (row,col) pair - lie past the fourth'
                  " cursor's reach; no known reader touches them." % tail]
    prose += [
        'prg_0c_0d_tactical_commands @BuildOfficerList walks the same run from pair 1, looking for the first tile'
        ' NOT already held by an officer (SearchRosterByTileCoord $D6B6), and gives that tile to'
        ' the unit being deployed. Rows skip 15: observed values %s with $0F unused, and a reader'
        ' that needs the 0-19 space subtracts 1 from anything >= $10 (GetOrderedDestination'
        ' $A1FF-$A204) while the war AI stores the byte through unchanged. Columns %s on the'
        ' 32-wide x 20-high tactical map. %s. Per-side measurements: %s.'
        % (span_of(rows), span_of(cols), cfg['anchor'], cfg['doc']),
    ]
    out = banner('TACTICAL %s UNIT PLACEMENT POOLS' % side.upper(),
                 '$%04X-$%04X' % (first, last + stride - 1), prose)
    for scene, recs in enumerate(groups):
        for k, addr in enumerate(recs):
            bs = take(data, addr, stride)
            extra = pairs - 1 - UNIT_PAIRS
            tail_txt = (' + %d pair past the cursors' % extra if extra == 1
                        else ' + %d pairs past the cursors' % extra) if extra else ''
            out.append('')
            out.append('; %s, %s side type %d - anchor (%d,%d) + %d unit tiles%s'
                       % (scene_note(scene), side.lower(), k, bs[0], bs[1],
                          UNIT_PAIRS, tail_txt))
            out.append('Tactical%sPool_%02d_%d:' % (side, scene, k))
            for off in range(0, stride, 8):
                chunk = bs[off:off + 8]
                pairs_txt = ' '.join('(%d,%d)' % (chunk[i], chunk[i + 1])
                                     for i in range(0, len(chunk) - 1, 2))
                if tail and off == stride - 2:
                    note = 'unreached pair (%d,%d)' % (chunk[0], chunk[1])
                elif off == 0:
                    rest = ' '.join('(%d,%d)' % (chunk[i], chunk[i + 1])
                                    for i in range(2, len(chunk) - 1, 2))
                    note = 'anchor (%d,%d) | units %s' % (chunk[0], chunk[1], rest)
                else:
                    note = 'units ' + pairs_txt
                out.append(byte_line(addr + off, chunk, note))
    return out


def emit_bounds_table(side, groups):
    cpu = BOUNDS_CPU[side]
    prose = [
        '30 x .word, same province index and the same side-type scaling as the pool table'
        ' above; the pointee run holds exactly one 4-byte rectangle per pool of this side.',
        'Reader: prg_0c_0d_tactical_commands @CheckBoundsForPosition $C447 (defense, army-deploy mode $050B = 2)'
        ' and @OtherModeBounds $C48E (attack) form ($10) = table[$050E*2] + type*$04 and keep'
        ' CARRY SET only if the cursor tile lies inside the rectangle - the gate on which map'
        " tile the 出兵 army-deploy command may select. The rectangle is the selectable city"
        ' area, not the bounding box of the paired placement pool: the two tables answer'
        ' different questions and are reached with one index.',
    ]
    out = banner('TACTICAL %s CITY BOUNDS RECTANGLE POINTERS' % side.upper(),
                 '$%04X-$%04X' % (cpu, cpu + 2 * SCENE_COUNT - 1), prose)
    out.append('Tactical%sBoundsPtrTable:' % side)
    for scene, recs in enumerate(groups):
        out.append(word_line(cpu + 2 * scene, recs[0],
                             'Tactical%sBounds_%02d_0' % (side, scene),
                             '%s -> $%04X, %d rect(s)'
                             % (scene_note(scene), recs[0], len(recs))))
    return out


def emit_bounds_records(side, data, groups):
    first, last = groups[0][0], groups[-1][-1]
    all_bs = [take(data, addr, BOUNDS_STRIDE) for recs in groups for addr in recs]
    dup = sum(1 for a, b in zip(all_bs, all_bs[1:]) if a == b)
    if dup:
        share = ('Adjacent side types often share one rectangle (%d of the %d consecutive'
                 ' pairs here are byte-identical): on this side the selector changes the'
                 ' placement array, not the city area - see the %s note in %s.'
                 % (dup, len(all_bs) - 1, side.lower(), SIDE[side]['doc']))
    else:
        share = ('No two adjacent side types share a rectangle here (0 of the %d consecutive'
                 ' pairs are byte-identical): on this side each type carries its own city'
                 ' area as well as its own placement array - see the %s note in %s.'
                 % (len(all_bs) - 1, side.lower(), SIDE[side]['doc']))
    prose = [
        '%d rectangles [row_min, col_min, row_max_excl, col_max_excl], one per pool at the'
        ' same index. Field ranges as stored: row_min %s, row_max %s, col_min %s, col_max'
        ' %s. Rows carry the same 15-skipping encoding as the pools.'
        % (len(all_bs), span_of([b[0] for b in all_bs]), span_of([b[2] for b in all_bs]),
           span_of([b[1] for b in all_bs]), span_of([b[3] for b in all_bs])),
        share,
    ]
    out = banner('TACTICAL %s CITY BOUNDS RECTANGLES' % side.upper(),
                 '$%04X-$%04X' % (first, last + BOUNDS_STRIDE - 1), prose)
    for scene, recs in enumerate(groups):
        for k, addr in enumerate(recs):
            bs = take(data, addr, BOUNDS_STRIDE)
            out.append('')
            out.append('; %s, %s side type %d - rows [%d,%d) cols [%d,%d)'
                       % (scene_note(scene), side.lower(), k, bs[0], bs[2], bs[1], bs[3]))
            out.append('Tactical%sBounds_%02d_%d:' % (side, scene, k))
            out.append(byte_line(addr, bs))
    return out


def emit_panels(data):
    prose = [
        '%d blocks of %d rows x %d tile bytes - the tile rows of strategy scroll phases 1-3.'
        % (PANEL_COUNT, PANEL_ROWS, PANEL_COLS),
        'The scroll machine prg_17_18_display StrategyCommandDispatch ($D693) dispatches on'
        ' strat_scroll_param ($0541) as a PHASE index (6 handlers; phases chain with INC $0541'
        ' at $D831/$D8B8/$D90C), and ScrollPanel_LoadRow is called from exactly three of them'
        ' - $D7B7, $D847 and $D8D6 - so $0541 = 1/2/3 select blocks 1/2/3 through the local'
        ' ScrollPanel_DataPtrTable ($DCD5 = $95E6/$976E/$98F6). Phases 4-6 never read this'
        ' bank.',
        'Each call copies one 28-byte row into the $0383 tile buffer and terminates it with'
        ' $FF (count $1C at $0380); the PPU target is ($0381,$0382) = dispatch_offset_ptr'
        ' ($04D4/$04D5), seeded $2082 at $DCC8/$DCCD and stepped by $20 per call. So a block'
        ' streams %d nametable rows - rows 4-17 of PPU $2000, columns 2-29, screen x 16-239'
        ' and y 32-143 - the framed inner area of the scroll.' % PANEL_ROWS,
        'The attribute bytes for that same area do NOT come from this bank: the first call of'
        " each phase (dispatch_step < 2, $DC7E) streams 32 bytes of the local"
        ' ScrollPanel_RowTemplate_Ornate/Solid/Plain ($DCDB) to $23C8, i.e. attribute rows'
        ' 1-4. Those three local records are attribute payloads, whatever',
        " ScrollPanel_PrepareRowData's comment calls them.",
        'UNPROVEN: the CHR page set live while a panel is drawn is not identified in this'
        ' project, so no claim is made about what these tile values depict; they are rendered'
        ' as raw bytes.',
    ]
    out = banner('STRATEGY SCROLL PHASE TILE BLOCKS',
                 '$%04X-$%04X' % (PANEL_CPU, PANEL_CPU + PANEL_COUNT * PANEL_SIZE - 1),
                 prose)
    for i in range(PANEL_COUNT):
        base = PANEL_CPU + i * PANEL_SIZE
        out.append('')
        out.append('; phase %d block ($0541 = %d, armed via ScrollPanel_DataPtrTable entry %d)'
                   ' - %d rows x %d tiles' % (i + 1, i + 1, i + 1, PANEL_ROWS, PANEL_COLS))
        out.append('StrategyScrollPhase%dTileRows:' % (i + 1))
        for r in range(PANEL_ROWS):
            row = base + r * PANEL_COLS
            for off in (0, 16):
                n = 16 if off == 0 else PANEL_COLS - 16
                out.append(byte_line(row + off, take(data, row + off, n),
                                     'row %d (PPU $%04X)%s'
                                     % (r, 0x2082 + r * 0x20,
                                        '' if off == 0 else ' tail')))
    return out


BLOB_NOTES = {
    0x9A7E: [
        '21 x .word, 1-based index -> $80-terminated OAM blobs. Sprites land at screen',
        ' x = x_off + $10, y = y_off + $1F - 1 (OAM stores Y-1): RenderDispatchSprite ($DBF3)',
        ' forces the writer bases itself - X $000C = $10 at $DBF3/$DBF5, Y $000A = $1F at',
        ' $DC06/$DC08, tile bias $0003 = 0 at $DC0B/$DC0D and flip/attr EOR $0002 = 0 - so',
        " the blob's own attr byte is used unchanged and no caller alters it.",
        'prg_17_18_display StrategyCommand_InitOfficerScroll ($D6AA) arms ($10/$11) = $9A7E ($D6D7-$D6DD)',
        ' and calls RenderDispatchSprite three times per pass: index dispatch_src_ptr_lo',
        ' ($04CA, 1..8), then $04CA+4 (5..12), then dispatch_src_ptr_hi ($04CB, 9..21), the',
        ' last skipped when that byte is negative (BMI $D6E2). $04CA comes from the scroll row',
        " offset at $D6F7-$D702 ($04CD >> 3 & 3 + 1).",
        'The 9..21 half is a SEQUENCE, not a lookup of a subject id: $04CB =',
        " SpriteBlobIndexTable[$04CE >> 2] ($D71D-$D723, that table's only read site) and $04CE is",
        ' a pass counter (cleared $D6B4, INC $D71A/$D7E4/$D874/$D8FB). Its 24 bytes - $09..$15',
        ' with repeats, three $F0 and a closing $FE - are therefore the blob played at each',
        ' pass, where bit7 ($F0) means "draw no sprite this pass" and $FE is the end sentinel',
        " tested at $D708. Despite its name SpriteBlobIndexTable holds no PRG bank numbers.",
    ],
    0x9CD9: [
        '4 x .word, 1-based index. prg_17_18_display StrategyCommand_ScrollIntroPanel ($D795) arms',
        ' ($10/$11) = $9CD9 at $D7E7-$D7ED and calls RenderDispatchSprite with',
        ' dispatch_src_ptr_lo ($04CA) = 1..4, one blob per pass of that phase. All four blobs',
        ' hold exactly 25 records: one 25-sprite layout re-emitted four times with only the',
        ' tile bytes differing.',
    ],
    0x9E75: [
        '6 x .word, 1-based index. prg_17_18_display StrategyCommand_ScrollTextPhase2 ($D82A) arms',
        ' ($10/$11) = $9E75 at $D877-$D87D and calls RenderDispatchSprite twice per pass, with',
        ' $04CA (1..3) and $04CA+3 (4..6), so two blobs layer per pass. $04CA is clamped to 3',
        ' at $D897, so the index space really is 1..6.',
    ],
}


def emit_blob_table(data, spec, note):
    cpu, count, name = spec['cpu'], spec['count'], spec['name']
    all_recs = []
    for i in range(count):
        recs, _term = decode_blob(data, cpu16(data, cpu + 2 * i))
        all_recs += recs
    prose = list(note) + [
        'Measured over the %d records of this table: tile $%02X-$%02X, y_off $%02X-$%02X,'
        ' x_off $%02X-$%02X, attr values %s.'
        % (len(all_recs), min(r[1] for r in all_recs), max(r[1] for r in all_recs),
           min(r[0] for r in all_recs), max(r[0] for r in all_recs),
           min(r[3] for r in all_recs), max(r[3] for r in all_recs),
           ', '.join('$%02X' % a for a in sorted(set(r[2] for r in all_recs)))),
    ]
    out = banner(spec['title'], '$%04X-$%04X' % (cpu, cpu + 2 * count - 1), prose)
    out.append('%sPtrTable:' % name)
    for i in range(count):
        p = cpu16(data, cpu + 2 * i)
        out.append(word_line(cpu + 2 * i, p, '%s_Blob%d' % (name, i),
                             'index %d -> blob $%04X' % (i + 1, p)))
    end = None
    for i in range(count):
        p = cpu16(data, cpu + 2 * i)
        recs, term = decode_blob(data, p)
        end = term + 1
        bs = take(data, p, BLOB_RECORD_BYTES * len(recs) + 1)
        out.append('')
        out.append('; blob index %d (@$%04X): %d [y,tile,attr,x] records,'
                   ' $%02X terminator @ $%04X' % (i + 1, p, len(recs),
                                                  BLOB_TERMINATOR, term))
        out.append('%s_Blob%d:' % (name, i))
        for off in range(0, len(bs), 16):
            chunk = bs[off:off + 16]
            note = ('terminator $%02X' % BLOB_TERMINATOR
                    if off and off + 16 >= len(bs) and chunk[-1] == BLOB_TERMINATOR
                    else None)
            out.append(byte_line(p + off, chunk, note))
    return out, end


def emit_filler(data):
    bs = data[FF_CPU - WINDOW_CPU:]
    out = ['', 'Bank06Filler:']
    for off in range(0, len(bs), 16):
        chunk = bs[off:off + 16]
        out.append(byte_line(FF_CPU + off, chunk,
                             'unused $FF filler, %d B past the last blob' % len(bs)
                             if off == 0 else None))
    return out


def span_of(values):
    vals = list(values)
    return '$%02X-$%02X' % (min(vals), max(vals))


def render(data):
    pools, bounds = {}, {}
    for side in ('Attack', 'Defense'):
        pools[side] = scene_groups(data, POOL_CPU[side], POOL_STRIDE[side],
                                   POOL_END[side], '%s placement pools' % side)
        bounds[side] = scene_groups(data, BOUNDS_CPU[side], BOUNDS_STRIDE,
                                    BOUNDS_END[side], '%s bounds rects' % side)
        check_side_types(pools[side], side)
        if [len(g) for g in pools[side]] != [len(g) for g in bounds[side]]:
            raise SystemExit('%s pool and rectangle runs diverge per province' % side)

    out = header(pools, bounds)
    out.append('')
    for side in ('Attack', 'Defense'):
        out += emit_pool_table(side, pools[side])
        out.append('')
        out += emit_pool_records(side, data, pools[side])
        out.append('')
    for side in ('Attack', 'Defense'):
        out += emit_bounds_table(side, bounds[side])
        out.append('')
        out += emit_bounds_records(side, data, bounds[side])
        out.append('')
    out += emit_panels(data)
    out.append('')
    prev_end = PANEL_CPU + PANEL_COUNT * PANEL_SIZE
    for i, spec in enumerate(BLOB_TABLES):
        if spec['cpu'] != prev_end:
            raise SystemExit('blob table $%04X does not follow the previous region '
                             '(ends $%04X)' % (spec['cpu'], prev_end))
        lines, prev_end = emit_blob_table(data, spec, BLOB_NOTES[spec['cpu']])
        out += lines
        if i < len(BLOB_TABLES) - 1:
            out.append('')
    if prev_end != FF_CPU:
        raise SystemExit('last blob must end at the $FF filler ($%04X != $%04X)'
                         % (prev_end, FF_CPU))
    out += emit_filler(data)
    out.append('')
    return '\n'.join(out)


def header(pools, bounds):
    n_atk = sum(len(g) for g in pools['Attack'])
    n_def = sum(len(g) for g in pools['Defense'])
    rows = [
        ('$8000-$803B', '30 x .word', 'attack-side unit placement pool bases'),
        ('$803C-$8C51', '%d x 34 B' % n_atk, '(17 (row,col) pairs: anchor + 15 units)'),
        ('$8C52-$8C8D', '30 x .word', 'defense-side unit placement pool bases'),
        ('$8C8E-$932D', '%d x 32 B' % n_def, '(16 (row,col) pairs: anchor + 15 units)'),
        ('$932E-$9369', '30 x .word', 'attack-side city bounds rectangle bases'),
        ('$936A-$94D5', '%d x  4 B' % n_atk, '[row_min,col_min,row_max,col_max]'),
        ('$94D6-$9511', '30 x .word', 'defense-side city bounds rectangle bases'),
        ('$9512-$95E5', '%d x  4 B' % n_def, ''),
        ('$95E6-$9A7D', '3 x 392 B', 'strategy scroll phase 1-3 tile rows (14 x 28)'),
        ('$9A7E-$9AA7', '21 x .word', 'strategy scroll phase 1 sprite blobs'),
        ('$9AA8-$9CD8', '21 blobs', ''),
        ('$9CD9-$9CE0', '4 x .word', 'strategy scroll phase 2 sprite blobs'),
        ('$9CE1-$9E74', '4 blobs', ''),
        ('$9E75-$9E80', '6 x .word', 'strategy scroll phase 3 sprite blobs'),
        ('$9E81-$9FBA', '6 blobs', ''),
        ('$9FBB-$9FFF', '69 B', 'unused $FF filler'),
    ]
    lines = [';   %s  %-10s %s' % row for row in rows]
    return [
        ';===============================================================================',
        '; DATA Bank 06 (PRG $06) - 8KB data bank, mapped into $8000-$9FFF by SwitchBank8;',
        '; no code lives here (see code/bank_switch_map.md 5.2).',
        ';',
        '; GENERATED by tools/gen_data_bank_06_asm.py --write; byte-exactness and the derived',
        '; geometry are enforced by tools/verify_data_bank_06.py. Raw source:',
        '; rom/prg/prg_06.bin (read-only) - do not hand-edit the rendered records.',
        ';',
        '; Two very different payloads share the bank:',
        ';   $8000-$95E5  the Tactical (war) layer\'s unit placement geometry - the records',
        ';        that the attack/defense "side type" selectors point into.',
        ';   $95E6-$9FBB  graphics for the strategy scroll screen machine in prg_17_18_display',
        ';        (StrategyCommandDispatch $D693): tile rows and OAM sprite blobs.',
        ';',
        '; Selected as $26 ($26 & $1F = $06) from eight sites in three consumer banks:',
        ';   prg_08_09_tactical_war  GetOrderedDestination $A1E5, @SetupDefenderRoster $B2E4,',
        ';              @SetupAttackerRoster $B343     - war AI unit placement',
        ';   prg_0c_0d_tactical_commands  @BuildOfficerList $C3DC/$C42B and @CheckBoundsForPosition',
        ';              $C455/$C495 (ArmyDeployDispatch)  - army-deploy command',
        ';   prg_17_18_display  StrategyCommandDispatch $D693, ScrollPanel_LoadRow $DC13 and',
        ';              RenderDispatchSprite $DBF3     - strategy scroll screens',
        ';',
        '; Layout (window addresses; file offset = addr - $8000):',
    ] + lines + [
        ';',
        '; The four 30-entry selector tables and their record runs tile $8000-$95E6 with no',
        '; gaps: per province the pool count equals the highest side type that province uses',
        '; in the matching selector table (attack: bank $10 $9E62, defense: bank $11 $9AB4)',
        '; plus one, and the bounds run carries exactly one rectangle per pool. Both',
        '; selector tables are documented in data_10_seed.asm / data_11_officer.asm - this bank is the',
        '; arrangement they select.',
        ';',
        '; Sprite blobs use the B1F_SpriteOamWriterSimple format ($F1AD, prg_1f_boot): repeated',
        '; [y_off, tile, attr, x_off] quads terminated by a leading $80 byte. Screen',
        '; position = (y_off + Y base $000A, x_off + X base $000C), tile + $0003 bias, attr',
        '; EOR $0002 flip flags. Same format as the blobs in asm/banks/data_01_bg_and_sprites.asm.',
        ';',
        '; Original binary: rom/prg/prg_06.bin',
        ';===============================================================================',
        '',
        '.segment "CODE_BANK06"',
    ]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--write', action='store_true',
                    help='overwrite asm/banks/data_06_placement_and_scroll.asm (default: stdout only)')
    args = ap.parse_args()
    text = render(read(ROM_BANK))
    if args.write:
        with open(ASM_PATH, 'w', encoding='utf-8') as f:
            f.write(text)
        print('wrote %s (%d lines)' % (ASM_PATH, text.count('\n') + 1))
    else:
        sys.stdout.write(text)
    return 0


if __name__ == '__main__':
    sys.exit(main())
