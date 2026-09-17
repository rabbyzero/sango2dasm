# namcot163-disasm agent stale classification source fixed

- **Category:** task_summary_experience
- **Memory ID:** b1183f78-3650-40a3-85ca-2e54251bba1a
- **Keywords:** namcot163-disasm, pbank31.cdl.asm, agent definition, authoritative classification, combined bank pair

## Content

Fixed better-harness finding targeting .qoder/agents/namcot163-disasm.md referencing asm/banks/pbank31.cdl.asm. Verification showed the literal pbank31.cdl.asm reference was already absent from both working tree and HEAD (removed in a prior rewrite); the residual problem was the File Structure and Verification Rules sections still describing the outdated per-bank asm/banks/prg_XX.asm layout. Updated both sections to name the decoded combined bank-pair files (asm/banks/prg_XX_YY.asm, e.g. prg_08_09.asm ... prg_1d_1e.asm, plus prg_1f.asm) as the authoritative code/data classification source and to mark individual prg_XX.asm stubs as placeholders, not classification references. Validated all referenced paths exist and the agent invocation no longer searches for the missing file. Note: the Agent tool loads a session-start snapshot from SharedClientCache workingSpace (__namcot163-disasm.md files), so the subagent answered with the pre-edit text; the project file is the source of truth and the cache refreshes on reload.
