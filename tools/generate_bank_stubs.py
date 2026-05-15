#!/usr/bin/env python3
"""
Generate bank stub files for disassembly.
Creates .asm stub files for each PRG bank that includes the binary data.
"""

import os
import sys

NUM_PRG_BANKS = 32

def generate_bank_stubs(output_dir):
    """Generate assembly stub files for each PRG bank."""
    os.makedirs(output_dir, exist_ok=True)

    # Generate stub for each bank
    for i in range(NUM_PRG_BANKS):
        bank_addr = 0x8000 + (i * 0x2000) % 0x8000  # $8000, $A000, $C000, $E000
        segment = f"CODE_BANK{i:02X}"

        filename = f"prg_{i:02x}.asm"
        filepath = os.path.join(output_dir, filename)

        with open(filepath, 'w') as f:
            f.write(f';===============================================================================\n')
            f.write(f'; PRG Bank {i:02X} - ${bank_addr:04X}-${bank_addr+0x1FFF:04X}\n')
            f.write(f'; Generated stub for disassembly\n')
            f.write(f';===============================================================================\n\n')
            f.write(f'.segment "{segment}"\n\n')
            f.write(f'; TODO: Disassemble code here\n')
            f.write(f'; Original binary: rom/prg/prg_{i:02x}.bin\n\n')
            f.write(f'.incbin "rom/prg/prg_{i:02x}.bin"\n\n')

        print(f"  Created {filename}")

    # Generate include file for all banks
    include_file = os.path.join(output_dir, "all_banks.asm")
    with open(include_file, 'w') as f:
        f.write(';===============================================================================\n')
        f.write('; Include all PRG bank stubs\n')
        f.write(';===============================================================================\n\n')
        for i in range(NUM_PRG_BANKS):
            f.write(f'.include "prg_{i:02x}.asm"\n')
        f.write('\n')

    print(f"  Created all_banks.asm")

if __name__ == '__main__':
    output_dir = sys.argv[1] if len(sys.argv) > 1 else 'asm/banks'
    print(f"Generating PRG bank stubs in {output_dir}...")
    generate_bank_stubs(output_dir)
    print("Done!")
