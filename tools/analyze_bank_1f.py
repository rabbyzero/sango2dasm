#!/usr/bin/env python3
"""Analyze PRG bank 0x1F (boot bank) - comprehensive analysis"""

def analyze_boot_bank():
    # Read combined PRG to access all addresses
    with open('rom/prg_combined.bin', 'rb') as f:
        prg = f.read()

    with open('rom/prg/prg_1f.bin', 'rb') as f:
        bank_1f = f.read()

    print("=" * 70)
    print("BANK 0x1F ANALYSIS - Boot Bank (Main Loop & Basic Functions)")
    print("=" * 70)

    # 1. Vector table at $E07C
    print("\n1. VECTOR DISPATCH TABLE at $E07C")
    print("-" * 70)
    print("Idx | Vector Addr | Target    | Description")
    print("-" * 70)
    for i in range(32):
        addr = 0xE07C + (i * 2)
        low = prg[addr]
        high = prg[addr + 1]
        target = (high << 8) | low
        print(f"  {i:2d} | ${addr:04X}      | ${target:04X}  | Entry point {i}")

    # 2. Reset Handler Analysis
    print("\n\n2. RESET HANDLER at $8000")
    print("-" * 70)
    print("The reset handler does:")
    print("  1. SEI/CLD - Disable interrupts, clear decimal mode")
    print("  2. PPU warmup (wait for 3 VBlanks)")
    print("  3. APU init ($4010, $4015, $4017)")
    print("  4. Clear RAM $0000-$07FF (2KB)")
    print("  5. Set stack pointer to $FF")
    print("  6. Read counter at $007A, use it to index vector table at $E07C")
    print("  7. Jump through indirect vector ($004E)")
    print()
    print("Key: Counter $007A determines which game state to enter")
    print("  $007A & 0x1F = entry index (0-31)")
    print("  Vector = $E07C + (index * 2)")

    # 3. Bank switching patterns
    print("\n\n3. BANK SWITCHING PATTERNS")
    print("-" * 70)
    # Look for STA $F800, $FA00, $FC00, $FE00
    bank_switches = []
    for i in range(len(bank_1f)):
        byte = bank_1f[i]
        addr = 0x8000 + i
        # STA absolute pattern: 8D XX YY
        if byte == 0x8D and i + 2 < len(bank_1f):
            lo = bank_1f[i+1]
            hi = bank_1f[i+2]
            target_addr = (hi << 8) | lo
            if target_addr in (0xF800, 0xFA00, 0xFC00, 0xFE00):
                bank_switches.append((addr, target_addr))

    print(f"Found {len(bank_switches)} bank switch operations:")
    for addr, switch_addr in bank_switches[:20]:
        # Look at the LDA before the STA
        for j in range(max(0, addr - 0x8000 - 10), addr - 0x8000):
            if bank_1f[j] == 0xA9:  # LDA #imm
                bank_num = bank_1f[j+1]
                print(f"  ${addr:04X}: LDA #${bank_num:02X} -> STA ${switch_addr:04X} (slot ${switch_addr & 0x0300:04X})")
                break

    # 4. Find commonly called functions in this bank
    print("\n\n4. KEY FUNCTIONS IN BANK 0x1F")
    print("-" * 70)

    # Search for RTS instructions to find function boundaries
    functions = []
    in_func = False
    func_start = 0
    for i in range(len(bank_1f)):
        byte = bank_1f[i]
        addr = 0x8000 + i

        # Function entry points (targets of JMP or common patterns)
        if i == 0 or (byte == 0x4C and i + 2 < len(bank_1f)):  # JMP abs
            if not in_func:
                in_func = True
                func_start = addr

        if byte in (0x60, 0x40):  # RTS or RTI
            if in_func:
                functions.append((func_start, addr))
                in_func = False

    print(f"Found {len(functions)} potential functions")

    # Look at specific addresses that are frequently called
    # $F237 is called 55 times - but it's in another bank
    # Let's find what's actually IN this bank

    # JSR targets within $8000-$9FFF
    internal_jsrs = {}
    for i in range(len(bank_1f)):
        if bank_1f[i] == 0x20 and i + 2 < len(bank_1f):  # JSR
            lo = bank_1f[i+1]
            hi = bank_1f[i+2]
            target = (hi << 8) | lo
            if 0x8000 <= target <= 0x9FFF:
                internal_jsrs[target] = internal_jsrs.get(target, 0) + 1

    print(f"\nInternal JSR targets (within bank 0x1F):")
    for target, count in sorted(internal_jsrs.items(), key=lambda x: -x[1])[:20]:
        print(f"  ${target:04X}: called {count} times")

    # 5. Look for utility patterns
    print("\n\n5. UTILITY FUNCTION PATTERNS")
    print("-" * 70)

    # Search for random number generation (LFSR patterns)
    print("\nSearching for RNG patterns (LFSR, ASL/ROL/EOR sequences)...")
    for i in range(len(bank_1f) - 10):
        # Common LFSR: ASL, ROL, EOR
        if (bank_1f[i] == 0x0A and  # ASL A
            bank_1f[i+1] == 0x2A):  # ROL A
            addr = 0x8000 + i
            print(f"  Potential RNG at ${addr:04X}")

    # Search for multiply/divide (shift and add patterns)
    print("\nSearching for math patterns (multiply/divide)...")
    for i in range(len(bank_1f) - 8):
        # 16-bit multiply often has loops with shifts
        if (bank_1f[i] == 0x4A or bank_1f[i] == 0x0A):  # LSR or ASL
            # Check for loop patterns
            for j in range(i+1, min(i+20, len(bank_1f))):
                if bank_1f[j] == 0xD0:  # BNE (loop)
                    addr = 0x8000 + i
                    print(f"  Potential math routine at ${addr:04X} (shift + BNE loop)")
                    break

    # 6. Data tables
    print("\n\n6. DATA TABLES")
    print("-" * 70)

    # Look for LDA table,Y patterns
    table_lookups = {}
    for i in range(len(bank_1f) - 2):
        if bank_1f[i] == 0xB9:  # LDA abs,Y
            lo = bank_1f[i+1]
            hi = bank_1f[i+2]
            table_addr = (hi << 8) | lo
            table_lookups[table_addr] = table_lookups.get(table_addr, 0) + 1

    print("Table lookup addresses (LDA addr,Y):")
    for addr, count in sorted(table_lookups.items(), key=lambda x: -x[1])[:15]:
        bank = "0x1F" if 0x8000 <= addr <= 0x9FFF else "external"
        print(f"  ${addr:04X} ({bank}): used {count} times")

if __name__ == '__main__':
    analyze_boot_bank()
