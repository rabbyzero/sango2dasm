# Semantic naming for core loop dispatchers

- **Category:** development_practice_specification
- **Memory ID:** 09f8de24-2917-4f8f-aec3-58ec503938aa
- **Keywords:** Dispatch, main loop, semantic naming, state machine
- **Usage scenarios:**
  - Naming a dispatcher that re-enters the main game loop or render cycle
  - Refactoring idle/yield procedures in the state machine table
  - Extending the main dispatch table with system-level handlers

## Content

State machine dispatchers that serve as entry points to core game cycles (e.g., returning control to the main loop) should be named with a semantic label ending in 'Dispatch', such as `MainLoopDispatch`. The name must reflect the system-level behavior being managed, even if the procedure is a thin wrapper around a callback or trampoline. Game-domain words in such names follow the semantic English glossary docs/manual_kb/terminology.md.
