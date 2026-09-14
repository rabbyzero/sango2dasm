#!/usr/bin/env python3
"""Replace raw direct-address operands ($A000-$FFFF) in prg_1b_1c.asm with symbols.

- $A000-$DFFF targets -> labels defined in this file (or the new inner-entry
  label ActionDeltaInputPoll_CapInA at $DA04).
- $E000-$FFFF targets -> B1F_* equates from include/functions.h.
- .word $A018 trampoline target -> B19_1A_TransferCapacityCalc (bank $19 entry,
  documented in functions.h).

Only the operand token is rewritten; hex byte comments are preserved.
Label/alias insertions do not emit bytes, so output stays byte-identical.
"""
import re

PATH = "asm/banks/prg_1b_1c.asm"

SYMBOLS = {
    # bank $1F fixed engine (functions.h)
    "$E57F": "B1F_BankPpuInit",
    "$E673": "B1F_SoundWrapperA",
    "$E843": "B1F_RandomBelow100",
    "$E850": "B1F_RandomMod4",
    "$E856": "B1F_RandomMod8",
    "$E85C": "B1F_RandomMod16",
    "$E9BA": "B1F_MathBinToBcd",
    "$EA7C": "B1F_MathDiv16",
    "$EAA5": "B1F_MathDiv24",
    "$EBE9": "B1F_MathMul24x8",
    "$ECEE": "B1F_PaletteCopyBuffer",
    "$ED19": "B1F_MenuCursorSystem",
    "$ED1E": "B1F_MenuStep2",
    "$ED28": "B1F_MenuStep4",
    "$EDF5": "B1F_PointerTableLookup",
    "$EE07": "B1F_BankedCallbackTrampoline",
    "$F25F": "B1F_SwitchBank8_B",
    "$F26D": "B1F_SetUI0",
    "$F28B": "B1F_SetUI4",
    "$F29B": "B1F_ClearUI",
    "$F2AF": "B1F_GetProvinceRecordAddr",
    "$F2D7": "B1F_GetOfficerRecordAddr",
    "$F368": "B1F_GetCountryDataPtr",
    "$F387": "B1F_GetOfficerRomRecordAddr",
    # bank $19 entry stub via functions.h (BankedCallbackTrampoline .word target)
    "$A018": "B19_1A_TransferCapacityCalc",
    # labels inside this file
    "$A46E": "CastleDevFieldOffsetTable",
    "$C6BB": "@AcademyTierSet",
    "$C85B": "@ArmoryGridNextItem",
    "$C8FA": "@ArmoryItemDescAddrTable",
    "$CAC5": "@WeaponGatePass",
    "$D543": "MapCursorArrowDraw",
    "$DA02": "ActionDeltaInputPoll",
    "$DA04": "ActionDeltaInputPoll_CapInA",
    "$DC6B": "ProvinceOfficerCount",
    "$DD4F": "ProvinceRulerIdGet",
    "$DD56": "CountryRulerIdGet",
    "$DDBF": "CountryProvinceCount",
}

ABS_INSTR = re.compile(
    r"^(\s*)((?:JSR|JMP|LDA|STA|ADC|AND|BIT|CMP|EOR|LDX|LDY|ORA|SBC|STX|STY"
    r"|INC|DEC|ASL|LSR|ROL|ROR)\s+a?:?)(\$[EFCDAB][0-9A-Fa-f]{3})\b(.*)$")
WORD_DIR = re.compile(r"^(\s*\.word\s+)(\$[EFCDAB][0-9A-Fa-f]{3})\b(.*)$")

with open(PATH) as f:
    lines = f.readlines()

out = []
replaced = 0
inserted = False
for line in lines:
    newline = "\n" if line.endswith("\n") else ""
    body = line[:-1] if newline else line
    if body.strip().startswith("STA a:$001F") and "$DA04" in body \
            and not inserted:
        # inner entry $DA04: caller passes the cursor index cap in A
        out.append("ActionDeltaInputPoll_CapInA:  ; inner entry: cursor index"
                   " cap passed in A\n")
        inserted = True
    m = ABS_INSTR.match(body)
    if m:
        head, operand, rest = m.group(1) + m.group(2), m.group(3), m.group(4)
    else:
        m = WORD_DIR.match(body)
        if m:
            head, operand, rest = m.group(1), m.group(2), m.group(3)
        else:
            head = operand = rest = None
    if operand is not None:
        addr = operand.upper()
        if addr in SYMBOLS:
            body = head + SYMBOLS[addr] + rest
            replaced += 1
    out.append(body + newline)

# refresh the $A018 trampoline comment (target now documented); realign the
# comment column to match neighboring lines (comments start at column 42)
for i, line in enumerate(out):
    if ".word B19_1A_TransferCapacityCalc" in line:
        out[i] = re.sub(
            r"^\s*\.word B19_1A_TransferCapacityCalc\s+;",
            "  .word B19_1A_TransferCapacityCalc      ;",
            line).replace(
            "bank $19 $A018 -> JMP $B8D7, undocumented",
            "bank $19 $A018 -> JMP TransferCapacityCalc")

# expose the inner entry at file scope (ca65 proc scoping; pattern from
# prg_0a_0b.asm: Name = Proc::Inner)
aliased = False
for i, line in enumerate(out):
    if line.rstrip() == ".endproc" and "MathDivideProduct" in out[i + 3]:
        out[i+2:i+2] = [
            "; Inner entry $DA04 (caller provides the cursor index cap in A)\n",
            "ActionDeltaInputPoll_CapInA = "
            "ActionDeltaInputPoll::ActionDeltaInputPoll_CapInA\n",
            "\n",
        ]
        aliased = True
        break
assert aliased, "file-scope alias not inserted"

assert inserted, "inner entry label not inserted"
with open(PATH, "w") as f:
    f.writelines(out)
print(f"replaced {replaced} operand sites, inserted inner-entry label "
      "+ file-scope alias")
