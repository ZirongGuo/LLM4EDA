#!/usr/bin/env python3
"""
工作流执行器：严格遵循 workflow_generate_json.md 的 5 阶段流程，
通过外部 LLM API (DeepSeek) 对校验失败的 JSON 进行增量外科手术式修复。

核心原则:
  - 绝对信任本地校验器 check_json_spec.py
  - 最小代价修正：严禁因局部错误全量重新生成
  - 上下文解耦：利用芯片层次化结构拆分任务
"""

import json
import os
import re
import sys
import copy
import urllib.error
import urllib.request
from pathlib import Path

# ---------------------------------------------------------------------------
# 配置常量
# ---------------------------------------------------------------------------
PROJ_ROOT = Path(__file__).resolve().parent.parent
CONFIG_PATH = PROJ_ROOT / "opencode_config.json"
SCHEMA_PATH = PROJ_ROOT / "specs" / "schema_v1.json"
LLM_CACHE_DIR = PROJ_ROOT / "output" / ".llm_cache"
MAX_RETRIES_PER_MODULE = 3


def load_config():
    with open(CONFIG_PATH) as f:
        return json.load(f)


def load_schema():
    with open(SCHEMA_PATH) as f:
        return json.load(f)


# ---------------------------------------------------------------------------
# LLM API 调用
# ---------------------------------------------------------------------------

def call_llm(system_prompt: str, user_prompt: str, config: dict, temperature: float = 0.1) -> str:
    llm = config.get("llm", {})
    api_url = llm.get("api_url", "").rstrip("/")
    api_key = llm.get("api_key", "")
    model = llm.get("model", "deepseek-v4-flash")

    endpoint = f"{api_url}/v1/chat/completions"

    payload = json.dumps({
        "model": model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "temperature": temperature,
    }).encode()

    req = urllib.request.Request(endpoint, data=payload, headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }, method="POST")

    print(f"  [LLM] 调用 {model} ...", end=" ", flush=True)
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            result = json.loads(resp.read())
            content = result["choices"][0]["message"]["content"]
            print(f"OK ({len(content)} chars)")

            # 保存 LLM 原始回复到缓存目录
            _save_llm_cache(system_prompt, user_prompt, content, result)

            return content
    except urllib.error.HTTPError as e:
        err_body = e.read().decode()[:500]
        print(f"FAIL HTTP {e.code}: {err_body}")
        return ""
    except Exception as e:
        print(f"FAIL: {e}")
        return ""


def _save_llm_cache(system_prompt: str, user_prompt: str, response: str, raw_result: dict):
    """将 LLM 请求/响应保存到 output/.llm_cache/ 用于调试和审计。"""
    import time as _time
    LLM_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    ts = _time.strftime("%Y%m%d_%H%M%S")
    cache_file = LLM_CACHE_DIR / f"llm_{ts}.json"
    cache_data = {
        "timestamp": ts,
        "model": raw_result.get("model", ""),
        "system_prompt": system_prompt[:500],
        "user_prompt": user_prompt[:500],
        "response": response,
        "usage": raw_result.get("usage", {}),
    }
    cache_file.write_text(json.dumps(cache_data, indent=2, ensure_ascii=False))
    print(f"    [Cache] 已保存 LLM 回复 -> {cache_file}")


# ---------------------------------------------------------------------------
# 从 LLM 回复中提取 JSON
# ---------------------------------------------------------------------------

def extract_json(text: str):
    """从 LLM 回复中鲁棒提取 JSON 对象。"""
    raw = text.strip()
    m = re.search(r'```(?:json)?\s*\n(.+?)\n```', raw, re.DOTALL)
    if m:
        raw = m.group(1).strip()
    brace_start = raw.find("{")
    if brace_start < 0:
        return None
    depth = 0
    for i in range(brace_start, len(raw)):
        if raw[i] == "{":
            depth += 1
        elif raw[i] == "}":
            depth -= 1
            if depth == 0:
                raw = raw[brace_start:i + 1]
                break
    raw = re.sub(r',\s*}', "}", raw)
    raw = re.sub(r',\s*]', "]", raw)
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        pass
    raw = re.sub(r'(?<=[{,])\s*(\w+)\s*:', r'"\1":', raw)
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        print(f"[WARN] 无法解析 LLM 回复为 JSON: {text[:300]}")
        return None


# ---------------------------------------------------------------------------
# 阶段二：运行校验器，收集结构化错误
# ---------------------------------------------------------------------------

def run_validator(json_path: str) -> dict:
    with open(json_path) as f:
        design = json.load(f)

    errors = []
    schema = load_schema()

    # Layer 1: JSON Schema 校验
    try:
        from jsonschema import validate
        validate(design, schema)
    except Exception as e:
        errors.append({
            "layer": 1,
            "category": "A",
            "message": str(e),
        })

    # Layer 2: Body 校验
    sys.path.insert(0, str(PROJ_ROOT / "scripts"))
    from check_json_spec import validate_bodies, validate_semantic_rules

    try:
        if not validate_bodies(design):
            errors.append({"layer": 2, "category": "B", "message": "Invalid body statements"})
    except Exception as e:
        errors.append({"layer": 2, "category": "B", "message": str(e)})

    # Layer 3: 语义校验（详细诊断）
    modules = design.get("modules", [])
    module_names = set(m.get("name") for m in modules if isinstance(m, dict))

    for mi, mod in enumerate(modules):
        if not isinstance(mod, dict):
            continue
        mname = mod.get("name", f"[{mi}]")

        # B003: 实例引用未解析
        for inst in mod.get("instances", []):
            if isinstance(inst, dict):
                ref_mod = inst.get("module")
                if isinstance(ref_mod, str) and ref_mod not in module_names:
                    errors.append({
                        "layer": 3, "category": "B", "rule": "B003",
                        "module": mname, "module_idx": mi,
                        "message": f"Instance '{inst.get('name')}' references unresolved module '{ref_mod}'",
                    })

        # B004: 端口连接计数不匹配
        for inst in mod.get("instances", []):
            if isinstance(inst, dict):
                ref_mod = inst.get("module")
                conns = inst.get("port_connections", [])
                if isinstance(ref_mod, str) and ref_mod in module_names:
                    target_ports = 0
                    for m in modules:
                        if m.get("name") == ref_mod:
                            target_ports = len(m.get("ports", []))
                            break
                    if len(conns) != target_ports:
                        errors.append({
                            "layer": 3, "category": "C", "rule": "B004",
                            "module": mname, "module_idx": mi,
                            "target_module": ref_mod,
                            "message": f"Instance '{inst.get('name')}' has {len(conns)} connections, target '{ref_mod}' has {target_ports} ports",
                        })

        # B007: 重复实例名
        inst_names = [i.get("name") for i in mod.get("instances", []) if isinstance(i, dict) and i.get("name")]
        dupes = {n for n in inst_names if inst_names.count(n) > 1}
        if dupes:
            errors.append({
                "layer": 3, "category": "B", "rule": "B007",
                "module": mname, "module_idx": mi,
                "message": f"Duplicate instance names: {dupes}",
            })

        # B009: 输入端口被驱动
        ports_by_name = {p.get("name"): p for p in mod.get("ports", []) if isinstance(p, dict)}
        driven = set()
        for a in mod.get("assignments", []):
            lhs = a.get("lhs", {})
            if isinstance(lhs, dict) and "ref" in lhs:
                driven.add(lhs["ref"])
        for blk in mod.get("always_blocks", []):
            for s in blk.get("body", []):
                if isinstance(s, dict) and s.get("type") == "assignment":
                    lhs = s.get("lhs", {})
                    if isinstance(lhs, dict) and "ref" in lhs:
                        driven.add(lhs["ref"])
        for sig in driven:
            if sig in ports_by_name and ports_by_name[sig].get("direction") == "input":
                errors.append({
                    "layer": 3, "category": "B", "rule": "B009",
                    "module": mname, "module_idx": mi,
                    "message": f"Input port '{sig}' is being driven",
                })

        # B011: 函数缺少 return
        for func in mod.get("functions", []):
            if isinstance(func, dict):
                if not _has_return(func.get("body", [])):
                    errors.append({
                        "layer": 3, "category": "B", "rule": "B011",
                        "module": mname, "module_idx": mi,
                        "message": f"Function '{func.get('name')}' has no return statement",
                    })

    if not errors:
        return {"passed": True, "errors": []}
    return {"passed": False, "errors": errors}


def _has_return(body):
    if not isinstance(body, list):
        return False
    for stmt in body:
        if not isinstance(stmt, dict):
            continue
        if stmt.get("type") == "return":
            return True
        for k in ("then", "else", "body"):
            sub = stmt.get(k)
            if isinstance(sub, list) and _has_return(sub):
                return True
    return False


# ---------------------------------------------------------------------------
# 阶段三：错误分类
# 阶段四：规则修复（零成本） vs LLM 修复
# ---------------------------------------------------------------------------

def try_rule_fix(design: dict, error: dict) -> bool:
    """对已知模式直接用规则修复，返回 True 表示已修复。"""
    err_rule = error.get("rule", "")
    err_msg = error.get("message", "")
    err_module = error.get("module", "")
    modules = design.get("modules", [])
    module_names = set(m.get("name") for m in modules if isinstance(m, dict))

    # Layer 1: 缺失 blocking 字段
    if error.get("layer") == 1 and "blocking" in err_msg:
        for mod in modules:
            for a in mod.get("assignments", []):
                if isinstance(a, dict) and "blocking" not in a:
                    a["blocking"] = False
        return True

    # Layer 1: delay 为 null -> 删除 delay 键
    if error.get("layer") == 1 and "delay" in err_msg and "None" in err_msg:
        for mod in modules:
            for a in mod.get("assignments", []):
                if a.get("delay") is None:
                    del a["delay"]
        return True

    # B003: 未解析模块引用 -> 从实例连接推断缺失模块
    if err_rule == "B003":
        m = re.search(r"references unresolved module '(\w+)'", err_msg)
        if m:
            missing_mod = m.group(1)
            target_ports = []
            for mod in modules:
                for inst in mod.get("instances", []):
                    if inst.get("module") == missing_mod:
                        for conn in inst.get("port_connections", []):
                            pname = conn.get("port")
                            if pname and pname not in [p["name"] for p in target_ports]:
                                direction = "output" if pname.endswith("_o") or pname.lower().endswith("o") else "input"
                                target_ports.append({
                                    "name": pname, "direction": direction,
                                    "data_type": "wire", "width": 1, "signed": False,
                                })
            if target_ports:
                modules.insert(0, {
                    "name": missing_mod,
                    "parameters": [],
                    "ports": target_ports,
                    "signals": [],
                })
                return True

    # B004: 端口计数不匹配 -> 裁剪多余连接
    if err_rule == "B004":
        m = re.search(r"Instance '(\w+)'.*target '(\w+)'.*has (\d+) ports", err_msg)
        if m:
            inst_name = m.group(1)
            target_mod = m.group(2)
            for mod in modules:
                if mod.get("name") == err_module:
                    for inst in mod.get("instances", []):
                        if inst.get("name") == inst_name:
                            # 获取目标模块端口名
                            target_port_names = set()
                            for tm in modules:
                                if tm.get("name") == target_mod:
                                    target_port_names = set(p.get("name") for p in tm.get("ports", []))
                                    break
                            if target_port_names:
                                orig = len(inst.get("port_connections", []))
                                inst["port_connections"] = [
                                    c for c in inst.get("port_connections", [])
                                    if c.get("port") in target_port_names
                                ]
                                return orig != len(inst.get("port_connections", []))
                    break

    # B007: 重复实例 -> 去重
    if err_rule == "B007":
        for mod in modules:
            if mod.get("name") == err_module:
                seen = set()
                unique = []
                for inst in mod.get("instances", []):
                    name = inst.get("name")
                    if name and name in seen:
                        continue
                    if name:
                        seen.add(name)
                    unique.append(inst)
                mod["instances"] = unique
                return True

    # B009: 输入端口被驱动 -> 移除赋值
    if err_rule == "B009":
        m = re.search(r"Input port '(\w+)'", err_msg)
        if m:
            port_name = m.group(1)
            for mod in modules:
                if mod.get("name") == err_module:
                    mod["assignments"] = [
                        a for a in mod.get("assignments", [])
                        if not (isinstance(a.get("lhs"), dict) and a["lhs"].get("ref") == port_name)
                    ]
                    return True

    # B011: 函数缺少 return -> 插入 return 语句
    if err_rule == "B011":
        m = re.search(r"Function '(\w+)'", err_msg)
        if m:
            func_name = m.group(1)
            for mod in modules:
                if mod.get("name") == err_module:
                    for func in mod.get("functions", []):
                        if func.get("name") == func_name:
                            ret_stmt = {"type": "return", "value": {"literal": "0"}}
                            func.setdefault("body", []).insert(0, ret_stmt)
                            return True

    return False


# ---------------------------------------------------------------------------
# LLM 修复
# ---------------------------------------------------------------------------

def build_fix_prompt(design: dict, error: dict, schema: dict) -> tuple:
    schema_str = json.dumps(schema, indent=2)
    system_prompt = f"""你是一个 Verilog 芯片设计 JSON 修复专家。对设计 JSON 进行最小代价外科手术式修复。

## JSON Schema
```json
{schema_str}
```

## 输出格式（必须严格遵守）
返回一个 JSON 对象：
- 用 "patch" key 返回 JSON Patch 数组: {{"patch":[{{"op":"replace","path":"modules[0].assignments[0].blocking","value":false}}]}}
- 或用 "module" key 返回修复后的完整模块对象（用于替换整个模块）

## 关键约束
- 只返回 JSON，不要文字说明
- 端口: name, direction, data_type, width, signed
- 信号: name, type, width, signed
- 实例: name, module, parameter_mapping, port_connections
- 一元运算符使用 "operand" 而非 "left"/"right"
- 表达式使用 AST 对象格式
"""

    error_module = error.get("module", "")
    fragment = {}
    for mod in design.get("modules", []):
        if mod.get("name") == error_module:
            fragment["target_module"] = mod
            parent_ctx = []
            for pm in design.get("modules", []):
                for inst in pm.get("instances", []):
                    if inst.get("module") == error_module:
                        parent_ctx.append({
                            "parent": pm.get("name"),
                            "instance": inst.get("name"),
                            "connections": [c.get("port") for c in inst.get("port_connections", [])],
                        })
            if parent_ctx:
                fragment["parent_interfaces"] = parent_ctx
            break

    user_prompt = f"""## 校验错误
{json.dumps(error, indent=2, ensure_ascii=False)}

## 出错模块上下文
```json
{json.dumps(fragment, indent=2, ensure_ascii=False)}
```

## 指令
只返回修复后的 patch 或 module JSON。不要包含其他模块。"""

    return system_prompt, user_prompt


def apply_llm_fix(design: dict, error: dict, llm_response: str) -> bool:
    """应用 LLM 返回的修复。返回 True 表示有变更。"""
    instructions = extract_json(llm_response)
    if not instructions:
        return False

    changed = False
    modules = design.get("modules", [])
    err_module = error.get("module", "")

    # 方式1: JSON Patch (支持 JSON Pointer 和 dot-bracket 两种格式)
    if "patch" in instructions:
        patches = instructions["patch"]
        if isinstance(patches, dict):
            patches = [patches]
        for patch in patches:
            op = patch.get("op")
            path = patch.get("path", "")
            value = patch.get("value")

            # 解析路径：支持 JSON Pointer (/modules/0/ports/0/direction) 和 dot-bracket (modules[0].ports[0].direction)
            segments = _parse_path(path)
            if not segments:
                continue

            obj = design
            for i, (key, idx) in enumerate(segments):
                if i == len(segments) - 1:
                    # 最终段：应用操作
                    if op == "replace":
                        if idx is not None and isinstance(obj, list):
                            obj[idx] = value
                        elif isinstance(obj, dict):
                            obj[key] = value
                        changed = True
                    elif op == "add":
                        if idx is not None and isinstance(obj, list):
                            obj.insert(idx, value)
                        elif isinstance(obj, dict):
                            if isinstance(obj.get(key), list):
                                obj[key].append(value)
                            else:
                                obj[key] = value
                        changed = True
                    elif op == "remove":
                        if idx is not None and isinstance(obj, list):
                            obj.pop(idx)
                        elif isinstance(obj, dict) and key in obj:
                            del obj[key]
                        changed = True
                else:
                    # 导航到下一层
                    if idx is not None:
                        if isinstance(obj, dict) and key in obj:
                            obj = obj[key]
                        if isinstance(obj, list):
                            if 0 <= idx < len(obj):
                                obj = obj[idx]
                            else:
                                break
                    else:
                        if isinstance(obj, dict) and key in obj:
                            obj = obj[key]
                        else:
                            break

        print(f"    [LLM-Patch] 应用了 {len(patches)} 个 patch")
        return changed

    # 方式2: 完整模块替换
    if "module" in instructions and err_module:
        new_mod = instructions["module"]
        if isinstance(new_mod, dict):
            for i, mod in enumerate(modules):
                if mod.get("name") == err_module:
                    deep_merge(mod, new_mod)
                    changed = True
                    print(f"    [LLM-Module] 合并修复了模块 '{err_module}'")
                    break
        return changed

    # 方式3: LLM 直接返回了新的模块定义（B003 场景）
    if err_module and isinstance(instructions, dict) and "name" in instructions and "ports" in instructions:
        if instructions["name"] not in [m.get("name") for m in modules]:
            modules.insert(0, instructions)
            print(f"    [LLM-Module] 添加了缺失模块 '{instructions['name']}'")
            return True

    print(f"    [LLM] 无法解析回复格式: {list(instructions.keys())[:5]}")
    return False


def _parse_path(path: str) -> list:
    """解析路径字符串，返回 [(key, idx), ...] 列表。idx 为 None 表示非数组访问。
    支持两种格式:
      - JSON Pointer: /modules/0/ports/0/direction
      - Dot-bracket:   modules[0].ports[0].direction
    """
    segments = []
    path = path.strip()

    if path.startswith("/"):
        # JSON Pointer 格式: /modules/0/ports/val
        parts = path.split("/")[1:]  # 跳过第一个空串
        for part in parts:
            if part == "":
                continue
            # 尝试整数索引
            try:
                idx = int(part)
                segments.append((part, idx))
            except ValueError:
                # 转义 ~1 -> /, ~0 -> ~
                part = part.replace("~1", "/").replace("~0", "~")
                segments.append((part, None))
    else:
        # Dot-bracket 格式: modules[0].ports[0].direction
        tokens = re.findall(r'(\w+)(?:\[(\d+|)\])?(?:\.|$)', path)
        for key, idx_str in tokens:
            idx = int(idx_str) if idx_str else None
            segments.append((key, idx))

    return segments

    # 方式2: 完整模块替换
    if "module" in instructions and err_module:
        new_mod = instructions["module"]
        if isinstance(new_mod, dict):
            for i, mod in enumerate(modules):
                if mod.get("name") == err_module:
                    deep_merge(mod, new_mod)
                    changed = True
                    print(f"    [LLM-Module] 合并修复了模块 '{err_module}'")
                    break
        return changed

    # 方式3: LLM 直接返回了新的模块定义（B003 场景）
    if err_module and isinstance(instructions, dict) and "name" in instructions and "ports" in instructions:
        if instructions["name"] not in [m.get("name") for m in modules]:
            modules.insert(0, instructions)
            print(f"    [LLM-Module] 添加了缺失模块 '{instructions['name']}'")
            return True

    print(f"    [LLM] 无法解析 LLM 回复格式: {list(instructions.keys())[:5]}")
    return False


def deep_merge(base: dict, update: dict):
    for key, val in update.items():
        if key not in base:
            base[key] = val
        elif isinstance(val, dict) and isinstance(base.get(key), dict):
            deep_merge(base[key], val)
        elif isinstance(val, list) and isinstance(base.get(key), list):
            for item in val:
                if not isinstance(item, dict):
                    base[key].append(item)
                    continue
                matched = False
                for nk in ("name", "id"):
                    if nk in item:
                        for bi in base[key]:
                            if isinstance(bi, dict) and bi.get(nk) == item[nk]:
                                deep_merge(bi, item)
                                matched = True
                                break
                        if matched:
                            break
                if not matched:
                    base[key].append(item)
        else:
            base[key] = val


# ---------------------------------------------------------------------------
# 预校验工具：在内存中校验设计字典（不读写文件）
# ---------------------------------------------------------------------------

def run_validator_on_dict(design: dict) -> dict:
    """与 run_validator 逻辑相同，但直接接受 design dict。"""
    errors = []
    schema = load_schema()

    # Layer 1
    try:
        from jsonschema import validate
        validate(design, schema)
    except Exception as e:
        errors.append({
            "layer": 1, "category": "A",
            "message": str(e),
        })

    # Layer 2
    sys.path.insert(0, str(PROJ_ROOT / "scripts"))
    from check_json_spec import validate_bodies

    try:
        if not validate_bodies(design):
            errors.append({"layer": 2, "category": "B", "message": "Invalid body statements"})
    except Exception as e:
        errors.append({"layer": 2, "category": "B", "message": str(e)})

    # Layer 3: 语义校验
    modules = design.get("modules", [])
    module_names = set(m.get("name") for m in modules if isinstance(m, dict))

    for mi, mod in enumerate(modules):
        if not isinstance(mod, dict):
            continue
        mname = mod.get("name", f"[{mi}]")

        for inst in mod.get("instances", []):
            if isinstance(inst, dict):
                ref_mod = inst.get("module")
                if isinstance(ref_mod, str) and ref_mod not in module_names:
                    errors.append({
                        "layer": 3, "category": "B", "rule": "B003",
                        "module": mname, "module_idx": mi,
                        "message": f"Instance '{inst.get('name')}' references unresolved module '{ref_mod}'",
                    })

        for inst in mod.get("instances", []):
            if isinstance(inst, dict):
                ref_mod = inst.get("module")
                conns = inst.get("port_connections", [])
                if isinstance(ref_mod, str) and ref_mod in module_names:
                    target_ports = 0
                    for m in modules:
                        if m.get("name") == ref_mod:
                            target_ports = len(m.get("ports", []))
                            break
                    if len(conns) != target_ports:
                        errors.append({
                            "layer": 3, "category": "C", "rule": "B004",
                            "module": mname, "module_idx": mi,
                            "target_module": ref_mod,
                            "message": f"Instance '{inst.get('name')}' has {len(conns)} connections, target '{ref_mod}' has {target_ports} ports",
                        })

        inst_names = [i.get("name") for i in mod.get("instances", []) if isinstance(i, dict) and i.get("name")]
        dupes = {n for n in inst_names if inst_names.count(n) > 1}
        if dupes:
            errors.append({
                "layer": 3, "category": "B", "rule": "B007",
                "module": mname, "module_idx": mi,
                "message": f"Duplicate instance names: {dupes}",
            })

        ports_by_name = {p.get("name"): p for p in mod.get("ports", []) if isinstance(p, dict)}
        driven = set()
        for a in mod.get("assignments", []):
            lhs = a.get("lhs", {})
            if isinstance(lhs, dict) and "ref" in lhs:
                driven.add(lhs["ref"])
        for blk in mod.get("always_blocks", []):
            for s in blk.get("body", []):
                if isinstance(s, dict) and s.get("type") == "assignment":
                    lhs = s.get("lhs", {})
                    if isinstance(lhs, dict) and "ref" in lhs:
                        driven.add(lhs["ref"])
        for sig in driven:
            if sig in ports_by_name and ports_by_name[sig].get("direction") == "input":
                errors.append({
                    "layer": 3, "category": "B", "rule": "B009",
                    "module": mname, "module_idx": mi,
                    "message": f"Input port '{sig}' is being driven",
                })

        for func in mod.get("functions", []):
            if isinstance(func, dict):
                if not _has_return(func.get("body", [])):
                    errors.append({
                        "layer": 3, "category": "B", "rule": "B011",
                        "module": mname, "module_idx": mi,
                        "message": f"Function '{func.get('name')}' has no return statement",
                    })

    if not errors:
        return {"passed": True, "errors": []}
    return {"passed": False, "errors": errors}


# ---------------------------------------------------------------------------
# 阶段五：回滚策略 - 黑盒
# ---------------------------------------------------------------------------

def blackbox_module(design: dict, module_name: str):
    for mod in design.get("modules", []):
        if mod.get("name") == module_name:
            mod["implementation"] = "locked"
            mod["always_blocks"] = []
            mod["assignments"] = []
            mod["functions"] = []
            mod["tasks"] = []
            mod["generates"] = []
            print(f"  [BLACKBOX] 模块 '{module_name}' 已置为黑盒")
            return


# ---------------------------------------------------------------------------
# 主工作流
# ---------------------------------------------------------------------------

def execute_workflow(json_path: str, max_iterations: int = 10):
    print(f"\n{'='*60}")
    print(f"工作流开始: {json_path}")
    print(f"{'='*60}")

    config = load_config()
    schema = load_schema()
    retry_count = {}
    blackboxed = set()

    for iteration in range(1, max_iterations + 1):
        print(f"\n--- 迭代 #{iteration} ---")

        result = run_validator(json_path)
        if result["passed"]:
            print("\n✅ 校验通过！工作流结束。")
            return True

        errors = result["errors"]
        print(f"  发现 {len(errors)} 个错误:")

        # 排序：先 A（全局）后 B（模块）后 C（跨模块）
        order = {"A": 0, "B": 1, "C": 2}
        errors.sort(key=lambda e: order.get(e.get("category", "B"), 99))

        fixed_any = False
        with open(json_path) as f:
            design = json.load(f)

        for err in errors:
            err_module = err.get("module", "")
            err_rule = err.get("rule", "L1-Schema")

            # 黑盒跳过
            if err_module in blackboxed:
                print(f"    [SKIP] {err_rule}: 模块 '{err_module}' 已黑盒")
                continue

            # 重试次数超限 -> 黑盒
            if err_module:
                retry_count.setdefault(err_module, 0)
                if retry_count[err_module] >= MAX_RETRIES_PER_MODULE:
                    print(f"    [BLACKBOX] {err_rule}: '{err_module}' 重试 {retry_count[err_module]} 次")
                    blackbox_module(design, err_module)
                    blackboxed.add(err_module)
                    fixed_any = True
                    continue

            print(f"\n  [{err_rule}] {err.get('message', '?')[:130]}")

            # 规则修复优先（零成本）
            if try_rule_fix(design, err):
                retry_count[err_module] = retry_count.get(err_module, 0) + 1
                fixed_any = True
                print(f"    [Rule] 规则修复成功")
                continue

            # LLM 修复（含预校验）
            sys_prompt, usr_prompt = build_fix_prompt(design, err, schema)

            for retry_llm in range(2):  # LLM 回复最多重试 2 次
                response = call_llm(sys_prompt, usr_prompt, config)
                if not response:
                    break

                # --- 预校验：在临时副本上应用修复再校验 ---
                trial = copy.deepcopy(design)
                if not apply_llm_fix(trial, err, response):
                    print(f"    [LLM] 回复无法解析，跳过")
                    break

                # 检查 trial 是否通过校验（只检查相关的 layer）
                trial_result = run_validator_on_dict(trial)
                new_errors = [e for e in trial_result["errors"]
                              if e.get("module") == err_module or e.get("category", "") in ("A",)]
                old_error_count = sum(1 for e in result["errors"]
                                      if e.get("module") == err_module or e.get("category", "") in ("A",))

                if len(new_errors) < old_error_count or trial_result["passed"]:
                    # 校验通过或错误减少 → 接受修复
                    design = trial
                    retry_count[err_module] = retry_count.get(err_module, 0) + 1
                    fixed_any = True
                    print(f"    [LLM-Validated] 预校验通过，修复已接受")
                    break
                else:
                    # 预校验失败：将新增错误反馈给 LLM
                    new_err_text = "\n".join(e.get("message", "") for e in new_errors[:3])
                    print(f"    [LLM-Reject] 预校验失败（{len(new_errors)} 错误），反馈给 LLM 重试...")
                    usr_prompt += f"\n\n## ⚠️ 上次修复引入了新错误：\n{new_err_text}\n请重新修复，避免引入这些错误。"
            else:
                # LLM 重试 2 次均失败
                print(f"    [LLM-Fail] LLM 修复 {2} 次均未通过预校验")
                retry_count[err_module] = retry_count.get(err_module, 0) + 1
                continue

        if fixed_any:
            with open(json_path, 'w') as f:
                json.dump(design, f, indent=2)
            print(f"\n  💾 保存修复结果 -> {json_path}")

        if not errors:
            break

    print(f"\n⚠️ 达到最大迭代次数 {max_iterations}，工作流结束")

    # 最终校验
    result = run_validator(json_path)
    if result["passed"]:
        print("✅ 最终校验通过！")
        return True
    else:
        print(f"❌ 最终校验失败：{len(result['errors'])} 个未解决错误")
        for e in result["errors"][:5]:
            print(f"   - [{e.get('rule','?')}] {e.get('message','')[:150]}")
        return False


# ---------------------------------------------------------------------------
def main():
    import argparse
    parser = argparse.ArgumentParser(description="高可靠芯片设计 JSON 修复工作流")
    parser.add_argument("json_file", help="待修复的设计 JSON 文件")
    parser.add_argument("--max-iter", type=int, default=10, help="最大迭代次数 (默认 10)")
    args = parser.parse_args()

    if not os.path.exists(args.json_file):
        print(f"[ERROR] 文件不存在: {args.json_file}")
        sys.exit(1)

    success = execute_workflow(args.json_file, max_iterations=args.max_iter)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
