#!/usr/bin/env python3
"""Analyze bank 0x1F - find functions, tables, and key patterns"""

def analyze_bank():
    with open('rom/prg/prg_1f.bin', 'rb') as f:
        data = f.read()
    
    base = 0x8000
    
    print("=" * 70)
    print("BANK 0x1F ANALYSIS - Boot Bank (Main Loop & Basic Functions)")
    print("=" * 70)
    
    # 1. Find function boundaries (RTS/RTI as end markers)
    print("\n1. FUNCTION BOUNDARIES")
    print("-" * 70)
    
    functions = []
    func_start = 0x8000
    in_func = True
    
    for i in range(len(data)):
        byte = data[i]
        addr = base + i
        
        if byte in (0x60, 0x40):  # RTS or RTI
            if in_func:
                functions.append((func_start, addr))
                in_func = False
        elif not in_func:
            # New function starts here
            func_start = addr
            in_func = True
    
    print(f"Found {len(functions)} functions:")
    for i, (start, end) in enumerate(functions[:30]):
        size = end - start + 1
        # Count JSRs in this function
        jsr_count = 0
        for j in range(start - base, min(end - base + 1, len(data))):
            if data[j] == 0x20:  # JSR
                jsr_count += 1
        
        print(f"  Func {i:2d}: ${start:04X}-${end:04X} ({size:3d} bytes, {jsr_count} JSRs)")
    
    # 2. Find all JSR targets that are INTERNAL to this bank ($8000-$9FFF)
    print("\n2. INTERNAL JSR TARGETS (within bank 0x1F)")
    print("-" * 70)
    
    internal_jsrs = {}
    for i in range(len(data) - 2):
        if data[i] == 0x20:  # JSR
            lo = data[i+1]
            hi = data[i+2]
            target = (hi << 8) | lo
            if 0x8000 <= target <= 0x9FFF:
                internal_jsrs[target] = internal_jsrs.get(target, 0) + 1
    
    for target, count in sorted(internal_jsrs.items(), key=lambda x: -x[1]):
        print(f"  ${target:04X}: called {count} times")
    
    # 3. Find bank switch patterns (STA $F800/$FA00/$FC00/$FE00)
    print("\n3. BANK SWITCHING OPERATIONS")
    print("-" * 70)
    
    bank_switches = []
    for i in range(len(data) - 2):
        if data[i] == 0x8D:  # STA absolute
            lo = data[i+1]
            hi = data[i+2]
            target = (hi << 8) | lo
            if target in (0xF800, 0xFA00, 0xFC00, 0xFE00):
                # Look backwards for the LDA #imm
                for j in range(max(0, i-5), i):
                    if data[j] == 0xA9:  # LDA #imm
                        bank_num = data[j+1]
                        addr = base + i
                        bank_switches.append((addr, bank_num, target))
                        break
    
    slot_names = {0xF800: "$8000-$9FFF", 0xFA00: "$A000-$BFFF", 
                  0xFC00: "$C000-$DFFF", 0xFE00: "$E000-$FFFF"}
    
    print(f"Found {len(bank_switches)} bank switches:")
    for addr, bank, switch_addr in bank_switches:
        print(f"  ${addr:04X}: LDA #${bank:02X} -> STA ${switch_addr:04X} (slot {slot_names[switch_addr]})")
    
    # 4. Find JMP $E066 pattern (main loop return)
    print("\n4. MAIN LOOP DISPATCH (JMP $E066)")
    print("-" * 70)
    
    jmp_e066 = []
    for i in range(len(data) - 2):
        if data[i] == 0x4C and data[i+1] == 0x66 and data[i+2] == 0xE0:
            addr = base + i
            # Look backwards to find the entry point
            for j in range(max(0, i-200), i):
                # Look for LDA #$XX STA $007A pattern
                if (data[j] == 0xA9 and j+4 < len(data) and 
                    data[j+2] == 0x8D and data[j+3] == 0x7A and data[j+4] == 0x00):
                    value = data[j+1]
                    jmp_e066.append((addr, value))
                    break
    
    print("Entry points that return to main loop ($E066):")
    for jmp_addr, entry_val in jmp_e066:
        print(f"  Entry ${entry_val:02X}: returns via JMP at ${jmp_addr:04X}")
    
    # 5. Find data table patterns (LDA addr,Y)
    print("\n5. TABLE LOOKUP ADDRESSES (LDA addr,Y)")
    print("-" * 70)
    
    table_refs = {}
    for i in range(len(data) - 2):
        if data[i] == 0xB9:  # LDA abs,Y
            lo = data[i+1]
            hi = data[i+2]
            table_addr = (hi << 8) | lo
            if table_addr not in table_refs:
                table_refs[table_addr] = []
            table_refs[table_addr].append(base + i)
    
    for addr, refs in sorted(table_refs.items(), key=lambda x: -len(x[1]))[:15]:
        bank = "0x1F" if 0x8000 <= addr <= 0x9FFF else "other"
        print(f"  ${addr:04X} ({bank}): referenced {len(refs)} times")
        if len(refs) <= 5:
            for ref in refs:
                print(f"    at ${ref:04X}")
    
    # 6. Common external function calls
    print("\n6. MOST CALLED EXTERNAL FUNCTIONS")
    print("-" * 70)
    
    external_jsrs = {}
    for i in range(len(data) - 2):
        if data[i] == 0x20:  # JSR
            lo = data[i+1]
            hi = data[i+2]
            target = (hi << 8) | lo
            if target < 0x8000 or target > 0x9FFF:
                external_jsrs[target] = external_jsrs.get(target, 0) + 1
    
    print("Top external JSR targets:")
    for target, count in sorted(external_jsrs.items(), key=lambda x: -x[1])[:20]:
        # Determine which bank this might be in
        bank = "unknown"
        if 0xA000 <= target <= 0xFFFF:
            # Could be in any bank loaded into slots
            bank = "switched"
        print(f"  ${target:04X} ({bank}): called {count} times")

if __name__ == '__main__':
    analyze_bank()
