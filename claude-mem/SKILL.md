---
name: claude-mem
description: Install and configure claude-mem for persistent memory across OpenCode sessions. Use when the user wants to set up persistent memory, install claude-mem, or configure memory compression for their AI coding sessions.
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
---

# Claude-Mem for OpenCode

Install and configure claude-mem to preserve context across OpenCode sessions. Claude-Mem automatically captures tool usage observations, generates semantic summaries, and makes them available to future sessions.

## When to Use

- "Install claude-mem", "Set up persistent memory"
- "Remember context between sessions", "Keep session history"
- "Configure memory compression", "Set up memory search"
- Any request to maintain knowledge across coding sessions

## Quick Start

### Install for OpenCode

```bash
npx claude-mem install --ide opencode
```

Or install manually:

```bash
# Clone the repository
git clone https://github.com/thedotmack/claude-mem.git ~/.claude-mem

# Install dependencies
cd ~/.claude-mem && npm install

# Configure for OpenCode
cat > ~/.claude-mem/settings.json << 'EOF'
{
  "CLAUDE_MEM_MODE": "code",
  "WORKER_PORT": 37777,
  "DATA_DIR": "~/.claude-mem/data",
  "LOG_LEVEL": "info"
}
EOF
```

### Verify Installation

```bash
# Check if worker is running
curl http://localhost:37777/health

# Check memory database
ls -la ~/.claude-mem/data/

# View memory stats
curl http://localhost:37777/api/stats
```

## How It Works

**Core Components:**

1. **5 Lifecycle Hooks** - SessionStart, UserPromptSubmit, PostToolUse, Stop, SessionEnd
2. **Worker Service** - Local HTTP API with web viewer UI and search endpoints
3. **SQLite Database** - Stores sessions, observations, summaries
4. **mem-search Skill** - Natural language queries with progressive disclosure
5. **Chroma Vector Database** - Hybrid semantic + keyword search

## Configuration

Settings are managed in `~/.claude-mem/settings.json`:

```json
{
  "CLAUDE_MEM_MODE": "code",
  "WORKER_PORT": 37777,
  "DATA_DIR": "~/.claude-mem/data",
  "LOG_LEVEL": "info",
  "AI_PROVIDER": "openai",
  "AI_MODEL": "gpt-4",
  "CONTEXT_INJECTION": {
    "enabled": true,
    "max_tokens": 8000,
    "injection_point": "system_prompt"
  }
}
```

### Mode Configuration

Claude-Mem supports multiple workflow modes:

| Mode | Description |
|------|-------------|
| `code` | Default English mode |
| `code--zh` | Simplified Chinese mode |
| `code--ja` | Japanese mode |

Change mode by editing `~/.claude-mem/settings.json`:

```json
{
  "CLAUDE_MEM_MODE": "code--zh"
}
```

## MCP Search Tools

Claude-Mem provides intelligent memory search through **3 MCP tools**:

### The 3-Layer Workflow

1. **`search`** - Get compact index with IDs (~50-100 tokens/result)
2. **`timeline`** - Get chronological context around interesting results
3. **`get_observations`** - Fetch full details ONLY for filtered IDs (~500-1,000 tokens/result)

### Usage Example

```typescript
// Step 1: Search for index
search(query="authentication bug", type="bugfix", limit=10)

// Step 2: Review index, identify relevant IDs (e.g., #123, #456)

// Step 3: Fetch full details
get_observations(ids=[123, 456])
```

**~10x token savings** by filtering before fetching details.

## Integration with OpenCode Skills

Claude-Mem works seamlessly with existing OpenCode skills:

### mem-search Integration

The `mem-search` skill uses claude-mem's search capabilities:

```bash
# Search memory for authentication patterns
mem-search "authentication implementation"

# Find recent bug fixes
mem-search "bugfix" --type=bugfix

# Get timeline of changes
mem-search --timeline --last=7d
```

### knowledge-agent Integration

Build knowledge bases from your code and query them:

```bash
# Index codebase
knowledge-agent index ./src

# Query knowledge base
knowledge-agent query "How does auth work?"
```

## Web Viewer

Access the memory web viewer at:

```
http://localhost:37777
```

Features:
- Real-time memory stream
- Search interface
- Session history
- Observation details

## Privacy Control

Use `<private>` tags to exclude sensitive content from storage:

```html
<!-- This content will NOT be stored -->
<private>
  API_KEY=sk-1234567890
  PASSWORD=mysecret
</private>

<!-- This content WILL be stored -->
<public>
  Implemented user authentication flow
</public>
```

## Troubleshooting

### Worker Not Starting

```bash
# Check port availability
lsof -i :37777

# Check logs
tail -f ~/.claude-mem/logs/worker.log

# Restart worker
pkill -f "claude-mem worker"
cd ~/.claude-mem && npm run worker
```

### Memory Not Persisting

```bash
# Check database
ls -la ~/.claude-mem/data/

# Check settings
cat ~/.claude-mem/settings.json

# Verify hooks are registered
ls -la ~/.claude/hooks/
```

### Search Not Working

```bash
# Check ChromaDB
curl http://localhost:8000/api/v1/heartbeat

# Rebuild index
cd ~/.claude-mem && npm run rebuild-index
```

## Advanced Configuration

### Custom AI Provider

```json
{
  "AI_PROVIDER": "anthropic",
  "AI_API_KEY": "sk-ant-...",
  "AI_MODEL": "claude-3-opus-20240229"
}
```

### Context Injection Tuning

```json
{
  "CONTEXT_INJECTION": {
    "enabled": true,
    "max_tokens": 4000,
    "layers": [
      "file_context",
      "project_context",
      "user_preferences"
    ],
    "priority": "recent"
  }
}
```

### Memory Retention

```json
{
  "RETENTION": {
    "max_days": 90,
    "max_observations": 10000,
    "compression": true,
    "archive_old": true
  }
}
```

## System Requirements

- **Node.js**: 20.0.0 or higher
- **OpenCode**: Latest version with plugin support
- **Bun**: JavaScript runtime (auto-installed if missing)
- **SQLite 3**: For persistent storage (bundled)

## See Also

- `mem-search` - Search memory with token-optimized workflows
- `knowledge-agent` - Build and query knowledge bases
- `cloud-sync` - Sync memory data to cloud storage
- `openclaw` - Configure AI gateway integration

## Support

- **Documentation**: https://docs.claude-mem.ai/
- **Issues**: https://github.com/thedotmack/claude-mem/issues
- **Repository**: https://github.com/thedotmack/claude-mem

## License

Apache 2.0 (same as claude-mem)
