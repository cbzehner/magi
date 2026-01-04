#!/bin/bash
# Check that required CLIs are installed
# Usage: check_prereqs.sh

set -euo pipefail

MISSING=0

echo "Checking prerequisites for magi..."
echo ""

# Check Gemini CLI
if command -v gemini &>/dev/null; then
    echo "[OK] Gemini CLI found"
else
    echo "[MISSING] Gemini CLI"
    echo "         Install: npm install -g @google/gemini-cli"
    echo "         Auth:    gemini --login"
    MISSING=1
fi

# Check Codex CLI
if command -v codex &>/dev/null; then
    echo "[OK] Codex CLI found"
else
    echo "[MISSING] Codex CLI"
    echo "         Install: npm install -g @openai/codex"
    echo "         Auth:    codex login"
    MISSING=1
fi

echo ""

if [ $MISSING -eq 1 ]; then
    echo "Some prerequisites are missing. Install them and try again."
    exit 1
else
    echo "All prerequisites installed!"
    exit 0
fi
