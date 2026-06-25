#!/usr/bin/env python3
"""
设计差异比较工具：对比两个规范 JSON 及其生成的 Verilog。

用法:
  # 比较两个 JSON
  python scripts/diff_design.py output/design.json output/design_modified.json

  # 比较两个 Verilog
  python scripts/diff_design.py output/generated/design_latest.v output/generated/design_20260625_120000.v

  # 自动检测 JSON 和对应的 generated Verilog
  python scripts/diff_design.py output/design.json --auto
"""

import argparse
import difflib
import json
import os
import sys
from pathlib import Path


def diff_module(mod_a, mod_b, name="?"):
    changes = []
    for key in ("parameters", "ports", "signals", "instances",
                "always_blocks", "assignments", "functions", "tasks", "generates"):
        a_list = mod_a.get(key, []) or []
        b_list = mod_b.get(key, []) or []
        a_names = sorted(_names(a_list))
        b_names = sorted(_names(b_list))
        if a_names != b_names:
            added = set(b_names) - set(a_names)
            removed = set(a_names) - set(b_names)
            if added:
                changes.append(f"  + {key}: {sorted(added)}")
            if removed:
                changes.append(f"  - {key}: {sorted(removed)}")

        detail = _diff_item_list(a_list, b_list, key)
        changes.extend(detail)

    return changes


def _names(items):
    result = []
    for item in items:
        if isinstance(item, dict):
            result.append(item.get("name", json.dumps(item)))
        else:
            result.append(str(item))
    return result


def _item_key(item):
    if isinstance(item, dict):
        return item.get("name", item.get("id", item.get("port", "")))
    return str(item)


def _diff_item_list(old_list, new_list, label):
    if not old_list and not new_list:
        return []
    changes = []
    old_by_key = {_item_key(i): i for i in old_list}
    new_by_key = {_item_key(i): i for i in new_list}
    all_keys = set(old_by_key) | set(new_by_key)

    for k in sorted(all_keys):
        if k in old_by_key and k in new_by_key:
            item_changes = _diff_item(old_by_key[k], new_by_key[k], k, label)
            changes.extend(item_changes)
    return changes


_DIFF_FIELDS = {
    "ports": ["direction", "data_type", "width", "signed"],
    "signals": ["type", "width", "signed", "initial_value"],
    "parameters": ["type", "data_type", "value"],
    "instances": ["module"],
}


def _diff_item(old, new, name, label):
    changes = []
    fields = _DIFF_FIELDS.get(label, [])
    for f in fields:
        a = old.get(f) if isinstance(old, dict) else None
        b = new.get(f) if isinstance(new, dict) else None
        if a != b:
            changes.append(f"    ~ {label} '{name}'.{f}: {a} -> {b}")
    return changes


def diff_verilog(file_a, file_b):
    file_a, file_b = str(file_a), str(file_b)
    a_lines = Path(file_a).read_text().splitlines(keepends=True)
    b_lines = Path(file_b).read_text().splitlines(keepends=True)
    diff = difflib.unified_diff(
        a_lines, b_lines,
        fromfile=file_a, tofile=file_b,
        n=2,
    )
    return "".join(diff)


def format_json_diff(changes):
    if not changes:
        return "  (无变化)"
    return "\n".join(changes)


def main():
    parser = argparse.ArgumentParser(description="设计差异比较工具")
    parser.add_argument("file_a", help="原始文件 (JSON 或 Verilog)")
    parser.add_argument("file_b", help="修改后文件 (JSON 或 Verilog)")
    parser.add_argument("--auto", action="store_true",
                        help="自动模式：给定 JSON 自动找对应的 generated Verilog 比较")
    parser.add_argument("--verilog", "-v", action="store_true",
                        help="强制按 Verilog 模式比较")
    parser.add_argument("--json", "-j", action="store_true",
                        help="强制按 JSON 模式比较")
    args = parser.parse_args()

    fa, fb = Path(args.file_a), Path(args.file_b)

    if not fa.exists():
        print(f"[ERROR] 文件不存在: {fa}")
        sys.exit(1)
    if not fb.exists():
        print(f"[ERROR] 文件不存在: {fb}")
        sys.exit(1)

    is_json = args.json or (not args.verilog and fa.suffix == ".json")
    is_verilog = args.verilog or (not args.json and fa.suffix in (".v", ".sv"))

    print("=" * 60)
    print(f"比较: {fa.name}  ↔  {fb.name}")
    print("=" * 60)

    if is_json:
        da = json.loads(fa.read_text())
        db = json.loads(fb.read_text())

        print(f"\n--- 顶层元数据 ---")
        ma = da.get("metadata", {})
        mb = db.get("metadata", {})
        if ma.get("generated_at") != mb.get("generated_at"):
            print(f"  generated_at: {ma.get('generated_at')} -> {mb.get('generated_at')}")
        if ma.get("source_files") != mb.get("source_files"):
            print(f"  source_files 变化")

        print(f"\n--- defines ---")
        def_a = {(d["name"], d["value"]) for d in da.get("defines", [])}
        def_b = {(d["name"], d["value"]) for d in db.get("defines", [])}
        if def_a != def_b:
            print(f"  + {def_b - def_a}" if def_b - def_a else "", end="")
            print(f"  - {def_a - def_b}" if def_a - def_b else "")

        modules_a = {m["name"]: m for m in da.get("modules", [])}
        modules_b = {m["name"]: m for m in db.get("modules", [])}
        all_mods = set(modules_a) | set(modules_b)

        for mname in sorted(all_mods):
            if mname not in modules_a:
                print(f"\n  [+] 新增模块: {mname}")
                continue
            if mname not in modules_b:
                print(f"\n  [-] 删除模块: {mname}")
                continue
            print(f"\n--- 模块: {mname} ---")
            ch = diff_module(modules_a[mname], modules_b[mname], mname)
            print(format_json_diff(ch))

    if is_verilog:
        print(f"\n--- Verilog 差异 ---")
        result = diff_verilog(fa, fb)
        if result:
            print(result)
        else:
            print("  (完全相同)")

    if args.auto:
        json_path = fa if fa.suffix == ".json" else fb
        base = json_path.parent
        stem = json_path.stem

        gen_dir = base / "generated"
        v_files = sorted(gen_dir.glob(f"{stem}_*.v")) if gen_dir.exists() else []
        if v_files:
            print(f"\n--- 生成的 Verilog 文件 ---")
            for vf in v_files:
                print(f"  {vf.name}")
            if len(v_files) >= 2:
                print(f"\n--- 最新两个 Verilog 差异 ---")
                print(diff_verilog(v_files[-2], v_files[-1]))


if __name__ == "__main__":
    main()
