# Proc Parameter Naming Plan

## Context

The goal is to add meaningful global and local parameter names to all procs in prg_17_18.asm, following the same pattern as in prg_1f.aligned.asm. Currently, the assembly code in prg_17_18.asm uses raw memory addresses (like $0000, $000A, etc.) without meaningful names for local parameters within procs. By adding local aliases within each .proc block, we can improve code readability and maintainability.

## Approach

1. Analyze each proc in prg_17_18.asm to identify what memory addresses it uses
2. Assign meaningful names to these addresses as local parameters within each proc
3. Follow the same pattern as prg_1f.aligned.asm where local variables are defined right after the .proc statement
4. Focus on commonly used addresses like zero-page addresses ($0000-$00FF) and frequently accessed RAM locations

## Implementation Strategy

1. Scan each proc to identify memory accesses (LDA, STA, STX, etc. with addresses)
2. Group related addresses by function within each proc
3. Create meaningful names based on the usage context
4. Insert the parameter definitions right after the .proc statement

## Critical Files to Modify

- `/home/zero/project/sango2dasm/asm/banks/prg_17_18.asm` - Main file to add parameter names

## Verification

- Ensure all existing functionality remains intact
- Verify that the new parameter names accurately reflect the usage
- Confirm assembly still compiles correctly