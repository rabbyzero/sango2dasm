# ca65 @-label conversion needs address-based fixpoint; git checkout wiped uncommitted prior work

- **Category:** common_pitfalls_experience
- **Memory ID:** 68ee8f78-4d84-4c44-8ff0-f22f1d70ff69
- **Keywords:** ca65 cheap local scope, @-label demotion, fixpoint, address-based analysis, git checkout data loss, workingSpace snapshot recovery

## Content

## Pitfall
Converting Loc_ADDR labels to @-locals in ca65 disassembly banks breaks assembly in two non-obvious ways.

Root cause 1: ca65 cheap-local (@) symbols are only visible within the segment between two non-@ labels. Demoting one label from @ to bare creates a NEW boundary that silently invalidates other @-labels' references (cascading).
Root cause 2: the same @-name may legally exist in multiple segments/procs. Analyzing labels by NAME instead of by unique address misattributes references across segments, causing mass false demotions and duplicate bare definitions.
Root cause 3 (process): running `git checkout -- <file>` on a dirty working tree discarded prior sessions' uncommitted semantic renames (working file had 101 Loc_ lines vs HEAD's 321).

Fix pattern: track transform state per unique address; iterate to fixpoint (demote -> recompute boundaries -> recheck); demoted labels are referenced by bare name (ca65 .proc scope makes them visible proc-wide); deleted labels are not boundaries. Verify with the per-bank byte-exact harness afterwards.

Reusable lesson: before any git discard command, diff working tree vs HEAD and confirm no uncommitted prior-session work; on IDE-based agents, per-file snapshots in ~/.config/QoderCN/SharedClientCache/cache/workingSpace/<uuid>__<filename> can restore the exact pre-discard state.

Applicable boundary: any ca65 codebase using @-prefix cheap locals with mixed bare global labels inside .proc blocks.
