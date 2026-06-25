#!/usr/bin/env python3
"""
LLM 交互式编辑：用自然语言修改设计 JSON，自动重新生成 Verilog + Block Design。

用法:
  # 配置 API
  python scripts/llm_edit.py --config

  # 交互式编辑
  python scripts/llm_edit.py output/design.json -p "将 pc_current 的位宽改为 64"

  # 编辑后自动重新生成
  python scripts/llm_edit.py output/design.json -p "..." --regenerate
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

CONFIG_PATH = Path(__file__).resolve().parent.parent / "opencode_config.json"


def load_config():
    if not CONFIG_PATH.exists():
        return {"llm": {"api_url": "https://api.openai.com/v1", "api_key": "", "model": "gpt-4o"}}
    with open(CONFIG_PATH) as f:
        return json.load(f)


def save_config(cfg):
    CONFIG_PATH.write_text(json.dumps(cfg, indent=2))
    print(f"[OK] 配置已保存到 {CONFIG_PATH}")


def setup_config():
    cfg = load_config()
    llm = cfg.setdefault("llm", {})
    current_url = llm.get("api_url", "https://api.openai.com/v1")
    current_key = llm.get("api_key", "")
    current_model = llm.get("model", "gpt-4o")

    print("=== LLM 配置（直接回车保留当前值） ===")
    url = input(f"API URL [{current_url}]: ").strip() or current_url
    key_hint = current_key[:8] + "..." if current_key else "(空)"
    key = input(f"API Key [{key_hint}]: ").strip() or current_key
    model = input(f"Model [{current_model}]: ").strip() or current_model

    llm["api_url"] = url
    llm["api_key"] = key
    llm["model"] = model
    save_config(cfg)


def call_llm(system_prompt, user_prompt, config):
    """调用 OpenAI 兼容 API 并返回响应文本。"""
    import urllib.request
    import urllib.error

    llm = config.get("llm", {})
    api_url = llm.get("api_url", "").rstrip("/")
    api_key = llm.get("api_key", "")
    model = llm.get("model", "gpt-4o")

    if not api_key:
        print("[ERROR] API Key 未配置，请先运行: python scripts/llm_edit.py --config")
        sys.exit(1)

    endpoint = f"{api_url}/chat/completions" if "v1" in api_url else f"{api_url}/v1/chat/completions"

    payload = json.dumps({
        "model": model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "temperature": 0.1,
    }).encode()

    req = urllib.request.Request(
        endpoint,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            result = json.loads(resp.read())
        return result["choices"][0]["message"]["content"]
    except urllib.error.HTTPError as e:
        print(f"[ERROR] HTTP {e.code}: {e.read().decode()}")
        sys.exit(1)
    except Exception as e:
        print(f"[ERROR] {e}")
        sys.exit(1)


def extract_json(text):
    """从 LLM 回复中提取 JSON 代码块或纯 JSON。"""
    m = re.search(r'```(?:json)?\s*\n(.*?)\n```', text, re.DOTALL)
    if m:
        return m.group(1).strip()
    m = re.search(r'\{.*\}', text, re.DOTALL)
    if m:
        return m.group(0)
    return text.strip()


def main():
    parser = argparse.ArgumentParser(description="LLM 交互式编辑设计 JSON")
    parser.add_argument("input", nargs="?", help="输入的规范 JSON 文件")
    parser.add_argument("-p", "--prompt", help="修改描述（自然语言）")
    parser.add_argument("--config", action="store_true", help="配置 LLM API URL / Key")
    parser.add_argument("--interactive", "-i", action="store_true", help="交互式会话模式")
    parser.add_argument("--regenerate", action="store_true", help="修改后自动重新生成 Verilog 和可视化")
    parser.add_argument("-o", "--output", help="输出 JSON 路径（默认覆盖输入文件）")

    args = parser.parse_args()

    if args.config:
        setup_config()
        return

    if not args.input:
        parser.print_help()
        print("\n请提供输入文件")
        sys.exit(1)

    if args.interactive:
        config = load_config()
        input_path = Path(args.input)
        if not input_path.exists():
            print(f"[ERROR] 文件不存在: {args.input}")
            sys.exit(1)

        design = json.loads(input_path.read_text())
        output_path = Path(args.output) if args.output else input_path

        print("=== LLM 交互式编辑会话 ===")
        print("输入修改描述，或输入 'quit' 退出，'save' 保存，'diff' 查看当前 JSON")
        print("---")

        while True:
            try:
                prompt = input(">>> ").strip()
            except (EOFError, KeyboardInterrupt):
                break
            if not prompt:
                continue
            if prompt.lower() in ("quit", "exit", "q"):
                break
            if prompt.lower() == "save":
                output_path.write_text(json.dumps(design, indent=2))
                print(f"[OK] 已保存到 {output_path}")
                continue
            if prompt.lower() == "diff":
                print(json.dumps(design, indent=2)[:2000])
                continue
            if prompt.lower() == "help":
                print("可用命令: quit/save/diff/help")
                continue

            design_str = json.dumps(design, indent=2)
            system_prompt = """你是一个 Verilog 芯片设计助手。根据用户的修改要求，返回修改后的完整 JSON。
规则：1.只修改用户要求的部分 2.保持 JSON 结构完整 3.返回完整 JSON 放在 ```json ``` 中"""

            print("  [LLM] 处理中...")
            response = call_llm(system_prompt, prompt + "\n\nJSON:\n" + design_str, config)
            json_str = extract_json(response)
            try:
                design = json.loads(json_str)
                print(f"  [OK] 已修改（输入 'save' 保存）")
            except json.JSONDecodeError as e:
                print(f"[ERROR] LLM 返回无效 JSON: {e}")

        output_path.write_text(json.dumps(design, indent=2))
        print(f"[OK] 已保存到 {output_path}")

        if args.regenerate:
            _regenerate(output_path)
        return

    if not args.prompt:
        parser.print_help()
        print("\n请提供修改描述 (-p)，或使用 --interactive 进入交互模式")
        sys.exit(1)

    config = load_config()
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"[ERROR] 文件不存在: {args.input}")
        sys.exit(1)

    design = json.loads(input_path.read_text())
    design_str = json.dumps(design, indent=2)

    system_prompt = """你是一个 Verilog 芯片设计助手。用户的输入是一个符合规范的 Verilog/SystemVerilog 
双向转换 JSON 文件。请根据用户的修改要求，返回修改后的完整 JSON。

规则：
1. 只修改用户要求的部分，保留所有其他内容不变
2. 保持 JSON 结构完整性（不要遗漏字段）
3. 修改端口位宽时同步更新相关信号
4. 修改信号连接时要确保端口名匹配
5. 返回完整的 JSON 对象，放在 ```json ... ``` 代码块中
6. 不要添加注释或解释

JSON 规范关键字段：
- modules[].ports[].width: 端口位宽
- modules[].signals[].width: 信号位宽
- modules[].parameters[].value: 参数值（字符串）
- instances[].port_connections[].connection: 连接表达式（AST 对象）
- always_blocks[].body: 语句列表
"""

    print("  [LLM] 发送修改请求...")
    response = call_llm(system_prompt, args.prompt + "\n\nJSON:\n" + design_str, config)

    json_str = extract_json(response)
    try:
        modified = json.loads(json_str)
    except json.JSONDecodeError as e:
        print(f"[ERROR] LLM 返回了无效的 JSON:\n{e}")
        print("--- LLM 原始回复 ---")
        print(response[:1000])
        sys.exit(1)

    output_path = Path(args.output) if args.output else input_path
    output_path.write_text(json.dumps(modified, indent=2))
    print(f"[OK] 已保存修改后的 JSON: {output_path}")

    if args.regenerate:
        _regenerate(output_path)


def _regenerate(json_path):
    from datetime import datetime
    base = json_path.parent
    proj_root = Path(__file__).resolve().parent.parent
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    stem = f"{json_path.stem}_{ts}"

    gen_v = base / "generated" / f"{stem}.v"
    print(f"  [阶段] 反向生成 Verilog...")
    subprocess.run(
        [sys.executable, str(proj_root / "scripts/generate_from_json.py"),
         str(json_path), "-o", str(gen_v)],
        check=True,
    )

    dot_file = base / "diagrams" / f"{stem}.dot"
    print(f"  [阶段] 生成 Block Design 图表...")
    subprocess.run(
        [sys.executable, str(proj_root / "scripts/visualize_block.py"),
         str(json_path), "--format", "dot", "-o", str(dot_file)],
        check=True,
    )
    print(f"[OK] 完成！Verilog: {gen_v}  图表: {dot_file}")

    # 同时更新 latest 软链接
    latest_v = base / "generated" / f"{json_path.stem}_latest.v"
    latest_dot = base / "diagrams" / f"{json_path.stem}_latest.dot"
    if latest_v.exists() or not latest_v.exists():
        try:
            if latest_v.exists():
                latest_v.unlink()
            latest_v.symlink_to(gen_v.name)
            if latest_dot.exists():
                latest_dot.unlink()
            latest_dot.symlink_to(dot_file.name)
            print(f"  [OK] latest 链接: {latest_v.name} -> {gen_v.name}")
        except OSError:
            pass


if __name__ == "__main__":
    main()
