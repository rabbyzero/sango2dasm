#!/usr/bin/env python3
"""Scan disassembled PRG bank files for bank-switching call sites.

Patterns detected:
  1. JSR SwitchBankAC_A / SwitchBankAC_B  (+ optional B1F_ prefix)
     -> Y = bank for $A000, Y+1 for $C000 (effective = Y & $1F)
  2. JSR SwitchBank8_A / SwitchBank8_B
     -> Y = bank for $8000 window
  3. JSR BankedCallbackTrampoline (+ B1F_ prefix)
     -> Y = target bank pair; inline .word target follows
  4. JMP $Axxx after an inline LDY+SwitchBank (NMI sub-dispatch style)
  5. LDA #imm ; JSR BankSwitch (CHR config only, reported separately)

Output: per-file call-site table + aggregated bank linkage map.
"""
import os
import re
import sys
from collections import defaultdict

BANKS_DIR = os.path.join(os.path.dirname(__file__), "..", "asm", "banks")
FUNC_H = os.path.join(os.path.dirname(__file__), "..", "include", "functions.h")

FILES = [
    "prg_1f.asm",
    "prg_17_18.asm",
    "prg_1d_1e.asm",
    "prg_0c_0d.asm",
    "prg_08_09.asm",
    "prg_0a_0b.asm",
]

SRC_FILE_TO_BANK = {
    "prg_1f.asm": "$1F (fixed $E000-$FFFF)",
    "prg_17_18.asm": "$17/$18 ($A000-$DFFF)",
    "prg_1d_1e.asm": "$1D/$1E ($A000-$DFFF)",
    "prg_0c_0d.asm": "$0C/$0D ($A000-$DFFF)",
    "prg_08_09.asm": "$08/$09 ($A000-$DFFF)",
    "prg_0a_0b.asm": "$0A/$0B ($A000-$DFFF)",
}

RE_ADDR = re.compile(r"\$([0-9A-Fa-f]{4})")
RE_LDY_IMM = re.compile(r"^\s*LDY\s+#\$([0-9A-Fa-f]{2})")
RE_LDA_IMM = re.compile(r"^\s*LDA\s+#\$([0-9A-Fa-f]{2})")
RE_LDX_IMM = re.compile(r"^\s*LDX\s+#\$([0-9A-Fa-f]{2})")
RE_LDY_ABS = re.compile(r"^\s*LDY\s+(\S+)\s")
RE_JSR = re.compile(r"^\s*(?:JSR|JMP)\s+(\S+)")
RE_WORD = re.compile(r"^\s*\.word\s+(.+?)(?:\s*;.*)?$")
RE_PROC = re.compile(r"^\s*\.proc\s+(\S+)")
RE_ENDPROC = re.compile(r"^\s*\.endproc")

SWITCH_AC = {"SwitchBankAC_A", "SwitchBankAC_B",
             "B1F_SwitchBankAC_A", "B1F_SwitchBankAC_B"}
SWITCH_8 = {"SwitchBank8_A", "SwitchBank8_B",
            "B1F_SwitchBank8_A", "B1F_SwitchBank8_B"}
TRAMPOLINE = {"BankedCallbackTrampoline", "B1F_BankedCallbackTrampoline"}
BANKSWITCH = {"BankSwitch", "B1F_BankSwitch"}


def load_symbol_map():
    """Build address -> [symbol names] from functions.h (banked $8000-$DFFF
    addresses are ambiguous across banks; keep all names)."""
    addr_map = defaultdict(list)
    pair_hint = {}  # symbol -> bank pair prefix like B17_18
    with open(FUNC_H) as f:
        for line in f:
            m = re.match(r"^(\w+)\s*=\s*\$([0-9A-Fa-f]{4})", line)
            if not m:
                continue
            name, addr = m.group(1), int(m.group(2), 16)
            addr_map[addr].append(name)
            pm = re.match(r"^B([0-9A-Fa-f]{2})_[0-9A-Fa-f]{2}_(\w+)$", name)
            if pm:
                pair_hint[name] = pm.group(1)
    return addr_map


def resolve_names(addr, addr_map, expect_pair=None):
    """Resolve an address to candidate symbol names, preferring the bank pair."""
    names = addr_map.get(addr, [])
    if expect_pair and names:
        pref = [n for n in names
                if n.startswith("B" + expect_pair + "_")]
        if pref:
            return pref
    return names


def code_part(line):
    """Return instruction portion of a line (strip trailing comment)."""
    # Comments in this project start with ';', but ';' inside strings is rare.
    return line.split(";")[0].rstrip()


def extract_addr(line):
    m = RE_ADDR.search(line)
    return int(m.group(1), 16) if m else None


class Scanner:
    def __init__(self, addr_map):
        self.addr_map = addr_map
        self.sites = []

    def scan_file(self, path, src_bank):
        with open(path) as f:
            lines = f.readlines()
        proc_stack = []
        for i, raw in enumerate(lines):
            code = code_part(raw)
            mp = RE_PROC.match(raw)
            if mp:
                proc_stack.append(mp.group(1))
                continue
            if RE_ENDPROC.match(raw):
                if proc_stack:
                    proc_stack.pop()
                continue

            mjsr = RE_JSR.match(code)
            if not mjsr:
                continue
            target = mjsr.group(1).rstrip(",")
            proc = proc_stack[-1] if proc_stack else "?"

            if target in SWITCH_AC or target in SWITCH_8:
                yval, ysrc = self.find_y(lines, i)
                kind = "AC" if target in SWITCH_AC else "8000"
                self.sites.append({
                    "file": os.path.basename(path), "line": i + 1,
                    "addr": extract_addr(raw), "proc": proc,
                    "kind": kind, "fn": target,
                    "y": yval, "ysrc": ysrc,
                })
            elif target in TRAMPOLINE:
                yval, ysrc = self.find_y(lines, i)
                tgt = self.find_inline_word(lines, i)
                self.sites.append({
                    "file": os.path.basename(path), "line": i + 1,
                    "addr": extract_addr(raw), "proc": proc,
                    "kind": "trampoline", "fn": target,
                    "y": yval, "ysrc": ysrc, "target": tgt,
                })
            elif target in BANKSWITCH:
                aval, asrc = self.find_a(lines, i)
                self.sites.append({
                    "file": os.path.basename(path), "line": i + 1,
                    "addr": extract_addr(raw), "proc": proc,
                    "kind": "chr-config", "fn": target,
                    "y": aval, "ysrc": asrc,
                })
            elif code.strip().startswith("JMP"):
                # NMI-style: LDY #imm ; JSR SwitchBankAC_B ; JMP $Axxx
                jmp_addr = extract_addr(code)
                if jmp_addr and 0xA000 <= jmp_addr <= 0xDFFF:
                    yval, ysrc = self.find_y(lines, i)
                    if yval is not None:
                        self.sites.append({
                            "file": os.path.basename(path), "line": i + 1,
                            "addr": extract_addr(raw), "proc": proc,
                            "kind": "jmp-after-switch", "fn": "JMP",
                            "y": yval, "ysrc": ysrc, "target": jmp_addr,
                        })

    def find_y(self, lines, i):
        """Track Y backwards from line i-1 (max 12 lines)."""
        for j in range(i - 1, max(0, i - 13), -1):
            c = code_part(lines[j])
            m = RE_LDY_IMM.match(c)
            if m:
                return int(m.group(1), 16), f"LDY #${m.group(1).upper()} @{j+1}"
            m = RE_LDX_IMM.match(c)
            if m and re.search(r"\bSTX\b", ""):  # placeholder, handled below
                pass
            # LDY <abs> or LDY <label>
            m = RE_LDY_ABS.match(c + " ")
            if m and not m.group(1).startswith("#"):
                return None, f"LDY {m.group(1)} @{j+1} (RAM)"
            if re.search(r"\b(TAY|INY|DEY|PLY|LDY)\b", c):
                if re.search(r"\bTAY\b", c):
                    # Y came from A; look for LDA #imm just above
                    for k in range(j - 1, max(0, j - 5), -1):
                        c2 = code_part(lines[k])
                        m2 = RE_LDA_IMM.match(c2)
                        if m2:
                            return int(m2.group(1), 16), f"LDA #${m2.group(1).upper()};TAY @{k+1}"
                        if re.search(r"\b(LDA|PLA|ADC|AND)\b", c2):
                            return None, f"computed Y @{j+1}"
                    return None, f"computed Y @{j+1}"
                if re.search(r"\bLDY\b", c):
                    return None, f"LDY non-imm @{j+1}"
                return None, f"Y modified @{j+1}"
            if re.match(r"\s*(RTS|JMP\s+B1F_StateDispatch)", c):
                break
        return None, "(not found)"

    def find_a(self, lines, i):
        for j in range(i - 1, max(0, i - 6), -1):
            c = code_part(lines[j])
            m = RE_LDA_IMM.match(c)
            if m:
                return int(m.group(1), 16), f"LDA #${m.group(1).upper()} @{j+1}"
            if re.search(r"\b(LDA|PLA)\b", c):
                return None, f"computed A @{j+1}"
        return None, "(not found)"

    def find_inline_word(self, lines, i):
        """First .word line after the JSR (within 3 lines)."""
        for j in range(i + 1, min(len(lines), i + 4)):
            c = code_part(lines[j]).strip()
            m = RE_WORD.match(lines[j])
            if m:
                vals = m.group(1).split(",")
                out = []
                for v in vals:
                    v = v.strip()
                    mm = re.match(r"\$([0-9A-Fa-f]{4})", v)
                    if mm:
                        out.append(int(mm.group(1), 16))
                    else:
                        out.append(v)
                return out
            if RE_JSR.match(c) or c.startswith(("JMP", "RTS")):
                break
        return None


def bank_desc(yval, kind):
    """Describe the target bank(s) for a given Y value."""
    if yval is None:
        return "?"
    if kind == "AC" or kind == "trampoline":
        b = yval & 0x1F
        return f"${b:02X}/${b+1:02X} @ $A000/$C000"
    if kind == "8000":
        b = yval & 0x1F
        return f"${b:02X} @ $8000"
    return "?"


def main():
    addr_map = load_symbol_map()
    sc = Scanner(addr_map)
    for fname in FILES:
        path = os.path.join(BANKS_DIR, fname)
        if os.path.exists(path):
            sc.scan_file(path, SRC_FILE_TO_BANK[fname])

    # --- Per-file tables ---
    by_file = defaultdict(list)
    for s in sc.sites:
        by_file[s["file"]].append(s)

    print("# Per-file call sites\n")
    for fname in FILES:
        sites = by_file.get(fname, [])
        if not sites:
            continue
        print(f"## {fname} ({len(sites)} sites)")
        for s in sites:
            addr = f"${s['addr']:04X}" if s["addr"] else "----"
            if s["kind"] == "trampoline":
                tgt = s.get("target")
                tdesc = ""
                if tgt:
                    parts = []
                    for t in tgt:
                        if isinstance(t, int):
                            pair = f"{(s['y'] or 0) & 0x1F:02X}" if s["y"] is not None else None
                            names = resolve_names(t, addr_map, pair)
                            nm = names[0] if names else ""
                            parts.append(f"${t:04X} {nm}")
                        else:
                            parts.append(str(t))
                    tdesc = " -> " + ", ".join(parts)
                yv = f"${s['y']:02X}" if s["y"] is not None else "??"
                print(f"  {addr} L{s['line']:5d} [{s['proc']}] LDY #{yv} "
                      f"trampoline{tdesc}")
            elif s["kind"] == "jmp-after-switch":
                tgt = s.get("target")
                pair = f"{(s['y'] or 0) & 0x1F:02X}" if s["y"] is not None else None
                names = resolve_names(tgt, addr_map, pair) if tgt else []
                nm = names[0] if names else ""
                yv = f"${s['y']:02X}" if s["y"] is not None else "??"
                print(f"  {addr} L{s['line']:5d} [{s['proc']}] LDY #{yv} "
                      f"JMP ${tgt:04X} {nm}")
            elif s["kind"] == "chr-config":
                yv = f"#{s['y']}" if s["y"] is not None else "?"
                print(f"  {addr} L{s['line']:5d} [{s['proc']}] BankSwitch cfg {yv} ({s['ysrc']})")
            else:
                yv = f"${s['y']:02X}" if s["y"] is not None else "??"
                print(f"  {addr} L{s['line']:5d} [{s['proc']}] LDY #{yv} "
                      f"JSR {s['fn']}  -> {bank_desc(s['y'], s['kind'])}  ({s['ysrc']})")
        print()

    # --- Aggregated linkage ---
    edges = defaultdict(list)  # (src_file, target_bank_desc) -> [procs]
    for s in sc.sites:
        if s["kind"] in ("AC", "trampoline"):
            if s["y"] is not None:
                b = s["y"] & 0x1F
                key = (s["file"], f"${b:02X}+${b+1:02X}")
            else:
                key = (s["file"], "dynamic")
        elif s["kind"] == "8000":
            if s["y"] is not None:
                b = s["y"] & 0x1F
                key = (s["file"], f"${b:02X} @$8000")
            else:
                key = (s["file"], "dynamic @$8000")
        elif s["kind"] == "jmp-after-switch":
            if s["y"] is not None:
                b = s["y"] & 0x1F
                key = (s["file"], f"${b:02X}+${b+1:02X}")
            else:
                continue
        else:
            continue
        edges[key].append(s["proc"])

    print("# Aggregated PRG linkage (source file -> target bank pair)\n")
    for (src, tgt), procs in sorted(edges.items()):
        uniq = sorted(set(procs))
        print(f"  {src:18s} -> {tgt:16s} ({len(procs)} calls: {', '.join(uniq[:6])}{'...' if len(uniq)>6 else ''})")


if __name__ == "__main__":
    main()
