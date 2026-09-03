# Bank-wide terminology alignment commit (battle->war) across PRG banks

- **Category:** task_summary_experience
- **Memory ID:** ae4821b4-d08d-4b50-af5a-183eeb2c86f9
- **Keywords:** sango2dasm, terminology alignment, war vs battle, bank assembly, functions.h, git commit, build verification
- **Usage scenarios:**
  - When reviewing large terminology refactor commits
  - When tracing bank-level symbol renames
  - When verifying build checks before committing

## Content

Completed a large-scale terminology alignment commit (118 files) in sango2dasm: renamed battle->war labels across PRG bank assembly files (prg_08_09, prg_0a_0b, prg_0c_0d, prg_0e_0f, prg_17_18, prg_1d_1e), updated cross-bank symbols in include/functions.h (CombatCalc->WarClash, BattleResult->WarResult, BattleSetup->WarSetup), corrected menu action names (LandDevelop->LandReclamation, FloodControl->DisasterPrevention, CastleRepair->UnidentifiedCmd), changed Kingdom->Country in template pointer equates, fixed stratagem table (雲梯->連弩), updated documentation (terminology.md, 06-reference-tables.md), and added font/charmap analysis tools with outputs. Workflow: git status -> git diff analysis -> make build check (pre-existing duplicate-symbol errors observed) -> check_baseline.py and check_diff.py -> git add -A -> git commit with descriptive message. Commit hash recorded as 2680b80.
