# Pipecat Context Hub

Local-first MCP server providing fresh Pipecat docs, examples, and API context for AI coding agents.

Use when: building Pipecat voice/multimodal AI apps, need framework docs or examples, checking deprecation status.

## Install

```bash
# Populate local index (first time)
uvx pipecat-ai-context-hub refresh

# Start MCP server
uvx pipecat-ai-context-hub serve
```

Or install persistently:
```bash
uv tool install pipecat-ai-context-hub
pipecat-context-hub refresh
pipecat-context-hub serve
```

## MCP Config (`.mcp.json` for opencode)

```json
{
  "mcpServers": {
    "pipecat-context-hub": {
      "command": "uvx",
      "args": ["pipecat-ai-context-hub", "serve"]
    }
  }
}
```

For persistent install:
```json
{
  "mcpServers": {
    "pipecat-context-hub": {
      "command": "pipecat-context-hub",
      "args": ["serve"]
    }
  }
}
```

## MCP Tools

| Tool | Use when |
|---|---|
| `search_docs` | "How do I ...?" — conceptual questions, guides |
| `get_doc` | Retrieve a specific doc page by ID/path |
| `search_examples` | "Show me an example of ..." |
| `get_example` | Get full source for a specific example |
| `search_api` | Class definitions, method signatures, frame types |
| `get_code_snippet` | Get targeted code by symbol name or file path |
| `check_deprecation` | Verify if an import path is deprecated/removed |

## Multi-Concept Queries

Use `+` or `&` as delimiters:
```
search_docs("TTS + STT")
search_examples("idle timeout + function calling + Gemini")
```

## Version-Aware Queries

```bash
uvx pipecat-ai-context-hub refresh --framework-version v0.0.96
# or
PIPECAT_HUB_FRAMEWORK_VERSION=v0.0.96 uvx pipecat-ai-context-hub refresh
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| Empty results | `uvx pipecat-ai-context-hub refresh` |
| Stale data | `uvx pipecat-ai-context-hub refresh --force` |
| Index corruption | `uvx pipecat-ai-context-hub refresh --force --reset-index` |
| `serve` exits with code 2 | Index is empty — run `refresh` first |

## Env Vars

- `PIPECAT_HUB_EXTRA_REPOS` — comma-separated extra repos to index
- `PIPECAT_HUB_STALE_AFTER_DAYS` — default 7, age before staleness warning
- `PIPECAT_HUB_WARMUP` — `1` to pre-warm models on boot
