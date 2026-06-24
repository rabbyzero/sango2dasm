# Rename Sub_AD9F to SetScrollWorkOffset4

## Context
`Sub_AD9F` at `$AD9F` copies scroll registers (`$008E`-`$0091`) to the working scroll area (`$000C`-`$000F`) with scroll X offset by +4. It is functionally identical to `CopyScrollRegs` but adds 4 to the X value. The name `SetScrollWorkOffset4` reflects this behavior and is consistent with the existing `CopyScrollRegs` / `AdjustScrollAndRender` naming style.

## Task 1: Rename in `asm/banks/prg_17_18.asm`

Update 5 occurrences in the file:

1. **Line 557** — `JSR Sub_AD9F` → `JSR SetScrollWorkOffset4`
2. **Line 1644** — `JMP Sub_AD9F` → `JMP SetScrollWorkOffset4`
3. **Line 1876** — comment header: `; $AD9F: Sub_AD9F` → `; $AD9F: SetScrollWorkOffset4`
4. **Line 1878** — `.proc Sub_AD9F` → `.proc SetScrollWorkOffset4`
5. **Line 1879** — `Sub_AD9F:` label → `SetScrollWorkOffset4:`

## Verification
- Run the build (`make` or the project build command) to confirm no broken references.
- Grep for any remaining `Sub_AD9F` occurrences to ensure none are left.
