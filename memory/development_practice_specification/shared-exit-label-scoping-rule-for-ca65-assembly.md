# Shared exit label scoping rule for ca65 assembly

- **Category:** development_practice_specification
- **Memory ID:** 16a18700-e457-4ae7-ac39-83f285b5e3d6
- **Keywords:** shared exit labels, ca65 .proc scope, bare globals, branch targets
- **Usage scenarios:**
  - Refactoring procedures with common exit paths
  - Resolving ca65 label accessibility errors
  - Documenting inline jump table patterns

## Content

Shared exit labels in ca65 assembly must be bare globals positioned between .proc scopes, not inside any .proc block. When multiple sub-procedures share a common exit path (e.g., RTS), the exit label must be defined outside all .proc blocks so that branches from within different procs can reach it. Example: Phase5WaitExit at $CD58 is placed between Phase5SideEventRosterCommit and Phase5SideEventPanelSetup procs, allowing both to branch to it. This follows the established pattern seen in Phase2WalkExit and other shared exits in prg_0e_0f.asm.
