# BattlePanelStatsRefresh decoded in prg_0e_0f.asm ($CBF1-$CCA7)

- **Category:** task_summary_experience
- **Memory ID:** f3df5ee1-2df9-42b2-83aa-1abe79c38a56
- **Keywords:** BattlePanelStatsRefresh, ClassTroopSum, panel field block, unit class totals, roster codes

## Content

## Task description
Decoded prg_0e_0f.asm $CBF1-$CCA7 via the Code Analysis Workflow: wrapped in .proc BattlePanelStatsRefresh with internal @ClassTroopSum helper ($CC7A); updated 8 call sites ($A115, $A249, $AB6A, $AE0D, $AE68, $AE8A, $AECC, $D727) and their header comments.

## Key findings
1. $CBF1 rebuilds the battle status panel troop-count field block $044C-$046C (8 fields, stride 3 = lo/hi/reserved): field 0 = side A commander troop count (<- $05AC), field 1 = side B (<- $05B7), then 16-bit per-side totals for unit classes 1/2/3 at $0452/$0455/$0458/$045B/$045E/$0461. This is the panel data behind the manual's 体/騎/弓/歩 display (p. 31: 体73/騎97/弓179/歩700).
2. @ClassTroopSum ($CC7A): A = class, Y = roster base (0 = side A, $0B = side B); sums $05AC,Y over 11 slots whose roster code low nibble ($05C2,Y & $0F) matches; 16-bit result in $0001/$0002; empty ($FF) and commander (nibble 0) slots never match.
3. Class-to-piece mapping (inferred from BattleRosterSetup grade limits + manual composition tables): 1 = infantry 歩兵, 2 = archer 弓隊, 3 = cavalry 騎馬; commander = class 0 (slots 0/$0B).
4. Prior "enqueue anim via $CBF1" comments were inaccurate: callers enqueue the tile animation themselves via $0310/$0311/$0300 writes; $CBF1 only refreshes the panel stats block.

## Notes
- Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches, 10 external stubs unchanged).
- The initial grep for JSR $CBF1 missed the $D727 site (undecoded Loc_D6DD block); always grep for the address token itself, not only in known decoded regions.

## Task overview
Fully decoded and renamed the $CBF1-$CCA7 panel stats refresh pair with zero byte drift.
