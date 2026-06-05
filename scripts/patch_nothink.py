#!/usr/bin/env python3
"""
patch_nothink.py — Disable thinking in a Qwen3/3.5 GGUF chat template.

Patches the embedded Jinja2 chat template in-place to output an empty
<think></think> block instead of starting a reasoning chain. This makes
responses instant (no 15-30s thinking delay) while keeping full model
intelligence.

Usage:
    python3 patch_nothink.py <path_to_model.gguf>

The original file is backed up as <model>.backup_original on first run.
"""

import sys
import struct
import shutil
import os

OLD_BLOCK = (
    '{%- if enable_thinking is defined and enable_thinking is false %}\n'
    "        {{- '<think>\\n\\n</think>\\n\\n' }}\n"
    '    {%- else %}\n'
    "        {{- '<think>\\n' }}\n"
    '    {%- endif %}'
)
NEW_BLOCK = "{{- '<think>\\n\\n</think>\\n\\n' }}"


def patch_gguf(model_path: str) -> bool:
    backup_path = model_path + '.backup_original'

    # Backup on first run
    if not os.path.exists(backup_path):
        print(f"  Backing up to {os.path.basename(backup_path)}...")
        shutil.copy2(model_path, backup_path)

    with open(model_path, 'rb') as f:
        data = bytearray(f.read())

    file_size = len(data)
    old_bytes = OLD_BLOCK.encode('utf-8')
    new_bytes = NEW_BLOCK.encode('utf-8')

    pos = data.find(old_bytes)
    if pos == -1:
        # Check if already patched
        if data.find(NEW_BLOCK.encode('utf-8')) != -1:
            print("  Already patched — thinking is already disabled.")
            return True
        print("  ERROR: Could not find thinking block in template.")
        print("  This model may use a different template format.")
        return False

    diff = len(old_bytes) - len(new_bytes)
    # Pad with trailing spaces to keep exact same byte length
    padded = new_bytes + b' ' * diff

    data[pos:pos + len(old_bytes)] = padded

    assert len(data) == file_size, "File size changed — aborting!"

    with open(model_path, 'wb') as f:
        f.write(data)

    print(f"  Patched: thinking disabled ({diff} bytes freed, padded to same size)")
    return True


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <path_to_model.gguf>")
        sys.exit(1)

    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"ERROR: File not found: {path}")
        sys.exit(1)

    print(f"Patching: {os.path.basename(path)}")
    success = patch_gguf(path)
    sys.exit(0 if success else 1)
