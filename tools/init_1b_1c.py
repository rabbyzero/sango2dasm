#!/usr/bin/env python3
"""
Initialize asm/banks/prg_1b_1c.asm from output/prg_1b_1c_raw.asm.

Steps:
  1. Parse the raw disassembly produced by tools/disasm_prg.py.
  2. Convert instruction runs containing ca65-unsupported opcodes
     (illegal opcode names such as SLO/JAM/RRA, NOP with operand, or an
     instruction straddling the $BFFF/$C000 bank boundary) into .byte data.
  3. Force absolute addressing (a: prefix) for direct $00xx operands that
     the ROM encodes with absolute (3-byte) opcodes; ca65 would otherwise
     shrink them to zero-page encoding.
  4. Regenerate code/data region markers and insert .segment directives:
     CODE_BANK1B for $A000-$BFFF, CODE_BANK1C for $C000-$DFFF.
  5. Verify the emitted byte stream matches the combined ROM banks exactly.
"""

import re
import sys

RAW_PATH = "output/prg_1b_1c_raw.asm"
OUT_PATH = "asm/banks/prg_1b_1c.asm"
BANK_LO = "rom/prg/prg_1b.bin"
BANK_HI = "rom/prg/prg_1c.bin"
BOUNDARY = 0xC000

LEGAL_MNEMONICS = {
    "ADC", "AND", "ASL", "BCC", "BCS", "BEQ", "BIT", "BMI", "BNE", "BPL",
    "BRK", "BVC", "BVS", "CLC", "CLD", "CLI", "CLV", "CMP", "CPX", "CPY",
    "DEC", "DEX", "DEY", "EOR", "INC", "INX", "INY", "JMP", "JSR", "LDA",
    "LDX", "LDY", "LSR", "NOP", "ORA", "PHA", "PHP", "PLA", "PLP", "ROL",
    "ROR", "RTI", "RTS", "SBC", "SEC", "SED", "SEI", "STA", "STX", "STY",
    "TAX", "TAY", "TSX", "TXA", "TXS", "TYA",
}

LABEL_RE = re.compile(r"^(Loc_[0-9A-F]{4}):(.*)$")
MARKER_RE = re.compile(r"^; --- (Code|Data) Region ---$")
# instruction line: "  MNEMONIC [operand]   ; $ADDR: XX YY ZZ"
INSTR_RE = re.compile(r"^  (.+?)\s+; \$([0-9A-F]{4}): ([0-9A-F ]+?)\s*$")
# data line: "  .byte $..,... ; $ADDR: XX YY ..."
DATA_RE = re.compile(r"^  \.byte (.+?);\s*\$([0-9A-F]{4}): ([0-9A-F ]+?)\s*$")


def parse_instr(line):
    m = INSTR_RE.match(line)
    if not m:
        return None
    text, addr, hexbytes = m.groups()
    parts = text.split(None, 1)
    mnemonic = parts[0]
    operand = parts[1].strip() if len(parts) > 1 else ""
    return {
        "text": text,
        "mnemonic": mnemonic,
        "operand": operand,
        "addr": int(addr, 16),
        "bytes": [int(b, 16) for b in hexbytes.split()],
    }


def is_bad(instr):
    """Instruction cannot be assembled by ca65 or straddles the bank boundary."""
    mn = instr["mnemonic"]
    if mn not in LEGAL_MNEMONICS:
        return True
    if mn == "NOP" and instr["operand"]:
        return True
    end = instr["addr"] + len(instr["bytes"])
    if instr["addr"] < BOUNDARY < end:
        return True
    return False


def fix_abs_zp(instr):
    """Add a: prefix when ROM uses absolute encoding for a $00xx operand."""
    op = instr["operand"]
    if len(instr["bytes"]) != 3 or not op:
        return instr["text"]
    m = re.match(r"^\$([0-9A-F]{1,4})(,X|,Y)?$", op)
    if not m:
        return instr["text"]
    val = int(m.group(1), 16)
    if val > 0xFF:
        return instr["text"]
    suffix = m.group(2) or ""
    return "{} a:${:04X}{}".format(instr["mnemonic"], val, suffix)


def data_rows(addr, bs):
    """Emit .byte rows of <=16 bytes with hex comments (raw output style)."""
    rows = []
    i = 0
    while i < len(bs):
        chunk = bs[i:i + 16]
        hex_bytes = ",".join("${:02X}".format(b) for b in chunk)
        raw_hex = " ".join("{:02X}".format(b) for b in chunk)
        padded = "  .byte {:<34s}".format(hex_bytes)
        rows.append((addr + i, chunk,
                     "{}; ${:04X}: {}".format(padded, addr + i, raw_hex)))
        i += len(chunk)
    return rows


def main():
    rom = open(BANK_LO, "rb").read() + open(BANK_HI, "rb").read()
    assert len(rom) == 0x4000

    lines = open(RAW_PATH).read().splitlines()

    # ---- Pass 1: parse into items ----
    # item = ("label", line) | ("instr", instr) | ("data", addr, bytes, line)
    items = []
    for line in lines:
        m = LABEL_RE.match(line)
        if m:
            items.append(("label", line))
            continue
        if MARKER_RE.match(line):
            continue  # regenerated later
        m = DATA_RE.match(line)
        if m:
            _, addr, hexbytes = m.groups()
            bs = [int(b, 16) for b in hexbytes.split()]
            items.append(("data", int(addr, 16), bs, line))
            continue
        instr = parse_instr(line)
        if instr:
            items.append(("instr", instr))
            continue
        if line.strip() == "":
            continue
        print("UNPARSED LINE: {}".format(line), file=sys.stderr)
        sys.exit(1)

    # ---- Pass 2: group instruction runs, convert bad runs to data ----
    out_items = []  # ("label",line) | ("code", text, addr, bytes) | ("data", addr, bytes)
    i = 0
    n_runs_bad = 0
    while i < len(items):
        kind = items[i][0]
        if kind != "instr":
            if kind == "label":
                out_items.append(items[i])
            else:
                _, addr, bs, _line = items[i]
                out_items.append(("data", addr, bs))
            i += 1
            continue
        j = i
        run = []
        while j < len(items) and items[j][0] == "instr":
            run.append(items[j][1])
            j += 1
        if any(is_bad(x) for x in run):
            n_runs_bad += 1
            base = run[0]["addr"]
            blob = []
            for x in run:
                assert x["addr"] == base + len(blob), \
                    "run gap at ${:04X}".format(x["addr"])
                blob.extend(x["bytes"])
            out_items.append(("data", base, blob))
        else:
            for x in run:
                out_items.append(("code", fix_abs_zp(x), x["addr"], x["bytes"]))
        i = j

    print("Converted {} bad instruction runs to data".format(n_runs_bad),
          file=sys.stderr)

    # ---- Pass 3: emit with segment switches + regenerated markers ----
    header = [
        ";===============================================================================",
        "; PRG Banks $1B+$1C - Combined 16KB ($A000-$DFFF)",
        "; Sangokushi 2 - Haou no Tairiku (J)",
        "; Namco-163 Mapper 19",
        ";",
        "; Bank $1B at $A000-$BFFF, Bank $1C at $C000-$DFFF",
        ";===============================================================================",
        "",
        '.include "6502_registers.h"',
        '.include "namco163.h"',
        '.include "functions.h"',
        "",
    ]

    emitted = []       # (addr, bytes) for verification
    out_lines = list(header)
    cur_seg = None
    last_class = None  # "code" | "data"

    # Address of the next content byte at/after each item index, so labels
    # can be emitted after the correct .segment directive.
    next_addr = [None] * (len(out_items) + 1)
    for k in range(len(out_items) - 1, -1, -1):
        it = out_items[k]
        if it[0] == "label":
            next_addr[k] = next_addr[k + 1]
        elif it[0] == "code":
            next_addr[k] = it[2]
        else:
            next_addr[k] = it[1]

    def switch_seg(addr):
        nonlocal cur_seg
        seg = "CODE_BANK1B" if addr < BOUNDARY else "CODE_BANK1C"
        if seg != cur_seg:
            out_lines.append("")
            out_lines.append('.segment "{}"'.format(seg))
            out_lines.append("")
            cur_seg = seg

    def marker(cls):
        nonlocal last_class
        if cls != last_class:
            out_lines.append("; --- {} Region ---".format(
                "Code" if cls == "code" else "Data"))
            last_class = cls

    for idx, it in enumerate(out_items):
        if it[0] == "label":
            if next_addr[idx] is not None:
                switch_seg(next_addr[idx])
            out_lines.append(it[1])
            continue
        if it[0] == "code":
            _, text, addr, bs = it
            switch_seg(addr)
            marker("code")
            out_lines.append("  {:<40s}; ${:04X}: {}".format(
                text, addr, " ".join("{:02X}".format(b) for b in bs)))
            emitted.append((addr, bs))
            continue
        # data: split rows, and split across the bank boundary if needed
        addr, bs = it[1], it[2]
        pos = 0
        while pos < len(bs):
            seg_end = 0xE000 if addr + pos >= BOUNDARY else BOUNDARY
            room = seg_end - (addr + pos)
            chunk_len = min(len(bs) - pos, room)
            chunk = bs[pos:pos + chunk_len]
            for row_addr, row_bs, row_text in data_rows(addr + pos, chunk):
                switch_seg(row_addr)
                marker("data")
                out_lines.append(row_text)
                emitted.append((row_addr, row_bs))
            pos += chunk_len

    out_lines.append("")

    # ---- Pass 4: verify byte stream against ROM ----
    stream = bytearray()
    expected_addr = 0xA000
    for addr, bs in emitted:
        if addr != expected_addr:
            print("Gap/overlap: expected ${:04X}, got ${:04X}".format(
                expected_addr, addr), file=sys.stderr)
            sys.exit(1)
        stream.extend(bs)
        expected_addr += len(bs)
    if len(stream) != len(rom):
        print("Length mismatch: {} vs {}".format(len(stream), len(rom)),
              file=sys.stderr)
        sys.exit(1)
    for k, (a, b) in enumerate(zip(stream, rom)):
        if a != b:
            print("Byte mismatch at ${:04X}: {:02X} vs {:02X}".format(
                0xA000 + k, a, b), file=sys.stderr)
            sys.exit(1)
    print("Verified: {} bytes match ROM exactly".format(len(stream)),
          file=sys.stderr)

    with open(OUT_PATH, "w") as f:
        f.write("\n".join(out_lines))
    print("Wrote {} ({} lines)".format(OUT_PATH, len(out_lines)),
          file=sys.stderr)


if __name__ == "__main__":
    main()
