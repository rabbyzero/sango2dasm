# BankedCallbackTrampoline merge and magic number computation fix

- **Category:** task_summary_experience
- **Memory ID:** 27e3dfbe-f737-4153-94d5-fc0e9e34af96
- **Keywords:** BankedCallbackTrampoline, banked callback, return address, magic number, trampoline fix

## Content

## Task description
- Core requirement: Fix BankedCallbackTrampoline structure in prg_1f.asm where BankedCallbackReturn was incorrectly defined as a separate proc
- Task background: User identified that address $EE4D is not a new procedure but follows the previous proc; the magic numbers at $EE44 ($EE) and $EE47 ($4C) are actually encoding $EE4D-1 = $EE4C as the return address for the trampoline mechanism

## Execution process
1. Identified the issue: BankedCallbackReturn at $EE4D-$EE52 should be merged into BankedCallbackTrampoline, not a separate .proc
2. Merged BankedCallbackReturn into BankedCallbackTrampoline by removing the separate .proc/.endproc block and its header comment
3. Replaced magic number operands at $EE44/$EE47 from `#$EE` / `#$4C` to `#<(@return_addr-1)` / `#>(@return_addr-1)` where @return_addr is a local label at $EE4D, making @return_addr - 1 = $EE4C
4. Updated file header range from `$ED19-$EE51` to `$ED19-$EE4D` to reflect the merged procedure end address
5. Verified byte alignment of comments after changes

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_1f.asm

## Notes
- The circular dependency issue: using `@return_addr - 1` as operand creates a self-referential calculation where the operand value affects the label's address which affects the operand value; hard-coded values only work because they're fixed-size instructions
- B1F_BankedCallbackReturn in functions.h still correctly points to $EE4D even though it's no longer a standalone proc; it's now an inner label within BankedCallbackTrampoline

## Task overview
Completed: Successfully merged BankedCallbackReturn into BankedCallbackTrampoline, replaced magic numbers with computed expressions using @return_addr-1, and updated file header. The trampoline now correctly computes the return address $EE4C (one byte before the PHA instruction) through symbolic expressions rather than hardcoded values.
