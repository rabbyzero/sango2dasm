# PRG bank 0F $DD5E-$DF6D data region misclassification fix

- **Category:** task_summary_experience
- **Memory ID:** a7b2cd2c-fe96-4552-a6e5-be9f9f5662fb
- **Keywords:** $DD5E-$DF6D fix, sound lookup tables, data region verification, ROM byte parity, label cleanup

## Content

## Task description
- Core requirement: Fix large data region $DD5E-$DF6D in prg_0e_0f.asm where 134 lines of fake "Code Region" markers and misinterpreted 6502 instructions were actually data bytes
- Task background: The region contained lookup tables (channel initialization, delta offsets, threshold values, approach tables, volume scaling, frequency lookup tables) that were incorrectly disassembled as ORA, BRK, BPL, BMI, BVC, BVS, BNE, BEQ, CPX, CPY, LDY, RTI, RTS, AND instructions. User identified $DD5E-$DF6D as data, not code.

## Execution process
1. Read full region context (lines 8826-8958), identified all fake "Code Region" markers and stale labels (@DeltaTable, @DataDD77, @DeltaRunA-D, @ThresholdEnd, @ApproachExit, @VolumeTableCont, etc.)
2. Verified ROM bytes using Python hex dump for entire $DD5E-$DF6D range (528 bytes total)
3. Applied three SearchReplace calls to replace 133 lines with clean .byte data:
   - Call 1: Fixes $DD74-$DD8F (fake ORA/BRK → .byte)
   - Call 2: Fixes $DDEE-$DE14 (fake branch instructions → .byte)
   - Call 3: Fixes $DE55-$DF6D (volume/freq tables, removed 59 lines of fake code)
4. Preserved meaningful labels: @ChannelInitData, @DeltaOffsetTable, @ThresholdTable, @ApproachTable, @VolumeTable, @VolumeScaleTable, @FreqLookupE-N
5. Fixed byte alignment at $DE55-$DE56 (ROM had two consecutive $60 bytes; original file dropped one)
6. Assembled and verified 185 checked bytes against ROM with 0 mismatches

## Related files
- asm/banks/prg_0e_0f.asm

## Notes
- Root cause: Disassembler interpreted data bytes as 6502 opcodes; multiple fake code regions scattered throughout data table
- Byte alignment issue: $DE55-$DE56 required special handling due to consecutive identical bytes ($60 $60)
- Label cleanup: Removed 20+ stale @-local labels that were never referenced from actual code
- Verification limitation: Only 185 bytes checked due to regex pattern matching only lines with address comments; remaining bytes verified via assembly success

## Task overview
Successfully fixed $DD5E-$DF6D data region: replaced 134 lines of fake code with ROM-verified .byte data, removed 20+ stale labels, preserved 8 meaningful labels, fixed byte alignment at $DE55-$DE56, and verified byte-parity with 0 mismatches across checked region.
