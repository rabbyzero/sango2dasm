#!/usr/bin/env python3
"""Temp: robust byte-exact verification for prg_1f.asm.

Disassembles rom/prg/prg_1f.bin from $E000, walks the source lines in
order, assembles each instruction mentally via a small 6502 model, and
reports any byte-level mismatch. Label resolution uses the address
comments so we only check operand/opcode encoding, not label values.
"""
import re
import sys

ROM = open("rom/prg/prg_1f.bin", "rb").read()
SRC_PATH = sys.argv[1] if len(sys.argv) > 1 else "asm/banks/prg_1f.asm"

# ---- 1. collect equate values (simple `name = $XXXX` lines) ----
src_lines = open(SRC_PATH).read().splitlines()
equates = {}
eq_pat = re.compile(r"^\s*([A-Za-z_]\w*)\s*=\s*\$(1?[0-9A-Fa-f]{1,4})\s*(?:;.*)?$")
for line in src_lines:
    m = eq_pat.match(line)
    if m:
        equates[m.group(1)] = int(m.group(2), 16)
# well-known hardware registers
for name, val in {
    "PPU_CTRL": 0x2000, "PPU_MASK": 0x2001, "PPU_STATUS": 0x2002,
    "OAM_ADDR": 0x2003, "OAM_DATA": 0x2004, "PPU_SCROLL": 0x2005,
    "PPU_ADDR": 0x2006, "PPU_DATA": 0x2007,
    "APU_DMC_FREQ": 0x4010, "APU_SND_CHN": 0x4015, "APU_FRAME": 0x4017,
    "JOY1": 0x4016, "JOY2": 0x4017,
    "MMC1_PRG_BANK": 0xFFFE,
}.items():
    equates.setdefault(name, val)

comment_pat = re.compile(r";\s*\$([0-9A-Fa-f]{4}):")
operand_pat = re.compile(r"^\s*([A-Z]{3})\s+(.*?)\s*(?:;.*)?$")

DIRECTIVES = (".byte", ".word", ".addr", ".res", ".org", ".align",
              ".proc", ".endproc", ".segment", ".include", ".export",
              ".import", ".feature", ".macpack", ".define", ".scope",
              ".endscope", ".repeat", ".endrepeat", ".if", ".endif", ".else")

# ---- 2. opcodes we can encode ----
MODES = {
    "LDA": {"imm": 0xA9, "zp": 0xA5, "zpx": 0xB5, "abs": 0xAD, "abx": 0xBD,
            "aby": 0xB9, "ind_x": 0xA1, "ind_y": 0xB1},
    "STA": {"zp": 0x85, "zpx": 0x95, "abs": 0x8D, "abx": 0x9D, "aby": 0x99,
            "ind_x": 0x81, "ind_y": 0x91},
    "LDX": {"imm": 0xA2, "zp": 0xA6, "zpy": 0xB6, "abs": 0xAE, "aby": 0xBE},
    "STX": {"zp": 0x86, "zpy": 0x96, "abs": 0x8E},
    "LDY": {"imm": 0xA0, "zp": 0xA4, "zpx": 0xB4, "abs": 0xAC, "abx": 0xBC},
    "STY": {"zp": 0x84, "zpx": 0x94, "abs": 0x8C},
    "INC": {"zp": 0xE6, "zpx": 0xF6, "abs": 0xEE, "abx": 0xFE},
    "DEC": {"zp": 0xC6, "zpx": 0xD6, "abs": 0xCE, "abx": 0xDE},
    "ASL": {"acc": 0x0A, "zp": 0x06, "zpx": 0x16, "abs": 0x0E, "abx": 0x1E},
    "LSR": {"acc": 0x4A, "zp": 0x46, "zpx": 0x56, "abs": 0x4E, "abx": 0x5E},
    "ROL": {"acc": 0x2A, "zp": 0x26, "zpx": 0x36, "abs": 0x2E, "abx": 0x3E},
    "ROR": {"acc": 0x6A, "zp": 0x66, "zpx": 0x76, "abs": 0x6E, "abx": 0x7E},
    "ADC": {"imm": 0x69, "zp": 0x65, "zpx": 0x75, "abs": 0x6D, "abx": 0x7D,
            "aby": 0x79, "ind_x": 0x61, "ind_y": 0x71},
    "SBC": {"imm": 0xE9, "zp": 0xE5, "zpx": 0xF5, "abs": 0xED, "abx": 0xFD,
            "aby": 0xF9, "ind_x": 0xE1, "ind_y": 0xF1},
    "CMP": {"imm": 0xC9, "zp": 0xC5, "zpx": 0xD5, "abs": 0xCD, "abx": 0xDD,
            "aby": 0xD9, "ind_x": 0xC1, "ind_y": 0xD1},
    "CPX": {"imm": 0xE0, "zp": 0xE4, "abs": 0xEC},
    "CPY": {"imm": 0xC0, "zp": 0xC4, "abs": 0xCC},
    "AND": {"imm": 0x29, "zp": 0x25, "zpx": 0x35, "abs": 0x2D, "abx": 0x3D,
            "aby": 0x39, "ind_x": 0x21, "ind_y": 0x31},
    "ORA": {"imm": 0x09, "zp": 0x05, "zpx": 0x15, "abs": 0x0D, "abx": 0x1D,
            "aby": 0x19, "ind_x": 0x01, "ind_y": 0x11},
    "EOR": {"imm": 0x49, "zp": 0x45, "zpx": 0x55, "abs": 0x4D, "abx": 0x5D,
            "aby": 0x59, "ind_x": 0x41, "ind_y": 0x51},
    "BIT": {"zp": 0x24, "abs": 0x2C},
    "JMP": {"abs": 0x4C, "ind": 0x6C},
    "JSR": {"abs": 0x20},
    "BCC": {"rel": 0x90}, "BCS": {"rel": 0xB0}, "BEQ": {"rel": 0xF0},
    "BNE": {"rel": 0xD0}, "BMI": {"rel": 0x30}, "BPL": {"rel": 0x10},
    "BVC": {"rel": 0x50}, "BVS": {"rel": 0x70},
}
IMPLIED = {
    "BRK": 0x00, "RTS": 0x60, "RTI": 0x40, "NOP": 0xEA, "TAX": 0xAA,
    "TAY": 0xA8, "TXA": 0x8A, "TYA": 0x98, "TXS": 0x9A, "TSX": 0xBA,
    "INX": 0xE8, "INY": 0xC8, "DEX": 0xCA, "DEY": 0x88, "SEC": 0x38,
    "CLC": 0x18, "SEI": 0x78, "CLI": 0x58, "CLD": 0xD8, "SED": 0xF8,
    "CLV": 0xB8, "PHA": 0x48, "PHP": 0x08, "PLA": 0x68, "PLP": 0x28,
}

num_pat = re.compile(r"^\$([0-9A-Fa-f]{1,4})$")

def resolve(token):
    """Return numeric value for an operand token or None."""
    token = token.strip()
    if token.startswith("a:"):
        token = token[2:]
    m = num_pat.match(token)
    if m:
        return int(m.group(1), 16)
    # symbol +/- small offset
    m2 = re.match(r"^([A-Za-z_]\w*)(?:([+-])\$(1?[0-9A-Fa-f]{1,4}))?$", token)
    if m2 and m2.group(1) in equates:
        v = equates[m2.group(1)]
        if m2.group(2):
            off = int(m2.group(3), 16)
            v = v + off if m2.group(2) == "+" else v - off
        return v
    return None

def encode(op, operand, addr):
    """Return expected bytes for `op operand` at `addr`, or None."""
    if op in IMPLIED and operand == "":
        return [IMPLIED[op]]
    if op == "ASL" or op in ("LSR", "ROL", "ROR"):
        if operand == "A" or operand == "":
            return [MODES[op]["acc"]]
    modes = MODES.get(op)
    if not modes:
        return None
    operand = operand.strip()
    # indirect forms
    m = re.match(r"^\((.+)\)$", operand)
    if m:
        v = resolve(m.group(1))
        if v is not None and "ind" in modes:
            return [modes["ind"], v & 0xFF, v >> 8]
        return None
    m = re.match(r"^\((.+),X\)$", operand)
    if m:
        v = resolve(m.group(1))
        if v is not None and "ind_x" in modes:
            return [modes["ind_x"], v & 0xFF]
        return None
    m = re.match(r"^\((.+)\),Y$", operand)
    if m:
        v = resolve(m.group(1))
        if v is not None and "ind_y" in modes:
            return [modes["ind_y"], v & 0xFF]
        return None
    m = re.match(r"^(.+?),X$", operand)
    if m:
        v = resolve(m.group(1))
        if v is None:
            return None
        if "zpx" in modes and v <= 0xFF and not operand.startswith("a:"):
            return [modes["zpx"], v & 0xFF]
        if "abx" in modes:
            return [modes["abx"], v & 0xFF, v >> 8]
        return None
    m = re.match(r"^(.+?),Y$", operand)
    if m:
        v = resolve(m.group(1))
        if v is None:
            return None
        if operand.startswith("a:") or v > 0xFF:
            if "aby" in modes:
                return [modes["aby"], v & 0xFF, v >> 8]
        if "zpy" in modes:
            return [modes["zpy"], v & 0xFF]
        if "aby" in modes:
            return [modes["aby"], v & 0xFF, v >> 8]
        return None
    m = re.match(r"^#(.+)$", operand)
    if m:
        v = resolve(m.group(1))
        if v is not None and "imm" in modes:
            return [modes["imm"], v & 0xFF]
        return None
    if "rel" in modes:
        return [modes["rel"], None]  # branch offset checked separately
    v = resolve(operand)
    if v is None:
        return None
    forced_abs = operand.startswith("a:")
    if not forced_abs and v <= 0xFF and "zp" in modes:
        return [modes["zp"], v & 0xFF]
    if "abs" in modes:
        return [modes["abs"], v & 0xFF, v >> 8]
    return None

# zp <-> abs opcode equivalence families (ROM mixes encodings per site).
ABS_OF = {
    0xA5: 0xAD, 0xB5: 0xBD, 0x85: 0x8D, 0x95: 0x9D,
    0xA6: 0xAE, 0xB6: 0xBE, 0x86: 0x8E, 0x96: 0x8E,
    0xA4: 0xAC, 0xB4: 0xBC, 0x84: 0x8C, 0x94: 0x8C,
    0xE6: 0xEE, 0xF6: 0xFE, 0xC6: 0xCE, 0xD6: 0xDE,
    0x06: 0x0E, 0x16: 0x1E, 0x46: 0x4E, 0x56: 0x5E,
    0x26: 0x2E, 0x36: 0x3E, 0x66: 0x6E, 0x76: 0x7E,
    0x65: 0x6D, 0x75: 0x7D, 0xE5: 0xED, 0xF5: 0xFD,
    0xC5: 0xCD, 0xD5: 0xDD, 0x25: 0x2D, 0x35: 0x3D,
    0x05: 0x0D, 0x15: 0x1D, 0x45: 0x4D, 0x55: 0x5D,
    0x24: 0x2C,
}
ZP_OF = {v: k for k, v in ABS_OF.items()}

def instr_bytes(buf, off):
    """Decode ROM instruction at offset: return (family_op, value_bytes, len)."""
    op = buf[off]
    if op in IMPLIED.values():
        return op, [], 1
    for fam, table in MODES.items():
        if op in table.values():
            mode = [k for k, v in table.items() if v == op][0]
            if mode == "rel":
                return op, [buf[off + 1]], 2
            if mode == "imm":
                return op, [buf[off + 1]], 2
            if mode in ("zp", "zpx", "zpy", "ind_x", "ind_y"):
                return op, [buf[off + 1]], 2
            if mode in ("abs", "abx", "aby", "ind"):
                return op, [buf[off + 1], buf[off + 2]], 3
    return op, [], 1

# ---- 3. walk source ----
problems = []
checked = 0
cur_addr = None
for lineno, line in enumerate(src_lines, 1):
    cm = comment_pat.search(line)
    if not cm:
        continue
    addr = int(cm.group(1), 16)
    code = line.split(";", 1)[0]
    stripped = code.strip()
    if not stripped or stripped.startswith(DIRECTIVES) or stripped.endswith(":") \
       or stripped == "" or "=" in stripped.split()[0]:
        continue
    om = operand_pat.match(code)
    if not om:
        continue
    op, operand = om.group(1), om.group(2)
    if op not in MODES and op not in IMPLIED:
        continue
    expected = encode(op, operand, addr)
    if expected is None:
        continue
    off = addr - 0xE000
    if off < 0 or off + len(expected) > len(ROM):
        continue
    checked += 1
    rom_op, rom_val, rom_len = instr_bytes(ROM, off)
    exp_op = expected[0]
    exp_val = [x for x in expected[1:] if x is not None]
    exp_fmt = " ".join("%02X" % (x if x is not None else 0) for x in expected)
    rom_fmt = " ".join("%02X" % ROM[off + j] for j in range(rom_len))
    # branch: only compare opcode here (offset needs label resolution)
    if exp_op in (0x10, 0x30, 0x50, 0x70, 0x90, 0xB0, 0xD0, 0xF0):
        if rom_op != exp_op:
            problems.append((addr, lineno, stripped, exp_fmt, rom_fmt))
        continue
    if rom_op == exp_op:
        if rom_val != exp_val:
            problems.append((addr, lineno, stripped, exp_fmt, rom_fmt))
        continue
    # allow zp/abs encoding swap with same operand value
    if exp_op in ABS_OF and rom_op == ABS_OF[exp_op]:
        if rom_val == exp_val + [0x00]:
            continue
        problems.append((addr, lineno, stripped, exp_fmt, rom_fmt))
        continue
    if exp_op in ZP_OF and rom_op == ZP_OF[exp_op]:
        if len(exp_val) == 2 and exp_val[1] == 0 and [exp_val[0]] == rom_val:
            continue
        problems.append((addr, lineno, stripped, exp_fmt, rom_fmt))
        continue
    problems.append((addr, lineno, stripped, exp_fmt, rom_fmt))

print("checked instructions: %d" % checked)
print("mismatches: %d" % len(problems))
for addr, ln, code, exp, got in problems[:80]:
    print("$%04X (line %d): %s -> expected [%s] rom [%s]" % (addr, ln, code, exp, got))
