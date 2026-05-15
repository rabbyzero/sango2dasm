#!/usr/bin/env python3
"""
Verify that the assembled ROM matches the original.
Used to check disassembly accuracy.
"""

import sys
import os

def compare_roms(original, rebuilt):
    """Compare two ROM files byte-by-byte."""
    with open(original, 'rb') as f:
        orig_data = f.read()

    with open(rebuilt, 'rb') as f:
        reb_data = f.read()

    print(f"Original: {os.path.basename(original)} ({len(orig_data)} bytes)")
    print(f"Rebuilt:  {os.path.basename(rebuilt)} ({len(reb_data)} bytes)")
    print()

    if len(orig_data) != len(reb_data):
        print(f"WARNING: Size mismatch!")
        print(f"  Original: {len(orig_data)} bytes")
        print(f"  Rebuilt:  {len(reb_data)} bytes")

    # Compare byte-by-byte
    min_len = min(len(orig_data), len(reb_data))
    mismatches = 0
    first_mismatch = None

    for i in range(min_len):
        if orig_data[i] != reb_data[i]:
            mismatches += 1
            if first_mismatch is None:
                first_mismatch = i
            if mismatches <= 20:
                print(f"  Mismatch at ${i:06X}: original ${orig_data[i]:02X}, rebuilt ${reb_data[i]:02X}")

    print()
    print(f"Total mismatches: {mismatches} / {min_len} bytes")

    if mismatches == 0 and len(orig_data) == len(reb_data):
        print("SUCCESS: ROMs are identical!")
        return 0
    else:
        accuracy = ((min_len - mismatches) / min_len) * 100
        print(f"Accuracy: {accuracy:.2f}%")
        if first_mismatch is not None:
            print(f"First mismatch at: ${first_mismatch:06X}")
        return 1

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <original.nes> <rebuilt.nes>")
        sys.exit(1)

    original = sys.argv[1]
    rebuilt = sys.argv[2]

    if not os.path.exists(original):
        print(f"Error: File not found: {original}")
        sys.exit(1)

    if not os.path.exists(rebuilt):
        print(f"Error: File not found: {rebuilt}")
        sys.exit(1)

    sys.exit(compare_roms(original, rebuilt))

if __name__ == '__main__':
    main()
