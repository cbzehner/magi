#!/bin/bash
# Query Gemini CLI as an advisor
# Usage: ask_gemini.sh "prompt" [text|json]

set -euo pipefail

PROMPT="${1:-}"
FORMAT="${2:-text}"

if [ -z "$PROMPT" ]; then
    echo "" >&2
    echo "================================================" >&2
    echo "           GEMINI ADVISOR ERROR                 " >&2
    echo "================================================" >&2
    echo "Error: Prompt required" >&2
    echo "Usage: ask_gemini.sh \"prompt\" [text|json]" >&2
    echo "================================================" >&2
    exit 1
fi

case "$FORMAT" in
    text|json) ;;
    *)
        echo "" >&2
        echo "================================================" >&2
        echo "           GEMINI ADVISOR ERROR                 " >&2
        echo "================================================" >&2
        echo "Error: Invalid format: $FORMAT" >&2
        echo "Fix: Use text or json" >&2
        echo "================================================" >&2
        exit 1
        ;;
esac

if ! command -v gemini &> /dev/null; then
    echo "" >&2
    echo "================================================" >&2
    echo "           GEMINI ADVISOR ERROR                 " >&2
    echo "================================================" >&2
    echo "Error: gemini CLI not found" >&2
    echo "Fix: npm install -g @google/gemini-cli && gemini --login" >&2
    echo "================================================" >&2
    exit 1
fi

gemini "$PROMPT" --sandbox -o "$FORMAT" 2>&1 || {
    EC=$?
    echo "" >&2
    echo "================================================" >&2
    echo "           GEMINI ADVISOR ERROR                 " >&2
    echo "================================================" >&2
    echo "Error: Gemini CLI failed (exit code $EC)" >&2
    echo "Fix: Check auth with 'gemini --login' or verify prompt" >&2
    echo "================================================" >&2
    exit $EC
}
