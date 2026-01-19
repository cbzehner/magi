# Magi

Query multiple AI advisors (Gemini, Codex, Claude) in parallel and synthesize their responses into unified recommendations.

> *Three minds. One synthesis.*
>
> Named for the biblical wise men who offered counsel—and for fans of giant
> robots, NERV's [MAGI system](https://evangelion.fandom.com/wiki/MAGI): three
> computers with distinct perspectives that vote on critical decisions.

## Why Use This?

- **Multiple perspectives**: Get advice from Gemini (web search, 1M context), Codex (fast, sandboxed), and Claude (deep reasoning)
- **Automatic synthesis**: Identifies consensus, complements, and conflicts across advisors
- **Better decisions**: Cross-reference recommendations to catch blind spots

## Prerequisites

You must have the Gemini and Codex CLIs installed and authenticated:

```bash
# Gemini CLI
npm install -g @google/gemini-cli
gemini --login

# Codex CLI
npm install -g @openai/codex
codex login
```

Verify installation:
```bash
~/.claude/skills/magi/scripts/check_prereqs.sh
```

## Installation

### From Marketplace

```bash
# Add the marketplace
/plugin marketplace add cbzehner/claude-skill-magi

# Install the skill
/plugin install magi@cbzehner
```

### Manual Installation

Clone into your `.claude/skills/` directory:

```bash
cd ~/.claude/skills/
git clone https://github.com/cbzehner/claude-skill-magi.git magi
```

## Usage

The skill triggers automatically when you mention:
- "plan", "debug", "research"
- "alternative perspective"
- "ask Gemini", "ask Codex", "ask Claude"

### Example

```
You: Help me plan how to implement authentication for my app

Claude: [Queries all 3 advisors in parallel, synthesizes responses]

Based on input from Gemini, Codex, and Claude:

**Consensus**: All recommend JWT with OAuth providers
**Gemini**: Google/GitHub OAuth integration (found current best practices)
**Codex**: jsonwebtoken + passport middleware pattern
**Claude**: Consider XSS risks, use httpOnly cookies

Recommended approach: Use passport.js with JWT stored in httpOnly
cookies. Implement Google OAuth first, add GitHub later...
```

## How It Works

```
Orchestrator (Claude Code)
     |
     +-- Bash --> ask_gemini.sh --> Gemini CLI --> Google API
     |
     +-- Bash --> ask_codex.sh --> Codex CLI --> OpenAI API
     |
     +-- Task (opus) --> Claude subagent --> (direct response)
```

The Claude advisor uses a Task subagent instead of CLI to avoid session contention. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

## Advisor Strengths

| Advisor | Best For | Why |
|---------|----------|-----|
| Gemini | Web/API docs, current info | Web search, 1M token context |
| Codex | Fast analysis, security | Speed, sandboxing |
| Claude | Architecture, code review | Deep reasoning (Opus) |

## Files

```
magi/
├── SKILL.md              # Main skill definition
├── README.md             # This file
├── LICENSE               # MIT
├── scripts/
│   ├── ask_gemini.sh     # Gemini CLI wrapper
│   ├── ask_codex.sh      # Codex CLI wrapper
│   └── check_prereqs.sh  # Verify CLIs installed
├── docs/
│   ├── ARCHITECTURE.md   # Why hybrid approach
│   └── REFERENCE.md      # Templates, patterns, handling
└── examples/
    ├── planning.md       # Feature planning example
    ├── debugging.md      # Error debugging example
    └── research.md       # Library research example
```

## Privacy & Cost

**Data sent**: Your prompts are sent to Google (Gemini), OpenAI (Codex), and Anthropic (Claude) APIs.

**Cost**: Each query invokes 3 AI models. Monitor your API usage accordingly.

## License

MIT
