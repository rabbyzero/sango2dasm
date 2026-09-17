# Distinguish genuine mechanics from stale naming after semantic refactoring

- **Category:** common_pitfalls_experience
- **Memory ID:** 23a8c164-3927-43b9-b584-053f397e6294
- **Keywords:** mechanic vs naming, generated dump sync, semantic cleanup, comment rewording, python script fallback

## Content

## Phenomenon
After major semantic renaming in disassembly projects, residual "mechanic-description" terms (e.g., "coin flip") may persist in comments where they incorrectly identify a stratagem/proc by its mechanic rather than its canonical name. Simultaneously, generated documentation dumps (e.g., RAM usage analysis, proc listings) retain old identifiers and require sync.

## Verified Root Cause
Two distinct categories of matches appear when scanning for renamed terms:
1. **Genuine mechanic descriptions**: The term describes actual game logic (e.g., `B1F_RandomByte` bit-0 roll for Bind success, order-slot `$80` coin flip between Advance/Hold). These are accurate and should be preserved.
2. **Stale naming errors**: The term was used as the stratagem/proc's identity before renaming (e.g., "row 0 (Bind) is a coin flip" instead of "row 0 (Bind) coin-flips..."). These must be reworded to make the mechanic secondary to the identity.

Generated dumps (e.g., `code/prg_0e_0f_ram_usage.txt`) are snapshots that don't auto-update; they accumulate stale proc names after renames.

## Correct Handling
1. **Categorize scan results**: Before fixing, separate matches into (a) genuine mechanics (keep), (b) identity-flavored comments (reword), (c) stale identifiers in generated files (sync).
2. **Reword identity-flavored comments**: Change "X is a coin flip that..." → "X coin-flips and on a hit...". Make the mechanic the verb, not the noun.
3. **Sync generated dumps**: Use targeted Python scripts with explicit replacement mappings (not SearchReplace replace_all) for bulk updates across hundreds of occurrences. Delete temp scripts after use.
4. **Verify**: Re-scan to confirm no stale identifiers remain; run byte-exactness verification.

## Applicable Boundary
- **Applies to**: Any disassembly project where semantic renaming follows a glossary or manual KB; any workflow generating documentation dumps (RAM maps, proc listings, call graphs).
- **Does not apply to**: Simple label renames without comment text changes; projects without generated dump artifacts.
