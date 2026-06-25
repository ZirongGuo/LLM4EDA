#!/usr/bin/env python3
"""
规范 JSON → Block Design 可视化脚本 (Graphviz DOT / SVG)。
用法: python visualize_block.py <design.json> [--format svg|png|dot] -o <输出文件>
"""

import argparse
import json
import os
import sys


def generate_dot(design):
    """生成 Graphviz DOT 格式的 Block Design 图。"""
    lines = []
    lines.append("digraph BlockDesign {")
    lines.append("    rankdir=LR;")
    lines.append("    node [shape=record, style=filled, fillcolor=lightblue, fontname=\"Courier\"];")
    lines.append("    edge [fontname=\"Courier\", fontsize=10];")
    lines.append("    splines=ortho;")
    lines.append("")

    for mod in design.get("modules", []):
        mod_name = mod["name"]
        is_top = (design.get("design_hierarchy", {}).get("top") == mod_name)

        cluster_label = f"  label=\"{mod_name}\";"
        if is_top:
            cluster_label = f'  label="{mod_name} (top)";\n    style=filled;\n    fillcolor=lightyellow;'

        lines.append(f"  subgraph cluster_{mod_name} {{")
        lines.append(f"    {cluster_label}")
        lines.append(f'    color=blue if is_top else "black";')

        input_ports = [p for p in mod.get("ports", []) if p["direction"] == "input"]
        output_ports = [p for p in mod.get("ports", []) if p["direction"] == "output"]

        for inst in mod.get("instances", []):
            inst_name = inst["name"]
            inst_mod = inst["module"]

            in_pins = []
            out_pins = []
            for c in inst.get("port_connections", []):
                port_name = c["port"]
                conn = c.get("connection", {})
                if isinstance(conn, dict):
                    conn_str = conn.get("ref", conn.get("literal", "?"))
                else:
                    conn_str = str(conn) if conn is not None else "?"
                if isinstance(conn, dict) and isinstance(conn.get("literal"), str) and conn["literal"].startswith("32"):
                    pass
                in_pins.append(f"<{port_name}> {port_name}")

            if in_pins:
                in_label = " | ".join(in_pins)
            else:
                in_label = ""

            if out_pins:
                out_label = " | ".join(out_pins)
            else:
                out_label = ""

            if in_label and out_label:
                full_label = f"{{{in_label}}} | {inst_mod} | {{{out_label}}}"
            elif in_label:
                full_label = f"{{{in_label}}} | {inst_mod}"
            elif out_label:
                full_label = f"{inst_mod} | {{{out_label}}}"
            else:
                full_label = inst_mod

            lines.append(f'    {inst_name} [label="{full_label}"];')

        if input_ports:
            in_label = " | ".join(f"<{p['name']}> {p['name']}" for p in input_ports)
            lines.append(f'    top_inputs [label="{{{in_label}}} | Inputs", shape=box, fillcolor=lightgreen];')
        if output_ports:
            out_label = " | ".join(f"<{p['name']}> {p['name']}" for p in output_ports)
            lines.append(f'    top_outputs [label="Outputs | {{{out_label}}}", shape=box, fillcolor=lightcoral];')

        lines.append("  }")
        lines.append("")

        for inst in mod.get("instances", []):
            for c in inst.get("port_connections", []):
                conn = c.get("connection")
                if not isinstance(conn, dict):
                    continue
                conn_str = ""
                if "ref" in conn:
                    conn_str = conn["ref"]
                elif "literal" in conn:
                    conn_str = conn["literal"]
                if conn_str:
                    label = c["port"]
                    lines.append(f'    "{conn_str}" -> {inst["name"]}:{c["port"]} [label="{label}"];')

        for a in mod.get("assignments", []):
            lhs = a.get("lhs") if isinstance(a.get("lhs"), dict) else {}
            rhs = a.get("rhs") if isinstance(a.get("rhs"), dict) else {}
            lhs_str = lhs.get("ref", "")
            rhs_str = rhs.get("ref", "")
            if lhs_str and rhs_str:
                lines.append(f'    "{rhs_str}" -> "{lhs_str}" [label="assign", style=dashed, color=green];')

    lines.append("}")
    return "\n".join(lines)


def generate_html_svg_wrapper(svg_path, design):
    """生成带有交互功能的 HTML 包装器。"""
    mod = design.get("modules", [{}])[0]
    mod_name = mod.get("name", "unknown")

    html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Block Design - {mod_name}</title>
<style>
  body {{ font-family: 'Courier New', monospace; margin: 20px; background: #1e1e1e; color: #d4d4d4; }}
  h1 {{ color: #569cd6; }}
  svg {{ border: 1px solid #333; background: #252526; }}
  #info-panel {{ position: fixed; right: 20px; top: 20px; width: 300px; padding: 15px;
                background: #2d2d2d; border: 1px solid #444; border-radius: 5px; display: none; }}
  #info-panel h3 {{ margin-top: 0; color: #569cd6; }}
  #info-panel pre {{ background: #1e1e1e; padding: 10px; border-radius: 3px; font-size: 12px; }}
</style>
</head>
<body>
<h1>Block Design: {mod_name}</h1>
<object data="{os.path.basename(svg_path)}" type="image/svg+xml" width="100%" height="800"
        id="block-diagram"></object>

<div id="info-panel">
  <h3 id="panel-title">Module Info</h3>
  <pre id="panel-content">Click a module to see details</pre>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {{
    var svgObj = document.getElementById("block-diagram");
    svgObj.addEventListener("load", function() {{
      var svgDoc = svgObj.contentDocument;
      var nodes = svgDoc.querySelectorAll("ellipse, polygon, rect");
      nodes.forEach(function(node) {{
        node.addEventListener("mouseenter", function() {{
          this.style.opacity = "0.8";
        }});
        node.addEventListener("mouseleave", function() {{
          this.style.opacity = "1.0";
        }});
        node.addEventListener("click", function() {{
          var title = this.getAttribute("title") || this.textContent || "Unknown";
          document.getElementById("info-panel").style.display = "block";
          document.getElementById("panel-title").textContent = title;
          document.getElementById("panel-content").textContent =
            "Module: " + title + "\\n" +
            "Click to view details\\n" +
            JSON.stringify({json.dumps(dict(
              module=mod_name,
              ports=len(mod.get("ports", [])),
              instances=len(mod.get("instances", [])),
              always_blocks=len(mod.get("always_blocks", [])),
            ))}, null, 2);
        }});
      }});
    }});
  }});
</script>
</body>
</html>"""
    return html


def main():
    parser = argparse.ArgumentParser(description="规范 JSON → Block Design 可视化")
    parser.add_argument("input", help="输入的规范 JSON 文件")
    parser.add_argument("--format", choices=["svg", "png", "dot"], default="svg", help="输出格式")
    parser.add_argument("-o", "--output", default="design_block.svg", help="输出文件路径")
    parser.add_argument("--html", action="store_true", help="同时生成交互式 HTML")
    args = parser.parse_args()

    with open(args.input) as f:
        design = json.load(f)

    dot_source = generate_dot(design)
    output_base = os.path.splitext(args.output)[0]

    if args.format == "dot" or not _graphviz_available():
        if args.format == "dot" or not _graphviz_available():
            with open(args.output, "w") as f:
                f.write(dot_source)
            print(f"[OK] 已生成 DOT 文件: {args.output}")
            if not _graphviz_available():
                print("     提示: 安装 graphviz Python 包可渲染为 SVG/PNG: pip install graphviz")
    else:
        import graphviz
        src = graphviz.Source(dot_source)
        src.format = args.format
        src.render(outfile=args.output, cleanup=True)
        print(f"[OK] 已生成 {args.format.upper()} 文件: {args.output}")

    if args.html:
        html_path = output_base + ".html"
        html_content = generate_html_svg_wrapper(args.output, design)
        with open(html_path, "w") as f:
            f.write(html_content)
        print(f"[OK] 已生成交互式 HTML: {html_path}")


def _graphviz_available():
    try:
        import graphviz
        return True
    except ImportError:
        return False


if __name__ == "__main__":
    main()
