#!/usr/bin/env python3
import json
import os
import sys
import csv
import hashlib
from datetime import datetime
from copy import deepcopy

PROJ_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPECS_DIR = os.path.join(PROJ_DIR, 'specs')
TEST_SUITES_DIR = os.path.join(PROJ_DIR, 'test_suites')

TIMESTAMP = datetime.now().strftime('%Y%m%d_%H%M%S')
OUT_DIR = os.path.join(TEST_SUITES_DIR, TIMESTAMP)
POS_DIR = os.path.join(OUT_DIR, 'positive')
NEG_DIR = os.path.join(OUT_DIR, 'negative')
ROB_DIR = os.path.join(OUT_DIR, 'robustness')

os.makedirs(POS_DIR, exist_ok=True)
os.makedirs(NEG_DIR, exist_ok=True)
os.makedirs(ROB_DIR, exist_ok=True)

with open(os.path.join(SPECS_DIR, 'example_design_complete.json')) as f:
    GOLDEN = json.load(f)

def deep_clone(obj):
    return json.loads(json.dumps(obj))

def make_minimal_valid():
    return {
        "version": "1.0.0",
        "metadata": {
            "design_name": "minimal",
            "top_module": "top"
        },
        "modules": [
            {
                "name": "top",
                "ports": [
                    {"name": "clk", "direction": "input", "data_type": "wire", "width": 1}
                ],
                "signals": [
                    {"name": "cnt", "type": "reg", "width": 8}
                ]
            }
        ]
    }

def make_counter():
    return {
        "version": "1.0.0",
        "metadata": {
            "design_name": "counter", "description": "Simple counter",
            "top_module": "counter_top", "source_files": ["counter.v"],
            "generated_by": "test_gen", "generated_at": "2026-06-28T00:00:00Z"
        },
        "includes": ["defines.vh"],
        "defines": [{"name": "MAX", "value": "255"}, {"name": "WIDTH", "value": "8"}],
        "modules": [{
            "name": "counter_top", "description": "top counter",
            "parameters": [{"name": "W", "type": "parameter", "data_type": "int", "value": "8"}],
            "ports": [
                {"name": "clk", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                {"name": "rst", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                {"name": "out", "direction": "output", "data_type": "reg", "width": 8, "signed": False}
            ],
            "signals": [
                {"name": "count", "type": "reg", "width": 8, "initial_value": "8'h00"},
                {"name": "next_count", "type": "wire", "width": 8}
            ],
            "always_blocks": [{
                "id": "seq", "type": "always_ff",
                "sensitivity": [{"type": "posedge", "signal": "clk"}, {"type": "negedge", "signal": "rst"}],
                "body": [{"type": "if", "condition": {"op": "!", "operand": {"ref": "rst"}},
                    "then": [{"type": "assignment", "lhs": {"ref": "count"}, "rhs": {"literal": "8'h00"}, "blocking": False}],
                    "else": [{"type": "assignment", "lhs": {"ref": "count"}, "rhs": {"ref": "next_count"}, "blocking": False}]
                }]
            }],
            "assignments": [{
                "id": "inc", "lhs": {"ref": "next_count"},
                "rhs": {"op": "+", "left": {"ref": "count"}, "right": {"literal": "8'h01"}},
                "blocking": True
            }]
        }],
        "design_hierarchy": {"top": "counter_top", "tree": {"counter_top": []}}
    }

def make_multiport_module():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "multiport", "top_module": "top"},
        "modules": [{
            "name": "top",
            "ports": [{"name": f"p{i}", "direction": d, "data_type": "wire", "width": w, "signed": False}
                for i, (d, w) in enumerate(
                    [("input", 1), ("output", 8), ("input", 16), ("output", 32), ("inout", 8),
                     ("input", 1), ("output", 1), ("input", 4), ("output", 4), ("input", 8),
                     ("output", 16), ("input", 32), ("output", 64), ("input", 8), ("output", 8)]
                )],
            "signals": [{"name": f"s{i}", "type": "reg" if i % 2 == 0 else "wire", "width": i + 1}
                for i in range(20)]
        }]
    }

def make_nested_instance():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "nested", "top_module": "top"},
        "modules": [
            {"name": "leaf", "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 1}], "signals": []},
            {"name": "mid", "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 1}], "signals": [],
             "instances": [{"name": "u_leaf", "module": "leaf", "port_connections": [{"port": "a", "connection": {"ref": "a"}}]}]},
            {"name": "top", "ports": [{"name": "clk", "direction": "input", "data_type": "wire", "width": 1}],
             "signals": [{"name": "mid_sig", "type": "wire", "width": 1}],
             "instances": [{"name": "u_mid", "module": "mid", "port_connections": [{"port": "a", "connection": {"ref": "mid_sig"}}]}]}
        ]
    }

def make_param_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "param_design", "top_module": "configurable_adder"},
        "modules": [{
            "name": "configurable_adder",
            "parameters": [{"name": "WIDTH", "type": "parameter", "data_type": "int", "value": "16"},
                           {"name": "USE_PIPE", "type": "parameter", "data_type": "int", "value": "1"}],
            "ports": [
                {"name": "clk", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                {"name": "a", "direction": "input", "data_type": "wire", "width": 16, "signed": False},
                {"name": "b", "direction": "input", "data_type": "wire", "width": 16, "signed": False},
                {"name": "sum", "direction": "output", "data_type": "reg", "width": 16, "signed": False}
            ],
            "signals": [{"name": "w_sum", "type": "wire", "width": 16, "signed": False}],
            "assignments": [{"id": "calc", "lhs": {"ref": "w_sum"},
                "rhs": {"op": "+", "left": {"ref": "a"}, "right": {"ref": "b"}}, "blocking": True}],
            "always_blocks": [{"id": "pipe", "type": "always_ff",
                "sensitivity": [{"type": "posedge", "signal": "clk"}],
                "body": [{"type": "assignment", "lhs": {"ref": "sum"}, "rhs": {"ref": "w_sum"}, "blocking": False}]}]
        }]
    }

def make_fsm_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "fsm", "top_module": "fsm"},
        "modules": [{
            "name": "fsm",
            "ports": [
                {"name": "clk", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                {"name": "rst", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                {"name": "go", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                {"name": "done", "direction": "output", "data_type": "reg", "width": 1, "signed": False}
            ],
            "signals": [{"name": "state", "type": "reg", "width": 2, "initial_value": "2'b00"},
                        {"name": "next_state", "type": "wire", "width": 2}],
            "always_blocks": [
                {"id": "state_seq", "type": "always_ff",
                 "sensitivity": [{"type": "posedge", "signal": "clk"}, {"type": "negedge", "signal": "rst"}],
                 "body": [{"type": "if", "condition": {"op": "!", "operand": {"ref": "rst"}},
                    "then": [{"type": "assignment", "lhs": {"ref": "state"}, "rhs": {"literal": "2'b00"}, "blocking": False}],
                    "else": [{"type": "assignment", "lhs": {"ref": "state"}, "rhs": {"ref": "next_state"}, "blocking": False}]}]},
                {"id": "state_comb", "type": "always_comb", "sensitivity": [],
                 "body": [{"type": "case", "expression": {"ref": "state"},
                    "items": [{"value": {"op": "+", "left": {"literal": "2'b00"}, "right": {"literal": "2'b01"}},
                        "body": [{"type": "assignment", "lhs": {"ref": "next_state"}, "rhs": {"ref": "go"}, "blocking": True}]}],
                    "default": [{"type": "assignment", "lhs": {"ref": "done"}, "rhs": {"literal": "1'b1"}, "blocking": True}]}]}
            ]
        }]
    }

def make_generate_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "generate_test", "top_module": "gen_top"},
        "modules": [
            {"name": "adder_cell",
             "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 1},
                       {"name": "b", "direction": "input", "data_type": "wire", "width": 1},
                       {"name": "ci", "direction": "input", "data_type": "wire", "width": 1},
                       {"name": "s", "direction": "output", "data_type": "wire", "width": 1},
                       {"name": "co", "direction": "output", "data_type": "wire", "width": 1}], "signals": []},
            {"name": "gen_top",
             "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 4},
                       {"name": "b", "direction": "input", "data_type": "wire", "width": 4},
                       {"name": "sum", "direction": "output", "data_type": "wire", "width": 4}],
             "signals": [{"name": "c", "type": "wire", "width": 5}],
             "instances": [{"name": "u0", "module": "adder_cell",
                "port_connections": [{"port": "a", "connection": {"ref": "a"}}, {"port": "b", "connection": {"ref": "b"}},
                    {"port": "ci", "connection": {"literal": "1'b0"}}, {"port": "s", "connection": {"ref": "sum"}},
                    {"port": "co", "connection": {"ref": "c"}}]}],
             "generates": [{"condition": {"op": "==", "left": {"ref": "c"}, "right": {"literal": "1'b1"}},
                "body": [{"type": "instance", "name": "u_extra", "module": "adder_cell", "port_connections": []}]}]}
        ]
    }

def make_function_task_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "func_task", "top_module": "top"},
        "modules": [{
            "name": "top",
            "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 8},
                      {"name": "b", "direction": "input", "data_type": "wire", "width": 8},
                      {"name": "clk", "direction": "input", "data_type": "wire", "width": 1},
                      {"name": "result", "direction": "output", "data_type": "reg", "width": 16}],
            "signals": [{"name": "sum", "type": "wire", "width": 16}],
            "functions": [{"name": "mul", "return_type": "logic [15:0]",
                "inputs": [{"name": "x", "direction": "input", "data_type": "logic", "width": 8},
                           {"name": "y", "direction": "input", "data_type": "logic", "width": 8}],
                "body": [{"type": "return", "value": {"op": "*", "left": {"ref": "x"}, "right": {"ref": "y"}}}]}],
            "tasks": [{"name": "update_result",
                "inputs": [{"name": "val", "direction": "input", "data_type": "wire", "width": 16}], "outputs": [],
                "body": [{"type": "assignment", "lhs": {"ref": "result"}, "rhs": {"ref": "val"}, "blocking": True}]}],
            "assignments": [{"lhs": {"ref": "sum"},
                "rhs": {"type": "call", "function": "mul", "arguments": [{"ref": "a"}, {"ref": "b"}]}, "blocking": True}]
        }]
    }

def make_complex_expr_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "complex_expr", "top_module": "top"},
        "modules": [{
            "name": "top",
            "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 32},
                      {"name": "b", "direction": "input", "data_type": "wire", "width": 32},
                      {"name": "sel", "direction": "input", "data_type": "wire", "width": 2},
                      {"name": "out", "direction": "output", "data_type": "reg", "width": 32}],
            "signals": [{"name": "mux_out", "type": "wire", "width": 32}],
            "assignments": [{"lhs": {"ref": "mux_out"},
                "rhs": {"type": "cond", "condition": {"op": "==", "left": {"ref": "sel"}, "right": {"literal": "2'b00"}},
                    "true_expr": {"ref": "a"},
                    "false_expr": {"type": "cond", "condition": {"op": "==", "left": {"ref": "sel"}, "right": {"literal": "2'b01"}},
                        "true_expr": {"ref": "b"},
                        "false_expr": {"type": "concat", "parts": [
                            {"type": "replicate", "times": {"literal": "16"}, "value": {"literal": "1'b1"}},
                            {"literal": "16'h0000"}]}}}, "blocking": True}]
        }]
    }

def make_empty_metadata_valid():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "empty_meta", "top_module": "test"},
        "modules": [{"name": "test", "ports": [{"name": "clk", "direction": "input", "data_type": "wire", "width": 1}], "signals": []}]
    }

def make_multi_design_hierarchy():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "hier", "top_module": "top"},
        "modules": [
            {"name": "sub_a", "ports": [{"name": "i", "direction": "input", "data_type": "wire", "width": 1}], "signals": []},
            {"name": "sub_b", "ports": [{"name": "i", "direction": "input", "data_type": "wire", "width": 1}], "signals": []},
            {"name": "top", "ports": [{"name": "clk", "direction": "input", "data_type": "wire", "width": 1}],
             "signals": [{"name": "s", "type": "wire", "width": 1, "signed": True}],
             "instances": [{"name": "u_a", "module": "sub_a", "port_connections": [{"port": "i", "connection": {"ref": "clk"}}]},
                           {"name": "u_b", "module": "sub_b", "port_connections": [{"port": "i", "connection": {"ref": "clk"}}]}]}
        ],
        "design_hierarchy": {"top": "top", "tree": {"top": ["u_a", "u_b"], "sub_a": [], "sub_b": []}}
    }

def make_include_defines_only():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "include_defines_test", "top_module": "test",
            "description": "Test includes and defines only"},
        "includes": ["std.vh", "config.vh", "types.vh"],
        "defines": [{"name": "A", "value": "1"}, {"name": "B", "value": "2"},
                    {"name": "C", "value": "3"}, {"name": "D", "value": "4"}],
        "modules": [{"name": "test", "ports": [{"name": "clk", "direction": "input", "data_type": "wire", "width": 1}], "signals": []}]
    }

def make_signed_port_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "signed_test", "top_module": "top"},
        "modules": [{
            "name": "top",
            "ports": [
                {"name": "a", "direction": "input", "data_type": "wire", "width": 8, "signed": True},
                {"name": "b", "direction": "input", "data_type": "wire", "width": 8, "signed": True},
                {"name": "clk", "direction": "input", "data_type": "wire", "width": 1},
                {"name": "result", "direction": "output", "data_type": "reg", "width": 8, "signed": True}
            ],
            "signals": [{"name": "diff", "type": "wire", "width": 8, "signed": True}],
            "assignments": [{"lhs": {"ref": "diff"},
                "rhs": {"op": "-", "left": {"ref": "a"}, "right": {"ref": "b"}}, "blocking": True}],
            "always_blocks": [{"id": "reg_out", "type": "always_ff",
                "sensitivity": [{"type": "posedge", "signal": "clk"}],
                "body": [{"type": "assignment", "lhs": {"ref": "result"}, "rhs": {"ref": "diff"}, "blocking": False}]}]
        }]
    }

positive_cases = {
    'case_001_example': GOLDEN,
    'case_002_counter': make_counter(),
    'case_003_minimal': make_minimal_valid(),
    'case_004_multiport': make_multiport_module(),
    'case_005_nested_instance': make_nested_instance(),
    'case_006_param_design': make_param_design(),
    'case_007_fsm': make_fsm_design(),
    'case_008_generate': make_generate_design(),
    'case_009_func_task': make_function_task_design(),
    'case_010_complex_expr': make_complex_expr_design(),
    'case_011_empty_meta': make_empty_metadata_valid(),
    'case_012_hierarchy': make_multi_design_hierarchy(),
    'case_013_include_defines': make_include_defines_only(),
    'case_014_signed_ports': make_signed_port_design(),
}

# Additional positive case variants
def make_wide_bus():
    d = make_minimal_valid()
    d['metadata']['design_name'] = 'wide_bus'
    d['modules'][0]['ports'] = [{"name": f"bus{i}", "direction": "input", "data_type": "wire", "width": 256} for i in range(8)]
    return d

def make_multi_always():
    d = make_counter()
    d['metadata']['design_name'] = 'multi_always'
    d['modules'][0]['always_blocks'].append(deep_clone(d['modules'][0]['always_blocks'][0]))
    d['modules'][0]['always_blocks'][1]['id'] = 'seq2'
    return d

def make_package_usage():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "pkg_test", "top_module": "use_pkg"},
        "packages": [{"name": "pkg1", "items": [{"name": "WIDTH", "value": "32"}]}],
        "modules": [{"name": "use_pkg", "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 1}], "signals": []}]
    }

def make_fifo_template():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "fifo", "top_module": "fifo"},
        "modules": [{"name": "fifo", "ports": [
            {"name": "clk", "direction": "input", "data_type": "wire", "width": 1},
            {"name": "rst", "direction": "input", "data_type": "wire", "width": 1},
            {"name": "wr_en", "direction": "input", "data_type": "wire", "width": 1},
            {"name": "rd_en", "direction": "input", "data_type": "wire", "width": 1},
            {"name": "wdata", "direction": "input", "data_type": "wire", "width": 32},
            {"name": "rdata", "direction": "output", "data_type": "reg", "width": 32},
            {"name": "full", "direction": "output", "data_type": "reg", "width": 1},
            {"name": "empty", "direction": "output", "data_type": "reg", "width": 1}
        ], "signals": [{"name": "mem", "type": "reg", "width": 1024},
                       {"name": "wr_ptr", "type": "reg", "width": 5},
                       {"name": "rd_ptr", "type": "reg", "width": 5}]}]
    }

positive_cases_extra = {
    'case_015_wide_bus': make_wide_bus(),
    'case_016_multi_always': make_multi_always(),
    'case_017_package_usage': make_package_usage(),
    'case_018_fifo_template': make_fifo_template(),
}

for i in range(19, 36):
    d = make_minimal_valid()
    d['metadata']['design_name'] = f'variant_{i}'
    d['modules'][0]['name'] = f'variant_{i}'
    d['modules'][0]['ports'] = [{"name": f"p{j}", "direction": "input", "data_type": "wire", "width": j+1} for j in range(4)]
    d['modules'][0]['signals'] = [{"name": f"s{j}", "type": "reg", "width": j+1} for j in range(3)]
    positive_cases_extra[f'case_{i:03d}_variant'] = d

for name, data in positive_cases_extra.items():
    positive_cases[name] = data

# Write positive cases
for name, data in positive_cases.items():
    path = os.path.join(POS_DIR, f'{name}.json')
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)

# ===== Negative Cases =====
BASE_VALID = make_minimal_valid()

def clone_base():
    return deep_clone(BASE_VALID)

negative_cases = []

# --- Schema: Missing required fields (S002-S004, various sub-required) ---
nc = clone_base()
del nc['version']
negative_cases.append(('rule_required_version', 'missing_version.json', nc, 'S002'))

nc = clone_base()
del nc['metadata']
negative_cases.append(('rule_required_metadata', 'missing_metadata.json', nc, 'S003'))

nc = clone_base()
del nc['modules']
negative_cases.append(('rule_required_modules', 'missing_modules.json', nc, 'S004'))

nc = clone_base()
del nc['metadata']['design_name']
negative_cases.append(('rule_required_design_name', 'missing_metadata_design_name.json', nc, 'S007'))

nc = clone_base()
del nc['metadata']['top_module']
negative_cases.append(('rule_required_top_module', 'missing_metadata_top_module.json', nc, 'S010'))

nc = clone_base()
del nc['modules'][0]['name']
negative_cases.append(('rule_required_module_name', 'missing_module_name.json', nc, 'S024'))

nc = clone_base()
del nc['modules'][0]['ports']
negative_cases.append(('rule_required_ports', 'missing_module_ports.json', nc, 'S024'))

nc = clone_base()
del nc['modules'][0]['signals']
negative_cases.append(('rule_required_signals', 'missing_module_signals.json', nc, 'S024'))

nc = clone_base()
del nc['modules'][0]['ports'][0]['direction']
negative_cases.append(('rule_required_port_direction', 'missing_port_direction.json', nc, 'S001'))

nc = clone_base()
del nc['modules'][0]['ports'][0]['data_type']
negative_cases.append(('rule_required_port_data_type', 'missing_port_data_type.json', nc, 'S001'))

nc = clone_base()
del nc['modules'][0]['ports'][0]['width']
negative_cases.append(('rule_required_port_width', 'missing_port_width.json', nc, 'S001'))

nc = clone_base()
del nc['modules'][0]['signals'][0]['type']
negative_cases.append(('rule_required_signal_type', 'missing_signal_type.json', nc, 'S001'))

nc = clone_base()
del nc['modules'][0]['signals'][0]['width']
negative_cases.append(('rule_required_signal_width', 'missing_signal_width.json', nc, 'S001'))

nc = clone_base()
nc['defines'] = [{"value": "32"}]
negative_cases.append(('rule_required_define_name', 'missing_define_name.json', nc, 'S018'))

nc = clone_base()
nc['defines'] = [{"name": "MYDEF"}]
negative_cases.append(('rule_required_define_value', 'missing_define_value.json', nc, 'S019'))

nc = clone_base()
nc['modules'][0]['parameters'] = [{"value": "8"}]
negative_cases.append(('rule_required_param_name', 'missing_parameter_name.json', nc, '--'))

nc = clone_base()
nc['modules'][0]['parameters'] = [{"name": "W"}]
negative_cases.append(('rule_required_param_value', 'missing_parameter_value.json', nc, '--'))

nc = clone_base()
nc['metadata']['source_files'] = "not_an_array"
negative_cases.append(('rule_required_metadata_source_files_type', 'source_files_not_array.json', nc, 'S008'))

# --- Type errors ---
nc = clone_base()
nc['version'] = 123
negative_cases.append(('rule_type_version', 'version_as_number.json', nc, 'S005'))

nc = clone_base()
nc['metadata'] = [1, 2, 3]
negative_cases.append(('rule_type_metadata', 'metadata_as_array.json', nc, 'S006'))

nc = clone_base()
nc['includes'] = {"bad": "data"}
negative_cases.append(('rule_type_includes', 'includes_as_object.json', nc, 'S014'))

nc = clone_base()
nc['modules'] = {"bad": "data"}
negative_cases.append(('rule_type_modules', 'modules_as_object.json', nc, 'S024'))

nc = clone_base()
nc['modules'][0]['ports'][0]['direction'] = 123
negative_cases.append(('rule_type_direction', 'port_direction_as_number.json', nc, 'S001'))

nc = clone_base()
nc['modules'][0]['ports'][0]['width'] = "not_a_number"
negative_cases.append(('rule_type_width', 'port_width_as_string.json', nc, 'S001'))

nc = clone_base()
nc['modules'][0]['ports'][0]['name'] = 999
negative_cases.append(('rule_type_port_name', 'port_name_as_number.json', nc, 'S001'))

nc = clone_base()
nc['modules'][0]['signals'][0]['name'] = ["bad"]
negative_cases.append(('rule_type_signal_name', 'signal_name_as_array.json', nc, 'S001'))

nc = clone_base()
nc['modules'][0]['signals'][0]['type'] = 42
negative_cases.append(('rule_type_signal_type', 'signal_type_as_number.json', nc, 'S001'))

nc = clone_base()
nc['metadata']['design_name'] = 987
negative_cases.append(('rule_type_design_name', 'design_name_as_number.json', nc, 'S007'))

nc = clone_base()
nc['metadata']['top_module'] = ['x']
negative_cases.append(('rule_type_top_module', 'top_module_as_array.json', nc, 'S010'))

nc = clone_base()
nc['defines'] = ["bad_item"]
negative_cases.append(('rule_type_define_item', 'defines_item_as_string.json', nc, 'S017'))

nc = clone_base()
nc['modules'][0]['name'] = 456
negative_cases.append(('rule_type_module_name', 'module_name_as_number.json', nc, 'S024'))

nc = clone_base()
nc['includes'] = [123, 456]
negative_cases.append(('rule_type_include_item', 'includes_item_not_string.json', nc, 'S015'))

nc = clone_base()
nc['modules'][0]['ports'][0]['signed'] = "yes"
negative_cases.append(('rule_type_signed', 'signed_as_string.json', nc, 'S001'))

# --- Enum violations ---
nc = clone_base()
nc['modules'][0]['ports'][0]['direction'] = "bidir"
negative_cases.append(('rule_enum_direction_bidir', 'direction_bidir.json', nc, 'S001'))

nc = clone_base()
nc['modules'][0]['ports'][0]['direction'] = "invalid"
negative_cases.append(('rule_enum_direction_invalid', 'direction_invalid.json', nc, 'S001'))

nc = clone_base()
nc['modules'][0]['always_blocks'] = [{"id": "b1", "type": "always_bad", "body": []}]
negative_cases.append(('rule_enum_always_type', 'bad_always_type.json', nc, 'S001'))

nc = clone_base()
nc['metadata'] = {"design_name": "test", "top_module": "test", "generated_at": "not-a-date"}
negative_cases.append(('rule_metadata_date', 'bad_date_format.json', nc, 'S013'))

# --- Business rule B008: duplicate module names ---
nc = clone_base()
nc['modules'].append(deep_clone(nc['modules'][0]))
negative_cases.append(('rule_B008_dup_module_name', 'dup_module_name.json', nc, 'B008'))

# --- Business rule B002: duplicate port names ---
nc = clone_base()
nc['modules'][0]['ports'].append({"name": "clk", "direction": "input", "data_type": "wire", "width": 1})
negative_cases.append(('rule_B002_dup_port_name', 'dup_port_name.json', nc, 'B002'))

# --- Business rule B001: duplicate signal names ---
nc = clone_base()
nc['modules'][0]['signals'].append({"name": "cnt", "type": "reg", "width": 8})
negative_cases.append(('rule_B001_dup_signal_name', 'dup_signal_name.json', nc, 'B001'))

# --- Business rule B003: instance module not existing ---
nc = clone_base()
nc['modules'][0]['instances'] = [{"name": "u_x", "module": "non_existent_module", "port_connections": []}]
negative_cases.append(('rule_B003_bad_instance', 'nonexistent_module.json', nc, 'B003'))

# --- Business rule B005: parameter value type ---
nc = clone_base()
nc['modules'][0]['parameters'] = [{"name": "X", "type": "parameter", "value": 123}]
negative_cases.append(('rule_B005_param_value_type', 'param_value_as_number.json', nc, 'B005'))

# --- Type: defines as object ---
nc = clone_base()
nc['defines'] = {"name": "X", "value": "1"}
negative_cases.append(('rule_type_defines', 'defines_as_object.json', nc, 'S016'))

# --- Additional Business rule tests ---
# B004: port_connection_count
nc = clone_base()
nc['modules'][0]['instances'] = [{"name": "u_x", "module": "top", "port_connections": []}]
negative_cases.append(('rule_B004_port_count', 'port_count_mismatch.json', nc, 'B004'))

# B006: always_block_id_unique
nc = clone_base()
nc['modules'][0]['always_blocks'] = [
    {"id": "b1", "type": "always_ff", "sensitivity": [{"type": "posedge", "signal": "clk"}],
     "body": [{"type": "assignment", "lhs": {"ref": "a"}, "rhs": {"literal": "1'b0"}, "blocking": False}]},
    {"id": "b1", "type": "always_ff", "sensitivity": [{"type": "negedge", "signal": "rst"}],
     "body": [{"type": "assignment", "lhs": {"ref": "b"}, "rhs": {"literal": "1'b1"}, "blocking": False}]}
]
negative_cases.append(('rule_B006_always_id_dup', 'always_id_dup.json', nc, 'B006'))

# B007: instance_name_unique
nc = clone_base()
nc['modules'][0]['instances'] = [
    {"name": "u_same", "module": "top", "port_connections": []},
    {"name": "u_same", "module": "top", "port_connections": []}
]
negative_cases.append(('rule_B007_instance_name_dup', 'instance_name_dup.json', nc, 'B007'))

# B009: port_direction_connection_match (input driven inside same module)
nc = clone_base()
nc['metadata']['design_name'] = 'direction_mismatch'
nc['modules'][0]['name'] = 'child'
nc['modules'][0]['ports'] = [{"name": "p", "direction": "input", "data_type": "wire", "width": 1}]
nc['modules'][0]['assignments'] = [{"lhs": {"ref": "p"}, "rhs": {"literal": "1'b1"}, "blocking": True}]
negative_cases.append(('rule_B009_direction_mismatch', 'direction_mismatch.json', nc, 'B009'))

# B010: version_format
nc = clone_base()
nc['version'] = "not.a.version"
negative_cases.append(('rule_B010_version_format', 'bad_version_format.json', nc, 'B010'))

# B011: function_body_has_return
nc = clone_base()
nc['modules'][0]['functions'] = [{"name": "no_return", "return_type": "int",
    "inputs": [], "body": [{"type": "assignment", "lhs": {"ref": "x"}, "rhs": {"literal": "1"}, "blocking": True}]}]
negative_cases.append(('rule_B011_func_no_return', 'function_no_return.json', nc, 'B011'))

# B012: always_comb sensitivity list
nc = clone_base()
nc['modules'][0]['always_blocks'] = [{"id": "comb_bad", "type": "always_comb",
    "sensitivity": [{"type": "posedge", "signal": "clk"}],
    "body": [{"type": "assignment", "lhs": {"ref": "a"}, "rhs": {"literal": "1'b0"}, "blocking": True}]}]
negative_cases.append(('rule_B012_comb_sensitivity', 'comb_with_sensitivity.json', nc, 'B012'))

# Write negative cases
for rule_dir, fname, data, rule_id in negative_cases:
    rule_path = os.path.join(NEG_DIR, rule_dir)
    os.makedirs(rule_path, exist_ok=True)
    with open(os.path.join(rule_path, fname), 'w') as f:
        json.dump(data, f, indent=2)

# ===== Robustness Cases =====
robustness_cases = []

robustness_cases.append(('empty_file.json', '', 1))
robustness_cases.append(('not_json.txt', 'This is not JSON content', 1))
robustness_cases.append(('xml_content.xml', '<?xml version="1.0"?><root><item>value</item></root>', 1))
robustness_cases.append(('truncated.json', '{"version": "1.0.0", "metadata": {', 1))

def make_deep_nested(depth):
    if depth <= 0:
        return {"ref": "x"}
    return {"op": "+", "left": make_deep_nested(depth - 1), "right": {"literal": "1'b1"}}

deep_data = clone_base()
deep_data['modules'][0]['assignments'] = [{"lhs": {"ref": "cnt"}, "rhs": make_deep_nested(600), "blocking": True}]
robustness_cases.append(('deep_nested_600.json', json.dumps(deep_data, indent=2), 0))

long_data = clone_base()
long_data['version'] = '9.9.9' + 'x' * 99995
robustness_cases.append(('long_version_string.json', json.dumps(long_data, indent=2), 0))

null_data = clone_base()
null_data['version'] = None
robustness_cases.append(('null_version.json', json.dumps(null_data, indent=2), 1))

bool_data = 'true'
robustness_cases.append(('boolean_root.json', bool_data, 1))

arr_root = json.dumps([1, 2, 3])
robustness_cases.append(('array_root.json', arr_root, 1))

unicode_data = clone_base()
unicode_data['metadata']['design_name'] = "\u00e9\u00e8\u00f1"
robustness_cases.append(('unicode_design_name.json', json.dumps(unicode_data, indent=2), 0))

deep_obj = clone_base()
d = deep_obj
for _ in range(200):
    d['metadata'] = {"design_name": "nested", "top_module": "x"}
    d = d['metadata']
robustness_cases.append(('deeply_nested_meta.json', json.dumps(deep_obj, indent=2), 0))

large_num = clone_base()
large_num['modules'][0]['ports'][0]['width'] = 10**10
robustness_cases.append(('huge_width.json', json.dumps(large_num, indent=2), 0))

# Additional robustness cases
neg_array = json.dumps(None)
robustness_cases.append(('null_root.json', neg_array, 1))

huge_nested_array = clone_base()
huge_nested_array['modules'] = [[{"x": i} for i in range(100)]]
robustness_cases.append(('huge_nested_array.json', json.dumps(huge_nested_array, indent=2), 1))

for fname, content, _ in robustness_cases:
    with open(os.path.join(ROB_DIR, fname), 'w') as f:
        f.write(content)

# ===== Manifest CSV =====
ROBUSTNESS_EXPECT_KEYWORD = {
    'empty_file.json': 'false',
    'not_json.txt': 'false',
    'xml_content.xml': 'false',
    'truncated.json': 'false',
    'deep_nested_600.json': 'true',
    'long_version_string.json': 'true',
    'null_version.json': 'false',
    'boolean_root.json': 'false',
    'array_root.json': 'false',
    'unicode_design_name.json': 'true',
    'deeply_nested_meta.json': 'true',
    'huge_width.json': 'true',
    'null_root.json': 'false',
    'huge_nested_array.json': 'false',
}

manifest_path = os.path.join(OUT_DIR, 'manifest.csv')
with open(manifest_path, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['file', 'category', 'expected_keyword', 'expected_exit_code'])
    for name in positive_cases:
        fpath = f'positive/{name}.json'
        writer.writerow([fpath, 'positive', 'true', 0])
    for rule_dir, fname, _, rule_id in negative_cases:
        fpath = f'negative/{rule_dir}/{fname}'
        writer.writerow([fpath, 'negative', 'false', 1])
    for fname, _, exit_code in robustness_cases:
        fpath = f'robustness/{fname}'
        kw = ROBUSTNESS_EXPECT_KEYWORD.get(fname, 'false')
        writer.writerow([fpath, 'robustness', kw, exit_code])

# ===== Copy full_rules.json snapshot =====
import shutil
src_rules = os.path.join(PROJ_DIR, 'full_rules.json')
if os.path.exists(src_rules):
    shutil.copy2(src_rules, os.path.join(OUT_DIR, 'full_rules.json'))

# ===== Generate metadata file =====
with open(os.path.join(SPECS_DIR, 'VERILOG_JSON_BIDIRECTIONAL_SPEC.md'), 'rb') as f:
    spec_hash = hashlib.sha256(f.read()).hexdigest()

meta = {
    'timestamp': TIMESTAMP,
    'spec_hash': spec_hash,
    'positive_count': len(positive_cases),
    'negative_count': len(negative_cases),
    'robustness_count': len(robustness_cases),
    'total': len(positive_cases) + len(negative_cases) + len(robustness_cases),
}
with open(os.path.join(OUT_DIR, 'metadata.json'), 'w') as f:
    json.dump(meta, f, indent=2)

print(f"Dataset generated: {OUT_DIR}")
print(f"  Positive: {len(positive_cases)}")
print(f"  Negative: {len(negative_cases)}")
print(f"  Robustness: {len(robustness_cases)}")
print(f"  Total: {meta['total']}")
