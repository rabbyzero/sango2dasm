#!/usr/bin/env python3
"""
Generate bank stub files for disassembly.
Creates .asm stub files for each PRG bank that includes the binary data.
"""

import os
import sys

NUM_PRG_BANKS = 32

# Banks mapped only into the $8000-$9FFF SwitchBank8 window that hold data (no
# code) - see code/bank_switch_map.md 5.2. These render as data_XX.asm stubs;
# every other bank is code and renders as prg_XX.asm.
DATA_BANKS = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
              0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16}

def generate_bank_stubs(output_dir):
    """Generate assembly stub files for each PRG bank."""
    os.makedirs(output_dir, exist_ok=True)

    names = []
    # Generate stub for each bank
    for i in range(NUM_PRG_BANKS):
        segment = f"CODE_BANK{i:02X}"
        is_data = i in DATA_BANKS
        prefix = "data" if is_data else "prg"
        filename = f"{prefix}_{i:02x}.asm"
        names.append(filename)
        filepath = os.path.join(output_dir, filename)

        with open(filepath, 'w') as f:
            if is_data:
                f.write(f';===============================================================================\n')
                f.write(f'; DATA Bank {i:02X} (PRG ${i:02X}) - 8KB data bank, mapped into\n')
                f.write(f'; $8000-$9FFF by SwitchBank8; no code lives here\n')
                f.write(f'; (see code/bank_switch_map.md 5.2).\n')
                f.write(f';===============================================================================\n\n')
                f.write(f'.segment "{segment}"\n\n')
                f.write(f'; Raw slice of the stock ROM until its data tables are decoded.\n')
                f.write(f'; Original binary: rom/prg/prg_{i:02x}.bin\n\n')
            else:
                f.write(f';===============================================================================\n')
                f.write(f'; PRG Bank {i:02X} - code bank\n')
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
        f.write('; Include every PRG bank: code banks as prg_XX.asm, the $8000-window data\n')
        f.write('; banks (see code/bank_switch_map.md 5.2) as data_XX.asm\n')
        f.write(';===============================================================================\n\n')
        for name in names:
            f.write(f'.include "{name}"\n')
        f.write('\n')

    print(f"  Created all_banks.asm")

if __name__ == '__main__':
    output_dir = sys.argv[1] if len(sys.argv) > 1 else 'asm/banks'
    print(f"Generating PRG bank stubs in {output_dir}...")
    generate_bank_stubs(output_dir)
    print("Done!")
