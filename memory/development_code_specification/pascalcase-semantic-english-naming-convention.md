# PascalCase semantic English naming convention for procedures and constants

- **Category:** development_code_specification
- **Memory ID:** 5b851c94-fc49-4240-88da-03537515ef43
- **Keywords:** PascalCase, semantic English, naming convention, procedure labels
- **Usage scenarios:**
  - Naming new procedures or constants in assembly files
  - Refactoring legacy labels to follow project conventions
  - Code review for naming consistency

## Content

The project uses PascalCase semantic English names for all procedure labels and constants, not romaji-based names. Game-domain words must come from the consolidated semantic English glossary docs/manual_kb/terminology.md. Examples include BankedCallbackTrampoline, AiOfficerActionDispatch, StratagemDispatch, FormationIdTable, DuelCommandDispatch. Cross-bank references use the Bxx_ prefix (e.g., B1F_CallbackDispatcher), while intra-bank references use bare names. This convention applies to all new labels and should be used when refactoring legacy code.
