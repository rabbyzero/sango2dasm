# CallbackDispatcher call sites in prg_08_09.asm

- **Category:** project_introduction
- **Memory ID:** ed0c00f9-1391-4914-ae2e-36fe90cd53d0
- **Keywords:** CallbackDispatcher, prg_08_09, inline dispatcher, dispatch table, $A09E, $ACAB, $B517

## Content

In prg_08_09.asm, `.proc CallbackDispatcher` ($B517-$B535) is an inline dispatcher identical to B1F_CallbackDispatcher. It indexes an inline .word table following the JSR using A register, JMPs to the target; the handler's RTS returns to the caller of the proc containing the JSR (return address is consumed by the dispatcher). Y is preserved via $20.

Two call sites exist:

1. **$A09E** (in @AiOfficerActionDecide): FULLY ANALYZED. Index = officer state AND #$0F (values 0-7). Table at $A0A1-$A0B0. Handlers: 0=Action_DefaultDecision, 1=Action_Regroup, 2=Action_AttackNearest, 3=Action_DefendBase, 4=Action_SweepRange3, 5=Action_CaptureProvince, 6=Action_RestoreHP, 7=Action_Idle. Handler entries are plain (non-@) labels because ca65 cheap-label scoping prevents .word references across scope boundaries; internal labels use @-prefix.

2. **$ACAB** (in AiCheckActionFeasible): FIXED and fully analyzed. Index = action code in $002C (values 0-15). These 16 codes are BATTLEFIELD STRATAGEMS (计略), confirmed by the user, shared with prg_0c_0d.asm's ValidateActionTarget ($AD80) / ExecuteAction ($B02B) dispatch tables — both banks now renamed to stratagem names (see memory "Semantic renaming for CheckAction_* validation routines" for the full map). Terrain codes: 0=woods, 2=plains, 3=water, 4=mountain, 5=castle. Table at $ACAE-$ACCD emitted as 16 .word entries: AiFeasible_FireAttack (火攻), AiFeasible_Trap (陷阱) + aliases AiFeasible_FeintTroops (虚兵) / AiFeasible_AmbushStrike (要击) via `=` assignment to the shared body at $ACDB, AiFeasible_MuddyWater (乱水), AiFeasible_FireArrows (火箭), AiFeasible_FeintCounter (伪击转杀), AiFeasible_CoordinatedStrike (共杀), AiFeasible_WinOver (笼络), AiFeasible_FallingRocks (落石), AiFeasible_ChainStratagem (连环) + alias AiFeasible_WaterAttack (水攻) sharing $AD92, AiFeasible_AmbushAllSides (十面埋伏), AiFeasible_RepeatingCrossbow (连弩), AiFeasible_PillageFire (劫火), AiFeasible_QimenDunjia (奇门遁甲). Handlers compute target terrain $0028 / self terrain $0029 via $B6E5 first, then check terrain/adjacency/record-field preconditions. Region $A95C-$B130 verified byte-exact (4400 bytes, 0 mismatches) via tools/tmp_verify_b130.py harness.
