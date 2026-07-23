#!/usr/bin/env python3
"""Check the address list pattern following BankedCallbackTrampoline and CallbackDispatcher calls."""
import struct
import sys

def analyze_bank(filename, base_addr):
    data = open(filename, "rb").read()
    
    print(f"=== Bank at ${base_addr:04X} ===")
    print()
    
    # BankedCallbackTrampoline (JSR $EE07)
    print("--- BankedCallbackTrampoline (JSR $EE07) inline targets ---")
    for i in range(len(data)-3):
        if data[i] == 0x20 and data[i+1] == 0x07 and data[i+2] == 0xEE:
            addr = base_addr + i
            offset = i + 3
            words = []
            for j in range(8):
                if offset + j*2 + 1 < len(data):
                    w = struct.unpack_from("<H", data, offset + j*2)[0]
                    words.append(w)
            if not words:
                continue
            first = words[0]
            addr_list = [first]
            for w in words[1:]:
                if w < first:
                    break
                addr_list.append(w)
            next_idx = len(addr_list)
            next_w = words[next_idx] if next_idx < len(words) else None
            entries_str = " ".join(f"${w:04X}" for w in addr_list)
            print(f"  ${addr:04X}: [{entries_str}] next=${next_w:04X}" if next_w else f"  ${addr:04X}: [{entries_str}]")
    
    print()
    
    # CallbackDispatcher (JSR $EADE)
    print("--- CallbackDispatcher (JSR $EADE) inline tables ---")
    for i in range(len(data)-3):
        if data[i] == 0x20 and data[i+1] == 0xDE and data[i+2] == 0xEA:
            addr = base_addr + i
            offset = i + 3
            words = []
            for j in range(20):
                if offset + j*2 + 1 < len(data):
                    w = struct.unpack_from("<H", data, offset + j*2)[0]
                    words.append(w)
            if not words:
                continue
            first = words[0]
            addr_list = [first]
            for w in words[1:]:
                if w < first:
                    break
                addr_list.append(w)
            next_idx = len(addr_list)
            next_w = words[next_idx] if next_idx < len(words) else None
            entries_str = " ".join(f"${w:04X}" for w in addr_list)
            next_str = f"${next_w:04X}" if next_w else "N/A"
            print(f"  ${addr:04X}: {len(addr_list)} entries [{entries_str}] next={next_str} < min=${first:04X}")

if __name__ == "__main__":
    analyze_bank("/home/zero/project/sango2dasm/rom/prg/prg_0c.bin", 0xA000)
