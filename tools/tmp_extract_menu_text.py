#!/usr/bin/env python3
"""Extract and decode menu display text from Sangokushi 2 PRG data banks.

Strategy:
1. Dump candidate text regions (scroll panel rows, tilemap streams).
2. Build char-code -> Unicode mapping from the officer name table in
   prg_10.bin ($101A, 10-byte records) using known officer readings.
3. Decode candidate strings and match against manual command vocabulary.
"""
import sys

PRG = "rom/prg/"


def load(bank):
    return open(f"{PRG}prg_{bank:02x}.bin", "rb").read()


def hexdump_row(row):
    return " ".join(f"{b:02X}" for b in row)


def dump_scroll_rows():
    # ScrollPanel_LoadRow switches bank Y=$26 (-> prg_06 via 5-bit mask) before
    # reading $95E6/$976E/$98F6; also check prg_12 as fallback.
    for bank in (0x06, 0x12):
        d = load(bank)
        for base, name in [(0x15E6, "$95E6"), (0x176E, "$976E"), (0x18F6, "$98F6")]:
            print(f"=== prg_{bank:02x} rows at {name} (offset {base:#06x}) ===")
            for r in range(8):
                row = d[base + r * 0x1C: base + (r + 1) * 0x1C]
                print(f"  row {r:2d}: {hexdump_row(row)}")
            print()


if __name__ == "__main__":
    dump_scroll_rows()
