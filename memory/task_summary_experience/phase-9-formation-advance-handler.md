# Phase 9 formation-advance handler decoded in prg_0e_0f.asm ($B1EC-$B547)

- **Category:** task_summary_experience
- **Memory ID:** 279cd3f5-4bf7-49ab-a738-ae12a436461f
- **Keywords:** Phase9Advance, formation advance, prg_0e_0f, contact damage, wobble table, BankedCallbackTrampoline

## Content

## Task description
Decoded Loc_B1EC in asm/banks/prg_0e_0f.asm: the phase-9 handler of BattleOverlayDispatch ($B1EC-$B547), previously raw .byte. It is the formation-advance sequence entered from the phase-8 point-spend row-effect dispatch row 5 ($B09C, SFX $F1); on completion it re-enters phase 8 at row-effect entry 3 ($0540<-8, $0541<-3).

## Key findings
1. $B1EC: redraw acting-side overlay strip (ptr lo $0560[$0549], hi $A5, X=0, Y=$39 -> bank $19 $A000 via B1F_BankedCallbackTrampoline) then sub-dispatch on $0541 via B1F_CallbackDispatcher, 4-entry table at $B209 -> $B211/$B25B/$B2F5/$B3EF. Note the trampoline inline .word sits at $B201 (the stray $00 after JSR in old listings is the target low byte, not padding).
2. New procs: Phase9AdvanceSubDispatch ($B1EC), Phase9AdvanceInit ($B211, blanks OAM rows $00B1/$C1/$D1/$C9/$D9, loads direction $0559 from $05C2[base]>>4, row $055A from $0596[base]<<4, column $055B from $0580[base]<<4, base $0558=0/$0B), Phase9AdvanceAnimFrame ($B25B, 32 frames; direction 0/1/2/3 = row-/row+/col-/col+; off-strip bounds finish), Phase9AdvanceComplete ($B2A9, shared JMP exit), Phase9AdvanceMarkerRender ($B2AC, descriptor $B2E8 via B1F_SpriteOamWriterScroll_NoInit, wobble SBC from $B2ED), Phase9AdvanceContactTick ($B2F5, gated on $005E low nibble, 4-tick divider), Phase9AdvanceRosterSweep ($B3EF, dead units $05AC==0 cleared via $B882 and $FF-marked in $0580/$0596/$05C2), Phase9AdvanceFinish ($B440) + bare global Phase9AdvanceReturn ($B44A RTS), Phase9AdvanceContactScan ($B44B, opposing-side slots within 2 tiles), Phase9AdvanceContactCheck ($B48A, biased-compare proximity), Phase9AdvanceContactApply ($B4AA, HP $05AC subtract with clamp, exits via JMP $D7FB), Phase9AdvanceDamageRoll ($B4E3, record byte 2 via B1F_GetOfficerRecordAddr minus rand($0A)+2, +1 min; commander slots 0/$0B halve; roster type 1 divides by 3 via B1F_MathDiv16 then doubles).
3. Data: Phase9AdvanceStripDrawDesc ($B2E8, 5-byte head), Phase9AdvanceWobbleOffsetTable ($B2ED, 8 entries overlapping the descriptor tail through $B2F4), Phase9AdvanceFramePtrTable ($B349-$B3EE, 166 raw bytes; leading words index tick render records within the block).

## Notes
- Pitfalls hit: (1) manual hex transcription of the 166-byte table introduced 2 byte errors; always generate .byte rows programmatically from rom/prg/prg_0e.bin (offset = addr-$A000); (2) placing the wobble table at $B2F5 instead of $B2ED caused a +7-byte segment overflow; (3) shared exits (Phase9AdvanceComplete/Finish/Return) must be independent procs or bare globals between procs, not labels inside .proc; intra-proc far exits use @local labels (e.g. BCS @NoContact to the proc's own RTS) or branch offsets resolve to the wrong proc.
- Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches).
- Remaining roadmap: phases 5 ($CD43), 6 ($CE25), 7 ($CF67), $A ($D6BA); row-effect handlers $AF26-$B0AB partly decoded by phase-8 work.
