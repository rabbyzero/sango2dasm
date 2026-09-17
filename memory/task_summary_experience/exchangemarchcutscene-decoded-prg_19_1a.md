# ExchangeMarchCutscene decoded at prg_19_1a.asm $CFD6-$D7FE

- **Category:** task_summary_experience
- **Memory ID:** 463e0571-eae2-458b-a732-fc8cfef7aeef
- **Keywords:** ExchangeMarchCutscene, prg_19_1a, CFD6, callback dispatcher, inline dispatch, troop exchange, scene table, byte parity

## Content

## Task
Code analysis of prg_19_1a.asm $CFD6 (unnamed Loc_CFD6 region) following the Verify/Replace/Rename/Fix/Explain workflow.

## Finding: ExchangeMarchCutscene ($CFD6-$D7FE, bank $1A)
Per-frame war-screen cutscene called from NmiState3_Battle (prg_1f $F945, banks $19/$1A mapped via Y=$39), self-gating on $04C8: 0=idle; 1..$7F=trigger from 0c_0d CommandState_Confirm (stores move_path_total+1 at $AA5E; start scene=$04C8-1); $80=phase 1 (BG panel build, 5 steps at $D425, $04CA cursor); $81=phase 2 (11-scene sprite animation, table at $D034, $04C9 scene index, transitions via 16-byte $D549 table next=tbl[$04C9]>>1). Phase 2 per frame draws a 12-sprite marching formation from bank-$11 record $8DB4+id*13 (id=$0664[$0509], positions $D38B), scene sprite-block lists at $D85F (11 words), OAM blocks via $D2C9/$D2CB -> B1F_SpriteOamWriterSimple. Ends when $04D0==$B0: clears $04C8 (releases 0c_0d CommandState_ShowResult which polls exchange_result_cnt==0), trampolines Y=$3D to B1D_1E_LoadScenarioData, restores exchange tiles $88/$89/$8A into $00C2-$00D5, note $1D via B1F_SoundWrapperA. Entry gate requires sentinels $0300==$FF and $0304==$FF.

## Key decode corrections
- Dispatcher table alignment: B1F_CallbackDispatcher reads entry A at (ret_addr+1+2A) where pushed ret = last JSR operand byte, so tables start at JSR_addr+3, NOT +4. The byte at $D034 (was disassembled as "LSR") is table entry 0 low byte -> entry 0 = $D04A (scene-0 handler), 11 entries total ending $D049.
- $D00C region: .word $D41F/$D010 phase table + code at $D010 (INC $D0/JSR $D2EA/LDA $04C9; old "CMP #$04" at $D017 was the AD C9 04 operand of LDA $04C9).
- $D3EA: .word $A015 = B1D_1E_LoadScenarioData trampoline target (Y=$3D -> bank pair $1D/$1E), NOT bank-$19 SortieWarCommit.
- $D0AC 12-byte palette-cell table (4 triples) / $D0B8 scene-2 handler; $D549 is a 16-byte table ($D552 was its tail); $D692 = 11x8-byte per-scene palette chunks; $D751 = 11-entry per-scene note table ($88->WrapperC, $95->WrapperE, else D).
- $D7FF-$DE2B regenerated as data: BG strips (base $D7FF embedded via #$FF+ADC immediates), $D85F lists, per-scene block lists at $D875/$D8EA(shared scenes1-2)/$DA2F/$DAB0/$DB94/$DC0A/$DC5E/$DCDC/$DD69/$DDFA (1-4 OAM blocks each, parsed by pointer-validity scan 0xD87B-0xDE2B).

## Changes
asm/banks/prg_19_1a.asm: .proc ExchangeMarchCutscene wrap, semantic @-labels, fixed tables, entry stub renamed ExchangeMarchCutscene_Entry; prg_1f.asm caller -> B19_1A_ExchangeMarchCutscene; functions.h new equate $A00F; cpu_ram_map.md $04C8-$04D1 alias updates. Verified tools/verify_19_1a.py: 16384 bytes, 0 mismatches. Scripts: tools/tmp_cfd6_rewrite.py, tmp_cfd6_cleanup.py, tmp_cfd6_realign.py, tmp_check_cfd6_refs.py, tmp_check_coverage.py, tmp_fix_labels_colon.py.

## Pitfalls hit
- Regenerating data rows from a non-16-aligned start ($D7FF) overran the region end by 10 bytes (loop must clamp last row to region end) - caused ld65 segment overflow.
- Fish shell: no heredocs/for-loops in Bash tool; use python script files.
- Whole-file "dominant comment column" heuristics fail on mixed-alignment banks; realign only the rewritten region (col 42 for prg_19_1a).
