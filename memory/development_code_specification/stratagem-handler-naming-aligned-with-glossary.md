# Stratagem handler naming fully aligned with glossary in prg_0c_0d and prg_08_09

- **Category:** development_code_specification
- **Memory ID:** 57f9a843-4c4e-40dd-8d18-3c85eb21cdf7
- **Keywords:** semantic naming, validation routines, action dispatch, assembly labeling

## Content

COMPLETED and glossary-aligned: the action codes 0-$0F shared by prg_0c_0d.asm's ValidateActionTarget/ExecuteAction and prg_08_09.asm's AiCheckActionFeasible are BATTLEFIELD STRATAGEMS (计略). prg_0c_0d.asm uses ValidStratagem_<Name>/ExecStratagem_<Name>; prg_08_09.asm uses AiFeasible_<Name>; functions.h exposes B08_09_AiFeasible_<Name>. All handler names now use the canonical glossary terms from docs/manual_kb/terminology.md: 0=FireAttack (火計), 1=PitfallTrap (陥穽), 2=FeintTroops (虚兵), 3=AmbushStrike (要撃), 4=BoatSabotage (乱水), 5=SupplyBurning (火箭), 6=CastleRaid (偽撃転殺), 7=FriendlyFire (共殺), 8=Enticement (籠絡), 9=Rockfall (落石), 10=ChainLink (連環), 11=TenfoldAmbush (十面埋伏), 12=FloodAttack (水攻), 13=SiegeLadder (雲梯; manual describes rain-of-arrows effect, slot identity uncertain), 14=Inferno (劫火), 15=MysticalStasis (奇門遁甲). Terrain codes: 0=Forest(林), 2=Plain(平地), 3=River(川), 4=Mountain(山), 5=Castle(城). Aliases: FeintTroops/AmbushStrike = PitfallTrap (valid + AI), FloodAttack = ChainLink (valid + AI), ExecStratagem_CastleRaid = ExecStratagem_FireAttack. Helpers: ExecStratagem_FriendlyFireNeighbor, ExecStratagem_ChainLinkProcess, ExecStratagem_FloodAttackProcess, ExecStratagem_InfernoCheck, ExecStratagem_InfernoCalc; shared calc helpers CommandPhase_DrainCalc/LoyaltyDrainCalc/StatDrainCalcA/B. prg_0c_0d.asm also uses country_param_copy ($046C, formerly kingdom_param_copy). Exec-table positions map procs differently than the validation table (ROM tables genuinely differ). Rename applied via tools/tmp_rename_0c_0d.py; byte-neutrality proven via identical ca65 error sets and identical embedded byte annotations for both banks.

--- Historical (superseded naming, for reference only) ---
Pre-glossary names replaced: Trap, MuddyWater, FireArrows, FeintCounter, CoordinatedStrike, WinOver, FallingRocks, ChainStratagem, AmbushAllSides, WaterAttack, RepeatingCrossbow, PillageFire, QimenDunjia. Even older: ValidAction_CalcGold/DomesticOps/... and ExecAction_Recruit/Train/...
