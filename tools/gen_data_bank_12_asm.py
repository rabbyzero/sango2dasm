#!/usr/bin/env python3
"""Render PRG bank $12 (the menu display-list bank) as annotated asm.

Bank $12 is pure data: it is mapped into the $8000-$9FFF window by SwitchBank8
and read by two consumers:

  - B1D_1E_MenuUpdate's stream VM (prg_1d_1e.asm $A154-$A2DA): SelectDataBankByPos
    ($A690) picks bank $12 whenever pos id >= $20 AND sub_state ($007A) is 3-8
    (@PosDataBankTable $A6A7, entry = $32), then CalcMenuDataPtr ($A61D) reads the
    .word at $8000 + pos*2 and adds $40 to the stored high byte, so
    stream address = stored word + $4000. The seed values reach pos_buf_0
    ($0310-$0313, a 4-entry UI queue) through B1F_OpenMsgWindow0/2/4/5 ($F26D-$F29B)
    and CmdPushPosition chains inside the streams themselves.
  - State_NewGameSetup (prg_1f.asm $E3FB): LDY #$32 / SwitchBank8_B, then
    B17_18_PpuCopyRaw streams 1 KB from $9AE3 to PPU $2000 (the new-game
    screen background nametable image, 960 tile bytes + 64 attribute bytes).

Layout (coverage proof: this generator asserts every region tiles exactly):

  $8000-$81FF  MenuStreamPtrTable  - 256 x .word, index = pos id; the stored
               word is stream_addr - $4000; unused entries are $0020 (never
               dereferenced: pos ids < $20 always select bank $13, and no code
               seeds the padded ids >= $20)
  $8200-$9AE2  MenuStreamArea      - 170 display-list streams in the MenuUpdate
               VM format (code/pputilerender_stream_architecture.md), packed
               back to back; one 165-byte orphan at $909D-$9141 is referenced
               by no table entry; some streams are shared by several pos ids
  $9AE3-$9EE2  NewGameBaseScreen  - 1 KB nametable image for PPU $2000
  $9EE3-$9FFF  $FF filler

Usage:
    python tools/gen_data_bank_12_asm.py            # preview on stdout
    python tools/gen_data_bank_12_asm.py --write    # update asm/banks/data_12.asm
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from menu_text_map import walk_stream, glyph_char  # noqa: E402  (shared stream VM decoder)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK = 0x12
BANK_BIN = os.path.join('rom', 'prg', 'prg_%02x.bin' % BANK)
ASM_PATH = os.path.join(ROOT, 'asm', 'banks', 'data_%02x.asm' % BANK)

WINDOW_CPU = 0x8000
BANK_SIZE = 0x2000
PTR_BIAS = 0x4000          # stream address = stored word + $4000
PTR_PADDING = 0x0020       # unused table entries
TABLE_END = 0x200          # 256 entries
STREAM_END = 0x1AE3        # exclusive: last stream byte at $9AE2
SCREEN_CPU = 0x9AE3
SCREEN_END = 0x9EE3        # exclusive
ROW_BYTES = 16
COMMENT_COL = 43

# pos id -> purpose, from the B1F_OpenMsgWindow0/2/4/5 call sites (LDA #imm directly
# before the call, enclosing proc name quoted). "n." = no corroborating name.
POS_NAMES = {
    0x20: 'country status overlay (CountryRotationDispatch)',
    0x21: 'ruler intro/duel route/succession panel',
    0x22: 'ruler intro/succession panel',
    0x23: 'command category menu / duel cmd route',
    0x24: 'army/castle/intrigue/warehouse cmd panel',
    0x25: 'castle cmd / duel parried panel',
    0x26: 'castle cmd / duel pursue death panel',
    0x27: 'army/castle/intrigue cmd / surrender panel',
    0x28: 'surrender execute / town cmd panel',
    0x29: 'army/castle/intrigue/town cmd panel',
    0x2A: 'castle/town cmd / duel pursuer setup',
    0x2B: 'castle cmd / duel tactic select',
    0x2C: 'castle cmd / duel command menu',
    0x2D: 'castle cmd panel',
    0x2E: 'castle cmd panel',
    0x2F: 'castle cmd panel',
    0x30: 'officer reinforce scene',
    0x31: 'castle/warehouse cmd panel',
    0x32: 'army/castle cmd panel',
    0x33: 'castle cmd panel',
    0x34: 'castle cmd panel',
    0x35: 'castle cmd panel',
    0x36: 'castle cmd panel',
    0x37: 'castle cmd panel',
    0x38: 'castle cmd / tactic dialog execute',
    0x39: 'castle cmd / duel gauge / reinforce',
    0x3A: 'castle cmd panel',
    0x3B: 'castle/intrigue cmd panel',
    0x3C: 'duel escape / intrigue cmd panel',
    0x3D: 'duel pursue strike panel',
    0x3E: 'intrigue cmd panel',
    0x3F: 'drought damage scene',
    0x40: 'own-province notice (IntrigueCommandDispatch)',
    0x41: 'army cmd panel',
    0x42: 'spoils armor grant panel',
    0x44: 'intrigue cmd panel',
    0x45: 'flood damage scene',
    0x46: 'unclaimed-land notice',
    0x47: 'roster-full notice',
    0x48: 'officer list panel',
    0x49: 'army/war town action panel',
    0x4A: 'intrigue/warehouse cmd panel',
    0x4B: 'cancel-confirm panel',
    0x4C: 'target-list-full notice',
    0x4D: 'damage/exchange notice panel',
    0x4E: 'cancel / march panel',
    0x4F: 'castle cmd panel',
    0x50: 'castle cmd panel',
    0x51: 'castle cmd panel',
    0x52: 'castle cmd / province menu',
    0x53: 'warehouse cmd panel',
    0x54: 'warehouse cmd panel',
    0x55: 'warehouse/exchange panel',
    0x57: 'warehouse cmd panel',
    0x58: 'warehouse cmd panel',
    0x59: 'warehouse cmd panel',
    0x5A: 'warehouse cmd panel',
    0x5B: 'warehouse cmd panel',
    0x5D: 'warehouse cmd panel',
    0x5E: 'warehouse cmd panel',
    0x60: 'army cmd panel',
    0x61: 'army cmd panel',
    0x62: 'army cmd panel',
    0x63: 'army cmd panel',
    0x64: 'army cmd panel',
    0x65: 'army cmd panel',
    0x66: 'army cmd panel',
    0x67: 'army cmd panel',
    0x68: 'army cmd panel',
    0x69: 'army cmd panel',
    0x6A: 'army cmd panel',
    0x6B: 'army cmd panel',
    0x6C: 'army cmd panel',
    0x6D: 'army cmd panel',
    0x6F: 'town cmd panel',
    0x70: 'town cmd panel',
    0x72: 'town cmd panel',
    0x73: 'town cmd / cancel panel',
    0x74: 'town cmd panel',
    0x75: 'town cmd panel',
    0x76: 'town cmd panel',
    0x77: 'town cmd panel',
    0x78: 'town cmd panel',
    0x79: 'intelligence-maxed notice',
    0x7A: 'hospital officer list',
    0x7B: 'taunt/warehouse panel',
    0x7C: 'taunt/warehouse panel',
    0x7D: 'rout check/warehouse panel',
    0x7E: 'retreat wait/warehouse panel',
    0x9A: 'town notice panel',
    0x9B: 'town notice panel',
    0xA0: 'officer march panel',
    0xA1: 'officer march panel',
    0xA2: 'officer march panel',
    0xA4: 'town cmd panel',
    0xA5: 'town cmd panel',
    0xA6: 'town cmd panel',
    0xA7: 'dest check/warehouse panel',
    0xA8: 'war town action notice',
    0xA9: 'war town action panel',
    0xAA: 'town/war town action panel',
    0xAB: 'town/war town action panel',
    0xAC: 'town/war town/warehouse panel',
    0xAD: 'town/war town action panel',
    0xAE: 'war town action panel',
    0xAF: 'war town action panel',
    0xB0: 'war town action panel',
    0xB1: 'war town action panel',
    0xB2: 'war town action panel',
    0xB3: 'war town action panel',
    0xB4: 'war town action panel',
    0xB7: 'army march/OfficerMarchDispatch panel',
    0xB8: 'move select panel',
    0xB9: 'castle cmd panel',
    0xBB: 'officer status/strategy request panel',
    0xBC: 'menu phase/tax collection panel',
    0xBD: 'march/rice harvest panel',
    0xBE: 'drought damage scene',
    0xBF: 'flood damage scene',
    0xC0: 'phase wait overlay',
    0xC1: 'succession/death/request overlay',
    0xC2: 'succession apply/request overlay',
    0xC3: 'officer transfer/request overlay',
    0xC6: 'move state init panel',
    0xC7: 'command menu setup panel',
    0xC8: 'province state menu',
    0xCA: 'officer turn init panel',
    0xCB: 'officer transfer target select',
    0xD0: 'ruler succession panel',
    0xD1: 'phase-3 command panel',
    0xD2: 'phase-6/7 formation menu',
    0xD3: 'phase-4 result damage panel',
    0xD4: 'phase-6/7 formation panel',
    0xD5: 'country rotation/exchange confirm',
    0xD6: 'province state init',
    0xD7: 'province/exchange select list',
    0xD8: 'province confirm/officer scroll',
    0xD9: 'province select list',
    0xDA: 'province menu / war result menu',
    0xDB: 'war result pick panel',
    0xDC: 'exchange select/scroll intro panel',
    0xDD: 'scroll text phase-2 panel',
    0xDE: 'scroll wait/reserve assign panel',
    0xDF: 'reserve assign/ending card panel',
    0xE0: 'strategy request panel',
    0xE1: 'window-row macro pushed by $DE/$E0: 32x tile $41',
    0xE2: 'window-row macro: 30x $F7 + $F8/$41 edge',
    0xE3: 'window-row macro: $41/$F9 ... $FA/$41 edge',
    0xE4: 'window-row macro: $41/$FB + $FC fill + $FD/$41 edge',
    0xE5: 'transfer refused/exchange/request overlay',
    0xE6: 'exchange select/request overlay',
    0xE7: 'season/date corner display',
    0xE8: 'province rebellion event',
    0xEA: 'battle text: success / phase-8 taunt',
    0xEB: 'battle text: failure / phase-8 taunt',
    0xEC: 'battle text: hit / phase-8 bind',
    0xED: 'battle text: miss / phase-8 bind',
    0xEE: 'crossbow volley/request overlay',
    0xEF: 'morale boost/intrigue overlay',
    0xF0: 'fire arrows overlay',
    0xF1: 'explosion/tactic point overlay',
    0xF4: 'command menu (funds ok) panel',
    0xF7: 'select target proceed panel',
    0xF9: 'army deploy panel',
    0xFA: 'battle retreat event overlay',
    0xFF: 'shared with $E7',
}

BANNER = """\
;===============================================================================
; DATA Bank 12 (PRG $12) - 8KB menu display-list bank, mapped into $8000-$9FFF
; by SwitchBank8; no code lives here (see code/bank_switch_map.md 5.2).
;
; GENERATED by tools/gen_data_bank_12_asm.py --write; byte-exactness is enforced
; by tools/verify_data_bank_12.py. Raw source: rom/prg/prg_12.bin (read-only) -
; do not hand-edit the rendered records.
;
; Selected as $32 from two consumers:
;   prg_1d_1e  SelectDataBankByPos $A690 + @PosDataBankTable $A6A7: bank $12 is
;              mapped whenever the pos id is >= $20 AND sub_state ($007A) is
;              3-8; CalcMenuDataPtr $A61D then reads the .word at
;              $8000 + pos*2 and adds $40 to its high byte, so
;              stream address = stored word + $4000. The pos ids enter the
;              4-entry UI queue pos_buf_0..3 ($0310-$0313) through
;              B1F_OpenMsgWindow0/2/4/5 ($F26D-$F29B) and through CmdPushPosition
;              ($82) chains inside the streams; CmdEndMenu ($80) shifts the
;              queue. pos ids < $20 always read bank $13 instead (its
;              pointer words are stored biased by -$20, this bank by -$40).
;   prg_1f     State_NewGameSetup $E3FB: LDY #$32 / SwitchBank8_B, then
;              B17_18_PpuCopyRaw copies 1 KB from $9AE3 to PPU $2000.
;
; Regions:
;   $8000-$81FF  MenuStreamPtrTable   256 x .word, index = pos id
;   $8200-$9AE2  MenuStreamArea       170 display-list streams, packed
;   $9AE3-$9EE2  NewGameBaseScreen    1 KB nametable image -> PPU $2000
;   $9EE3-$9FFF  $FF filler
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
;   the pointer table; ids < $20 re-select bank $13 mid-stream - pushes from
;   this bank target $03 (bank $13) and $E1-$E4), $83 pop position, $84/$85
;   overlay mode on/off, $86/$8A-$8F set VRAM address + 2 bytes [lo][hi],
;   $87/$88 indirect mode on/off, $89 set tile base offset + 1 byte, $90-$97
;   draw name slot 0-7 (bank $10 $901A officer names via RAM $042C), $98-$9B
;   draw BCD number slot 0-3 ('0' = tile $76), $9C/$9D/$9E/$9F draw name/7-char
;   name/formatted number/param name + 1 byte index.
;
; Text charmap (proven by decode anchors, see tools/menu_text_map.py): literal
; tile bytes in the two code spaces carry Japanese text - tiles $04-$38 are
; serial-gojukon katakana from ア (the officer-name code space; $32=ー $33=!
; $34=ィ $39/$3A dakuten/handakuten postfix), tiles $44-$75 are serial-gojukon
; hiragana from あ ($72-$75 ゃゅょっ). $01 = space. Any other literal, and
; everything under a nonzero $89 tile_base_offset, is window graphics shown
; as [XX]. Dynamic commands render as 〈名〉/〈省NN〉/⟨数⟩ placeholders.
; The full decoded text of every stream: python3 tools/report_stream_text.py.
;
; All 170 table-referenced streams terminate on $80 and cover $8200-$9AE2
; except the 165-byte orphan $909D-$9141 (MenuStreamUnused_909D), which no
; table entry points at; MenuStream_posF3 is the single byte $80 at $909C.
; Several streams are shared by consecutive pos ids (e.g. $CB-$D0, $E7+$FF);
; their labels use the lowest sharing id. Stream heads are tagged "vram" when
; the id is UI-queue-seeded (B1F_OpenMsgWindow* / direct $0310 writes) and as commands
; when the id is a CmdPushPosition target ($E1-$E4 in this bank).
;===============================================================================

.segment "CODE_BANK12"
"""


PUSH_TARGETS = {0x01, 0x03, 0xE1, 0xE2, 0xE3, 0xE4}
ROW_MACROS = {0xE1, 0xE2, 0xE3, 0xE4}   # push-invoked window-row macros in this bank

# pos id -> label suffix, from the stream's decoded text (tools/menu_text_map.py
# charmap; full per-stream text in build/stream_text_report.txt, regenerate with
# tools/report_stream_text.py). Blank/graphics-only streams keep the bare
# MenuStream_posXX label. Ids missing here have no table-referenced stream in
# this bank (they resolve in bank $13) or are pure window-blank primitives.
STREAM_NAMES = {
    0x20: 'StatusOverlayClear',
    0x21: 'DuelAttackMsg',
    0x22: 'DuelDamageDealtMsg',
    0x23: 'DuelKenseiMsg',
    0x24: 'DuelDesperateAttackMsg',
    0x25: 'DuelAttackEvadedMsg',
    0x26: 'DuelStrengthSpentMsg',
    0x27: 'DuelRulerLastWords',
    0x28: 'DuelCapturedMsg',
    0x29: 'DuelLeaveBattleMsg',
    0x2A: 'DuelChaseTauntMsg',
    0x2B: 'DuelTacticMenu',
    0x2C: 'DuelMenu2',
    0x2D: 'DuelRivalTaunt',
    0x2E: 'DuelRulerAngeredMsg',
    0x2F: 'DuelRefuseTaunt',
    0x30: 'DuelSurrenderDemand',
    0x31: 'DuelPersuadeHealth',
    0x32: 'DuelPersuadeLoyalty',
    0x33: 'DuelPersuadeTalent',
    0x34: 'DuelPersuadeRefused',
    0x35: 'DuelPersuadePostpone',
    0x36: 'DuelPersuadePonder',
    0x37: 'DuelPersuadeAccept',
    0x38: 'OfficerJoinedMsg',
    0x39: 'NoDamagePossibleMsg',
    0x3A: 'DuelChallengeMsg',
    0x3B: 'DuelInvitationMsg',
    0x3C: 'DuelFastFoeTaunt',
    0x3D: 'PursuitDamageMsg',
    0x3E: 'ItemSeiikenMsg',
    0x3F: 'ItemItkenMsg',
    0x40: 'ItemShichiseiMsg',
    0x41: 'ItemRyugatouMsg',
    0x42: 'ItemRyurinArmorMsg',
    0x48: 'WeaponTooHardMsg',
    0x49: 'SoldOutMsg',
    0x4A: 'LevelUpMightMsg',
    0x4B: 'LearnedTacticMsg',
    0x4C: 'TooFarForTacticMsg',
    0x4D: 'LevelUpMsg',
    0x4E: 'StrengthSpentMsg',
    0x4F: 'TroopsVitalityUpMsg',
    0x50: 'CastleCapturedMsg',
    0x51: 'CastleLostMsg',
    0x52: 'FullRetreatRegroupMsg',
    0x53: 'EnemyLeaderLostMsg',
    0x54: 'OurLeaderLostMsg',
    0x55: 'ArmyAnnihilatedMsg',
    0x60: 'TacticFloodPlan',
    0x61: 'TacticRiceBurnPlan',
    0x62: 'TacticCastleRaidPlan',
    0x63: 'TacticConfusePlan',
    0x64: 'TacticPersuadePlan',
    0x65: 'TacticRockfallPlan',
    0x66: 'TacticChainRiverPlan',
    0x67: 'TacticForestAmbushPlan',
    0x68: 'TacticDamBreakPlan',
    0x69: 'TacticLeverPlan',
    0x6A: 'TacticFirestormPlan',
    0x6B: 'TacticStoneTrapPlan',
    0x6C: 'EnemyTroopsUpMsg',
    0x6D: 'EnemyVitalityUpMsg',
    0x6E: 'EnemyBoundMsg',
    0x6F: 'EnemyRationsUpMsg',
    0x70: 'OfficerRecruitedMsg',
    0x71: 'EnemyRiverBlockedMsg',
    0x72: 'EnemyStoneMazeMsg',
    0x73: 'TacticFailApologyMsg',
    0x74: 'DuelNamedChallengeMsg',
    0x75: 'RivalSappedMsg',
    0x77: 'RivalSapFailedMsg',
    0x78: 'CrossbowVolleyAttackMsg',
    0x79: 'MoraleRaisedMsg',
    0x7A: 'FireArrowAttackMsg',
    0x7B: 'CannotMoveMsg',
    0x7C: 'DuelRequestAsk',
    0x7D: 'OfficerSubduedMsg',
    0x7E: 'PursuitDamageMsgB',
    0xA0: 'EnemyAttackInboundMsg',
    0xA1: 'EnemyTacticInboundMsg',
    0xA2: 'EnemyTacticFailedMsg',
    0xA3: 'TroopsChangedMsg',
    0xA4: 'VitalityChangedMsg',
    0xA5: 'ImmobilizedMsg',
    0xA6: 'RationsChangedMsg',
    0xA7: 'VillageEnterAsk',
    0xA8: 'RiceShopMenu',
    0xA9: 'RiceBuyAsk',
    0xAA: 'RiceSellAsk',
    0xAB: 'RiceBoughtMsg',
    0xAC: 'RiceSoldMsg',
    0xAD: 'ArmoryMenu',
    0xAE: 'ArmoryBuyAsk',
    0xAF: 'WeaponBoughtMsg',
    0xB0: 'NotEnoughGoldMsg',
    0xB1: 'HospitalIntro',
    0xB2: 'HealCostAsk',
    0xB3: 'NoHealNeededMsg',
    0xB4: 'HealedMsg',
    0xB5: 'EnemyRetreatedNews',
    0xB6: 'LostInStoneMazeMsg',
    0xB7: 'OfficerDefectedMsg',
    0xB8: 'AmbushedByFukheiMsg',
    0xB9: 'FukheiAmbushMsg',
    0xBA: 'FukheiHiddenMsg',
    0xBB: 'EnemyOfficerDamageMsg',
    0xBC: 'CaughtInEnemyTacticMsg',
    0xBD: 'OfficerRetreatedNews',
    0xBE: 'BattleWithdrawMsg',
    0xBF: 'RationsOutMsg',
    0xC0: 'OrderTargetAsk',
    0xC1: 'ArmyCmdMenu',
    0xC2: 'ReconTargetAsk',
    0xC3: 'AttackTargetAsk',
    0xC4: 'NoEnemyThereMsg',
    0xC5: 'AttackVowMsg',
    0xC6: 'MoveWhereAsk',
    0xC7: 'TacticSelectAsk',
    0xC8: 'RetreatByOrderMsg',
    0xC9: 'FullRetreatMsg',
    0xCA: 'StandbyWatchMsg',
    0xCB: 'AttackVowMsgB',
    0xD1: 'FormationLabelPanel',
    0xD2: 'UnitOrderAsk',
    0xD3: 'UnitStrengthSpentMsg',
    0xD4: 'FormationSelectAsk',
    0xD5: 'TactMapWindow',
    0xD6: 'RetreatCastleAsk',
    0xD7: 'ProvinceNumList',
    0xD8: 'ReturnedSafelyMsg',
    0xD9: 'NoCastleToReturnMsg',
    0xDA: 'RetreatDeniedMsg',
    0xDB: 'BattleOverMsg',
    0xDC: 'RetreatCastleAskP',
    0xDD: 'RetreatOfficerSelect',
    0xDE: 'OfficerGridPanel',
    0xDF: 'MoveOverTenWarn',
    0xE0: 'ShadingFillRows',
    0xE1: 'WindowRowFill',
    0xE2: 'WindowRowTop',
    0xE3: 'WindowRowHollow',
    0xE4: 'WindowRowBottom',
    0xE5: 'OfficerDropSelect',
    0xE6: 'OfficerDroppedMsg',
    0xE7: 'PointsPanel',
    0xE8: 'RebellionMsgClear',
    0xEA: 'TauntSuccessMsg',
    0xEB: 'TauntFailMsg',
    0xEC: 'BindImmobilizeMsg',
    0xED: 'JubakuFailMsg',
    0xEE: 'ArrowVolleyMsg',
    0xEF: 'MoraleUpMsg',
    0xF0: 'FireArrowAimMsg',
    0xF1: 'FireArrowLooseMsg',
    0xF2: 'NotEnoughMPMsg',
    0xF3: 'EndStub',
    0xF4: 'TacticTargetAsk',
    0xF5: 'TacticSuccessMsg',
    0xF6: 'TacticOnOfficerAsk',
    0xF7: 'TacticWrongSpotMsg',
    0xF8: 'TacticFailMsg',
    0xF9: 'DeployPlaceAsk',
    0xFA: 'OfficerRetreatedMsg',
    0xFB: 'TacticFireRaidPlan',
    0xFC: 'TacticTrapPlan',
    0xFD: 'TacticSmokePlan',
    0xFE: 'TacticAmbushPlan',
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
    pos id; streams maps target file offset -> dict
    with ids, tokens, end, queue, push_macro, label, expr (the asm expression
    the pointer table must emit for this target). A stream that is a strict
    suffix of an already-planned stream (pos $76 shares pos $75's last bytes:
    its leading PPU pair doubles as $75's trailing tile bytes) gets an alias
    expression instead of its own byte emission."""
    words = [data[pos * 2] | (data[pos * 2 + 1] << 8) for pos in range(256)]
    targets = {}
    for pos in range(256):
        if words[pos] != PTR_PADDING:
            targets.setdefault(words[pos] + PTR_BIAS - WINDOW_CPU, []).append(pos)
    streams = {}
    spans = []          # (start, end, label) of byte-owning streams, in order
    for tgt in sorted(targets):
        ids = sorted(targets[tgt])
        # pos $F3 is a one-byte $80 placeholder (StratagemState_Init seeds it to
        # end the menu immediately); it has no leading PPU pair to consume.
        queue = (not any(p in PUSH_TARGETS for p in ids)
                 and data[tgt] != 0x80)
        push_macro = any(p in ROW_MACROS for p in ids)
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
    # contiguity: primary streams plus the orphan must tile $8200-$9AE2
    covered = bytearray(BANK_SIZE)
    for tgt, st in streams.items():
        if st['alias']:
            continue
        for i in range(tgt, st['end']):
            assert not covered[i], 'overlap at %04X' % cpu_ofs(i)
            covered[i] = 1
    return words, streams, covered


def emit_ptr_table(words, streams):
    out = ['',
           '; --- $8000-$81FF  MenuStreamPtrTable: 256 x .word, index = pos id;',
           ';     stored word = stream address - $4000 (CalcMenuDataPtr adds $40 to the',
           ';     high byte); $0020 = unused entry, never dereferenced (pos ids < $20',
           ';     read bank $13, and no code seeds the padded ids >= $20) ---']
    out.append('MenuStreamPtrTable:')
    for pos in range(256):
        w = words[pos]
        addr = cpu_ofs(pos * 2)
        if w == PTR_PADDING:
            body = '  .word $%04X' % PTR_PADDING
            note = 'unused'
        else:
            tgt = w + PTR_BIAS - WINDOW_CPU
            st = streams[tgt]
            body = '  .word %s-$%04X' % (st['expr'], PTR_BIAS)
            ids = st['ids']
            names = [POS_NAMES.get(p) for p in ids]
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


def emit_streams(data, streams, covered):
    out = ['',
           '; --- $8200-$9AE2  MenuStreamArea: display-list streams for the bank $1D',
           ';     menu VM (legend in the banner), packed back to back; labels use the',
           ';     lowest pos id that targets the stream ---']
    out.append('MenuStreamArea:')
    last_end = 0x200
    orphan_done = False
    for tgt in sorted(streams):
        st = streams[tgt]
        if st['alias']:
            out.append('')
            out.append('; pos %s re-enters the tail of the stream above: its leading'
                       % ' '.join(hexb(p) for p in st['ids']))
            out.append('; PPU pair doubles as that stream\'s trailing tile bytes')
            out.append('%s = %s' % (st['label'], st['expr']))
            continue
        if not orphan_done and tgt > 0x109D:
            # gap $909D-$9141 between pos $F3's one-byte stream and pos $F4
            assert last_end == 0x109D, 'unexpected gap before %04X' % cpu_ofs(tgt)
            out.extend(emit_orphan(data, covered))
            orphan_done = True
            last_end = 0x1142
        assert last_end == tgt, 'gap before %04X (emitted to %04X)' % (
            cpu_ofs(tgt), cpu_ofs(last_end))
        ids = st['ids']
        tokens = st['tokens']
        end = st['end']
        names = [POS_NAMES.get(p) for p in ids if POS_NAMES.get(p)]
        head = '; --- %s-%s (%d B) pos %s%s ---' % (
            hexw(cpu_ofs(tgt)), hexw(cpu_ofs(end) - 1), end - tgt,
            ' '.join(hexb(p) for p in ids),
            ' ' + names[0] if names else ' (unnamed)')
        out.append('')
        out.append(head)
        if tokens[0][1].startswith('vram '):
            out.append(';     start PPU %s; %s' % (tokens[0][1][5:], stream_summary(tokens[1:])))
        elif st['push_macro']:
            out.append(';     pushed row macro; %s' % stream_summary(tokens))
        else:
            out.append(';     entered via CmdPushPosition; %s' % stream_summary(tokens))
        if st['lines']:
            out.append(';     text: "%s"' % ' / '.join(st['lines']))
        if len(ids) > 1:
            extra = [POS_NAMES[p] for p in ids[1:] if POS_NAMES.get(p)]
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
    assert orphan_done, 'orphan region never emitted'
    assert last_end == STREAM_END, (
        'stream area ends at %04X, expected %04X' % (cpu_ofs(last_end), cpu_ofs(STREAM_END)))
    for i in range(0x200, STREAM_END):
        assert covered[i], 'uncovered byte at %04X' % cpu_ofs(i)
    return out


def emit_orphan(data, covered):
    out = ['',
           '; --- $909D-$9141 (165 B) unreferenced by any pointer-table entry:',
           ';     leftover stream fragment (vram-set ladder and a $6A tile run,', 
           ';     terminated by $80) - kept as raw bytes ---']
    out.append('MenuStreamUnused_909D:')
    for a in range(0x109D, 0x1142, ROW_BYTES):
        chunk = data[a:min(a + ROW_BYTES, 0x1142)]
        body = '  .byte ' + ', '.join(hexb(v) for v in chunk)
        out.append('%s%s; %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                 hexw(cpu_ofs(a))))
    for i in range(0x109D, 0x1142):
        covered[i] = 1
    return out


# NewGameBaseScreen rows that carry the name-entry kana grid (the rest of the
# screen is window frame whose tiles coincidentally fall inside the kana code
# range, so only these rows get text annotations).
KANA_GRID_ROWS = {4, 5, 8, 9, 12, 13, 16, 17}


def screen_row_text(vals):
    parts = []
    for t in vals:
        ch = glyph_char(t)
        if ch is None:
            parts.append(' ' if t == 0x01 else '[%02X]' % t)
        else:
            parts.append(ch)
    return ''.join(parts).rstrip()


def emit_screen(data):
    out = ['',
           '; --- $9AE3-$9EE2  NewGameBaseScreen: 1 KB nametable image streamed to',
           ';     PPU $2000 by State_NewGameSetup (prg_1f $E3FB) via B17_18_PpuCopyRaw:',
           ';     960 tile bytes (blank $01, frame tiles $AA/$00/$12/$22/$13/$23,',
           ';     text tiles $7C...) then 64 attribute bytes, all $AA (palette 2).',
           ';     Rows 4-17 hold the ruler-name entry kana grid (2 x 5-char column',
           ';     pairs with page-arrow tiles $B7-$BA and digits); frame tiles on the',
           ';     other rows decode as kana-range coincidences, not text ---']
    out.append('NewGameBaseScreen:')
    for r in range(30):
        a = 0x1AE3 + r * 32
        vals = data[a:a + 32]
        body = '  .byte ' + ', '.join(hexb(v) for v in vals)
        note = 'row %d' % r
        if r in KANA_GRID_ROWS:
            txt = screen_row_text(vals)
            if txt:
                note += '  "%s"' % txt
        out.append('%s%s; %s  %s' % (body, ' ' * max(1, 43 - len(body)),
                                     hexw(cpu_ofs(a)), note))
    for r in range(2):
        a = 0x1AE3 + 960 + r * 32
        vals = data[a:a + 32]
        body = '  .byte ' + ', '.join(hexb(v) for v in vals)
        out.append('%s%s; %s  attr' % (body, ' ' * max(1, 43 - len(body)),
                                       hexw(cpu_ofs(a))))
    return out


def emit_filler(data):
    out = ['',
           '; --- $9EE3-$9FFF  unused ($FF filler) ---']
    for a in range(0x1EE3, BANK_SIZE, ROW_BYTES):
        chunk = data[a:a + ROW_BYTES]
        body = '  .byte ' + ', '.join(hexb(v) for v in chunk)
        out.append('%s%s; %s' % (body, ' ' * max(1, COMMENT_COL - len(body)),
                                 hexw(cpu_ofs(a))))
    out.append('')
    return out


def render(data):
    assert len(data) == BANK_SIZE
    # sanity: every non-padding word resolves inside the stream area
    for pos in range(256):
        w = data[pos * 2] | (data[pos * 2 + 1] << 8)
        if w != PTR_PADDING:
            assert 0x200 <= w + PTR_BIAS - WINDOW_CPU < STREAM_END, (
                'pos %02X word %04X out of range' % (pos, w))
    words, streams, covered = build_plan(data)
    out = [BANNER.rstrip('\n')]
    out.extend(emit_ptr_table(words, streams))
    out.extend(emit_streams(data, streams, covered))
    out.extend(emit_screen(data))
    out.extend(emit_filler(data))
    return '\n'.join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--write', action='store_true', help='overwrite asm/banks/data_12.asm')
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
