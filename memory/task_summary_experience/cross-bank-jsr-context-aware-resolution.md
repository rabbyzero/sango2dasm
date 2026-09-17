# Correcting cross-bank JSR references using context-aware symbol resolution

- **Category:** task_summary_experience
- **Memory ID:** 8190fd89-feb7-40c5-a00e-a117f0cbf5ec
- **Keywords:** bank switching, symbol resolution, JSR reference, context-aware labeling

## Content

## Task Description
Update the JSR at $E1AC to use the correct function name (`B0C_0D_OfficerTransferCalc_Entry`) based on active bank context after `SwitchBankAC_B`.

## Execution Process
```mermaid
graph TD
    A[Identify JSR $A006 at $E1AC] --> B[Search where $A006 is defined]
    B --> C[Find multiple functions at $A006 across banks]
    C --> D[Analyze preceding bank switch: SwitchBankAC_B with Y=$2C]
    D --> E[Determine active bank: 0C/0D]
    E --> F[Locate $A006 entry in prg_0c_0d.asm: OfficerTransferCalc_Entry]
    F --> G[Update JSR label to B0C_0D_OfficerTransferCalc_Entry]
```

## Task Summary
Successfully corrected symbolic reference from `B17_18_PpuWriteTileOffset` to `B0C_0D_OfficerTransferCalc_Entry`, ensuring accurate representation of the intended function call within the proper bank context. Binary output remains unchanged; only source clarity improved.
