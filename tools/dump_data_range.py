#!/usr/bin/env python3
data = open('rom/prg/prg_1e.bin','rb').read()
start = 0x1BCF  # $DBCF - $C000
end = 0x1D8B    # $DD8A - $C000 + 1
raw = data[start:end]
print(f'Length: {len(raw)} bytes')
for i in range(0, len(raw), 16):
    chunk = raw[i:i+16]
    addr = 0xDBCF + i
    bytes_str = ', '.join(f'${b:02X}' for b in chunk)
    comment = ' '.join(f'{b:02X}' for b in chunk)
    print(f'  .byte {bytes_str:<64s} ; ${addr:04X}: {comment}')
