# Internal procedures must nest within parent proc except when crossing segment boundaries

- **Category:** development_practice_specification
- **Memory ID:** dc124075-6732-4e9e-8ce1-53ebf6642883
- **Keywords:** internal procedure nesting, segment boundary exception, call graph, .proc scope, cross-segment procedures

## Content

When a procedure like `AiScanAdjacentOfficers` is only called internally by a parent procedure (e.g., `AiTurnProcess`) and has no external callers, it must be nested within the parent's `.proc` block as a local label rather than defined as a separate top-level `.proc`. This ensures logical grouping, scope encapsulation, and adherence to the project's call-graph-based nesting convention.

## Exception: Segment Boundary Constraint
If the internal procedure resides in a different `.segment` (PRG bank) than its caller, it CANNOT be nested. For example, `BattleChrBankAnimate` (CODE_BANK0F) is called from `BattleVBlankFrameUpdate` (CODE_BANK0E); since they span different segments, `BattleChrBankAnimate` must remain a top-level `.proc` despite having no external callers. This is because ca65 does not support `.segment` switches inside `.proc` blocks, and nesting would break the assembly structure.

## Re-evaluation Trigger
Re-evaluate nesting decisions when: (1) the potential child proc has external callers (must be top-level regardless), or (2) the child proc is in a different segment than the parent (must be top-level).
