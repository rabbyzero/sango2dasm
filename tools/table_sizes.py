#!/usr/bin/env python3
"""Determine exact table sizes for all CallbackDispatcher sites."""
import struct

data = open('/home/zero/project/sango2dasm/rom/prg/prg_0c.bin','rb').read() + open('/home/zero/project/sango2dasm/rom/prg/prg_0d.bin','rb').read()
base = 0xA000

dispatchers = [
    (0xA02B, 0xA02E),
    (0xA051, 0xA054),
    (0xA21E, 0xA221),
    (0xA29C, 0xA29F),
    (0xA45F, 0xA462),
    (0xA885, 0xA888),
    (0xADA9, 0xADAC),
    (0xB03F, 0xB042),
    (0xB955, 0xB958),
    (0xBCA0, 0xBCA3),
    (0xBE81, 0xBE84),
    (0xC207, 0xC20A),
    (0xC694, 0xC697),
    (0xC784, 0xC787),
    (0xC98F, 0xC992),
    (0xCD19, 0xCD1C),
    (0xD2D0, 0xD2D3),
]

print("=== CallbackDispatcher table sizes ===")
print(f"{'JSR_addr':<10} {'Table_start':<12} {'Entries':<8} {'Table_end':<10} {'Entry values'}")
print("-" * 80)

for jsr_addr, table_start in dispatchers:
    off = table_start - base
    entries = []
    for i in range(32):
        if off + i*2 + 1 >= len(data):
            break
        w = struct.unpack_from('<H', data, off + i*2)[0]
        if 0xA000 <= w <= 0xDFFF:
            entries.append(w)
        else:
            break
    table_end = table_start + len(entries) * 2
    entry_str = " ".join(f"${w:04X}" for w in entries[:6])
    if len(entries) > 6:
        entry_str += f" ... (+{len(entries)-6} more)"
    print(f"${jsr_addr:04X}    ${table_start:04X}      {len(entries):<8} ${table_end:04X}    {entry_str}")

# Also verify BankedCallbackTrampoline sites
print("\n=== BankedCallbackTrampoline inline targets ===")
tramps = []
for i in range(len(data) - 4):
    if data[i] == 0x20 and data[i+1] == 0x07 and data[i+2] == 0xEE:
        jsr_addr = base + i
        target = struct.unpack_from('<H', data, i+3)[0]
        tramps.append((jsr_addr, target))

print(f"{'JSR_addr':<10} {'Target':<10} {'Resume_at'}")
print("-" * 40)
for jsr_addr, target in tramps:
    resume = jsr_addr + 5
    print(f"${jsr_addr:04X}    ${target:04X}    ${resume:04X}")
