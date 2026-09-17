# Disassembly Procedure Spanning Non-Contiguous Entries

- **Category:** project_introduction
- **Memory ID:** 46195d03-3209-446a-ba56-3140e857d1e3
- **Keywords:** disassembly, entry points, .proc span, non-contiguous, reverse engineering

## Content

In disassembled code, when multiple entry points (e.g., `CopyScrollRegs`, `AdjustScrollAndRender`, `@main`) belong to the same logical function but are not contiguous in memory, it is acceptable to extend the `.proc` span across non-adjacent ranges if no unrelated code lies within the extended range. The procedure may include out-of-order entries as long as intervening code is part of the same logical routine.
