# Cross-proc entry points must be bare globals outside .proc scope

- **Category:** project_tech_stack
- **Memory ID:** 06871b5c-298a-4f40-be7a-d867fa93479e
- **Keywords:** multi-entry procedure, cross-proc reference, ProcName::LabelName, secondary entry point

## Content

For multi-entry procedures in this project, secondary entry/exit points referenced from outside the parent .proc must be bare global labels placed OUTSIDE any .proc/.endproc block (hoist the .endproc above the shared label, e.g. Phase2AnimWaitExit $A653, Phase2DamageAnimExit $A7B1, Phase2WalkExit $A61C in prg_0e_0f.asm). Verified ca65 constraints: labels declared inside .proc are scoped, so plain cross-proc references fail with undefined symbol; Proc::Label cross-proc forward references also fail, and Proc::@cheap-local references silently misresolve to wrong branch offsets. Cheap-local (@) label scope is terminated by ANY non-cheap label, so a bare inner label also breaks preceding @-references to labels defined after it. Fall-through from one .proc into the next (via JSR return or plain fall-through) works since .proc emits no bytes.

## Correction / addition (verified in prg_17_18.asm DrawOfficerCards $BDCB)
- Multi-level qualified references across procs (including the leading-global form ::Proc::Label, i.e. three scope parts) also FAIL with undefined symbol; only two-part Proc::Label from file scope or ::Proc::Label... with a single :: separator works. Do not attempt cross-proc access to labels inside another .proc — hoist instead.
- When hoisting a shared label out of its parent .proc, any proc-local zero-page equates used by the hoisted code (e.g. officer_data_ptr = $0000, ptr_0010_lo/hi) must be re-declared in the bare-global region, otherwise they become undefined. Re-declared at file scope they are safe: no other bank defines them globally, and proc-local definitions elsewhere shadow them.
- Error-set parity verification: after the fix the standalone ca65 error count drops by exactly the previously-undefined cross-proc reference error (262 -> 261), all other pre-existing errors unchanged.
