"""AST 表达式生成器：将表达式 AST 递归转换为 Verilog 字符串。"""

OPS = {
    "+": " + ", "-": " - ", "*": " * ", "/": " / ", "%": " % ",
    "&": " & ", "|": " | ", "^": " ^ ", "^~": " ^~ ", "~^": " ~^ ",
    "&&": " && ", "||": " || ",
    "==": " == ", "!=": " != ", "===": " === ", "!==": " !== ",
    "<": " < ", "<=": " <= ", ">": " > ", ">=": " >= ",
    "<<": " << ", ">>": " >> ", "<<<": " <<< ", ">>>": " >>> ",
}

UNA_OPS = {"!", "~", "-", "&", "~&", "|", "~|", "^", "~^"}


def emit_expr(expr, indent=0):
    if expr is None:
        return ""
    if isinstance(expr, str):
        return expr
    if not isinstance(expr, dict):
        return str(expr)

    if "ref" in expr:
        return expr["ref"]
    if "literal" in expr:
        return expr["literal"]
    if "type" in expr:
        t = expr["type"]
        if t == "select":
            src = emit_expr(expr["source"], indent)
            rng = expr.get("range", {})
            return f"{src}[{rng['msb']}:{rng['lsb']}]"
        if t == "bit_select":
            src = emit_expr(expr["source"], indent)
            idx = emit_expr(expr["index"], indent)
            return f"{src}[{idx}]"
        if t == "concat":
            parts = [emit_expr(p, indent) for p in expr.get("parts", [])]
            return "{" + ", ".join(parts) + "}"
        if t == "replicate":
            times = emit_expr(expr["times"], indent)
            val = emit_expr(expr["value"], indent)
            return "{" + times + "{" + val + "}}"
        if t == "cond":
            cond = emit_expr(expr["condition"], indent)
            te = emit_expr(expr["true_expr"], indent)
            fe = emit_expr(expr["false_expr"], indent)
            return f"({cond} ? {te} : {fe})"
        if t == "call":
            args = ", ".join(emit_expr(a, indent) for a in expr.get("arguments", []))
            return f"{expr['function']}({args})"
        if t in ("assignment",):
            return emit_stmt(expr, indent)

    if "type" in expr and expr["type"] == "parameter_ref":
        return expr.get("value", "")

    if "op" in expr:
        op = expr["op"]
        if op in UNA_OPS and "operand" in expr:
            operand = emit_expr(expr["operand"], indent)
            return f"{op}{operand}"
        if op in OPS and "left" in expr and "right" in expr:
            left = emit_expr(expr["left"], indent)
            right = emit_expr(expr["right"], indent)
            return f"({left}{OPS[op]}{right})"
        return f"<unknown_op:{op}>"

    if "value" in expr:
        return str(expr["value"])

    return "<unknown_expr>"


def emit_stmt(stmt, indent=0):
    pad = "  " * indent
    if stmt.get("type") == "assignment":
        lhs = emit_expr(stmt["lhs"])
        rhs = emit_expr(stmt["rhs"])
        arrow = "=" if stmt.get("blocking", True) else "<="
        delay = ""
        if "delay" in stmt:
            delay = f" #{stmt['delay']['value']}"
        return f"{pad}{lhs} {delay} {arrow} {rhs};"

    if stmt.get("type") == "if":
        cond = emit_expr(stmt["condition"])
        result = f"{pad}if ({cond}) begin\n"
        for s in stmt.get("then", []):
            result += emit_stmt(s, indent + 1) + "\n"
        if stmt.get("else"):
            result += f"{pad}end else begin\n"
            for s in stmt["else"]:
                result += emit_stmt(s, indent + 1) + "\n"
        result += f"{pad}end"
        return result

    if stmt.get("type") == "case":
        exp = emit_expr(stmt["expression"])
        ct = stmt.get("case_type", "")
        kw = "casex" if ct == "x" else ("casez" if ct == "z" else "case")
        result = f"{pad}{kw} ({exp})\n"
        for item in stmt.get("items", []):
            val = emit_expr(item.get("value", ""))
            result += f"{pad}  {val}: begin\n"
            for s in item.get("body", []):
                result += emit_stmt(s, indent + 2) + "\n"
            result += f"{pad}  end\n"
        if stmt.get("default"):
            result += f"{pad}  default: begin\n"
            for s in stmt["default"]:
                result += emit_stmt(s, indent + 2) + "\n"
            result += f"{pad}  end\n"
        result += f"{pad}endcase"
        return result

    if stmt.get("type") == "for":
        init = emit_stmt(stmt["init"], indent)
        cond = emit_expr(stmt["condition"])
        step = emit_stmt(stmt["step"], indent)
        result = f"{pad}for ({init} {cond}; {step}) begin\n"
        for s in stmt.get("body", []):
            result += emit_stmt(s, indent + 1) + "\n"
        result += f"{pad}end"
        return result

    if stmt.get("type") == "return":
        val = emit_expr(stmt.get("value"))
        return f"{pad}return {val};"

    if stmt.get("type") == "instance":
        result = f"{pad}{stmt['module']} {stmt['name']} ("
        conns = stmt.get("port_connections", [])
        if conns:
            conn_strs = []
            for c in conns:
                conn_strs.append(f".{c['port']}({emit_expr(c['connection'])})")
            result += "\n" + ",\n".join("  " + pad + cs for cs in conn_strs) + "\n" + pad
        result += ");"
        return result

    return f"{pad}<unknown_stmt>;"
