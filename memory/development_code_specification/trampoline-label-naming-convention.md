# Trampoline label naming convention

- **Category:** development_code_specification
- **Memory ID:** 9cbfca94-fe8c-4832-bacf-b333e2a8a78b
- **Keywords:** trampoline, local label, @ExitTo, JMP target, assembly naming

## Content

Trampoline jump targets (e.g., `$B616` → `JMP $BEC7`) are labeled with descriptive local names prefixed by `@`, following the pattern `@ExitToXXXX` for shared exit points. This applies consistently within procedure scopes and avoids global labels when no cross-file references exist.
