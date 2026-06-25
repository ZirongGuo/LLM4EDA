#!/usr/bin/env python3
"""
规范 JSON → Verilog 反向转换脚本。
用法: python generate_from_json.py <design.json> -o <输出.v>
"""

import argparse
import json
import sys
from utils.expr_emitter import emit_expr, emit_stmt


def generate_verilog(design):
    lines = []

    for inc in design.get("includes", []):
        lines.append(f'`include "{inc}"')

    for d in design.get("defines", []):
        lines.append(f'`define {d["name"]} {d["value"]}')

    if design.get("includes") or design.get("defines"):
        lines.append("")

    for mod in design.get("modules", []):
        lines.extend(_gen_module(mod))

    return "\n".join(lines)


def _gen_module(mod):
    lines = []
    name = mod["name"]

    has_params = bool(mod.get("parameters"))
    has_ports = bool(mod.get("ports"))

    if has_params:
        param_strs = []
        for p in mod["parameters"]:
            dtype = p.get("data_type") or p.get("type", "")
            if dtype == "parameter" or dtype == "localparam":
                dtype = ""
            dtype_str = f" {dtype}" if dtype else ""
            param_strs.append(
                f"  parameter{dtype_str} {p['name']} = {p['value']}"
            )
        lines.append(f"module {name}")
        lines.append("#(")
        lines.append(",\n".join(param_strs))
        lines.append(")")

    if has_ports:
        port_strs = []
        for p in mod["ports"]:
            pdir = p["direction"]
            dtype = p.get("data_type", "wire")
            signed = "signed " if p.get("signed") else ""
            width = ""
            if p.get("width", 1) > 1:
                width = f" [{p['width']-1}:0] "
            else:
                width = " "
            port_strs.append(f"  {pdir} {signed}{dtype}{width}{p['name']}")

        if has_params:
            lines.append("(")
        else:
            lines.append(f"module {name}")
            lines.append("(")
        lines.append(",\n".join(port_strs))
        lines.append(");")
    else:
        lines.append(f"module {name};")

    if mod.get("parameters"):
        lines.append("")

    if mod.get("signals"):
        for s in mod["signals"]:
            stype = s.get("type", "wire")
            signed = "signed " if s.get("signed") else ""
            width = ""
            if s.get("width", 1) > 1:
                width = f" [{s['width']-1}:0] "
            else:
                width = " "
            init = ""
            if s.get("initial_value"):
                init = f" = {s['initial_value']}"
            lines.append(f"  {stype} {signed}{width}{s['name']}{init};")

    if mod.get("functions"):
        lines.append("")
        for func in mod["functions"]:
            lines.extend(_gen_function(func))

    if mod.get("tasks"):
        lines.append("")
        for task in mod["tasks"]:
            lines.extend(_gen_task(task))

    if mod.get("always_blocks"):
        lines.append("")
        for ab in mod["always_blocks"]:
            lines.extend(_gen_always(ab))

    if mod.get("assignments"):
        lines.append("")
        for a in mod["assignments"]:
            delay = ""
            if a.get("delay"):
                delay = f" #{a['delay']['value']}"
            lhs = emit_expr(a["lhs"])
            rhs = emit_expr(a["rhs"])
            lines.append(f"  assign{delay} {lhs} = {rhs};")

    if mod.get("instances"):
        lines.append("")
        for inst in mod["instances"]:
            lines.extend(_gen_instance(inst))

    if mod.get("generates"):
        lines.append("")
        for gen in mod.get("generates", []):
            lines.extend(_gen_generate(gen))

    lines.append(f"endmodule\n")
    return lines


def _gen_function(func):
    lines = []
    ret = func["return_type"]
    inputs = ", ".join(f"{i['type']} {i['name']}" for i in func.get("inputs", []))
    lines.append(f"  function {ret} {func['name']}({inputs});")
    for s in func.get("body", []):
        line = emit_stmt(s, 2)
        if line:
            lines.append(line)
    lines.append("  endfunction")
    return lines


def _gen_task(task):
    lines = []
    io = []
    for i in task.get("inputs", []):
        io.append(f"input {i['type']} {i['name']}")
    for o in task.get("outputs", []):
        io.append(f"output {o['type']} {o['name']}")
    io_str = ", ".join(io)
    lines.append(f"  task {task['name']}({io_str});")
    for s in task.get("body", []):
        line = emit_stmt(s, 2)
        if line:
            lines.append(line)
    lines.append("  endtask")
    return lines


def _gen_always(ab):
    lines = []
    ab_type = ab["type"]
    sens_items = ab.get("sensitivity", [])
    if sens_items:
        sens_strs = []
        for si in sens_items:
            if si["type"] in ("posedge", "negedge"):
                sens_strs.append(f"{si['type']} {si['signal']}")
            else:
                sens_strs.append(si["signal"])
        lines.append(f"  {ab_type} @({' or '.join(sens_strs)}) begin")
    else:
        lines.append(f"  {ab_type} begin")
    for s in ab.get("body", []):
        line = emit_stmt(s, 2)
        if line:
            lines.append(line)
    lines.append("  end")
    return lines


def _gen_instance(inst):
    lines = []
    mod_name = inst["module"]
    inst_name = inst["name"]

    pmap = inst.get("parameter_mapping") or {}
    if pmap:
        lines.append(f"  {mod_name} #(")
        pstrs = [f"    .{k}({emit_expr(v)})" for k, v in pmap.items()]
        lines.append(",\n".join(pstrs))
        lines.append(f"  ) {inst_name} (")
    else:
        lines.append(f"  {mod_name} {inst_name} (")

    conns = inst.get("port_connections", [])
    if conns:
        cstrs = []
        for c in conns:
            conn_expr = emit_expr(c["connection"])
            cstrs.append(f"    .{c['port']}({conn_expr})")
        lines.append(",\n".join(cstrs))

    lines.append("  );")
    return lines


def _gen_generate(gen):
    lines = []
    cond = emit_expr(gen["condition"])
    lines.append(f"  generate")
    lines.append(f"    if ({cond}) begin")
    for item in gen.get("body", []):
        if item.get("type") == "instance":
            lines.extend(_gen_instance(item))
    lines.append("    end")
    lines.append(f"  endgenerate")
    return lines


def main():
    parser = argparse.ArgumentParser(description="规范 JSON → Verilog 反向生成")
    parser.add_argument("input", help="输入的规范 JSON 文件")
    parser.add_argument("-o", "--output", required=True, help="输出 .v 文件路径")
    args = parser.parse_args()

    with open(args.input) as f:
        design = json.load(f)

    code = generate_verilog(design)

    with open(args.output, "w") as f:
        f.write(code)
    print(f"[OK] 已生成 Verilog: {args.output}")
    print(f"     总行数: {len(code.splitlines())}")


if __name__ == "__main__":
    main()
