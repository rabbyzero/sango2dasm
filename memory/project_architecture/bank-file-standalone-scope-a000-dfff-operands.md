# Bank file standalone scope for $A000-$DFFF operands

- **Category:** project_architecture
- **Memory ID:** 16a918fd-e1c7-4652-912e-59df71b5692d
- **Keywords:** bank files, standalone, $A000-$DFFF, lo hi immediate, same-file scope

## Content

Bank files (prg_*.asm) are standalone: every $A000-$DFFF raw operand in a file refers only to that file's own banks, not cross-file references. Pointer constructions using lo/hi immediates must be detected within the same file scope. When symbolizing data regions, verify targets against the same file's data regions only.
