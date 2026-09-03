# Consolidated semantic English terminology glossary for Sangokushi 2 disassembly

- **Category:** task_summary_experience
- **Memory ID:** e9504a26-d39b-47ae-99a2-f8e0807ce836
- **Keywords:** terminology glossary, semantic English, stratagem names, KB consolidation, naming convention
- **Usage scenarios:**
  - When adding new terminology to the knowledge base
  - When naming procedures or labels with game-domain vocabulary
  - When resolving conflicts between legacy and new naming conventions

## Task description

- Core requirement: consolidate semantic English terminology from all 14 knowledge base files into a single glossary (terminology.md) and update related documentation to reference it as the authoritative naming source
- Task background: The project had scattered terminology across multiple KB files (02-general-stats, 07-war-rules, 08-tactical-mode, 09-battle-mode, 10-duel-mode) with inconsistent naming conventions; some files suggested romaji-based names while the project convention is PascalCase semantic English; needed a unified reference aligned with existing proc naming patterns (e.g., BankedCallbackTrampoline, AiOfficerActionDispatch)

## Execution process

1. Created docs/manual_kb/terminology.md with ~150 terms in three-column tables (Japanese -> reading -> semantic English), grouped by domain: game modes, officer stats, country stats, strategy commands, events, war rules, tactical mode (16 stratagems), battle mode (formations/tactics), duel mode
2. Updated README.md to list terminology.md as file 0 / primary naming reference and adjusted naming guidance to reference the glossary instead of romaji-first approach
3. Replaced "Naming Hints for Disassembly" tables in 5 per-file documents (02-general-stats.md, 07-war-rules.md, 08-tactical-mode.md, 09-battle-mode.md, 10-duel-mode.md) with one-liner pointers to terminology.md to avoid conflicting guidance
4. Fixed a duplication typo in terminology.md where characters were accidentally repeated
5. Updated 4 knowledge memories to align with glossary:
   - Battlefield Stratagem System with Execution Logic and Terrain Mapping (b67a21ef): updated stratagem map with canonical English names + legacy alias mapping
   - Semantic renaming for CheckAction_* validation routines (57f9a843): updated stratagem map with glossary names and legacy aliases
   - Semantic naming convention for state machine dispatchers (abf5b70d): added reference to terminology.md as vocabulary source
   - Semantic naming for core loop dispatchers (09f8de24): added reference to terminology.md as vocabulary source

## Related files

- /docs/manual_kb/terminology.md (created)
- /docs/manual_kb/README.md (updated)
- /docs/manual_kb/02-general-stats.md (updated)
- /docs/manual_kb/07-war-rules.md (updated)
- /docs/manual_kb/08-tactical-mode.md (updated)
- /docs/manual_kb/09-battle-mode.md (updated)
- /docs/manual_kb/10-duel-mode.md (updated)

## Notes

- The stratagem system required careful handling of legacy labels still present in asm files (e.g., Trap, MuddyWater, FireArrows) which differ from glossary names; documented explicit mappings so existing code remains interpretable
- Distinguished between tactical-map stratagem FireArrows (SupplyBurning) and battle-mode tactic 火矢 (FireArrows) to avoid confusion
- Verified against project's established naming conventions (PascalCase semantic names, Bxx_ prefix only for cross-bank calls) before finalizing glossary entries

## Task overview

Successfully completed consolidated semantic English terminology list at docs/manual_kb/terminology.md with ~150 terms covering all game domains; updated 7 documentation files to reference the glossary as authoritative source; refreshed 4 knowledge memories with glossary-aligned content and legacy label mappings; no blockers or unresolved issues.
