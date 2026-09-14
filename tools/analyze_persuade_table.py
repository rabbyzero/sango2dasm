#!/usr/bin/env python3
"""Analyze the duel-mode persuade (説得) event table in prg_17_18.

Table: BattleInit_FormationData ($BFB2 bank $17, $C000-$C089 bank $18),
216 entries, values 1-4 = persuade outcome event id.
Index = loyalty_term + vitality_term + intvirtue_term + rand(0-7):
  target Loyalty >= $50: 0, < $50: +$18, < $32: +$18 more
  target Vitality >= $50: 0, < $50: +$08, < $32: +$08 more
  own (Intelligence+Virtue) >= $B4: 0, < $B4: +$48, < $82: +$48 more
Events: 1/2 = refusal (back to command menu), 3 = wavers, 4 = accepts
(「これも天命かもしれん」 -> officer joins: panel $38).
"""
b17 = open('/home/zero/project/sango2dasm/rom/prg/prg_17.bin','rb').read()
b18 = open('/home/zero/project/sango2dasm/rom/prg/prg_18.bin','rb').read()
part1 = b17[0xBFB2-0xA000:0x2000]
part2 = b18[0x0000:0xC08A-0xC000]
table = list(part1) + list(part2)
print("table len:", len(table), "values:", sorted(set(table)))

def pct(n):
    return f"{100.0*n/8:.0f}%"

hdr = f"{'Loyalty':>16} {'Vitality':>16} {'Int+Virtue':>16} | succ(4) | wav(3) | refuse(1/2)"
print(hdr)
print("-" * len(hdr))
for lo, lo_desc in ((0, ">= $50"), (24, "< $50"), (48, "< $32")):
    for vi, vi_desc in ((0, ">= $50"), (8, "< $50"), (16, "< $32")):
        for iv, iv_desc in ((0, ">= $B4"), (72, "< $B4"), (144, "< $82")):
            s = lo + vi + iv
            ev = table[s:s+8]
            print(f"{lo_desc:>16} {vi_desc:>16} {iv_desc:>16} | "
                  f"{pct(ev.count(4)):>5} | {pct(ev.count(3)):>5} | "
                  f"{pct(ev.count(1)+ev.count(2)):>5}")
