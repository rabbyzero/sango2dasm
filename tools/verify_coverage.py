#!/usr/bin/env python3
import re

with open('/tmp/disasm_1d_final.txt') as f:
    lines = f.readlines()

total_bytes = 0
addrs_seen = set()
for line in lines:
    m = re.search(r'; \$([0-9A-F]{4}): (.+)$', line.rstrip())
    if m:
        addr = int(m.group(1), 16)
        hex_bytes = m.group(2).strip()
        byte_list = hex_bytes.split()
        count = len(byte_list)
        for i in range(count):
            addrs_seen.add(addr + i)
        total_bytes += count

print(f'Total bytes covered: {total_bytes} (expected 8192)')
print(f'Unique addresses: {len(addrs_seen)}')
print(f'Deficit: {8192 - total_bytes}')

# Check for gaps
expected = set(range(0xA000, 0xC000))
missing = expected - addrs_seen
if missing:
    print(f'\nMissing addresses ({len(missing)}):')
    for addr in sorted(missing)[:20]:
        print(f'  ${addr:04X}')
    if len(missing) > 20:
        print(f'  ... and {len(missing)-20} more')
else:
    print('\nNo gaps - all 8192 bytes covered!')
