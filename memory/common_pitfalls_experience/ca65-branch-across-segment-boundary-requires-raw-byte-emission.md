# ca65 branch across .segment boundary requires raw byte emission

- **Category:** common_pitfalls_experience
- **Memory ID:** 32a9e830-a654-4714-8de4-aeec059e038b
- **Keywords:** ca65, segment boundary, branch instruction, raw bytes, range error

## Content

## Bug class
ca65 range error on backward relative branch crossing .segment boundary

## Root cause
When a relative branch instruction (BCC, BEQ, etc.) has its target in the previous segment (e.g., branch at $C00C in CODE_BANK09 targeting $BFF9 in CODE_BANK08), ca65 treats CODE_BANK08 and CODE_BANK09 as separate sections. The assembler cannot compute a valid relative offset across section boundaries, even though the ROM layout is contiguous ($A000-$DFFF via bank switching). The error manifests as "range error: offset not in [-128..127]" with an absurd distance (e.g., -688 bytes) because ca65 computes the offset using internal section-relative PCs rather than physical ROM addresses.

## Fix pattern
Emit the branch as raw bytes when the target crosses a .segment boundary:
- Identify branches where the target address is in the previous segment but the opcode is in the current segment
- Replace `BCC @Label` with `.byte $90, $EB ; $C00C: 90 EB (BCC $BFF9 = @Label)`
- Keep the comment showing the original symbolic intent for documentation
- Precedent: prg_1d_1e.asm line 3708 uses this pattern for BNE $C010 from $BFF6

## Reusable lesson
Don't use symbolic branch targets when the target crosses a .segment boundary because ca65 cannot compute offsets across sections; instead emit raw bytes with a comment documenting the symbolic intent. Applies to NES disassembly projects using separate CODE_BANKxx segments for each PRG bank pair; does not apply when banks are combined into a single segment or when all code stays within one segment.
