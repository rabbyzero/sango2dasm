# Cross-bank function rename scope boundary decision

- **Category:** important_decision_experience
- **Memory ID:** e4ea6a05-6fbe-44ac-9143-1183214af0f4
- **Keywords:** cross-bank function rename, bank-local naming, scope management, terminology update, engineering trade-off
- **Usage scenarios:**
  - Deciding whether to include bank-local names in cross-bank terminology updates
  - Managing scope when renaming symbols across multiple banks
  - Prioritizing terminology corrections vs full bank refactoring

## Content

Conclusion: When updating terminology that affects cross-bank function names, leave bank-local names unchanged if they're tightly coupled with RAM equates and procedures across that entire bank; instead, flag as a separate bank-wide refactoring task.

Rationale (trade-off): Renaming only the cross-bank equates (B17_18_DomesticDisplay, B17_18_DomesticActionDispatch) without renaming the corresponding definitions in prg_17_18.asm would create inconsistency between the equate and the actual label. However, renaming everything in prg_17_18.asm would require changing RAM equates (domestic_work_ptr_*), procedure names (DomesticDisplay, DomesticActionDispatch), and their call sites—a much larger scope that risks introducing errors and is beyond the current task's focus. The decision prioritizes completing the core terminology correction (prg_1f.asm, functions.h, terminology.md) while deferring the bank-wide cleanup.

Rejected alternatives:
- Rename everything immediately including prg_17_18.asm's internal names—dropped because the scope is too large and introduces unnecessary risk for a terminology-only task
- Leave the cross-bank equates unchanged—dropped because it creates inconsistency with the canonical naming established in prg_1f.asm

Applicable / expiry conditions: Holds when the target bank has tightly-coupled internal naming (RAM equates + procedures + entry labels all using the same legacy term); re-evaluate when doing a full bank refactoring or when the bank is being rewritten from scratch.
