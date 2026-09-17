# BankedCallbackTrampoline target resolution via Y masking formula

- **Category:** project_architecture
- **Memory ID:** 9b1b7d85-37fb-49e8-9ae2-008f39d5eebe
- **Keywords:** BankedCallbackTrampoline, Y masking, Namco-163, bank switching, target resolution, functions.h

## Content

BankedCallbackTrampoline target resolution mechanism in Sangokushi 2 disassembly:

The Namco-163 mapper uses a 5-bit Y mask for PRG bank switching (effective_bank = Y & $1F). BankedCallbackTrampoline works by:
1. Reading a .word target address from inline data following the JSR call
2. Switching PRG bank based on Y register value masked with $1F
3. JMPing to the target address in the NEW bank
4. On RTS, restoring the original bank

Therefore, .word targets like $A000-$A02A are entry points in OTHER banks (determined by Y mask), NOT addresses within the current file's loaded range. For example:
- LDY #$3B + .word $A003 → Y=$3B & $1F = $1B → targets banks $1B+$1C
- LDY #$3D + .word $A02A → Y=$3D & $1F = $1D → targets banks $1D+$1E
- LDY #$2A + .word $A009 → Y=$2A & $1F = $0A → targets banks $0A+$0B

Correct handling requires:
1. Identify the Y register value used before each JSR B1F_BankedCallbackTrampoline call
2. Calculate effective bank: effective_bank = Y & $1F
3. Check if the bank pair exists in functions.h (e.g., B1B_1C_*, B1D_1E_*, B0A_0B_*)
4. Only replace with symbols if the target bank pair is documented in functions.h
5. Leave as raw addresses if the target bank is not yet disassembled/added to functions.h

Same numeric address can be valid entry stub in multiple bank pairs (e.g., $A009 appears in many banks); bank resolution must come from Y register, never from numeric value alone.
