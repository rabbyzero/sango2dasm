# HospitalWoundedRosterBuild decoded in prg_1b_1c.asm ($DC7C-$DCCF)

- **Category:** task_summary_experience
- **Memory ID:** 38a33d37-c7ae-41d6-be1f-fda898ea8db7
- **Keywords:** HospitalWoundedRosterBuild, hospital roster, Vitality seed compare, prg_1b_1c, wounded officers

## Content

## Task description
- Analyze Loc_DC7C in prg_1b_1c.asm ($DC7C-$DCCF, bank $1C): full code analysis workflow, wrap as .proc, convert Loc_ labels to @-style, naming per terminology.md / 04-strategy-commands.md.

## Execution process
1. Decoded behavior: hospital (病院) candidate roster builder for the current province ($0402). Officer is "wounded" when RAM officer record Vitality (+0, B1F_GetOfficerRecordAddr $F2D7) differs from ROM seed Vitality (+0 of bank-$31 master record, B1F_GetOfficerRomRecordAddr $F387). Fills work slots $0151-$015A (base $0140 + roster offsets $11-$1A) with $FF, then rescans the province roster (+$11-$1A via province ptr in $10/$11 from B1F_GetProvinceRecordAddr) and compacts surviving ids to the front.
2. Key insight: ROM officer record +0 is Vitality (docs/officer_data.md), NOT owner; cpu_ram_map.md's "owner code" table at that spot is the province record. The Vitality-vs-seed compare is what makes the list "wounded officers" for the hospital (heals 体力).
3. Named .proc HospitalWoundedRosterBuild; locals @FillIdleSlots / @RosterScan / @ScanNext; replaced raw JSR $F2AF/$F387/$F2D7 with B1F_ symbolic names; updated sole caller @ActionHospital ($C0E1) to JSR HospitalWoundedRosterBuild.
4. Verified with tools/verify_1b_1c.py: 16384 bytes, 0 mismatches.

## Notes
- Sole caller context: @ActionHospital routes $0151==$FF to the idle message; otherwise opens officer selection ($0401=$0A).
- Adjacent unlabeled region $DCD0-$DD24 (referenced by JSR $DCD0 at $C04D) is code (message/dialog ptr selector with entries $DCD0/$DCF2/$DD09/$DD1D tail-JMPing $DD1D -> JMP $ED28), still mislabeled as a Data Region in the file — candidate for a follow-up decode.
