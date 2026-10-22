#!/usr/bin/env python3
"""
Build NES ROM from PRG binary.
Adds the iNES header and the CHR banks extracted into rom/chr.

CHR is not written in assembly, so it is copied from rom/chr/chr_*.bin, and the
header flag bytes are copied from the original ROM when it is present; the
hardcoded mapper-19 flags below are only a fallback.
"""

import glob
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CHR_DIR = os.path.join(ROOT, "rom", "chr")
ORIGINAL = os.path.join(ROOT, "Sangokushi 2 - Haou no Tairiku (J).nes")


def read_chr():
    """Concatenate the CHR banks in page order."""
    pages = sorted(glob.glob(os.path.join(CHR_DIR, "chr_*.bin")))
    if not pages:
        sys.exit(f"no CHR banks in {CHR_DIR} - run: make split")
    data = b"".join(open(p, "rb").read() for p in pages)
    if len(data) % 8192:
        sys.exit(f"{CHR_DIR}: total CHR size {len(data)} is not a multiple of 8KB")
    return data, len(pages)


def build_nes(prg_path, output_path):
    """Create NES ROM with header."""
    with open(prg_path, 'rb') as f:
        prg_data = f.read()

    # Pad PRG to nearest 16KB multiple
    prg_size = len(prg_data)
    prg_pages = (prg_size + 16383) // 16384
    if prg_pages < 16:
        prg_pages = 16  # Match original ROM size
    prg_data = prg_data.ljust(prg_pages * 16384, b'\xFF')

    chr_data, chr_pages = read_chr()

    # Build iNES header (16 bytes)
    # Mapper 19 (Namco-163) = 0x13
    # Flags6: Mapper bits 7-4 = 0001, Battery = 1, Mirror = 0 (horizontal)
    #   0001 0010 = 0x12
    # Flags7: Mapper bits 3-0 = 0011
    #   0001 0000 = 0x10
    header = bytearray(16)
    header[0:4] = b'NES\x1a'
    header[4] = prg_pages  # PRG pages
    header[5] = chr_pages  # CHR pages
    header[6] = 0x12  # Mapper 19 (high) | Battery | Horizontal mirror
    header[7] = 0x10  # Mapper 19 (low) | NES 2.0

    original = open(ORIGINAL, 'rb').read() if os.path.exists(ORIGINAL) else None
    if original:
        header[6:16] = original[6:16]

    # Write ROM
    with open(output_path, 'wb') as f:
        f.write(header)
        f.write(prg_data)
        f.write(chr_data)

    print(f"Created {output_path}")
    print(f"  PRG: {prg_pages} x 16KB = {prg_pages * 16}KB")
    print(f"  CHR: {chr_pages} x 8KB = {chr_pages * 8}KB from {os.path.relpath(CHR_DIR, ROOT)}")
    print(f"  Header: original flag bytes" if original else
          f"  Header: hardcoded mapper-19 flags (original ROM not found)")
    print(f"  Mapper: 19 (Namco-163)")
    print(f"  Battery: Yes")
    print(f"  Mirror: Horizontal")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <prg.bin> <output.nes>")
        sys.exit(1)

    build_nes(sys.argv[1], sys.argv[2])
