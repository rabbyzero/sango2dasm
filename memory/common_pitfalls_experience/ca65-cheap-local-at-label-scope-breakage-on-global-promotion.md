# ca65 cheap-local @-label scope breakage on global promotion

- **Category:** common_pitfalls_experience
- **Memory ID:** b7a53cd7-1aca-44ba-9519-44aa9bd237ea
- **Keywords:** ca65, cheap-local scope, @-prefix, bare globals, undefined symbol

## Content

## Bug class
ca65 cheap-local @-label scope breakage causing undefined-symbol errors during assembly

## Root cause
ca65 attaches @-prefixed local labels to the last non-local label in the source file. Promoting a helper procedure from an @-local to a bare global creates a new cheap-local group boundary. Any subsequent @-labels defined before that promotion now attach to the wrong group, causing references to those @-labels to resolve to symbols in the previous group (or fail entirely if no symbol exists). Example: promoting ComputeAverageStats ($CCAA) created a boundary that broke @CheckFaction ($CC92) and @ComputeScaledStats ($CD00) refs, which were previously attached to the same group but now fall into different groups.

## Fix pattern
When refactoring helpers to bare globals:
1. Identify all @-labels that are called from multiple scopes or need cross-proc visibility
2. Before promoting a helper, scan for any @-labels defined between the last global and the target helper
3. Either promote ALL affected @-labels together, or restructure so the promoted helper is the first global after its @-locals
4. For helpers truly shared across many scopes, make them bare globals with PascalCase names (e.g., CheckFaction, ComputeAverageStats) and update all JSR/BEQ refs to use the bare name

## Reusable lesson
Don't promote a single @-local helper to a bare global without checking for downstream @-labels because it creates a new cheap-local group boundary that breaks other @-refs; instead promote all related @-labels together or restructure the proc boundaries. Applies when refactoring ca65 assembly files with @-prefixed locals; does not apply to pure .proc encapsulation where all calls stay within the same proc scope.
