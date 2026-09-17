# Grep for address tokens across full codebase, not just decoded regions

- **Category:** common_pitfalls_experience
- **Memory ID:** abdcaa66-8699-4e41-9e16-2c1bcb470fe3
- **Keywords:** grep scope, address token, call site discovery, undecoded blocks, search completeness

## Content

When searching for cross-references to a code region (e.g., JSR/JMP targets), always grep for the raw address token (e.g., `$CBF1`) across the entire codebase, not just within known decoded regions. Relying on grep restricted to previously analyzed sections can miss call sites located in undecoded or partially decoded blocks (e.g., `Loc_D6DD` block contained an 8th call site at `$D727` that was initially missed). This applies to both assembly files and any text-based search for symbolic addresses. Always perform full-codebase searches for address tokens to ensure completeness.
