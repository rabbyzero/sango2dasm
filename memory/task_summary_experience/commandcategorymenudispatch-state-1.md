# CommandCategoryMenuDispatch state 1 decoded in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** e4c997e5-9764-4505-83df-8483c9856bbc
- **Keywords:** CommandCategoryMenuDispatch, prg_1b_1c, frame state 1, command category menu, map scroll animation

## Content

prg_1b_1c.asm $A18B-$A294 decoded as CommandCategoryMenuDispatch (.proc, byte-exact via tools/verify_1b_1c.py, 0 mismatches). It is MapScreenFrameStateTable state 1: the strategy command category selection menu (manual pp.14-15: 城 castle / 軍隊 army / 倉 warehouse / 町 town). Sub-dispatch on $0401 via inline 2-entry table $A191: sub 0 $A195 CommandCategoryMenuScreenInit (gate on $0140 transition busy + $0304 overlay sentinel, then JSR $DD70 which resets shared menu cursor $0424/$0425 and returns A=$00; $0470 scroll counter reset, $0471 hemisphere phase <- 1, panel params $00B3/$00BD, $0140 <- $80, $0150 flag word from camera X $6F3F bit7: set->$01 else $81 with dead LDY #$40, JMP $F26D UI mode $23); sub 1 $A1D0 CommandCategoryMenuInput (B1F_MenuStep4 over table $A244 [00 01 02 03 FF FF FF FF, step 4, page 1 unreachable], cursor sprite via B1F_PointerTableLookup on $A24C per-item OAM Y/X base pairs + template $A254 [00 04 00 00 80], then $DDAD sentinel idle check C=1; Up/Down $30 -> vertical map scroll stepper $A259 CommandCategoryMapScrollStep counting $0470 0->$0A then $0471 EOR #3 toggles phase 1<->2 ORed into $0150, marker $80; A -> $0400 <- selection+2 i.e. states 2/3/4/5 = presumed castle/army/warehouse/town, B -> back to state 0; shared exit RTS at $A243). Note: $024C entries are NOT pointers; consumed by B1F_PointerTableLookup as (OAM Y base lo, X base hi) bases for B1F_SpriteOamWriterSimple whose OAM buffer order is (Y,tile,attr,X) with bases $0A/$0C.
