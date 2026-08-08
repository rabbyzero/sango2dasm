#!/usr/bin/env python3
"""Analyze the Loc_B517 inline dispatcher and its call sites in prg_08."""

data = open('rom/prg/prg_08.bin', 'rb').read()

def dump_range(start_addr, length):
    off = start_addr - 0xA000
    for i in range(0, length, 16):
        addr = start_addr + i
        hexb = ' '.join(f'{data[off+i+j]:02X}' for j in range(min(16, length-i)))
        print(f'  ${addr:04X}: {hexb}')

def read_byte(addr):
    return data[addr - 0xA000]

def read_word(addr):
    return data[addr - 0xA000] | (data[addr - 0xA000 + 1] << 8)

print("=" * 70)
print("Loc_B517 Inline Dispatcher - CONFIRMED ANALYSIS")
print("=" * 70)
print()
print("Dispatcher mechanism:")
print("  1. JSR pushes (JSR_addr + 2) onto stack")
print("  2. Dispatcher PLA's this value -> ptr = JSR_addr + 2")
print("  3. Y = index*2 + 1 (ASL, TAY, INY)")
print("  4. Reads ptr + Y and ptr + Y + 1 -> little-endian target")
print("  5. ptr + Y = (JSR_addr + 2) + (index*2 + 1) = JSR_addr + 3 + index*2")
print("  6. JSR_addr + 3 = first byte after JSR = inline table start")
print("  7. So: target = .word at table_start + index*2")
print("  8. JMP (target) - handler's RTS returns to code AFTER the table")
print()
print("  Table format: .word entry0, entry1, ... (little-endian)")
print("  Table starts IMMEDIATELY after the JSR instruction")
print()

# Caller 1: JSR at $A09E, table starts at $A0A1
print("=" * 70)
print("Caller 1: $A09E (AiOfficerActionDecide)")
print("  A = officer_state AND #$0F")
print("  Table at $A0A1, 8 entries (16 bytes), ends at $A0B0")
print("  Code resumes at $A0B1")
print()
for i in range(8):
    addr = 0xA0A1 + i*2
    target = read_word(addr)
    first_byte = read_byte(target)
    print(f"    [{i}] ${target:04X}  (first byte: ${first_byte:02X})")
print()
print("  Bytes after table ($A0B1+):")
dump_range(0xA0B1, 16)
print()

# Caller 2: JSR at $ACAB, table starts at $ACAE
print("=" * 70)
print("Caller 2: $ACAB")
print("  A = $002C (loaded at $ACA8)")
print("  Table at $ACAE")
print()
print("  Checking entries (looking for where valid addresses end):")
for i in range(12):
    addr = 0xACAE + i*2
    target = read_word(addr)
    valid = 0xA000 <= target <= 0xDFFF
    if valid:
        first_byte = read_byte(target)
        print(f"    [{i:2d}] ${target:04X}  VALID  (first byte: ${first_byte:02X})")
    else:
        print(f"    [{i:2d}] ${target:04X}  INVALID")
print()
print("  Context before ($ACA0-$ACAD):")
dump_range(0xACA0, 14)
print()
print("  Raw table bytes $ACAE-$ACD0:")
dump_range(0xACAE, 34)
print()

# Check what's at the dispatch targets for caller 2
print("  Dispatch target first bytes:")
for i in range(8):
    addr = 0xACAE + i*2
    target = read_word(addr)
    if 0xA000 <= target <= 0xBFFF:
        fb = read_byte(target)
        print(f"    [{i}] ${target:04X}: first_byte=${fb:02X}")

# Extended check for caller 2 table size
print("=" * 70)
print("Caller 2 - Extended entry check:")
for i in range(20):
    addr = 0xACAE + i*2
    if addr + 1 > 0xBFFF:
        print(f"  [{i:2d}] BEYOND BANK")
        break
    target = read_word(addr)
    valid = 0xA000 <= target <= 0xDFFF
    if valid and target < 0xC000:
        fb = read_byte(target)
        print(f"  [{i:2d}] ${target:04X}  VALID  first=${fb:02X}")
    else:
        status = "VALID(bank09)" if valid else "INVALID"
        print(f"  [{i:2d}] ${target:04X}  {status}")

print()
print("Unique dispatch target code snippets:")
targets_checked = set()
for i in range(16):
    addr = 0xACAE + i*2
    if addr + 1 > 0xBFFF:
        break
    target = read_word(addr)
    if target in targets_checked or not (0xA000 <= target < 0xC000):
        continue
    targets_checked.add(target)
    off = target - 0xA000
    snippet = ' '.join(f'{data[off+j]:02X}' for j in range(16))
    print(f"  ${target:04X}: {snippet}")

print()
print("=" * 70)
print("SUMMARY")
print("=" * 70)
print()
print("Loc_B517 is an INLINE DISPATCHER (like B1F_CallbackDispatcher):")
print("  - Usage: LDA #index / JSR $B517 / .word target0, target1, ...")
print("  - A = index into inline .word table")
print("  - Y is preserved (saved/restored via $20)")
print("  - JMP to target; handler's RTS returns to code AFTER the table")
print("  - Table size determined by max index value at each call site")
print()
print("Impact on disassembly:")
print("  - Bytes after 'JSR $B517' are NOT code - they are .word table entries")
print("  - Current prg_08_09.asm incorrectly disassembles these as instructions")
print("  - Must replace with .word directives and resume code after table")
