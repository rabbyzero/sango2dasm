# Battlefield Stratagem Naming in prg_0c_0d.asm

- **Category:** development_code_specification
- **Memory ID:** b1c06a9d-faf8-4615-8225-6e71f48ffba0
- **Keywords:** stratagem naming, prg_0c_0d, assembly labels, battlefield actions

## Content

The action codes 0-15 in prg_0c_0d.asm are BATTLEFIELD STRATAGEMS (计略), not strategic commands. The `ValidAction_*` and `ExecAction_*` labels have been renamed to `ValidStratagem_<Name>` and `ExecStratagem_<Name>` using the canonical names: 0=FireAttack, 1=Trap, 2=FeintTroops, 3=AmbushStrike, 4=MuddyWater, 5=FireArrows, 6=FeintCounter, 7=CoordinatedStrike, 8=WinOver, 9=FallingRocks, 10=ChainStratagem, 11=AmbushAllSides, 12=WaterAttack, 13=RepeatingCrossbow, 14=PillageFire, 15=QimenDunjia. Shared handlers use `=` aliases to maintain ROM byte-exactness.
