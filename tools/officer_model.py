#!/usr/bin/env python3
"""Officer seed-data model: docs/*.csv <-> bank $10/$11 records <-> asm.

This is the single codec shared by

  * `tools/gen_data_bank_asm.py`       - renders `asm/banks/data_10.asm` / `data_11.asm`
  * `tools/check_officer_pipeline.py`  - proves the CSV -> asm -> ROM loop is lossless
  * `editor/officer_editor.py`         - the standalone officer GUI editor
  * `editor/officer_cli.py`            - the headless front-end over the same model

Tables in scope (all new-game seed data, read through the `$8000-$9FFF` window):

| table | mapper bank | CPU | shape | CSV twin |
|---|---|---|---|---|
| officer master records | `$31` | `$8000` | 237 x 12 B | `docs/officer_data.csv` |
| officer katakana names | `$30` | `$901A` | 237 x 10 B, `$00`-terminated | `docs/officer_data.csv` (`katakana`) |
| arrival schedule | `$31` | `$8B1C` | 30 x `$14` = ten (id, year) pairs | `docs/officer_data.csv` (`schedule_province_id`, `appear_year`) |
| natural-death years | `$31` | `$9C58` | 237 x 1 B = year - 100 | `docs/officer_death_years.csv` |
| province rosters | `$30` | `$8C00 + $11..$1A` | 30 x 10 slots, `$FF` = empty | `docs/province_data.csv` (`officer_ids`) |
| kanji name plates | `$31` | `$8DB4` | 237 x 13 B (page + 3 kanji x 4 tiles) | read-only, see `NAME_GLYPH_CPU` |

The master record is the seed image of the officer's SRAM record at
`id * 12 + $63C0`; `SramInit` (`$DD8B`, `asm/banks/prg_1d_1e.asm`) copies it and
`B1F_GetOfficerRomRecordAddr` (`$F387`) also reads the ROM seed at runtime.
Field names follow the canonical glossary in `docs/manual_kb/terminology.md`, and
the byte-level evidence is in `docs/officer_data.md` /
`code/initial_data_tables.md`.

Record layout (12 bytes):

    +0 体力 Vitality  +1 武力 Might  +2 知力 Intelligence  +3 忠誠度 Loyalty
    +4 人徳 Virtue    +5 位置 LocationProvince (runtime-only, 0 in the seed)
    +6/+7 経験値 Experience (LE)     +8/+9 兵数 TroopCount (LE)
    +A bits 0-4 武器 Weapon (0-23), bits 5-7 防具 Armor (0-7)
    +B bits 4-7 レベル OfficerLevel (0-based), bits 2-3 軍の属性 ArmyAffinity,
       bits 0-1 状態 OfficerStatus

Invariants
----------
`problems()` reports exactly the rules that `tools/verify_data_banks.py`
re-checks on the *assembled* bytes (`structural_check` + `cross_check`), so an
edit that trips one here can never pass the repo's byte gate:

  * +0..+4 are 1-100; レベル is 1-5; 軍の属性 is 0-2; seed 状態 is 1 or 2
  * 状態 2 (rostered) == the union of all province roster slots, and no officer
    occupies two slots or a slot >= 237 (the governor is whoever holds slot `$11`)
  * the arrival schedule only ever lists 状態 1 (hidden) officers, at most ten
    per province block, year a single byte
  * a name fits nine kana codes plus the `$00` terminator

`notes()` reports the conventions the stock ROM follows but no reader enforces
(経験値 sitting on a level boundary, seven 忠誠度-100 rulers, and so on), each
labelled with the stock figure so a deliberate edit reads as a change of fact
rather than an error.

Standalone mode: this module imports nothing but the stdlib and never reads the
ROM, so a copy of it next to the editor plus the CSVs is enough to edit outside
the disassembly repo. Rendering the assembly and running the byte gate stay in
the repo; both front-ends say so instead of failing.
"""
import csv
import os
import re
from collections import namedtuple

# --- table geometry ------------------------------------------------------
OFFICER_COUNT = 237            # ids $00-$EC; every scan loop stops at CMP #$ED
WINDOW_CPU = 0x8000            # both seed banks are only ever mapped here
RECORD_STRIDE = 12
RECORD_CPU = WINDOW_CPU        # bank $31
NAME_STRIDE = 10
NAME_MAX_CODES = NAME_STRIDE - 1   # the last byte must stay the $00 terminator
NAME_CPU = 0x901A              # bank $30
ARRIVAL_CPU = 0x8B1C           # bank $31
ARRIVAL_STRIDE = 0x14
ARRIVAL_PAIRS = ARRIVAL_STRIDE // 2
DEATH_CPU = 0x9C58             # bank $31
DEATH_YEAR_OFFSET = 100        # table byte = death year - 100
PROVINCE_COUNT = 30
PROV_RECORD_STRIDE = 32
PROV_RECORD_CPU = 0x8C00       # bank $30
ROSTER_START = 0x11            # record +$11..+$1A; +$11 is the 太守 governor
ROSTER_SLOTS = 10
EMPTY_SLOT = 0xFF
SRAM_RECORD_BASE = 0x63C0

# The kanji name plate is a *second*, independent name encoding: 13 bytes per id
# at bank $31 $8DB4 - [0] the name-font CHR page, then up to three kanji x four
# 8x8 tile ids, the quadruple (n, n+1, n+$10, n+$11) of one 16x16 glyph, $FF
# terminated. `CmdDrawNameFromData` ($A426, prg_19_1a) posts it as OAM sprites on
# the ruler card. Tile ids are page-local and the pages are authored per surname
# group (code/ruler_card_decode.md section 4), so there is no kanji -> tiles
# function to re-encode a renamed officer with: this table is read-only here and
# renaming is reported as leaving it behind.
NAME_GLYPH_CPU = 0x8DB4
NAME_GLYPH_STRIDE = 0x0D
NAME_GLYPH_TILES = 4
GLYPH_TERMINATOR = 0xFF

# The family-heir reinforcement pools (bank $31 $8D74, right before the plate
# table): 4 little-endian word pointers whose HIGH byte is stored +$60 (the
# reader adds it back), each to a $FF-terminated (officer id, join year) list.
# EventReinforceGate ($A33C, prg_19_1a) runs each January per acting Country:
# Countries 2/3/4 (6 aliases slot 3) select pool (Country-2), and
# OfficerReinforceScene ($AEC0) inducts the FIRST still-hidden officer whose
# year has arrived into the Country's home Province roster (状態 <- 2, officer
# card shown). The four lists hold exactly the 26 hidden officers that have no
# arrival-schedule entry, grouped by family (Cao/Wei, Sun/Wu, Liu/Shu, Ma).
REINFORCE_PTR_CPU = 0x8D74
REINFORCE_POOL_COUNT = 4
REINFORCE_POOL_COUNTRIES = (2, 3, 4, 6)
REINFORCE_PTR_HI_BIAS = 0x60
REINFORCE_YEAR_OFFSET = 100            # byte = display year - 100
REINFORCE_YEAR_RANGE = (100, 255)      # what one byte can express
# docs/officer_reinforcement.csv columns (tools/extract_reinforcement_pools.py
# writes it; one row per (officer id, join year) pair in stored list order).
REINFORCE_COLUMNS = ('pool', 'country', 'officer_id', 'katakana', 'zh_hans',
                     'table_byte', 'join_year')

# --- officer card portraits ----------------------------------------------
# The 武将カード portrait: prg_1a $CED6 (@OfficerPortraitChrPageTable) holds
# each officer's 1KB CHR page id (bank $1A is the $C000-$DFFF half of the
# $A000-$DFFF 16KB window, so the file offset is $CED6 - $C000). Pages
# $18-$53 are the authored portrait block shared across the roster; the four
# reinforcement-only heirs sit outside it - 13 王双 and 116 申耽 share page
# $9F, 19 蒯良 and 228 凌统 share page $DB (verified by rendering: distinct
# authored cards, one per officer). OfficerCardRender ($CE1F, prg_19_1a)
# draws a 14-sprite body + 6-sprite face from the bank-$01 tables (class
# base $99A0, body pointers $9AA0, face-expression pointers $9BAC; records
# [y, tile, attr, x] + $80, consumed by SpriteOamWriterSimple $F1AD) and the
# IRQ handler (prg_1f $FD03) latches the page into CHR regs 2/3, so the card
# OAM tiles resolve into the officer's own page (tile & $3F). Expression =
# ($00A4 & 7) + class base: 0/1 normal, 2 angry (duel pursuer), 3 sad (war
# defeat), 4 happy (war victory); the talking frames ($9D64) alternate the
# same face with the mouth tile swapped every 8 frames.
PORTRAIT_PAGE_FILE = 'prg_1a.bin'
PORTRAIT_PAGE_OFFSET = 0x0ED6          # $CED6 - $C000 (bank $1A)
PORTRAIT_CARD_FILE = 'prg_01.bin'
PORTRAIT_CLASS_BASE_CPU = 0x99A0
PORTRAIT_BODY_PTR_CPU = 0x9AA0
PORTRAIT_FACE_PTR_CPU = 0x9BAC
PORTRAIT_SPRITE_REC = 4                # [y, tile, attr, x]
PORTRAIT_SPRITE_END = 0x80
PORTRAIT_EXPRESSIONS = ((0, 'normal'), (2, 'angry'), (3, 'sad'), (4, 'happy'))
# Sprite palettes of palette record 0 (LoadScenarioData $DBB1 -> bank $1E
# $DBEB, copied to the $0100 buffer and uploaded at $3F00 by PaletteUpload
# $E70E, so bytes 16-31 are the four sprite palettes at $3F10-$3F1F). The
# card scenes load record 0 before drawing (ProvinceOfficerRosterDispatch
# $AFF5, SceneRenderSetup $BD2B), and every card sprite in the blobs carries
# attr $23/$63 - palette 3 either way - so the visible colours are SPR3 =
# $0F $20 $27 $17 (white / gold / brown). Matches the manual scan card
# (res/manual_jpn scan 10: the face measures (227,186,61), i.e. gold $27).
# The war-result step scenes re-fill palette 3 per scene from the table at
# prg_1a $D692, so sad/happy cards can there show with $36 tan in slot 1.
# Sprite value 0 is transparent.
PORTRAIT_SPRITE_PALETTES = ((0x0F, 0x0F, 0x20, 0x16), (0x0F, 0x0F, 0x2B, 0x28),
                            (0x0F, 0x36, 0x30, 0x16), (0x0F, 0x20, 0x27, 0x17))
# Plate tile ids are page-local ($00-$3F); page V is the 1KB CHR chunk
# rom/chr/chr_(V//8).bin at (V%8)*$400 - the same mapping the BG display
# records use (code/initial_data_tables.md section 9). Verified by rendering:
# every surname group decodes to its kanji (尹/袁/王/夏侯/阿/劉/呂/司馬...).
PLATE_TILE_BYTES = 16
PLATE_CHUNK_BYTES = 0x400
PLATE_TILES_PER_SIDE = 2
# OAM attribute $01 (ruler_card_decode.md section 4) = sprite palette 1, and
# the strategy layer runs palette record 0 (LoadScenarioData, see
# code/initial_data_tables.md - validated by the title-screen control render):
# $3F14-$3F17 = $0F $0F $2B $28, and no other code writes the palette buffer.
NAME_SPRITE_PALETTE = (0x0F, 0x0F, 0x2B, 0x28)
# NES $3F00-$3F3F as RGB (2C02 generic palette), the same table
# tools/render_ppu_screen.py renders with.
NES_RGB = (
    (0x60, 0x60, 0x60), (0x00, 0x32, 0x98), (0x00, 0x1a, 0xac), (0x28, 0x00, 0x98),
    (0x54, 0x00, 0x70), (0x74, 0x00, 0x28), (0x68, 0x20, 0x00), (0x44, 0x3c, 0x00),
    (0x1c, 0x50, 0x00), (0x00, 0x5c, 0x00), (0x00, 0x50, 0x28), (0x00, 0x38, 0x58),
    (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xb2, 0xb2, 0xb2), (0x14, 0x80, 0xdb), (0x28, 0x60, 0xff), (0x5c, 0x3c, 0xff),
    (0xa0, 0x28, 0xdc), (0xd0, 0x1c, 0x74), (0xe8, 0x30, 0x28), (0xc0, 0x60, 0x00),
    (0x8c, 0x8c, 0x00), (0x4c, 0xb0, 0x00), (0x14, 0xc8, 0x30), (0x00, 0xc8, 0x78),
    (0x00, 0xb8, 0xd8), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xf0, 0xf4, 0xf8), (0x44, 0xc4, 0xff), (0x68, 0xa8, 0xff), (0xb4, 0x88, 0xff),
    (0xfc, 0x74, 0xf8), (0xfc, 0x74, 0xa0), (0xfc, 0x94, 0x58), (0xe8, 0xb4, 0x00),
    (0xbc, 0xd4, 0x00), (0x88, 0xfc, 0x10), (0x40, 0xfc, 0x4c), (0x00, 0xf8, 0x8c),
    (0x00, 0xe8, 0xe8), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0xf8, 0x00),
    (0xf8, 0xf8, 0xf8), (0xa8, 0xf0, 0xf8), (0xc0, 0xdc, 0xf8), (0xd8, 0xc8, 0xf8),
    (0xf8, 0xb8, 0xf8), (0xf8, 0xb4, 0xd8), (0xf8, 0xc8, 0xb8), (0xf8, 0xd8, 0x78),
    (0xe8, 0xe8, 0x60), (0xc0, 0xf8, 0x78), (0xa8, 0xf8, 0x9c), (0xa8, 0xf8, 0xd8),
    (0xa8, 0xf0, 0xf8), (0xa8, 0xa8, 0xa8), (0xfc, 0xfc, 0xfc), (0x00, 0x00, 0x00),
)

# --- value spaces --------------------------------------------------------
WEAPONS = {
    0: '短剣', 1: '飛剣', 2: '長剣', 3: '破斬剣', 4: '大剣',
    5: '青釭の剣', 6: '倚天の剣', 7: '七星宝剣',
    8: '薤刀', 9: '眉尖刀', 10: '三尖刀', 11: '鉤鐮刀', 12: '偃月刀',
    13: '鳳嘴刀', 14: '龍牙刀', 15: '関王刀',
    16: '矛', 17: '双戟', 18: '単鉤槍', 19: '戦斧', 20: '双鉤槍',
    21: '方天画戟', 22: '狼牙鎗', 23: '蛇矛',
}
ARMOR = {0: '綸巾', 1: '籠手', 2: '兜', 3: '硬皮', 4: '鶴氅', 5: '甲冑',
         6: '聖者の衣', 7: '竜鱗の鎧'}
ARMY_AFFINITY = {0: '平', 1: '山', 2: '水'}
OFFICER_STATUS = {0: 'free', 1: 'hidden', 2: 'rostered', 3: 'out of action'}
SEED_STATUSES = (1, 2)         # the ROM seed only ever holds these two
STAT_RANGE = (1, 100)
LEVEL_RANGE = (1, 5)           # stored 0-based in bits 4-7
WORD_RANGE = (0, 0xFFFF)
ARRIVAL_YEAR_RANGE = (0, 255)  # one plain binary byte
DEATH_YEAR_RANGE = (DEATH_YEAR_OFFSET, DEATH_YEAR_OFFSET + 255)

# 経験値 only ever marks a level boundary in the seed (docs/officer_data.md).
EXPERIENCE_BY_LEVEL = {1: 0, 2: 1000, 3: 2000, 4: 3500, 5: 5000}
# Arrival years span $BD-$D2 in the stock ROM.
STOCK_ARRIVAL_YEARS = (189, 210)
STOCK_DEATH_YEARS = (202, 265)
# Stock census, for the notes only - none of these is enforced by a reader.
STOCK_RULERS = 7               # 忠誠度 100 officers
STOCK_SCHEDULED = 154          # hidden officers with an arrival entry
STOCK_UNSCHEDULED_HIDDEN = 26  # hidden officers without one
STOCK_ROSTERED = 57            # 状態 2 officers == roster slots in use
STOCK_ROSTERED_NO_TROOPS = (16, 70)   # 王甫, 黄権

# --- kana code space (mirrors tools/charmap_kana.py; section 2 of
#     tools/check_officer_pipeline.py asserts the two copies agree) -------
# Serial gojuon from $04, small kana and the sokuon after ン, then the two
# postfix combining marks. $39/$3A are width-only overlay bytes for the
# renderer (`GetNameDisplayScale` $F308), never standalone characters.
KATAKANA = {
    0x04: 'ア', 0x05: 'イ', 0x06: 'ウ', 0x07: 'エ', 0x08: 'オ',
    0x09: 'カ', 0x0A: 'キ', 0x0B: 'ク', 0x0C: 'ケ', 0x0D: 'コ',
    0x0E: 'サ', 0x0F: 'シ', 0x10: 'ス', 0x11: 'セ', 0x12: 'ソ',
    0x13: 'タ', 0x14: 'チ', 0x15: 'ツ', 0x16: 'テ', 0x17: 'ト',
    0x18: 'ナ', 0x19: 'ニ', 0x1A: 'ヌ', 0x1B: 'ネ', 0x1C: 'ノ',
    0x1D: 'ハ', 0x1E: 'ヒ', 0x1F: 'フ', 0x20: 'ヘ', 0x21: 'ホ',
    0x22: 'マ', 0x23: 'ミ', 0x24: 'ム', 0x25: 'メ', 0x26: 'モ',
    0x27: 'ヤ', 0x28: 'ユ', 0x29: 'ヨ',
    0x2A: 'ラ', 0x2B: 'リ', 0x2C: 'ル', 0x2D: 'レ', 0x2E: 'ロ',
    0x2F: 'ワ', 0x30: 'ヲ', 0x31: 'ン',
    0x32: 'ァ', 0x33: 'ィ', 0x34: 'ゥ',
    0x35: 'ャ', 0x36: 'ュ', 0x37: 'ョ', 0x38: 'ッ',
}
DAKUTEN = 0x39        # ゛
HANDAKUTEN = 0x3A     # ゜
NAME_TERMINATOR = 0x00
_K2H = str.maketrans(
    'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥャュョッ',
    'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅゃゅょっ')
_VOICED_ROWS = 'カキクケコサシスセソタチツテトハヒフヘホウ'
_VOICED_FORM = 'ガギグゲゴザジズゼゾダヂヅデドバビブベボヴ'
_SEMI_ROWS = 'ハヒフヘホ'
_SEMI_FORM = 'パピプペポ'
_HIRAGANA_VOICED = 'がぎぐげござじずぜぞだぢづでどばびぶべぼゔ'
_HIRAGANA_SEMI = 'ぱぴぷぺぽ'


class OfficerError(Exception):
    """Base class for every error this model raises on purpose."""


class FieldError(OfficerError):
    """A value was rejected: out of range, not a choice, or coupling violated."""


class NameEncodeError(OfficerError):
    """A name cannot be written in the game's kana code space."""


def _voiced(ch):
    if ch in _VOICED_ROWS:
        return _VOICED_FORM[_VOICED_ROWS.index(ch)]
    return ch + '゛'


def _semi_voiced(ch):
    if ch in _SEMI_ROWS:
        return _SEMI_FORM[_SEMI_ROWS.index(ch)]
    return ch + '゜'


def decode_name(data):
    """Decode a `$00`-terminated name string, applying the postfix marks."""
    out = []
    for b in bytes(data):
        if b == NAME_TERMINATOR:
            break
        if b == DAKUTEN:
            if out:
                out[-1] = _voiced(out[-1])
            continue
        if b == HANDAKUTEN:
            if out:
                out[-1] = _semi_voiced(out[-1])
            continue
        out.append(KATAKANA.get(b, '[%02X]' % b))
    return ''.join(out)


def _encode_map():
    """kana character -> code tuple (the inverse of decode_name).

    Both the composed (ガ) and the ROM-literal postfix (カ゛) input forms are
    accepted, in katakana and hiragana, because all four show up when a name is
    copied out of a document.
    """
    table = {}
    for code, ch in KATAKANA.items():
        table[ch] = (code,)
        table[ch.translate(_K2H)] = (code,)
    for base, form in zip(_VOICED_ROWS, _VOICED_FORM):
        table[form] = table[base] + (DAKUTEN,)
    for base, form in zip(_VOICED_ROWS.translate(_K2H), _HIRAGANA_VOICED):
        table[form] = table[base] + (DAKUTEN,)
    for base, form in zip(_SEMI_ROWS, _SEMI_FORM):
        table[form] = table[base] + (HANDAKUTEN,)
    for base, form in zip(_SEMI_ROWS.translate(_K2H), _HIRAGANA_SEMI):
        table[form] = table[base] + (HANDAKUTEN,)
    return table


ENCODE = _encode_map()


def encode_name(text, stride=NAME_STRIDE):
    """Encode a name into exactly `stride` bytes, `$00`-terminated and padded.

    Accepts katakana or hiragana, and either the composed form (ガ) or the
    ROM-literal postfix form (カ゛). Raises NameEncodeError when a character has
    no code or when the result would not leave room for the terminator, which is
    what `GetNameDisplayScale` ($F308) walks to.
    """
    if not str(text).strip():
        raise NameEncodeError(
            'a name cannot be empty: every officer has one, and the field is a '
            '$00-terminated string')
    codes = []
    for ch in str(text):
        if ch in '゛゜':
            if not codes:
                raise NameEncodeError('%r: a combining mark has no character '
                                      'to attach to' % text)
            codes.append(DAKUTEN if ch == '゛' else HANDAKUTEN)
            continue
        entry = ENCODE.get(ch)
        if entry is None:
            raise NameEncodeError(
                '%r: no code for %r - the name space is the katakana of '
                'tools/charmap_kana.py plus the ゛/゜ marks' % (text, ch))
        codes += entry
    if len(codes) > NAME_MAX_CODES:
        raise NameEncodeError(
            '%r: %d kana codes, but a name field is %d bytes and must keep the '
            '$00 terminator (max %d codes)'
            % (text, len(codes), stride, NAME_MAX_CODES))
    return bytes(codes).ljust(stride, b'\x00')


# --- record codec --------------------------------------------------------
def fields_from_record(rec):
    """Split one 12-byte master record into the CSV's decoded columns."""
    rec = bytes(rec)
    return {
        'vitality': rec[0], 'might': rec[1], 'intelligence': rec[2],
        'loyalty': rec[3], 'virtue': rec[4], 'location5': rec[5],
        'experience': rec[6] | rec[7] << 8,
        'troop_count': rec[8] | rec[9] << 8,
        'weapon_index': rec[10] & 0x1F,
        'armor_index': rec[10] >> 5,
        'officer_level': (rec[11] >> 4) + 1,
        'army_affinity_bits': (rec[11] >> 2) & 0x03,
        'officer_status_bits': rec[11] & 0x03,
        'army_affinity_code': rec[11] & 0x0F,
    }


def record_from_fields(f):
    """Rebuild the 12 record bytes from decoded fields (+05 stays 0)."""
    return bytes([
        f['vitality'], f['might'], f['intelligence'], f['loyalty'],
        f['virtue'], 0,
        f['experience'] & 0xFF, (f['experience'] >> 8) & 0xFF,
        f['troop_count'] & 0xFF, (f['troop_count'] >> 8) & 0xFF,
        ((f['armor_index'] << 5) | f['weapon_index']) & 0xFF,
        (((f['officer_level'] - 1) << 4)
         | (f['army_affinity_bits'] << 2) | f['officer_status_bits']) & 0xFF,
    ])


def status_byte(f):
    """The `+0B` byte, i.e. what the asm comment quotes as `(+0B=$xx)`."""
    return (((f['officer_level'] - 1) << 4)
            | (f['army_affinity_bits'] << 2) | f['officer_status_bits']) & 0xFF


# --- field descriptors ---------------------------------------------------
# One table drives both front-ends: the GUI builds a widget per entry and the
# CLI's `set` validates against the same spec.
Field = namedtuple('Field', 'key jp en kind group lo hi choices nullable')
Field.__new__.__defaults__ = (None, None, None, 'int', 'stats',
                              None, None, None, False)

FIELDS = (
    Field('katakana', '名前', 'Name', 'text', 'identity'),
    Field('vitality', '体力', 'Vitality', 'int', 'stats', *STAT_RANGE),
    Field('might', '武力', 'Might', 'int', 'stats', *STAT_RANGE),
    Field('intelligence', '知力', 'Intelligence', 'int', 'stats', *STAT_RANGE),
    Field('loyalty', '忠誠度', 'Loyalty', 'int', 'stats', *STAT_RANGE),
    Field('virtue', '人徳', 'Virtue', 'int', 'stats', *STAT_RANGE),
    Field('officer_level', 'レベル', 'OfficerLevel', 'int', 'career',
          *LEVEL_RANGE),
    Field('experience', '経験値', 'Experience', 'int', 'career', *WORD_RANGE),
    Field('troop_count', '兵数', 'TroopCount', 'int', 'career', *WORD_RANGE),
    Field('weapon_index', '武器', 'Weapon', 'choice', 'equipment',
          choices=[(i, '%d %s' % (i, WEAPONS[i])) for i in sorted(WEAPONS)]),
    Field('armor_index', '防具', 'Armor', 'choice', 'equipment',
          choices=[(i, '%d %s' % (i, ARMOR[i])) for i in sorted(ARMOR)]),
    Field('army_affinity_bits', '軍の属性', 'ArmyAffinity', 'choice',
          'equipment',
          choices=[(i, '%d %s軍 %sArmy' % (i, ARMY_AFFINITY[i], en))
                   for i, en in sorted(ARMY_AFFINITY.items())]),
    Field('officer_status_bits', '状態', 'OfficerStatus', 'choice', 'placement',
          choices=[(i, '%d %s' % (i, OFFICER_STATUS[i]))
                   for i in SEED_STATUSES]),
    Field('schedule_province_id', '出現州', 'AppearProvince', 'province',
          'placement', nullable=True),
    Field('appear_year', '出現年', 'AppearYear', 'int', 'placement',
          *ARRIVAL_YEAR_RANGE, nullable=True),
    Field('death_year', '死亡年', 'DeathYear', 'int', 'life', *DEATH_YEAR_RANGE),
)
FIELD_BY_KEY = {f.key: f for f in FIELDS}
EDITABLE = tuple(f.key for f in FIELDS)

AFFINITY_EN = {0: 'Plains', 1: 'Mountain', 2: 'Naval'}


class Officer:
    """One officer: the seed record plus its name, schedule and death year.

    `roster_province` / `roster_slot` are read-only here - they belong to the
    province records, so placement goes through `Model.assign` / `Model.unassign`,
    which keep 状態 and the roster slots in step (the cross-bank gate).
    """

    def __init__(self, oid, katakana='', zh_hans='', kanji_ja='', pinyin=''):
        self.id = oid
        self.katakana = katakana
        self.zh_hans = zh_hans
        self.kanji_ja = kanji_ja
        self.pinyin = pinyin
        self.vitality = self.might = self.intelligence = 1
        self.loyalty = self.virtue = 1
        self.officer_level = 1
        self.experience = 0
        self.troop_count = 0
        self.weapon_index = 0
        self.armor_index = 0
        self.army_affinity_bits = 0
        self.officer_status_bits = 1
        self.schedule_province_id = None
        self.appear_year = None
        self.death_year = None
        self.roster_province = None
        self.roster_slot = None
        self.glyph = None            # the 13-byte kanji plate, when the ROM bank
        self.chr_page = None         # is available, plus its 1KB CHR font page
        self.label = ''              # (read-only, see NAME_GLYPH_*)
        self.portrait_page = None    # card portrait CHR page id, when the card
        self.portrait_chr = None     # bank + page table are available, plus
        self.portrait_body = ()      # the 14-sprite body and the per-expression
        self.portrait_faces = {}     # 6-sprite faces (see PORTRAIT_*)

    # --- display names ---------------------------------------------------
    @property
    def name(self):
        """Best available name for a listing: 漢字, else kana, else the id."""
        return self.zh_hans or self.kanji_ja or self.katakana or '#%d' % self.id

    def title(self):
        bits = ' '.join(p for p in (self.katakana, self.zh_hans) if p)
        return '%3d %s' % (self.id, bits or '(unnamed)')

    @property
    def weapon(self):
        return WEAPONS.get(self.weapon_index, '?%d' % self.weapon_index)

    @property
    def armor(self):
        return ARMOR.get(self.armor_index, '?%d' % self.armor_index)

    @property
    def army_affinity(self):
        return ARMY_AFFINITY.get(self.army_affinity_bits,
                                 '?%d' % self.army_affinity_bits)

    @property
    def officer_status(self):
        return OFFICER_STATUS.get(self.officer_status_bits,
                                  '?%d' % self.officer_status_bits)

    @property
    def is_ruler(self):
        return self.loyalty == 100

    @property
    def is_hidden(self):
        return self.officer_status_bits == 1

    def placement(self):
        """Where the seed puts him: a roster slot, an arrival year, or neither."""
        if self.roster_province is not None:
            governor = ' (太守 governor)' if self.roster_slot == 0 else ''
            return 'province %d slot %d%s' % (self.roster_province,
                                              self.roster_slot, governor)
        if self.schedule_province_id is not None and self.appear_year is not None:
            return 'arrives %d in province %d' % (self.appear_year,
                                                  self.schedule_province_id)
        if self.schedule_province_id is not None or self.appear_year is not None:
            return 'incomplete arrival entry'
        return 'unscheduled (hidden, found by the free-officer scans)'

    # --- bytes -----------------------------------------------------------
    def fields(self):
        return {key: getattr(self, key) for key in (
            'vitality', 'might', 'intelligence', 'loyalty', 'virtue',
            'experience', 'troop_count', 'weapon_index', 'armor_index',
            'officer_level', 'army_affinity_bits', 'officer_status_bits')}

    def record(self):
        return record_from_fields(self.fields())

    def name_bytes(self):
        return encode_name(self.katakana)

    def death_byte(self):
        return None if self.death_year is None else \
            self.death_year - DEATH_YEAR_OFFSET

    @property
    def glyph_page(self):
        """CHR page id of the kanji name plate, or None when unavailable."""
        return None if not self.glyph else self.glyph[0]

    def glyph_kanji(self):
        """The kanji of the name plate as tile quadruples, in draw order."""
        if not self.glyph:
            return []
        out = []
        for start in range(1, NAME_GLYPH_STRIDE, NAME_GLYPH_TILES):
            quad = tuple(self.glyph[start:start + NAME_GLYPH_TILES])
            if len(quad) < NAME_GLYPH_TILES or quad[0] == GLYPH_TERMINATOR:
                break
            out.append(quad)
        return out

    def plate_pixels(self):
        """Each plate kanji as a 16x16 tuple of 2bpp pixel values.

        Empty unless both the plate record (glyph_bank) and its CHR font page
        (chr_dir) were loaded. Pixel value 0 is transparent; 1-3 index
        NAME_SPRITE_PALETTE.
        """
        if not self.glyph or not self.chr_page:
            return []
        page = self.chr_page
        out = []
        for quad in self.glyph_kanji():
            rows = []
            for gy in range(PLATE_TILES_PER_SIDE * 8):
                row = []
                for gx in range(PLATE_TILES_PER_SIDE * 8):
                    tile = quad[(gy // 8) * PLATE_TILES_PER_SIDE + gx // 8]
                    base = tile * PLATE_TILE_BYTES
                    bit = 7 - gx % 8
                    p0 = page[base + gy % 8]
                    p1 = page[base + 8 + gy % 8]
                    row.append((p0 >> bit & 1) | ((p1 >> bit & 1) << 1))
                rows.append(tuple(row))
            out.append(tuple(rows))
        return out

    def portrait_pixels(self, expression=0):
        """The officer's card portrait as (width, rows) of pixel colours.

        Composes the bank-$01 body blob and the expression's face blob (each
        an 8x8-sprite grid, see PORTRAIT_*) over the portrait CHR page. Each
        non-transparent pixel is the (r, g, b) triple of its sprite's attr
        palette (PORTRAIT_SPRITE_PALETTES); 0 marks transparency. Returns
        None when no authored portrait (marker page) or no CHR chunk was
        loaded. Expressions 0/1 are both the normal face.
        """
        if not self.portrait_body or not self.portrait_chr:
            return None
        face = self.portrait_faces.get(0 if expression < 2 else expression)
        if face is None:
            return None
        cells = {}
        for y, x, tile, attr in self.portrait_body + face:
            base = tile * PLATE_TILE_BYTES
            pal = PORTRAIT_SPRITE_PALETTES[attr & 0x03]
            for ty in range(8):
                sy = 7 - ty if attr & 0x80 else ty
                p0 = self.portrait_chr[base + sy]
                p1 = self.portrait_chr[base + 8 + sy]
                for tx in range(8):
                    bit = 7 - (7 - tx if attr & 0x40 else tx)
                    v = (p0 >> bit & 1) | ((p1 >> bit & 1) << 1)
                    if v:
                        cells[(x + tx, y + ty)] = NES_RGB[pal[v]]
        if not cells:
            return None
        x0 = min(x for x, _ in cells)
        y0 = min(y for _, y in cells)
        width = max(x for x, _ in cells) - x0 + 1
        height = max(y for _, y in cells) - y0 + 1
        rows = [tuple(cells.get((x0 + gx, y0 + gy), 0)
                      for gx in range(width))
                for gy in range(height)]
        return width, rows

    def glyph_cpu(self):
        return NAME_GLYPH_CPU + self.id * NAME_GLYPH_STRIDE

    def record_cpu(self):
        return RECORD_CPU + self.id * RECORD_STRIDE

    def name_cpu(self):
        return NAME_CPU + self.id * NAME_STRIDE

    def sram_addr(self):
        return SRAM_RECORD_BASE + self.id * RECORD_STRIDE

    def summary(self):
        """The same one-line decode the asm comment carries."""
        return ('id %3d %s %s 体%d 武%d 知%d 忠%d 徳%d Lv%d 経験%d 兵%d | %s軍 '
                '%s | %s/%s (+0B=$%02X)'
                % (self.id, self.katakana, self.zh_hans, self.vitality,
                   self.might, self.intelligence, self.loyalty, self.virtue,
                   self.officer_level, self.experience, self.troop_count,
                   self.army_affinity, self.officer_status, self.weapon,
                   self.armor, status_byte(self.fields())))

    # --- generic access --------------------------------------------------
    def get(self, key):
        if key not in FIELD_BY_KEY:
            raise FieldError('no such officer field: %r' % key)
        return getattr(self, key)

    def state(self):
        """Everything editable, as one comparable tuple (for diff/undo)."""
        return tuple(self.get(key) for key in EDITABLE)


class Province:
    """The roster half of a province record - all the officer editor owns."""

    def __init__(self, pid, katakana='', zh_hans='', record=None):
        self.id = pid
        self.katakana = katakana
        self.zh_hans = zh_hans
        self.roster = []          # officer ids in slot order, no holes
        self.record = bytearray(record or ())

    @property
    def name(self):
        return self.zh_hans or self.katakana or '#%d' % self.id

    def title(self):
        return '%2d %s %s' % (self.id, self.katakana, self.zh_hans)

    @property
    def governor(self):
        """太守 = whoever occupies roster slot +$11, i.e. index 0 here."""
        return self.roster[0] if self.roster else None

    def roster_record(self):
        """The 32 record bytes with the roster slots rewritten from `roster`."""
        if not self.record:
            return None
        rec = bytearray(self.record)
        for slot in range(ROSTER_SLOTS):
            rec[ROSTER_START + slot] = (self.roster[slot] if slot <
                                        len(self.roster) else EMPTY_SLOT)
        return bytes(rec)


Change = namedtuple('Change', 'oid field jp old new')


def _load_chr_chunk(chr_dir, page):
    """The 1KB CHR chunk for page id V: rom/chr/chr_(V//8).bin @ (V%8)*$400."""
    if not chr_dir:
        return None
    path = os.path.join(chr_dir, 'chr_%02x.bin' % (page // 8))
    if not os.path.exists(path):
        return None
    with open(path, 'rb') as f:
        f.seek((page % 8) * PLATE_CHUNK_BYTES)
        chunk = f.read(PLATE_CHUNK_BYTES)
    return chunk if len(chunk) == PLATE_CHUNK_BYTES else None


def _read_oam_blob(bank, ptr_cpu):
    """One SpriteOamWriterSimple blob: records [y, tile, attr, x] + $80.

    Returns ((y, x, tile, attr), ...) with the tile made page-local
    (tile & $3F); flip/behind bits stay in attr.
    """
    ptr = ptr_cpu - WINDOW_CPU
    cursor = (bank[ptr] | (bank[ptr + 1] << 8)) - WINDOW_CPU
    out = []
    while cursor + PORTRAIT_SPRITE_REC <= len(bank) \
            and bank[cursor] != PORTRAIT_SPRITE_END:
        y, tile, attr, x = bank[cursor:cursor + PORTRAIT_SPRITE_REC]
        out.append((y, x, tile & 0x3F, attr))
        cursor += PORTRAIT_SPRITE_REC
    return tuple(out)


class Model:
    """The three CSV twins, their officers, and the rules that bind them.

    `province_csv` and `death_csv` are optional: without them the roster and
    death-year surfaces switch off and say why, which is what lets the editor
    run on a lone `officer_data.csv` outside the repo. `glyph_bank` (the stock
    `rom/prg/prg_11.bin`) is optional the same way: with it each officer also
    carries the read-only kanji name plate, so a rename can be reported as
    leaving that authored CHR data behind.
    """

    def __init__(self):
        self.officers = []
        self.provinces = []
        self.paths = {}
        self.fieldnames = {}
        self.rows = {}
        self._by_id = {}
        self._baseline = {'officers': {}, 'rosters': {}}
        self.chr_pages = {}          # plate font page id -> 1KB of CHR, when
        self.portrait_chunks = {}    # portrait page id -> 1KB of CHR, likewise
        self.reinforce_pools = []    # (Country id, [(officer id, join year)])
        self.loaded = False          # rom/chr was found beside the glyph bank

    # --- loading ---------------------------------------------------------
    @classmethod
    def load(cls, officer_csv, province_csv=None, death_csv=None,
             labels_inc=None, glyph_bank=None, chr_dir=None,
             reinforce_csv=None, card_bank=None, portrait_page_bank=None):
        m = cls()
        m.paths['officer'] = officer_csv
        header, rows = _read_csv(officer_csv)
        missing = [c for c in ('id', 'katakana', 'vitality', 'might',
                               'intelligence', 'loyalty', 'virtue',
                               'officer_level', 'experience', 'troop_count',
                               'weapon_index', 'armor_index',
                               'army_affinity_bits', 'officer_status_bits')
                   if c not in header]
        if missing:
            raise OfficerError('%s: missing column(s) %s - is this the '
                               'docs/officer_data.csv written by '
                               'tools/extract_officer_data.py?'
                               % (officer_csv, ', '.join(missing)))
        m.fieldnames['officer'] = header
        m.rows['officer'] = {_int(r['id']): r for r in rows}
        labels = _load_labels(labels_inc) if labels_inc else {}
        for row in rows:
            off = Officer(_int(row['id']), row.get('katakana', ''),
                          row.get('zh_hans', ''), row.get('kanji_ja', ''),
                          row.get('pinyin', ''))
            for key in ('vitality', 'might', 'intelligence', 'loyalty',
                        'virtue', 'officer_level', 'experience', 'troop_count',
                        'weapon_index', 'armor_index', 'army_affinity_bits',
                        'officer_status_bits'):
                setattr(off, key, _int(row[key]))
            off.schedule_province_id = _int_or_none(
                row.get('schedule_province_id'))
            off.appear_year = _int_or_none(row.get('appear_year'))
            off.label = labels.get(off.id, '')
            m.officers.append(off)
        m.officers.sort(key=lambda o: o.id)
        m._by_id = {o.id: o for o in m.officers}

        if province_csv and os.path.exists(province_csv):
            m.paths['province'] = province_csv
            header, rows = _read_csv(province_csv)
            m.fieldnames['province'] = header
            m.rows['province'] = {_int(r['id']): r for r in rows}
            for row in rows:
                prov = Province(_int(row['id']), row.get('katakana', ''),
                                row.get('zh_hans', ''),
                                _hex_bytes(row.get('hex')))
                prov.roster = [_int(o) for o in row.get('officer_ids',
                                                         '').split()]
                m.provinces.append(prov)
            m.provinces.sort(key=lambda p: p.id)
            m._apply_rosters()

        if death_csv and os.path.exists(death_csv):
            m.paths['death'] = death_csv
            header, rows = _read_csv(death_csv)
            m.fieldnames['death'] = header
            m.rows['death'] = {_int(r['id']): r for r in rows}
            by_id = m.rows['death']
            for off in m.officers:
                row = by_id.get(off.id)
                if row is not None:
                    off.death_year = _int(row['table_byte']) + DEATH_YEAR_OFFSET

        if glyph_bank and os.path.exists(glyph_bank):
            with open(glyph_bank, 'rb') as f:
                bank = f.read()
            base = NAME_GLYPH_CPU - WINDOW_CPU
            if len(bank) >= base + OFFICER_COUNT * NAME_GLYPH_STRIDE:
                m.paths['glyph_bank'] = glyph_bank
                for off in m.officers:
                    start = base + off.id * NAME_GLYPH_STRIDE
                    off.glyph = bank[start:start + NAME_GLYPH_STRIDE]
                pool_base = REINFORCE_PTR_CPU - WINDOW_CPU
                for pi in range(REINFORCE_POOL_COUNT):
                    word = bank[pool_base + pi * 2] \
                        | (bank[pool_base + pi * 2 + 1] << 8)
                    addr = (word & 0xFF) | (((word >> 8)
                                             + REINFORCE_PTR_HI_BIAS) << 8)
                    cursor = addr - WINDOW_CPU
                    pairs = []
                    while cursor < base \
                            and bank[cursor] != GLYPH_TERMINATOR:
                        pairs.append((bank[cursor],
                                      bank[cursor + 1] + REINFORCE_YEAR_OFFSET))
                        cursor += 2
                    m.reinforce_pools.append(
                        (REINFORCE_POOL_COUNTRIES[pi], pairs))
                if chr_dir and os.path.isdir(chr_dir):
                    m.paths['chr_dir'] = chr_dir
                    pages = {off.glyph[0] for off in m.officers}
                    for page in sorted(pages):
                        chunk = _load_chr_chunk(chr_dir, page)
                        if chunk is not None:
                            m.chr_pages[page] = chunk
                    for off in m.officers:
                        off.chr_page = m.chr_pages.get(off.glyph[0])

        if card_bank and portrait_page_bank \
                and os.path.exists(card_bank) \
                and os.path.exists(portrait_page_bank):
            # The card portrait is read-only authored data: the page table
            # lives in prg_1a ($CED6), the body/face OAM blobs in prg_01
            # (bank $01, mapped $8000-$9FFF).
            with open(portrait_page_bank, 'rb') as f:
                page_bank = f.read()
            table = page_bank[PORTRAIT_PAGE_OFFSET:
                              PORTRAIT_PAGE_OFFSET + OFFICER_COUNT]
            with open(card_bank, 'rb') as f:
                card = f.read()
            class_base = PORTRAIT_CLASS_BASE_CPU - WINDOW_CPU
            if len(table) == OFFICER_COUNT and len(card) >= class_base + \
                    OFFICER_COUNT:
                m.paths['portrait'] = portrait_page_bank
                for off in m.officers:
                    page = table[off.id]
                    chunk = m.portrait_chunks.get(page)
                    if chunk is None:
                        chunk = _load_chr_chunk(chr_dir, page)
                        if chunk is not None:
                            m.portrait_chunks[page] = chunk
                    off.portrait_page = page
                    if chunk is None:
                        continue    # page known but its CHR file is missing
                    off.portrait_chr = chunk
                    slot = card[class_base + off.id]     # class base 0/5/10/15
                    off.portrait_body = _read_oam_blob(
                        card, PORTRAIT_BODY_PTR_CPU + slot * 2)
                    off.portrait_faces = {
                        expr: _read_oam_blob(
                            card, PORTRAIT_FACE_PTR_CPU + (expr + slot) * 2)
                        for expr, _ in PORTRAIT_EXPRESSIONS}

        if reinforce_csv and os.path.exists(reinforce_csv):
            # The CSV is the editing surface and wins over the bank parse:
            # the generator re-renders the pools from it, so the model must
            # diff and save against the same rows.
            header, rows = _read_csv(reinforce_csv)
            missing = [c for c in ('pool', 'country', 'officer_id',
                                   'join_year') if c not in header]
            if missing:
                raise OfficerError('%s: missing column(s) %s - is this the '
                                   'docs/officer_reinforcement.csv written by '
                                   'tools/extract_reinforcement_pools.py?'
                                   % (reinforce_csv, ', '.join(missing)))
            m.fieldnames['reinforce'] = header
            m.rows['reinforce'] = [_int(r['officer_id']) for r in rows]
            pools = {pi: [] for pi in range(REINFORCE_POOL_COUNT)}
            for row in rows:
                pools[_int(row['pool'])].append(
                    (_int(row['officer_id']),
                     _int(row['join_year'])
                     if row.get('join_year') else
                     _int(row['table_byte']) + REINFORCE_YEAR_OFFSET))
            m.reinforce_pools = [
                (REINFORCE_POOL_COUNTRIES[pi], pools[pi])
                for pi in range(REINFORCE_POOL_COUNT)]
            m.paths['reinforce'] = reinforce_csv

        m.loaded = True
        m._snapshot_baseline()
        return m

    def _apply_rosters(self):
        for off in self.officers:
            off.roster_province = None
            off.roster_slot = None
        for prov in self.provinces:
            for slot, oid in enumerate(prov.roster):
                off = self.by_id.get(oid)
                if off is None:
                    continue
                if off.roster_province is None:
                    off.roster_province = prov.id
                    off.roster_slot = slot

    @property
    def by_id(self):
        return self._by_id

    def officer(self, oid):
        off = self.by_id.get(int(oid))
        if off is None:
            raise FieldError('no officer id %s (the table holds 0-%d)'
                             % (oid, OFFICER_COUNT - 1))
        return off

    def province(self, pid):
        for prov in self.provinces:
            if prov.id == int(pid):
                return prov
        raise FieldError('no province id %s (there are %d provinces)'
                         % (pid, PROVINCE_COUNT))

    @property
    def has_rosters(self):
        return bool(self.provinces)

    @property
    def has_deaths(self):
        return 'death' in self.paths

    @property
    def has_glyphs(self):
        """True when the kanji name plates were read from the stock bank."""
        return 'glyph_bank' in self.paths

    @property
    def has_chr(self):
        """True when the plates' CHR font pages are loaded and renderable."""
        return bool(self.chr_pages)

    @property
    def has_reinforce(self):
        """True when docs/officer_reinforcement.csv is loaded for editing."""
        return 'reinforce' in self.paths

    @property
    def has_portraits(self):
        """True when the card portraits (page table + OAM blobs) were read."""
        return 'portrait' in self.paths

    # --- editing ---------------------------------------------------------
    def set(self, oid, key, value):
        """Validate and apply one field edit; returns the old value."""
        off = self.officer(oid)
        spec = FIELD_BY_KEY.get(key)
        if spec is None:
            raise FieldError('no such officer field: %r (editable: %s)'
                             % (key, ', '.join(EDITABLE)))
        if key == 'death_year' and not self.has_deaths:
            raise FieldError('officer %d: no death-year CSV is loaded, so 死亡年 '
                             'has nowhere to be saved - pass '
                             'docs/officer_death_years.csv' % off.id)
        old = off.get(key)
        new = self._coerce(off, spec, value)
        if key == 'officer_status_bits':
            self._set_status(off, new)
        elif key in ('schedule_province_id', 'appear_year'):
            self._set_schedule_field(off, key, new)
        elif key == 'katakana':
            encode_name(new)          # fail before the edit lands
            off.katakana = new
        else:
            setattr(off, key, new)
        return old

    def _coerce(self, off, spec, value):
        if spec.nullable and value in (None, '', 'none', 'None', '-'):
            return None
        if spec.kind == 'text':
            return str(value).strip()
        if spec.kind == 'province':
            pid = _int(value)
            if not 0 <= pid < PROVINCE_COUNT:
                raise FieldError('%s: province %d out of range 0-%d'
                                 % (spec.en, pid, PROVINCE_COUNT - 1))
            if not self.has_rosters:
                raise FieldError('province data not loaded - pass the '
                                 'province CSV to edit arrival provinces')
            return pid
        try:
            num = _int(value)
        except (TypeError, ValueError):
            raise FieldError('%s: %r is not a number' % (spec.en, value))
        if spec.choices is not None and num not in [c[0] for c in spec.choices]:
            raise FieldError('%s: %d is not one of %s'
                             % (spec.en, num,
                                ' '.join(str(c[0]) for c in spec.choices)))
        if spec.lo is not None and not spec.lo <= num <= spec.hi:
            raise FieldError('%s: %d out of range %d-%d'
                             % (spec.en, num, spec.lo, spec.hi))
        return num

    def _set_status(self, off, value):
        if value == 2:
            if not self.has_rosters:
                raise FieldError(
                    'officer %d: province data is not loaded, so 状態 2 '
                    '(rostered) cannot be matched to a roster slot - load the '
                    'province CSV first' % off.id)
            if off.roster_province is None:
                raise FieldError(
                    'officer %d: 状態 2 (rostered) must equal a province roster '
                    'slot - assign him to a province instead (the roster is the '
                    'cross-bank gate in tools/verify_data_banks.py)' % off.id)
        elif off.roster_province is not None:
            self.unassign(off.id)
            return
        off.officer_status_bits = value

    def _set_schedule_field(self, off, key, value):
        if value is None:
            # One logical entry: a province with no year (or the reverse) is
            # dropped by the schedule renderer, so clearing clears both.
            off.schedule_province_id = None
            off.appear_year = None
            return
        if not off.is_hidden:
            raise FieldError(
                'officer %d: the arrival schedule only lists 状態 1 (hidden) '
                'officers - unassign him from province %s first'
                % (off.id, off.roster_province))
        other = 'schedule_province_id' if key == 'appear_year' else 'appear_year'
        if getattr(off, other) is None:
            raise FieldError('officer %d has no arrival entry to adjust - set '
                             'both halves at once with set_schedule(%d, '
                             'province, year)' % (off.id, off.id))
        setattr(off, key, value)

    def set_schedule(self, oid, province, year):
        """Create or change an officer's whole arrival entry (both halves)."""
        off = self.officer(oid)
        if not off.is_hidden:
            raise FieldError(
                'officer %d: the arrival schedule only lists 状態 1 (hidden) '
                'officers - unassign him from province %s first'
                % (off.id, off.roster_province))
        spec = FIELD_BY_KEY['schedule_province_id']
        pid = self._coerce(off, spec, province)
        year = self._coerce(off, FIELD_BY_KEY['appear_year'], year)
        if year is None:
            raise FieldError('officer %d: an arrival entry needs a year'
                             % off.id)
        off.schedule_province_id = pid
        off.appear_year = year

    def clear_schedule(self, oid):
        """Drop an officer's arrival entry (he stays hidden and unscheduled)."""
        off = self.officer(oid)
        off.schedule_province_id = None
        off.appear_year = None

    def assign(self, oid, pid, slot=None):
        """Place an officer in a province roster (状態 becomes 2).

        A rostered officer has no arrival entry (`OfficerArrivalScan` $B964 only
        considers 状態 1), so any schedule is cleared here and reported as part
        of the change set. `slot` 0 makes him the 太守 governor.
        """
        if not self.has_rosters:
            raise FieldError('province data not loaded - pass the province CSV '
                             'to edit rosters')
        off = self.officer(oid)
        prov = self.province(pid)
        # Validate before touching anything: an assign that raises half way
        # through would leave the officer out of both rosters.
        index = None
        if slot is not None:
            try:
                index = int(slot)
            except (TypeError, ValueError):
                raise FieldError('roster slot %r is not a number' % (slot,))
            if not 0 <= index < ROSTER_SLOTS:
                raise FieldError('roster slot %d out of range 0-%d'
                                 % (index, ROSTER_SLOTS - 1))
        if off.roster_province is not None and off.roster_province != prov.id:
            self.unassign(off.id)
        if off.roster_province is None:
            if len(prov.roster) >= ROSTER_SLOTS:
                raise FieldError('province %d (%s) already fills all %d roster '
                                 'slots' % (prov.id, prov.name, ROSTER_SLOTS))
            prov.roster.insert(len(prov.roster) if index is None else index,
                               off.id)
        elif index is not None and index != off.roster_slot:
            prov.roster.remove(off.id)
            prov.roster.insert(index, off.id)
        off.officer_status_bits = 2
        if off.schedule_province_id is not None or off.appear_year is not None:
            off.schedule_province_id = None
            off.appear_year = None
        self._apply_rosters()

    def unassign(self, oid):
        """Take an officer out of his roster (状態 becomes 1 hidden)."""
        off = self.officer(oid)
        if off.roster_province is None:
            return
        prov = self.province(off.roster_province)
        if off.id in prov.roster:
            prov.roster.remove(off.id)
        off.officer_status_bits = 1
        self._apply_rosters()

    def move_slot(self, oid, slot):
        """Re-order a roster, e.g. to make an officer the 太守 (slot 0)."""
        off = self.officer(oid)
        if off.roster_province is None:
            raise FieldError('officer %d is not in any province roster' % off.id)
        prov = self.province(off.roster_province)
        if not 0 <= int(slot) < len(prov.roster):
            raise FieldError('slot %s out of range 0-%d for province %d'
                             % (slot, len(prov.roster) - 1, prov.id))
        prov.roster.remove(off.id)
        prov.roster.insert(int(slot), off.id)
        self._apply_rosters()

    # --- derived views ---------------------------------------------------
    def schedule_blocks(self):
        """province id -> [(officer id, year)], in the order the asm renders."""
        blocks = {p: [] for p in range(PROVINCE_COUNT)}
        for off in self.officers:
            if off.schedule_province_id in (None, '') \
                    or off.appear_year in (None, ''):
                continue
            blocks.setdefault(int(off.schedule_province_id), []).append(
                (off.id, int(off.appear_year)))
        for pid in blocks:
            blocks[pid].sort(key=lambda pair: (pair[1], pair[0]))
        return blocks

    def reinforce_entry(self, oid):
        """(Country id, join year) when the officer sits in a pool, else None.

        The pool scan inducts the FIRST still-hidden officer whose year has
        arrived, in list order - the year is a gate, not a guaranteed date
        (earlier heirs that joined first shift nothing; a rostered officer is
        simply skipped by the status==hidden test).
        """
        for country, pairs in self.reinforce_pools:
            for pair_id, year in pairs:
                if pair_id == oid:
                    return country, year
        return None

    def set_reinforce_year(self, oid, year):
        """Change one heir's reinforcement join year, in place.

        Membership and list order live in docs/officer_reinforcement.csv
        too, but only the year has a single-officer editing command; moving
        an heir between countries is a CSV edit (the row order is the stored
        list order).
        """
        if not self.has_reinforce:
            raise FieldError('officer %d: no reinforcement CSV is loaded, so '
                             'the join year has nowhere to be saved - pass '
                             'docs/officer_reinforcement.csv' % oid)
        entry = self.reinforce_entry(oid)
        if entry is None:
            raise FieldError('officer %d is not in any reinforcement pool '
                             '(bank $31 $8D74) - to make him an heir, add a '
                             'row to docs/officer_reinforcement.csv' % oid)
        try:
            year = int(str(year), 0)      # $hex and 0xhex
        except ValueError:
            try:
                year = int(str(year))     # and plain decimal, incl. 0193
            except ValueError:
                raise FieldError('officer %d: reinforcement year %r is not a '
                                 'number' % (oid, year))
        if not REINFORCE_YEAR_RANGE[0] <= year <= REINFORCE_YEAR_RANGE[1]:
            raise FieldError('officer %d: reinforcement year %d does not fit '
                             'the byte (year - %d)'
                             % (oid, year, REINFORCE_YEAR_OFFSET))
        country = entry[0]
        for pi, (pool_country, pairs) in enumerate(self.reinforce_pools):
            if pool_country != country:
                continue
            self.reinforce_pools[pi] = (
                pool_country,
                [(pair_id, year if pair_id == oid else pair_year)
                 for pair_id, pair_year in pairs])
        return entry[1]

    def reinforce_rows(self):
        """The CSV rows for the pools, display columns recomputed."""
        rows = []
        for pool, (country, pairs) in enumerate(self.reinforce_pools):
            for oid, year in pairs:
                off = self.by_id.get(oid)
                rows.append({
                    'pool': pool, 'country': country, 'officer_id': oid,
                    'katakana': off.katakana if off else '?',
                    'zh_hans': (off.zh_hans or off.katakana or '#%d' % oid)
                               if off else '?',
                    'table_byte': year - REINFORCE_YEAR_OFFSET,
                    'join_year': year})
        return rows

    def roster_map(self):
        """officer id -> province id, from the province rosters alone."""
        return {oid: prov.id for prov in self.provinces
                for oid in prov.roster}

    def province_choices(self):
        return [(p.id, '%2d %s %s' % (p.id, p.katakana, p.zh_hans))
                for p in self.provinces]

    def record_bytes(self):
        """All 237 records concatenated, as bank $31 `$8000` holds them."""
        return b''.join(off.record() for off in self.officers)

    def name_bytes(self):
        """All 237 name fields concatenated, as bank $30 `$901A` holds them."""
        return b''.join(off.name_bytes() for off in self.officers)

    def death_bytes(self):
        """The 237 death-year bytes, or None when that CSV is not loaded."""
        if not self.has_deaths:
            return None
        return bytes(off.death_byte() if off.death_byte() is not None else 0
                     for off in self.officers)

    # --- validation ------------------------------------------------------
    def problems(self):
        """Hard invariant breaks - the assembled bank would fail the byte gate."""
        out = []
        ids = [o.id for o in self.officers]
        if len(self.officers) != OFFICER_COUNT:
            out.append('expected %d officers, got %d'
                       % (OFFICER_COUNT, len(self.officers)))
        if sorted(ids) != list(range(OFFICER_COUNT)):
            out.append('officer ids are not exactly 0-%d' % (OFFICER_COUNT - 1))
        rostered = self.roster_map()
        for off in self.officers:
            tag = 'officer %d (%s)' % (off.id, off.name)
            for key in ('vitality', 'might', 'intelligence', 'loyalty',
                        'virtue'):
                value = off.get(key)
                if not STAT_RANGE[0] <= value <= STAT_RANGE[1]:
                    out.append('%s: %s is %d, must be %d-%d'
                               % (tag, FIELD_BY_KEY[key].jp, value,
                                  STAT_RANGE[0], STAT_RANGE[1]))
            if not LEVEL_RANGE[0] <= off.officer_level <= LEVEL_RANGE[1]:
                out.append('%s: レベル is %d, must be %d-%d (the record stores '
                           'it 0-based in 4 bits)'
                           % (tag, off.officer_level, LEVEL_RANGE[0],
                              LEVEL_RANGE[1]))
            if not 0 <= off.army_affinity_bits <= 2:
                out.append('%s: 軍の属性 is %d, valid 0-2'
                           % (tag, off.army_affinity_bits))
            if off.officer_status_bits not in SEED_STATUSES:
                out.append('%s: 状態 is %d, the seed only holds 1 (hidden) or 2 '
                           '(rostered)' % (tag, off.officer_status_bits))
            for key in ('experience', 'troop_count'):
                if not WORD_RANGE[0] <= off.get(key) <= WORD_RANGE[1]:
                    out.append('%s: %s is %d, must fit 16 bits'
                               % (tag, FIELD_BY_KEY[key].jp, off.get(key)))
            if off.weapon_index not in WEAPONS:
                out.append('%s: 武器 index %d, the catalog holds 0-%d'
                           % (tag, off.weapon_index, max(WEAPONS)))
            if off.armor_index not in ARMOR:
                out.append('%s: 防具 index %d, the catalog holds 0-%d'
                           % (tag, off.armor_index, max(ARMOR)))
            try:
                raw = off.name_bytes()
            except NameEncodeError as exc:
                out.append('%s: 名前 %s' % (tag, exc))
                raw = None
            if raw is not None and raw[-1] != NAME_TERMINATOR:
                out.append('%s: 名前 fills all %d bytes, leaving no $00 '
                           'terminator' % (tag, NAME_STRIDE))
            if self.has_deaths and off.death_year is None:
                out.append('%s: the death-year CSV has no row for this id, so '
                           'the table byte would render as $00 (year %d)'
                           % (tag, DEATH_YEAR_OFFSET))
            if off.death_year is not None and not (
                    DEATH_YEAR_RANGE[0] <= off.death_year <= DEATH_YEAR_RANGE[1]):
                out.append('%s: 死亡年 %d, the table byte is year - %d so the '
                           'range is %d-%d'
                           % (tag, off.death_year, DEATH_YEAR_OFFSET,
                              DEATH_YEAR_RANGE[0], DEATH_YEAR_RANGE[1]))
            has_prov = off.schedule_province_id is not None
            has_year = off.appear_year is not None
            if has_prov != has_year:
                out.append('%s: arrival entry is half filled (province %s, year '
                           '%s) - the renderer drops it, so set both or neither'
                           % (tag, off.schedule_province_id, off.appear_year))
            if has_prov and has_year:
                if not 0 <= off.schedule_province_id < PROVINCE_COUNT:
                    out.append('%s: 出現州 %d out of range 0-%d'
                               % (tag, off.schedule_province_id,
                                  PROVINCE_COUNT - 1))
                if not ARRIVAL_YEAR_RANGE[0] <= off.appear_year <= \
                        ARRIVAL_YEAR_RANGE[1]:
                    out.append('%s: 出現年 %d does not fit one byte'
                               % (tag, off.appear_year))
                if not off.is_hidden:
                    out.append('%s: has an arrival entry but 状態 is %d - the '
                               'schedule only lists hidden officers'
                               % (tag, off.officer_status_bits))
            if self.has_rosters:
                in_roster = off.id in rostered
                if (off.officer_status_bits == 2) != in_roster:
                    out.append('%s: 状態 %d but %s a province roster slot - the '
                               'two must be the same set'
                               % (tag, off.officer_status_bits,
                                  'not in' if in_roster else 'in'))
                if in_roster and rostered[off.id] != off.roster_province:
                    out.append('%s: rostered twice (provinces %s and %s)'
                               % (tag, rostered[off.id], off.roster_province))
        if self.has_rosters:
            for prov in self.provinces:
                if len(prov.roster) > ROSTER_SLOTS:
                    out.append('province %d (%s): %d officers in %d roster slots'
                               % (prov.id, prov.name, len(prov.roster),
                                  ROSTER_SLOTS))
                for oid in prov.roster:
                    if not 0 <= oid < OFFICER_COUNT:
                        out.append('province %d (%s): roster slot holds %d, '
                                   'must be < %d'
                                   % (prov.id, prov.name, oid, OFFICER_COUNT))
                rulers = [o for o in prov.roster
                          if self.by_id.get(o) and self.by_id[o].is_ruler]
                if len(rulers) > 1:
                    out.append('province %d (%s): %d officers with 忠誠度 100 '
                               '(%s) - only one can be the 君主 ruler'
                               % (prov.id, prov.name, len(rulers),
                                  ', '.join(str(r) for r in rulers)))
        # A schedule block is ARRIVAL_STRIDE bytes = ARRIVAL_PAIRS pairs and
        # the renderer emits exactly that many, so this bound holds whether or
        # not the province CSV is loaded - it reads the officer rows alone.
        for pid, pairs in sorted(self.schedule_blocks().items()):
            if len(pairs) > ARRIVAL_PAIRS:
                out.append('province %d: %d arrival entries, but a schedule '
                           'block is %d bytes = %d pairs'
                           % (pid, len(pairs), ARRIVAL_STRIDE, ARRIVAL_PAIRS))
        for country, pairs in self.reinforce_pools:
            for oid, year in pairs:
                if not 0 <= oid < OFFICER_COUNT:
                    out.append('reinforcement pool (Country %d): officer id %d '
                               'is out of range 0-%d'
                               % (country, oid, OFFICER_COUNT - 1))
                if not ARRIVAL_YEAR_RANGE[0] <= year <= ARRIVAL_YEAR_RANGE[1]:
                    out.append('reinforcement pool (Country %d): join year %d '
                               'does not fit one byte' % (country, year))
        return out

    def notes(self):
        """Conventions the stock ROM follows; each names the stock figure."""
        out = []
        if not self.has_rosters:
            out.append('province data not loaded - 状態 2 (rostered) cannot be '
                       'checked against the province roster slots, rosters '
                       'cannot be edited, and the two roster columns of the '
                       'officer CSV are left untouched on save')
        if not self.has_deaths:
            out.append('death-year CSV not loaded - 死亡年 is neither shown nor '
                       'written, so the bank $31 $9C58 table stays as rendered')
        if not self.has_glyphs:
            out.append('kanji name plates not loaded (no rom/prg/prg_11.bin '
                       'beside the CSVs) - a rename still re-encodes the kana '
                       'name only, and the plate it leaves behind cannot be '
                       'quoted')
        for off in self.officers:
            was = self._baseline['officers'].get(off.id)
            if was is None or was[0] == off.katakana:
                continue
            if off.glyph:
                quads = off.glyph_kanji()
                detail = ('page $%02X, %d kanji: %s'
                          % (off.glyph_page, len(quads),
                             ' '.join(' '.join('%02X' % t for t in q)
                                      for q in quads)))
            else:
                # The plate being absent makes the rename *less* verifiable, not
                # less incomplete, so the disclosure must not depend on it.
                detail = ('the glyph bank is not loaded here, so its page and '
                          'tile ids are not shown')
            out.append('officer %d: 名前 re-encoded to %s, but the kanji name '
                       'plate at $%04X is authored CHR data (%s) that nothing '
                       're-derives - the ruler card keeps drawing the old kanji'
                       % (off.id, off.katakana, off.glyph_cpu(), detail))
        rulers = [o for o in self.officers if o.is_ruler]
        if len(rulers) != STOCK_RULERS:
            out.append('%d officers have 忠誠度 100 (stock %d): %s'
                       % (len(rulers), STOCK_RULERS,
                          ', '.join('%d %s' % (o.id, o.name) for o in rulers)))
        scheduled = [o for o in self.officers if o.appear_year is not None]
        if len(scheduled) != STOCK_SCHEDULED:
            out.append('%d officers carry an arrival year (stock %d)'
                       % (len(scheduled), STOCK_SCHEDULED))
        unscheduled = [o for o in self.officers
                       if o.is_hidden and o.appear_year is None]
        if len(unscheduled) != STOCK_UNSCHEDULED_HIDDEN:
            out.append('%d hidden officers have no arrival entry (stock %d) - '
                       'the stock 26 are the family heirs that join Countries '
                       '2/3/4/6 through the reinforcement pools at bank $31 '
                       '$8D74 (one per January, EventReinforceGate $A33C / '
                       'OfficerReinforceScene $AEC0)'
                       % (len(unscheduled), STOCK_UNSCHEDULED_HIDDEN))
        if self.has_rosters:
            total = sum(len(p.roster) for p in self.provinces)
            if total != STOCK_ROSTERED:
                out.append('%d roster slots in use (stock %d)'
                           % (total, STOCK_ROSTERED))
            for prov in self.provinces:
                if prov.roster and prov.governor is not None:
                    gov = self.by_id.get(prov.governor)
                    if gov is not None and gov.officer_status_bits != 2:
                        out.append('province %d (%s): slot +$11 holds officer %d '
                                   'whose 状態 is %d - the 太守 governor must be '
                                   'rostered'
                                   % (prov.id, prov.name, gov.id,
                                      gov.officer_status_bits))
        for off in self.officers:
            want = EXPERIENCE_BY_LEVEL.get(off.officer_level)
            if want is not None and off.experience != want:
                out.append('officer %d (%s): 経験値 %d with レベル %d; every '
                           'other seed record pairs level %d with %d'
                           % (off.id, off.name, off.experience,
                              off.officer_level, off.officer_level, want))
            if off.is_hidden and off.troop_count:
                out.append('officer %d (%s): hidden but 兵数 %d - 現役 troops '
                           'are summed over the province roster only, so the '
                           'value is dead until he appears'
                           % (off.id, off.name, off.troop_count))
            if self.has_rosters and off.roster_province is not None \
                    and not off.troop_count \
                    and off.id not in STOCK_ROSTERED_NO_TROOPS:
                out.append('officer %d (%s): rostered with 兵数 0 (the stock '
                           'exceptions are %s)'
                           % (off.id, off.name,
                              '/'.join(str(i) for i in STOCK_ROSTERED_NO_TROOPS)))
            if off.appear_year is not None and off.death_year is not None \
                    and off.death_year <= off.appear_year:
                out.append('officer %d (%s): 死亡年 %d is not after 出現年 %d'
                           % (off.id, off.name, off.death_year, off.appear_year))
        years = [o.appear_year for o in self.officers
                 if o.appear_year is not None]
        if years and (min(years), max(years)) != STOCK_ARRIVAL_YEARS:
            out.append('arrival years span %d-%d (stock %d-%d)'
                       % (min(years), max(years), STOCK_ARRIVAL_YEARS[0],
                          STOCK_ARRIVAL_YEARS[1]))
        deaths = [o.death_year for o in self.officers
                  if o.death_year is not None]
        if deaths and (min(deaths), max(deaths)) != STOCK_DEATH_YEARS:
            out.append('death years span %d-%d (stock %d-%d)'
                       % (min(deaths), max(deaths), STOCK_DEATH_YEARS[0],
                          STOCK_DEATH_YEARS[1]))
        return out

    def report(self):
        """(problems, notes) as printable lines."""
        return self.problems(), self.notes()

    def problem_ids(self):
        """Officer ids that trip a hard invariant, for highlighting a list.

        Parsed back out of the message text on purpose: `problems()` is the only
        place that knows which officer a line is about, and keeping the two
        together stops a reworded message from silently losing its highlight.
        """
        ids = set()
        for line in self.problems():
            match = re.match(r'^officer (\d+)', line)
            if match:
                ids.add(int(match.group(1)))
        return ids

    # --- diff / undo -----------------------------------------------------
    def snapshot(self):
        """An opaque, comparable copy of everything editable (undo / diff)."""
        return {'officers': {o.id: o.state() for o in self.officers},
                'rosters': {p.id: list(p.roster) for p in self.provinces},
                'reinforce': tuple((country, oid, year)
                                   for country, pairs in self.reinforce_pools
                                   for oid, year in pairs)}

    def restore(self, snap):
        """Put every editable value back to a previous `snapshot()`.

        Values are applied directly, not through `set()`: a snapshot was already
        validated when it was taken, and re-validating would make undo refuse to
        walk back through a state the user has since made legal.
        """
        for off in self.officers:
            state = snap['officers'].get(off.id)
            if state is None:
                continue
            for key, value in zip(EDITABLE, state):
                setattr(off, key, value)
        for prov in self.provinces:
            roster = snap['rosters'].get(prov.id)
            if roster is not None:
                prov.roster = list(roster)
        self._apply_rosters()
        pools = []
        for country, oid, year in snap.get('reinforce', ()):
            if not pools or pools[-1][0] != country:
                pools.append((country, []))
            pools[-1][1].append((oid, year))
        if pools:
            self.reinforce_pools = pools

    def _snapshot_baseline(self):
        self._baseline = self.snapshot()

    def changes(self, snap=None):
        """Field-level changes against `snap` (default: the load/commit point)."""
        snap = snap or self._baseline
        out = []
        for off in self.officers:
            old = snap['officers'].get(off.id)
            if old is None:
                continue
            for key, was, now in zip(EDITABLE, old, off.state()):
                if was != now:
                    out.append(Change(off.id, key, FIELD_BY_KEY[key].jp,
                                      was, now))
        for prov in self.provinces:
            was = snap['rosters'].get(prov.id)
            if was is not None and was != prov.roster:
                out.append(Change(prov.id, 'officer_ids', '武将 roster',
                                  ' '.join(str(o) for o in was),
                                  ' '.join(str(o) for o in prov.roster)))
        # Pool membership only changes through a CSV reload (which re-baselines),
        # so within a session the entries line up by position.
        current = tuple((country, oid, year)
                        for country, pairs in self.reinforce_pools
                        for oid, year in pairs)
        for old, new in zip(snap.get('reinforce', ()), current):
            if old != new:
                out.append(Change(new[1], 'join_year', '継承年',
                                  old[2], new[2]))
        return out

    def commit(self):
        """Make the current state the new diff/undo baseline."""
        self._snapshot_baseline()

    def change_lines(self, changes=None):
        lines = []
        for ch in changes if changes is not None else self.changes():
            if ch.field == 'officer_ids':
                lines.append('province %d %s: %s -> %s'
                             % (ch.oid, ch.jp, ch.old or '(empty)',
                                ch.new or '(empty)'))
                continue
            if ch.field == 'join_year':
                off = self.by_id.get(ch.oid)
                lines.append('officer %d (%s) reinforcement join year: '
                             '%s -> %s'
                             % (ch.oid, off.name if off else '?',
                                ch.old, ch.new))
                continue
            off = self.by_id.get(ch.oid)
            lines.append('officer %d (%s) %s %s: %s -> %s'
                         % (ch.oid, off.name if off else '?', ch.jp,
                            FIELD_BY_KEY[ch.field].en,
                            _show(ch.field, ch.old), _show(ch.field, ch.new)))
        return lines

    # --- saving ----------------------------------------------------------
    def save(self, officer_csv=None, province_csv=None, death_csv=None,
             reinforce_csv=None):
        """Write back every loaded CSV (or the given paths), columns unchanged."""
        written = []
        officer_csv = officer_csv or self.paths.get('officer')
        if officer_csv:
            _write_csv(officer_csv, self.fieldnames['officer'],
                       [self.officer_row(o) for o in self.officers])
            written.append(officer_csv)
        province_csv = province_csv or self.paths.get('province')
        if province_csv and self.has_rosters:
            _write_csv(province_csv, self.fieldnames['province'],
                       [self.province_row(p) for p in self.provinces])
            written.append(province_csv)
        death_csv = death_csv or self.paths.get('death')
        if death_csv and self.has_deaths:
            _write_csv(death_csv, self.fieldnames['death'],
                       [self.death_row(o) for o in self.officers])
            written.append(death_csv)
        reinforce_csv = reinforce_csv or self.paths.get('reinforce')
        if reinforce_csv and self.has_reinforce:
            _write_csv(reinforce_csv, self.fieldnames['reinforce'],
                       self.reinforce_rows())
            written.append(reinforce_csv)
        return written

    def officer_row(self, off):
        """The CSV row for one officer, derived columns recomputed.

        The two roster columns are only recomputed when the province CSV is
        loaded: without it there is nothing to derive them from, and overwriting
        them would silently unroster all 57 officers on save.
        """
        row = dict(self.rows['officer'].get(off.id, {'id': off.id}))
        fields = off.fields()
        row.update({
            'katakana': off.katakana,
            'vitality': off.vitality, 'might': off.might,
            'intelligence': off.intelligence, 'loyalty': off.loyalty,
            'virtue': off.virtue, 'officer_level': off.officer_level,
            'experience': off.experience, 'troop_count': off.troop_count,
            'weapon_index': off.weapon_index, 'armor_index': off.armor_index,
            'army_affinity_bits': off.army_affinity_bits,
            'officer_status_bits': off.officer_status_bits,
            'weapon': off.weapon, 'armor': off.armor,
            'army_affinity': off.army_affinity,
            'officer_status': off.officer_status,
            'army_affinity_code': fields_from_record(off.record())[
                'army_affinity_code'],
            'schedule_province_id': '' if off.schedule_province_id is None
                                    else off.schedule_province_id,
            'appear_year': '' if off.appear_year is None else off.appear_year,
            'hex': off.record().hex().upper(),
        })
        if self.has_rosters:
            row['in_province_roster'] = off.roster_province is not None
            row['roster_province_id'] = '' if off.roster_province is None \
                else off.roster_province
        return {k: row.get(k, '') for k in self.fieldnames['officer']}

    def province_row(self, prov):
        """The CSV row for one province, roster-derived columns recomputed."""
        row = dict(self.rows['province'].get(prov.id, {'id': prov.id}))
        rostered = [self.by_id[o] for o in prov.roster if o in self.by_id]
        ruler = [o.id for o in rostered if o.is_ruler]
        rec = prov.roster_record()
        row.update({
            'officer_ids': ' '.join(str(o) for o in prov.roster),
            'officer_count': len(prov.roster),
            'active_troops': sum(o.troop_count for o in rostered),
            'officer_names': ' '.join(o.zh_hans or o.katakana or '#%d' % o.id
                                      for o in rostered),
            'ruler_officer_id': '' if not ruler else ruler[-1],
        })
        if rec is not None and 'hex' in row:
            row['hex'] = rec.hex().upper()
        return {k: row.get(k, '') for k in self.fieldnames['province']}

    def death_row(self, off):
        row = dict(self.rows['death'].get(off.id, {'id': off.id}))
        row.update({'katakana': off.katakana})
        if off.death_byte() is not None:
            row['table_byte'] = off.death_byte()
            row['death_year'] = off.death_year
        return {k: row.get(k, '') for k in self.fieldnames['death']}


# --- small helpers -------------------------------------------------------
def _read_csv(path):
    with open(path, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        return list(reader.fieldnames or []), list(reader)


def _write_csv(path, fieldnames, rows):
    with open(path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: row.get(k, '') for k in fieldnames})


def _int(value):
    if isinstance(value, int):
        return value
    text = str(value).strip()
    if text.lower().startswith('$'):
        return int(text[1:], 16)
    if text.lower().startswith('0x'):
        return int(text, 16)
    return int(text)


def _int_or_none(value):
    if value is None:
        return None
    text = str(value).strip()
    return _int(text) if text else None


def _hex_bytes(value):
    text = str(value or '').strip().lower()
    if text.startswith('$'):
        text = text[1:]
    elif text.startswith('0x'):
        text = text[2:]
    text = text.replace(' ', '').replace(',', '')
    try:
        return bytearray(bytes.fromhex(text))
    except ValueError:
        return bytearray()


def _load_labels(path):
    """`OFFICER_NAME = id` lines from include/officer_ids.inc -> {id: NAME}."""
    out = {}
    try:
        with open(path, encoding='utf-8') as f:
            for line in f:
                m = re.match(r'^OFFICER_([A-Z0-9_]+)\s*=\s*(\d+)', line)
                if m:
                    out[int(m.group(2))] = m.group(1)
    except OSError:
        pass
    return out


def _show(key, value):
    if value is None or value == '':
        return '(none)'
    if key == 'weapon_index':
        return '%d %s' % (value, WEAPONS.get(value, '?'))
    if key == 'armor_index':
        return '%d %s' % (value, ARMOR.get(value, '?'))
    if key == 'army_affinity_bits':
        return '%d %s軍 %s' % (value, ARMY_AFFINITY.get(value, '?'),
                               AFFINITY_EN.get(value, '?'))
    if key == 'officer_status_bits':
        return '%d %s' % (value, OFFICER_STATUS.get(value, '?'))
    return str(value)


# --- list view helpers (shared by the GUI and the CLI front-ends) --------
# Column spec: (key, heading, alignment). The keys are
# Officer attributes except `placement`, which is composed. `cell_text` is the
# single place that turns a value into what a row shows, so a filter, a sort and
# a printed table can never disagree about it.
COLUMNS = (
    ('id', 'id', 'e'),
    ('katakana', '名前 kana', 'w'),
    ('zh_hans', '漢字', 'w'),
    ('vitality', '体', 'e'),
    ('might', '武', 'e'),
    ('intelligence', '知', 'e'),
    ('loyalty', '忠', 'e'),
    ('virtue', '徳', 'e'),
    ('officer_level', 'Lv', 'e'),
    ('experience', '経験', 'e'),
    ('troop_count', '兵数', 'e'),
    ('army_affinity', '軍', 'center'),
    ('officer_status', '状態', 'w'),
    ('weapon', '武器', 'w'),
    ('armor', '防具', 'w'),
    ('placement', '配置 placement', 'w'),
    ('death_year', '死亡年', 'e'),
)
NUMERIC_COLUMNS = frozenset(key for key, _, align in COLUMNS if align == 'e')
STATUS_FILTERS = ('all', 'hidden (状態 1)', 'rostered (状態 2)',
                  'rulers (忠誠度 100)', 'unscheduled hidden')
STATUS_ALIASES = {'all': 0, 'hidden': 1, 'rostered': 2, 'ruler': 3,
                  'rulers': 3, 'unscheduled': 4}


def status_filter(text):
    """A full filter label or its short name -> the label, else None.

    The GUI dropdown passes labels; the CLI passes `--status rostered`.
    """
    if text is None or text == '':
        return STATUS_FILTERS[0]
    if text in STATUS_FILTERS:
        return text
    return STATUS_FILTERS[STATUS_ALIASES[str(text).strip().lower()]] \
        if str(text).strip().lower() in STATUS_ALIASES else None


def cell_text(model, off, key):
    """One list cell as text."""
    if key == 'placement':
        if off.roster_province is not None:
            prov = model.province(off.roster_province)
            return '%d %s%s' % (prov.id, prov.name,
                                ' 太守' if off.roster_slot == 0 else '')
        if off.appear_year is not None:
            if off.schedule_province_id is None:
                # problems() reports the half-filled entry; a cell must never
                # raise, or one bad row blanks the whole table.
                return 'arrives %d @?' % off.appear_year
            return 'arrives %d @%d' % (off.appear_year, off.schedule_province_id)
        if off.schedule_province_id is not None:
            return 'arrival entry incomplete'
        return '-'
    value = getattr(off, key, '')
    return '' if value is None else str(value)


def row_values(model, off):
    return tuple(cell_text(model, off, key) for key, _, _ in COLUMNS)


def matches(off, text='', province=None, status='all'):
    """The filter predicate both front-ends use."""
    if text:
        needle = text.strip().lower()
        haystack = ' '.join(str(x).lower() for x in (
            off.id, off.katakana, off.zh_hans, off.kanji_ja, off.pinyin,
            off.label, off.weapon, off.armor))
        if needle not in haystack:
            return False
    if province is not None and off.roster_province != province \
            and off.schedule_province_id != province:
        return False
    if status == STATUS_FILTERS[1]:
        return off.is_hidden
    if status == STATUS_FILTERS[2]:
        return not off.is_hidden
    if status == STATUS_FILTERS[3]:
        return off.is_ruler
    if status == STATUS_FILTERS[4]:
        return off.is_hidden and off.appear_year is None
    return True


def visible(model, text='', province=None, status='all'):
    return [o for o in model.officers if matches(o, text, province, status)]


def sort(model, officers, key, reverse=False):
    """Sort by a list column, on exactly the text that column shows."""
    if key in NUMERIC_COLUMNS:
        def value(off):
            text = cell_text(model, off, key)
            return (text == '', int(text) if text else 0)
    else:
        def value(off):
            return cell_text(model, off, key)
    return sorted(officers, key=value, reverse=reverse)


def sibling_path(path, name):
    """`name` beside `path`, else beside its parent directory, else None.

    An officer CSV opened from anywhere brings its own province/death twins
    with it, and the search goes one level up so that `docs/officer_data.csv`
    still finds the repo's `include/officer_ids.inc` and `rom/prg/prg_11.bin`.
    """
    base = os.path.dirname(os.path.abspath(path))
    for root in (base, os.path.dirname(base)):
        candidate = os.path.join(root, name)
        if os.path.exists(candidate):
            return candidate
    return None


def find_repo(*roots):
    """The disassembly checkout holding the asm generator, else None.

    `roots` are extra candidates (a `--repo` argument, the front-end's parent
    directory); this codec's own parent is always tried last, so a copied-out
    `officer_model.py` reports standalone instead of pointing at a repo it is
    no longer part of.
    """
    here = os.path.dirname(os.path.abspath(__file__))
    for root in tuple(roots) + (os.path.dirname(here),):
        if root and os.path.exists(os.path.join(root, 'tools',
                                                'gen_data_bank_asm.py')):
            return os.path.abspath(root)
    return None


def default_paths(root):
    """The three CSV twins (plus the id equates and the stock bank) in a repo."""
    docs = os.path.join(root, 'docs')
    return {
        'officer': os.path.join(docs, 'officer_data.csv'),
        'province': os.path.join(docs, 'province_data.csv'),
        'death': os.path.join(docs, 'officer_death_years.csv'),
        'reinforce': os.path.join(docs, 'officer_reinforcement.csv'),
        'labels': os.path.join(root, 'include', 'officer_ids.inc'),
        'glyph_bank': os.path.join(root, 'rom', 'prg', 'prg_11.bin'),
        'card_bank': os.path.join(root, 'rom', 'prg', 'prg_01.bin'),
        'portrait_page_bank': os.path.join(root, 'rom', 'prg', 'prg_1a.bin'),
        'chr_dir': os.path.join(root, 'rom', 'chr'),
    }


def load_default(root, require_officer=True):
    """Load whatever CSV twins exist under `root`."""
    paths = default_paths(root)
    if require_officer and not os.path.exists(paths['officer']):
        raise OfficerError('%s not found' % paths['officer'])
    labels = paths['labels'] if os.path.exists(paths['labels']) else None
    return Model.load(paths['officer'],
                      province_csv=paths['province'],
                      death_csv=paths['death'],
                      labels_inc=labels,
                      glyph_bank=paths['glyph_bank'],
                      chr_dir=paths['chr_dir'],
                      reinforce_csv=paths['reinforce'],
                      card_bank=paths['card_bank'],
                      portrait_page_bank=paths['portrait_page_bank'])


if __name__ == '__main__':
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    model = load_default(root)
    kanji = sum(1 for o in model.officers if o.plate_pixels())
    print('loaded %d officers, %d provinces, death years %s, plate glyphs %s'
          % (len(model.officers), len(model.provinces),
             'yes' if model.has_deaths else 'no',
             '%d/%d officers' % (kanji, len(model.officers))
             if model.has_chr else 'no (no rom/chr)'))
    hard, soft = model.report()
    for line in hard:
        print('FAIL: %s' % line)
    for line in soft:
        print('note: %s' % line)
    print('%d problems, %d notes' % (len(hard), len(soft)))
    raise SystemExit(1 if hard else 0)
