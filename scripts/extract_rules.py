#!/usr/bin/env python3
import json
import os
import hashlib

SPECS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'specs')
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')

def compute_hash(path):
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()

def extract_schema_rules(schema):
    rules = []
    rid = 0

    def walk(obj, path='$', required_parent=None):
        nonlocal rid
        if not isinstance(obj, dict):
            return

        if 'type' in obj:
            rid += 1
            rules.append({
                'id': f'S{rid:03d}',
                'source': 'schema',
                'path': path,
                'constraint': 'type',
                'expect': obj['type'],
                'description': f'Field at {path} must be of type {obj["type"]}'
            })

        if 'required' in obj and required_parent is None:
            for field in obj['required']:
                rid += 1
                rules.append({
                    'id': f'S{rid:03d}',
                    'source': 'schema',
                    'path': f'{path}',
                    'constraint': 'required',
                    'expect': field,
                    'description': f'Required field "{field}" must exist at {path}'
                })

        if 'enum' in obj:
            rid += 1
            rules.append({
                'id': f'S{rid:03d}',
                'source': 'schema',
                'path': path,
                'constraint': 'enum',
                'expect': obj['enum'],
                'description': f'Field at {path} must be one of {obj["enum"]}'
            })

        if 'minimum' in obj:
            rid += 1
            rules.append({
                'id': f'S{rid:03d}',
                'source': 'schema',
                'path': path,
                'constraint': 'minimum',
                'expect': obj['minimum'],
                'description': f'Field at {path} must be >= {obj["minimum"]}'
            })

        if 'maximum' in obj:
            rid += 1
            rules.append({
                'id': f'S{rid:03d}',
                'source': 'schema',
                'path': path,
                'constraint': 'maximum',
                'expect': obj['maximum'],
                'description': f'Field at {path} must be <= {obj["maximum"]}'
            })

        if 'minItems' in obj:
            rid += 1
            rules.append({
                'id': f'S{rid:03d}',
                'source': 'schema',
                'path': path,
                'constraint': 'minItems',
                'expect': obj['minItems'],
                'description': f'Array at {path} must have at least {obj["minItems"]} items'
            })

        if 'maxItems' in obj:
            rid += 1
            rules.append({
                'id': f'S{rid:03d}',
                'source': 'schema',
                'path': path,
                'constraint': 'maxItems',
                'expect': obj['maxItems'],
                'description': f'Array at {path} must have at most {obj["maxItems"]} items'
            })

        if 'additionalProperties' in obj and obj['additionalProperties'] is False:
            rid += 1
            rules.append({
                'id': f'S{rid:03d}',
                'source': 'schema',
                'path': path,
                'constraint': 'additionalProperties',
                'expect': False,
                'description': f'Object at {path} must not have additional properties'
            })

        if 'pattern' in obj:
            rid += 1
            rules.append({
                'id': f'S{rid:03d}',
                'source': 'schema',
                'path': path,
                'constraint': 'pattern',
                'expect': obj['pattern'],
                'description': f'Field at {path} must match pattern {obj["pattern"]}'
            })

        if 'properties' in obj:
            for prop_name, prop_schema in obj['properties'].items():
                required_list = obj.get('required', [])
                rp = required_list if prop_name in required_list else None
                walk(prop_schema, f'{path}.{prop_name}', rp)
            if required_parent and path == '$':
                pass

        if 'items' in obj:
            walk(obj['items'], f'{path}[]')

        if 'oneOf' in obj:
            for i, sub in enumerate(obj['oneOf']):
                walk(sub, f'{path}.oneOf[{i}]')

        if 'additionalProperties' in obj and isinstance(obj['additionalProperties'], dict):
            walk(obj['additionalProperties'], f'{path}.additionalProperties')

    walk(schema)
    return rules


def main():
    schema_path = os.path.join(SPECS_DIR, 'schema_v1.json')
    with open(schema_path) as f:
        schema = json.load(f)

    spec_path = os.path.join(SPECS_DIR, 'VERILOG_JSON_BIDIRECTIONAL_SPEC.md')
    spec_hash = compute_hash(spec_path)

    schema_rules = extract_schema_rules(schema)

    business_rules = [
        {
            'id': 'B001',
            'source': 'business',
            'path': 'modules[].signals',
            'constraint': 'unique_signal_names',
            'description': 'Signal names within a module must be unique'
        },
        {
            'id': 'B002',
            'source': 'business',
            'path': 'modules[].ports',
            'constraint': 'unique_port_names',
            'description': 'Port names within a module must be unique'
        },
        {
            'id': 'B003',
            'source': 'business',
            'path': 'modules[].instances',
            'constraint': 'instance_module_resolvable',
            'description': 'Instance module references must refer to an existing module name'
        },
        {
            'id': 'B004',
            'source': 'business',
            'path': 'modules[].instances[].port_connections',
            'constraint': 'port_connection_count',
            'description': 'Port connection count should match target module port count'
        },
        {
            'id': 'B005',
            'source': 'business',
            'path': 'modules[].parameters',
            'constraint': 'parameter_value_type',
            'description': 'Parameter values must be string representations (not numeric types)'
        },
        {
            'id': 'B006',
            'source': 'business',
            'path': 'modules[].always_blocks',
            'constraint': 'always_block_id_unique',
            'description': 'Always block IDs within a module must be unique'
        },
        {
            'id': 'B007',
            'source': 'business',
            'path': 'modules[].instances[].name',
            'constraint': 'instance_name_unique',
            'description': 'Instance names within a module must be unique'
        },
        {
            'id': 'B008',
            'source': 'business',
            'path': 'modules[]',
            'constraint': 'module_name_unique',
            'description': 'Module names in the design must be unique'
        },
        {
            'id': 'B009',
            'source': 'business',
            'path': 'modules[].ports[].direction',
            'constraint': 'port_direction_connection_match',
            'description': 'Input ports must not be driven as outputs in port connections'
        },
        {
            'id': 'B010',
            'source': 'business',
            'path': 'version',
            'constraint': 'version_format',
            'description': 'Version string should follow semantic versioning (x.y.z)'
        },
        {
            'id': 'B011',
            'source': 'business',
            'path': 'modules[].functions[].body',
            'constraint': 'function_body_has_return',
            'description': 'Function body must contain at least one return statement'
        },
        {
            'id': 'B012',
            'source': 'business',
            'path': 'modules[].always_blocks[].sensitivity',
            'constraint': 'sensitivity_list_comb',
            'description': 'always_comb block should not have a sensitivity list'
        },
    ]

    full_rules = schema_rules + business_rules

    result = {
        'spec_version': schema.get('version', '1.0.0'),
        'spec_hash': spec_hash,
        'total_rules': len(full_rules),
        'schema_rules_count': len(schema_rules),
        'business_rules_count': len(business_rules),
        'rules': full_rules
    }

    os.makedirs(OUT_DIR, exist_ok=True)
    with open(os.path.join(OUT_DIR, 'full_rules.json'), 'w') as f:
        json.dump(result, f, indent=2)

    with open(os.path.join(OUT_DIR, 'rules_from_schema.json'), 'w') as f:
        json.dump({'spec_hash': spec_hash, 'rules': schema_rules}, f, indent=2)

    with open(os.path.join(OUT_DIR, 'rules_business.json'), 'w') as f:
        json.dump({'spec_hash': spec_hash, 'rules': business_rules}, f, indent=2)

    print(f"Rules extracted: {len(full_rules)} total ({len(schema_rules)} schema + {len(business_rules)} business)")
    print(f"Spec hash: {spec_hash}")
    print(f"Output: full_rules.json, rules_from_schema.json, rules_business.json")


if __name__ == '__main__':
    main()
