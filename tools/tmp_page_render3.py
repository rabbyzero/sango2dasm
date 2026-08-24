#!/usr/bin/env python3
"""Render tactical-mode BG pages $8D-$90 (display record 10)."""
import runpy, sys

src = open('tools/tmp_page_render2.py').read()
src = src.replace('(0x16, 0x63, 0x91)', '(0x8D, 0x8E, 0x8F, 0x90)')
exec(src)
