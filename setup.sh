#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# OpenCode Config Setup
# Cross-platform (macOS, Linux, Windows via Git Bash/WSL)
# Run after cloning this repo to ~/.config/opencode
# =============================================================================

CONFIG_DIR="$HOME/.config/opencode"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[!!]${NC} $*"; }
err()  { echo -e "${RED}[ERR]${NC} $*"; }

# ---------------------------------------------------------------------------
# 1. Install plugin dependencies (oh-my-openagent, opencode-caveman, etc.)
# ---------------------------------------------------------------------------
echo "=== Installing plugin dependencies ==="
if [ -f "$CONFIG_DIR/package.json" ]; then
    cd "$CONFIG_DIR"
    npm install
    log "Plugin dependencies installed"
else
    err "package.json not found in $CONFIG_DIR"
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Install codebase-memory-mcp (global)
#    https://github.com/DeusData/codebase-memory-mcp
# ---------------------------------------------------------------------------
echo ""
echo "=== Installing codebase-memory-mcp ==="
if command -v codebase-memory-mcp &>/dev/null; then
    log "codebase-memory-mcp already installed: $(codebase-memory-mcp --version 2>&1)"
else
    warn "codebase-memory-mcp not found. Installing via npm..."
    npm install -g codebase-memory-mcp
    log "codebase-memory-mcp installed: $(codebase-memory-mcp --version 2>&1)"
fi

# ---------------------------------------------------------------------------
# 3. Custom skills reminder
# ---------------------------------------------------------------------------
echo ""
echo "=== Custom skills ==="
SKILLS_DIR="$HOME/.agents/skills"
if [ -d "$SKILLS_DIR/agent-browser" ]; then
    log "Custom skills found at $SKILLS_DIR"
else
    warn "Custom skills not found at $SKILLS_DIR"
    warn "Sync them from your other machine or clone the skills repo."
    warn "At minimum, you need: agent-browser (from ~/.agents/skills/agent-browser)"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo "=============================================="
echo -e "${GREEN}Setup complete.${NC}"
echo "Restart OpenCode for changes to take effect."
echo "=============================================="
