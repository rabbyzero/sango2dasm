# AttractDemoDispatch Loc_A033 decoded in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** 6619948b-7512-4ea2-b794-640a177c5db6
- **Keywords:** AttractDemoDispatch, frame state $0B, demo rotation, Country records, misclassified code recovery

## Content

## Task description
Analyze and semantically decode Loc_A033 in asm/banks/prg_19_1a.asm (banks $19+$1A), applying results with byte-exact verification.

## Findings
1. Loc_A033 = AttractDemoDispatch: frame state $0B handler of the map-screen frame machine (entered from prg_1b_1c MapScreenFrameStateDispatch via entry $A003, Y=$39) — the title-screen attract demo run when no game is active. Implemented as `.proc AttractDemoDispatch` ($A033-$A19E): dispatch head by $0401 via B1F_CallbackDispatcher + inline .word table of four inner sub-state entries: CountrySelect ($A041), OverlayInit ($A12C), OverlayPoll ($A15E, shared exit label OverlayPollExit at $A185), ResetCheck ($A186). Entry stub $A003 = AttractDemoDispatch_Entry does JMP AttractDemoDispatch.
2. Demo RAM: $6F00 demo year counter (init $59 by SramInit $DD8B in prg_1d_1e), $6F01 rotation step (0-$0B), $6F03 focused Country slot, $6F04 frame divider (0-6), $6F05 province-count display value, $6F06 camera-focus phase flag, $6F45 rotation order index 0-4 (random). Country records: 7 x 8 bytes at $6F07..$6F37, [0]=Ruler id ($FF empty), [1]=home Province.
3. Tables inside the proc: CountryRecordPtrTable $A0D6 (duplicate of B1F CountryDataPtrTable), ProvinceCountDisplayTable $A0E4 (32 entries), AttractCountryOrderTable $A104 (5 rows x 8, each a permutation of slots 0-6). Camera targets from bank-$1A tables $C737 (X)/$C755 (Y) per Province; camera position = $6F3F/$6F41 used by MapRulerMarkerDraw.
4. Helpers (bare globals, outside the proc): ProvinceCountByOwner $A19F, MarkerSpriteDraw $A1C2 (+MarkerSpriteData $A1E6, 14 callers bank-wide), FindOfficerProvince $A1EB (scans province roster offsets $11-$1A), DecayCountryTimers $A209, AttractDemoCensusBuild $A240 (237 officers, gate: <30 unclaimed ends demo via overlay $D5).
5. Two code regions had been misclassified as .byte after JSR B1F_BankedCallbackTrampoline inline words and were re-disassembled: $A0BD-$A0D5 (trampoline to $A01E->JMP $C435 stats machine, then stores home province, sets $0400=$0A camera-focus frame state) and $A165-$A184 (trampoline to $A021->JMP $AFE5, overlay sentinels $0300/$0304, Start exits to frame state 0).
6. Province record layout confirmed: byte 0 low nibble = owner Country; offsets $11-$1A = 10-slot Officer roster; officer records id*12+$63C0, flag byte offset $0B.
7. Style follow-up: user converted MapProvinceDirtyMark ($BBDE) to .proc with inner secondary entry ByZone referenced as MapProvinceDirtyMark::ByZone; AttractDemoDispatch was then wrapped the same way (.proc with inner sub-state labels).

## Verification
tools/verify_19_1a.py: compared 16384 bytes, 0 mismatches after every edit round.

## Related files
asm/banks/prg_19_1a.asm (modified), asm/banks/prg_1b_1c.asm + prg_1d_1e.asm (caller context only).
