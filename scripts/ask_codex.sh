#!/bin/bash
# Query Codex CLI as an advisor
# Usage: ask_codex.sh "prompt" [read-only|workspace-write|danger-full-access]

set -euo pipefail

PROMPT="${1:-}"
SANDBOX="${2:-read-only}"

if [ -z "$PROMPT" ]; then
    echo "" >&2
    echo "================================================" >&2
    echo "           CODEX ADVISOR ERROR                  " >&2
    echo "================================================" >&2
    echo "Error: Prompt required" >&2
    echo "Usage: ask_codex.sh \"prompt\" [read-only|workspace-write|danger-full-access]" >&2
    echo "================================================" >&2
    exit 1
fi

case "$SANDBOX" in
    read-only|workspace-write|danger-full-access) ;;
    *)
        echo "" >&2
        echo "================================================" >&2
        echo "           CODEX ADVISOR ERROR                  " >&2
        echo "================================================" >&2
        echo "Error: Invalid sandbox mode: $SANDBOX" >&2
        echo "Fix: Use read-only, workspace-write, or danger-full-access" >&2
        echo "================================================" >&2
        exit 1
        ;;
esac

if ! command -v codex &> /dev/null; then
    echo "" >&2
    echo "================================================" >&2
    echo "           CODEX ADVISOR ERROR                  " >&2
    echo "================================================" >&2
    echo "Error: codex CLI not found" >&2
    echo "Fix: npm install -g @openai/codex && codex login" >&2
    echo "================================================" >&2
    exit 1
fi

codex exec --sandbox "$SANDBOX" --skip-git-repo-check -- "$PROMPT" 2>&1 || {
    EC=$?
    echo "" >&2
    echo "================================================" >&2
    echo "           CODEX ADVISOR ERROR                  " >&2
    echo "================================================" >&2
    echo "Error: Codex CLI failed (exit code $EC)" >&2
    echo "Fix: Check auth with 'codex login' or verify prompt" >&2
    echo "================================================" >&2
    exit $EC
}
