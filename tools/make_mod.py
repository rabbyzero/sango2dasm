#!/usr/bin/env python3
"""Build the requested Sangokushi 2 mod ROM from the verified original image.

Every patch is applied to the untouched original .nes with an assertion on the
bytes it replaces, so a wrong bank/address fails instead of silently corrupting
the ROM. The disassembly sources stay byte-exact against the stock ROM.

Usage:
    python3 tools/make_mod.py
    python3 tools/make_mod.py --in rom.bin --out build/sango2_mod.nes
"""
import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINAL = os.path.join(ROOT, "Sangokushi 2 - Haou no Tairiku (J).nes")
DEFAULT_OUT = os.path.join(ROOT, "build", "sango2_mod.nes")
BANK_SIZE = 0x2000
HEADER = 16


def off(bank, cpu, base):
    """File offset of a CPU address in a PRG bank window."""
    if not (base <= cpu < base + BANK_SIZE):
        raise ValueError("cpu $%04X outside $%04X-$%04X" % (cpu, base, base + BANK_SIZE - 1))
    return HEADER + bank * BANK_SIZE + (cpu - base)


def patch(rom, name, bank, cpu, base, old, new):
    """Assert old bytes, write new bytes, return the changed-offset list."""
    if len(old) != len(new):
        raise ValueError("%s: length mismatch" % name)
    o = off(bank, cpu, base)
    have = bytes(rom[o:o + len(old)])
    if have != old:
        raise ValueError(
            "%s: expected %s at bank $%02X $%04X, found %s"
            % (name, old.hex(" ").upper(), bank, cpu, have.hex(" ").upper()))
    rom[o:o + len(new)] = new
    return [o + i for i, (a, b) in enumerate(zip(old, new)) if a != b]


def remap_display_year(year):
    """Both arrival paths use the same bands: 189-192, 193-199, 200+."""
    if year <= 192:
        return 189
    if year <= 199:
        return 190
    return 191


def remap_reinforce_stored_year(stored):
    """Reinforcement pools store display year - 100 (89 means 189)."""
    return remap_display_year(stored + 100) - 100


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="src", default=ORIGINAL)
    ap.add_argument("--out", dest="out", default=DEFAULT_OUT)
    args = ap.parse_args()

    src = open(args.src, "rb").read()
    if len(src) != 524304:
        sys.exit("unexpected input size %d (expected 524304)" % len(src))
    rom = bytearray(src)
    changes = []  # (label, [offsets])

    def apply(label, bank, cpu, base, old, new):
        changes.append((label, patch(rom, label, bank, cpu, base, old, new)))

    # ------------------------------------------------------------------
    # 1. Officer arrival years: auto reinforcement pools + search schedule.
    # ------------------------------------------------------------------
    # Auto: bank $31 $8D74-$8DB3 (pointer table + 4 pair lists).
    # Pair byte 1 is display year - 100, so the display-year rule
    # 189-192 -> 189, 193-199 -> 190, 200+ -> 191 is stored as 89/90/91.
    o = off(0x11, 0x8D74, 0x8000)
    pools = bytes(src[o:o + 64])
    assert pools[:8] == bytes.fromhex("7C 2D 95 2D 9E 2D AB 2D"), pools[:8].hex()
    new_pools = bytearray(pools)
    for p in range(0, 8, 2):
        target = pools[p] | (pools[p + 1] << 8)
        idx = (target + 0x6000) - 0x8D74
        assert 8 <= idx < 64, "pool pointer %04X out of range" % target
        while idx < 64:
            oid = new_pools[idx]
            if oid == 0xFF:
                break
            year = new_pools[idx + 1]
            assert 89 <= year <= 110, "pool year %d out of range" % year
            new_pools[idx + 1] = remap_reinforce_stored_year(year)
            idx += 2
    apply("arrival-auto-pools", 0x11, 0x8D74, 0x8000, pools, bytes(new_pools))

    # Search: bank $31 $8B1C-$8D73 = 30 blocks x 10 (id, display year) pairs.
    # Pair byte 1 is the display year itself (OfficerArrivalScan does SBC #$64),
    # so it uses the same 189-192 / 193-199 / 200+ bands directly.
    o = off(0x11, 0x8B1C, 0x8000)
    sched = bytes(src[o:o + 600])
    new_sched = bytearray(sched)
    real_pairs = 0
    for i in range(0, 600, 2):
        oid = sched[i]
        if oid == 0xFF:
            continue
        year = sched[i + 1]
        assert 189 <= year <= 210, "schedule year %d at pair %d out of range" % (year, i // 2)
        new_sched[i + 1] = remap_display_year(year)
        real_pairs += 1
    assert real_pairs == 154, "expected 154 scheduled officers, found %d" % real_pairs
    apply("arrival-search-schedule", 0x11, 0x8B1C, 0x8000, sched, bytes(new_sched))

    # ------------------------------------------------------------------
    # 2. Level-up experience: 500 per level (cumulative 500..3500).
    #    Both tables hold seven 16-bit thresholds, indexed by level*2.
    # ------------------------------------------------------------------
    old_th = bytes.fromhex("E8 03 D0 07 AC 0D 88 13 4C 1D 10 27 98 3A")
    new_th = bytes.fromhex("F4 01 E8 03 DC 05 D0 07 C4 09 B8 0B AC 0D")
    apply("level-threshold-battle", 0x0F, 0xD85B, 0xC000, old_th, new_th)
    apply("level-threshold-war", 0x0A, 0xB0BC, 0xA000, old_th, new_th)

    # ------------------------------------------------------------------
    # 3. Hospital free (strategy + tactical).
    # ------------------------------------------------------------------
    # Strategy: $042C fee $32 -> $00; the existing check/subtract then uses 0.
    apply("hospital-free-strategy", 0x1C, 0xC534, 0xC000,
          bytes.fromhex("A9 32"), bytes.fromhex("A9 00"))
    # Tactical: "gold < 50?" -> "gold < 0?" and "gold -= 50" -> "gold -= 0".
    apply("hospital-free-tactical-check", 0x09, 0xC43C, 0xC000,
          bytes.fromhex("C9 32"), bytes.fromhex("C9 00"))
    apply("hospital-free-tactical-sub", 0x09, 0xC44E, 0xC000,
          bytes.fromhex("E9 32"), bytes.fromhex("E9 00"))
    # Tactical hospital prompt: replace the "5" tile in "キン50かかります"
    # with a blank so it reads "キン 0かかります".
    apply("hospital-text-zero", 0x12, 0x979F, 0x8000,
          bytes.fromhex("7B"), bytes.fromhex("01"))

    # ------------------------------------------------------------------
    # 4. Armory free (strategy + tactical share these tables).
    # ------------------------------------------------------------------
    old_prices = bytes.fromhex(
        "32 00 46 00 78 00 B4 00 FA 00 00 00 00 00 00 00 "
        "3C 00 64 00 96 00 C8 00 F0 00 04 01 00 00 90 01 "
        "50 00 64 00 78 00 C8 00 FA 00 2C 01 5E 01 90 01 "
        "32 00 50 00 64 00 96 00 C8 00 FA 00 5E 01 90 01")
    assert len(old_prices) == 64
    apply("armory-free-price-table", 0x09, 0xC89E, 0xC000,
          old_prices, bytes(64))
    # Furyou's province-exclusive 4th slot is priced in code, not the table.
    apply("armory-free-furyou-lo", 0x1C, 0xC7C3, 0xC000,
          bytes.fromhex("A9 90"), bytes.fromhex("A9 00"))
    apply("armory-free-furyou-hi", 0x1C, 0xC7C8, 0xC000,
          bytes.fromhex("A9 01"), bytes.fromhex("A9 00"))

    # ------------------------------------------------------------------
    # 5. Special equipment purchasable by every officer, repeatedly.
    #    Bypass the famous-weapon gate in both armory flows; the strategy
    #    gate must still clear its event mask $0472.
    # ------------------------------------------------------------------
    apply("special-gate-tactical", 0x09, 0xC73B, 0xC000,
          bytes.fromhex("AC 09"), bytes.fromhex("38 60"))  # SEC / RTS
    apply("special-gate-strategy", 0x1C, 0xCA6B, 0xC000,
          bytes.fromhex("A9 00 8D 72 04 AD 81"),
          bytes.fromhex("A9 00 8D 72 04 38 60"))  # clear $0472, SEC / RTS

    # ------------------------------------------------------------------
    # 6. Armory stock replacement: ordinary top-tier item -> special item.
    #    Applied to all six grid sets in ArmoryGridLayouts (shared by both
    #    the strategy-map and war-map armories).
    # ------------------------------------------------------------------
    replace = {
        0x02: 0x05,  # 長剣       -> 青釭の剣
        0x03: 0x06,  # 破斬剣     -> 倚天の剣
        0x04: 0x07,  # 大剣       -> 七星宝剣
        0x0C: 0x0E,  # 偃月刀     -> 龍牙刀
        0x0D: 0x0F,  # 鳳嘴刀     -> 関王刀
        0x14: 0x16,  # 双鉤槍     -> 狼牙鎗
        0x15: 0x17,  # 方天画戟   -> 蛇矛
        0x1C: 0x1E,  # 鶴氅       -> 聖者の衣
        0x1D: 0x1F,  # 甲冑       -> 竜鱗の鎧
    }
    o = off(0x09, 0xC8DE, 0xC000)
    layouts = bytes(src[o:o + 96])
    assert len(layouts) == 96
    new_layouts = bytes(replace.get(b, b) for b in layouts)
    apply("armory-stock-replace", 0x09, 0xC8DE, 0xC000, layouts, new_layouts)

    # ------------------------------------------------------------------
    # 7. Battle-mode taunt always succeeds (player tactics menu only; the
    #    AI uses AiTacticPointSpend's separate gate).
    # ------------------------------------------------------------------
    apply("taunt-always-success", 0x0E, 0xAF26, 0xA000,
          bytes.fromhex("AD 44 05 C9 05 D0 08 AD 49 05 D0"),
          bytes.fromhex("A9 EA 20 6D F2 A9 04 8D 41 05 60"))

    # ------------------------------------------------------------------
    # 8. Persuade: only target loyalty >= 100 (rulers) refuses, using the
    #    original >=80 table; every lower-loyalty target accepts (event 4).
    # ------------------------------------------------------------------
    # Loyalty tier boundary $50 (80) -> $64 (100).
    apply("persuade-ruler-threshold", 0x17, 0xBEC0, 0xA000,
          bytes.fromhex("C9 50"), bytes.fromhex("C9 64"))
    # Set the L1 and L2 rows (loyalty < 100) to event 4.
    for label, bank, cpu, old in [
        ("persuade-accept-A0", 0x17, 0xBFCA, bytes.fromhex(
            "01 01 01 01 01 01 01 02 01 01 01 01 01 01 01 01 "
            "01 01 01 01 02 02 03 03 01 01 01 01 01 01 04 04 "
            "01 01 03 03 04 04 04 04 02 02 02 02 04 04 04 04")),
        ("persuade-accept-A1", 0x18, 0xC012, bytes.fromhex(
            "01 01 01 01 01 01 01 01 01 01 01 01 02 02 03 03 "
            "01 01 01 01 02 02 02 02 01 01 01 01 03 03 04 04 "
            "01 01 03 03 03 03 04 04 01 01 03 03 04 04 04 04")),
        ("persuade-accept-A2", 0x18, 0xC05A, bytes.fromhex(
            "01 01 01 01 04 04 04 04 01 01 03 03 03 03 04 04 "
            "01 01 02 02 04 04 04 04 01 01 01 01 04 04 04 04 "
            "01 01 02 02 04 04 04 04 01 01 04 04 04 04 04 04")),
    ]:
        assert len(old) == 48
        apply(label, bank, cpu, 0xA000 if bank == 0x17 else 0xC000,
              old, bytes([4]) * 48)

    # ------------------------------------------------------------------
    # 9. Castle command menu opens on 情報集め (Intelligence Gathering)
    #    instead of 国造り (development).
    #    The 2 x 3 grid walks menu_cursor_page/col ($0425/$0424) and indexes
    #    CastleCommandMenuTable at page*2 + col, so page 1 / col 0 is the
    #    middle-left slot, whose table value is command 2 = scouting; the
    #    cursor sprite is then drawn from CastleCommandCursorPosTable[2] =
    #    y $C8 x $46, the same slot. CastleMenuScreenInit (sub 0) is the one
    #    frame that runs per entry and it calls the shared MenuCursorReset
    #    (52 callers, so it stays untouched); a 7-byte helper in bank $1F's
    #    $F67F-$F7FF unused run does the reset and then bumps the page,
    #    returning A = $00 for the caller's follow-up $0473/$00A4 stores.
    # ------------------------------------------------------------------
    apply("castle-open-on-scout-helper", 0x1F, 0xF7C0, 0xE000,
          bytes.fromhex("FF FF FF FF FF FF FF"),
          bytes.fromhex("20 70 DD"    # JSR MenuCursorReset  ($DD70, bank $1C)
                        "EE 25 04"    # INC menu_cursor_page $0425 -> 1
                        "60"))        # RTS (A = $00 from the reset)
    apply("castle-open-on-scout-call", 0x1B, 0xA2D8, 0xA000,
          bytes.fromhex("20 70 DD"), bytes.fromhex("20 C0 F7"))

    # ------------------------------------------------------------------
    # 10. Battle-mode tactic 挑発 (top-right panel row, cost 5): free and
    #     always on the panel. Row index 1 in the phase-8 tactics menu.
    # ------------------------------------------------------------------
    # Row cost 5 -> 0 covers both the affordability test and the deduction.
    apply("tactic-row1-cost-zero", 0x0E, 0xADE0, 0xA000,
          bytes.fromhex("05"), bytes.fromhex("00"))
    # Panel cost digit on that row's 4-tile ポイント run: "5" -> "0".
    # Number-page digits are tiles $76..$7F = 0..9.
    apply("tactic-row1-cost-text-zero", 0x0E, 0xB0F5, 0xA000,
          bytes.fromhex("7B"), bytes.fromhex("76"))
    # Point tier ladder: the first band (<5 -> tier 0) can no longer be
    # taken, so the tier is at least 1 and rows 0-1 are always scripted
    # onto the panel and selectable.
    apply("tactic-row1-always-shown", 0x0E, 0xACFC, 0xA000,
          bytes.fromhex("C9 05"), bytes.fromhex("C9 00"))
    # AI mirror (AiTacticPointSpend): drop the 5-point gate on its taunt
    # purchase and the 5-point deduction it makes on success.
    apply("ai-tactic-taunt-gate-zero", 0x0F, 0xD41D, 0xC000,
          bytes.fromhex("E0 05"), bytes.fromhex("E0 00"))
    apply("ai-tactic-taunt-cost-zero", 0x0F, 0xD6B4, 0xC000,
          bytes.fromhex("E9 05"), bytes.fromhex("E9 00"))

    # ------------------------------------------------------------------
    # Write and verify.
    # ------------------------------------------------------------------
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    open(args.out, "wb").write(rom)

    diff = [i for i, (a, b) in enumerate(zip(src, rom)) if a != b]
    expected = sorted(set(i for _, offs in changes for i in offs))
    if diff != expected:
        missing = sorted(set(expected) - set(diff))
        extra = sorted(set(diff) - set(expected))
        sys.exit("diff mismatch: missing=%s extra=%s" % (missing[:8], extra[:8]))

    print("mod ROM : %s" % args.out)
    print("size    : %d bytes (header + CHR unchanged)" % len(rom))
    print("patches : %d sites, %d bytes changed" % (len(changes), len(diff)))
    for label, offs in changes:
        print("  %-30s %3d byte(s)" % (label, len(offs)))


if __name__ == "__main__":
    main()
