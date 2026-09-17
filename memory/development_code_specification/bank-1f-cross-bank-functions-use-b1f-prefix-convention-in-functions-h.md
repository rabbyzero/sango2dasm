# Bank-1F cross-bank functions use B1F_* prefix convention in functions.h

- **Category:** development_code_specification
- **Memory ID:** 17774e59-d0cf-4215-9b6a-214f90e38cb7
- **Keywords:** B1F_* prefix, bank-1F routines, functions.h, inter-bank calls, cross-bank naming

## Content

Cross-bank function references use the BXX_YY_* naming convention where XX is the destination bank number and YY is the procedure name. Bank-$1F routines are referenced as B1F_RoutineName (e.g., B1F_CallbackDispatcher, B1F_PaletteCopyBuffer, B1F_NmiDisable, B1F_GetOfficerRecordAddr). These names are defined in include/functions.h and must be used instead of raw addresses ($EADE, $ECEE, $E768, $F2D7) in JSR/JMP instructions. This ensures consistency across all banks and enables cross-reference tooling to track inter-bank calls.
