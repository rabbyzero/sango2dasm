# Battlefield Stratagem System with Execution Logic and Terrain Mapping

- **Category:** project_introduction
- **Memory ID:** b67a21ef-a281-4d51-9b3e-0e5e507a0b19
- **Keywords:** battlefield stratagems, terrain conditions, combat effects, AI feasibility, ROM handlers, stratagem list
- **Usage scenarios:**
  - Implementing new stratagem effects or conditions
  - Debugging AI decision-making for battlefield actions
  - Verifying terrain-based feasibility checks in combat
  - Mapping game mechanics to assembly-level handlers

## Content

The project implements a battlefield stratagem (計略) system: 16 codes (0-15) tied to terrain conditions and combat effects, used in AI feasibility checks (prg_08_09.asm) and execution/validation logic (prg_0c_0d.asm). Terrain codes: 0=Forest(林), 2=Plain(平地), 3=River(川), 4=Mountain(山), 5=Castle(城).

Canonical English names per docs/manual_kb/terminology.md (authoritative glossary): 0=FireAttack (火計), 1=PitfallTrap (陥穽), 2=FeintTroops (虚兵), 3=AmbushStrike (要撃), 4=BoatSabotage (乱水), 5=SupplyBurning (火箭), 6=CastleRaid (偽撃転殺), 7=FriendlyFire (共殺), 8=Enticement (籠絡), 9=Rockfall (落石), 10=ChainLink (連環), 11=TenfoldAmbush (十面埋伏), 12=FloodAttack (水攻), 13=SiegeArrowRain (連弩), 14=Inferno (劫火), 15=MysticalStasis (奇門遁甲).

Legacy code labels still in asm for some codes differ from the glossary and map as: 1 Trap=PitfallTrap, 4 MuddyWater=BoatSabotage, 5 FireArrows=SupplyBurning (tactical-map rice-burning stratagem, distinct from battle-mode tactic 火矢 FireArrows), 6 FeintCounter=CastleRaid, 7 CoordinatedStrike=FriendlyFire, 8 WinOver=Enticement, 9 FallingRocks=Rockfall, 10 ChainStratagem=ChainLink, 11 AmbushAllSides=TenfoldAmbush, 12 WaterAttack=FloodAttack, 14 PillageFire=Inferno, 15 QimenDunjia=MysticalStasis. Use glossary names for any NEW labels.

The system uses shared handler bodies for multiple codes (e.g., codes 1-3, 10/12) via label aliases to conserve ROM space.
