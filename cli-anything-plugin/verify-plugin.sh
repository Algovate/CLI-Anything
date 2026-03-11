#!/usr/bin/env bash
# Verify cli-anything plugin structure

echo "Verifying cli-anything plugin structure..."
echo ""

ERRORS=0

# Check required files
check_file() {
    if [ -f "$1" ]; then
        echo "✓ $1"
    else
        echo "✗ $1 (MISSING)"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "Required files:"
check_file ".claude-plugin/plugin.json"
check_file "README.md"
check_file "LICENSE"
check_file "commands/cli-anything.md"
check_file "commands/default.md"
check_file "commands/list.md"
check_file "commands/refine.md"
check_file "commands/test.md"
check_file "commands/validate.md"
check_file "scripts/setup-cli-anything.sh"
check_file "skills/cli-anything/SKILL.md"

echo ""
echo "Checking plugin.json schema compatibility..."
if python3 -c "
import json, re, sys
from pathlib import Path

plugin_path = Path('.claude-plugin/plugin.json')
try:
    plugin = json.loads(plugin_path.read_text())
except Exception:
    sys.exit(1)

errors = []

for field in ('name', 'version', 'description', 'author'):
    if field not in plugin:
        errors.append(f'missing required field: {field}')

name = plugin.get('name')
if not isinstance(name, str) or not name:
    errors.append('name must be a non-empty string')
elif not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', name):
    errors.append('name must be kebab-case')

version = plugin.get('version')
if not isinstance(version, str) or not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?', version):
    errors.append('version must be semver (e.g. 1.0.0)')

description = plugin.get('description')
if not isinstance(description, str) or not description.strip():
    errors.append('description must be a non-empty string')

author = plugin.get('author')
if isinstance(author, dict):
    if not isinstance(author.get('name'), str) or not author['name'].strip():
        errors.append('author.name must be a non-empty string')
elif not isinstance(author, str) or not author.strip():
    errors.append('author must be a non-empty string or an object with name')


if errors:
    for err in errors:
        print(err)
    sys.exit(2)
" 2>/dev/null; then
    echo "✓ plugin.json matches required schema fields"
else
    echo "✗ plugin.json failed schema validation"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "../.claude-plugin/marketplace.json" ]; then
    echo ""
    echo "Checking marketplace.json schema compatibility..."
    if python3 -c "
import json, re, sys
from pathlib import Path

market_path = Path('../.claude-plugin/marketplace.json')
try:
    market = json.loads(market_path.read_text())
except Exception:
    sys.exit(1)

errors = []

for field in ('name', 'owner', 'plugins'):
    if field not in market:
        errors.append(f'missing required top-level field: {field}')

if not isinstance(market.get('name'), str) or not market['name'].strip():
    errors.append('marketplace name must be a non-empty string')

owner = market.get('owner')
if isinstance(owner, dict):
    if not isinstance(owner.get('name'), str) or not owner['name'].strip():
        errors.append('owner.name must be a non-empty string')
else:
    errors.append('owner must be an object with name')

plugins = market.get('plugins')
if not isinstance(plugins, list) or not plugins:
    errors.append('plugins must be a non-empty array')
else:
    for i, item in enumerate(plugins):
        if not isinstance(item, dict):
            errors.append(f'plugins[{i}] must be an object')
            continue
        for field in ('name', 'version', 'source', 'description', 'author'):
            if field not in item:
                errors.append(f'plugins[{i}] missing field: {field}')
        name = item.get('name')
        if not isinstance(name, str) or not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', name or ''):
            errors.append(f'plugins[{i}].name must be kebab-case')
        version = item.get('version')
        if not isinstance(version, str) or not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?', version):
            errors.append(f'plugins[{i}].version must be semver')
        source = item.get('source')
        if not isinstance(source, str) or not source.startswith('./'):
            errors.append(f'plugins[{i}].source must be a relative path starting with ./')

if errors:
    for err in errors:
        print(err)
    sys.exit(2)
" 2>/dev/null; then
        echo "✓ marketplace.json matches required schema fields"
    else
        echo "✗ marketplace.json failed schema validation"
        ERRORS=$((ERRORS + 1))
    fi

    echo ""
    echo "Checking plugin/marketplace consistency..."
    if python3 -c "
import json, sys
from pathlib import Path

plugin = json.loads(Path('.claude-plugin/plugin.json').read_text())
market = json.loads(Path('../.claude-plugin/marketplace.json').read_text())

entries = [p for p in market.get('plugins', []) if p.get('source') == './cli-anything-plugin']
if len(entries) != 1:
    print('marketplace must contain exactly one plugin entry with source ./cli-anything-plugin')
    sys.exit(2)

entry = entries[0]
if entry.get('name') != plugin.get('name'):
    print('name mismatch between plugin.json and marketplace.json')
    sys.exit(2)
if entry.get('version') != plugin.get('version'):
    print('version mismatch between plugin.json and marketplace.json')
    sys.exit(2)
" 2>/dev/null; then
        echo "✓ plugin.json and marketplace.json are consistent"
    else
        echo "✗ plugin/marketplace consistency check failed"
        ERRORS=$((ERRORS + 1))
    fi
fi

echo ""
echo "Checking script permissions..."
if [ -x "scripts/setup-cli-anything.sh" ]; then
    echo "✓ setup-cli-anything.sh is executable"
else
    echo "✗ setup-cli-anything.sh is not executable"
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✓ All checks passed! Plugin is ready."
    exit 0
else
    echo "✗ $ERRORS error(s) found. Please fix before publishing."
    exit 1
fi
