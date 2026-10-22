#!/usr/bin/env python3
"""Build the full 262144-byte PRG from asm/banks/ and byte-compare it with the
original release.

``make`` cannot do this. It runs a single ca65 pass over ``asm/main.asm``, which
``.include``s every bank file -- and each bank file declares its own file-scope
RAM equates, so the combined translation unit dies on duplicate symbols
(``addr_pad2_edge`` is in both prg_17_18 and prg_1f_boot; ~250 errors). This
script assembles each bank *standalone*, the same way the per-bank verification
gates already do:

  * data banks $00-$07, $10-$16 -> own segment, linked into the $8000-$9FFF window
  * bank $1F                   -> own segment, linked at $E000-$FFFF
  * code pairs                  -> delegated to the existing tools/verify_*.py,
                                   so external-stub lists live in one place and
                                   their build/_.bin output is harvested here

The 32 x 8KB results concatenate into build/prg_from_asm.bin and are wrapped
into build/sango2_from_asm.nes. Unlike tools/build_nes.py this emits the real
CHR from rom/chr and the original's own header bytes, so a reported mismatch
means the *disassembly* differs, not the packaging.

    python3 tools/build_nes_from_asm.py                 # build + compare
    python3 tools/build_nes_from_asm.py --fill-missing ff
    python3 tools/build_nes_from_asm.py --top 40         # detail on worst banks
"""
import argparse
import glob
import os
import re
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CC65 = "/home/zero/.local/bin/ca65"
LD65 = "/home/zero/.local/bin/ld65"
BUILD = os.path.join(ROOT, "build")
ORIGINAL = os.path.join(ROOT, "Sangokushi 2 - Haou no Tairiku (J).nes")
BANK_SIZE = 0x2000
HEADER_SIZE = 16

DATA_BANKS = {
    0x00: "data_00_terrain.asm",
    0x01: "data_01_bg_and_sprites.asm",
    0x02: "data_02_sound.asm",
    0x03: "data_03_terrain.asm",
    0x04: "data_04_terrain.asm",
    0x05: "data_05_terrain.asm",
    0x06: "data_06_placement_and_scroll.asm",
    0x07: "data_07_blank.asm",
    0x10: "data_10_initial_data.asm",
    0x11: "data_11_officer.asm",
    0x12: "data_12_menu_display.asm",
    0x13: "data_13_menu_display.asm",
    0x14: "data_14_sprite_set_a.asm",
    0x15: "data_15_sprite_set_b.asm",
    0x16: "data_16_menu_oam.asm",
}

FIXED_BANK = (0x1F, "prg_1f_boot.asm")

# bank pair -> the harness that owns its external-stub configuration. Running
# it leaves build/_bank{hi}.bin and build/_bank{lo}.bin behind, which is what
# we harvest; that keeps the stub lists out of this file.
CODE_PAIRS = {
    "08_09": "verify_08_09.py",
    "0a_0b": "verify_0a_0b_standalone.py",
    "0c_0d": "verify_0c_0d.py",
    "0e_0f": "verify_0e_0f.py",
    "17_18": "verify_17_18.py",
    "19_1a": "verify_19_1a.py",
    "1b_1c": "verify_1b_1c.py",
    "1d_1e": "verify_1d_1e.py",
}


def summarize_errors(text, limit=3):
    """Collapse ca65/ld65 stderr into its distinct error kinds with counts."""
    errs = re.findall(r"Error: (.+)", text)
    if not errs:
        line = text.strip().splitlines()
        return line[0][:160] if line else "failed"
    kinds = {}
    for e in errs:
        key = re.sub(r"[\u2018'].+?[\u2019']", "X", e)
        kinds[key] = kinds.get(key, 0) + 1
    top = sorted(kinds.items(), key=lambda kv: (-kv[1], kv[0]))[:limit]
    return "{} (+{} other errors)".format(
        "; ".join("{} x{}".format(k, n) for k, n in top),
        len(errs) - sum(n for _, n in top)) if len(errs) > limit else \
        "; ".join("{} x{}".format(k, n) for k, n in top)


def assemble_bank(bank, asm_name, start):
    """Assemble one bank file standalone; return (8192 bytes | None, error | None)."""
    tag = "_nes{:02x}".format(bank)
    asm = os.path.join(BUILD, tag + ".asm")
    obj = os.path.join(BUILD, tag + ".o")
    cfg = os.path.join(BUILD, tag + ".cfg")
    out = os.path.join(BUILD, tag + ".bin")

    src = open(os.path.join(ROOT, "asm", "banks", asm_name), encoding="utf-8").read()
    with open(asm, "w", encoding="utf-8") as f:
        f.write(src)
    with open(cfg, "w", encoding="utf-8") as f:
        f.write("MEMORY {{\n"
                "    BANK{b:02X}: start = ${start:04X}, size = ${size:04X}, type = ro,\n"
                "            fill = yes, fillval = $FF, file = \"build/{tag}.bin\";\n"
                "}}\n"
                "SEGMENTS {{\n"
                "    CODE_BANK{b:02X}: load = BANK{b:02X}, type = ro;\n"
                "}}\n".format(b=bank, start=start, size=BANK_SIZE, tag=tag))

    r = subprocess.run([CC65, "-I", os.path.join(ROOT, "include"),
                        "-I", os.path.join(ROOT, "asm", "banks"), asm, "-o", obj],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        return None, "ca65 -- " + summarize_errors(r.stderr)
    r = subprocess.run([LD65, "-C", cfg, obj, "-o", out],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        return None, "ld65 -- " + summarize_errors(r.stderr)
    data = open(out, "rb").read()
    if len(data) != BANK_SIZE:
        return None, "linked {} bytes, expected {}".format(len(data), BANK_SIZE)
    return data, None


def run_pair_verifier(pair, since):
    """Run the pair's harness; return (hi_bytes | None, lo_bytes | None, error | None)."""
    hi, lo = pair.split("_")
    script = os.path.join(ROOT, "tools", CODE_PAIRS[pair])
    paths = [os.path.join(BUILD, "_bank{}.bin".format(b)) for b in (hi, lo)]
    # A bin left by an earlier session must not pass for this build's output.
    for path in paths:
        if os.path.exists(path) and os.path.getmtime(path) < since:
            os.remove(path)
    r = subprocess.run([sys.executable, script], capture_output=True, text=True, cwd=ROOT)
    text = r.stdout + r.stderr
    out = []
    for path in paths:
        if os.path.exists(path) and os.path.getmtime(path) >= since:
            data = open(path, "rb").read()
            out.append(data if len(data) == BANK_SIZE else None)
        else:
            out.append(None)
    if out[0] is None or out[1] is None:
        reason = summarize_errors(text) if "Error" in text else \
            (text.strip().splitlines() or ["no bank output"])[-1]
        return None, None, reason
    return out[0], out[1], None


def assemble_all(since, fill_missing):
    """Return a list of 32 dicts: bank, asm, data, status, error."""
    result = {}

    for bank, asm in sorted(DATA_BANKS.items()):
        data, err = assemble_bank(bank, asm, 0x8000)
        result[bank] = {"bank": bank, "asm": asm, "data": data, "error": err}

    bank, asm = FIXED_BANK
    data, err = assemble_bank(bank, asm, 0xE000)
    result[bank] = {"bank": bank, "asm": asm, "data": data, "error": err}

    for pair in sorted(CODE_PAIRS):
        hi, lo = (int(x, 16) for x in pair.split("_"))
        asm = "prg_{}_*.asm".format(pair)
        d_hi, d_lo, err = run_pair_verifier(pair, since)
        result[hi] = {"bank": hi, "asm": asm, "data": d_hi, "error": err}
        result[lo] = {"bank": lo, "asm": asm, "data": d_lo, "error": err}

    rom = _rom_banks()
    rows = []
    prg = bytearray()
    for bank in range(32):
        entry = result[bank]
        if entry["data"] is not None:
            prg += entry["data"]
            entry["status"] = "built"
        elif fill_missing == "rom":
            prg += rom[bank]
            entry["status"] = "NOT BUILT (original bytes substituted)"
        else:
            prg += b"\xff" * BANK_SIZE
            entry["status"] = "NOT BUILT ($FF substituted)"
        rows.append(entry)
    return rows, prg


def _rom_banks():
    return [open(os.path.join(ROOT, "rom", "prg", "prg_{:02x}.bin".format(b)), "rb").read()
            for b in range(32)]


def window_base(bank):
    """CPU address the bank is mapped to, or None if it is in no fixed window here."""
    if bank == 0x1F:
        return 0xE000
    if bank in DATA_BANKS:
        return 0x8000
    for pair in CODE_PAIRS:
        hi, lo = (int(x, 16) for x in pair.split("_"))
        if bank == hi:
            return 0xA000
        if bank == lo:
            return 0xC000
    return None


def report(rows, prg, original, nes_path, top, fill_missing):
    rom = _rom_banks()
    built = open(nes_path, "rb").read()
    n_missing = sum(1 for r in rows if r["data"] is None)

    print("\n" + "=" * 100)
    print("Per-bank result -- 8192 bytes each")
    print("=" * 100)
    print("{:<6}{:<42}{:<14}{:>10}  {}".format(
        "bank", "asm source", "status", "mismatch", "first differing / note"))
    total = 0
    drift = []
    for r in rows:
        note = r["error"] or ""
        if r["data"] is None:
            mism = BANK_SIZE if "($FF" in r["status"] else 0
        else:
            diffs = [i for i in range(BANK_SIZE) if r["data"][i] != rom[r["bank"]][i]]
            mism = len(diffs)
            note = ("${:04X} asm={:02X} rom={:02X}".format(
                window_base(r["bank"]) + diffs[0],
                r["data"][diffs[0]], rom[r["bank"]][diffs[0]])
                if diffs else "byte-exact")
        r["mism"] = mism
        total += mism
        if mism and r["data"] is not None:
            drift.append(r)
        print("{:<6}{:<42}{:<14}{:>10}  {}".format(
            "${:02X}".format(r["bank"]), r["asm"], r["status"], mism, note[:64]))

    print("\nPRG mismatches in rebuilt banks : {} of {}".format(total, len(prg)))
    print("header mismatches              : {}".format(
        sum(1 for a, b in zip(original[:HEADER_SIZE], built[:HEADER_SIZE]) if a != b)))
    print("CHR mismatches                 : {} (CHR is copied verbatim from rom/chr,"
          " it is not in the asm sources)".format(
        sum(1 for a, b in zip(original[HEADER_SIZE + len(prg):],
                              built[HEADER_SIZE + len(prg):]) if a != b)))
    print("whole .nes file                : {} of {} bytes differ".format(
        sum(1 for a, b in zip(original, built) if a != b), len(original)))

    for r in sorted(drift, key=lambda x: -x["mism"])[:top]:
        print("\n" + "-" * 100)
        print("bank ${:02X} -- {} -- {} differing bytes".format(
            r["bank"], r["asm"], r["mism"]))
        base = window_base(r["bank"])
        shown = 0
        for i in range(BANK_SIZE):
            if r["data"][i] != rom[r["bank"]][i]:
                print("  ${:06X} in .nes  CPU ${:04X}  asm={:02X} rom={:02X}".format(
                    HEADER_SIZE + r["bank"] * BANK_SIZE + i, base + i,
                    r["data"][i], rom[r["bank"]][i]))
                shown += 1
                if shown >= 12:
                    print("  ... {} further differing bytes".format(r["mism"] - shown))
                    break

    if n_missing:
        print("\n{} of 32 banks would not assemble. {}".format(
            n_missing,
            "Their original bytes were substituted, so they add 0 to the counts above."
            if fill_missing == "rom" else
            "They are filled with $FF and account for the largest mismatch blocks."))
    print("\nBuilt image: {}".format(nes_path))


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--fill-missing", choices=("rom", "ff"), default="rom",
                    help="bytes used for a bank that will not assemble: 'rom' keeps"
                         " the mismatch count measuring only real drift, 'ff' makes"
                         " unbuilt banks show up as mismatches (default: rom)")
    ap.add_argument("--top", type=int, default=8,
                    help="show byte-level detail for the N worst banks (0 to skip)")
    args = ap.parse_args()

    since = time.time()
    os.makedirs(BUILD, exist_ok=True)
    if not os.path.exists(ORIGINAL):
        print("original ROM not found: " + ORIGINAL, file=sys.stderr)
        return 2
    original = open(ORIGINAL, "rb").read()

    rows, prg = assemble_all(since, args.fill_missing)
    with open(os.path.join(BUILD, "prg_from_asm.bin"), "wb") as f:
        f.write(prg)

    header = bytearray(HEADER_SIZE)
    header[0:4] = b"NES\x1a"
    header[4] = len(prg) // 16384
    header[5] = 32
    header[6:HEADER_SIZE] = original[6:HEADER_SIZE]
    chr_data = b"".join(open(p, "rb").read() for p in sorted(
        glob.glob(os.path.join(ROOT, "rom", "chr", "chr_*.bin"))))
    nes_path = os.path.join(BUILD, "sango2_from_asm.nes")
    with open(nes_path, "wb") as f:
        f.write(bytes(header) + bytes(prg) + chr_data)

    report(rows, prg, original, nes_path, args.top, args.fill_missing)
    return 0 if all(r.get("mism", 0) == 0 and r["data"] is not None
                    for r in rows) else 1


if __name__ == "__main__":
    sys.exit(main())
