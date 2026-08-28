;===============================================================================
; PRG Banks $0E+$0F - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $0E at $A000-$BFFF, Bank $0F at $C000-$DFFF
; Loaded together via SwitchBankAC with Y=$2E ($2E & $1F = $0E)
;
; MODULE SUMMARY: Battle Mode overlay + animation/sound engine
;
; This bank pair implements the Battle Mode overlay (a sub-scenario of
; Tactical Mode): the per-VBlank UI state machine that runs on top of the
; battlefield scene rendered by banks $08/$09, plus the battle animation
; and sound engine. It is entered through a 5-entry jump table
; ($A000-$A00C); the frame hook is dispatched from bank $1F NmiState3_Battle.
;
; Major functional areas:
;   $A000-$A00E  Jump table (VBlank hook, anim/sound engine, exp/level,
;                stat-sum exp transfer, sound play)
;   $A00F-$A084  BattleVBlankFrameUpdate + BattleOverlayDispatch (11-entry
;                phase table at $A06F, indexed by $0540)
;   $A085-$A15E  Phase 0 - battle intro (skip check, roster walk, anim
;                queue, data format top/bottom)
;   $A15F-$A2A8  Phase 1 - next-actor selection (cycle init, roster scan,
;                round pass)
;   $A2A9-$A39C  BattleDefeatEventCheck / BattleRetreatEventCheck
;   $A39D-$A3BB  BattlePlayerRequestPoll (player command request handoff)
;   $A3BC-$A4F6  Phase 4 - defeat/retreat result handlers
;   $A4F7-$AA22  Phase 2 - acting-unit command resolution (cursor walk,
;                move/attack commit, damage compute and apply)
;   $AA23-$ACC4  Phase 3 - acting-unit command selection (menu, arrows,
;                markers)
;   $ACC5-$B15A  Phase 8 - tactic point-spend panel + row effects
;   $B15B-$B1EB  BattleSideStatusCountersDecrement
;   $B1EC-$B547  Phase 9 - formation advance (animation, contact damage)
;   $B548-$B86F  BattleRosterSetup (per-side roster/unit array build)
;   $B870-$BB8E  Anim queue idle check + battlefield cell redraw engine
;   $BB8F-$BF4B  Cursor arrow / attack arrow / attack marker sprite submit
;   $BF4C-$BFFF  BattleSideStatusCounterDraw
;   $C01B-$C063  BattleChrBankAnimate (per-VBlank CHR bank animation)
;   $C064-$C826  Phase 2 route resolvers (walk direction, step tile probe,
;                move route, attack route)
;   $C827-$C925  Slot side compare, command marker render, formation
;                confirm prompt
;   $C926-$CD42  Combat stats init, overlay total refresh, terrain
;                passability, panel stats refresh, input prompt/pad fetch
;   $CD43-$CE24  Phase 5 - side event handlers
;   $CE25-$CF66  Phase 6 - side A pre-battle formation select (+ menu)
;   $CF67-$D066  Phase 7 - side B formation select + Battle Mode start
;   $D067-$D6B9  AI battle logic (side refresh, order assign, rout checks,
;                outnumbered check, tactic point spend)
;   $D6BA-$D7FA  Phase $A - AI taunt scene
;   $D7FB-$D8D3  Officer battle exp/level-up + stat-sum exp transfer
;   $D8D4-$DFFF  BattleAnimSoundEngine + BattleSoundChannelProc (battle
;                animation script and multi-channel sound engine)
;
; Dispatch mechanism:
;   $0540 = overlay phase (0-$A); $0541 = sub-phase within each phase.
;   All phases use B1F_CallbackDispatcher inline tables for state dispatch.
;   Phases 0-2 first redraw both overlay strips via banked calls into
;   bank $19 (B19_OverlayStripRender_Entry).
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

;===============================================================================
; RAM map ($0000-$07FF) - battle overlay / battlefield context
; Cross-proc globals for this bank pair. Zero-page call-register cells
; ($0000-$001F) are deliberately NOT defined here: they are per-proc
; work/parameter cells with call-site-dependent roles, so each proc defines
; its own local semantic equates (see the "zero-page work cells" blocks).
; Addresses owned by other scenes reuse the canonical globals from the
; owning bank files:
;   $0424/$0425 = menu_cursor_col/menu_cursor_page (prg_0c_0d.asm)
;   $0500/$0501 = war_scene_id/war_scene_phase     (prg_08_09.asm)
;===============================================================================
; --- Zero-page engine/hardware cells ---
frame_tick         = $005E  ; frame tick counter (incremented every 8 frames by NmiEpilogue)
btl_flash_counter   = $007A  ; screen-flash countdown (game-state slot during battle phases 4/5)
btl_oam_slot_cursor = $007C  ; OAM slot write cursor
btl_anim_flags      = $007E  ; NMI-owned animation/script status flags (bit2 = queued task done / input busy)
btl_pad1_lo         = $0081  ; pad 1 latched button state lo (menu input feed)
btl_pad2_lo         = $0082  ; pad 2 latched button state lo
btl_pad1_hi         = $0083  ; pad 1 latched button state hi
btl_pad2_hi         = $0085  ; pad 2 latched button state hi
btl_frame_flag      = $0087  ; palette/frame flag (bit7: intro skip, result flash wait)
btl_battle_flag     = $008F  ; battle commit flag (toggled by command confirm, cleared on advance init)
zp_panel_param_a    = $00BB  ; B1D_1E panel param A (script id)
zp_panel_param_b    = $00BC  ; B1D_1E panel param B (page/format)
zp_panel_param_c    = $00BD  ; B1D_1E panel param C (panel id)
; --- Tile-animation queue ($0300-$0311) ---
anim_queue_hdr0    = $0300  ; queue slot 0 header ($FF = empty)
anim_queue_hdr1    = $0304  ; queue slot 1 header ($FF = empty)
anim_queue_id0_lo  = $0310  ; slot 0 tile-animation id lo
anim_queue_id0_hi  = $0311  ; slot 0 tile-animation id hi
; --- VRAM update script buffer ($0380-$039C, FF-terminated two-segment records) ---
vram_script_buf    = $0380  ; record base; fields accessed as vram_script_buf+offset
; --- Battle status panel parameter/field blocks ($042C-$0431, $044C-$046E) ---
btl_panel_params   = $042C  ; panel parameter block (effect target / officer id at +0)
btl_panel_fields   = $044C  ; troop-count field block (fields 0-7, cleared through +$22)
btl_sideev_params  = $04A8  ; side-event panel params (+0..+2)
btl_sideev_troop_a = $04AB  ; side-event panel troop count slot 0 (A/B swapped)
btl_sideev_troop_b = $04AC  ; side-event panel troop count slot 1 (A/B swapped)
btl_sideev_strip_a = $04AD  ; side-event panel strip pointer slot 0 (A/B swapped)
btl_sideev_strip_b = $04AE  ; side-event panel strip pointer slot 1 (A/B swapped)
btl_strip_row_param = $04BC ; overlay strip redraw row param ($D0)
btl_attack_mirror_a = $04C1  ; side A attack value mirror (of btl_attack_a)
btl_attack_mirror_b = $04C2  ; side B attack value mirror (of btl_attack_b)
; --- Overlay strip records ($0514-$0517) ---
btl_strip_sel_a   = $0514  ; side A strip buffer pointer / selection
btl_strip_flag_a  = $0515  ; side A strip flag (2 = drained/retreat, mode 3 = AI strip)
btl_strip_sel_b   = $0516  ; side B strip buffer pointer / selection
btl_strip_flag_b  = $0517  ; side B strip flag
; --- Battle overlay state machine ($0540-$054F) ---
btl_overlay_phase = $0540  ; BattleOverlayDispatch phase (0-6, $B)
btl_overlay_sub   = $0541  ; BattleOverlayDispatch sub-phase (per-phase state)
battle_phase      = $0544  ; battle mode phase (0-4 normal, 5 = siege battle; also battle map index)
btl_scan_col      = $0545  ; roster scan column (0-$14)
btl_scan_row      = $0546  ; side-group priority row
btl_scan_wait     = $0547  ; scan frame wait
btl_frame_counter = $0548  ; per-phase frame/step counter (also roster index, damage amount, menu step)
btl_acting_unit   = $0549  ; acting unit id / side / player index (bit7 = none)
btl_walk_row      = $054A  ; cursor walk/marker row <<4 (also point tier, target row)
btl_walk_col      = $054B  ; cursor walk/target column <<4 (also phase resume latch)
btl_recorded_status = $054C ; column recorded status (also sub-phase resume latch)
btl_target_col    = $054D  ; attack target column
btl_command       = $054F  ; acting unit command value
; --- Battle order slots ($0550-$0557: side A +0..+3, side B +0..+3) ---
btl_order_slots_a = $0550  ; side A battle order slots (1 = withdraw, AI assignment)
btl_order_slots_b = $0554  ; side B battle order slots
; --- Formation advance state ($0558-$055B) ---
btl_advance_base  = $0558  ; acting side roster base slot (0 or $0B)
btl_advance_dir   = $0559  ; advance direction code (0 up, 1 down, 2 left, 3 right)
btl_advance_marker_row = $055A ; advance marker position row (<<4)
btl_advance_marker_col = $055B ; advance marker position column (<<4)
; --- Side setup / strip buffers ($0560-$0567) ---
btl_strip_buf_a   = $0560  ; overlay strip 0 buffer pointer lo (side A representative id)
btl_strip_buf_b   = $0561  ; overlay strip 1 buffer pointer lo (side B representative id)
btl_input_mode_a  = $0562  ; side A input mode (0-2 human pad, 3 = AI)
btl_input_mode_b  = $0563  ; side B input mode
btl_country_a     = $0564  ; side A country id
btl_country_b     = $0565  ; side B country id
btl_col_count_a   = $0566  ; side A battlefield column count
btl_col_count_b   = $0567  ; side B battlefield column count
; --- Player takeover handoff ($0568/$0569) ---
btl_player_request_a = $0568 ; pad 1 player-request handoff flag
btl_player_request_b = $0569 ; pad 2 player-request handoff flag
; --- Per-side combat stats ($056A-$0573) ---
btl_attack_a      = $056A  ; side A attack value (periodic reload via btl_reload_a)
btl_attack_b      = $056B  ; side B attack value
btl_formation_a   = $056C  ; side A formation index (0-3: Serpent/Goose/Wedge/Fish Scale)
btl_formation_b   = $056D  ; side B formation index
btl_defense_a     = $056E  ; side A edge-column defense value
btl_defense_b     = $056F  ; side B edge-column defense value
btl_edge_bonus_a  = $0570  ; side A edge-column attack bonus (column 0)
btl_edge_bonus_b  = $0571  ; side B edge-column attack bonus (column $0B)
btl_point_budget_a = $0572 ; side A tactic point budget
btl_point_budget_b = $0573 ; side B tactic point budget
; --- Per-side status counters ($0574-$0577, two nibble counters per byte) ---
btl_status_ctr0   = $0574  ; status counter byte 0 (phase gate / stat-check rows)
btl_status_ctr1   = $0575  ; status counter byte 1 (range counters, row-2 effect)
btl_status_ctr2   = $0576  ; status counter byte 2 (reload counter latch, row-3 effect)
btl_status_ctr3   = $0577  ; status counter byte 3 (attack bonus counter, row-4 effect)
btl_reload_a      = $0578  ; side A attack value reload latch
btl_reload_b      = $0579  ; side B attack value reload latch
btl_round_pass    = $057A  ; round-pass counter (shifts AI order window at >= 4)
btl_input_mask    = $057B  ; menu input mask (0 suppresses B1D_1E_MenuUpdate input)
btl_side_index    = $057C  ; AI tactic / taunt scene side index (0/1)
; --- Battlefield unit arrays ($0580-$05D7; side A at $0580, side B at +$0B) ---
btl_unit_col_a    = $0580  ; unit columns, side A (11 entries; $FF empty, $FE cleared)
btl_unit_col_b    = $058B  ; unit columns, side B
btl_unit_row_a    = $0596  ; unit rows, side A
btl_unit_row_b    = $05A1  ; unit rows, side B
btl_troops_a      = $05AC  ; side A troop count (commander)
btl_troops_b      = $05B7  ; side B troop count (commander)
btl_roster_code_a = $05C2  ; roster status codes, side A (hi nibble status, lo action bits)
btl_roster_code_b = $05CD  ; roster status codes, side B
; --- Sound channel state ($0700-$0715, parallel arrays indexed by channel base) ---
snd_chan_state      = $0700  ; channel state (0 = off, 2 = init, $FF = remove, else playing)
snd_chan_hw_idx     = $0701  ; hardware channel index (& 7 selects mask tables)
snd_chan_stream_lo  = $0702  ; command stream pointer lo
snd_chan_stream_hi  = $0703  ; command stream pointer hi
snd_chan_duration   = $0704  ; duration byte (hi nibble base/flag, lo nibble current)
snd_chan_dur_ctr    = $0705  ; duration countdown
snd_chan_volume     = $0706  ; volume/register byte (current)
snd_chan_volume_sv  = $0707  ; volume/register byte (saved copy)
snd_chan_note_ctr   = $0708  ; note lifetime counter (0 removes channel)
snd_chan_sweep      = $0709  ; sweep register value ($4001)
snd_chan_vib_ctr0   = $070A  ; vibrato counter 0
snd_chan_vib_ctr1   = $070B  ; vibrato counter 1
snd_chan_aux0c      = $070C  ; channel work byte ($0C)
snd_chan_freq_period = $070D ; pitch frame modulo (freq division loop)
snd_chan_frame_ctr  = $070E  ; pitch frame counter
snd_chan_decay_ctr  = $070F  ; envelope decay counter
snd_chan_decay_rld  = $0710  ; envelope decay reload
snd_chan_decay_tmr  = $0711  ; envelope decay timer
snd_chan_freq_acc   = $0712  ; frequency/vibrato accumulator
snd_chan_aux13      = $0713  ; channel work byte ($13)
snd_chan_cmd_rld    = $0714  ; command frame reload
snd_chan_cmd_tmr    = $0715  ; command frame timer
; --- Sound engine scratch ($07F2-$07F9) ---
snd_active_mask   = $07F2  ; active channel mask accumulated each frame
snd_hw_index      = $07F3  ; current hardware channel index (0-7)
snd_channel_mode  = $07F4  ; per-channel mode byte (from ChannelModeTable)
snd_reg_base      = $07F5  ; hardware register base (hw index * 4)
snd_apu_enable    = $07F6  ; APU $4015 channel-enable shadow
snd_freq_lo       = $07F7  ; note frequency divisor lo / freq shift accumulator
snd_freq_hi       = $07F8  ; note frequency divisor hi
snd_frame_ctr     = $07F9  ; engine frame counter


.segment "CODE_BANK0E"

BattleVBlankFrameUpdate_Entry:  ; (dispatch callback target)
  JMP BattleVBlankFrameUpdate             ; $A000: 4C 0F A0
BattleAnimSoundEngine_Entry:  ; (dispatch callback target)
  JMP BattleAnimSoundEngine                     ; $A003: 4C D4 D8
OfficerBattleExpLevelCheck_Entry:
  JMP OfficerBattleExpLevelCheck          ; $A006: 4C FB D7
OfficerStatSumBattleTransfer_Entry:
  JMP OfficerStatSumBattleTransfer          ; $A009: 4C B0 D8
SoundPlayAlt_Entry:
  JMP BattleSoundChannelProc::SoundPlayAlt                          ; $A00C: 4C 6E DF
;===============================================================================
; $A00F: BattleVBlankFrameUpdate
; Battle Mode VBlank frame hook (entry 5 of the bank jump table, dispatched
; via BattleVBlankFrameUpdate_Entry at $A000), called from prg_1f.asm
; NmiState3_Battle ($F945, bank $19 pair). Applies the CHR bank animation,
; runs the battle overlay state machine BattleOverlayDispatch (phases 0-2
; also redraw the overlay strips), then banked-calls B1D_1E_MenuUpdate with
; input suppressed ($057B=0 is temporarily swapped into the input flags at
; $0081). Resumes after the inline trampoline target word.
;===============================================================================
.proc BattleVBlankFrameUpdate
  JSR BattleChrBankAnimate                ; $A00F: 20 1B C0
  LDA #$00                                ; $A012: A9 00
  STA btl_input_mask                               ; $A014: 8D 7B 05
  JSR BattleOverlayDispatch               ; $A017: 20 30 A0
  LDA a:btl_pad1_lo                             ; $A01A: AD 81 00
  PHA                                     ; $A01D: 48
  LDA btl_input_mask                               ; $A01E: AD 7B 05
  STA a:btl_pad1_lo                             ; $A021: 8D 81 00
  LDY #$3D                                ; $A024: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $A026: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word B1D_1E_MenuUpdate                 ; $A029: 03 A0
  PLA                                     ; $A02B: 68
  STA a:btl_pad1_lo                             ; $A02C: 8D 81 00
  RTS                                     ; $A02F: 60
.endproc
;===============================================================================
; $A030: BattleOverlayDispatch
; Battle overlay state-machine dispatcher, run every VBlank from
; BattleVBlankFrameUpdate. Phase = $0540, sub-phase = $0541.
;
; Phases 0-2 first redraw both overlay strips via banked calls into bank $19
; (X selects the strip: 0 uses buffer ptr $0560, 1 uses $0561 with row param
; $04BC=$D0); the second trampoline resumes directly into the phase dispatch.
; All phases then dispatch through the inline 11-entry phase table ($A06F)
; via B1F_CallbackDispatcher; every phase handler sub-dispatches on $0541.
; Phase 0 (battle intro) sub-states 0-4 are the BattleOverlayIntroSkipCheck..
; BattleOverlayIntroDataFormatBottomAndAdvance handlers ($A095-$A137);
; sub-state 4 ends by advancing to phase 1. Phase 1 (next-actor selection)
; sub-states 0-2 are Phase1CycleInit/Phase1NextActorSelect/Phase1RoundPass.
; Phase 2 (acting-unit command resolution) sub-states 0-$A are the
; Phase2ActionGate..Phase2ActionDoneWait handlers ($A4F7-$AA22).
; Phase 3 (acting-unit command selection, player-request entry) sub-states
; 0-4 are the Phase3CommandPanelInit..Phase3CommandResultWait handlers
; ($AA23-$ACC4); it resumes at the latched phase/sub in $054B/$054C.
; Phase 4 (defeat/retreat result) sub-states 0-6 are the
; Phase4ResultAdvance..Phase4ResultConfirmInput handlers; it is entered at
; sub 0 by BattleDefeatEventCheck and at sub 3 by BattleRetreatEventCheck.
; Phase 6 (side A pre-battle formation select) sub-states 0-3 are the
; Phase6FormationPanelInit..Phase6AdvanceToSideBFormation handlers
; ($CE25-$CF04); the A-confirm hands off to phase 3 with resume latch
; $054B/$054C <- 6/3, and sub 3 advances to phase 7. Phase 7 (side B
; formation select) sub-states 0-4 are the
; Phase7FormationPanelInit..Phase7BattleModeStart handlers ($CF67-$D066);
; it mirrors phase 6 for side B (formation $056D, input mode $0563,
; country $0565); its A-confirm hands off to phase 3 with resume latch
; $054B/$054C <- 7/4 so sub 4 starts battle mode (roster setup), and input
; mode 3 (AI) jumps straight to sub 4.
; Phase 8 (point-spend panel) sub-states 0-4 are the
; Phase8PanelInit..Phase8PanelAdvanceWait handlers ($ACC5-$AEAD); it is
; entered from Phase3CommandInput::@Commit when the step-0 action slot is 4
; and no side status counters $0574-$0577 are pending. The panel spends the
; per-side point budget $0572[$0549]; B-cancel and A-confirm return to
; phase 3 sub 3, row effects route to sub 3/sub 4 or on to phase 9.
; Phase 8 (point-spend panel) enters phase 9 via its $B09C entry (SFX $F1);
; phase 9 (formation advance) runs the animated advance sweep and returns to
; the phase-8 sub-dispatch at sub-state 3 (Phase9AdvanceComplete).
;===============================================================================
.proc BattleOverlayDispatch
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; overlay strip render buffer ptr lo (bank $19)
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
  LDA btl_overlay_phase                               ; $A030: AD 40 05
  BEQ @RedrawOverlayStrips                ; $A033: F0 0B
  CMP #$01                                ; $A035: C9 01
  BEQ @RedrawOverlayStrips                ; $A037: F0 07
  CMP #$02                                ; $A039: C9 02
  BEQ @RedrawOverlayStrips                ; $A03B: F0 03
  JMP @PhaseDispatch                      ; $A03D: 4C 69 A0
@RedrawOverlayStrips:
; Strip 0: buffer ptr lo from $0560 (hi fixed $A5), X=0
  LDA btl_strip_buf_a                               ; $A040: AD 60 05
  STA strip_ptr_lo                                 ; $A043: 85 00
  LDA #$A5                                ; $A045: A9 A5
  STA strip_ptr_hi                                 ; $A047: 85 0A
  LDX #$00                                ; $A049: A2 00
  LDY #$39                                ; $A04B: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $A04D: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word B19_OverlayStripRender_Entry      ; $A050: 00 A0
; Strip 1: row param $04BC=$D0, buffer ptr lo from $0561, X=1
  LDA #$D0                                ; $A052: A9 D0
  STA btl_strip_row_param                               ; $A054: 8D BC 04
  LDA btl_strip_buf_b                               ; $A057: AD 61 05
  STA strip_ptr_lo                                 ; $A05A: 85 00
  LDA #$A5                                ; $A05C: A9 A5
  STA strip_ptr_hi                                 ; $A05E: 85 0A
  LDX #$01                                ; $A060: A2 01
  LDY #$39                                ; $A062: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $A064: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19); resumes at @PhaseDispatch ---
  .word B19_OverlayStripRender_Entry      ; $A067: 00 A0
@PhaseDispatch:
  LDA btl_overlay_phase                               ; $A069: AD 40 05
  JSR B1F_CallbackDispatcher              ; $A06C: 20 DE EA
; --- CallbackDispatcher phase table, indexed by $0540 ---
  .word Phase0IntroSubDispatch            ; $A06F: 85 A0 ; phase 0: intro sub-dispatch ($A085)
  .word Phase1NextActorSubDispatch        ; $A071: 5F A1 ; phase 1: next-actor select ($A15F)
  .word Phase2ActionSubDispatch           ; $A073: F7 A4 ; phase 2: command resolution ($A4F7)
  .word Phase3CommandSubDispatch          ; $A075: 23 AA ; phase 3: command selection ($AA23)
  .word Phase4ResultSubDispatch           ; $A077: BC A3 ; phase 4: defeat/retreat result ($A3BC)
  .word Phase5SideEventSubDispatch        ; $A079: 43 CD ; phase 5: side event ($CD43)
  .word Phase6FormationSelectSubDispatch  ; $A07B: 25 CE ; phase 6: side A formation select ($CE25)
  .word Phase7FormationSelectSubDispatch  ; $A07D: 67 CF ; phase 7: side B formation select ($CF67)
  .word Phase8PanelSubDispatch            ; $A07F: C5 AC ; phase 8: point-spend panel ($ACC5)
  .word Phase9AdvanceSubDispatch          ; $A081: EC B1 ; phase 9: formation advance ($B1EC)
  .word PhaseATauntSubDispatch            ; $A083: BA D6 ; phase $A: AI taunt scene ($D6BA)
.endproc
;===============================================================================
; $A085: Phase0IntroSubDispatch
; Phase-0 handler entry (battle intro): sub-dispatch on $0541 through the
; inline 5-entry table below, covering intro sub-states 0-4.
;===============================================================================
.proc Phase0IntroSubDispatch
  LDA btl_overlay_sub                               ; $A085: AD 41 05
  JSR B1F_CallbackDispatcher              ; $A088: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word BattleOverlayIntroSkipCheck       ; $A08B: 95 A0 ; sub 0
  .word BattleOverlayIntroRosterWalk      ; $A08D: D3 A0 ; sub 1
  .word BattleOverlayIntroAnimQueue       ; $A08F: F9 A0 ; sub 2
  .word BattleOverlayIntroDataFormatTop   ; $A091: 19 A1 ; sub 3
  .word BattleOverlayIntroDataFormatBottomAndAdvance ; $A093: 37 A1 ; sub 4
.endproc
;===============================================================================
; $A095: BattleOverlayIntroSkipCheck
; Intro sub-state 0. If $0087 bit7 is set, skip the intro entirely: jump to
; phase 6 with all per-unit/per-side status slots ($0550-$0557, $0574-$0577)
; and the roster index $0548 cleared, then run BattleSideCombatStatsInit
; (phase-6 combat-parameter setup).
;===============================================================================
.proc BattleOverlayIntroSkipCheck
  LDA a:btl_frame_flag                             ; $A095: AD 87 00
  BPL @Done                               ; $A098: 10 38 ; bit7 clear: no skip
  LDA #$06                                ; $A09A: A9 06
  STA btl_overlay_phase                               ; $A09C: 8D 40 05 ; phase <- 6
  LDA #$00                                ; $A09F: A9 00
  STA btl_overlay_sub                               ; $A0A1: 8D 41 05 ; sub-phase <- 0
  LDA #$00                                ; $A0A4: A9 00
  STA btl_order_slots_a                               ; $A0A6: 8D 50 05
  STA btl_order_slots_a+1                               ; $A0A9: 8D 51 05
  STA btl_order_slots_a+2                               ; $A0AC: 8D 52 05
  STA btl_order_slots_a+3                               ; $A0AF: 8D 53 05
  STA btl_order_slots_b                               ; $A0B2: 8D 54 05
  STA btl_order_slots_b+1                               ; $A0B5: 8D 55 05
  STA btl_order_slots_b+2                               ; $A0B8: 8D 56 05
  STA btl_order_slots_b+3                               ; $A0BB: 8D 57 05
  STA btl_status_ctr0                               ; $A0BE: 8D 74 05
  STA btl_status_ctr1                               ; $A0C1: 8D 75 05
  STA btl_status_ctr2                               ; $A0C4: 8D 76 05
  STA btl_status_ctr3                               ; $A0C7: 8D 77 05
  LDA #$00                                ; $A0CA: A9 00
  STA btl_frame_counter                               ; $A0CC: 8D 48 05
  JSR BattleSideCombatStatsInit           ; $A0CF: 20 26 C9
@Done:
  RTS                                     ; $A0D2: 60
.endproc
;===============================================================================
; $A0D3: BattleOverlayIntroRosterWalk
; Intro sub-state 1. Waits for the animation queue to idle (BattleAnimQueueIdleCheck, C=1 idle),
; then draws one roster entry per frame: entry $0548 of the 22-slot list at
; $0580 is passed to BattleCellRedraw (skipping $FF slots) with zp $12/$13 params. When
; all $16 entries are walked, advances to sub-state 2.
;===============================================================================
.proc BattleOverlayIntroRosterWalk
  JSR BattleAnimQueueIdleCheck                 ; $A0D3: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A0D6: 90 20 ; still busy: wait
  LDA #$10                                ; $A0D8: A9 10
  STA $12                                 ; $A0DA: 85 12
  LDY btl_frame_counter                               ; $A0DC: AC 48 05
  STY $13                                 ; $A0DF: 84 13
  LDA btl_unit_col_a,Y                             ; $A0E1: B9 80 05
  CMP #$FF                                ; $A0E4: C9 FF
  BEQ @Advance                            ; $A0E6: F0 03 ; empty slot: skip draw
  JSR BattleCellRedraw                         ; $A0E8: 20 82 B8 ; draw roster entry
@Advance:
  INC btl_frame_counter                               ; $A0EB: EE 48 05
  LDA btl_frame_counter                               ; $A0EE: AD 48 05
  CMP #$16                                ; $A0F1: C9 16
  BCC @Done                               ; $A0F3: 90 03
  INC btl_overlay_sub                               ; $A0F5: EE 41 05 ; all entries: sub-state <- 2
@Done:
  RTS                                     ; $A0F8: 60
.endproc
;===============================================================================
; $A0F9: BattleOverlayIntroAnimQueue
; Intro sub-state 2. Waits for the animation queue to idle, then enqueues the
; $E8/$E9 tile animation ($0310/$0311, slot $0300=0), sets panel param
; $00BC=5, refreshes the panel troop-count block (BattlePanelStatsRefresh)
; and advances to sub-state 3.
;===============================================================================
.proc BattleOverlayIntroAnimQueue
  JSR BattleAnimQueueIdleCheck                 ; $A0F9: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A0FC: 90 1A ; still busy: wait
  LDA #$E8                                ; $A0FE: A9 E8
  STA anim_queue_id0_lo                               ; $A100: 8D 10 03
  LDA #$E9                                ; $A103: A9 E9
  STA anim_queue_id0_hi                               ; $A105: 8D 11 03
  LDA #$00                                ; $A108: A9 00
  STA anim_queue_hdr0                               ; $A10A: 8D 00 03
  INC btl_overlay_sub                               ; $A10D: EE 41 05 ; sub-state <- 3
  LDA #$05                                ; $A110: A9 05
  STA a:zp_panel_param_b                             ; $A112: 8D BC 00
  JSR BattlePanelStatsRefresh           ; $A115: 20 F1 CB ; refresh panel stats
@Done:
  RTS                                     ; $A118: 60
.endproc
;===============================================================================
; $A119: BattleOverlayIntroDataFormatTop
; Intro sub-state 3. Waits for the animation queue to idle, then banked-calls
; B1D_1E_DataFormatter (bank $1D, Y=$3D) with buffer ptr $00/$01 = $0560/0
; and param $00BB=9 to format the top panel. Advances to sub-state 4.
;===============================================================================
.proc BattleOverlayIntroDataFormatTop
; zero-page work cells (proc-local):
fmt_ptr_lo     = $0000  ; B1D_1E_DataFormatter buffer ptr lo
fmt_ptr_hi     = $0001  ; formatter buffer ptr hi
  JSR BattleAnimQueueIdleCheck                 ; $A119: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A11C: 90 18 ; still busy: wait
  LDA #$09                                ; $A11E: A9 09
  STA a:zp_panel_param_a                             ; $A120: 8D BB 00
  LDA btl_strip_buf_a                               ; $A123: AD 60 05
  STA fmt_ptr_lo                                 ; $A126: 85 00
  LDA #$00                                ; $A128: A9 00
  STA fmt_ptr_hi                                 ; $A12A: 85 01
  LDY #$3D                                ; $A12C: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $A12E: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $A131: 3C A0
  INC btl_overlay_sub                               ; $A133: EE 41 05 ; sub-state <- 4
@Done:
  RTS                                     ; $A136: 60
.endproc
;===============================================================================
; $A137: BattleOverlayIntroDataFormatBottomAndAdvance
; Intro sub-state 4. If $007E is clear, banked-calls B1D_1E_DataFormatter
; (bank $1D) with buffer ptr $00/$01 = $0561/1 to format the bottom panel,
; then ends the intro: phase <- 1, sub-phase <- 0, clear handoff flags
; $0568/$0569.
;===============================================================================
.proc BattleOverlayIntroDataFormatBottomAndAdvance
; zero-page work cells (proc-local):
fmt_ptr_lo     = $0000  ; B1D_1E_DataFormatter buffer ptr lo
fmt_ptr_hi     = $0001  ; formatter buffer ptr hi
  LDA a:btl_anim_flags                             ; $A137: AD 7E 00
  BNE @Done                               ; $A13A: D0 22
  LDA btl_strip_buf_b                               ; $A13C: AD 61 05
  STA fmt_ptr_lo                                 ; $A13F: 85 00
  LDA #$01                                ; $A141: A9 01
  STA fmt_ptr_hi                                 ; $A143: 85 01
  LDY #$3D                                ; $A145: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $A147: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $A14A: 3C A0
  LDA #$01                                ; $A14C: A9 01
  STA btl_overlay_phase                               ; $A14E: 8D 40 05 ; phase <- 1 (intro done)
  LDA #$00                                ; $A151: A9 00
  STA btl_overlay_sub                               ; $A153: 8D 41 05 ; sub-phase <- 0
  LDA #$00                                ; $A156: A9 00
  STA btl_player_request_a                               ; $A158: 8D 68 05
  STA btl_player_request_b                               ; $A15B: 8D 69 05
@Done:
  RTS                                     ; $A15E: 60
.endproc
;===============================================================================
; $A15F: Phase1NextActorSubDispatch
; Phase-1 handler entry (next-actor selection): redraws the packed per-side
; status counters $0574-$0577 via BattleSideStatusCounterDraw every frame,
; then sub-dispatches on $0541 through the inline 3-entry table below.
; Sub 0 initializes the scan cursor, sub 1 picks the next acting unit, and
; sub 2 passes the round (incrementing the pass counter $057A and ticking
; the status counters) when a full roster scan found nobody.
;===============================================================================
.proc Phase1NextActorSubDispatch
  JSR BattleSideStatusCounterDraw         ; $A15F: 20 4C BF
  LDA btl_overlay_sub                               ; $A162: AD 41 05
  JSR B1F_CallbackDispatcher              ; $A165: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase1CycleInit                   ; $A168: 6E A1 ; sub 0
  .word Phase1NextActorSelect             ; $A16A: 83 A1 ; sub 1
  .word Phase1RoundPass                   ; $A16C: 35 A2 ; sub 2
.endproc
;===============================================================================
; $A16E: Phase1CycleInit
; Sub-phase 0. Advances to sub-phase 1, clears the roster-scan cursor
; ($0545=column, $0546=side-group row, $0547=frame wait) and the round-pass
; counter $057A, then refreshes the AI sides via Phase1AiSideRefresh ($D067).
;===============================================================================
.proc Phase1CycleInit
  INC btl_overlay_sub                               ; $A16E: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $A171: A9 00
  STA btl_scan_col                               ; $A173: 8D 45 05 ; scan column <- 0
  STA btl_scan_row                               ; $A176: 8D 46 05 ; side-group row <- 0
  STA btl_scan_wait                               ; $A179: 8D 47 05 ; frame wait <- 0
  STA btl_round_pass                               ; $A17C: 8D 7A 05 ; round-pass counter <- 0
  JSR Phase1AiSideRefresh                 ; $A17F: 20 67 D0
  RTS                                     ; $A182: 60
.endproc
;===============================================================================
; $A183: Phase1NextActorSelect
; Sub-phase 1. Battle-end event checks first: BattleRetreatEventCheck (side
; event flags $0580/$058B == $FE) and BattleDefeatEventCheck (== $FF) abort
; the frame straight into phase 4. Next, a queued player request (handoff
; flags $0568/$0569, set from BattlePlayerRequestPoll controller polling) advances to phase 3
; with $0549 <- $0569 and $054B/$054C <- 1. Otherwise scans the 22-slot
; battle roster $05C2 column by column ($0545) through the side groups in
; priority order 3,2,1,0 ($A231 table, row index $0546): the first unit
; whose low nibble matches the current side group advances to phase 2; its
; action slot $0550[unit&$0F (+4 for roster columns >= $0B)] is copied to
; $054F, and slot value $80 is rerolled via B1F_RandomByte bit0 to 0 or 2.
; A full scan without a match clears $0547 and advances to sub-phase 2
; (round pass).
;===============================================================================
.proc Phase1NextActorSelect
; zero-page work cells (proc-local):
side_id        = $0000  ; side id from Phase1SidePriorityOrder
slot_base      = $0000  ; order-slot base (0 cols 0-$A, 4 cols $B-$14)
  JSR BattleRetreatEventCheck             ; $A183: 20 2F A3 ; $FE side event -> phase 4
  JSR BattleDefeatEventCheck              ; $A186: 20 A9 A2 ; $FF side event -> phase 4
  LDA btl_player_request_a                               ; $A189: AD 68 05
  ORA btl_player_request_b                               ; $A18C: 0D 69 05
  BEQ @ScanRoster                         ; $A18F: F0 23 ; no player request
  LDA btl_player_request_b                               ; $A191: AD 69 05
  STA btl_acting_unit                               ; $A194: 8D 49 05 ; request param
  LDA #$03                                ; $A197: A9 03
  STA btl_overlay_phase                               ; $A199: 8D 40 05 ; phase <- 3
  LDA #$00                                ; $A19C: A9 00
  STA btl_overlay_sub                               ; $A19E: 8D 41 05 ; sub-phase <- 0
  LDA #$01                                ; $A1A1: A9 01
  STA btl_walk_col                               ; $A1A3: 8D 4B 05
  LDA #$01                                ; $A1A6: A9 01
  STA btl_recorded_status                               ; $A1A8: 8D 4C 05
  LDA #$00                                ; $A1AB: A9 00
  STA btl_player_request_a                               ; $A1AD: 8D 68 05 ; consume request flags
  STA btl_player_request_b                               ; $A1B0: 8D 69 05
  RTS                                     ; $A1B3: 60
@ScanRoster:
  LDA #$00                                ; $A1B4: A9 00
  STA btl_player_request_a                               ; $A1B6: 8D 68 05
  STA btl_player_request_b                               ; $A1B9: 8D 69 05
@NextCell:
  LDY btl_scan_row                               ; $A1BC: AC 46 05 ; side-group row
  LDA Phase1SidePriorityOrder,Y           ; $A1BF: B9 31 A2 ; side id for this row
  STA side_id                                 ; $A1C2: 85 00
  LDY btl_scan_col                               ; $A1C4: AC 45 05 ; roster column
  LDA btl_roster_code_a,Y                             ; $A1C7: B9 C2 05 ; roster entry
  CMP #$FF                                ; $A1CA: C9 FF
  BEQ @AdvanceCell                        ; $A1CC: F0 41 ; empty slot
  AND #$0F                                ; $A1CE: 29 0F ; unit side
  CMP side_id                                 ; $A1D0: C5 00
  BNE @AdvanceCell                        ; $A1D2: D0 3B ; not this side group
  LDA #$02                                ; $A1D4: A9 02
  STA btl_overlay_phase                               ; $A1D6: 8D 40 05 ; phase <- 2
  LDA #$00                                ; $A1D9: A9 00
  STA btl_overlay_sub                               ; $A1DB: 8D 41 05 ; sub-phase <- 0
  LDA #$00                                ; $A1DE: A9 00
  LDY btl_scan_col                               ; $A1E0: AC 45 05
  CPY #$0B                                ; $A1E3: C0 0B
  BCC @SlotBase                           ; $A1E5: 90 02 ; columns 0-10: slots 0-3
  LDA #$04                                ; $A1E7: A9 04 ; columns 11-21: slots 4-7
@SlotBase:
  STA slot_base                                 ; $A1E9: 85 00
  LDA btl_roster_code_a,Y                             ; $A1EB: B9 C2 05
  AND #$0F                                ; $A1EE: 29 0F ; unit slot
  ORA slot_base                                 ; $A1F0: 05 00
  TAY                                     ; $A1F2: A8
  LDA btl_order_slots_a,Y                             ; $A1F3: B9 50 05 ; action slot value
  STA btl_command                               ; $A1F6: 8D 4F 05
  CMP #$80                                ; $A1F9: C9 80
  BNE @Done                               ; $A1FB: D0 11 ; valid value: keep
  LDA #$00                                ; $A1FD: A9 00
  STA btl_command                               ; $A1FF: 8D 4F 05
  JSR B1F_RandomByte                      ; $A202: 20 7A E8
  AND #$01                                ; $A205: 29 01
  BNE @Done                               ; $A207: D0 05 ; odd: leave 0
  LDA #$02                                ; $A209: A9 02
  STA btl_command                               ; $A20B: 8D 4F 05 ; even: 2
@Done:
  RTS                                     ; $A20E: 60
@AdvanceCell:
  LDA #$00                                ; $A20F: A9 00
  STA btl_scan_wait                               ; $A211: 8D 47 05 ; frame wait <- 0
  INC btl_scan_col                               ; $A214: EE 45 05 ; next column
  LDA btl_scan_col                               ; $A217: AD 45 05
  CMP #$16                                ; $A21A: C9 16 ; 22 roster columns
  BCC @NextCell                           ; $A21C: 90 9E
  LDA #$00                                ; $A21E: A9 00
  STA btl_scan_col                               ; $A220: 8D 45 05 ; column wrap
  INC btl_scan_row                               ; $A223: EE 46 05 ; next side group
  LDA btl_scan_row                               ; $A226: AD 46 05
  CMP #$04                                ; $A229: C9 04 ; 4 side groups
  BCC @NextCell                           ; $A22B: 90 8F
  INC btl_overlay_sub                               ; $A22D: EE 41 05 ; full scan: sub-phase <- 2
  RTS                                     ; $A230: 60
.endproc
; --- Phase 1 side-group priority order, indexed by scan row $0546 ---
Phase1SidePriorityOrder:
  .byte $03,$02,$01,$00                   ; $A231: 03 02 01 00
;===============================================================================
; $A235: Phase1RoundPass
; Sub-phase 2, entered when a full roster scan found no acting unit. Re-arms
; sub-phase 1 (the cycle resumes with another scan next frame) and, once the
; animation queue idles (BattleAnimQueueIdleCheck, C=1 idle), enqueues the $E9 tile animation
; ($0310=$E9, slot $0300=0) and refreshes the panel troop-count block
; (BattlePanelStatsRefresh). Then walks the same 22x4 roster grid
; as Phase1NextActorSelect but only for side groups 0 and 1: cells of side
; groups 2/3 advance immediately, while the first side-0/1 cell stalls one
; frame ($0547 counts 0 -> 1) before the walk resumes one cell per visit.
; After the full walk: round-pass counter $057A is incremented, the packed
; side status counters $0574-$0577 are ticked down via
; BattleSideStatusCountersDecrement, then the AI sides may spend their
; tactic point budget (AiTacticSpendDispatch $D0AE) and are refreshed via
; Phase1AiSideRefresh ($D067).
;===============================================================================
.proc Phase1RoundPass
  LDA #$01                                ; $A235: A9 01
  STA btl_overlay_sub                               ; $A237: 8D 41 05 ; sub-phase <- 1 (resume scan next frame)
  JSR BattleAnimQueueIdleCheck                 ; $A23A: 20 70 B8 ; anim queue idle check
  BCC @ScanGrid                           ; $A23D: 90 0D ; still busy: skip enqueue
  LDA #$E9                                ; $A23F: A9 E9
  STA anim_queue_id0_lo                               ; $A241: 8D 10 03 ; anim id
  LDA #$00                                ; $A244: A9 00
  STA anim_queue_hdr0                               ; $A246: 8D 00 03 ; anim slot
  JSR BattlePanelStatsRefresh           ; $A249: 20 F1 CB ; refresh panel stats
@ScanGrid:
  LDA btl_scan_row                               ; $A24C: AD 46 05
  CMP #$04                                ; $A24F: C9 04
  BCS @PassComplete                       ; $A251: B0 39 ; all side groups walked
  LDY btl_scan_row                               ; $A253: AC 46 05
  LDA Phase1SidePriorityOrder,Y           ; $A256: B9 31 A2 ; side id for this row
  CMP #$02                                ; $A259: C9 02
  BEQ @AdvanceCell                        ; $A25B: F0 0E ; side 2: skip wait
  CMP #$03                                ; $A25D: C9 03
  BEQ @AdvanceCell                        ; $A25F: F0 0A ; side 3: skip wait
  INC btl_scan_wait                               ; $A261: EE 47 05 ; side 0/1: frame wait
  LDA btl_scan_wait                               ; $A264: AD 47 05
  CMP #$01                                ; $A267: C9 01
  BEQ @Done                               ; $A269: F0 3D ; first visit: stall one frame
@AdvanceCell:
  LDA #$00                                ; $A26B: A9 00
  STA btl_scan_wait                               ; $A26D: 8D 47 05 ; frame wait <- 0
  INC btl_scan_col                               ; $A270: EE 45 05 ; next column
  LDA btl_scan_col                               ; $A273: AD 45 05
  CMP #$16                                ; $A276: C9 16 ; 22 roster columns
  BCC @Done                               ; $A278: 90 2E
  LDA #$00                                ; $A27A: A9 00
  STA btl_scan_col                               ; $A27C: 8D 45 05 ; column wrap
  STA btl_scan_wait                               ; $A27F: 8D 47 05
  INC btl_scan_row                               ; $A282: EE 46 05 ; next side group
  LDA btl_scan_row                               ; $A285: AD 46 05
  CMP #$04                                ; $A288: C9 04
  BCC @Done                               ; $A28A: 90 1C
@PassComplete:
  LDA #$00                                ; $A28C: A9 00
  STA btl_scan_col                               ; $A28E: 8D 45 05 ; cursor reset
  STA btl_scan_row                               ; $A291: 8D 46 05
  INC btl_round_pass                               ; $A294: EE 7A 05 ; round-pass counter++
  JSR BattleSideStatusCountersDecrement   ; $A297: 20 5B B1 ; tick $0574-$0577
  JSR AiTacticSpendDispatch             ; $A29A: 20 AE D0 ; AI tactic-point spend
  JSR Phase1AiSideRefresh               ; $A29D: 20 67 D0 ; AI side refresh (orders/rout)
  LDA #$00                                ; $A2A0: A9 00
  STA btl_scan_col                               ; $A2A2: 8D 45 05
  STA btl_scan_row                               ; $A2A5: 8D 46 05
@Done:
  RTS                                     ; $A2A8: 60
.endproc
;===============================================================================
; $A2A9: BattleDefeatEventCheck
; Checks the per-side battle event flags ($0580 = side A, $058B = side B)
; for the defeat value $FF. When a side is defeated, loads the overlay strip
; buffer pointers $0560/$0561 into the panel parameter block $042C and
; $0514-$0517 (side A: $0515=2/$0517=0, side B: $0515=0/$0517=2), jumps to
; phase 4 sub 0, plays SFX $D3 ($F28B), runs $E57F/$E683 (A=$71), then pops
; both return addresses so the rest of the current frame is skipped.
;===============================================================================
.proc BattleDefeatEventCheck
  LDA btl_unit_col_a                               ; $A2A9: AD 80 05 ; side A event flag
  CMP #$FF                                ; $A2AC: C9 FF
  BNE @SideB                              ; $A2AE: D0 3C
  LDA btl_troops_a                               ; $A2B0: AD AC 05
  BEQ @SideADefeated                      ; $A2B3: F0 04
  CMP #$FF                                ; $A2B5: C9 FF
  BNE @SideB                              ; $A2B7: D0 33
@SideADefeated:
  LDA btl_strip_buf_a                               ; $A2B9: AD 60 05 ; strip 0 buffer ptr
  STA btl_panel_params                               ; $A2BC: 8D 2C 04
  STA btl_strip_sel_a                               ; $A2BF: 8D 14 05
  LDA #$02                                ; $A2C2: A9 02
  STA btl_strip_flag_a                               ; $A2C4: 8D 15 05
  LDA btl_strip_buf_b                               ; $A2C7: AD 61 05 ; strip 1 buffer ptr
  STA btl_strip_sel_b                               ; $A2CA: 8D 16 05
  LDA #$00                                ; $A2CD: A9 00
  STA btl_strip_flag_b                               ; $A2CF: 8D 17 05
@GotoPhase4:
  LDA #$04                                ; $A2D2: A9 04
  STA btl_overlay_phase                               ; $A2D4: 8D 40 05 ; phase <- 4
  LDA #$00                                ; $A2D7: A9 00
  STA btl_overlay_sub                               ; $A2D9: 8D 41 05 ; sub-phase <- 0
  LDA #$D3                                ; $A2DC: A9 D3
  JSR B1F_SetUI4                          ; $A2DE: 20 8B F2 ; SFX
  JSR B1F_BankPpuInit                     ; $A2E1: 20 7F E5
  LDA #$71                                ; $A2E4: A9 71
  JSR B1F_SoundWrapperC                   ; $A2E6: 20 83 E6
  PLA                                     ; $A2E9: 68 ; drop caller return addr
  PLA                                     ; $A2EA: 68
  RTS                                     ; $A2EB: 60 ; skip rest of frame
@SideB:
  LDA btl_unit_col_b                               ; $A2EC: AD 8B 05 ; side B event flag
  CMP #$FF                                ; $A2EF: C9 FF
  BNE @Done                               ; $A2F1: D0 3B
  LDA btl_troops_b                               ; $A2F3: AD B7 05
  BEQ @SideBDefeated                      ; $A2F6: F0 04
  CMP #$FF                                ; $A2F8: C9 FF
  BNE @Done                               ; $A2FA: D0 32
@SideBDefeated:
  LDA btl_strip_buf_a                               ; $A2FC: AD 60 05 ; strip 0 buffer ptr
  STA btl_strip_sel_a                               ; $A2FF: 8D 14 05
  LDA #$00                                ; $A302: A9 00
  STA btl_strip_flag_a                               ; $A304: 8D 15 05
  LDA btl_strip_buf_b                               ; $A307: AD 61 05 ; strip 1 buffer ptr
  STA btl_panel_params                               ; $A30A: 8D 2C 04
  STA btl_strip_sel_b                               ; $A30D: 8D 16 05
  LDA #$02                                ; $A310: A9 02
  STA btl_strip_flag_b                               ; $A312: 8D 17 05
  LDA #$04                                ; $A315: A9 04
  STA btl_overlay_phase                               ; $A317: 8D 40 05 ; phase <- 4
  LDA #$00                                ; $A31A: A9 00
  STA btl_overlay_sub                               ; $A31C: 8D 41 05 ; sub-phase <- 0
  LDA #$D3                                ; $A31F: A9 D3
  JSR B1F_SetUI4                          ; $A321: 20 8B F2 ; SFX
  JSR B1F_BankPpuInit                     ; $A324: 20 7F E5
  LDA #$71                                ; $A327: A9 71
  JSR B1F_SoundWrapperC                   ; $A329: 20 83 E6
  PLA                                     ; $A32C: 68 ; drop caller return addr
  PLA                                     ; $A32D: 68
@Done:
  RTS                                     ; $A32E: 60
.endproc
;===============================================================================
; $A32F: BattleRetreatEventCheck
; Checks the per-side battle event flags ($0580 = side A, $058B = side B)
; for the retreat value $FE. When a side retreats, loads the overlay strip
; buffer pointers $0560/$0561 into the panel parameter block ($0514-$0517,
; mirrored layout per side; side A also clears the scan column $0545 while
; side B sets it to 1), jumps to phase 4 sub 3, plays SFX $FA ($F28B), then
; pops both return addresses so the rest of the current frame is skipped.
;===============================================================================
.proc BattleRetreatEventCheck
  LDA btl_unit_col_a                               ; $A32F: AD 80 05 ; side A event flag
  CMP #$FE                                ; $A332: C9 FE
  BNE @SideB                              ; $A334: D0 30
  LDA btl_strip_buf_a                               ; $A336: AD 60 05 ; strip 0 buffer ptr
  STA btl_panel_params                               ; $A339: 8D 2C 04
  STA btl_strip_sel_a                               ; $A33C: 8D 14 05
  LDA #$01                                ; $A33F: A9 01
  STA btl_strip_flag_a                               ; $A341: 8D 15 05
  LDA btl_strip_buf_b                               ; $A344: AD 61 05 ; strip 1 buffer ptr
  STA btl_strip_sel_b                               ; $A347: 8D 16 05
  LDA #$00                                ; $A34A: A9 00
  STA btl_strip_flag_b                               ; $A34C: 8D 17 05
  LDA #$00                                ; $A34F: A9 00
  STA btl_scan_col                               ; $A351: 8D 45 05 ; scan column <- 0
@GotoPhase4:
  LDA #$04                                ; $A354: A9 04
  STA btl_overlay_phase                               ; $A356: 8D 40 05 ; phase <- 4
  LDA #$03                                ; $A359: A9 03
  STA btl_overlay_sub                               ; $A35B: 8D 41 05 ; sub-phase <- 3
  LDA #$FA                                ; $A35E: A9 FA
  JSR B1F_SetUI4                          ; $A360: 20 8B F2 ; SFX
  PLA                                     ; $A363: 68 ; drop caller return addr
  PLA                                     ; $A364: 68
  RTS                                     ; $A365: 60 ; skip rest of frame
@SideB:
  LDA btl_unit_col_b                               ; $A366: AD 8B 05 ; side B event flag
  CMP #$FE                                ; $A369: C9 FE
  BNE @Done                               ; $A36B: D0 2F
  LDA btl_strip_buf_a                               ; $A36D: AD 60 05 ; strip 0 buffer ptr
  STA btl_strip_sel_a                               ; $A370: 8D 14 05
  LDA #$00                                ; $A373: A9 00
  STA btl_strip_flag_a                               ; $A375: 8D 15 05
  LDA btl_strip_buf_b                               ; $A378: AD 61 05 ; strip 1 buffer ptr
  STA btl_panel_params                               ; $A37B: 8D 2C 04
  STA btl_strip_sel_b                               ; $A37E: 8D 16 05
  LDA #$01                                ; $A381: A9 01
  STA btl_strip_flag_b                               ; $A383: 8D 17 05
  LDA #$04                                ; $A386: A9 04
  STA btl_overlay_phase                               ; $A388: 8D 40 05 ; phase <- 4
  LDA #$03                                ; $A38B: A9 03
  STA btl_overlay_sub                               ; $A38D: 8D 41 05 ; sub-phase <- 3
  LDA #$FA                                ; $A390: A9 FA
  JSR B1F_SetUI4                          ; $A392: 20 8B F2 ; SFX
  LDA #$01                                ; $A395: A9 01
  STA btl_scan_col                               ; $A397: 8D 45 05 ; scan column <- 1
  PLA                                     ; $A39A: 68 ; drop caller return addr
  PLA                                     ; $A39B: 68
@Done:
  RTS                                     ; $A39C: 60
.endproc
;===============================================================================
; $A39D: BattlePlayerRequestPoll
; Called every frame from the phase-2 handler inline code ($A4F7). Fetches the
; mode-filtered input state of each controller via BattlePadStateFetch and,
; on an A-button edge (bit0 of $0001), latches the player-request handoff
; flags $0568 (pad 1) / $0569 (pad 2). Phase1NextActorSelect consumes them:
; any request aborts the automatic actor scan and jumps to phase 3 (player
; command input) with $0549 <- $0569 selecting the acting player.
;===============================================================================
.proc BattlePlayerRequestPoll
; zero-page work cells (proc-local):
pad_edge       = $0001  ; mode-filtered controller edge flags
  LDA #$00                                ; $A39D: A9 00 ; pad 1
  JSR BattlePadStateFetch                 ; $A39F: 20 DE CC
  LDA pad_edge                                 ; $A3A2: A5 01 ; mode-filtered edge flags
  LSR                                     ; $A3A4: 4A ; bit0 = A button
  BCC @PollPad2                           ; $A3A5: 90 05
  LDA #$01                                ; $A3A7: A9 01
  STA btl_player_request_a                               ; $A3A9: 8D 68 05 ; pad 1 request flag
@PollPad2:
  LDA #$01                                ; $A3AC: A9 01 ; pad 2
  JSR BattlePadStateFetch                 ; $A3AE: 20 DE CC
  LDA pad_edge                                 ; $A3B1: A5 01
  LSR                                     ; $A3B3: 4A ; bit0 = A button
  BCC @Done                               ; $A3B4: 90 05
  LDA #$01                                ; $A3B6: A9 01
  STA btl_player_request_b                               ; $A3B8: 8D 69 05 ; pad 2 request flag
@Done:
  RTS                                     ; $A3BB: 60
.endproc
;===============================================================================
; $A3BC: Phase4ResultSubDispatch
; Phase 4 (battle result: defeat/retreat resolution) handler of
; BattleOverlayDispatch, run once per VBlank while $0540 = 4. Entered at
; sub 0 by BattleDefeatEventCheck ($A2A9) and at sub 3 by
; BattleRetreatEventCheck ($A32F). Runs a random damage-roll cycle that
; drains one side's troop count ($05AC side A / $05B7 side B, selected by scan
; column $0545) and ends by advancing to phase 5. Sub-phases via inline
; 7-entry table at $A3C4 indexed by $0541:
;   0 Phase4ResultAdvance        ($A3D0) stall one frame
;   1 Phase4ResultDefeatInputWait($A3D4) wait anim-idle + A/B edge -> sub 2
;   2 Phase4ResultFlashTrigger   ($A3F2) $0087 bit7 -> flash $0500=$0B, $007A <- 3
;   3 Phase4ResultRetreatInputWait($A407) wait anim-idle + A/B edge, then
;                                         roll [0,100): <32 -> sub 2 retry,
;                                         else damage = roll2+5 -> sub 4
;                                         (roll continuation at $A42F)
;   4 Phase4ResultDamageApply    ($A488) apply damage, confirm -> sub 2
;   5 Phase4ResultConfirmInput   ($A4B5) A/B edge -> sub 2 (loop) with SFX $D3
;   6 Phase4ResultFlashTrigger   ($A3F2) shared with sub 2
;===============================================================================
.proc Phase4ResultSubDispatch
  LDA btl_overlay_sub                               ; $A3BC: AD 41 05 ; sub-phase index
  JSR B1F_CallbackDispatcher              ; $A3BF: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase4ResultAdvance               ; $A3C4: D0 A3 ; sub 0
  .word Phase4ResultDefeatInputWait       ; $A3C6: D4 A3 ; sub 1
  .word Phase4ResultFlashTrigger          ; $A3C8: F2 A3 ; sub 2
  .word Phase4ResultRetreatInputWait      ; $A3CA: 07 A4 ; sub 3
  .word Phase4ResultDamageApply           ; $A3CC: 88 A4 ; sub 4
  .word Phase4ResultConfirmInput          ; $A3CE: B5 A4 ; sub 5
  .word Phase4ResultFlashTrigger          ; $A3D0: F2 A3 ; sub 6
.endproc
;===============================================================================
; $A3D0: Phase4ResultAdvance
; Sub 0 (defeat entry point): stalls one frame by advancing to sub 1.
;===============================================================================
.proc Phase4ResultAdvance
  INC btl_overlay_sub                               ; $A3D0: EE 41 05 ; sub-phase <- 1
  RTS                                     ; $A3D3: 60
.endproc
;===============================================================================
; $A3D4: Phase4ResultDefeatInputWait
; Sub 1: waits for the animation queue to idle (BattleAnimQueueIdleCheck carry set), draws
; the blinking input prompt sprite (BattleInputPromptDraw) and accepts an
; A/B button edge on either pad (BattleBothPadsStateFetch $CD22, bits 0-1 of
; merged $0001),
; then advances to sub 2 via B1F_PaletteCopyBuffer + BattleOverlayTotalRefresh.
;===============================================================================
.proc Phase4ResultDefeatInputWait
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
  JSR BattleBothPadsStateFetch            ; $A3D4: 20 22 CD ; merge both pads -> $0000/$0001
  JSR BattleAnimQueueIdleCheck                 ; $A3D7: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A3DA: 90 15 ; busy: wait
  JSR BattleInputPromptDraw             ; $A3DC: 20 A8 CC ; blink input prompt sprite
  JSR BattleBothPadsStateFetch            ; $A3DF: 20 22 CD ; re-fetch merged pad state
  LDA pad_state                                 ; $A3E2: A5 01 ; merged raw state
  AND #$03                                ; $A3E4: 29 03 ; A or B edge?
  BEQ @Done                               ; $A3E6: F0 09
  JSR B1F_PaletteCopyBuffer               ; $A3E8: 20 EE EC ; palette refresh
  INC btl_overlay_sub                               ; $A3EB: EE 41 05 ; sub-phase <- 2
  JSR BattleOverlayTotalRefresh           ; $A3EE: 20 3F CA ; overlay total refresh
@Done:
  RTS                                     ; $A3F1: 60
.endproc
;===============================================================================
; $A3F2: Phase4ResultFlashTrigger
; Sub 2 and sub 6 shared handler: waits on $0087 bit7 (palette/frame flag);
; while clear, stalls. When set, arms a screen flash ($0500 <- $0B,
; $0501 <- 0, flash counter $007A <- 3) and falls through.
;===============================================================================
.proc Phase4ResultFlashTrigger
  LDA a:btl_frame_flag                             ; $A3F2: AD 87 00 ; palette/frame flag
  BPL @Done                               ; $A3F5: 10 0F ; bit7 clear: wait
  LDA #$0B                                ; $A3F7: A9 0B
  STA war_scene_id                               ; $A3F9: 8D 00 05 ; flash id
  LDA #$00                                ; $A3FC: A9 00
  STA war_scene_phase                               ; $A3FE: 8D 01 05
  LDA #$03                                ; $A401: A9 03
  STA a:btl_flash_counter                             ; $A403: 8D 7A 00 ; flash counter
@Done:
  RTS                                     ; $A406: 60
.endproc
;===============================================================================
; $A407: Phase4ResultRetreatInputWait
; Sub 3 (retreat entry point): same anim-idle + A/B edge gate as sub 1, but
; on input rolls a random value [0,100) (B1F_RandomBelowThreshold): < $20
; re-routes to sub 2 (flash/retry via B1F_PaletteCopyBuffer +
; BattleOverlayTotalRefresh), otherwise stores roll+5 as pending damage
; amount $0548 (mirror $042F), clears $0430/$0431, plays SFX $7E and
; advances to sub 4.
;===============================================================================
.proc Phase4ResultRetreatInputWait
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
  JSR BattleBothPadsStateFetch            ; $A407: 20 22 CD ; merge both pads
  JSR BattleAnimQueueIdleCheck                 ; $A40A: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A40D: 90 5D ; busy: wait
  JSR BattleInputPromptDraw             ; $A40F: 20 A8 CC ; blink input prompt sprite
  JSR BattleBothPadsStateFetch            ; $A412: 20 22 CD ; re-fetch merged pad state
  LDA pad_state                                 ; $A415: A5 01 ; merged raw state
  AND #$03                                ; $A417: 29 03 ; A or B edge?
  BEQ @Done                               ; $A419: F0 51
  LDA #$64                                ; $A41B: A9 64 ; threshold 100
  JSR B1F_RandomBelowThreshold            ; $A41D: 20 62 E8 ; roll [0,100)
  CMP #$20                                ; $A420: C9 20
  BCS @RollAccepted                       ; $A422: B0 0B ; roll >= 32: apply
  JSR B1F_PaletteCopyBuffer               ; $A424: 20 EE EC ; retry path
  LDA #$02                                ; $A427: A9 02
  STA btl_overlay_sub                               ; $A429: 8D 41 05 ; sub-phase <- 2
  JMP BattleOverlayTotalRefresh           ; $A42C: 4C 3F CA ; overlay total refresh
@RollAccepted:
  INC btl_overlay_sub                               ; $A42F: EE 41 05 ; sub-phase <- 4
  LDA #$0A                                ; $A432: A9 0A ; threshold 10
  JSR B1F_RandomBelowThreshold            ; $A434: 20 62 E8 ; roll [0,10)
  CLC                                     ; $A437: 18
  ADC #$05                                ; $A438: 69 05 ; damage = roll+5 (5..14)
  STA btl_panel_params+3                               ; $A43A: 8D 2F 04 ; panel param mirror
  STA btl_frame_counter                               ; $A43D: 8D 48 05 ; pending damage amount
  LDA #$00                                ; $A440: A9 00
  STA btl_panel_params+4                               ; $A442: 8D 30 04
  STA btl_panel_params+5                               ; $A445: 8D 31 04
  LDA #$7E                                ; $A448: A9 7E
  JSR B1F_SetUI4                          ; $A44A: 20 8B F2 ; SFX
  LDA btl_scan_col                               ; $A44D: AD 45 05 ; scan column selects side
  BNE @SideB                              ; $A450: D0 1B
  LDA btl_strip_sel_a                               ; $A452: AD 14 05 ; strip 0 buffer ptr
  STA btl_panel_params                               ; $A455: 8D 2C 04
  LDA btl_troops_a                               ; $A458: AD AC 05 ; side A troop count
  SEC                                     ; $A45B: 38
  SBC btl_frame_counter                               ; $A45C: ED 48 05
  BCS @StoreSideA                         ; $A45F: B0 08 ; no underflow
  LDA btl_troops_a                               ; $A461: AD AC 05 ; clamp: drain all
  STA btl_panel_params+3                               ; $A464: 8D 2F 04 ; damage = full troop count
  LDA #$00                                ; $A467: A9 00
@StoreSideA:
  STA btl_troops_a                               ; $A469: 8D AC 05
@Done:
  RTS                                     ; $A46C: 60
@SideB:
  LDA btl_strip_sel_b                               ; $A46D: AD 16 05 ; strip 1 buffer ptr
  STA btl_panel_params                               ; $A470: 8D 2C 04
  LDA btl_troops_b                               ; $A473: AD B7 05 ; side B troop count
  SEC                                     ; $A476: 38
  SBC btl_frame_counter                               ; $A477: ED 48 05
  BCS @StoreSideB                         ; $A47A: B0 08 ; no underflow
  LDA btl_troops_b                               ; $A47C: AD B7 05 ; clamp: drain all
  STA btl_panel_params+3                               ; $A47F: 8D 2F 04 ; damage = full troop count
  LDA #$00                                ; $A482: A9 00
@StoreSideB:
  STA btl_troops_b                               ; $A484: 8D B7 05
  RTS                                     ; $A487: 60
.endproc
;===============================================================================
; $A488: Phase4ResultDamageApply
; Sub 4: anim-idle + A/B edge gate; on input, Phase4ResultColumnDamageSelect
; returns the current troop count of the scanned side (0 if fully drained).
; Non-zero confirms (B1F_PaletteCopyBuffer, sub <- 2, BattleOverlayTotalRefresh);
; zero advances to sub 5 with SFX $D3.
;===============================================================================
.proc Phase4ResultDamageApply
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
  JSR BattleBothPadsStateFetch            ; $A488: 20 22 CD ; merge both pads
  JSR BattleAnimQueueIdleCheck                 ; $A48B: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A48E: 90 24 ; busy: wait
  JSR BattleInputPromptDraw             ; $A490: 20 A8 CC ; blink input prompt sprite
  JSR BattleBothPadsStateFetch            ; $A493: 20 22 CD ; re-fetch merged pad state
  LDA pad_state                                 ; $A496: A5 01 ; merged raw state
  AND #$03                                ; $A498: 29 03 ; A or B edge?
  BEQ @Done                               ; $A49A: F0 18
  JSR Phase4ResultColumnDamageSelect      ; $A49C: 20 D8 A4 ; troop count of scanned side
  BEQ @Advance                            ; $A49F: F0 0B ; fully drained
  JSR B1F_PaletteCopyBuffer               ; $A4A1: 20 EE EC ; confirm path
  LDA #$02                                ; $A4A4: A9 02
  STA btl_overlay_sub                               ; $A4A6: 8D 41 05 ; sub-phase <- 2
  JMP BattleOverlayTotalRefresh           ; $A4A9: 4C 3F CA ; overlay total refresh
@Advance:
  INC btl_overlay_sub                               ; $A4AC: EE 41 05 ; sub-phase <- 5
  LDA #$D3                                ; $A4AF: A9 D3
  JSR B1F_SetUI4                          ; $A4B1: 20 8B F2 ; SFX
@Done:
  RTS                                     ; $A4B4: 60
.endproc
;===============================================================================
; $A4B5: Phase4ResultConfirmInput
; Sub 5: anim-idle + A/B edge gate; on input, Phase4ResultColumnStripSelect
; marks the drained side's strip flag ($0515 side A / $0517 side B <- 2),
; then loops to sub 2 via B1F_PaletteCopyBuffer + BattleOverlayTotalRefresh.
;===============================================================================
.proc Phase4ResultConfirmInput
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
  JSR BattleBothPadsStateFetch            ; $A4B5: 20 22 CD ; merge both pads
  JSR BattleAnimQueueIdleCheck                 ; $A4B8: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A4BB: 90 1A ; busy: wait
  JSR BattleInputPromptDraw             ; $A4BD: 20 A8 CC ; blink input prompt sprite
  JSR BattleBothPadsStateFetch            ; $A4C0: 20 22 CD ; re-fetch merged pad state
  LDA pad_state                                 ; $A4C3: A5 01 ; merged raw state
  AND #$03                                ; $A4C5: 29 03 ; A or B edge?
  BEQ @Done                               ; $A4C7: F0 0E
  JSR Phase4ResultColumnStripSelect       ; $A4C9: 20 E6 A4 ; mark drained side strip
  JSR B1F_PaletteCopyBuffer               ; $A4CC: 20 EE EC ; palette refresh
  LDA #$02                                ; $A4CF: A9 02
  STA btl_overlay_sub                               ; $A4D1: 8D 41 05 ; sub-phase <- 2
  JMP BattleOverlayTotalRefresh           ; $A4D4: 4C 3F CA ; overlay total refresh
@Done:
  RTS                                     ; $A4D7: 60
.endproc
;===============================================================================
; $A4D8: Phase4ResultColumnDamageSelect
; Helper for Phase4ResultDamageApply: returns A = troop count of the side
; selected by scan column $0545 (0 -> side A $05AC, non-zero -> side B
; $05B7); Z flag set when the side is fully drained.
;===============================================================================
.proc Phase4ResultColumnDamageSelect
  LDA btl_troops_a                               ; $A4D8: AD AC 05 ; side A troop count
  LDY btl_scan_col                               ; $A4DB: AC 45 05 ; scan column
  BEQ @Compare                            ; $A4DE: F0 03 ; column 0: side A
  LDA btl_troops_b                               ; $A4E0: AD B7 05 ; side B troop count
@Compare:
  CMP #$00                                ; $A4E3: C9 00 ; set Z if drained
  RTS                                     ; $A4E5: 60
.endproc
;===============================================================================
; $A4E6: Phase4ResultColumnStripSelect
; Helper for Phase4ResultConfirmInput: sets the strip flag of the side
; selected by scan column $0545: column 0 -> $0515 (side A), else $0517
; (side B) <- 2.
;===============================================================================
.proc Phase4ResultColumnStripSelect
  LDY btl_scan_col                               ; $A4E6: AC 45 05 ; scan column
  BEQ @SideA                              ; $A4E9: F0 06 ; column 0: side A
  LDA #$02                                ; $A4EB: A9 02
  STA btl_strip_flag_b                               ; $A4ED: 8D 17 05 ; side B strip flag
  RTS                                     ; $A4F0: 60
@SideA:
  LDA #$02                                ; $A4F1: A9 02
  STA btl_strip_flag_a                               ; $A4F3: 8D 15 05 ; side A strip flag
  RTS                                     ; $A4F6: 60
.endproc
;===============================================================================
; $A4F7: Phase2ActionSubDispatch
; Phase 2 (acting-unit command resolution) handler of BattleOverlayDispatch,
; run once per VBlank while $0540 = 2. Redraws the side status counters
; ($0574-$0577), polls both pads for player takeover requests
; (BattlePlayerRequestPoll), then sub-dispatches on $0541 through the inline
; 11-entry table below. Sub-state flow: sub 0 routes on the acting unit's
; command value $054F to the attack path (subs 6-9), the move path (subs
; 3-5) or the cursor-walk/pass path (subs 1-2); subs 5 and $A wait out the
; action animation before returning to phase 1 sub 2 (Phase1RoundPass).
;===============================================================================
.proc Phase2ActionSubDispatch
  JSR BattleSideStatusCounterDraw         ; $A4F7: 20 4C BF ; redraw $0574-$0577
  JSR BattlePlayerRequestPoll             ; $A4FA: 20 9D A3 ; player takeover poll
  LDA btl_overlay_sub                               ; $A4FD: AD 41 05 ; sub-phase index
  JSR B1F_CallbackDispatcher              ; $A500: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase2ActionGate                  ; $A503: 19 A5 ; sub 0
  .word Phase2CursorWalkInit              ; $A505: C4 A5 ; sub 1
  .word Phase2CursorWalkStep              ; $A507: F3 A5 ; sub 2
  .word Phase2MoveEventCheck              ; $A509: 1D A6 ; sub 3
  .word Phase2MoveCommit                  ; $A50B: 54 A6 ; sub 4
  .word Phase2ActionEndWait               ; $A50D: E4 A6 ; sub 5
  .word Phase2AttackSetup                 ; $A50F: 02 A7 ; sub 6
  .word Phase2AttackArrowAnim             ; $A511: 2E A7 ; sub 7
  .word Phase2AttackAnimCount             ; $A513: 4A A7 ; sub 8
  .word Phase2AttackDamageApply           ; $A515: 5B A7 ; sub 9
  .word Phase2ActionDoneWait              ; $A517: E0 A7 ; sub $A
.endproc
;===============================================================================
; $A519: Phase2ActionGate
; Sub 0: routes the acting unit's command value $054F (copied from action
; slot $0550 by Phase1NextActorSelect). First clears the frame counter $0548
; and the recorded-status byte $054C. Command 1 goes straight to the
; selection gate. Otherwise the cursor column's status $05C2[$0545] decides:
; action bits == 2 takes the attack route (status recorded into $054C,
; actor id encoded into the status high nibble, sub <- 6), anything else the
; move route (status into $054B, sub <- 3); command 3 with action bits 0
; also falls to the selection gate, as does a missing actor ($0549 bit7).
; Selection gate: command 2 passes the turn outright; otherwise the side
; status counter $0574 nybble for the scanned board half (low for columns
; 0-$A, high for columns $B-$15) must be clear to select - non-zero passes
; the turn. Selection clears $FE/$FF markers via Phase2ColumnResetCheck,
; runs Phase2WalkDirectionResolve, encodes the resolved direction into the
; column status and advances to the cursor walk (sub 1).
;===============================================================================
.proc Phase2ActionGate
  LDA #$00                                ; $A519: A9 00
  STA btl_frame_counter                               ; $A51B: 8D 48 05 ; frame counter <- 0
  LDA #$00                                ; $A51E: A9 00
  STA btl_recorded_status                               ; $A520: 8D 4C 05 ; recorded status <- 0
  LDA btl_command                               ; $A523: AD 4F 05 ; command value
  CMP #$01                                ; $A526: C9 01
  BEQ @SelectGate                         ; $A528: F0 62 ; command 1: selection gate
  LDY btl_scan_col                               ; $A52A: AC 45 05 ; cursor column
  LDA btl_roster_code_a,Y                             ; $A52D: B9 C2 05 ; column status
  AND #$0F                                ; $A530: 29 0F ; action bits
  CMP #$02                                ; $A532: C9 02
  BNE @MoveRoute                          ; $A534: D0 2B
  JSR Phase2AttackRouteResolve            ; $A536: 20 0F C3 ; attack-route setup
  LDA btl_acting_unit                               ; $A539: AD 49 05 ; acting unit id
  BMI @MoveRoute                          ; $A53C: 30 23 ; no actor: move route
  LDA btl_command                               ; $A53E: AD 4F 05
  CMP #$03                                ; $A541: C9 03
  BNE @AttackRoute                        ; $A543: D0 07
  LDA btl_roster_code_a,X                             ; $A545: BD C2 05
  AND #$03                                ; $A548: 29 03
  BEQ @MoveRoute                          ; $A54A: F0 15 ; cmd 3, bits 0: move route
@AttackRoute:
  LDY btl_scan_col                               ; $A54C: AC 45 05
  LDA btl_roster_code_a,Y                             ; $A54F: B9 C2 05 ; column status
  STA btl_recorded_status                               ; $A552: 8D 4C 05 ; record for commit
  LDA btl_acting_unit                               ; $A555: AD 49 05 ; acting unit id
  JSR Phase2ColumnStatusEncode            ; $A558: 20 0F AA ; encode into status
  LDA #$06                                ; $A55B: A9 06
  STA btl_overlay_sub                               ; $A55D: 8D 41 05 ; sub-phase <- 6 (attack)
  RTS                                     ; $A560: 60
@MoveRoute:
  JSR Phase2MoveRouteResolve              ; $A561: 20 0F C2 ; move-route setup
  LDA btl_acting_unit                               ; $A564: AD 49 05
  BMI @SelectGate                         ; $A567: 30 23 ; no actor: selection gate
  LDA btl_command                               ; $A569: AD 4F 05
  CMP #$03                                ; $A56C: C9 03
  BNE @MoveRecord                         ; $A56E: D0 07
  LDA btl_roster_code_a,X                             ; $A570: BD C2 05
  AND #$03                                ; $A573: 29 03
  BEQ @SelectGate                         ; $A575: F0 15 ; cmd 3, bits 0: gate
@MoveRecord:
  LDY btl_scan_col                               ; $A577: AC 45 05
  LDA btl_roster_code_a,Y                             ; $A57A: B9 C2 05 ; column status
  STA btl_walk_col                               ; $A57D: 8D 4B 05 ; record for commit
  LDA btl_acting_unit                               ; $A580: AD 49 05 ; acting unit id
  JSR Phase2ColumnStatusEncode            ; $A583: 20 0F AA ; encode into status
  LDA #$03                                ; $A586: A9 03
  STA btl_overlay_sub                               ; $A588: 8D 41 05 ; sub-phase <- 3 (move)
  RTS                                     ; $A58B: 60
@SelectGate:
  LDA btl_command                               ; $A58C: AD 4F 05
  CMP #$02                                ; $A58F: C9 02
  BEQ @PassTurn                           ; $A591: F0 2E ; command 2: pass
  LDY btl_scan_col                               ; $A593: AC 45 05 ; cursor column
  BEQ @CounterUpper                       ; $A596: F0 0D ; column 0: high nybble
  CPY #$0B                                ; $A598: C0 0B
  BNE @Select                             ; $A59A: D0 10 ; inner columns: select
  LDA btl_status_ctr0                               ; $A59C: AD 74 05 ; side status counter
  AND #$0F                                ; $A59F: 29 0F ; lower-half nybble
  BNE @PassTurn                           ; $A5A1: D0 1E
  BEQ @Select                             ; $A5A3: F0 07
@CounterUpper:
  LDA btl_status_ctr0                               ; $A5A5: AD 74 05 ; side status counter
  AND #$F0                                ; $A5A8: 29 F0 ; upper-half nybble
  BNE @PassTurn                           ; $A5AA: D0 15
@Select:
  JSR Phase2ColumnResetCheck              ; $A5AC: 20 FE A7 ; clear $FE/$FF markers
  JSR Phase2WalkDirectionResolve          ; $A5AF: 20 64 C0 ; resolve walk direction
  LDA btl_acting_unit                               ; $A5B2: AD 49 05 ; direction ($FF = none)
  BMI @PassTurn                           ; $A5B5: 30 0A ; no direction: pass turn
  INC btl_overlay_sub                               ; $A5B7: EE 41 05 ; sub-phase <- 1 (walk)
  LDA btl_acting_unit                               ; $A5BA: AD 49 05
  JSR Phase2ColumnStatusEncode            ; $A5BD: 20 0F AA ; encode actor
@Done:
  RTS                                     ; $A5C0: 60
@PassTurn:
  JMP Phase2TurnPassReset                 ; $A5C1: 4C 06 A6
.endproc
;===============================================================================
; $A5C4: Phase2CursorWalkInit
; Sub 1: un-highlights the cursor column ($12=0/$13=column -> BattleCellRedraw),
; advances to sub 2, clears the frame counter $0548 and latches the acting
; column's row markers: $054A <- $0580[$0545]<<4, $054B <- $0596[$0545]<<4.
; Draws the first cursor-arrow frame via Phase2CursorArrowDraw.
;===============================================================================
.proc Phase2CursorWalkInit
  LDA #$00                                ; $A5C4: A9 00
  STA $12                                 ; $A5C6: 85 12 ; un-highlight
  LDA btl_scan_col                               ; $A5C8: AD 45 05 ; cursor column
  STA $13                                 ; $A5CB: 85 13
  JSR BattleCellRedraw                         ; $A5CD: 20 82 B8 ; column tile update
  INC btl_overlay_sub                               ; $A5D0: EE 41 05 ; sub-phase <- 2
  LDA #$00                                ; $A5D3: A9 00
  STA btl_frame_counter                               ; $A5D5: 8D 48 05 ; frame counter <- 0
  LDY btl_scan_col                               ; $A5D8: AC 45 05
  LDA btl_unit_col_a,Y                             ; $A5DB: B9 80 05 ; row marker
  ASL                                     ; $A5DE: 0A
  ASL                                     ; $A5DF: 0A
  ASL                                     ; $A5E0: 0A
  ASL                                     ; $A5E1: 0A
  STA btl_walk_row                               ; $A5E2: 8D 4A 05 ; walk row << 4
  LDA btl_unit_row_a,Y                             ; $A5E5: B9 96 05 ; row marker
  ASL                                     ; $A5E8: 0A
  ASL                                     ; $A5E9: 0A
  ASL                                     ; $A5EA: 0A
  ASL                                     ; $A5EB: 0A
  STA btl_walk_col                               ; $A5EC: 8D 4B 05 ; walk column << 4
  JSR Phase2CursorArrowDraw               ; $A5EF: 20 8F BB ; cursor arrow draw
  RTS                                     ; $A5F2: 60
.endproc
;===============================================================================
; $A5F3: Phase2CursorWalkStep
; Sub 2: animates the cursor walk - redraws the arrow (Phase2CursorArrowDraw)
; and steps the
; walk position one cell per frame in the direction for acting side $0549
; (Phase2CursorStep). After $10 frames calls Phase2CommitMarkerAdjust, whose
; RTS lands in Phase2TurnPassReset; while walking, the wait loop branches to
; Phase2TurnPassReset's shared Phase2WalkExit RTS.
;===============================================================================
.proc Phase2CursorWalkStep
  JSR Phase2CursorArrowDraw               ; $A5F3: 20 8F BB ; cursor arrow draw
  JSR Phase2CursorStep                    ; $A5F6: 20 A0 A9 ; step walk position
  INC btl_frame_counter                               ; $A5F9: EE 48 05 ; frame counter++
  LDA btl_frame_counter                               ; $A5FC: AD 48 05
  CMP #$10                                ; $A5FF: C9 10
  BCC Phase2WalkExit                      ; $A601: 90 19 ; still walking
  JSR Phase2CommitMarkerAdjust            ; $A603: 20 BD A9 ; commit; falls through
.endproc
;===============================================================================
; $A606: Phase2TurnPassReset
; Turn-pass reset, entered two ways: fall-through from Phase2CursorWalkStep
; (after the walk completes) and via JMP from Phase2ActionGate's pass-turn
; paths. Re-highlights the cursor column ($12=$10/$13=column -> BattleCellRedraw) and
; returns to phase 1 sub 2 (Phase1RoundPass).
;===============================================================================
.proc Phase2TurnPassReset
  LDA #$10                                ; $A606: A9 10
  STA $12                                 ; $A608: 85 12 ; highlight
  LDA btl_scan_col                               ; $A60A: AD 45 05 ; cursor column
  STA $13                                 ; $A60D: 85 13
  JSR BattleCellRedraw                         ; $A60F: 20 82 B8 ; column tile update
  LDA #$01                                ; $A612: A9 01
  STA btl_overlay_phase                               ; $A614: 8D 40 05 ; phase <- 1
  LDA #$02                                ; $A617: A9 02
  STA btl_overlay_sub                               ; $A619: 8D 41 05 ; sub <- 2 (Phase1RoundPass)
.endproc
;-------------------------------------------------------------------------------
; $A61C: Phase2WalkExit - shared RTS at the tail of Phase2TurnPassReset,
; branched to by Phase2CursorWalkStep's wait loop.
; Practice: a shared RTS has exactly one byte, so its label cannot live in
; two procs; ca65 scopes every label inside .proc (plain cross-proc refs,
; Proc::Label, anonymous :-, and .global all fail to reach it), so shared
; exit labels must stay bare globals between procs.
;-------------------------------------------------------------------------------
Phase2WalkExit:
  RTS                                     ; $A61C: 60
;===============================================================================
; $A61D: Phase2MoveEventCheck
; Sub 3 (move path first step): end-battle event gate - when the cursor
; column is one of the side-event columns (0 or $0B) and the latched walk
; position ($054A) is also 0 or $0B, a pending side event routes straight
; to phase 5 sub 0. Otherwise re-highlights the cursor column, advances to
; sub 4, clears the frame counter $0548 and plays SFX $5E (move start).
;===============================================================================
.proc Phase2MoveEventCheck
  LDA btl_scan_col                               ; $A61D: AD 45 05 ; cursor column
  BEQ @EventColumnCheck                   ; $A620: F0 04 ; column 0
  CMP #$0B                                ; $A622: C9 0B
  BNE @CommitPrep                         ; $A624: D0 14 ; inner column
@EventColumnCheck:
  LDA btl_walk_row                               ; $A626: AD 4A 05 ; walk row << 4
  BEQ @GotoPhase5                         ; $A629: F0 04
  CMP #$0B                                ; $A62B: C9 0B
  BNE @CommitPrep                         ; $A62D: D0 0B
@GotoPhase5:
  LDA #$05                                ; $A62F: A9 05
  STA btl_overlay_phase                               ; $A631: 8D 40 05 ; phase <- 5
  LDA #$00                                ; $A634: A9 00
  STA btl_overlay_sub                               ; $A636: 8D 41 05 ; sub-phase <- 0
  RTS                                     ; $A639: 60
@CommitPrep:
  LDA #$10                                ; $A63A: A9 10
  STA $12                                 ; $A63C: 85 12 ; highlight
  LDA btl_scan_col                               ; $A63E: AD 45 05 ; cursor column
  STA $13                                 ; $A641: 85 13
  JSR BattleCellRedraw                         ; $A643: 20 82 B8 ; column tile update
  INC btl_overlay_sub                               ; $A646: EE 41 05 ; sub-phase <- 4
  LDA #$00                                ; $A649: A9 00
  STA btl_frame_counter                               ; $A64B: 8D 48 05 ; frame counter <- 0
  LDA #$5E                                ; $A64E: A9 5E
  JSR B1F_SoundNotePlayer                 ; $A650: 20 09 E6 ; SFX move start
.endproc
;-------------------------------------------------------------------------------
; $A653: Phase2AnimWaitExit - shared RTS at the tail of Phase2MoveEventCheck,
; branched to by Phase2MoveCommit's animation wait loop.
; Bare global between procs by necessity: see Phase2WalkExit ($A61C).
;-------------------------------------------------------------------------------
Phase2AnimWaitExit:
  RTS                                     ; $A653: 60
;===============================================================================
; $A654: Phase2MoveCommit
; Sub 4: draws the cursor arrow via BattleCursorArrowSprSubmit ($BE15) and
; blinks the target
; column (Phase2CursorBlinkIfActive, Y = walk row $054A) while the frame
; counter $0548 counts to $20. Then writes the recorded column status $054B
; back to $05C2[$0545] and computes the damage inflicted on column $054A:
; if its action bits are 2, Phase2AttackComputeDefended (60% base), else
; Phase2AttackDamageCompute. The damage ($00) is subtracted from the column
; troop count $05AC[$054A]; a drained column is eliminated (panel update with amount
; $01, un-highlight, roster slots $0580/$0596/$05AC/$05C2 <- $FF), a
; surviving column is redrawn highlighted. Either way advances to sub 5.
;===============================================================================
.proc Phase2MoveCommit
; zero-page work cells (proc-local):
damage         = $0000  ; contact damage subtracted from troop count
amount         = $0001  ; panel update amount (pre-damage troop count)
  JSR BattleCursorArrowSprSubmit          ; $A654: 20 15 BE ; cursor arrow draw
  LDY btl_walk_row                               ; $A657: AC 4A 05 ; target column
  JSR Phase2CursorBlinkIfActive           ; $A65A: 20 D0 A6 ; blink target
  INC btl_frame_counter                               ; $A65D: EE 48 05 ; frame counter++
  LDA btl_frame_counter                               ; $A660: AD 48 05
  CMP #$20                                ; $A663: C9 20
  BCC Phase2AnimWaitExit                  ; $A665: 90 EC ; still animating
  LDY btl_scan_col                               ; $A667: AC 45 05 ; cursor column
  LDA btl_walk_col                               ; $A66A: AD 4B 05 ; recorded status
  STA btl_roster_code_a,Y                             ; $A66D: 99 C2 05 ; commit new status
  LDY btl_scan_col                               ; $A670: AC 45 05
  LDA btl_roster_code_a,Y                             ; $A673: B9 C2 05
  AND #$0F                                ; $A676: 29 0F ; action bits
  CMP #$02                                ; $A678: C9 02
  BNE @PlainDamage                        ; $A67A: D0 06
  JSR Phase2AttackComputeDefended         ; $A67C: 20 4D A8 ; 60% base damage
  JMP @ApplyDamage                        ; $A67F: 4C 85 A6
@PlainDamage:
  JSR Phase2AttackDamageCompute           ; $A682: 20 F2 A8 ; full damage
@ApplyDamage:
  LDY btl_walk_row                               ; $A685: AC 4A 05 ; target column
  LDA btl_troops_a,Y                             ; $A688: B9 AC 05 ; target troop count
  SEC                                     ; $A68B: 38
  SBC damage                                 ; $A68C: E5 00 ; subtract damage
  STA btl_troops_a,Y                             ; $A68E: 99 AC 05
  BEQ @Eliminated                         ; $A691: F0 02 ; exactly drained
  BCS @Survived                           ; $A693: B0 28 ; troop count left
@Eliminated:
  LDA amount                                 ; $A695: A5 01 ; computed amount
  STA damage                                 ; $A697: 85 00
  JSR Phase2DamagePanelUpdate             ; $A699: 20 C5 A7 ; panel damage number
  LDA #$00                                ; $A69C: A9 00
  STA $12                                 ; $A69E: 85 12 ; un-highlight
  LDA btl_walk_row                               ; $A6A0: AD 4A 05 ; target column
  STA $13                                 ; $A6A3: 85 13
  JSR BattleCellRedraw                         ; $A6A5: 20 82 B8 ; column tile update
  LDY btl_walk_row                               ; $A6A8: AC 4A 05
  LDA #$FF                                ; $A6AB: A9 FF
  STA btl_unit_col_a,Y                             ; $A6AD: 99 80 05 ; empty slot
  STA btl_unit_row_a,Y                             ; $A6B0: 99 96 05
  STA btl_troops_a,Y                             ; $A6B3: 99 AC 05
  STA btl_roster_code_a,Y                             ; $A6B6: 99 C2 05
  INC btl_overlay_sub                               ; $A6B9: EE 41 05 ; sub-phase <- 5
  RTS                                     ; $A6BC: 60
@Survived:
  JSR Phase2DamagePanelUpdate             ; $A6BD: 20 C5 A7 ; panel damage number
  LDA #$10                                ; $A6C0: A9 10
  STA $12                                 ; $A6C2: 85 12 ; highlight
  LDA btl_walk_row                               ; $A6C4: AD 4A 05 ; target column
  STA $13                                 ; $A6C7: 85 13
  JSR BattleCellRedraw                         ; $A6C9: 20 82 B8 ; column tile update
  INC btl_overlay_sub                               ; $A6CC: EE 41 05 ; sub-phase <- 5
@Done:
  RTS                                     ; $A6CF: 60
.endproc
;===============================================================================
; $A6D0: Phase2CursorBlinkIfActive
; Conditional column blink: when $005E bits 0-1 are set (frame phase),
; bit 3 selects the highlight mode into $12 and the column index (Y) into
; $13, then updates the column tile via BattleCellRedraw.
;===============================================================================
.proc Phase2CursorBlinkIfActive
  LDA a:frame_tick                             ; $A6D0: AD 5E 00 ; frame phase flags
  AND #$03                                ; $A6D3: 29 03
  BEQ @Done                               ; $A6D5: F0 0C ; not a blink frame
  LDA a:frame_tick                             ; $A6D7: AD 5E 00
  AND #$08                                ; $A6DA: 29 08 ; highlight mode
  STA $12                                 ; $A6DC: 85 12
  STY $13                                 ; $A6DE: 84 13 ; column index
  JSR BattleCellRedraw                         ; $A6E0: 20 82 B8 ; column tile update
@Done:
  RTS                                     ; $A6E3: 60
.endproc
;===============================================================================
; $A6E4: Phase2ActionEndWait
; Sub 5: waits for $007E bit2 (action animation done); then re-highlights
; the cursor column and returns to phase 1 sub 2 (Phase1RoundPass).
;===============================================================================
.proc Phase2ActionEndWait
  LDA a:btl_anim_flags                             ; $A6E4: AD 7E 00 ; action status
  AND #$04                                ; $A6E7: 29 04 ; done flag
  BNE @Done                               ; $A6E9: D0 16 ; not yet: wait
  LDA #$10                                ; $A6EB: A9 10
  STA $12                                 ; $A6ED: 85 12 ; highlight
  LDA btl_scan_col                               ; $A6EF: AD 45 05 ; cursor column
  STA $13                                 ; $A6F2: 85 13
  JSR BattleCellRedraw                         ; $A6F4: 20 82 B8 ; column tile update
  LDA #$01                                ; $A6F7: A9 01
  STA btl_overlay_phase                               ; $A6F9: 8D 40 05 ; phase <- 1
  LDA #$02                                ; $A6FC: A9 02
  STA btl_overlay_sub                               ; $A6FE: 8D 41 05 ; sub <- 2 (Phase1RoundPass)
@Done:
  RTS                                     ; $A701: 60
.endproc
;===============================================================================
; $A702: Phase2AttackSetup
; Sub 6: re-highlights the cursor column, advances to sub 7, latches the
; acting column's row markers ($054A <- $0580[Y]<<4, $054B <- $0596[Y]<<4)
; and plays SFX $5A (attack start).
;===============================================================================
.proc Phase2AttackSetup
  LDA #$10                                ; $A702: A9 10
  STA $12                                 ; $A704: 85 12 ; highlight
  LDA btl_scan_col                               ; $A706: AD 45 05 ; cursor column
  STA $13                                 ; $A709: 85 13
  JSR BattleCellRedraw                         ; $A70B: 20 82 B8 ; column tile update
  INC btl_overlay_sub                               ; $A70E: EE 41 05 ; sub-phase <- 7
  LDY btl_scan_col                               ; $A711: AC 45 05
  LDA btl_unit_col_a,Y                             ; $A714: B9 80 05 ; row marker
  ASL                                     ; $A717: 0A
  ASL                                     ; $A718: 0A
  ASL                                     ; $A719: 0A
  ASL                                     ; $A71A: 0A
  STA btl_walk_row                               ; $A71B: 8D 4A 05 ; target row << 4
  LDA btl_unit_row_a,Y                             ; $A71E: B9 96 05 ; row marker
  ASL                                     ; $A721: 0A
  ASL                                     ; $A722: 0A
  ASL                                     ; $A723: 0A
  ASL                                     ; $A724: 0A
  STA btl_walk_col                               ; $A725: 8D 4B 05 ; target column << 4
  LDA #$5A                                ; $A728: A9 5A
  JSR B1F_SoundWrapperF                   ; $A72A: 20 9B E6 ; SFX attack start
@Done:
  RTS                                     ; $A72D: 60
.endproc
;===============================================================================
; $A72E: Phase2AttackArrowAnim
; Sub 7: submits the attack arrow (Phase2AttackArrowSprSubmit) and fast-steps
; the cursor position (Phase2CursorStepFast) each frame, decrementing the
; frame counter $0548 by 2; when it goes negative, resets it to 8, advances
; to sub 8 and plays SFX $5D.
;===============================================================================
.proc Phase2AttackArrowAnim
  JSR Phase2AttackArrowSprSubmit          ; $A72E: 20 76 BE ; attack arrow draw
  JSR Phase2CursorStepFast                ; $A731: 20 E6 A9 ; step x2
  DEC btl_frame_counter                               ; $A734: CE 48 05 ; frame counter -= 2
  DEC btl_frame_counter                               ; $A737: CE 48 05
  BPL Phase2DamageAnimExit                ; $A73A: 10 75 ; still animating
  LDA #$08                                ; $A73C: A9 08
  STA btl_frame_counter                               ; $A73E: 8D 48 05 ; counter <- 8
  INC btl_overlay_sub                               ; $A741: EE 41 05 ; sub-phase <- 8
  LDA #$5D                                ; $A744: A9 5D
  JSR B1F_SoundNotePlayer                 ; $A746: 20 09 E6 ; SFX
@Done:
  RTS                                     ; $A749: 60
.endproc
;===============================================================================
; $A74A: Phase2AttackAnimCount
; Sub 8: submits the attack marker (Phase2AttackMarkerSprSubmit) each frame,
; decrementing the frame counter $0548; when it goes negative, resets it to
; $18 and advances to sub 9 (damage apply delay).
;===============================================================================
.proc Phase2AttackAnimCount
  JSR Phase2AttackMarkerSprSubmit         ; $A74A: 20 15 BF ; attack marker draw
  DEC btl_frame_counter                               ; $A74D: CE 48 05 ; frame counter--
  BPL @Done                               ; $A750: 10 08 ; still animating
  LDA #$18                                ; $A752: A9 18
  STA btl_frame_counter                               ; $A754: 8D 48 05 ; counter <- $18
  INC btl_overlay_sub                               ; $A757: EE 41 05 ; sub-phase <- 9
@Done:
  RTS                                     ; $A75A: 60
.endproc
;===============================================================================
; $A75B: Phase2AttackDamageApply
; Sub 9: blinks the target column (Phase2CursorBlinkIfActive, Y = $054D)
; while the frame counter $0548 counts down from $18. Then writes the
; recorded status $054C to $05C2[$0545], copies the target column $054D to
; $054A, recomputes the column highlight with attack bonus
; (Phase2AttackComputeWithBonus), and subtracts the damage ($00) from troop count
; $05AC[$054D]. A drained column is eliminated (panel update, un-highlight,
; roster slots <- $FF); a surviving column is redrawn highlighted. Either
; way advances to sub $A.
;===============================================================================
.proc Phase2AttackDamageApply
; zero-page work cells (proc-local):
damage         = $0000  ; computed damage
troops_pre     = $0001  ; pre-damage troop count
  LDY btl_target_col                               ; $A75B: AC 4D 05 ; target column
  JSR Phase2CursorBlinkIfActive           ; $A75E: 20 D0 A6 ; blink target
  DEC btl_frame_counter                               ; $A761: CE 48 05 ; frame counter--
  BPL Phase2DamageAnimExit                ; $A764: 10 4B ; still waiting
  LDY btl_scan_col                               ; $A766: AC 45 05 ; cursor column
  LDA btl_recorded_status                               ; $A769: AD 4C 05 ; recorded status
  STA btl_roster_code_a,Y                             ; $A76C: 99 C2 05 ; commit new status
  LDA btl_target_col                               ; $A76F: AD 4D 05 ; target column
  STA btl_walk_row                               ; $A772: 8D 4A 05
  JSR Phase2AttackComputeWithBonus        ; $A775: 20 71 A8 ; damage + bonus
  LDY btl_target_col                               ; $A778: AC 4D 05 ; target column
  LDA btl_troops_a,Y                             ; $A77B: B9 AC 05 ; target troop count
  STA troops_pre                                 ; $A77E: 85 01 ; keep pre-damage troop count
  SEC                                     ; $A780: 38
  SBC damage                                 ; $A781: E5 00 ; subtract damage
  STA btl_troops_a,Y                             ; $A783: 99 AC 05
  BEQ @Eliminated                         ; $A786: F0 02 ; exactly drained
  BCS Phase2DamageSurvived                ; $A788: B0 28 ; troop count left
@Eliminated:
  LDA troops_pre                                 ; $A78A: A5 01 ; pre-damage troop count
  STA damage                                 ; $A78C: 85 00
  JSR Phase2DamagePanelUpdate             ; $A78E: 20 C5 A7 ; panel damage number
  LDA #$00                                ; $A791: A9 00
  STA $12                                 ; $A793: 85 12 ; un-highlight
  LDA btl_target_col                               ; $A795: AD 4D 05 ; target column
  STA $13                                 ; $A798: 85 13
  JSR BattleCellRedraw                         ; $A79A: 20 82 B8 ; column tile update
  LDY btl_target_col                               ; $A79D: AC 4D 05
  LDA #$FF                                ; $A7A0: A9 FF
  STA btl_unit_col_a,Y                             ; $A7A2: 99 80 05 ; empty slot
  STA btl_unit_row_a,Y                             ; $A7A5: 99 96 05
  STA btl_troops_a,Y                             ; $A7A8: 99 AC 05
  STA btl_roster_code_a,Y                             ; $A7AB: 99 C2 05
  INC btl_overlay_sub                               ; $A7AE: EE 41 05 ; sub-phase <- $A
.endproc
;-------------------------------------------------------------------------------
; $A7B1: Phase2DamageAnimExit - shared RTS at the tail of the eliminated
; path of Phase2AttackDamageApply, branched to by the sub 7/sub 9
; animation wait loops.
; Bare global between procs by necessity: see Phase2WalkExit ($A61C).
;-------------------------------------------------------------------------------
Phase2DamageAnimExit:
  RTS                                     ; $A7B1: 60
;===============================================================================
; $A7B2: Phase2DamageSurvived
; Survived path of Phase2AttackDamageApply: updates the damage panel,
; re-highlights the target column and advances to sub $A.
;===============================================================================
.proc Phase2DamageSurvived
  JSR Phase2DamagePanelUpdate             ; $A7B2: 20 C5 A7 ; panel damage number
  LDA #$10                                ; $A7B5: A9 10
  STA $12                                 ; $A7B7: 85 12 ; highlight
  LDA btl_target_col                               ; $A7B9: AD 4D 05 ; target column
  STA $13                                 ; $A7BC: 85 13
  JSR BattleCellRedraw                         ; $A7BE: 20 82 B8 ; column tile update
  INC btl_overlay_sub                               ; $A7C1: EE 41 05 ; sub-phase <- $A
  RTS                                     ; $A7C4: 60
.endproc
;===============================================================================
; $A7C5: Phase2DamagePanelUpdate
; Sets up the damage-number panel update: amount $00 into $0B (high byte
; $0C <- 0), overlay strip buffer pointer $0560 into $0A (or $0561 for
; cursor columns >= $0B), then submits via OfficerBattleExpLevelCheck.
;===============================================================================
.proc Phase2DamagePanelUpdate
; zero-page work cells (proc-local):
damage         = $0000  ; damage amount
writer_ptr     = $000A  ; strip writer buffer ptr ($0560/$0561)
writer_damage  = $000B  ; writer param: damage value
writer_pad     = $000C  ; writer param: 0
  LDA damage                                 ; $A7C5: A5 00 ; damage amount
  STA writer_damage                                 ; $A7C7: 85 0B
  LDA #$00                                ; $A7C9: A9 00
  STA writer_pad                                 ; $A7CB: 85 0C
  LDA btl_strip_buf_a                               ; $A7CD: AD 60 05 ; strip 0 buffer ptr
  LDY btl_scan_col                               ; $A7D0: AC 45 05 ; cursor column
  CPY #$0B                                ; $A7D3: C0 0B
  BCC @Submit                             ; $A7D5: 90 03 ; columns 0-$A
  LDA btl_strip_buf_b                               ; $A7D7: AD 61 05 ; strip 1 buffer ptr
@Submit:
  STA writer_ptr                                 ; $A7DA: 85 0A
  JSR OfficerBattleExpLevelCheck          ; $A7DC: 20 FB D7 ; exp accrual/level-up
@Done:
  RTS                                     ; $A7DF: 60
.endproc
;===============================================================================
; $A7E0: Phase2ActionDoneWait
; Sub $A: waits for $007E bit2 (action animation done); then re-highlights
; the cursor column and returns to phase 1 sub 2 (Phase1RoundPass).
;===============================================================================
.proc Phase2ActionDoneWait
  LDA a:btl_anim_flags                             ; $A7E0: AD 7E 00 ; action status
  AND #$04                                ; $A7E3: 29 04 ; done flag
  BNE @Done                               ; $A7E5: D0 16 ; not yet: wait
  LDA #$10                                ; $A7E7: A9 10
  STA $12                                 ; $A7E9: 85 12 ; highlight
  LDA btl_scan_col                               ; $A7EB: AD 45 05 ; cursor column
  STA $13                                 ; $A7EE: 85 13
  JSR BattleCellRedraw                         ; $A7F0: 20 82 B8 ; column tile update
  LDA #$01                                ; $A7F3: A9 01
  STA btl_overlay_phase                               ; $A7F5: 8D 40 05 ; phase <- 1
  LDA #$02                                ; $A7F8: A9 02
  STA btl_overlay_sub                               ; $A7FA: 8D 41 05 ; sub <- 2 (Phase1RoundPass)
@Done:
  RTS                                     ; $A7FD: 60
.endproc
;===============================================================================
; $A7FE: Phase2ColumnResetCheck
; If the cursor column holds a pending side event (command 1 with marker
; $0580[$0545] == 0 for columns 0-$A, or low nibble $F for columns >= $0B),
; un-highlights the column, returns the overlay machine to phase 1 sub 2
; (Phase1RoundPass), marks the column slots cleared ($0580/$0596 <- $FE,
; $05C2 <- $FF) and pops the caller return address so the rest of the frame
; is skipped.
;===============================================================================
.proc Phase2ColumnResetCheck
  LDY btl_scan_col                               ; $A7FE: AC 45 05 ; cursor column
  CPY #$0B                                ; $A801: C0 0B
  BCS @UpperColumns                       ; $A803: B0 0F ; columns $B-$15
  LDA btl_command                               ; $A805: AD 4F 05 ; command value
  CMP #$01                                ; $A808: C9 01
  BNE @Done                               ; $A80A: D0 40 ; not command 1
  LDA btl_unit_col_a,Y                             ; $A80C: B9 80 05 ; side event marker
  BNE @Done                               ; $A80F: D0 3B ; non-zero: keep
  JMP @ResetColumn                        ; $A811: 4C 24 A8
@UpperColumns:
  LDA btl_command                               ; $A814: AD 4F 05 ; command value
  CMP #$01                                ; $A817: C9 01
  BNE @Done                               ; $A819: D0 31 ; not command 1
  LDA btl_unit_col_a,Y                             ; $A81B: B9 80 05 ; side event marker
  AND #$0F                                ; $A81E: 29 0F
  CMP #$0F                                ; $A820: C9 0F
  BNE @Done                               ; $A822: D0 28 ; not $F: keep
@ResetColumn:
  LDA #$00                                ; $A824: A9 00
  STA $12                                 ; $A826: 85 12 ; un-highlight
  LDA btl_scan_col                               ; $A828: AD 45 05 ; cursor column
  STA $13                                 ; $A82B: 85 13
  JSR BattleCellRedraw                         ; $A82D: 20 82 B8 ; column tile update
  LDA #$01                                ; $A830: A9 01
  STA btl_overlay_phase                               ; $A832: 8D 40 05 ; phase <- 1
  LDA #$02                                ; $A835: A9 02
  STA btl_overlay_sub                               ; $A837: 8D 41 05 ; sub <- 2 (Phase1RoundPass)
  LDY btl_scan_col                               ; $A83A: AC 45 05
  LDA #$FE                                ; $A83D: A9 FE
  STA btl_unit_col_a,Y                             ; $A83F: 99 80 05 ; cleared marker
  STA btl_unit_row_a,Y                             ; $A842: 99 96 05
  LDA #$FF                                ; $A845: A9 FF
  STA btl_roster_code_a,Y                             ; $A847: 99 C2 05 ; empty roster slot
  PLA                                     ; $A84A: 68 ; drop caller return addr
  PLA                                     ; $A84B: 68
@Done:
  RTS                                     ; $A84C: 60
.endproc
;===============================================================================
; $A84D: Phase2AttackComputeDefended
; Damage compute for a defended target (column action bits == 2): saves the
; side attack values $056A/$056B, scales each to 60% via
; Phase2PercentScale, computes the damage through
; Phase2AttackDamageCompute (result in $00), then restores the original
; values.
;===============================================================================
.proc Phase2AttackComputeDefended
  LDA btl_attack_a                               ; $A84D: AD 6A 05 ; side A attack value
  PHA                                     ; $A850: 48
  LDY #$3C                                ; $A851: A0 3C ; 60 percent
  JSR Phase2PercentScale                  ; $A853: 20 CF A8
  STA btl_attack_a                               ; $A856: 8D 6A 05
  LDA btl_attack_b                               ; $A859: AD 6B 05 ; side B attack value
  PHA                                     ; $A85C: 48
  LDY #$3C                                ; $A85D: A0 3C ; 60 percent
  JSR Phase2PercentScale                  ; $A85F: 20 CF A8
  STA btl_attack_b                               ; $A862: 8D 6B 05
  JSR Phase2AttackDamageCompute           ; $A865: 20 F2 A8 ; damage -> $00
  PLA                                     ; $A868: 68
  STA btl_attack_b                               ; $A869: 8D 6B 05 ; restore
  PLA                                     ; $A86C: 68
  STA btl_attack_a                               ; $A86D: 8D 6A 05
@Done:
  RTS                                     ; $A870: 60
.endproc
;===============================================================================
; $A871: Phase2AttackComputeWithBonus
; Damage compute for the main attack: saves $056A/$056B, scales each to 70%
; via Phase2PercentScale, then - when the matching nybble of the packed
; counter $0577 (low for side A, high for side B) is set - adds a random
; bonus of 0-9 (B1F_RandomByte low nibble, capped at 100). Computes the
; damage through Phase2AttackDamageCompute and restores the originals.
;===============================================================================
.proc Phase2AttackComputeWithBonus
  LDA btl_attack_a                               ; $A871: AD 6A 05 ; side A attack value
  PHA                                     ; $A874: 48
  LDY #$46                                ; $A875: A0 46 ; 70 percent
  JSR Phase2PercentScale                  ; $A877: 20 CF A8
  STA btl_attack_a                               ; $A87A: 8D 6A 05
  LDA btl_status_ctr3                               ; $A87D: AD 77 05 ; packed bonus counter
  AND #$0F                                ; $A880: 29 0F ; side A nybble
  BEQ @ScaleSideB                         ; $A882: F0 16 ; no bonus
@BonusSideA:
  JSR B1F_RandomByte                      ; $A884: 20 7A E8
  AND #$0F                                ; $A887: 29 0F ; bonus 0-$F
  CMP #$0A                                ; $A889: C9 0A
  BCS @BonusSideA                         ; $A88B: B0 F7 ; reroll >= 10
  CLC                                     ; $A88D: 18
  ADC btl_attack_a                               ; $A88E: 6D 6A 05
  CMP #$64                                ; $A891: C9 64 ; cap 100
  BCC @StoreSideA                         ; $A893: 90 02
  LDA #$64                                ; $A895: A9 64
@StoreSideA:
  STA btl_attack_a                               ; $A897: 8D 6A 05
@ScaleSideB:
  LDA btl_attack_b                               ; $A89A: AD 6B 05 ; side B attack value
  PHA                                     ; $A89D: 48
  LDY #$46                                ; $A89E: A0 46 ; 70 percent
  JSR Phase2PercentScale                  ; $A8A0: 20 CF A8
  STA btl_attack_b                               ; $A8A3: 8D 6B 05
  LDA btl_status_ctr3                               ; $A8A6: AD 77 05 ; packed bonus counter
  AND #$F0                                ; $A8A9: 29 F0 ; side B nybble
  BEQ @Compute                            ; $A8AB: F0 16 ; no bonus
@BonusSideB:
  JSR B1F_RandomByte                      ; $A8AD: 20 7A E8
  AND #$0F                                ; $A8B0: 29 0F ; bonus 0-$F
  CMP #$0A                                ; $A8B2: C9 0A
  BCS @BonusSideB                         ; $A8B4: B0 F7 ; reroll >= 10
  CLC                                     ; $A8B6: 18
  ADC btl_attack_b                               ; $A8B7: 6D 6B 05
  CMP #$64                                ; $A8BA: C9 64 ; cap 100
  BCC @StoreSideB                         ; $A8BC: 90 02
  LDA #$64                                ; $A8BE: A9 64
@StoreSideB:
  STA btl_attack_b                               ; $A8C0: 8D 6B 05
@Compute:
  JSR Phase2AttackDamageCompute           ; $A8C3: 20 F2 A8 ; damage -> $00
  PLA                                     ; $A8C6: 68
  STA btl_attack_b                               ; $A8C7: 8D 6B 05 ; restore
  PLA                                     ; $A8CA: 68
  STA btl_attack_a                               ; $A8CB: 8D 6A 05
@Done:
  RTS                                     ; $A8CE: 60
.endproc
;===============================================================================
; $A8CF: Phase2PercentScale
; Returns A = A * Y / 100 (value in A, percent in Y) using
; B1F_MathMul24x8 + B1F_MathDiv16.
;===============================================================================
.proc Phase2PercentScale
; zero-page work cells (proc-local):
mul_value      = $0000  ; multiplicand lo (24-bit cell $0000-$0002)
dividend_lo    = $0001  ; MathDiv16 dividend lo (product byte 0)
dividend_hi    = $0002  ; dividend hi (product byte 1)
percent        = $0003  ; multiplier percent (Y param)
divisor_lo     = $0003  ; MathDiv16 divisor lo (= 100)
divisor_hi     = $0004  ; divisor hi (0)
product_lo     = $0006  ; MathMul24x8 product byte 0
product_hi     = $0007  ; product byte 1
  STY percent                                 ; $A8CF: 84 03 ; percent
  STA mul_value                                 ; $A8D1: 85 00 ; value
  LDA #$00                                ; $A8D3: A9 00
  STA dividend_lo                                 ; $A8D5: 85 01
  STA dividend_hi                                 ; $A8D7: 85 02
  JSR B1F_MathMul24x8                     ; $A8D9: 20 E9 EB ; value * percent
  LDA product_lo                                 ; $A8DC: A5 06
  STA dividend_lo                                 ; $A8DE: 85 01
  LDA product_hi                                 ; $A8E0: A5 07
  STA dividend_hi                                 ; $A8E2: 85 02
  LDA #$64                                ; $A8E4: A9 64 ; divisor 100
  STA divisor_lo                                 ; $A8E6: 85 03
  LDA #$00                                ; $A8E8: A9 00
  STA divisor_hi                                 ; $A8EA: 85 04
  JSR B1F_MathDiv16                       ; $A8EC: 20 7C EA ; / 100
  LDA dividend_lo                                 ; $A8EF: A5 01 ; quotient low
@Done:
  RTS                                     ; $A8F1: 60
.endproc
;===============================================================================
; $A8F2: Phase2AttackDamageCompute
; Core damage computation, result in $00. Base value = side attack value
; $056A (cursor column < $0B, plus bonus $0570 when column 0) or $056B
; (columns >= $0B, plus bonus $0571 when column $0B), scaled by a tier
; percentage chosen from the target troop count $05AC[$0545] (tier table 20/40/50/
; 70/85/95/100 for troop count < 15/35/60/80/90/100). Then an adjustment keyed on
; index column $054A: edge columns 0/$0B subtract the defense value
; $056E/$056F from half the damage (floor 0); a column whose action bits
; are 1 scales the damage to 3/4.
;===============================================================================
.proc Phase2AttackDamageCompute
; zero-page work cells (proc-local):
damage         = $0000  ; damage work value (result)
dividend_lo    = $0001  ; MathDiv16 dividend lo
dividend_hi    = $0002  ; dividend hi
percent        = $0003  ; tier percent (Y param)
divisor_lo     = $0003  ; divisor lo
divisor_hi     = $0004  ; divisor hi (0)
product_lo     = $0006  ; MathMul24x8 product byte 0
product_hi     = $0007  ; product byte 1
  LDY btl_scan_col                               ; $A8F2: AC 45 05 ; cursor column
  CPY #$0B                                ; $A8F5: C0 0B
  BCS @SideBBase                          ; $A8F7: B0 0E ; columns $B-$15
  LDA btl_attack_a                               ; $A8F9: AD 6A 05 ; side A attack value
  CPY #$00                                ; $A8FC: C0 00
  BNE @ScaleByTier                        ; $A8FE: D0 15
  CLC                                     ; $A900: 18
  ADC btl_edge_bonus_a                               ; $A901: 6D 70 05 ; column-0 bonus
  JMP @ScaleByTier                        ; $A904: 4C 15 A9
@SideBBase:
  LDA btl_attack_b                               ; $A907: AD 6B 05 ; side B attack value
  CPY #$0B                                ; $A90A: C0 0B
  BNE @ScaleByTier                        ; $A90C: D0 07
  CLC                                     ; $A90E: 18
  ADC btl_edge_bonus_b                               ; $A90F: 6D 71 05 ; column-$B bonus
  JMP @ScaleByTier                        ; $A912: 4C 15 A9 ; redundant jump (ROM artifact)
@ScaleByTier:
  PHA                                     ; $A915: 48 ; base attack value
  LDA btl_troops_a,Y                             ; $A916: B9 AC 05 ; target troop count
  LDY #$14                                ; $A919: A0 14 ; 20 percent
  CMP #$0F                                ; $A91B: C9 0F
  BCC @DoScale                            ; $A91D: 90 20 ; troop count < 15
  LDY #$28                                ; $A91F: A0 28 ; 40 percent
  CMP #$23                                ; $A921: C9 23
  BCC @DoScale                            ; $A923: 90 1A ; troop count < 35
  LDY #$32                                ; $A925: A0 32 ; 50 percent
  CMP #$3C                                ; $A927: C9 3C
  BCC @DoScale                            ; $A929: 90 14 ; troop count < 60
  LDY #$46                                ; $A92B: A0 46 ; 70 percent
  CMP #$50                                ; $A92D: C9 50
  BCC @DoScale                            ; $A92F: 90 0E ; troop count < 80
  LDY #$55                                ; $A931: A0 55 ; 85 percent
  CMP #$5A                                ; $A933: C9 5A
  BCC @DoScale                            ; $A935: 90 08 ; troop count < 90
  LDY #$5F                                ; $A937: A0 5F ; 95 percent
  CMP #$64                                ; $A939: C9 64
  BCC @DoScale                            ; $A93B: 90 02 ; troop count < 100
  LDY #$64                                ; $A93D: A0 64 ; 100 percent
@DoScale:
  STY percent                                 ; $A93F: 84 03 ; tier percent
  PLA                                     ; $A941: 68 ; base attack value
  STA damage                                 ; $A942: 85 00
  LDA #$00                                ; $A944: A9 00
  STA dividend_lo                                 ; $A946: 85 01
  STA dividend_hi                                 ; $A948: 85 02
  JSR B1F_MathMul24x8                     ; $A94A: 20 E9 EB ; base * tier
  LDA product_lo                                 ; $A94D: A5 06
  STA dividend_lo                                 ; $A94F: 85 01
  LDA product_hi                                 ; $A951: A5 07
  STA dividend_hi                                 ; $A953: 85 02
  LDA #$64                                ; $A955: A9 64 ; divisor 100
  STA divisor_lo                                 ; $A957: 85 03
  LDA #$00                                ; $A959: A9 00
  STA divisor_hi                                 ; $A95B: 85 04
  JSR B1F_MathDiv16                       ; $A95D: 20 7C EA ; / 100
  LDA dividend_lo                                 ; $A960: A5 01 ; scaled damage
  STA damage                                 ; $A962: 85 00
  LDY btl_walk_row                               ; $A964: AC 4A 05 ; index column
  BEQ @EdgeColumnAdjust                   ; $A967: F0 10 ; column 0
  CPY #$0B                                ; $A969: C0 0B
  BEQ @EdgeColumnAdjust                   ; $A96B: F0 0C ; column $B
  LDA btl_roster_code_a,Y                             ; $A96D: B9 C2 05 ; column status
  AND #$0F                                ; $A970: 29 0F ; action bits
  CMP #$01                                ; $A972: C9 01
  BEQ @CounterAdjust                      ; $A974: F0 1E ; bits 1: x3/4
  JMP @Done                               ; $A976: 4C 9F A9 ; else: keep
@EdgeColumnAdjust:
  LDA damage                                 ; $A979: A5 00 ; scaled damage
  LSR                                     ; $A97B: 4A ; / 2
  PHA                                     ; $A97C: 48
  LDA btl_defense_a                               ; $A97D: AD 6E 05 ; defense value A
  CPY #$0B                                ; $A980: C0 0B
  BCC @SubtractDefense                    ; $A982: 90 03
  LDA btl_defense_b                               ; $A984: AD 6F 05 ; defense value B
@SubtractDefense:
  STA damage                                 ; $A987: 85 00
  PLA                                     ; $A989: 68 ; damage / 2
  SEC                                     ; $A98A: 38
  SBC damage                                 ; $A98B: E5 00 ; - defense
  BCS @Store                              ; $A98D: B0 0E ; no underflow
  LDA #$00                                ; $A98F: A9 00 ; floor 0
  JMP @Store                              ; $A991: 4C 9D A9
@CounterAdjust:
  LDA damage                                 ; $A994: A5 00 ; scaled damage
  LSR                                     ; $A996: 4A ; / 2
  STA damage                                 ; $A997: 85 00
  LSR                                     ; $A999: 4A ; / 4
  CLC                                     ; $A99A: 18
  ADC damage                                 ; $A99B: 65 00 ; dmg/2 + dmg/4
@Store:
  STA damage                                 ; $A99D: 85 00 ; final damage
@Done:
  RTS                                     ; $A99F: 60
.endproc
;===============================================================================
; $A9A0: Phase2CursorStep
; Steps the walk position ($054A column / $054B row) one cell per the
; acting side $0549: 0 -> row--, 1 -> row++, 2 -> column--, 3 -> column++.
;===============================================================================
.proc Phase2CursorStep
  LDA btl_acting_unit                               ; $A9A0: AD 49 05 ; acting side
  BNE @Side1                              ; $A9A3: D0 04
  DEC btl_walk_col                               ; $A9A5: CE 4B 05 ; row--
@Done:
  RTS                                     ; $A9A8: 60
@Side1:
  CMP #$01                                ; $A9A9: C9 01
  BNE @Side2                              ; $A9AB: D0 04
  INC btl_walk_col                               ; $A9AD: EE 4B 05 ; row++
  RTS                                     ; $A9B0: 60
@Side2:
  CMP #$02                                ; $A9B1: C9 02
  BNE @Side3                              ; $A9B3: D0 04
  DEC btl_walk_row                               ; $A9B5: CE 4A 05 ; column--
  RTS                                     ; $A9B8: 60
@Side3:
  INC btl_walk_row                               ; $A9B9: EE 4A 05 ; column++
  RTS                                     ; $A9BC: 60
.endproc
;===============================================================================
; $A9BD: Phase2CommitMarkerAdjust
; Commits the walk into the acting column's row markers, per acting side
; $0549: 0 -> $0596[X]--, 1 -> $0596[X]++, 2 -> $0580[X]--, 3 -> $0580[X]++
; (X = cursor column $0545).
;===============================================================================
.proc Phase2CommitMarkerAdjust
  LDA btl_acting_unit                               ; $A9BD: AD 49 05 ; acting side
  BNE @Side1                              ; $A9C0: D0 07
  LDX btl_scan_col                               ; $A9C2: AE 45 05 ; cursor column
  DEC btl_unit_row_a,X                             ; $A9C5: DE 96 05 ; marker--
@Done:
  RTS                                     ; $A9C8: 60
@Side1:
  CMP #$01                                ; $A9C9: C9 01
  BNE @Side2                              ; $A9CB: D0 07
  LDX btl_scan_col                               ; $A9CD: AE 45 05
  INC btl_unit_row_a,X                             ; $A9D0: FE 96 05 ; marker++
  RTS                                     ; $A9D3: 60
@Side2:
  CMP #$02                                ; $A9D4: C9 02
  BNE @Side3                              ; $A9D6: D0 07
  LDX btl_scan_col                               ; $A9D8: AE 45 05
  DEC btl_unit_col_a,X                             ; $A9DB: DE 80 05 ; marker--
  RTS                                     ; $A9DE: 60
@Side3:
  LDX btl_scan_col                               ; $A9DF: AE 45 05
  INC btl_unit_col_a,X                             ; $A9E2: FE 80 05 ; marker++
  RTS                                     ; $A9E5: 60
.endproc
;===============================================================================
; $A9E6: Phase2CursorStepFast
; Double step variant of Phase2CursorStep (two cells per call), used by the
; attack arrow animation.
;===============================================================================
.proc Phase2CursorStepFast
  LDA btl_acting_unit                               ; $A9E6: AD 49 05 ; acting side
  BNE @Side1                              ; $A9E9: D0 07
  DEC btl_walk_col                               ; $A9EB: CE 4B 05 ; row -= 2
  DEC btl_walk_col                               ; $A9EE: CE 4B 05
@Done:
  RTS                                     ; $A9F1: 60
@Side1:
  CMP #$01                                ; $A9F2: C9 01
  BNE @Side2                              ; $A9F4: D0 07
  INC btl_walk_col                               ; $A9F6: EE 4B 05 ; row += 2
  INC btl_walk_col                               ; $A9F9: EE 4B 05
  RTS                                     ; $A9FC: 60
@Side2:
  CMP #$02                                ; $A9FD: C9 02
  BNE @Side3                              ; $A9FF: D0 07
  DEC btl_walk_row                               ; $AA01: CE 4A 05 ; column -= 2
  DEC btl_walk_row                               ; $AA04: CE 4A 05
  RTS                                     ; $AA07: 60
@Side3:
  INC btl_walk_row                               ; $AA08: EE 4A 05 ; column += 2
  INC btl_walk_row                               ; $AA0B: EE 4A 05
  RTS                                     ; $AA0E: 60
.endproc
;===============================================================================
; $AA0F: Phase2ColumnStatusEncode
; Encodes the acting unit id (A) into the high nibble of the cursor
; column's roster status $05C2[$0545], preserving the low nibble (action
; bits).
;===============================================================================
.proc Phase2ColumnStatusEncode
; zero-page work cells (proc-local):
status_work    = $0000  ; column status/id work byte
  ASL                                     ; $AA0F: 0A ; id << 4
  ASL                                     ; $AA10: 0A
  ASL                                     ; $AA11: 0A
  ASL                                     ; $AA12: 0A
  STA status_work                                 ; $AA13: 85 00
  LDY btl_scan_col                               ; $AA15: AC 45 05 ; cursor column
  LDA btl_roster_code_a,Y                             ; $AA18: B9 C2 05 ; column status
  AND #$0F                                ; $AA1B: 29 0F ; keep action bits
  ORA status_work                                 ; $AA1D: 05 00 ; merge id
  STA btl_roster_code_a,Y                             ; $AA1F: 99 C2 05
@Done:
  RTS                                     ; $AA22: 60
.endproc
;===============================================================================
; $AA23: Phase3CommandSubDispatch
; Phase 3 (acting-unit command selection), entered from Phase1NextActorSelect
; on a queued player request (handoff flags $0568/$0569) with $0549 = acting
; side and the resume latch $054B/$054C <- 1/1. First redraws the acting
; side's overlay strip via a banked call into bank $19 (buffer ptr lo from
; $0560[$0549], X=0), then dispatches on $0541 via B1F_CallbackDispatcher
; through the inline 5-entry sub table ($AA40):
;   sub 0 Phase3CommandPanelInit   - command panel field setup
;   sub 1 Phase3CommandAnimStep    - marker step animation + officer display re-render
;   sub 2 Phase3CommandInput       - player command input (A/B/directions)
;   sub 3 Phase3CommandConfirmWait - confirm panel reformat wait
;   sub 4 Phase3CommandResultWait  - result strip reformat, then resumes the
;                                    latched phase/sub at $054B/$054C
;===============================================================================
.proc Phase3CommandSubDispatch
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; overlay strip render buffer ptr lo
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
  LDY btl_acting_unit                               ; $AA23: AC 49 05 ; acting side
  LDA btl_strip_buf_a,Y                             ; $AA26: B9 60 05 ; strip buffer ptr lo
  STA a:strip_ptr_lo                             ; $AA29: 8D 00 00
  LDA #$A5                                ; $AA2C: A9 A5 ; ptr hi
  STA a:strip_ptr_hi                             ; $AA2E: 8D 0A 00
  LDX #$00                                ; $AA31: A2 00 ; strip 0
  LDY #$39                                ; $AA33: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $AA35: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $AA38: 00 A0 ; B19_OverlayStripRender_Entry
  LDA btl_overlay_sub                               ; $AA3A: AD 41 05 ; sub-phase
  JSR B1F_CallbackDispatcher              ; $AA3D: 20 DE EA
; --- CallbackDispatcher sub table, indexed by $0541 ---
  .word Phase3CommandPanelInit            ; $AA40: 4A AA ; sub 0 ($AA4A)
  .word Phase3CommandAnimStep             ; $AA42: BD AA ; sub 1 ($AABD)
  .word Phase3CommandInput                ; $AA44: F0 AA ; sub 2 ($AAF0)
  .word Phase3CommandConfirmWait          ; $AA46: 75 AB ; sub 3 ($AB75)
  .word Phase3CommandResultWait           ; $AA48: 9A AB ; sub 4 ($AB9A)
.endproc
;===============================================================================
; $AA4A: Phase3CommandPanelInit
; Sub 0. Advances to sub 1, clears the menu step $0548 and $054A, sets UI
; mode $D1 (B1F_SetUI0) and resolves the acting unit id $0560[$0549] to its
; officer record pointer ($00) via B1F_GetOfficerRecordAddr. Then fills the
; command panel field block $044C-$0457: base value = column-0 troop count of
; side A ($05AC) or side B ($05B7) per acting side, overridden from record
; field [0] unless the resume latch $054B == 1; record fields [2]/[1]/[3]
; go to $044F/$0452/$0455, and field [3] == 100 forces $0457 <- $FE. Panel
; param $00BD <- 6.
;===============================================================================
.proc Phase3CommandPanelInit
; zero-page work cells (proc-local):
rec_ptr_lo     = $0000  ; officer record ptr lo (hi in $0001)
  INC btl_overlay_sub                               ; $AA4A: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $AA4D: A9 00
  STA btl_frame_counter                               ; $AA4F: 8D 48 05 ; menu step <- 0
  STA btl_walk_row                               ; $AA52: 8D 4A 05
  LDA #$D1                                ; $AA55: A9 D1
  JSR B1F_SetUI0                          ; $AA57: 20 6D F2 ; UI mode
  LDY btl_acting_unit                               ; $AA5A: AC 49 05 ; acting side
  LDA btl_strip_buf_a,Y                             ; $AA5D: B9 60 05 ; acting unit id
  JSR B1F_GetOfficerRecordAddr            ; $AA60: 20 D7 F2 ; record ptr -> ($00)
  LDA btl_troops_a                               ; $AA63: AD AC 05 ; side A column-0 troop count
  LDY btl_acting_unit                               ; $AA66: AC 49 05
  BEQ @StoreTotal                         ; $AA69: F0 03
  LDA btl_troops_b                               ; $AA6B: AD B7 05 ; side B column-0 troop count
@StoreTotal:
  STA btl_panel_fields                               ; $AA6E: 8D 4C 04 ; panel base value
  LDX btl_walk_col                               ; $AA71: AE 4B 05 ; resume latch phase
  CPX #$01                                ; $AA74: E0 01
  BEQ @FieldCopy                          ; $AA76: F0 07 ; latch 1: keep total
  LDY #$00                                ; $AA78: A0 00
  LDA (rec_ptr_lo),Y                             ; $AA7A: B1 00 ; record field [0]
  STA btl_panel_fields                               ; $AA7C: 8D 4C 04 ; override base value
@FieldCopy:
  LDY #$02                                ; $AA7F: A0 02
  LDA (rec_ptr_lo),Y                             ; $AA81: B1 00 ; record field [2]
  STA btl_panel_fields+$3                               ; $AA83: 8D 4F 04
  LDY #$01                                ; $AA86: A0 01
  LDA (rec_ptr_lo),Y                             ; $AA88: B1 00 ; record field [1]
  STA btl_panel_fields+$6                               ; $AA8A: 8D 52 04
  LDA #$00                                ; $AA8D: A9 00
  STA btl_panel_fields+$1                               ; $AA8F: 8D 4D 04 ; clear field ext bytes
  STA btl_panel_fields+$2                               ; $AA92: 8D 4E 04
  STA btl_panel_fields+$4                               ; $AA95: 8D 50 04
  STA btl_panel_fields+$5                               ; $AA98: 8D 51 04
  STA btl_panel_fields+$7                               ; $AA9B: 8D 53 04
  STA btl_panel_fields+$8                               ; $AA9E: 8D 54 04
  STA btl_panel_fields+$A                               ; $AAA1: 8D 56 04
  STA btl_panel_fields+$B                               ; $AAA4: 8D 57 04
  LDY #$03                                ; $AAA7: A0 03
  LDA (rec_ptr_lo),Y                             ; $AAA9: B1 00 ; record field [3]
  STA btl_panel_fields+$9                               ; $AAAB: 8D 55 04
  CMP #$64                                ; $AAAE: C9 64 ; full 100
  BNE @SetPanelParam                      ; $AAB0: D0 05
  LDA #$FE                                ; $AAB2: A9 FE
  STA btl_panel_fields+$B                               ; $AAB4: 8D 57 04 ; full-troop-count marker
@SetPanelParam:
  LDA #$06                                ; $AAB7: A9 06
  STA a:zp_panel_param_c                             ; $AAB9: 8D BD 00 ; panel param
  RTS                                     ; $AABC: 60
.endproc
;===============================================================================
; $AABD: Phase3CommandAnimStep
; Sub 1. Waits while the animation queue is busy (BattleAnimQueueIdleCheck carry clear) or
; input flag $007E bit2 is set (both wait paths exit at the trailing RTS).
; Otherwise, per frame, refreshes the target marker
; (Phase3CommandMarkerUpdate) and counts the menu step $0548 up to 4;
; then advances to sub 2, resets $0548 and banked-calls
; B1D_1E_OfficerDisplay_Render (Y=$3D) with buffer ptr $0000 <-
; $0560[$0549] to re-render the officer display.
;===============================================================================
.proc Phase3CommandAnimStep
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; officer display render buffer ptr lo
  JSR BattleAnimQueueIdleCheck                 ; $AABD: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AAC0: 90 2D ; still busy: wait
  LDA a:btl_anim_flags                             ; $AAC2: AD 7E 00
  AND #$04                                ; $AAC5: 29 04
  BNE @Done                               ; $AAC7: D0 26 ; input busy: wait
  LDA btl_frame_counter                               ; $AAC9: AD 48 05 ; menu step
  CMP #$04                                ; $AACC: C9 04
  BCS @Advance                            ; $AACE: B0 07 ; animation done
  JSR Phase3CommandMarkerUpdate           ; $AAD0: 20 A8 AC ; marker step
  INC btl_frame_counter                               ; $AAD3: EE 48 05 ; step++
  RTS                                     ; $AAD6: 60
@Advance:
  INC btl_overlay_sub                               ; $AAD7: EE 41 05 ; sub-phase <- 2
  LDA #$00                                ; $AADA: A9 00
  STA btl_frame_counter                               ; $AADC: 8D 48 05 ; menu step <- 0
  LDY btl_acting_unit                               ; $AADF: AC 49 05 ; acting side
  LDA btl_strip_buf_a,Y                             ; $AAE2: B9 60 05 ; strip buffer ptr lo
  STA a:strip_ptr_lo                             ; $AAE5: 8D 00 00
  LDY #$3D                                ; $AAE8: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $AAEA: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_OfficerDisplay_Render      ; $AAED: 30 A0
@Done:
  RTS                                     ; $AAEF: 60
.endproc
;===============================================================================
; $AAF0: Phase3CommandInput
; Sub 2. Player command input for the acting side $0549 (pad state via
; BattlePadStateFetch; AI-controlled sides get zeros). B (raw bit1) toggles
; battle flag $008F. A (raw bit0) resolves the current action slot
; $0550[$0549*4+$0548]: slot value 4 with no pending side status counters
; $0574-$0577 (own side's nibble clear) commits straight to phase 8 sub 0
; with the slot <- 2; any other value advances to sub 3, queueing the
; $E8/$E9 tile animation ($0310/$0311, slot $0300=0) and refreshing the
; panel troop-count block (BattlePanelStatsRefresh) when the
; resume latch $054B == 1 (player-request entry), else handing control off
; at Phase3CommandResultWait::Phase3CommandResumeHandoff. Every frame also
; runs Phase3CommandDirInput + Phase3CommandArrowDraw.
;===============================================================================
.proc Phase3CommandInput
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
  LDA btl_acting_unit                               ; $AAF0: AD 49 05 ; acting side
  JSR BattlePadStateFetch                 ; $AAF3: 20 DE CC
  LDA a:pad_state                             ; $AAF6: AD 01 00 ; pad raw state
  AND #$02                                ; $AAF9: 29 02 ; B button
  BEQ @ACheck                             ; $AAFB: F0 08
  LDA a:btl_battle_flag                             ; $AAFD: AD 8F 00 ; battle flag
  EOR #$01                                ; $AB00: 49 01
  STA a:btl_battle_flag                             ; $AB02: 8D 8F 00 ; toggle
@ACheck:
  LDA btl_acting_unit                               ; $AB05: AD 49 05
  JSR BattlePadStateFetch                 ; $AB08: 20 DE CC
  LDA a:pad_state                             ; $AB0B: AD 01 00
  AND #$01                                ; $AB0E: 29 01 ; A button
  BEQ @FrameUpdate                        ; $AB10: F0 5C ; no A: per-frame path
  LDA btl_acting_unit                               ; $AB12: AD 49 05
  ASL                                     ; $AB15: 0A
  ASL                                     ; $AB16: 0A
  TAY                                     ; $AB17: A8 ; Y = side * 4
  LDA btl_order_slots_a,Y                             ; $AB18: B9 50 05 ; step-0 action slot
  CMP #$04                                ; $AB1B: C9 04
  BNE @ConfirmAnim                        ; $AB1D: D0 32 ; slot != 4
  LDA btl_status_ctr0                               ; $AB1F: AD 74 05 ; side status counters
  ORA btl_status_ctr1                               ; $AB22: 0D 75 05
  ORA btl_status_ctr2                               ; $AB25: 0D 76 05
  ORA btl_status_ctr3                               ; $AB28: 0D 77 05
  LDY btl_acting_unit                               ; $AB2B: AC 49 05 ; acting side
  BEQ @SideANibble                        ; $AB2E: F0 07
  AND #$F0                                ; $AB30: 29 F0 ; side B nibble
  BNE @FrameUpdate                        ; $AB32: D0 3A ; counters pending
  JMP @Commit                             ; $AB34: 4C 3B AB
@SideANibble:
  AND #$0F                                ; $AB37: 29 0F ; side A nibble
  BNE @FrameUpdate                        ; $AB39: D0 33 ; counters pending
@Commit:
  LDA #$08                                ; $AB3B: A9 08
  STA btl_overlay_phase                               ; $AB3D: 8D 40 05 ; phase <- 8
  LDA #$00                                ; $AB40: A9 00
  STA btl_overlay_sub                               ; $AB42: 8D 41 05 ; sub-phase <- 0
  LDA btl_acting_unit                               ; $AB45: AD 49 05
  ASL                                     ; $AB48: 0A
  ASL                                     ; $AB49: 0A
  TAY                                     ; $AB4A: A8
  LDA #$02                                ; $AB4B: A9 02
  STA btl_order_slots_a,Y                             ; $AB4D: 99 50 05 ; slot <- 2
  RTS                                     ; $AB50: 60
@ConfirmAnim:
  INC btl_overlay_sub                               ; $AB51: EE 41 05 ; sub-phase <- 3
  LDA btl_walk_col                               ; $AB54: AD 4B 05 ; resume latch phase
  CMP #$01                                ; $AB57: C9 01
  BNE Phase3CommandResumeHandoff          ; $AB59: D0 56 ; hand off
  LDA #$E8                                ; $AB5B: A9 E8
  STA anim_queue_id0_lo                               ; $AB5D: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AB60: A9 E9
  STA anim_queue_id0_hi                               ; $AB62: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AB65: A9 00
  STA anim_queue_hdr0                               ; $AB67: 8D 00 03 ; anim slot 0
  JSR BattlePanelStatsRefresh           ; $AB6A: 20 F1 CB ; refresh panel stats
  RTS                                     ; $AB6D: 60
@FrameUpdate:
  JSR Phase3CommandDirInput               ; $AB6E: 20 C3 AB ; direction buttons
  JSR Phase3CommandArrowDraw              ; $AB71: 20 73 AC ; arrow sprite
  RTS                                     ; $AB74: 60
.endproc
;===============================================================================
; $AB75: Phase3CommandConfirmWait
; Sub 3. Sets panel param $00BD <- 6 and waits for the animation queue to
; idle (BattleAnimQueueIdleCheck carry clear); then sets panel param $00BB <- 9 and
; banked-calls B1D_1E_DataFormatter (Y=$3D) with buffer ptr ($0000) <-
; $0560/0 to reformat the confirm panel, advancing to sub 4.
;===============================================================================
.proc Phase3CommandConfirmWait
; zero-page work cells (proc-local):
buf_ptr_lo     = $0000  ; panel reformat buffer ptr lo
buf_ptr_hi     = $0001  ; buffer ptr hi
  LDA #$06                                ; $AB75: A9 06
  STA a:zp_panel_param_c                             ; $AB77: 8D BD 00 ; panel param
  JSR BattleAnimQueueIdleCheck                 ; $AB7A: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AB7D: 90 1A ; still busy: wait
  LDA #$09                                ; $AB7F: A9 09
  STA a:zp_panel_param_a                             ; $AB81: 8D BB 00 ; panel param
  LDA btl_strip_buf_a                               ; $AB84: AD 60 05 ; strip 0 buffer ptr lo
  STA a:buf_ptr_lo                             ; $AB87: 8D 00 00
  LDA #$00                                ; $AB8A: A9 00
  STA a:buf_ptr_hi                             ; $AB8C: 8D 01 00 ; ptr hi
  LDY #$3D                                ; $AB8F: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $AB91: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $AB94: 3C A0
  INC btl_overlay_sub                               ; $AB96: EE 41 05 ; sub-phase <- 4
@Done:
  RTS                                     ; $AB99: 60
.endproc
;===============================================================================
; $AB9A: Phase3CommandResultWait
; Sub 4. Waits while input flag $007E is set; then banked-calls
; B1D_1E_DataFormatter (Y=$3D) with buffer ptr ($0000) <- $0561/1 to
; reformat the result strip and falls through into
; Phase3CommandResumeHandoff. That path is also entered directly from
; Phase3CommandInput's confirm branch: it clears battle flag $008F and
; resumes the latched phase/sub-phase from $054B/$054C (player-request
; entry latches 1/1, returning to Phase1NextActorSelect sub 1).
;===============================================================================
.proc Phase3CommandResultWait
; zero-page work cells (proc-local):
buf_ptr_lo     = $0000  ; result strip reformat buffer ptr lo
buf_ptr_hi     = $0001  ; buffer ptr hi
  LDA a:btl_anim_flags                             ; $AB9A: AD 7E 00 ; input busy flag
  BNE Phase3CommandResultDone             ; $AB9D: D0 23 ; still busy: wait
  LDA btl_strip_buf_b                               ; $AB9F: AD 61 05 ; strip 1 buffer ptr lo
  STA a:buf_ptr_lo                             ; $ABA2: 8D 00 00
  LDA #$01                                ; $ABA5: A9 01
  STA a:buf_ptr_hi                             ; $ABA7: 8D 01 00 ; ptr hi
  LDY #$3D                                ; $ABAA: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $ABAC: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $ABAF: 3C A0
.endproc
; Resume handoff: fall-through tail of Phase3CommandResultWait, also entered
; directly from Phase3CommandInput's confirm branch.
Phase3CommandResumeHandoff:
  LDA #$00                                ; $ABB1: A9 00
  STA a:btl_battle_flag                             ; $ABB3: 8D 8F 00 ; battle flag <- 0
  LDA btl_walk_col                               ; $ABB6: AD 4B 05 ; resume latch phase
  STA btl_overlay_phase                               ; $ABB9: 8D 40 05
  LDA btl_recorded_status                               ; $ABBC: AD 4C 05 ; resume latch sub-phase
  STA btl_overlay_sub                               ; $ABBF: 8D 41 05
Phase3CommandResultDone:
  RTS                                     ; $ABC2: 60
;===============================================================================
; $ABC3: Phase3CommandDirInput
; Direction-button handler for the phase-3 command menu (acting side $0549,
; pad raw bits via BattlePadStateFetch): right $80 / left $40 adjust the
; action slot value $0550[$0549*4+$0548], down $20 / up $10 cycle the menu
; step $0548 through 0-3. Slot values run 0-3, extended to 4/5 at step 0
; while the resume latch $054B == 1 (player-request entry): right underflow
; wraps to 4 there (else 3), left caps at 5 there (else 4, wrapping to 0).
; Any change refreshes the marker via Phase3CommandMarkerUpdate.
;===============================================================================
.proc Phase3CommandDirInput
; zero-page work cells (proc-local):
step_cap       = $0000  ; cursor step cap index
pad_state      = $0001  ; merged both-pad raw state
  LDA btl_acting_unit                               ; $ABC3: AD 49 05 ; acting side
  JSR BattlePadStateFetch                 ; $ABC6: 20 DE CC
  LDA a:pad_state                             ; $ABC9: AD 01 00 ; pad raw state
  AND #$80                                ; $ABCC: 29 80 ; right
  BEQ @LeftPress                          ; $ABCE: F0 2A
  LDA btl_acting_unit                               ; $ABD0: AD 49 05
  ASL                                     ; $ABD3: 0A
  ASL                                     ; $ABD4: 0A
  ORA btl_frame_counter                               ; $ABD5: 0D 48 05 ; + menu step
  TAY                                     ; $ABD8: A8 ; slot index
  LDA btl_order_slots_a,Y                             ; $ABD9: B9 50 05 ; action slot value
  SEC                                     ; $ABDC: 38
  SBC #$01                                ; $ABDD: E9 01 ; value--
  BCS @StoreSlot                          ; $ABDF: B0 13 ; no underflow
  LDA #$03                                ; $ABE1: A9 03 ; default wrap
  CPY #$00                                ; $ABE3: C0 00 ; side A step 0
  BEQ @UnderflowLatchCheck                ; $ABE5: F0 04
  CPY #$04                                ; $ABE7: C0 04 ; side B step 0
  BNE @StoreSlot                          ; $ABE9: D0 09
@UnderflowLatchCheck:
  LDX btl_walk_col                               ; $ABEB: AE 4B 05 ; resume latch phase
  CPX #$01                                ; $ABEE: E0 01
  BNE @StoreSlot                          ; $ABF0: D0 02
  LDA #$04                                ; $ABF2: A9 04 ; extended wrap
@StoreSlot:
  STA btl_order_slots_a,Y                             ; $ABF4: 99 50 05
  JMP @MarkerUpdate                       ; $ABF7: 4C 6F AC
@LeftPress:
  LDA btl_acting_unit                               ; $ABFA: AD 49 05
  JSR BattlePadStateFetch                 ; $ABFD: 20 DE CC
  LDA a:pad_state                             ; $AC00: AD 01 00
  AND #$40                                ; $AC03: 29 40 ; left
  BEQ @DownPress                          ; $AC05: F0 32
  LDA btl_acting_unit                               ; $AC07: AD 49 05
  ASL                                     ; $AC0A: 0A
  ASL                                     ; $AC0B: 0A
  ORA btl_frame_counter                               ; $AC0C: 0D 48 05 ; + menu step
  TAY                                     ; $AC0F: A8 ; slot index
  LDA #$04                                ; $AC10: A9 04 ; default cap
  CPY #$00                                ; $AC12: C0 00 ; side A step 0
  BEQ @CapLatchCheck                      ; $AC14: F0 04
  CPY #$04                                ; $AC16: C0 04 ; side B step 0
  BNE @CapValue                           ; $AC18: D0 09
@CapLatchCheck:
  LDX btl_walk_col                               ; $AC1A: AE 4B 05 ; resume latch phase
  CPX #$01                                ; $AC1D: E0 01
  BNE @CapValue                           ; $AC1F: D0 02
  LDA #$05                                ; $AC21: A9 05 ; extended cap
@CapValue:
  STA a:step_cap                             ; $AC23: 8D 00 00 ; cap
  LDA btl_order_slots_a,Y                             ; $AC26: B9 50 05 ; action slot value
  CLC                                     ; $AC29: 18
  ADC #$01                                ; $AC2A: 69 01 ; value++
  CMP a:step_cap                             ; $AC2C: CD 00 00
  BCC @StoreSlot2                         ; $AC2F: 90 02 ; below cap
  LDA #$00                                ; $AC31: A9 00 ; wrap to 0
@StoreSlot2:
  STA btl_order_slots_a,Y                             ; $AC33: 99 50 05
  JMP @MarkerUpdate                       ; $AC36: 4C 6F AC
@DownPress:
  LDA btl_acting_unit                               ; $AC39: AD 49 05
  JSR BattlePadStateFetch                 ; $AC3C: 20 DE CC
  LDA a:pad_state                             ; $AC3F: AD 01 00
  AND #$20                                ; $AC42: 29 20 ; down
  BEQ @UpPress                            ; $AC44: F0 12
  INC btl_frame_counter                               ; $AC46: EE 48 05 ; menu step++
  LDA btl_frame_counter                               ; $AC49: AD 48 05
  CMP #$04                                ; $AC4C: C9 04
  BCC @StepChanged                        ; $AC4E: 90 05 ; steps 0-3
  LDA #$00                                ; $AC50: A9 00
  STA btl_frame_counter                               ; $AC52: 8D 48 05 ; wrap 4 -> 0
@StepChanged:
  JMP @MarkerUpdate                       ; $AC55: 4C 6F AC
@UpPress:
  LDA btl_acting_unit                               ; $AC58: AD 49 05
  JSR BattlePadStateFetch                 ; $AC5B: 20 DE CC
  LDA a:pad_state                             ; $AC5E: AD 01 00
  AND #$10                                ; $AC61: 29 10 ; up
  BEQ @Done                               ; $AC63: F0 0D ; no button
  DEC btl_frame_counter                               ; $AC65: CE 48 05 ; menu step--
  BPL @MarkerUpdate                       ; $AC68: 10 05 ; steps 0-3
  LDA #$03                                ; $AC6A: A9 03
  STA btl_frame_counter                               ; $AC6C: 8D 48 05 ; wrap <0 -> 3
@MarkerUpdate:
  JSR Phase3CommandMarkerUpdate           ; $AC6F: 20 A8 AC
@Done:
  RTS                                     ; $AC72: 60
.endproc
;===============================================================================
; $AC73: Phase3CommandArrowDraw
; Submits the command-menu selection arrow sprite for the current menu step
; $0548: table pointer ($0000) <- Phase3CommandArrowTiles, tile id from the
; step table, row param $000C <- $80, direct placement through
; B1F_SpriteOamWriterSimple (tail call).
;===============================================================================
.proc Phase3CommandArrowDraw
; zero-page work cells (proc-local):
table_ptr_lo   = $0000  ; arrow table ptr lo
table_ptr_hi   = $0001  ; arrow table ptr hi
flip_flags     = $0002  ; sprite flip flags
writer_arg_a   = $000A  ; OAM writer param A
writer_arg_b   = $000B  ; OAM writer param B
writer_row_param = $000C  ; OAM writer row parameter
writer_arg_d   = $000D  ; OAM writer param D
  LDA #$A3                                ; $AC73: A9 A3
  STA a:table_ptr_lo                             ; $AC75: 8D 00 00 ; table ptr lo
  LDA #$AC                                ; $AC78: A9 AC
  STA a:table_ptr_hi                             ; $AC7A: 8D 01 00 ; table ptr hi
  LDY btl_frame_counter                               ; $AC7D: AC 48 05 ; menu step
  LDA Phase3CommandArrowTiles,Y           ; $AC80: B9 9B AC ; tile id
  STA a:writer_arg_a                             ; $AC83: 8D 0A 00
  LDA #$80                                ; $AC86: A9 80
  STA a:writer_row_param                             ; $AC88: 8D 0C 00 ; row param
  LDA #$00                                ; $AC8B: A9 00
  STA a:writer_arg_b                             ; $AC8D: 8D 0B 00
  STA a:writer_arg_d                             ; $AC90: 8D 0D 00
  LDA #$00                                ; $AC93: A9 00
  STA a:flip_flags                             ; $AC95: 8D 02 00
  JMP B1F_SpriteOamWriterSimple           ; $AC98: 4C AD F1 ; direct placement
;===============================================================================
; $AC9B: Phase3CommandArrowTiles
; Selection-arrow tile ids per menu step: two identical groups of
; $A6/$B6/$C6/$D6 (steps 0-3), followed by filler bytes.
;===============================================================================
Phase3CommandArrowTiles:
  .byte $A6,$B6,$C6,$D6,$A6,$B6,$C6,$D6 ; $AC9B: A6 B6 C6 D6 A6 B6 C6 D6 ; steps 0-3 (x2)
  .byte $00,$07,$00,$00,$80              ; $ACA3: 00 07 00 00 80 ; filler
.endproc
;===============================================================================
; $ACA8: Phase3CommandMarkerUpdate
; Refreshes the command-menu target marker: menu step $0548 into $0000 and
; the current action slot value $0550[$0549*4+$0548] into $0001/$0002,
; then updates via Phase3CommandMarkerRender.
;===============================================================================
.proc Phase3CommandMarkerUpdate
; zero-page work cells (proc-local):
menu_step      = $0000  ; menu step (btl_frame_counter copy)
slot_value_lo  = $0001  ; action slot value lo
slot_value_hi  = $0002  ; action slot value hi
  LDA btl_frame_counter                               ; $ACA8: AD 48 05 ; menu step
  STA a:menu_step                             ; $ACAB: 8D 00 00
  LDA btl_acting_unit                               ; $ACAE: AD 49 05 ; acting side
  ASL                                     ; $ACB1: 0A
  ASL                                     ; $ACB2: 0A
  CLC                                     ; $ACB3: 18
  ADC btl_frame_counter                               ; $ACB4: 6D 48 05 ; + menu step
  TAY                                     ; $ACB7: A8 ; slot index
  LDA btl_order_slots_a,Y                             ; $ACB8: B9 50 05 ; action slot value
  STA a:slot_value_lo                             ; $ACBB: 8D 01 00
  STA a:slot_value_hi                             ; $ACBE: 8D 02 00
  JSR Phase3CommandMarkerRender           ; $ACC1: 20 39 C8 ; marker update
  RTS                                     ; $ACC4: 60
.endproc
;===============================================================================
; $ACC5: Phase8PanelSubDispatch
; Phase-8 handler entry (point-spend panel). First redraws the acting side's
; overlay strip (buffer ptr lo from $0560[$0549], hi fixed $A5, X=0) via
; bank $19 $A000, then sub-dispatches on $0541 through the inline 5-entry
; table below: sub-states 0-4 are the Phase8PanelInit..
; Phase8PanelAdvanceWait handlers.
;===============================================================================
.proc Phase8PanelSubDispatch
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; overlay strip render buffer ptr lo
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
  LDY btl_acting_unit                               ; $ACC5: AC 49 05 ; acting side
  LDA btl_strip_buf_a,Y                             ; $ACC8: B9 60 05 ; strip buffer ptr lo
  STA a:strip_ptr_lo                             ; $ACCB: 8D 00 00
  LDA #$A5                                ; $ACCE: A9 A5
  STA a:strip_ptr_hi                             ; $ACD0: 8D 0A 00 ; buffer ptr hi
  LDX #$00                                ; $ACD3: A2 00 ; strip 0
  LDY #$39                                ; $ACD5: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $ACD7: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $ACDA: 00 A0 ; B19_OverlayStripRender_Entry
  LDA btl_overlay_sub                               ; $ACDC: AD 41 05 ; sub-phase
  JSR B1F_CallbackDispatcher              ; $ACDF: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase8PanelInit                   ; $ACE2: EC AC ; sub 0 ($ACEC)
  .word Phase8PanelScriptStep             ; $ACE4: 3C AD ; sub 1 ($AD3C)
  .word Phase8PanelMenuInput              ; $ACE6: 5D AD ; sub 2 ($AD5D)
  .word Phase8PanelConfirmWait            ; $ACE8: 11 AE ; sub 3 ($AE11)
  .word Phase8PanelAdvanceWait            ; $ACEA: 8E AE ; sub 4 ($AE8E)
.endproc
;===============================================================================
; $ACEC: Phase8PanelInit
; Sub 0. Advances to sub 1 and clears the row cursor $0548, then computes
; the point tier $054A (0-5) from the per-side point budget $0572[$0549]
; through the threshold ladder <5/<7/<8/<$A/<$C. Sets UI mode $E7 and fills
; the panel field block: base value $044C <- budget, extension bytes
; $044D/$044E cleared, panel param $00BD <- $57, menu cursor $0424/$0425
; cleared. The tier selects the row count (tier+1) for sub 1/sub 2.
;===============================================================================
.proc Phase8PanelInit
  INC btl_overlay_sub                               ; $ACEC: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $ACEF: A9 00
  STA btl_frame_counter                               ; $ACF1: 8D 48 05 ; row cursor <- 0
  LDY btl_acting_unit                               ; $ACF4: AC 49 05 ; acting side
  LDA btl_point_budget_a,Y                             ; $ACF7: B9 72 05 ; point budget
  LDY #$00                                ; $ACFA: A0 00 ; tier
  CMP #$05                                ; $ACFC: C9 05
  BCC @StoreTier                          ; $ACFE: 90 15
  INY                                     ; $AD00: C8
  CMP #$07                                ; $AD01: C9 07
  BCC @StoreTier                          ; $AD03: 90 10
  INY                                     ; $AD05: C8
  CMP #$08                                ; $AD06: C9 08
  BCC @StoreTier                          ; $AD08: 90 0B
  INY                                     ; $AD0A: C8
  CMP #$0A                                ; $AD0B: C9 0A
  BCC @StoreTier                          ; $AD0D: 90 06
  INY                                     ; $AD0F: C8
  CMP #$0C                                ; $AD10: C9 0C
  BCC @StoreTier                          ; $AD12: 90 01
  INY                                     ; $AD14: C8 ; tier <- 5
@StoreTier:
  STY btl_walk_row                               ; $AD15: 8C 4A 05 ; point tier
  LDA #$E7                                ; $AD18: A9 E7
  JSR B1F_SetUI0                          ; $AD1A: 20 6D F2 ; UI mode $E7
  LDY btl_acting_unit                               ; $AD1D: AC 49 05 ; acting side
  LDA btl_point_budget_a,Y                             ; $AD20: B9 72 05 ; point budget
  STA btl_panel_fields                               ; $AD23: 8D 4C 04 ; panel base value
  LDA #$00                                ; $AD26: A9 00
  STA btl_panel_fields+$1                               ; $AD28: 8D 4D 04 ; clear field ext bytes
  STA btl_panel_fields+$2                               ; $AD2B: 8D 4E 04
  LDA #$57                                ; $AD2E: A9 57
  STA a:zp_panel_param_c                             ; $AD30: 8D BD 00 ; panel param
  LDA #$00                                ; $AD33: A9 00
  STA menu_cursor_col                               ; $AD35: 8D 24 04 ; menu cursor col <- 0
  STA menu_cursor_page                               ; $AD38: 8D 25 04 ; menu cursor page <- 0
  RTS                                     ; $AD3B: 60
.endproc
;===============================================================================
; $AD3C: Phase8PanelScriptStep
; Sub 1. Waits while the animation queue is busy ($B870 carry clear) or a
; row script is still displayed ($007E != 0). Otherwise queues the row
; script line $0548 (row text table via Loc_B0AC, script id $00BB <- 9) and
; counts $0548 up to the point tier $054A; then advances to sub 2.
;===============================================================================
.proc Phase8PanelScriptStep
  JSR BattleAnimQueueIdleCheck                 ; $AD3C: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AD3F: 90 1B ; still busy: wait
  LDA a:btl_anim_flags                             ; $AD41: AD 7E 00 ; script busy flag
  BNE @Done                               ; $AD44: D0 16 ; script pending: wait
  LDA #$09                                ; $AD46: A9 09
  STA a:zp_panel_param_a                             ; $AD48: 8D BB 00 ; script id
  JSR Phase8RowScriptQueue                ; $AD4B: 20 AC B0
  LDA btl_frame_counter                               ; $AD4E: AD 48 05 ; row cursor
  INC btl_frame_counter                               ; $AD51: EE 48 05 ; row++
  CMP btl_walk_row                               ; $AD54: CD 4A 05 ; vs point tier
  BCC @Done                               ; $AD57: 90 03 ; more rows
  INC btl_overlay_sub                               ; $AD59: EE 41 05 ; sub-phase <- 2
@Done:
  RTS                                     ; $AD5C: 60
.endproc
;===============================================================================
; $AD5D: Phase8PanelMenuInput
; Sub 2. Row selection for the point-spend panel. Saves the pad latch
; $0083/$0081 on the stack, refetches the acting side's pad state and
; latches it back, then steps the row cursor $0012 over the current tier's
; FF-terminated row list (Phase8TierRowPtrTable[$054A]) via B1F_MenuStep2
; and draws the selection cursor sprite through B1F_PointerTableLookup
; (coords Phase8RowCursorCoords, params Phase8RowCursorParams). When the
; animation queue idles (BattleAnimQueueIdleCheck carry set):
;   A: if the budget $0572[$0549] covers the row cost
;      (@RowCostTable[$0012] = 3/5/7/8/$A/$C), deducts it and applies the
;      row effect via Phase8RowEffectDispatch (Phase8RowCoinFlip..
;      Phase8RowAdvance);
;   B: cancels back to phase 3 sub 3 (queueing the $E8/$E9 tile animation
;      slot 0 and refreshing the panel troop-count block via
;      BattlePanelStatsRefresh).
;===============================================================================
.proc Phase8PanelMenuInput
; zero-page work cells (proc-local):
pad_fetched_hi = $0000  ; BattlePadStateFetch result hi
pad_fetched_lo = $0001  ; BattlePadStateFetch result lo
row_list_ptr_lo = $0010  ; tier row list ptr lo
row_list_ptr_hi = $0011  ; tier row list ptr hi
selected_row   = $0012  ; selected row index
cursor_tbl_lo  = $0010  ; cursor pos table ptr lo
cursor_tbl_hi  = $0011  ; cursor pos table ptr hi
cursor_ptr_lo  = $0000  ; cursor param ptr lo
cursor_ptr_hi  = $0001  ; cursor param ptr hi
pad_state      = $0001  ; merged both-pad raw state
  LDA a:btl_pad1_hi                             ; $AD5D: AD 83 00 ; pad latch hi
@PadLatchPush:
  PHA                                     ; $AD60: 48
  LDA a:btl_pad1_lo                             ; $AD61: AD 81 00 ; pad latch lo
  PHA                                     ; $AD64: 48
  LDA btl_acting_unit                               ; $AD65: AD 49 05 ; acting side
  JSR BattlePadStateFetch                 ; $AD68: 20 DE CC
  LDA a:pad_fetched_hi                             ; $AD6B: AD 00 00
  STA a:btl_pad1_hi                             ; $AD6E: 8D 83 00 ; relatch hi
  LDA a:pad_fetched_lo                             ; $AD71: AD 01 00
  STA a:btl_pad1_lo                             ; $AD74: 8D 81 00 ; relatch lo
  LDA btl_walk_row                               ; $AD77: AD 4A 05 ; point tier
  ASL                                     ; $AD7A: 0A
  TAY                                     ; $AD7B: A8
  LDA Phase8TierRowPtrTable,Y             ; $AD7C: B9 D0 AE ; row list ptr lo
  STA a:row_list_ptr_lo                             ; $AD7F: 8D 10 00
  LDA Phase8TierRowPtrTable+1,Y           ; $AD82: B9 D1 AE ; row list ptr hi
  STA a:row_list_ptr_hi                             ; $AD85: 8D 11 00
  LDA #$00                                ; $AD88: A9 00
  STA a:selected_row                             ; $AD8A: 8D 12 00 ; selected row <- 0
  JSR B1F_MenuStep2                       ; $AD8D: 20 1E ED ; D-pad row stepping
  LDA #$00                                ; $AD90: A9 00
  STA a:cursor_tbl_lo                             ; $AD92: 8D 10 00 ; cursor table ptr <- $AF00
  LDA #$AF                                ; $AD95: A9 AF
  STA a:cursor_tbl_hi                             ; $AD97: 8D 11 00
  LDA #$0C                                ; $AD9A: A9 0C ; cursor param ptr <- $AF0C
  STA a:cursor_ptr_lo                             ; $AD9C: 8D 00 00
  LDA #$AF                                ; $AD9F: A9 AF
  STA a:cursor_ptr_hi                             ; $ADA1: 8D 01 00
  LDA a:selected_row                             ; $ADA4: AD 12 00 ; selected row
  JSR B1F_PointerTableLookup              ; $ADA7: 20 F5 ED ; cursor sprite write
  PLA                                     ; $ADAA: 68
  STA a:btl_pad1_lo                             ; $ADAB: 8D 81 00 ; restore pad latch lo
  PLA                                     ; $ADAE: 68
  STA a:btl_pad1_hi                             ; $ADAF: 8D 83 00 ; restore pad latch hi
  JSR BattleAnimQueueIdleCheck                 ; $ADB2: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $ADB5: 90 59 ; still busy: wait
  LDA btl_acting_unit                               ; $ADB7: AD 49 05
  JSR BattlePadStateFetch                 ; $ADBA: 20 DE CC
  LDA a:pad_state                             ; $ADBD: AD 01 00
  AND #$01                                ; $ADC0: 29 01 ; A button
  BEQ @BCancelCheck                       ; $ADC2: F0 23
  LDY btl_acting_unit                               ; $ADC4: AC 49 05 ; acting side
  LDA btl_point_budget_a,Y                             ; $ADC7: B9 72 05 ; point budget
  LDY a:selected_row                             ; $ADCA: AC 12 00 ; selected row
  CMP @RowCostTable,Y                     ; $ADCD: D9 DF AD ; afford check
  BCC @BCancelCheck                       ; $ADD0: 90 15 ; too expensive
  SEC                                     ; $ADD2: 38
  SBC @RowCostTable,Y                     ; $ADD3: F9 DF AD ; deduct cost
  LDY btl_acting_unit                               ; $ADD6: AC 49 05
  STA btl_point_budget_a,Y                             ; $ADD9: 99 72 05 ; budget -= cost
  JMP Phase8RowEffectDispatch             ; $ADDC: 4C 11 AF ; apply row effect
; --- Row cost per selected row index (last two entries unused padding) ---
@RowCostTable:
  .byte $03,$05,$07,$08,$0A,$0C,$0C,$0C   ; $ADDF: 03 05 07 08 0A 0C 0C 0C
@BCancelCheck:
  LDA btl_acting_unit                               ; $ADE7: AD 49 05
  JSR BattlePadStateFetch                 ; $ADEA: 20 DE CC
  LDA a:pad_state                             ; $ADED: AD 01 00
  AND #$02                                ; $ADF0: 29 02 ; B button
  BEQ @Done                               ; $ADF2: F0 1C ; no button
  LDA #$03                                ; $ADF4: A9 03
  STA btl_overlay_phase                               ; $ADF6: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $ADF9: A9 03
  STA btl_overlay_sub                               ; $ADFB: 8D 41 05 ; sub-phase <- 3
  LDA #$E8                                ; $ADFE: A9 E8
  STA anim_queue_id0_lo                               ; $AE00: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AE03: A9 E9
  STA anim_queue_id0_hi                               ; $AE05: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AE08: A9 00
  STA anim_queue_hdr0                               ; $AE0A: 8D 00 03 ; anim slot 0
  JSR BattlePanelStatsRefresh           ; $AE0D: 20 F1 CB ; refresh panel stats
@Done:
  RTS                                     ; $AE10: 60
.endproc
;===============================================================================
; $AE11: Phase8PanelConfirmWait
; Sub 3. Waits for the animation queue to idle (BattleAnimQueueIdleCheck carry set) and an A
; button edge, then returns to phase 3 sub 3 (queueing the $E8/$E9 tile
; animation slot 0 and refreshing the panel troop-count block via
; BattlePanelStatsRefresh). If the side control flag $0562[$0549] == 3
; (player-request entry), both pads are merged via
; BattleBothPadsStateFetch and the resume latch $054B/$054C is set to 1/1
; so phase 3 hands control back afterwards.
;===============================================================================
.proc Phase8PanelConfirmWait
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
  JSR BattleInputPromptDraw             ; $AE11: 20 A8 CC ; blink input prompt sprite
  LDY btl_acting_unit                               ; $AE14: AC 49 05 ; acting side
  LDA btl_input_mode_a,Y                             ; $AE17: B9 62 05 ; side control flag
  CMP #$03                                ; $AE1A: C9 03 ; player-request entry
  BNE @SinglePadFetch                     ; $AE1C: D0 06
  JSR BattleBothPadsStateFetch            ; $AE1E: 20 22 CD
  JMP @InputCheck                         ; $AE21: 4C 2A AE
@SinglePadFetch:
  LDA btl_acting_unit                               ; $AE24: AD 49 05
  JSR BattlePadStateFetch                 ; $AE27: 20 DE CC
@InputCheck:
  JSR BattleAnimQueueIdleCheck                 ; $AE2A: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AE2D: 90 3C ; still busy: wait
  LDA a:pad_state                             ; $AE2F: AD 01 00
  AND #$01                                ; $AE32: 29 01 ; A button
  BEQ @Done                               ; $AE34: F0 35 ; no A: wait
  LDY btl_acting_unit                               ; $AE36: AC 49 05 ; acting side
  LDA btl_input_mode_a,Y                             ; $AE39: B9 62 05 ; side control flag
  CMP #$03                                ; $AE3C: C9 03
  BNE Phase8PanelReturnToCommand          ; $AE3E: D0 2C ; plain return
  LDA #$03                                ; $AE40: A9 03
  STA btl_overlay_phase                               ; $AE42: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $AE45: A9 03
  STA btl_overlay_sub                               ; $AE47: 8D 41 05 ; sub-phase <- 3
  LDA #$E8                                ; $AE4A: A9 E8
  STA anim_queue_id0_lo                               ; $AE4C: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AE4F: A9 E9
  STA anim_queue_id0_hi                               ; $AE51: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AE54: A9 00
  STA anim_queue_hdr0                               ; $AE56: 8D 00 03 ; anim slot 0
  LDA #$00                                ; $AE59: A9 00
  STA anim_queue_id0_lo                               ; $AE5B: 8D 10 03 ; clear anim id lo
  LDA #$01                                ; $AE5E: A9 01
  STA btl_walk_col                               ; $AE60: 8D 4B 05 ; resume latch phase <- 1
  LDA #$01                                ; $AE63: A9 01
  STA btl_recorded_status                               ; $AE65: 8D 4C 05 ; resume latch sub <- 1
  JSR BattlePanelStatsRefresh           ; $AE68: 20 F1 CB ; refresh panel stats
@Done:
  RTS                                     ; $AE6B: 60
.endproc
;===============================================================================
; $AE6C: Phase8PanelReturnToCommand
; Returns to phase 3 sub 3: sets the phase/sub, queues the $E8/$E9 tile
; animation (slot 0, anim id lo cleared afterwards) and refreshes the
; panel troop-count block (BattlePanelStatsRefresh).
;===============================================================================
.proc Phase8PanelReturnToCommand
  LDA #$03                                ; $AE6C: A9 03
  STA btl_overlay_phase                               ; $AE6E: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $AE71: A9 03
  STA btl_overlay_sub                               ; $AE73: 8D 41 05 ; sub-phase <- 3
  LDA #$E8                                ; $AE76: A9 E8
  STA anim_queue_id0_lo                               ; $AE78: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AE7B: A9 E9
  STA anim_queue_id0_hi                               ; $AE7D: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AE80: A9 00
  STA anim_queue_hdr0                               ; $AE82: 8D 00 03 ; anim slot 0
  LDA #$00                                ; $AE85: A9 00
  STA anim_queue_id0_lo                               ; $AE87: 8D 10 03 ; clear anim id lo
  JSR BattlePanelStatsRefresh           ; $AE8A: 20 F1 CB ; refresh panel stats
  RTS                                     ; $AE8D: 60
.endproc
;===============================================================================
; $AE8E: Phase8PanelAdvanceWait
; Sub 4. Waits for the animation queue to idle (BattleAnimQueueIdleCheck carry set) and an A
; button edge, then advances to phase 5 sub 0 (battle resolution).
;===============================================================================
.proc Phase8PanelAdvanceWait
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
  JSR BattleInputPromptDraw             ; $AE8E: 20 A8 CC ; blink input prompt sprite
  LDA btl_acting_unit                               ; $AE91: AD 49 05 ; acting side
  JSR BattlePadStateFetch                 ; $AE94: 20 DE CC
  JSR BattleAnimQueueIdleCheck                 ; $AE97: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AE9A: 90 11 ; still busy: wait
  LDA a:pad_state                             ; $AE9C: AD 01 00
  AND #$01                                ; $AE9F: 29 01 ; A button
  BEQ @Done                               ; $AEA1: F0 0A ; no A: wait
  LDA #$05                                ; $AEA3: A9 05
  STA btl_overlay_phase                               ; $AEA5: 8D 40 05 ; phase <- 5
  LDA #$00                                ; $AEA8: A9 00
  STA btl_overlay_sub                               ; $AEAA: 8D 41 05 ; sub-phase <- 0
@Done:
  RTS                                     ; $AEAD: 60
.endproc
;===============================================================================
; $AEAE: Phase8PanelReturnToCommandDup
; Unreferenced duplicate of Phase8PanelReturnToCommand without the $0300
; clear (identical effect, the slot byte is written last in the other
; copy). Retained as code for ROM byte-exactness.
;===============================================================================
.proc Phase8PanelReturnToCommandDup
  LDA #$03                                ; $AEAE: A9 03
  STA btl_overlay_phase                               ; $AEB0: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $AEB3: A9 03
  STA btl_overlay_sub                               ; $AEB5: 8D 41 05 ; sub-phase <- 3
  LDA #$E8                                ; $AEB8: A9 E8
  STA anim_queue_id0_lo                               ; $AEBA: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AEBD: A9 E9
  STA anim_queue_id0_hi                               ; $AEBF: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AEC2: A9 00
  STA anim_queue_hdr0                               ; $AEC4: 8D 00 03 ; anim slot 0
  LDA #$00                                ; $AEC7: A9 00
  STA anim_queue_id0_lo                               ; $AEC9: 8D 10 03 ; clear anim id lo
  JSR BattlePanelStatsRefresh           ; $AECC: 20 F1 CB ; refresh panel stats
  RTS                                     ; $AECF: 60
.endproc
;===============================================================================
; $AED0: Phase8TierRowPtrTable
; FF-terminated selectable-row lists per point tier $054A: tier t exposes
; rows 0..t (up to 6 rows), each padded with extra $FF terminators.
;===============================================================================
Phase8TierRowPtrTable:
  .word Phase8Tier0Rows                   ; $AED0: FC AE ; tier 0
  .word Phase8Tier1Rows                   ; $AED2: F8 AE ; tier 1
  .word Phase8Tier2Rows                   ; $AED4: F2 AE ; tier 2
  .word Phase8Tier3Rows                   ; $AED6: EC AE ; tier 3
  .word Phase8Tier4Rows                   ; $AED8: E4 AE ; tier 4
  .word Phase8Tier5Rows                   ; $AEDA: DC AE ; tier 5
Phase8Tier5Rows:
  .byte $00,$01,$02,$03,$04,$05,$FF,$FF  ; $AEDC: 00 01 02 03 04 05 FF FF ; rows 0-5
Phase8Tier4Rows:
  .byte $00,$01,$02,$03,$04,$FF,$FF,$FF  ; $AEE4: 00 01 02 03 04 FF FF FF ; rows 0-4
Phase8Tier3Rows:
  .byte $00,$01,$02,$03,$FF,$FF          ; $AEEC: 00 01 02 03 FF FF ; rows 0-3
Phase8Tier2Rows:
  .byte $00,$01,$02,$FF,$FF,$FF          ; $AEF2: 00 01 02 FF FF FF ; rows 0-2
Phase8Tier1Rows:
  .byte $00,$01,$FF,$FF                  ; $AEF8: 00 01 FF FF ; rows 0-1
Phase8Tier0Rows:
  .byte $00,$FF,$FF,$FF                  ; $AEFC: 00 FF FF FF ; row 0 only
;===============================================================================
; $AF00: Phase8RowCursorCoords
; Selection-cursor sprite coordinates per selected row (word = y,x):
; a 2-column x 3-row grid (x=$48/$88, y=$B4/$C4/$D4). Phase8RowCursorParams
; is the parameter block passed alongside through B1F_PointerTableLookup.
;===============================================================================
Phase8RowCursorCoords:
  .word $48B4                             ; $AF00: B4 48 ; row 0: y=$B4 x=$48
  .word $88B4                             ; $AF02: B4 88 ; row 1: y=$B4 x=$88
  .word $48C4                             ; $AF04: C4 48 ; row 2: y=$C4 x=$48
  .word $88C4                             ; $AF06: C4 88 ; row 3: y=$C4 x=$88
  .word $48D4                             ; $AF08: D4 48 ; row 4: y=$D4 x=$48
  .word $88D4                             ; $AF0A: D4 88 ; row 5: y=$D4 x=$88
Phase8RowCursorParams:
  .byte $00,$07,$00,$00,$80              ; $AF0C: 00 07 00 00 80 ; cursor params
;===============================================================================
; $AF11: Phase8RowEffectDispatch
; Applies the purchased row effect after the cost deduction in
; Phase8PanelMenuInput: dispatches on the selected row ($0012, mirrored to
; $0548) through the inline 6-entry table below. Rows 0/2/3/4 set timed
; side status counters $0574-$0577 (the acting side's nibble) - row 3 also
; saves and advances the periodic reload value $056A/$056B; row 1 rolls an
; officer-stat chance check (success skips to sub 4, failure to sub 3);
; row 0 is a coin flip that targets the opposing unit $042C; row 5 advances
; to phase 9 (formation advance).
;===============================================================================
.proc Phase8RowEffectDispatch
; zero-page work cells (proc-local):
selected_row   = $0012  ; selected row index
  LDA a:selected_row                             ; $AF11: AD 12 00 ; selected row
  STA btl_frame_counter                               ; $AF14: 8D 48 05 ; mirror to row slot
  JSR B1F_CallbackDispatcher              ; $AF17: 20 DE EA
; --- CallbackDispatcher row-effect table, indexed by selected row ---
  .word Phase8RowCoinFlip                 ; $AF1A: D2 AF ; row 0 ($AFD2)
  .word Phase8RowStatCheck                ; $AF1C: 26 AF ; row 1 ($AF26)
  .word Phase8RowCounter575               ; $AF1E: 0E B0 ; row 2 ($B00E)
  .word Phase8RowCounter576               ; $AF20: 2E B0 ; row 3 ($B02E)
  .word Phase8RowCounter577               ; $AF22: 7C B0 ; row 4 ($B07C)
  .word Phase8RowAdvance                  ; $AF24: 9C B0 ; row 5 ($B09C)
.endproc
;===============================================================================
; $AF26: Phase8RowStatCheck
; Row 1. Auto-fails while the battle phase $0544 == 5 on side A.
; Otherwise reads both officers' records (B1F_GetOfficerRecordAddr on the
; side unit ids $0560/$0561): field [$B]>>4 (rank/aptitude) and field [2]
; (troops), swaps the pairs when side B acts so ($000A,$000C) describe the
; acting side. Chance = floor(2 * max(0, rank edge) / 10) + 32 - opponent
; troops (B1F_MathDiv16 with divisor 10); if B1F_RandomBelowThreshold(100)
; lands below the chance, succeeds (UI $EA, sub-phase <- 4 = advance wait),
; otherwise fails at @Fail (UI $EB, sub-phase++ = confirm wait).
;===============================================================================
.proc Phase8RowStatCheck
; zero-page work cells (proc-local):
rec_ptr_lo     = $0000  ; officer record ptr lo (caller-set)
opp_troops_scratch = $0001  ; opponent troop count scratch
dividend_hi    = $0002  ; MathDiv16 dividend hi (0)
divisor_lo     = $0003  ; divisor lo (10)
divisor_hi     = $0004  ; divisor hi (0)
rank_a_work    = $000A  ; side A rank -> own rank -> dividend -> success chance
rank_b_work    = $000B  ; side B rank -> opponent rank
troops_a_work  = $000C  ; side A troop count -> own troops
troops_b_work  = $000D  ; side B troop count -> opponent troops
  LDA battle_phase                               ; $AF26: AD 44 05 ; battle phase
  CMP #$05                                ; $AF29: C9 05
  BNE @SideCheck                          ; $AF2B: D0 08
  LDA btl_acting_unit                               ; $AF2D: AD 49 05 ; acting side
  BNE @SideCheck                          ; $AF30: D0 03
  JMP @Fail                               ; $AF32: 4C C9 AF ; phase 5 side A: no go
@SideCheck:
  LDA btl_strip_buf_a                               ; $AF35: AD 60 05 ; side A unit id
  JSR B1F_GetOfficerRecordAddr            ; $AF38: 20 D7 F2 ; record ptr -> ($00)
  LDY #$0B                                ; $AF3B: A0 0B
  LDA (rec_ptr_lo),Y                             ; $AF3D: B1 00 ; record field [$B]
  LSR                                     ; $AF3F: 4A
  LSR                                     ; $AF40: 4A
  LSR                                     ; $AF41: 4A
  LSR                                     ; $AF42: 4A ; >>4: rank/aptitude
  STA a:rank_a_work                             ; $AF43: 8D 0A 00 ; side A rank
  LDY #$02                                ; $AF46: A0 02
  LDA (rec_ptr_lo),Y                             ; $AF48: B1 00 ; record field [2]
  STA a:troops_a_work                             ; $AF4A: 8D 0C 00 ; side A troops
  LDA btl_strip_buf_b                               ; $AF4D: AD 61 05 ; side B unit id
  JSR B1F_GetOfficerRecordAddr            ; $AF50: 20 D7 F2 ; record ptr -> ($00)
  LDY #$0B                                ; $AF53: A0 0B
  LDA (rec_ptr_lo),Y                             ; $AF55: B1 00 ; record field [$B]
  LSR                                     ; $AF57: 4A
  LSR                                     ; $AF58: 4A
  LSR                                     ; $AF59: 4A
  LSR                                     ; $AF5A: 4A ; >>4: rank/aptitude
  STA a:rank_b_work                             ; $AF5B: 8D 0B 00 ; side B rank
  LDY #$02                                ; $AF5E: A0 02
  LDA (rec_ptr_lo),Y                             ; $AF60: B1 00 ; record field [2]
  STA a:troops_b_work                             ; $AF62: 8D 0D 00 ; side B troops
  LDA btl_acting_unit                               ; $AF65: AD 49 05 ; acting side
  BEQ @RankEdge                           ; $AF68: F0 18 ; side A: keep order
  LDY a:rank_a_work                             ; $AF6A: AC 0A 00
  LDA a:rank_b_work                             ; $AF6D: AD 0B 00
  STA a:rank_a_work                             ; $AF70: 8D 0A 00 ; own rank
  STY a:rank_b_work                             ; $AF73: 8C 0B 00 ; opp rank
  LDY a:troops_a_work                             ; $AF76: AC 0C 00
  LDA a:troops_b_work                             ; $AF79: AD 0D 00
  STA a:troops_a_work                             ; $AF7C: 8D 0C 00 ; own troops
  STY a:troops_b_work                             ; $AF7F: 8C 0D 00 ; opp troops
@RankEdge:
  LDA a:rank_a_work                             ; $AF82: AD 0A 00 ; own rank
  SEC                                     ; $AF85: 38
  SBC a:rank_b_work                             ; $AF86: ED 0B 00 ; - opp rank
  BCS @ScaleEdge                          ; $AF89: B0 02 ; no underflow
  LDA #$00                                ; $AF8B: A9 00 ; clamp at 0
@ScaleEdge:
  ASL                                     ; $AF8D: 0A ; edge * 2
  STA a:rank_a_work                             ; $AF8E: 8D 0A 00 ; dividend lo
  LDA a:troops_b_work                             ; $AF91: AD 0D 00 ; opponent troops
  STA a:opp_troops_scratch                             ; $AF94: 8D 01 00 ; scratch for later
  LDA #$0A                                ; $AF97: A9 0A
  STA a:divisor_lo                             ; $AF99: 8D 03 00 ; divisor <- 10
  LDA #$00                                ; $AF9C: A9 00
  STA a:dividend_hi                             ; $AF9E: 8D 02 00 ; dividend hi <- 0
  STA a:divisor_hi                             ; $AFA1: 8D 04 00 ; divisor hi <- 0
  JSR B1F_MathDiv16                       ; $AFA4: 20 7C EA ; edge * 2 / 10
  LDA a:rank_a_work                             ; $AFA7: AD 0A 00 ; quotient
  CLC                                     ; $AFAA: 18
  ADC #$20                                ; $AFAB: 69 20 ; + 32 base chance
  SEC                                     ; $AFAD: 38
  SBC a:opp_troops_scratch                             ; $AFAE: ED 01 00 ; - opponent troops
  STA a:rank_a_work                             ; $AFB1: 8D 0A 00 ; success chance
  LDA #$64                                ; $AFB4: A9 64 ; threshold 100
  JSR B1F_RandomBelowThreshold            ; $AFB6: 20 62 E8 ; rand [0,100)
  CMP a:rank_a_work                             ; $AFB9: CD 0A 00
  BCS @Fail                               ; $AFBC: B0 0B ; rand >= chance
  LDA #$EA                                ; $AFBE: A9 EA
  JSR B1F_SetUI0                          ; $AFC0: 20 6D F2 ; UI $EA: success
  LDA #$04                                ; $AFC3: A9 04
  STA btl_overlay_sub                               ; $AFC5: 8D 41 05 ; sub-phase <- 4
  RTS                                     ; $AFC8: 60
@Fail:
  LDA #$EB                                ; $AFC9: A9 EB
  JSR B1F_SetUI0                          ; $AFCB: 20 6D F2 ; UI $EB: failure
  INC btl_overlay_sub                               ; $AFCE: EE 41 05 ; sub-phase <- 3
  RTS                                     ; $AFD1: 60
.endproc
;===============================================================================
; $AFD2: Phase8RowCoinFlip
; Row 0. Coin flip on B1F_RandomByte bit 0. Miss (bit clear): UI $ED and
; back to the confirm wait (sub-phase++). Hit (bit set): UI $EC, stores the
; opposing side's unit id $0560[$0549^1] into $042C as the effect target,
; then falls through into Phase8RowCounter574.
;===============================================================================
.proc Phase8RowCoinFlip
  JSR B1F_RandomByte                      ; $AFD2: 20 7A E8
  AND #$01                                ; $AFD5: 29 01 ; coin bit
  BNE @Hit                                ; $AFD7: D0 09
  INC btl_overlay_sub                               ; $AFD9: EE 41 05 ; sub-phase <- 3
  LDA #$ED                                ; $AFDC: A9 ED
  JSR B1F_SetUI0                          ; $AFDE: 20 6D F2 ; UI $ED: miss
  RTS                                     ; $AFE1: 60
@Hit:
  LDA #$EC                                ; $AFE2: A9 EC
  JSR B1F_SetUI0                          ; $AFE4: 20 6D F2 ; UI $EC: hit
  LDA btl_acting_unit                               ; $AFE7: AD 49 05 ; acting side
  EOR #$01                                ; $AFEA: 49 01 ; opposing side
  TAY                                     ; $AFEC: A8
  LDA btl_strip_buf_a,Y                             ; $AFED: B9 60 05 ; opposing unit id
  STA btl_panel_params                               ; $AFF0: 8D 2C 04 ; effect target
  INC btl_overlay_sub                               ; $AFF3: EE 41 05 ; sub-phase <- 3
.endproc
;===============================================================================
; $AFF6: Phase8RowCounter574
; Sets status counter $0574 to 4 in the acting side's nibble (side A: low
; nibble, side B: high nibble), preserving the other side's nibble. Fall-
; through tail of Phase8RowCoinFlip.
;===============================================================================
.proc Phase8RowCounter574
  LDA btl_status_ctr0                               ; $AFF6: AD 74 05 ; status counter 574
  LDY btl_acting_unit                               ; $AFF9: AC 49 05 ; acting side
  BNE @SideB                              ; $AFFC: D0 08
  AND #$F0                                ; $AFFE: 29 F0 ; keep side B nibble
  ORA #$04                                ; $B000: 09 04 ; side A counter <- 4
  STA btl_status_ctr0                               ; $B002: 8D 74 05
  RTS                                     ; $B005: 60
@SideB:
  AND #$0F                                ; $B006: 29 0F ; keep side A nibble
  ORA #$40                                ; $B008: 09 40 ; side B counter <- 4
  STA btl_status_ctr0                               ; $B00A: 8D 74 05
  RTS                                     ; $B00D: 60
.endproc
;===============================================================================
; $B00E: Phase8RowCounter575
; Row 2. UI $EE, sub-phase++, then sets status counter $0575 to 3 in the
; acting side's nibble. The counter-set tail ($B016, Apply) is also
; called directly from AiTacticPointSpend without the UI preamble.
;===============================================================================
.proc Phase8RowCounter575
  LDA #$EE                                ; $B00E: A9 EE
  JSR B1F_SetUI0                          ; $B010: 20 6D F2 ; UI $EE
  INC btl_overlay_sub                               ; $B013: EE 41 05 ; sub-phase <- 3
Apply:
  LDA btl_status_ctr1                               ; $B016: AD 75 05 ; status counter 575 (multi-entry: AiTacticPointSpend)
  LDY btl_acting_unit                               ; $B019: AC 49 05 ; acting side
  BNE @SideB                              ; $B01C: D0 08
  AND #$F0                                ; $B01E: 29 F0 ; keep side B nibble
  ORA #$03                                ; $B020: 09 03 ; side A counter <- 3
  STA btl_status_ctr1                               ; $B022: 8D 75 05
  RTS                                     ; $B025: 60
@SideB:
  AND #$0F                                ; $B026: 29 0F ; keep side A nibble
  ORA #$30                                ; $B028: 09 30 ; side B counter <- 3
  STA btl_status_ctr1                               ; $B02A: 8D 75 05
  RTS                                     ; $B02D: 60
.endproc
;===============================================================================
; $B02E: Phase8RowCounter576
; Row 3. UI $EF, sub-phase++, sets status counter $0576 to 4 in the acting
; side's nibble, then advances the side's periodic reload value: the
; current $056A/$056B is saved into the reload latch $0578/$0579 and
; replaced by itself + 5 + rand[0,5) (Phase8RowReloadRoll). When a $0576
; nibble expires, BattleSideStatusCountersDecrement latches the saved
; values back into $056A/$056B. The counter-set tail ($B036, Apply) is
; also called directly from AiTacticPointSpend without the UI preamble.
;===============================================================================
.proc Phase8RowCounter576
  LDA #$EF                                ; $B02E: A9 EF
  JSR B1F_SetUI0                          ; $B030: 20 6D F2 ; UI $EF
  INC btl_overlay_sub                               ; $B033: EE 41 05 ; sub-phase <- 3
Apply:
  LDA btl_status_ctr2                               ; $B036: AD 76 05 ; status counter 576 (multi-entry: AiTacticPointSpend)
  LDY btl_acting_unit                               ; $B039: AC 49 05 ; acting side
  BEQ @SideA                              ; $B03C: F0 14
  AND #$0F                                ; $B03E: 29 0F ; keep side A nibble
  ORA #$40                                ; $B040: 09 40 ; side B counter <- 4
  STA btl_status_ctr2                               ; $B042: 8D 76 05
  LDA btl_attack_b                               ; $B045: AD 6B 05 ; side B reload value
  STA btl_reload_b                               ; $B048: 8D 79 05 ; save to reload latch
  JSR Phase8RowReloadRoll                 ; $B04B: 20 66 B0 ; + 5 + rand[0,5)
  STA btl_attack_b                               ; $B04E: 8D 6B 05 ; advance reload
  RTS                                     ; $B051: 60
@SideA:
  AND #$F0                                ; $B052: 29 F0 ; keep side B nibble
  ORA #$04                                ; $B054: 09 04 ; side A counter <- 4
  STA btl_status_ctr2                               ; $B056: 8D 76 05
  LDA btl_attack_a                               ; $B059: AD 6A 05 ; side A reload value
  STA btl_reload_a                               ; $B05C: 8D 78 05 ; save to reload latch
  JSR Phase8RowReloadRoll                 ; $B05F: 20 66 B0 ; + 5 + rand[0,5)
  STA btl_attack_a                               ; $B062: 8D 6A 05 ; advance reload
  RTS                                     ; $B065: 60
.endproc
;===============================================================================
; $B066: Phase8RowReloadRoll
; Returns A + 5 + rand[0,5): rolls B1F_RandomByte & 7 until below 5, then
; adds 5 and the roll to the input value.
;===============================================================================
.proc Phase8RowReloadRoll
; zero-page work cells (proc-local):
roll           = $0000  ; random roll amount
  PHA                                     ; $B066: 48 ; input value
@RollLoop:
  JSR B1F_RandomByte                      ; $B067: 20 7A E8
  AND #$07                                ; $B06A: 29 07 ; rand [0,8)
  CMP #$05                                ; $B06C: C9 05
  BCS @RollLoop                           ; $B06E: B0 F7 ; reject 5-7
  STA a:roll                             ; $B070: 8D 00 00 ; roll
  PLA                                     ; $B073: 68 ; input value
  CLC                                     ; $B074: 18
  ADC #$05                                ; $B075: 69 05 ; + 5
  CLC                                     ; $B077: 18
  ADC a:roll                             ; $B078: 6D 00 00 ; + roll
  RTS                                     ; $B07B: 60
.endproc
;===============================================================================
; $B07C: Phase8RowCounter577
; Row 4. UI $F0, sub-phase++, then sets status counter $0577 to 3 in the
; acting side's nibble. The counter-set tail ($B084, Apply) is also
; called directly from AiTacticPointSpend without the UI preamble.
;===============================================================================
.proc Phase8RowCounter577
  LDA #$F0                                ; $B07C: A9 F0
  JSR B1F_SetUI0                          ; $B07E: 20 6D F2 ; UI $F0
  INC btl_overlay_sub                               ; $B081: EE 41 05 ; sub-phase <- 3
Apply:
  LDA btl_status_ctr3                               ; $B084: AD 77 05 ; status counter 577 (multi-entry: AiTacticPointSpend)
  LDY btl_acting_unit                               ; $B087: AC 49 05 ; acting side
  BNE @SideB                              ; $B08A: D0 08
  AND #$F0                                ; $B08C: 29 F0 ; keep side B nibble
  ORA #$03                                ; $B08E: 09 03 ; side A counter <- 3
  STA btl_status_ctr3                               ; $B090: 8D 77 05
  RTS                                     ; $B093: 60
@SideB:
  AND #$0F                                ; $B094: 29 0F ; keep side A nibble
  ORA #$30                                ; $B096: 09 30 ; side B counter <- 3
  STA btl_status_ctr3                               ; $B098: 8D 77 05
  RTS                                     ; $B09B: 60
.endproc
;===============================================================================
; $B09C: Phase8RowAdvance
; Row 5. Leaves the panel: phase <- 9 (formation advance), sub-phase <- 0,
; UI mode $F1.
;===============================================================================
.proc Phase8RowAdvance
  LDA #$09                                ; $B09C: A9 09
  STA btl_overlay_phase                               ; $B09E: 8D 40 05 ; phase <- 9
  LDA #$00                                ; $B0A1: A9 00
  STA btl_overlay_sub                               ; $B0A3: 8D 41 05 ; sub-phase <- 0
  LDA #$F1                                ; $B0A6: A9 F1
  JSR B1F_SetUI0                          ; $B0A8: 20 6D F2 ; UI $F1
  RTS                                     ; $B0AB: 60
.endproc
;===============================================================================
; $B0AC: Phase8RowScriptQueue
; Copies the FF-terminated row script Phase8RowScriptTable[$0548] into the
; script buffer $0380 and marks the script pending ($007E bit 2). Called by
; Phase8PanelScriptStep with the script id $00BB already set.
;===============================================================================
.proc Phase8RowScriptQueue
; zero-page work cells (proc-local):
script_ptr_lo  = $0000  ; script byte stream ptr lo
script_ptr_hi  = $0001  ; script byte stream ptr hi
  LDA btl_frame_counter                               ; $B0AC: AD 48 05 ; row cursor
  ASL                                     ; $B0AF: 0A
  TAY                                     ; $B0B0: A8 ; table index * 2
  LDA Phase8RowScriptTable,Y              ; $B0B1: B9 D5 B0 ; script ptr lo
  STA a:script_ptr_lo                             ; $B0B4: 8D 00 00
  LDA Phase8RowScriptTable+1,Y            ; $B0B7: B9 D6 B0 ; script ptr hi
  STA a:script_ptr_hi                             ; $B0BA: 8D 01 00
  LDY #$00                                ; $B0BD: A0 00
@CopyLoop:
  LDA (script_ptr_lo),Y                             ; $B0BF: B1 00 ; script byte
  CMP #$FF                                ; $B0C1: C9 FF ; terminator
  STA vram_script_buf,Y                             ; $B0C3: 99 80 03 ; script buffer
  BEQ @Done                               ; $B0C6: F0 04
  INY                                     ; $B0C8: C8
  JMP @CopyLoop                           ; $B0C9: 4C BF B0
@Done:
  LDA a:btl_anim_flags                             ; $B0CC: AD 7E 00 ; script busy flag
  ORA #$04                                ; $B0CF: 09 04 ; script pending bit
  STA a:btl_anim_flags                             ; $B0D1: 8D 7E 00
  RTS                                     ; $B0D4: 60
.endproc
;===============================================================================
; $B0D5: Phase8RowScriptTable
; Pointers to the FF-terminated row scripts displayed by
; Phase8PanelScriptStep (row index 0-5). Scripts carry a segment header
; (length byte, nametable row $22/$23) followed by tile runs and $01 fill;
; physical order below is row 1, 0, 2, 3, 4, 5.
;===============================================================================
Phase8RowScriptTable:
  .word Phase8RowScript0                  ; $B0D5: F7 B0 ; row 0 ($B0F7)
  .word Phase8RowScript1                  ; $B0D7: E1 B0 ; row 1 ($B0E1)
  .word Phase8RowScript2                  ; $B0D9: 08 B1 ; row 2 ($B108)
  .word Phase8RowScript3                  ; $B0DB: 19 B1 ; row 3 ($B119)
  .word Phase8RowScript4                  ; $B0DD: 33 B1 ; row 4 ($B133)
  .word Phase8RowScript5                  ; $B0DF: 45 B1 ; row 5 ($B145)
Phase8RowScript1:
  .byte $04,$22,$D2,$C0,$C1,$C2,$C3,$0B,$22,$F2,$D0,$D1,$D2,$D3,$01,$01; $B0E1: 04 22 D2 C0 C1 C2 C3 0B 22 F2 D0 D1 D2 D3 01 01
  .byte $01,$01,$01,$01,$7B,$FF          ; $B0F1: 01 01 01 01 7B FF
Phase8RowScript0:
  .byte $04,$22,$CA,$C4,$C5,$C6,$C7,$06,$22,$EA,$D4,$D5,$D6,$D7,$01,$79; $B0F7: 04 22 CA C4 C5 C6 C7 06 22 EA D4 D5 D6 D7 01 79
  .byte $FF                               ; $B107: FF
Phase8RowScript2:
  .byte $04,$23,$0A,$C8,$C9,$CA,$CB,$06,$23,$2A,$D8,$D9,$DA,$DB,$01,$7D; $B108: 04 23 0A C8 C9 CA CB 06 23 2A D8 D9 DA DB 01 7D
  .byte $FF                               ; $B118: FF
Phase8RowScript3:
  .byte $08,$23,$12,$CC,$CD,$CE,$CF,$E0,$E1,$E2,$E3,$0B,$23,$32,$DC,$DD; $B119: 08 23 12 CC CD CE CF E0 E1 E2 E3 0B 23 32 DC DD
  .byte $DE,$DF,$F0,$F1,$F2,$F3,$01,$01,$7E,$FF; $B129: DE DF F0 F1 F2 F3 01 01 7E FF
Phase8RowScript4:
  .byte $04,$23,$4A,$E4,$E5,$E6,$E7,$07,$23,$6A,$F4,$F5,$F6,$F7,$01,$77; $B133: 04 23 4A E4 E5 E6 E7 07 23 6A F4 F5 F6 F7 01 77
  .byte $76,$FF                           ; $B143: 76 FF
Phase8RowScript5:
  .byte $04,$23,$52,$E8,$E9,$EA,$EB,$0B,$23,$72,$F8,$F9,$FA,$FB,$01,$01; $B145: 04 23 52 E8 E9 EA EB 0B 23 72 F8 F9 FA FB 01 01
  .byte $01,$01,$01,$77,$78,$FF          ; $B155: 01 01 01 77 78 FF
;===============================================================================
; $B15B: BattleSideStatusCountersDecrement
; Ticks down the packed per-side status counters $0574-$0577 once per
; round pass (each byte holds two nibble counters). $0574/$0575/$0577 use
; @NibbleDecrement; $0576 uses @CounterDecrementLatch instead: when one of
; its nibbles reaches zero, the reload values $0578/$0579 are latched into
; $056A/$056B.
;===============================================================================
.proc BattleSideStatusCountersDecrement
; zero-page work cells (proc-local):
ctr_work       = $0000  ; counter byte work cell for @NibbleDecrement
  LDA btl_status_ctr0                               ; $B15B: AD 74 05
  STA a:ctr_work                             ; $B15E: 8D 00 00
  JSR @NibbleDecrement                    ; $B161: 20 98 B1
  LDA a:ctr_work                             ; $B164: AD 00 00
  STA btl_status_ctr0                               ; $B167: 8D 74 05
  LDA btl_status_ctr1                               ; $B16A: AD 75 05
  STA a:ctr_work                             ; $B16D: 8D 00 00
  JSR @NibbleDecrement                    ; $B170: 20 98 B1
  LDA a:ctr_work                             ; $B173: AD 00 00
  STA btl_status_ctr1                               ; $B176: 8D 75 05
  LDA btl_status_ctr2                               ; $B179: AD 76 05
  STA a:ctr_work                             ; $B17C: 8D 00 00
  JSR @CounterDecrementLatch              ; $B17F: 20 B7 B1
  LDA a:ctr_work                             ; $B182: AD 00 00
  STA btl_status_ctr2                               ; $B185: 8D 76 05
  LDA btl_status_ctr3                               ; $B188: AD 77 05
  STA a:ctr_work                             ; $B18B: 8D 00 00
  JSR @NibbleDecrement                    ; $B18E: 20 98 B1
  LDA a:ctr_work                             ; $B191: AD 00 00
  STA btl_status_ctr3                               ; $B194: 8D 77 05
  RTS                                     ; $B197: 60
; --- Decrement both nibbles of $0000 independently, clamped at zero ---
@NibbleDecrement:
  LDA a:ctr_work                             ; $B198: AD 00 00
  AND #$0F                                ; $B19B: 29 0F
  BEQ @LowDone                            ; $B19D: F0 07 ; low nibble already 0
  LDY a:ctr_work                             ; $B19F: AC 00 00
  DEY                                     ; $B1A2: 88
  STY a:ctr_work                             ; $B1A3: 8C 00 00
@LowDone:
  LDA a:ctr_work                             ; $B1A6: AD 00 00
  AND #$F0                                ; $B1A9: 29 F0
  BEQ @Done                               ; $B1AB: F0 09 ; high nibble already 0
  LDA a:ctr_work                             ; $B1AD: AD 00 00
  SEC                                     ; $B1B0: 38
  SBC #$10                                ; $B1B1: E9 10
  STA a:ctr_work                             ; $B1B3: 8D 00 00
@Done:
  RTS                                     ; $B1B6: 60
; --- Like @NibbleDecrement, but latches reloads when a nibble hits zero ---
@CounterDecrementLatch:
  LDA a:ctr_work                             ; $B1B7: AD 00 00
  AND #$0F                                ; $B1BA: 29 0F
  BEQ @HighCheck                          ; $B1BC: F0 13
  LDA a:ctr_work                             ; $B1BE: AD 00 00
  SEC                                     ; $B1C1: 38
  SBC #$01                                ; $B1C2: E9 01
  STA a:ctr_work                             ; $B1C4: 8D 00 00
  AND #$0F                                ; $B1C7: 29 0F
  BNE @HighCheck                          ; $B1C9: D0 06 ; not yet zero
  LDA btl_reload_a                               ; $B1CB: AD 78 05
  STA btl_attack_a                               ; $B1CE: 8D 6A 05 ; low-counter reload latch
@HighCheck:
  LDA a:ctr_work                             ; $B1D1: AD 00 00
  AND #$F0                                ; $B1D4: 29 F0
  BEQ @LatchDone                          ; $B1D6: F0 13
  LDA a:ctr_work                             ; $B1D8: AD 00 00
  SEC                                     ; $B1DB: 38
  SBC #$10                                ; $B1DC: E9 10
  STA a:ctr_work                             ; $B1DE: 8D 00 00
  AND #$F0                                ; $B1E1: 29 F0
  BNE @LatchDone                          ; $B1E3: D0 06 ; not yet zero
  LDA btl_reload_b                               ; $B1E5: AD 79 05
  STA btl_attack_b                               ; $B1E8: 8D 6B 05 ; high-counter reload latch
@LatchDone:
  RTS                                     ; $B1EB: 60
.endproc
;===============================================================================
; $B1EC: Phase9AdvanceSubDispatch
; Phase-9 handler entry (formation advance), entered from the phase-8 row-
; effect dispatch row 5 ($B09C, SFX $F1). Redraws the acting side's overlay
; strip (buffer ptr lo from $0560[$0549], hi fixed $A5, X=0) via bank $19
; $A000, then sub-dispatches on $0541 through the inline 4-entry table
; below: sub-states 0-3 are the Phase9AdvanceInit..
; Phase9AdvanceRosterSweep handlers.
;===============================================================================
.proc Phase9AdvanceSubDispatch
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; overlay strip render buffer ptr lo
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
  LDY btl_acting_unit                               ; $B1EC: AC 49 05 ; acting side
  LDA btl_strip_buf_a,Y                             ; $B1EF: B9 60 05 ; strip buffer ptr lo
  STA a:strip_ptr_lo                             ; $B1F2: 8D 00 00
  LDA #$A5                                ; $B1F5: A9 A5
  STA a:strip_ptr_hi                             ; $B1F7: 8D 0A 00 ; buffer ptr hi
  LDX #$00                                ; $B1FA: A2 00 ; strip 0
  LDY #$39                                ; $B1FC: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $B1FE: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $B201: 00 A0 ; B19_OverlayStripRender_Entry
  LDA btl_overlay_sub                               ; $B203: AD 41 05 ; sub-phase
  JSR B1F_CallbackDispatcher              ; $B206: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase9AdvanceInit                 ; $B209: 11 B2 ; sub 0 ($B211)
  .word Phase9AdvanceAnimFrame            ; $B20B: 5B B2 ; sub 1 ($B25B)
  .word Phase9AdvanceContactTick          ; $B20D: F5 B2 ; sub 2 ($B2F5)
  .word Phase9AdvanceRosterSweep          ; $B20F: EF B3 ; sub 3 ($B3EF)
.endproc
;===============================================================================
; $B211: Phase9AdvanceInit
; Sub 0. Blanks the five marker OAM rows ($00B1/$00C1/$00D1/$00C9/$00D9 <-
; $7F), resets the advance frame counter $0548, advances to sub 1 and loads
; the advance parameters from the acting side's roster base slot ($0558 <-
; 0 for side 0, $0B for side 1): direction code $0559 (roster byte $05C2
; high nibble), start row $055A (unit row $0596 << 4) and start column
; $055B (unit column $0580 << 4). Clears the battle flag $008F.
;===============================================================================
.proc Phase9AdvanceInit
  LDA #$7F                                ; $B211: A9 7F
  STA a:$00B1                             ; $B213: 8D B1 00 ; marker OAM row blank
  STA a:$00C1                             ; $B216: 8D C1 00
  STA a:$00D1                             ; $B219: 8D D1 00
  STA a:$00C9                             ; $B21C: 8D C9 00
  STA a:$00D9                             ; $B21F: 8D D9 00
  LDA #$00                                ; $B222: A9 00
  STA btl_frame_counter                               ; $B224: 8D 48 05 ; frame counter <- 0
  INC btl_overlay_sub                               ; $B227: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $B22A: A9 00
  LDY btl_acting_unit                               ; $B22C: AC 49 05 ; acting side
  BEQ @StoreBase                          ; $B22F: F0 02
  LDA #$0B                                ; $B231: A9 0B ; side 1 roster base
@StoreBase:
  STA btl_advance_base                               ; $B233: 8D 58 05 ; roster base slot
  TAY                                     ; $B236: A8
  LDA btl_roster_code_a,Y                             ; $B237: B9 C2 05 ; roster base byte
  LSR                                     ; $B23A: 4A
  LSR                                     ; $B23B: 4A
  LSR                                     ; $B23C: 4A
  LSR                                     ; $B23D: 4A ; high nibble
  STA btl_advance_dir                               ; $B23E: 8D 59 05 ; direction code
  LDA btl_unit_row_a,Y                             ; $B241: B9 96 05 ; unit row (tiles)
  ASL                                     ; $B244: 0A
  ASL                                     ; $B245: 0A
  ASL                                     ; $B246: 0A
  ASL                                     ; $B247: 0A ; x16
  STA btl_advance_marker_row                               ; $B248: 8D 5A 05 ; start row
  LDA btl_unit_col_a,Y                             ; $B24B: B9 80 05 ; unit column (tiles)
  ASL                                     ; $B24E: 0A
  ASL                                     ; $B24F: 0A
  ASL                                     ; $B250: 0A
  ASL                                     ; $B251: 0A ; x16
  STA btl_advance_marker_col                               ; $B252: 8D 5B 05 ; start column
  LDA #$00                                ; $B255: A9 00
  STA a:btl_battle_flag                             ; $B257: 8D 8F 00 ; battle flag <- 0
  RTS                                     ; $B25A: 60
.endproc
;===============================================================================
; $B25B: Phase9AdvanceAnimFrame
; Sub 1. Runs the 32-frame advance animation. Each frame steps the marker
; position one unit in direction $0559 (0 row up, 1 row down, 2 column left,
; 3 column right); leaving the strip bounds (row >= $A0, column wrap
; through $FF/0) finishes the advance via Phase9AdvanceComplete. Every 8
; frames the marker render picks the next wobble offset from
; Phase9AdvanceWobbleOffsetTable, then draws the descriptor at
; Phase9AdvanceStripDrawDesc through B1F_SpriteOamWriterScroll_NoInit at
; (row $055A - wobble, column $055B).
;===============================================================================
.proc Phase9AdvanceAnimFrame
  INC btl_frame_counter                               ; $B25B: EE 48 05 ; frame counter +1
  LDA btl_frame_counter                               ; $B25E: AD 48 05
  CMP #$20                                ; $B261: C9 20
  BCC @MoveMarker                         ; $B263: 90 08 ; 32 frames not done
  LDA #$00                                ; $B265: A9 00
  STA btl_frame_counter                               ; $B267: 8D 48 05 ; frame counter <- 0
  INC btl_overlay_sub                               ; $B26A: EE 41 05 ; sub-phase <- 2
@MoveMarker:
  LDA btl_advance_dir                               ; $B26D: AD 59 05 ; direction code
  BNE @DirDown                            ; $B270: D0 0D
  DEC btl_advance_marker_row                               ; $B272: CE 5A 05 ; dir 0: row -1
  LDA btl_advance_marker_row                               ; $B275: AD 5A 05
  CMP #$A0                                ; $B278: C9 A0
  BCS Phase9AdvanceComplete               ; $B27A: B0 2D ; off-strip
  JMP Phase9AdvanceMarkerRender           ; $B27C: 4C AC B2
@DirDown:
  CMP #$01                                ; $B27F: C9 01
  BNE @DirLeft                            ; $B281: D0 0D
  INC btl_advance_marker_row                               ; $B283: EE 5A 05 ; dir 1: row +1
  LDA btl_advance_marker_row                               ; $B286: AD 5A 05
  CMP #$A0                                ; $B289: C9 A0
  BCS Phase9AdvanceComplete               ; $B28B: B0 1C ; off-strip
  JMP Phase9AdvanceMarkerRender           ; $B28D: 4C AC B2
@DirLeft:
  CMP #$02                                ; $B290: C9 02
  BNE @DirRight                           ; $B292: D0 0D
  DEC btl_advance_marker_col                               ; $B294: CE 5B 05 ; dir 2: column -1
  LDA btl_advance_marker_col                               ; $B297: AD 5B 05
  CMP #$FF                                ; $B29A: C9 FF
  BEQ Phase9AdvanceComplete               ; $B29C: F0 0B ; wrapped off-strip
  JMP Phase9AdvanceMarkerRender           ; $B29E: 4C AC B2
@DirRight:
  INC btl_advance_marker_col                               ; $B2A1: EE 5B 05 ; dir 3: column +1
  LDA btl_advance_marker_col                               ; $B2A4: AD 5B 05
  BNE Phase9AdvanceMarkerRender           ; $B2A7: D0 03 ; still on-strip
.endproc
;===============================================================================
; $B2A9: Phase9AdvanceComplete
; Shared off-strip exit of the advance animation: routes through
; Phase9AdvanceFinish back to the phase-8 row-effect dispatch.
;===============================================================================
.proc Phase9AdvanceComplete
  JMP Phase9AdvanceFinish                 ; $B2A9: 4C 40 B4
.endproc
;===============================================================================
; $B2AC: Phase9AdvanceMarkerRender
; Draws the advance marker: descriptor ptr ($0000/$0001) <-
; Phase9AdvanceStripDrawDesc, sprite row <- marker row $055A minus the
; wobble offset (Phase9AdvanceWobbleOffsetTable indexed by frame/4),
; sprite column <- $055B; writer preset $0003=0/$0004=$A0. Exits through
; B1F_SpriteOamWriterScroll_NoInit.
;===============================================================================
.proc Phase9AdvanceMarkerRender
; zero-page work cells (proc-local):
desc_ptr_lo    = $0000  ; Phase9AdvanceStripDrawDesc ptr lo
desc_ptr_hi    = $0001  ; descriptor ptr hi
desc_index     = $0002  ; descriptor index (0)
spr_y          = $000A  ; sprite Y (marker row - wobble)
spr_arg_b      = $000B  ; OAM writer param B (0)
spr_x          = $000C  ; sprite X (marker column)
spr_arg_d      = $000D  ; OAM writer param D (0)
writer_preset_lo = $0003  ; OAM writer preset lo (0)
writer_preset_hi = $0004  ; OAM writer preset hi ($A0)
  LDA #$E8                                ; $B2AC: A9 E8
  STA a:desc_ptr_lo                             ; $B2AE: 8D 00 00 ; descriptor ptr lo
  LDA #$B2                                ; $B2B1: A9 B2
  STA a:desc_ptr_hi                             ; $B2B3: 8D 01 00 ; descriptor ptr hi
  LDA #$00                                ; $B2B6: A9 00
  STA a:desc_index                             ; $B2B8: 8D 02 00
  LDA btl_frame_counter                               ; $B2BB: AD 48 05 ; frame counter
  LSR                                     ; $B2BE: 4A
  LSR                                     ; $B2BF: 4A ; /4
  AND #$07                                ; $B2C0: 29 07 ; 8-step wobble cycle
  TAY                                     ; $B2C2: A8
  LDA btl_advance_marker_row                               ; $B2C3: AD 5A 05 ; marker row
  SEC                                     ; $B2C6: 38
  SBC Phase9AdvanceWobbleOffsetTable,Y   ; $B2C7: F9 ED B2 ; - wobble
  STA a:spr_y                             ; $B2CA: 8D 0A 00 ; sprite Y
  LDA btl_advance_marker_col                               ; $B2CD: AD 5B 05 ; marker column
  STA a:spr_x                             ; $B2D0: 8D 0C 00 ; sprite X
  LDA #$00                                ; $B2D3: A9 00
  STA a:spr_arg_b                             ; $B2D5: 8D 0B 00
  STA a:spr_arg_d                             ; $B2D8: 8D 0D 00
  LDA #$00                                ; $B2DB: A9 00
  STA a:writer_preset_lo                             ; $B2DD: 8D 03 00 ; writer preset
  LDA #$A0                                ; $B2E0: A9 A0
  STA a:writer_preset_hi                             ; $B2E2: 8D 04 00 ; writer preset
  JMP B1F_SpriteOamWriterScroll_NoInit    ; $B2E5: 4C 9C F0
.endproc
; --- Data Region ---
Phase9AdvanceStripDrawDesc:
  .byte $00,$C4,$02,$00,$80               ; $B2E8: 00 C4 02 00 80 ; marker strip draw descriptor (5-byte head)
Phase9AdvanceWobbleOffsetTable:
  .byte $00,$01,$02,$03,$03,$02,$01,$00  ; $B2ED: 00 01 02 03 03 02 01 00 ; 8-step marker wobble ramp (overlaps descriptor tail)
;===============================================================================
; $B2F5: Phase9AdvanceContactTick
; Sub 2. Contact-damage tick while the animation settles: runs only when the
; $005E low-nibble frame phase is 0; every 4 ticks applies
; Phase9AdvanceContactScan, then advances to sub 3 with the frame counter
; reset. Between ticks it re-renders the marker at its current position
; using the frame entry from Phase9AdvanceFramePtrTable.
;===============================================================================
.proc Phase9AdvanceContactTick
; zero-page work cells (proc-local):
desc_ptr_lo    = $0000  ; marker draw descriptor ptr lo
desc_ptr_hi    = $0001  ; descriptor ptr hi
desc_index     = $0002  ; descriptor index
spr_y          = $000A  ; sprite Y (marker row - wobble)
spr_arg_b      = $000B  ; OAM writer param B
spr_x          = $000C  ; sprite X (marker column)
spr_arg_d      = $000D  ; OAM writer param D
writer_preset_lo = $0003  ; OAM writer preset lo (0)
writer_preset_hi = $0004  ; OAM writer preset hi ($A0)
  LDA a:frame_tick                             ; $B2F5: AD 5E 00 ; frame phase flags
  AND #$0F                                ; $B2F8: 29 0F
  BNE @RenderFrame                        ; $B2FA: D0 16 ; not a tick frame
  INC btl_frame_counter                               ; $B2FC: EE 48 05 ; tick counter +1
  LDA btl_frame_counter                               ; $B2FF: AD 48 05
  CMP #$04                                ; $B302: C9 04
  BCC @RenderFrame                        ; $B304: 90 0C ; 4 ticks not done
  JSR Phase9AdvanceContactScan            ; $B306: 20 4B B4
  INC btl_overlay_sub                               ; $B309: EE 41 05 ; sub-phase <- 3
  LDA #$00                                ; $B30C: A9 00
  STA btl_frame_counter                               ; $B30E: 8D 48 05 ; tick counter <- 0
  RTS                                     ; $B311: 60
@RenderFrame:
  LDA btl_frame_counter                               ; $B312: AD 48 05 ; tick counter
  ASL                                     ; $B315: 0A ; word index
  TAY                                     ; $B316: A8
  LDA Phase9AdvanceFramePtrTable,Y        ; $B317: B9 49 B3 ; frame ptr lo
  STA a:desc_ptr_lo                             ; $B31A: 8D 00 00
  LDA Phase9AdvanceFramePtrTable+1,Y      ; $B31D: B9 4A B3 ; frame ptr hi
  STA a:desc_ptr_hi                             ; $B320: 8D 01 00
  LDA #$00                                ; $B323: A9 00
  STA a:desc_index                             ; $B325: 8D 02 00
  LDA btl_advance_marker_row                               ; $B328: AD 5A 05 ; marker row
  STA a:spr_y                             ; $B32B: 8D 0A 00 ; sprite Y
  LDA btl_advance_marker_col                               ; $B32E: AD 5B 05 ; marker column
  STA a:spr_x                             ; $B331: 8D 0C 00 ; sprite X
  LDA #$00                                ; $B334: A9 00
  STA a:spr_arg_b                             ; $B336: 8D 0B 00
  STA a:spr_arg_d                             ; $B339: 8D 0D 00
  LDA #$00                                ; $B33C: A9 00
  STA a:writer_preset_lo                             ; $B33E: 8D 03 00 ; writer preset
  LDA #$A0                                ; $B341: A9 A0
  STA a:writer_preset_hi                             ; $B343: 8D 04 00 ; writer preset
  JMP B1F_SpriteOamWriterScroll_NoInit    ; $B346: 4C 9C F0
.endproc
; --- Data Region ---
; Phase9AdvanceFramePtrTable ($B349-$B3EE, 166 bytes): per-frame strip
; animation data used by Phase9AdvanceContactTick. The leading word entries
; (indexed by tick counter x2) point into this very block at the per-tick
; render records; the remaining bytes are the record payloads.
Phase9AdvanceFramePtrTable:
  .byte $55,$B3,$66,$B3,$66,$B3,$66,$B3,$66,$B3,$66,$B3,$00,$E9,$02,$00; $B349: 55 B3 66 B3 66 B3 66 B3 66 B3 66 B3 00 E9 02 00
  .byte $00,$EA,$02,$08,$08,$F9,$02,$00,$08,$FA,$02,$08,$80,$F0,$C5,$02; $B359: 00 EA 02 08 08 F9 02 00 08 FA 02 08 80 F0 C5 02
  .byte $F8,$F8,$D4,$02,$F0,$F8,$D5,$02,$F8,$F0,$E6,$02,$00,$F0,$E6,$42; $B369: F8 F8 D4 02 F0 F8 D5 02 F8 F0 E6 02 00 F0 E6 42
  .byte $08,$F8,$F6,$02,$00,$F8,$E8,$02,$08,$F0,$C5,$42,$10,$F8,$D5,$42; $B379: 08 F8 F6 02 00 F8 E8 02 08 F0 C5 42 10 F8 D5 42
  .byte $10,$F8,$D4,$42,$18,$00,$E4,$02,$F0,$00,$E5,$02,$F8,$08,$F4,$02; $B389: 10 F8 D4 42 18 00 E4 02 F0 00 E5 02 F8 08 F4 02
  .byte $F0,$08,$F5,$02,$F8,$00,$E7,$02,$00,$00,$E8,$02,$08,$08,$F7,$02; $B399: F0 08 F5 02 F8 00 E7 02 00 00 E8 02 08 08 F7 02
  .byte $00,$08,$C9,$02,$08,$00,$E5,$42,$10,$00,$E4,$42,$18,$08,$F5,$42; $B3A9: 00 08 C9 02 08 00 E5 42 10 00 E4 42 18 08 F5 42
  .byte $10,$08,$F4,$42,$18,$10,$C6,$02,$F0,$10,$C7,$02,$F8,$18,$D6,$02; $B3B9: 10 08 F4 42 18 10 C6 02 F0 10 C7 02 F8 18 D6 02
  .byte $F0,$18,$D7,$02,$F8,$10,$C8,$02,$00,$10,$D9,$02,$08,$18,$D8,$02; $B3C9: F0 18 D7 02 F8 10 C8 02 00 10 D9 02 08 18 D8 02
  .byte $00,$18,$D8,$42,$08,$10,$C7,$42,$10,$10,$C6,$42,$18,$18,$D7,$42; $B3D9: 00 18 D8 42 08 10 C7 42 10 10 C6 42 18 18 D7 42
  .byte $10,$18,$D6,$42,$18,$80                       ; $B3E9: 10 18 D6 42 18 80
;===============================================================================
; $B3EF: Phase9AdvanceRosterSweep
; Sub 3. Sweeps the acting side's 11 roster slots ($0558+$0548, slot index
; $0548 = 0..$0A): dead units ($05AC == 0) are cleared from the OAM via BattleCellRedraw
; ($0012=0) and removed from the event/row/column/roster arrays ($FF);
; living units get their strip sprite refreshed ($0012=1). When all slots
; are processed the advance finishes via Phase9AdvanceFinish.
;===============================================================================
.proc Phase9AdvanceRosterSweep
; zero-page work cells (proc-local):
sprite_mode    = $0012  ; 0 = clear sprite, 1 = refresh sprite
slot_param     = $0013  ; roster slot parameter
  LDA #$00                                ; $B3EF: A9 00
  LDY btl_acting_unit                               ; $B3F1: AC 49 05 ; acting side
  BNE @SideB                              ; $B3F4: D0 02
  LDA #$0B                                ; $B3F6: A9 0B ; side 1 roster base
@SideB:
  CLC                                     ; $B3F8: 18
  ADC btl_frame_counter                               ; $B3F9: 6D 48 05 ; + slot cursor
  TAY                                     ; $B3FC: A8 ; roster slot index
  LDA btl_roster_code_a,Y                             ; $B3FD: B9 C2 05 ; roster entry
  CMP #$FF                                ; $B400: C9 FF
  BEQ @NextSlot                           ; $B402: F0 32 ; empty slot
  LDA btl_troops_a,Y                             ; $B404: B9 AC 05 ; unit troop count
  BNE @UpdateSprite                       ; $B407: D0 22 ; still alive
  LDA #$00                                ; $B409: A9 00
  STA a:sprite_mode                             ; $B40B: 8D 12 00 ; clear-sprite flag
  STY a:slot_param                             ; $B40E: 8C 13 00 ; slot param
  TYA                                     ; $B411: 98
  PHA                                     ; $B412: 48
  JSR BattleCellRedraw                         ; $B413: 20 82 B8 ; strip sprite clear
  PLA                                     ; $B416: 68
  TAY                                     ; $B417: A8
  LDA #$FF                                ; $B418: A9 FF
  STA btl_unit_col_a,Y                             ; $B41A: 99 80 05 ; event byte <- $FF
  STA btl_unit_row_a,Y                             ; $B41D: 99 96 05 ; row <- $FF
  STA btl_roster_code_a,Y                             ; $B420: 99 C2 05 ; roster <- $FF
  LDA #$00                                ; $B423: A9 00
  STA btl_troops_a,Y                             ; $B425: 99 AC 05 ; troop count <- 0
  JMP @NextSlot                           ; $B428: 4C 36 B4
@UpdateSprite:
  LDA #$01                                ; $B42B: A9 01
  STA a:sprite_mode                             ; $B42D: 8D 12 00 ; refresh-sprite flag
  STY a:slot_param                             ; $B430: 8C 13 00 ; slot param
  JSR BattleCellRedraw                         ; $B433: 20 82 B8 ; strip sprite update
@NextSlot:
  INC btl_frame_counter                               ; $B436: EE 48 05 ; slot cursor +1
  LDA btl_frame_counter                               ; $B439: AD 48 05
  CMP #$0B                                ; $B43C: C9 0B
  BCC Phase9AdvanceReturn                 ; $B43E: 90 0A ; 11 slots not done
.endproc
;===============================================================================
; $B440: Phase9AdvanceFinish
; Shared advance-finish block (also the fall-through exit of
; Phase9AdvanceRosterSweep): re-enters the phase-8 row-effect dispatch at
; entry 3 ($0540 <- 8, $0541 <- 3).
;===============================================================================
.proc Phase9AdvanceFinish
  LDA #$08                                ; $B440: A9 08
  STA btl_overlay_phase                               ; $B442: 8D 40 05 ; phase <- 8
  LDA #$03                                ; $B445: A9 03
  STA btl_overlay_sub                               ; $B447: 8D 41 05 ; row-effect entry 3
.endproc
Phase9AdvanceReturn:
  RTS                                     ; $B44A: 60
;===============================================================================
; $B44B: Phase9AdvanceContactScan
; Contact-damage scan: converts the marker position $055A/$055B to tile
; coordinates ($001A row, $001B column) and scans the OPPOSING side's 11
; roster slots (side 0 -> slots $0B-$15, side 1 -> slots 0-$0A, cursor
; $001C); units within 2 tiles on both axes take contact damage
; (Phase9AdvanceContactApply).
;===============================================================================
.proc Phase9AdvanceContactScan
; zero-page work cells (proc-local):
marker_row     = $001A  ; marker tile row
marker_col     = $001B  ; marker tile column
slot_cursor    = $001C  ; opposing roster slot cursor
  LDA btl_advance_marker_row                               ; $B44B: AD 5A 05 ; marker row
  LSR                                     ; $B44E: 4A
  LSR                                     ; $B44F: 4A
  LSR                                     ; $B450: 4A
  LSR                                     ; $B451: 4A ; /16
  STA a:marker_row                             ; $B452: 8D 1A 00 ; marker tile row
  LDA btl_advance_marker_col                               ; $B455: AD 5B 05 ; marker column
  LSR                                     ; $B458: 4A
  LSR                                     ; $B459: 4A
  LSR                                     ; $B45A: 4A
  LSR                                     ; $B45B: 4A ; /16
  STA a:marker_col                             ; $B45C: 8D 1B 00 ; marker tile column
  LDY btl_acting_unit                               ; $B45F: AC 49 05 ; acting side
  BNE @ScanSideA                          ; $B462: D0 13
  LDA #$0B                                ; $B464: A9 0B ; opposing base (side B)
  STA a:slot_cursor                             ; $B466: 8D 1C 00 ; slot cursor
@ScanSideB:
  JSR Phase9AdvanceContactCheck           ; $B469: 20 8A B4
  INC a:slot_cursor                             ; $B46C: EE 1C 00
  LDA a:slot_cursor                             ; $B46F: AD 1C 00
  CMP #$16                                ; $B472: C9 16 ; 11 slots
  BCC @ScanSideB                          ; $B474: 90 F3
  RTS                                     ; $B476: 60
@ScanSideA:
  LDA #$00                                ; $B477: A9 00 ; opposing base (side A)
  STA a:slot_cursor                             ; $B479: 8D 1C 00 ; slot cursor
@ScanSideALoop:
  JSR Phase9AdvanceContactCheck           ; $B47C: 20 8A B4
  INC a:slot_cursor                             ; $B47F: EE 1C 00
  LDA a:slot_cursor                             ; $B482: AD 1C 00
  CMP #$0B                                ; $B485: C9 0B ; 11 slots
  BCC @ScanSideALoop                      ; $B487: 90 F3
  RTS                                     ; $B489: 60
.endproc
;===============================================================================
; $B48A: Phase9AdvanceContactCheck
; Proximity check for roster slot $001C: |unit row $0596 - marker row $001A|
; <= 2 and |unit column $0580 - marker column $001B| <= 2 (both via biased
; unsigned compare) triggers Phase9AdvanceContactApply.
;===============================================================================
.proc Phase9AdvanceContactCheck
; zero-page work cells (proc-local):
slot_cursor    = $001C  ; roster slot cursor
marker_row     = $001A  ; marker tile row
marker_col     = $001B  ; marker tile column
  LDY a:slot_cursor                             ; $B48A: AC 1C 00 ; slot cursor
  LDA btl_unit_row_a,Y                             ; $B48D: B9 96 05 ; unit row
  SEC                                     ; $B490: 38
  SBC a:marker_row                             ; $B491: ED 1A 00 ; - marker row
  CLC                                     ; $B494: 18
  ADC #$01                                ; $B495: 69 01 ; bias +1
  CMP #$03                                ; $B497: C9 03
  BCS @NoContact                          ; $B499: B0 0E ; row too far
  LDA btl_unit_col_a,Y                             ; $B49B: B9 80 05 ; unit column
  SEC                                     ; $B49E: 38
  SBC a:marker_col                             ; $B49F: ED 1B 00 ; - marker column
  CLC                                     ; $B4A2: 18
  ADC #$01                                ; $B4A3: 69 01 ; bias +1
  CMP #$03                                ; $B4A5: C9 03
  BCC Phase9AdvanceContactApply           ; $B4A7: 90 01 ; in contact
@NoContact:
  RTS                                     ; $B4A9: 60
.endproc
;===============================================================================
; $B4AA: Phase9AdvanceContactApply
; Applies the rolled contact damage (Phase9AdvanceDamageRoll result $0000)
; to unit troop count $05AC[$001C] (clamped at zero; on clamp the pre-damage troop count is
; reported instead), then feeds the damage into the acting-side strip
; buffer ($000A <- $0560[$0549], $000B <- damage, $000C <- 0) and exits
; through OfficerBattleExpLevelCheck at $D7FB.
;===============================================================================
.proc Phase9AdvanceContactApply
; zero-page work cells (proc-local):
slot_cursor    = $001C  ; roster slot cursor
damage         = $0000  ; contact damage dealt
troops_pre     = $0001  ; pre-damage troop count
writer_ptr     = $000A  ; strip writer buffer ptr
writer_damage  = $000B  ; writer param: damage
writer_pad     = $000C  ; writer param: 0
  JSR Phase9AdvanceDamageRoll             ; $B4AA: 20 E3 B4
  LDY a:slot_cursor                             ; $B4AD: AC 1C 00 ; slot cursor
  LDA btl_troops_a,Y                             ; $B4B0: B9 AC 05 ; unit troop count
  STA a:troops_pre                             ; $B4B3: 8D 01 00 ; old troop count
  SEC                                     ; $B4B6: 38
  SBC a:damage                             ; $B4B7: ED 00 00 ; - damage
  STA btl_troops_a,Y                             ; $B4BA: 99 AC 05 ; new troop count
  BEQ @StripUpdate                        ; $B4BD: F0 0D ; exactly zero
  BCS @StripUpdate                        ; $B4BF: B0 0B ; no underflow
  LDA #$00                                ; $B4C1: A9 00
  STA btl_troops_a,Y                             ; $B4C3: 99 AC 05 ; clamp at zero
  LDA a:troops_pre                             ; $B4C6: AD 01 00
  STA a:damage                             ; $B4C9: 8D 00 00 ; report old troop count
@StripUpdate:
  LDA a:damage                             ; $B4CC: AD 00 00 ; damage dealt
  STA a:writer_damage                             ; $B4CF: 8D 0B 00
  LDA #$00                                ; $B4D2: A9 00
  STA a:writer_pad                             ; $B4D4: 8D 0C 00
  LDY btl_acting_unit                               ; $B4D7: AC 49 05 ; acting side
  LDA btl_strip_buf_a,Y                             ; $B4DA: B9 60 05 ; strip buffer ptr lo
  STA a:writer_ptr                             ; $B4DD: 8D 0A 00
  JMP OfficerBattleExpLevelCheck          ; $B4E0: 4C FB D7 ; exp accrual/level-up
.endproc
;===============================================================================
; $B4E3: Phase9AdvanceDamageRoll
; Contact-damage roll for slot $001C. Base damage = B1F_RandomBelowThreshold
; ($0A) + 2 subtracted from the acting-side officer record byte +2 (via
; B1F_GetOfficerRecordAddr on $0560[$0549]), clamped at zero then +1 (so
; 1..12). Commander slots (0 and $0B) take half damage; roster unit type 1
; ($05C2 low nibble) takes one third via B1F_MathDiv16 doubled. Result in
; $0000.
;===============================================================================
.proc Phase9AdvanceDamageRoll
; zero-page work cells (proc-local):
damage_work    = $0000  ; damage roll -> base damage -> third share
rec_ptr_lo     = $0000  ; officer record ptr lo (record byte 2 max)
dividend_lo    = $0001  ; MathDiv16 dividend lo
dividend_hi    = $0002  ; dividend hi (0)
divisor_lo     = $0003  ; divisor lo (3)
divisor_hi     = $0004  ; divisor hi (0)
slot_cursor    = $001C  ; roster slot cursor
  LDY btl_acting_unit                               ; $B4E3: AC 49 05 ; acting side
  LDA btl_strip_buf_a,Y                             ; $B4E6: B9 60 05 ; officer id
  JSR B1F_GetOfficerRecordAddr            ; $B4E9: 20 D7 F2 ; ($00) <- record
  LDY #$02                                ; $B4EC: A0 02
  LDA (rec_ptr_lo),Y                             ; $B4EE: B1 00 ; record byte 2 (max)
  PHA                                     ; $B4F0: 48
  LDA #$0A                                ; $B4F1: A9 0A
  JSR B1F_RandomBelowThreshold            ; $B4F3: 20 62 E8 ; rand [0,$0A)
  CLC                                     ; $B4F6: 18
  ADC #$02                                ; $B4F7: 69 02 ; rand +2
  STA a:damage_work                             ; $B4F9: 8D 00 00 ; damage roll
  PLA                                     ; $B4FC: 68
  SEC                                     ; $B4FD: 38
  SBC a:damage_work                             ; $B4FE: ED 00 00 ; max - roll
  BCS @ClampDone                          ; $B501: B0 02
  LDA #$00                                ; $B503: A9 00 ; clamp at zero
@ClampDone:
  CLC                                     ; $B505: 18
  ADC #$01                                ; $B506: 69 01 ; min damage 1
  STA a:damage_work                             ; $B508: 8D 00 00 ; base damage
  LDY a:slot_cursor                             ; $B50B: AC 1C 00 ; slot cursor
  BEQ @CommanderSlot                      ; $B50E: F0 10 ; slot 0
  CPY #$0B                                ; $B510: C0 0B
  BEQ @CommanderSlot                      ; $B512: F0 0C ; slot $0B
  LDA btl_roster_code_a,Y                             ; $B514: B9 C2 05 ; roster entry
  AND #$0F                                ; $B517: 29 0F ; unit type
  CMP #$01                                ; $B519: C9 01
  BEQ @Type1Unit                          ; $B51B: F0 0D
  JMP @DamageDone                         ; $B51D: 4C 47 B5 ; type != 1: as-is
@CommanderSlot:
  LDA a:damage_work                             ; $B520: AD 00 00
  LSR                                     ; $B523: 4A ; halve
  STA a:damage_work                             ; $B524: 8D 00 00
  JMP @DamageDone                         ; $B527: 4C 47 B5
@Type1Unit:
  LDA a:damage_work                             ; $B52A: AD 00 00
  STA a:dividend_lo                             ; $B52D: 8D 01 00 ; dividend
  LDA #$03                                ; $B530: A9 03
  STA a:divisor_lo                             ; $B532: 8D 03 00 ; divisor
  LDA #$00                                ; $B535: A9 00
  STA a:dividend_hi                             ; $B537: 8D 02 00 ; dividend hi
  STA a:divisor_hi                             ; $B53A: 8D 04 00
  JSR B1F_MathDiv16                       ; $B53D: 20 7C EA ; /3
  LDA a:dividend_lo                             ; $B540: AD 01 00 ; quotient
  ASL                                     ; $B543: 0A ; x2
  STA a:damage_work                             ; $B544: 8D 00 00
@DamageDone:
  RTS                                     ; $B547: 60
.endproc
;===============================================================================
; $B548: BattleRosterSetup
; Builds the battle rosters of both sides from the side officer ids $0560
; (side A) and $0561 (side B); called from Phase7BattleModeStart at battle
; start. First
; clears the $58-byte roster block $0580-$05D7 with $FF (unit columns
; $0580/$058B, unit rows $0596/$05A1, roster codes $05C2/$05CD, column troop count
; $05AD/$05B8, side troop counts $05AC/$05B7).
; Per side, with the officer record via B1F_GetOfficerRecordAddr:
;   - record field [0] -> side troop count ($05AC/$05B7);
;   - troop count = record fields [9]:[8]: column count = ceil(troops/100)
;     ($0566/$0567), then the troop count is split into per-column troop count
;     ($05AD/$05B8): the first (troops mod count) columns get the ceil
;     share, the rest the floor share;
;   - unit-class composition from the grade of record field [1]
;     (>= $50 -> grade 0, >= $32 -> grade 1, else grade 2) and the
;     rank/aptitude record field [$B]>>4 via BattleUnitGradeLimitTable:
;     slot 0 is the commander (roster code $30/$20), slots below bound 1
;     are class 3 ($33/$23), below bound 2 class 2 ($32/$22), the rest
;     class 1 ($31/$21); roster codes go to $05C2/$05CD (high nibble =
;     side: 3 = A, 2 = B);
;   - unit placement from BattleFormationPtrTable: side A uses layout
;     index i = $056C & 3 (columns entry i -> $0580, rows entry i+6 ->
;     $0596); side B uses i = $056D & 3 and mirrors the columns
;     ($058B <- $0F - col, rows -> $05A1). In battle phase 5
;     ($0544 == 5) side B uses the fixed index 4 with dedicated layouts:
;     class-2 slots take entries 4/10, all other slots entries 5/11, and
;     the class-3 bound is zeroed (no $23 units).
;===============================================================================
.proc BattleRosterSetup
; zero-page work cells (proc-local):
rec_ptr        = $0000  ; officer record ptr lo (indirect field reads)
div_work_lo    = $0001  ; dividend/share/bound work lo
div_work_hi    = $0002  ; dividend hi / class-2 bound
class2_bound   = $0002  ; class-2 slot bound
divisor_lo     = $0003  ; MathDiv16 divisor lo
divisor_hi     = $0004  ; divisor hi (0)
remainder      = $0005  ; division remainder
grade_work     = $0000  ; grade index g (n*4 + g)
slot_base      = $0000  ; commander-relative slot base
slot_count     = $0000  ; slot count bound
col_layout_lo  = $000A  ; formation column layout ptr lo
col_layout_hi  = $000B  ; column layout ptr hi
row_layout_lo  = $000C  ; formation row layout ptr lo
row_layout_hi  = $000D  ; row layout ptr hi
mirror_ofs     = $0003  ; column mirror offset (side B)
siege_col_ptr_lo = $001A  ; siege column layout ptr lo (i+1)
siege_col_ptr_hi = $001B  ; siege column layout ptr hi
siege_row_ptr_lo = $001C  ; siege row layout ptr lo (i+7)
siege_row_ptr_hi = $001D  ; siege row layout ptr hi
  LDY #$57                                ; $B548: A0 57 ; roster block size-1
  LDA #$FF                                ; $B54A: A9 FF ; empty marker
@ClearLoop:
  STA btl_unit_col_a,Y                             ; $B54C: 99 80 05
  DEY                                     ; $B54F: 88
  BPL @ClearLoop                          ; $B550: 10 FA
; --- Side A: officer record, troop count and column count ---
  LDA btl_strip_buf_a                               ; $B552: AD 60 05 ; side A officer id
  JSR B1F_GetOfficerRecordAddr            ; $B555: 20 D7 F2 ; record ptr -> ($00)
  LDY #$00                                ; $B558: A0 00
  LDA (rec_ptr),Y                             ; $B55A: B1 00 ; record field [0]
  STA btl_troops_a                               ; $B55C: 8D AC 05 ; side A troop count
  LDY #$0B                                ; $B55F: A0 0B
  LDA (rec_ptr),Y                             ; $B561: B1 00 ; field [$B] rank/aptitude
  PHA                                     ; $B563: 48 ; save for class lookup
  LDY #$01                                ; $B564: A0 01
  LDA (rec_ptr),Y                             ; $B566: B1 00 ; field [1] grade stat
  PHA                                     ; $B568: 48 ; save for grade check
  LDY #$09                                ; $B569: A0 09
  LDA (rec_ptr),Y                             ; $B56B: B1 00 ; troops hi
  PHA                                     ; $B56D: 48
  STA a:div_work_hi                             ; $B56E: 8D 02 00 ; dividend hi
  DEY                                     ; $B571: 88
  LDA (rec_ptr),Y                             ; $B572: B1 00 ; troops lo
  PHA                                     ; $B574: 48
  STA a:div_work_lo                             ; $B575: 8D 01 00 ; dividend lo
  LDA #$64                                ; $B578: A9 64 ; divisor <- 100
  STA a:divisor_lo                             ; $B57A: 8D 03 00
  LDA #$00                                ; $B57D: A9 00
  STA a:divisor_hi                             ; $B57F: 8D 04 00
  JSR B1F_MathDiv16                       ; $B582: 20 7C EA ; troops / 100
  LDA a:remainder                             ; $B585: AD 05 00 ; remainder
  BEQ @SideAColsDone                      ; $B588: F0 03
  INC a:div_work_lo                             ; $B58A: EE 01 00 ; round up
@SideAColsDone:
  LDA a:div_work_lo                             ; $B58D: AD 01 00 ; column count
  STA btl_col_count_a                               ; $B590: 8D 66 05 ; side A column count
  STA a:divisor_lo                             ; $B593: 8D 03 00 ; divisor <- count
  PLA                                     ; $B596: 68 ; troops lo
  STA a:div_work_lo                             ; $B597: 8D 01 00 ; dividend lo
  PLA                                     ; $B59A: 68 ; troops hi
  STA a:div_work_hi                             ; $B59B: 8D 02 00 ; dividend hi
  LDA #$00                                ; $B59E: A9 00
  STA a:divisor_hi                             ; $B5A0: 8D 04 00
  JSR B1F_MathDiv16                       ; $B5A3: 20 7C EA ; troops / count
  LDY #$00                                ; $B5A6: A0 00
  INC a:div_work_lo                             ; $B5A8: EE 01 00 ; ceil share
  LDA a:div_work_lo                             ; $B5AB: AD 01 00 ; troop count share
@SideATroopCountFill:
  CPY a:remainder                             ; $B5AE: CC 05 00 ; remainder
  BCS @SideATroopCountTail                        ; $B5B1: B0 0B ; Y >= r: floor share
  STA $05AD,Y                             ; $B5B3: 99 AD 05 ; ceil share
  INY                                     ; $B5B6: C8
  CPY btl_col_count_a                               ; $B5B7: CC 66 05 ; column count
  BCC @SideATroopCountFill                        ; $B5BA: 90 F2
  BCS @SideAFormation                     ; $B5BC: B0 0C ; always: columns done
@SideATroopCountTail:
  SEC                                     ; $B5BE: 38
  SBC #$01                                ; $B5BF: E9 01 ; floor share
@SideATroopCountTailLoop:
  STA $05AD,Y                             ; $B5C1: 99 AD 05
  INY                                     ; $B5C4: C8
  CPY btl_col_count_a                               ; $B5C5: CC 66 05
  BCC @SideATroopCountTailLoop                    ; $B5C8: 90 F7
; --- Side A: formation layout and unit-class bounds ---
@SideAFormation:
  LDA btl_formation_a                               ; $B5CA: AD 6C 05 ; formation random
  AND #$03                                ; $B5CD: 29 03 ; layout index 0-3
  ASL                                     ; $B5CF: 0A ; -> word offset
  TAY                                     ; $B5D0: A8
  LDA BattleFormationPtrTable,Y           ; $B5D1: B9 94 B7 ; col layout ptr lo
  STA a:col_layout_lo                             ; $B5D4: 8D 0A 00
  LDA BattleFormationPtrTable+1,Y         ; $B5D7: B9 95 B7 ; col layout ptr hi
  STA a:col_layout_hi                             ; $B5DA: 8D 0B 00
  LDA BattleFormationPtrTable+$0C,Y       ; $B5DD: B9 A0 B7 ; row layout ptr lo
  STA a:row_layout_lo                             ; $B5E0: 8D 0C 00
  LDA BattleFormationPtrTable+$0D,Y       ; $B5E3: B9 A1 B7 ; row layout ptr hi
  STA a:row_layout_hi                             ; $B5E6: 8D 0D 00
  LDY #$00                                ; $B5E9: A0 00
  PLA                                     ; $B5EB: 68 ; record field [1]
  CMP #$50                                ; $B5EC: C9 50 ; >= $50: grade 0
  BCS @SideAGradeDone                     ; $B5EE: B0 06
  INY                                     ; $B5F0: C8 ; grade 1
  CMP #$32                                ; $B5F1: C9 32 ; >= $32: grade 1
  BCS @SideAGradeDone                     ; $B5F3: B0 01
  INY                                     ; $B5F5: C8 ; grade 2
@SideAGradeDone:
  STY a:grade_work                             ; $B5F6: 8C 00 00 ; grade g
  PLA                                     ; $B5F9: 68 ; record field [$B]
  LSR                                     ; $B5FA: 4A
  LSR                                     ; $B5FB: 4A
  LSR                                     ; $B5FC: 4A
  LSR                                     ; $B5FD: 4A ; >>4: rank/aptitude n
  ASL                                     ; $B5FE: 0A
  ASL                                     ; $B5FF: 0A ; n * 4
  ORA a:grade_work                             ; $B600: 0D 00 00 ; n*4 + g
  ASL                                     ; $B603: 0A ; -> word offset
  TAY                                     ; $B604: A8
  LDA BattleUnitGradeLimitTable,Y         ; $B605: B9 AC B7 ; class-3 bound
  STA a:div_work_lo                             ; $B608: 8D 01 00
  LDA BattleUnitGradeLimitTable+1,Y       ; $B60B: B9 AD B7 ; class-2 bound
  STA a:div_work_hi                             ; $B60E: 8D 02 00
; --- Side A: roster codes and unit placement ---
  LDA btl_col_count_a                               ; $B611: AD 66 05 ; column count
  STA a:slot_base                             ; $B614: 8D 00 00
  INC a:slot_base                             ; $B617: EE 00 00 ; + commander slot
  LDY #$00                                ; $B61A: A0 00
@SideARosterLoop:
  LDA #$30                                ; $B61C: A9 30 ; commander (side A)
  CPY #$00                                ; $B61E: C0 00
  BEQ @SideARosterStore                   ; $B620: F0 10 ; slot 0
  LDA #$33                                ; $B622: A9 33 ; class 3
  CPY a:div_work_lo                             ; $B624: CC 01 00 ; class-3 bound
  BCC @SideARosterStore                   ; $B627: 90 09
  LDA #$32                                ; $B629: A9 32 ; class 2
  CPY a:div_work_hi                             ; $B62B: CC 02 00 ; class-2 bound
  BCC @SideARosterStore                   ; $B62E: 90 02
  LDA #$31                                ; $B630: A9 31 ; class 1
@SideARosterStore:
  STA btl_roster_code_a,Y                             ; $B632: 99 C2 05 ; roster code
  LDA (col_layout_lo),Y                             ; $B635: B1 0A ; col layout entry
  STA btl_unit_col_a,Y                             ; $B637: 99 80 05 ; unit column
  LDA (row_layout_lo),Y                             ; $B63A: B1 0C ; row layout entry
  STA btl_unit_row_a,Y                             ; $B63C: 99 96 05 ; unit row
  INY                                     ; $B63F: C8
  CPY a:slot_count                             ; $B640: CC 00 00 ; slot count
  BCC @SideARosterLoop                    ; $B643: 90 D7
; --- Side B: officer record, troop count and column count ---
  LDA btl_strip_buf_b                               ; $B645: AD 61 05 ; side B officer id
  JSR B1F_GetOfficerRecordAddr            ; $B648: 20 D7 F2 ; record ptr -> ($00)
  LDY #$00                                ; $B64B: A0 00
  LDA (rec_ptr),Y                             ; $B64D: B1 00 ; record field [0]
  STA btl_troops_b                               ; $B64F: 8D B7 05 ; side B troop count
  LDY #$0B                                ; $B652: A0 0B
  LDA (rec_ptr),Y                             ; $B654: B1 00 ; field [$B] rank/aptitude
  PHA                                     ; $B656: 48 ; save for class lookup
  LDY #$01                                ; $B657: A0 01
  LDA (rec_ptr),Y                             ; $B659: B1 00 ; field [1] grade stat
  PHA                                     ; $B65B: 48 ; save for grade check
  LDY #$09                                ; $B65C: A0 09
  LDA (rec_ptr),Y                             ; $B65E: B1 00 ; troops hi
  PHA                                     ; $B660: 48
  STA a:div_work_hi                             ; $B661: 8D 02 00 ; dividend hi
  DEY                                     ; $B664: 88
  LDA (rec_ptr),Y                             ; $B665: B1 00 ; troops lo
  PHA                                     ; $B667: 48
  STA a:div_work_lo                             ; $B668: 8D 01 00 ; dividend lo
  LDA #$64                                ; $B66B: A9 64 ; divisor <- 100
  STA a:divisor_lo                             ; $B66D: 8D 03 00
  LDA #$00                                ; $B670: A9 00
  STA a:divisor_hi                             ; $B672: 8D 04 00
  JSR B1F_MathDiv16                       ; $B675: 20 7C EA ; troops / 100
  LDA a:remainder                             ; $B678: AD 05 00 ; remainder
  BEQ @SideBColsDone                      ; $B67B: F0 03
  INC a:div_work_lo                             ; $B67D: EE 01 00 ; round up
@SideBColsDone:
  LDA a:div_work_lo                             ; $B680: AD 01 00 ; column count
  STA btl_col_count_b                               ; $B683: 8D 67 05 ; side B column count
  STA a:divisor_lo                             ; $B686: 8D 03 00 ; divisor <- count
  PLA                                     ; $B689: 68 ; troops lo
  STA a:div_work_lo                             ; $B68A: 8D 01 00 ; dividend lo
  PLA                                     ; $B68D: 68 ; troops hi
  STA a:div_work_hi                             ; $B68E: 8D 02 00 ; dividend hi
  LDA #$00                                ; $B691: A9 00
  STA a:divisor_hi                             ; $B693: 8D 04 00
  JSR B1F_MathDiv16                       ; $B696: 20 7C EA ; troops / count
  LDY #$00                                ; $B699: A0 00
  INC a:div_work_lo                             ; $B69B: EE 01 00 ; ceil share
  LDA a:div_work_lo                             ; $B69E: AD 01 00 ; troop count share
@SideBTroopCountFill:
  CPY a:remainder                             ; $B6A1: CC 05 00 ; remainder
  BCS @SideBTroopCountTail                        ; $B6A4: B0 0B ; Y >= r: floor share
  STA $05B8,Y                             ; $B6A6: 99 B8 05 ; ceil share
  INY                                     ; $B6A9: C8
  CPY btl_col_count_b                               ; $B6AA: CC 67 05 ; column count
  BCC @SideBTroopCountFill                        ; $B6AD: 90 F2
  BCS @SideBFormation                     ; $B6AF: B0 0C ; always: columns done
@SideBTroopCountTail:
  SEC                                     ; $B6B1: 38
  SBC #$01                                ; $B6B2: E9 01 ; floor share
@SideBTroopCountTailLoop:
  STA $05B8,Y                             ; $B6B4: 99 B8 05
  INY                                     ; $B6B7: C8
  CPY btl_col_count_b                               ; $B6B8: CC 67 05
  BCC @SideBTroopCountTailLoop                    ; $B6BB: 90 F7
; --- Side B: formation layouts and unit-class bounds ---
@SideBFormation:
  LDA #$04                                ; $B6BD: A9 04 ; siege layout index
  LDY battle_phase                               ; $B6BF: AC 44 05 ; battle phase
  CPY #$05                                ; $B6C2: C0 05
  BEQ @SideBLayoutLoad                    ; $B6C4: F0 05 ; phase 5: fixed index 4
  LDA btl_formation_b                               ; $B6C6: AD 6D 05 ; formation random
  AND #$03                                ; $B6C9: 29 03 ; layout index 0-3
@SideBLayoutLoad:
  ASL                                     ; $B6CB: 0A ; -> word offset
  TAY                                     ; $B6CC: A8
  LDA BattleFormationPtrTable,Y           ; $B6CD: B9 94 B7 ; col layout ptr lo
  STA a:col_layout_lo                             ; $B6D0: 8D 0A 00
  LDA BattleFormationPtrTable+1,Y         ; $B6D3: B9 95 B7 ; col layout ptr hi
  STA a:col_layout_hi                             ; $B6D6: 8D 0B 00
  LDA BattleFormationPtrTable+$0C,Y       ; $B6D9: B9 A0 B7 ; row layout ptr lo
  STA a:row_layout_lo                             ; $B6DC: 8D 0C 00
  LDA BattleFormationPtrTable+$0D,Y       ; $B6DF: B9 A1 B7 ; row layout ptr hi
  STA a:row_layout_hi                             ; $B6E2: 8D 0D 00
  LDA BattleFormationPtrTable+2,Y         ; $B6E5: B9 96 B7 ; siege col ptr lo (i+1)
  STA a:siege_col_ptr_lo                             ; $B6E8: 8D 1A 00
  LDA BattleFormationPtrTable+3,Y         ; $B6EB: B9 97 B7 ; siege col ptr hi (i+1)
  STA a:siege_col_ptr_hi                             ; $B6EE: 8D 1B 00
  LDA BattleFormationPtrTable+$0E,Y       ; $B6F1: B9 A2 B7 ; siege row ptr lo (i+7)
  STA a:siege_row_ptr_lo                             ; $B6F4: 8D 1C 00
  LDA BattleFormationPtrTable+$0F,Y       ; $B6F7: B9 A3 B7 ; siege row ptr hi (i+7)
  STA a:siege_row_ptr_hi                             ; $B6FA: 8D 1D 00
  LDY #$00                                ; $B6FD: A0 00
  PLA                                     ; $B6FF: 68 ; record field [1]
  CMP #$50                                ; $B700: C9 50 ; >= $50: grade 0
  BCS @SideBGradeDone                     ; $B702: B0 06
  INY                                     ; $B704: C8 ; grade 1
  CMP #$32                                ; $B705: C9 32 ; >= $32: grade 1
  BCS @SideBGradeDone                     ; $B707: B0 01
  INY                                     ; $B709: C8 ; grade 2
@SideBGradeDone:
  STY a:grade_work                             ; $B70A: 8C 00 00 ; grade g
  PLA                                     ; $B70D: 68 ; record field [$B]
  LSR                                     ; $B70E: 4A
  LSR                                     ; $B70F: 4A
  LSR                                     ; $B710: 4A
  LSR                                     ; $B711: 4A ; >>4: rank/aptitude n
  ASL                                     ; $B712: 0A
  ASL                                     ; $B713: 0A ; n * 4
  ORA a:grade_work                             ; $B714: 0D 00 00 ; n*4 + g
  ASL                                     ; $B717: 0A ; -> word offset
  TAY                                     ; $B718: A8
  LDA BattleUnitGradeLimitTable,Y         ; $B719: B9 AC B7 ; class-3 bound
  STA a:div_work_lo                             ; $B71C: 8D 01 00
  LDA BattleUnitGradeLimitTable+1,Y       ; $B71F: B9 AD B7 ; class-2 bound
  STA a:div_work_hi                             ; $B722: 8D 02 00
  LDA battle_phase                               ; $B725: AD 44 05 ; battle phase
  CMP #$05                                ; $B728: C9 05
  BNE @SideBBoundsDone                    ; $B72A: D0 05
  LDA #$00                                ; $B72C: A9 00 ; phase 5: no class 3
  STA a:div_work_lo                             ; $B72E: 8D 01 00
; --- Side B: roster codes and unit placement ---
@SideBBoundsDone:
  LDA btl_col_count_b                               ; $B731: AD 67 05 ; column count
  STA a:slot_base                             ; $B734: 8D 00 00
  INC a:slot_base                             ; $B737: EE 00 00 ; + commander slot
  LDY #$00                                ; $B73A: A0 00
@SideBRosterLoop:
  LDA #$20                                ; $B73C: A9 20 ; commander (side B)
  CPY #$00                                ; $B73E: C0 00
  BEQ @SideBRosterStore                   ; $B740: F0 10 ; slot 0
  LDA #$23                                ; $B742: A9 23 ; class 3
  CPY a:div_work_lo                             ; $B744: CC 01 00 ; class-3 bound
  BCC @SideBRosterStore                   ; $B747: 90 09
  LDA #$22                                ; $B749: A9 22 ; class 2
  CPY a:class2_bound                             ; $B74B: CC 02 00 ; class-2 bound
  BCC @SideBRosterStore                   ; $B74E: 90 02
  LDA #$21                                ; $B750: A9 21 ; class 1
@SideBRosterStore:
  STA $05CD,Y                             ; $B752: 99 CD 05 ; roster code
  CMP #$22                                ; $B755: C9 22 ; class 2 code?
  BEQ @SideBPlaceShared                   ; $B757: F0 21 ; -> index-i layouts
  LDA battle_phase                               ; $B759: AD 44 05 ; battle phase
  CMP #$05                                ; $B75C: C9 05
  BNE @SideBPlaceShared                   ; $B75E: D0 1A ; not phase 5: shared
  LDA ($1A),Y                             ; $B760: B1 1A ; siege col layout entry
  STA a:mirror_ofs                             ; $B762: 8D 03 00
  LDA #$0F                                ; $B765: A9 0F
  SEC                                     ; $B767: 38
  SBC a:mirror_ofs                             ; $B768: ED 03 00 ; mirror column
  STA btl_unit_col_b,Y                             ; $B76B: 99 8B 05 ; unit column
  LDA ($1C),Y                             ; $B76E: B1 1C ; siege row layout entry
  STA btl_unit_row_b,Y                             ; $B770: 99 A1 05 ; unit row
  INY                                     ; $B773: C8
  CPY a:slot_count                             ; $B774: CC 00 00 ; slot count
  BCC @SideBRosterLoop                    ; $B777: 90 C3
  RTS                                     ; $B779: 60
@SideBPlaceShared:
  LDA (col_layout_lo),Y                             ; $B77A: B1 0A ; col layout entry
  STA a:mirror_ofs                             ; $B77C: 8D 03 00
  LDA #$0F                                ; $B77F: A9 0F
  SEC                                     ; $B781: 38
  SBC a:mirror_ofs                             ; $B782: ED 03 00 ; mirror column
  STA btl_unit_col_b,Y                             ; $B785: 99 8B 05 ; unit column
  LDA (row_layout_lo),Y                             ; $B788: B1 0C ; row layout entry
  STA btl_unit_row_b,Y                             ; $B78A: 99 A1 05 ; unit row
  INY                                     ; $B78D: C8
  CPY a:slot_count                             ; $B78E: CC 00 00 ; slot count
  BCC @SideBRosterLoop                    ; $B791: 90 A9
  RTS                                     ; $B793: 60
.endproc
;===============================================================================
; Battle roster data tables ($B794-$B86F), used by BattleRosterSetup
;===============================================================================
; --- Formation placement pointer table ----------------------------------------
; 12 pointers to the 11-byte placement layouts below: entries 0-5 select
; column layouts ($0580/$058B), entries 6-11 row layouts ($0596/$05A1).
; Side A uses entries i / i+6 with i = $056C & 3; side B entries i / i+6
; with i = $056D & 3 (columns mirrored); battle phase 5 forces side B
; to index 4, where class-2 slots use entries 4/10 and all other slots
; entries 5/11.
BattleFormationPtrTable:
  .word BattleFormationCols_0             ; $B794: EC B7 ; entry 0 -> $B7EC
  .word BattleFormationCols_1             ; $B796: F7 B7 ; entry 1 -> $B7F7
  .word BattleFormationCols_2             ; $B798: 02 B8 ; entry 2 -> $B802
  .word BattleFormationCols_3             ; $B79A: 0D B8 ; entry 3 -> $B80D
  .word BattleFormationCols_4             ; $B79C: 18 B8 ; entry 4 -> $B818 (phase 5, class 2)
  .word BattleFormationCols_5             ; $B79E: 23 B8 ; entry 5 -> $B823 (phase 5, other)
  .word BattleFormationRows_0             ; $B7A0: 2E B8 ; entry 6 -> $B82E
  .word BattleFormationRows_1             ; $B7A2: 39 B8 ; entry 7 -> $B839
  .word BattleFormationRows_2             ; $B7A4: 44 B8 ; entry 8 -> $B844
  .word BattleFormationRows_3             ; $B7A6: 4F B8 ; entry 9 -> $B84F
  .word BattleFormationRows_4             ; $B7A8: 5A B8 ; entry 10 -> $B85A (phase 5, class 2)
  .word BattleFormationRows_5             ; $B7AA: 65 B8 ; entry 11 -> $B865 (phase 5, other)
; --- Unit-class composition bounds ---------------------------------------------
; Byte pairs (class-3 bound, class-2 bound), exclusive roster-slot bounds,
; indexed by ((rank << 2) | grade) * 2 with rank = record field [$B]>>4 and
; grade from record field [1] (>= $50 -> 0, >= $32 -> 1, else 2). Slot 0 is
; always the commander; slots below bound 1 are class 3, below bound 2
; class 2, the rest class 1. Every fourth pair (grade 3) is zero padding.
BattleUnitGradeLimitTable:
  .byte $06,$09,$08,$0A,$08,$0B,$00,$00 ; $B7AC: rank 0, grades 0-2 + pad
  .byte $05,$09,$07,$0A,$07,$0B,$00,$00 ; $B7B4: rank 1, grades 0-2 + pad
  .byte $05,$08,$06,$09,$06,$0A,$00,$00 ; $B7BC: rank 2, grades 0-2 + pad
  .byte $04,$07,$05,$08,$06,$09,$00,$00 ; $B7C4: rank 3, grades 0-2 + pad
  .byte $03,$06,$04,$08,$05,$09,$00,$00 ; $B7CC: rank 4, grades 0-2 + pad
  .byte $02,$06,$04,$07,$04,$08,$00,$00 ; $B7D4: rank 5, grades 0-2 + pad
  .byte $02,$05,$03,$06,$04,$07,$00,$00 ; $B7DC: rank 6, grades 0-2 + pad
  .byte $01,$05,$02,$06,$03,$07,$00,$00 ; $B7E4: rank 7, grades 0-2 + pad
; --- Column placement layouts (one tile column per roster slot, 11 bytes) -----
BattleFormationCols_0:
  .byte $01,$02,$02,$02,$03,$03,$03,$04,$04,$05,$03 ; $B7EC
BattleFormationCols_1:
  .byte $01,$04,$04,$02,$02,$03,$03,$04,$04,$05,$05 ; $B7F7
BattleFormationCols_2:
  .byte $01,$03,$02,$02,$02,$02,$03,$03,$04,$04,$05 ; $B802
BattleFormationCols_3:
  .byte $01,$02,$02,$03,$03,$03,$04,$04,$05,$05,$05 ; $B80D
BattleFormationCols_4:
  .byte $01,$03,$03,$08,$08,$06,$06,$07,$07,$07,$07 ; $B818
BattleFormationCols_5:
  .byte $01,$03,$03,$08,$08,$01,$01,$03,$03,$02,$02 ; $B823
; --- Row placement layouts (one tile row per roster slot, 11 bytes) -----------
BattleFormationRows_0:
  .byte $05,$01,$02,$03,$04,$05,$06,$07,$08,$09,$09 ; $B82E
BattleFormationRows_1:
  .byte $05,$04,$06,$04,$06,$03,$07,$02,$08,$01,$09 ; $B839
BattleFormationRows_2:
  .byte $05,$05,$04,$06,$02,$08,$03,$07,$04,$06,$05 ; $B844
BattleFormationRows_3:
  .byte $05,$04,$06,$03,$05,$07,$04,$06,$03,$05,$07 ; $B84F
BattleFormationRows_4:
  .byte $05,$04,$06,$02,$08,$02,$08,$01,$09,$02,$08 ; $B85A
BattleFormationRows_5:
  .byte $05,$04,$06,$02,$08,$03,$07,$02,$08,$01,$09 ; $B865
;===============================================================================
; $B870: BattleAnimQueueIdleCheck
; Returns the battle animation queue status in the carry: C=1 when both
; queue slot headers $0300 (slot 0) and $0304 (slot 1) hold $FF (empty),
; C=0 while either slot still runs an animation. Callers poll this before
; enqueuing new tile/panel work (intro roster walk, phase 2-4 handlers).
;===============================================================================
.proc BattleAnimQueueIdleCheck
  LDA anim_queue_hdr1                               ; $B870: AD 04 03 ; queue slot 1 header
  CMP #$FF                                ; $B873: C9 FF
  BNE @Busy                               ; $B875: D0 09 ; slot 1 active
  LDA anim_queue_hdr0                               ; $B877: AD 00 03 ; queue slot 0 header
  CMP #$FF                                ; $B87A: C9 FF
  BNE @Busy                               ; $B87C: D0 02 ; slot 0 active
  SEC                                     ; $B87E: 38 ; both empty
  RTS                                     ; $B87F: 60
@Busy:
  CLC                                     ; $B880: 18 ; queue running
  RTS                                     ; $B881: 60
.endproc
;===============================================================================
; $B882: BattleCellRedraw
; Rebuilds the battlefield cell of roster slot $0013 as a queued dual-
; nametable PPU update record ($0380-$039C, $FF-terminated) and raises
; $007E bit 2 so the NMI handler transfers it. Parameters: $0012 mode
; (0 = plain terrain redraw, skipping the target slot's own occupancy
; bit; nonzero = highlight render with status tiles + troop count digit overlay),
; $0013 roster slot (0-$15; column $0580[Y], row $0596[Y]).
; Flow: switch the $8000 map bank for battle phase $0544, fetch the
; map tile at (row,col) from the phase map table, expand it to a 2x2 tile
; pattern via the phase pattern table, compute the nametable addresses of
; the 2x2 cell on both screens, optionally overlay status highlight tiles
; (BattleCellHighlightTiles) and troop count digits (BattleCellTroopCountDigitOverlay),
; merge the adjacency occupancy bits (BattleCellAdjacencyScan) into the
; attribute bytes, and terminate the record.
;===============================================================================
.proc BattleCellRedraw
; zero-page work cells (proc-local):
roster_slot    = $0013  ; roster slot index (Y param)
cell_col       = $0010  ; unit battlefield column
cell_row       = $0011  ; unit battlefield row
map_ptr        = $0000  ; battlefield cell map ptr (indirect)
map_ptr_hi     = $0001  ; map ptr hi
pattern_ptr    = $0002  ; 2x2 tile pattern ptr lo
pattern_ptr_hi = $0003  ; pattern ptr hi
tile_offset_hi = $0004  ; tile offset high byte
col_x2         = $0008  ; column * 2 work (VRAM addr / attr offset)
addr_hi_work   = $000B  ; VRAM address high work byte
highlight      = $0012  ; highlight pass flag (nonzero = status tiles)
attr_ptr       = $0000  ; attribute table ptr (indirect)
attr_ptr_hi    = $0001  ; attribute table ptr hi
attr_index     = $0000  ; status index (slot * 4 + state)
attr_work      = $0000  ; attribute work byte
attr_ofs       = $0000  ; attribute cell offset
  LDY a:roster_slot                             ; $B882: AC 13 00 ; roster slot
  LDA btl_unit_col_a,Y                             ; $B885: B9 80 05 ; unit column
  STA a:cell_col                             ; $B888: 8D 10 00
  LDA btl_unit_row_a,Y                             ; $B88B: B9 96 05 ; unit row
  STA a:cell_row                             ; $B88E: 8D 11 00
  LDA battle_phase                               ; $B891: AD 44 05 ; battle phase
  PHA                                     ; $B894: 48 ; (copy 2: attribute pass)
  PHA                                     ; $B895: 48 ; (copy 1: pattern pass)
  TAY                                     ; $B896: A8
  LDA BattleCellMapBankTable,Y            ; $B897: B9 48 BB ; $8000 bank for phase
  TAY                                     ; $B89A: A8
  JSR B1F_SwitchBank8_B                   ; $B89B: 20 5F F2 ; switch $8000 slot B
  PLA                                     ; $B89E: 68 ; phase (copy 1)
  ASL                                     ; $B89F: 0A ; phase * 2 (word index)
  TAY                                     ; $B8A0: A8
  LDA BattleCellMapPtrTable,Y             ; $B8A1: B9 1E BB ; phase map table lo
  STA a:map_ptr                             ; $B8A4: 8D 00 00
  LDA BattleCellMapPtrTable+1,Y           ; $B8A7: B9 1F BB ; phase map table hi
  STA a:map_ptr_hi                             ; $B8AA: 8D 01 00
  LDA BattleCellPatternPtrTable,Y         ; $B8AD: B9 2C BB ; pattern base lo
  STA a:pattern_ptr                             ; $B8B0: 8D 02 00
  LDA BattleCellPatternPtrTable+1,Y       ; $B8B3: B9 2D BB ; pattern base hi
  STA a:pattern_ptr_hi                             ; $B8B6: 8D 03 00
  LDA a:cell_col                             ; $B8B9: AD 10 00 ; unit column
  STA a:col_x2                             ; $B8BC: 8D 08 00 ; (kept for troop count pass)
  LDX #$00                                ; $B8BF: A2 00 ; unused
  LDA a:cell_row                             ; $B8C1: AD 11 00 ; unit row
  ASL                                     ; $B8C4: 0A ; row * 16 (map stride)
  ASL                                     ; $B8C5: 0A
  ASL                                     ; $B8C6: 0A
  ASL                                     ; $B8C7: 0A
  PHA                                     ; $B8C8: 48 ; row * 16 (attribute pass)
  ORA a:cell_col                             ; $B8C9: 0D 10 00 ; map offset = row*16 + col
  TAY                                     ; $B8CC: A8
  LDA #$00                                ; $B8CD: A9 00
  STA a:tile_offset_hi                             ; $B8CF: 8D 04 00 ; tile offset high byte
  LDA (map_ptr),Y                             ; $B8D2: B1 00 ; map tile id at (row,col)
  ASL                                     ; $B8D4: 0A ; tile * 4 (pattern entry size)
  ROL a:tile_offset_hi                             ; $B8D5: 2E 04 00
  ASL                                     ; $B8D8: 0A
  ROL a:tile_offset_hi                             ; $B8D9: 2E 04 00
  CLC                                     ; $B8DC: 18
  ADC a:pattern_ptr                             ; $B8DD: 6D 02 00 ; pattern base + tile*4
  STA a:pattern_ptr                             ; $B8E0: 8D 02 00
  LDA a:pattern_ptr_hi                             ; $B8E3: AD 03 00
  ADC a:tile_offset_hi                             ; $B8E6: 6D 04 00
  STA a:pattern_ptr_hi                             ; $B8E9: 8D 03 00 ; ($0002) -> 2x2 pattern
  LDY #$00                                ; $B8EC: A0 00
  LDA (pattern_ptr),Y                             ; $B8EE: B1 02 ; pattern tile: top-left
  STA vram_script_buf+$03                               ; $B8F0: 8D 83 03 ; record 1 tile 0
  STA vram_script_buf+$11                               ; $B8F3: 8D 91 03 ; record 2 tile 0
  INY                                     ; $B8F6: C8
  LDA (pattern_ptr),Y                             ; $B8F7: B1 02 ; top-right
  STA vram_script_buf+$04                               ; $B8F9: 8D 84 03
  STA vram_script_buf+$12                               ; $B8FC: 8D 92 03
  INY                                     ; $B8FF: C8
  LDA (pattern_ptr),Y                             ; $B900: B1 02 ; bottom-left
  STA vram_script_buf+$08                               ; $B902: 8D 88 03
  STA vram_script_buf+$16                               ; $B905: 8D 96 03
  INY                                     ; $B908: C8
  LDA (pattern_ptr),Y                             ; $B909: B1 02 ; bottom-right
  STA vram_script_buf+$09                               ; $B90B: 8D 89 03
  STA vram_script_buf+$17                               ; $B90E: 8D 97 03
; --- Nametable addresses of the 2x2 cell (both screens) ---------------------
; Grid coordinates are 2x2-tile cells, so the nametable offset is
; (row*2)*32 + (col*2) = row*64 + col*2 below $2000.
  ASL a:col_x2                             ; $B911: 0E 08 00 ; column * 2
  LDA #$00                                ; $B914: A9 00
  STA a:addr_hi_work                             ; $B916: 8D 0B 00 ; address high part
  PLA                                     ; $B919: 68 ; row * 16
  ASL                                     ; $B91A: 0A ; row * 64
  ROL a:addr_hi_work                             ; $B91B: 2E 0B 00
  ASL                                     ; $B91E: 0A
  ROL a:addr_hi_work                             ; $B91F: 2E 0B 00
  CLC                                     ; $B922: 18
  ADC a:col_x2                             ; $B923: 6D 08 00 ; + column * 2
  STA vram_script_buf+$02                               ; $B926: 8D 82 03 ; record 1 addr lo
  STA vram_script_buf+$10                               ; $B929: 8D 90 03 ; record 2 addr lo
  LDA a:addr_hi_work                             ; $B92C: AD 0B 00
  ORA #$20                                ; $B92F: 09 20 ; nametable 0 ($2000)
  STA vram_script_buf+$01                               ; $B931: 8D 81 03 ; record 1 addr hi
  ORA #$04                                ; $B934: 09 04 ; nametable 1 ($2400)
  STA vram_script_buf+$0F                               ; $B936: 8D 8F 03 ; record 2 addr hi
  LDA vram_script_buf+$02                               ; $B939: AD 82 03 ; addr lo + one row
  CLC                                     ; $B93C: 18
  ADC #$20                                ; $B93D: 69 20 ; bottom tile pair
  STA vram_script_buf+$07                               ; $B93F: 8D 87 03 ; record 1 seg 2 addr lo
  STA vram_script_buf+$15                               ; $B942: 8D 95 03 ; record 2 seg 2 addr lo
  LDA vram_script_buf+$01                               ; $B945: AD 81 03
  ADC #$00                                ; $B948: 69 00 ; carry across the row
  STA vram_script_buf+$06                               ; $B94A: 8D 86 03 ; record 1 seg 2 addr hi
  ORA #$04                                ; $B94D: 09 04 ; nametable 1
  STA vram_script_buf+$14                               ; $B94F: 8D 94 03 ; record 2 seg 2 addr hi
  LDA #$02                                ; $B952: A9 02 ; segment count: 2 tiles
  STA vram_script_buf                               ; $B954: 8D 80 03 ; record 1 header
  STA vram_script_buf+$05                               ; $B957: 8D 85 03 ; record 1 seg 2 header
  STA vram_script_buf+$0E                               ; $B95A: 8D 8E 03 ; record 2 header
  STA vram_script_buf+$13                               ; $B95D: 8D 93 03 ; record 2 seg 2 header
; --- Highlight pass ($0012 nonzero): status tiles + troop count digits ---------------
  LDA a:highlight                             ; $B960: AD 12 00 ; highlight flag
  BEQ @AttributePass                      ; $B963: F0 44 ; plain redraw
  LDY a:roster_slot                             ; $B965: AC 13 00 ; roster slot
  LDA btl_roster_code_a,Y                             ; $B968: B9 C2 05 ; unit status byte
  AND #$03                                ; $B96B: 29 03 ; low bits (facing)
  STA a:attr_ptr                             ; $B96D: 8D 00 00
  LDA btl_roster_code_a,Y                             ; $B970: B9 C2 05
  AND #$F0                                ; $B973: 29 F0 ; high nibble (direction)
  LSR                                     ; $B975: 4A ; >> 2
  LSR                                     ; $B976: 4A
  ORA a:attr_index                             ; $B977: 0D 00 00 ; status index
  CMP #$10                                ; $B97A: C9 10 ; range guard
  BCC @IndexOk                            ; $B97C: 90 01
  NOP                                     ; $B97E: EA ; ROM artifact (unreached)
@IndexOk:
  ASL                                     ; $B97F: 0A ; status index * 4
  ASL                                     ; $B980: 0A
  TAY                                     ; $B981: A8
  LDA BattleCellHighlightTiles,Y          ; $B982: B9 4F BB ; highlight top-left
  STA vram_script_buf+$03                               ; $B985: 8D 83 03
  STA vram_script_buf+$11                               ; $B988: 8D 91 03
  LDA BattleCellHighlightTiles+1,Y        ; $B98B: B9 50 BB ; top-right
  STA vram_script_buf+$04                               ; $B98E: 8D 84 03
  STA vram_script_buf+$12                               ; $B991: 8D 92 03
  LDA BattleCellHighlightTiles+2,Y        ; $B994: B9 51 BB ; bottom-left
  STA vram_script_buf+$08                               ; $B997: 8D 88 03
  STA vram_script_buf+$16                               ; $B99A: 8D 96 03
  LDA BattleCellHighlightTiles+3,Y        ; $B99D: B9 52 BB ; bottom-right
  STA vram_script_buf+$09                               ; $B9A0: 8D 89 03
  STA vram_script_buf+$17                               ; $B9A3: 8D 97 03
  JSR BattleCellTroopCountDigitOverlay            ; $B9A6: 20 18 BA ; troop count digits on bottom row
; --- Attribute pass: base attribute + adjacency occupancy bits --------------
@AttributePass:
  PLA                                     ; $B9A9: 68 ; phase (copy 2)
  ASL                                     ; $B9AA: 0A ; phase * 2
  TAY                                     ; $B9AB: A8
  LDA BattleCellAttrPtrTable,Y            ; $B9AC: B9 3A BB ; attribute base lo
  STA a:attr_ptr                             ; $B9AF: 8D 00 00
  LDA BattleCellAttrPtrTable+1,Y          ; $B9B2: B9 3B BB ; attribute base hi
  STA a:attr_ptr_hi                             ; $B9B5: 8D 01 00
  LDA a:cell_col                             ; $B9B8: AD 10 00 ; column
  AND #$0E                                ; $B9BB: 29 0E ; even-aligned cell column
  LSR                                     ; $B9BD: 4A ; col / 2
  STA a:col_x2                             ; $B9BE: 8D 08 00
  LDA a:cell_row                             ; $B9C1: AD 11 00 ; row
  AND #$0E                                ; $B9C4: 29 0E ; even-aligned cell row
  ASL                                     ; $B9C6: 0A ; row * 8 (attribute stride)
  ASL                                     ; $B9C7: 0A
  ORA a:col_x2                             ; $B9C8: 0D 08 00 ; attribute cell offset
  TAY                                     ; $B9CB: A8
  LDA (attr_ptr),Y                             ; $B9CC: B1 00 ; base attribute byte
  STA a:attr_work                             ; $B9CE: 8D 00 00
  JSR BattleCellAdjacencyScan             ; $B9D1: 20 56 BA ; merge occupancy bits
  LDA a:attr_work                             ; $B9D4: AD 00 00 ; final attribute
  STA vram_script_buf+$0D                               ; $B9D7: 8D 8D 03 ; record 1 attribute
  STA vram_script_buf+$1B                               ; $B9DA: 8D 9B 03 ; record 2 attribute
  LDA a:cell_col                             ; $B9DD: AD 10 00 ; column
  AND #$0E                                ; $B9E0: 29 0E
  LSR                                     ; $B9E2: 4A ; col / 2
  STA a:attr_ofs                             ; $B9E3: 8D 00 00
  LDA a:cell_row                             ; $B9E6: AD 11 00 ; row
  AND #$0E                                ; $B9E9: 29 0E
  ASL                                     ; $B9EB: 0A ; row * 8
  ASL                                     ; $B9EC: 0A
  ORA a:attr_ofs                             ; $B9ED: 0D 00 00 ; attribute offset
  ORA #$C0                                ; $B9F0: 09 C0 ; attribute table at +$3C0
  STA vram_script_buf+$0C                               ; $B9F2: 8D 8C 03 ; record 1 attr addr lo
  STA vram_script_buf+$1A                               ; $B9F5: 8D 9A 03 ; record 2 attr addr lo
  LDA #$23                                ; $B9F8: A9 23 ; nametable 0 attribute
  STA vram_script_buf+$0B                               ; $B9FA: 8D 8B 03
  LDA #$27                                ; $B9FD: A9 27 ; nametable 1 attribute
  STA vram_script_buf+$19                               ; $B9FF: 8D 99 03
  LDA #$01                                ; $BA02: A9 01 ; attribute segment: 1 byte
  STA vram_script_buf+$0A                               ; $BA04: 8D 8A 03
  STA vram_script_buf+$18                               ; $BA07: 8D 98 03
  LDA #$FF                                ; $BA0A: A9 FF ; record terminator
  STA vram_script_buf+$1C                               ; $BA0C: 8D 9C 03
  LDA a:btl_anim_flags                             ; $BA0F: AD 7E 00 ; PPU queue flags
  ORA #$04                                ; $BA12: 09 04 ; cell update pending
  STA a:btl_anim_flags                             ; $BA14: 8D 7E 00
  RTS                                     ; $BA17: 60
.endproc
;===============================================================================
; $BA18: BattleCellTroopCountDigitOverlay
; Highlight-pass helper: overlays the unit's troop count as two digit tiles on the
; cell's bottom row of record 2 ($0396/$0397). troop count $05AC[$0013] is packed
; to BCD via B1F_MathBinToBcd; the tens and ones digits map to tiles
; $B4+d. When the BCD high byte $0008 has a nonzero low nibble (troop count in the
; thousands), the digits are replaced by the $BE/$BF overflow marker pair.
;===============================================================================
.proc BattleCellTroopCountDigitOverlay
; zero-page work cells (proc-local):
roster_slot    = $0013  ; roster slot index
bcd_in_lo      = $0001  ; binary troop count lo
bcd_in_mid     = $0002  ; binary troop count mid
bcd_in_hi      = $0003  ; binary troop count hi
bcd_tens       = $0007  ; BCD tens+ones result
bcd_thousands  = $0008  ; BCD thousands+hundreds result
  LDY a:roster_slot                             ; $BA18: AC 13 00 ; roster slot
  LDA btl_troops_a,Y                             ; $BA1B: B9 AC 05 ; unit troop count
  STA a:bcd_in_lo                             ; $BA1E: 8D 01 00 ; BCD input lo
  LDA #$00                                ; $BA21: A9 00
  STA a:bcd_in_mid                             ; $BA23: 8D 02 00 ; BCD input mid
  STA a:bcd_in_hi                             ; $BA26: 8D 03 00 ; BCD input hi
  JSR B1F_MathBinToBcd                    ; $BA29: 20 BA E9 ; troop count -> packed BCD
  LDA a:bcd_tens                             ; $BA2C: AD 07 00 ; tens+ones BCD byte
  LSR                                     ; $BA2F: 4A ; tens digit
  LSR                                     ; $BA30: 4A
  LSR                                     ; $BA31: 4A
  LSR                                     ; $BA32: 4A
  CLC                                     ; $BA33: 18
  ADC #$B4                                ; $BA34: 69 B4 ; digit tile base
  STA vram_script_buf+$16                               ; $BA36: 8D 96 03 ; bottom-left tile
  LDA a:bcd_tens                             ; $BA39: AD 07 00
  AND #$0F                                ; $BA3C: 29 0F ; ones digit
  CLC                                     ; $BA3E: 18
  ADC #$B4                                ; $BA3F: 69 B4
  STA vram_script_buf+$17                               ; $BA41: 8D 97 03 ; bottom-right tile
  LDA a:bcd_thousands                             ; $BA44: AD 08 00 ; thousands+hundreds
  AND #$0F                                ; $BA47: 29 0F ; hundreds digit
  BEQ @Done                               ; $BA49: F0 0A ; below 1000: keep digits
  LDA #$BE                                ; $BA4B: A9 BE ; overflow marker left
  STA vram_script_buf+$16                               ; $BA4D: 8D 96 03
  LDA #$BF                                ; $BA50: A9 BF ; overflow marker right
  STA vram_script_buf+$17                               ; $BA52: 8D 97 03
@Done:
  RTS                                     ; $BA55: 60
.endproc
;===============================================================================
; $BA56: BattleCellAdjacencyScan
; Merges occupancy bits into the attribute byte $0000 for the target cell
; ($0010 col / $0011 row): scans all 22 roster slots $15 -> 0 and, for each
; occupied slot, merges the side-specific mask bits when that unit sits in
; one of the four sub-cells of the target 2x2 block. In plain mode
; ($0012 == 0) the target slot $0013 itself is skipped.
;===============================================================================
.proc BattleCellAdjacencyScan
; zero-page work cells (proc-local):
cell_col       = $0010  ; unit battlefield column
cell_row       = $0011  ; unit battlefield row
probe_col      = $0002  ; adjacent probe column
probe_row      = $0003  ; adjacent probe row
highlight      = $0012  ; highlight flag
target_slot    = $0013  ; target roster slot
  LDA a:cell_col                             ; $BA56: AD 10 00 ; column
  AND #$0E                                ; $BA59: 29 0E ; even-aligned
  STA a:probe_col                             ; $BA5B: 8D 02 00 ; probe column
  LDA a:cell_row                             ; $BA5E: AD 11 00 ; row
  AND #$0E                                ; $BA61: 29 0E ; even-aligned
  STA a:probe_row                             ; $BA63: 8D 03 00 ; probe row
  LDY #$15                                ; $BA66: A0 15 ; 22 roster slots
@SlotLoop:
  LDA a:highlight                             ; $BA68: AD 12 00 ; highlight flag
  BNE @MergeSlot                          ; $BA6B: D0 05 ; highlight: include self
  CPY a:target_slot                             ; $BA6D: CC 13 00 ; target slot?
  BEQ @NextSlot                           ; $BA70: F0 03 ; plain: skip self
@MergeSlot:
  JSR BattleCellSlotAdjacencyMerge        ; $BA72: 20 79 BA
@NextSlot:
  DEY                                     ; $BA75: 88
  BPL @SlotLoop                           ; $BA76: 10 F0
  RTS                                     ; $BA78: 60
.endproc
;===============================================================================
; $BA79: BattleCellSlotAdjacencyMerge
; Merges the occupancy mask for roster slot Y into attribute byte $0000.
; Probes the four sub-cells of the target 2x2 block - (col,row),
; (col+1,row), (col+1,row+1), (col,row+1) - against the slot's position
; ($0580[Y],$0596[Y]) and ORs the matching mask into $0000 (bits are
; cleared first so the last writer wins). Side A (slots 0-$0A) uses the
; double masks $03/$0C/$30/$C0, side B (slots $0B-$15) the single masks
; $01/$04/$10/$40.
;===============================================================================
.proc BattleCellSlotAdjacencyMerge
; zero-page work cells (proc-local):
mask0          = $000A  ; sub-cell 0 highlight mask
mask1          = $000B  ; sub-cell 1 highlight mask
mask3          = $000C  ; sub-cell 3 highlight mask
mask2          = $000D  ; sub-cell 2 highlight mask
hit_work       = $0000  ; terrain hit work byte
probe_col      = $0002  ; probe column
probe_row      = $0003  ; probe row
  LDA #$01                                ; $BA79: A9 01 ; side B masks
  STA a:mask0                             ; $BA7B: 8D 0A 00 ; sub-cell 0 mask
  LDA #$04                                ; $BA7E: A9 04
  STA a:mask1                             ; $BA80: 8D 0B 00 ; sub-cell 1 mask
  LDA #$10                                ; $BA83: A9 10
  STA a:mask3                             ; $BA85: 8D 0C 00 ; sub-cell 3 mask
  LDA #$40                                ; $BA88: A9 40
  STA a:mask2                             ; $BA8A: 8D 0D 00 ; sub-cell 2 mask
  CPY #$0B                                ; $BA8D: C0 0B ; side boundary
  BCS @MaskReady                          ; $BA8F: B0 14 ; side B: keep singles
  LDA #$03                                ; $BA91: A9 03 ; side A masks
  STA a:mask0                             ; $BA93: 8D 0A 00
  LDA #$0C                                ; $BA96: A9 0C
  STA a:mask1                             ; $BA98: 8D 0B 00
  LDA #$30                                ; $BA9B: A9 30
  STA a:mask3                             ; $BA9D: 8D 0C 00
  LDA #$C0                                ; $BAA0: A9 C0
  STA a:mask2                             ; $BAA2: 8D 0D 00
@MaskReady:
  LDA a:probe_col                             ; $BAA5: AD 02 00 ; probe column
  CMP btl_unit_col_a,Y                             ; $BAA8: D9 80 05 ; slot column
  BNE @SubCell1                           ; $BAAB: D0 13
  LDA a:probe_row                             ; $BAAD: AD 03 00 ; probe row
  CMP btl_unit_row_a,Y                             ; $BAB0: D9 96 05 ; slot row
  BNE @SubCell1                           ; $BAB3: D0 0B
  LDA a:hit_work                             ; $BAB5: AD 00 00 ; (col,row) hit
  AND #$FC                                ; $BAB8: 29 FC
  ORA a:mask0                             ; $BABA: 0D 0A 00
  STA a:hit_work                             ; $BABD: 8D 00 00
@SubCell1:
  INC a:probe_col                             ; $BAC0: EE 02 00 ; column + 1
  LDA a:probe_col                             ; $BAC3: AD 02 00
  CMP btl_unit_col_a,Y                             ; $BAC6: D9 80 05
  BNE @SubCell2                           ; $BAC9: D0 13
  LDA a:probe_row                             ; $BACB: AD 03 00
  CMP btl_unit_row_a,Y                             ; $BACE: D9 96 05
  BNE @SubCell2                           ; $BAD1: D0 0B
  LDA a:hit_work                             ; $BAD3: AD 00 00 ; (col+1,row) hit
  AND #$F3                                ; $BAD6: 29 F3
  ORA a:mask1                             ; $BAD8: 0D 0B 00
  STA a:hit_work                             ; $BADB: 8D 00 00
@SubCell2:
  INC a:probe_row                             ; $BADE: EE 03 00 ; row + 1
  LDA a:probe_col                             ; $BAE1: AD 02 00
  CMP btl_unit_col_a,Y                             ; $BAE4: D9 80 05
  BNE @SubCell3                           ; $BAE7: D0 13
  LDA a:probe_row                             ; $BAE9: AD 03 00
  CMP btl_unit_row_a,Y                             ; $BAEC: D9 96 05
  BNE @SubCell3                           ; $BAEF: D0 0B
  LDA a:hit_work                             ; $BAF1: AD 00 00 ; (col+1,row+1) hit
  AND #$3F                                ; $BAF4: 29 3F
  ORA a:mask2                             ; $BAF6: 0D 0D 00
  STA a:hit_work                             ; $BAF9: 8D 00 00
@SubCell3:
  DEC a:probe_col                             ; $BAFC: CE 02 00 ; column back
  LDA a:probe_col                             ; $BAFF: AD 02 00
  CMP btl_unit_col_a,Y                             ; $BB02: D9 80 05
  BNE @Restore                            ; $BB05: D0 13
  LDA a:probe_row                             ; $BB07: AD 03 00
  CMP btl_unit_row_a,Y                             ; $BB0A: D9 96 05
  BNE @Restore                            ; $BB0D: D0 0B
  LDA a:hit_work                             ; $BB0F: AD 00 00 ; (col,row+1) hit
  AND #$CF                                ; $BB12: 29 CF
  ORA a:mask3                             ; $BB14: 0D 0C 00
  STA a:hit_work                             ; $BB17: 8D 00 00
@Restore:
  DEC a:probe_row                             ; $BB1A: CE 03 00 ; row back
  RTS                                     ; $BB1D: 60
.endproc
;===============================================================================
; Battle cell rendering tables ($BB1E-$BB8E), used by BattleCellRedraw.
; All pointers reference the map data in the bank switched via
; BattleCellMapBankTable (currently bank $21 for every phase).
;===============================================================================
; --- Phase map table pointers ($BB1E, 7 words) --------------------------------
; 16x16 tile-id maps, one per battle phase (16-byte rows).
BattleCellMapPtrTable:
  .word $8440,$8570,$86A0,$87D0           ; $BB1E: phases 0-3
  .word $8900,$8A30,$8B60                 ; $BB26: phases 4-6
; --- Phase unit pattern table pointers ($BB2C, 7 words) ------------------------
; 4-byte 2x2 tile patterns indexed by the map tile id; every phase keeps
; the pattern data at $8000 of the switched map bank.
BattleCellPatternPtrTable:
  .word $8000,$8000,$8000,$8000           ; $BB2C: phases 0-3
  .word $8000,$8000,$8000                 ; $BB34: phases 4-6
; --- Phase attribute table pointers ($BB3A, 7 words) ---------------------------
; Attribute bytes indexed by (row/2)*8 + col/2 within the even-aligned cell.
BattleCellAttrPtrTable:
  .word $8400,$8530,$8660,$8790           ; $BB3A: phases 0-3
  .word $88C0,$89F0,$8B20                 ; $BB42: phases 4-6
; --- Phase $8000 map bank table ($BB48, 7 bytes) -------------------------------
; Bank argument for B1F_SwitchBank8_B, indexed by battle phase.
BattleCellMapBankTable:
  .byte $21,$21,$21,$21,$21,$21,$21       ; $BB48: bank $21 for all phases
; --- Highlight cell tiles ($BB4F, 16 x 4 bytes) ---------------------------------
; 2x2 tile sets for the highlight render, indexed by
; ((($05C2[high nibble]>>2) | ($05C2 & 3)) * 4). One 4-byte 2x2 tile set
; per unit status index (entry 0 = $FD marker variant).
BattleCellHighlightTiles:
  .byte $FD,$63,$72,$73,$62,$63,$72,$73,$48,$49,$58,$59,$4E,$4F,$5E,$5F; $BB4F
  .byte $60,$FC,$70,$71,$60,$61,$70,$71,$4A,$4B,$5A,$5B,$4C,$4D,$5C,$5D; $BB5F
  .byte $46,$47,$54,$55,$44,$45,$54,$55,$40,$41,$50,$51,$42,$43,$52,$53; $BB6F
  .byte $56,$57,$66,$67,$64,$65,$66,$67,$6C,$6D,$6E,$6F,$68,$69,$6A,$6B; $BB7F
;===============================================================================
; $BB8F: Phase2CursorArrowDraw
; Draws the walk-cursor arrow sprite at the walk position ($054A row / $054B
; column, pixel coords latched by Phase2CursorWalkInit). The sprite stream is
; picked from BattleCursorArrowSpritePtrs indexed by the cursor column's
; status $05C2[$0545] (high nibble = unit status, bits 1:0 = action bits)
; and the 2-bit animation frame from bits 3:2 of the frame tick counter
; $005E: word index = (((status<<2) | (action&3)) << 2 | frame). Flip flags
; $0002: bit 6 (vertical flip, XORed into the per-sprite attributes by
; B1F_SpriteOamWriterScroll) when the status nibble is 3, plus bit 0 for
; unit columns ($0545 < $0B). Position: X = $054B, Y = $054A + 8. Tail JMP
; into B1F_SpriteOamWriterScroll.
;===============================================================================
.proc Phase2CursorArrowDraw
; zero-page work cells (proc-local):
status_work    = $0000  ; cursor status word (action bits)
status_frame   = $0001  ; status word with animation frame
flip_flags     = $0002  ; sprite flip/palette flags
spr_x          = $000A  ; cursor sprite X offset
spr_x_hi       = $000B  ; X offset hi
spr_y          = $000C  ; cursor sprite Y offset (row + 8)
spr_y_hi       = $000D  ; Y offset hi
  LDA a:frame_tick                             ; $BB8F: AD 5E 00 ; frame tick counter
  LSR                                     ; $BB92: 4A
  LSR                                     ; $BB93: 4A
  AND #$03                                ; $BB94: 29 03 ; animation frame (bits 3:2)
  STA a:status_frame                             ; $BB96: 8D 01 00
  LDY btl_scan_col                               ; $BB99: AC 45 05 ; cursor column
  LDA btl_roster_code_a,Y                             ; $BB9C: B9 C2 05 ; column status
  AND #$03                                ; $BB9F: 29 03 ; action bits 1:0
  STA a:status_work                             ; $BBA1: 8D 00 00
  LDA btl_roster_code_a,Y                             ; $BBA4: B9 C2 05
  AND #$F0                                ; $BBA7: 29 F0 ; status nibble
  LSR                                     ; $BBA9: 4A
  LSR                                     ; $BBAA: 4A ; status << 2
  ORA a:status_work                             ; $BBAB: 0D 00 00 ; | action bits
  ASL                                     ; $BBAE: 0A
  ASL                                     ; $BBAF: 0A ; variant * 4
  ORA a:status_frame                             ; $BBB0: 0D 01 00 ; | animation frame
  ASL                                     ; $BBB3: 0A ; word index
  TAY                                     ; $BBB4: A8
  LDA BattleCursorArrowSpritePtrs,Y       ; $BBB5: B9 FD BB ; stream ptr lo
  STA a:status_work                             ; $BBB8: 8D 00 00
  LDA BattleCursorArrowSpritePtrs+1,Y     ; $BBBB: B9 FE BB ; stream ptr hi
  STA a:status_frame                             ; $BBBE: 8D 01 00
  LDA btl_walk_row                               ; $BBC1: AD 4A 05 ; walk row << 4
  CLC                                     ; $BBC4: 18
  ADC #$08                                ; $BBC5: 69 08
  STA a:spr_y                             ; $BBC7: 8D 0C 00 ; Y offset = row + 8
  LDA btl_walk_col                               ; $BBCA: AD 4B 05 ; walk column << 4
  STA a:spr_x                             ; $BBCD: 8D 0A 00 ; X offset
  LDA #$00                                ; $BBD0: A9 00
  STA a:spr_x_hi                             ; $BBD2: 8D 0B 00 ; X offset hi
  STA a:spr_y_hi                             ; $BBD5: 8D 0D 00 ; Y offset hi
  LDA #$00                                ; $BBD8: A9 00
  STA a:flip_flags                             ; $BBDA: 8D 02 00 ; flip flags <- 0
  LDY btl_scan_col                               ; $BBDD: AC 45 05
  LDA btl_roster_code_a,Y                             ; $BBE0: B9 C2 05 ; column status
  LSR                                     ; $BBE3: 4A
  LSR                                     ; $BBE4: 4A
  LSR                                     ; $BBE5: 4A
  LSR                                     ; $BBE6: 4A ; status nibble
  CMP #$03                                ; $BBE7: C9 03
  BNE @ColumnCheck                        ; $BBE9: D0 05
  LDA #$40                                ; $BBEB: A9 40
  STA a:flip_flags                             ; $BBED: 8D 02 00 ; vertical-flip flag
@ColumnCheck:
  LDY btl_scan_col                               ; $BBF0: AC 45 05 ; cursor column
  CPY #$0B                                ; $BBF3: C0 0B ; unit columns only
  BCS @Submit                             ; $BBF5: B0 03
  INC a:flip_flags                             ; $BBF7: EE 02 00 ; palette bit 0
@Submit:
  JMP B1F_SpriteOamWriterScroll           ; $BBFA: 4C 92 F0
.endproc
;===============================================================================
; Cursor arrow sprite pointer table ($BBFD, 64 words) and sprite streams
; ($BC7D-$BE75). Word index = (((status_nibble << 2) | (action_bits & 3))
; << 2 | frame); the 2-bit frame alternates between the pair of streams
; every 4 ticks (frames 0/2 = first stream, frames 1/3 = second), giving a
; two-tile animation per column-status variant. Stream record format per
; B1F_SpriteOamWriterScroll: [X, tile, attr, Y] bytes, $80 terminator; flip
; flags $0002 are XORed into each attr byte (bit 6 flips the sprites
; vertically, bit 0 toggles palette bit 0).
;===============================================================================
BattleCursorArrowSpritePtrs:
  .word BattleCursorArrowSprBox42,BattleCursorArrowSprBox62 ; $BBFD: 05 BD 16 BD ; variant 0
  .word BattleCursorArrowSprBox42,BattleCursorArrowSprBox62 ; $BC01: 05 BD 16 BD
  .word BattleCursorArrowSprBox42b,BattleCursorArrowSprBox62b ; $BC05: 27 BD 38 BD ; variant 1
  .word BattleCursorArrowSprBox42b,BattleCursorArrowSprBox62b ; $BC09: 27 BD 38 BD
  .word BattleCursorArrowSprBox0A,BattleCursorArrowSprBox0AHi ; $BC0D: 49 BD 5A BD ; variant 2
  .word BattleCursorArrowSprBox0A,BattleCursorArrowSprBox0AHi ; $BC11: 49 BD 5A BD
  .word BattleCursorArrowSprBox0E,BattleCursorArrowSprBox2E ; $BC15: 6B BD 7C BD ; variant 3
  .word BattleCursorArrowSprBox0E,BattleCursorArrowSprBox2E ; $BC19: 6B BD 7C BD
  .word BattleCursorArrowSprTiles40,BattleCursorArrowSprTiles60 ; $BC1D: 7D BC 8E BC ; variant 4 (arrow glyph)
  .word BattleCursorArrowSprTiles40,BattleCursorArrowSprTiles60 ; $BC21: 7D BC 8E BC
  .word BattleCursorArrowSprTiles40Dup,BattleCursorArrowSprTiles60Dup ; $BC25: 9F BC B0 BC ; variant 5
  .word BattleCursorArrowSprTiles40Dup,BattleCursorArrowSprTiles60Dup ; $BC29: 9F BC B0 BC
  .word BattleCursorArrowSprBox08,BattleCursorArrowSprBox38 ; $BC2D: C1 BC D2 BC ; variant 6
  .word BattleCursorArrowSprBox08,BattleCursorArrowSprBox38 ; $BC31: C1 BC D2 BC
  .word BattleCursorArrowSprBox0C,BattleCursorArrowSprBox2C ; $BC35: E3 BC F4 BC ; variant 7
  .word BattleCursorArrowSprBox0C,BattleCursorArrowSprBox2C ; $BC39: E3 BC F4 BC
  .word BattleCursorArrowSprBox06,BattleCursorArrowSprBox26 ; $BC3D: 8D BD 9E BD ; variant 8
  .word BattleCursorArrowSprBox06,BattleCursorArrowSprBox26 ; $BC41: 8D BD 9E BD
  .word BattleCursorArrowSprBox04,BattleCursorArrowSprBox24 ; $BC45: AF BD C0 BD ; variant 9
  .word BattleCursorArrowSprBox04,BattleCursorArrowSprBox24 ; $BC49: AF BD C0 BD
  .word BattleCursorArrowSprBox00,BattleCursorArrowSprBox20 ; $BC4D: D1 BD E2 BD ; variant 10
  .word BattleCursorArrowSprBox00,BattleCursorArrowSprBox20 ; $BC51: D1 BD E2 BD
  .word BattleCursorArrowSprBox02,BattleCursorArrowSprBox22 ; $BC55: F3 BD 04 BE ; variant 11
  .word BattleCursorArrowSprBox02,BattleCursorArrowSprBox22 ; $BC59: F3 BD 04 BE
  .word BattleCursorArrowSprBox06,BattleCursorArrowSprBox26 ; $BC5D: 8D BD 9E BD ; variant 12 (dup of 8)
  .word BattleCursorArrowSprBox06,BattleCursorArrowSprBox26 ; $BC61: 8D BD 9E BD
  .word BattleCursorArrowSprBox04,BattleCursorArrowSprBox24 ; $BC65: AF BD C0 BD ; variant 13 (dup of 9)
  .word BattleCursorArrowSprBox04,BattleCursorArrowSprBox24 ; $BC69: AF BD C0 BD
  .word BattleCursorArrowSprBox00,BattleCursorArrowSprBox20 ; $BC6D: D1 BD E2 BD ; variant 14 (dup of 10)
  .word BattleCursorArrowSprBox00,BattleCursorArrowSprBox20 ; $BC71: D1 BD E2 BD
  .word BattleCursorArrowSprBox02,BattleCursorArrowSprBox22 ; $BC75: F3 BD 04 BE ; variant 15 (dup of 11)
  .word BattleCursorArrowSprBox02,BattleCursorArrowSprBox22 ; $BC79: F3 BD 04 BE
; --- Arrow glyph streams -------------------------------------------------------
BattleCursorArrowSprTiles40:  ; 2x2 arrow, tiles $40/$41/$50/$51
  .byte $00,$40,$00,$F8,$00,$41,$00,$00,$08,$50,$00,$F8,$08,$51,$00,$00; $BC7D: 00 40 00 F8 00 41 00 00 08 50 00 F8 08 51 00 00
  .byte $80                               ; $BC8D: 80
BattleCursorArrowSprTiles60:  ; 2x2 arrow, tiles $60/$61/$70/$71
  .byte $00,$60,$00,$F8,$00,$61,$00,$00,$08,$70,$00,$F8,$08,$71,$00,$00; $BC8E: 00 60 00 F8 00 61 00 00 08 70 00 F8 08 71 00 00
  .byte $80                               ; $BC9E: 80
BattleCursorArrowSprTiles40Dup: ; duplicate of BattleCursorArrowSprTiles40
  .byte $00,$40,$00,$F8,$00,$41,$00,$00,$08,$50,$00,$F8,$08,$51,$00,$00; $BC9F: 00 40 00 F8 00 41 00 00 08 50 00 F8 08 51 00 00
  .byte $80                               ; $BCAF: 80
BattleCursorArrowSprTiles60Dup: ; duplicate of BattleCursorArrowSprTiles60
  .byte $00,$60,$00,$F8,$00,$61,$00,$00,$08,$70,$00,$F8,$08,$71,$00,$00; $BCB0: 00 60 00 F8 00 61 00 00 08 70 00 F8 08 71 00 00
  .byte $80                               ; $BCC0: 80
; --- 4x4 bracket box streams ----------------------------------------------------
BattleCursorArrowSprBox08:    ; tiles $08/$09/$18/$19
  .byte $00,$08,$00,$F8,$00,$09,$00,$00,$08,$18,$00,$F8,$08,$19,$00,$00; $BCC1: 00 08 00 F8 00 09 00 00 08 18 00 F8 08 19 00 00
  .byte $80                               ; $BCD1: 80
BattleCursorArrowSprBox38:    ; tiles $08/$09/$38/$39
  .byte $00,$08,$00,$F8,$00,$09,$00,$00,$08,$38,$00,$F8,$08,$39,$00,$00; $BCD2: 00 08 00 F8 00 09 00 00 08 38 00 F8 08 39 00 00
  .byte $80                               ; $BCE2: 80
BattleCursorArrowSprBox0C:    ; tiles $0C/$0D/$1C/$1D
  .byte $00,$0C,$00,$F8,$00,$0D,$00,$00,$08,$1C,$00,$F8,$08,$1D,$00,$00; $BCE3: 00 0C 00 F8 00 0D 00 00 08 1C 00 F8 08 1D 00 00
  .byte $80                               ; $BCF3: 80
BattleCursorArrowSprBox2C:    ; tiles $2C/$2D/$3C/$3D
  .byte $00,$2C,$00,$F8,$00,$2D,$00,$00,$08,$3C,$00,$F8,$08,$3D,$00,$00; $BCF4: 00 2C 00 F8 00 2D 00 00 08 3C 00 F8 08 3D 00 00
  .byte $80                               ; $BD04: 80
BattleCursorArrowSprBox42:    ; tiles $42/$43/$52/$53
  .byte $00,$42,$00,$F8,$00,$43,$00,$00,$08,$52,$00,$F8,$08,$53,$00,$00; $BD05: 00 42 00 F8 00 43 00 00 08 52 00 F8 08 53 00 00
  .byte $80                               ; $BD15: 80
BattleCursorArrowSprBox62:    ; tiles $62/$63/$72/$73
  .byte $00,$62,$00,$F8,$00,$63,$00,$00,$08,$72,$00,$F8,$08,$73,$00,$00; $BD16: 00 62 00 F8 00 63 00 00 08 72 00 F8 08 73 00 00
  .byte $80                               ; $BD26: 80
BattleCursorArrowSprBox42b:   ; duplicate of BattleCursorArrowSprBox42
  .byte $00,$42,$00,$F8,$00,$43,$00,$00,$08,$52,$00,$F8,$08,$53,$00,$00; $BD27: 00 42 00 F8 00 43 00 00 08 52 00 F8 08 53 00 00
  .byte $80                               ; $BD37: 80
BattleCursorArrowSprBox62b:   ; duplicate of BattleCursorArrowSprBox62
  .byte $00,$62,$00,$F8,$00,$63,$00,$00,$08,$72,$00,$F8,$08,$73,$00,$00; $BD38: 00 62 00 F8 00 63 00 00 08 72 00 F8 08 73 00 00
  .byte $80                               ; $BD48: 80
BattleCursorArrowSprBox0A:    ; tiles $0A/$0B/$1A/$1B
  .byte $00,$0A,$00,$F8,$00,$0B,$00,$00,$08,$1A,$00,$F8,$08,$1B,$00,$00; $BD49: 00 0A 00 F8 00 0B 00 00 08 1A 00 F8 08 1B 00 00
  .byte $80                               ; $BD59: 80
BattleCursorArrowSprBox0AHi:  ; tiles $0A/$0B/$3A/$3B
  .byte $00,$0A,$00,$F8,$00,$0B,$00,$00,$08,$3A,$00,$F8,$08,$3B,$00,$00; $BD5A: 00 0A 00 F8 00 0B 00 00 08 3A 00 F8 08 3B 00 00
  .byte $80                               ; $BD6A: 80
BattleCursorArrowSprBox0E:    ; tiles $0E/$0F/$1E/$1F
  .byte $00,$0E,$00,$F8,$00,$0F,$00,$00,$08,$1E,$00,$F8,$08,$1F,$00,$00; $BD6B: 00 0E 00 F8 00 0F 00 00 08 1E 00 F8 08 1F 00 00
  .byte $80                               ; $BD7B: 80
BattleCursorArrowSprBox2E:    ; tiles $2E/$2F/$3E/$3F
  .byte $00,$2E,$00,$F8,$00,$2F,$00,$00,$08,$3E,$00,$F8,$08,$3F,$00,$00; $BD7C: 00 2E 00 F8 00 2F 00 00 08 3E 00 F8 08 3F 00 00
  .byte $80                               ; $BD8C: 80
BattleCursorArrowSprBox06:    ; tiles $06/$07/$14/$15
  .byte $00,$06,$00,$F8,$00,$07,$00,$00,$08,$14,$00,$F8,$08,$15,$00,$00; $BD8D: 00 06 00 F8 00 07 00 00 08 14 00 F8 08 15 00 00
  .byte $80                               ; $BD9D: 80
BattleCursorArrowSprBox26:    ; tiles $26/$27/$34/$35
  .byte $00,$26,$00,$F8,$00,$27,$00,$00,$08,$34,$00,$F8,$08,$35,$00,$00; $BD9E: 00 26 00 F8 00 27 00 00 08 34 00 F8 08 35 00 00
  .byte $80                               ; $BDAE: 80
BattleCursorArrowSprBox04:    ; tiles $04/$05/$14/$15
  .byte $00,$04,$00,$F8,$00,$05,$00,$00,$08,$14,$00,$F8,$08,$15,$00,$00; $BDAF: 00 04 00 F8 00 05 00 00 08 14 00 F8 08 15 00 00
  .byte $80                               ; $BDBF: 80
BattleCursorArrowSprBox24:    ; tiles $24/$05/$34/$35
  .byte $00,$24,$00,$F8,$00,$05,$00,$00,$08,$34,$00,$F8,$08,$35,$00,$00; $BDC0: 00 24 00 F8 00 05 00 00 08 34 00 F8 08 35 00 00
  .byte $80                               ; $BDD0: 80
BattleCursorArrowSprBox00:    ; tiles $00/$01/$10/$11
  .byte $00,$00,$00,$F8,$00,$01,$00,$00,$08,$10,$00,$F8,$08,$11,$00,$00; $BDD1: 00 00 00 F8 00 01 00 00 08 10 00 F8 08 11 00 00
  .byte $80                               ; $BDE1: 80
BattleCursorArrowSprBox20:    ; tiles $20/$21/$30/$31
  .byte $00,$20,$00,$F8,$00,$21,$00,$00,$08,$30,$00,$F8,$08,$31,$00,$00; $BDE2: 00 20 00 F8 00 21 00 00 08 30 00 F8 08 31 00 00
  .byte $80                               ; $BDF2: 80
BattleCursorArrowSprBox02:    ; tiles $02/$03/$12/$13
  .byte $00,$02,$00,$F8,$00,$03,$00,$00,$08,$12,$00,$F8,$08,$13,$00,$00; $BDF3: 00 02 00 F8 00 03 00 00 08 12 00 F8 08 13 00 00
  .byte $80                               ; $BE03: 80
BattleCursorArrowSprBox22:    ; tiles $22/$23/$32/$33
  .byte $00,$22,$00,$F8,$00,$23,$00,$00,$08,$32,$00,$F8,$08,$33,$00,$00; $BE04: 00 22 00 F8 00 23 00 00 08 32 00 F8 08 33 00 00
  .byte $80                               ; $BE14: 80
; Reachable cursor-marker sprite submit: Y offset
; <- $0580[$0545]<<4, X offset <- $0596[$0545]<<4, stream ptr <-
; BattleCursorArrowSprMarker, offsets Phase2AttackArrowRowOffsetTable/
; Phase2AttackArrowColOffsetTable + $0549, then JMP B1F_SpriteOamWriterScroll.
; Called by JSR from phase 2 sub 4 ($A654); kept as assembled bytes for
; byte-exact output.
BattleCursorArrowSprSubmit:
  .byte $AC,$45,$05,$B9,$80,$05,$0A,$0A; $BE15: AC 45 05 B9 80 05 0A 0A
  .byte $0A,$0A,$8D,$0C,$00,$B9,$96,$05,$0A,$0A,$0A,$0A,$8D,$0A,$00,$A9; $BE1D: 0A 0A 8D 0C 00 B9 96 05 0A 0A 0A 0A 8D 0A 00 A9
  .byte $65,$8D,$00,$00,$A9,$BE,$8D,$01,$00,$AC,$49,$05,$AD,$0C,$00,$18; $BE2D: 65 8D 00 00 A9 BE 8D 01 00 AC 49 05 AD 0C 00 18
  .byte $79,$5D,$BE,$8D,$0C,$00,$AD,$0A,$00,$18,$79,$61,$BE,$8D,$0A,$00; $BE3D: 79 5D BE 8D 0C 00 AD 0A 00 18 79 61 BE 8D 0A 00
  .byte $A9,$00,$8D,$0B,$00,$8D,$0D,$00,$A9,$00,$8D,$02,$00,$4C,$92,$F0; $BE4D: A9 00 8D 0B 00 8D 0D 00 A9 00 8D 02 00 4C 92 F0
; --- Marker stream -------------------------------------------------------------
; Unreferenced leading bytes $BE5D-$BE64 (stale sprite-record prefix).
  .byte $00,$00,$F8,$08,$F8,$08,$00,$00; $BE5D: 00 00 F8 08 F8 08 00 00
BattleCursorArrowSprMarker:   ; 2x2 marker, tiles $86/$87/$96/$97 (attr $02)
  .byte $00,$86,$02,$00,$00,$87,$02,$08; $BE65: 00 86 02 00 00 87 02 08
  .byte $08,$96,$02,$00,$08,$97,$02,$08,$80; $BE6D: 08 96 02 00 08 97 02 08 80
;===============================================================================
; $BE76: Phase2AttackArrowSprSubmit
; Submits the attack arrow sprite for phase 2 sub 7 (Phase2AttackArrowAnim).
; Stream select: index = acting side $0549 (0-3), plus +4 when the acting
; slot's side action counter is pending ($0545 >= $0B -> side B, check high
; nibble of $0577; else side A, check low nibble). The stream pointer comes
; from Phase2AttackArrowStreamPtrTable[index*2]. Sprite position = arrow
; walk position ($054A row / $054B column) plus per-side pixel offsets
; (Phase2AttackArrowRowOffsetTable/ColOffsetTable). Tail-calls
; B1F_SpriteOamWriterScroll (JMP, no return).
;===============================================================================
.proc Phase2AttackArrowSprSubmit
; zero-page work cells (proc-local):
path_ptr_lo    = $0000  ; arrow path stream ptr lo
path_ptr_hi    = $0001  ; arrow path stream ptr hi
flip_flags     = $0002  ; flip flags (0 = none)
spr_x          = $000A  ; arrow sprite X
spr_x_hi       = $000B  ; arrow sprite X hi (0)
spr_y          = $000C  ; arrow sprite Y
spr_y_hi       = $000D  ; arrow sprite Y hi (0)
  LDA btl_scan_col                               ; $BE76: AD 45 05 ; acting roster slot
  CMP #$0B                                ; $BE79: C9 0B ; side B starts at slot $0B
  BCC @SideA                              ; $BE7B: 90 10
  LDA btl_status_ctr3                               ; $BE7D: AD 77 05 ; side action counters
  AND #$F0                                ; $BE80: 29 F0 ; side B nibble
  BEQ @LookupStream                       ; $BE82: F0 19 ; no counter pending
  LDA btl_acting_unit                               ; $BE84: AD 49 05 ; acting side
  CLC                                     ; $BE87: 18
  ADC #$04                                ; $BE88: 69 04 ; engaged arrow variant
  JMP @Submit                             ; $BE8A: 4C A0 BE
@SideA:
  LDA btl_status_ctr3                               ; $BE8D: AD 77 05 ; side action counters
  AND #$0F                                ; $BE90: 29 0F ; side A nibble
  BEQ @LookupStream                       ; $BE92: F0 09 ; no counter pending
  LDA btl_acting_unit                               ; $BE94: AD 49 05 ; acting side
  CLC                                     ; $BE97: 18
  ADC #$04                                ; $BE98: 69 04 ; engaged arrow variant
  JMP @Submit                             ; $BE9A: 4C A0 BE
@LookupStream:
  LDA btl_acting_unit                               ; $BE9D: AD 49 05 ; acting side 0-3
@Submit:
  ASL                                     ; $BEA0: 0A ; index * 2
  TAY                                     ; $BEA1: A8
  LDA Phase2AttackArrowStreamPtrTable,Y   ; $BEA2: B9 DD BE ; stream ptr lo
  STA a:path_ptr_lo                             ; $BEA5: 8D 00 00
  LDA Phase2AttackArrowStreamPtrTable+1,Y ; $BEA8: B9 DE BE ; stream ptr hi
  STA a:path_ptr_hi                             ; $BEAB: 8D 01 00
  LDY btl_acting_unit                               ; $BEAE: AC 49 05 ; acting side
  LDA btl_walk_row                               ; $BEB1: AD 4A 05 ; arrow row
  CLC                                     ; $BEB4: 18
  ADC Phase2AttackArrowRowOffsetTable,Y   ; $BEB5: 79 D5 BE ; + side row offset
  STA a:spr_y                             ; $BEB8: 8D 0C 00 ; sprite Y
  LDA btl_walk_col                               ; $BEBB: AD 4B 05 ; arrow column
  CLC                                     ; $BEBE: 18
  ADC Phase2AttackArrowColOffsetTable,Y   ; $BEBF: 79 D9 BE ; + side column offset
  STA a:spr_x                             ; $BEC2: 8D 0A 00 ; sprite X
  LDA #$00                                ; $BEC5: A9 00
  STA a:spr_x_hi                             ; $BEC7: 8D 0B 00 ; X hi <- 0
  STA a:spr_y_hi                             ; $BECA: 8D 0D 00 ; Y hi <- 0
  LDA #$00                                ; $BECD: A9 00
  STA a:flip_flags                             ; $BECF: 8D 02 00 ; no flip
  JMP B1F_SpriteOamWriterScroll           ; $BED2: 4C 92 F0 ; submit OAM stream
.endproc
; --- Per-side sprite pixel offsets, indexed by acting side ($BE76) ---
Phase2AttackArrowRowOffsetTable:  ; row (Y) offset per side 0-3
  .byte $00,$00,$F8,$08           ; $BED5: 00 00 F8 08
Phase2AttackArrowColOffsetTable:  ; column (X) offset per side 0-3
  .byte $F8,$08,$00,$00           ; $BED9: F8 08 00 00
; --- Arrow stream pointers, indexed (side + engaged*4) * 2 ($BE76) ---
Phase2AttackArrowStreamPtrTable:
  .word Phase2AttackArrowSprUp            ; $BEDD: ED BE ; side 0 (row--)
  .word Phase2AttackArrowSprDown          ; $BEDF: F2 BE ; side 1 (row++)
  .word Phase2AttackArrowSprLeft          ; $BEE1: F7 BE ; side 2 (col--)
  .word Phase2AttackArrowSprRight         ; $BEE3: FC BE ; side 3 (col++)
  .word Phase2AttackArrowSprUpEngaged     ; $BEE5: 01 BF ; side 0, counter pending
  .word Phase2AttackArrowSprDownEngaged   ; $BEE7: 06 BF ; side 1, counter pending
  .word Phase2AttackArrowSprLeftEngaged   ; $BEE9: 0B BF ; side 2, counter pending
  .word Phase2AttackArrowSprRightEngaged  ; $BEEB: 10 BF ; side 3, counter pending
; --- Arrow sprite streams: one [relY,tile,attr,relX] record + $80 terminator ---
Phase2AttackArrowSprUp:
  .byte $04,$84,$02,$04,$80       ; $BEED: 04 84 02 04 80
Phase2AttackArrowSprDown:
  .byte $04,$94,$02,$04,$80       ; $BEF2: 04 94 02 04 80
Phase2AttackArrowSprLeft:
  .byte $04,$A4,$42,$04,$80       ; $BEF7: 04 A4 42 04 80 ; tile h-flipped
Phase2AttackArrowSprRight:
  .byte $04,$A4,$02,$04,$80       ; $BEFC: 04 A4 02 04 80
Phase2AttackArrowSprUpEngaged:
  .byte $04,$85,$02,$04,$80       ; $BF01: 04 85 02 04 80
Phase2AttackArrowSprDownEngaged:
  .byte $04,$95,$02,$04,$80       ; $BF06: 04 95 02 04 80
Phase2AttackArrowSprLeftEngaged:
  .byte $04,$A5,$42,$04,$80       ; $BF0B: 04 A5 42 04 80 ; tile h-flipped
Phase2AttackArrowSprRightEngaged:
  .byte $04,$A5,$02,$04,$80       ; $BF10: 04 A5 02 04 80
;===============================================================================
; $BF15: Phase2AttackMarkerSprSubmit
; Submits the 2x2 attack-marker sprite (tiles $86/$87/$96/$97) at the final
; arrow position ($054A row / $054B column) during phase 2 sub 8
; (Phase2AttackAnimCount). Tail-calls B1F_SpriteOamWriterScroll.
;===============================================================================
.proc Phase2AttackMarkerSprSubmit
; zero-page work cells (proc-local):
path_ptr_lo    = $0000  ; marker path stream ptr lo
path_ptr_hi    = $0001  ; marker path stream ptr hi
flip_flags     = $0002  ; flip flags (0 = none)
spr_x          = $000A  ; marker sprite X
spr_x_hi       = $000B  ; marker sprite X hi (0)
spr_y          = $000C  ; marker sprite Y
spr_y_hi       = $000D  ; marker sprite Y hi (0)
  LDA #$3B                                ; $BF15: A9 3B ; stream ptr lo ($BF3B)
  STA a:path_ptr_lo                             ; $BF17: 8D 00 00
  LDA #$BF                                ; $BF1A: A9 BF ; stream ptr hi
  STA a:path_ptr_hi                             ; $BF1C: 8D 01 00
  LDA btl_walk_row                               ; $BF1F: AD 4A 05 ; arrow row
  STA a:spr_y                             ; $BF22: 8D 0C 00 ; sprite Y
  LDA btl_walk_col                               ; $BF25: AD 4B 05 ; arrow column
  STA a:spr_x                             ; $BF28: 8D 0A 00 ; sprite X
  LDA #$00                                ; $BF2B: A9 00
  STA a:spr_x_hi                             ; $BF2D: 8D 0B 00 ; X hi <- 0
  STA a:spr_y_hi                             ; $BF30: 8D 0D 00 ; Y hi <- 0
  LDA #$00                                ; $BF33: A9 00
  STA a:flip_flags                             ; $BF35: 8D 02 00 ; no flip
  JMP B1F_SpriteOamWriterScroll           ; $BF38: 4C 92 F0 ; submit OAM stream
.endproc
Phase2AttackMarkerSprites:      ; 2x2 marker, tiles $86/$87/$96/$97 (attr $02)
  .byte $00,$86,$02,$00,$00,$87,$02,$08,$08,$96,$02,$00,$08,$97,$02,$08; $BF3B: 00 86 02 00 00 87 02 08 08 96 02 00 08 97 02 08
  .byte $80                               ; $BF4B: 80 ; stream terminator
;===============================================================================
; $BF4C: BattleSideStatusCounterDraw
; Redraws the four packed per-side status counter bytes $0574-$0577 (two
; one-digit counters per byte). For each counter, the high nibble is drawn
; in row X=$80 and the low nibble in row X=$70; the per-counter PPU stream
; pointer comes from @PerCounterStreamPtrTable (Y = counter index * 2) and
; the digit tile base is $D0. Submission goes through $F092 with $00B7=$91.
; Zero nibbles are skipped. Called every frame by Phase1NextActorSubDispatch.
;===============================================================================
.proc BattleSideStatusCounterDraw
; zero-page work cells (proc-local):
stream_ptr_lo  = $0000  ; counter stream ptr lo
stream_ptr_hi  = $0001  ; counter stream ptr hi
stream_work    = $0002  ; stream work byte
tile_base      = $000A  ; digit tile base
tile_base_hi   = $000B  ; digit tile base hi
row_param      = $000C  ; status panel row parameter
tile_attr      = $000D  ; digit tile attribute
  LDY #$00                                ; $BF4C: A0 00 ; counter 0 ($0574)
  LDA btl_status_ctr0                               ; $BF4E: AD 74 05
  LDX #$80                                ; $BF51: A2 80
  JSR @DrawHighNibble                     ; $BF53: 20 9D BF
  LDY #$00                                ; $BF56: A0 00
  LDA btl_status_ctr0                               ; $BF58: AD 74 05
  LDX #$70                                ; $BF5B: A2 70
  JSR @DrawLowNibble                      ; $BF5D: 20 A1 BF
  LDY #$02                                ; $BF60: A0 02 ; counter 1 ($0575)
  LDA btl_status_ctr1                               ; $BF62: AD 75 05
  LDX #$80                                ; $BF65: A2 80
  JSR @DrawHighNibble                     ; $BF67: 20 9D BF
  LDY #$02                                ; $BF6A: A0 02
  LDA btl_status_ctr1                               ; $BF6C: AD 75 05
  LDX #$70                                ; $BF6F: A2 70
  JSR @DrawLowNibble                      ; $BF71: 20 A1 BF
  LDY #$04                                ; $BF74: A0 04 ; counter 2 ($0576)
  LDA btl_status_ctr2                               ; $BF76: AD 76 05
  LDX #$80                                ; $BF79: A2 80
  JSR @DrawHighNibble                     ; $BF7B: 20 9D BF
  LDY #$04                                ; $BF7E: A0 04
  LDA btl_status_ctr2                               ; $BF80: AD 76 05
  LDX #$70                                ; $BF83: A2 70
  JSR @DrawLowNibble                      ; $BF85: 20 A1 BF
  LDY #$06                                ; $BF88: A0 06 ; counter 3 ($0577)
  LDA btl_status_ctr3                               ; $BF8A: AD 77 05
  LDX #$80                                ; $BF8D: A2 80
  JSR @DrawHighNibble                     ; $BF8F: 20 9D BF
  LDY #$06                                ; $BF92: A0 06
  LDA btl_status_ctr3                               ; $BF94: AD 77 05
  LDX #$70                                ; $BF97: A2 70
  JSR @DrawLowNibble                      ; $BF99: 20 A1 BF
  RTS                                     ; $BF9C: 60
@DrawHighNibble:
  LSR                                     ; $BF9D: 4A ; nibble -> bits 0-3
  LSR                                     ; $BF9E: 4A
  LSR                                     ; $BF9F: 4A
  LSR                                     ; $BFA0: 4A
@DrawLowNibble:
  AND #$0F                                ; $BFA1: 29 0F
  BEQ @Done                               ; $BFA3: F0 29 ; zero: nothing to draw
  STX a:row_param                             ; $BFA5: 8E 0C 00 ; row parameter
  LDA @PerCounterStreamPtrTable,Y         ; $BFA8: B9 CF BF ; PPU stream ptr lo
  STA a:stream_ptr_lo                             ; $BFAB: 8D 00 00
  LDA @PerCounterStreamPtrTable+1,Y       ; $BFAE: B9 D0 BF ; PPU stream ptr hi
  STA a:stream_ptr_hi                             ; $BFB1: 8D 01 00
  LDA #$D0                                ; $BFB4: A9 D0
  STA a:tile_base                             ; $BFB6: 8D 0A 00 ; digit tile base
  LDA #$00                                ; $BFB9: A9 00
  STA a:tile_base_hi                             ; $BFBB: 8D 0B 00
  STA a:tile_attr                             ; $BFBE: 8D 0D 00
  LDA #$00                                ; $BFC1: A9 00
  STA a:stream_work                             ; $BFC3: 8D 02 00
  JSR B1F_SpriteOamWriterScroll           ; $BFC6: 20 92 F0 ; submit PPU update
  LDA #$91                                ; $BFC9: A9 91
  STA a:$00B7                             ; $BFCB: 8D B7 00
@Done:
  RTS                                     ; $BFCE: 60
@PerCounterStreamPtrTable:  ; PPU stream ptr per counter, indexed Y = counter * 2
  .word BattleSideStatusCounterStream0    ; $BFCF: D7 BF ; counter 0 ($0574)
  .word BattleSideStatusCounterStream1    ; $BFD1: E8 BF ; counter 1 ($0575)
  .word BattleSideStatusCounterStream2    ; $BFD3: F9 BF ; counter 2 ($0576)
  .word BattleSideStatusCounterStream3    ; $BFD5: 0A C0 ; counter 3 ($0577)
.endproc
; --- Counter digit PPU streams (targets of @PerCounterStreamPtrTable) ---
; Four [relY,tile,attr,relX] records (2x2 digit pair) + $80 terminator each.
BattleSideStatusCounterStream0:  ; counter 0, tiles $69/$6A/$79/$7A
  .byte $00,$69,$00,$00,$00,$6A,$00,$08; $BFD7: 00 69 00 00 00 6A 00 08
  .byte $08,$79,$00,$00,$08,$7A,$00,$08,$80; $BFDF: 08 79 00 00 08 7A 00 08 80
BattleSideStatusCounterStream1:  ; counter 1, tiles $70-$73
  .byte $00,$70,$00,$00,$00,$71,$00,$08; $BFE8: 00 70 00 00 00 71 00 08
  .byte $08,$72,$00,$00,$08,$73,$00,$08,$80; $BFF0: 08 72 00 00 08 73 00 08 80
BattleSideStatusCounterStream2:  ; counter 2, tiles $6B/$6C/$7B/$7C; spans $BFFF/$C000
  .byte $00,$6B,$00,$00,$00,$6C,$00  ; $BFF9: 00 6B 00 00 00 6C 00

.segment "CODE_BANK0F"

  .byte $08                               ; $C000: 08 ; BattleSideStatusCounterStream2 tail
  .byte $08,$7B,$00,$00,$08,$7C,$00,$08,$80; $C001: 08 7B 00 00 08 7C 00 08 80
BattleSideStatusCounterStream3:  ; counter 3, tiles $6D/$6E/$7D/$7E (attr $02)
  .byte $00,$6D,$02,$00,$00,$6E,$02,$08; $C00A: 00 6D 02 00 00 6E 02 08
  .byte $08,$7D,$02,$00,$08,$7E,$02,$08,$80; $C012: 08 7D 02 00 08 7E 02 08 80
;===============================================================================
; $C01B: BattleChrBankAnimate
; Animates the battle CHR banks once per VBlank. Row index = bits 3-4 of the
; frame tick counter $005E (advances every 8 frames); battle phase 3
; ($0544) selects the second half of the table. Writes the chosen pair of CHR
; bank numbers to all five shadow copies of CHR bank 5 ($00B3/$00C3/$00CB/
; $00D3/$00DB) and CHR bank 7 ($00B5/$00C5/$00CD/$00D5/$00DD); the primary
; copies at $00AE-$00B5 are pushed to the Namco-163 by B1F ChrBankSwitch.
; Called only from BattleVBlankFrameUpdate.
;===============================================================================
.proc BattleChrBankAnimate

  LDA a:frame_tick                        ; $C01B: AD 5E 00
  LSR                                     ; $C01E: 4A
  LSR                                     ; $C01F: 4A
  LSR                                     ; $C020: 4A
  AND #$03                                ; $C021: 29 03
  TAY                                     ; $C023: A8
  LDA battle_phase                        ; $C024: AD 44 05
  CMP #$03                                ; $C027: C9 03
  BNE @select                             ; $C029: D0 04
  INY                                     ; $C02B: C8
  INY                                     ; $C02C: C8
  INY                                     ; $C02D: C8
  INY                                     ; $C02E: C8
@select:
  LDA BattleChrBankAnimTable,Y            ; $C02F: B9 54 C0
  STA a:$00B3                             ; $C032: 8D B3 00
  STA a:$00C3                             ; $C035: 8D C3 00
  STA a:$00CB                             ; $C038: 8D CB 00
  STA a:$00D3                             ; $C03B: 8D D3 00
  STA a:$00DB                             ; $C03E: 8D DB 00
  LDA BattleChrBankAnimTable+8,Y          ; $C041: B9 5C C0
  STA a:$00B5                             ; $C044: 8D B5 00
  STA a:$00C5                             ; $C047: 8D C5 00
  STA a:$00CD                             ; $C04A: 8D CD 00
  STA a:$00D5                             ; $C04D: 8D D5 00
  STA a:$00DD                             ; $C050: 8D DD 00
  RTS                                     ; $C053: 60
; CHR bank pairs per animation row: [bank for CHR slot 5] then [CHR slot 7]
BattleChrBankAnimTable:
  .byte $78,$79,$78,$79,$7A,$7B,$7A,$7B,$18,$19,$18,$19,$18,$19,$18,$19; $C054: 78 79 78 79 7A 7B 7A 7B 18 19 18 19 18 19 18 19
.endproc
;===============================================================================
; $C064: Phase2WalkDirectionResolve
; Walk-direction resolver for the phase-2 selection gate, called by
; Phase2ActionGate @Select ($A5AF) with Y = acting slot $0545. Picks a
; single step direction toward the objective and stores it in $0549
; (0=row-/up, 1=row+/down, 2=col-/left, 3=col+/right; $FF = none), after
; which the gate encodes $0549 into the column status and starts the cursor
; walk (sub 1). Objective: command 1 aims past the enemy edge (column $FF
; for side-A slots, $20 for side-B slots, on the enemy commander's row),
; other commands aim at the enemy commander (slot $0B for side-A actors,
; slot 0 for side-B actors). The column status low nibble ($05C2[$0545])
; selects the preferred axis: 0/3 step along the larger distance axis
; (random bit0 tiebreak via B1F_RandomByte), 2 biases to row steps, others
; bias to column steps; an already-aligned axis (< 2 tiles apart) switches
; to the other one. The preferred axis steps one tile toward the objective
; when that tile is empty (Phase2StepTileProbe carry) and terrain-passable
; (BattleTerrainPassabilityCheck returns 0); on failure the other axis
; gets one retry via the zero-page flag $0012, then $0549 <- $FF (the gate
; passes the turn).
;===============================================================================
.proc Phase2WalkDirectionResolve
; zero-page work cells (proc-local):
axis_retry     = $0012  ; axis retry counter
col_work       = $0010  ; objective column -> signed column delta
row_work       = $0011  ; objective row -> signed row delta
col_dist       = $0000  ; column distance
row_dist       = $0001  ; row distance
  LDA #$00                                ; $C064: A9 00
  STA a:axis_retry                             ; $C066: 8D 12 00 ; axis retry flag <- 0
  LDA btl_command                               ; $C069: AD 4F 05 ; command value
  CMP #$01                                ; $C06C: C9 01
  BEQ @AdvanceCommand                     ; $C06E: F0 25 ; command 1: edge objective
  LDA btl_scan_col                               ; $C070: AD 45 05 ; acting slot
  CMP #$0B                                ; $C073: C9 0B
  BCS @SideBActor                         ; $C075: B0 0F ; slot >= $0B: side B
  LDA btl_unit_col_b                               ; $C077: AD 8B 05 ; enemy commander column
  STA a:col_work                             ; $C07A: 8D 10 00
  LDA btl_unit_row_b                               ; $C07D: AD A1 05 ; enemy commander row
  STA a:row_work                             ; $C080: 8D 11 00
  JMP @ComputeDeltas                      ; $C083: 4C B8 C0
@SideBActor:
  LDA btl_unit_col_a                               ; $C086: AD 80 05 ; enemy commander column
  STA a:col_work                             ; $C089: 8D 10 00
  LDA btl_unit_row_a                               ; $C08C: AD 96 05 ; enemy commander row
  STA a:row_work                             ; $C08F: 8D 11 00
  JMP @ComputeDeltas                      ; $C092: 4C B8 C0
@AdvanceCommand:
  LDA btl_scan_col                               ; $C095: AD 45 05 ; acting slot
  CMP #$0B                                ; $C098: C9 0B
  BCS @SideBAdvance                       ; $C09A: B0 0E
  LDA #$FF                                ; $C09C: A9 FF ; past the left edge
  STA a:col_work                             ; $C09E: 8D 10 00
  LDA btl_unit_row_b                               ; $C0A1: AD A1 05 ; enemy commander row
  STA a:row_work                             ; $C0A4: 8D 11 00
  JMP @ComputeDeltas                      ; $C0A7: 4C B8 C0
@SideBAdvance:
  LDA #$20                                ; $C0AA: A9 20 ; past the right edge
  STA a:col_work                             ; $C0AC: 8D 10 00
  LDA btl_unit_row_a                               ; $C0AF: AD 96 05 ; enemy commander row
  STA a:row_work                             ; $C0B2: 8D 11 00
  JMP @ComputeDeltas                      ; $C0B5: 4C B8 C0
@ComputeDeltas:
  LDA btl_unit_col_a,Y                             ; $C0B8: B9 80 05 ; actor column
  SEC                                     ; $C0BB: 38
  SBC a:col_work                             ; $C0BC: ED 10 00 ; actor - objective
  STA a:col_work                             ; $C0BF: 8D 10 00 ; signed column delta
  BCS @ColumnAbsDone                      ; $C0C2: B0 05
  EOR #$FF                                ; $C0C4: 49 FF ; absolute value
  CLC                                     ; $C0C6: 18
  ADC #$01                                ; $C0C7: 69 01
@ColumnAbsDone:
  STA a:col_dist                             ; $C0C9: 8D 00 00 ; column distance
  LDA btl_unit_row_a,Y                             ; $C0CC: B9 96 05 ; actor row
  SEC                                     ; $C0CF: 38
  SBC a:row_work                             ; $C0D0: ED 11 00 ; actor - objective
  STA a:row_work                             ; $C0D3: 8D 11 00 ; signed row delta
  BCS @AxisPriority                       ; $C0D6: B0 05
  EOR #$FF                                ; $C0D8: 49 FF ; absolute value
  CLC                                     ; $C0DA: 18
  ADC #$01                                ; $C0DB: 69 01
@AxisPriority:
  STA a:row_dist                             ; $C0DD: 8D 01 00 ; row distance
  LDA btl_roster_code_a,Y                             ; $C0E0: B9 C2 05 ; column status
  AND #$0F                                ; $C0E3: 29 0F ; action bits
  BEQ @BalanceCompare                     ; $C0E5: F0 22 ; code 0: balanced
  CMP #$03                                ; $C0E7: C9 03
  BEQ @BalanceCompare                     ; $C0E9: F0 1E ; code 3: balanced
  CMP #$02                                ; $C0EB: C9 02
  BEQ @RowBias                            ; $C0ED: F0 0D ; code 2: row steps bias
  LDA a:col_dist                             ; $C0EF: AD 00 00 ; column distance
  CMP #$02                                ; $C0F2: C9 02
  BCC @ColumnAligned                      ; $C0F4: 90 03 ; on column: row step
  JMP @HorizontalStep                     ; $C0F6: 4C 23 C1
@ColumnAligned:
  JMP @VerticalFirst                      ; $C0F9: 4C 78 C1
@RowBias:
  LDA a:row_dist                             ; $C0FC: AD 01 00 ; row distance
  CMP #$02                                ; $C0FF: C9 02
  BCC @RowAligned                         ; $C101: 90 03 ; on row: column step
  JMP @VerticalFirst                      ; $C103: 4C 78 C1
@RowAligned:
  JMP @HorizontalStep                     ; $C106: 4C 23 C1
@BalanceCompare:
  LDA a:row_dist                             ; $C109: AD 01 00 ; row distance
  CMP a:col_dist                             ; $C10C: CD 00 00 ; vs column distance
  BEQ @BalanceTieRandom                   ; $C10F: F0 05 ; equal: random axis
  BCC @HorizontalFirst                    ; $C111: 90 0D ; column farther
  JMP @VerticalFirst                      ; $C113: 4C 78 C1 ; row farther
@BalanceTieRandom:
  JSR B1F_RandomByte                      ; $C116: 20 7A E8
  AND #$01                                ; $C119: 29 01
  BEQ @HorizontalFirst                    ; $C11B: F0 03
  JMP @VerticalFirst                      ; $C11D: 4C 78 C1
@HorizontalFirst:
  JMP @HorizontalStep                     ; $C120: 4C 23 C1
@HorizontalStep:
  LDA a:col_work                             ; $C123: AD 10 00 ; signed column delta
  BEQ @HorizontalTieRandom                ; $C126: F0 04 ; aligned: random side
  BMI @StepRight                          ; $C128: 30 23 ; objective right of actor
  BPL @StepLeft                           ; $C12A: 10 07 ; objective left of actor
@HorizontalTieRandom:
  JSR B1F_RandomByte                      ; $C12C: 20 7A E8
  AND #$80                                ; $C12F: 29 80
  BNE @StepRight                          ; $C131: D0 1A
@StepLeft:
  LDA #$FF                                ; $C133: A9 FF ; step delta (-1, 0)
  STA a:col_dist                             ; $C135: 8D 00 00
  LDA #$00                                ; $C138: A9 00
  STA a:row_dist                             ; $C13A: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C13D: 20 CD C1 ; probe left tile
  BCC @HorizontalRetry                    ; $C140: 90 25 ; occupied: blocked
  JSR BattleTerrainPassabilityCheck       ; $C142: 20 F9 CA ; terrain passability
  BNE @HorizontalRetry                    ; $C145: D0 20 ; impassable terrain
  LDA #$02                                ; $C147: A9 02 ; direction: left
  STA btl_acting_unit                               ; $C149: 8D 49 05
  RTS                                     ; $C14C: 60
@StepRight:
  LDA #$01                                ; $C14D: A9 01 ; step delta (+1, 0)
  STA a:col_dist                             ; $C14F: 8D 00 00
  LDA #$00                                ; $C152: A9 00
  STA a:row_dist                             ; $C154: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C157: 20 CD C1 ; probe right tile
  BCC @HorizontalRetry                    ; $C15A: 90 0B ; occupied: blocked
  JSR BattleTerrainPassabilityCheck       ; $C15C: 20 F9 CA ; terrain passability
  BNE @HorizontalRetry                    ; $C15F: D0 06 ; impassable terrain
  LDA #$03                                ; $C161: A9 03 ; direction: right
  STA btl_acting_unit                               ; $C163: 8D 49 05
  RTS                                     ; $C166: 60
@HorizontalRetry:
  LDA a:axis_retry                             ; $C167: AD 12 00 ; axis retry flag
  BNE @HorizontalGiveUp                   ; $C16A: D0 06 ; already retried
  INC a:axis_retry                             ; $C16C: EE 12 00
  JMP @VerticalFirst                      ; $C16F: 4C 78 C1 ; try the row axis
@HorizontalGiveUp:
  LDA #$FF                                ; $C172: A9 FF ; no direction
  STA btl_acting_unit                               ; $C174: 8D 49 05
  RTS                                     ; $C177: 60
@VerticalFirst:
  LDA a:row_work                             ; $C178: AD 11 00 ; signed row delta
  BEQ @VerticalTieRandom                  ; $C17B: F0 04 ; aligned: random side
  BMI @StepDown                           ; $C17D: 30 23 ; objective below actor
  BPL @StepUp                             ; $C17F: 10 07 ; objective above actor
@VerticalTieRandom:
  JSR B1F_RandomByte                      ; $C181: 20 7A E8
  AND #$80                                ; $C184: 29 80
  BNE @StepDown                           ; $C186: D0 1A
@StepUp:
  LDA #$00                                ; $C188: A9 00 ; step delta (0, -1)
  STA a:col_dist                             ; $C18A: 8D 00 00
  LDA #$FF                                ; $C18D: A9 FF
  STA a:row_dist                             ; $C18F: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C192: 20 CD C1 ; probe upper tile
  BCC @VerticalRetry                      ; $C195: 90 25 ; occupied: blocked
  JSR BattleTerrainPassabilityCheck       ; $C197: 20 F9 CA ; terrain passability
  BNE @VerticalRetry                      ; $C19A: D0 20 ; impassable terrain
  LDA #$00                                ; $C19C: A9 00 ; direction: up
  STA btl_acting_unit                               ; $C19E: 8D 49 05
  RTS                                     ; $C1A1: 60
@StepDown:
  LDA #$00                                ; $C1A2: A9 00 ; step delta (0, +1)
  STA a:col_dist                             ; $C1A4: 8D 00 00
  LDA #$01                                ; $C1A7: A9 01
  STA a:row_dist                             ; $C1A9: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C1AC: 20 CD C1 ; probe lower tile
  BCC @VerticalRetry                      ; $C1AF: 90 0B ; occupied: blocked
  JSR BattleTerrainPassabilityCheck       ; $C1B1: 20 F9 CA ; terrain passability
  BNE @VerticalRetry                      ; $C1B4: D0 06 ; impassable terrain
  LDA #$01                                ; $C1B6: A9 01 ; direction: down
  STA btl_acting_unit                               ; $C1B8: 8D 49 05
  RTS                                     ; $C1BB: 60
@VerticalRetry:
  LDA a:axis_retry                             ; $C1BC: AD 12 00 ; axis retry flag
  BNE @VerticalGiveUp                     ; $C1BF: D0 06 ; already retried
  INC a:axis_retry                             ; $C1C1: EE 12 00
  JMP @HorizontalStep                     ; $C1C4: 4C 23 C1 ; try the column axis
@VerticalGiveUp:
  LDA #$FF                                ; $C1C7: A9 FF ; no direction
  STA btl_acting_unit                               ; $C1C9: 8D 49 05
  RTS                                     ; $C1CC: 60
.endproc
;-------------------------------------------------------------------------------
; $C1CD: Phase2StepTileProbe
; Step-tile probe shared by the direction resolvers (Phase2WalkDirectionResolve
; selection gate, Phase2MoveRouteResolve move route, Phase2AttackRouteResolve
; attack route and later routines). Applies the step delta
; ($0000 = column, $0001 = row,
; signed) to the acting slot $0545's position ($0580/$0596), writing the
; candidate tile back into $0000/$0001. Bounds: column < $10, row < $0A;
; then scans all 22 slots
; ($15 down to 0) for an occupant of the candidate tile.
; Returns:
;   carry set              - tile empty (all 22 slots scanned);
;   carry clear, A = $01   - occupied by an opposing-side unit
;                            (BattleSlotSideCompare), X = occupant slot;
;   carry clear, A = $00   - occupied by a same-side unit, or out of
;                            bounds.
;-------------------------------------------------------------------------------
.proc Phase2StepTileProbe
; zero-page work cells (proc-local):
cand_col       = $0000  ; candidate column (col + delta)
cand_row       = $0001  ; candidate row (row + delta)
  LDY btl_scan_col                               ; $C1CD: AC 45 05 ; acting slot
  LDA btl_unit_col_a,Y                             ; $C1D0: B9 80 05 ; actor column
  CLC                                     ; $C1D3: 18
  ADC a:cand_col                             ; $C1D4: 6D 00 00 ; + column delta
  STA a:cand_col                             ; $C1D7: 8D 00 00 ; candidate column
  CMP #$10                                ; $C1DA: C9 10
  BCS @OutOfBounds                        ; $C1DC: B0 28 ; off board: blocked
  LDA btl_unit_row_a,Y                             ; $C1DE: B9 96 05 ; actor row
  CLC                                     ; $C1E1: 18
  ADC a:cand_row                             ; $C1E2: 6D 01 00 ; + row delta
  STA a:cand_row                             ; $C1E5: 8D 01 00 ; candidate row
  CMP #$0A                                ; $C1E8: C9 0A
  BCS @OutOfBounds                        ; $C1EA: B0 1A ; off board: blocked
  LDX #$15                                ; $C1EC: A2 15 ; last roster slot
@ScanSlots:
  LDA btl_unit_col_a,X                             ; $C1EE: BD 80 05 ; slot column
  CMP a:cand_col                             ; $C1F1: CD 00 00
  BNE @NextSlot                           ; $C1F4: D0 14
  LDA btl_unit_row_a,X                             ; $C1F6: BD 96 05 ; slot row
  CMP a:cand_row                             ; $C1F9: CD 01 00
  BNE @NextSlot                           ; $C1FC: D0 0C
  LDA btl_scan_col                               ; $C1FE: AD 45 05 ; actor slot
  JSR BattleSlotSideCompare               ; $C201: 20 27 C8 ; A=1 if enemy
  CLC                                     ; $C204: 18 ; occupied: blocked
  RTS                                     ; $C205: 60
@OutOfBounds:
  LDA #$00                                ; $C206: A9 00 ; blocked, not a target
  CLC                                     ; $C208: 18
  RTS                                     ; $C209: 60
@NextSlot:
  DEX                                     ; $C20A: CA
  BPL @ScanSlots                          ; $C20B: 10 E1
  SEC                                     ; $C20D: 38 ; no occupant: empty tile
  RTS                                     ; $C20E: 60
.endproc
;===============================================================================
; $C20F: Phase2MoveRouteResolve
; Move-route direction resolver called from Phase2ActionGate (@MoveRoute) when
; the acting unit's command takes the move path. Probes the four orthogonal
; neighbours of acting slot $0545 via Phase2StepTileProbe looking for an
; adjacent enemy unit, in randomized axis order (bit 0 of B1F_RandomByte) and
; randomized side order per axis (sign bit). An enemy hit commits: direction
; code (0 = up, 1 = down, 2 = left, 3 = right) <- $0549, enemy slot <- $054A
; (becomes Phase2MoveCommit's damage target). Empty or same-side tiles bounce
; off the zero-page probe counter $0010: retry value 3 gives up with
; $0549 <- $FF (all four neighbours blocked; the caller drops to the
; selection gate), value 1 switches to the other axis (both sides of the
; current axis failed), anything else probes the flip side. $0011 is cleared
; alongside $0010 but unused here. Every neighbour is probed at most once, so
; the retry chain always terminates within four probes.
;===============================================================================
.proc Phase2MoveRouteResolve
; zero-page work cells (proc-local):
probe_ctr      = $0010  ; probe loop counter
probe_spare    = $0011  ; spare (cleared, unused)
cand_col       = $0000  ; candidate column argument
cand_row       = $0001  ; candidate row argument
  LDA #$00                                ; $C20F: A9 00
  STA a:probe_ctr                             ; $C211: 8D 10 00 ; probe counter <- 0
  STA a:probe_spare                             ; $C214: 8D 11 00 ; spare clear (unused)
  JSR B1F_RandomByte                      ; $C217: 20 7A E8
  AND #$01                                ; $C21A: 29 01 ; axis pick
  BEQ @HorizontalAxis                     ; $C21C: F0 03 ; bit0 = 0: columns first
  JMP @VerticalAxis                       ; $C21E: 4C 98 C2 ; bit0 = 1: rows first
@HorizontalAxis:
  JSR B1F_RandomByte                      ; $C221: 20 7A E8 ; side pick
  AND #$80                                ; $C224: 29 80
  BNE @ProbeRight                         ; $C226: D0 38 ; sign set: right first
@ProbeLeft:
  LDA #$FF                                ; $C228: A9 FF ; step delta (-1, 0)
  STA a:cand_col                             ; $C22A: 8D 00 00
  LDA #$00                                ; $C22D: A9 00
  STA a:cand_row                             ; $C22F: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C232: 20 CD C1 ; probe left tile
  BCS @LeftRetry                          ; $C235: B0 0C ; empty: blocked
  TAY                                     ; $C237: A8
  BEQ @LeftRetry                          ; $C238: F0 09 ; same side: blocked
  STX btl_walk_row                               ; $C23A: 8E 4A 05 ; enemy slot -> target
  LDA #$02                                ; $C23D: A9 02 ; direction: left
  STA btl_acting_unit                               ; $C23F: 8D 49 05
  RTS                                     ; $C242: 60
@LeftRetry:
  LDA a:probe_ctr                             ; $C243: AD 10 00 ; probe counter
  CMP #$03                                ; $C246: C9 03
  BNE @LeftSwitchCheck                    ; $C248: D0 06
  LDA #$FF                                ; $C24A: A9 FF ; no direction
  STA btl_acting_unit                               ; $C24C: 8D 49 05
  RTS                                     ; $C24F: 60
@LeftSwitchCheck:
  CMP #$01                                ; $C250: C9 01
  BNE @LeftFlipSide                       ; $C252: D0 06
  INC a:probe_ctr                             ; $C254: EE 10 00
  JMP @VerticalAxis                       ; $C257: 4C 98 C2 ; axis exhausted: rows
@LeftFlipSide:
  INC a:probe_ctr                             ; $C25A: EE 10 00
  JMP @ProbeRight                         ; $C25D: 4C 60 C2 ; try the other side
@ProbeRight:
  LDA #$01                                ; $C260: A9 01 ; step delta (+1, 0)
  STA a:cand_col                             ; $C262: 8D 00 00
  LDA #$00                                ; $C265: A9 00
  STA a:cand_row                             ; $C267: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C26A: 20 CD C1 ; probe right tile
  BCS @RightRetry                         ; $C26D: B0 0C ; empty: blocked
  TAY                                     ; $C26F: A8
  BEQ @RightRetry                         ; $C270: F0 09 ; same side: blocked
  STX btl_walk_row                               ; $C272: 8E 4A 05 ; enemy slot -> target
  LDA #$03                                ; $C275: A9 03 ; direction: right
  STA btl_acting_unit                               ; $C277: 8D 49 05
  RTS                                     ; $C27A: 60
@RightRetry:
  LDA a:probe_ctr                             ; $C27B: AD 10 00 ; probe counter
  CMP #$03                                ; $C27E: C9 03
  BNE @RightSwitchCheck                   ; $C280: D0 06
  LDA #$FF                                ; $C282: A9 FF ; no direction
  STA btl_acting_unit                               ; $C284: 8D 49 05
  RTS                                     ; $C287: 60
@RightSwitchCheck:
  CMP #$01                                ; $C288: C9 01
  BNE @RightFlipSide                      ; $C28A: D0 06
  INC a:probe_ctr                             ; $C28C: EE 10 00
  JMP @VerticalAxis                       ; $C28F: 4C 98 C2 ; axis exhausted: rows
@RightFlipSide:
  INC a:probe_ctr                             ; $C292: EE 10 00
  JMP @ProbeLeft                          ; $C295: 4C 28 C2 ; try the other side
@VerticalAxis:
  JSR B1F_RandomByte                      ; $C298: 20 7A E8 ; side pick
  AND #$80                                ; $C29B: 29 80
  BNE @ProbeDown                          ; $C29D: D0 38 ; sign set: down first
@ProbeUp:
  LDA #$00                                ; $C29F: A9 00 ; step delta (0, -1)
  STA a:cand_col                             ; $C2A1: 8D 00 00
  LDA #$FF                                ; $C2A4: A9 FF
  STA a:cand_row                             ; $C2A6: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C2A9: 20 CD C1 ; probe upper tile
  BCS @UpRetry                            ; $C2AC: B0 0C ; empty: blocked
  TAY                                     ; $C2AE: A8
  BEQ @UpRetry                            ; $C2AF: F0 09 ; same side: blocked
  STX btl_walk_row                               ; $C2B1: 8E 4A 05 ; enemy slot -> target
  LDA #$00                                ; $C2B4: A9 00 ; direction: up
  STA btl_acting_unit                               ; $C2B6: 8D 49 05
  RTS                                     ; $C2B9: 60
@UpRetry:
  LDA a:probe_ctr                             ; $C2BA: AD 10 00 ; probe counter
  CMP #$03                                ; $C2BD: C9 03
  BNE @UpSwitchCheck                      ; $C2BF: D0 06
  LDA #$FF                                ; $C2C1: A9 FF ; no direction
  STA btl_acting_unit                               ; $C2C3: 8D 49 05
  RTS                                     ; $C2C6: 60
@UpSwitchCheck:
  CMP #$01                                ; $C2C7: C9 01
  BNE @UpFlipSide                         ; $C2C9: D0 06
  INC a:probe_ctr                             ; $C2CB: EE 10 00
  JMP @HorizontalAxis                     ; $C2CE: 4C 21 C2 ; axis exhausted: columns
@UpFlipSide:
  INC a:probe_ctr                             ; $C2D1: EE 10 00
  JMP @ProbeDown                          ; $C2D4: 4C D7 C2 ; try the other side
@ProbeDown:
  LDA #$00                                ; $C2D7: A9 00 ; step delta (0, +1)
  STA a:cand_col                             ; $C2D9: 8D 00 00
  LDA #$01                                ; $C2DC: A9 01
  STA a:cand_row                             ; $C2DE: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C2E1: 20 CD C1 ; probe lower tile
  BCS @DownRetry                          ; $C2E4: B0 0C ; empty: blocked
  TAY                                     ; $C2E6: A8
  BEQ @DownRetry                          ; $C2E7: F0 09 ; same side: blocked
  STX btl_walk_row                               ; $C2E9: 8E 4A 05 ; enemy slot -> target
  LDA #$01                                ; $C2EC: A9 01 ; direction: down
  STA btl_acting_unit                               ; $C2EE: 8D 49 05
  RTS                                     ; $C2F1: 60
@DownRetry:
  LDA a:probe_ctr                             ; $C2F2: AD 10 00 ; probe counter
  CMP #$03                                ; $C2F5: C9 03
  BNE @DownSwitchCheck                    ; $C2F7: D0 06
  LDA #$FF                                ; $C2F9: A9 FF ; no direction
  STA btl_acting_unit                               ; $C2FB: 8D 49 05
  RTS                                     ; $C2FE: 60
@DownSwitchCheck:
  CMP #$01                                ; $C2FF: C9 01
  BNE @DownFlipSide                       ; $C301: D0 06
  INC a:probe_ctr                             ; $C303: EE 10 00
  JMP @HorizontalAxis                     ; $C306: 4C 21 C2 ; axis exhausted: columns
@DownFlipSide:
  INC a:probe_ctr                             ; $C309: EE 10 00
  JMP @ProbeUp                            ; $C30C: 4C 9F C2 ; try the other side
.endproc
;===============================================================================
; $C30F: Phase2AttackRouteResolve
; Attack-route resolver called from Phase2ActionGate ($A536) when the cursor
; column's action bits == 2. Scans outward along one orthogonal axis from
; the acting slot $0545 looking for an enemy column to shoot at. Axis order
; (bit 0 of B1F_RandomByte) and side per axis (sign bit) are randomized.
; Each side walks tiles 1-6 away in order, testing every tile with
; Phase2ArrowPathTileCheck (bounds + terrain; blocking terrain aborts the
; side) and Phase2StepTileProbe: an enemy at distance 1 aborts the side
; (point-blank combat is the move route's job), empty and same-side tiles
; are shot over, and the first enemy column commits: target column <- $054D,
; arrow flight counter $0548 <- $1C/$2C/$3C/$4C/$5C for distances 2-6
; (Phase2AttackArrowAnim decrements it by 2 per frame), direction $0549 <-
; 0 up / 1 down / 2 left / 3 right. Distances 5-6 additionally require the
; acting side's nibble of $0575 (loaded to 3 by Phase8RowCounter575, ticked
; down by BattleSideStatusCountersDecrement) to be non-zero.
; Side failures dispatch through the probe counter $0010 like
; Phase2MoveRouteResolve: 3 = give up ($0549 <- $FF, the gate falls back to
; the move route), 1 = switch axis, otherwise flip side - except @LeftFail
; re-enters itself, so a fresh failure on the left side double-increments
; and switches axis without probing the right side. $0011 is cleared
; alongside $0010 but unused here.
;===============================================================================
.proc Phase2AttackRouteResolve
; zero-page work cells (proc-local):
probe_ctr      = $0010  ; probe loop counter
probe_spare    = $0011  ; spare (cleared, unused)
cand_col       = $0000  ; candidate column argument
cand_row       = $0001  ; candidate row argument
  LDA #$00                                ; $C30F: A9 00
  STA a:probe_ctr                             ; $C311: 8D 10 00 ; probe counter <- 0
  STA a:probe_spare                             ; $C314: 8D 11 00 ; spare clear (unused)
  JSR B1F_RandomByte                      ; $C317: 20 7A E8
  AND #$01                                ; $C31A: 29 01 ; axis pick
  BEQ @HorizontalAxis                     ; $C31C: F0 03 ; bit0 = 0: columns first
  JMP @VerticalAxis                       ; $C31E: 4C A4 C5 ; bit0 = 1: rows first
@HorizontalAxis:
  JSR B1F_RandomByte                      ; $C321: 20 7A E8 ; side pick
  AND #$80                                ; $C324: 29 80
  BNE @LeftAdjTerrain                     ; $C326: D0 03 ; sign set: left first
  JMP @RightAdjTerrain                    ; $C328: 4C 69 C4 ; clear: right first
@LeftAdjTerrain:
  LDA #$FF                                ; $C32B: A9 FF ; step delta (-1, 0)
  STA a:cand_col                             ; $C32D: 8D 00 00
  LDA #$00                                ; $C330: A9 00
  STA a:cand_row                             ; $C332: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C335: 20 C8 CA ; range-1 terrain
  TAY                                     ; $C338: A8
  BEQ @LeftAdjProbe                       ; $C339: F0 03 ; passable
  JMP @LeftFail                           ; $C33B: 4C 4C C4 ; blocked terrain
@LeftAdjProbe:
  LDA #$FF                                ; $C33E: A9 FF ; step delta (-1, 0)
  STA a:cand_col                             ; $C340: 8D 00 00
  LDA #$00                                ; $C343: A9 00
  STA a:cand_row                             ; $C345: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C348: 20 CD C1 ; probe adjacent tile
  BCS @LeftRange2Terrain                  ; $C34B: B0 06 ; empty: keep scanning
  TAY                                     ; $C34D: A8
  BEQ @LeftRange2Terrain                  ; $C34E: F0 03 ; ally: shoot over
  JMP @LeftFail                           ; $C350: 4C 4C C4 ; enemy: melee route's job
@LeftRange2Terrain:
  LDA #$FE                                ; $C353: A9 FE ; step delta (-2, 0)
  STA a:cand_col                             ; $C355: 8D 00 00
  LDA #$00                                ; $C358: A9 00
  STA a:cand_row                             ; $C35A: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C35D: 20 C8 CA
  TAY                                     ; $C360: A8
  BEQ @LeftRange2Probe                    ; $C361: F0 03
  JMP @LeftFail                           ; $C363: 4C 4C C4
@LeftRange2Probe:
  LDA #$FE                                ; $C366: A9 FE ; step delta (-2, 0)
  STA a:cand_col                             ; $C368: 8D 00 00
  LDA #$00                                ; $C36B: A9 00
  STA a:cand_row                             ; $C36D: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C370: 20 CD C1
  BCS @LeftRange3Terrain                  ; $C373: B0 08 ; empty: keep scanning
  TAY                                     ; $C375: A8
  BEQ @LeftRange3Terrain                  ; $C376: F0 05 ; ally: shoot over
  LDA #$1C                                ; $C378: A9 1C ; flight counter, dist 2
  JMP @CommitLeft                         ; $C37A: 4C 40 C4
@LeftRange3Terrain:
  LDA #$FD                                ; $C37D: A9 FD ; step delta (-3, 0)
  STA a:cand_col                             ; $C37F: 8D 00 00
  LDA #$00                                ; $C382: A9 00
  STA a:cand_row                             ; $C384: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C387: 20 C8 CA
  TAY                                     ; $C38A: A8
  BEQ @LeftRange3Probe                    ; $C38B: F0 03
  JMP @LeftFail                           ; $C38D: 4C 4C C4
@LeftRange3Probe:
  LDA #$FD                                ; $C390: A9 FD ; step delta (-3, 0)
  STA a:cand_col                             ; $C392: 8D 00 00
  LDA #$00                                ; $C395: A9 00
  STA a:cand_row                             ; $C397: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C39A: 20 CD C1
  BCS @LeftRange4Terrain                  ; $C39D: B0 08 ; empty: keep scanning
  TAY                                     ; $C39F: A8
  BEQ @LeftRange4Terrain                  ; $C3A0: F0 05 ; ally: shoot over
  LDA #$2C                                ; $C3A2: A9 2C ; flight counter, dist 3
  JMP @CommitLeft                         ; $C3A4: 4C 40 C4
@LeftRange4Terrain:
  LDA #$FC                                ; $C3A7: A9 FC ; step delta (-4, 0)
  STA a:cand_col                             ; $C3A9: 8D 00 00
  LDA #$00                                ; $C3AC: A9 00
  STA a:cand_row                             ; $C3AE: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C3B1: 20 C8 CA
  TAY                                     ; $C3B4: A8
  BEQ @LeftRange4Probe                    ; $C3B5: F0 03
  JMP @LeftFail                           ; $C3B7: 4C 4C C4
@LeftRange4Probe:
  LDA #$FC                                ; $C3BA: A9 FC ; step delta (-4, 0)
  STA a:cand_col                             ; $C3BC: 8D 00 00
  LDA #$00                                ; $C3BF: A9 00
  STA a:cand_row                             ; $C3C1: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C3C4: 20 CD C1
  BCS @LeftRangeGate                      ; $C3C7: B0 08 ; empty: keep scanning
  TAY                                     ; $C3C9: A8
  BEQ @LeftRangeGate                      ; $C3CA: F0 05 ; ally: shoot over
  LDA #$3C                                ; $C3CC: A9 3C ; flight counter, dist 4
  JMP @CommitLeft                         ; $C3CE: 4C 40 C4
@LeftRangeGate:
  LDA btl_scan_col                               ; $C3D1: AD 45 05 ; acting slot
  CMP #$0B                                ; $C3D4: C9 0B
  BCC @LeftGateSideA                      ; $C3D6: 90 0A ; side A actor
  LDA btl_status_ctr1                               ; $C3D8: AD 75 05 ; side range counters
  AND #$F0                                ; $C3DB: 29 F0 ; side B nibble
  BNE @LeftRange5Terrain                  ; $C3DD: D0 0D ; long range granted
  JMP @LeftFail                           ; $C3DF: 4C 4C C4 ; no long range
@LeftGateSideA:
  LDA btl_status_ctr1                               ; $C3E2: AD 75 05
  AND #$0F                                ; $C3E5: 29 0F ; side A nibble
  BNE @LeftRange5Terrain                  ; $C3E7: D0 03 ; long range granted
  JMP @LeftFail                           ; $C3E9: 4C 4C C4 ; no long range
@LeftRange5Terrain:
  LDA #$FB                                ; $C3EC: A9 FB ; step delta (-5, 0)
  STA a:cand_col                             ; $C3EE: 8D 00 00
  LDA #$00                                ; $C3F1: A9 00
  STA a:cand_row                             ; $C3F3: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C3F6: 20 C8 CA
  TAY                                     ; $C3F9: A8
  BEQ @LeftRange5Probe                    ; $C3FA: F0 03
  JMP @LeftFail                           ; $C3FC: 4C 4C C4
@LeftRange5Probe:
  LDA #$FB                                ; $C3FF: A9 FB ; step delta (-5, 0)
  STA a:cand_col                             ; $C401: 8D 00 00
  LDA #$00                                ; $C404: A9 00
  STA a:cand_row                             ; $C406: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C409: 20 CD C1
  BCS @LeftRange6Terrain                  ; $C40C: B0 08 ; empty: keep scanning
  TAY                                     ; $C40E: A8
  BEQ @LeftRange6Terrain                  ; $C40F: F0 05 ; ally: shoot over
  LDA #$4C                                ; $C411: A9 4C ; flight counter, dist 5
  JMP @CommitLeft                         ; $C413: 4C 40 C4
@LeftRange6Terrain:
  LDA #$FA                                ; $C416: A9 FA ; step delta (-6, 0)
  STA a:cand_col                             ; $C418: 8D 00 00
  LDA #$00                                ; $C41B: A9 00
  STA a:cand_row                             ; $C41D: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C420: 20 C8 CA
  TAY                                     ; $C423: A8
  BEQ @LeftRange6Probe                    ; $C424: F0 03
  JMP @LeftFail                           ; $C426: 4C 4C C4
@LeftRange6Probe:
  LDA #$FA                                ; $C429: A9 FA ; step delta (-6, 0)
  STA a:cand_col                             ; $C42B: 8D 00 00
  LDA #$00                                ; $C42E: A9 00
  STA a:cand_row                             ; $C430: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C433: 20 CD C1
  BCS @LeftFail                           ; $C436: B0 14 ; empty: out of range
  TAY                                     ; $C438: A8
  BEQ @LeftFail                           ; $C439: F0 11 ; ally: out of range
  LDA #$5C                                ; $C43B: A9 5C ; flight counter, dist 6
  JMP @CommitLeft                         ; $C43D: 4C 40 C4
@CommitLeft:
  STX btl_target_col                               ; $C440: 8E 4D 05 ; target column
  STA btl_frame_counter                               ; $C443: 8D 48 05 ; arrow flight counter
  LDA #$02                                ; $C446: A9 02
  STA btl_acting_unit                               ; $C448: 8D 49 05 ; direction: left
  RTS                                     ; $C44B: 60
@LeftFail:
  LDA a:probe_ctr                             ; $C44C: AD 10 00 ; probe counter
  CMP #$03                                ; $C44F: C9 03
  BNE @LeftFailSwitch                     ; $C451: D0 06
  LDA #$FF                                ; $C453: A9 FF ; no direction
  STA btl_acting_unit                               ; $C455: 8D 49 05
  RTS                                     ; $C458: 60
@LeftFailSwitch:
  CMP #$01                                ; $C459: C9 01
  BNE @LeftFailFlip                       ; $C45B: D0 06
  INC a:probe_ctr                             ; $C45D: EE 10 00
  JMP @VerticalAxis                       ; $C460: 4C A4 C5 ; axis exhausted: rows
@LeftFailFlip:
  INC a:probe_ctr                             ; $C463: EE 10 00
  JMP @LeftFail                           ; $C466: 4C 4C C4 ; re-dispatch, count++
@RightAdjTerrain:
  LDA #$01                                ; $C469: A9 01 ; step delta (+1, 0)
  STA a:cand_col                             ; $C46B: 8D 00 00
  LDA #$00                                ; $C46E: A9 00
  STA a:cand_row                             ; $C470: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C473: 20 C8 CA ; range-1 terrain
  TAY                                     ; $C476: A8
  BEQ @RightAdjProbe                      ; $C477: F0 03 ; passable
  JMP @RightFail                          ; $C479: 4C 87 C5 ; blocked terrain
@RightAdjProbe:
  LDA #$01                                ; $C47C: A9 01 ; step delta (+1, 0)
  STA a:cand_col                             ; $C47E: 8D 00 00
  LDA #$00                                ; $C481: A9 00
  STA a:cand_row                             ; $C483: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C486: 20 CD C1 ; probe adjacent tile
  BCS @RightRange2Terrain                 ; $C489: B0 06 ; empty: keep scanning
  TAY                                     ; $C48B: A8
  BEQ @RightRange2Terrain                 ; $C48C: F0 03 ; ally: shoot over
  JMP @RightFail                          ; $C48E: 4C 87 C5 ; enemy: melee route's job
@RightRange2Terrain:
  LDA #$02                                ; $C491: A9 02 ; step delta (+2, 0)
  STA a:cand_col                             ; $C493: 8D 00 00
  LDA #$00                                ; $C496: A9 00
  STA a:cand_row                             ; $C498: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C49B: 20 C8 CA
  TAY                                     ; $C49E: A8
  BEQ @RightRange2Probe                   ; $C49F: F0 03
  JMP @RightFail                          ; $C4A1: 4C 87 C5
@RightRange2Probe:
  LDA #$02                                ; $C4A4: A9 02 ; step delta (+2, 0)
  STA a:cand_col                             ; $C4A6: 8D 00 00
  LDA #$00                                ; $C4A9: A9 00
  STA a:cand_row                             ; $C4AB: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C4AE: 20 CD C1
  BCS @RightRange3Terrain                 ; $C4B1: B0 08 ; empty: keep scanning
  TAY                                     ; $C4B3: A8
  BEQ @RightRange3Terrain                 ; $C4B4: F0 05 ; ally: shoot over
  LDA #$1C                                ; $C4B6: A9 1C ; flight counter, dist 2
  JMP @CommitRight                        ; $C4B8: 4C 7B C5
@RightRange3Terrain:
  LDA #$03                                ; $C4BB: A9 03 ; step delta (+3, 0)
  STA a:cand_col                             ; $C4BD: 8D 00 00
  LDA #$00                                ; $C4C0: A9 00
  STA a:cand_row                             ; $C4C2: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C4C5: 20 C8 CA
  TAY                                     ; $C4C8: A8
  BEQ @RightRange3Probe                   ; $C4C9: F0 03
  JMP @RightFail                          ; $C4CB: 4C 87 C5
@RightRange3Probe:
  LDA #$03                                ; $C4CE: A9 03 ; step delta (+3, 0)
  STA a:cand_col                             ; $C4D0: 8D 00 00
  LDA #$00                                ; $C4D3: A9 00
  STA a:cand_row                             ; $C4D5: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C4D8: 20 CD C1
  BCS @RightRange4Terrain                 ; $C4DB: B0 08 ; empty: keep scanning
  TAY                                     ; $C4DD: A8
  BEQ @RightRange4Terrain                 ; $C4DE: F0 05 ; ally: shoot over
  LDA #$2C                                ; $C4E0: A9 2C ; flight counter, dist 3
  JMP @CommitRight                        ; $C4E2: 4C 7B C5
@RightRange4Terrain:
  LDA #$04                                ; $C4E5: A9 04 ; step delta (+4, 0)
  STA a:cand_col                             ; $C4E7: 8D 00 00
  LDA #$00                                ; $C4EA: A9 00
  STA a:cand_row                             ; $C4EC: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C4EF: 20 C8 CA
  TAY                                     ; $C4F2: A8
  BEQ @RightRange4Probe                   ; $C4F3: F0 03
  JMP @RightFail                          ; $C4F5: 4C 87 C5
@RightRange4Probe:
  LDA #$04                                ; $C4F8: A9 04 ; step delta (+4, 0)
  STA a:cand_col                             ; $C4FA: 8D 00 00
  LDA #$00                                ; $C4FD: A9 00
  STA a:cand_row                             ; $C4FF: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C502: 20 CD C1
  BCS @RightRangeGate                     ; $C505: B0 08 ; empty: keep scanning
  TAY                                     ; $C507: A8
  BEQ @RightRangeGate                     ; $C508: F0 05 ; ally: shoot over
  LDA #$3C                                ; $C50A: A9 3C ; flight counter, dist 4
  JMP @CommitRight                        ; $C50C: 4C 7B C5
@RightRangeGate:
  LDA btl_scan_col                               ; $C50F: AD 45 05 ; acting slot
  CMP #$0B                                ; $C512: C9 0B
  BCC @RightGateSideA                     ; $C514: 90 0A ; side A actor
  LDA btl_status_ctr1                               ; $C516: AD 75 05 ; side range counters
  AND #$F0                                ; $C519: 29 F0 ; side B nibble
  BNE @RightRange5Terrain                 ; $C51B: D0 0D ; long range granted
  JMP @RightFail                          ; $C51D: 4C 87 C5 ; no long range
@RightGateSideA:
  LDA btl_status_ctr1                               ; $C520: AD 75 05
  AND #$0F                                ; $C523: 29 0F ; side A nibble
  BNE @RightRange5Terrain                 ; $C525: D0 03 ; long range granted
  JMP @RightFail                          ; $C527: 4C 87 C5 ; no long range
@RightRange5Terrain:
  LDA #$05                                ; $C52A: A9 05 ; step delta (+5, 0)
  STA a:cand_col                             ; $C52C: 8D 00 00
  LDA #$00                                ; $C52F: A9 00
  STA a:cand_row                             ; $C531: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C534: 20 C8 CA
  TAY                                     ; $C537: A8
  BEQ @RightRange5Probe                   ; $C538: F0 03
  JMP @RightFail                          ; $C53A: 4C 87 C5
@RightRange5Probe:
  LDA #$05                                ; $C53D: A9 05 ; step delta (+5, 0)
  STA a:cand_col                             ; $C53F: 8D 00 00
  LDA #$00                                ; $C542: A9 00
  STA a:cand_row                             ; $C544: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C547: 20 CD C1
  BCS @RightRange6Terrain                 ; $C54A: B0 08 ; empty: keep scanning
  TAY                                     ; $C54C: A8
  BEQ @RightRange6Terrain                 ; $C54D: F0 05 ; ally: shoot over
  LDA #$4C                                ; $C54F: A9 4C ; flight counter, dist 5
  JMP @CommitRight                        ; $C551: 4C 7B C5
@RightRange6Terrain:
  LDA #$06                                ; $C554: A9 06 ; step delta (+6, 0)
  STA a:cand_col                             ; $C556: 8D 00 00
  LDA #$00                                ; $C559: A9 00
  STA a:cand_row                             ; $C55B: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C55E: 20 C8 CA
  TAY                                     ; $C561: A8
  BEQ @RightRange6Probe                   ; $C562: F0 03
  JMP @RightFail                          ; $C564: 4C 87 C5
@RightRange6Probe:
  LDA #$06                                ; $C567: A9 06 ; step delta (+6, 0)
  STA a:cand_col                             ; $C569: 8D 00 00
  LDA #$00                                ; $C56C: A9 00
  STA a:cand_row                             ; $C56E: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C571: 20 CD C1
  BCS @RightFail                          ; $C574: B0 11 ; empty: out of range
  TAY                                     ; $C576: A8
  BEQ @RightFail                          ; $C577: F0 0E ; ally: out of range
  LDA #$5C                                ; $C579: A9 5C ; flight counter, dist 6
@CommitRight:
  STX btl_target_col                               ; $C57B: 8E 4D 05 ; target column
  STA btl_frame_counter                               ; $C57E: 8D 48 05 ; arrow flight counter
  LDA #$03                                ; $C581: A9 03
  STA btl_acting_unit                               ; $C583: 8D 49 05 ; direction: right
  RTS                                     ; $C586: 60
@RightFail:
  LDA a:probe_ctr                             ; $C587: AD 10 00 ; probe counter
  CMP #$03                                ; $C58A: C9 03
  BNE @RightFailSwitch                    ; $C58C: D0 06
  LDA #$FF                                ; $C58E: A9 FF ; no direction
  STA btl_acting_unit                               ; $C590: 8D 49 05
  RTS                                     ; $C593: 60
@RightFailSwitch:
  CMP #$01                                ; $C594: C9 01
  BNE @RightFailFlip                      ; $C596: D0 06
  INC a:probe_ctr                             ; $C598: EE 10 00
  JMP @VerticalAxis                       ; $C59B: 4C A4 C5 ; axis exhausted: rows
@RightFailFlip:
  INC a:probe_ctr                             ; $C59E: EE 10 00
  JMP @LeftAdjTerrain                     ; $C5A1: 4C 2B C3 ; try the other side
@VerticalAxis:
  JSR B1F_RandomByte                      ; $C5A4: 20 7A E8 ; side pick
  AND #$80                                ; $C5A7: 29 80
  BNE @UpAdjTerrain                       ; $C5A9: D0 03 ; sign set: up first
  JMP @DownAdjTerrain                     ; $C5AB: 4C EC C6 ; clear: down first
@UpAdjTerrain:
  LDA #$00                                ; $C5AE: A9 00 ; step delta (0, -1)
  STA a:cand_col                             ; $C5B0: 8D 00 00
  LDA #$FF                                ; $C5B3: A9 FF
  STA a:cand_row                             ; $C5B5: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C5B8: 20 C8 CA ; range-1 terrain
  TAY                                     ; $C5BB: A8
  BEQ @UpAdjProbe                         ; $C5BC: F0 03 ; passable
  JMP @UpFail                             ; $C5BE: 4C CF C6 ; blocked terrain
@UpAdjProbe:
  LDA #$00                                ; $C5C1: A9 00 ; step delta (0, -1)
  STA a:cand_col                             ; $C5C3: 8D 00 00
  LDA #$FF                                ; $C5C6: A9 FF
  STA a:cand_row                             ; $C5C8: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C5CB: 20 CD C1 ; probe adjacent tile
  BCS @UpRange2Terrain                    ; $C5CE: B0 06 ; empty: keep scanning
  TAY                                     ; $C5D0: A8
  BEQ @UpRange2Terrain                    ; $C5D1: F0 03 ; ally: shoot over
  JMP @UpFail                             ; $C5D3: 4C CF C6 ; enemy: melee route's job
@UpRange2Terrain:
  LDA #$00                                ; $C5D6: A9 00 ; step delta (0, -2)
  STA a:cand_col                             ; $C5D8: 8D 00 00
  LDA #$FE                                ; $C5DB: A9 FE
  STA a:cand_row                             ; $C5DD: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C5E0: 20 C8 CA
  TAY                                     ; $C5E3: A8
  BEQ @UpRange2Probe                      ; $C5E4: F0 03
  JMP @UpFail                             ; $C5E6: 4C CF C6
@UpRange2Probe:
  LDA #$00                                ; $C5E9: A9 00 ; step delta (0, -2)
  STA a:cand_col                             ; $C5EB: 8D 00 00
  LDA #$FE                                ; $C5EE: A9 FE
  STA a:cand_row                             ; $C5F0: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C5F3: 20 CD C1
  BCS @UpRange3Terrain                    ; $C5F6: B0 08 ; empty: keep scanning
  TAY                                     ; $C5F8: A8
  BEQ @UpRange3Terrain                    ; $C5F9: F0 05 ; ally: shoot over
  LDA #$1C                                ; $C5FB: A9 1C ; flight counter, dist 2
  JMP @CommitUp                           ; $C5FD: 4C C3 C6
@UpRange3Terrain:
  LDA #$00                                ; $C600: A9 00 ; step delta (0, -3)
  STA a:cand_col                             ; $C602: 8D 00 00
  LDA #$FD                                ; $C605: A9 FD
  STA a:cand_row                             ; $C607: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C60A: 20 C8 CA
  TAY                                     ; $C60D: A8
  BEQ @UpRange3Probe                      ; $C60E: F0 03
  JMP @UpFail                             ; $C610: 4C CF C6
@UpRange3Probe:
  LDA #$00                                ; $C613: A9 00 ; step delta (0, -3)
  STA a:cand_col                             ; $C615: 8D 00 00
  LDA #$FD                                ; $C618: A9 FD
  STA a:cand_row                             ; $C61A: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C61D: 20 CD C1
  BCS @UpRange4Terrain                    ; $C620: B0 08 ; empty: keep scanning
  TAY                                     ; $C622: A8
  BEQ @UpRange4Terrain                    ; $C623: F0 05 ; ally: shoot over
  LDA #$2C                                ; $C625: A9 2C ; flight counter, dist 3
  JMP @CommitUp                           ; $C627: 4C C3 C6
@UpRange4Terrain:
  LDA #$00                                ; $C62A: A9 00 ; step delta (0, -4)
  STA a:cand_col                             ; $C62C: 8D 00 00
  LDA #$FC                                ; $C62F: A9 FC
  STA a:cand_row                             ; $C631: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C634: 20 C8 CA
  TAY                                     ; $C637: A8
  BEQ @UpRange4Probe                      ; $C638: F0 03
  JMP @UpFail                             ; $C63A: 4C CF C6
@UpRange4Probe:
  LDA #$00                                ; $C63D: A9 00 ; step delta (0, -4)
  STA a:cand_col                             ; $C63F: 8D 00 00
  LDA #$FC                                ; $C642: A9 FC
  STA a:cand_row                             ; $C644: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C647: 20 CD C1
  BCS @UpRangeGate                        ; $C64A: B0 08 ; empty: keep scanning
  TAY                                     ; $C64C: A8
  BEQ @UpRangeGate                        ; $C64D: F0 05 ; ally: shoot over
  LDA #$3C                                ; $C64F: A9 3C ; flight counter, dist 4
  JMP @CommitUp                           ; $C651: 4C C3 C6
@UpRangeGate:
  LDA btl_scan_col                               ; $C654: AD 45 05 ; acting slot
  CMP #$0B                                ; $C657: C9 0B
  BCC @UpGateSideA                        ; $C659: 90 0A ; side A actor
  LDA btl_status_ctr1                               ; $C65B: AD 75 05 ; side range counters
  AND #$F0                                ; $C65E: 29 F0 ; side B nibble
  BNE @UpRange5Terrain                    ; $C660: D0 0D ; long range granted
  JMP @UpFail                             ; $C662: 4C CF C6 ; no long range
@UpGateSideA:
  LDA btl_status_ctr1                               ; $C665: AD 75 05
  AND #$0F                                ; $C668: 29 0F ; side A nibble
  BNE @UpRange5Terrain                    ; $C66A: D0 03 ; long range granted
  JMP @UpFail                             ; $C66C: 4C CF C6 ; no long range
@UpRange5Terrain:
  LDA #$00                                ; $C66F: A9 00 ; step delta (0, -5)
  STA a:cand_col                             ; $C671: 8D 00 00
  LDA #$FB                                ; $C674: A9 FB
  STA a:cand_row                             ; $C676: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C679: 20 C8 CA
  TAY                                     ; $C67C: A8
  BEQ @UpRange5Probe                      ; $C67D: F0 03
  JMP @UpFail                             ; $C67F: 4C CF C6
@UpRange5Probe:
  LDA #$00                                ; $C682: A9 00 ; step delta (0, -5)
  STA a:cand_col                             ; $C684: 8D 00 00
  LDA #$FB                                ; $C687: A9 FB
  STA a:cand_row                             ; $C689: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C68C: 20 CD C1
  BCS @UpRange6Terrain                    ; $C68F: B0 08 ; empty: keep scanning
  TAY                                     ; $C691: A8
  BEQ @UpRange6Terrain                    ; $C692: F0 05 ; ally: shoot over
  LDA #$4C                                ; $C694: A9 4C ; flight counter, dist 5
  JMP @CommitUp                           ; $C696: 4C C3 C6
@UpRange6Terrain:
  LDA #$00                                ; $C699: A9 00 ; step delta (0, -6)
  STA a:cand_col                             ; $C69B: 8D 00 00
  LDA #$FA                                ; $C69E: A9 FA
  STA a:cand_row                             ; $C6A0: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C6A3: 20 C8 CA
  TAY                                     ; $C6A6: A8
  BEQ @UpRange6Probe                      ; $C6A7: F0 03
  JMP @UpFail                             ; $C6A9: 4C CF C6
@UpRange6Probe:
  LDA #$00                                ; $C6AC: A9 00 ; step delta (0, -6)
  STA a:cand_col                             ; $C6AE: 8D 00 00
  LDA #$FA                                ; $C6B1: A9 FA
  STA a:cand_row                             ; $C6B3: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C6B6: 20 CD C1
  BCS @UpFail                             ; $C6B9: B0 14 ; empty: out of range
  TAY                                     ; $C6BB: A8
  BEQ @UpFail                             ; $C6BC: F0 11 ; ally: out of range
  LDA #$5C                                ; $C6BE: A9 5C ; flight counter, dist 6
  JMP @CommitUp                           ; $C6C0: 4C C3 C6
@CommitUp:
  STX btl_target_col                               ; $C6C3: 8E 4D 05 ; target column
  STA btl_frame_counter                               ; $C6C6: 8D 48 05 ; arrow flight counter
  LDA #$00                                ; $C6C9: A9 00
  STA btl_acting_unit                               ; $C6CB: 8D 49 05 ; direction: up
  RTS                                     ; $C6CE: 60
@UpFail:
  LDA a:probe_ctr                             ; $C6CF: AD 10 00 ; probe counter
  CMP #$03                                ; $C6D2: C9 03
  BNE @UpFailSwitch                       ; $C6D4: D0 06
  LDA #$FF                                ; $C6D6: A9 FF ; no direction
  STA btl_acting_unit                               ; $C6D8: 8D 49 05
  RTS                                     ; $C6DB: 60
@UpFailSwitch:
  CMP #$01                                ; $C6DC: C9 01
  BNE @UpFailFlip                         ; $C6DE: D0 06
  INC a:probe_ctr                             ; $C6E0: EE 10 00
  JMP @HorizontalAxis                     ; $C6E3: 4C 21 C3 ; axis exhausted: columns
@UpFailFlip:
  INC a:probe_ctr                             ; $C6E6: EE 10 00
  JMP @DownAdjTerrain                     ; $C6E9: 4C EC C6 ; try the other side
@DownAdjTerrain:
  LDA #$00                                ; $C6EC: A9 00 ; step delta (0, +1)
  STA a:cand_col                             ; $C6EE: 8D 00 00
  LDA #$01                                ; $C6F1: A9 01
  STA a:cand_row                             ; $C6F3: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C6F6: 20 C8 CA ; range-1 terrain
  TAY                                     ; $C6F9: A8
  BEQ @DownAdjProbe                       ; $C6FA: F0 03 ; passable
  JMP @DownFail                           ; $C6FC: 4C 0A C8 ; blocked terrain
@DownAdjProbe:
  LDA #$00                                ; $C6FF: A9 00 ; step delta (0, +1)
  STA a:cand_col                             ; $C701: 8D 00 00
  LDA #$01                                ; $C704: A9 01
  STA a:cand_row                             ; $C706: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C709: 20 CD C1 ; probe adjacent tile
  BCS @DownRange2Terrain                  ; $C70C: B0 06 ; empty: keep scanning
  TAY                                     ; $C70E: A8
  BEQ @DownRange2Terrain                  ; $C70F: F0 03 ; ally: shoot over
  JMP @DownFail                           ; $C711: 4C 0A C8 ; enemy: melee route's job
@DownRange2Terrain:
  LDA #$00                                ; $C714: A9 00 ; step delta (0, +2)
  STA a:cand_col                             ; $C716: 8D 00 00
  LDA #$02                                ; $C719: A9 02
  STA a:cand_row                             ; $C71B: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C71E: 20 C8 CA
  TAY                                     ; $C721: A8
  BEQ @DownRange2Probe                    ; $C722: F0 03
  JMP @DownFail                           ; $C724: 4C 0A C8
@DownRange2Probe:
  LDA #$00                                ; $C727: A9 00 ; step delta (0, +2)
  STA a:cand_col                             ; $C729: 8D 00 00
  LDA #$02                                ; $C72C: A9 02
  STA a:cand_row                             ; $C72E: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C731: 20 CD C1
  BCS @DownRange3Terrain                  ; $C734: B0 08 ; empty: keep scanning
  TAY                                     ; $C736: A8
  BEQ @DownRange3Terrain                  ; $C737: F0 05 ; ally: shoot over
  LDA #$1C                                ; $C739: A9 1C ; flight counter, dist 2
  JMP @CommitDown                         ; $C73B: 4C FE C7
@DownRange3Terrain:
  LDA #$00                                ; $C73E: A9 00 ; step delta (0, +3)
  STA a:cand_col                             ; $C740: 8D 00 00
  LDA #$03                                ; $C743: A9 03
  STA a:cand_row                             ; $C745: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C748: 20 C8 CA
  TAY                                     ; $C74B: A8
  BEQ @DownRange3Probe                    ; $C74C: F0 03
  JMP @DownFail                           ; $C74E: 4C 0A C8
@DownRange3Probe:
  LDA #$00                                ; $C751: A9 00 ; step delta (0, +3)
  STA a:cand_col                             ; $C753: 8D 00 00
  LDA #$03                                ; $C756: A9 03
  STA a:cand_row                             ; $C758: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C75B: 20 CD C1
  BCS @DownRange4Terrain                  ; $C75E: B0 08 ; empty: keep scanning
  TAY                                     ; $C760: A8
  BEQ @DownRange4Terrain                  ; $C761: F0 05 ; ally: shoot over
  LDA #$2C                                ; $C763: A9 2C ; flight counter, dist 3
  JMP @CommitDown                         ; $C765: 4C FE C7
@DownRange4Terrain:
  LDA #$00                                ; $C768: A9 00 ; step delta (0, +4)
  STA a:cand_col                             ; $C76A: 8D 00 00
  LDA #$04                                ; $C76D: A9 04
  STA a:cand_row                             ; $C76F: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C772: 20 C8 CA
  TAY                                     ; $C775: A8
  BEQ @DownRange4Probe                    ; $C776: F0 03
  JMP @DownFail                           ; $C778: 4C 0A C8
@DownRange4Probe:
  LDA #$00                                ; $C77B: A9 00 ; step delta (0, +4)
  STA a:cand_col                             ; $C77D: 8D 00 00
  LDA #$04                                ; $C780: A9 04
  STA a:cand_row                             ; $C782: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C785: 20 CD C1
  BCS @DownRangeGate                      ; $C788: B0 08 ; empty: keep scanning
  TAY                                     ; $C78A: A8
  BEQ @DownRangeGate                      ; $C78B: F0 05 ; ally: shoot over
  LDA #$3C                                ; $C78D: A9 3C ; flight counter, dist 4
  JMP @CommitDown                         ; $C78F: 4C FE C7
@DownRangeGate:
  LDA btl_scan_col                               ; $C792: AD 45 05 ; acting slot
  CMP #$0B                                ; $C795: C9 0B
  BCC @DownGateSideA                      ; $C797: 90 0A ; side A actor
  LDA btl_status_ctr1                               ; $C799: AD 75 05 ; side range counters
  AND #$F0                                ; $C79C: 29 F0 ; side B nibble
  BNE @DownRange5Terrain                  ; $C79E: D0 0D ; long range granted
  JMP @DownFail                           ; $C7A0: 4C 0A C8 ; no long range
@DownGateSideA:
  LDA btl_status_ctr1                               ; $C7A3: AD 75 05
  AND #$0F                                ; $C7A6: 29 0F ; side A nibble
  BNE @DownRange5Terrain                  ; $C7A8: D0 03 ; long range granted
  JMP @DownFail                           ; $C7AA: 4C 0A C8 ; no long range
@DownRange5Terrain:
  LDA #$00                                ; $C7AD: A9 00 ; step delta (0, +5)
  STA a:cand_col                             ; $C7AF: 8D 00 00
  LDA #$05                                ; $C7B2: A9 05
  STA a:cand_row                             ; $C7B4: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C7B7: 20 C8 CA
  TAY                                     ; $C7BA: A8
  BEQ @DownRange5Probe                    ; $C7BB: F0 03
  JMP @DownFail                           ; $C7BD: 4C 0A C8
@DownRange5Probe:
  LDA #$00                                ; $C7C0: A9 00 ; step delta (0, +5)
  STA a:cand_col                             ; $C7C2: 8D 00 00
  LDA #$05                                ; $C7C5: A9 05
  STA a:cand_row                             ; $C7C7: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C7CA: 20 CD C1
  BCS @DownRange6Terrain                  ; $C7CD: B0 08 ; empty: keep scanning
  TAY                                     ; $C7CF: A8
  BEQ @DownRange6Terrain                  ; $C7D0: F0 05 ; ally: shoot over
  LDA #$4C                                ; $C7D2: A9 4C ; flight counter, dist 5
  JMP @CommitDown                         ; $C7D4: 4C FE C7
@DownRange6Terrain:
  LDA #$00                                ; $C7D7: A9 00 ; step delta (0, +6)
  STA a:cand_col                             ; $C7D9: 8D 00 00
  LDA #$06                                ; $C7DC: A9 06
  STA a:cand_row                             ; $C7DE: 8D 01 00
  JSR Phase2ArrowPathTileCheck            ; $C7E1: 20 C8 CA
  TAY                                     ; $C7E4: A8
  BEQ @DownRange6Probe                    ; $C7E5: F0 03
  JMP @DownFail                           ; $C7E7: 4C 0A C8
@DownRange6Probe:
  LDA #$00                                ; $C7EA: A9 00 ; step delta (0, +6)
  STA a:cand_col                             ; $C7EC: 8D 00 00
  LDA #$06                                ; $C7EF: A9 06
  STA a:cand_row                             ; $C7F1: 8D 01 00
  JSR Phase2StepTileProbe                 ; $C7F4: 20 CD C1
  BCS @DownFail                           ; $C7F7: B0 11 ; empty: out of range
  TAY                                     ; $C7F9: A8
  BEQ @DownFail                           ; $C7FA: F0 0E ; ally: out of range
  LDA #$5C                                ; $C7FC: A9 5C ; flight counter, dist 6
@CommitDown:
  STX btl_target_col                               ; $C7FE: 8E 4D 05 ; target column
  STA btl_frame_counter                               ; $C801: 8D 48 05 ; arrow flight counter
  LDA #$01                                ; $C804: A9 01
  STA btl_acting_unit                               ; $C806: 8D 49 05 ; direction: down
  RTS                                     ; $C809: 60
@DownFail:
  LDA a:probe_ctr                             ; $C80A: AD 10 00 ; probe counter
  CMP #$03                                ; $C80D: C9 03
  BNE @DownFailSwitch                     ; $C80F: D0 06
  LDA #$FF                                ; $C811: A9 FF ; no direction
  STA btl_acting_unit                               ; $C813: 8D 49 05
  RTS                                     ; $C816: 60
@DownFailSwitch:
  CMP #$01                                ; $C817: C9 01
  BNE @DownFailFlip                       ; $C819: D0 06
  INC a:probe_ctr                             ; $C81B: EE 10 00
  JMP @HorizontalAxis                     ; $C81E: 4C 21 C3 ; axis exhausted: columns
@DownFailFlip:
  INC a:probe_ctr                             ; $C821: EE 10 00
  JMP @UpAdjTerrain                       ; $C824: 4C AE C5 ; try the other side
.endproc
;-------------------------------------------------------------------------------
; $C827: BattleSlotSideCompare
; Side-relation compare for roster slots: A = actor slot, X = other slot.
; Slots 0-$0A belong to side A, $0B-$15 to side B. Returns A = 1 when the
; two slots sit on opposing sides, A = 0 when on the same side.
;-------------------------------------------------------------------------------
.proc BattleSlotSideCompare
  CPX #$0B                                ; $C827: E0 0B ; other slot side
  BCS @OtherSideB                         ; $C829: B0 07
  CMP #$0B                                ; $C82B: C9 0B ; actor slot side
  BCS @Opposing                           ; $C82D: B0 07 ; A side, B actor
@SameSide:
  LDA #$00                                ; $C82F: A9 00 ; same side
  RTS                                     ; $C831: 60
@OtherSideB:
  CMP #$0B                                ; $C832: C9 0B ; actor slot side
  BCS @SameSide                           ; $C834: B0 F9 ; both side B
@Opposing:
  LDA #$01                                ; $C836: A9 01 ; opposing sides
  RTS                                     ; $C838: 60
.endproc
;===============================================================================
; $C839: Phase3CommandMarkerRender
; Draws the phase-3 command-menu value marker: a 4x2-tile command icon for
; action slot value $0001 (0-4) at the PPU position of menu step $0000
; (0-3). Builds a two-segment, FF-terminated VRAM script in the $0380
; buffer: segment 1 = icon top row (4 tiles + blank $01) at
; Phase3CommandMarkerAddrTable[2*step] (nametable page $22/$23, panel row
; 20+2*step, column 20), segment 2 = icon bottom row at
; Phase3CommandMarkerAddrTable[2*step+1] ORA #$04 (page + $0400, row
; 21+2*step). Raises $007E bit 2 so the NMI sub-dispatch banked-jumps to
; B1D_1E_VRAMBufferWrite, which streams the script to the PPU; sets script
; param $00BB <- $77. Called by Phase3CommandMarkerUpdate.
;===============================================================================
.proc Phase3CommandMarkerRender
; zero-page work cells (proc-local):
menu_step      = $0000  ; menu step value ($0548 copy)
slot_value     = $0001  ; action slot value (*5 for table)
  LDA a:menu_step                             ; $C839: AD 00 00 ; menu step
  ASL                                     ; $C83C: 0A ; step * 4
  ASL                                     ; $C83D: 0A ; (word pair index)
  TAY                                     ; $C83E: A8
  LDA Phase3CommandMarkerAddrTable+1,Y    ; $C83F: B9 BC C8 ; seg 1 addr hi
  STA vram_script_buf+$01                               ; $C842: 8D 81 03
  LDA Phase3CommandMarkerAddrTable,Y      ; $C845: B9 BB C8 ; seg 1 addr lo
  STA vram_script_buf+$02                               ; $C848: 8D 82 03
  LDA Phase3CommandMarkerAddrTable+3,Y    ; $C84B: B9 BE C8 ; seg 2 addr hi
  STA vram_script_buf+$09                               ; $C84E: 8D 89 03
  LDA Phase3CommandMarkerAddrTable+2,Y    ; $C851: B9 BD C8 ; seg 2 addr lo
  STA vram_script_buf+$0A                               ; $C854: 8D 8A 03
  LDA a:slot_value                             ; $C857: AD 01 00 ; action slot value
  ASL                                     ; $C85A: 0A ; value * 10
  ASL                                     ; $C85B: 0A ; (icon row index)
  CLC                                     ; $C85C: 18
  ADC a:slot_value                             ; $C85D: 6D 01 00 ; * 5
  ASL                                     ; $C860: 0A ; * 10
  TAY                                     ; $C861: A8
  LDA Phase3CommandMarkerTiles,Y          ; $C862: B9 CB C8 ; icon top tile 0
  STA vram_script_buf+$03                               ; $C865: 8D 83 03
  LDA Phase3CommandMarkerTiles+1,Y        ; $C868: B9 CC C8 ; top tile 1
  STA vram_script_buf+$04                               ; $C86B: 8D 84 03
  LDA Phase3CommandMarkerTiles+2,Y        ; $C86E: B9 CD C8 ; top tile 2
  STA vram_script_buf+$05                               ; $C871: 8D 85 03
  LDA Phase3CommandMarkerTiles+3,Y        ; $C874: B9 CE C8 ; top tile 3
  STA vram_script_buf+$06                               ; $C877: 8D 86 03
  LDA Phase3CommandMarkerTiles+4,Y        ; $C87A: B9 CF C8 ; blank tail
  STA vram_script_buf+$07                               ; $C87D: 8D 87 03
  LDA Phase3CommandMarkerTiles+5,Y        ; $C880: B9 D0 C8 ; icon bottom tile 0
  STA vram_script_buf+$0B                               ; $C883: 8D 8B 03
  LDA Phase3CommandMarkerTiles+6,Y        ; $C886: B9 D1 C8 ; bottom tile 1
  STA vram_script_buf+$0C                               ; $C889: 8D 8C 03
  LDA Phase3CommandMarkerTiles+7,Y        ; $C88C: B9 D2 C8 ; bottom tile 2
  STA vram_script_buf+$0D                               ; $C88F: 8D 8D 03
  LDA Phase3CommandMarkerTiles+8,Y        ; $C892: B9 D3 C8 ; bottom tile 3
  STA vram_script_buf+$0E                               ; $C895: 8D 8E 03
  LDA Phase3CommandMarkerTiles+9,Y        ; $C898: B9 D4 C8 ; blank tail
  STA vram_script_buf+$0F                               ; $C89B: 8D 8F 03
  LDA #$05                                ; $C89E: A9 05
  STA vram_script_buf                               ; $C8A0: 8D 80 03 ; seg 1 length: 5 tiles
  LDA #$05                                ; $C8A3: A9 05
  STA vram_script_buf+$08                               ; $C8A5: 8D 88 03 ; seg 2 length: 5 tiles
  LDA #$FF                                ; $C8A8: A9 FF
  STA vram_script_buf+$10                               ; $C8AA: 8D 90 03 ; script terminator
  LDA a:btl_anim_flags                             ; $C8AD: AD 7E 00 ; NMI sub-dispatch ctrl
  ORA #$04                                ; $C8B0: 09 04 ; VRAM script pending bit
  STA a:btl_anim_flags                             ; $C8B2: 8D 7E 00
  LDA #$77                                ; $C8B5: A9 77
  STA a:zp_panel_param_a                             ; $C8B7: 8D BB 00 ; script param
  RTS                                     ; $C8BA: 60
.endproc
;===============================================================================
; $C8BB: Phase3CommandMarkerAddrTable
; PPU addresses of the command-menu value marker, two words per menu step:
; word 2*s = segment 1 (icon top row, nametable page $22/$23), word 2*s+1
; = segment 2 base (icon bottom row; the render ORs $04 into the high
; byte). Row 20+2*s, column 20 -> step 0 $2294/$22B4, step 1 $22D4/$22F4,
; step 2 $2314/$2334, step 3 $2354/$2374.
;===============================================================================
Phase3CommandMarkerAddrTable:
  .word $2294                             ; $C8BB: 94 22 ; step 0, seg 1 (top row)
  .word $22B4                             ; $C8BD: B4 22 ; step 0, seg 2 (bottom row)
  .word $22D4                             ; $C8BF: D4 22 ; step 1, seg 1
  .word $22F4                             ; $C8C1: F4 22 ; step 1, seg 2
  .word $2314                             ; $C8C3: 14 23 ; step 2, seg 1
  .word $2334                             ; $C8C5: 34 23 ; step 2, seg 2
  .word $2354                             ; $C8C7: 54 23 ; step 3, seg 1
  .word $2374                             ; $C8C9: 74 23 ; step 3, seg 2
;===============================================================================
; $C8CB: Phase3CommandMarkerTiles
; Command icon tiles per action slot value (5 rows of 10 bytes, row index =
; slot value): bytes 0-3 = icon top row, byte 4 = blank tile $01, bytes 5-8
; = icon bottom row, byte 9 = blank tile $01. Each icon is two 2x2-tile
; blocks side by side; tile ids are not monotonic across values.
;===============================================================================
Phase3CommandMarkerTiles:
  .byte $40,$41,$42,$43,$01,$50,$51,$52,$53,$01 ; $C8CB: 40 41 42 43 01 50 51 52 53 01 ; value 0
  .byte $60,$61,$62,$63,$01,$70,$71,$72,$73,$01 ; $C8D5: 60 61 62 63 01 70 71 72 73 01 ; value 1
  .byte $64,$65,$66,$67,$01,$74,$75,$68,$69,$01 ; $C8DF: 64 65 66 67 01 74 75 68 69 01 ; value 2
  .byte $48,$49,$4A,$4B,$01,$58,$59,$5A,$5B,$01 ; $C8E9: 48 49 4A 4B 01 58 59 5A 5B 01 ; value 3
  .byte $44,$45,$46,$47,$01,$54,$55,$56,$57,$01 ; $C8F3: 44 45 46 47 01 54 55 56 57 01 ; value 4
;===============================================================================
; $C8FD: FormationConfirmPromptDraw
; Draws the blinking "press A" confirmation prompt sprite (tile $04) at OAM
; base Y=$D8/X=$A0 via B1F_SpriteOamWriterSimple, gated by frame counter
; $005E bit 4 (visible 16 frames, hidden 16 frames). On the hidden half the
; branch lands on the RTS at $C920 for an immediate return. The sprite record
; submitted to B1F_SpriteOamWriterSimple is FormationConfirmPromptSprite at
; $C921. Duplicate of BattleInputPromptDraw ($CCA8) with different Y/X bases.
;===============================================================================
.proc FormationConfirmPromptDraw
; zero-page work cells (proc-local):
spr_x          = $000A  ; prompt sprite X base
spr_y          = $000C  ; prompt sprite Y base
spr_ptr_lo     = $0000  ; sprite record ptr lo
spr_ptr_hi     = $0001  ; sprite record ptr hi
attr_eor       = $0002  ; attribute EOR mask
  LDA a:frame_tick                             ; $C8FD: AD 5E 00 ; frame counter
  AND #$10                                ; $C900: 29 10 ; blink gate
  BNE @Skip                               ; $C902: D0 1C ; hidden half: RTS
  LDA #$D8                                ; $C904: A9 D8 ; OAM Y base
  STA a:spr_x                             ; $C906: 8D 0A 00
  LDA #$A0                                ; $C909: A9 A0 ; OAM X base
  STA a:spr_y                             ; $C90B: 8D 0C 00
  LDA #$21                                ; $C90E: A9 21 ; record ptr lo ($C921)
  STA a:spr_ptr_lo                             ; $C910: 8D 00 00 ; ptr lo -> FormationConfirmPromptSprite
  LDA #$C9                                ; $C913: A9 C9 ; record ptr hi
  STA a:spr_ptr_hi                             ; $C915: 8D 01 00
  LDA #$00                                ; $C918: A9 00
  STA a:attr_eor                             ; $C91A: 8D 02 00 ; attr EOR
  JMP B1F_SpriteOamWriterSimple           ; $C91D: 4C AD F1
@Skip:
  RTS                                     ; $C920: hidden-half immediate return
;===============================================================================
; $C921-$C925: FormationConfirmPromptSprite
; Sprite record consumed by B1F_SpriteOamWriterSimple (4-byte entries
; [y_off, tile, attr, x_off], terminated by $80): single tile $04 at offset
; (0,0) relative to the OAM Y/X bases. Identical to BattleInputPromptSprite
; ($CCD9).
;===============================================================================
FormationConfirmPromptSprite:
  .byte $00,$04                           ; $C921: y_off 0, tile $04
  .byte $00,$00,$80                       ; $C923: attr 0, x_off 0, terminator
.endproc
;===============================================================================
; $C926: BattleSideCombatStatsInit
; Pre-battle combat-parameter setup for both sides, from the commanders'
; officer records (B1F_GetOfficerRecordAddr on $0560/$0561). Runs once, from
; BattleOverlayIntroSkipCheck ($A0CF) after an intro skip; sole initializer
; of these battle-RAM outputs (later writers are mid-battle reload latches):
;   - Attack value -> $056A/$056B (mirrored to $04C1/$04C2): record[1]
;     scaled by a 45-70% tier plus a 1..9 roll (see BattleAttackValueRoll);
;     consumed as the base damage by Phase2AttackDamageCompute;
;   - Edge-column attack bonus -> $0570/$0571: BattleEdgeBonusLowTable
;     [record[$0A] & $1F], added at cursor column 0 (side A) / $0B (side B);
;   - Edge-column defense -> $056E/$056F: BattleEdgeDefenseHighTable
;     [record[$0A] >> 5], subtracted from half the damage at those columns;
;   - Tactic point budget -> $0572/$0573: record[2] * 13 / 100, spent by the
;     phase-8 point-spend panel (indexed by acting side $0549).
; BattleAttackValueRoll clobbers zp $00/$01, so the record pointer is
; re-fetched before each record[2] read below.
;===============================================================================
.proc BattleSideCombatStatsInit
; zero-page work cells (proc-local):
stat_work      = $0000  ; record byte work -> mul value
dividend_lo    = $0001  ; MathDiv16 dividend lo
dividend_hi    = $0002  ; dividend hi
divisor_lo     = $0003  ; divisor lo
divisor_hi     = $0004  ; divisor hi (0)
tier_percent   = $0003  ; tier percent (Y param)
product_lo     = $0006  ; MathMul24x8 product byte 0
product_hi     = $0007  ; product byte 1
  LDA btl_strip_buf_a                               ; $C926: AD 60 05 ; side A commander id
  JSR B1F_GetOfficerRecordAddr            ; $C929: 20 D7 F2 ; record ptr -> ($00)
  JSR BattleAttackValueRoll               ; $C92C: 20 91 C9
  STA btl_attack_a                               ; $C92F: 8D 6A 05
  STA btl_attack_mirror_a                               ; $C932: 8D C1 04 ; attack value mirror
  STY btl_edge_bonus_a                               ; $C935: 8C 70 05
  STX btl_defense_a                               ; $C938: 8E 6E 05
  LDA btl_strip_buf_a                               ; $C93B: AD 60 05 ; re-fetch side A record
  JSR B1F_GetOfficerRecordAddr            ; $C93E: 20 D7 F2 ; (roll clobbered $00/$01)
  LDY #$02                                ; $C941: A0 02
  LDA (stat_work),Y                             ; $C943: B1 00 ; record [2]
  STA a:stat_work                             ; $C945: 8D 00 00
  LDA #$00                                ; $C948: A9 00
  STA a:dividend_lo                             ; $C94A: 8D 01 00
  LDA #$0D                                ; $C94D: A9 0D
  STA a:divisor_lo                             ; $C94F: 8D 03 00
  JSR B1F_MathMulDiv100                   ; $C952: 20 CA EB ; * 13, / 100
  LDA a:stat_work                             ; $C955: AD 00 00
  STA btl_point_budget_a                               ; $C958: 8D 72 05 ; side A point budget
  LDA btl_strip_buf_b                               ; $C95B: AD 61 05 ; side B commander id
  JSR B1F_GetOfficerRecordAddr            ; $C95E: 20 D7 F2
  JSR BattleAttackValueRoll               ; $C961: 20 91 C9
  STA btl_attack_b                               ; $C964: 8D 6B 05 ; side B attack value
  STA btl_attack_mirror_b                               ; $C967: 8D C2 04 ; attack value mirror
  STY btl_edge_bonus_b                               ; $C96A: 8C 71 05
  STX btl_defense_b                               ; $C96D: 8E 6F 05
  LDA btl_strip_buf_b                               ; $C970: AD 61 05
  JSR B1F_GetOfficerRecordAddr            ; $C973: 20 D7 F2
  LDY #$02                                ; $C976: A0 02
  LDA (stat_work),Y                             ; $C978: B1 00
  STA a:stat_work                             ; $C97A: 8D 00 00
  LDA #$00                                ; $C97D: A9 00
  STA a:dividend_lo                             ; $C97F: 8D 01 00
  LDA #$0D                                ; $C982: A9 0D
  STA a:divisor_lo                             ; $C984: 8D 03 00
  JSR B1F_MathMulDiv100                   ; $C987: 20 CA EB
  LDA a:stat_work                             ; $C98A: AD 00 00
  STA btl_point_budget_b                               ; $C98D: 8D 73 05
  RTS                                     ; $C990: 60
;-------------------------------------------------------------------------------
; $C991: BattleAttackValueRoll - side attack roll from the officer record at
; ($00). Returns A = record[1] * tier% / 100 + 9 - rand(0..8), floored at 1,
; with tier% = 45/50/55/60/65/70 for record[1] < $32/$41/$50/$57/$5C/else;
; Y = BattleEdgeBonusLowTable[record[$0A] & $1F] (edge-column attack bonus);
; X = BattleEdgeDefenseHighTable[record[$0A] >> 5] (edge-column defense).
; Clobbers zp $00-$07; record[$0A] rides the stack through the math.
;-------------------------------------------------------------------------------
BattleAttackValueRoll:
  LDY #$0A                                ; $C991: A0 0A
  LDA (stat_work),Y                             ; $C993: B1 00 ; record[$0A]
  PHA                                     ; $C995: 48
  LDY #$01                                ; $C996: A0 01
  LDA (stat_work),Y                             ; $C998: B1 00 ; record[1] (attack stat)
  LDY #$2D                                ; $C99A: A0 2D ; 45 percent
  CMP #$32                                ; $C99C: C9 32 ; record[1] < $32 (50)
  BCC @TierPctSelected                                       ; $C99E: 90 20
  LDY #$2D                                ; $C9A0: A0 2D ; 45 percent
  CMP #$41                                ; $C9A2: C9 41 ; record[1] < $41 (65)
  BCC @TierPctSelected                                       ; $C9A4: 90 1A
  LDY #$32                                ; $C9A6: A0 32 ; 50 percent
  CMP #$50                                ; $C9A8: C9 50 ; record[1] < $50 (80)
  BCC @TierPctSelected                                       ; $C9AA: 90 14
  LDY #$37                                ; $C9AC: A0 37 ; 55 percent
  CMP #$57                                ; $C9AE: C9 57 ; record[1] < $57 (87)
  BCC @TierPctSelected                                       ; $C9B0: 90 0E
  LDY #$3C                                ; $C9B2: A0 3C ; 60 percent
  CMP #$5C                                ; $C9B4: C9 5C ; record[1] < $5C (92)
  BCC @TierPctSelected                                       ; $C9B6: 90 08
  LDY #$41                                ; $C9B8: A0 41 ; 65 percent
  CMP #$61                                ; $C9BA: C9 61 ; else
  BCC @TierPctSelected                                       ; $C9BC: 90 02
  LDY #$46                                ; $C9BE: A0 46 ; 70 percent
@TierPctSelected:
  STY a:tier_percent                             ; $C9C0: 8C 03 00 ; tier percent
  STA a:stat_work                             ; $C9C3: 8D 00 00
  LDA #$00                                ; $C9C6: A9 00
  STA a:dividend_lo                             ; $C9C8: 8D 01 00
  STA a:dividend_hi                             ; $C9CB: 8D 02 00
  JSR B1F_MathMul24x8                     ; $C9CE: 20 E9 EB ; record[1] * tier
  LDA a:product_lo                             ; $C9D1: AD 06 00
  STA a:dividend_lo                             ; $C9D4: 8D 01 00
  LDA a:product_hi                             ; $C9D7: AD 07 00
  STA a:dividend_hi                             ; $C9DA: 8D 02 00
  LDA #$64                                ; $C9DD: A9 64 ; divisor 100
  STA a:divisor_lo                             ; $C9DF: 8D 03 00
  LDA #$00                                ; $C9E2: A9 00
  STA a:divisor_hi                             ; $C9E4: 8D 04 00
  JSR B1F_MathDiv16                       ; $C9E7: 20 7C EA ; / 100
@RollLoop:
  JSR B1F_RandomByte                      ; $C9EA: 20 7A E8
  AND #$0F                                ; $C9ED: 29 0F
  CMP #$09                                ; $C9EF: C9 09 ; retry while >= 9 (roll 0..8)
  BCS @RollLoop                                              ; $C9F1: B0 F7
  STA a:dividend_hi                             ; $C9F3: 8D 02 00
  LDA a:dividend_lo                             ; $C9F6: AD 01 00
  CLC                                     ; $C9F9: 18
  ADC #$09                                ; $C9FA: 69 09 ; + 9
  SEC                                     ; $C9FC: 38
  SBC a:dividend_hi                             ; $C9FD: ED 02 00 ; - roll
  BCS @RollStore                                             ; $CA00: B0 02
  LDA #$01                                ; $CA02: A9 01 ; floor at 1
@RollStore:
  STA a:dividend_lo                             ; $CA04: 8D 01 00 ; attack value
  PLA                                     ; $CA07: 68
  PHA                                     ; $CA08: 48
  AND #$1F                                ; $CA09: 29 1F ; record[$0A] low 5 bits
  TAY                                     ; $CA0B: A8
  LDA BattleEdgeBonusLowTable,Y           ; $CA0C: B9 1F CA
  TAY                                     ; $CA0F: A8
  PLA                                     ; $CA10: 68
  LSR                                     ; $CA11: 4A
  LSR                                     ; $CA12: 4A
  LSR                                     ; $CA13: 4A
  LSR                                     ; $CA14: 4A
  LSR                                     ; $CA15: 4A
  TAX                                     ; $CA16: AA
  LDA BattleEdgeDefenseHighTable,X        ; $CA17: BD 37 CA
  TAX                                     ; $CA1A: AA
  LDA a:dividend_lo                             ; $CA1B: AD 01 00
  RTS                                     ; $CA1E: 60 ; A=attack, Y=bonus, X=defense
; --- Data Region ---
; $CA1F: Edge-column attack bonus, indexed by record[$0A] & $1F. Only 24
; entries before the defense table below; indices $18-$1F alias those bytes
; (layout kept as disassembled; verified against ROM).
BattleEdgeBonusLowTable:
  .byte $03,$04,$07,$09,$0D,$0F,$10,$11,$04,$05,$08,$0A,$0C,$0B,$11,$13; $CA1F: 03 04 07 09 0D 0F 10 11 04 05 08 0A 0C 0B 11 13
  .byte $05,$06,$07,$0A,$0B,$10,$12,$14   ; $CA2F: 05 06 07 0A 0B 10 12 14
; $CA37: Edge-column defense, indexed by record[$0A] >> 5 (0-7).
BattleEdgeDefenseHighTable:
  .byte $02,$03,$05,$07,$08,$0A,$0B,$0C   ; $CA37: 02 03 05 07 08 0A 0B 0C
.endproc
;===============================================================================
; $CA3F: BattleOverlayTotalRefresh
; Commits both sides' current troop state into the commander roster records
; (B1F_GetOfficerRecordAddr on $0560/$0561): record[0] <- side troop count
; ($05AC side A / $05B7 side B), record[8/9] <- 16-bit sum of the side's
; 10 per-unit HP values ($05AD-$05B6 side A / $05B8-$05C1 side B, $FF empty
; slots skipped; record[9] keeps its low 2 bits). Used by the phase-4 result
; handlers and phase 5 sub 0 (Phase5SideEventRosterCommit).
;===============================================================================
.proc BattleOverlayTotalRefresh
; zero-page work cells (proc-local):
strip_ptr      = $0000  ; strip buffer ptr (indirect base)
addr_lo        = $0002  ; VRAM address work lo
addr_hi        = $0003  ; VRAM address work hi
  LDA btl_strip_buf_a                               ; $CA3F: AD 60 05 ; side A commander id
  JSR B1F_GetOfficerRecordAddr            ; $CA42: 20 D7 F2
  LDA btl_troops_a                               ; $CA45: AD AC 05
  LDY #$00                                ; $CA48: A0 00
  STA (strip_ptr),Y                             ; $CA4A: 91 00
  LDY #$00                                ; $CA4C: A0 00
  STY a:addr_lo                             ; $CA4E: 8C 02 00
  STY a:addr_hi                             ; $CA51: 8C 03 00
@SideASumLoop:
  LDA $05AD,Y                             ; $CA54: B9 AD 05
  CMP #$FF                                ; $CA57: C9 FF
  BEQ @SideASlotDone                                               ; $CA59: F0 12
  LDA $05AD,Y                             ; $CA5B: B9 AD 05
  CLC                                     ; $CA5E: 18
  ADC a:addr_lo                             ; $CA5F: 6D 02 00
  STA a:addr_lo                             ; $CA62: 8D 02 00
  LDA a:addr_hi                             ; $CA65: AD 03 00
  ADC #$00                                ; $CA68: 69 00
  STA a:addr_hi                             ; $CA6A: 8D 03 00
@SideASlotDone:
  INY                                     ; $CA6D: C8
  CPY #$0A                                ; $CA6E: C0 0A
  BCC @SideASumLoop                                               ; $CA70: 90 E2
  LDY #$08                                ; $CA72: A0 08
  LDA a:addr_lo                             ; $CA74: AD 02 00
  STA (strip_ptr),Y                             ; $CA77: 91 00
  INY                                     ; $CA79: C8
  LDA (strip_ptr),Y                             ; $CA7A: B1 00
  AND #$FC                                ; $CA7C: 29 FC
  ORA a:addr_hi                             ; $CA7E: 0D 03 00
  STA (strip_ptr),Y                             ; $CA81: 91 00
  LDA btl_strip_buf_b                               ; $CA83: AD 61 05
  JSR B1F_GetOfficerRecordAddr            ; $CA86: 20 D7 F2
  LDA btl_troops_b                               ; $CA89: AD B7 05
  LDY #$00                                ; $CA8C: A0 00
  STA (strip_ptr),Y                             ; $CA8E: 91 00
  LDY #$00                                ; $CA90: A0 00
  STY a:addr_lo                             ; $CA92: 8C 02 00
  STY a:addr_hi                             ; $CA95: 8C 03 00
@SideBSumLoop:
  LDA $05B8,Y                             ; $CA98: B9 B8 05
  CMP #$FF                                ; $CA9B: C9 FF
  BEQ @SideBSlotDone                                               ; $CA9D: F0 12
  LDA $05B8,Y                             ; $CA9F: B9 B8 05
  CLC                                     ; $CAA2: 18
  ADC a:addr_lo                             ; $CAA3: 6D 02 00
  STA a:addr_lo                             ; $CAA6: 8D 02 00
  LDA a:addr_hi                             ; $CAA9: AD 03 00
  ADC #$00                                ; $CAAC: 69 00
  STA a:addr_hi                             ; $CAAE: 8D 03 00
@SideBSlotDone:
  INY                                     ; $CAB1: C8
  CPY #$0A                                ; $CAB2: C0 0A
  BCC @SideBSumLoop                                               ; $CAB4: 90 E2
  LDY #$08                                ; $CAB6: A0 08
  LDA a:addr_lo                             ; $CAB8: AD 02 00
  STA (strip_ptr),Y                             ; $CABB: 91 00
  INY                                     ; $CABD: C8
  LDA (strip_ptr),Y                             ; $CABE: B1 00
  AND #$FC                                ; $CAC0: 29 FC
  ORA a:addr_hi                             ; $CAC2: 0D 03 00
  STA (strip_ptr),Y                             ; $CAC5: 91 00
  RTS                                     ; $CAC7: 60
.endproc
;-------------------------------------------------------------------------------
; $CAC8: Phase2ArrowPathTileCheck
; Line-of-fire tile check used by Phase2AttackRouteResolve for every tile
; along a scan direction. Applies the step delta ($0000 = column,
; $0001 = row, signed) to the acting slot $0545's position ($0580/$0596)
; and rejects out-of-bounds tiles (A = 1; negative wraps land >= $10),
; then asks BattleTerrainPassabilityCheck whether the tile's terrain
; blocks the shot. Terrain classes 4 and 5 are forced passable here
; (arrows fly over them), so the scan is aborted (A = terrain class,
; non-zero) by class 1 always and by classes 2/3 when the acting troop
; type cannot traverse them. A = 0: the arrow can cross this tile.
;-------------------------------------------------------------------------------
.proc Phase2ArrowPathTileCheck
; zero-page work cells (proc-local):
cand_col       = $0000  ; candidate column (col + delta)
cand_row       = $0001  ; candidate row (row + delta)
  LDY btl_scan_col                               ; $CAC8: AC 45 05 ; acting slot
  LDA btl_unit_col_a,Y                             ; $CACB: B9 80 05 ; actor column
  CLC                                     ; $CACE: 18
  ADC a:cand_col                             ; $CACF: 6D 00 00 ; + column delta
  STA a:cand_col                             ; $CAD2: 8D 00 00 ; candidate column
  CMP #$10                                ; $CAD5: C9 10
  BCS @Blocked                            ; $CAD7: B0 0E ; col out of bounds
  LDA btl_unit_row_a,Y                             ; $CAD9: B9 96 05 ; actor row
  CLC                                     ; $CADC: 18
  ADC a:cand_row                             ; $CADD: 6D 01 00 ; + row delta
  STA a:cand_row                             ; $CAE0: 8D 01 00 ; candidate row
  CMP #$0A                                ; $CAE3: C9 0A
  BCC @TerrainCheck                       ; $CAE5: 90 03 ; row in bounds
@Blocked:
  LDA #$01                                ; $CAE7: A9 01 ; tile rejected
  RTS                                     ; $CAE9: 60
@TerrainCheck:
  JSR BattleTerrainPassabilityCheck       ; $CAEA: 20 F9 CA
  CMP #$04                                ; $CAED: C9 04 ; class 4
  BEQ @Passable                           ; $CAEF: F0 04 ; arrows fly over
  CMP #$05                                ; $CAF1: C9 05 ; class 5
  BNE @KeepClass                          ; $CAF3: D0 02 ; (never returned)
@Passable:
  LDA #$00                                ; $CAF5: A9 00 ; tile passable
@KeepClass:
  TAY                                     ; $CAF7: A8 ; Z flag = passable
  RTS                                     ; $CAF8: 60
.endproc
;-------------------------------------------------------------------------------
; $CAF9: BattleTerrainPassabilityCheck
; Terrain passability check for the acting slot $0545's army affinity against
; the candidate tile at absolute coordinates $0000/$0001. Reads the tile id
; from the current battle map's terrain grid ($0544 = map index; per-map
; pointers at $BB1E, the $8000 window bank from $BB48), maps the tile id
; through BattleTerrainClassTable and returns:
;   A = 0              - class 0 passes for every army affinity, as does any
;                        class matching one of the army affinity's two entries
;                        in BattleArmyAffinityTerrainTableA/B;
;   A = terrain class  - blocked: classes 1/5 always (no troop-type
;                        override), and classes 2/3/4 the troop cannot
;                        traverse.
; Army affinity = bits 2-3 of officer-record byte $0B of the acting side's
; lead officer ($0560 for side A slots, $0561 for side B slots).
;-------------------------------------------------------------------------------
.proc BattleTerrainPassabilityCheck
; zero-page work cells (proc-local):
cand_col       = $0000  ; candidate column
cand_row       = $0001  ; candidate row
map_ptr_lo     = $0002  ; terrain map ptr lo
map_ptr_hi     = $0003  ; terrain map ptr hi
rec_ptr        = $0000  ; lead officer record ptr
  LDA battle_phase                               ; $CAF9: AD 44 05 ; battle map index
  PHA                                     ; $CAFC: 48
  TAY                                     ; $CAFD: A8
  LDA BattleCellMapBankTable,Y            ; $CAFE: B9 48 BB ; map data bank
  TAY                                     ; $CB01: A8
  JSR B1F_SwitchBank8_B                   ; $CB02: 20 5F F2 ; switch $8000 window
  PLA                                     ; $CB05: 68
  ASL                                     ; $CB06: 0A ; map index * 2
  TAY                                     ; $CB07: A8
  LDA BattleCellMapPtrTable,Y             ; $CB08: B9 1E BB ; terrain map ptr lo
  STA a:map_ptr_lo                             ; $CB0B: 8D 02 00
  LDA BattleCellMapPtrTable+1,Y           ; $CB0E: B9 1F BB ; terrain map ptr hi
  STA a:map_ptr_hi                             ; $CB11: 8D 03 00
  LDA a:cand_row                             ; $CB14: AD 01 00 ; candidate row
  ASL                                     ; $CB17: 0A
  ASL                                     ; $CB18: 0A
  ASL                                     ; $CB19: 0A
  ASL                                     ; $CB1A: 0A ; row * 16
  ORA a:cand_col                             ; $CB1B: 0D 00 00 ; + column
  TAY                                     ; $CB1E: A8
  LDA (map_ptr_lo),Y                             ; $CB1F: B1 02 ; terrain tile id
  TAY                                     ; $CB21: A8
  LDA BattleTerrainClassTable,Y           ; $CB22: B9 59 CB ; tile id -> class
  BEQ @Exit                               ; $CB25: F0 30 ; class 0: open, A = 0
  CMP #$01                                ; $CB27: C9 01
  BEQ @Exit                               ; $CB29: F0 2C ; class 1: blocked, no override
  CMP #$05                                ; $CB2B: C9 05
  BEQ @Exit                               ; $CB2D: F0 28 ; class 5: blocked, no override
  PHA                                     ; $CB2F: 48 ; keep class
  LDY #$00                                ; $CB30: A0 00 ; side A lead
  LDA btl_scan_col                               ; $CB32: AD 45 05 ; acting slot
  CMP #$0B                                ; $CB35: C9 0B
  BCC @SideLead                           ; $CB37: 90 01
  INY                                     ; $CB39: C8 ; side B lead
@SideLead:
  LDA btl_strip_buf_a,Y                             ; $CB3A: B9 60 05 ; lead officer id
  JSR B1F_GetOfficerRecordAddr            ; $CB3D: 20 D7 F2 ; record -> ($00)
  LDY #$0B                                ; $CB40: A0 0B
  LDA (rec_ptr),Y                             ; $CB42: B1 00 ; officer byte $0B
  LSR                                     ; $CB44: 4A
  LSR                                     ; $CB45: 4A
  AND #$03                                ; $CB46: 29 03 ; army affinity (bits 2-3)
  TAY                                     ; $CB48: A8
  PLA                                     ; $CB49: 68 ; terrain class
  TAX                                     ; $CB4A: AA ; kept in X (unused)
  CMP BattleArmyAffinityTerrainTableA,Y          ; $CB4B: D9 E9 CB ; allowed class A
  BEQ @Passable                           ; $CB4E: F0 05
  CMP BattleArmyAffinityTerrainTableB,Y          ; $CB50: D9 ED CB ; allowed class B
  BNE @Exit                               ; $CB53: D0 02 ; blocked: A = class
@Passable:
  LDA #$00                                ; $CB55: A9 00 ; passable
@Exit:
  TAY                                     ; $CB57: A8 ; Z flag = passable
  RTS                                     ; $CB58: 60
.endproc
; --- Terrain tile id -> class map for BattleTerrainPassabilityCheck ($CB59, 144 entries) ---
BattleTerrainClassTable:
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB59: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB69: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB79: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB89: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB99: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$00,$05,$00,$00,$05,$05; $CBA9: 00 00 00 00 00 00 00 00 05 05 00 05 00 00 05 05
  .byte $05,$05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CBB9: 05 05 05 05 05 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$03,$04,$02,$00,$00,$00,$00,$00,$00,$00,$01; $CBC9: 00 00 00 00 00 03 04 02 00 00 00 00 00 00 00 01
  .byte $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CBD9: 01 01 01 01 01 01 01 00 00 00 00 00 00 00 00 00
; --- Allowed terrain classes per army affinity (class A / class B) ---
BattleArmyAffinityTerrainTableA:
  .byte $00,$02,$03,$00                   ; $CBE9: 00 02 03 00
BattleArmyAffinityTerrainTableB:
  .byte $00,$02,$04,$00                   ; $CBED: 00 02 04 00
;===============================================================================
; $CBF1: BattlePanelStatsRefresh
; Rebuilds the battle status panel troop-count field block $044C-$046C from
; the live roster: the per-side general/infantry/archer/cavalry troop counts
; shown on the panel (cf. manual p. 31 example: 体73/騎97/弓179/歩700). The
; block holds 8 fields at stride 3 (value lo, value hi, reserved):
;   $044C       field 0: side A commander troop count (8-bit, <- $05AC)
;   $044F       field 1: side B commander troop count (8-bit, <- $05B7)
;   $0452/$0453 field 2: side A class-1 (infantry) troop total (16-bit)
;   $0455/$0456 field 3: side B class-1 (infantry) troop total
;   $0458/$0459 field 4: side A class-2 (archer) troop total
;   $045B/$045C field 5: side B class-2 (archer) troop total
;   $045E/$045F field 6: side A class-3 (cavalry) troop total
;   $0461/$0462 field 7: side B class-3 (cavalry) troop total
; The commander counts come from roster slots 0/$0B themselves; the class
; totals are accumulated by @ClassTroopSum over the 11 roster slots of each
; side (bases 0 and $0B). The class-to-piece mapping (1 = infantry 歩兵,
; 2 = archer 弓隊, 3 = cavalry 騎馬) follows BattleRosterSetup's composition
; rules and the manual's 騎:弓:歩 table. Callers pair this refresh with
; their own $0310/$0311/$0300 tile-animation queue writes: intro sub-state 2
; ($A0F9), the phase 1 round pass ($A235), and every return to the phase 3
; command panel ($AB6A, $AE0D, $AE68, $AE8A, $AECC, $D727).
;===============================================================================
.proc BattlePanelStatsRefresh
; zero-page work cells (proc-local):
req_class      = $0000  ; requested class filter ($FF = all)
total_lo       = $0001  ; class troop total lo
total_hi       = $0002  ; class troop total hi
; --- Code Region ---
  LDY #$20                                ; $CBF1: A0 20 ; field block size - 1
  LDA #$00                                ; $CBF3: A9 00
@ClearLoop:
  STA btl_panel_fields,Y                             ; $CBF5: 99 4C 04 ; clear $044C-$046C
  DEY                                     ; $CBF8: 88
  BPL @ClearLoop                          ; $CBF9: 10 FA
  LDA btl_troops_a                               ; $CBFB: AD AC 05 ; side A commander troop count
  STA btl_panel_fields                               ; $CBFE: 8D 4C 04 ; field 0
  LDA btl_troops_b                               ; $CC01: AD B7 05 ; side B commander troop count
  STA btl_panel_fields+$3                               ; $CC04: 8D 4F 04 ; field 1
  LDA #$01                                ; $CC07: A9 01 ; class 1 (infantry)
  LDY #$00                                ; $CC09: A0 00 ; side A roster base
  JSR @ClassTroopSum                      ; $CC0B: 20 7A CC ; sum -> $0001/$0002
  LDA a:total_lo                             ; $CC0E: AD 01 00 ; total lo
  STA btl_panel_fields+$6                               ; $CC11: 8D 52 04 ; field 2 lo
  LDA a:total_hi                             ; $CC14: AD 02 00 ; total hi
  STA btl_panel_fields+$7                               ; $CC17: 8D 53 04 ; field 2 hi
  LDA #$01                                ; $CC1A: A9 01 ; class 1 (infantry)
  LDY #$0B                                ; $CC1C: A0 0B ; side B roster base
  JSR @ClassTroopSum                      ; $CC1E: 20 7A CC
  LDA a:total_lo                             ; $CC21: AD 01 00
  STA btl_panel_fields+$9                               ; $CC24: 8D 55 04 ; field 3 lo
  LDA a:total_hi                             ; $CC27: AD 02 00
  STA btl_panel_fields+$A                               ; $CC2A: 8D 56 04 ; field 3 hi
  LDA #$02                                ; $CC2D: A9 02 ; class 2 (archer)
  LDY #$00                                ; $CC2F: A0 00 ; side A roster base
  JSR @ClassTroopSum                      ; $CC31: 20 7A CC
  LDA a:total_lo                             ; $CC34: AD 01 00
  STA btl_panel_fields+$C                               ; $CC37: 8D 58 04 ; field 4 lo
  LDA a:total_hi                             ; $CC3A: AD 02 00
  STA btl_panel_fields+$D                               ; $CC3D: 8D 59 04 ; field 4 hi
  LDA #$02                                ; $CC40: A9 02 ; class 2 (archer)
  LDY #$0B                                ; $CC42: A0 0B ; side B roster base
  JSR @ClassTroopSum                      ; $CC44: 20 7A CC
  LDA a:total_lo                             ; $CC47: AD 01 00
  STA btl_panel_fields+$F                               ; $CC4A: 8D 5B 04 ; field 5 lo
  LDA a:total_hi                             ; $CC4D: AD 02 00
  STA btl_panel_fields+$10                               ; $CC50: 8D 5C 04 ; field 5 hi
  LDA #$03                                ; $CC53: A9 03 ; class 3 (cavalry)
  LDY #$00                                ; $CC55: A0 00 ; side A roster base
  JSR @ClassTroopSum                      ; $CC57: 20 7A CC
  LDA a:total_lo                             ; $CC5A: AD 01 00
  STA btl_panel_fields+$12                               ; $CC5D: 8D 5E 04 ; field 6 lo
  LDA a:total_hi                             ; $CC60: AD 02 00
  STA btl_panel_fields+$13                               ; $CC63: 8D 5F 04 ; field 6 hi
  LDA #$03                                ; $CC66: A9 03 ; class 3 (cavalry)
  LDY #$0B                                ; $CC68: A0 0B ; side B roster base
  JSR @ClassTroopSum                      ; $CC6A: 20 7A CC
  LDA a:total_lo                             ; $CC6D: AD 01 00
  STA btl_panel_fields+$15                               ; $CC70: 8D 61 04 ; field 7 lo
  LDA a:total_hi                             ; $CC73: AD 02 00
  STA btl_panel_fields+$16                               ; $CC76: 8D 62 04 ; field 7 hi
  RTS                                     ; $CC79: 60
;-------------------------------------------------------------------------------
; @ClassTroopSum ($CC7A): accumulates the per-slot troop counts $05AC,Y of
; the 11 roster slots starting at base Y whose roster code low nibble
; ($05C2,Y & $0F) equals the requested unit class in A. Returns the 16-bit
; total in $0001 (lo) / $0002 (hi). Empty slots ($FF) and commander slots
; (low nibble 0) never match classes 1-3 and are skipped. Destroys A/X/Y.
;-------------------------------------------------------------------------------
@ClassTroopSum:
  STA a:req_class                             ; $CC7A: 8D 00 00 ; requested class
  LDA #$00                                ; $CC7D: A9 00
  STA a:total_lo                             ; $CC7F: 8D 01 00 ; total lo <- 0
  STA a:total_hi                             ; $CC82: 8D 02 00 ; total hi <- 0
  LDX #$0A                                ; $CC85: A2 0A ; 11 slots per side
@SumLoop:
  LDA btl_roster_code_a,Y                             ; $CC87: B9 C2 05 ; roster code
  AND #$0F                                ; $CC8A: 29 0F ; unit class
  CMP a:req_class                             ; $CC8C: CD 00 00
  BNE @NextSlot                           ; $CC8F: D0 12 ; class mismatch
  LDA btl_troops_a,Y                             ; $CC91: B9 AC 05 ; slot troop count
  CLC                                     ; $CC94: 18
  ADC a:total_lo                             ; $CC95: 6D 01 00
  STA a:total_lo                             ; $CC98: 8D 01 00 ; total lo += count
  LDA a:total_hi                             ; $CC9B: AD 02 00
  ADC #$00                                ; $CC9E: 69 00 ; propagate carry
  STA a:total_hi                             ; $CCA0: 8D 02 00 ; total hi
@NextSlot:
  INY                                     ; $CCA3: C8
  DEX                                     ; $CCA4: CA
  BPL @SumLoop                            ; $CCA5: 10 E0
  RTS                                     ; $CCA7: 60
.endproc
;===============================================================================
; $CCA8: BattleInputPromptDraw
; Draws the blinking input-prompt sprite (tile $04, X base $A0) used by the
; A/B input-wait states: phase 4 defeat/retreat/damage/confirm handlers
; ($A3DC, $A40F, $A490, $A4BD) and the phase 8 panel confirm/advance waits
; ($AE11, $AE8E). The prompt is drawn only while frame tick counter $005E
; bit 4 is clear, so it blinks at a 16-tick period. Y base selects the
; prompt position: entry $CCA8 uses Y = $D8; the unreferenced alternate
; entry BattleInputPromptDrawAlt ($CCB5) uses Y = $E0. The sprite record
; (BattleInputPromptSprite) is submitted to B1F_SpriteOamWriterSimple with
; flip flags $0002 <- 0; the OAM slot cursor $007C is left as set by the
; per-frame sprite pipeline.
;===============================================================================
.proc BattleInputPromptDraw
; zero-page work cells (proc-local):
spr_x          = $000A  ; prompt sprite X
spr_y          = $000C  ; prompt sprite Y
spr_ptr_lo     = $0000  ; sprite record ptr lo
spr_ptr_hi     = $0001  ; sprite record ptr hi
flip_flags     = $0002  ; flip flags (0)
; --- Code Region ---
  LDA #$D8                                ; $CCA8: A9 D8 ; OAM Y base <- $D8
  STA a:spr_x                             ; $CCAA: 8D 0A 00
  LDA #$A0                                ; $CCAD: A9 A0 ; OAM X base <- $A0
  STA a:spr_y                             ; $CCAF: 8D 0C 00
  JMP BattleInputPromptBlinkDraw          ; $CCB2: 4C BF CC ; skip the alt entry
;-------------------------------------------------------------------------------
; BattleInputPromptDrawAlt ($CCB5): unreferenced alternate entry (retained
; for ROM byte-exactness): identical to the main entry but with Y base $E0
; (prompt shifted 8 pixels down). Falls through to the blink gate.
;-------------------------------------------------------------------------------
BattleInputPromptDrawAlt:
  LDA #$E0                                ; $CCB5: A9 E0 ; OAM Y base <- $E0
  STA a:spr_x                             ; $CCB7: 8D 0A 00
  LDA #$A0                                ; $CCBA: A9 A0 ; OAM X base <- $A0
  STA a:spr_y                             ; $CCBC: 8D 0C 00
BattleInputPromptBlinkDraw:
  LDA a:frame_tick                             ; $CCBF: AD 5E 00 ; frame tick counter
  AND #$10                                ; $CCC2: 29 10 ; blink phase bit
  BNE @Done                               ; $CCC4: D0 12 ; blink off: skip draw
  LDA #$D9                                ; $CCC6: A9 D9
  STA a:spr_ptr_lo                             ; $CCC8: 8D 00 00 ; sprite record ptr lo
  LDA #$CC                                ; $CCCB: A9 CC
  STA a:spr_ptr_hi                             ; $CCCD: 8D 01 00 ; ptr hi -> BattleInputPromptSprite
  LDA #$00                                ; $CCD0: A9 00
  STA a:flip_flags                             ; $CCD2: 8D 02 00 ; flip flags <- 0
  JMP B1F_SpriteOamWriterSimple           ; $CCD5: 4C AD F1 ; draw prompt sprite
@Done:
  RTS                                     ; $CCD8: 60
; --- Sprite record: single tile $04 at offset (0,0) + bases, $80-terminated ---
BattleInputPromptSprite:
  .byte $00,$04,$00,$00,$80               ; $CCD9: 00 04 00 00 80
.endproc
;===============================================================================
; $CCDE: BattlePadStateFetch
; Mode-filtered controller state fetch. Input: A = pad index (0/1). The input
; source mode is taken from $0562 (pad 1) / $0563 (pad 2):
;   mode 1: $0000 <- pad 2 edge ($0085), $0001 <- pad 2 raw ($0082)
;   mode 3: $0000/$0001 <- 0 (AI-controlled side: physical input ignored)
;   other : $0000 <- pad 1 edge ($0083), $0001 <- pad 1 raw ($0081)
; (pad edge/raw semantics per ControllerRead $E6C6.) Except for mode 3, the
; raw byte is OR-latched into $057B, which BattleVBlankFrameUpdate swaps into
; $0081 to feed B1D_1E_MenuUpdate.
;===============================================================================
.proc BattlePadStateFetch
; zero-page work cells (proc-local):
merged_hi      = $0000  ; merged pad state hi (relatched to $0083)
merged_lo      = $0001  ; merged pad state lo (relatched to $0081)
; --- Code Region ---
  CMP #$00                                ; $CCDE: C9 00 ; pad index
  BNE @Pad2Mode                           ; $CCE0: D0 06
  LDA btl_input_mode_a                               ; $CCE2: AD 62 05 ; pad 1 input mode
  JMP @ModeDispatch                       ; $CCE5: 4C EB CC
@Pad2Mode:
  LDA btl_input_mode_b                               ; $CCE8: AD 63 05 ; pad 2 input mode
@ModeDispatch:
  CMP #$01                                ; $CCEB: C9 01
  BEQ @Pad2State                          ; $CCED: F0 17
  CMP #$03                                ; $CCEF: C9 03
  BEQ @NoInput                            ; $CCF1: F0 26
  LDA a:btl_pad1_hi                             ; $CCF3: AD 83 00 ; pad 1 edge
  STA a:merged_hi                             ; $CCF6: 8D 00 00
  LDA a:btl_pad1_lo                             ; $CCF9: AD 81 00 ; pad 1 raw
  STA a:merged_lo                             ; $CCFC: 8D 01 00
  ORA btl_input_mask                               ; $CCFF: 0D 7B 05
  STA btl_input_mask                               ; $CD02: 8D 7B 05 ; latch into menu input mask
  RTS                                     ; $CD05: 60
@Pad2State:
  LDA a:btl_pad2_hi                             ; $CD06: AD 85 00 ; pad 2 edge
  STA a:merged_hi                             ; $CD09: 8D 00 00
  LDA a:btl_pad2_lo                             ; $CD0C: AD 82 00 ; pad 2 raw
  STA a:merged_lo                             ; $CD0F: 8D 01 00
  ORA btl_input_mask                               ; $CD12: 0D 7B 05
  STA btl_input_mask                               ; $CD15: 8D 7B 05
  RTS                                     ; $CD18: 60
@NoInput:
  LDA #$00                                ; $CD19: A9 00 ; AI side: no physical input
  STA a:merged_hi                             ; $CD1B: 8D 00 00
  STA a:merged_lo                             ; $CD1E: 8D 01 00
  RTS                                     ; $CD21: 60
.endproc
;===============================================================================
; $CD22: BattleBothPadsStateFetch
; Fetches both pads' mode-filtered states via BattlePadStateFetch and merges
; them: $0000 = pad1 edge | pad2 edge, $0001 = pad1 raw | pad2 raw. Used by
; the phase-4 result handlers to accept an A/B edge from either controller.
;===============================================================================
.proc BattleBothPadsStateFetch
; zero-page work cells (proc-local):
merged_hi      = $0000  ; OR-merged both-pad state hi
merged_lo      = $0001  ; OR-merged both-pad state lo
  LDA #$00                                ; $CD22: A9 00 ; pad 1
  JSR BattlePadStateFetch                 ; $CD24: 20 DE CC
  LDA a:merged_hi                             ; $CD27: AD 00 00
  PHA                                     ; $CD2A: 48
  LDA a:merged_lo                             ; $CD2B: AD 01 00
  PHA                                     ; $CD2E: 48
  LDA #$01                                ; $CD2F: A9 01
  JSR BattlePadStateFetch                 ; $CD31: 20 DE CC
  PLA                                     ; $CD34: 68
  ORA a:merged_lo                             ; $CD35: 0D 01 00
  STA a:merged_lo                             ; $CD38: 8D 01 00
  PLA                                     ; $CD3B: 68
  ORA a:merged_hi                             ; $CD3C: 0D 00 00
  STA a:merged_hi                             ; $CD3F: 8D 00 00
  RTS                                     ; $CD42: 60
.endproc
;===============================================================================
; $CD43: Phase5SideEventSubDispatch
; Phase-5 handler entry (side event): sub-dispatch on $0541 through the
; inline 3-entry table below, covering side-event sub-states 0-2. Entered
; from Phase2MoveEventCheck when a unit walks onto a side-event column
; (0 or $0B), and re-enters the overlay at phase 0 sub 1 once sub 2 finishes.
;   0 Phase5SideEventRosterCommit ($CD4F) palette copy + roster HP commit
;   1 Phase5SideEventPanelSetup   ($CD59) panel params + per-side pad flags
;   2 Phase5SideEventClose        ($CDCF) troop reload, retreat marks, exit
;===============================================================================
.proc Phase5SideEventSubDispatch
  LDA btl_overlay_sub                               ; $CD43: AD 41 05
  JSR B1F_CallbackDispatcher              ; $CD46: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase5SideEventRosterCommit       ; $CD49: 4F CD ; sub 0
  .word Phase5SideEventPanelSetup         ; $CD4B: 59 CD ; sub 1
  .word Phase5SideEventClose              ; $CD4D: CF CD ; sub 2
.endproc
;===============================================================================
; $CD4F: Phase5SideEventRosterCommit
; Sub 0 (side-event entry): copies the palette buffer (B1F_PaletteCopyBuffer),
; advances to sub 1 and commits both sides' current troop counts and per-unit
; HP totals into the commander roster records (BattleOverlayTotalRefresh).
;===============================================================================
.proc Phase5SideEventRosterCommit
  JSR B1F_PaletteCopyBuffer               ; $CD4F: 20 EE EC ; palette refresh
  INC btl_overlay_sub                               ; $CD52: EE 41 05 ; sub-phase <- 1
  JSR BattleOverlayTotalRefresh           ; $CD55: 20 3F CA ; roster HP commit
.endproc
;-------------------------------------------------------------------------------
; $CD58: Phase5WaitExit - shared RTS at the tail of Phase5SideEventRosterCommit,
; branched to by Phase5SideEventPanelSetup's palette-wait loop. Same scoping
; constraint as Phase2WalkExit: shared exit labels stay bare globals.
;-------------------------------------------------------------------------------
Phase5WaitExit:
  RTS                                     ; $CD58: 60
;===============================================================================
; $CD59: Phase5SideEventPanelSetup
; Sub 1: waits on $0087 bit7 (palette/frame flag), then disables NMI
; (B1F_NmiDisable), advances to sub 2, arms the flash counter ($007A <- 7)
; and clears panel params $04A8-$04AA. Then fills the per-side panel block
; from the pad input modes $0562/$0563: direct order when side A mode is 0
; or side B mode is neither 0 nor 1, swapped order when side A mode != 0 and
; side B mode is 0/1. Strip pointers $0560/$0561 go to $04AD/$04AE (swapped:
; $04AE/$04AD) and each side's pad mode is stored (or $80 for AI mode 3)
; into $04AB/$04AC (swapped: $04AC/$04AB).
;===============================================================================
.proc Phase5SideEventPanelSetup
  LDA a:btl_frame_flag                             ; $CD59: AD 87 00 ; palette/frame flag
  BPL Phase5WaitExit                      ; $CD5C: 10 FA ; bit7 clear: wait
  JSR B1F_NmiDisable                      ; $CD5E: 20 68 E7
  INC btl_overlay_sub                               ; $CD61: EE 41 05 ; sub-phase <- 2
  LDA #$07                                ; $CD64: A9 07
  STA a:btl_flash_counter                             ; $CD66: 8D 7A 00 ; flash counter <- 7
  LDA #$00                                ; $CD69: A9 00
  STA btl_sideev_params                               ; $CD6B: 8D A8 04 ; panel params clear
  STA btl_sideev_params+1                               ; $CD6E: 8D A9 04
  STA btl_sideev_params+2                               ; $CD71: 8D AA 04
  LDA btl_input_mode_a                               ; $CD74: AD 62 05 ; side A input mode
  BEQ @DirectAssign                       ; $CD77: F0 0C ; mode 0: direct order
  LDA btl_input_mode_b                               ; $CD79: AD 63 05 ; side B input mode
  BEQ @SwappedAssign                      ; $CD7C: F0 2C
  LDA btl_input_mode_b                               ; $CD7E: AD 63 05
  CMP #$01                                ; $CD81: C9 01
  BEQ @SwappedAssign                      ; $CD83: F0 25
@DirectAssign:
  LDA btl_strip_buf_a                               ; $CD85: AD 60 05 ; strip 0 ptr
  STA btl_sideev_strip_a                               ; $CD88: 8D AD 04
  LDA btl_strip_buf_b                               ; $CD8B: AD 61 05 ; strip 1 ptr
  STA btl_sideev_strip_b                               ; $CD8E: 8D AE 04
  LDA btl_input_mode_a                               ; $CD91: AD 62 05 ; side A mode
  CMP #$03                                ; $CD94: C9 03 ; AI-controlled?
  BNE @StoreSideAFlag                     ; $CD96: D0 02
  LDA #$80                                ; $CD98: A9 80 ; AI flag
@StoreSideAFlag:
  STA btl_sideev_troop_a                               ; $CD9A: 8D AB 04
  LDA btl_input_mode_b                               ; $CD9D: AD 63 05 ; side B mode
  CMP #$03                                ; $CDA0: C9 03 ; AI-controlled?
  BNE @StoreSideBFlag                     ; $CDA2: D0 02
  LDA #$80                                ; $CDA4: A9 80 ; AI flag
@StoreSideBFlag:
  STA btl_sideev_troop_b                               ; $CDA6: 8D AC 04
  RTS                                     ; $CDA9: 60
@SwappedAssign:
  LDA btl_strip_buf_a                               ; $CDAA: AD 60 05 ; strip 0 ptr
  STA btl_sideev_strip_b                               ; $CDAD: 8D AE 04 ; -> slot 1
  LDA btl_strip_buf_b                               ; $CDB0: AD 61 05 ; strip 1 ptr
  STA btl_sideev_strip_a                               ; $CDB3: 8D AD 04 ; -> slot 0
  LDA btl_input_mode_a                               ; $CDB6: AD 62 05 ; side A mode
  CMP #$03                                ; $CDB9: C9 03 ; AI-controlled?
  BNE @StoreSideBFlagSwapped              ; $CDBB: D0 02
  LDA #$80                                ; $CDBD: A9 80 ; AI flag
@StoreSideBFlagSwapped:
  STA btl_sideev_troop_b                               ; $CDBF: 8D AC 04 ; A mode -> slot 1
  LDA btl_input_mode_b                               ; $CDC2: AD 63 05 ; side B mode
  CMP #$03                                ; $CDC5: C9 03 ; AI-controlled?
  BNE @StoreSideAFlagSwapped              ; $CDC7: D0 02
  LDA #$80                                ; $CDC9: A9 80 ; AI flag
@StoreSideAFlagSwapped:
  STA btl_sideev_troop_a                               ; $CDCB: 8D AB 04 ; B mode -> slot 0
  RTS                                     ; $CDCE: 60
.endproc
;===============================================================================
; $CDCF: Phase5SideEventClose
; Sub 2: waits on $0087 bit7, then reloads both sides' troop counts from
; offset 0 of the commander roster records ($0560/$0561 via
; B1F_GetOfficerRecordAddr) into $05AC/$05B7. Marks a retreat (strip flag
; == 1 in $0515/$0517) by setting slot 0 of the corresponding side's action
; slot array ($0550 side A / $0554 side B) via Phase5RetreatSlotMark, then
; re-enters the overlay: phase <- 0, sub <- 1 (BattleOverlayIntroRosterWalk),
; frame counter $0548 <- 0.
;===============================================================================
.proc Phase5SideEventClose
; zero-page work cells (proc-local):
rec_ptr        = $0000  ; officer record ptr (record[0] troop count)
  LDA a:btl_frame_flag                             ; $CDCF: AD 87 00 ; palette/frame flag
  BPL @Done                               ; $CDD2: 10 3B ; bit7 clear: wait
  LDA btl_strip_buf_a                               ; $CDD4: AD 60 05 ; side A commander id
  JSR B1F_GetOfficerRecordAddr            ; $CDD7: 20 D7 F2
  LDY #$00                                ; $CDDA: A0 00
  LDA (rec_ptr),Y                             ; $CDDC: B1 00 ; record[0] troop count
  STA btl_troops_a                               ; $CDDE: 8D AC 05 ; side A troop count
  LDA btl_strip_buf_b                               ; $CDE1: AD 61 05 ; side B commander id
  JSR B1F_GetOfficerRecordAddr            ; $CDE4: 20 D7 F2
  LDY #$00                                ; $CDE7: A0 00
  LDA (rec_ptr),Y                             ; $CDE9: B1 00 ; record[0] troop count
  STA btl_troops_b                               ; $CDEB: 8D B7 05 ; side B troop count
  LDA #$00                                ; $CDEE: A9 00
  STA btl_overlay_phase                               ; $CDF0: 8D 40 05 ; phase <- 0
  LDA #$01                                ; $CDF3: A9 01
  STA btl_overlay_sub                               ; $CDF5: 8D 41 05 ; sub <- 1 (roster walk)
  LDA #$00                                ; $CDF8: A9 00
  STA btl_frame_counter                               ; $CDFA: 8D 48 05 ; frame counter <- 0
  LDA btl_strip_sel_a                               ; $CDFD: AD 14 05 ; side A strip ptr
  LDY btl_strip_flag_a                               ; $CE00: AC 15 05 ; side A strip flag
  JSR Phase5RetreatSlotMark               ; $CE03: 20 10 CE
  LDA btl_strip_sel_b                               ; $CE06: AD 16 05 ; side B strip ptr
  LDY btl_strip_flag_b                               ; $CE09: AC 17 05 ; side B strip flag
  JSR Phase5RetreatSlotMark               ; $CE0C: 20 10 CE
@Done:
  RTS                                     ; $CE0F: 60
.endproc
;===============================================================================
; $CE10: Phase5RetreatSlotMark
; Helper for Phase5SideEventClose: A = side strip ptr, Y = side strip flag.
; Only a retreat flag (Y == 1) is handled: if the strip ptr matches side A
; ($0560), slot 0 of side A's action slot array ($0550) is marked 1,
; otherwise slot 0 of side B's array ($0554).
;===============================================================================
.proc Phase5RetreatSlotMark
  CPY #$01                                ; $CE10: C0 01 ; strip flag: 1 = retreated
  BNE @Done                               ; $CE12: D0 10
  CMP btl_strip_buf_a                               ; $CE14: CD 60 05 ; side A strip?
  BNE @MarkSideB                          ; $CE17: D0 06
  LDA #$01                                ; $CE19: A9 01
  STA btl_order_slots_a                               ; $CE1B: 8D 50 05 ; side A slot 0 <- 1
  RTS                                     ; $CE1E: 60
@MarkSideB:
  LDA #$01                                ; $CE1F: A9 01
  STA btl_order_slots_b                               ; $CE21: 8D 54 05 ; side B slot 0 <- 1
@Done:
  RTS                                     ; $CE24: 60
.endproc
;===============================================================================
; $CE25: Phase6FormationSelectSubDispatch
; Phase 6 handler (side A pre-battle formation select): sub-dispatch on
; $0541 through the inline 4-entry table below. Edits the side A formation
; index $056C (0-3: Serpent/Goose/Wedge/Fish Scale, consumed by
; BattleRosterSetup as the &3 layout index); input mode $0562 = 3 (AI) gets
; a random formation and skips the menus. The A-confirm hands control to
; phase 3 command selection with resume latch $054B/$054C <- 6/3 so sub 3
; here advances to phase 7 (side B formation select) afterwards.
;===============================================================================
.proc Phase6FormationSelectSubDispatch
  LDA btl_overlay_sub                               ; $CE25: AD 41 05
  JSR B1F_CallbackDispatcher              ; $CE28: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase6FormationPanelInit          ; $CE2B: 33 CE ; sub 0 ($CE33)
  .word Phase6FormationMenuInput          ; $CE2D: 68 CE ; sub 1 ($CE68)
  .word Phase6FormationConfirmWait        ; $CE2F: AE CE ; sub 2 ($CEAE)
  .word Phase6AdvanceToSideBFormation     ; $CE31: FA CE ; sub 3 ($CEFA)
.endproc
;===============================================================================
; $CE33: Phase6FormationPanelInit
; Sub 0. Seeds formation index $056C with a random value (&3) as the
; default, then (unless side A input mode $0562 = 3, AI: jump straight to
; sub 3) requests UI panel $D4 (formation select), advances to sub 1,
; re-renders the side A officer display (B1D_1E_OfficerDisplay_Render with
; buffer $0560) and resets the shared menu cursor ($0424 column / $0425
; page); panel param $00BC <- $7D.
;===============================================================================
.proc Phase6FormationPanelInit
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; overlay strip render buffer ptr lo
  JSR B1F_RandomByte                      ; $CE33: 20 7A E8
  AND #$03                                ; $CE36: 29 03
  STA btl_formation_a                               ; $CE38: 8D 6C 05 ; formation <- random
  LDA btl_input_mode_a                               ; $CE3B: AD 62 05 ; side A input mode
  CMP #$03                                ; $CE3E: C9 03
  BNE @ShowPanel                          ; $CE40: D0 03 ; not AI: show panel
  JMP Phase6AdvanceToSideBFormation       ; $CE42: 4C FA CE ; AI: skip menus
@ShowPanel:
  LDA #$D4                                ; $CE45: A9 D4
  JSR B1F_SetUI0                          ; $CE47: 20 6D F2 ; formation panel
  INC btl_overlay_sub                               ; $CE4A: EE 41 05 ; sub-phase <- 1
  LDA btl_strip_buf_a                               ; $CE4D: AD 60 05 ; side A commander id
  STA a:strip_ptr_lo                             ; $CE50: 8D 00 00
  LDY #$3D                                ; $CE53: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $CE55: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_OfficerDisplay_Render      ; $CE58: 30 A0
  LDA #$00                                ; $CE5A: A9 00
  STA menu_cursor_col                               ; $CE5C: 8D 24 04 ; menu column <- 0
  STA menu_cursor_page                               ; $CE5F: 8D 25 04 ; menu page <- 0
  LDA #$7D                                ; $CE62: A9 7D
  STA a:zp_panel_param_b                             ; $CE64: 8D BC 00 ; panel param
  RTS                                     ; $CE67: 60
.endproc
;===============================================================================
; $CE68: Phase6FormationMenuInput
; Sub 1. Per frame: re-render the side A overlay strip (bank $19 render with
; buffer $0560, X=0), run FormationSelectMenu (side-A pad input through the
; 4-wide menu; shared cursor $0424/$0425, selected item -> $056C) and wait
; while the animation queue is busy. On A: advance to sub 2, request UI
; panel $D2 (confirm) and copy side A country $0564's ruler officer id
; (country record byte 0) to $042C for panel formatting.
;===============================================================================
.proc Phase6FormationMenuInput
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; strip render ptr lo / country data ptr
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
country_ptr    = $0000  ; country record ptr (ruler id byte 0)
pad_state      = $0001  ; merged both-pad raw state
menu_result    = $0012  ; FormationSelectMenu selected item
  LDA btl_strip_buf_a                               ; $CE68: AD 60 05 ; side A commander id
  STA a:strip_ptr_lo                             ; $CE6B: 8D 00 00
  LDA #$A5                                ; $CE6E: A9 A5 ; buffer page
  STA a:strip_ptr_hi                             ; $CE70: 8D 0A 00
  LDX #$00                                ; $CE73: A2 00 ; strip 0
  LDY #$39                                ; $CE75: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $CE77: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $CE7A: 00 A0 ; B19_OverlayStripRender_Entry
  LDY #$00                                ; $CE7C: A0 00 ; side A pad input
  JSR FormationSelectMenu                 ; $CE7E: 20 05 CF
  LDA a:menu_result                             ; $CE81: AD 12 00 ; menu result item
  STA btl_formation_a                               ; $CE84: 8D 6C 05 ; formation index
  LDA #$00                                ; $CE87: A9 00
  JSR BattlePadStateFetch                 ; $CE89: 20 DE CC
  JSR BattleAnimQueueIdleCheck            ; $CE8C: 20 70 B8
  BCC @Done                               ; $CE8F: 90 1C ; queue busy: wait
  LDA a:pad_state                             ; $CE91: AD 01 00
  AND #$01                                ; $CE94: 29 01 ; A button
  BEQ @Done                               ; $CE96: F0 15
  INC btl_overlay_sub                               ; $CE98: EE 41 05 ; sub-phase <- 2
  LDA #$D2                                ; $CE9B: A9 D2
  JSR B1F_SetUI0                          ; $CE9D: 20 6D F2 ; confirm panel
  LDA btl_country_a                               ; $CEA0: AD 64 05 ; side A country
  JSR B1F_GetCountryDataPtr               ; $CEA3: 20 68 F3
  LDY #$00                                ; $CEA6: A0 00
  LDA (country_ptr),Y                             ; $CEA8: B1 00 ; ruler officer id
  STA btl_panel_params                               ; $CEAA: 8D 2C 04 ; panel officer id
@Done:
  RTS                                     ; $CEAD: 60
.endproc
;===============================================================================
; $CEAE: Phase6FormationConfirmWait
; Sub 2. Per frame: re-render the side A overlay strip, wait while the
; animation queue is busy, then draw the blinking A-confirm prompt
; (FormationConfirmPromptDraw). On A: hand control to phase 3 command
; selection (phase $0540 <- 3, sub $0541 <- 0, acting side $0549 <- 0) with
; resume latch $054B/$054C <- 6/3, so phase 6 resumes at sub 3 (advance to
; side B) once the command cycle finishes; panel param $00BC <- 5.
;===============================================================================
.proc Phase6FormationConfirmWait
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; strip render buffer ptr lo
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
pad_state      = $0001  ; merged both-pad raw state
  LDA btl_strip_buf_a                               ; $CEAE: AD 60 05
  STA a:strip_ptr_lo                             ; $CEB1: 8D 00 00
  LDA #$A5                                ; $CEB4: A9 A5
  STA a:strip_ptr_hi                             ; $CEB6: 8D 0A 00
  LDX #$00                                ; $CEB9: A2 00
  LDY #$39                                ; $CEBB: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $CEBD: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $CEC0: 00 A0 ; B19_OverlayStripRender_Entry
  LDA #$00                                ; $CEC2: A9 00
  JSR BattlePadStateFetch                 ; $CEC4: 20 DE CC
  JSR BattleAnimQueueIdleCheck            ; $CEC7: 20 70 B8
  BCC @Done                               ; $CECA: 90 2D ; queue busy: wait
  JSR FormationConfirmPromptDraw          ; $CECC: 20 FD C8 ; blinking prompt
  LDA #$00                                ; $CECF: A9 00
  JSR BattlePadStateFetch                 ; $CED1: 20 DE CC
  LDA a:pad_state                             ; $CED4: AD 01 00
  AND #$01                                ; $CED7: 29 01 ; A button
  BEQ @Done                               ; $CED9: F0 1E
  LDA #$03                                ; $CEDB: A9 03
  STA btl_overlay_phase                               ; $CEDD: 8D 40 05 ; phase <- 3 (command select)
  LDA #$00                                ; $CEE0: A9 00
  STA btl_overlay_sub                               ; $CEE2: 8D 41 05 ; sub-phase <- 0
  LDA #$06                                ; $CEE5: A9 06
  STA btl_walk_col                               ; $CEE7: 8D 4B 05 ; resume latch phase <- 6
  LDA #$03                                ; $CEEA: A9 03
  STA btl_recorded_status                               ; $CEEC: 8D 4C 05 ; resume latch sub <- 3
  LDA #$00                                ; $CEEF: A9 00
  STA btl_acting_unit                               ; $CEF1: 8D 49 05 ; acting side <- 0
  LDA #$05                                ; $CEF4: A9 05
  STA a:zp_panel_param_b                             ; $CEF6: 8D BC 00 ; panel param
@Done:
  RTS                                     ; $CEF9: 60
.endproc
;===============================================================================
; $CEFA: Phase6AdvanceToSideBFormation
; Sub 3. Advances the overlay to phase 7 (side B pre-battle formation
; select), sub 0. Reached when the side A confirm completes its phase 3
; command cycle (resume latch 6/3), or immediately from sub 0 when side A
; is AI-controlled.
;===============================================================================
.proc Phase6AdvanceToSideBFormation
  LDA #$07                                ; $CEFA: A9 07
  STA btl_overlay_phase                               ; $CEFC: 8D 40 05 ; phase <- 7
  LDA #$00                                ; $CEFF: A9 00
  STA btl_overlay_sub                               ; $CF01: 8D 41 05 ; sub-phase <- 0
  RTS                                     ; $CF04: 60
.endproc
;===============================================================================
; $CF05: FormationSelectMenu
; Side-wrapped 4-wide menu (bank $1F helpers): temporarily swaps the side's
; pad state (BattlePadStateFetch on Y = side) into the shared menu input
; slots $0083/$0081, steps the menu (B1F_MenuStep4) over
; FormationSelectItemList, then draws the cursor sprite at the selected
; item's Y/X base (B1F_PointerTableLookup on FormationSelectCursorPosTable
; + FormationSelectCursorSprite). The selected item stays in zp $12 for the
; caller.
;===============================================================================
.proc FormationSelectMenu
; zero-page work cells (proc-local):
pad_fetched_hi = $0000  ; BattlePadStateFetch result hi
pad_fetched_lo = $0001  ; BattlePadStateFetch result lo
list_ptr_lo    = $0010  ; FormationSelectItemList ptr lo
list_ptr_hi    = $0011  ; item list ptr hi
selected_item  = $0012  ; selected menu item (stays for caller)
cursor_tbl_lo  = $0010  ; cursor pos table ptr lo
cursor_tbl_hi  = $0011  ; cursor pos table ptr hi
cursor_ptr_lo  = $0000  ; cursor param ptr lo
cursor_ptr_hi  = $0001  ; cursor param ptr hi
  LDA a:btl_pad1_hi                             ; $CF05: AD 83 00
  PHA                                     ; $CF08: 48
  LDA a:btl_pad1_lo                             ; $CF09: AD 81 00
  PHA                                     ; $CF0C: 48
  TYA                                     ; $CF0D: 98
  JSR BattlePadStateFetch                 ; $CF0E: 20 DE CC
  LDA a:pad_fetched_hi                             ; $CF11: AD 00 00
  STA a:btl_pad1_hi                             ; $CF14: 8D 83 00
  LDA a:pad_fetched_lo                             ; $CF17: AD 01 00
  STA a:btl_pad1_lo                             ; $CF1A: 8D 81 00
  LDA #$52                                ; $CF1D: A9 52
  STA a:list_ptr_lo                             ; $CF1F: 8D 10 00
  LDA #$CF                                ; $CF22: A9 CF
  STA a:list_ptr_hi                             ; $CF24: 8D 11 00
  LDA #$00                                ; $CF27: A9 00
  STA a:selected_item                             ; $CF29: 8D 12 00
  JSR B1F_MenuStep4                       ; $CF2C: 20 28 ED
  LDA #$5A                                ; $CF2F: A9 5A
  STA a:cursor_tbl_lo                             ; $CF31: 8D 10 00
  LDA #$CF                                ; $CF34: A9 CF
  STA a:cursor_tbl_hi                             ; $CF36: 8D 11 00
  LDA #$62                                ; $CF39: A9 62
  STA a:cursor_ptr_lo                             ; $CF3B: 8D 00 00
  LDA #$CF                                ; $CF3E: A9 CF
  STA a:cursor_ptr_hi                             ; $CF40: 8D 01 00
  LDA a:selected_item                             ; $CF43: AD 12 00
  JSR B1F_PointerTableLookup              ; $CF46: 20 F5 ED
  PLA                                     ; $CF49: 68
  STA a:btl_pad1_lo                             ; $CF4A: 8D 81 00
  PLA                                     ; $CF4D: 68
  STA a:btl_pad1_hi                             ; $CF4E: 8D 83 00
  RTS                                     ; $CF51: 60
.endproc
; --- Data Region ---
FormationSelectItemList:  ; formation items 0-3 + $FF terminator
  .byte $00,$01,$02,$03,$FF               ; $CF52: 00 01 02 03 FF
  .byte $FF,$FF,$FF                       ; $CF57: FF FF FF ; padding
FormationSelectCursorPosTable:  ; per item: cursor OAM Y base, X base
  .byte $B6,$4C,$B6,$74,$B6,$9C,$B6,$C4   ; $CF5A: B6 4C B6 74 B6 9C B6 C4
FormationSelectCursorSprite:  ; OAM record (dy/tile/attr/dx) + $80 terminator
  .byte $00,$04,$00,$00,$80               ; $CF62: 00 04 00 00 80
;===============================================================================
; $CF67: Phase7FormationSelectSubDispatch
; Phase 7 handler (side B pre-battle formation select): sub-dispatch on
; $0541 through the inline 5-entry table below. Mirrors phase 6 for side B:
; edits the side B formation index $056D (0-3: Serpent/Goose/Wedge/Fish
; Scale), using side B input mode $0563 and country $0565. Input mode 3
; (AI) skips the menus and jumps straight to sub 4 (battle mode start). The
; A-confirm hands control to phase 3 command selection with resume latch
; $054B/$054C <- 7/4, so sub 4 here starts the battle once the command
; cycle finishes.
;===============================================================================
.proc Phase7FormationSelectSubDispatch
  LDA btl_overlay_sub                               ; $CF67: AD 41 05
  JSR B1F_CallbackDispatcher              ; $CF6A: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase7FormationPanelInit          ; $CF6D: 77 CF ; sub 0 ($CF77)
  .word Phase7FormationPanelOpen          ; $CF6F: 9D CF ; sub 1 ($CF9D)
  .word Phase7FormationMenuInput          ; $CF71: C2 CF ; sub 2 ($CFC2)
  .word Phase7FormationConfirmWait        ; $CF73: 08 D0 ; sub 3 ($D008)
  .word Phase7BattleModeStart             ; $CF75: 54 D0 ; sub 4 ($D054)
.endproc
;===============================================================================
; $CF77: Phase7FormationPanelInit
; Sub 0. Seeds formation index $056D with a random value (&3) as the
; default, then (unless side B input mode $0563 = 3, AI: jump straight to
; sub 4 battle mode start) clears the pending animation id/slot
; ($0310/$0300), advances to sub 1 and resets the shared menu cursor
; ($0424 column / $0425 page).
;===============================================================================
.proc Phase7FormationPanelInit
  JSR B1F_RandomByte                      ; $CF77: 20 7A E8
  AND #$03                                ; $CF7A: 29 03
  STA btl_formation_b                               ; $CF7C: 8D 6D 05 ; formation <- random
  LDA btl_input_mode_b                               ; $CF7F: AD 63 05 ; side B input mode
  CMP #$03                                ; $CF82: C9 03
  BNE @ShowPanel                          ; $CF84: D0 03 ; not AI: show panel
  JMP Phase7BattleModeStart               ; $CF86: 4C 54 D0 ; AI: skip menus
@ShowPanel:
  LDA #$00                                ; $CF89: A9 00
  STA anim_queue_id0_lo                               ; $CF8B: 8D 10 03 ; anim id <- 0
  STA anim_queue_hdr0                               ; $CF8E: 8D 00 03 ; anim slot <- 0
  INC btl_overlay_sub                               ; $CF91: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $CF94: A9 00
  STA menu_cursor_col                               ; $CF96: 8D 24 04 ; menu column <- 0
  STA menu_cursor_page                               ; $CF99: 8D 25 04 ; menu page <- 0
  RTS                                     ; $CF9C: 60
.endproc
;===============================================================================
; $CF9D: Phase7FormationPanelOpen
; Sub 1. Waits for the animation queue to idle (BattleAnimQueueIdleCheck,
; C=1 idle), then requests UI panel $D4 (formation select), advances to
; sub 2, re-renders the side B officer display (B1D_1E_OfficerDisplay_Render
; with buffer $0561) and sets panel params $00BB <- 9 / $00BC <- $7D.
;===============================================================================
.proc Phase7FormationPanelOpen
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; overlay strip render buffer ptr lo
  JSR BattleAnimQueueIdleCheck            ; $CF9D: 20 70 B8
  BCC @Done                               ; $CFA0: 90 1F ; queue busy: wait
  LDA #$D4                                ; $CFA2: A9 D4
  JSR B1F_SetUI0                          ; $CFA4: 20 6D F2 ; formation panel
  INC btl_overlay_sub                               ; $CFA7: EE 41 05 ; sub-phase <- 2
  LDA btl_strip_buf_b                               ; $CFAA: AD 61 05 ; side B commander id
  STA a:strip_ptr_lo                             ; $CFAD: 8D 00 00
  LDY #$3D                                ; $CFB0: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $CFB2: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_OfficerDisplay_Render      ; $CFB5: 30 A0
  LDA #$09                                ; $CFB7: A9 09
  STA a:zp_panel_param_a                             ; $CFB9: 8D BB 00 ; panel param
  LDA #$7D                                ; $CFBC: A9 7D
  STA a:zp_panel_param_b                             ; $CFBE: 8D BC 00 ; panel param
@Done:
  RTS                                     ; $CFC1: 60
.endproc
;===============================================================================
; $CFC2: Phase7FormationMenuInput
; Sub 2. Per frame: re-render the side B overlay strip (bank $19 render with
; buffer $0561, X=0), run FormationSelectMenu (side B pad input through the
; 4-wide menu; shared cursor $0424/$0425, selected item -> $056D) and wait
; while the animation queue is busy. On A: advance to sub 3, request UI
; panel $D2 (confirm) and copy side B country $0565's ruler officer id
; (country record byte 0) to $042C for panel formatting.
;===============================================================================
.proc Phase7FormationMenuInput
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; strip render ptr lo / country data ptr
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
country_ptr    = $0000  ; country record ptr (ruler id byte 0)
pad_state      = $0001  ; merged both-pad raw state
menu_result    = $0012  ; FormationSelectMenu selected item
  LDA btl_strip_buf_b                               ; $CFC2: AD 61 05 ; side B commander id
  STA a:strip_ptr_lo                             ; $CFC5: 8D 00 00
  LDA #$A5                                ; $CFC8: A9 A5 ; buffer page
  STA a:strip_ptr_hi                             ; $CFCA: 8D 0A 00
  LDX #$00                                ; $CFCD: A2 00 ; strip 0
  LDY #$39                                ; $CFCF: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $CFD1: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $CFD4: 00 A0 ; B19_OverlayStripRender_Entry
  LDY #$01                                ; $CFD6: A0 01 ; side B pad input
  JSR FormationSelectMenu                 ; $CFD8: 20 05 CF
  LDA a:menu_result                             ; $CFDB: AD 12 00 ; menu result item
  STA btl_formation_b                               ; $CFDE: 8D 6D 05 ; formation index
  LDA #$01                                ; $CFE1: A9 01
  JSR BattlePadStateFetch                 ; $CFE3: 20 DE CC
  JSR BattleAnimQueueIdleCheck            ; $CFE6: 20 70 B8
  BCC @Done                               ; $CFE9: 90 1C ; queue busy: wait
  LDA a:pad_state                             ; $CFEB: AD 01 00
  AND #$01                                ; $CFEE: 29 01 ; A button
  BEQ @Done                               ; $CFF0: F0 15
  INC btl_overlay_sub                               ; $CFF2: EE 41 05 ; sub-phase <- 3
  LDA #$D2                                ; $CFF5: A9 D2
  JSR B1F_SetUI0                          ; $CFF7: 20 6D F2 ; confirm panel
  LDA btl_country_b                               ; $CFFA: AD 65 05 ; side B country
  JSR B1F_GetCountryDataPtr               ; $CFFD: 20 68 F3
  LDY #$00                                ; $D000: A0 00
  LDA (country_ptr),Y                             ; $D002: B1 00 ; ruler officer id
  STA btl_panel_params                               ; $D004: 8D 2C 04 ; panel officer id
@Done:
  RTS                                     ; $D007: 60
.endproc
;===============================================================================
; $D008: Phase7FormationConfirmWait
; Sub 3. Per frame: re-render the side B overlay strip, wait while the
; animation queue is busy, then draw the blinking A-confirm prompt
; (FormationConfirmPromptDraw). On A: hand control to phase 3 command
; selection (phase $0540 <- 3, sub $0541 <- 0, acting side $0549 <- 1) with
; resume latch $054B/$054C <- 7/4, so phase 7 resumes at sub 4 (battle mode
; start) once the command cycle finishes; panel param $00BC <- 5.
;===============================================================================
.proc Phase7FormationConfirmWait
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; strip render buffer ptr lo
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
pad_state      = $0001  ; merged both-pad raw state
  LDA btl_strip_buf_b                               ; $D008: AD 61 05
  STA a:strip_ptr_lo                             ; $D00B: 8D 00 00
  LDA #$A5                                ; $D00E: A9 A5
  STA a:strip_ptr_hi                             ; $D010: 8D 0A 00
  LDX #$00                                ; $D013: A2 00
  LDY #$39                                ; $D015: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $D017: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $D01A: 00 A0 ; B19_OverlayStripRender_Entry
  LDA #$01                                ; $D01C: A9 01
  JSR BattlePadStateFetch                 ; $D01E: 20 DE CC
  JSR BattleAnimQueueIdleCheck            ; $D021: 20 70 B8
  BCC @Done                               ; $D024: 90 2D ; queue busy: wait
  JSR FormationConfirmPromptDraw          ; $D026: 20 FD C8 ; blinking prompt
  LDA #$01                                ; $D029: A9 01
  JSR BattlePadStateFetch                 ; $D02B: 20 DE CC
  LDA a:pad_state                             ; $D02E: AD 01 00
  AND #$01                                ; $D031: 29 01 ; A button
  BEQ @Done                               ; $D033: F0 1E
  LDA #$03                                ; $D035: A9 03
  STA btl_overlay_phase                               ; $D037: 8D 40 05 ; phase <- 3 (command select)
  LDA #$00                                ; $D03A: A9 00
  STA btl_overlay_sub                               ; $D03C: 8D 41 05 ; sub-phase <- 0
  LDA #$07                                ; $D03F: A9 07
  STA btl_walk_col                               ; $D041: 8D 4B 05 ; resume latch phase <- 7
  LDA #$04                                ; $D044: A9 04
  STA btl_recorded_status                               ; $D046: 8D 4C 05 ; resume latch sub <- 4
  LDA #$01                                ; $D049: A9 01
  STA btl_acting_unit                               ; $D04B: 8D 49 05 ; acting side <- 1
  LDA #$05                                ; $D04E: A9 05
  STA a:zp_panel_param_b                             ; $D050: 8D BC 00 ; panel param
@Done:
  RTS                                     ; $D053: 60
.endproc
;===============================================================================
; $D054: Phase7BattleModeStart
; Sub 4. Battle Mode start: reset phase/sub-phase to 0/1 (intro roster
; walk), clear the damage counter $0548 and build both sides' rosters via
; BattleRosterSetup. Reached through the resume latch 7/4 after the side B
; A-confirm's phase 3 command cycle, or directly from sub 0 when side B is
; AI-controlled.
;===============================================================================
.proc Phase7BattleModeStart
  LDA #$00                                ; $D054: A9 00
  STA btl_overlay_phase                               ; $D056: 8D 40 05 ; phase <- 0
  LDA #$01                                ; $D059: A9 01
  STA btl_overlay_sub                               ; $D05B: 8D 41 05 ; sub-phase <- 1 (roster walk)
  LDA #$00                                ; $D05E: A9 00
  STA btl_frame_counter                               ; $D060: 8D 48 05 ; damage counter <- 0
  JSR BattleRosterSetup                   ; $D063: 20 48 B5
  RTS                                     ; $D066: 60
.endproc
;===============================================================================
; $D067: Phase1AiSideRefresh
; Phase-1 helper called from Phase1CycleInit ($A17F) and Phase1RoundPass
; ($A29D). Refreshes the AI side state for the battle round:
; 1. AiBattleOrderAssign ($D0CB) assigns the four order slots
;    $0550-$0553 / $0554-$0557 of every AI-controlled side (control mode
;    $0562/$0563 == 3; human sides get their orders from the phase 3
;    command menu), skipped while the side is already withdrawing (slot
;    0 == 1). The per-side resolver (@OrderResolve) picks a 4-byte order
;    vector from AiOrderVectorWindow, indexed through AiOrderIndexTable by
;    commander army affinity (officer record [$B] bits 2-3) * 8 + battle
;    phase $0544, shifted by +4 once the round-pass counter $057A >= 4;
;    siege battles ($0544 == 5) use fixed Hold/Advance patterns. Slot
;    values: 0 = Advance, 1 = Withdraw, 2 = Hold, 3 = Surround, 4 = Tactic,
;    $80 = coin flip between Advance and Hold (rerolled in
;    Phase1NextActorSelect).
; 2. From round pass 4 on, each AI side runs AiCommanderRoutCheck ($D1D8,
;    roster base Y = 0 / $0B): when the commander troop count $05AC+Y drops
;    below the game-level ($6F02) threshold @TroopThreshold, two or more
;    enemy units are adjacent to the commander (Phase2StepTileProbe on the
;    neighbouring tiles), record field [3] != 100 and a
;    B1F_RandomBelowThreshold(100) roll lands below @RollThreshold[level],
;    the check drops its own return address (2x PLA) and forces the phase 4
;    battle result (phase/sub <- 4/0, retreat strip $0514-$0517, UI mode 4).
; 3. The roster-scan cursor column $0545 is cleared.
; 4. From round pass 4 on, each AI side runs AiArmyRoutCheck ($D2D4): when
;    the side is not already withdrawing and BattleOutnumberedCheck reports
;    its non-commander troop total below 200 while outnumbered by 145+, a
;    0-99 roll below @RoutRollThreshold[level] drops the whole call chain
;    (4x PLA, up to Phase1RoundPass) and orders all four slots to Withdraw
;    (slot <- 1).
;===============================================================================
.proc Phase1AiSideRefresh
  JSR AiBattleOrderAssign               ; $D067: 20 CB D0
  LDA btl_round_pass                               ; $D06A: AD 7A 05
  CMP #$04                                ; $D06D: C9 04
  BCC @CursorReset                                               ; $D06F: 90 18
  LDA btl_input_mode_a                               ; $D071: AD 62 05
  CMP #$03                                ; $D074: C9 03
  BNE @CommanderRoutSideB                                               ; $D076: D0 05
  LDY #$00                                ; $D078: A0 00
  JSR AiCommanderRoutCheck              ; $D07A: 20 D8 D1 ; side A commander rout check
@CommanderRoutSideB:
  LDA btl_input_mode_b                               ; $D07D: AD 63 05
  CMP #$03                                ; $D080: C9 03
  BNE @CursorReset                                               ; $D082: D0 05
  LDY #$0B                                ; $D084: A0 0B
  JSR AiCommanderRoutCheck              ; $D086: 20 D8 D1 ; side B commander rout check
@CursorReset:
  LDA #$00                                ; $D089: A9 00
  STA btl_scan_col                             ; $D08B: 8D 45 05 ; scan cursor column <- 0
  LDA btl_round_pass                             ; $D08E: AD 7A 05 ; round-pass counter
  CMP #$04                                ; $D091: C9 04
  BCC @Done                                               ; $D093: 90 18
  LDA btl_input_mode_a                               ; $D095: AD 62 05
  CMP #$03                                ; $D098: C9 03
  BNE @ArmyRoutSideB                                               ; $D09A: D0 05
  LDY #$00                                ; $D09C: A0 00
  JSR AiArmyRoutCheck                   ; $D09E: 20 D4 D2 ; side A army rout check
@ArmyRoutSideB:
  LDA btl_input_mode_b                               ; $D0A1: AD 63 05
  CMP #$03                                ; $D0A4: C9 03
  BNE @Done                                               ; $D0A6: D0 05
  LDY #$0B                                ; $D0A8: A0 0B
  JSR AiArmyRoutCheck                   ; $D0AA: 20 D4 D2 ; side B army rout check
@Done:
  RTS                                     ; $D0AD: 60
.endproc
;===============================================================================
; $D0AE: AiTacticSpendDispatch
; Per-round-pass AI tactic-point spend dispatch, called from Phase1RoundPass
; ($A29A) after the side status counters are ticked down. Runs
; AiTacticPointSpend for every AI-controlled side (control mode $0562/$0563
; == 3) with X = side index (0/1 -> $057C/$0549) and Y = roster base
; (0 / $0B -> $0545). At most one tactic purchase per side per pass: a
; successful purchase inside AiTacticPointSpend pops the dispatch return as
; well.
;===============================================================================
.proc AiTacticSpendDispatch
  LDA btl_input_mode_a                               ; $D0AE: AD 62 05 ; side A control mode
  CMP #$03                                ; $D0B1: C9 03
  BNE @SideB                              ; $D0B3: D0 07 ; not AI
  LDX #$00                                ; $D0B5: A2 00 ; side index
  LDY #$00                                ; $D0B7: A0 00 ; roster base (slot 0)
  JSR AiTacticPointSpend                  ; $D0B9: 20 C7 D3
@SideB:
  LDA btl_input_mode_b                               ; $D0BC: AD 63 05 ; side B control mode
  CMP #$03                                ; $D0BF: C9 03
  BNE @Done                               ; $D0C1: D0 07 ; not AI
  LDX #$01                                ; $D0C3: A2 01 ; side index
  LDY #$0B                                ; $D0C5: A0 0B ; roster base (slot $B)
  JSR AiTacticPointSpend                  ; $D0C7: 20 C7 D3
@Done:
  RTS                                     ; $D0CA: 60
.endproc
;===============================================================================
; $D0CB: AiBattleOrderAssign
; Assigns the four battle order slots $0550-$0553 (side A) / $0554-$0557
; (side B) of every AI-controlled side (control mode $0562/$0563 == 3),
; skipped while the side is already withdrawing (first slot == 1). Called
; from Phase1AiSideRefresh. Per side, the resolver @OrderResolve loads the
; commander officer record (B1F_GetOfficerRecordAddr) and indexes
; AiOrderIndexTable by army affinity (record [$B] bits 2-3) * 8 + battle
; phase $0544; the resulting offset selects a 4-byte order vector in
; AiOrderVectorWindow (offset + 4 once the round-pass counter $057A >= 4)
; copied into the side's slots. Siege battles ($0544 == 5) take fixed
; patterns (@SiegeOrders): side A Hold + 3x Advance (all Advance from pass
; 4), side B all Hold (slot 1 Advance from pass 6), then slot 2 of side B
; flips to Advance when no side-A unit column has crossed the midpoint
; (< $08). Slot values: 0 = Advance, 1 = Withdraw, 2 = Hold, 3 = Surround,
; 4 = Tactic, $80 = coin flip Advance/Hold.
;===============================================================================
.proc AiBattleOrderAssign
; zero-page work cells (proc-local):
commander_id   = $000C  ; commander officer id
slot_base_ofs  = $000A  ; order slot base offset
side_index     = $000B  ; side index (0/1)
rec_ptr        = $0000  ; officer record ptr (field $B)
window_ofs     = $000D  ; order vector window offset
  LDA btl_input_mode_a                               ; $D0CB: AD 62 05 ; side A control mode
  CMP #$03                                ; $D0CE: C9 03
  BNE @SideB                              ; $D0D0: D0 14 ; not AI
  LDA btl_order_slots_a                               ; $D0D2: AD 50 05 ; side A slot 0
  CMP #$01                                ; $D0D5: C9 01
  BEQ @SideB                              ; $D0D7: F0 0D ; already withdrawing
  LDA btl_strip_buf_a                               ; $D0D9: AD 60 05 ; side A commander id
  STA a:commander_id                             ; $D0DC: 8D 0C 00
  LDA #$00                                ; $D0DF: A9 00 ; slot base offset
  LDX #$00                                ; $D0E1: A2 00 ; side index
  JSR @OrderResolve                       ; $D0E3: 20 02 D1
@SideB:
  LDA btl_input_mode_b                               ; $D0E6: AD 63 05 ; side B control mode
  CMP #$03                                ; $D0E9: C9 03
  BNE @Done                               ; $D0EB: D0 14 ; not AI
  LDA btl_order_slots_b                               ; $D0ED: AD 54 05 ; side B slot 0
  CMP #$01                                ; $D0F0: C9 01
  BEQ @Done                               ; $D0F2: F0 0D ; already withdrawing
  LDA btl_strip_buf_b                               ; $D0F4: AD 61 05 ; side B commander id
  STA a:commander_id                             ; $D0F7: 8D 0C 00
  LDA #$04                                ; $D0FA: A9 04 ; slot base offset
  LDX #$01                                ; $D0FC: A2 01 ; side index
  JSR @OrderResolve                       ; $D0FE: 20 02 D1
@Done:
  RTS                                     ; $D101: 60
@OrderResolve:
  STA a:slot_base_ofs                             ; $D102: 8D 0A 00 ; slot base offset
  STX a:side_index                             ; $D105: 8E 0B 00 ; side index
  LDA a:commander_id                             ; $D108: AD 0C 00 ; commander id
  JSR B1F_GetOfficerRecordAddr            ; $D10B: 20 D7 F2
  LDY #$0B                                ; $D10E: A0 0B
  LDA (rec_ptr),Y                             ; $D110: B1 00 ; record [$B]
  LSR                                     ; $D112: 4A
  LSR                                     ; $D113: 4A
  AND #$03                                ; $D114: 29 03 ; army affinity (bits 2-3)
  ASL                                     ; $D116: 0A
  ASL                                     ; $D117: 0A
  ASL                                     ; $D118: 0A ; * 8
  CLC                                     ; $D119: 18
  ADC battle_phase                               ; $D11A: 6D 44 05 ; + battle phase
  TAY                                     ; $D11D: A8
  LDA AiOrderIndexTable,Y                 ; $D11E: B9 B0 D1
  STA a:window_ofs                             ; $D121: 8D 0D 00 ; window offset
  LDA btl_round_pass                               ; $D124: AD 7A 05 ; round-pass counter
  CMP #$04                                ; $D127: C9 04
  BCC @WindowLookup                       ; $D129: 90 09
  LDA a:window_ofs                             ; $D12B: AD 0D 00
  CLC                                     ; $D12E: 18
  ADC #$04                                ; $D12F: 69 04 ; late-pass window shift
  STA a:window_ofs                             ; $D131: 8D 0D 00
@WindowLookup:
  LDX a:window_ofs                             ; $D134: AE 0D 00 ; window offset
  LDY a:slot_base_ofs                             ; $D137: AC 0A 00 ; slot base offset
  LDA battle_phase                               ; $D13A: AD 44 05 ; battle phase
  CMP #$05                                ; $D13D: C9 05
  BEQ @SiegeOrders                        ; $D13F: F0 19
  LDA AiOrderVectorWindow,X               ; $D141: BD C8 D1
  STA btl_order_slots_a,Y                             ; $D144: 99 50 05 ; slot 0
  LDA AiOrderVectorWindow+1,X             ; $D147: BD C9 D1
  STA btl_order_slots_a+1,Y                             ; $D14A: 99 51 05 ; slot 1
  LDA AiOrderVectorWindow+2,X             ; $D14D: BD CA D1
  STA btl_order_slots_a+2,Y                             ; $D150: 99 52 05 ; slot 2
  LDA AiOrderVectorWindow+3,X             ; $D153: BD CB D1
  STA btl_order_slots_a+3,Y                             ; $D156: 99 53 05 ; slot 3
  RTS                                     ; $D159: 60
@SiegeOrders:
  CPY #$04                                ; $D15A: C0 04
  BCS @SiegeSideB                         ; $D15C: B0 1D
  LDA #$02                                ; $D15E: A9 02 ; Hold
  STA btl_order_slots_a,Y                             ; $D160: 99 50 05 ; slot 0
  LDA #$00                                ; $D163: A9 00 ; Advance
  STA btl_order_slots_a+1,Y                             ; $D165: 99 51 05 ; slot 1
  STA btl_order_slots_a+2,Y                             ; $D168: 99 52 05 ; slot 2
  STA btl_order_slots_a+3,Y                             ; $D16B: 99 53 05 ; slot 3
  LDA btl_round_pass                               ; $D16E: AD 7A 05 ; round-pass counter
  CMP #$04                                ; $D171: C9 04
  BCC @SideADone                          ; $D173: 90 05
  LDA #$00                                ; $D175: A9 00 ; Advance
  STA btl_order_slots_a,Y                             ; $D177: 99 50 05 ; slot 0 from pass 4
@SideADone:
  RTS                                     ; $D17A: 60
@SiegeSideB:
  LDA #$02                                ; $D17B: A9 02 ; Hold
  STA btl_order_slots_a,Y                             ; $D17D: 99 50 05 ; slot 0
  STA btl_order_slots_a+1,Y                             ; $D180: 99 51 05 ; slot 1
  STA btl_order_slots_a+2,Y                             ; $D183: 99 52 05 ; slot 2
  STA btl_order_slots_a+3,Y                             ; $D186: 99 53 05 ; slot 3
  LDA btl_round_pass                               ; $D189: AD 7A 05 ; round-pass counter
  CMP #$06                                ; $D18C: C9 06
  BCC @MidpointCheck                      ; $D18E: 90 05
  LDA #$00                                ; $D190: A9 00 ; Advance
  STA btl_order_slots_a+1,Y                             ; $D192: 99 51 05 ; slot 1 from pass 6
@MidpointCheck:
  LDY #$01                                ; $D195: A0 01 ; side A slot 1
  LDX #$00                                ; $D197: A2 00 ; crossed count
@MidpointLoop:
  LDA btl_unit_col_a,Y                             ; $D199: B9 80 05 ; unit column
  CMP #$08                                ; $D19C: C9 08
  BCS @MidpointNext                       ; $D19E: B0 01 ; still own half
  INX                                     ; $D1A0: E8 ; crossed midpoint
@MidpointNext:
  INY                                     ; $D1A1: C8
  CPY #$0B                                ; $D1A2: C0 0B
  BCC @MidpointLoop                       ; $D1A4: 90 F3
  CPX #$00                                ; $D1A6: E0 00
  BNE @Exit                               ; $D1A8: D0 05 ; some unit crossed
  LDA #$00                                ; $D1AA: A9 00 ; Advance
  STA btl_order_slots_b+2                               ; $D1AC: 8D 56 05 ; side B slot 2
@Exit:
  RTS                                     ; $D1AF: 60
; --- Data Region ---
AiOrderIndexTable:
; Order window offset per army affinity (4) x battle phase entry (8),
; relative to AiOrderVectorWindow. The $80 sentinel is unhandled in the
; original: @OrderResolve indexes the window with it and reads code bytes
; at $D248 as order values (behaves like Advance).
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00; $D1B0: 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00
  .byte $00,$00,$00,$08,$00,$00,$00,$00   ; $D1C0: 00 00 00 08 00 00 00 00
AiOrderVectorWindow:
; 4-byte order vectors at offsets 0/2/8 into this window (the table tail at
; $D1C8 doubles as vector data): [Hold,Coin,Coin,Advance],
; [Coin,Coin,Advance,Coin], [Hold,Advance,Advance,Advance].
  .byte $02,$80,$80,$00,$80,$00,$00,$00   ; $D1C8: 02 80 80 00 80 00 00 00
  .byte $02,$00,$00,$00,$80,$00,$00,$00   ; $D1D0: 02 00 00 00 80 00 00 00
.endproc
;===============================================================================
; $D1D8: AiCommanderRoutCheck
; Commander rout check for one AI side, called from Phase1AiSideRefresh
; (round pass >= 4) with Y = roster base (0 = side A, $0B = side B). When
; the commander troop count $05AC,Y falls below @RoutThresholds[$6F02]
; (45/40/30 by game level), probes the four orthogonal neighbours of the
; commander via Phase2StepTileProbe and counts adjacent enemy units in
; $0548. With 2+ adjacent enemies, the commander officer record field [3]
; != 100 and a B1F_RandomBelowThreshold(100) roll below
; @RoutThresholds+3[$6F02] (55/50/30), the commander routs: drops its own
; and Phase1AiSideRefresh's return addresses (2x PLA, resuming
; Phase1RoundPass at $A2A0), runs B1F_BankPpuInit + SFX $6C and forces the
; phase 4 battle result (phase/sub <- 4/0, retreat strip $0514-$0517 with
; mode 3, UI mode 4 via B1F_SetUI4 $7D). Original asymmetry: side A writes
; its own commander $0560 into $042C/$0514 and the enemy $0561 into $0516,
; while side B writes its own commander $0561 into both slots.
;===============================================================================
.proc AiCommanderRoutCheck
; zero-page work cells (proc-local):
probe_col_delta = $0000  ; tile probe column delta
probe_row_delta = $0001  ; tile probe row delta
rec_ptr        = $0000  ; commander record ptr (field [3] loyalty)
  STY btl_scan_col                               ; $D1D8: 8C 45 05 ; roster base (0 / $B)
  LDA btl_troops_a,Y                             ; $D1DB: B9 AC 05 ; commander troop count
  LDY $6F02                               ; $D1DE: AC 02 6F ; game level
  CMP @RoutThresholds,Y                   ; $D1E1: D9 E7 D1
  BCC @AdjacentScan                       ; $D1E4: 90 07
  RTS                                     ; $D1E6: 60 ; troops still safe
@RoutThresholds:
; $D1E7: troop threshold per game level (45/40/30); $D1EA: rout roll
; threshold per game level (55/50/30).
  .byte $2D,$28,$1E,$37,$32,$1E           ; $D1E7: 2D 28 1E 37 32 1E
@AdjacentScan:
  LDA #$00                                ; $D1ED: A9 00
  STA btl_frame_counter                               ; $D1EF: 8D 48 05 ; adjacent-enemy count <- 0
  LDA #$01                                ; $D1F2: A9 01
  STA a:probe_col_delta                             ; $D1F4: 8D 00 00 ; column delta +1
  LDA #$00                                ; $D1F7: A9 00
  STA a:probe_row_delta                             ; $D1F9: 8D 01 00 ; row delta 0
  JSR Phase2StepTileProbe                 ; $D1FC: 20 CD C1 ; right neighbour
  BCS @ProbeLeft                          ; $D1FF: B0 06 ; empty tile
  TAY                                     ; $D201: A8
  BEQ @ProbeLeft                          ; $D202: F0 03 ; same side / blocked
  INC btl_frame_counter                               ; $D204: EE 48 05 ; enemy adjacent
@ProbeLeft:
  LDA #$FF                                ; $D207: A9 FF
  STA a:probe_col_delta                             ; $D209: 8D 00 00 ; column delta -1
  LDA #$00                                ; $D20C: A9 00
  STA a:probe_row_delta                             ; $D20E: 8D 01 00 ; row delta 0
  JSR Phase2StepTileProbe                 ; $D211: 20 CD C1 ; left neighbour
  BCS @ProbeUp                            ; $D214: B0 06 ; empty tile
  TAY                                     ; $D216: A8
  BEQ @ProbeUp                            ; $D217: F0 03 ; same side / blocked
  INC btl_frame_counter                               ; $D219: EE 48 05 ; enemy adjacent
@ProbeUp:
  LDA #$00                                ; $D21C: A9 00
  STA a:probe_col_delta                             ; $D21E: 8D 00 00 ; column delta 0
  LDA #$FF                                ; $D221: A9 FF
  STA a:probe_row_delta                             ; $D223: 8D 01 00 ; row delta -1
  JSR Phase2StepTileProbe                 ; $D226: 20 CD C1 ; upper neighbour
  BCS @ProbeDown                          ; $D229: B0 06 ; empty tile
  TAY                                     ; $D22B: A8
  BEQ @ProbeDown                          ; $D22C: F0 03 ; same side / blocked
  INC btl_frame_counter                               ; $D22E: EE 48 05 ; enemy adjacent
@ProbeDown:
  LDA #$00                                ; $D231: A9 00
  STA a:probe_col_delta                             ; $D233: 8D 00 00 ; column delta 0
  LDA #$01                                ; $D236: A9 01
  STA a:probe_row_delta                             ; $D238: 8D 01 00 ; row delta +1
  JSR Phase2StepTileProbe                 ; $D23B: 20 CD C1 ; lower neighbour
  BCS @CountGate                          ; $D23E: B0 06 ; empty tile
  TAY                                     ; $D240: A8
  BEQ @CountGate                          ; $D241: F0 03 ; same side / blocked
  INC btl_frame_counter                               ; $D243: EE 48 05 ; enemy adjacent
@CountGate:
  LDA btl_frame_counter                               ; $D246: AD 48 05 ; adjacent-enemy count
  CMP #$02                                ; $D249: C9 02
  BCS @LoyaltyGate                        ; $D24B: B0 01
@NoRout:
  RTS                                     ; $D24D: 60
@LoyaltyGate:
  LDA btl_strip_buf_a                               ; $D24E: AD 60 05 ; side A commander id
  LDY btl_scan_col                               ; $D251: AC 45 05 ; roster base
  CPY #$0B                                ; $D254: C0 0B
  BCC @RecordLookup                       ; $D256: 90 03
  LDA btl_strip_buf_b                               ; $D258: AD 61 05 ; side B: own commander
@RecordLookup:
  JSR B1F_GetOfficerRecordAddr            ; $D25B: 20 D7 F2
  LDY #$03                                ; $D25E: A0 03
  LDA (rec_ptr),Y                             ; $D260: B1 00 ; record field [3]
  CMP #$64                                ; $D262: C9 64
  BEQ @NoRout                             ; $D264: F0 E7 ; 100: never routs
  LDA #$64                                ; $D266: A9 64
  JSR B1F_RandomBelowThreshold            ; $D268: 20 62 E8 ; roll [0,100)
  LDY $6F02                               ; $D26B: AC 02 6F ; game level
  CMP @RoutThresholds+3,Y                 ; $D26E: D9 EA D1 ; rout roll thresholds
  BCS @NoRout                             ; $D271: B0 DA ; roll failed
  PLA                                     ; $D273: 68 ; drop own return
  PLA                                     ; $D274: 68 ; drop Phase1AiSideRefresh return
  JSR B1F_BankPpuInit                     ; $D275: 20 7F E5
  LDA #$6C                                ; $D278: A9 6C
  JSR B1F_SoundWrapperC                   ; $D27A: 20 83 E6 ; SFX $6C
  LDA btl_scan_col                               ; $D27D: AD 45 05 ; roster base
  BNE @StripSideB                         ; $D280: D0 29
  LDA btl_strip_buf_a                               ; $D282: AD 60 05 ; side A commander
  STA btl_panel_params                               ; $D285: 8D 2C 04 ; panel param
  STA btl_strip_sel_a                               ; $D288: 8D 14 05 ; strip slot 0
  LDA #$03                                ; $D28B: A9 03
  STA btl_strip_flag_a                               ; $D28D: 8D 15 05 ; strip mode 3
  LDA btl_strip_buf_b                               ; $D290: AD 61 05 ; enemy commander
  STA btl_strip_sel_b                               ; $D293: 8D 16 05 ; strip slot 1
  LDA #$00                                ; $D296: A9 00
  STA btl_strip_flag_b                               ; $D298: 8D 17 05
  LDA #$04                                ; $D29B: A9 04
  STA btl_overlay_phase                               ; $D29D: 8D 40 05 ; phase <- 4 (result)
  LDA #$00                                ; $D2A0: A9 00
  STA btl_overlay_sub                               ; $D2A2: 8D 41 05 ; sub-phase <- 0
  LDA #$7D                                ; $D2A5: A9 7D
  JSR B1F_SetUI4                          ; $D2A7: 20 8B F2 ; UI mode 4
  RTS                                     ; $D2AA: 60
@StripSideB:
  LDA btl_strip_buf_b                               ; $D2AB: AD 61 05 ; side B commander
  STA btl_panel_params                               ; $D2AE: 8D 2C 04 ; panel param
  STA btl_strip_sel_a                               ; $D2B1: 8D 14 05 ; strip slot 0
  LDA #$03                                ; $D2B4: A9 03
  STA btl_strip_flag_a                               ; $D2B6: 8D 15 05 ; strip mode 3
  LDA btl_strip_buf_b                               ; $D2B9: AD 61 05 ; own commander again (ROM asymmetry)
  STA btl_strip_sel_b                               ; $D2BC: 8D 16 05 ; strip slot 1
  LDA #$00                                ; $D2BF: A9 00
  STA btl_strip_flag_b                               ; $D2C1: 8D 17 05
  LDA #$04                                ; $D2C4: A9 04
  STA btl_overlay_phase                               ; $D2C6: 8D 40 05 ; phase <- 4 (result)
  LDA #$00                                ; $D2C9: A9 00
  STA btl_overlay_sub                               ; $D2CB: 8D 41 05 ; sub-phase <- 0
  LDA #$7D                                ; $D2CE: A9 7D
  JSR B1F_SetUI4                          ; $D2D0: 20 8B F2 ; UI mode 4
  RTS                                     ; $D2D3: 60
.endproc
;===============================================================================
; $D2D4: AiArmyRoutCheck
; Whole-army rout check for one AI side, called from Phase1AiSideRefresh
; (round pass >= 4) with Y = roster base (0 = side A, $0B = side B). Skips
; sides already withdrawing (first order slot == 1). When
; BattleOutnumberedCheck reports the side's non-commander troop total
; below 200 while the enemy outnumbers it by 145+, a
; B1F_RandomBelowThreshold(100) roll below @RoutRollThreshold[$6F02]
; (30/40/45 by game level) routs the whole army: four PLAs drop the entire
; call chain up to Phase1RoundPass's caller (the rest of the frame is
; skipped) and all four of the side's order slots ($0550-$0553 or
; $0554-$0557) are set to Withdraw (1).
;===============================================================================
.proc AiArmyRoutCheck
  STY btl_scan_col                               ; $D2D4: 8C 45 05 ; roster base (0 / $B)
  LDA btl_scan_col                               ; $D2D7: AD 45 05
  BNE @SideB                              ; $D2DA: D0 09
  LDA btl_order_slots_a                               ; $D2DC: AD 50 05 ; side A slot 0
  CMP #$01                                ; $D2DF: C9 01
  BNE @OutnumberGate                      ; $D2E1: D0 0A
  BEQ @Done                               ; $D2E3: F0 07 ; ROM artifact: mirror branch
@SideB:
  LDA btl_order_slots_b                               ; $D2E5: AD 54 05 ; side B slot 0
  CMP #$01                                ; $D2E8: C9 01
  BNE @OutnumberGate                      ; $D2EA: D0 01
@Done:
  RTS                                     ; $D2EC: 60 ; already withdrawing
@OutnumberGate:
  JSR BattleOutnumberedCheck              ; $D2ED: 20 2A D3
  TYA                                     ; $D2F0: 98
  BNE @NoRout                             ; $D2F1: D0 24 ; not collapsing
  LDA #$64                                ; $D2F3: A9 64
  JSR B1F_RandomBelowThreshold            ; $D2F5: 20 62 E8 ; roll [0,100)
  LDY $6F02                               ; $D2F8: AC 02 6F ; game level
  CMP @RoutRollThreshold,Y                ; $D2FB: D9 27 D3
  BCS @NoRout                             ; $D2FE: B0 17 ; roll failed
  PLA                                     ; $D300: 68 ; drop this check's return
  PLA                                     ; $D301: 68 ; drop AiArmyRoutCheck... chain
  PLA                                     ; $D302: 68
  PLA                                     ; $D303: 68 ; ...up to Phase1RoundPass's caller
  LDA btl_scan_col                               ; $D304: AD 45 05 ; roster base
  BNE @SideBWithdraw                      ; $D307: D0 0F
  LDA #$01                                ; $D309: A9 01 ; Withdraw
  STA btl_order_slots_a                               ; $D30B: 8D 50 05 ; slot 0
  STA btl_order_slots_a+1                               ; $D30E: 8D 51 05 ; slot 1
  STA btl_order_slots_a+2                               ; $D311: 8D 52 05 ; slot 2
  STA btl_order_slots_a+3                               ; $D314: 8D 53 05 ; slot 3
@NoRout:
  RTS                                     ; $D317: 60
@SideBWithdraw:
  LDA #$01                                ; $D318: A9 01 ; Withdraw
  STA btl_order_slots_b                               ; $D31A: 8D 54 05 ; slot 0
  STA btl_order_slots_b+1                               ; $D31D: 8D 55 05 ; slot 1
  STA btl_order_slots_b+2                               ; $D320: 8D 56 05 ; slot 2
  STA btl_order_slots_b+3                               ; $D323: 8D 57 05 ; slot 3
  RTS                                     ; $D326: 60
@RoutRollThreshold:
; Rout roll threshold per game level (30/40/45).
  .byte $1E,$28,$2D                       ; $D327: 1E 28 2D
.endproc
;===============================================================================
; $D32A: BattleOutnumberedCheck
; Side strength comparison shared by AiArmyRoutCheck and the
; AiTacticPointSpend rout-pressure purchase. Totals the active
; non-commander troop counts of both sides: side A from slots 1-$A
; ($0581 column / $05AD troop count), side B from slots $B-$14 ($058C /
; $05B8); slots with bit 7 set in the column byte ($FF = empty roster
; slot) are skipped. When $0545 is non-zero (side B context) the totals
; are swapped so ($0000/$0001) holds the acting side's total and
; ($0002/$0003) the enemy's. Returns Y = 0 when the acting side's total
; is below 200 ($C8) and the enemy total exceeds it by at least 145
; (own + $90 still below enemy), otherwise Y = $FF.
;===============================================================================
.proc BattleOutnumberedCheck
; zero-page work cells (proc-local):
total_a_lo     = $0000  ; side A troop total lo (swapped to own/enemy)
total_a_hi     = $0001  ; side A troop total hi
total_b_lo     = $0002  ; side B troop total lo
total_b_hi     = $0003  ; side B troop total hi
  LDY #$00                                ; $D32A: A0 00
  LDX #$00                                ; $D32C: A2 00
  STX a:total_a_lo                             ; $D32E: 8E 00 00 ; side A total lo <- 0
  STX a:total_a_hi                             ; $D331: 8E 01 00 ; side A total hi <- 0
@SideALoop:
  LDA $0581,Y                             ; $D334: B9 81 05 ; slot column (empty = $FF)
  BMI @SideANext                          ; $D337: 30 12 ; inactive slot
  LDA $05AD,Y                             ; $D339: B9 AD 05 ; column troop count
  CLC                                     ; $D33C: 18
  ADC a:total_a_lo                             ; $D33D: 6D 00 00
  STA a:total_a_lo                             ; $D340: 8D 00 00
  LDA a:total_a_hi                             ; $D343: AD 01 00
  ADC #$00                                ; $D346: 69 00 ; carry
  STA a:total_a_hi                             ; $D348: 8D 01 00
@SideANext:
  INY                                     ; $D34B: C8
  INX                                     ; $D34C: E8
  CPX #$0A                                ; $D34D: E0 0A ; slots 1-$A
  BCC @SideALoop                          ; $D34F: 90 E3
  LDY #$00                                ; $D351: A0 00
  LDX #$00                                ; $D353: A2 00
  STX a:total_b_lo                             ; $D355: 8E 02 00 ; side B total lo <- 0
  STX a:total_b_hi                             ; $D358: 8E 03 00 ; side B total hi <- 0
@SideBLoop:
  LDA $058C,Y                             ; $D35B: B9 8C 05 ; slot column (empty = $FF)
  BMI @SideBNext                          ; $D35E: 30 12 ; inactive slot
  LDA $05B8,Y                             ; $D360: B9 B8 05 ; column troop count
  CLC                                     ; $D363: 18
  ADC a:total_b_lo                             ; $D364: 6D 02 00
  STA a:total_b_lo                             ; $D367: 8D 02 00
  LDA a:total_b_hi                             ; $D36A: AD 03 00
  ADC #$00                                ; $D36D: 69 00 ; carry
  STA a:total_b_hi                             ; $D36F: 8D 03 00
@SideBNext:
  INY                                     ; $D372: C8
  INX                                     ; $D373: E8
  CPX #$0A                                ; $D374: E0 0A ; slots $B-$14
  BCC @SideBLoop                          ; $D376: 90 E3
  LDA btl_scan_col                               ; $D378: AD 45 05 ; acting-side context
  BEQ @CollapseCheck                      ; $D37B: F0 18 ; side A: keep order
  LDX a:total_a_lo                             ; $D37D: AE 00 00
  LDY a:total_a_hi                             ; $D380: AC 01 00
  LDA a:total_b_lo                             ; $D383: AD 02 00
  STA a:total_a_lo                             ; $D386: 8D 00 00 ; own <- side B
  LDA a:total_b_hi                             ; $D389: AD 03 00
  STA a:total_a_hi                             ; $D38C: 8D 01 00
  STX a:total_b_lo                             ; $D38F: 8E 02 00 ; enemy <- side A
  STY a:total_b_hi                             ; $D392: 8C 03 00
@CollapseCheck:
  LDA a:total_a_hi                             ; $D395: AD 01 00 ; own total hi
  BNE @Safe                               ; $D398: D0 2A ; >= 256 troops
  LDA a:total_a_lo                             ; $D39A: AD 00 00 ; own total lo
  CMP #$C8                                ; $D39D: C9 C8
  BCS @Safe                               ; $D39F: B0 23 ; >= 200 troops
  LDA a:total_a_lo                             ; $D3A1: AD 00 00
  CLC                                     ; $D3A4: 18
  ADC #$90                                ; $D3A5: 69 90 ; own + 144
  STA a:total_a_lo                             ; $D3A7: 8D 00 00
  LDA a:total_a_hi                             ; $D3AA: AD 01 00
  ADC #$01                                ; $D3AD: 69 01
  STA a:total_a_hi                             ; $D3AF: 8D 01 00
  LDA a:total_a_lo                             ; $D3B2: AD 00 00
  SEC                                     ; $D3B5: 38
  SBC a:total_b_lo                             ; $D3B6: ED 02 00 ; - enemy lo
  LDA a:total_a_hi                             ; $D3B9: AD 01 00
  SBC a:total_b_hi                             ; $D3BC: ED 03 00 ; - enemy hi
  BCS @Safe                               ; $D3BF: B0 03 ; enemy not 145+ ahead
  LDY #$00                                ; $D3C1: A0 00 ; collapsing
  RTS                                     ; $D3C3: 60
@Safe:
  LDY #$FF                                ; $D3C4: A0 FF ; not collapsing
  RTS                                     ; $D3C6: 60
.endproc
;===============================================================================
; $D3C7: AiTacticPointSpend
; AI-side tactic point spend, run by AiTacticSpendDispatch for every
; AI-controlled side after each round pass (the AI counterpart of the
; phase-8 point-spend panel). Inputs: X = side index (0/1, stored in
; $057C and mirrored to the acting side $0549), Y = roster base
; (0 / $0B, stored in $0545).
; Gate: the side's packed status counters $0574-$0577 are OR-combined and
; the side's own nibble (low for side A, high for side B) must be zero -
; no purchase while a timed tactic effect is still running. The side's
; tactic point budget $0572[$057C] is then mirrored to $0548 and walked
; down the purchase ladder, most expensive first; costs match the
; phase-8 panel row costs (@RowCostTable: 3/5/7/8/$A/$C). A successful
; purchase deducts its cost from the budget and pops both its own return
; and the ladder's return (2x PLA), ending the side's spend for this
; pass:
;   cost $0C @AdvancePurchase: formation advance (phase 9 sub 0, UI $F1),
;     gated on enemies crowding the commander's facing probe zone;
;   cost $0A @Counter577Purchase: status counter $0577 <- 3
;     (Phase8RowCounter577Apply), gated on enemies near the side's
;     class-2 units;
;   cost $08 @Counter576Purchase: status counter $0576 <- 4 plus periodic
;     reload advance (Phase8RowCounter576Apply), flat 20% roll;
;   cost $07 @Counter575Purchase: status counter $0575 <- 3
;     (Phase8RowCounter575Apply), odds scale with the class-2 unit count;
;   cost $05 @StatEdgePurchase: phase $A sub 4 (battle event wrapper),
;     gated on own attack bonus and commander troops both >= the enemy's;
;   cost $03 @CoinFlipPurchase: phase $A sub 0 (battle event wrapper,
;     grants counter $0574 <- 4), gated on the enemy army collapsing
;     (BattleOutnumberedCheck), a 50% roll and a coin flip.
; The purchases reuse the Phase8 row effects without their panel UI.
; The manual's battle tactics list (docs/manual_kb/06-reference-tables.md:
; Chouhatsu/Jubaku/Do/Shiki Koujou/Hiya/Bakuen at 3/3?/6?/8?/10/12 points)
; is the likely in-game correspondence of the six rows; panel text is not
; decoded yet, so the naming here stays with the code-level effects.
;===============================================================================
.proc AiTacticPointSpend
; zero-page work cells (proc-local):
calc_work_a    = $000A  ; layout ptr / success chance / own attack bonus
calc_work_b    = $000B  ; layout ptr hi / enemy attack bonus
calc_work_c    = $000C  ; own commander troops work
calc_work_d    = $000D  ; enemy commander troops work
col_delta      = $0000  ; probe column delta
row_delta      = $0001  ; probe row delta
class2_count   = $0000  ; class-2 unit count
zone_count     = $0000  ; enemy-in-zone count
  STX btl_side_index                               ; $D3C7: 8E 7C 05 ; AI side index
  STX btl_acting_unit                               ; $D3CA: 8E 49 05 ; acting side (for row effects)
  STY btl_scan_col                               ; $D3CD: 8C 45 05 ; roster base (commander slot)
  LDA btl_status_ctr0                               ; $D3D0: AD 74 05 ; status counter 574
  ORA btl_status_ctr1                               ; $D3D3: 0D 75 05 ; OR all four counters
  ORA btl_status_ctr2                               ; $D3D6: 0D 76 05
  ORA btl_status_ctr3                               ; $D3D9: 0D 77 05
  LDX btl_point_budget_a                               ; $D3DC: AE 72 05 ; side A point budget
  CPY #$00                                ; $D3DF: C0 00 ; roster base 0 = side A
  BEQ @StoreBudget                        ; $D3E1: F0 07
  LSR                                     ; $D3E3: 4A ; side B: own nibble is the
  LSR                                     ; $D3E4: 4A ; high nibble of the OR-sum
  LSR                                     ; $D3E5: 4A
  LSR                                     ; $D3E6: 4A
  LDX btl_point_budget_b                               ; $D3E7: AE 73 05 ; side B point budget
@StoreBudget:
  STX btl_frame_counter                               ; $D3EA: 8E 48 05 ; budget mirror
  AND #$0F                                ; $D3ED: 29 0F ; own counter nibble
  BEQ @PurchaseLadder                     ; $D3EF: F0 01
  RTS                                     ; $D3F1: 60 ; tactic still active: skip
@PurchaseLadder:
  LDX btl_frame_counter                               ; $D3F2: AE 48 05 ; budget
  CPX #$0C                                ; $D3F5: E0 0C ; cost 12
  BCC @Counter577Check                    ; $D3F7: 90 03
  JSR @AdvancePurchase                    ; $D3F9: 20 2F D4
@Counter577Check:
  LDX btl_frame_counter                               ; $D3FC: AE 48 05
  CPX #$0A                                ; $D3FF: E0 0A ; cost 10
  BCC @Counter576Check                    ; $D401: 90 03
  JSR @Counter577Purchase                 ; $D403: 20 06 D5
@Counter576Check:
  LDX btl_frame_counter                               ; $D406: AE 48 05
  CPX #$08                                ; $D409: E0 08 ; cost 8
  BCC @Counter575Check                    ; $D40B: 90 03
  JSR @Counter576Purchase                 ; $D40D: 20 A0 D5
@Counter575Check:
  LDX btl_frame_counter                               ; $D410: AE 48 05
  CPX #$07                                ; $D413: E0 07 ; cost 7
  BCC @StatEdgeCheck                      ; $D415: 90 03
  JSR @Counter575Purchase                 ; $D417: 20 BC D5
@StatEdgeCheck:
  LDX btl_frame_counter                               ; $D41A: AE 48 05
  CPX #$05                                ; $D41D: E0 05 ; cost 5
  BCC @CoinFlipCheck                      ; $D41F: 90 03
  JSR @StatEdgePurchase                   ; $D421: 20 52 D6
@CoinFlipCheck:
  LDX btl_frame_counter                               ; $D424: AE 48 05
  CPX #$03                                ; $D427: E0 03 ; cost 3
  BCC @LadderDone                         ; $D429: 90 03
  JSR @CoinFlipPurchase                   ; $D42B: 20 12 D6
@LadderDone:
  RTS                                     ; $D42E: 60
;-------------------------------------------------------------------------------
; $D42F: @AdvancePurchase (cost $0C)
; Formation-advance purchase. Selects one of four 9-tile probe zones
; (@AdvanceZoneDown/Up/Left/Right) by the high nibble of the commander's
; roster code $05C2[$0545] - the side tag (3 = A, 2 = B) picks the zone
; facing the enemy half of the board, other values pick the vertical
; zones. Counts enemy-occupied tiles in the zone via Phase2StepTileProbe
; ($057E), then a B1F_RandomBelowThreshold(100) roll below
; @AdvanceSuccessChance[count] (0/0/40/70/100...) succeeds: pops the
; ladder return, sets phase/sub <- 9/0 (formation advance), UI $F1
; (B1F_SetUI0) and deducts 12 points.
;-------------------------------------------------------------------------------
@AdvancePurchase:
  LDY btl_scan_col                               ; $D42F: AC 45 05 ; roster base
  LDA btl_roster_code_a,Y                             ; $D432: B9 C2 05 ; commander roster code
  LSR                                     ; $D435: 4A
  LSR                                     ; $D436: 4A
  LSR                                     ; $D437: 4A
  LSR                                     ; $D438: 4A ; high nibble
  STA $057D                               ; $D439: 8D 7D 05 ; zone selector
  LDA #$00                                ; $D43C: A9 00
  STA $057E                               ; $D43E: 8D 7E 05 ; enemy count <- 0
@ZoneLoop:
  PHA                                     ; $D441: 48 ; tile index
  TAY                                     ; $D442: A8
  LDA $057D                               ; $D443: AD 7D 05 ; zone selector
  ASL                                     ; $D446: 0A ; * 2
  TAX                                     ; $D447: AA
  LDA @AdvanceZonePtrTable,X              ; $D448: BD AA D4 ; zone ptr lo
  STA a:calc_work_a                             ; $D44B: 8D 0A 00
  LDA @AdvanceZonePtrTable+1,X            ; $D44E: BD AB D4 ; ptr hi
  STA a:calc_work_b                             ; $D451: 8D 0B 00
  LDA (calc_work_a),Y                             ; $D454: B1 0A ; column delta
  STA a:col_delta                             ; $D456: 8D 00 00
  TYA                                     ; $D459: 98
  CLC                                     ; $D45A: 18
  ADC #$09                                ; $D45B: 69 09 ; row delta offset
  TAY                                     ; $D45D: A8
  LDA (calc_work_a),Y                             ; $D45E: B1 0A ; row delta
  STA a:row_delta                             ; $D460: 8D 01 00
  JSR Phase2StepTileProbe                 ; $D463: 20 CD C1 ; commander + delta
  BCS @ZoneNext                           ; $D466: B0 06 ; empty tile
  TAY                                     ; $D468: A8
  BEQ @ZoneNext                           ; $D469: F0 03 ; same side / blocked
  INC $057E                               ; $D46B: EE 7E 05 ; enemy in zone
@ZoneNext:
  PLA                                     ; $D46E: 68 ; tile index
  CLC                                     ; $D46F: 18
  ADC #$01                                ; $D470: 69 01
  CMP #$09                                ; $D472: C9 09 ; 9 zone tiles
  BCC @ZoneLoop                           ; $D474: 90 CB
  LDY $057E                               ; $D476: AC 7E 05 ; enemy count
  LDA @AdvanceSuccessChance,Y             ; $D479: B9 FA D4
  BEQ @ZoneMiss                           ; $D47C: F0 0D ; count < 2: never
  STA a:calc_work_a                             ; $D47E: 8D 0A 00 ; success chance
  LDA #$64                                ; $D481: A9 64
  JSR B1F_RandomBelowThreshold            ; $D483: 20 62 E8 ; roll [0,100)
  CMP a:calc_work_a                             ; $D486: CD 0A 00
  BCC @ZoneHit                            ; $D489: 90 01
@ZoneMiss:
  RTS                                     ; $D48B: 60 ; back to the ladder
@ZoneHit:
  PLA                                     ; $D48C: 68 ; drop own return
  PLA                                     ; $D48D: 68 ; drop ladder return
  LDA #$09                                ; $D48E: A9 09
  STA btl_overlay_phase                               ; $D490: 8D 40 05 ; phase <- 9 (formation advance)
  LDA #$00                                ; $D493: A9 00
  STA btl_overlay_sub                               ; $D495: 8D 41 05 ; sub-phase <- 0
  LDA #$F1                                ; $D498: A9 F1
  JSR B1F_SetUI0                          ; $D49A: 20 6D F2 ; UI $F1
  LDY btl_side_index                               ; $D49D: AC 7C 05 ; side index
  LDA btl_point_budget_a,Y                             ; $D4A0: B9 72 05 ; point budget
  SEC                                     ; $D4A3: 38
  SBC #$0C                                ; $D4A4: E9 0C ; cost 12
  STA btl_point_budget_a,Y                             ; $D4A6: 99 72 05 ; budget -= 12
  RTS                                     ; $D4A9: 60 ; back to AiTacticSpendDispatch
; --- Data Region ---
@AdvanceZonePtrTable:
; Probe zone pointers indexed by the zone selector (x2): zone 0 below the
; commander, zone 1 above, zone 2 left, zone 3 right.
  .word $D4B2,$D4C4                       ; $D4AA: B2 D4 C4 D4 ; zones 0/1
  .word $D4D6,$D4E8                       ; $D4AE: D6 D4 E8 D4 ; zones 2/3
@AdvanceZoneDown:
; Zone 0: 3x3 block below the commander (rows +1..+3, columns -1..+1).
  .byte $FF,$FF,$FF,$00,$00,$00,$01,$01,$01 ; $D4B2: FF FF FF 00 00 00 01 01 01 ; column deltas
  .byte $01,$02,$03,$01,$02,$03,$01,$02,$03 ; $D4BB: 01 02 03 01 02 03 01 02 03 ; row deltas
@AdvanceZoneUp:
; Zone 1: 3x3 block above the commander (rows -1..-3, columns -1..+1).
  .byte $FF,$FF,$FF,$00,$00,$00,$01,$01,$01 ; $D4C4: FF FF FF 00 00 00 01 01 01 ; column deltas
  .byte $FF,$FE,$FD,$FF,$FE,$FD,$FF,$FE,$FD ; $D4CD: FF FE FD FF FE FD FF FE FD ; row deltas
@AdvanceZoneLeft:
; Zone 2: block left of the commander (columns -1..-3, rows -1..+1).
  .byte $FF,$FF,$FF,$FE,$FE,$FE,$FD,$FD,$FD ; $D4D6: FF FF FF FE FE FE FD FD FD ; column deltas
  .byte $FF,$00,$01,$FF,$00,$01,$FF,$00,$01 ; $D4DF: FF 00 01 FF 00 01 FF 00 01 ; row deltas
@AdvanceZoneRight:
; Zone 3: block right of the commander (columns +1..+3, rows -1..+1).
  .byte $01,$01,$01,$02,$02,$02,$03,$03,$03 ; $D4E8: 01 01 01 02 02 02 03 03 03 ; column deltas
  .byte $FF,$00,$01,$FF,$00,$01,$FF,$00,$01 ; $D4F1: FF 00 01 FF 00 01 FF 00 01 ; row deltas
@AdvanceSuccessChance:
; Success chance per enemy count in the zone (index 0-11): 0/0/40/70,
; 100 from four enemies on.
  .byte $00,$00,$28,$46,$64,$64,$64,$64,$64,$64,$64,$64; $D4FA: 00 00 28 46 64 64 64 64 64 64 64 64
;-------------------------------------------------------------------------------
; $D506: @Counter577Purchase (cost $0A)
; Status-counter-577 purchase. Scans the side's 11 roster slots; every
; class-2 unit (roster code low nibble == 2) runs @FlankProbe, a 9-tile
; long-range probe (columns 0, rows +/-2..+/-4 and columns -2..-4, row 0)
; counting enemy-occupied tiles into $057E across all class-2 units. A
; B1F_RandomBelowThreshold(100) roll below @FlankProbeSuccessChance[count]
; (0/0/40/70/100...) succeeds: sets counter $0577 <- 3 for the acting
; side via Phase8RowCounter577Apply (no panel UI), deducts 10 points and
; pops the ladder return.
;-------------------------------------------------------------------------------
@Counter577Purchase:
  LDA #$00                                ; $D506: A9 00
  STA $057E                               ; $D508: 8D 7E 05 ; enemy count <- 0
  LDA btl_scan_col                               ; $D50B: AD 45 05 ; roster base
  PHA                                     ; $D50E: 48 ; save scan base
@FlankSlotLoop:
  LDY btl_scan_col                               ; $D50F: AC 45 05 ; scan slot
  LDA btl_roster_code_a,Y                             ; $D512: B9 C2 05 ; roster code
  AND #$0F                                ; $D515: 29 0F ; unit class
  CMP #$02                                ; $D517: C9 02
  BNE @FlankSlotNext                      ; $D519: D0 03 ; not class 2
  JSR @FlankProbe                         ; $D51B: 20 58 D5
@FlankSlotNext:
  INC btl_scan_col                               ; $D51E: EE 45 05 ; next slot
  LDA btl_scan_col                               ; $D521: AD 45 05
  CMP #$0B                                ; $D524: C9 0B ; side A ends at slot $A
  BEQ @FlankRoll                          ; $D526: F0 04
  CMP #$16                                ; $D528: C9 16 ; side B ends at slot $15
  BNE @FlankSlotLoop                      ; $D52A: D0 E3
@FlankRoll:
  PLA                                     ; $D52C: 68 ; restore scan base
  STA btl_scan_col                               ; $D52D: 8D 45 05
  LDY $057E                               ; $D530: AC 7E 05 ; enemy count
  LDA @FlankProbeSuccessChance,Y          ; $D533: B9 94 D5
  BEQ @FlankMiss                          ; $D536: F0 0D ; count < 2: never
  STA a:calc_work_a                             ; $D538: 8D 0A 00 ; success chance
  LDA #$64                                ; $D53B: A9 64
  JSR B1F_RandomBelowThreshold            ; $D53D: 20 62 E8 ; roll [0,100)
  CMP a:calc_work_a                             ; $D540: CD 0A 00
  BCC @FlankHit                           ; $D543: 90 01
@FlankMiss:
  RTS                                     ; $D545: 60 ; back to the ladder
@FlankHit:
  JSR Phase8RowCounter577::Apply          ; $D546: 20 84 B0 ; counter $0577 <- 3
  LDY btl_side_index                               ; $D549: AC 7C 05 ; side index
  LDA btl_point_budget_a,Y                             ; $D54C: B9 72 05 ; point budget
  SEC                                     ; $D54F: 38
  SBC #$0A                                ; $D550: E9 0A ; cost 10
  STA btl_point_budget_a,Y                             ; $D552: 99 72 05 ; budget -= 10
  PLA                                     ; $D555: 68 ; drop own return
  PLA                                     ; $D556: 68 ; drop ladder return
  RTS                                     ; $D557: 60 ; back to AiTacticSpendDispatch
@FlankProbe:
  LDA #$00                                ; $D558: A9 00 ; offset index
@FlankProbeLoop:
  PHA                                     ; $D55A: 48 ; offset index
  TAY                                     ; $D55B: A8
  LDA @FlankProbeColumnDeltas,Y           ; $D55C: B9 7C D5
  STA a:col_delta                             ; $D55F: 8D 00 00 ; column delta
  LDA @FlankProbeRowDeltas,Y              ; $D562: B9 88 D5
  STA a:row_delta                             ; $D565: 8D 01 00 ; row delta
  JSR Phase2StepTileProbe                 ; $D568: 20 CD C1 ; slot + delta
  BCS @FlankProbeNext                     ; $D56B: B0 06 ; empty tile
  TAY                                     ; $D56D: A8
  BEQ @FlankProbeNext                     ; $D56E: F0 03 ; same side / blocked
  INC $057E                               ; $D570: EE 7E 05 ; enemy found
@FlankProbeNext:
  PLA                                     ; $D573: 68 ; offset index
  CLC                                     ; $D574: 18
  ADC #$01                                ; $D575: 69 01
  CMP #$09                                ; $D577: C9 09 ; 9 probe offsets
  BCC @FlankProbeLoop                     ; $D579: 90 DF
  RTS                                     ; $D57B: 60
; --- Data Region ---
@FlankProbeColumnDeltas:
; Column deltas of the long-range flank probe (rows +/-2..4 at column 0,
; then columns -2..-4 at row 0).
  .byte $00,$00,$00,$00,$00,$00,$FE,$FD,$FC ; $D57C: 00 00 00 00 00 00 FE FD FC
; Stray head bytes ($D585-$D587 duplicate the first three row deltas; the
; probe loop reads rows from $D588).
  .byte $02,$03,$04                       ; $D585: 02 03 04
@FlankProbeRowDeltas:
; Row deltas indexed by probe 0-8: probes 0-2 step down, 3-5 up, 6-8 hold
; their row (column deltas do the moving).
  .byte $02,$03,$04,$FE,$FD,$FC           ; $D588: 02 03 04 FE FD FC
; --- Padding ($D58E-$D593) ---
  .byte $00,$00,$00,$00,$00,$00           ; $D58E: 00 00 00 00 00 00
@FlankProbeSuccessChance:
; Success chance per total enemy count (index 0-11): 0/0/40/70, 100 from
; four enemies on.
  .byte $00,$00,$28,$46,$64,$64,$64,$64,$64,$64,$64,$64; $D594: 00 00 28 46 64 64 64 64 64 64 64 64
;-------------------------------------------------------------------------------
; $D5A0: @Counter576Purchase (cost $08)
; Status-counter-576 purchase. Flat 20% roll (B1F_RandomBelowThreshold(100)
; below $14); on success sets counter $0576 <- 4 and advances the side's
; periodic reload value via Phase8RowCounter576Apply, deducts 8 points and
; pops the ladder return.
;-------------------------------------------------------------------------------
@Counter576Purchase:
  LDA #$64                                ; $D5A0: A9 64
  JSR B1F_RandomBelowThreshold            ; $D5A2: 20 62 E8 ; roll [0,100)
  CMP #$14                                ; $D5A5: C9 14 ; 20% chance
  BCC @ReloadHit                          ; $D5A7: 90 01
  RTS                                     ; $D5A9: 60 ; back to the ladder
@ReloadHit:
  JSR Phase8RowCounter576::Apply          ; $D5AA: 20 36 B0 ; counter $0576 <- 4 + reload
  LDY btl_side_index                               ; $D5AD: AC 7C 05 ; side index
  LDA btl_point_budget_a,Y                             ; $D5B0: B9 72 05 ; point budget
  SEC                                     ; $D5B3: 38
  SBC #$08                                ; $D5B4: E9 08 ; cost 8
  STA btl_point_budget_a,Y                             ; $D5B6: 99 72 05 ; budget -= 8
  PLA                                     ; $D5B9: 68 ; drop own return
  PLA                                     ; $D5BA: 68 ; drop ladder return
  RTS                                     ; $D5BB: 60 ; back to AiTacticSpendDispatch
;-------------------------------------------------------------------------------
; $D5BC: @Counter575Purchase (cost $07)
; Status-counter-575 purchase. Counts the side's class-2 units via
; @ClassCount; a B1F_RandomBelowThreshold(100) roll below
; @Counter575ClassCountChance[count] (0/0/48/80/128, guaranteed from four
; units on) succeeds: sets counter $0575 <- 3 via
; Phase8RowCounter575Apply, deducts 7 points and pops the ladder return.
;-------------------------------------------------------------------------------
@Counter575Purchase:
  JSR @ClassCount                         ; $D5BC: 20 F3 D5 ; count -> $0000
  LDY a:class2_count                             ; $D5BF: AC 00 00 ; class-2 unit count
  BEQ @ClassMiss                          ; $D5C2: F0 10 ; none: never
  LDA @Counter575ClassCountChance,Y       ; $D5C4: B9 E7 D5
  STA a:calc_work_a                             ; $D5C7: 8D 0A 00 ; success chance
  LDA #$64                                ; $D5CA: A9 64
  JSR B1F_RandomBelowThreshold            ; $D5CC: 20 62 E8 ; roll [0,100)
  CMP a:calc_work_a                             ; $D5CF: CD 0A 00
  BCC @ClassHit                           ; $D5D2: 90 01
@ClassMiss:
  RTS                                     ; $D5D4: 60 ; back to the ladder
@ClassHit:
  JSR Phase8RowCounter575::Apply          ; $D5D5: 20 16 B0 ; counter $0575 <- 3
  LDY btl_side_index                               ; $D5D8: AC 7C 05 ; side index
  LDA btl_point_budget_a,Y                             ; $D5DB: B9 72 05 ; point budget
  SEC                                     ; $D5DE: 38
  SBC #$07                                ; $D5DF: E9 07 ; cost 7
  STA btl_point_budget_a,Y                             ; $D5E1: 99 72 05 ; budget -= 7
  PLA                                     ; $D5E4: 68 ; drop own return
  PLA                                     ; $D5E5: 68 ; drop ladder return
  RTS                                     ; $D5E6: 60 ; back to AiTacticSpendDispatch
; --- Data Region ---
@Counter575ClassCountChance:
; Success chance per class-2 unit count (index 0-11): 0/0/48/80, 128
; (guaranteed) from four units on.
  .byte $00,$00,$30,$50,$80,$80,$80,$80,$80,$80,$80,$80; $D5E7: 00 00 30 50 80 80 80 80 80 80 80 80
@ClassCount:
; Counts the side's class-2 units: walks the 11 roster slots starting at
; the roster base $0545, counting non-empty ($FF) roster codes whose low
; nibble equals 2. Result in $0000.
  LDY btl_scan_col                               ; $D5F3: AC 45 05 ; roster base
  LDX #$00                                ; $D5F6: A2 00
  STX a:zone_count                             ; $D5F8: 8E 00 00 ; count <- 0
@ClassCountLoop:
  LDA btl_roster_code_a,Y                             ; $D5FB: B9 C2 05 ; roster code
  CMP #$FF                                ; $D5FE: C9 FF
  BEQ @ClassCountNext                     ; $D600: F0 09 ; empty slot
  AND #$0F                                ; $D602: 29 0F ; unit class
  CMP #$02                                ; $D604: C9 02
  BNE @ClassCountNext                     ; $D606: D0 03 ; not class 2
  INC a:zone_count                             ; $D608: EE 00 00 ; count++
@ClassCountNext:
  INY                                     ; $D60B: C8
  INX                                     ; $D60C: E8
  CPX #$0B                                ; $D60D: E0 0B ; 11 slots
  BCC @ClassCountLoop                     ; $D60F: 90 EA
  RTS                                     ; $D611: 60
;-------------------------------------------------------------------------------
; $D612: @CoinFlipPurchase (cost $03)
; Taunt-scene purchase (PhaseATauntSubDispatch sub 0: counter $0574 <- 4
; via PhaseATauntSceneOpen). Gate: with $0545 flipped to the enemy roster
; base ($057C EOR 1, zero/non-zero is all BattleOutnumberedCheck needs), the
; enemy army must be collapsing, then a roll below 50 must pass. The 3
; points are deducted before the final B1F_RandomByte coin flip, so a
; lost flip still drains the budget (original quirk). On success pops
; the ladder return and enters phase $A sub 0.
;-------------------------------------------------------------------------------
@CoinFlipPurchase:
  LDA btl_scan_col                               ; $D612: AD 45 05 ; roster base
  PHA                                     ; $D615: 48 ; save
  LDA btl_side_index                               ; $D616: AD 7C 05 ; side index
  EOR #$01                                ; $D619: 49 01 ; enemy side
  STA btl_scan_col                               ; $D61B: 8D 45 05 ; enemy roster context
  JSR BattleOutnumberedCheck              ; $D61E: 20 2A D3 ; enemy collapsing?
  PLA                                     ; $D621: 68
  STA btl_scan_col                               ; $D622: 8D 45 05 ; restore roster base
  TYA                                     ; $D625: 98
  BNE @CoinMiss                           ; $D626: D0 09 ; enemy not collapsing
  LDA #$64                                ; $D628: A9 64
  JSR B1F_RandomBelowThreshold            ; $D62A: 20 62 E8 ; roll [0,100)
  CMP #$32                                ; $D62D: C9 32 ; 50% chance
  BCC @CoinSpend                          ; $D62F: 90 01
@CoinMiss:
  RTS                                     ; $D631: 60 ; back to the ladder
@CoinSpend:
  LDY btl_side_index                               ; $D632: AC 7C 05 ; side index
  LDA btl_point_budget_a,Y                             ; $D635: B9 72 05 ; point budget
  SEC                                     ; $D638: 38
  SBC #$03                                ; $D639: E9 03 ; cost 3
@CoinStore:
  STA btl_point_budget_a,Y                             ; $D63B: 99 72 05 ; budget -= 3 (before the flip)
  JSR B1F_RandomByte                      ; $D63E: 20 7A E8 ; coin flip
  AND #$01                                ; $D641: 29 01
  BNE @CoinMiss                           ; $D643: D0 EC ; lost flip: budget already spent
  PLA                                     ; $D645: 68 ; drop own return
  PLA                                     ; $D646: 68 ; drop ladder return
  LDA #$0A                                ; $D647: A9 0A
  STA btl_overlay_phase                               ; $D649: 8D 40 05 ; phase <- $A (taunt scene)
  LDA #$00                                ; $D64C: A9 00
  STA btl_overlay_sub                               ; $D64E: 8D 41 05 ; sub-phase <- 0
  RTS                                     ; $D651: 60 ; back to AiTacticSpendDispatch
;-------------------------------------------------------------------------------
; $D652: @StatEdgePurchase (cost $05)
; Taunt-scene purchase (PhaseATauntSubDispatch sub 4). Loads the commander-column attack
; bonuses $0570/$0571 and commander troop counts $05AC/$05B7 of both
; sides; when the acting side is B ($0545 != 0) the pairs are swapped so
; ($000A,$000C) describe the acting side. Gate: own attack bonus >= the
; enemy's AND own commander troops >= the enemy's, then a
; B1F_RandomBelowThreshold(100) roll below 40. On success pops the
; ladder return, enters phase $A sub 4 (taunt scene, skipping the opening
; beat) and deducts 5 points.
;-------------------------------------------------------------------------------
@StatEdgePurchase:
  LDA btl_edge_bonus_a                               ; $D652: AD 70 05 ; side A attack bonus
  STA a:calc_work_a                             ; $D655: 8D 0A 00
  LDA btl_edge_bonus_b                               ; $D658: AD 71 05 ; side B attack bonus
  STA a:calc_work_b                             ; $D65B: 8D 0B 00
  LDA btl_troops_a                               ; $D65E: AD AC 05 ; side A commander troops
  STA a:calc_work_c                             ; $D661: 8D 0C 00
  LDA btl_troops_b                               ; $D664: AD B7 05 ; side B commander troops
  STA a:calc_work_d                             ; $D667: 8D 0D 00
  LDA btl_scan_col                               ; $D66A: AD 45 05 ; roster base
  BEQ @EdgeCompare                        ; $D66D: F0 18 ; side A: keep order
  LDX a:calc_work_a                             ; $D66F: AE 0A 00
  LDA a:calc_work_b                             ; $D672: AD 0B 00
  STA a:calc_work_a                             ; $D675: 8D 0A 00 ; own attack bonus
  STX a:calc_work_b                             ; $D678: 8E 0B 00 ; enemy attack bonus
  LDX a:calc_work_c                             ; $D67B: AE 0C 00
  LDA a:calc_work_d                             ; $D67E: AD 0D 00
  STA a:calc_work_c                             ; $D681: 8D 0C 00 ; own commander troops
  STX a:calc_work_d                             ; $D684: 8E 0D 00 ; enemy commander troops
@EdgeCompare:
  LDA a:calc_work_a                             ; $D687: AD 0A 00 ; own attack bonus
  CMP a:calc_work_b                             ; $D68A: CD 0B 00 ; vs enemy
  BCC @EdgeMiss                           ; $D68D: 90 08 ; enemy stronger
  LDA a:calc_work_c                             ; $D68F: AD 0C 00 ; own commander troops
  CMP a:calc_work_d                             ; $D692: CD 0D 00 ; vs enemy
  BCS @EdgeRoll                           ; $D695: B0 01
@EdgeMiss:
  RTS                                     ; $D697: 60 ; back to the ladder
@EdgeRoll:
  LDA #$64                                ; $D698: A9 64
  JSR B1F_RandomBelowThreshold            ; $D69A: 20 62 E8 ; roll [0,100)
  CMP #$28                                ; $D69D: C9 28 ; 40% chance
  BCS @EdgeMiss                           ; $D69F: B0 F6 ; roll failed
  PLA                                     ; $D6A1: 68 ; drop own return
  PLA                                     ; $D6A2: 68 ; drop ladder return
  LDA #$0A                                ; $D6A3: A9 0A
  STA btl_overlay_phase                               ; $D6A5: 8D 40 05 ; phase <- $A (taunt scene)
  LDA #$04                                ; $D6A8: A9 04
  STA btl_overlay_sub                               ; $D6AA: 8D 41 05 ; sub-phase <- 4
  LDY btl_side_index                               ; $D6AD: AC 7C 05 ; side index
  LDA btl_point_budget_a,Y                             ; $D6B0: B9 72 05 ; point budget
  SEC                                     ; $D6B3: 38
  SBC #$05                                ; $D6B4: E9 05 ; cost 5
  STA btl_point_budget_a,Y                             ; $D6B6: 99 72 05 ; budget -= 5
  RTS                                     ; $D6B9: 60 ; back to AiTacticSpendDispatch
.endproc
;===============================================================================
; $D6BA: PhaseATauntSubDispatch
; Phase-$A handler entry (AI taunt scene): sub-dispatch on $0541 through the
; inline 6-entry table below. Entered only from the AI tactic-point spend
; ladder AiTacticPointSpend: @CoinFlipPurchase (Taunt row, cost 3) starts at
; sub 0 and runs subs 0-5; @StatEdgePurchase (stat-edge row, cost 5) starts
; at sub 4 and skips the opening beat. Subs 2/3 are idle wait frames; the
; scene exits either back to the command select (Phase3CommandConfirmWait
; with the resume latch 1/1) or into the phase-5 side event (sub 0).
;===============================================================================
.proc PhaseATauntSubDispatch
  LDA btl_overlay_sub                               ; $D6BA: AD 41 05
  JSR B1F_CallbackDispatcher              ; $D6BD: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word PhaseATauntSceneOpen              ; $D6C0: CC D6 ; sub 0 ($D6CC)
  .word PhaseATauntSceneAdvanceWait       ; $D6C2: DD D6 ; sub 1 ($D6DD)
  .word PhaseATauntSceneWaitFrame         ; $D6C4: 2A D7 ; sub 2 ($D72A)
  .word PhaseATauntSceneWaitFrame         ; $D6C6: 2A D7 ; sub 3 ($D72A)
  .word PhaseATauntSceneStep              ; $D6C8: 43 D7 ; sub 4 ($D743)
  .word PhaseATauntSceneChoice            ; $D6CA: 7F D7 ; sub 5 ($D77F)
.endproc
;===============================================================================
; $D6CC: PhaseATauntSceneOpen
; Sub 0 (taunt opening beat). Advances to sub 1, clears the row cursor
; $0548, sets UI panel $7B and applies status counter $0574 <- 4 for the
; acting side through Phase8RowCounter574 (the no-UI counter tail of the
; player-side Taunt row).
;===============================================================================
.proc PhaseATauntSceneOpen
  INC btl_overlay_sub                               ; $D6CC: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $D6CF: A9 00
  STA btl_frame_counter                               ; $D6D1: 8D 48 05 ; row cursor <- 0
  LDA #$7B                                ; $D6D4: A9 7B
  JSR B1F_SetUI0                          ; $D6D6: 20 6D F2 ; UI panel $7B
  JSR Phase8RowCounter574                 ; $D6D9: 20 F6 AF ; counter $0574 <- 4
  RTS                                     ; $D6DC: 60
.endproc
;===============================================================================
; $D6DD: PhaseATauntSceneAdvanceWait
; Sub 1. Per frame, redraws the opposing side's overlay strip
; (PhaseATauntStripRedraw with $057C temporarily flipped) and refetches
; both pads (BattleBothPadsStateFetch); once the animation queue idles
; (BattleAnimQueueIdleCheck carry set) and an A-button edge arrives on
; either pad ($0001 bit0), closes the scene: phase/sub <- 3/3
; (Phase3CommandConfirmWait), clears the scan cursor $0545/$0546, latches
; the resume pair $054B/$054C <- 1/1 (resumption target phase 1 sub 1),
; queues the $E8/$E9 tile animation into slot 0 ($0310/$0311, $0300) and
; refreshes the panel troop-count block (BattlePanelStatsRefresh).
;===============================================================================
.proc PhaseATauntSceneAdvanceWait
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
  LDA btl_side_index                               ; $D6DD: AD 7C 05 ; side index
  PHA                                     ; $D6E0: 48
  EOR #$01                                ; $D6E1: 49 01 ; opposing side
  STA btl_side_index                               ; $D6E3: 8D 7C 05
  JSR PhaseATauntStripRedraw              ; $D6E6: 20 2B D7 ; enemy strip redraw
  PLA                                     ; $D6E9: 68
  STA btl_side_index                               ; $D6EA: 8D 7C 05 ; restore side index
  JSR BattleBothPadsStateFetch            ; $D6ED: 20 22 CD ; both pads
  JSR BattleAnimQueueIdleCheck            ; $D6F0: 20 70 B8
  BCC PhaseATauntSceneWaitFrame           ; $D6F3: 90 35 ; busy: wait
  LDA a:pad_state                             ; $D6F5: AD 01 00 ; pad raw merged
  AND #$01                                ; $D6F8: 29 01 ; A button edge
  BEQ PhaseATauntSceneWaitFrame           ; $D6FA: F0 2E ; no press: wait
.endproc
; Shared scene exit (also entered from PhaseATauntSceneChoice row 1):
; re-enter the command select at phase 3 sub 3 with the resume latch 1/1.
PhaseATauntCommandReturn:
  LDA #$03                                ; $D6FC: A9 03
  STA btl_overlay_phase                               ; $D6FE: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $D701: A9 03
  STA btl_overlay_sub                               ; $D703: 8D 41 05 ; sub-phase <- 3
  LDA #$00                                ; $D706: A9 00
  STA btl_scan_col                               ; $D708: 8D 45 05 ; scan cursor col <- 0
  STA btl_scan_row                               ; $D70B: 8D 46 05 ; scan cursor row <- 0
  LDA #$01                                ; $D70E: A9 01
  STA btl_walk_col                               ; $D710: 8D 4B 05 ; resume latch phase <- 1
  LDA #$01                                ; $D713: A9 01
  STA btl_recorded_status                               ; $D715: 8D 4C 05 ; resume latch sub <- 1
  LDA #$E8                                ; $D718: A9 E8
  STA anim_queue_id0_lo                               ; $D71A: 8D 10 03 ; tile anim slot 0 lo
  LDA #$E9                                ; $D71D: A9 E9
  STA anim_queue_id0_hi                               ; $D71F: 8D 11 03 ; tile anim slot 0 hi
  LDA #$00                                ; $D722: A9 00
  STA anim_queue_hdr0                               ; $D724: 8D 00 03 ; anim slot index <- 0
  JSR BattlePanelStatsRefresh             ; $D727: 20 F1 CB ; refresh panel stats
; Shared wait frame (dispatch subs 2/3 and the sub-1 wait paths): plain RTS.
PhaseATauntSceneWaitFrame:
  RTS                                     ; $D72A: 60
;===============================================================================
; $D72B: PhaseATauntStripRedraw
; Redraws the overlay strip of the side currently in $057C: buffer ptr lo
; from $0560[$057C] (hi fixed $A5) via the bank-19 strip renderer
; (B19_OverlayStripRender_Entry), X=0 strip slot, Y=$39.
;===============================================================================
.proc PhaseATauntStripRedraw
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; taunt strip render buffer ptr lo
strip_ptr_hi   = $000A  ; strip render buffer ptr hi
  LDY btl_side_index                               ; $D72B: AC 7C 05 ; side index
  LDA btl_strip_buf_a,Y                             ; $D72E: B9 60 05 ; strip buffer ptr lo
  STA a:strip_ptr_lo                             ; $D731: 8D 00 00
  LDA #$A5                                ; $D734: A9 A5
  STA a:strip_ptr_hi                             ; $D736: 8D 0A 00 ; buffer ptr hi
  LDX #$00                                ; $D739: A2 00 ; strip slot 0
  LDY #$39                                ; $D73B: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $D73D: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $D740: 00 A0 ; B19_OverlayStripRender_Entry
  RTS                                     ; $D742: 60
.endproc
;===============================================================================
; $D743: PhaseATauntSceneStep
; Sub 4. Advances to sub 5, clears the row cursor $0548 and sets UI panel
; $7C; publishes the acting side's commander unit id $0560[$057C] as the
; effect target $042C, sets script id $00BB <- 9, then banked-calls
; B1D_1E_DataFormatter (Y=$3D) with buffer ptr ($0000)/($0001) <-
; $0560[$057C^1]/0 to render the opposing commander's data panel, and
; finally clears the menu cursor $0424/$0425.
;===============================================================================
.proc PhaseATauntSceneStep
; zero-page work cells (proc-local):
strip_ptr_lo   = $0000  ; officer display render buffer ptr lo
strip_ptr_hi   = $0001  ; officer display render buffer ptr hi
  INC btl_overlay_sub                               ; $D743: EE 41 05 ; sub-phase <- 5
  LDA #$00                                ; $D746: A9 00
  STA btl_frame_counter                               ; $D748: 8D 48 05 ; row cursor <- 0
  LDA #$7C                                ; $D74B: A9 7C
  JSR B1F_SetUI0                          ; $D74D: 20 6D F2 ; UI panel $7C
  LDY btl_side_index                               ; $D750: AC 7C 05 ; side index
  LDA btl_strip_buf_a,Y                             ; $D753: B9 60 05 ; own commander unit id
  STA btl_panel_params                               ; $D756: 8D 2C 04 ; effect target
  LDA #$09                                ; $D759: A9 09
  STA a:zp_panel_param_a                             ; $D75B: 8D BB 00 ; script id <- 9
  LDA btl_side_index                               ; $D75E: AD 7C 05 ; side index
  EOR #$01                                ; $D761: 49 01 ; opposing side
  TAY                                     ; $D763: A8
  LDA btl_strip_buf_a,Y                             ; $D764: B9 60 05 ; enemy commander unit id
  STA a:strip_ptr_lo                             ; $D767: 8D 00 00 ; buffer ptr lo
  LDA #$00                                ; $D76A: A9 00
  STA a:strip_ptr_hi                             ; $D76C: 8D 01 00 ; buffer ptr hi
  LDY #$3D                                ; $D76F: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $D771: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $D774: 3C A0 ; data panel render
  LDA #$00                                ; $D776: A9 00
  STA menu_cursor_col                               ; $D778: 8D 24 04 ; menu cursor col <- 0
  STA menu_cursor_page                               ; $D77B: 8D 25 04 ; menu cursor page <- 0
  RTS                                     ; $D77E: 60
.endproc
;===============================================================================
; $D77F: PhaseATauntSceneChoice
; Sub 5. Two-row choice menu for the taunt scene. Saves the pad latch
; $0081, refreshes the opposing side's overlay strip (PhaseATauntStripRedraw
; with $057C temporarily flipped), refetches both pads and latches the
; merged raw state back into $0081, then steps the row cursor $0012 over
; the FF-terminated row list PhaseATauntChoiceRows via B1F_MenuStep2 and
; draws the selection cursor through B1F_PointerTableLookup (coords
; PhaseATauntChoiceCursorCoords, params PhaseATauntChoiceCursorParams).
; When the animation queue idles and an A-button edge arrives on either
; pad, the choice commits: row 0 hands over to the side event (phase/sub
; <- 5/0, Phase5SideEventRosterCommit); row 1 exits to the command select
; via PhaseATauntCommandReturn.
;===============================================================================
.proc PhaseATauntSceneChoice
; zero-page work cells (proc-local):
pad_state      = $0001  ; merged both-pad raw state
list_ptr_lo    = $0010  ; taunt row list ptr lo
list_ptr_hi    = $0011  ; taunt row list ptr hi
selected_row   = $0012  ; selected row index
cursor_ptr_lo  = $0010  ; cursor coord ptr lo
cursor_ptr_hi  = $0011  ; cursor coord ptr hi
param_ptr_lo   = $0000  ; cursor param ptr lo
param_ptr_hi   = $0001  ; cursor param ptr hi
  LDA btl_side_index                               ; $D77F: AD 7C 05 ; side index
  PHA                                     ; $D782: 48
  EOR #$01                                ; $D783: 49 01 ; opposing side
  STA btl_side_index                               ; $D785: 8D 7C 05
  JSR PhaseATauntStripRedraw              ; $D788: 20 2B D7 ; enemy strip redraw
  PLA                                     ; $D78B: 68
  STA btl_side_index                               ; $D78C: 8D 7C 05 ; restore side index
  LDA a:btl_pad1_lo                             ; $D78F: AD 81 00 ; pad latch lo
  PHA                                     ; $D792: 48 ; save
  JSR BattleBothPadsStateFetch            ; $D793: 20 22 CD ; both pads
  LDA a:pad_state                             ; $D796: AD 01 00 ; merged raw state
  STA a:btl_pad1_lo                             ; $D799: 8D 81 00 ; relatch
  LDA #<PhaseATauntChoiceRows             ; $D79C: A9 EE
  STA a:list_ptr_lo                             ; $D79E: 8D 10 00 ; row list ptr lo
  LDA #>PhaseATauntChoiceRows             ; $D7A1: A9 D7
  STA a:list_ptr_hi                             ; $D7A3: 8D 11 00 ; row list ptr hi
  LDA #$00                                ; $D7A6: A9 00
  STA a:selected_row                             ; $D7A8: 8D 12 00 ; selected row <- 0
  JSR B1F_MenuStep2                       ; $D7AB: 20 1E ED ; step row cursor
  PLA                                     ; $D7AE: 68
  STA a:btl_pad1_lo                             ; $D7AF: 8D 81 00 ; restore latch
  LDA #<PhaseATauntChoiceCursorCoords     ; $D7B2: A9 F2
  STA a:cursor_ptr_lo                             ; $D7B4: 8D 10 00 ; cursor coord ptr lo
  LDA #>PhaseATauntChoiceCursorCoords     ; $D7B7: A9 D7
  STA a:cursor_ptr_hi                             ; $D7B9: 8D 11 00 ; cursor coord ptr hi
  LDA #<PhaseATauntChoiceCursorParams     ; $D7BC: A9 F6
  STA a:param_ptr_lo                             ; $D7BE: 8D 00 00 ; cursor param ptr lo
  LDA #>PhaseATauntChoiceCursorParams     ; $D7C1: A9 D7
  STA a:param_ptr_hi                             ; $D7C3: 8D 01 00 ; cursor param ptr hi
  LDA a:selected_row                             ; $D7C6: AD 12 00 ; selected row
  JSR B1F_PointerTableLookup              ; $D7C9: 20 F5 ED ; cursor sprite
  JSR BattleAnimQueueIdleCheck            ; $D7CC: 20 70 B8
  BCC @Wait                               ; $D7CF: 90 1C ; busy: wait
  JSR BattleBothPadsStateFetch            ; $D7D1: 20 22 CD ; both pads
  LDA a:pad_state                             ; $D7D4: AD 01 00 ; pad raw merged
  AND #$01                                ; $D7D7: 29 01 ; A button edge
  BEQ @Wait                               ; $D7D9: F0 12 ; no press: wait
  LDA a:selected_row                             ; $D7DB: AD 12 00 ; selected row
  BEQ @SideEventEntry                     ; $D7DE: F0 03 ; row 0
  JMP PhaseATauntCommandReturn            ; $D7E0: 4C FC D6 ; row 1: command return
@SideEventEntry:
  LDA #$05                                ; $D7E3: A9 05
  STA btl_overlay_phase                               ; $D7E5: 8D 40 05 ; phase <- 5 (side event)
  LDA #$00                                ; $D7E8: A9 00
  STA btl_overlay_sub                               ; $D7EA: 8D 41 05 ; sub-phase <- 0
@Wait:
  RTS                                     ; $D7ED: 60
.endproc
; --- Data Region ---
PhaseATauntChoiceRows:
; FF-terminated selectable-row list for the taunt scene choice menu: rows
; 0-1 (accept -> side event, refuse -> command return).
  .byte $00,$01,$FF,$FF                   ; $D7EE: 00 01 FF FF
PhaseATauntChoiceCursorCoords:
; Selection-cursor sprite coordinates per selected row (word = y,x): row 0
; y=$CE x=$48, row 1 y=$CE x=$88.
  .word $48CE                             ; $D7F2: CE 48 ; row 0
  .word $88CE                             ; $D7F4: CE 88 ; row 1
PhaseATauntChoiceCursorParams:
; Cursor sprite parameter block passed alongside through
; B1F_PointerTableLookup.
  .byte $00,$07,$00,$00,$80               ; $D7F6: 00 07 00 00 80
;===============================================================================
; $D7FB: OfficerBattleExpLevelCheck
; Battle experience accrual and level-up check for a commander officer.
; Input: $000A <- officer id (experience recipient), $000B/$000C <-
; 16-bit amount. Bank entry OfficerBattleExpLevelCheck_Entry; also called from
; Phase2DamagePanelUpdate ($A7DC) and Phase9AdvanceContactApply ($B4E0).
; Halves the amount and adds it to the officer's 16-bit Experience
; field (record bytes 6-7, capped at $C34F). The experience total is then
; compared against the OfficerLevelExpThresholds entry for the officer's
; current level (record byte $0B high nibble); on reaching the threshold the
; level is bumped (byte $0B high nibble +1, low nibble preserved) and Might
; (record byte 1) gains a diminishing bonus by current Might. The following
; OfficerStatSumBattleTransfer (bank entry OfficerStatSumBattleTransfer_Entry) wraps this routine,
; feeding the donor's Might + Intelligence as the amount.
;===============================================================================
.proc OfficerBattleExpLevelCheck
; zero-page work cells (proc-local):
officer_id     = $000A  ; officer id (entry param)
amount_lo      = $000B  ; exp gain amount lo (entry param, halved)
amount_hi      = $000C  ; exp gain amount hi
exp_work_lo    = $000D  ; new experience lo
exp_work_hi    = $000E  ; new experience hi
new_level      = $000F  ; computed new level nibble
rec_ptr        = $0000  ; officer record ptr
  LDA a:officer_id                             ; $D7FB: AD 0A 00 ; officer id
  JSR B1F_GetOfficerRecordAddr            ; $D7FE: 20 D7 F2 ; ($00) <- record
  LSR a:amount_hi                             ; $D801: 4E 0C 00 ; amount / 2
  ROR a:amount_lo                             ; $D804: 6E 0B 00 ; (16-bit)
  LDY #$06                                ; $D807: A0 06
  LDA (rec_ptr),Y                             ; $D809: B1 00 ; Experience low
  CLC                                     ; $D80B: 18
  ADC a:amount_lo                             ; $D80C: 6D 0B 00 ; + amount/2
  STA a:exp_work_lo                             ; $D80F: 8D 0D 00 ; working low
  STA (rec_ptr),Y                             ; $D812: 91 00
  INY                                     ; $D814: C8
  LDA (rec_ptr),Y                             ; $D815: B1 00 ; Experience high
  ADC a:amount_hi                             ; $D817: 6D 0C 00 ; + carry
  STA a:exp_work_hi                             ; $D81A: 8D 0E 00 ; working high
  STA (rec_ptr),Y                             ; $D81D: 91 00
  LDY #$06                                ; $D81F: A0 06
  LDA (rec_ptr),Y                             ; $D821: B1 00
  SEC                                     ; $D823: 38
  SBC #$4F                                ; $D824: E9 4F ; compare vs $C34F
  INY                                     ; $D826: C8
  LDA (rec_ptr),Y                             ; $D827: B1 00
  SBC #$C3                                ; $D829: E9 C3
  BCC @ExpClamped                         ; $D82B: 90 0B ; below cap: keep
  LDY #$06                                ; $D82D: A0 06
  LDA #$4F                                ; $D82F: A9 4F
  STA (rec_ptr),Y                             ; $D831: 91 00 ; clamp low
  INY                                     ; $D833: C8
  LDA #$C3                                ; $D834: A9 C3
  STA (rec_ptr),Y                             ; $D836: 91 00 ; clamp high
@ExpClamped:
  LDY #$0B                                ; $D838: A0 0B
  LDA (rec_ptr),Y                             ; $D83A: B1 00 ; status/level byte
  AND #$F0                                ; $D83C: 29 F0 ; level nibble <<4
  LSR                                     ; $D83E: 4A
  LSR                                     ; $D83F: 4A
  LSR                                     ; $D840: 4A ; -> level*2
  CMP #$0E                                ; $D841: C9 0E ; level >= 7?
  BCS DoneNoMight                         ; $D843: B0 10 ; max level: done
  TAY                                     ; $D845: A8 ; Y = level*2 (word idx)
  LDA a:exp_work_lo                             ; $D846: AD 0D 00
  SEC                                     ; $D849: 38
  SBC OfficerLevelExpThresholds,Y         ; $D84A: F9 5B D8 ; exp - threshold
  LDA a:exp_work_hi                             ; $D84D: AD 0E 00
  SBC OfficerLevelExpThresholds+1,Y       ; $D850: F9 5C D8 ; (16-bit)
  BCS LevelUp                             ; $D853: B0 14 ; threshold reached
DoneNoMight:
  LDA #$00                                ; $D855: A9 00
  STA a:new_level                             ; $D857: 8D 0F 00 ; no level-up
  RTS                                     ; $D85A: 60
OfficerLevelExpThresholds:
; 16-bit experience thresholds per level (word index level*2): levels 0-6
; require $03E8/$07D0/$0DAC/$1388/$1D4C/$2710/$3A98 to reach the next level.
  .word $03E8,$07D0,$0DAC,$1388,$1D4C,$2710,$3A98; $D85B: E8 03 D0 07 AC 0D 88 13 4C 1D 10 27 98 3A
LevelUp:
  TYA                                     ; $D869: 98 ; Y = level*2
  LSR                                     ; $D86A: 4A ; -> level
  CLC                                     ; $D86B: 18
  ADC #$01                                ; $D86C: 69 01 ; level + 1
  ASL                                     ; $D86E: 0A
  ASL                                     ; $D86F: 0A
  ASL                                     ; $D870: 0A
  ASL                                     ; $D871: 0A ; -> nibble <<4
  STA a:new_level                             ; $D872: 8D 0F 00 ; new level nibble
  LDY #$0B                                ; $D875: A0 0B
  LDA (rec_ptr),Y                             ; $D877: B1 00
  AND #$F0                                ; $D879: 29 F0 ; current level nibble
  CMP a:new_level                             ; $D87B: CD 0F 00
  BCS DoneNoMight                         ; $D87E: B0 D5 ; not higher: done
  LDY #$0B                                ; $D880: A0 0B
  LDA (rec_ptr),Y                             ; $D882: B1 00
  AND #$0F                                ; $D884: 29 0F ; keep low nibble
  ORA a:new_level                             ; $D886: 0D 0F 00 ; set new level
  STA (rec_ptr),Y                             ; $D889: 91 00
  LDY #$01                                ; $D88B: A0 01
  LDA (rec_ptr),Y                             ; $D88D: B1 00 ; Might
  LDY #$06                                ; $D88F: A0 06 ; default gain +6
  CMP #$33                                ; $D891: C9 33 ; Might < 51?
  BCC @ApplyMightGain                     ; $D893: 90 12
  LDY #$05                                ; $D895: A0 05 ; gain +5
  CMP #$47                                ; $D897: C9 47 ; Might < 71?
  BCC @ApplyMightGain                     ; $D899: 90 0C
  LDY #$04                                ; $D89B: A0 04 ; gain +4
  CMP #$51                                ; $D89D: C9 51 ; Might < 81?
  BCC @ApplyMightGain                     ; $D89F: 90 06
  LDY #$02                                ; $D8A1: A0 02 ; gain +2
  CMP #$5A                                ; $D8A3: C9 5A ; Might >= 90?
  BCS @Done                               ; $D8A5: B0 08 ; max: no gain
@ApplyMightGain:
  TYA                                     ; $D8A7: 98 ; gain (6/5/4/2)
  LDY #$01                                ; $D8A8: A0 01
  CLC                                     ; $D8AA: 18
  ADC (rec_ptr),Y                             ; $D8AB: 71 00 ; Might + gain
  STA (rec_ptr),Y                             ; $D8AD: 91 00
@Done:
  RTS                                     ; $D8AF: 60
.endproc
;===============================================================================
; $D8B0: OfficerStatSumBattleTransfer
; Computes the donor officer's Might (record byte 1) + Intelligence (record
; byte 2) sum and feeds it as the 16-bit amount to OfficerBattleExpLevelCheck.
; Input: $000A <- recipient officer id (passed through to $D7FB, experience
; target), $000B <- donor officer id (stat source). Bank entry
; OfficerStatSumBattleTransfer_Entry;
; called via BankedCallbackTrampoline from prg_0c_0d.asm ($B628, $C7AD).
;===============================================================================
.proc OfficerStatSumBattleTransfer
; zero-page work cells (proc-local):
donor_work     = $000B  ; donor officer id -> transfer amount lo
amount_hi      = $000C  ; transfer amount hi
rec_ptr        = $0000  ; officer record ptr (Might/Int)
  LDA a:donor_work                             ; $D8B0: AD 0B 00 ; donor officer id
  JSR B1F_GetOfficerRecordAddr            ; $D8B3: 20 D7 F2 ; ($00) <- donor record
  LDA #$00                                ; $D8B6: A9 00
  STA a:donor_work                             ; $D8B8: 8D 0B 00 ; clear amount low
  STA a:amount_hi                             ; $D8BB: 8D 0C 00 ; clear amount high
  LDY #$01                                ; $D8BE: A0 01
  LDA (rec_ptr),Y                             ; $D8C0: B1 00 ; Might
  INY                                     ; $D8C2: C8
  CLC                                     ; $D8C3: 18
  ADC (rec_ptr),Y                             ; $D8C4: 71 00 ; + Intelligence
  STA a:donor_work                             ; $D8C6: 8D 0B 00 ; sum -> amount low
  LDA a:amount_hi                             ; $D8C9: AD 0C 00
  ADC #$00                                ; $D8CC: 69 00 ; carry -> amount high
  STA a:amount_hi                             ; $D8CE: 8D 0C 00
  JMP OfficerBattleExpLevelCheck          ; $D8D1: 4C FB D7 ; exp accrual/level-up
.endproc
;===============================================================================
; $D8D4: BattleAnimSoundEngine
; Battle scene multi-channel animation and audio engine. Processes 22
; independent channels each VBlank: 4 NES APU channels (pulse 1/2, triangle,
; noise) plus up to 18 Namco-163 expansion audio channels. Each channel
; interprets a byte-stream command protocol that encodes duration, volume,
; pitch, vibrato, loop points, and termination. Called via bank entry
; BattleAnimSoundEngine_Entry from the BattleVBlankFrameUpdate dispatch chain.
;===============================================================================
.proc BattleAnimSoundEngine
@EngineInit:
  LDY #$22                                ; $D8D4: A0 22
  JSR B1F_SwitchBank8_B                   ; $D8D6: 20 5F F2
  LDA #$23                                ; $D8D9: A9 23
  STA a:$00E2                             ; $D8DB: 8D E2 00
  ORA #$C0                                ; $D8DE: 09 C0
  STA NAMCO_PRG_A000                      ; $D8E0: 8D 00 E8
  LDA #$00                                ; $D8E3: A9 00
  STA snd_active_mask                               ; $D8E5: 8D F2 07
  INC snd_frame_ctr                               ; $D8E8: EE F9 07
@ChannelLoop:
  TAX                                     ; $D8EB: AA
  LDA snd_chan_hw_idx,X                             ; $D8EC: BD 01 07
  AND #$07                                ; $D8EF: 29 07
  STA snd_hw_index                               ; $D8F1: 8D F3 07
  TAY                                     ; $D8F4: A8
  ASL                                     ; $D8F5: 0A
  ASL                                     ; $D8F6: 0A
  STA snd_reg_base                               ; $D8F7: 8D F5 07
  LDA BattleSoundChannelProc::ChannelModeTable,Y ; $D8FA: B9 56 DD
  STA snd_channel_mode                               ; $D8FD: 8D F4 07
  LDA snd_chan_state,X                             ; $D900: BD 00 07
  BEQ @InitChannel                                               ; $D903: F0 53
  CMP #$FF                                ; $D905: C9 FF
  BEQ @NextChannel                                               ; $D907: F0 46
  JSR BattleSoundChannelProc::SoundPlay                               ; $D909: 20 D8 DC
  INC snd_chan_frame_ctr,X                             ; $D90C: FE 0E 07
  LDA snd_chan_frame_ctr,X                             ; $D90F: BD 0E 07
  CMP snd_chan_freq_period,X                             ; $D912: DD 0D 07
  BCC @DecrementDuration                                               ; $D915: 90 06
  LDA snd_chan_freq_period,X                             ; $D917: BD 0D 07
  STA snd_chan_frame_ctr,X                             ; $D91A: 9D 0E 07
@DecrementDuration:
  DEC snd_chan_dur_ctr,X                             ; $D91D: DE 05 07
  BPL @AdvanceStream                                               ; $D920: 10 18
  LDA snd_chan_duration,X                             ; $D922: BD 04 07
  AND #$0F                                ; $D925: 29 0F
  STA snd_chan_dur_ctr,X                             ; $D927: 9D 05 07
  JSR BattleSoundChannelProc::VibratoUpdate                               ; $D92A: 20 90 DC
  LDA snd_chan_cmd_tmr,X                             ; $D92D: BD 15 07
  BEQ @SkipAnimDec                                               ; $D930: F0 03
  DEC snd_chan_cmd_tmr,X                             ; $D932: DE 15 07
@SkipAnimDec:
  DEC snd_chan_note_ctr,X                             ; $D935: DE 08 07
  BEQ @RemoveChannel                                               ; $D938: F0 06
@AdvanceStream:
  JSR BattleSoundChannelProc::SoundPlayAlt                           ; $D93A: 20 6E DF
  JMP @AccumulateMask                               ; $D93D: 4C 43 D9
@RemoveChannel:
  JSR @CmdProcess                             ; $D940: 20 9B D9
@AccumulateMask:
  LDY snd_hw_index                               ; $D943: AC F3 07
  LDA BattleSoundChannelProc::ChannelMaskTable,Y ; $D946: B9 4E DD
  ORA snd_active_mask                               ; $D949: 0D F2 07
  STA snd_active_mask                               ; $D94C: 8D F2 07
@NextChannel:
  TXA                                     ; $D94F: 8A
  CLC                                     ; $D950: 18
  ADC #$16                                ; $D951: 69 16
  CMP #$F2                                ; $D953: C9 F2
  BNE @ChannelLoop                                               ; $D955: D0 94
  RTS                                     ; $D957: 60
;-------------------------------------------------------------------------------
; Channel initialization: load stream pointer, extract duration/volume/frequency
;-------------------------------------------------------------------------------
@InitChannel:
  LDA snd_chan_stream_lo,X                             ; $D958: BD 02 07
  STA a:$00F0                             ; $D95B: 8D F0 00
  LDA snd_chan_stream_hi,X                             ; $D95E: BD 03 07
  STA a:$00F1                             ; $D961: 8D F1 00
  LDY #$00                                ; $D964: A0 00
  LDA ($F0),Y                             ; $D966: B1 F0
  AND #$0F                                ; $D968: 29 0F
  STA snd_chan_duration,X                             ; $D96A: 9D 04 07
  STA snd_chan_dur_ctr,X                             ; $D96D: 9D 05 07
  INY                                     ; $D970: C8
  JSR VolumeExtract                               ; $D971: 20 3F DC
  INY                                     ; $D974: C8
  LDA ($F0),Y                             ; $D975: B1 F0
  ORA snd_freq_lo                               ; $D977: 0D F7 07
  STA snd_chan_volume,X                             ; $D97A: 9D 06 07
  STA snd_chan_volume_sv,X                             ; $D97D: 9D 07 07
  INY                                     ; $D980: C8
  LDA ($F0),Y                             ; $D981: B1 F0
  STA snd_chan_sweep,X                             ; $D983: 9D 09 07
  LDA #$00                                ; $D986: A9 00
  STA snd_chan_vib_ctr0,X                             ; $D988: 9D 0A 07
  STA snd_chan_vib_ctr1,X                             ; $D98B: 9D 0B 07
  STA snd_chan_aux0c,X                             ; $D98E: 9D 0C 07
  STA snd_chan_decay_ctr,X                             ; $D991: 9D 0F 07
  LDA #$02                                ; $D994: A9 02
  STA snd_chan_state,X                             ; $D996: 9D 00 07
  BNE @RemoveChannel                                               ; $D999: D0 A5
@CmdProcess:
  LDA snd_chan_cmd_rld,X                             ; $D99B: BD 14 07
  STA snd_chan_cmd_tmr,X                             ; $D99E: 9D 15 07
  LDY #$00                                ; $D9A1: A0 00
  STY a:$00F1                             ; $D9A3: 8C F1 00
  LDA snd_chan_state,X                             ; $D9A6: BD 00 07
  ASL                                     ; $D9A9: 0A
  ROL a:$00F1                             ; $D9AA: 2E F1 00
  ADC snd_chan_stream_lo,X                             ; $D9AD: 7D 02 07
  STA a:$00F0                             ; $D9B0: 8D F0 00
  LDA snd_chan_stream_hi,X                             ; $D9B3: BD 03 07
  ADC a:$00F1                             ; $D9B6: 6D F1 00
  STA a:$00F1                             ; $D9B9: 8D F1 00
  DEY                                     ; $D9BC: 88
@CmdLoop:
  INY                                     ; $D9BD: C8
  LDA ($F0),Y                             ; $D9BE: B1 F0
  INC snd_chan_state,X                             ; $D9C0: FE 00 07
  INY                                     ; $D9C3: C8
  CMP #$F0                                ; $D9C4: C9 F0
  BCS @CmdFD_SaveLoopPt                                               ; $D9C6: B0 1A
  CMP #$E0                                ; $D9C8: C9 E0
  BCS @CmdNegOffset                                               ; $D9CA: B0 2D
  CMP #$D0                                ; $D9CC: C9 D0
  BCS @CmdExtractLowNibble                                               ; $D9CE: B0 33
  CMP #$C0                                ; $D9D0: C9 C0
  BCS @CmdSetMaxDuration                                               ; $D9D2: B0 44
  CMP #$B0                                ; $D9D4: C9 B0
  BCS @CmdVolumeEnvelope                                               ; $D9D6: B0 5F
  CMP #$A0                                ; $D9D8: C9 A0
  BCC @CmdJmpBelowA0                                               ; $D9DA: 90 03
  JMP @CmdA0_ChannelMask                           ; $D9DC: 4C 65 DA
@CmdJmpBelowA0:
  JMP @CmdBelowA0                               ; $D9DF: 4C 21 DB
@CmdFD_SaveLoopPt:
  CMP #$FD                                ; $D9E2: C9 FD
  BNE @CmdFF_Terminate                                               ; $D9E4: D0 09
  LDA snd_chan_state,X                             ; $D9E6: BD 00 07
  STA snd_chan_aux13,X                             ; $D9E9: 9D 13 07
@CmdLoopBack:
  JMP @CmdLoop                               ; $D9EC: 4C BD D9
@CmdFF_Terminate:
  CMP #$FF                                ; $D9EF: C9 FF
  BNE @CmdLoopBack                                               ; $D9F1: D0 F9
  STA snd_chan_state,X                             ; $D9F3: 9D 00 07
  JMP @CmdExit                               ; $D9F6: 4C F1 DB
@CmdNegOffset:
  AND #$0F                                ; $D9F9: 29 0F
  EOR #$FF                                ; $D9FB: 49 FF
  CLC                                     ; $D9FD: 18
  ADC #$01                                ; $D9FE: 69 01
  JMP @CmdApplyFreqOffset                               ; $DA00: 4C 05 DA
@CmdExtractLowNibble:
  AND #$0F                                ; $DA03: 29 0F
@CmdApplyFreqOffset:
  BIT snd_channel_mode                               ; $DA05: 2C F4 07
  BMI @CmdFreqDone                                               ; $DA08: 30 0B
  STA snd_chan_decay_ctr,X                             ; $DA0A: 9D 0F 07
  LDA ($F0),Y                             ; $DA0D: B1 F0
  STA snd_chan_decay_rld,X                             ; $DA0F: 9D 10 07
  STA snd_chan_decay_tmr,X                             ; $DA12: 9D 11 07
@CmdFreqDone:
  JMP @CmdLoop                               ; $DA15: 4C BD D9
@CmdSetMaxDuration:
  AND #$0F                                ; $DA18: 29 0F
  STA snd_freq_lo                               ; $DA1A: 8D F7 07
  BIT snd_channel_mode                               ; $DA1D: 2C F4 07
  BMI @CmdDurationDone                                               ; $DA20: 30 12
  LDA snd_chan_volume,X                             ; $DA22: BD 06 07
  AND #$10                                ; $DA25: 29 10
  BEQ @CmdDurationDone                                               ; $DA27: F0 0B
  LDA ($F0),Y                             ; $DA29: B1 F0
  STA snd_chan_freq_period,X                             ; $DA2B: 9D 0D 07
  LDA snd_freq_lo                               ; $DA2E: AD F7 07
  STA snd_chan_aux0c,X                             ; $DA31: 9D 0C 07
@CmdDurationDone:
  JMP @CmdLoop                               ; $DA34: 4C BD D9
@CmdVolumeEnvelope:
  AND #$0F                                ; $DA37: 29 0F
  BEQ @CmdEnvReloadPtr                                               ; $DA39: F0 1D
  PHA                                     ; $DA3B: 48
  LDA ($F0),Y                             ; $DA3C: B1 F0
  BNE @CmdEnvPhaseB                                               ; $DA3E: D0 0D
  PLA                                     ; $DA40: 68
  DEC snd_chan_vib_ctr0,X                             ; $DA41: DE 0A 07
  BEQ @CmdEnvJump                                               ; $DA44: F0 1C
  BPL @CmdEnvReloadPtr                                               ; $DA46: 10 10
  STA snd_chan_vib_ctr0,X                             ; $DA48: 9D 0A 07
  BMI @CmdEnvReloadPtr                                               ; $DA4B: 30 0B
@CmdEnvPhaseB:
  PLA                                     ; $DA4D: 68
  DEC snd_chan_vib_ctr1,X                             ; $DA4E: DE 0B 07
  BEQ @CmdEnvJump                                               ; $DA51: F0 0F
  BPL @CmdEnvReloadPtr                                               ; $DA53: 10 03
  STA snd_chan_vib_ctr1,X                             ; $DA55: 9D 0B 07
@CmdEnvReloadPtr:
  LDA ($F0),Y                             ; $DA58: B1 F0
  BNE @CmdEnvSetPtr                                               ; $DA5A: D0 03
  LDA snd_chan_aux13,X                             ; $DA5C: BD 13 07
@CmdEnvSetPtr:
  STA snd_chan_state,X                             ; $DA5F: 9D 00 07
@CmdEnvJump:
  JMP @CmdProcess                               ; $DA62: 4C 9B D9
@CmdA0_ChannelMask:
  BNE @CmdA1_SetRestore                                               ; $DA65: D0 0F
  BIT snd_channel_mode                               ; $DA67: 2C F4 07
  BMI @CmdA0Done                                               ; $DA6A: 30 13
  LDA snd_chan_volume,X                             ; $DA6C: BD 06 07
  AND #$C0                                ; $DA6F: 29 C0
  ORA ($F0),Y                             ; $DA71: 11 F0
  JMP @CmdA2Done                               ; $DA73: 4C 93 DA
@CmdA1_SetRestore:
  CMP #$A1                                ; $DA76: C9 A1
  BNE @CmdA2_SetFreq                                               ; $DA78: D0 08
  LDA ($F0),Y                             ; $DA7A: B1 F0
  STA snd_chan_sweep,X                             ; $DA7C: 9D 09 07
@CmdA0Done:
  JMP @CmdLoop                               ; $DA7F: 4C BD D9
@CmdA2_SetFreq:
  CMP #$A2                                ; $DA82: C9 A2
  BNE @CmdA3_SetVibrato                                               ; $DA84: D0 16
  JSR VolumeExtract                               ; $DA86: 20 3F DC
  BCS @CmdA2Done                                               ; $DA89: B0 08
  LDA snd_chan_volume,X                             ; $DA8B: BD 06 07
  AND #$1F                                ; $DA8E: 29 1F
  ORA snd_freq_lo                               ; $DA90: 0D F7 07
@CmdA2Done:
  STA snd_chan_volume,X                             ; $DA93: 9D 06 07
  STA snd_chan_volume_sv,X                             ; $DA96: 9D 07 07
  JMP @CmdLoop                               ; $DA99: 4C BD D9
@CmdA3_SetVibrato:
  CMP #$A3                                ; $DA9C: C9 A3
  BNE @CmdA4_Or_VibratoReset                                               ; $DA9E: D0 1C
  LDA ($F0),Y                             ; $DAA0: B1 F0
  BMI @ClearVibrato                                               ; $DAA2: 30 1C
  PHA                                     ; $DAA4: 48
  AND #$0F                                ; $DAA5: 29 0F
  ASL                                     ; $DAA7: 0A
  STA snd_chan_cmd_rld,X                             ; $DAA8: 9D 14 07
  STA snd_chan_cmd_tmr,X                             ; $DAAB: 9D 15 07
  PLA                                     ; $DAAE: 68
  AND #$70                                ; $DAAF: 29 70
  ORA snd_chan_hw_idx,X                             ; $DAB1: 1D 01 07
  ORA #$80                                ; $DAB4: 09 80
  STA snd_chan_hw_idx,X                             ; $DAB6: 9D 01 07
  JMP @CmdLoop                               ; $DAB9: 4C BD D9
@CmdA4_Or_VibratoReset:
  CMP #$A4                                ; $DABC: C9 A4
  BNE @CmdAD_PitchBend                                               ; $DABE: D0 0B
@ClearVibrato:
  LDA snd_chan_hw_idx,X                             ; $DAC0: BD 01 07
  AND #$07                                ; $DAC3: 29 07
  STA snd_chan_hw_idx,X                             ; $DAC5: 9D 01 07
  JMP @CmdLoop                               ; $DAC8: 4C BD D9
@CmdAD_PitchBend:
  CMP #$AD                                ; $DACB: C9 AD
  BNE @CmdAE_ShiftVolume                                               ; $DACD: D0 29
  LDA ($F0),Y                             ; $DACF: B1 F0
  PHA                                     ; $DAD1: 48
  LDA #$00                                ; $DAD2: A9 00
  STA a:$00F1                             ; $DAD4: 8D F1 00
  LDA snd_chan_state,X                             ; $DAD7: BD 00 07
  ASL                                     ; $DADA: 0A
  ROL a:$00F1                             ; $DADB: 2E F1 00
  ADC snd_chan_stream_lo,X                             ; $DADE: 7D 02 07
  STA snd_chan_stream_lo,X                             ; $DAE1: 9D 02 07
  LDA snd_chan_stream_hi,X                             ; $DAE4: BD 03 07
  ADC a:$00F1                             ; $DAE7: 6D F1 00
  STA snd_chan_stream_hi,X                             ; $DAEA: 9D 03 07
  LDA #$00                                ; $DAED: A9 00
  STA snd_chan_state,X                             ; $DAEF: 9D 00 07
  PLA                                     ; $DAF2: 68
  BNE @CmdAEDone                                               ; $DAF3: D0 10
  JMP @InitChannel                               ; $DAF5: 4C 58 D9
@CmdAE_ShiftVolume:
  CMP #$AE                                ; $DAF8: C9 AE
  BNE @CmdAF_SetDuration                                               ; $DAFA: D0 0C
  ASL snd_chan_duration,X                             ; $DAFC: 1E 04 07
  LDA ($F0),Y                             ; $DAFF: B1 F0
  ASL                                     ; $DB01: 0A
  ROR snd_chan_duration,X                             ; $DB02: 7E 04 07
@CmdAEDone:
  JMP @CmdLoop                               ; $DB05: 4C BD D9
@CmdAF_SetDuration:
  CMP #$AF                                ; $DB08: C9 AF
  BNE @CmdAFDone                                               ; $DB0A: D0 12
  LDA ($F0),Y                             ; $DB0C: B1 F0
  AND #$0F                                ; $DB0E: 29 0F
  STA snd_chan_dur_ctr,X                             ; $DB10: 9D 05 07
  LDA snd_chan_duration,X                             ; $DB13: BD 04 07
  AND #$F0                                ; $DB16: 29 F0
  ORA snd_chan_dur_ctr,X                             ; $DB18: 1D 05 07
  STA snd_chan_duration,X                             ; $DB1B: 9D 04 07
@CmdAFDone:
  JMP @CmdLoop                               ; $DB1E: 4C BD D9
@CmdBelowA0:
  STA snd_freq_lo                               ; $DB21: 8D F7 07
  LDA ($F0),Y                             ; $DB24: B1 F0
  STA snd_chan_note_ctr,X                             ; $DB26: 9D 08 07
  LDA snd_freq_lo                               ; $DB29: AD F7 07
  BIT snd_channel_mode                               ; $DB2C: 2C F4 07
  BVC @CmdScaleVolume                                               ; $DB2F: 50 03
  JMP @CmdDBE2                               ; $DB31: 4C E2 DB
@CmdScaleVolume:
  PHA                                     ; $DB34: 48
  AND #$0F                                ; $DB35: 29 0F
  CMP #$0C                                ; $DB37: C9 0C
  BCC @CmdVolLookup                                               ; $DB39: 90 03
  JMP @CmdPullExit                               ; $DB3B: 4C F0 DB
@CmdVolLookup:
  ASL                                     ; $DB3E: 0A
  TAY                                     ; $DB3F: A8
  LDA snd_chan_duration,X                             ; $DB40: BD 04 07
  BPL @CmdVolAdjust                                               ; $DB43: 10 05
  TYA                                     ; $DB45: 98
  CLC                                     ; $DB46: 18
  ADC #$18                                ; $DB47: 69 18
  TAY                                     ; $DB49: A8
@CmdVolAdjust:
  LDA snd_hw_index                               ; $DB4A: AD F3 07
  CMP #$04                                ; $DB4D: C9 04
  BCC @CmdFreqScale                                               ; $DB4F: 90 05
  TYA                                     ; $DB51: 98
  CLC                                     ; $DB52: 18
  ADC #$30                                ; $DB53: 69 30
  TAY                                     ; $DB55: A8
@CmdFreqScale:
  LDA BattleSoundChannelProc::NoteFreqTable,Y    ; $DB56: B9 06 DD
  STA snd_freq_lo                               ; $DB59: 8D F7 07
  LDA BattleSoundChannelProc::NoteFreqTable+1,Y  ; $DB5C: B9 07 DD
  STA snd_freq_hi                               ; $DB5F: 8D F8 07
  PLA                                     ; $DB62: 68
  AND #$70                                ; $DB63: 29 70
  LDY snd_hw_index                               ; $DB65: AC F3 07
  CPY #$04                                ; $DB68: C0 04
  BCC @CmdShiftDown                                               ; $DB6A: 90 1A
  CMP #$40                                ; $DB6C: C9 40
  BNE @CmdFreqAdjust                                               ; $DB6E: D0 09
  ASL snd_freq_lo                               ; $DB70: 0E F7 07
  ROL snd_freq_hi                               ; $DB73: 2E F8 07
  JMP @CmdWriteFreq                               ; $DB76: 4C 96 DB
@CmdFreqAdjust:
  SBC #$30                                ; $DB79: E9 30
  BEQ @CmdShiftDown                                               ; $DB7B: F0 09
  BCC @CmdNegate                                               ; $DB7D: 90 02
  LDA #$B0                                ; $DB7F: A9 B0
@CmdNegate:
  EOR #$FF                                ; $DB81: 49 FF
  CLC                                     ; $DB83: 18
  ADC #$01                                ; $DB84: 69 01
@CmdShiftDown:
  LSR                                     ; $DB86: 4A
  LSR                                     ; $DB87: 4A
  LSR                                     ; $DB88: 4A
  LSR                                     ; $DB89: 4A
  BEQ @CmdWriteFreq                                               ; $DB8A: F0 0A
  TAY                                     ; $DB8C: A8
@CmdShiftLoop:
  LSR snd_freq_hi                               ; $DB8D: 4E F8 07
  ROR snd_freq_lo                               ; $DB90: 6E F7 07
  DEY                                     ; $DB93: 88
  BNE @CmdShiftLoop                                               ; $DB94: D0 F7
@CmdWriteFreq:
  LDA #$00                                ; $DB96: A9 00
  STA snd_chan_frame_ctr,X                             ; $DB98: 9D 0E 07
  LDA snd_chan_volume_sv,X                             ; $DB9B: BD 07 07
  STA snd_chan_volume,X                             ; $DB9E: 9D 06 07
  JSR ChannelMaskCheck                               ; $DBA1: 20 31 DC
  CPY #$04                                ; $DBA4: C0 04
  BCS @CmdTriggerSound                                               ; $DBA6: B0 0C
  LDA BattleSoundChannelProc::ChannelMaskTable,Y ; $DBA8: B9 4E DD
  ORA snd_apu_enable                               ; $DBAB: 0D F6 07
  STA snd_apu_enable                               ; $DBAE: 8D F6 07
  STA $4015                               ; $DBB1: 8D 15 40
@CmdTriggerSound:
  LDA snd_freq_hi                               ; $DBB4: AD F8 07
  PHA                                     ; $DBB7: 48
  LDA snd_freq_lo                               ; $DBB8: AD F7 07
  PHA                                     ; $DBBB: 48
  JSR BattleSoundChannelProc::SoundPlayAltEntry                      ; $DBBC: 20 71 DF
  CPY #$10                                ; $DBBF: C0 10
  BCS @CmdClampLow                                               ; $DBC1: B0 06
  LDA snd_chan_sweep,X                             ; $DBC3: BD 09 07
  STA $4001,Y                             ; $DBC6: 99 01 40
@CmdClampLow:
  PLA                                     ; $DBC9: 68
  JSR @FreqHighWrite                               ; $DBCA: 20 03 DC
  CMP #$02                                ; $DBCD: C9 02
  BCC @CmdLoadLow                                               ; $DBCF: 90 08
  CMP #$FE                                ; $DBD1: C9 FE
  BCC @CmdStoreClamp                                               ; $DBD3: 90 06
  LDA #$FD                                ; $DBD5: A9 FD
  BNE @CmdStoreClamp                                               ; $DBD7: D0 02
@CmdLoadLow:
  LDA #$02                                ; $DBD9: A9 02
@CmdStoreClamp:
  STA snd_chan_freq_acc,X                             ; $DBDB: 9D 12 07
  PLA                                     ; $DBDE: 68
  JMP @FreqLowWrite                               ; $DBDF: 4C 18 DC
@CmdDBE2:
  CMP #$10                                ; $DBE2: C9 10
  BCS @CmdExit                                               ; $DBE4: B0 0B
  STA snd_freq_lo                               ; $DBE6: 8D F7 07
  LDA #$00                                ; $DBE9: A9 00
  STA snd_freq_hi                               ; $DBEB: 8D F8 07
  BEQ @CmdWriteFreq                                               ; $DBEE: F0 A6
@CmdPullExit:
  PLA                                     ; $DBF0: 68
@CmdExit:
  LDA snd_chan_volume,X                             ; $DBF1: BD 06 07
  AND #$C0                                ; $DBF4: 29 C0
  BIT snd_channel_mode                               ; $DBF6: 2C F4 07
  BPL @CmdExitWrite                                               ; $DBF9: 10 02
  LDA #$00                                ; $DBFB: A9 00
@CmdExitWrite:
  STA snd_chan_volume,X                             ; $DBFD: 9D 06 07
  JMP BattleSoundChannelProc::SoundPlayAlt                           ; $DC00: 4C 6E DF
@FreqHighWrite:
  CPY #$10                                ; $DC03: C0 10
  BCS @FreqHighWriteNamco                                               ; $DC05: B0 04
  STA $4002,Y                             ; $DC07: 99 02 40
  RTS                                     ; $DC0A: 60
@FreqHighWriteNamco:
  PHA                                     ; $DC0B: 48
  TYA                                     ; $DC0C: 98
  ASL                                     ; $DC0D: 0A
  ORA #$60                                ; $DC0E: 09 60
  STA NAMCO_CTRL                          ; $DC10: 8D 00 F8
  PLA                                     ; $DC13: 68
  STA $4800                               ; $DC14: 8D 00 48
  RTS                                     ; $DC17: 60
@FreqLowWrite:
  CPY #$10                                ; $DC18: C0 10
  BCS @FreqLowWriteNamco                                               ; $DC1A: B0 08
  AND #$07                                ; $DC1C: 29 07
  ORA #$08                                ; $DC1E: 09 08
  STA $4003,Y                             ; $DC20: 99 03 40
  RTS                                     ; $DC23: 60
@FreqLowWriteNamco:
  PHA                                     ; $DC24: 48
  TYA                                     ; $DC25: 98
  ASL                                     ; $DC26: 0A
  ORA #$62                                ; $DC27: 09 62
  STA NAMCO_CTRL                          ; $DC29: 8D 00 F8
  PLA                                     ; $DC2C: 68
  STA $4800                               ; $DC2D: 8D 00 48
  RTS                                     ; $DC30: 60
;-------------------------------------------------------------------------------
; Helper routines: channel mask check, volume extract, frequency division,
; vibrato update, sound play, APU/Namco register writers
;-------------------------------------------------------------------------------
ChannelMaskCheck:
  LDY snd_hw_index                               ; $DC31: AC F3 07
  LDA BattleSoundChannelProc::ChannelMaskTable,Y ; $DC34: B9 4E DD
  BIT snd_active_mask                               ; $DC37: 2C F2 07
  BEQ @MaskCheckRts                                               ; $DC3A: F0 02
  PLA                                     ; $DC3C: 68
  PLA                                     ; $DC3D: 68
@MaskCheckRts:
  RTS                                     ; $DC3E: 60
VolumeExtract:
  BIT snd_channel_mode                               ; $DC3F: 2C F4 07
  BMI VolumeExtractNamco                                               ; $DC42: 30 0C
  LDA ($F0),Y                             ; $DC44: B1 F0
  ROR                                     ; $DC46: 6A
  ROR                                     ; $DC47: 6A
  ROR                                     ; $DC48: 6A
  AND #$C0                                ; $DC49: 29 C0
  STA snd_freq_lo                               ; $DC4B: 8D F7 07
  CLC                                     ; $DC4E: 18
  RTS                                     ; $DC4F: 60
VolumeExtractNamco:
  LDA ($F0),Y                             ; $DC50: B1 F0
  AND #$7F                                ; $DC52: 29 7F
  STA snd_freq_lo                               ; $DC54: 8D F7 07
  SEC                                     ; $DC57: 38
  RTS                                     ; $DC58: 60
.endproc
;===============================================================================
; $DC59: BattleSoundChannelProc
; Sound channel processing engine. Handles frequency scaling, vibrato, sound
; playback, and APU/Namco register writes for battle scene audio channels.
; Primary entry at SoundPlayAlt ($DF6E), dispatched via bank entry
; SoundPlayAlt_Entry and called from BattleAnimSoundEngine.
;===============================================================================
.proc BattleSoundChannelProc
; --- Code Region: volume/frequency scale processing ---
VolumeFreqScale:
  .byte $0A,$0A,$0A,$0A                   ; $DC59: 0A 0A 0A 0A ; padding (ASL A x4)
  PHA                                     ; $DC5D: 48 ; save volume nibble
  LDA #$00                                ; $DC5E: A9 00
  STA snd_freq_lo                               ; $DC60: 8D F7 07 ; clear freq shift acc
  LDA snd_chan_frame_ctr,X                             ; $DC63: BD 0E 07 ; frame counter
  LDY #$03                                ; $DC66: A0 03 ; 4 iterations
@FreqDivisionLoop:
  ASL                                     ; $DC68: 0A ; shift freq
  CMP snd_chan_freq_period,X                             ; $DC69: DD 0D 07
  BCC @FreqDivSubtract                    ; $DC6C: 90 03
  SBC snd_chan_freq_period,X                             ; $DC6E: FD 0D 07
@FreqDivSubtract:
  ROL snd_freq_lo                               ; $DC71: 2E F7 07
  DEY                                     ; $DC74: 88
  BPL @FreqDivisionLoop                                               ; $DC75: 10 F1
  PLA                                     ; $DC77: 68
  ORA snd_freq_lo                               ; $DC78: 0D F7 07
  TAY                                     ; $DC7B: A8
  LDA snd_chan_volume,X                             ; $DC7C: BD 06 07
  AND #$0F                                ; $DC7F: 29 0F
  ORA RegSelectTable,Y                    ; $DC81: 19 CE DD
  TAY                                     ; $DC84: A8
  LDA snd_chan_volume,X                             ; $DC85: BD 06 07
  AND #$C0                                ; $DC88: 29 C0
  ORA RegMergeTable,Y                     ; $DC8A: 19 6E DE
  JMP ChannelWrite                               ; $DC8D: 4C 87 DF
VibratoUpdate:
  BIT snd_channel_mode                               ; $DC90: 2C F4 07
  BMI @VibratoReturn                                               ; $DC93: 30 31
  LDA snd_chan_decay_ctr,X                             ; $DC95: BD 0F 07
  BEQ @VibratoReturn                                               ; $DC98: F0 2C
  DEC snd_chan_decay_tmr,X                             ; $DC9A: DE 11 07
  BNE @VibratoReturn                                               ; $DC9D: D0 27
  LDA snd_chan_decay_rld,X                             ; $DC9F: BD 10 07
  STA snd_chan_decay_tmr,X                             ; $DCA2: 9D 11 07
  LDA snd_chan_volume,X                             ; $DCA5: BD 06 07
  AND #$1F                                ; $DCA8: 29 1F
  STA snd_freq_lo                               ; $DCAA: 8D F7 07
  AND #$10                                ; $DCAD: 29 10
  BEQ @VibratoReturn                                               ; $DCAF: F0 15
  LDA snd_chan_decay_ctr,X                             ; $DCB1: BD 0F 07
  BMI @VibratoDecrement                                               ; $DCB4: 30 11
  DEC snd_chan_decay_ctr,X                             ; $DCB6: DE 0F 07
  LDA snd_freq_lo                               ; $DCB9: AD F7 07
  CMP #$1F                                ; $DCBC: C9 1F
  BEQ @VibratoReturn                                               ; $DCBE: F0 06
  INC snd_chan_volume,X                             ; $DCC0: FE 06 07
  INC snd_chan_volume_sv,X                             ; $DCC3: FE 07 07
@VibratoReturn:
  RTS                                     ; $DCC6: 60
@VibratoDecrement:
  INC snd_chan_decay_ctr,X                             ; $DCC7: FE 0F 07
  LDA snd_freq_lo                               ; $DCCA: AD F7 07
  CMP #$10                                ; $DCCD: C9 10
  BEQ @VibratoReturn                                               ; $DCCF: F0 F5
  DEC snd_chan_volume,X                             ; $DCD1: DE 06 07
  DEC snd_chan_volume_sv,X                             ; $DCD4: DE 07 07
  RTS                                     ; $DCD7: 60
SoundPlay:
  JSR BattleAnimSoundEngine::ChannelMaskCheck                               ; $DCD8: 20 31 DC
  BIT snd_channel_mode                               ; $DCDB: 2C F4 07
  BVS @SoundPlayReturn                                               ; $DCDE: 70 25
  LDA snd_chan_cmd_tmr,X                             ; $DCE0: BD 15 07
  BNE @SoundPlayReturn                                               ; $DCE3: D0 20
  LDA snd_chan_hw_idx,X                             ; $DCE5: BD 01 07
  BPL @SoundPlayReturn                                               ; $DCE8: 10 1B
  AND #$70                                ; $DCEA: 29 70
  STA snd_freq_lo                               ; $DCEC: 8D F7 07
  LDA snd_frame_ctr                               ; $DCEF: AD F9 07
  AND #$0F                                ; $DCF2: 29 0F
  ORA snd_freq_lo                               ; $DCF4: 0D F7 07
  TAY                                     ; $DCF7: A8
  LDA ToneOffsetTable,Y                   ; $DCF8: B9 5E DD
  CLC                                     ; $DCFB: 18
  ADC snd_chan_freq_acc,X                             ; $DCFC: 7D 12 07
  LDY snd_reg_base                               ; $DCFF: AC F5 07
  STA $4002,Y                             ; $DD02: 99 02 40
@SoundPlayReturn:
  RTS                                     ; $DD05: 60
; --- Data Region ---
; NoteFreqTable: 16-bit note frequency divisors, indexed by the Y offset
; built in @CmdFreqScale. Lookup continues past this label into the rows below.
NoteFreqTable:
  .byte $AE,$06,$4E,$06,$F4,$05,$9E,$05,$4D,$05,$01,$05,$B9,$04,$75,$04; $DD06: AE 06 4E 06 F4 05 9E 05 4D 05 01 05 B9 04 75 04
  .byte $35,$04,$F9,$03,$C0,$03,$8A,$03,$7E,$06,$21,$06,$C9,$05,$76,$05; $DD16: 35 04 F9 03 C0 03 8A 03 7E 06 21 06 C9 05 76 05
  .byte $27,$05,$DD,$04,$96,$04,$55,$04,$17,$04,$DD,$03,$A5,$03,$71,$03; $DD26: 27 05 DD 04 96 04 55 04 17 04 DD 03 A5 03 71 03
  .byte $D9,$47,$10,$4C,$A5,$50,$71,$55,$86,$5A,$E8,$5F,$9C,$65,$A7,$6B; $DD36: D9 47 10 4C A5 50 71 55 86 5A E8 5F 9C 65 A7 6B
  .byte $0D,$72,$D5,$78,$05,$80,$A2,$87   ; $DD46: 0D 72 D5 78 05 80 A2 87
ChannelMaskTable:
  .byte $01,$02,$04,$08,$10,$20,$40,$80   ; $DD4E: 01 02 04 08 10 20 40 80 ; channel enable bit masks
ChannelModeTable:
  .byte $00,$01,$82,$43,$04,$05,$06,$07   ; $DD56: 00 01 82 43 04 05 06 07 ; per-channel mode byte -> $07F4
ToneOffsetTable:
  .byte $00,$00,$01,$01,$00,$00,$FF,$FF   ; $DD5E: 00 00 01 01 00 00 FF FF ; tone pitch delta lookup
@ChannelInitData:
  .byte $00,$00,$01,$01,$00,$00,$FF,$FF,$00,$00,$00,$00,$01,$01; $DD66: 00 00 01 01 00 00 FF FF 00 00 00 00 01 01
; --- Data Region ---
  .byte $01,$01,$00                         ; $DD74: 01 01 00
  .byte $00,$00,$00,$FF,$FF,$FF,$FF,$00,$01,$02,$01,$00,$FF,$FE,$FF,$00; $DD77: 00 00 00 FF FF FF FF 00 01 02 01 00 FF FE FF 00
  .byte $01,$02,$01,$00,$FF,$FE,$FF,$00   ; $DD87: 01 02 01 00 FF FE FF 00
@DeltaOffsetTable:
  .byte $00,$01,$01,$02,$02,$01,$01,$00,$00,$FF,$FF,$FE,$FE,$FF,$FF,$FF; $DD8F: 00 01 01 02 02 01 01 00 00 FF FF FE FE FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE; $DD9F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FE
  .byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$01; $DDAF: FE FE FE FE FE FE FE FE FE FE FE FE FE FE FE 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $DDBF: 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01                       ; $DDCB: 01 01 01
RegSelectTable:
  .byte $02,$02,$02                       ; $DDCE: 02 02 02
  .byte $02                               ; $DDD1: 02
  .byte $02                               ; $DDD2: 02
  .byte $02,$02,$02,$02,$02,$02           ; $DDD3: 02 02 02 02 02 02
  .byte $02,$02,$02,$02                   ; $DDD9: 02 02 02 02
@ThresholdTable:
  .byte $02,$F0,$E0,$D0,$C0,$B0,$A0,$90,$80,$70,$60,$50,$40,$30,$20,$10; $DDDD: 02 F0 E0 D0 C0 B0 A0 90 80 70 60 50 40 30 20 10
  .byte $00                               ; $DDED: 00
; --- Data Region (cont.) ---
@ApproachTable:
  .byte $00                               ; $DDEE: 00
  .byte $10,$20,$30,$40,$50,$60,$70,$80,$90,$A0,$B0,$C0,$D0,$E0,$F0; $DDEF: 10 20 30 40 50 60 70 80 90 A0 B0 C0 D0 E0 F0
  .byte $F0,$E0,$D0,$C0,$B0,$A0,$90,$80,$80,$90,$A0,$B0,$C0,$D0,$E0,$F0; $DDFE: F0 E0 D0 C0 B0 A0 90 80 80 90 A0 B0 C0 D0 E0 F0
  .byte $80,$90,$A0,$B0,$C0,$D0,$E0,$F0,$F0,$E0,$D0,$C0,$B0,$A0,$90,$80; $DE0E: 80 90 A0 B0 C0 D0 E0 F0 F0 E0 D0 C0 B0 A0 90 80
  .byte $F0,$D0,$B0,$90,$70,$50,$30,$10,$E0,$C0,$A0,$80,$60,$40,$20,$00; $DE1E: F0 D0 B0 90 70 50 30 10 E0 C0 A0 80 60 40 20 00
  .byte $F0,$E0,$D0,$C0,$C0               ; $DE2E: F0 E0 D0 C0 C0
  .byte $D0,$E0,$D0,$C0,$A0,$80,$60,$40,$20,$10,$00; $DE33: D0 E0 D0 C0 A0 80 60 40 20 10 00
  .byte $F0,$D0,$B0,$90                   ; $DE3E: F0 D0 B0 90
  .byte $A0,$B0,$90,$70,$60,$50           ; $DE42: A0 B0 90 70 60 50
@VolumeTable:
; --- Data Region (cont.) ---
  .byte $40                               ; $DE48: 40
  .byte $30,$20,$10,$10,$00,$40,$40,$40,$40,$40,$40,$40; $DE49: 30 20 10 10 00 40 40 40 40 40 40 40
  .byte $60                               ; $DE55: 60
  .byte $60,$70,$80,$A0,$C0,$F0,$B0           ; $DE56: 60 70 80 A0 C0 F0 B0
@VolumeScaleTable:
  .byte $80,$F0,$F0,$A0,$80,$F0,$F0,$A0,$80,$70,$70,$60,$60; $DE5D: 80 F0 F0 A0 80 F0 F0 A0 80 70 70 60 60
  .byte $50                               ; $DE6A: 50
@VolumeScaleRun:
  .byte $50,$40,$20                       ; $DE6B: 50 40 20
RegMergeTable:
  .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30; $DE6E: 30 30 30 30 30 30 30 30 30 30 30 30 30
  .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$31,$31,$31,$31,$31; $DE7B: 30 30 30 30 30 30 30 30 30 30 30 31 31 31 31 31
  .byte $31,$31,$31,$30,$30,$30,$30,$31,$31,$31,$31,$31,$31,$31,$31,$32; $DE8B: 31 31 31 30 30 30 30 31 31 31 31 31 31 31 31 32
  .byte $32,$32,$32,$30,$30,$30,$31       ; $DE9B: 32 32 32 30 30 30 31
@FreqLookupA:
  .byte $31,$31                           ; $DEA2: 31 31
  .byte $31,$31                           ; $DEA4: 31 31
  .byte $32,$32                           ; $DEA6: 32 32
  .byte $32,$32                           ; $DEA8: 32 32
@FreqLookupE:
  .byte $32,$33,$33,$33,$30,$30,$31,$31,$31,$31,$32,$32; $DEAA: 32 33 33 33 30 30 31 31 31 31 32 32
@FreqLookupF:
  .byte $32,$32,$33,$33,$33,$33           ; $DEB6: 32 32 33 33 33 33
@FreqLookupG:
  .byte $34,$34,$30,$30                   ; $DEBC: 34 34 30 30
@FreqLookupH:
  .byte $31,$31                           ; $DEC0: 31 31
  .byte $31,$32,$32,$32,$33,$33,$33,$34,$34,$34,$35,$35,$30,$30; $DEC2: 31 32 32 32 33 33 33 34 34 34 35 35 30 30
@FreqLookupI:
  .byte $31,$31,$32                       ; $DED0: 31 31 32
  .byte $32,$32,$33,$33,$34,$34,$34,$35,$35,$36,$36,$30,$30,$31,$31,$32; $DED3: 32 32 33 33 34 34 34 35 35 36 36 30 30 31 31 32
  .byte $32,$33,$33,$34,$34,$35,$35,$36,$36,$37,$37,$30,$31; $DEE3: 32 33 33 34 34 35 35 36 36 37 37 30 31
@FreqLookupJ:
  .byte $31,$32,$32,$33,$33,$34,$34,$35,$35,$36,$36,$37,$37,$38,$30,$31; $DEF0: 31 32 32 33 33 34 34 35 35 36 36 37 37 38 30 31
@FreqLookupK:
  .byte $31,$32,$32,$33,$34,$34,$35,$35,$36,$37,$37,$38,$38,$39,$30,$31; $DF00: 31 32 32 33 34 34 35 35 36 37 37 38 38 39 30 31
  .byte $31,$32                           ; $DF10: 31 32
@FreqLookupL:
  .byte $33,$33,$34,$35,$35,$36,$37,$37,$38,$39,$39,$3A,$30,$31,$31,$32; $DF12: 33 33 34 35 35 36 37 37 38 39 39 3A 30 31 31 32
  .byte $33,$34,$34,$35,$36,$37,$37,$38,$39,$3A,$3A,$3B,$30,$31,$32; $DF22: 33 34 34 35 36 37 37 38 39 3A 3A 3B 30 31 32
@FreqLookupM:
  .byte $32,$33,$34,$35,$36,$36,$37,$38,$39,$3A,$3A,$3B,$3C,$30,$31,$32; $DF31: 32 33 34 35 36 36 37 38 39 3A 3A 3B 3C 30 31 32
  .byte $33,$33,$34,$35,$36,$37,$38,$39,$3A,$3A,$3B,$3C,$3D,$30,$31,$32; $DF41: 33 33 34 35 36 37 38 39 3A 3A 3B 3C 3D 30 31 32
@FreqLookupN:
  .byte $33,$34,$35,$36,$37,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$30,$31,$32; $DF51: 33 34 35 36 37 37 38 39 3A 3B 3C 3D 3E 30 31 32
  .byte $33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F     ; $DF61: 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F
; --- Code Region: SoundPlay continuation (alternate entries) ---
SoundPlayAlt:
  JSR BattleAnimSoundEngine::ChannelMaskCheck                         ; $DF6E: 20 31 DC
SoundPlayAltEntry:
  BIT snd_channel_mode                                   ; $DF71: 2C F4 07
  BMI SoundPlayAltDirect                               ; $DF74: 30 3F
  LDA snd_chan_aux0c,X                                 ; $DF76: BD 0C 07
  BEQ @BranchDF7E                                   ; $DF79: F0 03
  JMP VolumeFreqScale                          ; $DF7B: 4C 59 DC
@BranchDF7E:
  LDA snd_chan_volume,X                                 ; $DF7E: BD 06 07
@VolumeMerge:
; --- Code Region ---
  AND #$10                                ; $DF81: 29 10
  ASL                                     ; $DF83: 0A
  ORA snd_chan_volume,X                             ; $DF84: 1D 06 07
ChannelWrite:
  LDY snd_reg_base                               ; $DF87: AC F5 07
  CPY #$10                                ; $DF8A: C0 10
  BCS @ChannelWriteNamco                                               ; $DF8C: B0 04
  STA $4000,Y                             ; $DF8E: 99 00 40
@WriteReturn:
  RTS                                     ; $DF91: 60
@ChannelWriteNamco:
  PHA                                     ; $DF92: 48
  PHA                                     ; $DF93: 48
  TYA                                     ; $DF94: 98
  ASL                                     ; $DF95: 0A
  ORA #$67                                ; $DF96: 09 67
  TAY                                     ; $DF98: A8
  STA NAMCO_CTRL                          ; $DF99: 8D 00 F8
  PLA                                     ; $DF9C: 68
  AND #$0F                                ; $DF9D: 29 0F
  ORA #$30                                ; $DF9F: 09 30
  STA $4800                               ; $DFA1: 8D 00 48
  DEY                                     ; $DFA4: 88
  STY NAMCO_CTRL                          ; $DFA5: 8C 00 F8
  PLA                                     ; $DFA8: 68
  AND #$C0                                ; $DFA9: 29 C0
  LSR                                     ; $DFAB: 4A
  LSR                                     ; $DFAC: 4A
  LSR                                     ; $DFAD: 4A
  STA $4800                               ; $DFAE: 8D 00 48
  LDY snd_reg_base                               ; $DFB1: AC F5 07
  RTS                                     ; $DFB4: 60
SoundPlayAltDirect:
; --- Code Region: Alternate sound play direct write (bypasses VolumeFreqScale) ---
  LDY snd_reg_base                                   ; $DFB5: AC F5 07
  LDA snd_chan_volume,X                                 ; $DFB8: BD 06 07
  STA $4000,Y                                 ; $DFBB: 99 00 40
  RTS                                         ; $DFBE: 60
.endproc
; --- Bank fill to $DFFF ---
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFBF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFCF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFDF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFEF: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF                                           ; $DFFF: FF
