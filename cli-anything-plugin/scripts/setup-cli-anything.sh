#!/usr/bin/env bash
# cli-anything plugin setup script

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Plugin info
PLUGIN_NAME="cli-anything"
PLUGIN_VERSION="1.0.3"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  cli-anything Plugin v${PLUGIN_VERSION}${NC}"
echo -e "${BLUE}  Build powerful CLI interfaces for any GUI application${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if HARNESS.md exists
HARNESS_PATH="/root/cli-anything/HARNESS.md"
if [ ! -f "$HARNESS_PATH" ]; then
    echo -e "${YELLOW}⚠️  HARNESS.md not found at $HARNESS_PATH${NC}"
    echo -e "${YELLOW}   The cli-anything methodology requires HARNESS.md${NC}"
    echo -e "${YELLOW}   You can create it or specify a custom path with --harness-path${NC}"
    echo ""
fi

# Check Python version
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Python 3 detected: ${PYTHON_VERSION}"
else
    echo -e "${RED}✗${NC} Python 3 not found. Please install Python 3.10+"
    exit 1
fi

# Check for required Python packages
echo ""
echo "Checking Python dependencies..."

check_package() {
    local package=$1
    if python3 -c "import $package" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $package installed"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $package not installed"
        return 1
    fi
}

MISSING_PACKAGES=()

check_package "click" || MISSING_PACKAGES+=("click")
check_package "pytest" || MISSING_PACKAGES+=("pytest")

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Missing packages: ${MISSING_PACKAGES[*]}${NC}"
    echo -e "${YELLOW}Install with: pip install ${MISSING_PACKAGES[*]}${NC}"
fi

install_alias() {
    local path="$1"
    local description="$2"
    local body="$3"
    if [ -d "$path" ]; then
        echo -e "${YELLOW}⚠${NC} Cannot write alias at ${path}: path is a directory."
        echo -e "${YELLOW}   Remove/rename it and re-run setup to restore this alias.${NC}"
        return 1
    fi

    if ! cat > "$path" <<EOF
---
description: $description
---
$body
EOF
    then
        echo -e "${YELLOW}⚠${NC} Failed to write alias at ${path}."
        return 1
    fi
}

install_command_aliases() {
    # Install user-level command aliases for Claude Code v2.
    # Some builds expose plugin commands only in namespaced form (`/cli-anything:default`).
    # These aliases make `/cli-anything` and related commands always available.
    local commands_dir="${HOME}/.claude/commands"
    local alias_dir="${commands_dir}/cli-anything"
    local alias_failures=0

    echo ""
    echo "Installing command aliases in ${commands_dir} ..."

    if ! mkdir -p "${commands_dir}" "${alias_dir}" 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC} Cannot write ${commands_dir}. Skipping alias installation."
        echo -e "${YELLOW}   You can still use namespaced commands like /cli-anything:default${NC}"
        return 0
    fi

    if ! install_alias \
        "${commands_dir}/cli-anything.md" \
        "Build a CLI-Anything harness for a local path or repository." \
        'Read HARNESS.md from the installed cli-anything plugin if available, then execute the full cli-anything build workflow for: $ARGUMENTS'
    then
        alias_failures=$((alias_failures + 1))
    fi

    if ! install_alias \
        "${alias_dir}/default.md" \
        "Build a CLI-Anything harness for a local path or repository." \
        'Read HARNESS.md from the installed cli-anything plugin if available, then execute the full cli-anything build workflow for: $ARGUMENTS'
    then
        alias_failures=$((alias_failures + 1))
    fi

    if ! install_alias \
        "${alias_dir}/refine.md" \
        "Refine an existing harness and expand capability coverage." \
        'Read HARNESS.md from the installed cli-anything plugin if available, then refine the existing harness using this input: $ARGUMENTS'
    then
        alias_failures=$((alias_failures + 1))
    fi

    if ! install_alias \
        "${alias_dir}/test.md" \
        "Run harness tests and update TEST.md with results." \
        'Read HARNESS.md from the installed cli-anything plugin if available, then run the test workflow for: $ARGUMENTS'
    then
        alias_failures=$((alias_failures + 1))
    fi

    if ! install_alias \
        "${alias_dir}/validate.md" \
        "Validate a harness against HARNESS.md standards." \
        'Read HARNESS.md from the installed cli-anything plugin if available, then run the validation workflow for: $ARGUMENTS'
    then
        alias_failures=$((alias_failures + 1))
    fi

    if ! install_alias \
        "${alias_dir}/list.md" \
        "List discovered CLI-Anything harnesses." \
        'List and summarize discovered CLI-Anything harnesses using this input: $ARGUMENTS'
    then
        alias_failures=$((alias_failures + 1))
    fi

    if [ "${alias_failures}" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Installed command aliases at ${commands_dir}"
        return 0
    fi

    echo -e "${YELLOW}⚠${NC} Alias installation completed with ${alias_failures} error(s)."
    return 1
}

if ! install_command_aliases; then
    echo -e "${YELLOW}⚠${NC} Some commands may be unavailable until alias issues are resolved."
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Plugin installed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Available commands:"
echo ""
echo -e "  ${BLUE}/cli-anything${NC} <path-or-repo>         - Build complete CLI harness"
echo -e "  ${BLUE}/cli-anything:default${NC} <path-or-repo> - Build command (namespaced fallback)"
echo -e "  ${BLUE}/cli-anything:refine${NC} <path> [focus] - Refine existing harness"
echo -e "  ${BLUE}/cli-anything:test${NC} <path-or-repo>   - Run tests and update TEST.md"
echo -e "  ${BLUE}/cli-anything:validate${NC} <path-or-repo> - Validate against standards"
echo -e "  ${BLUE}/cli-anything:list${NC} [path-or-repo]   - List discovered harnesses"
echo ""
echo "Examples:"
echo ""
echo -e "  ${BLUE}/cli-anything${NC} /home/user/gimp"
echo -e "  ${BLUE}/cli-anything:refine${NC} /home/user/blender \"particle systems\""
echo -e "  ${BLUE}/cli-anything:test${NC} /home/user/inkscape"
echo -e "  ${BLUE}/cli-anything:validate${NC} /home/user/audacity"
echo -e "  ${BLUE}/cli-anything:list${NC} /home/user"
echo ""
echo "Documentation:"
echo ""
echo "  HARNESS.md: /root/cli-anything/HARNESS.md"
echo "  Plugin README: Use '/help cli-anything' for more info"
echo ""
echo -e "${GREEN}Ready to build CLI harnesses! 🚀${NC}"
echo ""
