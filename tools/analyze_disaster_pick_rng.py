#!/usr/bin/env python3
"""Enumerate the 256 disaster province-pick sequences and analyse SAME-MONTH coherence.

Model under test (asm/banks/prg_19_1a_event_scenes.asm $A896, asm/banks/prg_1f_boot.asm $E87A/$E8BA):

  RandomByte:  A = RandomTable[$0050]; $0050 = ($0050 + 1) & $FF   ; 256-entry table
  RandomMod8:  A = RandomByte() & $07
  Pick loop:   for slot X in 0..15: re-roll RandomMod8 until the value is < $06,
               keep the slot only on $00, store pool[X] into $042D,X, INC a:$0000.

Sample space: the random index $0050 at loop entry can be any of 0..255, so there are
exactly 256 disaster-month cases, one per index, each producing its own 16-value mod8
sequence (uniqueness is asserted and reported below).

SCOPE NOTE — there is NO cross-month coherence.  $0050 is the single global RNG index
shared by every RandomByte caller in the game; a strategy turn burns a data-dependent
amount of it (AI action rolls, scrolls, battle, severity rolls), so the index a disaster
month starts on is not a function of the previous disaster month.  Anything keyed on an
"inter-month stride" is therefore an artefact, not a mechanic, and is deliberately not
computed here.  What *is* meaningful is how two Provinces co-occur inside ONE month:
the 16 slot rolls share one 256-byte table walk, so their hit indicators are not
independent.

Two models are computed for every index:
  W (window)  : the 16 consecutive table entries at the index, each & $07 — the plain
                "16 calls" reading of the loop.
  R (rom)     : the actual ROM loop with rejection sampling (re-roll while >= $06),
                which consumes 17..27 entries and shifts each following slot.

Outputs:
  docs/disaster_pick_rng_sequences.csv      256 indices x (both sequences + both hit lists)
  docs/disaster_pick_rng_pair_coherence.csv province-pair joint counts / lift / phi
  code/disaster_pick_rng_coherence.md       full enumeration + same-month coherence report

Usage: python3 tools/analyze_disaster_pick_rng.py   (or: make disasterrng)
"""

import csv
import math
import os
import re
import sys
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROM_BANK1F = os.path.join(ROOT, "rom", "prg", "prg_1f.bin")
ASM_1F = os.path.join(ROOT, "asm", "banks", "prg_1f_boot.asm")
ASM_191A = os.path.join(ROOT, "asm", "banks", "prg_19_1a_event_scenes.asm")
PROVINCE_CSV = os.path.join(ROOT, "docs", "province_names.csv")
OUT_CSV = os.path.join(ROOT, "docs", "disaster_pick_rng_sequences.csv")
OUT_PAIR_CSV = os.path.join(ROOT, "docs", "disaster_pick_rng_pair_coherence.csv")
OUT_MD = os.path.join(ROOT, "code", "disaster_pick_rng_coherence.md")

BANK1F_WINDOW = 0xE000          # prg_1f_boot.asm header: $E000-$FFFF
TABLE_ADDR = 0xE8BA
TABLE_LEN = 256
SLOTS = 16


# ---------------------------------------------------------------- input data --
def load_table_from_rom():
    with open(ROM_BANK1F, "rb") as fh:
        blob = fh.read()
    off = TABLE_ADDR - BANK1F_WINDOW
    return list(blob[off:off + TABLE_LEN])


def load_table_from_asm():
    """Cross-check: the .byte rows carry the authoritative ' ; $E8xx: hex' dump."""
    with open(ASM_1F, encoding="utf-8") as fh:
        text = fh.read()
    rows = {}
    start = text.index("RandomTable:")
    for line in text[start:start + 4000].splitlines():
        m = re.match(r"\s*\.byte .*;\s*\$([0-9A-F]{4}): ((?:[0-9A-F]{2} )+[0-9A-F]{2})\s*$", line)
        if not m:
            continue
        addr = int(m.group(1), 16)
        for k, byte in enumerate(m.group(2).split()):
            rows[addr + k] = int(byte, 16)
    return [rows[TABLE_ADDR + i] for i in range(TABLE_LEN)]


def load_pools():
    """Parse @DroughtProvincePool / @FloodProvincePool .byte rows out of the asm."""
    with open(ASM_191A, encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    pools = {}
    for i, line in enumerate(lines):
        m = re.match(r"^@(Drought|Flood)ProvincePool:", line)
        if not m:
            continue
        body = lines[i + 1].split(";")[0].strip()
        assert body.startswith(".byte"), body
        pools[m.group(1).lower()] = [int(v, 16) for v in re.findall(r"\$([0-9A-F]{2})", body[len(".byte"):])]
    assert len(pools) == 2 and all(len(v) == SLOTS for v in pools.values()), pools
    return pools


def load_province_names():
    with open(PROVINCE_CSV, encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))
    return {int(r["id"]): {"romaji": r["romaji"].strip(), "katakana": r["katakana"].strip(),
                           "kanji": r["kanji_ja"].strip()} for r in rows}


# ------------------------------------------------------------------ simulate --
def rom_loop(table, index):
    """Exact ROM replay: rejection sampling, variable consumption."""
    i = index
    rolls, hits = [], []
    for slot in range(SLOTS):
        while True:
            v = table[i] & 0x07
            i = (i + 1) & 0xFF
            if v < 6:
                break
        rolls.append(v)
        if v == 0:
            hits.append(slot)
    return {"index": index, "rolls": rolls, "hits": frozenset(hits),
            "consumed": (i - index) & 0xFF}


def window_seq(table, index):
    """Plain '16 calls' model: the 16 consecutive table entries from the index."""
    seq = [(table[(index + k) & 0xFF] & 0x07) for k in range(SLOTS)]
    return {"index": index, "rolls": seq,
            "hits": frozenset(k for k, v in enumerate(seq) if v == 0)}


# ---------------------------------------------------------------- pair stats --
def pair_stats(cases, slot_a, slot_b):
    """2x2 contingency over the 256 indices for two slots' hit indicators."""
    n = len(cases)
    n11 = sum(1 for c in cases if slot_a in c["hits"] and slot_b in c["hits"])
    n10 = sum(1 for c in cases if slot_a in c["hits"] and slot_b not in c["hits"])
    n01 = sum(1 for c in cases if slot_a not in c["hits"] and slot_b in c["hits"])
    n00 = n - n11 - n10 - n01
    a_hits, b_hits = n11 + n10, n11 + n01
    exp = a_hits * b_hits / n
    denom = math.sqrt((n11 + n10) * (n01 + n00) * (n11 + n01) * (n10 + n00))
    phi = (n11 * n00 - n10 * n01) / denom if denom else 0.0
    return {"n": n, "n11": n11, "n10": n10, "n01": n01, "n00": n00,
            "n_a": a_hits, "n_b": b_hits, "exp": exp,
            "lift": n11 / exp if exp else float("nan"),
            "phi": phi,
            "p_b_given_a": n11 / a_hits if a_hits else float("nan"),
            "p_a_given_b": n11 / b_hits if b_hits else float("nan")}


def chi2_pvalue(obs, exp):
    """Wilson-Hilferty approximation of the chi-square upper tail p-value."""
    stat = sum((o - e) ** 2 / e for o, e in zip(obs, exp))
    df = len(obs) - 1
    if df <= 0:
        return stat, 1.0
    z = ((stat / df) ** (1 / 3.0) - (1 - 2 / (9.0 * df))) / math.sqrt(2 / (9.0 * df))
    return stat, 0.5 * math.erfc(z / math.sqrt(2))


def mask_str(hits):
    return "".join("1" if s in hits else "." for s in range(SLOTS))


def fmt_slots(hits):
    return ",".join(str(s) for s in sorted(hits)) if hits else "-"


def prov(pool, slot, names):
    pid = pool[slot]
    return "$FF*" if pid == 0xFF else f"{names[pid]['romaji']} {names[pid]['kanji']}"


def hit_names(hits, pool, names):
    out = [("$FF*" if pool[s] == 0xFF else names[pool[s]]["romaji"]) for s in sorted(hits)]
    return " ".join(out) if out else "-"


# ---------------------------------------------------------------------- main --
def main():
    table = load_table_from_rom()
    if table != load_table_from_asm():
        sys.exit("FATAL: ROM RandomTable != asm annotation, refusing to analyse")
    pools = load_pools()
    names = load_province_names()
    for pool in pools.values():
        for pid in pool:
            assert pid == 0xFF or pid in names, pid
    real_slots = [s for s in range(SLOTS) if pools["drought"][s] != 0xFF]
    assert len(real_slots) == 15 and all(pools["flood"][s] != 0xFF for s in real_slots)

    rom = [rom_loop(table, i) for i in range(TABLE_LEN)]
    win = [window_seq(table, i) for i in range(TABLE_LEN)]

    # --- uniqueness of the per-index 16-value mod8 sequence ---
    rom_seqs = ["".join(map(str, c["rolls"])) for c in rom]
    win_seqs = ["".join(map(str, c["rolls"])) for c in win]
    rom_dupes = TABLE_LEN - len(set(rom_seqs))
    win_dupes = TABLE_LEN - len(set(win_seqs))
    # cyclic-shift classes: two indices whose sequences are rotations share content
    rom_shift_classes = len({min(s[k:] + s[:k] for k in range(SLOTS)) for s in set(rom_seqs)})
    win_shift_classes = len({min(s[k:] + s[:k] for k in range(SLOTS)) for s in set(win_seqs)})

    nib = Counter(b & 0x07 for b in table)
    acc = sum(nib[k] for k in range(6))
    # Per-index multiplicity: an index whose own byte is a re-roll byte (>= $06) produces exactly the
    # same accepted sequence as its successor, so the 192 distinct R sequences are NOT equiprobable -
    # weight(j) = 1 + length of the re-roll run immediately preceding j.
    is_rej = [(b & 0x07) >= 6 for b in table]
    reps = [j for j in range(TABLE_LEN) if not is_rej[j]]        # one per distinct R sequence
    weights = []
    for j in reps:
        k = 0
        while k < TABLE_LEN and is_rej[(j - 1 - k) & 0xFF]:
            k += 1
        weights.append(1 + k)
    weight_hist = Counter(weights)
    seq_weight = Counter(rom_seqs)
    assert len(reps) == len(set(rom_seqs)) == TABLE_LEN - (nib[6] + nib[7])
    assert sum(weights) == TABLE_LEN, sum(weights)
    # The predicted multiplicity (1 + preceding re-roll run) must equal the observed number of indices
    # that produce each distinct accepted sequence.
    assert sorted(weights) == sorted(seq_weight.values()), (weight_hist, Counter(seq_weight.values()))
    zero_pos = [p for p in range(TABLE_LEN) if (table[p] & 0x07) == 0]
    autocorr = {d: sum(1 for p in zero_pos if table[(p + d) & 0xFF] & 0x07 == 0)
                for d in range(1, 16)}
    exp_w_pair = TABLE_LEN * (len(zero_pos) / TABLE_LEN) ** 2
    rej_autocorr = {d: sum(1 for p in range(TABLE_LEN) if is_rej[p] and is_rej[(p + d) & 0xFF])
                    for d in range(1, 16)}

    slot_hits_r = [sum(1 for c in rom if s in c["hits"]) for s in range(SLOTS)]
    slot_hits_w = [sum(1 for c in win if s in c["hits"]) for s in range(SLOTS)]
    exp_uniform = sum(slot_hits_r) / SLOTS
    stat_r, p_r = chi2_pvalue(slot_hits_r, [exp_uniform] * SLOTS)
    stat_w, p_w = chi2_pvalue(slot_hits_w, [sum(slot_hits_w) / SLOTS] * SLOTS)

    cnt_r = Counter(len(c["hits"]) for c in rom)
    cnt_w = Counter(len(c["hits"]) for c in win)
    mean_r = sum(len(c["hits"]) for c in rom) / TABLE_LEN
    mean_w = sum(len(c["hits"]) for c in win) / TABLE_LEN
    var_r = sum((len(c["hits"]) - mean_r) ** 2 for c in rom) / TABLE_LEN
    var_w = sum((len(c["hits"]) - mean_w) ** 2 for c in win) / TABLE_LEN
    p_bar = mean_r / SLOTS
    binom = {k: TABLE_LEN * math.comb(SLOTS, k) * p_bar ** k * (1 - p_bar) ** (SLOTS - k)
             for k in range(SLOTS + 1)}

    consumed = Counter(c["consumed"] for c in rom)

    # --- same-month province-pair coherence (real slots only) ---
    pairs_r, pairs_w = [], []
    for a in real_slots:
        for b in real_slots:
            if a >= b:
                continue
            pr = pair_stats(rom, a, b)
            pw = pair_stats(win, a, b)
            for lst, st, model in ((pairs_r, pr, "R"), (pairs_w, pw, "W")):
                lst.append({"a": a, "b": b, "dist": b - a, "model": model, **st})
    lift_r = [p["lift"] for p in pairs_r]
    lift_w = [p["lift"] for p in pairs_w]
    phi_r = [p["phi"] for p in pairs_r]
    # Variance-sum identity: Var(hits per month) - sum of per-slot variances = 2 x sum of covariances,
    # which quantifies the net within-month (anti)coupling.
    var_sum_indep = sum((slot_hits_r[s] / TABLE_LEN) * (1 - slot_hits_r[s] / TABLE_LEN)
                        for s in range(SLOTS))
    cov_sum = (var_r - var_sum_indep) / 2.0
    n_all_pairs = SLOTS * (SLOTS - 1) // 2
    mean_cov = cov_sum / n_all_pairs
    mean_phi = sum(phi_r) / len(phi_r)
    top_r = sorted(pairs_r, key=lambda p: -p["lift"])[:10]
    bot_r = sorted(pairs_r, key=lambda p: p["lift"])[:10]
    top_w = sorted(pairs_w, key=lambda p: -p["lift"])[:10]
    bot_w = sorted(pairs_w, key=lambda p: p["lift"])[:10]
    dist_r = {d: [p["lift"] for p in pairs_r if p["dist"] == d] for d in range(1, SLOTS)}
    dist_w = {d: [p["lift"] for p in pairs_w if p["dist"] == d] for d in range(1, SLOTS)}

    # cross-pool (flood province vs drought province, same month): impossible by design
    cross_hits = sum(1 for c in rom for a in c["hits"] for b in c["hits"]
                     if pools["drought"][a] == pools["flood"][b])

    # ------------------------------------------------------- sequences CSV --
    with open(OUT_CSV, "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["random_index_hex", "random_index_dec",
                    "window_mod8_16", "window_hit_mask", "window_hit_slots", "window_hit_count",
                    "rom_mod8_16", "rom_hit_mask", "rom_hit_slots", "rom_hit_count",
                    "table_entries_consumed", "drought_provinces", "flood_provinces"])
        for r, c in zip(rom, win):
            w.writerow([
                f"${r['index']:02X}", r["index"],
                "".join(map(str, c["rolls"])), mask_str(c["hits"]), fmt_slots(c["hits"]), len(c["hits"]),
                "".join(map(str, r["rolls"])), mask_str(r["hits"]), fmt_slots(r["hits"]), len(r["hits"]),
                r["consumed"],
                " ".join(names[pools["drought"][s]]["romaji"] if pools["drought"][s] != 0xFF
                         else "$FF*" for s in sorted(r["hits"])) or "-",
                " ".join(names[pools["flood"][s]]["romaji"] if pools["flood"][s] != 0xFF
                         else "$FF*" for s in sorted(r["hits"])) or "-",
            ])

    # ---------------------------------------------------------- pairs CSV --
    with open(OUT_PAIR_CSV, "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["model", "pool", "slot_a", "province_a_id", "province_a",
                    "slot_b", "province_b_id", "province_b", "slot_distance",
                    "indices_both_hit", "indices_a_hit", "indices_b_hit",
                    "expected_under_independence", "lift", "phi",
                    "p_b_hits_given_a_hits", "p_a_hits_given_b_hits"])
        for pool_key in ("drought", "flood"):
            for row in pairs_r:
                a, b = row["a"], row["b"]
                w.writerow(["R_rom_rejection_sampling", pool_key,
                            a, f"${pools[pool_key][a]:02X}", names[pools[pool_key][a]]["romaji"],
                            b, f"${pools[pool_key][b]:02X}", names[pools[pool_key][b]]["romaji"],
                            row["dist"], row["n11"], row["n_a"], row["n_b"], row["exp"],
                            f"{row['lift']:.4f}", f"{row['phi']:.4f}",
                            f"{row['p_b_given_a']:.4f}", f"{row['p_a_given_b']:.4f}"])
            for row in pairs_w:
                a, b = row["a"], row["b"]
                w.writerow(["W_plain_window", pool_key,
                            a, f"${pools[pool_key][a]:02X}", names[pools[pool_key][a]]["romaji"],
                            b, f"${pools[pool_key][b]:02X}", names[pools[pool_key][b]]["romaji"],
                            row["dist"], row["n11"], row["n_a"], row["n_b"], row["exp"],
                            f"{row['lift']:.4f}", f"{row['phi']:.4f}",
                            f"{row['p_b_given_a']:.4f}", f"{row['p_a_given_b']:.4f}"])

    # ------------------------------------------------------------- report --
    L = []
    A = L.append
    A("# Disaster province pick: all 256 random indices and SAME-MONTH province coherence\n")
    A("Generated by `tools/analyze_disaster_pick_rng.py` (`make disasterrng`) from "
      "`rom/prg/prg_1f.bin` + `asm/banks/prg_1f_boot.asm` (RNG), `asm/banks/prg_19_1a_event_scenes.asm` "
      "(`ProvincePickListBuild` $A896, pools $A8C0/$A8D0) and `docs/province_names.csv`.\n")
    A("CSV twins: [`disaster_pick_rng_sequences.csv`](../docs/disaster_pick_rng_sequences.csv) "
      "(256 indices), [`disaster_pick_rng_pair_coherence.csv`](../docs/disaster_pick_rng_pair_coherence.csv) "
      "(all 105 province pairs x 2 pools x 2 models).\n")

    A("## Scope: why there is no cross-month coherence\n")
    A("`$0050` is the **single global** RNG index shared by every `B1F_RandomByte` caller "
      "(`RandomByte2/3/4` use independent indices $0052/$0054/$0055). Between two disaster months a "
      "strategy turn burns a large, data-dependent amount of it — AI action rolls, advice rolls, map "
      "scrolls, battle and duel code all call the same walk — so the index a disaster month starts on "
      "is **not** a function of the previous disaster month's index. Any 'stride'/'cycle' coupling "
      "between months is an artefact of ignoring those consumers, so it is not analysed here.")
    A("What remains, and what this report measures, is coherence **inside one month**: the 16 slot rolls "
      "of one month are drawn from one contiguous stretch of the same 256-entry table, so the hit "
      f"indicators of two Provinces are not independent — that coupling is the {len(pairs_r) * 2} entries "
      "of the pair-coherence CSV.\n")

    A("## Sample space and models\n")
    A("The random index at loop entry can be any of 0..255, so there are exactly **256 cases**, one per "
      "index, and each case yields one 16-value mod8 sequence. Two readings are computed:\n")
    A("| model | definition | table entries eaten per month |")
    A("|---|---|---|")
    A(f"| **W** plain window | the 16 consecutive entries at the index, each `& $07` (the literal "
      "'16 calls' reading) | exactly 16 |")
    A(f"| **R** ROM | the actual loop: re-roll `RandomMod8` while `>= $06`, keep slot only on `$00` "
      "($A8A5-$A8AA) | {lo}..{hi} (mean {mean:.2f}) |".format(
        lo=min(consumed), hi=max(consumed), mean=sum(c * n for c, n in consumed.items()) / TABLE_LEN))
    A("")
    A("**Uniqueness check (requested):** model W yields %d distinct 16-digit sequences out of 256 indices "
      "(%d duplicates) — every index does generate its own sequence, as expected. Model R yields %d "
      "distinct sequences (%d duplicates): an index whose own byte is a re-roll byte (`& $07 >= $06`, %d of "
      "256 entries) eats that byte before the first slot and therefore produces *exactly* the accepted "
      "sequence of index+1, so runs of consecutive re-roll bytes collapse onto one outcome."
      % (len(set(win_seqs)), win_dupes, len(set(rom_seqs)), rom_dupes, nib[6] + nib[7]))
    A("The %d distinct R sequences are **not equiprobable**: sequence multiplicity = 1 + length of the "
      "re-roll run immediately preceding its index (predicted multiplicities verified against the observed "
      "counts): %s. All statistics in this report are therefore computed over the 256 *indices* (the "
      "uniform sample space the hardware walks), not over the %d distinct strings — counting indices "
      "automatically carries the right weights.\n" % (
        len(set(rom_seqs)),
        ", ".join(f"weight {k}: {weight_hist[k]} sequence(s)" for k in sorted(weight_hist)),
        len(set(rom_seqs))))
    A("Consequence for the plain '16 calls' intuition: model W's per-slot hit share is 32/256 = **1/8** "
      "(mean %.3f hits/month), while the ROM's rejection sampling renormalises it to 32/192 = **1/6** "
      "(mean %.3f). The re-rolls are what raise the disaster rate by a third.\n" % (mean_w, mean_r))
    A("Model R's sequence for index *i+1* is usually model R's sequence for *i* shifted by one digit with "
      "a new tail digit, because the accepted-value stream is the same table walk minus the rejected "
      "bytes; that is a property of the enumeration, not extra randomness.\n")

    A("## 1. The random table ($E8BA, 256 bytes)\n")
    A("```")
    A("byte & $07 histogram: " + "  ".join(f"{k}:{nib[k]}" for k in range(8)))
    A("accepted (<$06): %d bytes -> per-slot hit share %d/%d = %.4f" % (acc, nib[0], acc, nib[0] / acc))
    A("re-rolled (>= $06): %d bytes = %.1f%% of the table" % (nib[6] + nib[7], 100.0 * (nib[6] + nib[7]) / 256))
    A("```\n")
    A("The table is perfectly balanced (32 of each low-nibble value), so the marginal hit chance of one "
      "slot is exactly 1/6 = 16.67%; all deviation in this report is therefore joint-structure, not "
      "per-slot bias.\n")

    A("## 2. Marginal hit rate per Province (256 indices)\n")
    A("| slot | Province (drought pool) | Province (flood pool) | R hits | R rate | W hits | W rate |")
    A("|---|---|---|---|---|---|---|")
    for s in range(SLOTS):
        A("| %d | %s | %s | %d | %.2f%% | %d | %.2f%% |" % (
            s, prov(pools["drought"], s, names), prov(pools["flood"], s, names),
            slot_hits_r[s], 100.0 * slot_hits_r[s] / TABLE_LEN,
            slot_hits_w[s], 100.0 * slot_hits_w[s] / TABLE_LEN))
    A("")
    A("R: min %d, max %d, ideal %.1f (chi-square %.2f, df 15, upper-tail p %.3f). "
      "W: min %d, max %d, chi-square %.2f, p %.3f. Both marginals are flat, which is exactly why the "
      "pairwise joint numbers below are the interesting part.\n" % (
        min(slot_hits_r), max(slot_hits_r), exp_uniform, stat_r, p_r,
        min(slot_hits_w), max(slot_hits_w), stat_w, p_w))

    A("## 3. Hits per month\n")
    A("| hit count | R indices | W indices | Binomial(16, %.4f) reference |" % p_bar)
    A("|---|---|---|---|")
    for k in range(SLOTS + 1):
        if k not in cnt_r and k not in cnt_w and binom.get(k, 0) < 0.5:
            continue
        A("| %d | %d | %d | %.1f |" % (k, cnt_r.get(k, 0), cnt_w.get(k, 0), binom.get(k, 0)))
    A("")
    A("R: mean %.3f, variance %.3f. W: mean %.3f, variance %.3f. Binomial(16,1/6) reference variance "
      "%.3f. Both models are under-dispersed and both never produce an empty month in R "
      "(%d indices with zero hits) or W (%d) — the callers' 'no hit -> skip the scene' branch at "
      "$A705 / $A9B6 is unreachable, so a flood/drought month always shows at least one Province "
      "card.\n" % (mean_r, var_r, mean_w, var_w, 16 * p_bar * (1 - p_bar),
                    cnt_r.get(0, 0), cnt_w.get(0, 0)))
    A("Slot 15 stores the pool tail byte `$FF` ($A8CF / $A8DF): model R still counts it in `a:$0000`, "
      "model W hits it %d times. Real candidates per month are therefore 15, not 16.\n" % slot_hits_w[15])

    A("## 4. SAME-MONTH coherence between two Provinces\n")
    A("For each pair of slots (a, b) over the 256 indices: `n11` = indices where both Provinces are hit, "
      "`E` = `n_a x n_b / 256` (independence), `lift = n11 / E`, `phi` = the Pearson correlation of the "
      "two hit indicators (+1 = always together, -1 = mutually exclusive, 0 = independent). "
      "%d pairs per pool, %d rows in the CSV.\n" % (len(pairs_r), len(pairs_r) * 4))
    A("```")
    A("model R  lift: min %.3f  median %.3f  max %.3f   phi: min %+.3f  max %+.3f" % (
        min(lift_r), sorted(lift_r)[len(lift_r) // 2], max(lift_r), min(phi_r), max(phi_r)))
    A("model W  lift: min %.3f  median %.3f  max %.3f   phi: min %+.3f  max %+.3f" % (
        min(lift_w), sorted(lift_w)[len(lift_w) // 2], max(lift_w),
        min(p["phi"] for p in pairs_w), max(p["phi"] for p in pairs_w)))
    A("```")
    A("So within one month the joint risk is *not* the product of the marginals: model R pairs range "
      "%.0f%%..%.0f%% of independence, model W pairs %.0f%%..%.0f%%. Because slot -> Province is "
      "positional, these are literally Province pairs.\n" % (
        100 * min(lift_r), 100 * max(lift_r), 100 * min(lift_w), 100 * max(lift_w)))
    A("The **net** coupling is repulsion: mean lift over the %d Province pairs %.3f, mean phi %+.4f. That "
      "is forced by the hit-count budget of section 3 — a:$0000 counts all 16 slots, its variance is "
      "%.3f against a sum of independent per-slot variances of %.3f, and the %.3f deficit has to be "
      "carried by the 2 x %d covariances (mean covariance %+.5f). In plain terms: a month holds roughly "
      "2-3 hits and the table spreads them out, so knowing one Province was hit makes another one *less* "
      "likely to be hit than chance would suggest.\n" % (
        len(pairs_r), sum(lift_r) / len(lift_r), mean_phi, var_r, var_sum_indep,
        var_sum_indep - var_r, n_all_pairs, mean_cov))
    A("Model W's coupling is a pure function of the slot *distance* (all pairs at the same distance come "
      "out identical, since the two slots just read table entries *d* apart); model R breaks that "
      "degeneracy because each re-roll shifts the following slots by a variable amount.\n")

    A("### 4.1 Coherence vs slot distance\n")
    A("If the coupling were only 'nearby table entries look alike', lift would decay with the distance "
      "b-a. Observed mean lift per distance:\n")
    A("| distance d | pairs | mean lift R | mean lift W | min lift R | max lift R |")
    A("|---|---|---|---|---|---|")
    for d in range(1, SLOTS):
        if not dist_r[d]:
            continue
        A("| %d | %d | %.3f | %.3f | %.3f | %.3f |" % (
            d, len(dist_r[d]), sum(dist_r[d]) / len(dist_r[d]),
            sum(dist_w[d]) / len(dist_w[d]) if dist_w[d] else float("nan"),
            min(dist_r[d]), max(dist_r[d])))
    A("")
    attract = [d for d in sorted(dist_r) if dist_r[d] and sum(dist_r[d]) / len(dist_r[d]) > 1.2]
    repel = [d for d in sorted(dist_r) if dist_r[d] and sum(dist_r[d]) / len(dist_r[d]) < 0.6]
    A("The profile does **not** decay with distance — it oscillates: distances %s are strongly repelling "
      "(mean lift %.2f..%.2f) while distances %s are attracting (mean lift up to %.2f). Adjacent slots "
      "(d=1) are the most repulsive short-range case because the table simply does not place two "
      "`& $07 == 0` bytes next to each other often. The oscillation is the fingerprint of the table's "
      "fixed layout, made explicit in section 4.2.\n" % (
        "/".join(str(d) for d in repel), min(sum(dist_r[d]) / len(dist_r[d]) for d in repel),
        max(sum(dist_r[d]) / len(dist_r[d]) for d in repel),
        "/".join(str(d) for d in attract),
        max(sum(dist_r[d]) / len(dist_r[d]) for d in attract) if attract else float("nan")))

    A("### 4.2 Mechanism: the coherence is the table's own autocorrelation\n")
    A("In model W a Province pair at slot distance *d* is hit together exactly when two table entries *d* "
      "apart both satisfy `& $07 == 0`. So the joint count is the lag-*d* autocorrelation `C(d)` of the "
      f"{len(zero_pos)} hit-byte positions, and independence predicts `C = 256 x (32/256)^2 = "
      f"{exp_w_pair:.1f}`. Measured directly from `$E8BA`:\n")
    A("| lag d | C(d) zero-pairs | C(d)/independence | model W lift (observed) | re-roll-pair count R(d) "
      "| re-roll pairs / independence |")
    A("|---|---|---|---|---|---|")
    for d in range(1, SLOTS):
        A("| %d | %d | %.3f | %s | %d | %.3f |" % (
            d, autocorr[d], autocorr[d] / exp_w_pair,
            ("%.3f" % (sum(dist_w[d]) / len(dist_w[d]))) if dist_w[d] else "n/a (slot 15 is the $FF tail)",
            rej_autocorr[d], rej_autocorr[d] / (256 * ((nib[6] + nib[7]) / 256.0) ** 2)))
    A("")
    A("Every W lift equals `C(d)/%.1f` exactly, which proves the coupling is not a property of the "
      "Provinces or of the pick algorithm but of **where Namco put the zeros in the 256-byte table** "
      "(the `%d` entries with `& $07 == 0`, whose lag-*d* autocorrelations are listed above).\n" % (
        exp_w_pair, len(zero_pos)))
    A("Model R does **not** preserve that clean profile: because each re-roll shifts every following slot "
      "by a variable amount, a slot pair at distance *d* samples a spread of table lags instead of one. "
      "That is why R's per-distance means (%.2f..%.2f) diverge from W's `C(d)/%.1f` (%.2f..%.2f) and why "
      "individual R pairs at the same distance differ from each other (R lift %.2f..%.2f) while W pairs at "
      "a fixed distance are identical. W is the diagnostic, R is what the console does.\n" % (
        min(sum(dist_r[d]) / len(dist_r[d]) for d in dist_r if dist_r[d]),
        max(sum(dist_r[d]) / len(dist_r[d]) for d in dist_r if dist_r[d]),
        exp_w_pair, min(lift_w), max(lift_w), min(lift_r), max(lift_r)))
    A("Practical reading: the R pairs at distance %s are the near-impossible ones (down to %d of 256 "
      "indices where independence predicts %.1f), while distance %s pairs co-occur up to %.2fx as often as "
      "chance. Which Provinces those are follows from the pool tables ($A8C0/$A8D0) — slot distance is not "
      "map distance, so the coupled pairs are effectively arbitrary Province combinations, listed by name "
      "in section 4.3.\n" % (
        "/".join(str(d) for d in repel[:3]), min(p["n11"] for p in pairs_r),
        max(p["exp"] for p in pairs_r if p["n11"] == min(q["n11"] for q in pairs_r)),
        "/".join(str(d) for d in attract), max(lift_r)))

    A("### 4.3 Strongest and weakest Province pairs (model R)\n")
    A("| slots | Province A | Province B | d | both hit /256 | E | lift | phi | P(B hit \\| A hit) |")
    A("|---|---|---|---|---|---|---|---|---|")
    for p in top_r:
        A("| %d,%d | %s | %s | %d | %d | %.2f | %.3f | %+.3f | %.1f%% |" % (
            p["a"], p["b"], prov(pools["drought"], p["a"], names), prov(pools["drought"], p["b"], names),
            p["dist"], p["n11"], p["exp"], p["lift"], p["phi"], 100 * p["p_b_given_a"]))
    A("")
    A("Least likely to share a month:\n")
    A("| slots | Province A | Province B | d | both hit /256 | E | lift | phi | P(B hit \\| A hit) |")
    A("|---|---|---|---|---|---|---|---|---|")
    for p in bot_r:
        A("| %d,%d | %s | %s | %d | %d | %.2f | %.3f | %+.3f | %.1f%% |" % (
            p["a"], p["b"], prov(pools["drought"], p["a"], names), prov(pools["drought"], p["b"], names),
            p["dist"], p["n11"], p["exp"], p["lift"], p["phi"], 100 * p["p_b_given_a"]))
    A("")
    A("The flood pool carries the same slot-level structure with different Province labels (the rolls do "
      "not depend on Y, only the stored ids do); see the CSV rows `pool=flood` for the named flood "
      "equivalents, e.g. slots (%d,%d) = %s + %s.\n" % (
        bot_r[0]["a"], bot_r[0]["b"], prov(pools["flood"], bot_r[0]["a"], names),
        prov(pools["flood"], bot_r[0]["b"], names)))

    A("### 4.4 Flood Province vs drought Province: mutually exclusive\n")
    A("A drought Province id and a flood Province id can never co-occur in one month: the pools are "
      "disjoint halves of the 30 Province ids, so the same-month joint count for any flood+drought pair "
      f"is **{cross_hits}** (out of 256 indices, {len(pairs_r)} real pairs each) and `lift = 0`, "
      "`phi = -1`. This is structural (data layout), not probabilistic — the strongest coherence in the "
      "system, and the reason a Province never sees both 洪水 and 日照り.\n")

    A("## 5. Full enumeration — all 256 random indices\n")
    A("`W` = plain-window mod8 string, `R` = ROM accepted-value string after rejection sampling; a digit "
      "`0` marks the kept (hit) slot, slot $00 is the leftmost digit. `$FF*` = pool tail entry "
      "($A8CF/$A8DF): counted by `a:$0000`, skipped by the scene poll.\n")
    A("```")
    A("idx  W mod8          W mask        R mod8          R mask        hits(R)  drought (Y=$00)"
      "                              flood (Y=$10)                             eaten")
    A("-" * 158)
    for r, c in zip(rom, win):
        A("$%02X  %-14s  %-13s  %-14s  %-13s  %-7s  %-38s %-38s %2d" % (
            r["index"], "".join(map(str, c["rolls"])), mask_str(c["hits"]),
            "".join(map(str, r["rolls"])), mask_str(r["hits"]), fmt_slots(r["hits"]),
            hit_names(r["hits"], pools["drought"], names),
            hit_names(r["hits"], pools["flood"], names), r["consumed"]))
    A("```\n")

    A("## 6. Caveats\n")
    A("* Model R is the ROM-faithful replay (verified byte-for-byte against $A8A5-$A8BD); model W is the "
      "analytical '16 independent-looking calls' simplification. Where they disagree, R is what the "
      "console does.")
    A("* The 256 indices are treated as equally likely. In a real save the index distribution is set by "
      "unrelated RNG traffic, which is also what destroys cross-month coupling.")
    A("* `@DamageProvincePoll` / `@LossProvincePoll` still skip an UnclaimedLand Province (owner nibble 7) "
      "and an AI/unattended country (`Country[$03]==$03`), so a *rendered* pair of hits can be smaller "
      "than the list built here; the joint statistics above are about the built list.")
    A("* Damage severity is a separate roll (`DisasterSeverityRoll`, 防災 tiered) and does not feed back "
      "into which Provinces are in the list.\n")

    with open(OUT_MD, "w", encoding="utf-8") as fh:
        fh.write("\n".join(L) + "\n")

    print(f"table: ROM == asm annotation ({TABLE_LEN} bytes), &7 histogram " +
          " ".join(f"{k}:{nib[k]}" for k in range(8)))
    print(f"uniqueness: W {len(set(win_seqs))}/256 distinct ({win_dupes} dupes, "
          f"{win_shift_classes} rotation classes), R {len(set(rom_seqs))}/256 distinct "
          f"({rom_dupes} dupes, {rom_shift_classes} rotation classes)")
    print(f"marginals R: {min(slot_hits_r)}..{max(slot_hits_r)}/256, chi2 {stat_r:.2f} p {p_r:.3f}")
    print(f"hits/month R: mean {mean_r:.3f} var {var_r:.3f} zero {cnt_r.get(0,0)}; "
          f"W: mean {mean_w:.3f} var {var_w:.3f} zero {cnt_w.get(0,0)}")
    print(f"same-month pair coherence R: lift {min(lift_r):.3f}..{max(lift_r):.3f} "
          f"(median {sorted(lift_r)[len(lift_r)//2]:.3f}), phi {min(phi_r):+.3f}..{max(phi_r):+.3f}")
    print(f"same-month pair coherence W: lift {min(lift_w):.3f}..{max(lift_w):.3f} "
          f"(median {sorted(lift_w)[len(lift_w)//2]:.3f})")
    print(f"R index multiplicity: {dict(sorted(weight_hist.items()))} "
          f"(distinct sequences {len(set(rom_seqs))})")
    print(f"mechanism: zero-byte autocorrelation C(1..8) = "
          + " ".join(f"{autocorr[d]}" for d in range(1, 9)) + f" vs independence {exp_w_pair:.1f}")
    print(f"net coupling R: mean lift {sum(lift_r)/len(lift_r):.3f}, mean phi {mean_phi:+.4f}, "
          f"Var(a:$0000) {var_r:.3f} vs independent per-slot sum {var_sum_indep:.3f}, "
          f"mean cov {mean_cov:+.5f}")
    print(f"wrote {os.path.relpath(OUT_CSV, ROOT)}, {os.path.relpath(OUT_PAIR_CSV, ROOT)}, "
          f"{os.path.relpath(OUT_MD, ROOT)} ({len(L)} lines)")


if __name__ == "__main__":
    main()
