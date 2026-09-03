# Semantic naming convention for state machine dispatchers

- **Category:** development_practice_specification
- **Memory ID:** abf5b70d-38ed-4775-aa6f-b2cc43f9ec4b
- **Keywords:** state machine, dispatch, semantic naming, assembly labeling
- **Usage scenarios:**
  - Renaming raw address labels in PRG assembly files
  - Defining new state machine entry points in 6502 code
  - Refactoring legacy labels to improve code readability

## Content

Dispatch procedures in state machines should be named with a semantic label ending in 'Dispatch' (e.g., `ProvinceSelectDispatch`, `OfficerMarchDispatch`) to indicate their role as entry points for multi-phase state machines. The name should reflect the domain entity and action being managed. Domain vocabulary (game concepts like Stratagem, Formation, Duel, Mobility) must come from the consolidated semantic English glossary docs/manual_kb/terminology.md, not ad-hoc translations or romaji.
