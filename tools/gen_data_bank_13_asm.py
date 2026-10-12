#!/usr/bin/env python3
"""Render PRG bank $13 (the second menu display-list bank) as annotated asm.

Bank $13 is pure data: it is mapped into the $8000-$9FFF window by SwitchBank8
and read by B1D_1E_MenuUpdate's stream VM (prg_1d_1e.asm $A154-$A2DA) through
the same pointer-table protocol as bank $12. SelectDataBankByPos ($A690) picks
bank $13 in two cases:

  - pos id (pos_buf_0, $0310) < $20: the table index is forced to 0 and
    @PosDataBankTable[0] = $33, so every small pos id renders from this bank;
  - pos id >= $20 with sub_state ($007A) outside 3-8: the table index is the
    sub_state and @PosDataBankTable[9..14]/[0..2] = $33.

CalcMenuDataPtr ($A61D) reads the .word at $8000 + pos*2 and adds $20 to the
stored high byte whenever its table index is < 3 or >= 9 (the same CMP #$09 /
CMP #$03 ladder that gives bank $12 its +$40 bias for indices 3-8), so
stream address = stored word + $2000.

The small pos ids are the UI-queue "mode screens": B1F_OpenMsgWindow0/2/4/5
(prg_1f.asm $F26D-$F29B) store the mode (0/2/4/5) into pos_buf_0 ($0310) -
the stream the VM renders first - and the UI id into pos_buf_1 ($0311),
which CmdEndMenu ($A248) shifts into pos_buf_0 when the mode stream ends.
B1F_ClearUI ($F29B) stores the caller's A (always $00 at its call sites)
into pos_buf_0 directly. The six tail streams at $9ECA-$9F32 are therefore
a family of window-blanking primitives: the four mode heads clear a 4-row
window at a fixed PPU spot by five times CmdPushPosition-ing into the pos-03
blank-tile macro (32 blank tiles, pop) - pos $00/$02 push $01, which re-enters
that macro 8 bytes in for a 24-tile variant, pos $04/$05 push $03 directly -
and pos $03 is also the push target of the bank-$12 streams ($82 $03).

Layout (coverage proof: this generator asserts every region tiles exactly):

  $8000-$81FF  MenuStreamPtrTable  - 256 x .word, index = pos id; the stored
               word is stream_addr - $2000; unlike bank $12 there is no
               padding value, every pos id has an entry (the unseeded ids
               $06-$0E/$12-$15/$17-$1E alternate between the two tail
               primitives in even/odd pairs and are targeted by no code path)
  $8200-$9F33  MenuStreamArea      - 208 display-list streams in the MenuUpdate
               VM format (code/pputilerender_stream_architecture.md), packed
               back to back; pos $01's push macro is the pos-03 stream
               re-entered 8 bytes in (both return through the same pop byte at
               $9EFC); several streams are shared by several pos ids
  $9F33-$9FFF  $FF filler

Usage:
    python tools/gen_data_bank_13_asm.py            # preview on stdout
    python tools/gen_data_bank_13_asm.py --write    # update asm/banks/data_13.asm
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_data_bank_12_asm import POS_NAMES  # ids >= $20 reuse bank $12's names
from menu_text_map import walk_stream       # shared stream VM decoder

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK = 0x13
BANK_BIN = os.path.join('rom', 'prg', 'prg_%02x.bin' % BANK)
ASM_PATH = os.path.join(ROOT, 'asm', 'banks', 'data_%02x.asm' % BANK)

WINDOW_CPU = 0x8000
BANK_SIZE = 0x2000
PTR_BIAS = 0x2000          # stream address = stored word + $2000
TABLE_END = 0x200          # 256 entries
STREAM_END = 0x1F33        # exclusive: last stream byte at $9F32
ROW_BYTES = 16
COMMENT_COL = 43

# pos id -> purpose, from bank-$13-specific call sites (bank-$12's POS_NAMES
# covers the ids >= $20; only the small ids and the direct-write seeds differ).
B13_POS_NAMES = {
    0x00: 'OpenMsgWindow mode-0 head / ClearUI idle: blank a 4-row window at $22A8; also '
          'the UI id of CommandCategoryMenuDispatch/ArmyCommandDispatch/'
          'TownCommandDispatch',
    0x01: 'push macro: 24 blank tiles (pos-03 macro re-entered 8 bytes in; '
          'pushed 5x by pos 00/02)',
    0x02: 'OpenMsgWindow mode-2 head: blank a 4-row window at $2428',
    0x03: 'push macro: 32 blank tiles = one window row (pushed by bank-12 '
          'streams and by pos 04/05)',
    0x04: 'OpenMsgWindow mode-4 head: blank a 4-row window at $22A0; also the UI id of '
          'WarehouseCommandDispatch/TownCommandDispatch',
    0x05: 'OpenMsgWindow mode-5 head: blank a 4-row window at $2420',
    0x10: 'UI id seeded by IntrigueCommandDispatch (OpenMsgWindow0 $10): re-renders '
          'the pos-00 blank-row stream',
    0x16: 'UI id seeded by CastleCommandDispatch (OpenMsgWindow0 $16): re-renders the '
          'pos-00 blank-row stream',
    0x1F: 'ruler intro panel (MapRulerIntroDispatch OpenMsgWindow0 $1F)',
    0xF3: 'head seeded by StratagemState_Init (prg_0c_0d $A8A0, renders '
          'bank-12 blank placeholder in war mode)',
}

PUSH_TARGETS = {0x01, 0x03}   # pushed by bank-13 mode heads and bank-12 streams

# pos id -> label suffix, from the stream's decoded text (tools/menu_text_map.py
# charmap; full per-stream text in build/stream_text_report.txt). The small
# blank-window primitives $00-$05 and the one-byte $80 stubs $9C-$A2/$A9 keep
# their bare pos labels.
STREAM_NAMES = {
    0x1F: 'OrderCastleAsk',
    0x20: 'OrderSheetsLeftMsg',
    0x21: 'NoCastleThereMsg',
    0x22: 'EnemyCastleMsg',
    0x23: 'MoveDestMenu',
    0x24: 'NoCastleThereMsgB',
    0x25: 'CastleCmdMenu',
    0x26: 'LandDevMenu',
    0x27: 'SendOfficerAsk',
    0x28: 'GoldNeededMsg',
    0x29: 'OrderSheetNeededAsk',
    0x2A: 'NotEnoughGoldHereMsg',
    0x2B: 'LandValueUpMsg',
    0x2C: 'IndustryUpMsg',
    0x2D: 'PopulationUpMsg',
    0x2E: 'MoveOfficerAsk',
    0x2F: 'MoveDeniedMsg',
    0x30: 'OfficerCapturedMsg',
    0x31: 'LeavingNowMsg',
    0x32: 'AbandonCastleAsk',
    0x33: 'FoundOfficerMsg',
    0x34: 'FoundTreasureMsg',
    0x35: 'FoundNothingMsg',
    0x36: 'PersuadeSelfAsk',
    0x37: 'VassalizeAsk',
    0x38: 'GoldDemandAsk',
    0x39: 'WillServeMsg',
    0x3A: 'RefuseServeMsg',
    0x3B: 'IntrigueMenu',
    0x3C: 'PickCountryAsk',
    0x3D: 'AlliancePickAsk',
    0x3E: 'SchemeTargetAsk',
    0x3F: 'DroughtNewsMsg',
    0x40: 'OwnCastleMsg',
    0x41: 'AlliedCountryMsg',
    0x42: 'AllianceFormedMsg',
    0x43: 'AllianceRefusedMsg',
    0x44: 'AllianceBrokenMsg',
    0x45: 'FloodNewsMsg',
    0x46: 'NoOfficerThereMsg',
    0x47: 'RosterFullMsg',
    0x48: 'SchemeTargetAskB',
    0x49: 'RulerIsTaishuMsg',
    0x4A: 'OfficerIsRulerMsg',
    0x4B: 'BecameVassalMsg',
    0x4C: 'SchemeFailedMsg',
    0x4D: 'NoHarmDoneMsg',
    0x4E: 'RikanDiscordMsg',
    0x4F: 'BousaiCostMsg',
    0x50: 'DisasterGuardUpMsg',
    0x51: 'SaveGameAsk',
    0x52: 'SavedGameMsg',
    0x53: 'WarehouseMenu',
    0x54: 'TransportPickAsk',
    0x55: 'TransportDeniedMsg',
    0x56: 'WarehouseFullMsg',
    0x57: 'TransportAmountAsk',
    0x58: 'GiveWhoAsk',
    0x59: 'GivePeopleAsk',
    0x5A: 'PeopleHappyMsg',
    0x5B: 'GiveGoldAsk',
    0x5C: 'GiveTreasureAsk',
    0x5D: 'GiveOfficerAsk',
    0x5E: 'RefuseGiftMsg',
    0x5F: 'LoyaltyUpMsg',
    0x60: 'ArmyCmdMenuB',
    0x61: 'InvadeTargetAsk',
    0x62: 'SortieDeniedMsg',
    0x63: 'ProvisionAsk',
    0x64: 'BecameTaishuMsg',
    0x65: 'SortieConfirmAsk',
    0x66: 'PickCommanderAsk',
    0x67: 'SiegeVowMsg',
    0x68: 'ConscriptCostMsg',
    0x69: 'ConscriptCountPanel',
    0x6A: 'AssignReservesAsk',
    0x6B: 'SpyCastleAsk',
    0x6C: 'AppointTaishuAsk',
    0x6D: 'SpyMoreAsk',
    0x6E: 'TownDestMenu',
    0x6F: 'ShopMenu',
    0x70: 'TreasureSellMsg',
    0x71: 'GoldReceivedMsg',
    0x72: 'RiceTradeMenu',
    0x73: 'RiceBuyAskB',
    0x74: 'RiceSellAskB',
    0x75: 'RiceBoughtMsgB',
    0x76: 'RiceSoldMsgB',
    0x77: 'HospitalSendAsk',
    0x78: 'AcademySendAsk',
    0x79: 'RefuseTreatmentMsg',
    0x7A: 'WillRecuperateMsg',
    0x7B: 'HealedMsgB',
    0x7C: 'WillStudyMsg',
    0x7D: 'WisdomUpMsg',
    0x7E: 'GiveGoldTreasureAsk',
    0x7F: 'WastelandReclaimPlan',
    0x80: 'ForestClearPlan',
    0x81: 'MarshFillPlan',
    0x82: 'IrrigationPlan',
    0x83: 'ReservoirPlan',
    0x84: 'NewCropsPlan',
    0x85: 'FertilizerPlan',
    0x86: 'FarmToolsPlan',
    0x87: 'SeedImprovePlan',
    0x88: 'WorksitePlan',
    0x89: 'HireWorkersPlan',
    0x8A: 'BuildMarketPlan',
    0x8B: 'CartTradePlan',
    0x8C: 'MineDigPlan',
    0x8D: 'NewMinePlan',
    0x8E: 'NewCraftsPlan',
    0x8F: 'ToolImprovePlan',
    0x90: 'ProductionBoostPlan',
    0x91: 'RoadRepairPlan',
    0x92: 'TownCleanupPlan',
    0x93: 'WidenRoadPlan',
    0x94: 'BuildPlazaPlan',
    0x95: 'BuildHomesPlan',
    0x96: 'GatheringHallPlan',
    0x97: 'ExpandTownPlan',
    0x98: 'TownPostsPlan',
    0x99: 'HillHomesPlan',
    0x9A: 'WeaponTooHardMsgB',
    0x9B: 'SoldOutMsgB',
    0x9C: 'EndStub',
    0x9D: 'EndStub',
    0x9F: 'EndStub',
    0xA0: 'EndStub',
    0xA1: 'EndStub',
    0xA2: 'EndStub',
    0xA3: 'ArmoryIntro',
    0xA4: 'ArmoryBuyerAsk',
    0xA5: 'ArmoryListAsk',
    0xA6: 'ArmoryBuyAskB',
    0xA7: 'SpendWarningMsg',
    0xA8: 'AllianceUnneededMsg',
    0xA9: 'EndStub',
    0xAA: 'WeaponTooPriceyMsg',
    0xAB: 'WeaponBoughtMsgB',
    0xAC: 'NoTreasureHereMsg',
    0xAD: 'NoWoundedMsg',
    0xAE: 'TownDestMenuB',
    0xAF: 'TownDestMenuC',
    0xB0: 'TownDestMenuD',
    0xB1: 'TownDestMenuE',
    0xB2: 'TownDestMenuF',
    0xB3: 'TownDestMenuG',
    0xB4: 'TownDestMenuH',
    0xB7: 'NoOfficerHereMsg',
    0xB8: 'CaughtBanditsMsg',
    0xB9: 'RichRiceDonationMsg',
    0xBA: 'RichGoldDonationMsg',
    0xBC: 'AprilTaxMsg',
    0xBD: 'OctoberHarvestMsg',
    0xBE: 'DroughtOutbreakMsg',
    0xBF: 'FloodOutbreakMsg',
    0xC0: 'ArmyAtWarPanel',
    0xC1: 'OfficerDiedMsg',
    0xC2: 'HeirSucceedsMsg',
    0xC3: 'ClanExterminatedMsg',
    0xD0: 'PickHeirCastleAsk',
    0xD1: 'PickHeirAsk',
    0xD2: 'HeirConfirmAsk',
    0xD3: 'BecameRulerMsg',
    0xD4: 'RulerAbdicatedMsg',
    0xD5: 'UnificationImpossibleMsg',
    0xD8: 'DefeatEpilogue',
    0xD9: 'DeathEpilogue',
    0xE0: 'OfficerTurnedCoatMsg',
    0xE1: 'SecretTalkSightedMsg',
    0xE2: 'AllianceEnvoyMsg',
    0xE3: 'AllianceGoldAsk',
    0xE4: 'AllianceMadeMsg',
    0xE5: 'AllianceDeclinedMsg',
    0xE6: 'SchemeSuspectedMsg',
    0xDA: 'PickPlayerRulerAsk',
    0xDB: 'AlreadyChosenMsg',
    0xDC: 'WarEndNarration',
    0xDD: 'HeroEpilogue',
    0xDE: 'UnificationScoreEpilogue',
    0xDF: 'UnificationCongrats',
    0xE8: 'RebellionNewsMsg',
    0xE9: 'PeopleFleeingMsg',
    0xEA: 'MobRaidMsg',
    0xEB: 'WorkersStrikeMsg',
    0xEC: 'AllianceDemandAsk',
    0xED: 'NotEnoughRiceMsg',
    0xEE: 'AllianceRiceAsk',
    0xEF: 'AlliancePeaceAsk',
    0xF0: 'EndingNamesPanel',
    0xF1: 'StrengthMenCaption',
    0xF2: 'StaffCaption',
    0xF3: 'StaffCreditsCoordinator',
    0xF4: 'StaffCreditsProgrammer',
    0xF5: 'StaffCreditsCharacter',
    0xF6: 'StaffCreditsComposer',
    0xF7: 'StaffCreditsDirector',
    0xF8: 'EndingBlankPanel',
    0xF9: 'EndingTileRow',
}


def read_bank():
    with open(os.path.join(ROOT, BANK_BIN), 'rb') as f:
        return f.read()


def cpu_ofs(ofs):
    return WINDOW_CPU + ofs


def hexb(v):
    return '$%02X' % v


def hexw(v):
    return '$%04X' % v


def pos_label(ids):
    name = STREAM_NAMES.get(ids[0])
    if name:
        return 'MenuStream_pos%02X_%s' % (ids[0], name)
    return 'MenuStream_pos%02X' % ids[0]


def pos_name(pos):
    return B13_POS_NAMES.get(pos) or POS_NAMES.get(pos)


def stream_summary(tokens):
    counts = {}
    for n, tag, ch in tokens:
        key = tag.split()[0]
        counts[key] = counts.get(key, 0) + 1
    order = ['tile', 'row', 'push', 'pop', 'ovl', 'vram', 'ind', 'tile_ofs',
             'mark', 'name', 'name_data', 'name7', 'name_param', 'num',
             'fmtnum', 'end']
    parts = []
    for key in order:
        if key in counts:
            label = {'tile': 'tiles', 'row': 'rows', 'push': 'push', 'pop': 'pop',
                     'ovl': 'ovl', 'vram': 'vram', 'ind': 'ind',
                     'tile_ofs': 'tile_ofs', 'mark': 'marks', 'end': 'end'}.get(key, key)
            parts.append('%d %s' % (counts[key], label))
    return ', '.join(parts)


def build_plan(data):
    """Walk every table-referenced stream once.

    Returns (words, streams, covered): words[pos] = the raw table word for every
    pos id; streams maps target file offset -> dict with ids, tokens, end,
    queue, push_macro, label, expr (the asm expression the pointer table must
    emit for this target). A stream that is a strict suffix of an already-walked
    stream (pos $01 shares pos $03's trailing pop: both macros return through
    the same $9EEC byte) gets an alias expression instead of its own byte
    emission."""
    words = [data[pos * 2] | (data[pos * 2 + 1] << 8) for pos in range(256)]
    targets = {}
    for pos in range(256):
        targets.setdefault(words[pos] + PTR_BIAS - WINDOW_CPU, []).append(pos)
    streams = {}
    spans = []          # (start, end, label) of byte-owning streams, in order
    for tgt in sorted(targets):
        ids = sorted(targets[tgt])
        queue = (not any(p in PUSH_TARGETS for p in ids)
                 and data[tgt] != 0x80)
        push_macro = any(p in PUSH_TARGETS for p in ids)
        tokens, end, lines = walk_stream(data, tgt, queue=queue, push_macro=push_macro)
        label = pos_label(ids)
        expr = label
        owner = None
        for start, send, slabel in spans:
            if start <= tgt < send:
                owner = (start, send, slabel)
        if owner is not None:
            start, send, slabel = owner
            assert end == send, (
                'pos %02X suffix stream %04X-%04X does not match owner end %04X'
                % (ids[0], cpu_ofs(tgt), cpu_ofs(end), cpu_ofs(send)))
            expr = '%s + %d' % (slabel, tgt - start)
        else:
            spans.append((tgt, end, label))
        streams[tgt] = dict(ids=ids, tokens=tokens, end=end, queue=queue,
                            push_macro=push_macro, label=label, expr=expr,
                            lines=lines, alias=owner is not None)
    # contiguity: primary streams plus any orphan must tile $8200-$9F33
    covered = bytearray(BANK_SIZE)
    orphans = []
    for tgt in sorted(streams):
        st = streams[tgt]
        if st['alias']:
            continue
        for i in range(tgt, st['end']):
            assert not covered[i], 'overlap at %04X' % cpu_ofs(i)
            covered[i] = 1
    i = TABLE_END
    while i < STREAM_END:
        if not covered[i]:
            j = i
            while j < STREAM_END and not covered[j]:
                j += 1
            orphans.append((i, j))
            i = j
        else:
            i += 1
    return words, streams, covered, orphans


def emit_ptr_table(words, streams):
    out = ['',
           '; --- $8000-$81FF  MenuStreamPtrTable: 256 x .word, index = pos id;',
           ';     stored word = stream address - $2000 (CalcMenuDataPtr adds $20 to',
           ';     the high byte for table index 0-2/9-14, the same ladder that gives',
           ';     bank $12 +$40 for index 3-8); unlike bank $12 every entry is live',
           ';     - the unseeded ids $06-$1E alternate between the two tail',
           ';     primitives in even/odd pairs, and $BB reuses the pos-00 stream ---']
    out.append('MenuStreamPtrTable:')
    for pos in range(256):
        w = words[pos]
        addr = cpu_ofs(pos * 2)
        tgt = w + PTR_BIAS - WINDOW_CPU
        st = streams[tgt]
        body = '  .word %s-$%04X' % (st['expr'], PTR_BIAS)
        ids = st['ids']
        names = [pos_name(p) for p in ids]
        names = [n for n in names if n]
        note = 'word %s -> %s  pos %s' % (hexw(w), hexw(w + PTR_BIAS),
                                          ', '.join(hexb(p) for p in ids))
        if names:
            note += ' ' + names[0]
        out.append('%s%s; %s  %s' % (body, ' ' * max(1, 43 - len(body)),
                                     hexw(addr), note))
    return out


def token_note(token):
    """Compact per-token comment: the decoded character when the tile is text."""
    tag, ch = token
    if ch is not None:
        return 'sp' if ch == ' ' else ch
    return {'row': 'row', 'end': 'end', 'pop': 'pop',
            'pop (returns to pusher)': 'pop→pusher'}.get(tag, tag)


def emit_streams(data, streams, orphans):
    out = ['',
           '; --- $8200-$9F32  MenuStreamArea: display-list streams for the bank $1D',
           ';     menu VM (legend in the banner), packed back to back; labels use the',
           ';     lowest pos id that targets the stream ---']
    out.append('MenuStreamArea:')
    last_end = TABLE_END
    orphan_queue = list(orphans)
    for tgt in sorted(streams):
        st = streams[tgt]
        while orphan_queue and orphan_queue[0][0] <= tgt:
            ostart, oend = orphan_queue.pop(0)
            assert last_end == ostart, 'gap before orphan at %04X' % cpu_ofs(ostart)
            out.extend(emit_orphan(data, ostart, oend))
            last_end = oend
        if st['alias']:
            out.append('')
            out.append('; pos %s re-enters the tail of the stream above: both push'
                       % ' '.join(hexb(p) for p in st['ids']))
            out.append('; macros return through the same shared pop byte')
            out.append('%s = %s' % (st['label'], st['expr']))
            continue
        assert last_end == tgt, 'gap before %04X (emitted to %04X)' % (
            cpu_ofs(tgt), cpu_ofs(last_end))
        ids = st['ids']
        tokens = st['tokens']
        end = st['end']
        names = [pos_name(p) for p in ids if pos_name(p)]
        head = '; --- %s-%s (%d B) pos %s%s ---' % (
            hexw(cpu_ofs(tgt)), hexw(cpu_ofs(end) - 1), end - tgt,
            ' '.join(hexb(p) for p in ids),
            ' ' + names[0] if names else ' (unnamed)')
        out.append('')
        out.append(head)
        if tokens[0][1].startswith('vram '):
            out.append(';     start PPU %s; %s' % (tokens[0][1][5:], stream_summary(tokens[1:])))
        elif st['push_macro']:
            out.append(';     pushed blank-tile macro; %s' % stream_summary(tokens))
        else:
            out.append(';     entered via CmdPushPosition; %s' % stream_summary(tokens))
        if st['lines']:
            out.append(';     text: "%s"' % ' / '.join(st['lines']))
        if len(ids) > 1:
            extra = [pos_name(p) for p in ids[1:] if pos_name(p)]
            if extra:
                out.append(';     other ids: %s' % '; '.join(extra))
        out.append('%s:' % st['label'])
        rows, a, row, row_bytes, tags = [], tgt, [], 0, []
        for n, tag, ch in tokens:
            if row and row_bytes + n > ROW_BYTES:
                rows.append((a, row, tags))
                a += row_bytes
                row, row_bytes, tags = [], 0, []
            row.append(n)
            tags.append((tag, ch))
            row_bytes += n
        if row:
            rows.append((a, row, tags))
        for start, sizes, tg in rows:
            vals = [data[start + k] for k in range(sum(sizes))]
            body = '  .byte ' + ', '.join(hexb(v) for v in vals)
            tag = ' | '.join(token_note(t) for t in tg)
            out.append('%s%s; %s  %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                         hexw(cpu_ofs(start)), tag))
        last_end = end
    while orphan_queue:
        ostart, oend = orphan_queue.pop(0)
        assert last_end == ostart, 'gap before orphan at %04X' % cpu_ofs(ostart)
        out.extend(emit_orphan(data, ostart, oend))
        last_end = oend
    assert last_end == STREAM_END, (
        'stream area ends at %04X, expected %04X' % (cpu_ofs(last_end), cpu_ofs(STREAM_END)))
    return out


def emit_orphan(data, ostart, oend):
    out = ['',
           '; --- %s-%s (%d B) executed by no path: the shared continuation bytes'
           % (hexw(cpu_ofs(ostart)), hexw(cpu_ofs(oend) - 1), oend - ostart),
           ';     after the push macros\' common pop (ovl-on and a pos-01 push/row',
           ';     ladder) - kept as raw bytes ---']
    out.append('MenuStreamUnused_%04X' % cpu_ofs(ostart))
    for a in range(ostart, oend, ROW_BYTES):
        chunk = data[a:min(a + ROW_BYTES, oend)]
        body = '  .byte ' + ', '.join(hexb(v) for v in chunk)
        out.append('%s%s; %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                 hexw(cpu_ofs(a))))
    return out


def emit_filler(data):
    out = ['',
           '; --- $9F33-$9FFF  unused ($FF filler) ---']
    for a in range(STREAM_END, BANK_SIZE, ROW_BYTES):
        chunk = data[a:a + ROW_BYTES]
        body = '  .byte ' + ', '.join(hexb(v) for v in chunk)
        out.append('%s%s; %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                 hexw(cpu_ofs(a))))
    out.append('')
    out.append('.endproc')
    out.append('')
    return out


def render(data):
    assert len(data) == BANK_SIZE
    # sanity: every word resolves inside the stream area
    for pos in range(256):
        w = data[pos * 2] | (data[pos * 2 + 1] << 8)
        assert TABLE_END <= w + PTR_BIAS - WINDOW_CPU < STREAM_END, (
            'pos %02X word %04X out of range' % (pos, w))
    words, streams, covered, orphans = build_plan(data)
    for i in range(TABLE_END, STREAM_END):
        assert covered[i], 'uncovered byte at %04X' % cpu_ofs(i)
    out = [BANNER.rstrip('\n')]
    out.extend(emit_ptr_table(words, streams))
    out.extend(emit_streams(data, streams, orphans))
    out.extend(emit_filler(data))
    return '\n'.join(out)


BANNER = """\
;===============================================================================
; DATA Bank 13 (PRG $13) - 8KB menu display-list bank, mapped into $8000-$9FFF
; by SwitchBank8; no code lives here (see code/bank_switch_map.md 5.2).
;
; GENERATED by tools/gen_data_bank_13_asm.py --write; byte-exactness is enforced
; by tools/verify_data_bank_13.py. Raw source: rom/prg/prg_13.bin (read-only) -
; do not hand-edit the rendered records.
;
; Selected as $33 from B1D_1E_MenuUpdate's stream VM (prg_1d_1e):
;   SelectDataBankByPos $A690 + @PosDataBankTable $A6A7: bank $13 is mapped
;   whenever the pos id (pos_buf_0, $0310) is < $20 (table index forced to 0),
;   or whenever pos id >= $20 and sub_state ($007A) is outside 3-8 (indices
;   0-2 and 9-14). CalcMenuDataPtr $A61D reads the .word at $8000 + pos*2 and
;   adds $20 to its high byte for those indices (bank $12 gets +$40 for
;   indices 3-8), so stream address = stored word + $2000. The pos ids enter
;   the 4-entry UI queue pos_buf_0..3 ($0310-$0313) through B1F_OpenMsgWindow0/2/4/5
;   (prg_1f $F26D-$F29B: mode -> pos_buf_0, UI id -> pos_buf_1), through
;   B1F_ClearUI ($F29B, caller A always $00), through direct $0310/$0311
;   writes (StratagemState_Init seeds $F3;
;   OfficerExchangeConfirmDispatch seeds $E0/$DB), and through
;   CmdPushPosition ($82) chains inside the streams;
;   CmdEndMenu ($A248) shifts the queue. This bank is also the push target of
;   the bank-$12 streams: their single small-id push ($82 $03) enters the
;   pos-03 blank-tile macro here.
;
; Regions:
;   $8000-$81FF  MenuStreamPtrTable   256 x .word, index = pos id (all live)
;   $8200-$9F33  MenuStreamArea       207 display-list streams + one 16-byte
;                                    orphan at $9EED-$9EFC, packed
;   $9F33-$9FFF  $FF filler
;
; Stream VM legend (full description: code/pputilerender_stream_architecture.md):
;   a stream entered through the UI queue (menu_status = 0 path, CheckInputAndProcess
;   $A17F) begins with a 2-byte PPU address stored LOW BYTE FIRST - the engine
;   writes $2006 with tile_row1_lo ($031D) before tile_row1_hi ($031C), so the
;   pair [b0][b1] addresses PPU (b1<<8)|b0 (e.g. $A8 $22 -> $22A8, inside the
;   strategy-map nametable); a stream entered through CmdPushPosition starts
;   directly with command/tile bytes. Then a byte stream read through ($00A6),Y -
;   $00-$7F and $C0-$FF literal tile bytes (tile_base_offset added, written into
;   the tile-row buffers $031C/$034C), $39/$3A name-slot markers while indirect
;   mode is off, $80 end menu (shifts the UI queue), $81 advance one row ($40),
;   $82 push position + 1 byte new pos id (chains into another stream through
;   the pointer table; this bank's pushes target $01/$03 and bank-12's $03
;   targets this bank), $83 pop position (returns to the pusher), $84/$85
;   overlay mode on/off, $86/$8A-$8F set VRAM address + 2 bytes [lo][hi],
;   $87/$88 indirect mode on/off, $89 set tile base offset + 1 byte, $90-$97
;   draw name slot 0-7 (bank $10 $901A officer names via RAM $042C), $98-$9B
;   draw BCD number slot 0-3 ('0' = tile $76), $9C/$9D/$9E/$9F draw name/7-char
;   name/formatted number/param name + 1 byte index.
;
; Text charmap (proven by decode anchors, see tools/menu_text_map.py): literal
; tile bytes in the two code spaces carry Japanese text - tiles $04-$38 are
; serial-gojukon katakana from ア (the officer-name code space; $32=ー $33=!
; $34=ィ $39/$3A dakuten/handakuten postfix), tiles $44-$75 are serial-gojuon
; hiragana from あ ($72-$75 ゃゅょっ). $01 = space. Any other literal, and
; everything under a nonzero $89 tile_base_offset, is window graphics shown
; as [XX]. Dynamic commands render as 〈名〉/〈省NN〉/⟨数⟩ placeholders.
; The full decoded text of every stream: python3 tools/report_stream_text.py.
;
; The six tail streams $9ECA-$9F32 are a window-blanking primitive family for
; the small pos ids: the four OpenMsgWindow mode heads (pos $00/$02/$04/$05 = modes
; 0/2/4/5) blank a 4-row window at a fixed PPU spot ($22A8/$2428/$22A0/$2420)
; by five times pushing the pos-03 blank-tile macro (32 tiles, one window row);
; pos $00/$02 push $01 - the same macro re-entered 8 bytes in, 24 tiles - and
; pos $04/$05 push $03 directly, as do the bank-$12 streams. Ids >= $20 serve
; the same panels as bank $12 (names reused from tools/gen_data_bank_12_asm.py)
; but are read from this bank whenever sub_state ($007A) is outside 3-8 - e.g.
; transition frames; pos $F3, a one-byte $80 placeholder in bank $12, is a
; full text stream here.
;===============================================================================

.segment "CODE_BANK13"

; Bank-13 stream labels are scoped: bank $12's generated file defines the same
; global MenuStream_posXX names for the ids >= $20, and both banks are
; included in all_banks.asm.

.proc Bank13MenuStreams
"""


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--write', action='store_true', help='overwrite asm/banks/data_13.asm')
    args = ap.parse_args()
    text = render(read_bank())
    if args.write:
        with open(ASM_PATH, 'w', encoding='utf-8') as f:
            f.write(text)
        print('wrote %s (%d lines)' % (os.path.relpath(ASM_PATH, ROOT), text.count('\n')))
    else:
        print(text)


if __name__ == '__main__':
    main()
