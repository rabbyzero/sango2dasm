# Semantic Routine Renaming Decision - SceneRenderer

- **Category:** important_decision_experience
- **Memory ID:** c0b6b2f7-6433-412a-96af-d86bc4031d82
- **Keywords:** routine renaming, semantic naming, NES disassembly, SceneRenderer
- **Usage scenarios:**
  - Renaming generic assembly labels (e.g., SmallRoutineX) to descriptive names based on behavioral analysis
  - Choosing a functionally accurate name for a graphics rendering routine in a NES disassembly
  - Consistently updating routine names across source and tooling scripts after reverse-engineering analysis

## Content

## Decision Scenario
Renaming an ambiguous assembly routine during reverse engineering of a NES game disassembly.

## Decision Content
Select 'SceneRenderer' as the new name for `SmallRoutineB`, based on its behavior: state-driven dispatch, copying tile data to VRAM buffer `$0380`, and managing palette fades.

## Applicable Scope
Any NES/SNES disassembly project where routines are named generically (e.g., `SmallRoutineX`) and require semantic renaming based on observed functionality and memory usage.
