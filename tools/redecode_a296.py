#!/usr/bin/env python3
"""Phase 1: re-disassemble misclassified .byte blobs in prg_19_1a.asm ($A296-$C434).

Every blob's bytes are taken from rom/prg/prg_19.bin + prg_1a.bin (ground
truth). The script locates the source lines by their `; $XXXX:` address
comments, replaces them with properly formatted code/table lines, and
asserts byte counts match exactly. Run tools/verify_19_1a.py afterwards.
"""
import re
import sys

sys.path.insert(0, "tools")
from disasm_6502 import OPCODE_TABLE  # (mode, mnemonic, size, cycles)

ASM = "asm/banks/prg_19_1a.asm"
rom = (open("rom/prg/prg_19.bin", "rb").read() +
       open("rom/prg/prg_1a.bin", "rb").read())

BASE = 0xA000
lines = open(ASM).read().split("\n")

# Existing Loc_ labels (to avoid duplicates)
existing = set(re.findall(r"^Loc_([0-9A-F]{4}):", "\n".join(lines), re.M))


def rb(addr, n):
    return rom[addr - BASE: addr - BASE + n]


def fmt_addr(a):
    return ("a:$%04X" % a) if a < 0x100 else ("$%04X" % a)


def decode(addr):
    op = rom[addr - BASE]
    if op >= len(OPCODE_TABLE) or OPCODE_TABLE[op] is None:
        raise SystemExit("unknown opcode %02X at $%04X" % (op, addr))
    mode, mn, size, _ = OPCODE_TABLE[op]
    b = rb(addr, size)
    if mode == "imp":
        text = mn
    elif mode == "acc":
        text = mn
    elif mode == "imm":
        text = "%s #$%02X" % (mn, b[1])
    elif mode == "zp":
        text = "%s %s" % (mn, fmt_addr(b[1]))
    elif mode == "zpx":
        text = "%s $%02X,X" % (mn, b[1])
    elif mode == "zpy":
        text = "%s $%02X,Y" % (mn, b[1])
    elif mode == "izx":
        text = "%s ($%02X,X)" % (mn, b[1])
    elif mode == "izy":
        text = "%s ($%02X),Y" % (mn, b[1])
    elif mode == "abs":
        text = "%s %s" % (mn, fmt_addr(b[1] | b[2] << 8))
    elif mode == "abx":
        text = "%s %s,X" % (mn, fmt_addr(b[1] | b[2] << 8))
    elif mode == "aby":
        text = "%s %s,Y" % (mn, fmt_addr(b[1] | b[2] << 8))
    elif mode == "ind":
        text = "%s ($%04X)" % (mn, b[1] | b[2] << 8)
    elif mode == "rel":
        t = (addr + 2 + (b[1] ^ 0x80) - 0x80) & 0xFFFF
        text = "%s $%04X" % (mn, t)
    else:
        raise SystemExit("unhandled mode %s at $%04X" % (mode, addr))
    return text, size


def code_lines(start, end):
    """Disassemble [start, end) into project-formatted lines."""
    out = []
    a = start
    while a < end:
        text, size = decode(a)
        b = rb(a, size)
        out.append("  %s%s; $%04X: %s" % (
            text, " " * (40 - len(text)), a, " ".join("%02X" % x for x in b)))
        a += size
    if a != end:
        raise SystemExit("decode overrun at $%04X (end $%04X)" % (a, end))
    return out


def word_table(start, targets, labels, comment_prefix):
    """Emit a .word pointer table with per-entry comments."""
    out = ["; --- Inline pointer table (%d entries) ---" % len(targets)]
    for i, (t, lab) in enumerate(zip(targets, labels)):
        b = rb(start + 2 * i, 2)
        out.append("  .word %s%s; $%04X: %s %s ; %s%d" % (
            lab, " " * (34 - len(lab)), start + 2 * i,
            "%02X" % b[0], "%02X" % b[1], comment_prefix, i))
    return out


def find_line(addr):
    """Index of the line whose byte comment starts at addr."""
    pat = "; $%04X:" % addr
    for i, ln in enumerate(lines):
        if pat in ln:
            return i
    raise SystemExit("no line with comment %s" % pat)


def line_bytes(ln):
    """Byte count + hex string from a line's comment; None if not a data line."""
    m = re.search(r"; \$[0-9A-F]{4}: ((?:[0-9A-F]{2} )*[0-9A-F]{2})\s*$", ln)
    if not m:
        return None
    toks = m.group(1).split(" ")
    return toks


def consume_range(start_addr, total):
    """Return (first_idx, last_idx) covering exactly `total` bytes from start_addr."""
    i0 = find_line(start_addr)
    got = 0
    i = i0
    while got < total:
        toks = line_bytes(lines[i])
        if toks is None:
            s = lines[i].strip()
            if got > 0 and (s.startswith(";") or s == ""):
                i += 1
                continue
            raise SystemExit("non-data line in blob at idx %d: %r" % (i, lines[i]))
        got += len(toks)
        i += 1
    if got != total:
        raise SystemExit("byte count mismatch at $%04X: got %d want %d"
                         % (start_addr, got, total))
    i1 = i - 1
    # swallow a directly preceding '; --- Data Region ---' marker
    while i0 - 1 >= 0 and lines[i0 - 1].strip() == "; --- Data Region ---":
        i0 -= 1
        break
    return i0, i1


def replace(idx0, idx1, new_lines):
    lines[idx0:idx1 + 1] = new_lines


def label_line(addr, marker=True):
    if "%04X" % addr in existing:
        return None
    existing.add("%04X" % addr)
    if marker:
        return "Loc_%04X:  ; (dispatch callback target)" % addr
    return "Loc_%04X:" % addr


TRAMP = {
    (0xA85A - 2): None,  # placeholder, notes are per-site below
}

# ---------------------------------------------------------------------------
# Blob specifications
#   each: (start, total_bytes, builder(lines) -> new_lines)
# ---------------------------------------------------------------------------

def blob_table_code(start, n_words, code_start, code_end, entry_marker=True):
    """Blob = .word table (n_words) optionally followed by code block."""
    def build():
        labels = ["Loc_%04X" % t for t in table_targets[start]]
        out = word_table(start, table_targets[start], labels, "sub ")
        if code_start is not None:
            lab = label_line(code_start, entry_marker)
            if lab:
                out.append(lab)
            out.append("; --- Code Region ---")
            out += code_lines(code_start, code_end)
        return out
    return build


def blob_code(start, end, entry_marker=False, label=True):
    def build():
        out = []
        lab = label_line(start, entry_marker) if label else None
        if lab:
            out.append(lab)
        out += code_lines(start, end)
        return out
    return build


def blob_tramp(word_addr, target, note, code_start, code_end, entry_labels=()):
    """Blob = trampoline .word + resumed code."""
    def build():
        b = rb(word_addr, 2)
        out = ["; --- BankedCallbackTrampoline target ---",
               "  .word $%04X%s; $%04X: %02X %02X (%s)" % (
                   target, " " * (34 - 6), word_addr, b[0], b[1], note),
               "; --- Resumed code after trampoline return ---"]
        for e, mk in entry_labels:
            lab = label_line(e, mk)
            if lab:
                out.append(lab)
        out += code_lines(code_start, code_end)
        return out
    return build


# Dispatch table targets (verified against ROM words)
table_targets = {
    0xA3EB: [0xA3F1, 0xA404, 0xA420],
    0xA5B0: [0xA5B6, 0xA5C9, 0xA5E5],
    0xA6F5: [0xA6FD, 0xA720, 0xA741],
    0xA9A6: [0xA9AE, 0xA9D1, 0xA9F2, 0xAADE],
    0xAB1B: [0xAB25, 0xABA9, 0xAC4D, 0xAC9A, 0xACBD],
    0xAEC6: [0xAECE, 0xAF74, 0xAF8B, 0xAFB8],
    0xAD87: [0xAD95, 0xADAA, 0xAE0D, 0xAE51, 0xBE01, 0xC132, 0xC37A],
    0xBC86: [0xBC8C, 0xBC95, 0xBD67],
    0xBE07: [0xBE17, 0xBE2E, 0xBE83, 0xBED1, 0xBF2F, 0xBFB9, 0xC01E, 0xC0E5],
    0xC138: [0xC144, 0xC158, 0xC1DB, 0xC25D, 0xC280, 0xC289],
    0xC380: [0xC386, 0xC3C2, 0xC41E],
    0xA29C: [0xA2BC, 0xA30C, 0xA33C, 0xA389, 0xA39B, 0xA363, 0xA3E5, 0xA5AA,
             0xA6EF, 0xA9A0, 0xAEC0, 0xBC80, 0xBE01, 0xC132, 0xC37A, 0xAB15],
}

specs = [
    # (start, total_bytes, builder)
    (0xA29C, 32, lambda: (
        ["; --- Inline pointer table (16 entries) ---"] +
        ["  .word Loc_%04X%s; $%04X: %02X %02X ; sub-state %d" % (
            t, " " * (34 - len("Loc_%04X" % t)), 0xA29C + 2 * i,
            rb(0xA29C + 2 * i, 2)[0], rb(0xA29C + 2 * i, 2)[1], i)
         for i, t in enumerate(table_targets[0xA29C])])),

    (0xA3EB, 25, blob_table_code(0xA3EB, 3, 0xA3F1, 0xA404)),
    (0xA541, 15, blob_code(0xA541, 0xA550, label=True)),
    (0xA583, 2, blob_code(0xA583, 0xA585, label=True)),
    (0xA5B0, 25, blob_table_code(0xA5B0, 3, 0xA5B6, 0xA5C9)),
    (0xA6F5, 24, blob_table_code(0xA6F5, 3, 0xA6FD, 0xA70D)),
    (0xA720, 32, blob_code(0xA720, 0xA740, entry_marker=True)),
    (0xA741, 10, blob_code(0xA741, 0xA74B, entry_marker=True)),
    (0xA858, 46, blob_tramp(0xA858, 0xA02A,
                            "bank $1D $A02A -> JMP OfficerDisplay_Lookup",
                            0xA85A, 0xA886)),
    (0xA9A6, 8, blob_table_code(0xA9A6, 4, None, None)),  # table only
    (0xAAD2, 12, blob_tramp(0xAAD2, 0xA02A,
                            "bank $1D $A02A -> JMP OfficerDisplay_Lookup",
                            0xAAD4, 0xAADE)),
    (0xAC32, 27, blob_tramp(0xAC32, 0xA009,
                            "bank $1B $A009 -> JMP $DF25: MapHalfFlagByProvince",
                            0xAC34, 0xAC4D)),
    (0xAC8F, 11, blob_tramp(0xAC8F, 0xA02A,
                            "bank $1D $A02A -> JMP OfficerDisplay_Lookup",
                            0xAC91, 0xAC9A)),
    (0xADA4, 6, blob_tramp(0xADA4, 0xA01E,
                           "bank $1D $A01E -> JMP YearDisplaySetup",
                           0xADA6, 0xADAA)),
    (0xAEB5, 11, blob_tramp(0xAEB5, 0xA01E,
                            "bank $1D $A01E -> JMP YearDisplaySetup",
                            0xAEB7, 0xAEC0)),
    (0xAFAE, 10, blob_tramp(0xAFAE, 0xA02A,
                            "bank $1D $A02A -> JMP OfficerDisplay_Lookup",
                            0xAFB0, 0xAFB8)),
    (0xAB1B, 10, blob_table_code(0xAB1B, 5, None, None)),  # table only
    (0xAEC6, 8, blob_table_code(0xAEC6, 4, None, None)),   # table only
    (0xAD87, 14, blob_table_code(0xAD87, 7, None, None)),  # table only
    (0xBC86, 6, blob_table_code(0xBC86, 3, None, None)),   # table only
    (0xBE07, 16, blob_table_code(0xBE07, 8, None, None)),  # table only
    (0xC138, 12, blob_table_code(0xC138, 6, None, None)),  # table only
    (0xBEE5, 23, blob_tramp(0xBEE5, 0xA006,
                            "bank $1B $A006 -> JMP $D64A",
                            0xBEE7, 0xBEFC)),
    (0xC05E, 23, blob_tramp(0xC05E, 0xA009,
                            "banks $0A+$0B $A009 -> JMP DataRecordLookup",
                            0xC060, 0xC075)),
    (0xC2ED, 20, blob_tramp(0xC2ED, 0xA009,
                            "banks $0A+$0B $A009 -> JMP DataRecordLookup",
                            0xC2EF, 0xC301)),
    (0xC380, 55, blob_table_code(0xC380, 3, 0xC386, 0xC3B7)),
    (0xC3BB, 31, None),  # special: 7-byte data table + code C3C2-C3DA
    (0xC41E, 22, blob_code(0xC41E, 0xC434, entry_marker=True)),
]


def build_c3bb():
    out = ["; --- Per-country notice id table (indexed by $040A) ---"]
    b = rb(0xC3BB, 7)
    out.append("  .byte %s; $C3BB: %s" % (
        ",".join("$%02X" % x for x in b), " ".join("%02X" % x for x in b)))
    lab = label_line(0xC3C2, True)
    if lab:
        out.append(lab)
    out.append("; --- Code Region ---")
    out += code_lines(0xC3C2, 0xC3DA)
    return out


specs[-2] = (0xC3BB, 31, build_c3bb)

# Special: A9A6 replaces an "LDX $D1A9" code line + one .byte line.
# find_line handles it since the LDX line carries "; $A9A6:".

for start, total, builder in specs:
    if builder is None:
        continue
    i0, i1 = consume_range(start, total)
    replace(i0, i1, builder())

# ---------------------------------------------------------------------------
# Cross-boundary LDA $040D at $BFFE
# ---------------------------------------------------------------------------
i0, i1 = consume_range(0xBFFE, 2)
# find the ".segment" line after it and the two $C000/$C010 rows
seg_idx = next(i for i in range(i1, i1 + 4) if ".segment" in lines[i])
j0 = find_line(0xC000)
j1 = find_line(0xC010)

new_bffe = [
    "  .byte $AD,$0D                           ; $BFFE: AD 0D ; LDA $040D opcode+operand hi (instr spans $BFFF/$C000)",
    "",
    ".segment \"CODE_BANK1A\"",
    "",
]
lines[i0:seg_idx + 1] = new_bffe
# indices shifted; recompute
j0 = find_line(0xC000)
j1 = find_line(0xC010)
new_c000 = ([
    "  .byte $04                               ; $C000: 04    ; LDA $040D operand lo (instr spans $BFFF/$C000)",
    "; --- Code Region ---",
] + code_lines(0xC001, 0xC01D))
lines[j0:j1 + 1] = new_c000

open(ASM, "w").write("\n".join(lines))
print("phase 1 complete: %d specs applied" % len(specs))
