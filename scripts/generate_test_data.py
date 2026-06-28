#!/usr/bin/env python3
import json
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJ_DIR = os.path.dirname(BASE_DIR)
SPECS_DIR = os.path.join(PROJ_DIR, 'specs')
TEST_DIR = os.path.join(PROJ_DIR, 'test_suite')
POS_DIR = os.path.join(TEST_DIR, 'positive')
NEG_DIR = os.path.join(TEST_DIR, 'negative')
ROB_DIR = os.path.join(TEST_DIR, 'robustness')

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
            "design_name": "counter",
            "description": "Simple counter",
            "top_module": "counter_top",
            "source_files": ["counter.v"],
            "generated_by": "test_gen",
            "generated_at": "2026-06-28T00:00:00Z"
        },
        "includes": ["defines.vh"],
        "defines": [
            {"name": "MAX", "value": "255"},
            {"name": "WIDTH", "value": "8"}
        ],
        "modules": [
            {
                "name": "counter_top",
                "description": "top counter",
                "parameters": [
                    {"name": "W", "type": "parameter", "data_type": "int", "value": "8"}
                ],
                "ports": [
                    {"name": "clk", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                    {"name": "rst", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                    {"name": "out", "direction": "output", "data_type": "reg", "width": 8, "signed": False}
                ],
                "signals": [
                    {"name": "count", "type": "reg", "width": 8, "initial_value": "8'h00"},
                    {"name": "next_count", "type": "wire", "width": 8}
                ],
                "always_blocks": [
                    {
                        "id": "seq",
                        "type": "always_ff",
                        "sensitivity": [
                            {"type": "posedge", "signal": "clk"},
                            {"type": "negedge", "signal": "rst"}
                        ],
                        "body": [
                            {
                                "type": "if",
                                "condition": {"op": "!", "operand": {"ref": "rst"}},
                                "then": [
                                    {"type": "assignment", "lhs": {"ref": "count"}, "rhs": {"literal": "8'h00"}, "blocking": False}
                                ],
                                "else": [
                                    {"type": "assignment", "lhs": {"ref": "count"}, "rhs": {"ref": "next_count"}, "blocking": False}
                                ]
                            }
                        ]
                    }
                ],
                "assignments": [
                    {
                        "id": "inc",
                        "lhs": {"ref": "next_count"},
                        "rhs": {"op": "+", "left": {"ref": "count"}, "right": {"literal": "8'h01"}},
                        "blocking": True
                    }
                ]
            }
        ],
        "design_hierarchy": {"top": "counter_top", "tree": {"counter_top": []}}
    }


def make_multiport_module():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "multiport", "top_module": "top"},
        "modules": [
            {
                "name": "top",
                "ports": [
                    {"name": "p" + str(i), "direction": d, "data_type": "wire", "width": w, "signed": False}
                    for i, (d, w) in enumerate(
                        [("input", 1), ("output", 8), ("input", 16), ("output", 32), ("inout", 8),
                         ("input", 1), ("output", 1), ("input", 4), ("output", 4), ("input", 8),
                         ("output", 16), ("input", 32), ("output", 64), ("input", 8), ("output", 8)]
                    )
                ],
                "signals": [
                    {"name": "s" + str(i), "type": "reg" if i % 2 == 0 else "wire", "width": i + 1}
                    for i in range(20)
                ]
            }
        ]
    }


def make_nested_instance():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "nested", "top_module": "top"},
        "modules": [
            {
                "name": "leaf",
                "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 1}],
                "signals": []
            },
            {
                "name": "mid",
                "ports": [{"name": "a", "direction": "input", "data_type": "wire", "width": 1}],
                "signals": [],
                "instances": [
                    {"name": "u_leaf", "module": "leaf", "port_connections": [{"port": "a", "connection": {"ref": "a"}}]}
                ]
            },
            {
                "name": "top",
                "ports": [{"name": "clk", "direction": "input", "data_type": "wire", "width": 1}],
                "signals": [{"name": "mid_sig", "type": "wire", "width": 1}],
                "instances": [
                    {"name": "u_mid", "module": "mid", "port_connections": [{"port": "a", "connection": {"ref": "mid_sig"}}]}
                ]
            }
        ]
    }


def make_param_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "param_design", "top_module": "configurable_adder"},
        "modules": [
            {
                "name": "configurable_adder",
                "parameters": [
                    {"name": "WIDTH", "type": "parameter", "data_type": "int", "value": "16"},
                    {"name": "USE_PIPE", "type": "parameter", "data_type": "int", "value": "1"}
                ],
                "ports": [
                    {"name": "clk", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                    {"name": "a", "direction": "input", "data_type": "wire", "width": 16, "signed": False},
                    {"name": "b", "direction": "input", "data_type": "wire", "width": 16, "signed": False},
                    {"name": "sum", "direction": "output", "data_type": "reg", "width": 16, "signed": False}
                ],
                "signals": [
                    {"name": "w_sum", "type": "wire", "width": 16, "signed": False}
                ],
                "assignments": [
                    {
                        "id": "calc",
                        "lhs": {"ref": "w_sum"},
                        "rhs": {"op": "+", "left": {"ref": "a"}, "right": {"ref": "b"}},
                        "blocking": True
                    }
                ],
                "always_blocks": [
                    {
                        "id": "pipe",
                        "type": "always_ff",
                        "sensitivity": [{"type": "posedge", "signal": "clk"}],
                        "body": [
                            {"type": "assignment", "lhs": {"ref": "sum"}, "rhs": {"ref": "w_sum"}, "blocking": False}
                        ]
                    }
                ]
            }
        ]
    }


def make_fsm_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "fsm", "top_module": "fsm"},
        "modules": [
            {
                "name": "fsm",
                "ports": [
                    {"name": "clk", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                    {"name": "rst", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                    {"name": "go", "direction": "input", "data_type": "wire", "width": 1, "signed": False},
                    {"name": "done", "direction": "output", "data_type": "reg", "width": 1, "signed": False}
                ],
                "signals": [
                    {"name": "state", "type": "reg", "width": 2, "initial_value": "2'b00"},
                    {"name": "next_state", "type": "wire", "width": 2}
                ],
                "always_blocks": [
                    {
                        "id": "state_seq",
                        "type": "always_ff",
                        "sensitivity": [{"type": "posedge", "signal": "clk"}, {"type": "negedge", "signal": "rst"}],
                        "body": [
                            {
                                "type": "if",
                                "condition": {"op": "!", "operand": {"ref": "rst"}},
                                "then": [{"type": "assignment", "lhs": {"ref": "state"}, "rhs": {"literal": "2'b00"}, "blocking": False}],
                                "else": [{"type": "assignment", "lhs": {"ref": "state"}, "rhs": {"ref": "next_state"}, "blocking": False}]
                            }
                        ]
                    },
                    {
                        "id": "state_comb",
                        "type": "always_comb",
                        "sensitivity": [],
                        "body": [
                            {
                                "type": "case",
                                "expression": {"ref": "state"},
                                "items": [
                                    {
                                        "value": {"op": "+", "left": {"literal": "2'b00"}, "right": {"literal": "2'b01"}},
                                        "body": [{"type": "assignment", "lhs": {"ref": "next_state"}, "rhs": {"ref": "go"}, "blocking": True}]
                                    }
                                ],
                                "default": [{"type": "assignment", "lhs": {"ref": "done"}, "rhs": {"literal": "1'b1"}, "blocking": True}]
                            }
                        ]
                    }
                ]
            }
        ]
    }


def make_generate_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "generate_test", "top_module": "gen_top"},
        "modules": [
            {
                "name": "adder_cell",
                "ports": [
                    {"name": "a", "direction": "input", "data_type": "wire", "width": 1},
                    {"name": "b", "direction": "input", "data_type": "wire", "width": 1},
                    {"name": "ci", "direction": "input", "data_type": "wire", "width": 1},
                    {"name": "s", "direction": "output", "data_type": "wire", "width": 1},
                    {"name": "co", "direction": "output", "data_type": "wire", "width": 1}
                ],
                "signals": []
            },
            {
                "name": "gen_top",
                "ports": [
                    {"name": "a", "direction": "input", "data_type": "wire", "width": 4},
                    {"name": "b", "direction": "input", "data_type": "wire", "width": 4},
                    {"name": "sum", "direction": "output", "data_type": "wire", "width": 4}
                ],
                "signals": [{"name": "c", "type": "wire", "width": 5}],
                "instances": [
                    {
                        "name": "u0",
                        "module": "adder_cell",
                        "port_connections": [
                            {"port": "a", "connection": {"ref": "a"}},
                            {"port": "b", "connection": {"ref": "b"}},
                            {"port": "ci", "connection": {"literal": "1'b0"}},
                            {"port": "s", "connection": {"ref": "sum"}},
                            {"port": "co", "connection": {"ref": "c"}}
                        ]
                    }
                ],
                "generates": [
                    {
                        "condition": {"op": "==", "left": {"ref": "c"}, "right": {"literal": "1'b1"}},
                        "body": [
                            {
                                "type": "instance",
                                "name": "u_extra",
                                "module": "adder_cell",
                                "port_connections": []
                            }
                        ]
                    }
                ]
            }
        ]
    }


def make_function_task_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "func_task", "top_module": "top"},
        "modules": [
            {
                "name": "top",
                "ports": [
                    {"name": "a", "direction": "input", "data_type": "wire", "width": 8},
                    {"name": "b", "direction": "input", "data_type": "wire", "width": 8},
                    {"name": "clk", "direction": "input", "data_type": "wire", "width": 1},
                    {"name": "result", "direction": "output", "data_type": "reg", "width": 16}
                ],
                "signals": [{"name": "sum", "type": "wire", "width": 16}],
                "functions": [
                    {
                        "name": "mul",
                        "return_type": "logic [15:0]",
                        "inputs": [
                            {"name": "x", "direction": "input", "data_type": "logic", "width": 8},
                            {"name": "y", "direction": "input", "data_type": "logic", "width": 8}
                        ],
                        "body": [
                            {"type": "return", "value": {"op": "*", "left": {"ref": "x"}, "right": {"ref": "y"}}}
                        ]
                    }
                ],
                "tasks": [
                    {
                        "name": "update_result",
                        "inputs": [{"name": "val", "direction": "input", "data_type": "wire", "width": 16}],
                        "outputs": [],
                        "body": [
                            {"type": "assignment", "lhs": {"ref": "result"}, "rhs": {"ref": "val"}, "blocking": True}
                        ]
                    }
                ],
                "assignments": [
                    {
                        "lhs": {"ref": "sum"},
                        "rhs": {"type": "call", "function": "mul", "arguments": [{"ref": "a"}, {"ref": "b"}]},
                        "blocking": True
                    }
                ]
            }
        ]
    }


def make_complex_expr_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "complex_expr", "top_module": "top"},
        "modules": [
            {
                "name": "top",
                "ports": [
                    {"name": "a", "direction": "input", "data_type": "wire", "width": 32},
                    {"name": "b", "direction": "input", "data_type": "wire", "width": 32},
                    {"name": "sel", "direction": "input", "data_type": "wire", "width": 2},
                    {"name": "out", "direction": "output", "data_type": "reg", "width": 32}
                ],
                "signals": [
                    {"name": "mux_out", "type": "wire", "width": 32}
                ],
                "assignments": [
                    {
                        "lhs": {"ref": "mux_out"},
                        "rhs": {
                            "type": "cond",
                            "condition": {"op": "==", "left": {"ref": "sel"}, "right": {"literal": "2'b00"}},
                            "true_expr": {"ref": "a"},
                            "false_expr": {
                                "type": "cond",
                                "condition": {"op": "==", "left": {"ref": "sel"}, "right": {"literal": "2'b01"}},
                                "true_expr": {"ref": "b"},
                                "false_expr": {
                                    "type": "concat",
                                    "parts": [
                                        {"type": "replicate", "times": {"literal": "16"}, "value": {"literal": "1'b1"}},
                                        {"literal": "16'h0000"}
                                    ]
                                }
                            }
                        },
                        "blocking": True
                    }
                ]
            }
        ]
    }


def make_empty_metadata_valid():
    return {
        "version": "1.0.0",
        "metadata": {
            "design_name": "empty_meta",
            "top_module": "test"
        },
        "modules": [
            {
                "name": "test",
                "ports": [{"name": "clk", "direction": "input", "data_type": "wire", "width": 1}],
                "signals": []
            }
        ]
    }


def make_multi_design_hierarchy():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "hier", "top_module": "top"},
        "modules": [
            {
                "name": "sub_a",
                "ports": [{"name": "i", "direction": "input", "data_type": "wire", "width": 1}],
                "signals": []
            },
            {
                "name": "sub_b",
                "ports": [{"name": "i", "direction": "input", "data_type": "wire", "width": 1}],
                "signals": []
            },
            {
                "name": "top",
                "ports": [{"name": "clk", "direction": "input", "data_type": "wire", "width": 1}],
                "signals": [{"name": "s", "type": "wire", "width": 1, "signed": True}],
                "instances": [
                    {"name": "u_a", "module": "sub_a", "port_connections": [{"port": "i", "connection": {"ref": "clk"}}]},
                    {"name": "u_b", "module": "sub_b", "port_connections": [{"port": "i", "connection": {"ref": "clk"}}]}
                ]
            }
        ],
        "design_hierarchy": {
            "top": "top",
            "tree": {"top": ["u_a", "u_b"], "sub_a": [], "sub_b": []}
        }
    }


def make_include_defines_only():
    return {
        "version": "1.0.0",
        "metadata": {
            "design_name": "include_defines_test",
            "top_module": "test",
            "description": "Test includes and defines only"
        },
        "includes": ["std.vh", "config.vh", "types.vh"],
        "defines": [
            {"name": "A", "value": "1"},
            {"name": "B", "value": "2"},
            {"name": "C", "value": "3"},
            {"name": "D", "value": "4"}
        ],
        "modules": [
            {
                "name": "test",
                "ports": [{"name": "clk", "direction": "input", "data_type": "wire", "width": 1}],
                "signals": []
            }
        ]
    }


def make_signed_port_design():
    return {
        "version": "1.0.0",
        "metadata": {"design_name": "signed_test", "top_module": "top"},
        "modules": [
            {
                "name": "top",
                "ports": [
                    {"name": "a", "direction": "input", "data_type": "wire", "width": 8, "signed": True},
                    {"name": "b", "direction": "input", "data_type": "wire", "width": 8, "signed": True},
                    {"name": "clk", "direction": "input", "data_type": "wire", "width": 1},
                    {"name": "result", "direction": "output", "data_type": "reg", "width": 8, "signed": True}
                ],
                "signals": [
                    {"name": "diff", "type": "wire", "width": 8, "signed": True}
                ],
                "assignments": [
                    {
                        "lhs": {"ref": "diff"},
                        "rhs": {"op": "-", "left": {"ref": "a"}, "right": {"ref": "b"}},
                        "blocking": True
                    }
                ],
                "always_blocks": [
                    {
                        "id": "reg_out",
                        "type": "always_ff",
                        "sensitivity": [{"type": "posedge", "signal": "clk"}],
                        "body": [
                            {"type": "assignment", "lhs": {"ref": "result"}, "rhs": {"ref": "diff"}, "blocking": False}
                        ]
                    }
                ]
            }
        ]
    }


# ===== Positive Cases =====
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

for i, (name, data) in enumerate(positive_cases.items()):
    path = os.path.join(POS_DIR, f'{name}.json')
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)

# ===== Negative Cases =====
BASE_VALID = make_minimal_valid()

def clone_base():
    return deep_clone(BASE_VALID)

negative_cases = []

# --- Missing required fields ---
nc = clone_base()
del nc['version']
negative_cases.append(('rule_required_version', 'missing_version.json', nc))

nc = clone_base()
del nc['metadata']
negative_cases.append(('rule_required_metadata', 'missing_metadata.json', nc))

nc = clone_base()
del nc['modules']
negative_cases.append(('rule_required_modules', 'missing_modules.json', nc))

nc = clone_base()
del nc['metadata']['design_name']
negative_cases.append(('rule_required_design_name', 'missing_metadata_design_name.json', nc))

nc = clone_base()
del nc['metadata']['top_module']
negative_cases.append(('rule_required_top_module', 'missing_metadata_top_module.json', nc))

nc = clone_base()
del nc['modules'][0]['name']
negative_cases.append(('rule_required_module_name', 'missing_module_name.json', nc))

nc = clone_base()
del nc['modules'][0]['ports']
negative_cases.append(('rule_required_ports', 'missing_module_ports.json', nc))

nc = clone_base()
del nc['modules'][0]['signals']
negative_cases.append(('rule_required_signals', 'missing_module_signals.json', nc))

nc = clone_base()
del nc['modules'][0]['ports'][0]['direction']
negative_cases.append(('rule_required_port_direction', 'missing_port_direction.json', nc))

nc = clone_base()
del nc['modules'][0]['ports'][0]['data_type']
negative_cases.append(('rule_required_port_data_type', 'missing_port_data_type.json', nc))

nc = clone_base()
del nc['modules'][0]['ports'][0]['width']
negative_cases.append(('rule_required_port_width', 'missing_port_width.json', nc))

nc = clone_base()
del nc['modules'][0]['signals'][0]['type']
negative_cases.append(('rule_required_signal_type', 'missing_signal_type.json', nc))

nc = clone_base()
del nc['modules'][0]['signals'][0]['width']
negative_cases.append(('rule_required_signal_width', 'missing_signal_width.json', nc))

nc = clone_base()
nc['defines'] = [{"value": "32"}]
negative_cases.append(('rule_required_define_name', 'missing_define_name.json', nc))

nc = clone_base()
nc['defines'] = [{"name": "MYDEF"}]
negative_cases.append(('rule_required_define_value', 'missing_define_value.json', nc))

nc = clone_base()
nc['modules'][0]['parameters'] = [{"value": "8"}]
negative_cases.append(('rule_required_param_name', 'missing_parameter_name.json', nc))

nc = clone_base()
nc['modules'][0]['parameters'] = [{"name": "W"}]
negative_cases.append(('rule_required_param_value', 'missing_parameter_value.json', nc))

nc = clone_base()
nc['metadata']['source_files'] = "not_an_array"
negative_cases.append(('rule_required_metadata_source_files_type', 'source_files_not_array.json', nc))

# --- Type errors ---
nc = clone_base()
nc['version'] = 123
negative_cases.append(('rule_type_version', 'version_as_number.json', nc))

nc = clone_base()
nc['metadata'] = [1, 2, 3]
negative_cases.append(('rule_type_metadata', 'metadata_as_array.json', nc))

nc = clone_base()
nc['includes'] = {"bad": "data"}
negative_cases.append(('rule_type_includes', 'includes_as_object.json', nc))

nc = clone_base()
nc['modules'] = {"bad": "data"}
negative_cases.append(('rule_type_modules', 'modules_as_object.json', nc))

nc = clone_base()
nc['modules'][0]['ports'][0]['direction'] = 123
negative_cases.append(('rule_type_direction', 'port_direction_as_number.json', nc))

nc = clone_base()
nc['modules'][0]['ports'][0]['width'] = "not_a_number"
negative_cases.append(('rule_type_width', 'port_width_as_string.json', nc))

nc = clone_base()
nc['modules'][0]['ports'][0]['name'] = 999
negative_cases.append(('rule_type_port_name', 'port_name_as_number.json', nc))

nc = clone_base()
nc['modules'][0]['signals'][0]['name'] = ["bad"]
negative_cases.append(('rule_type_signal_name', 'signal_name_as_array.json', nc))

nc = clone_base()
nc['modules'][0]['signals'][0]['type'] = 42
negative_cases.append(('rule_type_signal_type', 'signal_type_as_number.json', nc))

nc = clone_base()
nc['metadata']['design_name'] = 987
negative_cases.append(('rule_type_design_name', 'design_name_as_number.json', nc))

nc = clone_base()
nc['metadata']['top_module'] = ['x']
negative_cases.append(('rule_type_top_module', 'top_module_as_array.json', nc))

nc = clone_base()
nc['defines'] = ["bad_item"]
negative_cases.append(('rule_type_define_item', 'defines_item_as_string.json', nc))

nc = clone_base()
nc['modules'][0]['name'] = 456
negative_cases.append(('rule_type_module_name', 'module_name_as_number.json', nc))

nc = clone_base()
nc['includes'] = [123, 456]
negative_cases.append(('rule_type_include_item', 'includes_item_not_string.json', nc))

nc = clone_base()
nc['modules'][0]['ports'][0]['signed'] = "yes"
negative_cases.append(('rule_type_signed', 'signed_as_string.json', nc))

# --- Enum violations ---
nc = clone_base()
nc['modules'][0]['ports'][0]['direction'] = "bidir"
negative_cases.append(('rule_enum_direction_bidir', 'direction_bidir.json', nc))

nc = clone_base()
nc['modules'][0]['ports'][0]['direction'] = "invalid"
negative_cases.append(('rule_enum_direction_invalid', 'direction_invalid.json', nc))

nc = clone_base()
nc['modules'][0]['always_blocks'] = [{"id": "b1", "type": "always_bad", "body": []}]
negative_cases.append(('rule_enum_always_type', 'bad_always_type.json', nc))

nc = clone_base()
nc['metadata'] = {"design_name": "test", "top_module": "test", "generated_at": "not-a-date"}
# No format validation in draft-07 by default with jsonschema 2.6.0, but worth testing
negative_cases.append(('rule_metadata_date', 'bad_date_format.json', nc))

# --- Name uniqueness violations (business rules not caught by schema) ---
nc = clone_base()
nc['modules'].append(deep_clone(nc['modules'][0]))
# Duplicate module names - not caught by schema directly
negative_cases.append(('rule_B008_dup_module_name', 'dup_module_name.json', nc))

nc = clone_base()
nc['modules'][0]['ports'].append({"name": "clk", "direction": "input", "data_type": "wire", "width": 1})
# Duplicate port name - schema doesn't enforce uniqueness
negative_cases.append(('rule_B002_dup_port_name', 'dup_port_name.json', nc))

nc = clone_base()
nc['modules'][0]['signals'].append({"name": "cnt", "type": "reg", "width": 8})
# Duplicate signal name
negative_cases.append(('rule_B001_dup_signal_name', 'dup_signal_name.json', nc))

# --- Instance module not existing ---
nc = clone_base()
nc['modules'][0]['instances'] = [{"name": "u_x", "module": "non_existent_module", "port_connections": []}]
negative_cases.append(('rule_B003_bad_instance', 'nonexistent_module.json', nc))

# --- Add two more negative tests for completeness ---
nc = clone_base()
nc['modules'][0]['parameters'] = [{"name": "X", "type": "parameter", "value": 123}]
# Parameter value should be string but we put number directly
negative_cases.append(('rule_type_param_value', 'param_value_as_number.json', nc))

nc = clone_base()
nc['defines'] = {"name": "X", "value": "1"}
# Defines should be array, not object
negative_cases.append(('rule_type_defines', 'defines_as_object.json', nc))


for rule_dir, fname, data in negative_cases:
    rule_path = os.path.join(NEG_DIR, rule_dir)
    os.makedirs(rule_path, exist_ok=True)
    with open(os.path.join(rule_path, fname), 'w') as f:
        json.dump(data, f, indent=2)


# ===== Robustness Cases =====
robustness_cases = []

robustness_cases.append(('empty_file.json', ''))
robustness_cases.append(('not_json.txt', 'This is not JSON content'))
robustness_cases.append(('xml_content.xml', '<?xml version="1.0"?><root><item>value</item></root>'))
robustness_cases.append(('truncated.json', '{"version": "1.0.0", "metadata": {'))

def make_deep_nested(depth):
    if depth <= 0:
        return {"ref": "x"}
    return {"op": "+", "left": make_deep_nested(depth - 1), "right": {"literal": "1'b1"}}

deep_data = clone_base()
deep_data['modules'][0]['assignments'] = [{
    "lhs": {"ref": "cnt"},
    "rhs": make_deep_nested(600),
    "blocking": True
}]
robustness_cases.append(('deep_nested_600.json', json.dumps(deep_data, indent=2)))

long_data = clone_base()
long_data['version'] = 'x' * 100000
robustness_cases.append(('long_version_string.json', json.dumps(long_data, indent=2)))

null_data = clone_base()
null_data['version'] = None
robustness_cases.append(('null_version.json', json.dumps(null_data, indent=2)))

bool_data = 'true'
robustness_cases.append(('boolean_root.json', bool_data))

arr_root = json.dumps([1, 2, 3])
robustness_cases.append(('array_root.json', arr_root))

# Additional robustness: unicode in strings
unicode_data = clone_base()
unicode_data['metadata']['design_name'] = "\u00e9\u00e8\u00f1"
robustness_cases.append(('unicode_design_name.json', json.dumps(unicode_data, indent=2)))

# deeply nested object (not body)
deep_obj = clone_base()
d = deep_obj
for _ in range(200):
    d['metadata'] = {"design_name": "nested", "top_module": "x"}
    d = d['metadata']
robustness_cases.append(('deeply_nested_meta.json', json.dumps(deep_obj, indent=2)))

# Extremely large number
large_num = clone_base()
large_num['modules'][0]['ports'][0]['width'] = 10**10
robustness_cases.append(('huge_width.json', json.dumps(large_num, indent=2)))

for fname, content in robustness_cases:
    with open(os.path.join(ROB_DIR, fname), 'w') as f:
        f.write(content)


# ===== Manifest CSV =====
# Determine expected keywords for robustness: valid JSON that conforms to schema expects "true",
# invalid/non-JSON expects "false"
ROBUSTNESS_EXPECT = {
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
}

import csv
manifest_path = os.path.join(TEST_DIR, 'manifest.csv')
with open(manifest_path, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['file', 'category', 'expected_keyword'])
    for name in positive_cases:
        fpath = f'positive/{name}.json'
        writer.writerow([fpath, 'positive', 'true'])
    for rule_dir, fname, _ in negative_cases:
        fpath = f'negative/{rule_dir}/{fname}'
        writer.writerow([fpath, 'negative', 'false'])
    for fname, _ in robustness_cases:
        fpath = f'robustness/{fname}'
        writer.writerow([fpath, 'robustness', ROBUSTNESS_EXPECT.get(fname, 'false')])

print(f"Positive cases: {len(positive_cases)}")
print(f"Negative cases: {len(negative_cases)}")
print(f"Robustness cases: {len(robustness_cases)}")
print(f"Total: {len(positive_cases) + len(negative_cases) + len(robustness_cases)}")
print(f"Manifest: {manifest_path}")
