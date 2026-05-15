#!/usr/bin/env python3
"""
Analyze NES ROM structure and generate disassembly reference.
Outputs bank layout, code regions, and potential entry points.
"""

import sys
import os

def analyze_rom(rom_path):
    """Analyze NES ROM and print structure information."""
    with open(rom_path, 'rb') as f:
        data = f.read()

    # Parse header
    if data[:4] != b'NES\x1a':
        print("Error: Not a valid NES ROM")
        return

    prg_pages = data[4]
    chr_pages = data[5]
    flags6 = data[6]
    flags7 = data[7]

    mapper = ((flags7 >> 4) & 0x0F) | (flags6 >> 4)
    mirror = flags6 & 1
    battery = (flags6 & 2) >> 1

    prg_size = prg_pages * 16384
    chr_size = chr_pages * 8192

    print("=" * 70)
    print("Sangokushi 2 - Haou no Tairiku (J) - ROM Analysis")
    print("=" * 70)
    print(f"Mapper:       {mapper} (Namco-163)")
    print(f"PRG ROM:      {prg_pages} x 16KB = {prg_size // 1024}KB")
    print(f"CHR ROM:      {chr_pages} x 8KB = {chr_size // 1024}KB")
    print(f"Mirroring:    {'Vertical' if mirror else 'Horizontal'}")
    print(f"Battery:      {'Yes' if battery else 'No'}")
    print()

    # PRG data starts after header
    prg_data = data[16:16 + prg_size]
    num_8k_banks = len(prg_data) // 8192

    print(f"PRG ROM Structure ({num_8k_banks} x 8KB banks):")
    print("-" * 70)

    # Analyze each 8KB bank
    for i in range(num_8k_banks):
        start = i * 8192
        bank = prg_data[start:start + 8192]

        # Count non-zero bytes
        non_zero = sum(1 for b in bank if b != 0)
        non_ff = sum(1 for b in bank if b != 0xFF)

        # Find code patterns
        sei_cld = []
        for j in range(len(bank) - 1):
            if bank[j] == 0x78 and bank[j+1] == 0xD8:
                sei_cld.append(j)

        jsr_count = bank.count(0x20)
        rts_count = bank.count(0x60)
        rti_count = bank.count(0x40)

        # Check for interrupt vectors
        has_vectors = False
        vec_addr = None
        for j in range(len(bank) - 5):
            if j % 2 == 0:
                v1 = bank[j] | (bank[j+1] << 8)
                v2 = bank[j+2] | (bank[j+3] << 8)
                v3 = bank[j+4] | (bank[j+5] << 8)
                if (0x8000 <= v1 <= 0xFFFF and
                    0x8000 <= v2 <= 0xFFFF and
                    0x8000 <= v3 <= 0xFFFF and
                    abs(v1 - v2) < 0x2000 and
                    abs(v2 - v3) < 0x2000):
                    has_vectors = True
                    vec_addr = j
                    break

        # Print bank info
        code_indicator = ""
        if sei_cld:
            code_indicator = " [RESET]"
        elif jsr_count > 100:
            code_indicator = " [CODE]"
        elif non_zero < 100 and non_ff < 100:
            code_indicator = " [EMPTY]"
        elif non_zero == 0:
            code_indicator = " [ZERO]"
        elif non_ff == 0:
            code_indicator = " [0xFF]"

        print(f"  Bank {i:02X} (${start:05X}-${start+8191:05X}): "
              f"NZ={non_zero:5d} N-FF={non_ff:5d} "
              f"JSR={jsr_count:3d} RTS={rts_count:3d} RTI={rti_count:2d}"
              f"{code_indicator}")

        if sei_cld:
            for pos in sei_cld:
                print(f"    -> Reset candidate at ${0x8000 + pos:04X}")
        if has_vectors:
            v1 = bank[vec_addr] | (bank[vec_addr+1] << 8)
            v2 = bank[vec_addr+2] | (bank[vec_addr+3] << 8)
            v3 = bank[vec_addr+4] | (bank[vec_addr+5] << 8)
            print(f"    -> Vectors at ${0x8000 + vec_addr:04X}: "
                  f"NMI=${v1:04X} RST=${v2:04X} IRQ=${v3:04X}")

    print()
    print("=" * 70)
    print("Disassembly Notes:")
    print("=" * 70)
    print("- Namco-163 uses 8KB bank switching")
    print("- Banks are switched via writes to $F800-$FFFF range")
    print("- Reset code found at bank 0x1F, offset $8000")
    print("- SRAM at $6000-$7FFF is battery-backed (save data)")
    print("- Use ca65/ld65 (cc65) for assembly")
    print()
    print("Next Steps:")
    print("  1. Disassemble bank 0x1F first (contains reset handler)")
    print("  2. Identify bank switching routines")
    print("  3. Map out which banks are used for what purpose")
    print("  4. Gradually disassemble other banks")

if __name__ == '__main__':
    rom_path = sys.argv[1] if len(sys.argv) > 1 else 'Sangokushi 2 - Haou no Tairiku (J).nes'
    if not os.path.exists(rom_path):
        print(f"Error: File not found: {rom_path}")
        sys.exit(1)
    analyze_rom(rom_path)
