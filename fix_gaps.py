#!/usr/bin/env python3
"""
Comprehensive gap byte fix for prg_1f.asm.

Removes previous incorrect gap byte insertions, fixes data overlap,
and inserts correct gap bytes from ROM at all gap locations.
"""
import re

SOURCE = 'asm/banks/prg_1f.asm'
ROM_PATH = 'rom/prg/prg_1f.bin'
OUTPUT = 'asm/banks/prg_1f.asm'

with open(ROM_PATH, 'rb') as f:
    rom = f.read()

with open(SOURCE) as f:
    lines = f.readlines()

# Patterns
addr_pat = re.compile(r';\s*\$([0-9A-Fa-f]{4}):\s*((?:[0-9A-Fa-f]{2}\s*)+)')
pad_label_pat = re.compile(r'^pad_[0-9a-f]{4}:')
res_pat = re.compile(r'\.res\s+(\d+)')

# ===========================================================================
# Phase 1: Remove previous gap byte insertions
# ===========================================================================
remove_indices = set()

for i, line in enumerate(lines):
    stripped = line.strip()
    # Remove pad_ label lines
    if pad_label_pat.match(stripped):
        remove_indices.add(i)
        continue
    # Remove .byte directives that are gap byte insertions (preceded by pad_ label)
    if stripped.startswith('.byte') and ';' in stripped:
        m = addr_pat.search(line)
        if m:
            # Check if preceded by pad_ label (within 3 lines)
            for j in range(max(0, i - 3), i):
                if pad_label_pat.match(lines[j].strip()):
                    remove_indices.add(i)
                    break

# Remove blank lines associated with pad_ blocks
for i in sorted(remove_indices):
    if i > 0 and lines[i - 1].strip() == '':
        for j in range(i + 1, min(i + 3, len(lines))):
            if j in remove_indices:
                remove_indices.add(i - 1)
                break

cleaned = []
for i, line in enumerate(lines):
    if i not in remove_indices:
        cleaned.append(line)

print(f"Phase 1: Removed {len(remove_indices)} lines, {len(cleaned)} remaining")

# ===========================================================================
# Phase 2: Fix DomesticBaseDataPtrs overlap
# ===========================================================================
for i, line in enumerate(cleaned):
    if line.strip() == 'DomesticBaseDataPtrs:':
        if i + 1 < len(cleaned) and cleaned[i + 1].strip().startswith('.byte'):
            print(f"\nPhase 2: Fixing DomesticBaseDataPtrs overlap at lines {i + 1}-{i + 2}")
            cleaned[i] = "; DomesticBaseDataPtrs is at offset 14 within DomesticGraphicPtrs\n"
            cleaned[i + 1] = "DomesticBaseDataPtrs = DomesticGraphicPtrs + 14\n"
            break

# ===========================================================================
# Phase 3: Fix Padding sizes
# Padding1: $F676-$F7FF is 394 bytes: 9 zero bytes + 385 $FF via .res
# Padding2: $FFD6-$FFF8 is 35 bytes, but there's also a $00 at $FFF9.
#   Insert 6 data bytes ($FFD6-$FFDB) as pad_ffd6, reduce .res 35 -> 30.
# ===========================================================================
padding1_line = -1
padding2_line = -1
for i, line in enumerate(cleaned):
    if ('.res 392' in line or '.res 374' in line or '.res 383' in line or '.res 385' in line) and '$FF' in line:
        print(f"\nPhase 3: Fixing Padding1 .res at line {i + 1}")
        cleaned[i] = re.sub(r'\.res \d+', '.res 385', line)
        padding1_line = i
    if '.res 35' in line and '$FF' in line:
        print(f"Phase 3: Fixing Padding2 .res at line {i + 1}")
        cleaned[i] = re.sub(r'\.res \d+', '.res 30', line)
        padding2_line = i

# ===========================================================================
# Phase 4: Detect gaps and insert correct gap bytes from ROM
# ===========================================================================
prev_end = 0xE000
gap_insertions = []

# First pass: find .res directive addresses to avoid double-counting
res_addresses = {}  # addr -> res_bytes
res_prev_end = 0xE000
for i, line in enumerate(cleaned):
    m = addr_pat.search(line)
    if m:
        addr = int(m.group(1), 16)
        hexbytes = m.group(2).split()
        if addr >= res_prev_end:
            res_prev_end = addr + len(hexbytes)
    rm = res_pat.search(line)
    if rm:
        res_bytes = int(rm.group(1))
        res_addresses[res_prev_end] = res_bytes
        res_prev_end += res_bytes

print(f"\nPhase 4: .res directives at addresses: {', '.join(f'${a:04X}({n}B)' for a,n in sorted(res_addresses.items()))}")

prev_end = 0xE000

for i, line in enumerate(cleaned):
    m = addr_pat.search(line)
    if not m:
        continue

    addr = int(m.group(1), 16)
    hexbytes = m.group(2).split()
    nbytes = len(hexbytes)

    if addr > prev_end:
        gap_size = addr - prev_end
        rom_offset = prev_end - 0xE000
        gap_bytes = rom[rom_offset:rom_offset + gap_size]

        # Check if a .res directive covers part of this gap
        res_bytes = res_addresses.get(prev_end, 0)
        if res_bytes > 0 and res_bytes < gap_size:
            # Only insert the non-.res portion
            actual_gap = gap_size - res_bytes
            gap_bytes = gap_bytes[:actual_gap]
            gap_size = actual_gap
            print(f"  .res at ${prev_end:04X} covers {res_bytes}B, inserting only {gap_size}B")

        insert_lines = []

        if raw_prev_end == 0xE079 and gap_size == 3:
            # Special: JMP ($004E) - dispatch indirect jump
            insert_lines.append("  JMP ($004E)               ; $E079: 6C 4E 00\n")
        elif raw_prev_end == 0xECEE and gap_size == 43:
            # Special: disassemble as 6502 code (memory copy routine)
            insert_lines.append("\n")
            insert_lines.append("; Undocumented function: $ECEE-$ED18 (memory copy)\n")
            insert_lines.append("pad_ecee:\n")
            insert_lines.append("  LDA #$01                  ; $ECEE: A9 01\n")
            insert_lines.append("  STA $0087                 ; $ECF0: 8D 87 00\n")
            insert_lines.append("  LDA #$00                  ; $ECF3: A9 00\n")
            insert_lines.append("  STA $0088                 ; $ECF5: 8D 88 00\n")
            insert_lines.append("  LDA #$04                  ; $ECF8: A9 04\n")
            insert_lines.append("  STA $0089                 ; $ECFA: 8D 89 00\n")
            insert_lines.append("  LDA #$00                  ; $ECFD: A9 00\n")
            insert_lines.append("  STA $00                   ; $ECFF: 85 00\n")
            insert_lines.append("  LDA #$01                  ; $ED01: A9 01\n")
            insert_lines.append("  STA $01                   ; $ED03: 85 01\n")
            insert_lines.append("  LDA #$20                  ; $ED05: A9 20\n")
            insert_lines.append("  STA $02                   ; $ED07: 85 02\n")
            insert_lines.append("  LDA #$01                  ; $ED09: A9 01\n")
            insert_lines.append("  STA $03                   ; $ED0B: 85 03\n")
            insert_lines.append("  LDY #$00                  ; $ED0D: A0 00\n")
            insert_lines.append("@loc_ed0f:\n")
            insert_lines.append("  LDA ($00),Y               ; $ED0F: B1 00\n")
            insert_lines.append("  STA ($02),Y               ; $ED11: 91 02\n")
            insert_lines.append("  INY                       ; $ED13: C8\n")
            insert_lines.append("  CPY #$20                  ; $ED14: C0 20\n")
            insert_lines.append("  BNE @loc_ed0f             ; $ED16: D0 F7\n")
            insert_lines.append("  RTS                       ; $ED18: 60\n")
        elif raw_prev_end == 0xF676:
            # Special: 9 zero bytes before Padding1 (.res handles $F67F-$F7FE)
            insert_lines.append("\n")
            insert_lines.append("pad_f676:\n")
            insert_lines.append(
                "  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00"
                "                 ; $F676: 00 00 00 00 00 00 00 00 00\n"
            )
        elif gap_size == 1:
            byte_val = gap_bytes[0]
            label_name = f"pad_{prev_end:04x}"
            insert_lines.append("\n")
            insert_lines.append(f"{label_name}:\n")
            insert_lines.append(
                f"  .byte ${byte_val:02X}"
                f"                 ; ${prev_end:04X}: {byte_val:02X}\n"
            )
        elif gap_size <= 16:
            label_name = f"pad_{prev_end:04x}"
            hex_str = ", ".join(f"${b:02X}" for b in gap_bytes)
            comment_hex = " ".join(f"{b:02X}" for b in gap_bytes)
            insert_lines.append("\n")
            insert_lines.append(f"{label_name}:\n")
            insert_lines.append(
                f"  .byte {hex_str}"
                f"                 ; ${prev_end:04X}: {comment_hex}\n"
            )
        else:
            # Large gap - dump as data rows
            insert_lines.append("\n")
            insert_lines.append(
                f"; Gap data: ${prev_end:04X}-${addr - 1:04X}"
                f" ({gap_size} bytes)\n"
            )
            label_name = f"pad_{prev_end:04x}"
            insert_lines.append(f"{label_name}:\n")
            for row_start in range(0, gap_size, 16):
                row_bytes = gap_bytes[row_start:row_start + 16]
                hex_str = ", ".join(f"${b:02X}" for b in row_bytes)
                comment_hex = " ".join(f"{b:02X}" for b in row_bytes)
                row_addr = prev_end + row_start
                insert_lines.append(
                    f"  .byte {hex_str}"
                    f"                 ; ${row_addr:04X}: {comment_hex}\n"
                )

        if insert_lines:
            gap_insertions.append((i, insert_lines))
            gap_hex = " ".join(f"{b:02X}" for b in gap_bytes[:16])
            if gap_size > 16:
                gap_hex += " ..."
            print(f"  Gap ${prev_end:04X}-${addr - 1:04X} ({gap_size}B): {gap_hex}")

    # Update prev_end with instruction/data bytes
    if addr >= prev_end:
        prev_end = addr + nbytes
    # Save the end address of this instruction/data for special case checks.
    raw_prev_end = prev_end

# Handle trailing gap bytes after the last instruction.
# The .res at Padding2 ($FFD6) covers 29 of the 35 bytes from $FFD6-$FFF8.
# The remaining 6 bytes ($FFD6-$FFDB) must be inserted as pad data.
# Find the first .addr line (Vectors section) as the insertion point.
if prev_end < 0xFFFF:
    trailing_addr = prev_end
    # Look for the Vectors section to determine insertion point
    for ti in range(len(cleaned) - 1, -1, -1):
        if '.addr' in cleaned[ti] and '$FFFA' in cleaned[ti]:
            # Found first vector line, search backward for insertion point
            # (before Padding2 comment/section)
            trailing_insert_lines = []
            trailing_rom_off = trailing_addr - 0xE000
            trailing_bytes = rom[trailing_rom_off:trailing_rom_off + 6]
            hex_str = ", ".join(f"${b:02X}" for b in trailing_bytes)
            comment_hex = " ".join(f"{b:02X}" for b in trailing_bytes)
            trailing_insert_lines.append("\n")
            trailing_insert_lines.append(f"pad_{trailing_addr:04x}:\n")
            trailing_insert_lines.append(
                f"  .byte {hex_str}"
                f"                 ; ${trailing_addr:04X}: {comment_hex}\n"
            )
            gap_insertions.append((ti, trailing_insert_lines))
            print(f"  Trailing gap ${trailing_addr:04X}-${trailing_addr+5:04X} (6B): {comment_hex}")
            break

print(f"\nPhase 4: {len(gap_insertions)} gap insertions")

# ===========================================================================
# Phase 5: Apply insertions (reverse order to maintain indices)
# Move insertions before .proc boundaries to keep pad_ labels in global scope
# ===========================================================================
proc_pat = re.compile(r'^\.proc\s+')
endproc_pat = re.compile(r'^\.endproc')

adjusted_insertions = []
for insert_before, insert_lines in gap_insertions:
    adjusted_point = insert_before
    
    # Check if insertion point is near a Padding comment (Padding1 or Padding2).
    # Search backward (up to 30 lines) for the Padding comment to insert
    # gap bytes BEFORE the .res directive. This search crosses .endproc
    # boundaries since the padding area is between procs.
    for j in range(insert_before, max(insert_before - 30, 0), -1):
        stripped_j = cleaned[j].strip()
        if stripped_j.startswith(';') and ('Padding1' in cleaned[j] or 'Padding2' in cleaned[j]):
            adjusted_point = j
            break
    
    # If no Padding1 found, search backward for a .proc line
    # (with no .endproc between it and insert point) to keep pad_ labels
    # in global scope
    if adjusted_point == insert_before:
        for j in range(insert_before - 1, max(insert_before - 20, 0), -1):
            stripped = cleaned[j].strip()
            if endproc_pat.match(stripped):
                break  # Found .endproc before .proc, stop - we're between procs
            if proc_pat.match(stripped):
                adjusted_point = j
                break
    
    adjusted_insertions.append((adjusted_point, insert_lines))

# Sort by insertion point (descending) to maintain indices
adjusted_insertions.sort(key=lambda x: x[0], reverse=True)

for insert_before, insert_lines in adjusted_insertions:
    for j, new_line in enumerate(reversed(insert_lines)):
        cleaned.insert(insert_before, new_line)

# ===========================================================================
# Phase 6: Write output and verify
# ===========================================================================
with open(OUTPUT, "w") as f:
    f.writelines(cleaned)

print(f"\nPhase 6: Wrote {len(cleaned)} lines to {OUTPUT}")

# Verify byte count
prev_end = 0xE000
remaining_gaps = 0
remaining_overlaps = 0

addr_dot_pat = re.compile(r'^\s*\.addr\s+')

for line in cleaned:
    m = addr_pat.search(line)
    if m:
        addr = int(m.group(1), 16)
        hexbytes = m.group(2).split()
        nbytes = len(hexbytes)
        if addr > prev_end:
            remaining_gaps += 1
            gap_size = addr - prev_end
            if gap_size > 1:
                print(f"  REMAINING GAP: ${prev_end:04X}-${addr - 1:04X} ({gap_size}B)")
        elif addr < prev_end:
            remaining_overlaps += 1
        if addr >= prev_end:
            prev_end = addr + nbytes
    rm = res_pat.search(line)
    if rm:
        prev_end += int(rm.group(1))
    # Track .addr directives (2 bytes each) for interrupt vectors
    if addr_dot_pat.match(line):
        prev_end += 2

total_bytes = prev_end - 0xE000
print(f"\nVerification:")
print(f"  Total bytes: {total_bytes} (expected 8192)")
print(f"  Remaining gaps: {remaining_gaps}")
print(f"  Remaining overlaps: {remaining_overlaps}")
if total_bytes == 8192:
    print("  SUCCESS: Byte count matches bank size!")
else:
    print(f"  WARNING: Off by {total_bytes - 8192:+d} bytes")
