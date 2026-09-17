# Circular dependency in computed address operands for trampoline returns

- **Category:** common_pitfalls_experience
- **Memory ID:** 3d4bda29-6356-4cf1-b8e8-1ff5826464c6
- **Keywords:** circular dependency, computed address, trampoline return, self-referential, assembly operand

## Content

## Bug class: Circular dependency in computed address operands
Root cause: Using an expression like `@label - 1` as an operand creates a self-referential calculation where the operand value affects the label's address, which in turn affects the operand value. For example, `#<(@return_addr-1)` where `@return_addr` is defined at $EE4D: the PHA instruction size (1 byte) determines whether @return_addr - 1 = $EE4C, but if you change the operand from hard-coded to symbolic, the instruction size might change, breaking the calculation.

Fix pattern: Keep hard-coded immediate values (e.g., `#$EE`, `#$4C`) for operands that are part of a self-referential trampoline return mechanism. Add a clarifying comment explaining the relationship between the magic numbers and the target address (e.g., `; $EE44: A9 EE  return addr low = $EE4C`). The symbolic form `#<(@return_addr-1)` can be used ONLY when the instruction size is fixed and known not to change.

Reusable lesson: Don't use computed address expressions like `@label - N` for operands in self-referential structures because the operand value affects the label's position, creating a circular dependency; instead use hard-coded values with explanatory comments. Applies when implementing banked callback trampolines or similar mechanisms where the return address points back into the same procedure; does not apply to standard forward/backward references where the label position is independent of the operand.
