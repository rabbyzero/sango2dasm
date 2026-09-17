#!/usr/bin/env python3
"""Symbolize raw relative branch targets ($A000-$FFFF) in prg_1b_1c.asm.

Replaces `BXX $XXXX` operands with existing @-local labels (same-proc refs,
verified by tools/tmp_analyze_branch_targets_1b1c.py), and inserts 6 new
semantic labels at previously unlabeled targets. Also converts the inline
.byte row at $C9E6 (trampoline + continuation code) back to instructions,
matching the established inline-dispatch pattern (cf. SortieWarRequestGate).
"""
import re

PATH = '/home/zero/project/sango2dasm/asm/banks/prg_1b_1c.asm'

hexcomment = re.compile(r';\s*\$([0-9A-F]{4}):')
labeldef = re.compile(r'^\s*(\S+?):')
branchraw = re.compile(r'^(\s{2}(?:BCC|BCS|BEQ|BMI|BNE|BPL|BVC|BVS))\s+(\$[0-9A-F]{4})\b')

NEW_LABELS = {
    0xB231: '@SlideWaitExit',      # SortieAbortSlideWait: slide still in progress / no selection
    0xB255: '@WarRequestCommit',   # SortieWarRequestGate: dialog result != $FF -> commit sortie
    0xB5A5: '@RedrawBusyExit',     # ResultRedrawTrigger: overlay busy -> skip redraw step
    0xB61F: '@WarLaunchSkip',      # WarSceneLaunch: $0087 bit7 clear -> no war scene launch
    0xC827: '@ArmoryDescRender',   # @ArmoryItemDescStream: $0300 == $FF -> render item records
    0xC9EE: '@ArmoryBuyGateSkip',  # @ArmoryBuyerGate: $0300 nonzero -> skip purchase gate
}

INLINE_C9E6_OLD = [
    '; --- Data Region ---',
    '  .byte $24,$A0,$AD,$71,$04,$8D,$01,$04,$60 ; $C9E6: 24 A0 AD 71 04 8D 01 04 60',
]
INLINE_C9E6_NEW = [
    '  .word B1D_1E_ImmediateOverlay         ; $C9E6: 24 A0 (BankedCallbackTrampoline target)',
    '  LDA $0471                             ; $C9E8: AD 71 04',
    '  STA $0401                             ; $C9EB: 8D 01 04  ; -> sub 17 (@ArmoryPurchaseApply)',
    '@ArmoryBuyGateSkip:',
    '  RTS                                   ; $C9EE: 60',
]

lines = open(PATH, encoding='utf-8').read().splitlines()

# --- build addr -> label map (label address = own or next instruction's hex comment) ---
addr_label = {}
addr_line = {}
for i, ln in enumerate(lines):
    m = hexcomment.search(ln)
    if m:
        a = int(m.group(1), 16)
        if a not in addr_line:
            addr_line[a] = i
for i, ln in enumerate(lines):
    lm = labeldef.match(ln)
    if not lm:
        continue
    name = lm.group(1).strip()
    if name.startswith('.') or name.startswith(';'):
        continue
    m = hexcomment.search(ln)
    addr = int(m.group(1), 16) if m else None
    if addr is None:
        for j in range(i + 1, min(i + 5, len(lines))):
            m2 = hexcomment.search(lines[j])
            if m2:
                addr = int(m2.group(1), 16)
                break
            if labeldef.match(lines[j]):
                continue
    if addr is not None and addr not in addr_label:
        addr_label[addr] = name

addr_label.update(NEW_LABELS)

# --- apply edits ---
out = []
replaced = 0
labeled = 0
i = 0
while i < len(lines):
    ln = lines[i]
    # inline .byte row at $C9E6 -> code + label at $C9EE
    if ln.startswith('; --- Data Region ---') and i + 1 < len(lines) \
            and '; $C9E6:' in lines[i + 1]:
        out.extend(INLINE_C9E6_NEW)
        labeled += 1
        i += 2
        continue
    m = branchraw.match(ln)
    if m:
        hexm = hexcomment.search(ln)
        tgt = int(m.group(2)[1:], 16)
        name = addr_label.get(tgt)
        assert name, f"no label for branch target ${tgt:04X} at line {i + 1}"
        cm = hexcomment.search(ln)
        code = f"{m.group(1)} {name}"
        newln = code.ljust(cm.start()) + ln[cm.start():]
        out.append(newln)
        replaced += 1
        i += 1
        continue
    hexm = hexcomment.search(ln)
    if hexm:
        a = int(hexm.group(1), 16)
        if a in NEW_LABELS:
            # insert new label before this line if not already labeled here
            if not labeldef.match(ln):
                out.append(NEW_LABELS[a] + ':')
                labeled += 1
    out.append(ln)
    i += 1

open(PATH, 'w', encoding='utf-8').write('\n'.join(out) + '\n')
print(f"branch operands replaced: {replaced}")
print(f"new labels inserted / inline rows converted: {labeled}")
