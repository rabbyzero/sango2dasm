# Procedure encapsulation decision for BattleResultSlotTemplateApply

- **Category:** important_decision_experience
- **Memory ID:** a780f1d1-c291-45c3-bf1c-eac08209009c
- **Keywords:** procedure encapsulation, data tables, proc scope, namespace pollution, NES disassembly
- **Usage scenarios:**
  - When refactoring NES 6502 assembly to organize procedure-specific data
  - When deciding whether to keep data tables inside or outside proc scope

## Content

## Conclusion
BattleResultSlotTemplateApply proc encapsulates its exclusive data tables (BattleResult_SlotRecordPtrs and BattleResult_SlotRecordTemplate) within its .proc scope, with padding correctly set to .res $032C for $DCD4-$DFFF.

## Rationale (trade-off)
Encapsulating procedure-specific data inside the proc reduces global namespace pollution and promotes locality; keeping data outside would make the proc harder to understand in isolation and could lead to accidental external references.

## Rejected alternatives
- Scattering data tables globally after the proc end - this was considered but rejected because it violates encapsulation principles and makes the proc's dependencies less obvious.

## Applicable / expiry conditions
Holds when a procedure has data tables or subroutines that are exclusively used by that procedure and have no external references; re-evaluate if the data needs to be shared across multiple procedures or if external symbolic references are required.
