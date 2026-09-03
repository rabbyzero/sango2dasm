# Legacy label conflicts when establishing new terminology standards in disassembly projects

- **Category:** common_pitfalls_experience
- **Memory ID:** 46003d08-1036-4dcb-828e-89dbd0e17d77
- **Keywords:** legacy labels, terminology mapping, naming conflicts, disassembly refactoring, stratagem names
- **Usage scenarios:**
  - When creating a new terminology glossary for a project with existing code
  - When refactoring legacy labels to follow new naming conventions
  - When documenting mappings between old and new naming schemes

## Content

Bug class: Terminology inconsistency between legacy asm labels and new glossary names
Root cause: Existing assembly files contain legacy English labels (e.g., Trap, MuddyWater, FireArrows) that differ from the consolidated glossary's canonical names (PitfallTrap, BoatSabotage, SupplyBurning); without explicit mapping documentation, future contributors cannot understand which glossary term corresponds to which legacy label.
Fix pattern: When creating a new terminology glossary, document explicit legacy-label -> glossary-name mappings for all stratagem codes and domain terms; preserve the legacy labels in asm files but add comments or metadata linking them to canonical names. For example, code 5 maps to SupplyBurning (火箭) but legacy asm uses FireArrows; this distinction must be documented because battle-mode also has a tactic named FireArrows (火矢) which is different.
Reusable lesson: Don't assume legacy labels can be silently replaced with glossary names because existing asm files depend on them; instead create explicit mapping tables showing which legacy labels correspond to which canonical terms. Applies when consolidating terminology in any disassembly project with historical labeling conventions; does not apply when starting a fresh project with no legacy code.
