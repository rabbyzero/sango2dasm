# Phase 2 move-route direction resolver Loc_C20F analysis and refactoring

- **Category:** task_summary_experience
- **Memory ID:** ebdf32d3-8333-4426-bb08-d3b9dfe986d6
- **Keywords:** Phase2MoveRouteResolve, move route resolver, adjacent enemy probe, direction resolver, semantic renaming

## Content

## Task description
- Core requirement: analyze and refactor Loc_C20F in prg_0e_0f.asm (phase-2 move-route direction resolver).
- Task background: Loc_C20F ($C20F-$C30E) was raw code called from Phase2ActionGate's @MoveRoute path; it probes four orthogonal neighbours of the acting slot for adjacent enemy units but lacked semantic naming and documentation.

## Execution process
1. Read prg_0e_0f.asm around $C20F–$C30E to identify routine boundaries and call sites; confirmed single caller at $A561 in Phase2ActionGate.
2. Analyzed semantics: routine searches for adjacent ENEMY units via Phase2StepTileProbe, using randomized axis/side order and a probe counter $0010 (max 4 probes); commits direction code to $0549 and enemy slot to $054A.
3. Identified helper routines: Phase2StepTileProbe ($C1CD) for tile occupancy probe; B1F_RandomByte ($E87A) for randomization.
4. Renamed Loc_C20F → .proc Phase2MoveRouteResolve with full header comment describing algorithm and RAM usage.
5. Renamed all 18 Loc_* control-flow labels to @-prefixed semantic names: @HorizontalAxis/@VerticalAxis, @ProbeLeft/@ProbeRight/@ProbeUp/@ProbeDown, and per-direction @*Retry/@*SwitchCheck/@*FlipSide triples.
6. Updated JSR $E87A → JSR B1F_RandomByte; updated caller comment at $A561 and Phase2StepTileProbe cross-reference comment.
7. Fixed comment formatting issues (removed stray blank lines, reconnected broken line wraps).
8. Verified byte-exact match using tools/verify_0e_0f.py: 16384 bytes compared, 0 mismatches.

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_0e_0f.asm

## Notes
- Pitfall: SearchReplace operations introduced stray blank lines in comment blocks; cleaned up by re-reading and fixing text formatting.
- Full make remains blocked by pre-existing errors in prg_0a_0b/prg_17_18/prg_0c_0d; standalone harness verified byte-exactness independently.

## Task overview
Completed: refactored Loc_C20F into Phase2MoveRouteResolve with semantic naming, renamed all 18 control-flow labels to @-prefixed names, updated JSR calls symbolically, fixed comment formatting, and verified byte-exact match. Remaining roadmap: decode the attack-route resolver at $C30F as the next target.
