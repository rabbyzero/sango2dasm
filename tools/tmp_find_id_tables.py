#!/usr/bin/env python3
"""Find menu selection -> command ID tables using known army IDs.

Army list order: シュツジン,チョウヘイ,テイサツ,ニンメイ = IDs contain
{12,0A,13}. Search for 4-6 byte tables containing these as a permutation
plus the unknown ニンメイ id.
"""
data = open('rom/prg_combined.bin', 'rb').read()

known = {0x12, 0x0A, 0x13}
print('--- candidate army ID tables (3 of 4 bytes match {12,0A,13}) ---')
for i in range(len(data) - 6):
    b = data[i:i + 6]
    if sum(x in known for x in b[:4]) == 3 and len(set(b[:4])) == 4:
        bank, loc = i // 0x2000, 0x8000 + i % 0x2000
        if 0x10 <= bank <= 0x13:
            print(f'  bank{bank:02X} ${loc:04X}: '
                  + ' '.join(f'{x:02X}' for x in b))

print('--- candidate castle ID tables (contains 03 and 6 distinct ids) ---')
castle_known = {0x03}
for i in range(0x12 * 0x2000, 0x14 * 0x2000 - 8):
    b = data[i:i + 6]
    if 0x03 in b[:6] and all(2 <= x <= 0x1B for x in b[:6]):
        # need also 0C (transfer) or 11 (intrigue) to be castle-ish
        if 0x0C in b[:6] or 0x11 in b[:6]:
            bank, loc = i // 0x2000, 0x8000 + i % 0x2000
            print(f'  bank{bank:02X} ${loc:04X}: '
                  + ' '.join(f'{x:02X}' for x in data[i:i + 8]))
