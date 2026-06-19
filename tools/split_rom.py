#!/usr/bin/env python3
"""
Split NES ROM into PRG and CHR banks for disassembly.
Supports Namco-163 (Mapper 19) ROMs.
"""

import sys
import os
import struct

def parse_nes_header(data):
    """Parse iNES header."""
    if data[:4] != b'NES\x1a':
        raise ValueError("Not a valid NES ROM")

    prg_pages = data[4]
    chr_pages = data[5]
    flags6 = data[6]
    flags7 = data[7]

    mapper = (flags6 >> 4) | ((flags7 >> 4) << 4)
    mirror = flags6 & 1
    has_battery = (flags6 & 2) >> 1
    has_trainer = (flags6 & 4) >> 2
    four_screen = (flags6 & 8) >> 3

    return {
        'prg_pages': prg_pages,
        'chr_pages': chr_pages,
        'mapper': mapper,
        'mirror': mirror,
        'battery': has_battery,
        'trainer': has_trainer,
        'four_screen': four_screen,
        'header_size': 16
    }

def split_rom(rom_path, output_dir):
    """Split NES ROM into separate PRG and CHR files."""
    with open(rom_path, 'rb') as f:
        data = f.read()

    header = parse_nes_header(data)
    prg_size = header['prg_pages'] * 16384  # 16KB per PRG page
    chr_size = header['chr_pages'] * 8192   # 8KB per CHR page

    print(f"ROM: {os.path.basename(rom_path)}")
    print(f"Mapper: {header['mapper']} (Namco-163)" if header['mapper'] == 19 else f"Mapper: {header['mapper']}")
    print(f"PRG ROM: {header['prg_pages']} x 16KB = {prg_size // 1024}KB")
    print(f"CHR ROM: {header['chr_pages']} x 8KB = {chr_size // 1024}KB")
    print(f"Mirroring: {'Four-screen' if header['four_screen'] else 'Vertical' if header['mirror'] else 'Horizontal'}")
    print(f"Battery-backed: {'Yes' if header['battery'] else 'No'}")
    print()

    # Extract PRG ROM
    prg_start = header['header_size']
    if header['trainer']:
        prg_start += 512

    prg_data = data[prg_start:prg_start + prg_size]
    chr_data = data[prg_start + prg_size:prg_start + prg_size + chr_size]

    # Create output directories
    prg_dir = os.path.join(output_dir, 'prg')
    chr_dir = os.path.join(output_dir, 'chr')
    os.makedirs(prg_dir, exist_ok=True)
    os.makedirs(chr_dir, exist_ok=True)

    # Split PRG into 8KB banks (ca65 standard)
    bank_size = 8192
    num_prg_banks = len(prg_data) // bank_size

    print(f"Splitting PRG ROM into {num_prg_banks} banks...")
    for i in range(num_prg_banks):
        start = i * bank_size
        end = start + bank_size
        bank_data = prg_data[start:end]

        filename = f'prg_{i:02x}.bin'
        filepath = os.path.join(prg_dir, filename)
        with open(filepath, 'wb') as f:
            f.write(bank_data)

    # Split CHR into 8KB banks
    num_chr_banks = len(chr_data) // bank_size if chr_data else 0

    if num_chr_banks > 0:
        print(f"Splitting CHR ROM into {num_chr_banks} banks...")
        for i in range(num_chr_banks):
            start = i * bank_size
            end = start + bank_size
            bank_data = chr_data[start:end]

            filename = f'chr_{i:02x}.bin'
            filepath = os.path.join(chr_dir, filename)
            with open(filepath, 'wb') as f:
                f.write(bank_data)

    # Generate header file with ROM info
    header_file = os.path.join(output_dir, 'rom_info.h')
    with open(header_file, 'w') as f:
        f.write('; ROM Information - Auto-generated\n')
        f.write(f'; Mapper: {header["mapper"]}\n')
        f.write(f'; PRG Banks: {num_prg_banks}\n')
        f.write(f'; CHR Banks: {num_chr_banks}\n')
        f.write('\n')
        f.write(f'.define MAPPER {header["mapper"]}\n')
        f.write(f'.define PRG_BANKS {num_prg_banks}\n')
        f.write(f'.define CHR_BANKS {num_chr_banks}\n')

    # Generate a combined PRG binary for disassembler input
    combined_prg = os.path.join(output_dir, 'prg_combined.bin')
    with open(combined_prg, 'wb') as f:
        f.write(prg_data)

    print(f"\nOutput directory: {output_dir}")
    print(f"  - {num_prg_banks} PRG banks in prg/")
    print(f"  - {num_chr_banks} CHR banks in chr/")
    print(f"  - Combined PRG: prg_combined.bin")
    print(f"  - ROM info: rom_info.h")

    return header

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <rom.nes> [output_dir]")
        sys.exit(1)

    rom_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else 'rom'

    if not os.path.exists(rom_path):
        print(f"Error: File not found: {rom_path}")
        sys.exit(1)

    split_rom(rom_path, output_dir)

if __name__ == '__main__':
    main()
