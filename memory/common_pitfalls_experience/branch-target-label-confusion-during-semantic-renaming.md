# Branch target label confusion during semantic renaming in assembly

- **Category:** common_pitfalls_experience
- **Memory ID:** 1298c9d9-a61a-4aa0-94c6-b0a789c85ea8
- **Keywords:** branch target, semantic renaming, label confusion, control flow

## Content

Bug class: Branch target label confusion during semantic renaming
Root cause: When converting numeric branch targets (e.g., BNE $A2EC) to semantic labels, incorrectly mapping the wrong target address. In prg_0e_0f.asm BattleDefeatEventCheck, the BNE at $A2B7 was renamed from BNE $A2EC to BNE @Done, but $A2EC is actually @SideB (side-B check), while @Done is at $A32E. This caused a single-byte mismatch (asm=75 vs rom=33) because the assembler resolved @Done to $A32E instead of the correct $A2EC.
Fix pattern: Always verify the actual target address of each branch instruction before assigning semantic labels; trace control flow to confirm which label each branch should point to.
Reusable lesson: Don't assume semantic label names match branch destinations without verifying addresses because similar-looking branches may target different logical points in the code. Applies when refactoring assembly with inline dispatch tables and multiple conditional branches; does not apply to simple linear code without branching.
