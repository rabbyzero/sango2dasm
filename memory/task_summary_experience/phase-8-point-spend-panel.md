# Phase 8 point-spend panel decoded in prg_0e_0f.asm ($ACC5-$AEAD)

- **Category:** task_summary_experience
- **Memory ID:** 1ae87289-b0eb-4e00-96ac-025446c6da58
- **Keywords:** Phase8Panel, point-spend panel, row effect dispatch, tier row lists, prg_0e_0f

## Content

## Task description
Decoded Loc_ACC5 in asm/banks/prg_0e_0f.asm: the phase-8 handler of BattleOverlayDispatch ($ACC5-$AEAD plus tables to $AF25), previously raw .byte. It is the point-spend panel entered from Phase3CommandInput::@Commit ($AB3B) when step-0 action slot == 4 and side status counters $0574-$0577 are clear. Follow-up pass decoded the six row-effect handlers ($AF26-$B0AB), the reload-roll helper, and the row-script queue/table ($B0AC-$B15A).

## Key findings
1. $ACC5: overlay strip redraw (ptr lo $0560[$0549], hi $A5, X=0, bank $19 $A000) then sub-dispatch on $0541 via B1F_CallbackDispatcher. The sub table at $ACE2 has 5 entries (not 3): $ACEC/$AD3C/$AD5D/$AE11/$AE8E — the old disasm only split 3 entries, leaving $AE11/$AE8E misread as .byte.
2. Panel procs: Phase8PanelSubDispatch ($ACC5), Phase8PanelInit ($ACEC, tier ladder <5/<7/<8/<$A/<$C on budget $0572[$0549] into $054A; UI $E7; panel $044C<-budget, $00BD<-$57, $0424/$0425 clear), Phase8PanelScriptStep ($AD3C), Phase8PanelMenuInput ($AD5D, B1F_MenuStep2 + B1F_PointerTableLookup; A deducts @RowCostTable $ADDF=3/5/7/8/$A/$C then JMP Phase8RowEffectDispatch; B cancels to phase 3 sub 3), Phase8PanelConfirmWait ($AE11, $0562[$0549]==3 -> BattleBothPadsStateFetch + resume latch $054B/$054C<-1), Phase8PanelReturnToCommand ($AE6C), Phase8PanelAdvanceWait ($AE8E, A -> phase 5 sub 0), Phase8PanelReturnToCommandDup ($AEAE, unreferenced duplicate).
3. Tables: Phase8TierRowPtrTable ($AED0, tier t -> rows 0..t), Phase8Tier5..0Rows ($AEDC-$AEFF), Phase8RowCursorCoords ($AF00, y,x words 2x3 grid), Phase8RowCursorParams ($AF0C).
4. Row effects (Phase8RowEffectDispatch $AF11, table $AF1A in ROM order of procs): Phase8RowCoinFlip ($AFD2, B1F_RandomByte bit0; hit: UI $EC, $042C <- opposing unit $0560[$0549^1], falls through to Phase8RowCounter574; miss: UI $ED), Phase8RowStatCheck ($AF26, auto-fails when battle scene phase $0544==5 on side A; chance = floor(2*max(0,rankEdge)/10)+32-opponent troops via B1F_MathDiv16(divisor 10, dividend lo $000A) + B1F_RandomBelowThreshold(100); rank=officer record field[$B]>>4, troops=field[2], success UI $EA sub<-4, failure UI $EB sub<-3), Phase8RowCounter575 ($B00E, UI $EE, counter 575<-3 own nibble), Phase8RowCounter576 ($B02E, UI $EF, counter 576<-4 own nibble + $056A/$056B saved to $0578/$0579 then += 5+rand[0,5) via Phase8RowReloadRoll $B066), Phase8RowCounter577 ($B07C, UI $F0, counter 577<-3), Phase8RowAdvance ($B09C, phase<-9 sub<-0 UI $F1). Counters set the acting side's nibble ($0574 low=sideA/high=sideB etc.).
5. Phase8RowScriptQueue ($B0AC) copies FF-terminated Phase8RowScriptTable[$0548] scripts into $0380 and sets $007E bit2; table $B0D5 points to Phase8RowScript1/0/2/3/4/5 at $B0E1/$B0F7/$B108/$B119/$B133/$B145 (physical order row1 first). Script header byte = $04 (rows 0/1/2/4/5) or $08 (row 3), then nametable row $22/$23 + tile runs + $01 fill.

## Notes
- Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches) after each pass.
- Pitfall: old disasm hex comments can mislabel row boundaries — row-3 script first byte is $08 at $B119 (the $B115 comment line "…08 23 12" straddles FF at $B118); always verify splits against rom/prg/prg_0e.bin.
- Pitfall reconfirmed: sub-dispatch tables inside raw .byte blobs are often under-split; decode the full table by checking where the next real code label starts.
- Remaining roadmap: phases 5 ($CD43), 6 ($CE25), 7 ($CF67), $A ($D6BA) still raw (phase 9 decoded by user as Phase9AdvanceSubDispatch).
