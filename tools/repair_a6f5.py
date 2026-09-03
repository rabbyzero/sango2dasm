ASM = "asm/banks/prg_19_1a.asm"
lines = open(ASM).read().split("\n")
out = []
i = 0
added_word = False
added_label = False
while i < len(lines):
    ln = lines[i]
    if not added_label and "; $A85F: 20 85 A9" in ln:
        out.append("Loc_A85F:  ; (dispatch callback target)")
        added_label = True
    out.append(ln)
    if not added_word and "; $A6F9: 41 A7 ; sub 2" in ln:
        out.append("  .word Loc_A85F                           ; $A6FB: 5F A8 ; sub 3")
        added_word = True
    i += 1
src = "\n".join(out)
src = src.replace("; --- Inline pointer table (3 entries) ---\n  .word Loc_A6FD", "; --- Inline pointer table (4 entries) ---\n  .word Loc_A6FD", 1)
if not (added_word and added_label):
    raise SystemExit("repair failed: word=%s label=%s" % (added_word, added_label))
open(ASM, "w").write(src)
print("repair applied")
