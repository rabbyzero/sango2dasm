# WarehouseCommandDispatch re-application with corrected naming after revert

- **Category:** task_summary_experience
- **Memory ID:** 37440d2a-5a97-477d-818f-92e6aa61f894
- **Keywords:** WarehouseCommandDispatch, prg_1b_1c.asm, revert recovery, zero drift verification, Ataeru gift, naming correction

## Content

## Task description
- Core requirement: Re-apply the full WarehouseCommandDispatch decoding and refactoring to prg_1b_1c.asm after the user reverted previous changes
- Task background: The WarehouseCommandDispatch routine ($B759-$BFB6) implements the warehouse command screen from the game manual (p.26): 物資を運ぶ (goods transport, subs 2-4), 与える to subordinate generals (subs 6-9), and 与える to populace (subs $0A/$0B). Previous decoding was reverted, requiring full re-application with corrected naming (user pointed out earlier "Field/Troop/Supply" names were wrong for warehouse context).

## Execution process
1. Verified baseline clean state with tools/verify_1b_1c.py (16384 bytes, 0 mismatches)
2. Applied chunk 1: line 62 state-table entry, header documentation, .proc start, 16-entry dispatch table at $B75F, sub-state 0 initialization
3. Applied chunk 2: sub-states 1-2 (command menu input, province selection) with corrected @MenuToGive label
4. Applied chunk 3: sub-states 3-4 (goods amount panel, transfer apply logic)
5. Applied chunk 4: sub-state 5 (与える submenu with corrected Give/OfficerGive naming)
6. Applied chunk 5: sub-state 6 (officer gift resource menu)
7. Applied chunk 6: sub-states 7-8 (gold/treasure give flows with $BC06 trampoline fix)
8. Applied chunk 7: sub-states 9 and $0A (officer apply, populace amount panel)
9. Applied chunk 8: sub-state $0B, result states $0C-$0F, helpers WarehouseAmountDiv10 and WarehouseSliderScale10, .endproc closure
10. Verified byte-exactness: tools/verify_1b_1c.py confirmed 0 mismatches
11. Checked for stale references: zero Loc_B7xx-BFxx tokens remain in region

## Related files
- asm/banks/prg_1b_1c.asm

## Notes
- User previously identified that "Field/Troop/Supply" naming was incorrect for warehouse commands; corrected to "Give/OfficerGive/Populace" naming aligned with game manual terminology (与える = Ataeru/give)
- Three data-as-code regions decoded: $B86E (.word $A018 + code), $BC06 (.word B1D_1E_OfficerDisplay_Lookup), $BF3B (similar pattern)
- Record-field identifications verified: province +$0B =統治度 (cap 100), officer +$03 =忠誠度 (cap 99), +$10 = treasure count
- Full make still has pre-existing Loc_* collision issues at $Dxxx addresses unrelated to this work

## Task overview
Completed: Successfully re-applied full WarehouseCommandDispatch decoding with corrected naming baked in on first pass (no intermediate wrong names). Zero byte drift verified. All ~60 @-labels applied, three data-as-code fixes implemented, helpers documented. Ready for next phase (state 5 town screen or other bank work).
