#!/usr/bin/env python3
"""Comprehensive .proc wrapping + branch/sublabel conversion for prg_1f.asm.
Handles all remaining functions from BankPpuInit through the end of file."""

import re

# ============================================================================
# Function definitions: (label_name, is_combined_proc, export)
# Functions are listed in file order. Combined procs group fall-through functions.
# ============================================================================
FUNCTIONS = [
    # Step 7: BankPpuInit through SoundNotePlayer
    ('BankPpuInit', False, False),      # Falls into SoundInit
    ('SoundInit', False, False),        # Falls into WavetableWriteDelay
    ('WavetableWriteDelay', False, False),  # Falls into SoundNotePlayer
    ('SoundNotePlayer', False, False),
    # Data: SoundChannelTable (no wrap)
    # Step 8: SoundWrapper chain
    ('SoundWrapper0', False, False),    # Falls through chain
    ('SoundWrapperA', False, False),
    ('SoundWrapperB', False, False),
    ('SoundWrappersC', False, False),
    # Data: WavetableInitData (no wrap)
    # Step 9: ControllerRead through SpriteBufferInit
    ('ControllerRead', False, False),
    ('PaletteUpload', False, False),
    # PpuMaskHelper and PpuCtrlNmiHelpers already have entry labels
    ('PpuMaskHelper', False, False),
    ('PpuCtrlNmiHelpers', False, False),
    ('NametableFill1', False, False),
    ('NametableFill2', False, False),
    ('SpriteBufferInit', False, False),
    # Step 10: SpriteHide + Randoms
    ('SpriteHide', False, False),
    ('RandomBelow100', False, False),
    ('RandomDiv2', False, False),
    ('RandomModPow2', False, False),
    ('RandomBelowThreshold', False, False),
    ('RandomByte', False, False),
    ('RandomVariants', False, False),
    # Data: RandomTable (no wrap)
    # Step 11: Math library + PaletteAnimation
    ('MathBinToBcd', False, False),
    ('MathDiv16', False, False),
    ('MathDiv24', False, False),
    ('CallbackDispatcher', False, False),
    ('ScrollSet', False, False),
    ('PpuCtrlNametableUpdate', False, False),
    ('WindowReset', False, False),
    ('MathBcdToBin', False, False),
    ('MathExtractUpperNibble', False, False),
    ('MathAccumulate24', False, False),
    ('MathMulDiv100', False, False),
    ('MathMul24x8', False, False),
    ('MathMul24x16', False, False),
    ('PaletteAnimation', False, False),
    # Data at $ECEF-$ED18 (no wrap)
    # Step 12: MenuCursorSystem through GetHeroInitialData
    ('MenuCursorSystem', False, False),
    ('MenuItemLookup', False, False),
    ('PointerTableLookup', False, False),
    ('BankedCallbackTrampoline', False, False),
    ('BankedCallbackReturn', False, False),
    ('NmiSubDispatch', False, False),
    ('PpuBgTileWrite', False, False),
    ('PpuSpriteTileWrite', False, False),
    ('PpuAttrTileWrite', False, False),
    ('PpuAttrTileWriteAlt', False, False),
    ('NamcoSoundRegRead', False, False),
    ('SpriteOamWriterScroll', False, False),
    ('SpriteOamWriterSimple', False, False),
    ('ChrBankSwitch', False, False),
    ('WindowDisplaySetup', False, False),
    ('WindowSetup2', False, False),
    ('WindowSetupHelpers', False, False),
    ('GetHeroAddr', False, False),
    ('GetCityAddr', False, False),
    ('GetHeroKataName', False, False),
    # Data: KataNameWidthTable (no wrap)
    ('GetKingdomAddr', False, False),
    # Data: KingdomPtrTable (no wrap)
    ('GetHeroInitialData', False, False),
    # Step 13: MapperInitCtrlCheck, RamIntegrityTest
    ('MapperInitCtrlCheck', False, False),
    ('RamIntegrityTest', False, False),
    # Data: SoundMusicData, Padding1 (no wrap)
    # Step 14: NmiHandler
    ('NmiHandler', False, True),   # export ::
    # Step 15: PaletteSwap + ControllerReadBankRestore
    ('PaletteSwapA', False, False),
    ('PaletteSwapB', False, False),
    ('NmiScrollMode', False, False),
    ('ControllerReadBankRestore', False, False),
    # Step 16: IrqHandler
    ('IrqHandler', False, True),   # export ::
    # Step 17: ScrollCalc + Vectors
    ('ScrollCalcA', False, False),
    ('ScrollCalcB', False, False),
    # Data: Padding2, Vectors (no wrap)
]

# Data tables / padding that should NOT be wrapped
DATA_LABELS = {
    'BankSwitchTable', 'SoundChannelTable', 'WavetableInitData',
    'RandomTable', 'KataNameWidthTable', 'KingdomPtrTable',
    'SoundMusicData', 'Padding1', 'Padding2',
    'DomesticGraphicPtrs', 'DomesticBaseDataPtrs', 'DomesticSpriteYPos',
    'NmiSubStateTable',
}

# Labels that should stay global (outside any .proc)
GLOBAL_LABELS = {
    'Reset_dispatch_loop', 'VectorTable',
    'NmiCommonExit', 'IrqCommonExit',
    'NmiScrollMode',  # might be referenced from outside
}

# Sub-label patterns: FuncName_sublabel -> @sublabel
# These are label definitions (at start of line)
SUBLABEL_PATTERNS = [
    # NmiHandler sub-states
    (r'NmiSubState_(\w+)', r'@sub_state_\1'),
    # IrqHandler sub-states
    (r'IrqSubState_(\w+)', r'@sub_state_\1'),
    # MenuCursorSystem entries
    (r'MenuCursorSystem_(\w+)', r'@\1'),
]

BRANCH_OPS = r'BCC|BCS|BEQ|BMI|BNE|BPL|BVC|BVS'
BRANCH_HEX_PAT = re.compile(r'((?:' + BRANCH_OPS + r')\s+)(\$[0-9A-Fa-f]{4})(\s+;)')
JMP_HEX_PAT = re.compile(r'(JMP\s+)(\$[0-9A-Fa-f]{4})(\s+;)')


def main():
    filepath = '/home/zero/project/sango2dasm/asm/banks/prg_1f.asm'
    with open(filepath, 'r') as f:
        lines = f.readlines()

    # Build address -> label map from existing labels
    addr_to_label = {}
    for line in lines:
        stripped = line.rstrip('\n')
        # Check for label at start of line (no leading whitespace)
        if stripped and not stripped[0].isspace() and ':' in stripped:
            label = stripped.split(':')[0].strip()
            if label and not label.startswith(';') and not label.startswith('.'):
                # Get address from comment
                m = re.search(r';\s*\$([0-9A-Fa-f]{4}):', stripped)
                if m:
                    addr = '$' + m.group(1).upper()
                    addr_to_label[addr] = label
        # Also check inline labels (on their own line)
        if stripped and not stripped[0].isspace() and stripped.endswith(':') and not any(op in stripped.upper() for op in ['LDA','STA','JSR','JMP','BNE','BEQ']):
            label = stripped[:-1].strip()
            if label:
                # Look at next line for address
                idx = lines.index(line)
                if idx + 1 < len(lines):
                    next_line = lines[idx + 1].rstrip('\n')
                    m = re.search(r';\s*\$([0-9A-Fa-f]{4}):', next_line)
                    if m:
                        addr = '$' + m.group(1).upper()
                        addr_to_label[addr] = label

    # Also map addresses from instruction comments
    # (for labels that ARE the instruction at that address)
    for i, line in enumerate(lines):
        stripped = line.rstrip('\n')
        if not stripped or stripped[0].isspace() or stripped.startswith(';'):
            continue
        if stripped.endswith(':') and not any(op in stripped.upper() for op in ['LDA','STA','JSR','JMP','BNE','BEQ','INC','DEC']):
            label = stripped[:-1].strip()
            # Check next non-empty line for address
            for j in range(i+1, min(i+3, len(lines))):
                m = re.search(r';\s*\$([0-9A-Fa-f]{4}):', lines[j])
                if m:
                    addr = '$' + m.group(1).upper()
                    if addr not in addr_to_label:
                        addr_to_label[addr] = label
                    break

    # Build function set for quick lookup
    func_names = {f[0] for f in FUNCTIONS}

    # Process lines
    new_lines = []
    current_proc = None
    in_existing_proc = False
    func_set = set()
    proc_count = 0

    for i, line in enumerate(lines):
        stripped = line.rstrip('\n')

        # Track existing .proc/.endproc
        if re.match(r'\.proc\s+', stripped):
            in_existing_proc = True
            current_proc = re.match(r'\.proc\s+(\w+)', stripped).group(1)
            new_lines.append(line)
            continue
        if stripped.strip() == '.endproc':
            in_existing_proc = False
            current_proc = None
            new_lines.append(line)
            continue

        # Check if this line starts a function that needs wrapping
        if not in_existing_proc and stripped and not stripped[0].isspace():
            label = stripped.split(':')[0].strip() if ':' in stripped else stripped.strip()
            if label in func_names and label not in func_set:
                func_set.add(label)
                func_info = next(f for f in FUNCTIONS if f[0] == label)
                _, _, export = func_info

                # Add .proc before this line
                if export:
                    new_lines.append(f'.proc {label}::\n')
                else:
                    new_lines.append(f'.proc {label}\n')
                current_proc = label
                proc_count += 1

                # Add the original line
                new_lines.append(line)

                # Check if next function starts right after this one's end
                # (we'll add .endproc when we detect the next function or data)
                continue

        # Check if we need to add .endproc (when we hit a non-function label or data)
        if current_proc and not in_existing_proc and stripped and not stripped[0].isspace():
            label = stripped.split(':')[0].strip() if ':' in stripped else stripped.strip()
            # If this is a data table or a different function, close current proc
            if label in DATA_LABELS or (label in func_names and label not in func_set):
                new_lines.append('.endproc\n')
                new_lines.append('\n')
                current_proc = None

        # Convert sub-labels to @labels (inside any proc)
        result = stripped
        if current_proc or in_existing_proc:
            # Convert FuncName_sublabel: to @sublabel:
            for pattern, replacement in SUBLABEL_PATTERNS:
                result = re.sub(r'^' + pattern + r':', replacement + ':', result)
                # Also convert references in branch operands
                def sublabel_ref_repl(m):
                    full = m.group(0)
                    return re.sub(pattern, replacement, full)
                result = re.sub(r'\b' + pattern + r'\b', sublabel_ref_repl, result)

            # Convert branch hex targets to labels
            def branch_repl(m):
                prefix = m.group(1)
                addr = m.group(2).upper()
                suffix = m.group(3)
                if addr in addr_to_label:
                    target = addr_to_label[addr]
                    # Use @label if it's within the same proc
                    if target.startswith('@'):
                        return f'{prefix}{target:<24s}{suffix}'
                    # Use the existing label name
                    return f'{prefix}{target:<24s}{suffix}'
                return m.group(0)
            result = BRANCH_HEX_PAT.sub(branch_repl, result)

            # Convert JMP hex targets to labels (intra-proc only)
            def jmp_repl(m):
                prefix = m.group(1)
                addr = m.group(2).upper()
                suffix = m.group(3)
                if addr in addr_to_label:
                    target = addr_to_label[addr]
                    return f'{prefix}{target:<24s}{suffix}'
                return m.group(0)
            result = JMP_HEX_PAT.sub(jmp_repl, result)

        new_lines.append(result + '\n')

    # Close any remaining open proc
    if current_proc and not in_existing_proc:
        new_lines.append('.endproc\n')

    with open(filepath, 'w') as f:
        f.writelines(new_lines)

    print(f"Procs added: {proc_count}")
    print(f"Total lines: {len(new_lines)}")
    print(f"Address->label map size: {len(addr_to_label)}")

    # Count remaining branch hex targets
    remaining_branches = 0
    with open(filepath, 'r') as f:
        for lineno, line in enumerate(f, 1):
            if BRANCH_HEX_PAT.search(line):
                remaining_branches += 1
                if remaining_branches <= 5:
                    print(f"  Remaining branch at line {lineno}: {line.rstrip()}")
    print(f"Remaining branch hex targets: {remaining_branches}")


if __name__ == '__main__':
    main()
