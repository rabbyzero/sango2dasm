# ca65 .proc internal label scoping and multi-entry exposure pattern

- **Category:** project_architecture
- **Memory ID:** 450f7fec-e851-45d3-bf70-951281650db0
- **Keywords:** ca65, proc scoping, multi-entry procedure, file-scope alias, Proc::Inner syntax

## Content

ca65 .proc-internal labels are scope-local and cannot be referenced via bare names from outside the proc. The established project pattern for exposing inner entry points is to create a file-scope alias after the .endproc using the Proc::Inner syntax (e.g., `ActionDeltaInputPoll_CapInA = ActionDeltaInputPoll::ActionDeltaInputPoll_CapInA`). Using `.global` inside a proc does NOT make the symbol visible to outer-scope bare references; only the Proc::Inner scoped reference or the file-scope alias pattern works. This pattern is verified in prg_0a_0b.asm (ProvinceSelect_GetRecord) and applied consistently across bank files. Multi-entry procedures are used when one entry point falls through to another, such as combining address calculation and data copying into a single proc where the first entry computes an address and the second performs the copy operation.
