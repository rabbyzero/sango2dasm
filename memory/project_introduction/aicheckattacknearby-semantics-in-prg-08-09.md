# AiCheckAttackNearby semantics in prg_08_09.asm

- **Category:** project_introduction
- **Memory ID:** 6cf19bd2-ad96-4462-9580-c472b4452308
- **Keywords:** adjacent enemy scan, AI budget gate, attack target selection, 6FDD direction table

## Content

In prg_08_09.asm, `.proc AiCheckAttackNearby` ($A8A8-$A8D2) selects an adjacent enemy as attack target for the current AI officer ($6F8C). Gate: requires AI action budget $0505 >= 2 (attacking costs 2), otherwise returns C=0. It calls AiTurnProcess::AiScanAdjacentOfficers to fill $6FDD-$6FE0 (N/S/W/E entries; $FF=empty, bit7=enemy, low 7 bits=officer index), then scans the 4 directions in fixed N,S,W,E order and picks the first enemy entry: stores officer index (AND #$7F) into $6F8D, sets $6F8F=1, returns C=1. Internal labels: @CheckDirection, @NextDirection, @NoTarget. Called from Action_DefaultDecision ($A0C5), Action_AttackNearest ($A175), Action_DefendBase ($A21C), Action_SweepRange3 ($A2B9). Verified byte-exact against ROM via standalone ca65 assembly.
