# Town command frame state handler decoding in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** fba40731-a120-4f15-8862-4589fa634375
- **Keywords:** Town command, frame state handler, sub-state dispatch, market operations, armory purchase, officer equipment, @-label style, prg_1b_1c

## Content

## Task description
- Core requirement: analyze and document the Town (町) command screen frame state handler at Loc_BFB7 in prg_1b_1c.asm, converting label styles to @-prefix for local labels and aligning naming with terminology.md and 04-strategy-commands.md
- Task background: WarehouseCommandDispatch ended at $BFB6; Loc_BFB7 begins a new large region ($BFB7-$CADE ≈ $B28 bytes) representing state 5 of the map frame-state dispatch table. The region contains 24 sub-state handlers accessed via inline .word table at $BFBD-$BFFC, implementing town commands including market operations (buy/sell rice, sell treasure), academy training, armory purchases with officer equipment updates, and various UI modes.

## Execution process
1. Identified region boundaries: Loc_BFB7 entry point followed by WarehouseCommandDispatch's .endproc; region ends at Loc_CADF (state 6 start) after sub-state 23's RTS at $CADE
2. Mapped dispatch structure: CallbackDispatcher target at $EADE with 24 sub-state entries ($BFED-$C9EF); confirmed state 5 = Town (町) via CommandCategoryMenuDispatch mapping (item 3 → $0400=5)
3. Decoded sub-state behaviors:
   - Sub 0 ($BFED): initial setup, message window init
   - Sub 1-2 ($C04D/$C136): Market rice buy/sell flows (Gold/Rice transactions)
   - Sub 3 ($C1C1): Treasure sell flow (Treasure -= amount, Gold += amount×100)
   - Sub 6 ($C339): Rice purchase from province (+$04 Rice field)
   - Sub 8 ($C414): Treasure sale to province (+$02 Gold field)
   - Sub 12 ($C515): Officer display lookup via banked call B1D_1E_OfficerDisplay_Lookup
   - Sub 13-15 ($C547-$C5D7): Immediate overlay displays (year, gold, rice amounts)
   - Sub 19-23 ($C76E-$C9EF): Armory purchase flow with weapon/armor equipping (+$0A officer record field)
4. Verified banked callback targets: $A02A = B1D_1E_OfficerDisplay_Lookup, $A024 = B1D_1E_ImmediateOverlay; resolved confusion about bank 8 $A01E (ExpandFormationSlots is battle-specific but called with Y=$28 → pair 08+09)
5. Confirmed province record fields from docs/province_data.md: +$02 Gold, +$04 Rice, +$10 Treasure; officer record +$0A = Weapon/Armor bits (bits 0-4 weapon, 5-7 armor)
6. Applied label style: converted Loc_BFED-Loc_CADE sub-handler labels to @-prefix for local-only references (table-dispatched only); retained bare globals for cross-bank stubs (B1D_1E_* names)
7. Resolved bank boundary at $BFFF (.segment "CODE_BANK1C"): verified cross-boundary instruction segmentation rule (STA $0473 split across segments preserved as .byte + .word)

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_1b_1c.asm (read and analyzed ~1200 lines of code region)

## Notes
- Banked callback target bank must be decoded from LDY value (Y & $1F mask), not caller context; Y=$28 selects PRG pair 08+09, Y=$39 selects 19+1A
- ExpandFormationSlots at bank 8 $A01E is battle-specific (formation slot expansion); its use in armory context was initially puzzling but likely represents shared data-lookup logic or misnamed function
- Verification harness (tools/verify_1b_1c.py) only recognizes Loc_[0-9A-F]{4} labels as defined-in-bank; renaming to @-labels would break its defined-set tracking if used externally
- Fish shell requires `begin; end` blocks for loops; bash -c wrapper needed for multi-command scripts

## Task overview
Partially completed analysis: fully mapped the Town command region structure, identified all 24 sub-state behaviors with functional descriptions, confirmed terminology mappings (Town/町, Market/商店, Academy/学問所, Armory/武器屋), and applied @-label style for local sub-handlers. Full procedure wrapping and documentation comments still pending; byte-exact verification harness not yet run on modified file.
