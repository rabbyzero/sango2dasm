# BattlePlayerRequestPoll and BattlePadStateFetch decoded in prg_0e_0f.asm

- **Category:** project_introduction
- **Memory ID:** c30cb4ff-548d-4580-a923-08522dcd6d2a
- **Keywords:** BattlePlayerRequestPoll, BattlePadStateFetch, input mode, pad edge raw, handoff flags

## Content

In asm/banks/prg_0e_0f.asm, Loc_A39D became BattlePlayerRequestPoll (.proc $A39D-$A3BB): called every frame from the phase-2 handler inline code ($A4F7, bytes JSR $BF4C / JSR $A39D / LDA $0541 / JSR $EADE / dispatch table $A519); fetches each pad's mode-filtered state via BattlePadStateFetch and on A-button edge (bit0 of $0001) latches handoff flags $0568 (pad1) / $0569 (pad2), consumed by Phase1NextActorSelect to jump to phase 3 with $0549 <- $0569. Loc_CCDE became BattlePadStateFetch (.proc $CCDE-$CD21, bank $0F): A = pad index selects input mode from $0562 (pad1) / $0563 (pad2); mode 1 copies pad2 edge $0085->$0000 and pad2 raw $0082->$0001, mode 3 zeros $0000/$0001 (AI-controlled side ignores physical input), otherwise pad1 edge $0083->$0000 and raw $0081->$0001; except mode 3 the raw byte OR-latches into $057B. Pad edge/raw/prev semantics per ControllerRead $E6C6 in prg_1f.asm ($0081/$0082 edge, $0083/$0085 raw, $0084/$0086 prev). All 13 in-bank JSR $CCDE sites updated to the semantic name. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches, stubs 6->5).
