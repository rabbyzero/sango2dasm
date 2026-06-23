#!/usr/bin/env python3
"""Dump bytes from prg_17.bin at offset $08FD (what the disassembly calls $A8FD)."""

with open('/home/zero/project/sango2dasm/rom/prg/prg_17.bin', 'rb') as f:
    data = f.read()

# Dump from offset $08D3 to $0988 (what disassembly calls $A8D3-$A988)
start = 0x08D3
end = 0x0989
length = end - start

print("prg_17.bin bytes at offset ${:04X}-${:04X} (disasm addresses ${:04X}-${:04X}):".format(
    start, end-1, start+0x8000, end-1+0x8000))
chunk = data[start:end]
for i in range(0, len(chunk), 16):
    addr = start + 0x8000 + i
    hex_bytes = ' '.join('{:02X}'.format(b) for b in chunk[i:i+16])
    ascii_repr = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk[i:i+16])
    print("${:04X}: {:<48} {}".format(addr, hex_bytes, ascii_repr))

# Also check the data table area specifically ($A8FD-$A988 = offset $08FD-$0988)
print("\nData table area ($08FD-$0988):")
table_start = 0x08FD
table_end = 0x0989
table_data = data[table_start:table_end]
for i in range(0, len(table_data), 10):
    entry_num = i // 10
    addr = table_start + 0x8000 + i
    entry = table_data[i:i+10]
    if len(entry) < 10:
        break
    hex_str = ' '.join('{:02X}'.format(b) for b in entry)
    ptr = entry[0] | (entry[1] << 8)
    print("Entry {:2d} (${04X}): {} -> .addr ${:04X}".format(entry_num, addr, hex_str, ptr))
