# ca65 cheap local symbols scoped by preceding global label, not .proc boundary

- **Category:** common_pitfalls_experience
- **Memory ID:** a31f0be7-cb7b-4ae7-b573-385a6660b4a2
- **Keywords:** ca65, cheap local symbols, @-prefix, group scoping, duplicate symbols, dispatcher tables

## Content

Bug class: ca65 cheap local (@-) symbols scoped by preceding global label, not .proc boundary

Root cause: In ca65, cheap local symbols (@name) resolve against the definition whose group parent — the nearest preceding GLOBAL label within the enclosing .proc scope — matches the reference's group parent. Verified semantics (ca65 0.x at ~/.local/bin/ca65): (1) two @X: defs inside one .proc are a duplicate-symbol ERROR unless separated by an intervening global label; (2) a global label between two @X: defs makes them distinct symbols (legal); (3) a .word @X reference cannot see @X: defined below an intervening global label even within the same .proc (undefined symbol); (4) forward references within the same group are fine; (5) separate .proc scopes allow the same @name in each without conflict.

Fix pattern: Convert a bare label to @-local only when every reference and the definition share the same group parent; blanket per-proc conversion breaks assembly. Use group-aware checkers (tools/check_local_groups.py, tools/check_dispatcher_label_style.py in this repo) and convert greedily with re-verification. Note: converting labels that previously separated duplicate @-names merges their groups and exposes latent duplicate-symbol errors (seen with @PhaseExit x4, @StillWaiting x2, @Scan x2 in prg_19_1a.asm StrategyRequestDispatch/CardFillDispatch).

Applicable boundary: All ca65 projects using cheap local symbols; verified in Sangokushi 2 disassembly with byte-exact per-bank harness (tools/verify_19_1a.py, 0 mismatches after conversion).
