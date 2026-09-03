# Terminology.md as authoritative naming reference for game-domain vocabulary

- **Category:** project_architecture
- **Memory ID:** 3d4b68a4-eb9a-4c5b-bdce-ebcead318293
- **Keywords:** terminology glossary, authoritative naming reference, game vocabulary, semantic English
- **Usage scenarios:**
  - When creating new procedure labels with game-domain vocabulary
  - When resolving naming conflicts between legacy and new conventions
  - When onboarding new contributors to the disassembly project

## Content

The project uses docs/manual_kb/terminology.md as the consolidated semantic English glossary and authoritative naming reference for all game-domain vocabulary (Japanese -> reading -> English term). This glossary supersedes any romaji-based naming suggestions in per-file documentation. The glossary covers game modes (Strategy/Tactical/Battle/Duel), strategy-mode commands (castle/army/warehouse/town groups), tactical commands, the 16 stratagem list, battle commands and tactics list, formations, duel commands, officer/country stats, events, ruler profiles, and the 30-country map. All new procedure labels and constants using domain vocabulary must derive from this glossary to maintain consistency with existing PascalCase semantic naming patterns (e.g., BankedCallbackTrampoline, AiOfficerActionDispatch, StratagemDispatch).
