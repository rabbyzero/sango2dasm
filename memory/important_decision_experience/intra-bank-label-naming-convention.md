# Intra-Bank Label Naming Convention: Bare Names, Prefixes for Cross-Bank Only

- **Category:** important_decision_experience
- **Memory ID:** 6bc883a2-52a7-4a4f-b360-fd92b4413313
- **Keywords:** label naming, intra-bank, cross-bank, 6502 assembly, Bxx prefix

## Content

## 决策场景
Standardizing label naming convention for intra-bank vs. cross-bank subroutine calls in 6502 assembly

## 决策内容
- In bank-specific assembly files (e.g., `prg_1f.asm`), use bare `.proc` or label names (e.g., `JSR BankSwitch`) for all intra-bank references.
- Reserve the `Bxx_functionname` prefix (e.g., `B1F_BankSwitch`) exclusively for cross-bank `JSR`/`JMP` calls.

## 适用范围
Any 6502 assembly project using bank switching where symbol resolution and code clarity depend on consistent naming conventions across memory banks.
