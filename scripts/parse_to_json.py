#!/usr/bin/env python3
"""
Verilog → 规范 JSON 前向转换脚本。
用法: python parse_to_json.py --top <顶层模块> [--incdir <目录>] <源文件>... -o <输出.json>
"""

import argparse
import json
import os
import sys
import re


from utils.ast_builder import (
    build_ref, build_literal, build_binary, build_unary,
    build_select, build_bit_select, build_concat, build_replicate,
    build_cond, build_call, build_assignment, build_if, build_case,
    build_case_item, build_for, build_return, build_always_block,
    build_sensitivity_item, build_instance, build_port_connection,
    build_port, build_signal, build_parameter, build_define,
    build_function, build_task, build_generate, build_module,
)


def _find_block_end(text, start):
    """查找匹配 begin/end 的 end 位置，支持嵌套。"""
    depth = 1
    i = start
    while i < len(text):
        if re.match(r'\bbegin\b', text[i:]):
            depth += 1
            i += 5
        elif re.match(r'\bend\b', text[i:]):
            depth -= 1
            if depth <= 0:
                return i
            i += 3
        else:
            i += 1
    return len(text)


def _find_endmodule(text, start):
    return text.find("endmodule", start)


def _find_kwd_end(text, kwd, start):
    """Find keyword 'kwd' after start, respecting nesting."""
    return text.find(kwd, start)


class SimpleVerilogParser:
    def __init__(self, src_files, inc_dirs=None, top_module=None):
        self.src_files = src_files
        self.inc_dirs = inc_dirs or []
        self.top_module = top_module
        self.defines = {}
        self.includes = []
        self.modules = []
        self.source_text = ""
        self._load_sources()

    def _load_sources(self):
        for f in self.src_files:
            with open(f) as fh:
                self.source_text += fh.read() + "\n"

    def _strip_comments(self, text):
        text = re.sub(r'//.*', '', text)
        text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
        return text

    def _find_defines(self, text):
        for m in re.finditer(r'`define\s+(\w+)\s+(.+)', text):
            self.defines[m.group(1)] = m.group(2).strip().split('//')[0].strip()

    def _find_includes(self, text):
        for m in re.finditer(r'`include\s+"([^"]+)"', text):
            self.includes.append(m.group(1))

    def _remove_strings(self, text):
        """Remove quoted strings to avoid false matches inside strings."""
        return re.sub(r'"[^"]*"', '', text)

    def _parse_ports(self, port_text):
        """Parse only from module header port list, NOT from body."""
        ports = []
        for m in re.finditer(
            r'(input|output|inout)\s+'
            r'(wire|reg|logic)?\s*'
            r'(signed)?\s*'
            r'(?:\[(\d+):(\d+)\])?\s*'
            r'(\w+)',
            port_text
        ):
            direction = m.group(1)
            data_type = m.group(2) or "wire"
            signed = bool(m.group(3))
            width = 1
            if m.group(4) and m.group(5):
                width = int(m.group(4)) - int(m.group(5)) + 1
            ports.append(build_port(m.group(6), direction, data_type, width, signed))
        return ports

    def _parse_sensitivity(self, sens_text):
        sens_list = []
        for m in re.finditer(r'(posedge|negedge)\s+(\w+)', sens_text):
            sens_list.append(build_sensitivity_item(m.group(1), m.group(2)))
        for m in re.finditer(r'(?:,\s*)(\w+)(?!\s*\))', sens_text):
            if not any(s["signal"] == m.group(1) for s in sens_list):
                sens_list.append(build_sensitivity_item("level", m.group(1)))
        return sens_list

    def _parse_expression(self, expr_text):
        expr_text = expr_text.strip()
        if not expr_text:
            return None

        if re.match(r'^\d+\'[bodh]', expr_text, re.IGNORECASE):
            return build_literal(expr_text)
        if re.match(r'^\d+$', expr_text):
            return build_literal(expr_text)

        if expr_text.startswith("{") and expr_text.endswith("}"):
            inner = expr_text[1:-1].strip()
            m2 = re.match(r'(\d+)\{(.+)\}', inner)
            if m2:
                return build_replicate(
                    build_literal(m2.group(1)),
                    self._parse_expression(m2.group(2))
                )
            parts = [self._parse_expression(p.strip()) for p in self._split_comma(inner)]
            return build_concat(parts)

        if "?" in expr_text and ":" in expr_text:
            parts = re.split(r'\s*\?\s*', expr_text, maxsplit=1)
            if len(parts) == 2:
                tf = re.split(r'\s*:\s*', parts[1], maxsplit=1)
                if len(tf) == 2:
                    return build_cond(
                        self._parse_expression(parts[0]),
                        self._parse_expression(tf[0]),
                        self._parse_expression(tf[1]),
                    )

        for op_pat in [r'<<<', r'>>>', r'<<', r'>>', r'>=', r'<=', r'===', r'!==',
                       r'==', r'!=', r'&&', r'\|\|', r'[+\-*/%&|^~]', r'<', r'>']:
            parts = re.split(r'\s*(' + op_pat + r')\s*', expr_text, maxsplit=1)
            if len(parts) == 3:
                return build_binary(
                    self._parse_expression(parts[0]),
                    parts[1],
                    self._parse_expression(parts[2]),
                )

        m = re.match(r'(!|~|-)\s*(\S+)', expr_text)
        if m:
            return build_unary(m.group(1), self._parse_expression(m.group(2)))

        m = re.match(r'(\w+)\s*\((.+)\)', expr_text, re.DOTALL)
        if m:
            args = [self._parse_expression(a.strip()) for a in self._split_comma(m.group(2))]
            return build_call(m.group(1), args)

        m = re.match(r'(\w+)\[(\d+):(\d+)\]', expr_text)
        if m:
            return build_select(build_ref(m.group(1)), int(m.group(2)), int(m.group(3)))
        m = re.match(r'(\w+)\[(\d+)\]', expr_text)
        if m:
            return build_bit_select(build_ref(m.group(1)), build_literal(m.group(2)))
        if re.match(r'^\w+$', expr_text):
            return build_ref(expr_text)
        if expr_text.startswith('`'):
            return build_ref(expr_text)

        return build_ref(expr_text)

    def _split_comma(self, text):
        depth = 0
        parts, cur = [], ""
        for ch in text:
            if ch in "({[":
                depth += 1
            elif ch in ")}]":
                depth -= 1
            elif ch == "," and depth == 0:
                parts.append(cur)
                cur = ""
                continue
            cur += ch
        parts.append(cur)
        return [p.strip() for p in parts if p.strip()]

    def _extract_assignments(self, text):
        assigns = []
        for m in re.finditer(
            r'assign\s+(?:#\s*(\d+))?\s*(\w+(?:\[\d+:\d+\])?)\s*=\s*([^;]+);',
            text
        ):
            delay_val = m.group(1)
            lhs = self._parse_expression(m.group(2))
            rhs = self._parse_expression(m.group(3).strip())
            delay = {"value": delay_val, "type": "unit"} if delay_val else None
            assigns.append({
                "id": f"assign_{m.start()}",
                "lhs": lhs, "rhs": rhs, "delay": delay,
            })
        return assigns

    def _extract_signals(self, text):
        """Extract wire/reg/logic declarations, skipping function/task bodies."""
        signals = []
        clean = re.sub(r'function.*?endfunction', '', text, flags=re.DOTALL)
        clean = re.sub(r'task.*?endtask', '', clean, flags=re.DOTALL)
        clean = re.sub(r'generate.*?endgenerate', '', clean, flags=re.DOTALL)
        for m in re.finditer(
            r'(wire|reg|logic)\s+'
            r'(signed)?\s*'
            r'(?:\[(\d+):(\d+)\])?\s*'
            r'(\w+)\s*'
            r'(?:=\s*([^;]+))?\s*;',
            clean
        ):
            sig_type = m.group(1)
            signed = bool(m.group(2))
            width = 1
            if m.group(3) and m.group(4):
                width = int(m.group(3)) - int(m.group(4)) + 1
            name = m.group(5)
            init_val = m.group(6)
            if init_val:
                init_val = init_val.strip()
            signals.append(build_signal(name, sig_type, width, signed, init_val))
        return signals

    def _extract_always(self, text):
        blocks = []
        idx = 0
        pos = 0
        while pos < len(text):
            m = re.search(r'(always_ff|always_comb|always_latch|always)\s*'
                          r'(?:@\s*\(([^)]*)\))?\s*', text[pos:], re.DOTALL)
            if not m:
                break
            always_type = m.group(1)
            sens_text = m.group(2) or ""

            after = pos + m.end()
            bm = re.search(r'\bbegin\b', text[after:])
            if not bm:
                pos = after + 1
                continue
            body_start = after + bm.end()
            body_end = _find_block_end(text, body_start)
            if body_end <= body_start:
                pos = after + 1
                continue
            inner = text[body_start:body_end].strip()

            sensitivity = self._parse_sensitivity(sens_text) if sens_text else []
            stmts = self._extract_statements(inner)
            if stmts:
                blocks.append(build_always_block(
                    f"proc_{idx}", always_type, sensitivity, stmts
                ))
                idx += 1
            pos = body_end + 3
        return blocks

    def _extract_statements(self, text):
        """Extract if-else, case, and flat assignment statements from always block body."""
        stmts = []
        i = 0
        while i < len(text):
            chunk = text[i:].lstrip()
            i += len(text[i:]) - len(chunk)
            if not chunk:
                break

            if_match = re.match(r'if\s*\(', chunk)
            if if_match:
                cond_end = self._match_paren(chunk, if_match.end() - 1)
                if cond_end < 0:
                    i += 1
                    continue
                cond = self._parse_expression(chunk[if_match.end():cond_end])

                # find then body
                after = cond_end + 1
                bm = re.search(r'\bbegin\b', chunk[after:])
                then_end = len(chunk)
                then_stmts = []
                if bm:
                    ts = after + bm.end()
                    then_end = _find_block_end(chunk, ts)
                    if then_end > ts:
                        then_stmts = self._extract_flat_assignments(chunk[ts:then_end])

                # find else body
                else_stmts = []
                after_then = then_end + 3 if then_end < len(chunk) else len(chunk)
                rest = chunk[after_then:].lstrip()
                if rest.startswith("else"):
                    rest = rest[4:].lstrip()
                    bm2 = re.search(r'\bbegin\b', rest)
                    if bm2:
                        es = bm2.end()
                        ee = _find_block_end(rest, es)
                        if ee > es:
                            else_stmts = self._extract_flat_assignments(rest[es:ee])
                        i += len(chunk) - len(rest[(ee + 3):]) if ee < len(rest) else len(chunk)
                    else:
                        # else without begin/end
                        assign_m = re.match(r'(\w+\s*(?:<=|=)\s*[^;]+;)\s*', rest)
                        if assign_m:
                            else_stmts = self._extract_flat_assignments(assign_m.group(1))
                            i += len(chunk) - len(rest[assign_m.end():])
                        else:
                            i += len(chunk) - len(rest)
                else:
                    i += len(chunk) - len(rest)

                stmts.append(build_if(cond, then_stmts, else_stmts))
                continue

            case_match = re.match(r'case[xz]?\s*\(', chunk)
            if case_match:
                expr_end = self._match_paren(chunk, case_match.end() - 1)
                if expr_end < 0:
                    i += 1
                    continue
                case_expr = self._parse_expression(chunk[case_match.end():expr_end])
                case_text = chunk[expr_end + 1:]

                # Find endcase to delimit the case body (no begin/end wrapping case)
                ec = case_text.find("endcase")
                if ec < 0:
                    i += 1
                    continue
                inner = case_text[:ec]

                items = []
                default_stmts = []
                ci = 0
                while ci < len(inner):
                    vm = re.match(r'([^:]+?)\s*:\s*begin\s*', inner[ci:], re.DOTALL)
                    if not vm:
                        ci += 1
                        continue
                    val_text = vm.group(1).strip()
                    ibs_off = vm.end()
                    ibe = _find_block_end(inner[ci:], ibs_off)
                    body_text = inner[ci:][ibs_off:ibe].strip()
                    if val_text == "default":
                        default_stmts = self._extract_flat_assignments(body_text)
                    else:
                        items.append(build_case_item(
                            self._parse_expression(val_text),
                            self._extract_flat_assignments(body_text)
                        ))
                    ci += ibe + 3

                if items or default_stmts:
                    stmts.append(build_case(case_expr, items, default_stmts))
                i += len(chunk) - len(case_text[ec + 7:])
                continue

            assign_match = re.match(
                r'(\w+(?:\[\d+:\d+\])?)\s*(<=|=)\s*([^;]+);',
                chunk
            )
            if assign_match:
                stmts.append(build_assignment(
                    self._parse_expression(assign_match.group(1)),
                    self._parse_expression(assign_match.group(3).strip()),
                    blocking=(assign_match.group(2) == "="),
                ))
                i += assign_match.end()
                continue

            i += 1

        return stmts

    def _extract_flat_assignments(self, text):
        stmts = []
        for m in re.finditer(
            r'(\w+(?:\[\d+:\d+\])?)\s*(<=|=)\s*([^;]+);',
            text
        ):
            lhs_t = m.group(1)
            op = m.group(2)
            rhs_t = m.group(3).strip()
            stmts.append(build_assignment(
                self._parse_expression(lhs_t),
                self._parse_expression(rhs_t),
                blocking=(op == "="),
            ))
        return stmts

    def _extract_instances(self, body):
        instances = []
        # Strip function/task/always bodies to avoid false matches
        clean = re.sub(r'function.*?endfunction', '', body, flags=re.DOTALL)
        clean = re.sub(r'task.*?endtask', '', clean, flags=re.DOTALL)
        clean = re.sub(r'always_ff.*?end', '', clean, flags=re.DOTALL)
        clean = re.sub(r'always_comb.*?end', '', clean, flags=re.DOTALL)
        clean = re.sub(r'assign\s+.*?;', '', clean)
        clean = re.sub(r'(wire|reg|logic)\s+.*?;', '', clean)
        clean = re.sub(r'endgenerate', '', clean)
        clean = re.sub(r'\bgenerate\b', '', clean)

        idx = 0
        while idx < len(clean):
            # Match: module_name [param_parens] inst_name parens;
            m = re.search(
                r'(\w+)\s+'
                r'(?:#\s*\(((?:[^()]|\([^()]*\))*)\)\s*)?'
                r'(\w+)\s*\(',
                clean[idx:], re.DOTALL
            )
            if not m:
                break
            mod_name = m.group(1)
            param_text = m.group(2)
            inst_name = m.group(3)

            param_map = {}
            if param_text:
                for pm in re.finditer(r'\.(\w+)\s*\(\s*([^)]*?)\s*\)', param_text):
                    param_map[pm.group(1)] = self._parse_expression(pm.group(2).strip())

            paren_open = idx + m.end(0) - 1
            paren_end = self._match_paren(clean, paren_open)
            if paren_end < 0:
                idx = paren_open + 1
                continue
            conn_text = clean[paren_open+1:paren_end]

            conns = []
            if conn_text.strip():
                for c in re.finditer(r'\.(\w+)\s*\(\s*([^)]*?)\s*\)', conn_text):
                    conn_val = c.group(2).strip()
                    conns.append(build_port_connection(
                        c.group(1), self._parse_expression(conn_val)
                    ))
            instances.append(build_instance(inst_name, mod_name, param_map, conns))
            idx = paren_end + 1

        return instances

    def _match_paren(self, text, start):
        depth = 1
        i = start + 1
        while i < len(text) and depth > 0:
            if text[i] == '(':
                depth += 1
            elif text[i] == ')':
                depth -= 1
            i += 1
        return i - 1 if depth == 0 else -1

    def parse(self):
        text = self._strip_comments(self.source_text)
        self._find_defines(text)
        self._find_includes(text)

        mod_re = re.compile(
            r'module\s+(\w+)\s*'
            r'(?:#\s*\((.*?)\))?\s*'
            r'\((.*?)\)\s*;',
            re.DOTALL
        )

        mod_cursor = 0
        while True:
            m = mod_re.search(text, mod_cursor)
            if not m:
                break
            mod_name = m.group(1)
            param_text = m.group(2) or ""
            port_text = m.group(3) or ""

            after_header = m.end()
            em = _find_endmodule(text, after_header)
            if em < 0:
                break
            body = text[after_header:em]

            params = self._parse_params(param_text)
            ports = self._parse_ports(port_text)
            signals = self._extract_signals(body)
            always_blocks = self._extract_always(body)
            assignments = self._extract_assignments(body)
            instances = self._extract_instances(body)
            functions = self._parse_functions(body)
            tasks = self._parse_tasks(body)
            generates = self._parse_generates(body)

            self.modules.append(build_module(
                mod_name, params, ports, signals,
                always_blocks, assignments, instances,
                functions, tasks, generates,
            ))
            mod_cursor = em + 9

        return self._build_output()

    def _parse_params(self, param_text):
        params = []
        if not param_text.strip():
            return params
        for p in re.finditer(r'parameter\s+(\w+)\s+(\w+)\s*=\s*([^,)]+)', param_text):
            params.append(build_parameter(
                p.group(1), "parameter", p.group(2), p.group(3).strip()
            ))
        for p in re.finditer(r'parameter\s+(\w+)\s*=\s*([^,)]+)', param_text):
            if not any(pp["name"] == p.group(1) for pp in params):
                params.append(build_parameter(
                    p.group(1), "parameter", "int", p.group(2).strip()
                ))
        return params

    def _parse_functions(self, body):
        funcs = []
        idx = 0
        while idx < len(body):
            # function <return_type> <name> ;  or  function <return_type> <name> ( ... ) ;
            m = re.search(r'\bfunction\s+', body[idx:])
            if not m:
                break
            after = idx + m.end()
            # Find the function name (the last identifier before '(' or ';')
            semi = body.find(";", after)
            if semi < 0:
                break
            header = body[after:semi].strip()
            # return_type is everything except the last word (name)
            parts = header.split()
            if len(parts) < 2:
                idx = semi + 1
                continue
            func_name = parts[-1]
            ret_type = " ".join(parts[:-1])

            inputs = []
            # Check if there are parenthesized input declarations
            arg_match = re.search(r'\(\s*', body[after:semi])
            if arg_match:
                args_end = self._match_paren(body, after + arg_match.start())
                if args_end > 0:
                    args_text = body[after + arg_match.start() + 1:args_end]
                    for arg in re.finditer(r'\binput\s+(\S+(?:\s*\[[^\]]+\])?)\s+(\w+)', args_text):
                        inputs.append({"name": arg.group(2), "type": arg.group(1)})

            func_end_kw = body.find("endfunction", semi)
            if func_end_kw < 0:
                break
            func_body_text = body[semi + 1:func_end_kw]
            funcs.append(build_function(func_name, ret_type, inputs,
                                        self._extract_flat_assignments(func_body_text)))
            idx = func_end_kw + 11
        return funcs

    def _parse_tasks(self, body):
        tasks_list = []
        idx = 0
        while idx < len(body):
            m = re.search(r'\btask\s+(\w+)', body[idx:])
            if not m:
                break
            task_name = m.group(1)
            after = idx + m.end()
            semi = body.find(";", after)
            if semi < 0:
                break

            inputs, outputs = [], []
            arg_match = re.search(r'\(\s*', body[after:semi])
            if arg_match:
                args_end = self._match_paren(body, after + arg_match.start())
                if args_end > 0:
                    args_text = body[after + arg_match.start() + 1:args_end]
                    for arg in re.finditer(r'\b(input|output)\s+(\S+(?:\s*\[[^\]]+\])?)\s+(\w+)', args_text):
                        entry = {"name": arg.group(3), "type": arg.group(2)}
                        if arg.group(1) == "input":
                            inputs.append(entry)
                        else:
                            outputs.append(entry)

            task_end_kw = body.find("endtask", semi)
            if task_end_kw < 0:
                break
            tasks_list.append(build_task(task_name, inputs, outputs,
                                        self._extract_flat_assignments(body[semi + 1:task_end_kw])))
            idx = task_end_kw + 7
        return tasks_list

    def _parse_generates(self, body):
        gens = []
        for m in re.finditer(
            r'generate\s+if\s*\((.*?)\)\s*'
            r'begin\s*(.*?)end\s*endgenerate',
            body, re.DOTALL
        ):
            cond = self._parse_expression(m.group(1).strip())
            gen_body_text = m.group(2).strip()
            gen_body = self._extract_instances(gen_body_text)
            gens.append(build_generate(cond, gen_body))
        return gens

    def _build_output(self):
        defines_list = [build_define(k, v) for k, v in self.defines.items()]
        hierarchy = {}
        for mod in self.modules:
            children = [inst["name"] for inst in mod.get("instances", [])]
            hierarchy[mod["name"]] = children

        return {
            "version": "1.0.0",
            "metadata": {
                "design_name": self.top_module or "unknown",
                "source_files": self.src_files,
                "top_module": self.top_module or "",
                "description": f"Parsed from {len(self.src_files)} file(s)",
                "generated_by": "parse_to_json.py v1.0",
                "generated_at": __import__("datetime").datetime.now().isoformat(),
            },
            "includes": self.includes,
            "defines": defines_list,
            "modules": self.modules,
            "design_hierarchy": {
                "top": self.top_module or (self.modules[0]["name"] if self.modules else ""),
                "tree": hierarchy,
            },
        }


def main():
    parser = argparse.ArgumentParser(description="Verilog → 规范 JSON 转换")
    parser.add_argument("--top", help="顶层模块名")
    parser.add_argument("--incdir", action="append", default=[], help="include 目录")
    parser.add_argument("-o", "--output", default="design.json", help="输出 JSON 路径")
    parser.add_argument("src", nargs="+", help="Verilog 源文件")
    args = parser.parse_args()

    vp = SimpleVerilogParser(args.src, args.incdir, args.top)
    result = vp.parse()

    with open(args.output, "w") as f:
        json.dump(result, f, indent=2)
    print(f"[OK] 已生成规范 JSON: {args.output}")
    print(f"     模块数: {len(result['modules'])}")


if __name__ == "__main__":
    main()
