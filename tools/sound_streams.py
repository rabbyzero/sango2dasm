#!/usr/bin/env python3
"""Decoder for the Namco-163 sound command streams (PRG bank $02 + bank $03 head).

The sound note player B1F_SoundNotePlayer ($E609, bank $1F) copies the 4-byte
descriptor at $8000+soundID*4 into a sound-RAM track block at $0700+X, and the
NMI driver B0E/B0F BattleAnimSoundEngine ($D8D4) + BattleSoundChannelProc
($DC59) then plays it. Everything this module decodes follows those two
routines; the field routing is not inferred from the data.

Descriptor (bank $02, $8000-$82DB, index = soundID, stride $04):
    b0 -> X          sound-RAM track offset (stride $16, 11 tracks)
    b1 -> $0701,X    hardware channel index 0-7 (0-3 = APU, 4-7 = Namco-163)
    b2 -> $0702,X    stream pointer LOW  byte
    b3 -> $0703,X    stream pointer HIGH byte, stored as b3 + $40
    $0700,X <- $00   track armed ($FF = idle)          (prg_1f.asm:1096-1150)

The driver maps two windows before walking a stream (prg_0e_0f.asm:8945-8950):
    LDY #$22 ; JSR SwitchBank8_B      -> $8000-$9FFF = PRG bank $02
    LDA #$23 ; ORA #$C0 ; STA $E800   -> $A000-$BFFF = PRG bank $03
so a stream pointer is a real CPU address and the sound data spans bank $02
$82DC-$9FFF plus bank $03 $0000-$0965 as one contiguous area.

Stream layout, proven by @InitChannel ($D958) and @CmdProcess/@CmdLoop
($D99B-$DA15, $DB21-$DBF0):

    +0 .. +3   note-record header
        +0  bits0-3 = frames-per-tick - 1, bit7 = use NoteFreqTable row 2
        +1  duty source: only reaches the volume byte when entered with C=1
            (the $A2 path); at init it extracts 0, so it is inert here
        +2  channel control byte, written to $4000/$4004/$4008/$400C (APU) or
            the 163 volume/wave register - bits0-3 volume, bit4 envelope mode,
            bits6-7 duty
        +3  sweep byte, written to $4001+channel
    +4 ..      2-byte command cells [opcode][operand]; the cell index (the
            driver's "state") counts cells, so a jump operand is a cell number

Command alphabet (dispatch chain prg_0e_0f.asm:9051-9231):

    opcode < $A0   pitch. low nibble = semitone over NoteFreqTable row 1
                   (F1..E2, measured within 3% of equal temperament), bits4-6 =
                   number of right-shifts of the period = octaves up; low
                   nibble $C-$F = rest. operand = sustain in ticks. On the
                   noise channel (hw 3) the opcode is a raw period (< $10) and
                   the pitch table is skipped; on Namco channels (hw >= 4) the
                   table index is based at +$30 (separate divisor rows).
    $A0 nn         control byte = (byte & $C0) | nn          (triangle: inert)
    $A1 nn         sweep byte = nn
    $A2 nn         duty = nn & 3, keeps the low 5 volume bits
    $A3 nn         vibrato on: rate = (nn & $0F) * 2 frames, source = nn & $70
                   selects a ToneOffsetTable row, sets the track's bit-7 flag
    $A4            vibrato off (operand slot holds filler)
    $AD nn         relocate the stream pointer past the cells and re-read a
                   4-byte header at it - not used by this ROM
    $AE nn         duration-bit rewrite (2 uses)
    $AF nn         tick divisor = nn & $0F
    $B0 nn         goto cell nn (nn = 0 -> the $FD marker)
    $Bn nn         goto cell nn (0 -> the $FD marker) n times; nn = 0 uses
                   counter A, nn != 0 counter B, so two loops can nest
    $Cn nn         tremolo/envelope: period = nn frames, depth source = n;
                   only armed when the control byte's bit4 is set
    $Dn / $En nn   volume triangle LFO: +/-1 per nn ticks, n steps each way,
                   bounded to the volume bits $10-$1F
    $FD            save loop marker; the operand slot is always $FE filler
    $F0-$FE        no-op cell (operand slot is a separate cell's opcode)
    $FF            end of stream. Its operand byte is NOT consumed, so the next
                   stream starts on the very next byte - the area is packed.

Absolute pitch names in this module are the pulse-channel reference; the
triangle channel plays the same period values 3 octaves higher (its counter
runs at half the pulse rate) and the 163 channels use their own divisor rows.

Usage:
    python tools/sound_streams.py --validate    # region coverage + format proof
    python tools/sound_streams.py --stats
    python tools/sound_streams.py --dump 08 98  # one stream as annotated asm text
"""
import argparse
import collections
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK02_BIN = os.path.join(ROOT, 'rom', 'prg', 'prg_02.bin')
BANK03_BIN = os.path.join(ROOT, 'rom', 'prg', 'prg_03.bin')

DESC_CPU = 0x8000          # SoundNoteHeaderTable: 184 x 4-byte entries
DESC_SIZE = 4
DESC_COUNT = 184           # soundID $00-$B7; entry $B7's row doubles as a note
SHARED_NOTE_CPU = 0x82DC   # the note 17 ptr words target = entry $B7's 4 bytes
STREAM_B02_END = 0xA000    # bank $02 side of the stream area
STREAM_B03_END = 0xA000 + 0x0966   # last byte + 1 (bank $03 offset $0966)
PTR_HIGH_BIAS = 0x40       # descriptor b3 + $40 = stream pointer high byte
TRACK_STRIDE = 0x16
TICK_BASE = 1              # frames per tick when the divisor byte is 0

FCH = ['F', 'F#', 'G', 'G#', 'A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E']

CH_NAME = ['pulse1', 'pulse2', 'triangle', 'noise',
           'namco1', 'namco2', 'namco3', 'namco4']


def ctrl_fields(ctrl):
    """Channel control byte ($4000-style) decoded into its three fields."""
    return 'vol %d %s duty %d' % (ctrl & 0x0F, 'env' if ctrl & 0x10 else 'fixed',
                                  (ctrl >> 6) & 3)


def note_name(op):
    """Pitch opcode -> (name, rest?) using the pulse reference octave F1."""
    semi = op & 0x0F
    if semi >= 0x0C:
        return 'rest', True
    shift = (op >> 4) & 0x07
    octave = 1 + shift + (1 if semi >= 7 else 0)
    return '%s%d' % (FCH[semi], octave), False


class SoundData:
    """The two sound windows as one address space."""

    def __init__(self, b02=None, b03=None):
        self.b02 = b02 if b02 is not None else _read(BANK02_BIN)
        self.b03 = b03 if b03 is not None else _read(BANK03_BIN)

    def read(self, addr):
        addr &= 0xFFFF
        if 0x8000 <= addr < 0xA000:
            return self.b02[addr - 0x8000]
        if 0xA000 <= addr < 0xC000:
            return self.b03[addr - 0xA000]
        raise KeyError('$%04X is outside the two sound windows' % addr)

    def read_block(self, addr, n):
        return [self.read(addr + i) for i in range(n)]

    def descriptors(self):
        out = []
        for sid in range(184):
            b = self.read_block(DESC_CPU + sid * DESC_SIZE, DESC_SIZE)
            out.append({
                'id': sid,
                'slot': b[0],
                'track': b[0] // TRACK_STRIDE if b[0] % TRACK_STRIDE == 0 else None,
                'channel': b[1],
                'ch_name': CH_NAME[b[1] & 7],
                'addr': ((b[3] + PTR_HIGH_BIAS) << 8) | b[2],
                'raw': b,
            })
        return out


def _read(path):
    with open(path, 'rb') as f:
        return f.read()


def decode_cell(op, arg, tick, hw, is_namco):
    """(bytes_consumed, tag, detail) for one command cell.

    `tag` is the compact form used in generated asm comments; `detail` is the
    longer wording used by --dump.
    """
    if op < 0xA0:
        frames = arg * tick
        if hw == 3:                                     # noise: raw period
            tag = ('noise$%02X/%d' % (op, arg)) if op < 0x10 else \
                  ('noise?%02X/%d' % (op, arg))
            return 2, tag, 'noise period $%02X, sustain %d ticks = %d frames' \
                % (op, arg, frames)
        name, rest = note_name(op)
        if rest:
            return 2, 'rest/%d' % arg, \
                'rest %d ticks = %d frames (pitch nibble $%X)' % (arg, frames, op & 0x0F)
        tag = '%s/%d' % (name, arg)
        detail = 'sustain %d ticks = %d frames' % (arg, frames)
        if hw == 2:
            detail += '; triangle sounds 3 octaves higher'
        elif is_namco:
            detail += '; 163 channel: NoteFreqTable index based at +$30'
        return 2, tag, detail
    if op == 0xA0:
        return 2, 'ctrl=$%02X' % arg, \
            'control byte = (byte & $C0) | $%02X -> %s' % (arg, ctrl_fields(arg))
    if op == 0xA1:
        return 2, 'sweep=$%02X' % arg, 'sweep byte = $%02X, written to $4001+channel' % arg
    if op == 0xA2:
        return 2, 'duty=%d' % (arg & 3), \
            'duty %d from operand $%02X, volume bits kept' % (arg & 3, arg)
    if op == 0xA3:
        return 2, 'vib r%d s$%02X' % (arg & 0x0F, arg & 0x70), \
            'timer %d frames, ToneOffsetTable select $%02X' \
            % ((arg & 0x0F) * 2, arg & 0x70)
    if op == 0xA4:
        return 2, 'vib off', 'operand slot is filler $%02X' % arg
    if op == 0xAD:
        return 2, 'reloc', 'stream += 2*state, re-read 4-byte header at it'
    if op == 0xAE:
        return 2, 'durw', 'operand $%02X folded into the duration byte' % arg
    if op == 0xAF:
        return 2, 'tick=%d' % (arg & 0x0F), 'frames per tick = %d' % ((arg & 0x0F) + 1)
    if op == 0xB0:
        return 2, 'goto %s' % ('mark' if arg == 0 else 'c%d' % arg), 'unconditional jump'
    if 0xB1 <= op <= 0xBF:
        return 2, 'loop %s x%d' % ('mark' if arg == 0 else 'c%d' % arg, op & 0x0F), \
            'counter %s, %d extra passes' % ('A' if arg == 0 else 'B', op & 0x0F)
    if 0xC0 <= op <= 0xCF:
        return 2, 'trem d%d p%d' % (op & 0x0F, arg), \
            'envelope depth %d, period %d frames (needs control bit4)' % (op & 0x0F, arg)
    if 0xD0 <= op <= 0xEF:
        step = op & 0x0F
        return 2, 'env%s%d/%d' % ('-' if op >= 0xE0 else '+', step, arg), \
            'volume LFO, %d steps of +/-1 every %d ticks' % (step, arg)
    if op == 0xFD:
        return 2, 'mark', 'loop marker, operand slot is filler $%02X' % arg
    if op == 0xFF:
        return 1, 'end', 'track stops; the next byte starts the next stream'
    return 2, 'nop', 'no-op cell (opcode range $F0-$FE)'


def walk(sd, start, hw=0, cap=4096):
    """Parse one stream. Returns (cells, header, end_addr, problems)."""
    problems = []
    hdr = sd.read_block(start, 4)
    tick = (hdr[0] & 0x0F) + TICK_BASE
    is_namco = (hw & 7) >= 4
    cells, addr = [], start + 4
    while True:
        if addr - start > cap:
            problems.append('no $FF within %d bytes' % cap)
            return cells, hdr, addr, problems
        op, arg = sd.read(addr), sd.read(addr + 1)
        consumed, tag, detail = decode_cell(op, arg, tick, hw & 7, is_namco)
        cells.append({'addr': addr, 'op': op, 'arg': arg, 'tick': tick,
                      'tag': tag, 'detail': detail, 'size': consumed,
                      'index': (addr - start - 4) // 2})
        if consumed == 1:
            return cells, hdr, addr + 1, problems
        addr += consumed


def streams(sd):
    """Distinct streams in address order with their soundIDs merged."""
    by_addr = collections.defaultdict(list)
    for d in sd.descriptors():
        by_addr[d['addr']].append(d)
    return [by_addr[a] for a in sorted(by_addr)]


def coverage(sd, lo=SHARED_NOTE_CPU, hi=STREAM_B03_END):
    """Walk every stream and prove the [lo, hi) area is exactly covered."""
    out = []
    pos = lo
    for group in streams(sd):
        addrs = group[0]['addr']
        if addrs < lo or addrs >= hi:
            continue
        cells, hdr, end, problems = walk(sd, group[0]['addr'], group[0]['channel'])
        out.append({'ids': [d['id'] for d in group], 'desc': group[0],
                    'hdr': hdr, 'cells': cells, 'end': end, 'problems': problems})
        pos = max(pos, end)
    return out, pos


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--validate', action='store_true',
                    help='prove every stream terminates and the area is covered')
    ap.add_argument('--stats', action='store_true', help='print decode statistics')
    ap.add_argument('--dump', nargs='*', metavar='SOUNDID',
                    help='print one or more streams as annotated text')
    args = ap.parse_args()
    sd = SoundData()

    if args.validate or not (args.stats or args.dump):
        items, pos = coverage(sd)
        bad = [it for it in items if it['problems']]
        dup = sum(len(it['ids']) - 1 for it in items)
        print('streams in $82DC-$A965: %d (descriptors: %d, shared: %d)'
              % (len(items), sum(len(i['ids']) for i in items), dup))
        print('terminated by $FF: %d, failures: %d' % (len(items) - len(bad), len(bad)))
        gaps = []
        prev = 0x82DC
        for it in items:
            if it['desc']['addr'] != prev:
                gaps.append((prev, it['desc']['addr']))
            prev = it['end']
        print('coverage: area $82DC-$A965 = %d bytes, streams claim %d, gaps %d, ends at $%04X'
              % (STREAM_B03_END - SHARED_NOTE_CPU, prev - SHARED_NOTE_CPU, len(gaps), prev))
        for a, b in gaps[:10]:
            print('  gap $%04X-$%04X (%d bytes)' % (a, b, b - a))
        for it in bad[:5]:
            print('  FAIL soundIDs %s @ $%04X: %s' % (it['ids'], it['desc']['addr'],
                                                      it['problems']))
        unknown = collections.Counter()
        for it in items:
            for c in it['cells']:
                if c['tag'].startswith('nop $') and c['op'] not in (0xFE,):
                    unknown[c['op']] += 1
        print('no-op cells used: %s' % dict(sorted(unknown.items())))
        if bad or gaps:
            return 1

    if args.stats:
        kinds = collections.Counter()
        notes = frames = 0
        for d in sd.descriptors():
            kinds[d['ch_name']] += 1
        for it in coverage(sd)[0]:
            for c in it['cells']:
                if c['op'] < 0xA0:
                    notes += 1
                    frames += c['arg'] * ((it['hdr'][0] & 0x0F) + TICK_BASE)
        print('descriptor channels: %s' % dict(sorted(kinds.items())))
        print('pitch cells: %d, single-pass length total: %d frames (%.1fs)'
              % (notes, frames, frames / 60.0))

    for sid in (args.dump or []):
        n = int(sid, 16)
        d = sd.descriptors()[n]
        cells, hdr, end, problems = walk(sd, d['addr'], d['channel'])
        tick = (hdr[0] & 0x0F) + TICK_BASE
        print('=== soundID $%02X  track %s  channel %s  stream $%04X-$%04X (%d bytes)'
              % (n, d['track'], d['ch_name'], d['addr'], end, end - d['addr']))
        print('    header %s: tick=%d (%d frames/tick) duty-src=$%02X control=$%02X sweep=$%02X'
              % (' '.join('$%02X' % b for b in hdr), hdr[0] & 0x0F, tick, hdr[1], hdr[2], hdr[3]))
        for c in cells:
            print('    cell %-3d $%04X: %02X %02X  %-18s %s'
                  % (c['index'], c['addr'], c['op'], c['arg'], c['tag'], c['detail']))
        if problems:
            print('    PROBLEMS: %s' % problems)
    return 0


if __name__ == '__main__':
    sys.exit(main())
