#!/usr/bin/env python3
"""Shared scaffolding for per-bank-pair byte-exact verification harnesses.

Assembles ``asm/banks/prg_{hi}_{lo}.asm`` standalone against a generated
two-segment linker config, then compares the concatenated 16 KB output
with ``rom/prg/prg_{hi}.bin + rom/prg/prg_{lo}.bin``.

Two stub-discovery strategies are supported because the existing
harnesses diverged historically:

* ``"retry"`` — start from a fixed external-RAM equate block; on each
  ca65 failure, parse ``Symbol 'X' is undefined`` messages and append
  ``X = 0`` stubs, retrying up to ``max_attempts`` times.
* ``"regex"`` — pre-scan the source for ``JSR/JMP $XXXX`` and
  ``JSR/JMP a:$XXXX`` operands whose targets are in $A000-$DFFF and are
  not defined as ``Loc_XXXX:`` labels inside the bank; emit
  ``ext_XXXX = $XXXX`` equates and rewrite the operands to reference
  them. Single ca65 pass.

Build artifacts are namespaced per bank-pair (``_region{hi}_{lo}.*``,
``_bank{hi}.bin``, ``_bank{lo}.bin``) so that concurrent or sequential
runs of different harnesses do not overwrite each other.
"""
import os
import re
import subprocess
import sys

CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"


def _inject_orgs(src, bank_hi, bank_lo):
    """Pin the PC at $A000 / $C000 so relative branches resolve as in
    the real memory layout."""
    src = src.replace('.segment "CODE_BANK{}"'.format(bank_hi.upper()),
                      '.segment "CODE_BANK{}"\n.org $A000'.format(bank_hi.upper()),
                      1)
    src = src.replace('.segment "CODE_BANK{}"'.format(bank_lo.upper()),
                      '.segment "CODE_BANK{}"\n.org $C000'.format(bank_lo.upper()),
                      1)
    return src


def _stub_regex_prescan(src):
    """Regex pre-scan strategy: build ext_XXXX equates for absolute
    JSR/JMP targets in $A000-$DFFF that are not defined as Loc_XXXX
    labels inside the bank, and rewrite the operands to reference them.

    Returns (transformed_src, stubs_text, external_count).
    """
    defined = set(re.findall(r"^(Loc_[0-9A-F]{4}):", src, re.M))
    refs = set()
    for m in re.finditer(r"(?:JSR|JMP)\s+\$([0-9A-F]{4})", src):
        refs.add(int(m.group(1), 16))
    for m in re.finditer(r"(?:JSR|JMP)\s+a:\$([0-9A-F]{4})", src):
        refs.add(int(m.group(1), 16))
    external = sorted(a for a in refs
                      if 0xA000 <= a < 0xE000
                      and "Loc_{:04X}".format(a) not in defined)
    stubs = "".join("ext_{:04X} = ${:04X}\n".format(a, a) for a in external)
    for a in external:
        src = re.sub(r"(JSR|JMP)(\s+)a:\${:04X}\b".format(a),
                     r"\1\2ext_{:04X}".format(a), src)
        src = re.sub(r"(JSR|JMP)(\s+)\${:04X}\b".format(a),
                     r"\1\2ext_{:04X}".format(a), src)
    return src, stubs, len(external)


def _linker_cfg(bank_hi, bank_lo):
    hi = bank_hi.upper()
    lo = bank_lo.upper()
    return """
MEMORY {{
    BANK{hi}: start = $A000, size = $2000, type = ro, fill = yes, fillval = $FF,
            file = "build/_bank{hi_l}.bin";
    BANK{lo}: start = $C000, size = $2000, type = ro, fill = yes, fillval = $FF,
            file = "build/_bank{lo_l}.bin";
}}
SEGMENTS {{
    CODE_BANK{hi}: load = BANK{hi}, type = ro;
    CODE_BANK{lo}: load = BANK{lo}, type = ro;
}}
""".format(hi=hi, lo=lo, hi_l=bank_hi.lower(), lo_l=bank_lo.lower())


def _compare_and_report(bank_hi, bank_lo):
    """Concatenate the two linker outputs and byte-compare against the
    ROM slices. Prints diagnostics; returns mismatch count."""
    assembled = (open("build/_bank{}.bin".format(bank_hi.lower()), "rb").read() +
                 open("build/_bank{}.bin".format(bank_lo.lower()), "rb").read())
    rom = (open("rom/prg/prg_{}.bin".format(bank_hi.lower()), "rb").read() +
           open("rom/prg/prg_{}.bin".format(bank_lo.lower()), "rb").read())
    if len(assembled) != len(rom):
        print("length mismatch: {} vs {}".format(len(assembled), len(rom)))
        return -1
    mismatch = 0
    for i, (a, b) in enumerate(zip(assembled, rom)):
        if a != b:
            mismatch += 1
            if mismatch <= 30:
                print("MISMATCH ${:04X}: asm={:02X} rom={:02X}".format(
                    0xA000 + i, a, b))
    print("compared {} bytes, {} mismatches".format(len(rom), mismatch))
    return mismatch


def verify_bank_pair(bank_hi, bank_lo, *,
                     external_ram=None,
                     stub_strategy="retry",
                     stub_header="",
                     max_attempts=10):
    """Assemble prg_{hi}_{lo}.asm standalone and byte-compare against ROM.

    Parameters
    ----------
    bank_hi, bank_lo : str
        Two-character lowercase hex bank IDs (e.g. ``"0e"``, ``"0f"``).
    external_ram : list[str] | None
        Lines of the form ``"name = $XXXX\\n"`` for RAM globals that are
        referenced by this bank but defined in another bank's asm file.
    stub_strategy : {"retry", "regex"}
        Which external-symbol discovery strategy to use (see module docstring).
    stub_header : str
        Optional comment line(s) prepended to the stub block (retry strategy
        only; regex strategy emits its own ``ext_XXXX`` block).
    max_attempts : int
        Retry budget for the ``"retry"`` strategy.

    Returns
    -------
    int
        Process exit code: 0 on byte-exact match, 1 on any failure.
    """
    pair = "{}_{}".format(bank_hi.lower(), bank_lo.lower())
    region_asm = "build/_region{}.asm".format(pair)
    region_o = "build/_region{}.o".format(pair)
    region_cfg = "build/_region{}.cfg".format(pair)
    region_out = "build/_region{}.out".format(pair)

    src = open("asm/banks/prg_{}.asm".format(pair)).read()
    src = _inject_orgs(src, bank_hi, bank_lo)
    ram_block = "".join(external_ram or [])

    if stub_strategy == "regex":
        src, stubs, ext_count = _stub_regex_prescan(src)
        open(region_asm, "w").write(src + "\n" + stubs + "\n" + ram_block)
        print("external stubs:", ext_count)
        r = subprocess.run([CC65, "-I", "include", region_asm, "-o", region_o],
                           capture_output=True, text=True)
        if r.returncode != 0:
            print("CA65 FAILED:\n" + r.stderr[:3000])
            return 1
        if r.stderr.strip():
            print("ca65 warnings:\n" + r.stderr[:1000])
    elif stub_strategy == "retry":
        stubs = stub_header + ram_block
        r = None
        for _attempt in range(max_attempts):
            open(region_asm, "w").write(src + "\n" + stubs)
            r = subprocess.run([CC65, "-I", "include", region_asm, "-o", region_o],
                               capture_output=True, text=True)
            if r.returncode == 0:
                break
            missing = sorted(set(re.findall(
                r"Symbol '([A-Za-z_][A-Za-z0-9_]*)' is undefined", r.stderr)))
            if not missing:
                print("CA65 FAILED:\n" + r.stderr[:3000])
                return 1
            print("stubbing undefined symbols:", ", ".join(missing))
            stubs += "".join("{} = 0\n".format(s) for s in missing)
        if r is None or r.returncode != 0:
            print("CA65 FAILED after stubbing:\n" + (r.stderr[:3000] if r else ""))
            return 1
        if r.stderr.strip():
            print("ca65 warnings:\n" + r.stderr[:1000])
    else:
        raise ValueError("stub_strategy must be 'retry' or 'regex', got {!r}".format(stub_strategy))

    open(region_cfg, "w").write(_linker_cfg(bank_hi, bank_lo))
    r = subprocess.run([LD65, "-C", region_cfg, region_o, "-o", region_out],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("LD65 FAILED:\n" + r.stderr[:3000])
        return 1

    mismatch = _compare_and_report(bank_hi, bank_lo)
    return 1 if mismatch else 0


def main(bank_hi, bank_lo, **kwargs):
    """Convenience entry point: runs verify_bank_pair and exits with its
    return code. Intended for thin per-bank wrapper scripts."""
    os.makedirs("build", exist_ok=True)
    sys.exit(verify_bank_pair(bank_hi, bank_lo, **kwargs))
