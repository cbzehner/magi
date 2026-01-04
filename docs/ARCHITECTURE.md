# Magi Architecture

## Overview

This skill queries three AI advisors in parallel and synthesizes their responses.

**Key insight**: The Claude advisor uses a Task subagent (which IS Claude), while Gemini/Codex use their respective CLIs via Bash.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         ORCHESTRATOR (Main Claude Code)                          │
│                                                                                  │
│  Receives user request, formulates advisor prompt, runs all 3 in parallel       │
└─────────────────────────────────────────────────────────────────────────────────┘
           │                          │                          │
           │ Bash                     │ Bash                     │ Task subagent
           │                          │                          │ model: opus
           ▼                          ▼                          ▼
┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
│      GEMINI       │      │      CODEX        │      │      CLAUDE       │
│                   │      │                   │      │                   │
│  gemini CLI       │      │  codex CLI        │      │  Subagent just    │
│  --sandbox        │      │  --sandbox        │      │  THINKS and       │
│  -o text          │      │  read-only        │      │  responds         │
│                   │      │                   │      │                   │
│                   │      │                   │      │  No subprocess    │
│                   │      │                   │      │  No CLI           │
│                   │      │                   │      │  No API call      │
└───────────────────┘      └───────────────────┘      └───────────────────┘
           │                          │                          │
           ▼                          ▼                          │
┌───────────────────┐      ┌───────────────────┐                 │
│   Google Gemini   │      │   OpenAI Codex    │                 │
│      API          │      │      API          │                 │
└───────────────────┘      └───────────────────┘                 │
           │                          │                          │
           └──────────────────────────┼──────────────────────────┘
                                      │
                                      ▼
                              ORCHESTRATOR
                              synthesizes all 3 responses
```

## Why This Hybrid Approach?

### Claude: Task Subagent (not CLI)

Running `claude -p` as a subprocess from within Claude Code causes hangs due to:
- Session contention (both access `~/.claude/` files)
- Rate limiting (both hit Anthropic API)
- Lock file conflicts

**Solution**: Use a Task subagent with `model: "opus"`. The subagent IS Claude - it doesn't need to spawn a subprocess or call an API. It just thinks and responds.

```
OLD: claude -p subprocess          NEW: Task subagent
═══════════════════════            ═══════════════════

Orchestrator                       Orchestrator
     │                                  │
     └── Bash                           └── Task (opus)
           │                                  │
           └── claude -p                      └── (just responds)
                  │                                No process
                  └── API call                     No CLI
                         │                         No API
                    MAY HANG                       RELIABLE
```

### Gemini/Codex: Bash (not subagents)

Task subagents can't run Bash commands due to permission restrictions. So Gemini and Codex must be called via Bash directly from the orchestrator.

The bash scripts (`ask_gemini.sh`, `ask_codex.sh`) provide:
- Input validation
- Error handling with clear banners
- Consistent interface

## Parallel Execution

Run all three in a single orchestrator turn:

```
# In parallel:
Bash: scripts/ask_gemini.sh "[prompt]" &
Bash: scripts/ask_codex.sh "[prompt]" &
Task: Claude subagent (opus) with "[prompt]"
wait
```

Or use background execution:
```
Bash (background): scripts/ask_gemini.sh "[prompt]"
Bash (background): scripts/ask_codex.sh "[prompt]"
Task (background): Claude subagent
TaskOutput: wait for all 3
```

## Model Selection

| Advisor | Method | Model | Rationale |
|---------|--------|-------|-----------|
| Gemini | Bash → CLI | (Gemini's default) | Web search, 1M context |
| Codex | Bash → CLI | gpt-5.2-codex | Fast, sandboxed |
| Claude | Task subagent | **opus** | Deep reasoning, best model |

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions |
| `scripts/ask_gemini.sh` | Gemini CLI wrapper with validation |
| `scripts/ask_codex.sh` | Codex CLI wrapper with validation |
| `references/ARCHITECTURE.md` | This file |
| `references/TOOL_CAPABILITIES.md` | CLI reference |
